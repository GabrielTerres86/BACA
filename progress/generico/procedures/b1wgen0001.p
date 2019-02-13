/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +------------------------------------+------------------------------------+
  | b1wgen0001.p (Variaveis)           | EXTR0001                           |
  | blwgen0001.obtem-saldo             | EXTR0001.pc_obtem_saldo            |
  | blwgen0001.consulta-extrato        | EXTR0001.pc_consulta_extrato       |
  | blwgen0001.gera-registro-extrato   | EXTR0001.pc_gera_registro_extrato  |
  | blwgen0001.obtem-saldo-dia         | EXTR0001.pc_obtem_saldo_dia        |
  | blwgen0001.compor-saldo-dia        | EXTR0001.pc_compor_saldo_dia       |
  | b1wgen0001.obtem-saldos-anteriores | EXTR0001.pc_obtem_saldos_anteriores|
  | blwgen0001.ver_capital             | EXTR0001.pc_ver_capital            | 
  | blwgen0001.ver_saldos              | EXTR0001.pc_ver_saldos             | 
  | blwgen0001.carrega_dep_vista       | EXTR0001.pc_carrega_dep_vista      |
  | b1wgen0001.carrega_dados_atenda	   | CADA0004.pc_carrega_dados_atenda   |
  | b1wgen0001.obtem-cabecalho         | CADA0004.pc_obtem_cabecalho_atenda |
  | b1wgen0001.fgetnatopc              | CADA0004.fn_dsnatopc               |
  | b1wgen0001.fgetnrramfon	           | CADA0004.fn_nrramfon               |
  | b1wgen0001.fgetdstipcta	           | CADA0004.fn_dstipcta               |
  | b1wgen0001.fgetdssitdct	           | CADA0004.fn_dssitdct               |
  | b1wgen0001.completa-cabecalho      | CADA0004.pc_completa_cab_atenda    |
  | b1wgen0001.carrega_dep_vista       | CADA0004.pc_carrega_dep_vista      |
  | b1wgen0001.pc_obtem_medias         | EXTR0001.obtem-medias              |
  | b1wgen0001.pc_carrega_medias       | EXTR0001.carrega_medias            |
  +------------------------------------+------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/*..............................................................................

   Programa: b1wgen0001.p                  
   Autora  : Mirtes.
   Data    : 12/09/2005                      Ultima atualizacao: 30/05/2018

   Dados referentes ao programa:

   Objetivo  : BO  EXTRATO CONTA CORRENTE/ CONSULTA SALDO CONTA CORRENTE

   Alteracoes: 26/12/2005 - Inclusao das alineas de devolucao de cheque no
                            historico (Junior).
                            
               10/02/2006 - Desprezar custodia e desconto de cheques nos
                            lancamentos do dia (Junior).
                            
               22/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).

               29/05/2007 - SQLWorks - Murilo
                            Inclusao das procedures de obtencao de CPMF e 
                            medias.

               03/08/2007 - Definicoes de temp-tables para include (David).
                          - Incluir procedure carrega_dados_atenda (David).
                          - Incluir procedure extrato_investimento (Guilherme).

               03/09/2007 - Conversao de programas para BO, adicionados a este:
                          - Inclusao procedure ver_capital  (Sidnei)
                          - Inclusao procedure ver_cadastro (Sidnei)

               04/10/2007 - Retirar procedure extrato_investimento, pois foi 
                            incluida na BO b1wgen0020 (David);
                          - Retirar procedure extrato_cotas, pois foi incluida
                            na BO b1wgen0021 (David);
                          - Incluidas variaveis rd2_lshistor e rd2_contador
                            para a melhoria de performance (Evandro).

               24/10/2007 - Incluir Limpeza das Temp Tables de retorno nas
                            procedure obtem_cabecalho e carrega_dados_atenda.

               13/11/2007 - Incluir parametros para chamada das BO's b1wgen0020
                            e b1wgen0021 (David).

               22/11/2007 - Tratar consulta-extrato para Cash - FOTON (Ze).

               28/11/2007 - Separar Nome do Primeiro e Segundo Titular 
                            do Obtem-Cabec - FOTON  (Ze).

               12/12/2007 - Incluir Valor do Limite no Obtem-Cabec - FOTON (Ze)

               07/02/2008 - Incluir procedure completa-cabecalho
                          - Incluir procedure zoom-associados 
                          - Incluir procedure carrega_dep_vista 
                          - Incluir procedure carrega_medias (Guilherme).
                          - Incluir procedure saldo_utiliza (David).

               12/03/2008 - Retirar procedure saldo_utiliza (David).
                          - Adaptacoes para agendamentos (David).

               16/07/2008 - Comentario de onde a consulta-extrato eh chamada
                          - Alimentado novos campos na tt-extrato_conta  
                          - Incluir procedures tarext_cheque e 
                            gera_extrato_especial(Guilherme).

               31/07/2008 - Incluir chamada da procedure busca_anota
                            na carrega_dados_atenda
                          - Incluir chamada procedure busca_cartoes_magneticos 
                            na carrega_dados_atenda (Guilherme).
                          - Incluir chamada da procedure obtem-mensagens-alerta
                            na carrega_dados_atenda (David).

               28/08/2008 - Listar historicos 590,591,597,687 com o cdpesqbb
                          - Incluido RETURN "OK" na ver_cadastro (Guilherme).
                          - Tratamento para obter ocupacao de pessoas juridicas
                          - Chamada para procedure obtem-cartoes-magneticos
                          - Tratamento para desconto de titulos na procedure
                            ver_saldos (David).
               30/10/2008 - Incluir o historico 359 Est. Debito nos historico
                            utilizado pelo CASH para o final de semana (Ze).
 
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).

               11/02/2009 - Incluir procedure gera_extrato_tarifas (Gabriel).

               02/03/2009 - Alteracao cdempres (Diego).
                          - Incluir campo tt-cabec.inpessoa na procedure
                            obtem-cabecalho (David).
                          - Gerar log na procedure gera_extrato_tarifas (David).
                          - Ler total de descontos pela b1wgen0030(Guilherme).

               08/05/2009 - Para o zoom dos associados, mostrar somente os
                            associados da cooperativa em questao (Evandro).

               15/07/2009 - Incluir campo tt-cabec.dssititg na procedure 
                            obtem-cabecalho (Guilherme).
                          - Paginacao na zoom-associados para ayllos WEB
                            (Guilherme).
                          - Tratamento para historicos 771 e 772 (David). 

               23/09/2009 - Tratamento para listagem de depositos identificados
                            (David).
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).

               21/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).

               04/11/2009 - Incluir novas variaveis utilizadas na procedure
                            ver_saldos (David).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).
                            
               05/04/2010 - Ajustes para saldo e extrato referente a envelopes
                            depositados no cash (Evandro).
               
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                          - Retornar limite de credito armazenado na crapass
                            na procedure obtem-saldo-dia (David).
                            
               05/07/2010 - Retirar procedure zoom-associados. A procedure foi
                            movida para a BO b1wgen0059 (David).      
                            
               04/08/2010 - Incluir procedure extrato-paginado para utilizacao
                            na Internet (David).
                            
               01/09/2010 - Ajuste para rotina DEP.VISTA (David).             
                          - Inclusao historio 891, demandas BACEN (Guilherme).  
                          
               28/10/2010 - Incluidos parametros flgativo e nrctrhcj na
                            procedure lista_cartoes (Diego).    
                            
               03/11/2010 - Incluidos historicos 918(Saque) e 920(Estorno)
                            utilizados pelo TAA compartilhado (Henrique).   
                            
               05/11/2010 - Inclusao de parametros ref. TAA compartilhado na 
                            procedure gera-tarifa-extrato (Diego).      
                            
               25/11/2010 - Inclusao temporariamente do parametro flgliber
                            (Transferencia do PAC5 Acredi) (Irlan)
                            
               08/12/2010 - Incluir na procedure que carrega os dados
                            da conta na atenda , o valor da rotina
                            Cobranca (Gabriel).                                       
                            
               13/12/2010 - Incluida situacao 3-recolhido no tratamento da
                            crapenl (Evandro).
                                                                                                          
               23/02/2011 - Modificada a funcao fgetnrramfon , que trata
                            do telefone na ATENDA (Gabriel).          
                            
               18/03/2011 - Nova BO de Anotacao para tela ATENDA (David).
               
               31/03/2011 - Para o extrato TAA, efetuar mesmos controle do
                            extrato INTERNET (Evandro).
                            
               29/04/2011 - Aumento do formato do campo Nr. Documento (Gabriel)             
               
               03/06/2011 - Ajustada posicao do cdpesqbb para a gendamento
                            (Evandro).
                            
               22/08/2011 - Alimentar campo dsidenti na procedure que consulta
                            com a cooperativa, agencia e nr do terminal 
                            (Gabriel).   
                            
               06/09/2011 - Incluir quantos titulares a conta tem no obtem
                            cabecalho (Gabriel)                    
                            
               15/09/2011 - Ajuste na criacao da tt-extrato_conta, melhorando
                            o controle de sequencia dos registros encontrados.
                            WEB estava com falha para historico 698 (David);
                          - Permitir cobranca de tarifa para PJ (Evandro).
                          
               26/10/2011 - Incluido parametro na procedure busca_seguros
                            (GATI).
                            
               22/11/2011 - Incluido tratamento para transferencia entre 
                            cooperativas historicos 1009, 1011, 1014 e 1015
                            (Elton).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descriçao
                            do histórico em extratos (Lucas) [Projeto Tarifas].
                            
               11/10/2012 - Retirado condicao de filtrar resultados apenas do 
                            mes inicial, respeitando data inicial e final em 
                            procedure obtem-cheques-deposito. (Jorge).
                                
               16/10/2012 - Nova chamada da procedure valida_operador_migrado
                            da b1wgen9998 para controle de contas e operadores
                            migrados (David Kruger).                                  

                16/01/2013 - Inclusao historicos 1109 e 1110 nas procedures
                             consulta-extrato e obtem-saldo-dia
                             (Guilherme/Supero).
                             
                14/02/2013 - Incluir chamada da procedure valida_restricao_operador
                             Projeto Acesso a contas Restritas (Lucas R.)
                             
                20/04/2013 - Transferencia intercooperativa (Gabriel)
                
                24/05/2013 - Retirado parametro par_inisenta na chamada da procedure
                             gera-tarifa-extrato e incluso procedure verifica-tarifacao-extrato.
                             Incluso processo para buscar valor ta tarifa usando b1wgen0153.
                             (Daniel)
                             
                03/06/2013 - Buscar Saldo Bloqueado Judicial e grava nas tt-table 
                            das procedure consulta-extrato , obtem-saldo
                            carrega_dep_vista, obtem-saldos-anteriores,
                            obtem-saldo-dia (Andre Santos - SUPERO)
                            
                27/06/2013 - Ajuste de performance na crapenl (Evandro).
                
                11/07/2013 - Tratamento para históricos 1009 e 1011 e remoçao do
                             histórico fixo 1162 nas procedures 'obtem-saldo-dia'
                             e 'consulta-extrato' (Lucas).
                             
                23/08/2013 - Substituir campo crapass.dsnatura pelo campo
                             crapttl.dsnatura (David).
                
                26/08/2013 - Modificado a forma de busca da craptex para ficar
                             em conformidade com novo indice (cdcooper, nrdconta
                             tpextrat, nrseqext) (Tiago).
                             
                26/09/2013 - Alterado para nao receber o telefone da crapass
                             (Reinert).
                             
                02/10/2013 - Tratamento de erro na crapdoc (Jean Michel).
                
                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).
                             
                30/10/2013 - Alteraçao na consulta da crapdoc para cartao de
                             assinatura (Jean Michel).
                             
                18/12/2013 - Adicionado validate para tabela crapext (Tiago).             
                
                13/01/2014 - Retirada a consulta da CRAPDOC para cartao de
                             assinatura, flag será sempre TRUE para que todas
                             as contas tenham o link de "Cartao Assinatura" (Jean Michel).
                             
                24/03/2014 - Ajuste Oracle tratamento FIND LAST da tabelas
                             craptex (Daniel).
                             
                17/04/2014 - Ajustado chamada para procedure consulta-aplicacoes
                             para que seja apenas chamada uma vez (Daniel).  

                25/04/2014 - Ajustado procedure ver_cadastro para usar FIELDS no
                             buffer crabass (Daniel).				
                                     
                02/06/2014 - Concatena o numero do servidor no endereco do
                             terminal (Tiago-RKAM).

                17/06/2014 - Ajustado o formato do campo craplcm.nrdocmto, pois
                             o mesmo esta vindo com 22 posicoes. (Andrino-RKAM)
                             
                
                18/06/2014 - Exclusao do uso da tabela crapcar
                           (Tiago Castro - Tiago RKAM)
                
                18/06/2014 - Ajuste na procedure "gera-registro-extrato"
                             para mostrar o avalista que efetuou o pagamento
                             (James)

                20/06/2014 - Incluido o campo tt-extrato-conta.cdcoptfn
                             (Andrino-RKAM)
                             
                03/07/2014 - Ajuste para restricao de operadores 
                            (Chamado 161874) (Jonata - RKAM).            
                             
                22/08/2014 - Ajuste para incluir os historicos de lancamentos
                             da tabela craphcb na variavel aux_lshisesp.
                            (Jaison)
                            
                22/08/2014 - Alteracao da procedure carrega_dados_atenda,
                             retirada e chamada de novas procedures para
                             aplicacao. (Jean Michel)
                
                05/09/2014 - Incluido o campo tt-extrato_conta.nrseqlmt 
                             (Chamado 161899) (Jonathan - RKAM).
                           
                23/09/2014 - Ajuste na procedure obtem-saldo-dia para compor
                             o credito do emprestimo no dia. (James)
                             
                25/09/2014 - Incluido na procedure carrega_dados_atenda
                             as validacoes de Pagto de titulos por Arquivo
                             (Andre Santos - SUPERO)
			    
			    08/10/2014 - Procedure obtem-cheques-deposito alterada para 
                             tratar depositos de cheque intercooperativa. 
                             (Reinert)

				23/10/2014 - Ajuste na leitura da craplmt (Jonata-RKAM).             

                30/10/2014 - Alterar procedures obtem-saldo-dia e consulta-extrato para
                             incluir o histório 530 na lista de históricos verificados
                             em finais de semana e feriados. E verificar se o lançamento
                             de histórico 530 foi proveniente de agendamento.
                             (Douglas - Projeto Captação Internet 2014/2)
                             
                05/12/2014 - Incluido na procedure carrega_dados_atenda
                             no parametro de entrada par_flgerlog (Daniel)
                             
                19/03/2015 - Ajustado a procedure ver_saldos para leitura de novas
                             procedures (Jean Michel). 
                             
                01/09/2015 - Ajustado a procedure gera-registro-extrato, feito
                             a atribuicao do nrdocmto quando cdpesqbb = 
                             "Fato gerador tarifa:", Prj. Tarifas - 218 (Jean Michel).
                             
                06/10/2015 - Ajuste na procedure carrega_dados_atenda para retornar
                             o limite de saque no TAA. (James)
                             
                14/10/2015 - Adicionado novos campos média do mês atual e dias úteis decorridos.
							 SD 320300 (Kelvin).
                
                25/11/2015 - Adicionar RETURN "OK" na procedure carrega_medias
                             Ajustar perocedure consulta-extrato para chamar Oracle
                             Remover procedure obtem-saldo-dia (rev. 10034)
                             (Douglas - Chamado 285228)
                
                10/12/2015 - Ajustes na gera_extrato_tarifas (Dionathan)              
				
                13/05/2016 - Ajuste na carrega_medias para leitura da crapsda utilizando a 
                             chave primaria, pois devida mah interpretacao da query pelo 
                             DataServer a leitura esta sendo feita sem o filtro de data 
                             (Douglas - Chamado 452024)

                27/05/2016 - Incluido verificacao de origem na procedure valida-impressao-extrato
							 antes da chamada da procedure pc_verifica_pacote_tarifas,
							 para verificacao do tipo de servico, Prj. Tarifas Fase 2 (Jean Michel).
				
				29/07/2016 - Ajuste na leitura da tabela craptex para utilizar o 
				             index craptex1 (Daniel)   

				02/08/2016 - Nao tratar parametro de isencao de extrato na cooperativa
                             quando cooperado possuir servico de extrato no pacote de 
                             tarifas (Diego).
                             
                23/08/2016 - Alteracao da procedure obtem-saldo para uso da procedure 
                             Oracle pc_obtem_saldo_car criada para tratar e retornar
                             os dados da pc_obtem_saldo para rotinas PROGRESS. 
                             (Carlos Rafael Tanholi. SD 513352)
                             
                31/08/2016 - Correcao na forma de calculo da procedure carrega_medias
                             agora levando em consideracao apenas as datas validas para
                             consultar os dados que formam a media. 
                             (Carlos Rafael Tanholi. SD 513352)

                05/09/2016 - Correcao no comando usado para consulta do campo dtmvtoan 
							 da CRAPDAT e na logica usada para calculo da media
							 procedute carrega_medias.(Carlos Rafael Tanholi. SD 513352).

                03/10/2016 - Correcao no carregamento da TEMP TABLE da procedure obtem-saldo
							 com formato invalido. (Carlos Rafael Tanholi - SD 531031)

				06/10/2016 - Incluido a chamada da procedure pc_ret_vlr_bloq_acordo na
							 procedure carrega_dep_vista, Prj. 302 (Jean Michel).

                07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
 
                20/12/2016 - obtem-cheques-deposito - Exibir cheque no extrato somente quando
                             cheque da própria cooperativa estiver com agencia destino e
							 conta destino igual a zero (AJFink) (SD#572650)
							 
                10/07/2016 - inclusão do campo vllimcpa na tabela tt-saldos  (M441 - Roberto Holz (Mouts))

                18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                             crapass, crapttl, crapjur 
                             (Adriano - P339).
                             
                17/01/2018 - Ajustar chamada da rotina carrega_dados_tarifa_vigente
                             pois haviam casos em que nao estavamos entrando na rotina
                             na procedure gera-tarifa-extrato (Lucas Ranghetti #787894)

                12/03/2018 - Alterado para buscar descricao do tipo de conta do oracle. PRJ366 (Lombardi).

                21/04/2018 - Alterar tratamento do retorno da pc_consulta_extrato_car para
                             tratar o novo campo idlstdom (Anderson - P285)

                03/05/2018 - Alterado para buscar descricao da situacao de conta do oracle. PRJ366 (Lombardi).

	            30/05/2018 - Carregado campo dscomple na tt-extrato_conta (Alcemir Mout's - Prj. 467).
..............................................................................*/

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0020tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0026tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/b1wgen0085tt.i }
{ sistema/generico/includes/b1wgen0192tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_lshistor AS CHAR                                           NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR                                           NO-UNDO.
DEF VAR cHostname    AS CHAR                                           NO-UNDO.

DEF VAR aux_sequen   AS INTE                                           NO-UNDO.
DEF VAR i-cod-erro   AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_cdhistaa AS INTE                                           NO-UNDO.
DEF VAR aux_cdhsetaa AS INTE                                           NO-UNDO.
DEF VAR aux_cdhisint AS INTE                                           NO-UNDO.
DEF VAR aux_cdhseint AS INTE                                           NO-UNDO.

DEF VAR dt-inipesq   AS DATE                                           NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.

DEF VAR aux_vlblqaco AS DECI INIT 0    								   NO-UNDO.

DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0192 AS HANDLE                                         NO-UNDO.


/**************************** FUNCOES DE CABECALHO ****************************/

FUNCTION fgetnrdctitg RETURNS CHAR                                     FORWARD.
FUNCTION fgetnmtitula RETURNS CHAR                                     FORWARD.
FUNCTION fgetdtaltera RETURNS DATE (INPUT p-cdccoper AS INTEGER)       FORWARD.
   
FUNCTION fgetnatopc   RETURNS CHAR (INPUT p-cdcooper  AS INTEGER, 
                                    INPUT p-nro-conta AS INTEGER)      FORWARD.
    
FUNCTION fgetnrramfon RETURNS CHAR (INPUT p-cdcooper AS INTEGER)       FORWARD.
    
FUNCTION fgetnrcpfcgc RETURNS CHAR                                     FORWARD.
    
FUNCTION fgetdstipcta RETURNS CHAR (INPUT p-cdcooper AS INTEGER)       FORWARD.
FUNCTION fgetdssitdct RETURNS CHAR                                     FORWARD.

/**************************** FUNCOES DE CABECALHO ****************************/

FUNCTION f_retorna_valor_negativo CHAR (INPUT par_vlnegati AS DECIMAL):

    /* Retorna valor negativo codificado COBOL - uso para FOTON nos cash
       Exemplo: 20,0} corresponde ao valor 20,00- e 20,0N corresponde 20,05- */
    
    DEF VAR aux_vlcaract AS CHAR                                    NO-UNDO.
    DEF VAR aux_intdigit AS INT                                     NO-UNDO.
    DEF VAR aux_vlnegati AS CHAR                                    NO-UNDO.
    DEF VAR rel_cdcodifi AS CHAR    FORMAT "x(1)" EXTENT 10
                    INIT ["}","J","K","L","M","N","O","P","Q","R"]  NO-UNDO.

    /*  -0=},-1=J,-2=K,-3=L,-4=M,-5=N,-6=O,-7=P,-8=Q e -9=R   */

    ASSIGN aux_vlnegati = "".
        
    IF   par_vlnegati < 0 THEN
         DO:
             ASSIGN aux_vlcaract = STRING(par_vlnegati,"zzzzzzzzz9.99-")
                    aux_intdigit = INTEGER(SUBSTR(aux_vlcaract,
                                           LENGTH(aux_vlcaract) - 1,1))
                    aux_vlnegati = SUBSTR(aux_vlcaract,01,
                                          LENGTH(aux_vlcaract) - 2) + 
                                   rel_cdcodifi[aux_intdigit + 1].  
         END.

    RETURN aux_vlnegati.

END. 

/******************************************************************************/
/**             Procedure para listar extrato da conta-corrente              **/
/******************************************************************************/

PROCEDURE consulta-extrato:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_conta.
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO. 

    DEF VAR aux_cdcritic  AS INTE                                   NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR                                   NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_consulta_extrato_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nrdconta,
                                            INPUT par_dtiniper,
                                            INPUT par_dtfimper,
                                            INPUT par_idorigem,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT IF par_flgerlog THEN 1 ELSE 0,
                                           OUTPUT "",  /* pr_des_erro */
                                           OUTPUT "",  /* pr_clob_ret */
                                           OUTPUT 0,   /* pr_cdcritic */
                                           OUTPUT ""). /* pr_dscritic */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_extrato_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_consulta_extrato_car.pr_cdcritic 
                           WHEN pc_consulta_extrato_car.pr_cdcritic <> ?
           aux_dscritic = pc_consulta_extrato_car.pr_dscritic 
                           WHEN pc_consulta_extrato_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,          /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
       END.

    EMPTY TEMP-TABLE tt-extrato_conta.

    /*Leitura do XML de retorno da proc e criacao dos registros na tt-extrato_conta
     para visualizacao dos registros na tela */

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_extrato_car.pr_clob_ret. 

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    IF ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).

            DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 

                IF xRoot2:NUM-CHILDREN > 0 THEN
                    CREATE tt-extrato_conta.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1).

                    ASSIGN tt-extrato_conta.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta".
                    ASSIGN tt-extrato_conta.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                    ASSIGN tt-extrato_conta.nrsequen = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrsequen".
                    ASSIGN tt-extrato_conta.cdhistor = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor".
                    ASSIGN tt-extrato_conta.dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor".
                    ASSIGN tt-extrato_conta.nrdocmto = xText:NODE-VALUE WHEN xField:NAME = "nrdocmto".
                    ASSIGN tt-extrato_conta.indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre".
                    ASSIGN tt-extrato_conta.dtliblan = xText:NODE-VALUE WHEN xField:NAME = "dtliblan".
                    ASSIGN tt-extrato_conta.inhistor = INT(xText:NODE-VALUE) WHEN xField:NAME = "inhistor".
                    ASSIGN tt-extrato_conta.vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
                    ASSIGN tt-extrato_conta.vlsddisp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsddisp".
                    ASSIGN tt-extrato_conta.vlsdchsl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdchsl".
                    ASSIGN tt-extrato_conta.vlsdbloq = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdbloq".
                    ASSIGN tt-extrato_conta.vlsdblpr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdblpr".
                    ASSIGN tt-extrato_conta.vlsdblfp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdblfp".
                    ASSIGN tt-extrato_conta.vlsdtota = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdtota".
                    ASSIGN tt-extrato_conta.vllimcre = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllimcre".
                    ASSIGN tt-extrato_conta.dsagenci = xText:NODE-VALUE WHEN xField:NAME = "dsagenci".
                    ASSIGN tt-extrato_conta.cdagenci = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci".
                    ASSIGN tt-extrato_conta.cdbccxlt = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdbccxlt".
                    ASSIGN tt-extrato_conta.nrdolote = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdolote".
                    ASSIGN tt-extrato_conta.dsidenti = xText:NODE-VALUE WHEN xField:NAME = "dsidenti".
                    ASSIGN tt-extrato_conta.nrparepr = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrparepr".
                    ASSIGN tt-extrato_conta.dsextrat = xText:NODE-VALUE WHEN xField:NAME = "dsextrat".
                    ASSIGN tt-extrato_conta.vlblqjud = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlblqjud".
                    ASSIGN tt-extrato_conta.cdcoptfn = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcoptfn".
                    ASSIGN tt-extrato_conta.nrseqlmt = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrseqlmt".
                    ASSIGN tt-extrato_conta.cdtippro = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtippro".
                    ASSIGN tt-extrato_conta.dsprotoc = xText:NODE-VALUE WHEN xField:NAME = "dsprotoc".
                    ASSIGN tt-extrato_conta.flgdetal = INT(xText:NODE-VALUE) WHEN xField:NAME = "flgdetal".
                    ASSIGN tt-extrato_conta.idlstdom = INT(xText:NODE-VALUE) WHEN xField:NAME = "idlstdom".
	                ASSIGN tt-extrato_conta.dscomple = xText:NODE-VALUE WHEN xField:NAME = "dscomple".
                END. 

            END.

            SET-SIZE(ponteiro_xml) = 0. 

        END.

    /*Elimina os objetos criados*/
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

END PROCEDURE.

/******************************************************************************/
/**    Procedure para controlar listagem do extrato da conta em paginacao    **/
/******************************************************************************/
PROCEDURE extrato-paginado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_iniregis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtregpag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_conta.

    DEF VAR aux_vllanant AS DECI                                    NO-UNDO.
    DEF VAR aux_vllansld AS DECI                                    NO-UNDO.

    DEF VAR aux_dtmvtant AS DATE                                    NO-UNDO.
    DEF VAR aux_dtmvtsld AS DATE                                    NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-extrato_conta.
    
    RUN consulta-extrato (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nrdconta,
                          INPUT par_dtiniper,
                          INPUT par_dtfimper,
                          INPUT par_idorigem,
                          INPUT par_idseqttl,
                          INPUT par_nmdatela,
                          INPUT par_flgerlog,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-extrato_conta).

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    FIND tt-extrato_conta WHERE tt-extrato_conta.nrsequen = 0
                                EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAILABLE tt-extrato_conta  THEN 
        DO: 
            ASSIGN aux_dtmvtsld = tt-extrato_conta.dtmvtolt
                   aux_vllansld = tt-extrato_conta.vllanmto.
            DELETE tt-extrato_conta.
        END.

    FOR EACH tt-extrato_conta EXCLUSIVE-LOCK:

        ASSIGN par_qtregist = par_qtregist + 1.

        IF  par_qtregist = par_iniregis  THEN 
            ASSIGN aux_dtmvtant = aux_dtmvtsld
                   aux_vllanant = aux_vllansld.

        ASSIGN aux_dtmvtsld = tt-extrato_conta.dtmvtolt.

        IF  tt-extrato_conta.cdhistor <> 698   THEN
            DO:
                IF  tt-extrato_conta.indebcre = "C"  THEN 
                    ASSIGN aux_vllansld = aux_vllansld + 
                                          tt-extrato_conta.vllanmto.
                ELSE 
                    ASSIGN aux_vllansld = aux_vllansld - 
                                          tt-extrato_conta.vllanmto.
            END.
        
        IF  par_qtregist >= par_iniregis                  AND  
            par_qtregist < (par_iniregis + par_qtregpag)  THEN 
            DO:
                IF  par_qtregist = ((par_iniregis + par_qtregpag) - 1)  THEN 
                    ASSIGN tt-extrato_conta.vlsdtota = aux_vllansld.
    
                NEXT.
            END.
    
        DELETE tt-extrato_conta.
    
    END. /** Fim do FOR EACH tt-extrato_conta **/
                                                
    IF  par_qtregist > 0  THEN 
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.
                                             
            FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                               crapage.cdagenci = crapass.cdagenci
                               NO-LOCK NO-ERROR.
                          
            CREATE tt-extrato_conta.
            ASSIGN tt-extrato_conta.nrdconta = par_nrdconta
                   tt-extrato_conta.nrsequen = 0
                   tt-extrato_conta.dtmvtolt = aux_dtmvtant
                   tt-extrato_conta.vlsdtota = aux_vllanant
                   tt-extrato_conta.dshistor = "SALDO ANTERIOR"
                   tt-extrato_conta.dsextrat = "SALDO ANTERIOR"
                   tt-extrato_conta.vllimcre = crapass.vllimcre
                   tt-extrato_conta.dsagenci = crapage.nmextage.
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**           Procedure para listar cheques recebidos em deposito            **/
/******************************************************************************/
PROCEDURE obtem-cheques-deposito:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_iniregis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtregpag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-extrato_cheque.

    DEF VAR aux_fimregis AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vltotchq AS DECI                                    NO-UNDO.
    
    DEF VAR aux_dtmvtolt AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-extrato_cheque.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar cheques em deposito.".

    ASSIGN aux_fimregis = par_iniregis + par_qtregpag.
                   
    FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper AND
                           crapchd.nrdconta  = par_nrdconta AND
                           crapchd.cdbccxlt <> 700          AND
                           crapchd.dtmvtolt >= par_dtiniper AND
                           crapchd.dtmvtolt <= par_dtfimper AND
                           crapchd.nrdocmto >  0            AND
						   crapchd.cdagedst  = 0            AND
						   crapchd.nrctadst  = 0            
                           NO-LOCK BREAK BY crapchd.dtmvtolt
                                            BY crapchd.nrdocmto
                                               BY crapchd.cdbanchq
                                                  BY crapchd.cdagechq
                                                     BY crapchd.nrctachq
                                                        BY crapchd.nrcheque:
        ASSIGN par_qtregist = par_qtregist + 1.

        IF  FIRST-OF(crapchd.dtmvtolt)   OR 
            FIRST-OF(crapchd.nrdocmto)   OR
            par_qtregist = par_iniregis  THEN
            ASSIGN aux_dtmvtolt = STRING(crapchd.dtmvtolt,"99/99/9999")
                   aux_vltotchq = crapchd.vlcheque.
        ELSE                                        
            ASSIGN aux_dtmvtolt = ""
                   aux_vltotchq = aux_vltotchq + crapchd.vlcheque.

        IF  NOT par_flgpagin              OR
           (par_qtregist >= par_iniregis  AND 
            par_qtregist <  aux_fimregis) THEN
            DO:
                CREATE tt-extrato_cheque.
                ASSIGN tt-extrato_cheque.dtmvtolt = aux_dtmvtolt 
                       tt-extrato_cheque.nrdocmto = crapchd.nrdocmto
                       tt-extrato_cheque.cdbanchq = crapchd.cdbanchq
                       tt-extrato_cheque.cdagechq = crapchd.cdagechq
                       tt-extrato_cheque.nrctachq = crapchd.nrctachq
                       tt-extrato_cheque.nrcheque = crapchd.nrcheque
                       tt-extrato_cheque.nrddigc3 = crapchd.nrddigc3
                       tt-extrato_cheque.vlcheque = crapchd.vlcheque.

                IF  LAST-OF(crapchd.dtmvtolt)                           OR
                    LAST-OF(crapchd.nrdocmto)                           OR 
                   (par_flgpagin AND par_qtregist = (aux_fimregis - 1)) THEN
                    ASSIGN tt-extrato_cheque.vltotchq = aux_vltotchq.
                ELSE
                    ASSIGN tt-extrato_cheque.vltotchq = 0.
            END.

    END. /** Fim do FOR EACH crapchd **/

    /*      DEPOSITO INTERCOOP.     */

    /* Busca agencia central da cooperativa de destino do deposito */
    FOR FIRST crapcop FIELDS(cdagectl)
                      WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:

        FOR EACH crapchd WHERE crapchd.cdagedst = crapcop.cdagectl  AND
                               crapchd.nrctadst = par_nrdconta      AND
                               crapchd.dtmvtolt >= par_dtiniper     AND
                               crapchd.dtmvtolt <= par_dtfimper
                               NO-LOCK BREAK BY crapchd.dtmvtolt
                                                BY crapchd.nrdocmto
                                                   BY crapchd.cdbanchq
                                                      BY crapchd.cdagechq
                                                         BY crapchd.nrctachq
                                                            BY crapchd.nrcheque:
            ASSIGN par_qtregist = par_qtregist + 1.
    
            IF  FIRST-OF(crapchd.dtmvtolt)   OR 
                FIRST-OF(crapchd.nrdocmto)   OR
                par_qtregist = par_iniregis  THEN
                ASSIGN aux_dtmvtolt = STRING(crapchd.dtmvtolt,"99/99/9999")
                       aux_vltotchq = crapchd.vlcheque.
            ELSE                                        
                ASSIGN aux_dtmvtolt = ""
                       aux_vltotchq = aux_vltotchq + crapchd.vlcheque.
    
            IF  NOT par_flgpagin              OR
               (par_qtregist >= par_iniregis  AND 
                par_qtregist <  aux_fimregis) THEN
                DO:
                    CREATE tt-extrato_cheque.
                    ASSIGN tt-extrato_cheque.dtmvtolt = aux_dtmvtolt 
                           tt-extrato_cheque.nrdocmto = crapchd.nrdocmto
                           tt-extrato_cheque.cdbanchq = crapchd.cdbanchq
                           tt-extrato_cheque.cdagechq = crapchd.cdagechq
                           tt-extrato_cheque.nrctachq = crapchd.nrctachq
                           tt-extrato_cheque.nrcheque = crapchd.nrcheque
                           tt-extrato_cheque.nrddigc3 = crapchd.nrddigc3
                           tt-extrato_cheque.vlcheque = crapchd.vlcheque.
    
                    IF  LAST-OF(crapchd.dtmvtolt)                           OR
                        LAST-OF(crapchd.nrdocmto)                           OR 
                       (par_flgpagin AND par_qtregist = (aux_fimregis - 1)) THEN
                        ASSIGN tt-extrato_cheque.vltotchq = aux_vltotchq.
                    ELSE
                        ASSIGN tt-extrato_cheque.vltotchq = 0.
                END.
    
        END. /** Fim do FOR EACH crapchd **/
    END. /** Fim do FOR FIRST crapcop **/
    
    IF  par_flgerlog  THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
    
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**              Procedure para listar depositos identificados               **/
/******************************************************************************/
PROCEDURE obtem-depositos-identificados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_iniregis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtregpag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dep-identificado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_vltarpro AS DECI                                    NO-UNDO.
    DEF VAR aux_cdbattaa AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdbatint AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-dep-identificado.
    EMPTY TEMP-TABLE tt-erro.
        
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar depositos identificados.".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).      
                       
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,  
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".
        END.

    ASSIGN aux_cdhistaa = 0
           aux_cdhsetaa = 0
           aux_cdhisint = 0
           aux_cdhseint = 0.

    IF  crapass.inpessoa = 1 THEN
        ASSIGN aux_cdbattaa = "TROUTTAAPF"  /* Pessoa Física via TAA      */
               aux_cdbatint = "TROUTINTPF". /* Pessoa Física via Internet */
    ELSE
        ASSIGN aux_cdbattaa = "TROUTTAAPJ"  /* Pessoa Jurídica via TAA      */
               aux_cdbatint = "TROUTINTPJ". /* Pessoa Jurídica via Internet */
 
    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
                                                    
    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                   (INPUT par_cdcooper,
                                    INPUT aux_cdbattaa,
                                    INPUT 1, 
                                    INPUT "", /* cdprogra */
                                    OUTPUT aux_cdhistaa,
                                    OUTPUT aux_cdhsetaa,
                                    OUTPUT aux_vltarpro,
                                    OUTPUT aux_dtdivulg,
                                    OUTPUT aux_dtvigenc,
                                    OUTPUT aux_cdfvlcop,
                                    OUTPUT TABLE tt-erro).

    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                   (INPUT par_cdcooper,
                                    INPUT aux_cdbatint,
                                    INPUT 1, 
                                    INPUT "", /* cdprogra */
                                    OUTPUT aux_cdhisint,
                                    OUTPUT aux_cdhseint,
                                    OUTPUT aux_vltarpro,
                                    OUTPUT aux_dtdivulg,
                                    OUTPUT aux_dtvigenc,
                                    OUTPUT aux_cdfvlcop,
                                    OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.

    FOR EACH craplcm WHERE craplcm.cdcooper  = par_cdcooper AND
                           craplcm.nrdconta  = par_nrdconta AND
                           craplcm.dtmvtolt >= par_dtiniper AND
                           craplcm.dtmvtolt <= par_dtfimper AND
                           craplcm.dsidenti <> ""
                           NO-LOCK USE-INDEX craplcm2:
                           
        ASSIGN par_qtregist = par_qtregist + 1.

        IF  NOT par_flgpagin                              OR
           (par_qtregist >= par_iniregis                  AND 
            par_qtregist < (par_iniregis + par_qtregpag)) THEN 
            DO:
                RUN gera-registro-extrato (INPUT ROWID(craplcm),
                                           INPUT "tt-dep-identificado",
                                           INPUT TRUE,
                                          OUTPUT aux_dscritic).
                                                        
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0.
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).      
                           
                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT aux_dscritic,
                                               INPUT aux_dsorigem,
                                               INPUT aux_dstransa,
                                               INPUT FALSE,
                                               INPUT par_idseqttl,  
                                               INPUT par_nmdatela,
                                               INPUT par_nrdconta,
                                              OUTPUT aux_nrdrowid). 
        
                        RETURN "NOK".            
                    END.
            END.
        
    END. /** Fim do FOR EACH craplcm **/
   
    IF  par_flgerlog  THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
    
    RETURN "OK".    
    
END PROCEDURE.
 

/******************************************************************************/
/**        Procedure para retornar taxa de juros do limite de credito        **/
/******************************************************************************/
PROCEDURE obtem-juros-limite-credito:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-extrato_conta.

    DEF OUTPUT PARAM TABLE FOR tt-taxajuros.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
            
    DEF VAR aux_tpdetaxa AS LOGI EXTENT 4                           NO-UNDO.

    DEF VAR aux_conthist AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
    
    DEF VAR aux_uldiames AS DATE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-taxajuros.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter taxa de juros do limite de credito."
           aux_tpdetaxa = FALSE.

    /** Juros cheque especial **/
    FIND FIRST tt-extrato_conta WHERE tt-extrato_conta.cdhistor = 38 
                                      NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-extrato_conta  THEN  
        ASSIGN aux_tpdetaxa[2] = TRUE.
        
    /** Juros saque s/ deposito **/
    FIND FIRST tt-extrato_conta WHERE tt-extrato_conta.cdhistor = 57 
                                      NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-extrato_conta  THEN  
        ASSIGN aux_tpdetaxa[3] = TRUE.
             
    /** Taxa c/c negativa **/
    FIND FIRST tt-extrato_conta WHERE tt-extrato_conta.cdhistor = 37 
                                      NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-extrato_conta  THEN
        ASSIGN aux_tpdetaxa[4] = TRUE.
    
    /** Encontra data em que foi gerado o craptax **/
    FIND LAST craptax WHERE craptax.cdcooper = par_cdcooper AND
                            craptax.dtmvtolt < par_dtmvtolt AND 
                            craptax.tpdetaxa = 2            NO-LOCK NO-ERROR.

    IF  AVAILABLE craptax  THEN
        ASSIGN aux_uldiames = craptax.dtmvtolt.
    ELSE
        DO:
            ASSIGN aux_uldiames = par_dtmvtolt - DAY(par_dtmvtolt).
    
            DO WHILE TRUE:
      
                IF  CAN-DO("1,7",STRING(WEEKDAY(aux_uldiames)))  OR
                    CAN-FIND(crapfer WHERE 
                             crapfer.cdcooper = par_cdcooper     AND
                             crapfer.dtferiad = aux_uldiames)    THEN
                    DO:
                        ASSIGN aux_uldiames = aux_uldiames - 1.
                        NEXT.
                    END.
     
                LEAVE.
                 
            END. /** Fim do DO WHILE TRUE **/
        END. 

    DO aux_conthist = 2 TO 4:

        IF  aux_tpdetaxa[aux_conthist]  THEN
            DO:
                ASSIGN aux_cdlcremp = 0.

                /** Juros do Cheque Especial **/
                IF  aux_conthist = 2  THEN
                    DO:
                        FOR EACH craplim WHERE
                                 craplim.cdcooper = par_cdcooper AND
                                 craplim.nrdconta = par_nrdconta AND
                                 craplim.tpctrlim = 1               
                                 NO-LOCK BY craplim.dtfimvig:
        
                            IF  craplim.insitlim = 2  THEN
                                DO:
                                    ASSIGN aux_cdlcremp = craplim.cddlinha.
                                    LEAVE.
                                END.
                            ELSE
                                ASSIGN aux_cdlcremp = craplim.cddlinha.
                        
                        END. /** Fim do FOR EACH craplim **/
                    END. 

                FIND craptax WHERE craptax.cdcooper = par_cdcooper  AND
                                  (craptax.cdlcremp = aux_cdlcremp) AND
                                  (craptax.tpdetaxa = aux_conthist) AND
                                  (craptax.dtmvtolt = aux_uldiames)
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craptax  THEN
                    DO:
                        ASSIGN aux_cdcritic = 347
                               aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,          /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).      
                           
                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,  
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).

                        RETURN "NOK".
                    END. 
                
                CREATE tt-taxajuros.
                ASSIGN tt-taxajuros.dslcremp = craptax.dslcremp
                       tt-taxajuros.txmensal = craptax.txmensal.
            END.

    END. /** Fim do DO ... TO **/
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                                     
    RETURN "OK".    
        
END PROCEDURE.


/******************************************************************************/
/**      Procedure para gerar tarifa referente a impressao de extrato        **/
/******************************************************************************/
PROCEDURE gera-tarifa-extrato:
                      
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
  /*  DEF  INPUT PARAM par_inisenta AS INTE                           NO-UNDO. */
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_inisenta AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqext AS INTE                                    NO-UNDO.
    
    DEF VAR h-b1wgen0153    AS HANDLE                               NO-UNDO.
    DEF VAR aux_cdbattar    AS CHAR                                 NO-UNDO.
    
    DEF VAR aux_cdhisest    AS INTE                                 NO-UNDO.
    DEF VAR aux_dtdivulg    AS DATE                                 NO-UNDO.
    DEF VAR aux_dtvigenc    AS DATE                                 NO-UNDO.
    DEF VAR aux_vllanaut    AS DECIMAL                              NO-UNDO.
    DEF VAR aux_cdhistor    AS INTE                                 NO-UNDO.
    DEF VAR aux_cdfvlcop    AS INTE                                 NO-UNDO.
    DEF VAR aux_tpextrat    AS INTE                                 NO-UNDO.
    
    DEF VAR aux_contador    AS INTE                                 NO-UNDO.
    DEF VAR aux_tipotari    AS INTE                                 NO-UNDO.
    DEF VAR aux_fliseope    AS INTE                                 NO-UNDO.
    DEF VAR aux_qtacobra    AS INTEGER                              NO-UNDO.
     
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.
    
    
    /** Gerar tarifa apenas para IMPRES e ATENDA, exceto CRPS029 **/
    IF  par_inproces > 2  THEN
        RETURN "OK".
        
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar tarifa para impressao de extrato.".

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapdat   THEN
         DO:
             ASSIGN aux_cdcritic = 1
                    aux_dscritic = "".
                   
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                                   
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
                                   
             RETURN "NOK".
         END.
         
    /* Verifica se isento da tarifacao do extrato */
    RUN verifica-tarifacao-extrato (INPUT  par_cdcooper,
                                    INPUT  par_nrdconta,
                                    INPUT  crapdat.dtmvtocd,
                                    INPUT  par_dtrefere,
                                    OUTPUT aux_inisenta,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF AVAIL tt-erro THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = tt-erro.dscritic.
            END.

        IF  par_flgerlog  THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        RETURN "NOK".
    END.  
               

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
            RETURN "NOK".
        END.
        
     
    /** Lista apenas para impres.p atenda/extrato exceto crps029.p **/
   
    IF  par_dtrefere < ( crapdat.dtmvtocd - 30 ) THEN /* Periodo */
        DO:
            IF par_nrterfin <> 0 THEN /* TAA */ 
                DO:
                    ASSIGN aux_tipotari = 9.

                    IF crapass.inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "EXTPETAAPF".
                    ELSE
                        ASSIGN aux_cdbattar = "EXTPETAAPJ".
                END.
            ELSE
                DO:
                    ASSIGN aux_tipotari = 8.

                    IF crapass.inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "EXTPEPREPF".
                    ELSE
                        ASSIGN aux_cdbattar = "EXTPEPREPJ".
                END. 
        END.
    ELSE
        DO:
            IF par_nrterfin <> 0 THEN /* TAA */ 
                DO:
                    ASSIGN aux_tipotari = 7.

                    IF crapass.inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "EXTMETAAPF".
                    ELSE
                        ASSIGN aux_cdbattar = "EXTMETAAPJ".
                END.
            ELSE
                DO:
                    ASSIGN aux_tipotari = 6.

                    IF crapass.inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "EXTMEPREPF".
                    ELSE
                        ASSIGN aux_cdbattar = "EXTMEPREPJ".
                END.
        END.

    IF  par_flgtarif  THEN
        DO:
            
            /*VERIFICACAO TARIFAS DE OPERACAO*/
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT par_cdoperad, /* Código do Operador */
                                         INPUT par_cdagetfn, /* Codigo Agencia */
                                         INPUT par_cdcoptfn, /* Codigo banco caixa */
                                         INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */   
                                         INPUT par_nrdconta, /* Numero da Conta */
                                         INPUT aux_tipotari, /* Tipo de Tarifa(1-Saque,2-Consulta) */
                                         INPUT 0,            /* Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus) */
                                         INPUT 0,            /* Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque) */
                                         OUTPUT 0,           /* Quantidade de registros a cobrar tarifa na operação */
                                         OUTPUT 0,           /* Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta */
                                         OUTPUT 0,           /* Código da crítica */
                                         OUTPUT "").         /* Descrição da crítica */
            
            CLOSE STORED-PROC pc_verifica_tarifa_operacao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                 aux_dscritic = ""
                 aux_cdcritic = pc_verifica_tarifa_operacao.pr_cdcritic 
                                 WHEN pc_verifica_tarifa_operacao.pr_cdcritic <> ?
                 aux_dscritic = pc_verifica_tarifa_operacao.pr_dscritic
                                 WHEN pc_verifica_tarifa_operacao.pr_dscritic <> ?
                 aux_fliseope = pc_verifica_tarifa_operacao.pr_fliseope
                                 WHEN pc_verifica_tarifa_operacao.pr_fliseope <> ?
                 aux_qtacobra = pc_verifica_tarifa_operacao.pr_qtacobra
                                 WHEN pc_verifica_tarifa_operacao.pr_qtacobra <> ?.
            
            IF aux_cdcritic <> 0   OR
               aux_dscritic <> ""  THEN
             DO:
                 IF aux_dscritic = "" THEN
                    DO:
                       FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                          NO-LOCK NO-ERROR.
            
                       IF AVAIL crapcri THEN
                          ASSIGN aux_dscritic = crapcri.dscritic.
            
                    END.
            
                 
                 RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                           
                IF  par_flgerlog  THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                               
                RETURN "NOK".
                                
             END.
             
            /* Possui pacote de tarifas, e utilizou operacao isenta disponivel*/ 
            IF   aux_fliseope = 1 THEN
                ASSIGN aux_inisenta = 1.
            ELSE
                 /*Possui pacote de tarifas, e excedeu qtd.isenta do servico "extrato"*/ 
                 IF   aux_qtacobra > 0 THEN
                    /* Essa atribuicao eh necessaria devido a chamada da procedure 
                      'verifica-tarifacao-extrato' anteriormente, que retorna na 
                      variavel 'aux_inisenta' se o cooperado possui extrato isento 
                      oferecido pela cooperativa. Porem, quando o cooperado possuir
                      o servico "extrato" no pacote de tarifas, nao devera receber
                      mais isencao pela cooperativa.*/ 
                      ASSIGN aux_inisenta = 0. 


            IF  aux_inisenta = 0 THEN
                DO:
                    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN 
                        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
                        
                    /*  Busca valor da tarifa extrato*/
                    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                    (INPUT par_cdcooper,
                                                     INPUT aux_cdbattar,
                                                     INPUT 1,             /* vllanmto */
                                                     INPUT "",            /* cdprogra */
                                                     OUTPUT aux_cdhistor,
                                                     OUTPUT aux_cdhisest,
                                                     OUTPUT aux_vllanaut,
                                                     OUTPUT aux_dtdivulg,
                                                     OUTPUT aux_dtvigenc,
                                                     OUTPUT aux_cdfvlcop,
                                                     OUTPUT TABLE tt-erro).
                                                     
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                        
                            CREATE tt-msg-confirma.
                            ASSIGN tt-msg-confirma.inconfir = 2
                                   tt-msg-confirma.dsmensag = "Nao ha tabela cadastrada"
                                    + " CRED-USUARI-11-" + aux_cdbattar + ". Informe o Suporte Operacional".

                            IF  VALID-HANDLE(h-b1wgen0153) THEN
                               DELETE PROCEDURE h-b1wgen0153. 

                            RETURN "NOK".

                        END. 
                    ELSE
                        DO:
                            CREATE tt-msg-confirma.
                            ASSIGN tt-msg-confirma.inconfir = 1
                                   tt-msg-confirma.dsmensag = "******** AVISO: ESTE " +
                                    "EXTRATO SERA TARIFADO EM R$ " + 
                                    TRIM(STRING(aux_vllanaut,"zzz,zzz,zz9.99")) + " NESTA DATA. ********".
                                    
                            IF  VALID-HANDLE(h-b1wgen0153) THEN
                                DELETE PROCEDURE h-b1wgen0153.
                        END. 
                END.

            /*FIM VERIFICACAO TARIFAS DE OPERACAO*/

            DO TRANSACTION ON ERROR UNDO, LEAVE:
    
                            
                CREATE crapext.
                ASSIGN crapext.cdcooper = par_cdcooper
                       crapext.cdagenci = crapass.cdagenci
                       crapext.nrdconta = par_nrdconta
                       crapext.dtrefere = par_dtrefere
                       crapext.nranoref = 0
                       crapext.nrctremp = 0
                       crapext.nraplica = 0
                       crapext.inselext = 0
                       crapext.tpextrat = 1
                       crapext.inisenta = aux_inisenta 
                       crapext.insitext = 1
                       crapext.dtreffim = crapdat.dtmvtocd
                       crapext.cdcoptfn = par_cdcoptfn
                       crapext.cdagetfn = par_cdagetfn
                       crapext.nrterfin = par_nrterfin
                       aux_flgtrans     = TRUE.
                VALIDATE crapext.

                IF aux_fliseope = 1 THEN
                    RETURN "OK".
                
                ASSIGN aux_tpextrat = 51.

                IF par_dtrefere < ( crapdat.dtmvtocd - 30 ) THEN /* Periodo */
                DO:
                    ASSIGN aux_tpextrat = 52.   /*
                           aux_inisenta = 0. /* Nao Isento */     */
                END.
                
                /* O sequencial nao sera informada desta forma sera ativado uma trigger 
                   que ira buscar o sequencial atraves de uma sequence no Oracle */
                CREATE craptex.
                ASSIGN craptex.cdcooper = par_cdcooper
                       craptex.nrdconta = par_nrdconta
                       craptex.tpextrat = aux_tpextrat
                /*     craptex.nrseqext = aux_nrseqext */
                       craptex.inisenta = aux_inisenta
                       craptex.dtemiext = crapdat.dtmvtocd
                       craptex.vltarifa = aux_vllanaut
                       craptex.cdhistor = aux_cdhistor
                       craptex.cdfvlcop = aux_cdfvlcop.
                            
            END. /** Fim do DO TRANSACTION **/
        
            IF  NOT aux_flgtrans  THEN
                DO:                                      
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel gerar a tarifa.".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                           
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                                   
                    RETURN "NOK".
                END.
        END.

    IF  par_flgerlog  THEN 
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                               
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "inisenta",
                                     INPUT "",
                                     INPUT STRING(aux_inisenta)).
        END.

    RETURN "OK".        

END PROCEDURE.


/******************************************************************************/
/**      Procedure para validar impressao do extrato de conta corrente       **/
/******************************************************************************/
PROCEDURE valida-impressao-extrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inisenta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_inisenta AS INTE                                    NO-UNDO.
    DEF VAR aux_qtopdisp AS INTE                                    NO-UNDO.
    DEF VAR aux_tpservic AS INTE                                    NO-UNDO.
    DEF VAR aux_flservic AS INTEGER                                 NO-UNDO.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar impressao de extrato da conta corrente.".
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.

    IF  par_dtiniper <= 03/31/2005  THEN
        DO:
            ASSIGN aux_cdcritic = 852
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
                               
    IF  par_dtiniper > par_dtmvtolt  OR
        par_dtfimper > par_dtmvtolt  OR
        par_dtiniper > par_dtfimper  THEN      
        DO: 
            ASSIGN aux_cdcritic = 13
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
    
    /* Verifica o tipo do serviço a ser validado no pacote de tarifas, com base na origem, se mensal ou por periodo */
    /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
    IF par_dtiniper < ( par_dtmvtolt - 30 ) THEN /* Periodo */
        DO:
            IF par_idorigem = 4  THEN 
                ASSIGN aux_tpservic = 9.
            ELSE IF par_idorigem = 1 OR par_idorigem = 5 THEN
                ASSIGN aux_tpservic = 8.
        END.
    ELSE /* Mensal */
        DO:
            IF par_idorigem = 4  THEN 
                ASSIGN aux_tpservic = 7.
            ELSE IF par_idorigem = 1 OR par_idorigem = 5 THEN 
                ASSIGN aux_tpservic = 6.
        END.


    /* VERIFICACAO PACOTE DE TARIFAS */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_verifica_pacote_tarifas
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,  /* Código da Cooperativa */
                                 INPUT par_nrdconta,  /* Numero da Conta */
                                 INPUT par_idorigem,  /* Origem */
                                 INPUT aux_tpservic,   /* Tipo de Servico */
                                 OUTPUT 0,            /* Flag de Pacote */
                                 OUTPUT 0,            /* Flag de Sevico */
                                 OUTPUT 0,            /* Quantidade de Operacoes Disponiveis */
                                 OUTPUT 0,            /* Código da crítica */
                                 OUTPUT "").          /* Descrição da crítica */ 
    
    CLOSE STORED-PROC pc_verifica_pacote_tarifas
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_verifica_pacote_tarifas.pr_cdcritic 
                          WHEN pc_verifica_pacote_tarifas.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_pacote_tarifas.pr_dscritic
                          WHEN pc_verifica_pacote_tarifas.pr_dscritic <> ?.
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
         DO:
            RETURN "NOK".
        END.
    
    ASSIGN /* retorna qtd. de extratos isentos que ainda possui disponivel no pacote de tarifas */
           aux_qtopdisp = pc_verifica_pacote_tarifas.pr_qtopdisp
           /* retorna pr_flservic = 1 quando existir o servico "extrato" no pacote */
           aux_flservic = pc_verifica_pacote_tarifas.pr_flservic.

    IF aux_qtopdisp > 0 THEN
      RETURN "OK".

    /* Quando o cooperado NAO possuir o servico "extrato" contemplado no pacote de tarifas,
       devera validar a qtd. de extratos isentos oferecidos pela cooperativa(parametro). 
       Caso contrario, o cooperado tera direito apenas a qtd. disponibilizada no pacote */
    IF   aux_flservic = 0 THEN
    /* Verifica se isento da tarifacao do extrato */
    RUN verifica-tarifacao-extrato (INPUT  par_cdcooper,
                                    INPUT  par_nrdconta,
                                    INPUT  par_dtmvtolt,
                                    INPUT  par_dtiniper,
                                    OUTPUT aux_inisenta,
                                    OUTPUT TABLE tt-erro).
                                    
    IF  aux_inisenta = 0  THEN  /** Gerar tarifa **/
        DO:
            FIND FIRST crapext WHERE crapext.cdcooper  = par_cdcooper AND
                                     crapext.nrdconta  = par_nrdconta AND
                                     crapext.tpextrat  = 1            AND
                                     crapext.dtreffim  = par_dtmvtolt AND
                                     crapext.insitext <> 5
                                     NO-LOCK NO-ERROR.

            IF  AVAILABLE crapext  THEN
                ASSIGN aux_dsmensag = "Este extrato ja foi impresso hoje" +
                                      " e sera tarifado. Confirma a operacao?".
            ELSE
                ASSIGN aux_dsmensag = "Este extrato sera tarifado. Confirma " +
                                      "a operacao?".

            IF  aux_dsmensag <> ""  THEN
                DO:
                    CREATE tt-msg-confirma.
                    ASSIGN tt-msg-confirma.inconfir = 1
                           tt-msg-confirma.dsmensag = aux_dsmensag.
                END.
        END.

    RETURN "OK".
     
END PROCEDURE.


/******************************************************************************/
/**       Procedure para obter impressao do extrato de conta corrente        **/
/******************************************************************************/
PROCEDURE obtem-impressao-extrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inrelext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inisenta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-cabrel.
    DEF OUTPUT PARAM TABLE FOR tt-dados_cooperado.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_conta.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_cheque.
    DEF OUTPUT PARAM TABLE FOR tt-dep-identificado.
    DEF OUTPUT PARAM TABLE FOR tt-taxajuros.
    DEF OUTPUT PARAM TABLE FOR tt-totais-futuros.
    DEF OUTPUT PARAM TABLE FOR tt-lancamento_futuro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    DEF VAR aux_terminal AS CHAR                                    NO-UNDO.
    DEF VAR aux_server   AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstraint AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0003 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-cabrel.
    EMPTY TEMP-TABLE tt-dados_cooperado.
    EMPTY TEMP-TABLE tt-extrato_conta.
    EMPTY TEMP-TABLE tt-extrato_cheque.
    EMPTY TEMP-TABLE tt-dep-identificado.
    EMPTY TEMP-TABLE tt-taxajuros.
    EMPTY TEMP-TABLE tt-totais-futuros.
    EMPTY TEMP-TABLE tt-lancamento_futuro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstraint = "Consultar dados para Extrato."
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
    
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                           crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapage  THEN
            DO:
                ASSIGN aux_dscritic = "PA nao cadastrado.".
                LEAVE.
            END.

        IF  CAN-DO("1,2,5",STRING(par_idorigem))  THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapcop  THEN
                    DO:
                        ASSIGN aux_cdcritic = 651.
                        LEAVE.
                    END.

                FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                   crapope.cdoperad = par_cdoperad 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapope  THEN
                    DO:
                        ASSIGN aux_cdcritic = 67.
                        LEAVE.
                    END.

                ASSIGN aux_cdempres = 0.

                IF  crapass.inpessoa = 1  THEN
                    DO:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                           crapttl.nrdconta = par_nrdconta AND
                                           crapttl.idseqttl = 1 
                                           NO-LOCK NO-ERROR.
                
                        IF  AVAILABLE crapttl  THEN
                            ASSIGN aux_cdempres = crapttl.cdempres.
                    END.
                ELSE
                    DO:
                        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                           crapjur.nrdconta = par_nrdconta
                                           NO-LOCK NO-ERROR.
                
                        IF  AVAILABLE crapjur  THEN
                            ASSIGN aux_cdempres = crapjur.cdempres.
                    END.
                
                IF  CAN-DO("11,50",STRING(aux_cdempres))  AND 
                    crapope.nmoperad <> crapass.nmprimtl  AND
                    crapope.cddepart <> 20               THEN   /* TI */
                    DO:              
                        IF  par_idorigem = 1  THEN
                            DO:
                            
                                INPUT THROUGH basename `tty` NO-ECHO.
                
                                IMPORT UNFORMATTED aux_terminal.
                               
                                INPUT CLOSE.

                                INPUT THROUGH basename `hostname -s` NO-ECHO.
                                IMPORT UNFORMATTED aux_server.
                                INPUT CLOSE.
                                aux_terminal = substr(aux_server,length(aux_server) - 1) +
                                                      aux_terminal.
                                
                            END.
                            
                        UNIX SILENT VALUE ("echo " + 
                                    STRING(YEAR(par_dtmvtolt),"9999") +
                                    STRING(MONTH(par_dtmvtolt),"99") +
                                    STRING(DAY(par_dtmvtolt),"99") + " " +
                                    STRING(par_cdoperad,"x(10)") + " " +
                                    STRING(crapope.nmoperad,"x(15)") + " " + 
                                    STRING(par_nrdconta,"99999999") + ' "' +
                                    STRING(crapass.nmprimtl,"x(15)") + '" ' +
                                    STRING(TIME,"HH:MM:SS") + " " +
                                    STRING(aux_terminal,"x(15)") + " " +
                                    STRING(par_nmdatela,"x(30)") +
                                    " >> /usr/coop/" + crapcop.dsdircop + 
                                    "/arq/.acessos.dat").
                    END.
            END.

        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999.".
                LEAVE.
            END.

        RUN busca_cabrel IN h-b1wgen9999 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT 40, /** Codigo Relatorio **/
                                          INPUT par_nrdconta,
                                          INPUT par_dtmvtolt,
                                         OUTPUT TABLE tt-erro,        
                                         OUTPUT TABLE tt-cabrel).
    
        DELETE PROCEDURE h-b1wgen9999.
        
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.
            
        CREATE tt-dados_cooperado.
        ASSIGN tt-dados_cooperado.nrdconta = crapass.nrdconta
               tt-dados_cooperado.nmprimtl = crapass.nmprimtl
               tt-dados_cooperado.cdagenci = crapage.cdagenci
               tt-dados_cooperado.nmresage = crapage.nmresage
               tt-dados_cooperado.vllimcre = crapass.vllimcre.
        
        RUN consulta-extrato (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nrdconta,
                              INPUT par_dtiniper,
                              INPUT par_dtfimper,
                              INPUT par_idorigem,
                              INPUT par_idseqttl,
                              INPUT par_nmdatela,
                              INPUT FALSE,  /** LOG **/
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-extrato_conta).

        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        /** Cheques recebidos em deposito **/
        IF  par_inrelext = 2 OR par_inrelext = 4  THEN
            DO: 
                RUN obtem-cheques-deposito (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtiniper,
                                            INPUT par_dtfimper,
                                            INPUT FALSE,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT FALSE,  /** LOG **/
                                           OUTPUT aux_qtregist,
                                           OUTPUT TABLE tt-extrato_cheque).

                /******* Desabilitado - Tarefa 22.635 ********
                RUN obtem-juros-limite-credito (INPUT par_cdcooper, 
                                                INPUT par_cdagenci, 
                                                INPUT par_nrdcaixa, 
                                                INPUT par_cdoperad, 
                                                INPUT par_nmdatela, 
                                                INPUT par_idorigem, 
                                                INPUT par_nrdconta, 
                                                INPUT par_idseqttl, 
                                                INPUT par_dtmvtolt, 
                                                INPUT par_flgerlog,          
                                                INPUT TABLE tt-extrato_conta,
                                               OUTPUT TABLE tt-taxajuros,
                                               OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE = "NOK"  THEN
                    LEAVE.
                *********************************************/     
            END.

        /** Depositos identificados **/
        IF  par_inrelext = 3 OR par_inrelext = 4  THEN
            DO:
                RUN obtem-depositos-identificados 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtiniper,
                                       INPUT par_dtfimper,
                                       INPUT FALSE,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT FALSE, /** LOG **/
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-dep-identificado,
                                      OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE = "NOK"  THEN
                    LEAVE.
            END.

        /** Lancamentos Futuros - Hoje somente utilizado no InternetBank **/
        IF  par_inrelext = 5 OR (par_inrelext = 4 AND par_idorigem = 3)  THEN
            DO:
                RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT 
                    SET h-b1wgen0003.

                IF  NOT VALID-HANDLE(h-b1wgen0003)  THEN
                    DO:
                        aux_dscritic = "Handle invalido para BO b1wgen0003.".
                        LEAVE.
                    END.

                RUN consulta-lancamento IN h-b1wgen0003 
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE,  /** LOG **/
                                       OUTPUT TABLE tt-totais-futuros,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-lancamento_futuro).

                DELETE PROCEDURE h-b1wgen0003.

                IF  RETURN-VALUE = "NOK"  THEN
                    LEAVE.
            END.

        RUN gera-tarifa-extrato (INPUT par_cdcooper, 
                                 INPUT par_cdagenci, 
                                 INPUT par_nrdcaixa, 
                                 INPUT par_cdoperad, 
                                 INPUT par_nmdatela, 
                                 INPUT par_idorigem, 
                                 INPUT par_nrdconta, 
                                 INPUT par_idseqttl, 
                                 INPUT par_dtiniper, 
                              /*   INPUT par_inisenta,  */
                                 INPUT par_inproces,     
                                 INPUT par_flgtarif, 
                                 INPUT FALSE,   /** LOG **/
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT 0,
                                OUTPUT TABLE tt-msg-confirma,
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        ASSIGN aux_flgtrans = TRUE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        aux_dscritic = tt-erro.dscritic.
                    ELSE
                        aux_dscritic = "Nao foi possivel carregar o extrato.".
                END.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstraint,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,  
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstraint,
                            INPUT TRUE,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                                     
    RETURN "OK".    

END PROCEDURE. 
/******************************************************************************/
/**       Procedure para tratar registro do extrato de conta corrente        **/
/******************************************************************************/
PROCEDURE gera-registro-extrato:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nmdtable AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgident AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrdconta LIKE craplcm.nrdconta                      NO-UNDO.
    DEF VAR aux_dtmvtolt LIKE craplcm.dtmvtolt                      NO-UNDO.
    DEF VAR aux_nrdolote LIKE craplcm.nrdolote                      NO-UNDO.
    DEF VAR aux_cdagenci LIKE craplcm.cdagenci                      NO-UNDO.
    DEF VAR aux_cdbccxlt LIKE craplcm.cdbccxlt                      NO-UNDO.
    DEF VAR aux_cdcoptfn LIKE craplcm.cdcoptfn                      NO-UNDO.
    DEF VAR aux_vllanmto LIKE craplcm.vllanmto                      NO-UNDO.
    DEF VAR aux_dsidenti LIKE craplcm.dsidenti                      NO-UNDO.
    DEF VAR aux_indebcre LIKE craphis.indebcre                      NO-UNDO.
    DEF VAR aux_inhistor LIKE craphis.inhistor                      NO-UNDO.
    DEF VAR aux_cdhistor LIKE craphis.cdhistor                      NO-UNDO.
    DEF VAR aux_dsextrat LIKE craphis.dsextrat                      NO-UNDO.
    DEF VAR aux_dshistor LIKE craphis.dshistor                      NO-UNDO.

    DEF VAR aux_nrdocmto AS CHAR                                    NO-UNDO.
    DEF VAR aux_dslibera AS CHAR                                    NO-UNDO.
    
        
    FIND craplcm WHERE ROWID(craplcm) = par_nrdrowid NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craplcm  THEN
        DO:
            ASSIGN par_dscritic = "Lancamento nao cadastrado.".
            RETURN "NOK".
        END.   
        
    ASSIGN aux_nrdconta = craplcm.nrdconta
           aux_dtmvtolt = craplcm.dtmvtolt
           aux_nrdolote = craplcm.nrdolote
           aux_cdagenci = craplcm.cdagenci
           aux_cdbccxlt = craplcm.cdbccxlt           
           aux_cdcoptfn = craplcm.cdcoptfn
           aux_vllanmto = craplcm.vllanmto
           aux_dsidenti = IF  par_flgident   THEN 
                              CAPS(craplcm.dsidenti)
                          ELSE 
                              ""
           aux_nrdocmto = IF SUBSTR(craplcm.cdpesqbb,1,20) = "Fato gerador tarifa:" THEN
                             STRING(INT(SUBSTR(craplcm.cdpesqbb,21)),"zzzzz999999")
                          ELSE
                          IF CAN-DO(aux_lshistor,STRING(craplcm.cdhistor)) THEN
                             STRING(craplcm.nrdocmto,"zzzzz,zz9,9")
                          ELSE 
                          IF LENGTH(STRING(craplcm.nrdocmto)) < 10 THEN
                             STRING(craplcm.nrdocmto,"zzzzzzz,zz9")
                          ELSE
                             SUBSTR(STRING(craplcm.nrdocmto,
                                       "9999999999999999999999999"),15,11).
                       
    FIND craphis WHERE craphis.cdcooper = craplcm.cdcooper AND
                       craphis.cdhistor = craplcm.cdhistor NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL craphis  THEN
        ASSIGN aux_indebcre = " "
               aux_cdhistor = 0    
               aux_dsextrat = STRING(craplcm.cdhistor,"9999") + " - " + 
                              "Nao cadastrado!" 
               aux_dshistor = aux_dsextrat
               aux_inhistor = 0.                   
    ELSE 
        DO:
            ASSIGN aux_dslibera = "".
                
            IF  CAN-DO("3,4,5",STRING(craphis.inhistor))  THEN 
                DO:
                    FIND crapdpb WHERE crapdpb.cdcooper = craplcm.cdcooper AND
                                       crapdpb.dtmvtolt = craplcm.dtmvtolt AND
                                       crapdpb.cdagenci = craplcm.cdagenci AND
                                       crapdpb.cdbccxlt = craplcm.cdbccxlt AND
                                       crapdpb.nrdolote = craplcm.nrdolote AND
                                       crapdpb.nrdconta = craplcm.nrdconta AND
                                       crapdpb.nrdocmto = craplcm.nrdocmto 
                                       NO-LOCK NO-ERROR.
                                                       
                    IF  NOT AVAIL crapdpb  THEN
                        ASSIGN aux_dslibera = "(**/**)".
                    ELSE
                    IF  crapdpb.inlibera = 1  THEN
                        ASSIGN aux_dslibera = "(" + SUBSTR(STRING(
                                              crapdpb.dtliblan),1,5)+ ")".
                    ELSE
                        ASSIGN aux_dslibera = "(Estorno)".

                END.
             
            ASSIGN aux_indebcre = craphis.indebcre
                   aux_inhistor = craphis.inhistor
                   aux_cdhistor = craphis.cdhistor.  

            IF  craphis.cdhistor = 508 THEN
                DO:
                    ASSIGN aux_dsextrat = craphis.dsextrat
                           aux_dshistor = craphis.dshistor.
                  
                    IF  craplcm.dscedent <> ""  THEN
                        ASSIGN aux_dsextrat = aux_dsextrat + " - "  + 
                                              craplcm.dscedent
                               aux_dshistor = aux_dshistor + " - "  + 
                                              craplcm.dscedent.
                END.
            ELSE /* Lancamento de pagamento de avalista */ 
            IF  CAN-DO("1539,1541,1542,1543,1544",STRING(craphis.cdhistor)) AND
                craplcm.nrseqava > 0 THEN
                DO:
                    ASSIGN aux_dsextrat = craphis.dsextrat
                           aux_dshistor = SUBSTR(craphis.dshistor,1,11) + " " +
                                          STRING(craplcm.nrseqava).
                END.
            ELSE
                DO:
                    ASSIGN aux_dsextrat =
                            IF CAN-DO("24,27,47,78,156,191,338,351,399,573,657",
                               STRING(craplcm.cdhistor)) THEN
                               craphis.dsextrat + craplcm.cdpesqbb
                            ELSE 
                               craphis.dsextrat.
                               
                    ASSIGN aux_dshistor =
                            IF CAN-DO("24,27,47,78,156,191,338,351,399,573,657",
                               STRING(craplcm.cdhistor)) THEN
                               craphis.dshistor + craplcm.cdpesqbb
                            ELSE 
                               craphis.dshistor.
                END.
        END.

    IF SUBSTR(craplcm.cdpesqbb,1,20) = "Fato gerador tarifa:" THEN
        aux_nrdocmto = STRING(INT(SUBSTR(craplcm.cdpesqbb,21)),"zzzzz999999").
    ELSE /* Para saque e saque em TAA compartilhado mostra no extrato o numero do documento e a hora */
    IF  craplcm.cdhistor = 316  OR craplcm.cdhistor = 918 THEN 
        aux_nrdocmto = STRING(craplcm.nrdocmto,"zzzz9") + " " +
                       STRING(INTE(craplcm.nrdocmto),"HH:MM").
    ELSE        
    IF  CAN-DO("375,376,377,537,538,539,771,772",STRING(craplcm.cdhistor))  THEN
        aux_nrdocmto = STRING(INTE(SUBSTR(craplcm.cdpesqbb,45,8)),
                              "zzzzz,zzz,9").
    ELSE /* Estorno Transferencia */
    IF  CAN-DO("567,568,569,773,774",STRING(craplcm.cdhistor))  THEN
        aux_nrdocmto = STRING(INTE(SUBSTR(craplcm.cdpesqbb,50,8)),
                              "zzzzz,zzz,9").
    ELSE
    IF  CAN-DO("104,302,303,590,591,597,687",STRING(craplcm.cdhistor))  THEN
        DO:
            IF  INTE(craplcm.cdpesqbb) > 0  THEN
                aux_nrdocmto = STRING(INTE(craplcm.cdpesqbb),"zzzzz,zzz,9").
            ELSE
                aux_nrdocmto = STRING(craplcm.nrdocmto,"zzz,zzz,zz9").
        END.
    ELSE     
    IF  craplcm.cdhistor = 418  THEN
        aux_nrdocmto = "    " + STRING(SUBSTR(craplcm.cdpesqbb,60,07)).
    ELSE /** Tratamento para transferencia entre contas **/
    IF  CAN-DO("1009,1011,1014,1015,1163,1167," +
               STRING(aux_cdhistaa) + "," + STRING(aux_cdhsetaa) + "," +
               STRING(aux_cdhisint) + "," + STRING(aux_cdhseint),
               STRING(craplcm.cdhistor))  THEN
        DO:
            ASSIGN aux_nrdocmto = STRING(craplcm.nrdctabb,"zzzzz,zzz,z").
            
            IF  CAN-DO("1009,1011,1163,1167" +
                       STRING(aux_cdhistaa) + "," + STRING(aux_cdhsetaa) + "," +
                       STRING(aux_cdhisint) + "," + STRING(aux_cdhseint),
                STRING(craplcm.cdhistor)) THEN
                aux_dsidenti = "Agencia: " + 
                          STRING(INTE(SUBSTR(craplcm.cdpesqbb,10,4)),"9999").
        END.
    ELSE
        aux_nrdocmto = IF  craplcm.cdhistor = 100  THEN
                           IF  craplcm.cdpesqbb <> ""  THEN
                                craplcm.cdpesqbb
                           ELSE 
                               STRING(craplcm.nrdocmto,"zzzzzzz,zz9")
                       ELSE 
                       IF  CAN-DO(aux_lshistor,STRING(craplcm.cdhistor))  THEN 
                           STRING(craplcm.nrdocmto,"zzzzz,zz9,9")
                       ELSE 
                       IF  LENGTH(STRING(craplcm.nrdocmto)) < 10  THEN
                           STRING(craplcm.nrdocmto,"zzzzzzz,zz9")
                       ELSE
                           SUBSTR(STRING(craplcm.nrdocmto,
                                         "9999999999999999999999999"),15,11).

    /* Se pagamento de percela, insere num. da parcela da descr. do extrato */
    IF  craplcm.nrparepr > 0 THEN
        DO:
            FIND crapepr WHERE crapepr.cdcooper = craplcm.cdcooper AND
                               crapepr.nrdconta = craplcm.nrdconta AND
                               crapepr.nrctremp = INT(craplcm.cdpesqbb)
                               NO-LOCK NO-ERROR NO-WAIT.

            IF AVAIL crapepr THEN
                ASSIGN aux_dsextrat = SUBSTRING(aux_dsextrat,1,13) + " "
                                      + STRING(craplcm.nrparepr,"999") 
                                      + "/" + STRING(crapepr.qtpreemp,"999").

        END.

    IF  par_nmdtable = "tt-extrato_conta"  THEN
        DO:
            FIND LAST tt-extrato_conta WHERE 
                      tt-extrato_conta.dtmvtolt = aux_dtmvtolt NO-LOCK NO-ERROR.

            ASSIGN aux_nrsequen = IF  AVAILABLE tt-extrato_conta  THEN
                                      tt-extrato_conta.nrsequen + 1
                                  ELSE
                                      1.
 
            CREATE tt-extrato_conta.
            ASSIGN tt-extrato_conta.nrdconta = aux_nrdconta
                   tt-extrato_conta.dtmvtolt = aux_dtmvtolt
                   tt-extrato_conta.nrsequen = aux_nrsequen
                   tt-extrato_conta.nrdolote = aux_nrdolote
                   tt-extrato_conta.cdagenci = aux_cdagenci
                   tt-extrato_conta.cdbccxlt = aux_cdbccxlt
                   tt-extrato_conta.cdcoptfn = aux_cdcoptfn
                   tt-extrato_conta.vllanmto = aux_vllanmto
                   tt-extrato_conta.dsidenti = aux_dsidenti
                   tt-extrato_conta.nrdocmto = aux_nrdocmto
                   tt-extrato_conta.dtliblan = aux_dslibera
                   tt-extrato_conta.indebcre = aux_indebcre
                   tt-extrato_conta.inhistor = aux_inhistor
                   tt-extrato_conta.cdhistor = aux_cdhistor
                   tt-extrato_conta.dsextrat = aux_dsextrat
                   tt-extrato_conta.dshistor = aux_dshistor.

            IF CAN-DO ("519,555,578,799,958", STRING(craplcm.cdhistor)) THEN
               DO:

                FIND FIRST craplmt WHERE 
                           craplmt.cdcooper = craplcm.cdcooper AND
                           craplmt.nrdconta = craplcm.nrdconta AND
                           craplmt.dttransa = craplcm.dtmvtolt AND
						   craplmt.hrtransa = craplcm.hrtransa AND	
                           craplmt.vldocmto = craplcm.vllanmto NO-LOCK NO-ERROR. 
            
                IF AVAIL craplmt THEN
                    ASSIGN tt-extrato_conta.nrseqlmt = craplmt.nrsequen.

            END.

        END.
    ELSE
    IF  par_nmdtable = "tt-dep-identificado"  THEN
        DO:
            CREATE tt-dep-identificado.
            ASSIGN tt-dep-identificado.dtmvtolt = aux_dtmvtolt
                   tt-dep-identificado.dsextrat = aux_dsextrat
                   tt-dep-identificado.dshistor = aux_dshistor
                   tt-dep-identificado.nrdocmto = aux_nrdocmto
                   tt-dep-identificado.indebcre = aux_indebcre 
                   tt-dep-identificado.vllanmto = aux_vllanmto
                   tt-dep-identificado.dsidenti = aux_dsidenti.
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-saldo:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
    DEF INPUT        PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT        PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT        PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT        PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT        PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT        PARAM par_dtrefere AS DATE NO-UNDO.
    DEF INPUT        PARAM par_idorigem AS INTE NO-UNDO. 

    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    DEF OUTPUT       PARAM TABLE FOR tt-saldos. 

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO.	
	
	
    EMPTY TEMP-TABLE tt-saldos.
    EMPTY TEMP-TABLE tt-erro.
      
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   
    RUN STORED-PROCEDURE pc_obtem_saldo_car 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, /* Cooperativa */
                          INPUT par_cdagenci, /* Agencia */
                          INPUT par_nrdcaixa, /* Nr. Caixa */
                          INPUT par_cdoperad, /* Operador */
                          INPUT par_nrdconta, /* Nr. Conta */
                          INPUT par_dtrefere, /* Dt. Referencia */
                         OUTPUT "", /* (OK|NOK) */
                         OUTPUT ?). /* Tabela Extrato da Conta */
            
    CLOSE STORED-PROC pc_obtem_saldo_car 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = pc_obtem_saldo_car.pr_des_reto
                          WHEN pc_obtem_saldo_car.pr_des_reto <> ?.

    IF  aux_dscritic <> ""  THEN
        DO:
        CREATE tt-erro.
        ASSIGN tt-erro.dscritic = aux_dscritic.
            
            RETURN "NOK".
        END. 
    ELSE
        DO:

      CREATE tt-saldos.

      EMPTY TEMP-TABLE tt-saldos.

      /*Leitura do XML de retorno da proc e criacao dos registros na tt-extrato_conta
       para visualizacao dos registros na tela */

      /* Buscar o XML na tabela de retorno da procedure Progress */ 
      ASSIGN xml_req = pc_obtem_saldo_car.pr_clob_ret. 

      /* Efetuar a leitura do XML*/ 
      SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
      PUT-STRING(ponteiro_xml,1) = xml_req. 

      /* Inicializando objetos para leitura do XML */ 
      CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
      CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
      CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
      CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
      CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

      IF ponteiro_xml <> ? THEN
        DO:
              xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
              xDoc:GET-DOCUMENT-ELEMENT(xRoot).
            
              DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

                  xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

                  IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 
   
                  IF xRoot2:NUM-CHILDREN > 0 THEN
                      CREATE tt-saldos.

                  DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
            
                      xRoot2:GET-CHILD(xField,aux_cont).

                      IF xField:SUBTYPE <> "ELEMENT" THEN 
                          NEXT. 
        
                      xField:GET-CHILD(xText,1).
        
                      ASSIGN tt-saldos.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME 	= "nrdconta".
                      ASSIGN tt-saldos.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                      ASSIGN tt-saldos.vlsddisp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsddisp".
                      ASSIGN tt-saldos.vlsdchsl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdchsl".
                      ASSIGN tt-saldos.vlsdbloq = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdbloq".
                      ASSIGN tt-saldos.vlsdblpr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdblpr".
                      ASSIGN tt-saldos.vlsdblfp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdblfp".
                      ASSIGN tt-saldos.vlsdindi = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdindi".
                      ASSIGN tt-saldos.vllimcre = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllimcre".
                      ASSIGN tt-saldos.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME 	= "cdcooper".
                      ASSIGN tt-saldos.vlsdeved = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdeved".
                      ASSIGN tt-saldos.vldeschq = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vldeschq".
                      ASSIGN tt-saldos.vllimutl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllimutl".
                      ASSIGN tt-saldos.vladdutl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vladdutl".
                      ASSIGN tt-saldos.vlsdrdca = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdrdca".
                      ASSIGN tt-saldos.vlsdrdpp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdrdpp".
                      ASSIGN tt-saldos.vllimdsc = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllimdsc".
                      ASSIGN tt-saldos.vlprepla = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprepla".
                      ASSIGN tt-saldos.vlprerpp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprerpp".
                      ASSIGN tt-saldos.vlcrdsal = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlcrdsal".
                      ASSIGN tt-saldos.qtchqliq = INT(xText:NODE-VALUE) WHEN xField:NAME 	= "vlcrdsal".
                      ASSIGN tt-saldos.qtchqass = INT(xText:NODE-VALUE) WHEN xField:NAME 	= "vlcrdsal".
                      ASSIGN tt-saldos.dtdsdclq = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdsdclq".
                      ASSIGN tt-saldos.vltotpar = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vltotpar".
                      ASSIGN tt-saldos.vlopcdia = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlopcdia".
                      ASSIGN tt-saldos.vlavaliz = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlavaliz".
                      ASSIGN tt-saldos.vlavlatr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlavlatr".
                      ASSIGN tt-saldos.qtdevolu = INT(xText:NODE-VALUE) WHEN xField:NAME 	= "qtdevolu".
                      ASSIGN tt-saldos.vltotren = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vltotren". 
                      ASSIGN tt-saldos.vldestit = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vldestit".
                      ASSIGN tt-saldos.vllimtit = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllimtit".
                      ASSIGN tt-saldos.vlsdempr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdempr".
                      ASSIGN tt-saldos.vlsdfina = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdfina".
                      ASSIGN tt-saldos.vlsrdc30 = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsrdc30".
                      ASSIGN tt-saldos.vlsrdc60 = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsrdc60".
                      ASSIGN tt-saldos.vlsrdcpr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsrdcpr".
                      ASSIGN tt-saldos.vlsrdcpo = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsrdcpo".
                      ASSIGN tt-saldos.vlsdcota = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdcota".
                      ASSIGN tt-saldos.vlblqtaa = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlblqtaa".
                      ASSIGN tt-saldos.vlstotal = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlstotal".
                      ASSIGN tt-saldos.vlsaqmax = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsaqmax".
                      ASSIGN tt-saldos.vlacerto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlacerto".
                      ASSIGN tt-saldos.dslimcre = xText:NODE-VALUE WHEN xField:NAME			  = "dslimcre".
                      ASSIGN tt-saldos.vlipmfpg = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlipmfpg".
                      ASSIGN tt-saldos.dtultlcr = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtultlcr".
                      ASSIGN tt-saldos.vlblqjud = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlblqjud".
        
        END.

        END.   
            
              SET-SIZE(ponteiro_xml) = 0. 

        END.
        
      /*Elimina os objetos criados*/
      DELETE OBJECT xDoc. 
      DELETE OBJECT xRoot. 
      DELETE OBJECT xRoot2. 
      DELETE OBJECT xField. 
      DELETE OBJECT xText.    
        
    RETURN "OK".  

    END.

END PROCEDURE.


PROCEDURE compor-saldo-dia:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    /** Utilizada para compor saldo do dia para procedure obtem-saldo-dia **/
    
    DEF INPUT        PARAM par_cdcooper LIKE craplcm.cdcooper       NO-UNDO.    
    DEF INPUT        PARAM par_vllanmto LIKE craplcm.vllanmto       NO-UNDO.
    DEF INPUT        PARAM par_cdhistor LIKE craplcm.cdhistor       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsddisp LIKE crapsda.vlsddisp       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdchsl LIKE crapsda.vlsdchsl       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdbloq LIKE crapsda.vlsdbloq       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdblpr LIKE crapsda.vlsdblpr       NO-UNDO. 
    DEF INPUT-OUTPUT PARAM par_vlsdblfp LIKE crapsda.vlsdblfp       NO-UNDO. 
    DEF INPUT-OUTPUT PARAM par_vlsdindi LIKE crapsda.vlsdindi       NO-UNDO.
    DEF       OUTPUT PARAM par_cdcritic LIKE crapcri.cdcritic       NO-UNDO.
    DEF PARAM BUFFER crabhis FOR craphis.

    FIND crabhis WHERE crabhis.cdcooper = par_cdcooper AND
                       crabhis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crabhis  THEN
        DO:
            ASSIGN par_cdcritic = 80. 
            RETURN "NOK".
        END.

    IF  crabhis.inhistor = 1  THEN
        par_vlsddisp = par_vlsddisp + par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 2  THEN
        par_vlsdchsl = par_vlsdchsl + par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 3  THEN
        par_vlsdbloq = par_vlsdbloq + par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 4  THEN
        par_vlsdblpr = par_vlsdblpr + par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 5  THEN
        par_vlsdblfp = par_vlsdblfp + par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 6  THEN
        par_vlsdindi = par_vlsdindi + par_vllanmto.
    ELSE      
    IF  crabhis.inhistor = 11  THEN
        par_vlsddisp = par_vlsddisp - par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 12  THEN
        par_vlsdchsl = par_vlsdchsl - par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 13  THEN
        par_vlsdbloq = par_vlsdbloq - par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 14  THEN
        par_vlsdblpr = par_vlsdblpr - par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 15  THEN
        par_vlsdblfp = par_vlsdblfp - par_vllanmto.
    ELSE
    IF  crabhis.inhistor = 16  THEN
        par_vlsdindi = par_vlsdindi - par_vllanmto.
    ELSE
        DO:
            ASSIGN par_cdcritic = 83. 
            RETURN "NOK".
        END.
            
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE obtem-cpmf:
    
    DEF INPUT        PARAM par_cdcooper    AS INTE NO-UNDO.
    DEF INPUT        PARAM par_cdagenci    AS INTE NO-UNDO.
    DEF INPUT        PARAM par_nrdcaixa    AS INTE NO-UNDO.
    DEF INPUT        PARAM par_cdoperad    AS CHAR NO-UNDO.
    DEF INPUT        PARAM par_nrdconta    AS INTE NO-UNDO.
    DEF INPUT        PARAM par_idorigem    AS INTE NO-UNDO. 
    DEF INPUT        PARAM par_idseqttl    AS INTE NO-UNDO.
    DEF INPUT        PARAM par_nmdatela    AS CHAR NO-UNDO.
    
    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    DEF OUTPUT       PARAM TABLE FOR tt-cpmf.
    
    EMPTY TEMP-TABLE tt-cpmf.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados de CPMF.".
    
    FIND FIRST crapdat  WHERE
               crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL crapdat THEN
        DO:
            ASSIGN aux_cdcritic = 1
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).      
                           
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_cdcritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,  
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid). 

            RETURN "NOK".

         END.
                       
    CREATE tt-cpmf.
    ASSIGN tt-cpmf.dsexcpmf = YEAR(crapdat.dtmvtolt) - 1.
    CREATE tt-cpmf.
    ASSIGN tt-cpmf.dsexcpmf = YEAR(crapdat.dtmvtolt).

    FOR EACH crapipm WHERE crapipm.cdcooper = par_cdcooper  AND
                           crapipm.nrdconta = par_nrdconta AND
                           crapipm.dtdebito > DATE(12,31,
                                 YEAR(crapdat.dtmvtolt) - 2) NO-LOCK:
  
        IF   YEAR(crapipm.dtdebito) = YEAR(crapdat.dtmvtolt)   THEN 
             FIND LAST tt-cpmf NO-ERROR.
        ELSE
             FIND FIRST tt-cpmf NO-ERROR.
         
        ASSIGN tt-cpmf.vlbscpmf = tt-cpmf.vlbscpmf + crapipm.vlbasipm
               tt-cpmf.vlpgcpmf = tt-cpmf.vlpgcpmf + crapipm.vldoipmf.

    END. /* fim do FOR EACH */
    
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega_dep_vista:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-saldos.
    DEF OUTPUT PARAM TABLE FOR tt-libera-epr.
    
    DEF VAR aux_vlsaqmax AS DECI                                    NO-UNDO.
    DEF VAR aux_vlacerto AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsddisp AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdbloq AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdblpr AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdblfp AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdchsl AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdindi AS DECI                                    NO-UNDO.
    DEF VAR aux_vlstotal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlalipmf AS DECI                                    NO-UNDO.
    DEF VAR aux_vlestorn AS DECI                                    NO-UNDO.
    DEF VAR aux_vlestabo AS DECI                                    NO-UNDO.
    DEF VAR aux_vlipmfpg AS DECI                                    NO-UNDO.
    DEF VAR aux_insaqmax AS DECI                                    NO-UNDO.
    DEF VAR aux_txdoipmf AS DECI                                    NO-UNDO.
    DEF VAR aux_vlipmfap AS DECI                                    NO-UNDO.
    DEF VAR aux_vllibera AS DECI                                    NO-UNDO.

    DEF VAR aux_indoipmf AS INTE                                    NO-UNDO.

    DEF VAR tab_txcpmfcc AS DECI                                    NO-UNDO.
    DEF VAR tab_txrdcpmf AS DECI                                    NO-UNDO.
    DEF VAR tab_txiofrda AS DECI                                    NO-UNDO.
    DEF VAR tab_txiofepr AS DECI                                    NO-UNDO.

    DEF VAR tab_indabono AS INTE                                    NO-UNDO.

    DEF VAR tab_dtinipmf AS DATE                                    NO-UNDO.
    DEF VAR tab_dtfimpmf AS DATE                                    NO-UNDO.
    DEF VAR tab_dtiniiof AS DATE                                    NO-UNDO.
    DEF VAR tab_dtfimiof AS DATE                                    NO-UNDO.
    DEF VAR tab_dtiniabo AS DATE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-saldos.
    EMPTY TEMP-TABLE tt-libera-epr.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Consultar dados Dep. Vista.".
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".
        END.    

    /** Tabela com a taxa do CPMF **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRCPMFCCR" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 641
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".             
        END.
 
    ASSIGN tab_dtinipmf = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           tab_dtfimpmf = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           tab_txcpmfcc = IF  par_dtmvtolt >= tab_dtinipmf  AND
                              par_dtmvtolt <= tab_dtfimpmf  THEN
                              DECI(SUBSTR(craptab.dstextab,23,13))
                          ELSE 
                              0
           tab_txrdcpmf = IF  par_dtmvtolt >= tab_dtinipmf  AND
                              par_dtmvtolt <= tab_dtfimpmf  THEN
                              DECI(SUBSTR(craptab.dstextab,38,13))
                          ELSE 
                              1
           tab_indabono = INTE(SUBSTR(craptab.dstextab,51,1)) 
           tab_dtiniabo = DATE(INTE(SUBSTR(craptab.dstextab,56,2)),
                               INTE(SUBSTR(craptab.dstextab,53,2)),
                               INTE(SUBSTR(craptab.dstextab,59,4))). 

    /** Tabela com a taxa do IOF sobre aplicacoes **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRIOFRDCA" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 641
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".             
        END.

    ASSIGN tab_dtiniiof = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           tab_dtfimiof = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           tab_txiofrda = IF  par_dtmvtolt >= tab_dtiniiof  AND
                              par_dtmvtolt <= tab_dtfimiof  THEN
                              DECI(SUBSTR(craptab.dstextab,23,16))
                          ELSE 
                              0.

    /** Tabela com a taxa do IOF sobre emprestimos **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "CTRIOFEMPR" AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.
      
    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 626
                   aux_dscritic = "".
             
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".
        END.
    
    ASSIGN tab_dtiniiof = DATE(INTE(SUBSTR(craptab.dstextab,4,2)),
                               INTE(SUBSTR(craptab.dstextab,1,2)),
                               INTE(SUBSTR(craptab.dstextab,7,4)))
           tab_dtfimiof = DATE(INTE(SUBSTR(craptab.dstextab,15,2)),
                               INTE(SUBSTR(craptab.dstextab,12,2)),
                               INTE(SUBSTR(craptab.dstextab,18,4)))
           tab_txiofepr = IF  par_dtmvtolt >= tab_dtiniiof  AND
                              par_dtmvtolt <= tab_dtfimiof  THEN
                              DECI(SUBSTR(craptab.dstextab,23,16))
                          ELSE
                              0.

    FIND FIRST crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                             crapsld.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsld  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta/dv: " + STRING(par_nrdconta) + 
                                  " sem registro de saldo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

            RETURN "NOK".
        END.
         
    ASSIGN aux_vlsddisp = crapsld.vlsddisp
           aux_vlsdbloq = crapsld.vlsdbloq
           aux_vlsdblpr = crapsld.vlsdblpr
           aux_vlsdblfp = crapsld.vlsdblfp
           aux_vlsdchsl = crapsld.vlsdchsl
           aux_vlsdindi = crapsld.vlsdindi
           aux_vlipmfap = 0
           aux_vlestabo = 0.     

    FOR EACH craplcm WHERE craplcm.cdcooper  = par_cdcooper AND
                           craplcm.nrdconta  = par_nrdconta AND
                           craplcm.dtmvtolt  = par_dtmvtolt AND
                           craplcm.cdhistor <> 289 
                           USE-INDEX craplcm2 NO-LOCK:
        
        RUN compor-saldo-dia (INPUT        par_cdcooper,
                              INPUT        craplcm.vllanmto,
                              INPUT        craplcm.cdhistor,
                              INPUT-OUTPUT aux_vlsddisp,
                              INPUT-OUTPUT aux_vlsdchsl,
                              INPUT-OUTPUT aux_vlsdbloq,
                              INPUT-OUTPUT aux_vlsdblpr,
                              INPUT-OUTPUT aux_vlsdblfp,
                              INPUT-OUTPUT aux_vlsdindi,
                                    OUTPUT aux_cdcritic,
                              BUFFER craphis).
                            
        IF  RETURN-VALUE = "NOK"  THEN  
            DO:
                ASSIGN aux_dscritic = "".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).      
                   
                RETURN "NOK".
            END.
        
        ASSIGN aux_txdoipmf = tab_txcpmfcc             
               aux_indoipmf = IF  tab_indabono = 0  AND
                                  CAN-DO("114,117,127,160",
                                         STRING(craplcm.cdhistor))  THEN
                                  1
                              ELSE 
                                  craphis.indoipmf.

        /** Calcula CPMF para os lancamentos **/
        IF  aux_indoipmf > 1  THEN
            DO:
                IF  craphis.indebcre = "D"  THEN
                    aux_vlipmfap = aux_vlipmfap +
                                   TRUNC(craplcm.vllanmto * tab_txcpmfcc,2).
                ELSE
                IF  craphis.indebcre = "C"  THEN
                    aux_vlipmfap = aux_vlipmfap -
                                   TRUNC(craplcm.vllanmto * tab_txcpmfcc,2).
                ELSE 
                    .
            END.
        ELSE
        IF  craphis.inhistor = 12  THEN
            DO:
                IF  craplcm.cdhistor <> 43  THEN
                    ASSIGN aux_vlsdchsl = aux_vlsdchsl -
                                       TRUNC(craplcm.vllanmto * tab_txcpmfcc,2)
                           aux_vlsddisp = aux_vlsddisp +
                                       TRUNC(craplcm.vllanmto * tab_txcpmfcc,2)
                           aux_vlipmfap = aux_vlipmfap +
                                       TRUNC(craplcm.vllanmto * tab_txcpmfcc,2).
            END.

        IF  tab_indabono = 0                                    AND
            tab_dtiniabo <= craplcm.dtrefere                    AND
            CAN-DO("186,187,498,500",STRING(craplcm.cdhistor))  THEN
            ASSIGN aux_vlestorn = TRUNC(craplcm.vllanmto * tab_txcpmfcc,2)
                   aux_vlipmfap = aux_vlipmfap + aux_vlestorn +
                                  TRUNC(aux_vlestorn * tab_txcpmfcc,2)
                   aux_vlestabo = aux_vlestabo + craplcm.vllanmto.

    END. /** Fim do FOR EACH craplcm **/
         
    ASSIGN aux_vlestabo = TRUNC(aux_vlestabo * tab_txiofrda,2)
           aux_vlacerto = aux_vlsddisp - crapsld.vlipmfap -
                          crapsld.vlipmfpg - aux_vlipmfap - aux_vlestabo
           aux_vlsaqmax = IF  aux_vlacerto <= 0  THEN 
                              0
                          ELSE 
                              TRUNC(aux_vlacerto * tab_txrdcpmf,2)
           aux_vlacerto = aux_vlacerto + aux_vlsdbloq + aux_vlsdblpr +
                          aux_vlsdblfp
           aux_vlacerto = IF  aux_vlacerto < 0  THEN
                              TRUNC(aux_vlacerto * (1 + tab_txcpmfcc),2)
                          ELSE 
                              aux_vlacerto
           aux_vlstotal = aux_vlsddisp + aux_vlsdbloq + aux_vlsdblpr +
                          aux_vlsdblfp + aux_vlsdchsl
           aux_vlblqjud = 0
           aux_vlresblq = 0.

    /*** Busca Saldo Bloqueado Judicial ***/
    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* nrcpfcgc */
                                             INPUT 1, /* 1 - Bloqueio */
                                             INPUT 1, /* 1 - Dep.Vista */
                                             INPUT par_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/

	{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    /* Verifica se ha contratos de acordo */
    RUN STORED-PROCEDURE pc_ret_vlr_bloq_acordo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                            ,INPUT par_nrdconta
                                            ,OUTPUT 0
                                            ,OUTPUT 0
                                            ,OUTPUT "").

    CLOSE STORED-PROC pc_ret_vlr_bloq_acordo
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = INT(pc_ret_vlr_bloq_acordo.pr_cdcritic) WHEN pc_ret_vlr_bloq_acordo.pr_cdcritic <> ?
            aux_dscritic = pc_ret_vlr_bloq_acordo.pr_dscritic WHEN pc_ret_vlr_bloq_acordo.pr_dscritic <> ?
            aux_vlblqaco = DECIMAL(pc_ret_vlr_bloq_acordo.pr_vlblqaco).
			
	IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
      DO:
	    
		RUN gera_erro (INPUT par_cdcooper,
						INPUT par_cdagenci,
						INPUT par_nrdcaixa,
						INPUT 1,            /** Sequencia **/
						INPUT aux_cdcritic,
						INPUT-OUTPUT aux_dscritic).      
                   
		RETURN "NOK".
	  END.			
    

    CREATE tt-saldos.
    ASSIGN tt-saldos.vlsddisp = aux_vlsddisp          
           tt-saldos.vlsdbloq = aux_vlsdbloq
           tt-saldos.vlsdblpr = aux_vlsdblpr
           tt-saldos.vlsdblfp = aux_vlsdblfp
           tt-saldos.vlsdchsl = aux_vlsdchsl
           tt-saldos.vlstotal = aux_vlsdchsl + aux_vlsdblfp + 
                                aux_vlsdblpr + aux_vlsdbloq + aux_vlsddisp
           tt-saldos.vlsaqmax = aux_vlsaqmax
           tt-saldos.vlacerto = aux_vlacerto
           tt-saldos.vllimcre = crapass.vllimcre 
           tt-saldos.dslimcre = IF  crapass.tplimcre = 1  THEN 
                                    "(CP)"
                                ELSE 
                                IF  crapass.tplimcre = 2  THEN
                                    "(SM)"
                                ELSE 
                                    ""
           tt-saldos.dtultlcr = crapass.dtultlcr
           tt-saldos.vlipmfpg = crapsld.vlipmfpg
           tt-saldos.vlblqjud = aux_vlblqjud
		   tt-saldos.vlblqaco = aux_vlblqaco.

    FOR EACH crapdpb WHERE crapdpb.cdcooper = par_cdcooper AND
                           crapdpb.nrdconta = par_nrdconta AND
                           crapdpb.cdhistor = 2            AND
                           crapdpb.inlibera = 1            AND
                           crapdpb.dtliblan > par_dtmvtolt
                           USE-INDEX crapdpb2 NO-LOCK:

        ASSIGN aux_vllibera = crapdpb.vllanmto.

        FOR EACH craplcm WHERE 
                 craplcm.cdcooper = par_cdcooper                       AND 
                 craplcm.nrdconta = crapdpb.nrdconta                   AND
                 craplcm.dtmvtolt = crapdpb.dtmvtolt                   AND
                (craplcm.cdhistor = 108                                OR
                 craplcm.cdhistor = 161                                OR
                 craplcm.cdhistor = 891                                OR
                 craplcm.cdhistor = 282)                               AND
                 craplcm.cdpesqbb = STRING(crapdpb.nrdocmto,"9999999")
                 USE-INDEX craplcm2 NO-LOCK:
                                                                   
            ASSIGN aux_vllibera = aux_vllibera - craplcm.vllanmto -
                                  TRUNC(craplcm.vllanmto * tab_txcpmfcc,2).

        END. /** Fim do FOR EACH craplcm **/

        ASSIGN aux_vllibera = TRUNC(aux_vllibera * tab_txrdcpmf,2).
        
        /** Calculo do IOF sobre o emprestimo **/
        ASSIGN aux_vllibera = aux_vllibera - 
                              TRUNC(crapdpb.vllanmto * tab_txiofepr,2).
        
        IF  aux_vllibera <= 0  THEN
            NEXT.

        CREATE tt-libera-epr.
        ASSIGN tt-libera-epr.dtlibera = crapdpb.dtliblan
               tt-libera-epr.vllibera = aux_vllibera.

    END. /** Fim do FOR EACH crapdpb **/
           
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".
        
END PROCEDURE.

PROCEDURE obtem-medias:
    
    DEF INPUT        PARAM p-cdcooper      AS INTE NO-UNDO.
    DEF INPUT        PARAM p-cod-agencia   AS INTE NO-UNDO.
    DEF INPUT        PARAM p-nro-caixa     AS INTE NO-UNDO.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR NO-UNDO.                
    DEF INPUT        PARAM p-nro-conta     AS INTE NO-UNDO.
    
    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    DEF OUTPUT       PARAM TABLE FOR tt-medias.
                
    DEF VAR aux_nrindtab   AS INTE           NO-UNDO.
    DEF VAR aux_contador   AS INTE           NO-UNDO.
    DEF VAR aux_nrindice   AS INTE           NO-UNDO.
    
    DEF VAR aux_nmmesano   AS CHAR           NO-UNDO.
    
    EMPTY TEMP-TABLE tt-medias.
    EMPTY TEMP-TABLE tt-erro.
        
    FIND crapsld WHERE 
         crapsld.nrdconta = p-nro-conta AND
         crapsld.cdcooper = p-cdcooper  NO-LOCK NO-ERROR.
                              
    FIND FIRST crapdat WHERE 
               crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

    /************** tratativa de erro ***************/
    IF   NOT AVAIL crapdat THEN
         DO:
             ASSIGN i-cod-erro = 1
                    c-dsc-erro = " ".                                        
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
                          
    ASSIGN aux_nmmesano = "JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ".
                                                           
    DO aux_contador = MONTH(crapdat.dtmvtolt) TO MONTH(crapdat.dtmvtolt) + 6:
           
        ASSIGN aux_nrindice = 6 + aux_contador
               aux_nrindice =  IF aux_nrindice > 12
                                  THEN aux_nrindice - 12
                                  ELSE aux_nrindice
               aux_nrindtab =  IF aux_nrindice > 6
                                  THEN aux_nrindice - 6
                                  ELSE aux_nrindice.
                                      
        CREATE tt-medias.
        ASSIGN tt-medias.periodo  = 
                   ENTRY(aux_nrindice, aux_nmmesano) +
                   IF    aux_nrindice > MONTH(crapdat.dtmvtolt)
                         THEN "/" + STRING(YEAR(crapdat.dtmvtolt) - 1,"9999")
                         ELSE "/" + STRING(YEAR(crapdat.dtmvtolt)    ,"9999")
               tt-medias.vlsmstre =
                   IF    aux_contador <> MONTH(crapdat.dtmvtolt) + 6
                         THEN STRING(crapsld.vlsmstre[aux_nrindtab])
                         ELSE STRING(crapsld.vlsmpmes).

    END. /* Fim do DO .. TO */
           
END PROCEDURE.

PROCEDURE carrega_medias:

    DEF  INPUT  PARAM  par_cdcooper  AS  INTE  NO-UNDO.                   
    DEF  INPUT  PARAM  par_cdagenci  AS  INTE  NO-UNDO. /** 0-TODOS **/
    DEF  INPUT  PARAM  par_nrdcaixa  AS  INTE  NO-UNDO.                     
    DEF  INPUT  PARAM  par_cdoperad  AS  CHAR  NO-UNDO.                
    DEF  INPUT  PARAM  par_nrdconta  AS  INTE  NO-UNDO.
    DEF  INPUT  PARAM  par_dtmvtolt  AS  DATE  NO-UNDO.
    DEF  INPUT  PARAM  par_idorigem  AS  INTE  NO-UNDO. 
    DEF  INPUT  PARAM  par_idseqttl  AS  INTE  NO-UNDO.
    DEF  INPUT  PARAM  par_nmdatela  AS  CHAR  NO-UNDO.
    DEF  INPUT  PARAM  par_flgerlog  AS  LOGI  NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-medias.
    DEF OUTPUT PARAM TABLE FOR tt-comp_medias.
    
    DEF VAR aux_vlsmnmes AS DECIMAL            NO-UNDO.
    DEF VAR aux_vlsmnesp AS DECIMAL            NO-UNDO.
    DEF VAR aux_vlsmnblq AS DECIMAL            NO-UNDO.
    DEF VAR aux_qtdiaute AS INTEGER            NO-UNDO.
    DEF VAR aux_vlsmdtri AS DECIMAL            NO-UNDO.
    DEF VAR aux_vlsmdsem AS DECIMAL            NO-UNDO.
    DEF VAR aux_vltsddis AS DECIMAL            NO-UNDO.
    DEF VAR aux_qtdiauti AS INTEGER            NO-UNDO.
    
    DEF VAR aux_dtmvtolt AS DATE               NO-UNDO.
    DEF VAR aux_dtmvtfim AS DATE               NO-UNDO.
    
    DEF VAR aux_nrmesano AS INTEGER            NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-comp_medias.
    EMPTY TEMP-TABLE tt-medias.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados para Extrato Medias.".
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapdat THEN
         DO:
            ASSIGN aux_cdcritic = 1
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

             RETURN "NOK".
         END.
    
    ASSIGN aux_qtdiaute = crapdat.qtdiaute.

    RUN obtem-medias (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-medias).
                     
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
        
            RETURN "NOK".
        END.
    
    FIND FIRST crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                             crapsld.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapsld   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta/dv: " + STRING(par_nrdconta) + 
                                  " sem registro de saldo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 

             RETURN "NOK".
         END.
    
    ASSIGN aux_vlsmnmes = crapsld.vlsmnmes
           aux_vlsmnesp = crapsld.vlsmnesp
           aux_vlsmnblq = crapsld.vlsmnblq
           aux_vlsmdsem = (crapsld.vlsmstre[1] + crapsld.vlsmstre[2] +
                           crapsld.vlsmstre[3] + crapsld.vlsmstre[4] +
                           crapsld.vlsmstre[5] + crapsld.vlsmstre[6]) / 6
           aux_nrmesano = IF   MONTH(crapdat.dtmvtolt) > 6   THEN 
                               MONTH(crapdat.dtmvtolt) - 6
                          ELSE 
                               MONTH(crapdat.dtmvtolt)
           aux_vlsmdtri = IF   aux_nrmesano = 1   THEN   /*  Meses 1 ou 7  */
                              (crapsld.vlsmstre[6] + crapsld.vlsmstre[5] +
                                      crapsld.vlsmstre[4]) / 3
                          ELSE
                          IF aux_nrmesano = 2   THEN   /*  Meses 2 ou 8  */
                            (crapsld.vlsmstre[1] + crapsld.vlsmstre[6] +
                                    crapsld.vlsmstre[5]) / 3
                          ELSE
                          IF aux_nrmesano = 3   THEN   /*  Meses 3 ou 9  */
                            (crapsld.vlsmstre[2] + crapsld.vlsmstre[1] +
                                    crapsld.vlsmstre[6]) / 3
                          ELSE
                          IF aux_nrmesano = 4   THEN   /*  Meses 4 ou 10 */
                            (crapsld.vlsmstre[3] + crapsld.vlsmstre[2] +
                                    crapsld.vlsmstre[1]) / 3
                          ELSE
                          IF aux_nrmesano = 5   THEN   /*  Meses 5 ou 11 */
                            (crapsld.vlsmstre[4] + crapsld.vlsmstre[3] +
                                    crapsld.vlsmstre[2]) / 3
                          ELSE
                          IF aux_nrmesano = 6   THEN   /*  Meses 6 ou 12 */
                            (crapsld.vlsmstre[5] + crapsld.vlsmstre[4] +
                                    crapsld.vlsmstre[3]) / 3
                          ELSE 0.
                           
    /* Primeiro dia do mes atual */
    ASSIGN aux_dtmvtolt = DATE("01/" + STRING(MONTH(par_dtmvtolt)) + "/" +  STRING(YEAR(par_dtmvtolt))).

    /* Busca pela data do movimento do dia anterior */
	FOR FIRST crapdat FIELDS(dtmvtoan) WHERE crapdat.cdcooper = par_cdcooper NO-LOCK: END.
		IF AVAILABLE crapdat THEN 
		DO:
			ASSIGN aux_dtmvtfim = crapdat.dtmvtoan.
		END.

    /* Loop do periodo do mes, do dia 1 ate a data do movimento anterior */
    DO WHILE aux_dtmvtolt <= aux_dtmvtfim :

		/* filtra a data na tabela de feriados */
		FOR FIRST crapfer FIELDS(dtferiad) WHERE crapfer.cdcooper = par_cdcooper AND crapfer.dtferiad = aux_dtmvtolt NO-LOCK: END.

		/* Se for sabado ou domingo ou feriado */
		IF ((weekday(aux_dtmvtolt) = 1) OR (weekday(aux_dtmvtolt) = 7) OR (AVAIL(crapfer))) THEN
		DO:
			ASSIGN aux_dtmvtolt = aux_dtmvtolt + 1.
		END.
		ELSE
		DO:
        FIND FIRST crapsda WHERE crapsda.cdcooper = par_cdcooper 
                             AND crapsda.nrdconta = par_nrdconta 
                             AND crapsda.dtmvtolt = aux_dtmvtolt
                           NO-LOCK NO-ERROR.
        IF AVAILABLE crapsda THEN
        DO:
				ASSIGN aux_vltsddis = aux_vltsddis + crapsda.vlsddisp.
        END.
        
			ASSIGN aux_qtdiauti = aux_qtdiauti + 1  /* incrementa a quantidade de dias uteis */
				   aux_dtmvtolt = aux_dtmvtolt + 1. /* atualiza a data do movimento */
        END.
    END.

    CREATE tt-comp_medias.
    ASSIGN tt-comp_medias.vlsmnmes = aux_vlsmnmes
           tt-comp_medias.vlsmnesp = aux_vlsmnesp
           tt-comp_medias.vlsmnblq = aux_vlsmnblq
           tt-comp_medias.qtdiaute = aux_qtdiaute
           tt-comp_medias.vlsmdtri = aux_vlsmdtri
           tt-comp_medias.vlsmdsem = aux_vlsmdsem
           tt-comp_medias.qtdiauti = aux_qtdiauti
           tt-comp_medias.vltsddis = aux_vltsddis / aux_qtdiauti.
           
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).           

    RETURN "OK".
END PROCEDURE.


/******************************************************************************/
/**         Procedure para obter saldos anteriores da conta-corrente         **/
/******************************************************************************/
PROCEDURE obtem-saldos-anteriores:                                            

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-saldos.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-saldos. 

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Consultar saldo anterior do cooperado.".
    
    IF  par_dtrefere = ?  THEN
        ASSIGN par_dtrefere = par_dtmvtoan.
    ELSE
    IF  par_dtrefere >= par_dtmvtolt  OR
        WEEKDAY(par_dtrefere) = 1     OR
        WEEKDAY(par_dtrefere) = 7     OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                               crapfer.dtferiad = par_dtrefere)  THEN
        DO:
            ASSIGN aux_cdcritic = 13
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 
                   
            RETURN "NOK".
        END.

    FIND crapsda WHERE crapsda.cdcooper = par_cdcooper AND
                       crapsda.nrdconta = par_nrdconta AND
                       crapsda.dtmvtolt = par_dtrefere 
                       USE-INDEX crapsda1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsda  THEN
        DO:
            ASSIGN aux_cdcritic = 853
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid). 
                   
            RETURN "NOK".
        END.

    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.

    /*** Busca Saldo Bloqueado Judicial ***/

    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* nrcpfcgc */
                                             INPUT 1, /* 1 - Bloqueio  */
                                             INPUT 1, /* 1 - Dep.Vista */
                                             INPUT par_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/
               
    CREATE tt-saldos.
    ASSIGN tt-saldos.vlsddisp = crapsda.vlsddisp
           tt-saldos.vlsdchsl = crapsda.vlsdchsl
           tt-saldos.vlsdbloq = crapsda.vlsdbloq
           tt-saldos.vlsdblpr = crapsda.vlsdblpr
           tt-saldos.vlsdblfp = crapsda.vlsdblfp
           tt-saldos.vlsdindi = crapsda.vlsdindi
           tt-saldos.vllimcre = crapsda.vllimcre
           tt-saldos.vlstotal = crapsda.vlsddisp + crapsda.vlsdbloq + 
                                crapsda.vlsdblpr + crapsda.vlsdblfp + 
                                crapsda.vlsdchsl + crapsda.vlsdindi
           tt-saldos.vlblqjud = aux_vlblqjud
		   tt-saldos.vllimcpa = crapsda.vllimcpa.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".        

END PROCEDURE.

PROCEDURE obtem-cabecalho: 

    DEF INPUT        PARAM p-cdcooper      AS INTE NO-UNDO.                   
    DEF INPUT        PARAM p-cod-agencia   AS INTE NO-UNDO.
    DEF INPUT        PARAM p-nro-caixa     AS INTE NO-UNDO.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR NO-UNDO.                
    DEF INPUT        PARAM p-nro-conta     AS INTE NO-UNDO.
    DEF INPUT        PARAM p-nro-conta-itg AS CHAR NO-UNDO.
    DEF INPUT        PARAM p-data-inicio   AS DATE NO-UNDO.
    DEF INPUT        PARAM p-data-fim      AS DATE NO-UNDO.
    DEF INPUT        PARAM p-origem        AS INTE NO-UNDO. 

    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-cabec.
    
    DEF VAR aux_cdempres                   AS INT  NO-UNDO.
    DEF VAR aux_qttitula                   AS INT  NO-UNDO.
	DEF VAR aux_nmsegntl				   LIKE crapttl.nmextttl NO-UNDO.

	DEFINE BUFFER crabttl FOR crapttl.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabec.

    FIND FIRST crapdat WHERE 
               crapdat.cdcooper = p-cdcooper 
               NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapdat THEN
         DO:
             ASSIGN i-cod-erro = 1
                    c-dsc-erro = " ".

             { sistema/generico/includes/b1wgen0001.i }
                     
             RETURN "NOK".
         END.
    
    IF   p-nro-conta <> 0 THEN
         FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                            crapass.nrdconta = p-nro-conta
                            NO-LOCK NO-ERROR.
    ELSE
    IF   p-nro-conta-itg <> "" THEN
         FIND crapass WHERE crapass.cdcooper = p-cdcooper      AND
                            crapass.nrdctitg = p-nro-conta-itg
                            NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
             ASSIGN i-cod-erro = 9
                    c-dsc-erro = " ".

             { sistema/generico/includes/b1wgen0001.i }
                     
             RETURN "NOK".
         END.

    ASSIGN aux_cdempres = 0.
    
    IF   crapass.inpessoa = 1 THEN
         DO:    
             /* Quantidade de titulares */
             FOR EACH crapttl WHERE crapttl.cdcooper = p-cdcooper   AND
                                    crapttl.nrdconta = crapass.nrdconta
                                    NO-LOCK:
                 ASSIGN aux_qttitula = aux_qttitula + 1.
             END.

             FIND crapttl WHERE crapttl.cdcooper = p-cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta AND
                                crapttl.idseqttl = 1           
                                NO-LOCK NO-ERROR.
         
             IF   NOT AVAILABLE crapttl THEN
                  DO:
                      ASSIGN i-cod-erro = 821
                             c-dsc-erro = " ".

                      { sistema/generico/includes/b1wgen0001.i }
                     
                      RETURN "NOK".
                  END.
                  
             ASSIGN aux_cdempres = crapttl.cdempres.
             
			 FOR FIRST crabttl FIELDS(nmextttl) 
			                   WHERE crabttl.cdcooper = p-cdcooper       AND
                                     crabttl.nrdconta = crapass.nrdconta AND
                                     crabttl.idseqttl = 2           
                                     NO-LOCK:

               ASSIGN aux_nmsegntl = crabttl.nmextttl.

         END.
             
         END.
    ELSE
         DO:
             /* Quantidade de titulares*/
             ASSIGN aux_qttitula = 1.

             FIND crapjur WHERE crapjur.cdcooper = p-cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.                  
         END.

    ASSIGN p-nro-conta     = crapass.nrdconta
           p-nro-conta-itg = crapass.nrdctitg.

    CREATE tt-cabec.
    ASSIGN tt-cabec.nrmatric = crapass.nrmatric
           tt-cabec.cdagenci = crapass.cdagenci
           tt-cabec.dtadmiss = crapass.dtadmiss
           tt-cabec.nrdctitg = fgetnrdctitg()
           tt-cabec.nrctainv = crapass.nrctainv
           tt-cabec.dtadmemp = crapass.dtadmemp
           tt-cabec.nmprimtl = crapass.nmprimtl
           tt-cabec.nmsegntl = aux_nmsegntl
           tt-cabec.dtaltera = fgetdtaltera(p-cdcooper)
           tt-cabec.dsnatopc = fgetNatOpc  (p-cdcooper, p-nro-conta)
           tt-cabec.nrramfon = fgetNrRamFon(p-cdcooper)
           tt-cabec.dtdemiss = crapass.dtdemiss
           tt-cabec.dsnatura = IF  AVAIL crapttl  THEN 
                                   crapttl.dsnatura
                               ELSE
                                   ""
           tt-cabec.nrcpfcgc = fgetNrCpfCgc()
           tt-cabec.cdsecext = crapass.cdsecext
           tt-cabec.indnivel = crapass.indnivel
           tt-cabec.dstipcta = fgetDsTipCta(p-cdcooper)
           tt-cabec.dssitdct = fgetDsSitDct()
           tt-cabec.cdempres = aux_cdempres
           tt-cabec.cdturnos = IF   AVAILABLE crapttl THEN
                                    crapttl.cdturnos
                               ELSE
                                    0
           tt-cabec.cdtipsfx = crapass.cdtipsfx
           tt-cabec.nrdconta = crapass.nrdconta
           tt-cabec.vllimcre = crapass.vllimcre
           tt-cabec.inpessoa = crapass.inpessoa
           tt-cabec.qttitula = aux_qttitula
           tt-cabec.dssititg = IF crapass.flgctitg = 2 THEN
                                  "Ativa"
                               ELSE
                               IF crapass.flgctitg = 3 THEN
                                  "Inativa"
                               ELSE
                               IF crapass.nrdctitg <> "" THEN
                                  "Em Proc"
                               ELSE
                                  "".
           
END PROCEDURE.
          
PROCEDURE completa-cabecalho: 

    DEF INPUT        PARAM p-cdcooper      AS INTE NO-UNDO.                   
    DEF INPUT        PARAM p-cod-agencia   AS INTE NO-UNDO.
    DEF INPUT        PARAM p-nro-caixa     AS INTE NO-UNDO.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR NO-UNDO.                
    DEF INPUT        PARAM p-nro-conta     AS INTE NO-UNDO.
    DEF INPUT        PARAM p-nro-conta-itg AS CHAR NO-UNDO.
    DEF INPUT        PARAM p-data-inicio   AS DATE NO-UNDO.
    DEF INPUT        PARAM p-origem        AS INTE NO-UNDO. 

    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-comp_cabec.
    
    /*Devolucoes*/
    DEF VAR aux_qtdevolu AS INTE FORMAT "zzzzz9"         NO-UNDO.
    /*CL/Estouro*/
    DEF VAR aux_qtddsdev AS INTE                         NO-UNDO.
    DEF VAR aux_qtddtdev AS INTE                         NO-UNDO.
    /*Data SFN*/
    DEF VAR aux_dtabtcc2 AS DATE                         NO-UNDO.
    DEF VAR aux_dtabtcct AS CHAR                         NO-UNDO.
    /*Ft.Salari*/
    DEF VAR aux_ftsalari AS CHAR                         NO-UNDO.
    DEF VAR aux_messalar AS INTE                         NO-UNDO.
    DEF VAR aux_anosalar AS INTE                         NO-UNDO.
    /*Plano*/
    DEF VAR aux_vlprepla AS DECI FORMAT "zzz,zzz,zz9.99" NO-UNDO.
    /*Fls.Ret*/
    DEF VAR aux_qttalret AS INTE FORMAT "zz,zzz,zz9"     NO-UNDO.
    DEF VAR aux_qtfolret AS INTE                         NO-UNDO.
    DEF VAR aux_dtinicio AS DATE                         NO-UNDO.
    
    DEF VAR aux_flgdigit AS CHAR                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-comp_cabec.

    FIND FIRST crapdat WHERE 
               crapdat.cdcooper = p-cdcooper 
               NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapdat THEN
         DO:
             ASSIGN i-cod-erro = 1
                    c-dsc-erro = " ".

             { sistema/generico/includes/b1wgen0001.i }
                     
             RETURN "NOK".
         END.
    
    IF   p-nro-conta <> 0 THEN
         FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                            crapass.nrdconta = p-nro-conta
                            NO-LOCK NO-ERROR.
    ELSE
    IF   p-nro-conta-itg <> "" THEN
         FIND crapass WHERE crapass.cdcooper = p-cdcooper      AND
                            crapass.nrdctitg = p-nro-conta-itg
                            NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
             
             
             ASSIGN i-cod-erro = 9
                    c-dsc-erro = " ".

             { sistema/generico/includes/b1wgen0001.i }
                     
             RETURN "NOK".
         END.

    /* Devolucoes */
    ASSIGN aux_qtdevolu = 0.
    FOR EACH crapneg WHERE crapneg.cdcooper = p-cdcooper  AND
                           crapneg.nrdconta = p-nro-conta AND
                           crapneg.cdhisest = 1           AND
                           CAN-DO("11,12,13",STRING(crapneg.cdobserv))
                           NO-LOCK USE-INDEX crapneg2:

        ASSIGN aux_qtdevolu = aux_qtdevolu + 1.
    END.
    
    /* CL/Estouro */
    FIND FIRST crapsld WHERE crapsld.cdcooper = p-cdcooper AND
                             crapsld.nrdconta = p-nro-conta
                             NO-LOCK NO-ERROR.
                       
    IF AVAILABLE crapsld THEN
       ASSIGN aux_qtddtdev = crapsld.qtddtdev
              aux_qtddsdev = crapsld.qtddsdev.
    ELSE
       ASSIGN aux_qtddtdev = 0
              aux_qtddsdev = 0.
    
    /* Data SFN */
    ASSIGN aux_messalar = MONTH(crapass.dtedvmto)
           aux_anosalar = YEAR(crapass.dtedvmto).
           
    IF  crapass.vledvmto <> 0 THEN
        ASSIGN aux_ftsalari = STRING(crapass.vledvmto,"zzzz9") + " " + 
                              STRING(aux_messalar,"99") +  "/"  +
                              SUBSTR(STRING(aux_anosalar,"9999"),3,2).  
    ELSE
        ASSIGN aux_ftsalari = "".
    
    /* Plano */
    FIND FIRST crappla WHERE crappla.cdcooper = p-cdcooper   AND
                             crappla.nrdconta = p-nro-conta   AND
                             crappla.tpdplano = 1              AND
                             crappla.cdsitpla = 1
                             USE-INDEX crappla3 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crappla   THEN
         ASSIGN aux_vlprepla = 0.
    ELSE
         ASSIGN aux_vlprepla = crappla.vlprepla.
         
    /* Fls.Ret */
    ASSIGN aux_dtinicio = DATE(MONTH(p-data-inicio),01,YEAR(p-data-inicio)).
    FOR EACH crapfdc WHERE crapfdc.cdcooper  = p-cdcooper   AND
                           crapfdc.nrdconta  = p-nro-conta  AND
                           crapfdc.dtemschq <> ?            AND
                           crapfdc.dtretchq <> ?            AND
                           crapfdc.tpcheque = 1  NO-LOCK:

        IF   crapfdc.dtretchq >= aux_dtinicio  THEN
             aux_qtfolret = aux_qtfolret + 1.

    END.   /*  Fim do FOR EACH  --  Leitura do cadastro de cheques  */
    
    /* Data de abertura da conta mais antiga */
    FOR EACH crapsfn WHERE  crapsfn.cdcooper = p-cdcooper     AND
                            crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                            crapsfn.tpregist = 1                NO-LOCK 
                                BY  crapsfn.dtabtcct DESCENDING:
    
        ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct.
                            
    END.
    
    IF  aux_dtabtcc2 <> ? THEN
        aux_dtabtcct = STRING(DAY(aux_dtabtcc2),"99")   +
                       STRING(MONTH(aux_dtabtcc2),"99") +
                       STRING(YEAR(aux_dtabtcc2),"9999").
    ELSE
        aux_dtabtcct = "".
    
    /* 
        COMENTÁRIO FEITO EM 13/01/2014
        SERÁ LIBERADO P/ CONSULTA TODOS OS CARTOES ASSINATURA,
        CASO FUTURAMENTE SE QUEIRA CONSULTAR A CRAPDOC, SOMENTE DESCOMENTAR O CODIGO ABAIXO E 
        COMENTAR O ASSIGN DA VAR aux_flgdigit = "S".
    
    FIND LAST crapdoc WHERE crapdoc.cdcooper = p-cdcooper AND
                            crapdoc.nrdconta = p-nro-conta AND
                            crapdoc.tpdocmto = 6 AND /*ALTERADO P/ 6(CARTAO ASSINATURA NA CRAPDOC) E NAO 11 (CARTAO ASSINATURA NA CRAPTAB) */
                            crapdoc.idseqttl = 1 NO-LOCK NO-ERROR NO-WAIT.

    IF AVAIL crapdoc THEN
        DO:
            IF crapdoc.flgdigit = YES THEN
                ASSIGN aux_flgdigit = "S".
            ELSE
                ASSIGN aux_flgdigit = "N".
        END.
    ELSE
        ASSIGN aux_flgdigit = "N".
    */
    
    ASSIGN aux_flgdigit = "S"
           p-nro-conta     = crapass.nrdconta
           p-nro-conta-itg = crapass.nrdctitg.

    CREATE tt-comp_cabec.
    ASSIGN tt-comp_cabec.qtdevolu = aux_qtdevolu
           tt-comp_cabec.qtddsdev = aux_qtddsdev
           tt-comp_cabec.qtddtdev = aux_qtddtdev
           tt-comp_cabec.dtsisfin = DATE(aux_dtabtcct)
           tt-comp_cabec.ftsalari = aux_ftsalari
           tt-comp_cabec.vlprepla = aux_vlprepla
           tt-comp_cabec.qttalret = aux_qtfolret
           tt-comp_cabec.flgdigit = aux_flgdigit.
           
END PROCEDURE.


PROCEDURE carrega_dados_atenda:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.  
    DEF INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrctaitg AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOG                            NO-UNDO.

    DEF OUTPUT PARAM par_flconven AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cabec.
    DEF OUTPUT PARAM TABLE FOR tt-comp_cabec.
    DEF OUTPUT PARAM TABLE FOR tt-valores_conta.
    DEF OUTPUT PARAM TABLE FOR tt-crapobs.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens-atenda.
    DEF OUTPUT PARAM TABLE FOR tt-arquivos.

    DEF VAR aux_vlsldant AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldcap AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldepr AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldapl AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldinv AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldppr AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_vllimite AS DECI                                    NO-UNDO.
    DEF VAR aux_vllautom AS DECI                                    NO-UNDO.
    DEF VAR aux_vlstotal AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                                    NO-UNDO.
    DEF VAR aux_qtfolhas AS INTE                                    NO-UNDO.
    DEF VAR aux_qtconven AS INTE                                    NO-UNDO.
    DEF VAR aux_qtprecal AS INTE                                    NO-UNDO.
    DEF VAR aux_flgocorr AS LOGI                                    NO-UNDO.
    DEF VAR aux_dssitura AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssitnet AS CHAR                                    NO-UNDO.
    DEF VAR aux_vltotccr AS DECI                                    NO-UNDO.
    DEF VAR aux_qtcarmag AS INTE                                    NO-UNDO.
    DEF VAR aux_vltotseg AS DECI                                    NO-UNDO.
    DEF VAR aux_qtsegass AS INTE                                    NO-UNDO.
    DEF VAR aux_vltotdsc AS DECI                                    NO-UNDO.
    DEF VAR aux_flgativo AS LOG                                     NO-UNDO.
    DEF VAR aux_nrctrhcj AS INT                                     NO-UNDO.
    DEF VAR aux_flgliber AS LOG                                     NO-UNDO.
    DEF VAR aux_flgbloqt AS LOG                                     NO-UNDO.
    DEF VAR aux_opmigrad AS LOG                                     NO-UNDO.
    DEF VAR aux_vlsldtot AS DEC                                     NO-UNDO.
    DEF VAR aux_vlsldrgt AS DEC                                     NO-UNDO.
    DEF VAR aux_vllimite_saque AS DECIMAL                           NO-UNDO.
        
    DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0003 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0004 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0015 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0019 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0020 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0026 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0027 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0030 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0031 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0032 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0033 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0082 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0085 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9998 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_dtassele AS DATE                                    NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                                    NO-UNDO. /* Data de corte */
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabec.
    EMPTY TEMP-TABLE tt-comp_cabec.
    EMPTY TEMP-TABLE tt-valores_conta.
    EMPTY TEMP-TABLE tt-crapobs.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados para tela ATENDA.".
                   
        RUN sistema/generico/procedures/b1wgen9998.p
        PERSISTENT SET h-b1wgen9998.

    /* Validacao de operado e conta migrada */
    RUN valida_operador_migrado IN h-b1wgen9998 (INPUT par_cdoperad,
                                                 INPUT par_nrdconta,
                                                 INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 OUTPUT aux_opmigrad,
                                                 OUTPUT TABLE tt-erro).
                
    DELETE PROCEDURE h-b1wgen9998.
           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
        
            IF par_flgerlog THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RETURN "NOK".

        END.           

    IF NOT VALID-HANDLE(h-b1wgen9998) THEN
       RUN sistema/generico/procedures/b1wgen9998.p
           PERSISTENT SET h-b1wgen9998.
    
    RUN valida_restricao_operador IN h-b1wgen9998
                                 (INPUT par_cdoperad,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctaitg,
                                  INPUT par_cdcooper,
                                 OUTPUT aux_dscritic).

    IF  VALID-HANDLE(h-b1wgen9998) THEN
        DELETE OBJECT h-b1wgen9998.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".  
        END.
    
    /** Dados da conta para compor cabecalho da tela **/
    RUN obtem-cabecalho (INPUT  par_cdcooper,                   
                         INPUT  par_cdagenci,
                         INPUT  par_nrdcaixa,                     
                         INPUT  par_cdoperad,                
                         INPUT  par_nrdconta,
                         INPUT  par_nrctaitg,
                         INPUT  par_dtiniper,
                         INPUT  par_dtfimper,
                         INPUT  par_idorigem, 
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-cabec).
                              
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                
            IF par_flgerlog THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RETURN "NOK".
        END.
      
    IF  par_nrdconta = 0  THEN
        DO:
            FIND FIRST tt-cabec NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-cabec  THEN
                ASSIGN par_nrdconta = tt-cabec.nrdconta.
        END.
    
    RUN completa-cabecalho (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nrdconta,
                            INPUT par_nrctaitg,
                            INPUT par_dtiniper,
                            INPUT par_idorigem,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-comp_cabec).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:

            FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                
            IF par_flgerlog THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RETURN "NOK".
        END.
    
    RUN carrega_dep_vista (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nrdconta,
                           INPUT par_dtmvtolt,
                           INPUT par_idorigem,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT FALSE,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-saldos,
                          OUTPUT TABLE tt-libera-epr).
                                 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                
            IF par_flgerlog THEN
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RETURN "NOK".
        END.
    
    FIND FIRST tt-saldos NO-LOCK NO-ERROR.
    IF  AVAIL tt-saldos  THEN
        ASSIGN aux_vlstotal = tt-saldos.vlstotal.

    /** Lancamentos Futuros **/
    RUN sistema/generico/procedures/b1wgen0003.p
        PERSISTENT SET h-b1wgen0003.
         
    IF  VALID-HANDLE(h-b1wgen0003)  THEN
        DO:
            RUN consulta-lancamento IN h-b1wgen0003 
                                   (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_nrdconta,
                                    INPUT par_idorigem,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT FALSE, /* Nao Logar */
                                   OUTPUT TABLE tt-totais-futuros,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-lancamento_futuro).

            DELETE PROCEDURE h-b1wgen0003.
            
            IF   RETURN-VALUE = "NOK" THEN
                 DO:
                    
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
                     IF  AVAILABLE tt-erro  THEN
                         ASSIGN aux_cdcritic = tt-erro.cdcritic
                                aux_dscritic = tt-erro.dscritic.
                
                     IF par_flgerlog THEN
                     RUN proc_gerar_log (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT aux_dscritic,
                                         INPUT aux_dsorigem,
                                         INPUT aux_dstransa,
                                         INPUT FALSE,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdatela,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
                 
                     RETURN "NOK".
                 END.
            
            FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.

            IF  AVAIL tt-totais-futuros  THEN
                ASSIGN aux_vllautom = tt-totais-futuros.vllautom.
               
        END.
    
    /** Saldo de Cotas/Capital **/
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.

    IF  VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            RUN obtem-saldo-cotas IN h-b1wgen0021 
                                              (INPUT  par_cdcooper,
                                               INPUT  par_cdagenci,
                                               INPUT  par_nrdcaixa,
                                               INPUT  par_cdoperad,
                                               INPUT  par_nmdatela,
                                               INPUT  par_idorigem,
                                               INPUT  par_nrdconta,
                                               INPUT  par_idseqttl,
                                               OUTPUT TABLE tt-saldo-cotas,
                                               OUTPUT TABLE tt-erro). 
        
            DELETE PROCEDURE h-b1wgen0021.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
            
            FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-saldo-cotas THEN
                ASSIGN aux_vlsldcap = tt-saldo-cotas.vlsldcap.
            ELSE
                ASSIGN aux_vlsldcap = 0.
        END.
    
    RUN sistema/generico/procedures/b1wgen0026.p PERSISTENT 
        SET h-b1wgen0026.
     
    IF  VALID-HANDLE(h-b1wgen0026)  THEN
        DO:
            RUN lista_conven IN h-b1wgen0026 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nrdconta,
                                              INPUT par_idorigem,
                                              INPUT par_idseqttl,
                                              INPUT par_nmdatela,
                                              INPUT FALSE, /* nao logar */
                                             OUTPUT TABLE tt-conven,
                                             OUTPUT TABLE tt-totconven).

            DELETE PROCEDURE h-b1wgen0026.
            
            FIND FIRST tt-totconven NO-LOCK NO-ERROR.

            IF   AVAIL tt-totconven   THEN
                 ASSIGN aux_qtconven = tt-totconven.qtconven.
                
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT 
        SET h-b1wgen0028.
    
    IF  VALID-HANDLE(h-b1wgen0028)  THEN
        DO:
            RUN lista_cartoes IN h-b1wgen0028 (INPUT par_cdcooper, 
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_idorigem,
                                               INPUT par_idseqttl,
                                               INPUT par_nmdatela,
                                               INPUT FALSE,
                                               OUTPUT aux_flgativo,
                                               OUTPUT aux_nrctrhcj,
                                               OUTPUT aux_flgliber,
                                               OUTPUT aux_dtassele,
                                               OUTPUT aux_dsvlrprm,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-cartoes,
                                              OUTPUT TABLE tt-lim_total).

            DELETE PROCEDURE h-b1wgen0028.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
            IF  AVAIL tt-lim_total  THEN
                aux_vltotccr = tt-lim_total.vltotccr.
        END.    

    RUN sistema/generico/procedures/b1wgen0027.p PERSISTENT 
        SET h-b1wgen0027.
    
    IF  VALID-HANDLE(h-b1wgen0027)  THEN
        DO:
            RUN lista_ocorren IN h-b1wgen0027 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT par_inproces,
                                               INPUT par_idorigem,
                                               INPUT par_idseqttl,
                                               INPUT par_nmdatela,
                                               INPUT FALSE, /* Nao Logar */
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-ocorren).

            DELETE PROCEDURE h-b1wgen0027.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-ocorren NO-LOCK NO-ERROR.
            IF  AVAIL tt-ocorren  THEN
                aux_flgocorr = tt-ocorren.flgocorr.
        END.

    /** Saldo devedor de emprestimos **/
    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT 
        SET h-b1wgen0002.
    
    IF  VALID-HANDLE(h-b1wgen0002)  THEN
        DO:
            RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT 0,
                                                   INPUT "B1WGEN0001",
                                                   INPUT par_inproces,
                                                   INPUT FALSE,
                                                  OUTPUT aux_vlsldepr,
                                                  OUTPUT aux_vltotpre,
                                                  OUTPUT aux_qtprecal,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0002.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.

        END.

    /** Saldo das aplicacoes **/
    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
        SET h-b1wgen0081.        
    
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DO:
            RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT 0,
                                       INPUT par_nmdatela,
                                       INPUT FALSE,
                                       INPUT ?,
                                       INPUT ?,
                                       OUTPUT aux_vlsldtot,
                                       OUTPUT TABLE tt-saldo-rdca,
                                       OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0081.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic =tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.

            FOR EACH tt-saldo-rdca NO-LOCK:
            
                ASSIGN aux_vlsldapl = aux_vlsldapl + tt-saldo-rdca.sldresga.

            END.
           
            DELETE PROCEDURE h-b1wgen0081.
        END.
    
     /*Busca Saldo Novas Aplicacoes*/
     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
      
      RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* Código da Cooperativa */
                                 INPUT par_cdoperad, /* Código do Operador */
                                 INPUT par_nmdatela, /* Nome da Tela */
                                 INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                 INPUT par_nrdconta, /* Número da Conta */
                                 INPUT par_idseqttl, /* Titular da Conta */
                                 INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                 INPUT par_dtmvtolt, /* Data de Movimento */
                                 INPUT 0,            /* Código do Produto */
                                 INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                 INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                OUTPUT 0,            /* Saldo Total da Aplicação */
                                OUTPUT 0,            /* Saldo Total para Resgate */
                                OUTPUT 0,            /* Código da crítica */
                                OUTPUT "").          /* Descrição da crítica */
      
      CLOSE STORED-PROC pc_busca_saldo_aplicacoes
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                             WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
             aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                             WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
             aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                             WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
             aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                             WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

      IF aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             IF aux_dscritic = "" THEN
                DO:
                   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                      NO-LOCK NO-ERROR.
    
                   IF AVAIL crapcri THEN
                      ASSIGN aux_dscritic = crapcri.dscritic.
    
                END.
    
             CREATE tt-erro.
    
             ASSIGN tt-erro.cdcritic = aux_cdcritic
                    tt-erro.dscritic = aux_dscritic.
      
             RETURN "NOK".
                            
         END.
     
     ASSIGN aux_vlsldapl = aux_vlsldapl + aux_vlsldrgt.
     /*Fim Busca Saldo Novas Aplicacoes*/
    
    /** Saldo Conta Investimento **/
    RUN sistema/generico/procedures/b1wgen0020.p PERSISTENT
        SET h-b1wgen0020.
    
    IF  VALID-HANDLE(h-b1wgen0020)  THEN
        DO:
            RUN obtem-saldo-investimento IN h-b1wgen0020 
                                          (INPUT  par_cdcooper,
                                           INPUT  par_cdagenci,
                                           INPUT  par_nrdcaixa,
                                           INPUT  par_cdoperad,
                                           INPUT  par_nmdatela,
                                           INPUT  par_idorigem,
                                           INPUT  par_nrdconta,
                                           INPUT  par_idseqttl,
                                           INPUT  par_dtmvtolt,
                                           OUTPUT TABLE tt-saldo-investimento).
    
            DELETE PROCEDURE h-b1wgen0020.
            
            FIND tt-saldo-investimento NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-saldo-investimento  THEN
                ASSIGN aux_vlsldinv = tt-saldo-investimento.vlsldinv.
        END.    
        
    /** Saldo de poupanca programada **/
    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
        SET h-b1wgen0006.
    
    IF  VALID-HANDLE(h-b1wgen0006)  THEN
        DO:                      
            RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT 0,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT par_inproces,
                                                   INPUT par_nmdatela,
                                                   INPUT FALSE,
                                                  OUTPUT aux_vlsldppr,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-dados-rpp). 
                                   
            DELETE PROCEDURE h-b1wgen0006.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
        END.
    
    /** Valor do Limite de Credito **/
    RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT 
        SET h-b1wgen0019.
    
    IF  VALID-HANDLE(h-b1wgen0019)  THEN
        DO:
            
            RUN obtem-valor-limite IN h-b1wgen0019
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci, 
                                                 INPUT par_nrdcaixa, 
                                                 INPUT par_cdoperad, 
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta, 
                                                 INPUT par_idseqttl, 
                                                 INPUT FALSE, /** LOG **/
                                                OUTPUT TABLE tt-limite-credito,
                                                OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h-b1wgen0019.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.

            FIND FIRST tt-limite-credito NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-limite-credito  THEN
                ASSIGN aux_vllimite = tt-limite-credito.vllimcre.
        END.
 
    /** Quantidade de folhas de cheque disponiveis para o associado **/
    FOR EACH crapfdc WHERE crapfdc.cdcooper =  par_cdcooper AND
                           crapfdc.nrdconta =  par_nrdconta AND
                           crapfdc.dtemschq <> ?            AND
                           crapfdc.dtretchq <> ?            AND
                           crapfdc.tpcheque =  1            NO-LOCK:

        IF  CAN-DO("0,1,2",STRING(crapfdc.incheque))  THEN
            aux_qtfolhas = aux_qtfolhas + 1.
         
    END. /** Fim do FOR EACH crapfdc **/

    /** Situacao da senha do Tele-Atendimento e InterneBank **/
    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT 
        SET h-b1wgen0015.
    
    IF  VALID-HANDLE(h-b1wgen0015)  THEN
        DO:
            RUN obtem_situacao_ura IN h-b1wgen0015
                                                (INPUT  par_cdcooper,
                                                 INPUT  par_cdagenci, 
                                                 INPUT  par_nrdcaixa, 
                                                 INPUT  par_cdoperad, 
                                                 INPUT  par_nmdatela,
                                                 INPUT  par_idorigem,
                                                 INPUT  par_nrdconta,
                                                 INPUT  par_idseqttl,
                                                 OUTPUT TABLE tt-situacao-ura,
                                                 OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0015.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
            
            RUN obtem_situacao_internet IN h-b1wgen0015
                                           (INPUT  par_cdcooper,
                                            INPUT  par_cdagenci, 
                                            INPUT  par_nrdcaixa, 
                                            INPUT  par_cdoperad, 
                                            INPUT  par_nmdatela,
                                            INPUT  par_idorigem,
                                            INPUT  par_nrdconta,
                                            INPUT  par_idseqttl,
                                            OUTPUT TABLE tt-situacao-internet).
  
            DELETE PROCEDURE h-b1wgen0015.
            
            FIND FIRST tt-situacao-ura NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-situacao-ura  THEN
                ASSIGN aux_dssitura = tt-situacao-ura.dssitura.

            FIND FIRST tt-situacao-internet NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-situacao-internet  THEN
                ASSIGN aux_dssitnet = tt-situacao-internet.dssitnet.
        END.
 
    /* Saldo Lancamentos futuros */
    ASSIGN aux_vllautom = aux_vllautom + aux_vlstotal.
    
    RUN sistema/generico/procedures/b1wgen0031.p PERSISTENT SET h-b1wgen0031.
    
    IF  VALID-HANDLE(h-b1wgen0031)  THEN
        DO:
            RUN obtem-mensagens-alerta IN h-b1wgen0031 
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_dtmvtoan,
                                             INPUT par_inproces,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-mensagens-atenda).

            DELETE PROCEDURE h-b1wgen0031.
                   
            IF  RETURN-VALUE = "NOK"  THEN
                DO: 
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.                                  
        END.

    RUN sistema/generico/procedures/b1wgen0085.p PERSISTENT SET h-b1wgen0085.
    
    IF  VALID-HANDLE(h-b1wgen0085)  THEN
        DO:
            RUN Busca_Dados IN h-b1wgen0085 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT 0,
                                             INPUT "C",
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-infoass,
                                            OUTPUT TABLE tt-crapobs,
                                            OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0085.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    IF par_flgerlog THEN
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
        END.
    
    /** Qtdade de Cartoes Magneticos **/
    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.
    
    IF  VALID-HANDLE(h-b1wgen0032)  THEN
        DO:
            RUN obtem-cartoes-magneticos IN h-b1wgen0032
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci, 
                                            INPUT par_nrdcaixa, 
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtmvtolt,
                                            INPUT FALSE, /** LOG **/
                                           OUTPUT aux_qtcarmag,
                                           OUTPUT TABLE tt-cartoes-magneticos).
            
            DELETE PROCEDURE h-b1wgen0032.
        END.    
    
    /** Valor total de seguros **/
    RUN sistema/generico/procedures/b1wgen0033.p PERSISTENT 
        SET h-b1wgen0033.
    
    IF  VALID-HANDLE(h-b1wgen0033)  THEN
        DO:
            RUN busca_seguros IN h-b1wgen0033 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_idorigem,
                                               INPUT par_nmdatela,
                                               INPUT FALSE, /* LOG */
                                               OUTPUT TABLE tt-seguros,
                                               OUTPUT aux_qtsegass,
                                               OUTPUT aux_vltotseg,
                                               OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.
            
        END.    
        
    /* Valor total de Descontos */
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT 
        SET h-b1wgen0030.
    
    IF  VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            RUN busca_total_descontos IN h-b1wgen0030 
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT par_idorigem,
                                     INPUT par_nmdatela,
                                     INPUT FALSE, /* LOG */
                                    OUTPUT TABLE tt-tot_descontos).

            FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

            IF  AVAIL tt-tot_descontos  THEN
                aux_vltotdsc = tt-tot_descontos.vltotdsc.
                
            DELETE PROCEDURE h-b1wgen0030.    

        END.    

    /* Retorna se o Cooperado possui cadastro de emissao bloqueto ativo*/
    RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.

    aux_flgbloqt = DYNAMIC-FUNCTION ("verifica-cadastro-ativo" IN h-b1wgen0082,
                       
                        INPUT par_cdcooper,
                        INPUT par_nrdconta).

    DELETE PROCEDURE h-b1wgen0082.
    
    ASSIGN aux_vllimite_saque = 0.    
    /* Busca o valor de limite de saque */
    FOR tbtaa_limite_saque FIELDS(vllimite_saque)
                           WHERE tbtaa_limite_saque.cdcooper = par_cdcooper AND
                                 tbtaa_limite_saque.nrdconta = par_nrdconta
                                 NO-LOCK: END.
                                 
    IF AVAILABLE tbtaa_limite_saque THEN
       ASSIGN aux_vllimite_saque = tbtaa_limite_saque.vllimite_saque.                                 
    
    /** Cria TEMP-TABLE com valores referente a conta **/
    CREATE tt-valores_conta.
    ASSIGN tt-valores_conta.vlsldcap = aux_vlsldcap
           tt-valores_conta.vlsldepr = aux_vlsldepr
           tt-valores_conta.vlsldapl = aux_vlsldapl
           tt-valores_conta.vlsldinv = aux_vlsldinv
           tt-valores_conta.vlsldppr = aux_vlsldppr
           tt-valores_conta.vllimite = aux_vllimite
           tt-valores_conta.qtfolhas = aux_qtfolhas
           tt-valores_conta.qtconven = aux_qtconven
           tt-valores_conta.flgocorr = aux_flgocorr
           tt-valores_conta.dssitura = aux_dssitura
           tt-valores_conta.vllautom = aux_vllautom
           tt-valores_conta.dssitnet = aux_dssitnet
           tt-valores_conta.vlstotal = aux_vlstotal
           tt-valores_conta.vltotpre = aux_vltotpre
           tt-valores_conta.vltotccr = aux_vltotccr
           tt-valores_conta.qtcarmag = aux_qtcarmag
           tt-valores_conta.vltotseg = aux_vltotseg
           tt-valores_conta.vltotdsc = aux_vltotdsc
           tt-valores_conta.flgbloqt = aux_flgbloqt
           tt-valores_conta.vllimite_saque = aux_vllimite_saque.

    IF par_flgerlog THEN
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    /** Verifica se existe Pagto de Titulos  **/
    IF  NOT VALID-HANDLE(h-b1wgen0192)  THEN
        RUN sistema/generico/procedures/b1wgen0192.p 
        PERSISTENT SET h-b1wgen0192.
    
    RUN verif-aceite-conven IN h-b1wgen0192
                           (INPUT par_cdcooper,
                            INPUT par_nrdconta,
                            INPUT 1, /* par_nrconven - FIXO */
                            OUTPUT par_flconven,
                            OUTPUT par_cdcritic,
                            OUTPUT par_dscritic,
                            OUTPUT TABLE tt-arquivos).

    IF  VALID-HANDLE(h-b1wgen0192)  THEN
        DELETE PROCEDURE h-b1wgen0192.
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
PROCEDURE ver_capital.

/*****************************************************************************
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Setembro/2007.                        Ultima atualizacao: 

   Objetivo  : Verificar se o associado possui capital 
              (conversao em BO do fontes/ver_capital.p)

               p-nro-conta    = Conta do associado em questao
               p-valor-lancto = Se maior que 0, verifica de pode sacar o valor
                              se for 0, apenas testa se o associado possui
                              capital suficiente para efetuar a operacao.
                              
*****************************************************************************/ 

DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-conta    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-valor-lancto AS DECIMAL                         NO-UNDO.
DEF INPUT  PARAMETER p-dtmvtolt     AS DATE                            NO-UNDO.
DEF INPUT  PARAMETER p-cdprogra     AS CHAR                            NO-UNDO.
DEF INPUT  PARAMETER p-origem       AS INTE NO-UNDO. 

DEF OUTPUT PARAM TABLE FOR tt-erro.


DEF VAR d-vlcapmin                  AS DECIMAL                         NO-UNDO.
DEF VAR aux_data                    AS DATE                            NO-UNDO.

EMPTY TEMP-TABLE tt-erro.
ASSIGN aux_sequen = 0.

FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

/*  Le registro de matricula  */

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
FIND FIRST crapmat WHERE crapmat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

/*  Le tabela de valor minimo do capital  */

FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "USUARI"          AND
                   craptab.cdempres = 11                AND
                   craptab.cdacesso = "VLRUNIDCAP"      AND
                   craptab.tpregist = 1                 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN d-vlcapmin = crapmat.vlcapini.
ELSE
     ASSIGN d-vlcapmin = DECIMAL(craptab.dstextab).
     
/*
IF   d-vlcapmin < crapmat.vlcapini   THEN
     IF  crapcop.cdcooper <> 6   THEN
         ASSIGN d-vlcapmin = crapmat.vlcapini.
*/
FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                   crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass   THEN 
     DO:
       
         ASSIGN i-cod-erro = 9
                c-dsc-erro = " ".           
                
         {sistema/generico/includes/b1wgen0001.i}
                                                                       
         RETURN "NOK".
     END.

IF   crapass.inpessoa <> 3   THEN 
     DO:
        
         /*  Le registro de capital  */
    
         FIND crapcot WHERE crapcot.cdcooper = crapcop.cdcooper AND
                            crapcot.nrdconta = p-nro-conta  
                            NO-LOCK NO-ERROR. 
            
         IF   NOT AVAILABLE crapcot   THEN 
              DO:
                  ASSIGN i-cod-erro = 169
                         c-dsc-erro = " ".           

                  {sistema/generico/includes/b1wgen0001.i}
                   
                  RETURN "NOK".
              END.
         
         IF   p-valor-lancto = 0   THEN   
              DO:
              /*  Verifica se ha capital suficiente  */
                    
                  IF   crapcot.vldcotas < d-vlcapmin   THEN 
                       DO:
                           
                        /*FIND crapadm OF crapcot NO-LOCK NO-ERROR.*/
                          FIND crapadm WHERE 
                               crapadm.cdcooper = crapcop.cdcooper  AND
                               crapadm.nrdconta = crapcot.nrdconta
                               NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crapadm   THEN 
                                DO:
                                
                                    IF   crapass.dtdemiss = ?   THEN 
                                         DO:
                                              
                                             ASSIGN aux_data = crapdat.dtmvtolt
                                                        - DAY(crapdat.dtmvtolt)
                                                    aux_data = aux_data - 
                                                               DAY(aux_data).
                        
                                             IF   crapass.dtadmiss <= aux_data 
                                                  THEN DO:  
                                                      ASSIGN i-cod-erro = 735
                                                             c-dsc-erro = " ".
                                                             
                            {sistema/generico/includes/b1wgen0001.i}                                                       RETURN "NOK".
                                                  END.
                                         END.
                                END.
                       END.
              END.
         ELSE  
              DO: 
                
                  IF   crapcot.vldcotas <> p-valor-lancto   OR
                       crapass.dtdemiss = ?               THEN 
                       DO:
                        
                           IF  (crapcot.vldcotas - p-valor-lancto) < d-vlcapmin
                               THEN DO:
                                    ASSIGN i-cod-erro = 630
                                           c-dsc-erro = " ".           
                                           
                            {sistema/generico/includes/b1wgen0001.i}                                     RETURN "NOK".
                               END.
                       
                          RETURN "OK".
                       END.

                  /*Nao permite sacar capital se houver saldos*/
                  RUN ver_saldos(INPUT  p-cdcooper,
                                 INPUT  p-cod-agencia,
                                 INPUT  p-nro-caixa,  
                                 INPUT  p-nro-conta,  
                                 INPUT  p-dtmvtolt,   
                                 INPUT  p-cdprogra,   
                                 OUTPUT TABLE tt-erro).
                  
                  IF   RETURN-VALUE = "NOK"   THEN
                       RETURN "NOK".
              END.
              
     END.
RETURN "OK".

END PROCEDURE.

/* ......................................................................... */

PROCEDURE ver_saldos:

    DEF INPUT  PARAMETER p-cdcooper     AS INTEGER NO-UNDO.
    DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER NO-UNDO.
    DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER NO-UNDO.
    DEF INPUT  PARAMETER p-nro-conta    AS INTEGER NO-UNDO.
    DEF INPUT  PARAMETER p-dtmvtolt     AS DATE    NO-UNDO.
    DEF INPUT  PARAMETER p-cdprogra     AS CHAR    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0081 AS HANDLE NO-UNDO.
        
    DEF VAR d-vldsaldo   AS DECI               NO-UNDO.
    DEF VAR aux_vldsaldo AS DECI               NO-UNDO.
    DEF VAR aux_vlsldapl AS DECIMAL DECIMALS 8 NO-UNDO.
    DEF VAR aux_vlsldtot AS DECI               NO-UNDO.
    DEF VAR aux_vlsldrgt AS DECI               NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID              NO-UNDO.
    
    FIND FIRST crapepr WHERE crapepr.cdcooper = p-cdcooper        AND
                             crapepr.nrdconta = p-nro-conta       AND
                             crapepr.inliquid = 0 
                             NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crapepr   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "EMPRESTIMO COM SALDO DEVEDOR.".           

             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END.
         
    FIND FIRST crappla WHERE crappla.cdcooper = p-cdcooper  AND
                             crappla.nrdconta = p-nro-conta AND
                             crappla.cdsitpla = 1 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crappla   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "PLANO DE CAPITAL ATIVO.".

             { sistema/generico/includes/b1wgen0001.i }             

             RETURN "NOK".
         END.

    IF   crapass.vllimcre > 0   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "LIMITE DE CREDITO EM CONTA-CORRENTE.".

             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.

    FIND FIRST crapcrd WHERE crapcrd.cdcooper = p-cdcooper  AND
                             crapcrd.nrdconta = p-nro-conta AND
                             crapcrd.dtcancel = ?             
                             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcrd   THEN  
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "CARTAO DE CREDITO ATIVO.".
                    
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.

    /* NOVA VERIFICACAO DE APLICACAO - JEAN MICHEL */
    
    /** Saldo das aplicacoes **/
    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
        SET h-b1wgen0081.        
   
    IF VALID-HANDLE(h-b1wgen0081)  THEN
        DO:
            RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                      (INPUT p-cdcooper,    /*Cooperativa*/
                                       INPUT p-cod-agencia, /*Agencia*/
                                       INPUT p-nro-caixa,   /*Caixa*/
                                       INPUT 1,             /*Operador*/
                                       INPUT p-cdprogra,    /*Nome da Tela*/
                                       INPUT 1,             /*Idorigem*/
                                       INPUT p-nro-conta,   /*Conta*/
                                       INPUT 1,             /*Idseqttl*/
                                       INPUT 0,             /*Nraplica*/
                                       INPUT p-cdprogra,    /*Cdprogra*/
                                       INPUT FALSE,
                                       INPUT ?,
                                       INPUT ?,
                                       OUTPUT aux_vlsldtot,
                                       OUTPUT TABLE tt-saldo-rdca,
                                       OUTPUT TABLE tt-erro).
        
            IF RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0081.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                
                    RUN proc_gerar_log (INPUT p-cdcooper,
                                        INPUT 1,
                                        INPUT aux_dscritic,
                                        INPUT "Caracter",
                                        INPUT "Consulta de Saldo de Aplicacao",
                                        INPUT FALSE,
                                        INPUT 1,
                                        INPUT p-cdprogra,
                                        INPUT p-nro-conta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.

            ASSIGN aux_vlsldapl = aux_vlsldtot.

            DELETE PROCEDURE h-b1wgen0081.
        END.
    
    /*Busca Saldo Novas Aplicacoes*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT p-cdcooper,   /* Código da Cooperativa */
                                 INPUT '1',          /* Código do Operador */
                                 INPUT p-cdprogra,   /* Nome da Tela */
                                 INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                 INPUT p-nro-conta,  /* Número da Conta */
                                 INPUT 1,            /* Titular da Conta */
                                 INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                 INPUT p-dtmvtolt,   /* Data de Movimento */
                                 INPUT 0,            /* Código do Produto */
                                 INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                 INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                OUTPUT 0,            /* Saldo Total da Aplicação */
                                OUTPUT 0,            /* Saldo Total para Resgate */
                                OUTPUT 0,            /* Código da crítica */
                                OUTPUT "").          /* Descrição da crítica */
      
    CLOSE STORED-PROC pc_busca_saldo_aplicacoes
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vlsldtot = 0
           aux_vlsldrgt = 0
           aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                          WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
           aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                          WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
           aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                          WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
           aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                          WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.
      
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
        DO:
            IF aux_dscritic = "" THEN
                DO:
                    FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
    
                    IF AVAIL crapcri THEN
                        ASSIGN aux_dscritic = crapcri.dscritic.
    
                END.
    
            CREATE tt-erro.
    
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
      
            RETURN "NOK".
                            
        END.

    /* Saldo acumulado */
    ASSIGN aux_vldsaldo = aux_vlsldapl + aux_vlsldrgt.

    /* NOVA VERIFICACAO DE APLICACAO - JEAN MICHEL  */

    IF  aux_vldsaldo > 0  THEN
        DO:
            ASSIGN i-cod-erro = 0
                   c-dsc-erro = "SALDO EM APLICACAO RDC.".

            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.     

    FIND FIRST crapseg WHERE crapseg.cdcooper = p-cdcooper   AND
                             crapseg.nrdconta = p-nro-conta  AND
                             crapseg.dtfimvig > aux_datdodia AND
                             crapseg.dtcancel = ?           
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapseg   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "SEGURO ATIVO.".

             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.

    FIND FIRST crapatr WHERE crapatr.cdcooper = p-cdcooper    AND
                             crapatr.nrdconta = p-nro-conta   AND
                             crapatr.dtfimatr = ? 
                             NO-LOCK NO-ERROR.
 
    IF   AVAILABLE crapatr   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "AUTORIZACAO DE DEBITO EM CONTA-CORRENTE.".

             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
    
    FOR EACH craprpp WHERE craprpp.cdcooper = p-cdcooper        AND
                           craprpp.nrdconta = p-nro-conta       AND
                          (craprpp.vlsdrdpp > 0                 OR
                           craprpp.dtcancel = ?)                NO-LOCK:
        
        ASSIGN d-vldsaldo = craprpp.vlsdrdpp.
        
        FOR EACH craplpp WHERE craplpp.cdcooper = p-cdcooper         AND
                               craplpp.nrdconta = craprpp.nrdconta   AND
                               craplpp.nrctrrpp = craprpp.nrctrrpp   AND
                              (craplpp.cdhistor = 496                OR
                               craplpp.cdhistor = 158)               NO-LOCK:
                               
            ASSIGN d-vldsaldo = d-vldsaldo - craplpp.vllanmto.                 
                    
        END.  /*  Fim do FOR EACH -- Leitura do craplpp  */
         
        IF   d-vldsaldo > 0   THEN 
             DO:
                 ASSIGN i-cod-erro = 0
                        c-dsc-erro = "POUPANCA PROGRAMADA COM SALDO.".

                 { sistema/generico/includes/b1wgen0001.i }
                 
                 RETURN "NOK".
             END.

    END.  /*  Fim do FOR EACH -- Leitura do craprpp  */
         
    FOR EACH crapfdc WHERE crapfdc.cdcooper = p-cdcooper        AND
                           crapfdc.nrdconta = p-nro-conta       AND
                           crapfdc.dtretchq <> ?                NO-LOCK:
                           
        IF   crapfdc.incheque = 0   THEN  
             DO:
                 IF   crapfdc.tpcheque = 1   THEN   
                      DO:
                          ASSIGN i-cod-erro = 0
                                 c-dsc-erro = "TALAO DE CHEQUES EM USO.".

                          { sistema/generico/includes/b1wgen0001.i }
                          
                          RETURN "NOK".
                      END.
                 ELSE 
                      DO:
                          ASSIGN i-cod-erro = 0
                                 c-dsc-erro = "TALAO DE CHEQUES TB EM USO.".
                                 
                          { sistema/generico/includes/b1wgen0001.i }
                          
                          RETURN "NOK".
                      END.
             END.

    END.  /*  for each crapfdc */                       

    FIND FIRST crapcst WHERE crapcst.cdcooper = p-cdcooper        AND
                             crapcst.nrdconta = p-nro-conta       AND
                             crapcst.dtlibera > p-dtmvtolt        AND
                             crapcst.dtdevolu = ? 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapcst   THEN  
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "CHEQUES EM CUSTODIA NAO RESGATADOS.".
             
             { sistema/generico/includes/b1wgen0001.i }
             
             RETURN "NOK".
         END.

    FIND FIRST crapcdb WHERE crapcdb.cdcooper = p-cdcooper  AND
                             crapcdb.nrdconta = p-nro-conta AND
                             crapcdb.dtlibera > p-dtmvtolt  AND
                             crapcdb.dtdevolu = ?           NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcdb   THEN
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "CHEQUES DESCONTADOS NAO RESGATADOS.".
                    
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
         
    FIND FIRST craptdb WHERE craptdb.cdcooper = p-cdcooper  AND
                             craptdb.nrdconta = p-nro-conta AND
                             craptdb.insittit = 4 NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE craptdb   THEN
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "TITULOS DESCONTADOS NAO RESGATADOS.".
                    
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.     

    FIND FIRST craptit WHERE craptit.cdcooper = p-cdcooper        AND
                             craptit.nrdconta = p-nro-conta       AND
                             craptit.dtdpagto > p-dtmvtolt        AND
                             craptit.dtdevolu = ?             
                             NO-LOCK NO-ERROR.

    IF   AVAIL craptit   THEN 
         DO:
             ASSIGN i-cod-erro = 0
                    c-dsc-erro = "TITULOS PROGRAMADOS NAO RESGATADOS.".
                    
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
PROCEDURE ver_cadastro.
 
/* .............................................................................

   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Setembro/2007.                        Ultima atualizacao: 
 
   Objetivo  : Verificar se eh necessario fazer recadastramento do associado.
               (conversao do programa fontes/ver_cadastro.p)
..............................................................................*/

DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-conta    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER p-dtmvtolt     AS DATE                            NO-UNDO.
DEF INPUT  PARAMETER p-origem       AS INTE NO-UNDO. 

DEF OUTPUT PARAM TABLE FOR tt-erro.

DEF BUFFER  crabass FOR crapass.

EMPTY TEMP-TABLE tt-erro.
ASSIGN aux_sequen = 0.

FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = p-cdcooper   AND
                   craptab.cdacesso = "ATUALIZCAD"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     DO:
        FIND LAST crapalt WHERE crapalt.cdcooper = p-cdcooper  AND 
                                crapalt.nrdconta = p-nro-conta  AND
                                crapalt.tpaltera = 1           
                                NO-LOCK NO-ERROR.
                  
        IF  AVAILABLE crapalt   THEN
            IF   (p-dtmvtolt - crapalt.dtaltera) > INT(craptab.dstextab) THEN
            DO:
                  ASSIGN i-cod-erro = 763
                         c-dsc-erro = " ".           

                  {sistema/generico/includes/b1wgen0001.i}
                              
                  RETURN "NOK".
            END.
            ELSE
                  .
        ELSE 
            DO:  
			    FOR FIRST crabass FIELDS(dtadmiss)
	                  WHERE crabass.cdcooper = p-cdcooper  AND 
                            crabass.nrdconta = p-nro-conta NO-LOCK: END.
			/*
                FIND crabass WHERE crabass.cdcooper = p-cdcooper  AND 
                                   crabass.nrdconta = p-nro-conta 
                                   NO-LOCK NO-ERROR. */
                IF  AVAIL crabass AND
                    ((p-dtmvtolt - crabass.dtadmiss)
                                   > INT(craptab.dstextab))  THEN
                DO:
                     ASSIGN i-cod-erro = 763
                            c-dsc-erro = " ".           

                     {sistema/generico/includes/b1wgen0001.i}
                                
                     RETURN "NOK".
                END.
            END.
     END. 

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_extrato_tarifas:

    DEF INPUT        PARAM par_cdcooper    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_cdagenci    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_nrdcaixa    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_cdoperad    AS CHAR             NO-UNDO.
    DEF INPUT        PARAM par_nrdconta    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_anorefer    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_idorigem    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_idseqttl    AS INTE             NO-UNDO.
    DEF INPUT        PARAM par_nmdatela    AS CHAR             NO-UNDO.
    DEF INPUT        PARAM par_flgerlog    AS LOGI             NO-UNDO.
    
    DEF OUTPUT       PARAM TABLE FOR       tt-dados_cooperado.
    DEF OUTPUT       PARAM TABLE FOR       tt-tarifas.
    DEF OUTPUT       PARAM aux_totdomes    AS DEC EXTENT 13    NO-UNDO.
    DEF OUTPUT       PARAM TABLE FOR       tt-erro.


    DEF VAR                aux_contador    AS INT     NO-UNDO.
    DEF VAR                aux_listahis    AS CHAR    NO-UNDO.
    DEF VAR                aux_vllanmto    AS DECI    NO-UNDO.
    DEF VAR                mes             AS INT     NO-UNDO.


    EMPTY TEMP-TABLE tt-dados_cooperado.
    EMPTY TEMP-TABLE tt-tarifas.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar extrato de tarifas".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = "".
                                 
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
                                   
             RETURN "NOK".
         END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
                                     
             RETURN "NOK".
         END.
    
    CREATE tt-dados_cooperado.
    ASSIGN tt-dados_cooperado.nmextcop = crapcop.nmextcop
           tt-dados_cooperado.nrdconta = crapass.nrdconta
           tt-dados_cooperado.inpessoa = crapass.inpessoa 
           tt-dados_cooperado.nmprimtl = crapass.nmprimtl
           tt-dados_cooperado.nrcpfcgc = crapass.nrcpfcgc
           tt-dados_cooperado.cdagenci = crapass.cdagenci.
           
    FOR EACH crapfvl NO-LOCK:
                           
        IF aux_listahis = "" THEN
        DO:
           aux_listahis = STRING(crapfvl.cdhistor) + "," +
           STRING(crapfvl.cdhisest).
        END.
        ELSE
        DO:
           aux_listahis = aux_listahis + "," +
           STRING(crapfvl.cdhistor) + "," + 
           STRING(crapfvl.cdhisest).
        END.
            
    END.

    FOR EACH craplcm WHERE craplcm.cdcooper  = par_cdcooper             AND
                           craplcm.nrdconta  = par_nrdconta             AND
                           CAN-DO(aux_listahis,STRING(craplcm.cdhistor))AND
                           craplcm.dtmvtolt >= DATE(01,01,par_anorefer) AND
                           craplcm.dtmvtolt <= DATE(12,31,par_anorefer) NO-LOCK,
        
        FIRST craphis WHERE craphis.cdcooper  = par_cdcooper       AND
                            craphis.cdhistor  = craplcm.cdhistor   NO-LOCK
                            BREAK BY craphis.dsexthst: 
        
        FIND tt-tarifas WHERE tt-tarifas.dsexthst = craphis.dsexthst
                              NO-LOCK NO-ERROR.
      
        IF   NOT AVAILABLE tt-tarifas   THEN
             DO:
                 CREATE tt-tarifas.
                 ASSIGN tt-tarifas.dsexthst = craphis.dsexthst
                        tt-tarifas.indebcre = craphis.indebcre.
             END.

        mes = MONTH(craplcm.dtmvtolt).
               
        aux_vllanmto = IF  craphis.indebcre = 'C' THEN 
                         craplcm.vllanmto
                       ELSE 
                         -1 * craplcm.vllanmto.
        
        tt-tarifas.vlrdomes[mes] = tt-tarifas.vlrdomes[mes] + aux_vllanmto.

        aux_totdomes[mes] = aux_totdomes[mes] + aux_vllanmto.

        IF   LAST-OF(craphis.dsexthst)   THEN
             DO:
                 DO aux_contador = 1 TO 12: /* Total anual historico */
                 
                    tt-tarifas.vlrdomes[13] = tt-tarifas.vlrdomes[13] + 
                                              tt-tarifas.vlrdomes[aux_contador].
                 END.

             END.

    END. /* Fim do FOR EACH craplcm */

    DO aux_contador = 1 TO 12: /* Total anual de todos os historicos */
        
       aux_totdomes[13] = aux_totdomes[13] + aux_totdomes[aux_contador].

    END.

    IF   par_flgerlog   THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).

    RETURN "OK".
    
END PROCEDURE.

                                    
PROCEDURE verifica-tarifacao-extrato:

    DEF INPUT        PARAM par_cdcooper    AS INTE              NO-UNDO.
    DEF INPUT        PARAM par_nrdconta    AS INTE              NO-UNDO.
    DEF INPUT        PARAM par_dtmvtolt    AS DATE              NO-UNDO. 
    DEF INPUT        PARAM par_dtiniper    AS DATE              NO-UNDO.
    
    DEF OUTPUT       PARAM aux_inisenta    AS INTE              NO-UNDO.
    DEF OUTPUT       PARAM TABLE FOR       tt-erro.

    DEF VAR aux_dsconteu                   AS CHAR              NO-UNDO.
    DEF VAR aux_qtdisent                   AS INTE              NO-UNDO. 
    DEF VAR aux_dtemiext                   AS DATE              NO-UNDO. 
    DEF VAR h-b1wgen0153                   AS HANDLE            NO-UNDO.

    ASSIGN aux_inisenta = 0.


    /* Verifico se extrato periodo, o mesmo eh tarifado e nao tem isencao*/
    IF  par_dtiniper < ( par_dtmvtolt - 30 )  THEN /* Periodo */
        RETURN "OK".
            

    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
       RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.


    /*  Busca quantidade limite de extratos por mes livres de tarifacao*/
    RUN carrega_par_tarifa_vigente IN h-b1wgen0153
                                    (INPUT par_cdcooper,
                                    INPUT "EXTMESISEN",
                                    OUTPUT aux_dsconteu,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
       IF  VALID-HANDLE(h-b1wgen0153) THEN
           DELETE PROCEDURE h-b1wgen0153. 

       RETURN "NOK".
    END.

    ASSIGN  aux_qtdisent = INTE(aux_dsconteu).

    IF  VALID-HANDLE(h-b1wgen0153) THEN
           DELETE PROCEDURE h-b1wgen0153.
                                                                  
    /* Monta data inicial do mes e ano corrente */
    aux_dtemiext = DATE( '01/' + STRING(MONTH(par_dtmvtolt)) + '/' + STRING(YEAR(par_dtmvtolt)) ).

    /* Verifica quantidade de extratos emitidos sem tarifacao */
    FOR EACH craptex WHERE craptex.cdcooper = par_cdcooper  AND
                           craptex.nrdconta = par_nrdconta  AND
                           craptex.inisenta = 1             AND 
                           craptex.tpextrat = 51            AND 
                           craptex.dtemiext >= aux_dtemiext USE-INDEX craptex1:
                           
                           aux_qtdisent  =  aux_qtdisent - 1.
                           
    END.

    /* Enquanto a quantidade for positiva nao deve gerar tarifar. */
    IF aux_qtdisent > 0  THEN
        aux_inisenta = 1. /* Nao Tarifa */

    RETURN "OK".


END.


/****************************  FUNCOES ******************************/

FUNCTION fgetnrdctitg RETURNS CHARACTER:

    RETURN IF   crapass.nrdctitg = "" 
           THEN "00000000"
           ELSE crapass.nrdctitg.

END FUNCTION.

FUNCTION fgetdtaltera RETURNS DATE (INPUT p-cdcooper AS INTEGER):

    FIND LAST crapalt WHERE 
              crapalt.cdcooper = p-cdcooper     AND
              crapalt.nrdconta = crapass.nrdconta AND
              crapalt.tpaltera = 1 NO-LOCK NO-ERROR.
    
    RETURN IF   AVAILABLE crapalt THEN crapalt.dtaltera
           ELSE ?.

END FUNCTION.

FUNCTION fgetnatopc RETURNS CHARACTER (INPUT p-cdcooper AS INTEGER, 
                                       INPUT p-nro-conta AS INTEGER):
    
    DEFINE VARIABLE cDsNatOpc    AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE                          NO-UNDO.
    
    IF   crapass.inpessoa = 1 THEN
         DO:
             FIND crapttl WHERE crapttl.cdcooper = p-cdcooper  AND
                                crapttl.nrdconta = p-nro-conta AND
                                crapttl.idseqttl = 1
                                NO-LOCK NO-ERROR.
                                
             IF   AVAILABLE crapttl   THEN
                  DO:
                      RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                          SET h-b1wgen9999.
                          
                      IF  VALID-HANDLE(h-b1wgen9999)  THEN
                          DO:
                              RUN p-conectagener IN h-b1wgen9999.
                          
                              IF  RETURN-VALUE = "OK"  THEN
                                  RUN sistema/generico/procedures/b1wgen0001a.p
                                                    (INPUT crapttl.cdnatopc,
                                                    OUTPUT cDsNatOpc).
                              ELSE
                                  cDsNatOpc = STRING(crapass.dsproftl,"x(20)").
                              
                              RUN p-desconectagener IN h-b1wgen9999.

                              DELETE PROCEDURE h-b1wgen9999.
                          END.
                      ELSE
                          cDsNatOpc = STRING(crapass.dsproftl,"x(20)").
                  END.                       
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = p-cdcooper  AND
                                crapjur.nrdconta = p-nro-conta NO-LOCK NO-ERROR.             
             IF   AVAILABLE crapjur   THEN
                  DO:
                      RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                          SET h-b1wgen9999.
                          
                      IF  VALID-HANDLE(h-b1wgen9999)  THEN
                          DO:
                              RUN p-conectagener IN h-b1wgen9999.
                          
                              IF  RETURN-VALUE = "OK"  THEN
                                  RUN sistema/generico/procedures/b1wgen0001b.p
                                                    (INPUT crapjur.natjurid,
                                                    OUTPUT cDsNatOpc).
                              ELSE
                                  cDsNatOpc = STRING(crapass.dsproftl,"x(20)").
                              
                              RUN p-desconectagener IN h-b1wgen9999.

                              DELETE PROCEDURE h-b1wgen9999.
                          END.
                      ELSE
                          cDsNatOpc = STRING(crapass.dsproftl,"x(20)").
                  END.
         END.
  
    RETURN cDsNatOpc.
    
END FUNCTION.

FUNCTION fgetnrramfon RETURNS CHARACTER (INPUT p-cdcooper AS INTEGER):

    DEFINE VARIABLE aux_nrtelefo AS CHAR   NO-UNDO.
    DEFINE VARIABLE aux_tptelefo AS CHAR   NO-UNDO.
    DEFINE VARIABLE aux_conttitu AS INTE   NO-UNDO.
    DEFINE VARIABLE aux_conttipo AS INTE   NO-UNDO.
    DEFINE VARIABLE aux_qttitula AS INTE   NO-UNDO.

    DEFINE BUFFER crabttl FOR crapttl.

    /*** Se pessoa fisica :  Residencial/Celular/Comercial/Contato ***/
    /*** Se pessoa juridica: Comercial/Celular/Residencial/Contato ***/
    ASSIGN aux_qttitula = 0
           aux_nrtelefo = ""
           aux_tptelefo = IF  crapass.inpessoa = 1   THEN 
                              "1,2,3,4"
                          ELSE
                              "3,2,1,4".
                                                               
    IF  crapass.inpessoa = 1  THEN
        FOR EACH crabttl WHERE crabttl.cdcooper = p-cdcooper       AND
                               crabttl.nrdconta = crapass.nrdconta NO-LOCK:
            ASSIGN aux_qttitula = aux_qttitula + 1.
        END.
    ELSE
        ASSIGN aux_qttitula = 1.

    TITULARES:
    DO aux_conttitu = 1 TO aux_qttitula:

        TIPO:
        DO aux_conttipo = 1 TO 4:

            FIND FIRST craptfc WHERE 
                       craptfc.cdcooper = p-cdcooper         AND
                       craptfc.nrdconta = crapass.nrdconta   AND
                       craptfc.idseqttl = aux_conttitu       AND
                       craptfc.tptelefo = INTE(ENTRY(aux_conttipo,aux_tptelefo))  
                       NO-LOCK NO-ERROR.
            
            IF  AVAIL craptfc  THEN
                DO:
                    IF  craptfc.nrdddtfc <> 0  THEN
                        aux_nrtelefo = "(" + STRING(craptfc.nrdddtfc) + ")".

                    ASSIGN aux_nrtelefo = aux_nrtelefo + 
                                          STRING(craptfc.nrtelefo). 
    
                    LEAVE TITULARES.
                END.

        END. /** Fim do DO ... TO - TIPO **/

    END. /** Fim do DO ... TO - TITULARES **/
                              
    RETURN aux_nrtelefo.

END FUNCTION.

FUNCTION fgetnrcpfcgc RETURNS CHARACTER:

    RETURN IF crapass.inpessoa = 1  THEN 
              STRING(STRING(crapass.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx")
           ELSE 
              STRING(STRING(crapass.nrcpfcgc,"99999999999999"),
                                                        "xx.xxx.xxx/xx~xx-xx").

END FUNCTION.

FUNCTION fgetdstipcta RETURNS CHARACTER (INPUT p-cdcooper AS INTEGER):

    DEF VAR aux_dstipcta AS CHAR                              NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                              NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                              NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descrição da crítica */
    
    CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dstipcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                          WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                          WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                          WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
        RETURN STRING(crapass.cdtipcta,"z9").

    RETURN STRING(crapass.cdtipcta,"z9") + " - " + aux_dstipcta.

END FUNCTION.

FUNCTION fgetdssitdct RETURNS CHARACTER:
DEFINE VARIABLE aux_dssitcta AS CHARACTER  NO-UNDO.
DEFINE VARIABLE aux_des_erro AS CHARACTER  NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER  NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_descricao_situacao_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.cdsitdct, /* pr_cdsituacao */
                                        OUTPUT "",               /* pr_dssituacao */
                                        OUTPUT "",               /* pr_des_erro   */
                                        OUTPUT "").              /* pr_dscritic   */
    
    CLOSE STORED-PROC pc_descricao_situacao_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dssitcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dssitcta = pc_descricao_situacao_conta.pr_dssituacao 
                          WHEN pc_descricao_situacao_conta.pr_dssituacao <> ?
           aux_des_erro = pc_descricao_situacao_conta.pr_des_erro 
                          WHEN pc_descricao_situacao_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_situacao_conta.pr_dscritic
                          WHEN pc_descricao_situacao_conta.pr_dscritic <> ?.

    IF aux_des_erro = "NOK" THEN 
        aux_dssitcta = "".

    RETURN STRING(crapass.cdsitdct,"9") + " " + UPPER(aux_dssitcta).

END FUNCTION.


/************************* FIM DAS FUNCOES ***************************/

/* ......................................................................... */





