/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | procedures/b1wgen0030.p         | DSCT0001                                |
  |   efetua_baixa_titulo           | DSCT0001.pc_efetua_baixa_titulo         |
  |   busca_tarifas_dsctit          | TARI0001.pc_busca_tarifas_dsctit        |
  |   carrega_dados_tarifa_vigente  | TARI0001.pc_carrega_dados_tarifa_vigente|
  |   efetua_liquidacao_bordero     | DSCT0001.pc_efetua_liquidacao_bordero   |
  |   busca_total_descto_lim        | DSCT0001.pc_busca_total_descto_lim      |
  |   busca_total_descontos         | DSCT0001.pc_busca_total_descontos       |
  |   efetua_resgate_tit_bordero    | DSCT0001.pc_efetua_resgate_tit_bord     |
  |   busca_parametros_dsctit       | DSCT0002.pc_busca_parametros_dsctit     |
  |   busca_dados_limite            | DSCT0002.pc_busca_dados_limite          |
  |   busca_dados_limite_consulta   | DSCT0002.pc_busca_dados_limite_cons     |
  |   busca_restricoes              | DSCT0002.pc_busca_restricoes            |
  |   busca_dados_bordero           | DSCT0002.pc_busca_dados_bordero         |
  |   busca_titulos_bordero         | DSCT0002.pc_busca_titulos_bordero       |
  |   carrega_dados_bordero_titulos | DSCT0002.pc_carrega_dados_bordero_tit   |
  |   busca_dados_impressao_dsctit  | DSCT0002.pc_busca_dados_imp_descont     |
  |   busca_tarifa_desconto_titulo  | DSCT0003.pc_busca_tarifa_desc_titulo    |
  +---------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: b1wgen0030.p
    Autor   : Guilherme
    Data    : Julho/2008                     Ultima Atualizacao: 09/04/2019
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a Desconto de Titulos         
                    
    Alteracoes: 07/11/2008 - Ajustes para o AYLLOS WEB 
                           - Return 'nok' na critica_dados_lote (Guilherme).
                           
                15/12/2008 - Verificar data de baixa para pagamentos efetuados
                             no caixa ou internet (Evandro).
                             
                13/01/2009 - Correcao do calculo de juros devido aos fins de
                             semanas ou feriados (Evandro).
                             
                19/01/2009 - Liquidar o desconto de titulos com a data atual,
                             independente da data do parametro;
                           - Nao acumular o juros dos titulos (Evandro).
                           
                17/02/2009 - Valor de titulo excedido nao e' mais bloqueado
                             na tela LANBDT agora e' criado uma restricao no
                             bordero - abt.nrseqdig = 1 
                                     - abt.nrseqdig = 3 
                           - Incluir procedures de impressoes - adpatacao dos
                             fontes/dsctit_bordero_m.p fontes/dsctit_limite_m.p
                             (Guilherme).
                             
                17/03/2009 - Comentado as restricoes - abt.nrseqdig = 1 
                                                     - abt.nrseqdig = 3
                             (Guilherme).
                             
                08/04/2009 - Postergacao da data de vencimento para verificacao
                             na baixa do titulo (Guilherme).
                             
                21/05/2009 - Adicionar parâmetros da CECRED para TAB052
                             (Guilherme).                             
                             
                28/05/2009 - Titulos que tem a data de vencto menor que a data
                             de pagto, a data de vencto num feriado e a data 
                             de pagto for maior que vencto nao efetuar a baixa
                             pois o crps517 fara o debito a noite(Guilherme).
                             
                02/06/2009 - Acerto na limpeza de variaveis de erro(Guilherme).
                
                22/06/2009 - Nao permitir selecao de boleto gerado para 
                             pagamento de emprestimos - procedure busca_titulos
                             (Fernando).
                
                24/06/2009 - Nao baixar titulos que forem pagos apos o 1o. dia
                             util ao pagamento, caso contrario faz a baixa
                             (Guilherme).
                           - Incluir efetua_alteracao_bordero(Guilherme).
                           - Incluir LOG para desconto de titulos(Guilherme).
                           
                30/07/2009 - Acerto na hora de criar o crapljt por causa do 
                             escopo da transacao, estava criando crapljt sem 
                             liberar o bordero sendo assim duplicava os 
                             registros (Guilherme).
                           
                05/08/2009 - Incluir procedure busca_total_descto_lim;
                           - Na efetua_exclusao_tit_bordero excluir o bordero
                             quando nao houver mais titulos, verificar pelos
                             titulos e nao mais pelo lote;
                           - Mudanca de LOG para operacoes (Guilherme);
                           - Somente estornar titulos em desconto com situacao
                             igual a 2-Pago, limpar data pagamento;
                           - Corrigido escopo de transacao na liberacao do
                             bordero (Evandro).
                
                04/09/2009 - Limpeza da temp-table crawljt(Evandro/Guilherme).
                
                25/09/2009 - Quando o pagamento for pelo ayllos (batch) lancar
                             com a data atual, senao com a data enviada via
                             parametro;
                           - Controlar mais de um operador liberando o mesmo
                             bordero ao mesmo tempo (Evandro).
                             
                10/12/2009 -  Retirada do tratamento da atualizacao do
                              Rating. Projeto Rating (Gabriel).
                           -  Substituida todas as referencias a vlopescr por
                              vltotsfn no rating (Elton).  
                              
                14/01/2010 - Zerar variavel aux_tottitul -> Tarifa(Guilherme).
                
                01/04/2010 - Novos parametros para procedure consulta-poupanca
                             da BO b1wgen0006 (David).
                           - Incluido procedure busca_desconto_titulos (Elton).
                           
                07/06/2010 - Adaptacao para RATING no Ayllos Web (David).
                
                23/06/2010 - Incluir campo de envio a sede (Gabriel).
                
                28/06/2010 - Nao descontar titulos do pac 5 da CREDITEXTIL
                             Migracao de pac de cooperativas (Guilherme).
                             
                05/08/2010 - Leitura da crapass para alteracao acima (Guilherme)
                
                30/08/2010 - Alterado caminho da gravacao dos arquivos de log
                             (Elton).
                             
                23/09/2010 - Incluir procedure para gerar impressao da proposta
                             e contrato para limite do desconto (David).
                           - Incluir parametros nas procedures dos avalistas
                             na BO 9999 (Gabriel).    
                             
                19/10/2010 - Nao permitir inclusao de titulo com valor zerado
                             no bordero (David).
                             
                28/10/2010 - Incluidos parametros flgativo e nrctrhcj na 
                             procedure lista_cartoes (Diego).
                             
                16/11/2010 - Incluida a palavra "CADIN" na proposta do limite
                             de titulo (Vitor).   
                             
                22/11/2010 - Ajuste nas mensagens de confirmacao para liberacao
                             de bordero (David).
                
                25/11/2010 - Inclusao temporariamente do parametro flgliber
                             (Transferencia do PAC5 Acredi) (Irlan)
                             
                02/12/2010 - Trocada a procedure que cuida da impressao dos
                             ratings (Gabriel).  
                             
                04/01/2010 - Alterado o texto da clausula 5.1 do contrato
                             (Henrique).           
                             
                04/02/2011 - Incluir parametro par_flgcondc na procedure 
                             obtem-dados-emprestimos  (Gabriel - DB1).
                             
                16/02/2011 - Alteracao devido ajuste do campo nome (Henrique).
                           - Melhoria para performance craptdb (Guilherme).
                           
                05/04/2011 - Correcao na leitura da tt-risco na analise de 
                             borderos (David).
                             
                20/04/2011 - Alteracao dos procedimentos efetua_alteracao_limite,
                             para se adequar ao CEP integrado. (André - DB1)
                             
                24/05/2011 - Ajuste na impressao dos avalistas, utilizando os
                             novos parametros da alteracao acima (David).
                             
                30/05/2011 - Alteracao do format do campo 
                             tt-dados_nota_pro.dsendco2. (Fabricio)
                             
                31/05/2011 - Filtrar apenas por titulos que nao sao registrados
                             (crapcob.flgregis = FALSE); procedure busca_titulos
                             (Fabricio)
                             
                21/07/2011 - Nao gerar a proposta quando a impressao for completa 
                            (Isara - RKAM)
                            
                26/10/2011 - Adicionado na procedure busca_dados_limite_incluir,
                             a chamada da procedure 
                             valida_percentual_societario. (Fabricio)
                             
                21/11/2011 - Colocado em comentario temporariamente a chamada
                            da procedure valida_percentual_societario. 
                            (Fabricio)
                            
                19/03/2012 - Adicionada área para uso da Digitalizaçao (Lucas).
                
                24/04/2012 - Busca do dado flgdigit (Tiago).          
                
                04/06/2012 - Alterado numero do lote na liberaçao do crédito.
                             Objetivo: evitar lock de registros
                             10300 -> 17.000 + PAC (crédito da operaçao)
                              8461 -> 18.000 + PAC (IOF)           
                              8452 -> 19.000 + PAC (Tarifa de bordero) (Rafael).
                              
                21/06/2012 - Validaçao para a CRAPTAB na procedure 
                             'busca_dados_bordero' (Lucas).
                             
                27/06/2012 - Realizado melhorias na opçao "A,C" para as telas
                             Tab052, Tab053 (David Kruger).
                             
                09/07/2012 - Tratamento do cdoperad 'operador' de INTE para CHAR. (Lucas R.)
                           - Alterada a procedure 'efetua_baixa_titulo' para gravar valores
                             corretos na craplot com o histórico 597
                           - Alteraçoes na procedure 'busca_dados_dsctit' para
                             buscar valores dos títulos descontados por tipo de
                             cobrança
                           - Criaçao da procedure 'lista-linhas-desc-tit' para
                             listagem de Linhas de Desconto de Título disponíveis
                           - Criaçao da procedure 'busca_tipos_cobranca' para retornar
                             os Tipos de Cobrança disponíveis para a conta/dv.
                           - Criaçao da procedure 'valida-titulo-bordero' com
                             validaçoes para Títulos com e sem Cobrança Registrada
                           - Criaçao da procedure 'excluir-bordero-inteiro' para a
                             opçao E da tela LANBDT
                           - Adicionado parâmetro de Cobrança Registrada
                             na procedure 'busca_parametros_dsctit'
                           - Alteradas procedures 'busca_tarifas_dsctit', 'grava_tarifas_dsctit',
                             'efetua_baixa_titulo' e 'efetua_resgate_tit_bordero' para trabalhar com
                             diferentes taxas de acordo com o Tipo de Cobrança do Título
                           - Procedures 'busca_dados_exclusao_bordero' 
                             e 'busca_dados_consulta_bordero' unificadas na 
                             procedure 'busca_dados_validacao_bordero'
                           - Criada a procedure 'analisar-titulo-bordero' 
                             para reduzir a procedure 'efetua_liber_anali_bordero'
                           - Criada a procedure 'grava-restricao-bordero'
                           - Criada a procedure 'retorna-titulos-ocorrencia' para contar Títulos
                             por ocorrencia, bem como pelo sacado, cedente, entre outros
                           - Unificaçao das Impressoes de Desconto de Títulos e Limite na BO30i,
                             chamada na nova procedure 'carrega-impressao-dsctit'
                           - Alteraçoes na procedure 'busca_titulos':
                                - Adicionado parâmetro 'par_tpcobran' para consulta
                                  de títulos Com Cobrança, Sem Cobrança ou TODOS
                                - Retornar campo 'tt-titulos.flgregis' indicando se o Título
                                  possui Cobrança Registrada ou Sem Registro, caso par_tpcobran = TODOS 
                                - Retornar campo 'tt-titulos.tpcobran' com o Tp. de Cobrança, caso
                                  o Título possua Cobrança Registrada.
                           - Alteraçoes na procedure 'busca_titulos_bordero_lote':
                                - Retornar campo 'tt-titulos.flgregis' indicando se o Título
                                  possui Cobrança Registrada ou Sem Registro, caso par_tpcobran = TODOS 
                                - Retornar campo 'tt-titulos.tpcobran' com o Tp. de Cobrança, caso
                                  o Título possua Cobrança Registrada (Lucas) [Projeto Desconto de Título - Cob. Registrada].
                                  
                11/10/2012 - Incluido a passagem de um novo paramentro na 
                             chamada da procedure saldo_utiliza - Projeto GE
                             (Adriano).
                                
                05/11/2012 - Ajuste nas procedures valida_proposta_dados, 
                             efetua_liber_anali_bordero para atender ao projeto 
                             GE (Adriano).
                             
                30/11/2012 - Nao criticar tempo minimo de associado para 
                             cooperados migrados ao incluir limite (Rafael).
                             
                03/12/2012 - Permitir criaçao de borderos de título mesmo que limite 
                             da conta tenha Linha de Desconto Bloqueada.
                           - Nao permitir criaçao de limite contendo Linha de Desconto
                             bloqueada
                           - Nao permitir novo limite se cobrança nao estiver ativa (Lucas).
                           
                28/12/2012 - Incluso a passagem do parametro par_cdoperad nas 
                             procedures cria-tabelas-avalistas e 
                             atualiza_tabela_avalistas (Daniel).
                
                11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                             consulta da craptco (Tiago).
                             
                24/01/2013 - Tratamento para estorno de pagamentos a maior - 
                             Cob. sem registro (Lucas).
                             
                11/03/2013 - Nao levar em consideracao a situacao do convenio
                             (insitceb = 1) do cooperado ao mostrar os titulos 
                             do bordero (Rafael).
                           - Corrigir visualizacao dos titulos dos bordero que
                             possuem CEB com 5 digitos (Rafael).
                             
                26/03/2013 - Ajustes realizados:
                             - Incluido a chamada da procedure alerta_fraude 
                               dentro das procedures:
                               - busca_dados_limite_altera;
                               - busca_dados_limite_incluir;
                               - valida_proposta_dados;
                               - efetua_liber_anali_bordero;
                             - Retirado tratamento para apresentar mensagem
                               "Conta pertencente a Grupo economico...." nas
                               procedures valida_proposta_dados,
                               efetua_liber_anali_bordero (Adriano). 
                              
                04/04/2013 - Incluir Verificaçao de idade na procedure 
                             busca_dados_limite_incluir (Lucas R.).
                             
                15/04/2013 - Alterado parametro da tt-emprestimo para 
                             INPUT-OUTPUT (Daniele).
                             
                24/04/2013 - Correçao no cálculo da porcentagem de tit.
                             protestados e em cartorio (Lucas).
                             
                08/05/2013 - Adicionada validaçao para Limite excedido ao
                             Liberar bordero de títulos (Lucas).

                25/06/2013 - RATING BNDES - Gravar campo dtmvtolt crapprp
                             (Guilherme/Supero)
                             
                12/07/2013 - Alterado processos de busca tarifa para utilizar
                             rotinas da b1wgen0153 (Daniel).
                             
                03/09/2013 - Tratamento para Imunidade Tributaria (Ze).
                
                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).
                 
                23/10/2013 - Corrigido format na procedure
                             'carrega_dados_proposta_bordero'
                           - Correçao validaçao da situaçao do
                             bordero antes da Pre-analise/liberaçao (Lucas).
                             
                29/10/2013 - Substituido telefone da crapass para craptfc
                             na procedure busca_dados_impressao_dsctit. (Reinert)
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                02/12/2013 - Adicionado campo idseqttl nos FOR FIRST da tabela
                             craptfc. (Reinert)                             
                
                20/12/2013 - Adicionado validate para as tabelas craplot,
                             craplcm, crapljt, craplim, crapjfn, crapprp,
                             crapbdt, craptdb, crablot, crablcm, cra2lot,
                             crapabt (Tiago).     
                             
                             
                26/12/2013 - Ajuste leitura crapcob para ganho de performace 
                             e retirado validaco se crapcob.insitpro <> 3
                             quando sacado DDA  (Daniel).  
                             
                02/01/2014 - Melhoria na leitura da tabela crabcob (Daniel).
                
                29/01/2014 - Nao permitir que titulos resgatados interfiram
                             no processo de selecao de titulos para um novo
                             bordero. (Rafael).
                             
                07/02/2014 - Ajuste procedure busca_dados_dsctit para alimentar
                             tt-desconto_titulos mesmo independente situacao do
                             contrato de limite titulo (Daniel).
                             
                24/02/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                             
                24/03/2014 - Retirar tratamento de sequencia na crapbdt
                             (Gabriel).
                             
                24/06/2014 - Adicionado o parametro par_dsoperac 
                            (com valor 'DESCONTO TITULO') a chamada das
                            procedures cria-tabelas-avalistas e 
                            atualiza_tabela_avalistas. 
                            (Chamado 166383) - (Fabricio)
                            
                24/06/2014 - Inclusao da include b1wgen0138tt para uso da
                             temp-table tt-grupo.
                             (Chamado 130880) - (Tiago Castro - RKAM)
                             
                14/07/2014 - Adicionado novos parametros nas procedures
                             atualiza_tabela_avalistas e cria-tabelas-avalistas
                             (Daniel/Thiago)
                             
                28/07/2014 - adicionado parametro de saida em chamada da
                             proc. cria-tabelas-avalistas.
                             (Jorge/Gielow) - SD 156112           
                             
               25/08/2014 - Ajustes referentes ao Projeto CET 
                             (Lucas Ranghetti/Gielow)   
                             
               08/09/2014 - Alterado crapcop.nmcidade para crapage.nmcidade
                            estava buscando a cidade da sede. (SD 163504 Lucas R.)                             
                            
               24/09/2014 - Ajuste na efetua_estorno_baixa_titulo incluindo
                            Tratamento para estorno de lançamentos: 
                               cdhistor = 1101 Ajuste a menor - Cob. com registro 
                               cdhistor = 1102 Ajuste a Maior - Cob. com registro             
                            (SD 202445 - Odirlei/Amcom).
                            
               06/11/2014 - Alterado parametro passado na chamada das procedures
                            cria-tabelas-avalistas e atualiza_tabela_avalistas;
                            de: 'DESCONTO TITULO' para: 'DESC.TITULO'.
                            Motivo: Possibilidade de erro ao tentar gravar
                            registro de log (craplgm). (Fabricio)
               
               01/12/2014 - Incluir nova procedure valida_situacao_pa
                            Softdesk 100471 (Lucas R./Rodrigo)

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                           
               17/12/2014 - Alterado a procedure valida_proposta_dados para
                            qdo for validar linha de credito verificar se
                            está ativa, pois estava deixando incluir 
                            proposta com linha bloqueada
                            SD 234036 (Tiago/Rosangela).
                            
               21/01/2015 - Substituicao da chamada da procedure consulta-aplicacoes 
                            da BO b1wgen0004 pela procedure obtem-dados-aplicacoes 
                            da BO b1wgen0081.Também foi adicionado o procedimento 
                            pc_busca_saldos_aplicacoes da package APLI0005. 
                           (Carlos Rafael Tanholi - Projeto Captacao) 
                           
               28/01/2015 - Incluso VALIDATE na b-crapbdt e craptdb (Daniel).
               
               27/02/2015 - Corrigr gravacao da crapabt.dsrestri. Chamado
                            259370 (Jonata-Rkam).                             

               14/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
                            de proposta de novo limite de desconto de cheque para
                            menores nao emancipados. (Reinert)  
                            
               19/06/2015 - Adicionado verificacao se tem produto de cobranca antes
                            de incluir limite em proc. busca_dados_limite_incluir.
                            (Jorge/Gielow) - SD 291542                          
               
               22/06/2015 - Ajuste para passar o numero do cpf do conjuge do avalista
                            corretamente. (Jorge/Gielow) - SD 290885
                            
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
               
               26/08/2015 - Ajuste na passagem de cpf/cnpj em lugares indevidos, 
                            conforme relatado no chamado 314472. (Kelvin). 
               
               13/10/2015 - Ajuste na tipagem do vllimite que estava como int 
                            e foi passando para decimal. SD 325240 (Kelvin).   
                            
               15/10/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
               16/10/2015 - Ajuste para mostrar o numero cpf do conjugue do 
                            segundo fiador corretamente. (Jorge/Gielow) 341376

               08/12/2015 - Retirado select da funcao fn_sequence e substituido
                            pela chamada da procedure pc_sequence_progress
                            por problemas de cursores abertos 
                            (Tiago/Rodrigo SD347440).
                            
               18/12/2015 - Criada procedure para edição de número do contrato de limite 
                            (Lunelli - SD 360072 [M175])
                            
               29/12/2015 - Adicionado novo parametro na CRAPTAB das procedures
                            busca_parametros_dsctit, grava_parametros_dsctit
                            (carencia debito titulos vencidos) 
                            (Tiago/Rodrigo Melhoria 116).

               16/05/2016 - Ajustado rotina efetua_resgate_tit_bordero para gerar
			                tarifa de resgate na data de resgate e não na data na qual
				  		   foi criado o bordero de desconto de titulo.
						   PRJ318 - Nova plataforma de cobrança (Odirlei-AMcom)

			   28/04/2016 - Adicionado verificacao para tratar isencao de cobranca
                            de tarifa na procedure efetua_liber_anali_bordero. 
                            (Reinert)
               17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

               27/06/2016 - Criacao dos parametros inconfi6, cdopcoan e cdopcolb na
                            efetua_liber_anali_bordero. Inclusao de funcionamento
                            de pedir senha do coordenador. (Jaison/James)

               02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                            (Jaison/Anderson)

               25/10/2016 - Validacao de CNAE restrito Melhoria 310 (Tiago/Thiago)

			   09/03/2017 - Ajuste para validar se o titulo ja esta incluso em um bordero
					       (Adriano - SD 603451).

               12/05/2017 - Passagem de 0 para a nacionalidade. (Jaison/Andrino)

               05/06/2017 - Verificacao de titulo baixado para gravar restricao
                            (Tiago/Ademir #678289)
                            
               12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
			 		       (Adriano - P339).

			         29/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)

               08/08/2017 - Inserido Valor do bordero no cálculo das tarifas - Everton/Mouts/M150
               
               04/10/2017 - Chamar a verificacao de revisao cadastral apenas para inclusao
                            de novo limite. (Chamado 768648) - (Fabricio)

			   16/10/2017 - Inserido valor liquido do Bordero para cálculo de tarifas - Everton/Mouts/M150

               20/10/2017 - Projeto 410 - Ajustado cálculo do IOF na liberação do borderô
                            (Diogo - MoutS)

               25/10/2017 - Projeto 410 - Ajustado cálculo do IOF na baixa do título
                            (James)

               20/10/2017 - Criada procedure busca_iof_simples_nacional 
                            (Diogo - MoutS - Projeto 410 - RF 43 a 46)

               11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))

               07/03/2018 - Preenchimento do campo 'dtrenova' na procedure busca_dados_dsctit (Leonardo Oliveira - GFT)

               13/03/2018 - Preenchimento do campo 'perrenov' na procedure busca_dados_dsctit  (Leonardo Oliveira - GFT)

               14/03/2018 - Removido o conteúdo "(CONTINGENCIA)" das situações 3-Aprovada e 6-Rejeitada do campo insitapr da 
                            procedure busca_limites (Paulo Penteado - GFT)

               16/03/2018 - Preenchimento dos campos  'flgstlcr' e 'cddlinha' na procedure busca_dados_dsctit (Leonardo Oliveira - GFT)
               
               16/03/2018 - Filtrar as operações de desconto que foram inclusas no sistema e não tiverem a liberação/efetivação dentro de até 120 dias corridos em 'busca_borderos' (Leonardo Oliveira - GFT)

               23/03/2018 - Alterada as rotinas efetua_inclusao_limite e efetua_alteracao_limite para substituir a utilização da tabela de contrato CRAPLIM para
                            a tabela de proposta CRAWLIM.
                            Criado a procedure busca_dados_proposta para preencher a tt-dsctit_dados_limite com os dados da proposta, ela é chamada na procedure 
                            busca_dados_limite_altera (Paulo Penteado GFT)
                            
               10/04/2018 - Adicionado o procedimento busca_dados_proposta_consulta (Paulo Penteado GFT)

               12/04/2018 - Criado a procedure 'busca_dados_limite_manutencao',
                              - Criado a procedure 'realizar_manutencao_contrato', 
                              - Retirada a validação para alteração na procedure 'busca_dados_limite',
                              - Adição da validação de limite máximo na procedure 'efetua_inclusao_limite' (Leonardo Oliveira - GFT)

               13/04/2018 - Na procedure busca_dados_impressao_dsctit alterado a chamada da procedure busca_dados_proposta_consulta pela 
                            busca_dados_proposta_consulta (Paulo penteado GFT)

               16/04/2018 - Na procedure efetua_cancelamento_limite, adicionado o cancelamento das proposta principal e de manutenção do contrato (Paulo Penteado GFT)

               18/04/2018 - Na procedure realizar_manutencao_contrato, adicionado validação para não incluir uma proposta de manutenção caso já tenha uma outra proposta
                            na situação Em estudo, Aprovada ou Não Aprovada (Paulo Penteado GFT)

               20/04/2018 - Na procedure busca_dados_dsctit, adicionado o retorno da data da ultima proposta de manutenção ativa (Paulo Penteado GFT)

               24/04/2018 - Copiado a validação de verificação de proposta em estudo existente na rotina b1wgen0030.p > realizar_manutencao_contrato para a 
                            rotina b1wgen0030.p > busca_dados_limite_manutencao.
                            Adicionado a procedure busca_dados_proposta_manuten. (Paulo Penteado GFT)

               25/04/2018 - Correções na busca_parametros_dsctit para buscar as regras de registrados (Luis Fernando GFT)
               
               17/04/2017 - Chamada para rotina pc_valida_adesao_produto.
                          - Inlusao das procedures valida_inclusao_bordero,
                            valida_alteracao_bordero e valida_exclusao_tit_bordero.
                            Projeto 366 (Lombardi).

               09/05/2018 - Adicionado na busca_dados_limite_altera validação para não permitir a alteração de uma proposta criada antes da nova implantação do
                            Limite de Desconto de Título (Paulo Penteado GFT)
			   
			  26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

               21/08/2018 - Adicionado na efetua_cancelamento_limite validação para não permitir a exclusao de contrato com propostas pendentes na IBRATAN (Andrew Albuquerque - GFT)
               
               23/08/2018 - Alteraçao na efetua_cancelamento_limite: Registrar o cancelamento na tabela de histórico de alteraçao de contrato de limite (Andrew Albuquerque - GFT)
               
               29/08/2018 - Adicionado controle para situaçao(insitlim) ANULADA na proc 'busca_dados_proposta'. PRJ 438 (Mateus Z - Mouts)
				  
               03/09/2018 - Correção para remover lote (Jonata - Mouts).

			   13/11/2018 - Adicionada parametros a procedure pc_verifica_tarifa_operacao. PRJ 345. (Fabio Stein - Supero)

               16/11/2018 - Alterado para buscar o qtd dias de renovacao da tabela craprli (Paulo Penteao GFT)

               29/11/2018 - P410 - Ajuste na chamada pc_insere_iof para nrseqdig (Douglas Pagel / AMcom).

			   09/04/2019 - Ajustado busca_total_descontos para contabilizar total de desconto de titulo atraves no campo
			                saldo do titulo vlsldtit (Daniel - Ailos)
..............................................................................*/

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_vltarifa AS DECI                                           NO-UNDO. 
DEF VAR aux_cdfvlcop AS INTE                                           NO-UNDO. 
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO. 

DEF VAR h-b1wgen0153 AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE tt-dsctit LIKE tt-dados_dsctit.

DEFINE VARIABLE const_txiofpf AS DECIMAL DECIMALS 4 INITIAL 0.0082  NO-UNDO.
DEFINE VARIABLE const_txiofpj AS DECIMAL DECIMALS 4 INITIAL 0.0041  NO-UNDO.

/*****************************************************************************/
/*            Buscar a soma total de descontos (titulos + cheques)           */
/*****************************************************************************/
PROCEDURE busca_total_descontos:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tot_descontos.

    EMPTY TEMP-TABLE tt-tot_descontos.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar valor total de descontos.".
    
    CREATE tt-tot_descontos.
    
    /* Cheques */
    /* Busca saldo e limite de desconto de cheques */
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 2            AND
                             craplim.insitlim = 2        
                             NO-LOCK NO-ERROR.

    IF  AVAILABLE craplim  THEN
        ASSIGN tt-tot_descontos.vllimchq = craplim.vllimite.

    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                           crapcdb.nrdconta = par_nrdconta   AND
                           crapcdb.insitchq = 2              AND
                           crapcdb.dtlibera > par_dtmvtolt   NO-LOCK:
    
        ASSIGN tt-tot_descontos.vldscchq = tt-tot_descontos.vldscchq +
                                           crapcdb.vlcheque
               tt-tot_descontos.vltotdsc = tt-tot_descontos.vltotdsc +
                                           crapcdb.vlcheque
               tt-tot_descontos.qtdscchq = tt-tot_descontos.qtdscchq + 1
               tt-tot_descontos.qttotdsc = tt-tot_descontos.qttotdsc + 1.
    
    END.  /*  Fim do FOR EACH crapcdb  */
    
    /* Titulos */
    /* Busca saldo e limite de desconto de titulos */
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 3            AND
                             craplim.insitlim = 2        
                             NO-LOCK NO-ERROR.

    IF  AVAILABLE craplim  THEN
        ASSIGN tt-tot_descontos.vllimtit = craplim.vllimite.
    
    /*Titulos que estao em desconto liberados ou que foram pagos na data atual*/
    FOR EACH craptdb WHERE (craptdb.cdcooper  = par_cdcooper AND
                            craptdb.nrdconta  = par_nrdconta AND
                            craptdb.insittit =  4)
                           OR
                           (craptdb.cdcooper  = par_cdcooper AND
                            craptdb.nrdconta  = par_nrdconta AND
                            craptdb.insittit = 2 AND
                            craptdb.dtdpagto = par_dtmvtolt)
                          NO-LOCK:

        ASSIGN tt-tot_descontos.vldsctit = tt-tot_descontos.vldsctit +
                                           craptdb.vlsldtit
               tt-tot_descontos.qtdsctit = tt-tot_descontos.qtdsctit + 1

               tt-tot_descontos.vlmaxtit = IF craptdb.vltitulo > 
                                              tt-tot_descontos.vlmaxtit  THEN
                                              craptdb.vltitulo
                                            ELSE tt-tot_descontos.vlmaxtit
                                            
               tt-tot_descontos.vltotdsc = 
                            tt-tot_descontos.vltotdsc + craptdb.vltitulo
               tt-tot_descontos.qttotdsc = tt-tot_descontos.qttotdsc + 1.
           
    END.  /*  Fim do FOR EACH craptdb  */
    
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

/*****************************************************************************/
/*   Buscar valor total da divida em desconto a partir do numero do craplim  */
/*****************************************************************************/
PROCEDURE busca_total_descto_lim:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tot_descontos.

    EMPTY TEMP-TABLE tt-tot_descontos.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar valor total de desconto a partir " + 
                              "do limite.".
    
    CREATE tt-tot_descontos.
    
    /* Busca saldo e limite de desconto de titulos do limite */
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 3            AND
                             craplim.nrctrlim = par_nrctrlim
                             NO-LOCK NO-ERROR.

    IF  AVAILABLE craplim  THEN
        ASSIGN tt-tot_descontos.vllimtit = craplim.vllimite.
    
    /*  
        Titulos  do limite que estao em desconto(liberados ou que foram pagos 
        na data atual)
    */
    FOR EACH crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND
                           crapbdt.nrdconta = par_nrdconta AND
                           crapbdt.nrctrlim = par_nrctrlim NO-LOCK,
        EACH craptdb WHERE (craptdb.cdcooper  = crapbdt.cdcooper AND
                            craptdb.nrdconta  = crapbdt.nrdconta AND
                            craptdb.nrborder  = crapbdt.nrborder AND
                            craptdb.insittit =  4)
                           OR
                           (craptdb.cdcooper  = crapbdt.cdcooper AND
                            craptdb.nrdconta  = crapbdt.nrdconta AND
                            craptdb.nrborder  = crapbdt.nrborder AND
                            craptdb.insittit = 2                 AND
                            craptdb.dtdpagto = par_dtmvtolt)
                          NO-LOCK:

        ASSIGN tt-tot_descontos.vldsctit = tt-tot_descontos.vldsctit +
                                           craptdb.vltitulo
               tt-tot_descontos.qtdsctit = tt-tot_descontos.qtdsctit + 1

               tt-tot_descontos.vlmaxtit = IF craptdb.vltitulo > 
                                              tt-tot_descontos.vlmaxtit  THEN
                                              craptdb.vltitulo
                                            ELSE tt-tot_descontos.vlmaxtit
                                            
               tt-tot_descontos.vltotdsc = 
                            tt-tot_descontos.vltotdsc + craptdb.vltitulo
               tt-tot_descontos.qttotdsc = tt-tot_descontos.qttotdsc + 1.
           
    END.  /*  Fim do FOR EACH craptdb  */
    
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

/****************************************************************************/
/*           Validar numero de contrato informado e tabela avl              */
/****************************************************************************/
PROCEDURE valida_nrctrato_avl:

    DEF INPUT PARAM par_cdcooper AS INTE    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE    NO-UNDO.
    DEF INPUT PARAM par_antnrctr AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrctaav1 AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrctaav2 AS INTE    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    IF  par_nrctaav1 > 0 THEN
        DO:
            IF  CAN-FIND(crapavl WHERE 
                         crapavl.cdcooper = par_cdcooper AND
                         crapavl.nrdconta = par_nrctaav1 AND
                         crapavl.nrctravd = par_nrctrlim AND
                         crapavl.tpctrato = 8) THEN         
                DO:
                    ASSIGN aux_cdcritic = 390
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".

                END.
        END.
                  
    IF  par_nrctaav2 > 0 THEN
        DO:
            IF  CAN-FIND(crapavl WHERE 
                         crapavl.cdcooper = par_cdcooper AND
                         crapavl.nrdconta = par_nrctaav2 AND
                         crapavl.nrctravd = par_nrctrlim AND
                         crapavl.tpctrato = 8)  THEN
                DO:                         
                
                    ASSIGN aux_cdcritic = 390
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    RETURN "NOK".                    

                END.
        END.
                  
    IF  par_nrctrlim <> par_antnrctr   THEN
        DO:
            ASSIGN aux_cdcritic = 301
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".                   
        END.
            
    RETURN "OK".

END PROCEDURE.


/****************************************************************************/
/*                  Efetuar Analise ou liberacao do bordero                 */
/****************************************************************************/
PROCEDURE efetua_liber_anali_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_cdopcoan AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_cdopcolb AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.    
    DEF INPUT PARAM par_inproces AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_inconfir AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_inconfi2 AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_inconfi3 AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_inconfi4 AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_inconfi5 AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_inconfi6 AS INTE                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_indrestr AS INTE                      NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_indentra AS INTE                      NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
                                                                    
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
    DEF OUTPUT PARAM TABLE FOR tt-risco.                            
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.          
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
                                                                    
    DEF VAR aux_contamsg AS INTEGER                                  NO-UNDO.
    DEF VAR aux_contareg AS INTEGER                                  NO-UNDO.
    DEF VAR aux_contador AS INTEGER                                  NO-UNDO.
    DEF VAR aux_vlr_maxleg   AS DECIMAL                              NO-UNDO.
    DEF VAR aux_vlr_maxutl   AS DECIMAL                              NO-UNDO.
    DEF VAR aux_vlr_minscr   AS DECIMAL                              NO-UNDO.
    DEF VAR aux_vlr_excedido AS LOGICAL                              NO-UNDO.
    DEF VAR aux_vlutiliz AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_diaratin AS INTEGER                                  NO-UNDO.
    DEF VAR aux_vlrmaior AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_recid    AS RECID                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                                     NO-UNDO.
    DEF VAR aux_txdiaria AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_vlborder AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_vlborderbrut AS DECIMAL                              NO-UNDO.
    DEF VAR aux_qtdprazo AS INTEGER                                  NO-UNDO.
    DEF VAR aux_vltitulo AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_dtperiod AS DATE                                     NO-UNDO.
    DEF VAR aux_vldjuros AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_vljurper AS DECIMAL                                  NO-UNDO.
    DEF VAR aux_dtrefjur AS DATE                                     NO-UNDO.
    DEF VAR aux_contado1 AS INTEGER                                  NO-UNDO.
    DEF VAR flg_trocapac AS LOGICAL                                  NO-UNDO.
    DEF VAR aux_cdpactra LIKE crapope.cdpactra                       NO-UNDO.
    DEF VAR aux_nrdgrupo AS INT                                      NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                     NO-UNDO.
    DEF VAR aux_pertengp AS LOG                                      NO-UNDO.
    DEF VAR aux_dsdrisco AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                     NO-UNDO.
    DEF VAR aux_flgimune AS INT                                      NO-UNDO.
    DEF VAR aux_flsnhcoo AS LOGICAL INIT "N"                         NO-UNDO.
    DEF VAR aux_qtacobra AS INTE                                     NO-UNDO.
    DEF VAR aux_fliseope AS INTE                                     NO-UNDO.
    DEF VAR aux_cdacesso AS CHAR                                     NO-UNDO.
	DEF VAR aux_nrseqdig AS INT									     NO-UNDO.

    DEFINE VARIABLE aux_qtdiaiof AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_periofop AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vliofcal AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiof AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vltotaliofsn AS DECIMAL NO-UNDO.

    DEFINE VARIABLE aux_natjurid AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_tpregtrb AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vltotiofpri AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiofadi AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiofcpl AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotoperac AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltxiofatraso AS DECIMAL NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0159 AS HANDLE                                   NO-UNDO.
   
    DEF BUFFER crablot  FOR craplot.
    DEF BUFFER crabtdb  FOR craptdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE crawljt.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad 
                       NO-LOCK NO-ERROR.

    IF AVAIL crapope THEN
       ASSIGN aux_cdpactra = crapope.cdpactra.
    ELSE
       ASSIGN aux_cdpactra = 0.
           
    IF par_flgerlog  THEN
       DO:
          ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

          IF par_cddopcao = "N"  THEN       
             ASSIGN aux_dstransa = "Analisar bordero " + STRING(par_nrborder) +
                                   " de desconto de titulo.".
          ELSE
             ASSIGN aux_dstransa = "Liberar bordero " + STRING(par_nrborder) +
                                   " de desconto de titulo.".
       END.
    
    DO TRANSACTION aux_contador = 1 TO 10:

        FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper   AND
                           crapbdt.nrborder = par_nrborder
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF  NOT AVAILABLE crapbdt   THEN
            IF  LOCKED crapbdt   THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero em uso. Tente" +
                                          " novamente.".
                           aux_cdcritic = 0.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero nao encontrado."
                           aux_cdcritic = 0.
                    LEAVE.
                END.

        IF  par_cddopcao = "N"    AND
            crapbdt.insitbdt > 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "O bordero deve estar na situacao " +
                                      "EM ESTUDO ou ANALISADO.".

                LEAVE.                      
            END.

        IF  par_cddopcao = "L"     AND
            crapbdt.insitbdt <> 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "O bordero deve estar na situacao " +
                                      "ANALISADO.".

                LEAVE.                      
            END.

        ASSIGN aux_dscritic = "".
        LEAVE.

    END. /* Final do DO .. TO */    

    IF  aux_dscritic <> ""  THEN
        DO:
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
    
	RUN valida_titulos_bordero(INPUT par_cdcooper,
							   INPUT par_cdagenci,
							   INPUT par_nrdcaixa,
							   INPUT par_cdoperad,
							   INPUT par_dtmvtolt,
							   INPUT par_idorigem,
							   INPUT par_nrdconta,
							   INPUT par_nrborder,
							   INPUT 1, /*tpvalida*/
							   INPUT TABLE tt-titulos,
							   OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
	   DO:
	      FIND FIRST tt-erro NO-LOCK NO-ERROR.

		  IF NOT AVAIL tt-erro THEN
		     DO:
		        ASSIGN aux_dscritic = "Nao foi possivel validar o bordero.".
            
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).    

            END.

            RETURN "NOK".

        END.    
    
    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

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

    RUN busca_iof IN h-b1wgen9999 (INPUT par_cdcooper,
                                   INPUT 0, /* agenci */
                                   INPUT 0, /* caixa  */
                                   INPUT par_dtmvtolt,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-iof).
                               
    RUN busca_iof_simples_nacional IN h-b1wgen9999 (INPUT par_cdcooper,
                                      INPUT 0, /* agenci */
                                      INPUT 0, /* caixa  */
                                      INPUT par_dtmvtolt,
                                      INPUT 'VLIOFOPSN',
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-iof-sn).
    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE OBJECT h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
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
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro da tabela de IOF nao " +
                                          "encontrada.".

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
        
    FIND FIRST tt-iof NO-LOCK NO-ERROR.
    
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper  AND
                             craplim.nrdconta = par_nrdconta  AND
                             craplim.tpctrlim = 3             AND
                             craplim.insitlim = 2             
                             NO-LOCK NO-ERROR.
     
    IF  NOT AVAILABLE craplim  THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de limites nao encontrado.".
                   
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
    
    ASSIGN aux_dtmvtolt = par_dtmvtolt.
           
    RUN busca_dados_risco (INPUT par_cdcooper,
                           OUTPUT TABLE tt-risco).
    
    FIND FIRST tt-risco WHERE tt-risco.diaratin <> 0 NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-risco  THEN
        ASSIGN aux_dtmvtolt = (aux_dtmvtolt - tt-risco.diaratin). /* 180 dias */
    
    ASSIGN flg_trocapac = FALSE.

    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrborder = par_nrborder AND
                           craptdb.nrdconta = par_nrdconta 
                           NO-LOCK:
                           
        IF  craptdb.dtvencto >= 01/01/2011  THEN
            ASSIGN flg_trocapac = TRUE.
                           
    END.
    
    /* Buscar dados do cooperado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".        

        END.

    ASSIGN aux_inpessoa = crapass.inpessoa.

    /* Busca dados da pessoa jurídica */
    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                       crapjur.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
    IF  NOT AVAIL(crapjur)  THEN
      DO:
        ASSIGN aux_natjurid = 0.
        ASSIGN aux_tpregtrb = 0.
      END.
    ELSE
      DO:
        ASSIGN aux_natjurid = crapjur.natjurid.
        ASSIGN aux_tpregtrb = crapjur.tpregtrb.
      END.
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de liberar/pre-analisar os borderos " + 
                          "de descontos de titulos na conta "              +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta, 
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 5, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).


    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.


    IF  flg_trocapac          AND
        crapass.cdcooper = 2  AND
        crapass.cdagenci = 5  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Bordero possui titulo com vencto " +
                                  "superior a 31/12/2010.".
                   
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

    /* Realiza a pre-analise e cria restricoes do bordero */
    RUN analisar-titulo-bordero (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_dtmvtolt,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_nrborder,
                                 INPUT TRUE,
                                 INPUT par_cddopcao,
                                 INPUT-OUTPUT par_indrestr,
                                 OUTPUT aux_flsnhcoo,
                                 OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

   /* Se possui restricoes executa o bloco */
   IF par_indrestr = 1    AND 
     (par_cddopcao = "N"  OR
      par_cddopcao = "L") THEN
      DO:
         /****************************************/
         ASSIGN aux_vlr_excedido = NO
                aux_vlr_maxleg = 0
                aux_vlr_maxutl = 0
                aux_vlr_minscr = 0.
    
         FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                            NO-LOCK NO-ERROR.

         IF  AVAIL crapcop THEN
             ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
                    aux_vlr_maxutl = crapcop.vlmaxutl
                    aux_vlr_minscr = crapcop.vlcnsscr.
         
         IF NOT VALID-HANDLE(h-b1wgen0138) THEN
            RUN sistema/generico/procedures/b1wgen0138.p
                PERSISTENT SET h-b1wgen0138.
         
         
         ASSIGN aux_pertengp = DYNAMIC-FUNCTION ("busca_grupo" IN h-b1wgen0138,
                                                  INPUT par_cdcooper,
                                                  INPUT par_nrdconta,
                                                  OUTPUT aux_nrdgrupo,
                                                  OUTPUT aux_gergrupo,
                                                  OUTPUT aux_dsdrisgp).
         
         IF par_inconfi5 = 30 THEN
            DO:
               IF aux_gergrupo <> "" THEN
                  DO:
                     CREATE tt-msg-confirma.
                     
                     ASSIGN tt-msg-confirma.inconfir = par_inconfi5 + 1
                            tt-msg-confirma.dsmensag = aux_gergrupo + 
                                                       " Confirma?".
         
                     IF VALID-HANDLE(h-b1wgen0138) THEN
                        DELETE OBJECT(h-b1wgen0138).
                                 
                     RETURN "OK".
         
                  END.
               
            END.
         
         IF aux_pertengp THEN
            DO:
              /* Procedure responsavel por calcular o endividamento do grupo */
                RUN calc_endivid_grupo IN h-b1wgen0138
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci, 
                                             INPUT par_nrdcaixa, 
                                             INPUT par_cdoperad, 
                                             INPUT par_dtmvtolt, 
                                             INPUT par_nmdatela, 
                                             INPUT par_idorigem, 
                                             INPUT aux_nrdgrupo, 
                                             INPUT TRUE, /*Consulta por conta*/
                                            OUTPUT aux_dsdrisco, 
                                            OUTPUT aux_vlutiliz,
                                            OUTPUT TABLE tt-grupo,
                                            OUTPUT TABLE tt-erro).
         
                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE OBJECT h-b1wgen0138.
                
                IF RETURN-VALUE <> "OK" THEN
                   RETURN "NOK".

                IF par_inconfi2 > 10  AND 
                   par_inconfi3 = 21  THEN
                   IF aux_vlr_maxutl > 0  THEN
                      DO:
                         ASSIGN aux_vlrmaior = 0. 
                     
                         IF par_inconfi2 = 11 THEN
                            DO:
                             IF (aux_vlutiliz + aux_vlrmaior) > aux_vlr_maxutl THEN
                                DO:
                                   CREATE tt-msg-confirma.
                 
                                   ASSIGN tt-msg-confirma.inconfir = 
                                                           par_inconfi2 + 1
                                          tt-msg-confirma.dsmensag = 
                                               "Vlrs(Utl) Excedidos"    +
                                               "(Utiliz. "              +
                                                TRIM(STRING(aux_vlutiliz,
                                                            "zzz,zzz,zz9.99")) + 
                                               " Excedido " +
                                               TRIM(STRING((aux_vlutiliz + 
                                                            aux_vlrmaior
                                                            - aux_vlr_maxutl),
                                                            "zzz,zzz,zz9.99")) +
                                               ")Confirma? ".
                 
                                   RETURN "OK".
                 
                                END.      

                            END.
                 
                            
                         IF par_inconfi2 = 12 AND
                           ((aux_vlutiliz + aux_vlrmaior) > aux_vlr_maxleg) THEN
                             DO:
                                CREATE tt-msg-confirma.
                 
                                ASSIGN tt-msg-confirma.inconfir = 19
                                       tt-msg-confirma.dsmensag = 
                                       "Vlr(Legal) Excedido" +
                                       "(Utiliz. " +
                                       TRIM(STRING(aux_vlutiliz,
                                       "zzz,zzz,zz9.99")) 
                                       + " Excedido " +
                                       TRIM(STRING((aux_vlutiliz + aux_vlrmaior
                                       - aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                       ") ". 
                 
                                ASSIGN aux_dscritic = "". 
                                       aux_cdcritic = 79.
                                
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                              
                                RETURN "NOK".

                             END.

                   END.
              
                IF par_inconfi4 = 71  THEN
                   IF (aux_vlutiliz + aux_vlrmaior) >  aux_vlr_minscr  THEN
                       DO:
                          CREATE tt-msg-confirma.
                  
                          ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                                 tt-msg-confirma.dsmensag = 
                                           "Efetue consulta no SCR.".

                          RETURN "OK".
                  
                       END.
         
            END.
         ELSE
            DO:
               IF VALID-HANDLE(h-b1wgen0138) THEN
                  DELETE OBJECT h-b1wgen0138.
               

               IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                  RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                      SET h-b1wgen9999.
              
               IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Handle invalido para BO " + 
                                            "b1wgen9999.".
                      
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
              
              
               RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_dtmvtopr,
                                                  INPUT "",
                                                  INPUT par_inproces,
                                                  INPUT FALSE,
                                                 OUTPUT aux_vlutiliz,
                                                 OUTPUT TABLE tt-erro).
              
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE OBJECT h-b1wgen9999.
              
               IF RETURN-VALUE = "NOK"  THEN
                  DO:
                      IF par_flgerlog  THEN
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
              
              IF  par_inconfi2 > 10  AND 
                  par_inconfi3 = 21  THEN
                  IF  aux_vlr_maxutl > 0  THEN
                      DO:
                         ASSIGN aux_vlrmaior = 0. 
                    
                         IF par_inconfi2 = 11 THEN
                            DO:
                             IF (aux_vlutiliz + aux_vlrmaior) > aux_vlr_maxutl THEN
                                DO:
                                   CREATE tt-msg-confirma.
              
                                   ASSIGN tt-msg-confirma.inconfir = 
                                                           par_inconfi2 + 1
                                          tt-msg-confirma.dsmensag = 
                                               "Vlrs(Utl) Excedidos"    +
                                               "(Utiliz. "              +
                                                TRIM(STRING(aux_vlutiliz,
                                                            "zzz,zzz,zz9.99")) + 
                                               " Excedido " +
                                               TRIM(STRING((aux_vlutiliz + 
                                                            aux_vlrmaior
                                                            - aux_vlr_maxutl),
                                                            "zzz,zzz,zz9.99")) +
                                               ")Confirma? ".
              
                                   RETURN "OK".
              
                                END.     

                            END.
              
                         IF  par_inconfi2 = 12 AND
                            ((aux_vlutiliz + aux_vlrmaior) > aux_vlr_maxleg)
                             THEN
                             DO:
                                 CREATE tt-msg-confirma.
              
                                 ASSIGN tt-msg-confirma.inconfir = 19
                                        tt-msg-confirma.dsmensag = 
                                        "Vlr(Legal) Excedido" +
                                        "(Utiliz. " +
                                        TRIM(STRING(aux_vlutiliz,
                                        "zzz,zzz,zz9.99")) 
                                        + " Excedido " +
                                        TRIM(STRING((aux_vlutiliz + aux_vlrmaior
                                        - aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                        ") ". 

                                ASSIGN aux_dscritic = "". 
                                       aux_cdcritic = 79.
                                
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                              
                                RETURN "NOK".
              
              
                             END.

                  END.
              
              IF  par_inconfi4 = 71  THEN
                  IF (aux_vlutiliz + aux_vlrmaior) >  aux_vlr_minscr  THEN
                     DO: 
                         CREATE tt-msg-confirma.
              
                         ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                                tt-msg-confirma.dsmensag = 
                                         "Efetue consulta no SCR.".

                         RETURN "OK".
              
                     END.
                 
            END.   

      END.

   IF aux_flsnhcoo THEN
      DO:
          IF par_inconfi6 = 51 THEN
             DO:
                  CREATE tt-msg-confirma.
                  ASSIGN tt-msg-confirma.inconfir = par_inconfi6 + 1.
                  VALIDATE tt-msg-confirma.
                  RETURN "OK".
             END.

      END.
   
   /*  Calculo do juros sobre o desconto do titulo .......................... */
   ASSIGN aux_txdiaria = ROUND((EXP(1 + (crapbdt.txmensal / 100),
                                         1 / 30) - 1),7)
          aux_vlborder = 0
          aux_vlborderbrut = 0
          aux_contamsg = 0
          aux_contareg = 0
          aux_vltotiof = 0.

   FOR EACH crabtdb WHERE crabtdb.cdcooper = par_cdcooper       AND
                          crabtdb.nrborder = crapbdt.nrborder   AND
                          crabtdb.nrdconta = crapbdt.nrdconta 
                          NO-LOCK:
                              
       DO aux_contador = 1 TO 10:

          FIND craptdb WHERE RECID(craptdb) = RECID(crabtdb)
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAILABLE craptdb  THEN
              DO:
                  IF  LOCKED craptdb  THEN
                      DO:
                          ASSIGN aux_cdcritic = 341.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                  ELSE
                      DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Titulo do bordero nao " +
                                                "encontrado.".
                    
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,     /** Sequencia **/
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

          ASSIGN aux_cdcritic = 0.
          
          LEAVE.
          
       END.
       
       IF  aux_cdcritic > 0  THEN
           DO:
               ASSIGN aux_dscritic = "".
                    
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,     /** Sequencia **/
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
          
       ASSIGN aux_qtdprazo = craptdb.dtvencto - par_dtmvtolt
              aux_vltitulo = craptdb.vltitulo
              aux_dtperiod = par_dtmvtolt
              aux_vldjuros = 0
              aux_vljurper = 0.

       DO aux_contador = 1 TO aux_qtdprazo:
   
          ASSIGN aux_vldjuros = ROUND(aux_vltitulo * aux_txdiaria,2)
                 aux_vltitulo = aux_vltitulo + aux_vldjuros
                 aux_dtperiod = aux_dtperiod + 1
                 aux_dtrefjur = ((DATE(MONTH(aux_dtperiod),28,
                                 YEAR(aux_dtperiod)) + 4) -
                                 DAY(DATE(MONTH(aux_dtperiod),28,
                                           YEAR(aux_dtperiod)) + 4)).

          DO aux_contado1 = 1 TO 10: 
            
             FIND crawljt WHERE crawljt.cdcooper = craptdb.cdcooper AND
                                crawljt.nrdconta = craptdb.nrdconta AND
                                crawljt.nrborder = craptdb.nrborder AND
                                crawljt.dtrefere = aux_dtrefjur     AND
                                crawljt.cdbandoc = craptdb.cdbandoc AND
                                crawljt.nrdctabb = craptdb.nrdctabb AND
                                crawljt.nrcnvcob = craptdb.nrcnvcob AND
                                crawljt.nrdocmto = craptdb.nrdocmto
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
             IF   NOT AVAILABLE crawljt   THEN
                  DO:
                      IF   LOCKED crawljt   THEN
                           DO:
                               ASSIGN aux_cdcritic = 341.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               CREATE crawljt.
                               ASSIGN crawljt.cdcooper = craptdb.cdcooper    
                                      crawljt.nrdconta = craptdb.nrdconta    
                                      crawljt.nrborder = craptdb.nrborder    
                                      crawljt.dtrefere = aux_dtrefjur        
                                      crawljt.cdbandoc = craptdb.cdbandoc    
                                      crawljt.nrdctabb = craptdb.nrdctabb    
                                      crawljt.nrcnvcob = craptdb.nrcnvcob    
                                      crawljt.nrdocmto = craptdb.nrdocmto.

                           END.      
                  END.
                  
             ASSIGN aux_cdcritic = 0.
                  
             LEAVE. 
          
          END. /* Fim do DO ... TO */
           
          IF  aux_cdcritic > 0  THEN
              DO:
                  ASSIGN aux_dscritic = "".
                    
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,     /** Sequencia **/
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
                  
          crawljt.vldjuros = crawljt.vldjuros + aux_vldjuros.
          
       END. /* Fim do DO .. TO */
         
       ASSIGN aux_vldjuros     = aux_vltitulo - craptdb.vltitulo
              craptdb.vlliquid = craptdb.vltitulo - aux_vldjuros
              aux_vlborder     = aux_vlborder + craptdb.vlliquid
              aux_vlborderbrut = aux_vlborderbrut + craptdb.vltitulo.

       /* Daniel */
       /* IF par_cddopcao = "L" THEN 
       DO:
         ASSIGN aux_qtdiaiof = craptdb.dtvencto - par_dtmvtolt.

         IF aux_qtdiaiof > 365 THEN
             aux_qtdiaiof = 365.
         
         IF aux_inpessoa = 1 THEN
           /* IOF Operacacao PF */
           aux_periofop = aux_qtdiaiof * 0.0082.
         ELSE
           /* IOF Operacacao PJ */
           aux_periofop = aux_qtdiaiof * 0.0041.

         /* Calculo IOF */
         ASSIGN aux_vliofcal = (craptdb.vlliquid * aux_periofop) / 100.

         /* Acumula Total IOF */
         ASSIGN aux_vltotiof = aux_vltotiof + aux_vliofcal.

       END.  */                         
                          
   END.  /*  Fim do FOR EACH craptdb  */

   /* Analise do bordero */
   IF par_cddopcao = "N"    THEN
      DO TRANSACTION: 

         ASSIGN crapbdt.insitbdt = 2 /*  Analisado  */
                crapbdt.cdopcoan = par_cdopcoan /* Operador Coordenador analise */

                /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                crapbdt.cdopeori = par_cdoperad
                crapbdt.cdageori = par_cdagenci
                crapbdt.dtinsori = TODAY.
                /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */       
         CREATE tt-msg-confirma.

         ASSIGN tt-msg-confirma.inconfir = 88.
                tt-msg-confirma.dsmensag = "Bordero Analisado "  +
                                           IF par_indrestr = 1 THEN 
                                              "COM restricoes. Verifique a opcao Visualizar Titulos."
                                           ELSE "SEM restricoes!".
      END.
   /* Liberacao do bordero */
   ELSE 
      DO:    
         IF par_indrestr = 1  AND
            par_indentra = 1  THEN
            DO:
                IF  par_inconfi3 = 21  THEN
                    DO:
                        CREATE tt-msg-confirma.

                        ASSIGN tt-msg-confirma.inconfir = par_inconfi3 + 1
                               tt-msg-confirma.dsmensag = 
                               "Ha RESTRICOES no bordero, liberar mesmo" +
                               " assim?".

                        RETURN "OK".       

                    END.
            END.
         ELSE
         IF par_indentra = 0   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor maximo por contrato " + 
                                      "excedido. Liberacao NAO " +
                                      "permitida.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
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

         IF aux_vlborder <= 0   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O valor liquido ficou negativo " +
                                      "ou zerado.".
               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
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
/* Daniel
         RUN busca_tarifas_dsctit (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_idorigem,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-tarifas_dsctit).        
      
         IF RETURN-VALUE = "NOK"  THEN
            DO:
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
*/

         RUN busca_tarifa_desconto_titulo(INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT aux_vlborderbrut,
                                          OUTPUT aux_vltarifa,
                                          OUTPUT aux_cdfvlcop,
                                          OUTPUT aux_cdhistor).

         IF RETURN-VALUE = "NOK"  THEN
            DO:
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

         ASSIGN aux_cdcritic = 0
                aux_dscritic = "".

         LIBERACAO:
         DO TRANSACTION ON ENDKEY UNDO LIBERACAO, RETURN "NOK"
                        ON ERROR  UNDO LIBERACAO, RETURN "NOK":
                        
			{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

			/* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
			RUN STORED-PROCEDURE pc_sequence_progress
			aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
												,INPUT "NRSEQDIG"
												,STRING(par_cdcooper) + ";" + STRING(par_dtmvtolt,"99/99/9999") + ";" + STRING(1) + ";100;" + STRING(17000 + aux_cdpactra)
												,INPUT "N"
												,"").

			CLOSE STORED-PROC pc_sequence_progress
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

			{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

			ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
				                       WHEN pc_sequence_progress.pr_sequence <> ?.

            /*  Liberacao do bordero .....................................*/
            DO aux_contador = 1 TO 10:

               FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                  craplot.dtmvtolt = par_dtmvtolt   AND
                                  craplot.cdagenci = 1              AND
                                  craplot.cdbccxlt = 100            AND
                                  /* craplot.nrdolote = 10300 */
                                  craplot.nrdolote = 17000 + aux_cdpactra
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF NOT AVAILABLE craplot   THEN
                  DO:
                      IF LOCKED craplot   THEN
                         DO:                           
                             PAUSE 1 NO-MESSAGE.
                             ASSIGN aux_cdcritic = 341.
                             NEXT.
                         END.
                      ELSE
                         DO:
                             CREATE craplot.

                             ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                    craplot.cdagenci = 1
                                    craplot.cdbccxlt = 100
                                    /* craplot.nrdolote = 10300 */
                                    craplot.nrdolote = 17000 + aux_cdpactra
                                    craplot.tplotmov = 1
                                    craplot.cdoperad = par_cdoperad
                                    craplot.cdhistor = 686
                                    craplot.cdcooper = par_cdcooper.
                         END.       
                  END.
            
               ASSIGN aux_cdcritic = 0.                         
               LEAVE.

            END. /* Fim do DO ... TO */
         
            IF  aux_cdcritic > 0  THEN
                UNDO LIBERACAO, LEAVE.

            RUN sistema/generico/procedures/b1wgen0088.p
                PERSISTENT SET h-b1wgen0088.

            /* Liberacao dos titulos */
            ASSIGN aux_vltotoperac = 0.
            FOR EACH crabtdb WHERE crabtdb.cdcooper = par_cdcooper       AND
                                   crabtdb.nrborder = crapbdt.nrborder   AND
                                   crabtdb.nrdconta = crapbdt.nrdconta
                                   NO-LOCK:
              ASSIGN aux_vltotoperac = aux_vltotoperac + crabtdb.vlliquid.
            END.
                           
            ASSIGN aux_vltotiof = 0
                   aux_vltotiofpri = 0
                   aux_vltotiofadi = 0
                   aux_vltotiofcpl = 0
                   aux_flgimune = 0.
            FOR EACH crabtdb WHERE crabtdb.cdcooper = par_cdcooper       AND
                                   crabtdb.nrborder = crapbdt.nrborder   AND
                                   crabtdb.nrdconta = crapbdt.nrdconta
                                   NO-LOCK:
                           
                DO aux_contador = 1 TO 10:

                   FIND craptdb WHERE RECID(craptdb) = RECID(crabtdb)
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF NOT AVAILABLE craptdb  THEN
                      DO:
                          IF LOCKED craptdb  THEN
                             DO:
                                 ASSIGN aux_cdcritic = 341.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                          ELSE
                             DO:
                                 ASSIGN aux_cdcritic = 0
                                        aux_dscritic = 
                                            "Titulo do bordero nao " +
                                            "encontrado.".
                                 UNDO LIBERACAO, LEAVE.
                             END.
                      END.

                   ASSIGN aux_cdcritic = 0.
                   LEAVE. 

                END.
      
                IF aux_cdcritic > 0  THEN
                   UNDO LIBERACAO, LEAVE.

                IF par_idorigem = 1   THEN
                   DO:  
                       ASSIGN aux_contamsg = aux_contamsg + 1
                              aux_contareg = aux_contareg + 1.
                         
                       IF aux_contamsg > 10   THEN
                          DO:
                              HIDE MESSAGE NO-PAUSE.
                              MESSAGE "Liberando registro"
                                      aux_contareg "...".
                              ASSIGN aux_contamsg = 0.

                          END.

                   END.
                
                /* Titulo Liberado */
                ASSIGN craptdb.dtlibbdt = par_dtmvtolt
                       craptdb.insittit = 4.

                FIND FIRST crapcob 
                     WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdocmto = craptdb.nrdocmto AND
                           crapcob.flgregis = TRUE
                           NO-LOCK NO-ERROR.

                IF AVAIL crapcob THEN
                   DO:
                       RUN cria-log-cobranca IN h-b1wgen0088 
                           (INPUT ROWID(crapcob),
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT 'Titulo Descontado - Bordero ' + 
                                   STRING(crapbdt.nrborder)).
                   END.

                /* Projeto 410 - Novo IOF */
                ASSIGN aux_qtdiaiof = crabtdb.dtvencto - par_dtmvtolt.
                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                RUN STORED-PROCEDURE pc_calcula_valor_iof_prg
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT 2                      /* Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante) */
                                                    ,INPUT 1                      /* Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso) */
                                                    ,INPUT crabtdb.cdcooper       /* Código da cooperativa */
                                                    ,INPUT crabtdb.nrdconta       /* Número da conta */
                                                    ,INPUT aux_inpessoa           /* Tipo de Pessoa */
                                                    ,INPUT aux_natjurid           /* Natureza Juridica */
                                                    ,INPUT aux_tpregtrb           /* Tipo de Regime Tributario */
                                                    ,INPUT par_dtmvtolt           /* Data do movimento para busca na tabela de IOF */
                                                    ,INPUT aux_qtdiaiof           /* Qde dias em atraso (cálculo IOF atraso) */
                                                    ,INPUT crabtdb.vlliquid       /* Valor liquido da operaçao */
                                                    ,INPUT aux_vltotoperac        /* Valor total da operaçao */
                                                    ,INPUT "0"                    /* Valor da taxa de IOF complementar */
                                                    ,OUTPUT 0                     /* Retorno do valor do IOF principal */
                                                    ,OUTPUT 0                     /* Retorno do valor do IOF adicional */
                                                    ,OUTPUT 0                     /* Retorno do valor do IOF complementar */
                                                    ,OUTPUT ""                     /* Valor da taxa de IOF principal */
                                                    ,OUTPUT ?                      /* Flag da imunidade */
                                                    ,OUTPUT "").                  /* Critica */
                                                    
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_calcula_valor_iof_prg
                
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                /* Se retornou erro */
                ASSIGN aux_dscritic = ""
                       aux_dscritic = pc_calcula_valor_iof_prg.pr_dscritic WHEN pc_calcula_valor_iof_prg.pr_dscritic <> ?.
                IF aux_dscritic <> "" THEN
                  UNDO LIBERACAO, LEAVE.
                /* Soma IOF principal */
                IF pc_calcula_valor_iof_prg.pr_vliofpri <> ? THEN
                  DO:
                    ASSIGN aux_vltotiofpri = aux_vltotiofpri + ROUND(DECI(pc_calcula_valor_iof_prg.pr_vliofpri),2).
                  END.
                /* Soma IOF adicional */
                IF pc_calcula_valor_iof_prg.pr_vliofadi <> ? THEN
                  DO:
                    ASSIGN aux_vltotiofadi = aux_vltotiofadi + ROUND(DECI(pc_calcula_valor_iof_prg.pr_vliofadi),2).
                  END.
                /* Soma IOF complementar */
                IF pc_calcula_valor_iof_prg.pr_vliofcpl <> ? THEN
                  DO:
                    ASSIGN aux_vltotiofcpl = aux_vltotiofcpl + ROUND(DECI(pc_calcula_valor_iof_prg.pr_vliofcpl),2).
                  END.
                /* Valor da taxa de IOF principal */
                IF pc_calcula_valor_iof_prg.pr_vltaxa_iof_principal <> "" THEN
                  DO:
                    ASSIGN aux_vltxiofatraso = DECI(pc_calcula_valor_iof_prg.pr_vltaxa_iof_principal).
                  END.                  
                IF pc_calcula_valor_iof_prg.pr_flgimune <> ? THEN
                  DO:
                    ASSIGN aux_flgimune = pc_calcula_valor_iof_prg.pr_flgimune.
                  END.
            END.  /*  Fim do FOR EACH craptdb  */
            ASSIGN aux_vltotiof = aux_vltotiofpri + aux_vltotiofadi.

            IF VALID-HANDLE(h-b1wgen0088) THEN
               DELETE PROCEDURE h-b1wgen0088.

            IF aux_vltarifa /* tt-tarifas_dsctit.vltarbdt */ > 0  THEN
               DO:
                   /* Gera a tarifa de bordero */ /*
                   DO aux_contador = 1 TO 10:

                      FIND crablot WHERE
                           crablot.cdcooper = par_cdcooper  AND 
                           crablot.dtmvtolt = par_dtmvtolt  AND
                           crablot.cdagenci = 1             AND
                           crablot.cdbccxlt = 100           AND
                           /* crablot.nrdolote = 8452 */
                           crablot.nrdolote = 19000 + aux_cdpactra
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                      IF NOT AVAILABLE crablot   THEN
                         IF LOCKED crablot   THEN
                            DO:
                                ASSIGN aux_cdcritic = 341.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.

                            END.
                         ELSE
                            DO:                           
                                CREATE crablot.

                                ASSIGN crablot.dtmvtolt = par_dtmvtolt
                                       crablot.cdagenci = 1
                                       crablot.cdbccxlt = 100
                                       /* crablot.nrdolote = 8452 */
                                       crablot.nrdolote = 19000 + aux_cdpactra
                                       crablot.tplotmov = 1
                                       crablot.cdoperad = par_cdoperad
                                       crablot.cdhistor = 594
                                       crablot.cdcooper = par_cdcooper.
                            END.
                      ELSE
                         ASSIGN aux_cdcritic = 0.
                    
                      LEAVE.

                   END.   /*  Fim do DO .. TO  */
         
                   IF aux_cdcritic > 0   THEN
                      UNDO LIBERACAO, LEAVE.

                   CREATE craplcm.
                   ASSIGN craplcm.dtmvtolt = crablot.dtmvtolt
                          craplcm.cdagenci = crablot.cdagenci
                          craplcm.cdbccxlt = crablot.cdbccxlt
                          craplcm.nrdolote = crablot.nrdolote
                          craplcm.nrdconta = crapbdt.nrdconta
                          craplcm.nrdctabb = crapbdt.nrdconta
                          craplcm.nrdctitg = STRING(crapbdt.nrdconta,
                                                    "99999999")
                          craplcm.nrdocmto = crablot.nrseqdig + 1
                          craplcm.cdhistor = 594
                          craplcm.nrseqdig = crablot.nrseqdig + 1
                          craplcm.vllanmto = tt-tarifas_dsctit.vltarbdt
                          craplcm.cdcooper = par_cdcooper
                
                          crablot.vlinfodb = crablot.vlinfodb + 
                                                 craplcm.vllanmto
                          crablot.vlcompdb = crablot.vlcompdb + 
                                                 craplcm.vllanmto
                          crablot.qtinfoln = crablot.qtinfoln + 1
                          crablot.qtcompln = crablot.qtcompln + 1
                          crablot.nrseqdig = crablot.nrseqdig + 1.  */

                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

                    /* Efetuar a chamada a rotina Oracle */
                    RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper         /* Cooperativa */
                                                        ,INPUT "1"                  /* Operador */
                                                        ,INPUT 1                    /* PA */ 
                                                        ,INPUT 100                  /* Banco */
                                                        ,INPUT par_dtmvtolt         /* Data de movimento */
                                                        ,INPUT "b1wgen0030"         /* Cód. programa */
                                                        ,INPUT 1                    /* Id. Origem*/
                                                        ,INPUT crapbdt.nrdconta     /* Nr. da conta */
                                                        ,INPUT 16                   /* Tipo de tarifa */
                                                        ,INPUT 0                    /* Tipo TAA */
                                                        ,INPUT 1                    /* Quantidade de operacoes */
														,INPUT 0			/* numero documento - adicionado por Valeria Supero outubro 2018 */ 
														,INPUT 0			/* hora de realização da operação -adicionado por Valeria Supero */
                                                        ,OUTPUT 0                   /* Quantidade de operações a serem cobradas */
                                                        ,OUTPUT 0                   /* Indicador de isencao de tarifa (0 - nao isenta, 1 - isenta) */
                                                        ,OUTPUT 0    /* Código da crítica */
                                                        ,OUTPUT "").  /* Descrição da crítica */
                    
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_verifica_tarifa_operacao
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                    
                    ASSIGN aux_qtacobra = 0
                           aux_fliseope = 0
                           aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_qtacobra = pc_verifica_tarifa_operacao.pr_qtacobra
                                          WHEN pc_verifica_tarifa_operacao.pr_qtacobra <> ?
                           aux_fliseope = pc_verifica_tarifa_operacao.pr_fliseope
                                          WHEN pc_verifica_tarifa_operacao.pr_fliseope <> ?
                           aux_cdcritic = pc_verifica_tarifa_operacao.pr_cdcritic
                                          WHEN pc_verifica_tarifa_operacao.pr_cdcritic <> ?
                           aux_dscritic = pc_verifica_tarifa_operacao.pr_dscritic
                                          WHEN pc_verifica_tarifa_operacao.pr_dscritic <> ?.
                    
                    /* Se retornou erro */
                    IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN          
                        UNDO LIBERACAO, LEAVE.

                    /* Se não isenta cobranca de tarifa */
                    IF  aux_fliseope <> 1 THEN
                        DO: 

                    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
    
                    RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                   (INPUT par_cdcooper,
                                    INPUT crapbdt.nrdconta,            
                                    INPUT par_dtmvtolt,
                                    INPUT aux_cdhistor, 
                                    INPUT aux_vltarifa,
                                    INPUT par_cdcooper,                                      /* cdoperad */
                                    INPUT 1,                                                 /* cdagenci */
                                    INPUT 100,                                               /* cdbccxlt */         
                                    INPUT 19000 + aux_cdpactra,                              /* nrdolote */        
                                    INPUT 1,                                                 /* tpdolote */         
                                    INPUT 0 ,                                                /* nrdocmto */
                                    INPUT crapbdt.nrdconta,                                  /* nrdconta */
                                    INPUT STRING(crapbdt.nrdconta,"99999999"),               /* nrdctitg */
                                    INPUT "Fato gerador tarifa:" + STRING(crapbdt.nrborder), /* cdpesqbb */
                                    INPUT 0,                                                 /* cdbanchq */
                                    INPUT 0,                                                 /* cdagechq */
                                    INPUT 0,                                                 /* nrctachq */
                                    INPUT FALSE,                                             /* flgaviso */
                                    INPUT 0,                                                 /* tpdaviso */
                                    INPUT aux_cdfvlcop,                                      /* cdfvlcop */
                                    INPUT par_inproces,                                      /* inproces */
                                    OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                           IF AVAIL tt-erro THEN 
                           DO: /* VERIFICAR UNDO */
                               IF tt-erro.dscritic <> ""   THEN
                                  UNDO LIBERACAO, LEAVE.
                           END.
                        END.
        
                    IF  VALID-HANDLE(h-b1wgen0153)  THEN
                        DELETE PROCEDURE h-b1wgen0153.

               END.
               END.

            /* Cria lancamento da conta do associado */
            /* credito de desconto de titulos */
            CREATE craplcm.
            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt 
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrdconta = crapbdt.nrdconta
                   craplcm.nrdocmto = craplot.nrseqdig + 1
                   craplcm.vllanmto = aux_vlborder
                   craplcm.cdhistor = 686
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   craplcm.nrdctabb = crapbdt.nrdconta 

                   craplcm.nrautdoc = 0
                   craplcm.cdcooper = par_cdcooper

                   craplcm.cdpesqbb = "Desconto do bordero " +
                                       STRING(crapbdt.nrborder,"zzz,zz9")

                   craplot.nrseqdig = craplcm.nrseqdig
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1

                   craplot.vlinfocr = craplot.vlinfocr +
                                      craplcm.vllanmto
                   craplot.vlcompcr = craplot.vlcompcr +
                                      craplcm.vllanmto.

                            
            VALIDATE craplot.
            VALIDATE craplcm.

            /* RUN buscar_valor_iof_simples_nacional(INPUT aux_vlborder,
                                                  INPUT par_cdcooper,
                                                  INPUT par_nrdconta,
                                                  INPUT TABLE tt-iof,
                                                  INPUT TABLE tt-iof-sn,
                                                  OUTPUT aux_vltotaliofsn).
            aux_vltotiof = aux_vltotiof + aux_vltotaliofsn. */
            RUN sistema/generico/procedures/b1wgen0159.p
                            PERSISTENT SET h-b1wgen0159.

            RUN verifica-imunidade-tributaria IN h-b1wgen0159(
                                                 INPUT par_cdcooper,
                                                 INPUT crapbdt.nrdconta,
                                                 INPUT par_dtmvtolt,
                                                 INPUT TRUE,
                                                 INPUT 2,
                                                 INPUT tt-iof.txccdiof,
                                                OUTPUT aux_flgimune,
                                                OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h-b1wgen0159.

            /*  Cobranca do IOF de desconto  */
            IF  aux_vltotiof > 0 THEN         
               DO:
                   DO aux_contador = 1 TO 10:
                      FIND craplot WHERE
                           craplot.cdcooper = par_cdcooper   AND
                           craplot.dtmvtolt = par_dtmvtolt   AND
                           craplot.cdagenci = 1              AND
                           craplot.cdbccxlt = 100            AND
                           /* craplot.nrdolote = 8461 */
                           craplot.nrdolote = 18000 + aux_cdpactra
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE craplot   THEN
                         IF LOCKED craplot   THEN
                            DO:
                               ASSIGN aux_dscritic = "Registro de lote para " +
                                                     "IOF esta em uso. " +
                                                     "Tente novamente.".
                               PAUSE 1 NO-MESSAGE.
                               NEXT.

                            END.
                         ELSE
                            DO:
                                CREATE craplot.

                                ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                       craplot.cdagenci = 1
                                       craplot.cdbccxlt = 100
                                       /* craplot.nrdolote = 8461 */
                                       craplot.nrdolote = 18000 + aux_cdpactra
                                       craplot.tplotmov = 1
                                       craplot.cdcooper = par_cdcooper.
                            END.

                      ASSIGN aux_dscritic = "".                            
                      LEAVE. 

                   END.  /*  Fim do DO .. TO  */
                                  
                   IF aux_dscritic <> ""   THEN
                      UNDO LIBERACAO, LEAVE.
                
                   CREATE craplcm.
                   ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                          craplcm.cdagenci = craplot.cdagenci
                          craplcm.cdbccxlt = craplot.cdbccxlt
                          craplcm.nrdolote = craplot.nrdolote
                          craplcm.nrdconta = crapbdt.nrdconta
                          craplcm.nrdctabb = crapbdt.nrdconta
                          craplcm.nrdctitg = STRING(crapbdt.nrdconta,
                                                    "99999999")
                          craplcm.nrdocmto = craplot.nrseqdig + 1
                          /* craplcm.cdhistor = 688 */
                          craplcm.cdhistor = 2320 /* Novo histórico - projeto 410 */

                          craplcm.nrseqdig = craplot.nrseqdig + 1
                          craplcm.cdpesqbb = "Bordero " +
                                             STRING(crapbdt.nrborder)
                                             + " - " +
                                             STRING(aux_vlborder,
                                                    "999,999,999.99")
                          /* craplcm.vllanmto = ROUND( ( ROUND(aux_vlborder * tt-iof.txccdiof,2) + aux_vltotiof ) , 2 ) */
                          craplcm.vllanmto = ROUND(aux_vltotiof, 2)
                          craplcm.cdcooper = par_cdcooper
                          craplot.vlinfodb = craplot.vlinfodb + 
                                                     craplcm.vllanmto
                          craplot.vlcompdb = craplot.vlcompdb + 
                                                     craplcm.vllanmto
                          craplot.qtinfoln = craplot.qtinfoln + 1
                          craplot.qtcompln = craplot.qtcompln + 1
                          craplot.nrseqdig = craplot.nrseqdig + 1.
                     
                   VALIDATE craplot.
                   VALIDATE craplcm.

                  /* Projeto 410 - Novo IOF */
                  ASSIGN aux_dscritic = "".
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                  RUN STORED-PROCEDURE pc_insere_iof                  
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper           /* Codigo da Cooperativa */ 
                                                      ,INPUT crapbdt.nrdconta       /* Numero da Conta Corrente */
                                                      ,INPUT par_dtmvtolt           /* Data de Movimento */
                                                      ,INPUT 2                      /* Tipo de Produto */
                                                      ,INPUT crapbdt.nrborder       /* Numero do Contrato */
                                                      ,INPUT ?                   /* Chave: Id dos Lancamentos Futuros */
                                                      ,INPUT craplot.dtmvtolt       /* Chave: Data de Movimento Lancamento */
                                                      ,INPUT craplot.cdagenci       /* Chave: Agencia do Lancamento */
                                                      ,INPUT craplot.cdbccxlt       /* Chave: Caixa do Lancamento */
                                                      ,INPUT craplot.nrdolote       /* Chave: Lote do Lancamento */
                                                      ,INPUT craplot.nrseqdig       /* Chave: Sequencia do Lancamento */
                                                      ,INPUT ROUND(aux_vltotiofpri, 2)  /* Valor do IOF Principal */
                                                      ,INPUT ROUND(aux_vltotiofadi, 2)  /* Valor do IOF Adicional */
                                                      ,INPUT ROUND(aux_vltotiofcpl, 2)  /* Valor do IOF Complementar */
                                                      ,INPUT aux_flgimune           /* Flag da imunidade */   
                                                      ,OUTPUT 0                     /* Código da Crítica */
                                                      ,OUTPUT "").
                  /* Fechar o procedimento para buscarmos o resultado */ 
                  CLOSE STORED-PROC pc_insere_iof
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                  /* Se retornou erro */
                  ASSIGN aux_dscritic = ""
                         aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
                  IF  aux_dscritic <> "" THEN          
                    UNDO LIBERACAO, LEAVE.
                   /* Atualiza IOF pago e base de calculo no crapcot */
                   DO aux_contador = 1 TO 10:
     
                      FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                                         crapcot.nrdconta = crapbdt.nrdconta 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crapcot   THEN
                         IF LOCKED crapcot   THEN
                            DO:
                               ASSIGN aux_dscritic = "Registro de cotas "     +
                                                     "para IOF esta em uso. " +
                                                     "Tente novamente.".
                               PAUSE 1 NO-MESSAGE.
                               NEXT.

                            END.
                         ELSE
                            DO:
                                ASSIGN aux_dscritic = "Registro crapcot nao " +
                                                      "encontrado.".

                                UNDO LIBERACAO, LEAVE.

                            END.
                    
                      ASSIGN aux_dscritic = "".
                      LEAVE.

                   END.  /*  Fim do DO .. TO  */

                   IF aux_dscritic <> ""   THEN
                      UNDO LIBERACAO, LEAVE.
                
                   ASSIGN crapcot.vliofapl = crapcot.vliofapl +
                                             craplcm.vllanmto
                          crapcot.vlbsiapl = crapcot.vlbsiapl + 
                                             aux_vlborder.
               END.
          
            ASSIGN crapbdt.insitbdt = 3 /*  Liberado  */
                   crapbdt.dtlibbdt = par_dtmvtolt
                   crapbdt.cdopelib = par_cdoperad
                   crapbdt.cdopcolb = par_cdopcolb /* Operador Coordenador liberacao */

                   /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                   crapbdt.cdopeori = par_cdoperad
                   crapbdt.cdageori = par_cdagenci
                   crapbdt.dtinsori = TODAY
                   crapbdt.vltaxiof = aux_vltxiofatraso.
                   /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */            

            /* 
                Criar os juros para os titulos somente depois de todas as 
                transacoes necessarias
            */
            FOR EACH crawljt WHERE crawljt.cdcooper = par_cdcooper 
                                   EXCLUSIVE-LOCK:
             
                CREATE crapljt.
                BUFFER-COPY crawljt TO crapljt.
                VALIDATE crapljt.

                DELETE crawljt.    

            END.  /*  Fim do FOR EACH crawljt  */       
            
            CREATE tt-msg-confirma.

            ASSIGN tt-msg-confirma.inconfir = 88
                   tt-msg-confirma.dsmensag = "Bordero liberado " +
                                              (IF par_indrestr = 1 THEN
                                                  "COM restricoes!"
                                               ELSE "SEM restricoes!") 
                                               + " Valor liquido de R$ "  +
                                               TRIM(STRING(aux_vlborder,
                                                        "zzz,zzz,zz9.99")).


         END. /* Fim da transacao LIBERACAO */
      
      END. /* Fim do IF da liberacao */
        
   FIND CURRENT crapbdt NO-LOCK.  

   RELEASE crapbdt.
   RELEASE craplot.
   RELEASE craplcm.
   RELEASE craptdb.
   RELEASE crapljt.
   RELEASE crapabt.

   /* Houve erro */
   IF  aux_cdcritic > 0  OR
       aux_dscritic <> "" THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,     /** Sequencia **/
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
   ELSE
   /* Operacao efetuada com sucesso */
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

/****************************************************************************/
/*                             Excluir bordero                              */
/****************************************************************************/
PROCEDURE efetua_exclusao_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgelote AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nrdocmto AS INTE NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_contado2 AS INTE NO-UNDO.
    DEF VAR aux_flgderro AS LOGI NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Excluir bordero " + STRING(par_nrborder) +
                              " de desconto de titulo.".
           
    TRANS_EXCLUSAO:
    DO TRANSACTION ON ERROR UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO:
    
        DO aux_contador = 1 TO 10:
         
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper   AND
                               crapbdt.nrborder = par_nrborder 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                IF  LOCKED crapbdt   THEN
                    DO:
                        ASSIGN aux_dscritic = "Registro de bordero em uso. " +
                                              "Tente novamente.".
                               aux_cdcritic = 0.                    
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Registro de bordero nao " +
                                              "encontrado."
                               aux_cdcritic = 0.
                        LEAVE.
                     END.
                  
            IF  crapbdt.insitbdt > 2  THEN 
                DO:
                    ASSIGN aux_dscritic = "Bordero ja LIBERADO."
                           aux_cdcritic = 0.
                    LEAVE.
                END.

            aux_dscritic = "".
            LEAVE.

        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.

            END.

        /*  Exclusao dos titulos do bordero .............................. */
        FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper      AND 
                               craptdb.nrborder = crapbdt.nrborder  AND
                               craptdb.nrdconta = crapbdt.nrdconta  
                               EXCLUSIVE-LOCK:
                                    
            DELETE craptdb.                   
                       
        END.  /*  Fim do FOR EACH craptdb  */

        /*  Exclusao das restricoes dos titulos do bordero ............... */
        FOR EACH crapabt WHERE crapabt.cdcooper = par_cdcooper      AND
                               crapabt.nrborder = crapbdt.nrborder  
                               EXCLUSIVE-LOCK:

            DELETE crapabt.

        END.  /*  Fim do FOR EACH crapabt  */

        IF  par_flgelote  THEN
            DO:
                DO  aux_contador = 1 TO 10:
    
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND
                                       craplot.dtmvtolt = crapbdt.dtmvtolt AND
                                       craplot.cdagenci = crapbdt.cdagenci AND
                                       craplot.cdbccxlt = crapbdt.cdbccxlt AND
                                       craplot.nrdolote = crapbdt.nrdolote
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                    IF  NOT AVAILABLE craplot   THEN
                        DO:
                            IF  LOCKED craplot   THEN
                                DO:
                                    ASSIGN aux_dscritic = "Registro de lote " +
                                                          "esta em uso. " +
                                                          "Tente novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_dscritic = "Registro de lote " +
                                                          "nao encontrado.".
                                    LEAVE.
                                END.
                        END.

                    aux_dscritic = "".
                    LEAVE.

                END.
                
                IF  aux_dscritic <> ""  THEN
                    DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1, /* Sequencia */
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                       
                        ASSIGN aux_flgderro = TRUE.
                        
                        UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
   
                    END.
                
                DELETE craplot.
               
            END.
                
        /* Exclui o bordero */
        DELETE crapbdt.
    
    END. /* Final da transacao */
    
    IF  aux_flgderro  THEN
        DO:
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

/****************************************************************************/
/*                  Buscar limites de uma conta informada                   */
/****************************************************************************/
PROCEDURE busca_limites:

    DEF INPUT PARAM par_cdcooper AS INTE        NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-limite_tit.

    DEF VAR aux_dssitmnt AS CHAR   NO-UNDO.

    EMPTY TEMP-TABLE tt-limite_tit.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper  AND
                           craplim.nrdconta = par_nrdconta  AND
                           craplim.tpctrlim = 3             NO-LOCK:

        FIND crapprp WHERE crapprp.cdcooper = craplim.cdcooper   AND
                           crapprp.nrdconta = craplim.nrdconta   AND
                           crapprp.tpctrato = craplim.tpctrlim   AND
                           crapprp.nrctrato = craplim.nrctrlim
                           NO-LOCK NO-ERROR.
						   
        FIND crawlim WHERE (crawlim.cdcooper = craplim.cdcooper   AND
                            crawlim.nrdconta = craplim.nrdconta   AND
                            crawlim.tpctrlim = craplim.tpctrlim   AND
                            crawlim.nrctrmnt = craplim.nrctrlim   AND
                            crawlim.insitlim = 1 /*em estudo*/ )
                           OR
                           (crawlim.cdcooper = craplim.cdcooper   AND
                            crawlim.nrdconta = craplim.nrdconta   AND
                            crawlim.tpctrlim = craplim.tpctrlim   AND
                            crawlim.nrctrmnt = craplim.nrctrlim   AND
                            crawlim.insitlim = 5 /*aprovada*/ )
                           OR
                           (crawlim.cdcooper = craplim.cdcooper   AND
                            crawlim.nrdconta = craplim.nrdconta   AND
                            crawlim.tpctrlim = craplim.tpctrlim   AND
                            crawlim.nrctrmnt = craplim.nrctrlim   AND
                            crawlim.insitlim = 6 /*não aprovada*/ )
                           OR /*438*/
                           (crawlim.cdcooper = craplim.cdcooper   AND
                            crawlim.nrdconta = craplim.nrdconta   AND
                            crawlim.tpctrlim = craplim.tpctrlim   AND
                            crawlim.nrctrmnt = craplim.nrctrlim   AND
                            crawlim.insitlim = 8 /*438 - Expirada decurso de prazo*/ )                            
                           OR /*438*/
                           (crawlim.cdcooper = craplim.cdcooper   AND
                            crawlim.nrdconta = craplim.nrdconta   AND
                            crawlim.tpctrlim = craplim.tpctrlim   AND
                            crawlim.nrctrmnt = craplim.nrctrlim   AND
                            crawlim.insitlim = 9 /*438 - Anulada - Paulo Martins (Mouts)*/ )                                
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crawlim  THEN
            ASSIGN aux_dssitmnt = "MAJORAÇÃO SOLICITADA".
        ELSE
            ASSIGN aux_dssitmnt = "ATIVO".
			

        CREATE tt-limite_tit.
        ASSIGN tt-limite_tit.dtpropos = craplim.dtpropos
               tt-limite_tit.dtinivig = craplim.dtinivig
               tt-limite_tit.nrctrlim = craplim.nrctrlim
               tt-limite_tit.vllimite = craplim.vllimite
               tt-limite_tit.qtdiavig = craplim.qtdiavig
               tt-limite_tit.cddlinha = craplim.cddlinha
               tt-limite_tit.tpctrlim = craplim.tpctrlim
               tt-limite_tit.dssitlim = (IF craplim.insitlim = 1 THEN               /*Situacao do Limite*/
                                            "EM ESTUDO"
                                         ELSE 
                                         IF craplim.insitlim = 2 THEN
                                            aux_dssitmnt
                                         ELSE
                                         IF craplim.insitlim = 3 THEN
                                            "CANCELADO"
                                         ELSE
                                         IF craplim.insitlim = 4 THEN
                                            "VIGENTE"
                                         ELSE 
                                         IF craplim.insitlim = 5 THEN
                                            "APROVADO"
                                         ELSE
                                         IF craplim.insitlim = 6 THEN
                                            "NAO APROVADO"
                                         ELSE
                                         IF craplim.insitlim = 7 THEN
                                            "REJEITADO"
                                         ELSE 
                                            "DIFERENTE")
               tt-limite_tit.flgenvio = IF   AVAIL crapprp   THEN
                                             IF   crapprp.flgenvio   THEN
                                                  "SIM"
                                             ELSE
                                                  "NAO"
                                        ELSE
                                             "NAO"
               tt-limite_tit.insitlim = craplim.insitlim.

    END.  /*  Fim da leitura do craplim  */
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "C" */
/****************************************************************************/
PROCEDURE busca_dados_limite_consulta:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.
    
    RUN busca_dados_limite (INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "C",
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dsctit_dados_limite,
                            OUTPUT TABLE tt-dados_dsctit).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-dsctit_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de limite nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".            
        END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.                                     

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".

        END.
        
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 8, /** Tipo do contrato **/
                                         INPUT par_nrctrlim,    
                                         INPUT tt-dsctit_dados_limite.nrctaav1,
                                         INPUT tt-dsctit_dados_limite.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).      
                                          
    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/*******************************************************************/
/*    Buscar dados de uma proposta limite de desconto de titulos   */
/*******************************************************************/
PROCEDURE busca_dados_proposta_consulta:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.
    
    RUN busca_dados_proposta(INPUT par_cdcooper,
                             INPUT par_cdagenci, 
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT par_idorigem,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,  
                             INPUT par_nmdatela,
                             INPUT par_nrctrlim,
                             INPUT "C",
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dsctit_dados_limite,
                             OUTPUT TABLE tt-dados_dsctit).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-dsctit_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados da proposta nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".            
        END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.                                     

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".

        END.
        
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 8, /** Tipo do contrato **/
                                         INPUT par_nrctrlim,    
                                         INPUT tt-dsctit_dados_limite.nrctaav1,
                                         INPUT tt-dsctit_dados_limite.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).      
                                          
    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "A" */
/****************************************************************************/
PROCEDURE busca_dados_limite_altera:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-risco.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-dados_dsctit.

    DEF VAR aux_dsoperac AS CHAR   NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.


    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
               
           RETURN "NOK".        

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de "  + 
                          "descontos de titulos na conta "                 +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 6, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.


    RUN busca_dados_proposta (INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "A",
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dsctit_dados_limite,
                            OUTPUT TABLE tt-dados_dsctit).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-dsctit_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de limite nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.                                     

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".

        END.
        
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 8, /** Tipo do contrato **/
                                         INPUT par_nrctrlim,    
                                         INPUT tt-dsctit_dados_limite.nrctaav1,
                                         INPUT tt-dsctit_dados_limite.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).        
    
    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    RUN busca_dados_risco (INPUT par_cdcooper,
                          OUTPUT TABLE tt-risco).    
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*    Buscar dados de um limite de desconto de titulos COMPLETO - opcao "I" */
/****************************************************************************/
PROCEDURE busca_dados_limite_incluir:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_inconfir AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-risco.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.

    DEF VAR aux_regalias         AS CHAR                    NO-UNDO.
    DEF VAR h-b1wgen0001         AS HANDLE                  NO-UNDO.
    DEF VAR h-b1wgen0058         AS HANDLE                  NO-UNDO.
    DEF VAR h-b1wgen0110         AS HANDLE                  NO-UNDO.
    DEF VAR h-b1wgen9999         AS HANDLE                  NO-UNDO.
    DEF VAR aux_nrdeanos         AS INTE                    NO-UNDO.
    DEF VAR aux_nrdmeses         AS INTE                    NO-UNDO.
    DEF VAR aux_dsdidade         AS CHAR                    NO-UNDO.
    DEF VAR aux_dsoperac         AS CHAR                    NO-UNDO.
    DEF VAR aux_nriniseq 	       AS INTE					          NO-UNDO.
	  DEF VAR aux_flgrestrito      AS INTE                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    EMPTY TEMP-TABLE tt-msg-confirma.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    RUN sistema/generico/procedures/b1wgen0001.p 
        PERSISTENT SET h-b1wgen0001.
        
    IF  VALID-HANDLE(h-b1wgen0001)   THEN
    DO:
        RUN ver_cadastro IN h-b1wgen0001(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 0, /* cod-agencia */
                                         INPUT 0, /* nro-caixa   */
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro).


        IF  RETURN-VALUE = "NOK"  THEN
        DO:                               
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.
        
        DELETE PROCEDURE h-b1wgen0001.
    END.

    RUN lista-linhas-desc-tit (INPUT par_cdcooper,
							   INPUT par_cdagenci, 
							   INPUT par_nrdcaixa, 
							   INPUT par_cdoperad,
							   INPUT par_dtmvtolt,
							   INPUT par_nrdconta,
							   INPUT 0,
							   INPUT 999,
							   INPUT 0,
							  OUTPUT aux_nriniseq,
							  OUTPUT TABLE tt-linhas_desc).

    IF  RETURN-VALUE = "NOK" THEN
	    DO:
		   ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Habilite o produto Cobranca para incluir um limite.".

		   RUN gera_erro (INPUT par_cdcooper,
						  INPUT par_cdagenci,
					      INPUT par_nrdcaixa,
					      INPUT 1,            /** Sequencia **/
					      INPUT aux_cdcritic,
					      INPUT-OUTPUT aux_dscritic).
			
		   RETURN "NOK".
	    END.

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE,
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-dados_dsctit,
                                OUTPUT TABLE tt-dados_cecred_dsctit).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.           
            
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    
		/*Se tem cnae verificar se e um cnae restrito*/
		IF  crapass.cdclcnae > 0 THEN
			DO:

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Busca a se o CNAE eh restrito */
                RUN STORED-PROCEDURE pc_valida_cnae_restrito
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.cdclcnae
                                                    ,0).

                CLOSE STORED-PROC pc_valida_cnae_restrito
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_flgrestrito = INTE(pc_valida_cnae_restrito.pr_flgrestrito)
                                            WHEN pc_valida_cnae_restrito.pr_flgrestrito <> ?.

				IF  aux_flgrestrito = 1 THEN
					DO:
    						CREATE tt-msg-confirma.
							ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
								   tt-msg-confirma.dsmensag = "CNAE restrito, conforme previsto na Política de Responsabilidade <br> Socioambiental do Sistema AILOS. Necessário apresentar Licença Regulatória.<br><br>Deseja continuar?".
        END.
    
			END.

        /* rotina para buscar o crapttl.inhabmen */
    FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                             crapttl.nrdconta = par_nrdconta   AND
                             crapttl.idseqttl = 1
                             NO-LOCK NO-ERROR.
    IF  AVAIL crapttl THEN
        DO:
                  
            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                RUN sistema/generico/procedures/b1wgen9999.p 
                    PERSISTENT SET h-b1wgen9999.
           
            /*  Rotina que retorna a idade do cooperado */
            RUN idade IN h-b1wgen9999(INPUT crapttl.dtnasttl,
                                      INPUT par_dtmvtolt,
                                      OUTPUT aux_nrdeanos,
                                      OUTPUT aux_nrdmeses,
                                      OUTPUT aux_dsdidade).
           
            IF  VALID-HANDLE(h-b1wgen9999) THEN
                DELETE PROCEDURE h-b1wgen9999.
           
            IF  par_inconfir = 1     AND
                aux_nrdeanos >= 16   AND 
                aux_nrdeanos <  18   AND 
                crapttl.inhabmen = 0 THEN 
                DO:
                    CREATE tt-msg-confirma.                    
                    ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
                           tt-msg-confirma.dsmensag = "Atencao! Cooperado menor de idade. Deseja continuar?".

                    RETURN "OK".
                END.
              
            IF  aux_nrdeanos < 16 THEN 
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Cooperado menor de idade, nao e " +
                                         "possivel realizar a operacao.".
           
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,            /** Sequencia **/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
                   
                       RETURN "NOK".
                   
                END.
        END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
          PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de incluir novo limite de descontos de " +
                          "titulos na conta "                                 +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")               +
                          " - CPF/CNPJ "                                      +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc, 
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 7, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
       
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "LIBPRAZEMP" AND
                       craptab.tpregist = 001          
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptab  THEN
        ASSIGN aux_regalias = craptab.dstextab.
                            
    IF  tt-dados_dsctit.qtminfil > 
        (par_dtmvtolt - crapass.dtmvtolt)                 AND
        NOT CAN-DO(aux_regalias,STRING(crapass.nrdconta)) AND 
        NOT CAN-FIND (craptco WHERE 
                      craptco.cdcooper = crapass.cdcooper  AND
                      craptco.nrdconta = crapass.nrdconta  AND 
                      craptco.tpctatrf <> 3) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = 
                            "Tempo minimo de filiacao abaixo do parametro, " +
                            "tempo minino " + STRING(tt-dados_dsctit.qtminfil) +
                            IF tt-dados_dsctit.qtminfil > 1 THEN
                            " dias."
                            ELSE
                            " dia.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        

            RETURN "NOK".

        END.

    RUN busca_dados_risco (INPUT par_cdcooper,
                           OUTPUT TABLE tt-risco).

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*      Buscar dados de um determinado limite de desconto de titulos        */
/****************************************************************************/
PROCEDURE busca_dados_limite:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.

    DEF VAR aux_cdtipdoc AS INTEGER                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.

    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 3            AND
                             craplim.nrctrlim = par_nrctrlim NO-LOCK NO-ERROR.
         
    IF  NOT AVAILABLE craplim   THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de limites nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
 
    IF  par_cddopcao = "X"  THEN        
        DO:
            IF  craplim.insitlim <> 2   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "O contrato DEVE estar ATIVO.".
                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                  
                    RETURN "NOK".
               END.
        END.
    ELSE
    IF  par_cddopcao = "E"  THEN
        DO:
            IF  craplim.insitlim <> 1   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "O contrato DEVE estar em ESTUDO.".
                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                  
                    RETURN "NOK".
                END.
        END.

    FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                       crapprp.nrdconta = craplim.nrdconta   AND
                       crapprp.nrctrato = craplim.nrctrlim   AND
                       crapprp.tpctrato = 3 
                       NO-LOCK NO-ERROR.    
                   
    IF  NOT AVAILABLE crapprp   THEN                                   
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de proposta de desconto de titulo" +
                                  " nao encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.    
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                       crapldc.cddlinha = craplim.cddlinha   AND
                       crapldc.tpdescto = 3 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapldc  THEN 
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de linha " +
                                  "de desconto nao encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */ 

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE,
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.

    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                       crapjfn.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
        
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND         
               craptab.nmsistem = "CRED"        AND         
               craptab.tptabela = "GENERI"      AND         
               craptab.cdempres = 00            AND         
               craptab.cdacesso = "DIGITALIZA"  AND
               craptab.tpregist = 3 
               NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN
        DO:
            ASSIGN aux_dscritic = 'Falta registro na Tabela "DIGITALIZA". '.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                    
            RETURN "NOK".
        END. 

    ASSIGN aux_cdtipdoc = INTE(ENTRY(3,craptab.dstextab,";")).

    CREATE tt-dsctit_dados_limite.  
    ASSIGN tt-dsctit_dados_limite.txdmulta = tt-dados_dsctit.pcdmulta
           tt-dsctit_dados_limite.codlinha = crapldc.cddlinha
           tt-dsctit_dados_limite.dsdlinha = crapldc.dsdlinha
           tt-dsctit_dados_limite.txjurmor = crapldc.txjurmor 
           tt-dsctit_dados_limite.dsramati = crapprp.dsramati
           tt-dsctit_dados_limite.vlmedtit = crapprp.vlmedchq
           tt-dsctit_dados_limite.vlfatura = crapprp.vlfatura
           tt-dsctit_dados_limite.vloutras = crapprp.vloutras
           tt-dsctit_dados_limite.vlsalari = crapprp.vlsalari
           tt-dsctit_dados_limite.vlsalcon = crapprp.vlsalcon
           tt-dsctit_dados_limite.dsdbens1 = SUBSTRING(crapprp.dsdebens,01,060)
           tt-dsctit_dados_limite.dsdbens2 = SUBSTRING(crapprp.dsdebens,61,120)
           tt-dsctit_dados_limite.dsobserv = crapprp.dsobserv[1]
           tt-dsctit_dados_limite.insitlim = craplim.insitlim
           tt-dsctit_dados_limite.nrctrlim = craplim.nrctrlim
           tt-dsctit_dados_limite.vllimite = craplim.vllimite
           tt-dsctit_dados_limite.qtdiavig = craplim.qtdiavig
           tt-dsctit_dados_limite.cddlinha = craplim.cddlinha
           tt-dsctit_dados_limite.dtcancel = craplim.dtcancel
           tt-dsctit_dados_limite.nrctaav1 = craplim.nrctaav1
           tt-dsctit_dados_limite.nrctaav2 = craplim.nrctaav2
           tt-dsctit_dados_limite.flgdigit = craplim.flgdigit
           tt-dsctit_dados_limite.cdtipdoc = aux_cdtipdoc
           /* ------------------- Rating -----------------*/
           tt-dsctit_dados_limite.nrgarope = craplim.nrgarope
           tt-dsctit_dados_limite.nrinfcad = craplim.nrinfcad
           tt-dsctit_dados_limite.nrliquid = craplim.nrliquid
           tt-dsctit_dados_limite.nrpatlvr = craplim.nrpatlvr
           tt-dsctit_dados_limite.vltotsfn = craplim.vltotsfn
           tt-dsctit_dados_limite.nrperger = craplim.nrperger
           /* Faturamento unico cliente - Pessoa Juridica */
           tt-dsctit_dados_limite.perfatcl = crapjfn.perfatcl
                                             WHEN AVAILABLE crapjfn.
    
    RETURN "OK".

END PROCEDURE.

/**********************************************************************************/
/*      Buscar dados de uma determinada proposta de limite de desconto de titulos */
/**********************************************************************************/
PROCEDURE busca_dados_proposta:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.

    DEF VAR aux_cdtipdoc AS INTEGER                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.

    FIND FIRST crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                             crawlim.nrdconta = par_nrdconta AND
                             crawlim.tpctrlim = 3            AND
                             crawlim.nrctrlim = par_nrctrlim NO-LOCK NO-ERROR.
         
    IF  NOT AVAILABLE crawlim   THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de proposta não encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
 
    IF  par_cddopcao = "X"  THEN        
        DO:
            IF  crawlim.insitlim <> 1   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "A proposta DEVE estar EM ESTUDO.".
                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                  
                    RETURN "NOK".
               END.
        END.
    ELSE
    IF  par_cddopcao = "A"  THEN
        DO:
            /* PRJ 438 - Adicionado controle para situaçao ANULADA */
            IF  ((crawlim.insitlim = 2) or (crawlim.insitlim = 3) or (crawlim.insitlim = 4) or (crawlim.insitlim = 9))  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Não é permitido alterar uma proposta com a situação ATIVA, CANCELADA, ANULADA ou VIGENTE".
                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                  
                    RETURN "NOK".                    
                END.
        END.
    ELSE
    IF  par_cddopcao = "E"  THEN
        DO:
            IF  crawlim.insitlim <> 1   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "A proposta DEVE estar em ESTUDO.".
                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                  
                    RETURN "NOK".
                END.
        END.

    FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                       crapprp.nrdconta = crawlim.nrdconta   AND
                       crapprp.nrctrato = crawlim.nrctrlim   AND
                       crapprp.tpctrato = 3 
                       NO-LOCK NO-ERROR.    
                   
    IF  NOT AVAILABLE crapprp   THEN                                   
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de proposta de desconto de titulo" +
                                  " não encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.    
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                       crapldc.cddlinha = crawlim.cddlinha   AND
                       crapldc.tpdescto = 3 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapldc  THEN 
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de linha " +
                                  "de desconto não encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */ 

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE,
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.

    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                       crapjfn.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
        
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND         
               craptab.nmsistem = "CRED"        AND         
               craptab.tptabela = "GENERI"      AND         
               craptab.cdempres = 00            AND         
               craptab.cdacesso = "DIGITALIZA"  AND
               craptab.tpregist = 3 
               NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN
        DO:
            ASSIGN aux_dscritic = 'Falta registro na Tabela "DIGITALIZA". '.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                    
            RETURN "NOK".
        END. 

    ASSIGN aux_cdtipdoc = INTE(ENTRY(3,craptab.dstextab,";")).

    CREATE tt-dsctit_dados_limite.  
    ASSIGN tt-dsctit_dados_limite.txdmulta = tt-dados_dsctit.pcdmulta
           tt-dsctit_dados_limite.codlinha = crapldc.cddlinha
           tt-dsctit_dados_limite.dsdlinha = crapldc.dsdlinha
           tt-dsctit_dados_limite.txjurmor = crapldc.txjurmor 
           tt-dsctit_dados_limite.dsramati = crapprp.dsramati
           tt-dsctit_dados_limite.vlmedtit = crapprp.vlmedchq
           tt-dsctit_dados_limite.vlfatura = crapprp.vlfatura
           tt-dsctit_dados_limite.vloutras = crapprp.vloutras
           tt-dsctit_dados_limite.vlsalari = crapprp.vlsalari
           tt-dsctit_dados_limite.vlsalcon = crapprp.vlsalcon
           tt-dsctit_dados_limite.dsdbens1 = SUBSTRING(crapprp.dsdebens,01,060)
           tt-dsctit_dados_limite.dsdbens2 = SUBSTRING(crapprp.dsdebens,61,120)
           tt-dsctit_dados_limite.dsobserv = crapprp.dsobserv[1]
           tt-dsctit_dados_limite.insitlim = crawlim.insitlim
           tt-dsctit_dados_limite.nrctrlim = crawlim.nrctrlim
           tt-dsctit_dados_limite.vllimite = crawlim.vllimite
           tt-dsctit_dados_limite.qtdiavig = crawlim.qtdiavig
           tt-dsctit_dados_limite.cddlinha = crawlim.cddlinha
           tt-dsctit_dados_limite.dtcancel = crawlim.dtcancel
           tt-dsctit_dados_limite.nrctaav1 = crawlim.nrctaav1
           tt-dsctit_dados_limite.nrctaav2 = crawlim.nrctaav2
           tt-dsctit_dados_limite.flgdigit = crawlim.flgdigit
           tt-dsctit_dados_limite.cdtipdoc = aux_cdtipdoc
           /* ------------------- Rating -----------------*/
           tt-dsctit_dados_limite.nrgarope = crawlim.nrgarope
           tt-dsctit_dados_limite.nrinfcad = crawlim.nrinfcad
           tt-dsctit_dados_limite.nrliquid = crawlim.nrliquid
           tt-dsctit_dados_limite.nrpatlvr = crawlim.nrpatlvr
           tt-dsctit_dados_limite.vltotsfn = crawlim.vltotsfn
           tt-dsctit_dados_limite.nrperger = crawlim.nrperger
           /* Faturamento unico cliente - Pessoa Juridica */
           tt-dsctit_dados_limite.perfatcl = crapjfn.perfatcl
                                             WHEN AVAILABLE crapjfn
           tt-dsctit_dados_limite.idcobop = crawlim.idcobop.
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/*                          Buscar dados de risco                            */
/*****************************************************************************/
PROCEDURE busca_dados_risco:

    DEF INPUT PARAM par_cdcooper AS INTE    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-risco.
    
    EMPTY TEMP-TABLE tt-risco.
    
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND 
                           craptab.tptabela = "GENERI"       AND 
                           craptab.cdempres = 00             AND
                           craptab.cdacesso = "PROVISAOCL"   NO-LOCK:
        
         CREATE tt-risco.
         ASSIGN tt-risco.contador = INT(SUBSTR(craptab.dstextab,12,2))
                tt-risco.dsdrisco = TRIM(SUBSTR(craptab.dstextab,8,3)).
          
        IF  craptab.tpregist = 999 THEN  /* Vlr obrigatorio informar risco */
            DO:
                CREATE tt-risco.
                ASSIGN tt-risco.vlrrisco = DEC(SUBSTR(craptab.dstextab,15,11))
                       tt-risco.diaratin = INT(SUBSTR(craptab.dstextab,87,3)).
            END.

    END.
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*     Validar dados informados da proposta de limite novo ou alteracao      */
/*****************************************************************************/
PROCEDURE valida_proposta_dados:

   DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
   DEF INPUT PARAM par_dtmvtopr AS DATE                    NO-UNDO.    
   DEF INPUT PARAM par_inproces AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_diaratin AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_vllimite AS DECI                    NO-UNDO.
   DEF INPUT PARAM par_dtrating AS DATE                    NO-UNDO.
   DEF INPUT PARAM par_vlrrisco AS DECI                    NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
   DEF INPUT PARAM par_cddlinha AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_inconfir AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_inconfi2 AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_inconfi4 AS INTE                    NO-UNDO.
   DEF INPUT PARAM par_inconfi5 AS INTE                    NO-UNDO.
       
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
   DEF OUTPUT PARAM TABLE FOR tt-grupo.

   DEF VAR aux_vlr_maxleg   AS DECIMAL NO-UNDO.
   DEF VAR aux_vlr_maxutl   AS DECIMAL NO-UNDO.
   DEF VAR aux_vlr_minscr   AS DECIMAL NO-UNDO.
   DEF VAR aux_vlr_excedido AS LOGICAL NO-UNDO.
   DEF VAR aux_vlutiliz     AS DECIMAL NO-UNDO.
   DEF VAR aux_contador     AS INTEGER NO-UNDO.
   DEF VAR aux_valor        AS DECIMAL NO-UNDO.
   DEF VAR aux_recid        AS RECID   NO-UNDO.
   
   DEF BUFFER crabass FOR crapass.
   DEF BUFFER crabass2 FOR crapass.
   
   DEF VAR h-b1wgen9999 AS HANDLE      NO-UNDO.
   DEF VAR h-b1wgen0138 AS HANDLE      NO-UNDO.
   DEF VAR h-b1wgen0110 AS HANDLE      NO-UNDO.
   DEF VAR aux_nrdgrupo AS INT         NO-UNDO.
   DEF VAR aux_gergrupo AS CHAR        NO-UNDO.
   DEF VAR aux_dsdrisgp AS CHAR        NO-UNDO.
   DEF VAR aux_pertengp AS LOG         NO-UNDO.
   DEF VAR aux_dsdrisco AS CHAR        NO-UNDO.
   DEF VAR aux_dsoperac AS CHAR        NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-msg-confirma.
   EMPTY TEMP-TABLE tt-grupo.
   
   ASSIGN aux_dscritic     = ""
          aux_cdcritic     = 0
          aux_vlr_excedido = NO
          aux_vlr_maxleg   = 0
          aux_vlr_maxutl   = 0
          aux_vlr_minscr   = 0.

   FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta 
                      NO-LOCK NO-ERROR.
                       
   IF NOT AVAIL(crapass)  THEN
      DO:
          ASSIGN aux_cdcritic = 9
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
              
          RETURN "NOK".    

      END.
   
   IF NOT VALID-HANDLE(h-b1wgen0110) THEN
      RUN sistema/generico/procedures/b1wgen0110.p
          PERSISTENT SET h-b1wgen0110.

   /*Monta a mensagem da operacao para envio no e-mail*/
   IF par_cddopcao = "A" THEN
      ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de "  + 
                            "descontos de titulos na conta "                 +
                            STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                            " - CPF/CNPJ "                                   +
                           (IF crapass.inpessoa = 1 THEN
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999")),"xxx.xxx.xxx-xx")
                            ELSE
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999999")),
                                       "xx.xxx.xxx/xxxx-xx")).
   ELSE
      ASSIGN aux_dsoperac = "Tentativa de incluir novo limite de descontos " + 
                            "de titulos na conta "                           +
                            STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                            " - CPF/CNPJ "                                   +
                           (IF crapass.inpessoa = 1 THEN
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999")),"xxx.xxx.xxx-xx")
                            ELSE
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999999")),
                                       "xx.xxx.xxx/xxxx-xx")).

   /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT (IF par_cddopcao = "A" THEN 
                                                6 /*cdoperac*/
                                             ELSE
                                                7), /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */

   RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_idorigem,
                                INPUT TRUE,
                                INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-dados_dsctit,
                                OUTPUT TABLE tt-dados_cecred_dsctit).

   IF RETURN-VALUE = "NOK" THEN
      RETURN "NOK".


   FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR NO-WAIT.

   
   IF par_vllimite > tt-dados_dsctit.vllimite  THEN
      DO:
          ASSIGN aux_cdcritic = 0 
                 aux_dscritic = "Limite maximo por contrato excedido, " +
                                "valor maximo R$ " + 
                            STRING(tt-dados_dsctit.vllimite,"zzz,zzz,zz9.99")
                                + ".".
                 
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
                                     
          RETURN "NOK".

      END.
      

   FIND crapldc WHERE crapldc.cdcooper = par_cdcooper   AND
                      crapldc.cddlinha = par_cddlinha   AND
                      crapldc.tpdescto = 3              AND
                      crapldc.flgstlcr = TRUE /*ATIVA*/
                      NO-LOCK NO-ERROR.
   
   IF NOT AVAILABLE crapldc   THEN
      DO:
          ASSIGN aux_cdcritic = 0
                 aux_dscritic = "Linha de desconto nao cadastrada.".
                 
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
                                     
          RETURN "NOK".            

      END.    


   IF par_cddopcao = "I"  THEN
      DO:
         IF CAN-FIND(craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                   craplim.nrdconta = par_nrdconta   AND
                                   craplim.nrctrlim = par_nrctrlim   AND
                                   craplim.tpctrlim = 3) THEN
            DO:
                ASSIGN aux_dscritic = "Proposta de limite ja existe."
                       aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".

            END.

         IF CAN-FIND(crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                   crapprp.nrdconta = par_nrdconta   AND
                                   crapprp.nrctrato = par_nrctrlim   AND
                                   crapprp.tpctrato = 3) THEN
            DO:
                ASSIGN aux_dscritic = "Registro de proposta ja existe."
                       aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".

            END.

      END.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF AVAIL crapcop THEN
      ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
             aux_vlr_maxutl = crapcop.vlmaxutl
             aux_vlr_minscr = crapcop.vlcnsscr.


   IF NOT VALID-HANDLE(h-b1wgen0138) THEN
      RUN sistema/generico/procedures/b1wgen0138.p
          PERSISTENT SET h-b1wgen0138.

   
   ASSIGN aux_pertengp = DYNAMIC-FUNCTION ("busca_grupo" IN h-b1wgen0138,
                                            INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            OUTPUT aux_nrdgrupo,
                                            OUTPUT aux_gergrupo,
                                            OUTPUT aux_dsdrisgp).

   IF par_inconfi5 = 30 THEN
      DO:
         IF aux_gergrupo <> "" THEN
            DO:
               CREATE tt-msg-confirma.
               
               ASSIGN tt-msg-confirma.inconfir = par_inconfi5 + 1
                      tt-msg-confirma.dsmensag = aux_gergrupo + " Confirma?".

               IF VALID-HANDLE(h-b1wgen0138) THEN
                  DELETE OBJECT(h-b1wgen0138).
                           
               RETURN "OK".

            END.
         
      END.
   
   IF aux_pertengp THEN
      DO:
         /* Procedure responsavel por calcular o endividamento do grupo */
          RUN calc_endivid_grupo IN h-b1wgen0138
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci, 
                                       INPUT par_nrdcaixa, 
                                       INPUT par_cdoperad, 
                                       INPUT par_dtmvtolt, 
                                       INPUT par_nmdatela, 
                                       INPUT par_idorigem, 
                                       INPUT aux_nrdgrupo, 
                                       INPUT TRUE, /*Consulta por conta*/
                                      OUTPUT aux_dsdrisco, 
                                      OUTPUT aux_vlutiliz,
                                      OUTPUT TABLE tt-grupo, 
                                      OUTPUT TABLE tt-erro).

          IF VALID-HANDLE(h-b1wgen0138) THEN
             DELETE OBJECT h-b1wgen0138.
          
          IF RETURN-VALUE <> "OK" THEN
             RETURN "NOK".

          IF par_inconfi2 > 10 THEN
            DO: 
               IF aux_vlr_maxutl > 0 THEN
                  DO:
                     IF par_vllimite > aux_vlutiliz THEN
                        ASSIGN aux_valor = par_vllimite.       
                     ELSE
                        ASSIGN aux_valor = aux_vlutiliz.

                     IF par_inconfi2 = 11 THEN
                        DO: 
                           IF aux_valor > aux_vlr_maxutl THEN
                              DO:
                                 CREATE tt-msg-confirma.

                                 ASSIGN tt-msg-confirma.inconfir = 
                                                         par_inconfi2 + 1
                                        tt-msg-confirma.dsmensag = 
                                             "Vlrs(Utl) Excedidos"    +
                                             "(Utiliz. "              +
                                              TRIM(STRING(aux_vlutiliz,
                                                          "zzz,zzz,zz9.99")) +
                                             " Excedido " +
                                             TRIM(STRING((aux_valor
                                                          - aux_vlr_maxutl),
                                                          "zzz,zzz,zz9.99")) +
                                             ")Confirma? ".

                                 RETURN "OK".

                               END.      
                        END.

                     IF par_inconfi2 = 12            AND
                        (aux_valor > aux_vlr_maxleg) THEN
                        DO: 
                            CREATE tt-msg-confirma.

                            ASSIGN tt-msg-confirma.inconfir = 19
                                   tt-msg-confirma.dsmensag = 
                                        "Vlr(Legal) Excedido" +
                                        "(Utiliz. " +
                                        TRIM(STRING(aux_vlutiliz,
                                        "zzz,zzz,zz9.99")) 
                                        + " Excedido " +
                                        TRIM(STRING((aux_valor
                                        - aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                        ") ". 
                            
                           ASSIGN aux_dscritic = "" 
                                  aux_cdcritic = 79.
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,     /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                      
                            RETURN "NOK".

                        END.

                  END.

            END.
         
         IF par_inconfi4 = 71  THEN
            IF aux_valor >  aux_vlr_minscr  THEN
               DO:
                   CREATE tt-msg-confirma.

                   ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                          tt-msg-confirma.dsmensag = 
                          "Efetue consulta no SCR.".

               END.

      END.
   ELSE
      DO:
         IF VALID-HANDLE(h-b1wgen0138) THEN
            DELETE OBJECT(h-b1wgen0138).
         
         RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
             SET h-b1wgen9999.
             
         IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                       
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                           
                RETURN "NOK".
       
            END.   
       
         RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtmvtopr,
                                            INPUT "",
                                            INPUT par_inproces,
                                            INPUT FALSE,
                                            OUTPUT aux_vlutiliz,
                                            OUTPUT TABLE tt-erro).
         
         DELETE PROCEDURE h-b1wgen9999.
         
         IF RETURN-VALUE = "NOK"  THEN
            RETURN "NOK".            
         
         IF par_inconfi2 > 10  THEN
            DO:
               IF aux_vlr_maxutl > 0  THEN
                  DO:
                     IF par_vllimite > aux_vlutiliz THEN
                        ASSIGN aux_valor = par_vllimite.       
                     ELSE
                        ASSIGN aux_valor = aux_vlutiliz.

                     IF par_inconfi2 = 11 THEN
                        DO: 
                           IF aux_valor > aux_vlr_maxutl THEN
                              DO:
                                 CREATE tt-msg-confirma.

                                 ASSIGN tt-msg-confirma.inconfir = 
                                                         par_inconfi2 + 1
                                        tt-msg-confirma.dsmensag = 
                                             "Vlrs(Utl) Excedidos"    +
                                             "(Utiliz. "              +
                                              TRIM(STRING(aux_vlutiliz,
                                                          "zzz,zzz,zz9.99")) +
                                             " Excedido " +
                                             TRIM(STRING((aux_valor
                                                          - aux_vlr_maxutl),
                                                          "zzz,zzz,zz9.99")) +
                                             ")Confirma? ".

                                 RETURN "OK".

                               END.      
                        END.

                     
                     IF par_inconfi2 = 12 AND
                        (aux_valor > aux_vlr_maxleg)  THEN
                        DO:
                            CREATE tt-msg-confirma.

                            ASSIGN tt-msg-confirma.inconfir = 19
                                   tt-msg-confirma.dsmensag = 
                                        "Vlr(Legal) Excedido" +
                                        "(Utiliz. " +
                                        TRIM(STRING(aux_vlutiliz,
                                        "zzz,zzz,zz9.99")) 
                                        + " Excedido " +
                                        TRIM(STRING((aux_valor
                                        - aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                        ") ". 
                            
                            ASSIGN aux_dscritic = "" 
                                   aux_cdcritic = 79.
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,     /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                      
                            RETURN "NOK".

                        END.

                  END.

            END.
         
         IF par_inconfi4 = 71  THEN
            IF   aux_valor >  aux_vlr_minscr  THEN
                 DO:
                     CREATE tt-msg-confirma.

                     ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                            tt-msg-confirma.dsmensag = 
                            "Efetue consulta no SCR.".

                 END.

      END.

   RETURN "OK".       


END PROCEDURE.

/*************************************************************************************/
/*       Efetuar a inclusao de uma nova proposta de limite de desconto de titulos    */
/*************************************************************************************/
PROCEDURE efetua_inclusao_limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsramati AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmedtit AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlfatura AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdbens1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdbens2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.   
    DEF  INPUT PARAM par_qtdiavig AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    /** ---------------------------- RATING ---------------------------- **/
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrmnt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idcobope AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.                                   
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
        
    DEF VAR h-b1wgen0021 AS HANDLE  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE  NO-UNDO.
    DEF VAR aux_contador AS INTE    NO-UNDO.
    DEF VAR aux_lscontas AS CHAR    NO-UNDO.
    DEF VAR aux_flgderro AS LOGI    NO-UNDO.
    DEF VAR aux_nrctrlim AS INTE    NO-UNDO.
    DEF VAR aux_nrseqcar AS INTE	NO-UNDO.
    DEF VAR aux_mensagens AS CHAR    NO-UNDO.    
    DEF VAR aux_dsfrase  AS CHAR    NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    DEF VAR aux_dsdlinha AS CHAR    NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
               aux_dstransa = "Incluir limite " + STRING(par_nrctrlim) +
                              " de desconto de titulos.".

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE,
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).

    FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
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

    /** Buscar regra para renovaçao **/
    FIND FIRST craprli 
         WHERE craprli.cdcooper = par_cdcooper
           AND craprli.tplimite = 3
           AND craprli.inpessoa = crapass.inpessoa
           NO-LOCK NO-ERROR.

    IF NOT AVAILABLE craprli  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Tabela Regra de limite nao cadastrada.".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,      /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.
    
    /* Validaçao TAB052*/
    /*LIMITE MAXIMO EXCEDIDO*/
    IF par_vllimite > tt-dados_dsctit.vllimite THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Limite maximo excedido.".

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
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

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

    TRANS_INCLUI:    
    DO  TRANSACTION ON ERROR UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI:
    
        DO WHILE TRUE:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Busca a proxima sequencia do campo craplim.nrctrlim */
          RUN STORED-PROCEDURE pc_sequence_progress
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLIM"
                                              ,INPUT "NRCTRLIM"
                                              ,STRING(par_cdcooper) + ";" + "3" /* tpctrlim */
                                              ,INPUT "N"
                                              ,"").

          CLOSE STORED-PROC pc_sequence_progress
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
                                WHEN pc_sequence_progress.pr_sequence <> ?.
          
          ASSIGN aux_nrctrlim = aux_nrseqcar.
                            
          
          
          FIND FIRST crawlim 
               WHERE crawlim.cdcooper = par_cdcooper
                 AND crawlim.tpctrlim = 3
                 AND crawlim.nrctrlim = aux_nrctrlim
                 NO-LOCK NO-ERROR.
          IF NOT AVAILABLE crawlim THEN       
          DO:
            LEAVE.
          END.
                 
        END.       
        
        ASSIGN par_nrctrlim = aux_nrctrlim.
    
        RUN cria-tabelas-avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT par_idorigem,
                                                    INPUT "DESC.TITULO",
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT 8, /* Tipo Contrato */
                                                    INPUT par_nrctrlim,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    /** 1o avalista **/
                                                    INPUT par_nrctaav1,
                                                    INPUT par_nmdaval1,
                                                    INPUT par_nrcpfav1,
                                                    INPUT par_tpdocav1,
                                                    INPUT par_dsdocav1,
                                                    INPUT par_nmdcjav1,
                                                    INPUT par_cpfcjav1, 
                                                    INPUT par_tdccjav1,
                                                    INPUT par_doccjav1,
                                                    INPUT par_ende1av1,
                                                    INPUT par_ende2av1,
                                                    INPUT par_nrfonav1,
                                                    INPUT par_emailav1,
                                                    INPUT par_nmcidav1,
                                                    INPUT par_cdufava1,
                                                    INPUT par_nrcepav1,
                                                    INPUT 0, /* Nacao*/
                                                    INPUT 0,  /* Vl. Endiv. */
                                                    INPUT 0,  /* Vl. Rendim */
                                                    INPUT par_nrender1,
                                                    INPUT par_complen1,
                                                    INPUT par_nrcxaps1,
                                                    INPUT 0,  /* inpessoa 1o avail */
                                                    INPUT ?,  /* dtnascto 1o avail */ 
													INPUT 0, /* par_vlrecjg1 */
                                                    /** 2o avalista **/
                                                    INPUT par_nrctaav2,
                                                    INPUT par_nmdaval2, 
                                                    INPUT par_nrcpfav2,
                                                    INPUT par_tpdocav2,
                                                    INPUT par_dsdocav2, 
                                                    INPUT par_nmdcjav2, 
                                                    INPUT par_cpfcjav2,
                                                    INPUT par_tdccjav2,
                                                    INPUT par_doccjav2,
                                                    INPUT par_ende1av2,
                                                    INPUT par_ende2av2,
                                                    INPUT par_nrfonav2,
                                                    INPUT par_emailav2, 
                                                    INPUT par_nmcidav2, 
                                                    INPUT par_cdufava2, 
                                                    INPUT par_nrcepav2,
                                                    INPUT 0, /* Nacao */
                                                    INPUT 0,  /* Vl. Endiv */
                                                    INPUT 0,  /* Vl. Rendim. */
                                                    INPUT par_nrender2,
                                                    INPUT par_complen2,
                                                    INPUT par_nrcxaps2,
                                                    INPUT 0,  /* inpessoa 2o avail */
                                                    INPUT ?,  /* dtnascto 2o avail */
													INPUT 0, /* par_vlrecjg2 */
                                                    INPUT "",
                                                   OUTPUT TABLE tt-erro).
        
        DELETE PROCEDURE h-b1wgen9999.
        
        IF RETURN-VALUE = "NOK" THEN
        DO:
            ASSIGN aux_flgderro = TRUE.
            UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
        END.

        FIND FIRST crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                                 crawlim.nrdconta = par_nrdconta AND
                                 crawlim.tpctrlim = 3            AND
                                 crawlim.nrctrlim = par_nrctrlim 
                                 NO-LOCK NO-ERROR.
         
        IF  AVAILABLE crawlim   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de proposta de limite de desconto de titulos ja existente.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.  
            END.

        RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
            SET h-b1wgen0021.

        IF  VALID-HANDLE(h-b1wgen0021)  THEN
            DO:
                RUN obtem-saldo-cotas IN h-b1wgen0021 
                                              (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               OUTPUT TABLE tt-saldo-cotas,
                                               OUTPUT TABLE tt-erro). 
        
                DELETE PROCEDURE h-b1wgen0021.

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN aux_flgderro = TRUE.
                        UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
                    END.
            
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para h-b1wgen0021.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.                
            END.

        FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
        IF  NOT AVAIL tt-saldo-cotas THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de cotas nao encontrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.

                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
            END.
        
        CREATE crawlim.
        ASSIGN crawlim.nrdconta    = par_nrdconta
               crawlim.tpctrlim    = 3 /* Limite de Desconto de titulo */
               crawlim.nrctrlim    = par_nrctrlim

               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crawlim.cdopeori = par_cdoperad
               crawlim.cdageori = par_cdagenci
               crawlim.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

               crawlim.dtpropos    = par_dtmvtolt
               crawlim.insitlim    = 1
               crawlim.cddlinha    = par_cddlinha
               crawlim.qtdiavig    = par_qtdiavig
               crawlim.cdoperad    = par_cdoperad
               crawlim.cdmotcan    = 0
               crawlim.vllimite    = par_vllimite
               crawlim.inbaslim    = IF par_vllimite > 
                                        tt-saldo-cotas.vlsldcap THEN
                                        2
                                     ELSE  
                                        1
               crawlim.flgimpnp    = TRUE
               crawlim.nrctaav1    = par_nrctaav1
               crawlim.nrctaav2    = par_nrctaav2

                crawlim.qtrenctr    = craprli.qtmaxren

               crawlim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               crawlim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               crawlim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               crawlim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") +
                                         " - " + CAPS(par_cdufava2)
               crawlim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_nmdaval1)
               crawlim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         CAPS(par_nmdaval2)
               crawlim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               crawlim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               crawlim.nmcjgav1    = CAPS(par_nmdcjav1)
               crawlim.nmcjgav2    = CAPS(par_nmdcjav2)
               crawlim.dscfcav1    = CAPS(par_doccjav1)
               crawlim.dscfcav2    = CAPS(par_doccjav2)
               crawlim.nrgarope    = par_nrgarope
               crawlim.nrinfcad    = par_nrinfcad
               crawlim.nrliquid    = par_nrliquid
               crawlim.nrpatlvr    = par_nrpatlvr
               crawlim.nrperger    = par_nrperger
               crawlim.vltotsfn    = par_vltotsfn
               crawlim.cdcooper    = par_cdcooper
               crawlim.nrctrmnt    = par_nrctrmnt
			   crawlim.idcobope    = par_idcobope
               crawlim.idcobefe    = par_idcobope.
        
        VALIDATE crawlim.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF   crapass.inpessoa <> 1   THEN
             DO aux_contador = 1 TO 10:
    
                FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper  AND
                                   crapjfn.nrdconta = par_nrdconta  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF   NOT AVAILABLE crapjfn   THEN
                     IF  LOCKED crapjfn   THEN
                         DO:
                            ASSIGN aux_cdcritic = 72.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                     ELSE
                         DO:
                            CREATE crapjfn.
                            ASSIGN crapjfn.cdcooper = par_cdcooper
                                   crapjfn.nrdconta = par_nrdconta
    
                                   aux_cdcritic     = 0.
                            VALIDATE crapjfn.
                         END.
    
                IF   aux_cdcritic > 0   THEN
                     DO:
                         ASSIGN aux_dscritic = "".
                    
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1, /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                                        
                         ASSIGN aux_flgderro = TRUE.
                         
                          UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
                     END.
    
                ASSIGN crapjfn.perfatcl = par_perfatcl.
    
                LEAVE.
             END. /* Fim do DO TO */

        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                                 crapprp.nrdconta = par_nrdconta     AND
                                 crapprp.tpctrato = 3                AND
                                 crapprp.nrctrato = crawlim.nrctrlim
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapprp  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de proposta ja existe.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
            END.               
               
        CREATE crapprp.
        ASSIGN crapprp.nrdconta = par_nrdconta
               crapprp.nrctrato = par_nrctrlim
               crapprp.tpctrato = 3 /* Limite de Dscto Titulo */
               crapprp.dsramati = CAPS(par_dsramati)
               crapprp.vlmedchq = par_vlmedtit
               crapprp.vlfatura = par_vlfatura
               crapprp.vloutras = par_vloutras
               crapprp.vlsalari = par_vlsalari
               crapprp.vlsalcon = par_vlsalcon
               crapprp.dsdebens = STRING(par_dsdbens1,"x(60)") + 
                                  STRING(par_dsdbens2,"x(60)")
               crapprp.dsobserv[1] = CAPS(par_dsobserv)
               crapprp.dsobserv[2] = ""
               crapprp.dsobserv[3] = ""
               crapprp.cdcooper    = par_cdcooper
               crapprp.dtmvtolt    = par_dtmvtolt.
        VALIDATE crapprp.                   
        
        /* Verificar se a conta pertence ao grupo economico novo */	
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_obtem_mensagem_grp_econ_prg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,""
                                              ,0
                                              ,"").

        CLOSE STORED-PROC pc_obtem_mensagem_grp_econ_prg
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic      = 0
               aux_dscritic     = ""
               aux_cdcritic  = INT(pc_obtem_mensagem_grp_econ_prg.pr_cdcritic) WHEN pc_obtem_mensagem_grp_econ_prg.pr_cdcritic <> ?
               aux_dscritic  = pc_obtem_mensagem_grp_econ_prg.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?
               aux_mensagens = pc_obtem_mensagem_grp_econ_prg.pr_mensagens WHEN pc_obtem_mensagem_grp_econ_prg.pr_mensagens <> ?.
                        
        IF aux_cdcritic > 0 THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                              
               ASSIGN aux_flgderro = TRUE.
               UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
           END.
        ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /*sequencia*/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
                             
              ASSIGN aux_flgderro = TRUE.
              UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
          END.
                      
        IF aux_mensagens <> ? AND aux_mensagens <> "" THEN
           DO:
               CREATE tt-msg-confirma.                        
               ASSIGN tt-msg-confirma.inconfir = 1
                      tt-msg-confirma.dsmensag = aux_mensagens.
           END.    
        
           
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT par_idcobope
                                              ,INPUT par_nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
           END.
        
    END. /* Final da TRANSACAO */
    
    IF  aux_flgderro  THEN
        DO:
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
      /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Numero de Contrato do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Contrato",
                                 INPUT "",
                                 INPUT TRIM(STRING(par_nrctrlim, "zzz,zzz,zz9"))).
        /** Valor do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Vl.Limite de Crédito",
                                 INPUT "",
                                 INPUT TRIM(STRING(par_vllimite, "zzz,zzz,zz9.99"))).
        /** Data Alteracao do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Data de Contrataçao",
                                 INPUT "",
                                 INPUT STRING(par_dtmvtolt, "99/99/9999")).
        /** Linha de crédito **/
        FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                           crapldc.cddlinha = par_cddlinha AND
                           crapldc.tpdescto = 2
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapldc   THEN
             aux_dsdlinha = STRING(par_cddlinha) + " - " + "NAO CADASTRADA".
        ELSE
             aux_dsdlinha = STRING(par_cddlinha) + " - " + crapldc.dsdlinha.
        //
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Linha de Crédito",
                                 INPUT "",
                                 INPUT STRING(aux_dsdlinha)).
        /** Prazo de Vigencia **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Prazo de Vigencia (dias)",
                                 INPUT "",
                                 INPUT STRING(par_qtdiavig)).
        /** Periodicidade da Capitalizaçao **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Tx.Juros Remuneratórios",
                                 INPUT "",
                                 INPUT STRING("Aplicável em cada borderô")).
        /** Custo Efetivo Total (CET) **/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_busca_cet_limite
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrlim,
                                            OUTPUT "",  /* DSFRASE */
                                            OUTPUT 0,   /* Codigo da crítica */
                                            OUTPUT ""). /* Descriçao da crítica */
        CLOSE STORED-PROC pc_busca_cet_limite
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        ASSIGN aux_dsfrase  = ""
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_dsfrase  = pc_busca_cet_limite.pr_dsfrase 
                              WHEN pc_busca_cet_limite.pr_dsfrase <> ?
               aux_cdcritic = pc_busca_cet_limite.pr_cdcritic 
                              WHEN pc_busca_cet_limite.pr_cdcritic <> ?
               aux_dscritic = pc_busca_cet_limite.pr_dscritic
                              WHEN pc_busca_cet_limite.pr_dscritic <> ?.
        IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
           aux_dsfrase  = "Erro ao buscar o CET " + aux_dscritic.
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Custo Efetivo Total (CET)",
                                 INPUT "",
                                 INPUT STRING(aux_dsfrase)).
    END.
    /* Fim Pj470 - SM2 */
    
    RETURN "OK".
        
END PROCEDURE.

/*****************************************************************************/
/* Atualizar tabela de avalistas e os dados da proposta de limite de dsc tit */
/*****************************************************************************/
PROCEDURE efetua_alteracao_limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsramati AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmedtit AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlfatura AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdbens1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdbens2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    /** ---------------------------- RATING --------------------------- **/
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idcobope AS INTE                           NO-UNDO.
      
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0021 AS HANDLE  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE  NO-UNDO.
    DEF VAR aux_contador AS INTE    NO-UNDO.
    DEF VAR aux_flgderro AS LOGI    NO-UNDO.
    
    DEF VAR old_dtpropos LIKE crawlim.dtpropos.
    DEF VAR old_cddlinha LIKE crawlim.cddlinha.
    DEF VAR old_cdoperad LIKE crawlim.cdoperad.
    DEF VAR old_vllimite LIKE crawlim.vllimite.
    DEF VAR old_inbaslim LIKE crawlim.inbaslim.
    DEF VAR old_nrctaav1 LIKE crawlim.nrctaav1.
    DEF VAR old_nrctaav2 LIKE crawlim.nrctaav2.
    DEF VAR old_ende1av1 AS CHAR    NO-UNDO.
    DEF VAR old_ende2av1 AS CHAR    NO-UNDO.
    DEF VAR old_ende1av2 AS CHAR    NO-UNDO.
    DEF VAR old_ende2av2 AS CHAR    NO-UNDO.
    DEF VAR old_nmdaval1 LIKE crawlim.nmdaval1.
    DEF VAR old_nmdaval2 LIKE crawlim.nmdaval2.
    DEF VAR old_dscpfav1 LIKE crawlim.dscpfav1.
    DEF VAR old_dscpfav2 LIKE crawlim.dscpfav2.
    DEF VAR old_nmdcjav1 LIKE crawlim.nmcjgav1.
    DEF VAR old_nmcjgav2 LIKE crawlim.nmcjgav2.
    DEF VAR old_dscfcav1 LIKE crawlim.dscfcav1.
    DEF VAR old_dscfcav2 LIKE crawlim.dscfcav2.
    DEF VAR old_dsramati LIKE crapprp.dsramati.
    DEF VAR old_vlmedchq LIKE crapprp.vlmedchq.
    DEF VAR old_vlfatura LIKE crapprp.vlfatura.
    DEF VAR old_vloutras LIKE crapprp.vloutras.
    DEF VAR old_vlsalari LIKE crapprp.vlsalari.
    DEF VAR old_vlsalcon LIKE crapprp.vlsalcon.
    DEF VAR old_dsdeben1 LIKE crapprp.dsdebens.  
    DEF VAR old_dsdeben2 LIKE crapprp.dsdebens.
    DEF VAR old_dsobser1 LIKE crapprp.dsobserv[1].
    /**----------- OLD - RATING -----------**/    
    DEF VAR old_nrgarope LIKE crawlim.nrgarope.
    DEF VAR old_nrinfcad LIKE crawlim.nrinfcad.
    DEF VAR old_nrliquid LIKE crawlim.nrliquid.
    DEF VAR old_nrpatlvr LIKE crawlim.nrpatlvr.
    DEF VAR old_nrperger LIKE crawlim.nrperger.
    DEF VAR old_vltotsfn LIKE crawlim.vltotsfn.
    DEF VAR old_perfatcl LIKE crapjfn.perfatcl.    
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Alterar dados da proposta " + STRING(par_nrctrlim) +
                              " do limite de desconto de titulos.".
    
                   
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
                     
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

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

    TRANS_ALTERA:    
    DO  TRANSACTION ON ERROR UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA:
    
        RUN atualiza_tabela_avalistas IN h-b1wgen9999 
                                 (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT par_idorigem,
                                  INPUT "DESC.TITULO",
                                  INPUT par_nrdconta, 
                                  INPUT par_dtmvtolt, 
                                  INPUT 8, /*tpctrato*/
                                  INPUT par_nrctrlim,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  /** 1 avalista **/
                                  INPUT par_nrctaav1, 
                                  INPUT par_nmdaval1, 
                                  INPUT par_nrcpfav1, 
                                  INPUT par_tpdocav1, 
                                  INPUT par_dsdocav1,
                                  INPUT par_nmdcjav1,
                                  INPUT par_cpfcjav1,
                                  INPUT par_tdccjav1, 
                                  INPUT par_doccjav1, 
                                  INPUT par_ende1av1, 
                                  INPUT par_ende2av1, 
                                  INPUT par_nrfonav1, 
                                  INPUT par_emailav1, 
                                  INPUT par_nmcidav1, 
                                  INPUT par_cdufava1, 
                                  INPUT par_nrcepav1, 
                                  INPUT 0, /* Nacao */
                                  INPUT 0,  /* Vl. Endividamento */
                                  INPUT 0,  /* Vl. Renda */
                                  INPUT par_nrender1,
                                  INPUT par_complen1,
                                  INPUT par_nrcxaps1,
                                  INPUT 0,  /* inpessoa 1o avail */
                                  INPUT ?,  /* dtnascto 1o avail */
								  INPUT 0, /* par_vlrecjg1 */
                                  /** 2 avalista **/
                                  INPUT par_nrctaav2, 
                                  INPUT par_nmdaval2, 
                                  INPUT par_nrcpfav2, 
                                  INPUT par_tpdocav2, 
                                  INPUT par_dsdocav2, 
                                  INPUT par_nmdcjav2, 
                                  INPUT par_cpfcjav2, 
                                  INPUT par_tdccjav2, 
                                  INPUT par_doccjav2, 
                                  INPUT par_ende1av2, 
                                  INPUT par_ende2av2, 
                                  INPUT par_nrfonav2, 
                                  INPUT par_emailav2, 
                                  INPUT par_nmcidav2, 
                                  INPUT par_cdufava2, 
                                  INPUT par_nrcepav2,
                                  INPUT 0,  /* Nacao */ 
                                  INPUT 0,   /* Vl. Endividamento */
                                  INPUT 0,   /* Vl. Renda*/
                                  INPUT par_nrender2,
                                  INPUT par_complen2,
                                  INPUT par_nrcxaps2,
                                  INPUT 0,  /* inpessoa 2o avail */
                                  INPUT ?,  /* dtnascto 2o avail */
								  INPUT 0, /* par_vlrecjg2 */
                                  INPUT ""). /* Bens dos aval */ 

        DELETE PROCEDURE h-b1wgen9999.
        
        DO  aux_contador = 1 TO 10:
            FIND FIRST crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                                     crawlim.nrdconta = par_nrdconta AND
                                     crawlim.tpctrlim = 3            AND
                                     crawlim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE crawlim   THEN 
                IF   LOCKED crawlim   THEN
                     DO:
                        aux_dscritic = "Registro da proposta de limite de desconto de titulos sendo" +
                                       " alterado. Tente Novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                     END.
                ELSE
                     DO:            
                         ASSIGN aux_dscritic = "Registro da proposta de limite de desconto de titulos nao " +
                                               "encontrado.".
                         LEAVE.
                     END.
            aux_dscritic = "".
            LEAVE.
        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                LEAVE.  
            END.        
        
        RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
            SET h-b1wgen0021.

        IF  VALID-HANDLE(h-b1wgen0021)  THEN
            DO:
                RUN obtem-saldo-cotas IN h-b1wgen0021 
                                              (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               OUTPUT TABLE tt-saldo-cotas,
                                               OUTPUT TABLE tt-erro). 
        
                DELETE PROCEDURE h-b1wgen0021.

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN aux_flgderro = TRUE.
                        UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
                    END.
            
            END.
        ELSE
            DO:
                DELETE PROCEDURE h-b1wgen0021.

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de cotas nao encontrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
            END.

        FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
        IF  NOT AVAIL tt-saldo-cotas THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de cotas nao encontrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.                
            END.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF   crapass.inpessoa <> 1   THEN
             DO aux_contador = 1 TO 10:
    
                FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper  AND
                                   crapjfn.nrdconta = par_nrdconta  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF   NOT AVAILABLE crapjfn   THEN
                     IF  LOCKED crapjfn   THEN
                         DO:
                            ASSIGN aux_cdcritic = 72.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                     ELSE
                         DO:
                            CREATE crapjfn.
                            ASSIGN crapjfn.cdcooper = par_cdcooper
                                   crapjfn.nrdconta = par_nrdconta
    
                                   aux_cdcritic     = 0.
                            VALIDATE crapjfn.
                         END.
    
                IF   aux_cdcritic > 0   THEN
                     DO:
                         ASSIGN aux_dscritic = "".
                    
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1, /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                                        
                         ASSIGN aux_flgderro = TRUE.
                         
                         UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
                     END.
    
                ASSIGN old_perfatcl     = crapjfn.perfatcl
                       crapjfn.perfatcl = par_perfatcl.
    
                LEAVE.
             END. /* Fim do DO TO */
            
        ASSIGN old_dtpropos     = crawlim.dtpropos
               crawlim.dtpropos = par_dtmvtolt
               crawlim.insitlim = 1
               old_cddlinha     = crawlim.cddlinha
               crawlim.cddlinha = par_cddlinha
               old_cdoperad     = crawlim.cdoperad
               crawlim.cdoperad = par_cdoperad
               crawlim.cdmotcan = 0
               old_vllimite     = crawlim.vllimite
               crawlim.vllimite = par_vllimite
               old_inbaslim     = crawlim.inbaslim
               crawlim.inbaslim = IF  par_vllimite > 
                                      tt-saldo-cotas.vlsldcap  THEN 2
                                  ELSE 1
               crawlim.flgimpnp = TRUE
               old_nrctaav1     = crawlim.nrctaav1
               crawlim.nrctaav1 = par_nrctaav1
               old_nrctaav2     = crawlim.nrctaav2
               crawlim.nrctaav2 = par_nrctaav2
               old_ende1av1     = crawlim.dsendav1[1]
               crawlim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE 
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               old_ende2av1        = crawlim.dsendav1[2]
               crawlim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               old_ende1av2 = crawlim.dsendav2[1]
               crawlim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               old_ende2av2        = crawlim.dsendav2[2]
               crawlim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") +
                                         " - " + CAPS(par_cdufava2)
               old_nmdaval1        = crawlim.nmdaval1
               crawlim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_nmdaval1
               old_nmdaval2        = crawlim.nmdaval2
               crawlim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         par_nmdaval2
               old_dscpfav1        = crawlim.dscpfav1
               crawlim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               old_dscpfav2        = crawlim.dscpfav2
               crawlim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               old_nmdcjav1        = crawlim.nmcjgav1
               crawlim.nmcjgav1    = par_nmdcjav1
               old_nmcjgav2        = crawlim.nmcjgav2
               crawlim.nmcjgav2    = par_nmdcjav2
               old_dscfcav1        = crawlim.dscfcav1
               crawlim.dscfcav1    = par_doccjav1
               old_dscfcav2        = crawlim.dscfcav2
               crawlim.dscfcav2    = par_doccjav2
               old_nrgarope        = crawlim.nrgarope
               crawlim.nrgarope    = par_nrgarope
               old_nrinfcad        = crawlim.nrinfcad
               crawlim.nrinfcad    = par_nrinfcad
               old_nrliquid        = crawlim.nrliquid
               crawlim.nrliquid    = par_nrliquid
               old_nrpatlvr        = crawlim.nrpatlvr
               crawlim.nrpatlvr    = par_nrpatlvr
               old_nrperger        = crawlim.nrperger
               crawlim.nrperger    = par_nrperger
               old_vltotsfn        = crawlim.vltotsfn
               crawlim.vltotsfn    = par_vltotsfn
			   crawlim.idcobope    = par_idcobope
               crawlim.idcobefe    = par_idcobope
               crawlim.insitest    = 0
               crawlim.dtenvest    = ?
               crawlim.hrenvest    = 0
               crawlim.cdopeste    = ""
               crawlim.insitapr    = 0
               crawlim.dtaprova    = ?
               crawlim.hraprova    = 0
               crawlim.cdopeapr    = "".                                
        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                                     crapprp.nrdconta = par_nrdconta     AND
                                     crapprp.tpctrato = 3                AND
                                     crapprp.nrctrato = crawlim.nrctrlim
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapprp  THEN
                DO:
                    IF  LOCKED crapprp  THEN
                        DO:
                            aux_dscritic = "Registro de proposta esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Registro de proposta nao " +
                                           "encontrado.".
                            LEAVE.               
                        END.
                END.

            aux_dscritic = "".
            LEAVE.
            
        END. /** Fim do DO ... TO **/ 
                   
        IF  aux_dscritic <> ""  THEN    
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                ASSIGN aux_flgderro = TRUE.
                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
            END.        
        
        ASSIGN old_dsramati     = crapprp.dsramati
               crapprp.dsramati = CAPS(par_dsramati)
               old_vlmedchq     = crapprp.vlmedchq
               crapprp.vlmedchq = par_vlmedtit
               old_vlfatura     = crapprp.vlfatura
               crapprp.vlfatura = par_vlfatura
               old_vloutras     = crapprp.vloutras
               crapprp.vloutras = par_vloutras
               old_vlsalari     = crapprp.vlsalari
               crapprp.vlsalari = par_vlsalari
               old_vlsalcon     = crapprp.vlsalcon
               crapprp.vlsalcon = par_vlsalcon
               old_dsdeben1     = SUBSTR(crapprp.dsdebens,1,60)
               old_dsdeben2     = SUBSTR(crapprp.dsdebens,60,61)
               crapprp.dsdebens = STRING(par_dsdbens1,"x(60)") +
                                  STRING(par_dsdbens2,"x(60)")
               old_dsobser1     = crapprp.dsobserv[1]
               crapprp.dsobserv[1] = CAPS(par_dsobserv)
               crapprp.dsobserv[2] = ""
               crapprp.dsobserv[3] = "".
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT par_idcobope
                                              ,INPUT crawlim.nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
           END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_interrompe_proposta_lim_est
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                        ,INPUT par_cdagenci                                        
                        ,INPUT par_cdoperad 
                        ,INPUT par_idorigem
                        ,INPUT par_nrdconta
                        ,INPUT par_nrctrlim
                        ,INPUT 3
                        ,INPUT par_dtmvtolt
                        ,0
                        ,"").

        CLOSE STORED-PROC pc_interrompe_proposta_lim_est
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_cdcritic = pc_interrompe_proposta_lim_est.pr_cdcritic
                              WHEN pc_interrompe_proposta_lim_est.pr_cdcritic <> ?
               aux_dscritic  = ""
               aux_dscritic  = pc_interrompe_proposta_lim_est.pr_dscritic 
                               WHEN pc_interrompe_proposta_lim_est.pr_dscritic <> ?.

        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
           END.   
        
        FIND CURRENT crawlim NO-LOCK NO-ERROR.
        FIND CURRENT crapprp NO-LOCK NO-ERROR.

        IF  AVAILABLE crapjfn  THEN
            FIND CURRENT crapjfn NO-LOCK NO-ERROR.
           
    END. /* Final da transacao */

    IF  aux_flgderro  THEN
        DO:
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

            IF  old_dtpropos <> crawlim.dtpropos  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "data proposta",
                                        INPUT old_dtpropos,
                                        INPUT crawlim.dtpropos).
                                        
            IF  old_cddlinha <> crawlim.cddlinha  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "linha de credito",
                                        INPUT old_cddlinha,
                                        INPUT crawlim.cddlinha).
                                        
            IF  old_cdoperad <> crawlim.cdoperad  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "operador",
                                        INPUT old_cdoperad,
                                        INPUT crawlim.cdoperad).
                                        
            IF  old_vllimite <> crawlim.vllimite  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "valor limite",
                                        INPUT STRING(old_vllimite,
                                                     "z,zzz,zz9.99"),
                                        INPUT STRING(crawlim.vllimite,
                                                     "z,zzz,zz9.99")).
                                        
            IF  old_inbaslim <> crawlim.inbaslim  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "base limite",
                                        INPUT old_inbaslim,
                                        INPUT crawlim.inbaslim).
                                        
            IF  old_nrctaav1 <> crawlim.nrctaav1  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "conta aval 1",
                                        INPUT old_nrctaav1,
                                        INPUT par_nrctaav1).
                                        
            IF  old_nrctaav2 <> crawlim.nrctaav2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "conta aval 2",
                                        INPUT old_nrctaav2,
                                        INPUT par_nrctaav2).    
                                        
            IF  old_ende1av1 <> crawlim.dsendav1[1]  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "endereco 1 aval 1",
                                        INPUT old_ende1av1,
                                        INPUT crawlim.dsendav1[1]).
                                        
            IF  old_ende2av1 <> crawlim.dsendav1[2]  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "endereco 2 aval 1",
                                        INPUT old_ende2av1,
                                        INPUT crawlim.dsendav1[2]).
                                        
            IF  old_ende1av2 <> crawlim.dsendav2[1]  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "endereco 1 aval 2",
                                        INPUT old_ende1av2,
                                        INPUT crawlim.dsendav2[1]).
                                        
            IF  old_ende2av2 <> crawlim.dsendav2[2]  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "endereco 2 aval 2",
                                        INPUT old_ende2av2,
                                        INPUT crawlim.dsendav2[2]).
                                        
            IF  old_nmdaval1 <> crawlim.nmdaval1  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nome aval 1",
                                        INPUT old_nmdaval1,
                                        INPUT crawlim.nmdaval1).
                                        
            IF  old_nmdaval2 <> crawlim.nmdaval2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nome aval 2",
                                        INPUT old_nmdaval2,
                                        INPUT crawlim.nmdaval2).
                                        
            IF  old_dscpfav1 <> crawlim.dscpfav1  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "cpf aval 1",
                                        INPUT old_dscpfav1,
                                        INPUT crawlim.dscpfav1).
                                        
            IF  old_dscpfav2 <> crawlim.dscpfav2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "cpf aval 2",
                                        INPUT old_dscpfav2,
                                        INPUT crawlim.dscpfav2).
                                        
            IF  old_nmdcjav1 <> crawlim.nmcjgav1  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nome conjuge aval 1",
                                        INPUT old_nmdcjav1,
                                        INPUT crawlim.nmcjgav1).
                                        
            IF  old_nmcjgav2 <> crawlim.nmcjgav2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nome conjuge aval 2",
                                        INPUT old_nmcjgav2,
                                        INPUT crawlim.nmcjgav2).
                                        
            IF  old_dscfcav1 <> crawlim.dscfcav1  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "cpf conjuge aval 1",
                                        INPUT old_dscfcav1,
                                        INPUT crawlim.dscfcav1).
                                 
            IF  old_dscfcav2 <> crawlim.dscfcav2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "cpf conjuge aval 2",
                                        INPUT old_dscfcav1,
                                        INPUT crawlim.dscfcav1).
            
            IF   old_nrinfcad <> crawlim.nrinfcad   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "informacoes cadastrais",
                                         INPUT old_nrinfcad,
                                         INPUT crawlim.nrinfcad).
                    
            IF   old_nrliquid <> crawlim.nrliquid   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "liquidez das garantias",
                                         INPUT old_nrliquid,
                                         INPUT crawlim.nrliquid).
               
            IF   old_nrpatlvr <> crawlim.nrpatlvr   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "patrimonio pessoal livre",
                                         INPUT old_nrpatlvr,
                                         INPUT crawlim.nrpatlvr).
                              
            IF   old_nrperger <> crawlim.nrperger   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "percepcao geral (empresa)",
                                         INPUT old_nrperger,
                                         INPUT crawlim.nrperger).
            
            IF   old_vltotsfn <> crawlim.vltotsfn   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "valor total SFN",
                                         INPUT old_vltotsfn,
                                         INPUT crawlim.vltotsfn).   
            
            IF   old_nrgarope <> crawlim.nrgarope   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "garantia",
                                         INPUT old_nrgarope,
                                         INPUT crawlim.nrgarope).
            
            IF   AVAILABLE crapjfn                  AND 
                 old_perfatcl <> crapjfn.perfatcl   THEN
                 RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                         INPUT "percentual faturamento",
                                         INPUT old_perfatcl,
                                         INPUT crapjfn.perfatcl).
               
            IF  old_dsramati <> crapprp.dsramati  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "ramo atividade", 
                                        INPUT old_dsramati,
                                        INPUT crapprp.dsramati).
                                        
            IF  old_vlmedchq <> crapprp.vlmedchq  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "valor medio titulos",
                                        INPUT STRING(old_vlmedchq,
                                                     "zz,zzz,zz9.99"),
                                        INPUT STRING(crapprp.vlmedchq,
                                                     "zz,zzz,zz9.99")).
                                        
            IF  old_vlfatura <> crapprp.vlfatura  THEN 
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "faturamento",
                                        INPUT STRING(old_vlfatura,
                                                     "z,zzz,zzz,zz9.99"),
                                        INPUT STRING(crapprp.vlfatura,
                                                     "z,zzz,zzz,zz9.99")).
                                        
            IF  old_vloutras <> crapprp.vloutras  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "outras rendas",
                                        INPUT STRING(old_vloutras,
                                                     "z,zzz,zzz,zz9.99"),
                                        INPUT STRING(crapprp.vloutras,
                                                     "z,zzz,zzz,zz9.99")).
                                        
            IF  old_vlsalari <> crapprp.vlsalari  THEN 
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "salario",
                                        INPUT STRING(old_vlsalari,
                                                     "z,zzz,zzz,zz9.99"),
                                        INPUT STRING(crapprp.vlsalari,
                                                     "z,zzz,zzz,zz9.99")).
                                        
            IF  old_vlsalcon <> crapprp.vlsalcon  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "salario conjuge",
                                        INPUT STRING(old_vlsalcon,
                                                     "z,zzz,zzz,zz9.99"),
                                        INPUT STRING(crapprp.vlsalcon,
                                                     "z,zzz,zzz,zz9.99")).
                                      
            IF  old_dsdeben1 <> SUBSTR(crapprp.dsdebens,1,60)  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "bens 1",
                                        INPUT old_dsdeben1,
                                        INPUT SUBSTR(crapprp.dsdebens,1,60)).
                                         
            IF  old_dsdeben2 <> SUBSTR(crapprp.dsdebens,61,60)  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "bens 2",
                                        INPUT old_dsdeben2,
                                        INPUT SUBSTR(crapprp.dsdebens,61,60)).
                                       
            IF  old_dsobser1 <> crapprp.dsobserv[1]  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "observacoes",
                                        INPUT old_dsobser1,
                                        INPUT crapprp.dsobserv[1]).
        
        END.
    
    RETURN "OK".
   
END PROCEDURE.

/****************************************************************************/
/*        Efetuar o cancelamento de um limite de desconto de titulos        */
/****************************************************************************/
PROCEDURE efetua_cancelamento_limite:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE        NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI        NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE      NO-UNDO.

    DEF BUFFER crablim  FOR crawlim.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Cancelar limite " + STRING(par_nrctrlim) +
                              " de desconto de titulos.".
    
    TRANS_CANCELAMENTO:

    DO TRANSACTION ON ERROR UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO:

        DO aux_contador = 1 TO 10:
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 3            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplim  THEN 
                IF  LOCKED craplim  THEN
                    DO:
                        aux_dscritic = "Registro de titulos sendo " +
                                       "alterado. Tente Novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    ASSIGN aux_dscritic = "Registro de limites nao " +
                                          "encontrado.".
            
            LEAVE.

        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
            UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.  
            
        IF  craplim.insitlim <> 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O contrato deve estar ATIVO.".
                          
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
            END.
        
        ASSIGN craplim.insitlim = 3
               craplim.dtcancel = par_dtmvtolt
			   /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopeexc = par_cdoperad
               craplim.cdageexc = par_cdagenci
               craplim.dtinsexc = TODAY
			   /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopecan = par_cdoperad.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                              ,INPUT craplim.idcobope
                                              ,INPUT "D"
                                              ,INPUT par_cdoperad
                                              ,INPUT ""
                                              ,INPUT 0
                                              ,INPUT "S"
                                              ,"").

        CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
           END.


        RUN sistema/generico/procedures/b1wgen0043.p 
            PERSISTENT SET h-b1wgen0043.

        IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0043.".
                          
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
            END.

        RUN desativa_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_nrdconta,
                                             INPUT 3, /** Descto. Tit **/
                                             INPUT par_nrctrlim,
                                             INPUT TRUE,
                                             INPUT par_idseqttl,
                                             INPUT par_idorigem,
                                             INPUT par_nmdatela,
                                             INPUT par_inproces,
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-erro).
                                        
        DELETE PROCEDURE h-b1wgen0043.

        IF  RETURN-VALUE = "NOK"  THEN
            UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
           

        /* No cancelamento do contrato, busco a proposta principal de criacao e cancelo */
        DO aux_contador = 1 TO 10:
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            FIND FIRST crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                                     crawlim.nrdconta = par_nrdconta AND
                                     crawlim.tpctrlim = 3            AND
                                     crawlim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE crawlim  THEN 
                IF  LOCKED crawlim  THEN
                    DO:
                        aux_dscritic = "Registro de contrato sendo " +
                                       "alterado. Tente Novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    ASSIGN aux_dscritic = "Registro de contrato nao " +
                                          "encontrado.".

            LEAVE.

        END. /* Final do DO .. TO */    
    
        /* Adicinando tratamento para impedir cancelamento quando proposta estiver na IBRATAN */
        IF aux_dscritic = "" THEN
          DO:
            IF crawlim.insitlim = 1 AND crawlim.insitest = 2 THEN
              DO:
                aux_dscritic = "Nao é possível cancelar o contrato. Existe " + 
                               "um processo de análise deste contrato em andamento".
              END.
            ELSE
              /* Adicinando tratamento para impedir cancelamento quando proposta estiver na IBRATAN */
              IF crawlim.insitlim = 1 AND crawlim.insitapr = 8 THEN
                DO:
                  aux_dscritic = "Nao é possível cancelar o contrato. Existe " + 
                               "um processo de análise deste contrato em andamento".
                END.
          END.
          
        IF  aux_dscritic <> ""  THEN
            UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.

        IF  AVAILABLE crawlim   THEN 
            ASSIGN crawlim.insitlim = 3.



        /* No cancelamento do contrato, busco as propostas de manutencao e cancelo */
        FOR EACH crablim WHERE crablim.cdcooper = par_cdcooper AND
                               crablim.nrdconta = par_nrdconta AND
                               crablim.tpctrlim = 3            AND
                               crablim.nrctrmnt = par_nrctrlim 
                               NO-LOCK:
                       
            DO aux_contador = 1 TO 10:
    
               ASSIGN aux_dscritic = "".

               FIND crawlim WHERE RECID(crawlim) = RECID(crablim)
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF  NOT AVAILABLE crawlim  THEN 
                   IF  LOCKED crawlim  THEN
                       DO:
                           aux_dscritic = "Registro de contrato sendo " +
                                          "alterado. Tente Novamente.".
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                   ELSE
                       ASSIGN aux_dscritic = "Registro de contrato nao " +
                                             "encontrado.".
                                             
               LEAVE. 

            END.   
    
            /* Adicinando tratamento para impedir cancelamento quando proposta estiver na IBRATAN */
            IF aux_dscritic = "" THEN
              DO:
                IF crawlim.insitlim = 1 AND crawlim.insitest = 2 THEN
                  DO:
                    aux_dscritic = "Nao é possível cancelar o contrato. Existe " + 
                                   "um processo de análise deste contrato em andamento".
                  END.
                ELSE
                  /* Adicinando tratamento para impedir cancelamento quando proposta estiver na IBRATAN */
                  IF crawlim.insitlim = 1 AND crawlim.insitapr = 8 THEN
                    DO:
                      aux_dscritic = "Nao é possível cancelar o contrato. Existe " + 
                                     "um processo de análise deste contrato em andamento".
                    END.
              END.
    
            IF  aux_dscritic <> ""  THEN
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
           
            ASSIGN crawlim.insitlim = 3.
        END.
           
        FIND CURRENT crawlim NO-LOCK NO-ERROR.

        RELEASE crawlim.
           
        FIND CURRENT craplim NO-LOCK NO-ERROR.

        RELEASE craplim.

        /*AWAE: Registrar o cancelamento na tabela de histórico. */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        RUN STORED-PROCEDURE pc_gravar_hist_alt_limite                  
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* Codigo da Cooperativa */ 
                                            ,INPUT par_nrdconta  /* Numero da Conta Corrente */
                                            ,INPUT par_nrctrlim  /* Número do contrato de Limite */
                                            ,INPUT 3             /* Tipo de Contrato */
                                            ,"CANCELAMENTO"      /* Descriçao do Motivo */
                                            ,OUTPUT 0            /* Código da Crítica */
                                            ,OUTPUT "").         /* Descriçao da Crítica */

        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_gravar_hist_alt_limite
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        /* Se retornou erro */
        ASSIGN aux_dscritic = ""
               aux_dscritic = pc_gravar_hist_alt_limite.pr_dscritic WHEN pc_gravar_hist_alt_limite.pr_dscritic <> ?.
        IF  aux_dscritic <> "" THEN          
          UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Final da transacao **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic= ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Nao foi possivel cancelar " +
                                                  "o limite.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,          /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                END.
            ELSE
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

/****************************************************************************/
/*          Efetuar a exclusao de um limite de desconto de titulos          */
/****************************************************************************/
PROCEDURE efetua_exclusao_limite:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE        NO-UNDO.
    DEF VAR aux_flgderro AS LOGI        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Excluir limite " + STRING(par_nrctrlim) +
                              " de desconto de titulos.".
                              
    TRANS_EXCLUSAO:
    DO TRANSACTION ON ERROR UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO:

        DO aux_contador = 1 TO 10:
    
            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 3            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplim   THEN 
                IF   LOCKED craplim   THEN
                     DO:
                        aux_dscritic = "Registro de titulos sendo" +
                                       " alterado. Tente Novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                     END.
                ELSE
                     DO:            
                         ASSIGN aux_dscritic = "Registro de limites nao " +
                                               "encontrado.".
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.

        END. /* Final do DO .. TO */    
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                LEAVE TRANS_EXCLUSAO.  
            END.
        
        IF  craplim.insitlim <> 1   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O contrato DEVE estar em ESTUDO.".
                          
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                  
                ASSIGN aux_flgderro = TRUE.
                
                LEAVE TRANS_EXCLUSAO.
            END.
        
        DO aux_contador = 1 TO 10:
    
            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                               crapprp.nrdconta = craplim.nrdconta   AND
                               crapprp.nrctrato = craplim.nrctrlim   AND
                               crapprp.tpctrato = 3
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                              
            IF   NOT AVAILABLE crapprp   THEN 
                 DO:
                     IF   LOCKED crapprp   THEN
                          DO:
                             aux_dscritic = "Registro de propostas sendo" +
                                            " alterado. Tente Novamente.".
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                          END.
                     ELSE
                          DO:
                             aux_dscritic = "Registro de propostas nao " +
                                            "encontrado.".
                             LEAVE.
                          END.
                 END.
            aux_dscritic = "".
            LEAVE.
        END. /* Final do DO .. TO */
    
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN aux_flgderro = TRUE.
                
                LEAVE TRANS_EXCLUSAO.  
            END.            
            
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper       AND
                               crapavt.tpctrato = 8                  AND
                               crapavt.nrdconta = craplim.nrdconta   AND
                               crapavt.nrctremp = craplim.nrctrlim   
                               EXCLUSIVE-LOCK:
           DELETE crapavt.
        END.
   
        IF  craplim.nrctaav1 <> 0 THEN
            DO:
                 FOR EACH crapavl WHERE 
                          crapavl.cdcooper = par_cdcooper       AND
                          crapavl.nrdconta = craplim.nrctaav1   AND
                          crapavl.nrctravd = craplim.nrctrlim   AND
                          crapavl.tpctrato = 8                  EXCLUSIVE-LOCK:
                     DELETE crapavl.
                 END.
            END.
  
        IF  craplim.nrctaav2 <> 0 THEN
            DO:
                 FOR EACH crapavl WHERE 
                          crapavl.cdcooper = par_cdcooper       AND
                          crapavl.nrdconta = craplim.nrctaav2   AND
                          crapavl.nrctravd = craplim.nrctrlim   AND
                          crapavl.tpctrato = 8                  EXCLUSIVE-LOCK:
                     DELETE crapavl.
                 END.
            END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT craplim.idcobope
                                              ,INPUT 0
                                              ,INPUT 0
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic
                WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
            END.

        DELETE craplim.
        DELETE crapprp.
           
    END. /* Final da transacao */
    
    IF  aux_flgderro  THEN
        DO:
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

/****************************************************************************/
/*                  Buscar borderos de uma conta informada                  */
/****************************************************************************/
PROCEDURE busca_borderos:
    
    DEF INPUT PARAM par_cdcooper AS INTE        NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-bordero_tit.
    
    DEF VAR aux_flglibch AS LOGICAL             NO-UNDO.
    DEF VAR aux_qttottit AS DECI                NO-UNDO.
    DEF VAR aux_vltottit AS DECI                NO-UNDO.
    
    EMPTY TEMP-TABLE tt-bordero_tit.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapbdt WHERE crapbdt.cdcooper = par_cdcooper   AND
                           crapbdt.nrdconta = par_nrdconta   NO-LOCK
                           BY crapbdt.nrborder DESCENDING:

        /* 
            Borderos liberados ate 90 dias 
            Borderos liberados a mais de 90 dias com titulos pendentes 
            Todos os borderos nao liberados
        */    
        IF  crapbdt.dtlibbdt <> ?  THEN
            IF (crapbdt.dtlibbdt < par_dtmvtolt - 90) AND
                crapbdt.insitbdt = 4                  THEN  
                NEXT.

		 IF crapbdt.dtmvtolt <> ?  THEN
            IF (crapbdt.dtmvtolt <= par_dtmvtolt - 120) AND
               (crapbdt.insitbdt = 1 OR crapbdt.insitbdt = 2) THEN
                NEXT.

        ASSIGN aux_qttottit = 0
               aux_vltottit = 0.
               
        FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper     AND
                               craptdb.nrborder = crapbdt.nrborder AND
                               craptdb.nrdconta = crapbdt.nrdconta NO-LOCK:
        
        
            ASSIGN aux_qttottit = aux_qttottit + 1
                   aux_vltottit = aux_vltottit + craptdb.vltitulo.

        END.
        
        CREATE tt-bordero_tit.
        ASSIGN tt-bordero_tit.dtmvtolt = crapbdt.dtmvtolt
               tt-bordero_tit.nrborder = crapbdt.nrborder
               tt-bordero_tit.nrctrlim = crapbdt.nrctrlim
               tt-bordero_tit.qtcompln = aux_qttottit 
               tt-bordero_tit.vlcompcr = aux_vltottit
               tt-bordero_tit.dssitbdt = IF crapbdt.insitbdt = 1 THEN
                                            "EM ESTUDO"
                                         ELSE 
                                         IF crapbdt.insitbdt = 2 THEN
                                            "ANALISADO"
                                         ELSE 
                                         IF crapbdt.insitbdt = 3 THEN
                                            "LIBERADO"
                                         ELSE
                                         IF crapbdt.insitbdt = 4 THEN
                                            "LIQUIDADO"
                                         ELSE
                                            "PROBLEMA".
                                            

    END.  /*  Fim da leitura do crapbdt  */
    
    RETURN "OK".
    
END PROCEDURE. 


/*****************************************************************************/
/*        Buscar titulos de um determinado bordero a partir da craptdb       */
/*****************************************************************************/
PROCEDURE busca_titulos_bordero:
                                          
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tits_do_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_bordero_restricoes.

    DEF VAR aux_nossonum AS CHAR         NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dsctit_bordero_restricoes.
    EMPTY TEMP-TABLE tt-tits_do_bordero.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nossonum = "".
    
    /* Titulos contidos no  bordero */ 
    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrborder = par_nrborder AND
                           craptdb.nrdconta = par_nrdconta 
                           NO-LOCK:
                    
        /* Busca dados do boleto de cobranca */ 
        FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto
                           NO-LOCK NO-ERROR.
                           
                                                        
        /* Verificar tipo de convenio  */ 
        FIND crapcco WHERE crapcco.cdcooper = craptdb.cdcooper AND
                           crapcco.nrconven = craptdb.nrcnvcob            
                           NO-LOCK NO-ERROR.
                           
        IF  crapcco.flgregis = FALSE THEN
            DO:
                IF   crapcco.flgutceb  THEN   /* 7 digitos */
                     DO:
                         FIND crapceb WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                            crapceb.nrdconta = crapcob.nrdconta AND
                                            crapceb.nrconven = crapcob.nrcnvcob 
                                            NO-LOCK NO-ERROR.
                                            
                         ASSIGN aux_nossonum = STRING(crapcob.nrcnvcob,"9999999") +
                                               STRING(INT(SUBSTR(TRIM(STRING(
                                                   crapceb.nrcnvceb, "zzzz9"))
                                                   ,1,4)),"9999") +                                               
                                               STRING(crapcob.nrdocmto,"999999").
                     END.
                ELSE      /* 6 digitos */  
                     ASSIGN aux_nossonum = STRING(crapcob.nrdconta,"99999999") + 
                                           STRING(crapcob.nrdocmto,"999999999").
            END.
        ELSE
            ASSIGN aux_nossonum = crapcob.nrnosnum.
        
        /* Busca os dados do Sacado */ 
        FIND crapsab WHERE crapsab.cdcooper = craptdb.cdcooper AND
                           crapsab.nrdconta = craptdb.nrdconta AND
                           crapsab.nrinssac = craptdb.nrinssac 
                           NO-LOCK NO-ERROR.

        CREATE tt-tits_do_bordero.
        ASSIGN tt-tits_do_bordero.nrdctabb = craptdb.nrdctabb
               tt-tits_do_bordero.nrcnvcob = craptdb.nrcnvcob
               tt-tits_do_bordero.nrinssac = craptdb.nrinssac 
               tt-tits_do_bordero.cdbandoc = craptdb.cdbandoc
               tt-tits_do_bordero.nrdconta = craptdb.nrdconta
               tt-tits_do_bordero.nrdocmto = craptdb.nrdocmto
               tt-tits_do_bordero.dtvencto = craptdb.dtvencto
               tt-tits_do_bordero.dtlibbdt = craptdb.dtlibbdt
               tt-tits_do_bordero.nossonum = aux_nossonum
               tt-tits_do_bordero.vltitulo = craptdb.vltitulo
               tt-tits_do_bordero.vlliquid = craptdb.vlliquid
               tt-tits_do_bordero.nmsacado = crapsab.nmdsacad
               tt-tits_do_bordero.insittit = craptdb.insittit
               tt-tits_do_bordero.flgregis = crapcob.flgregis.
               
        /*  Leitura das restricoes para o titulo */
        RUN busca_restricoes (INPUT par_cdcooper,
                              INPUT par_nrborder,
                              INPUT craptdb.cdbandoc,
                              INPUT craptdb.nrdctabb,
                              INPUT craptdb.nrcnvcob,
                              INPUT craptdb.nrdconta,
                              INPUT craptdb.nrdocmto,
                              OUTPUT TABLE tt-dsctit_bordero_restricoes).

    END.  /*  Fim do FOR EACH  */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/* PROCEDURE interna que monta o cpf usado para lista de titulos do bordero  */
/*****************************************************************************/
PROCEDURE pi_monta_cpfcgc:

    DEF  INPUT PARAM par_nrcpfcgc AS INTE NO-UNDO.
    
    DEF OUTPUT PARAM par_dscpfcgc AS CHAR NO-UNDO.

    DEF VAR aux_stsnrcal AS LOGICAL NO-UNDO.    
    DEF VAR h-b1wgen9999 AS HANDLE  NO-UNDO.
    
    ASSIGN par_dscpfcgc = "".
    
    IF   LENGTH(STRING(crapcec.nrcpfcgc)) > 11   THEN
         DO:
             ASSIGN par_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                    par_dscpfcgc = STRING(par_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

             RETURN.
         END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN "NOK".
        
    RUN valida-cpf IN h-b1wgen9999 (INPUT par_nrcpfcgc,
                                   OUTPUT aux_stsnrcal).
    
    DELETE PROCEDURE h-b1wgen9999.
    
    IF   aux_stsnrcal   THEN
         ASSIGN par_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999")
                par_dscpfcgc = STRING(par_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN par_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                par_dscpfcgc = STRING(par_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

    RETURN "OK".
    
END PROCEDURE.

/*****************************************************************************/
/*        Buscar restricoes de um determinado bordero ou titulo              */
/*****************************************************************************/
PROCEDURE busca_restricoes:
    
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdbandoc AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrcnvcob AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_bordero_restricoes.
    
    /* 
        nao dar empty temp-table pois ela fica na memoria para utilizacao
        na visualizacao dos titulos do bordero
    */
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
    FOR EACH crapabt WHERE crapabt.cdcooper = par_cdcooper AND
                           crapabt.nrborder = par_nrborder AND
                           crapabt.cdbandoc = par_cdbandoc AND
                           crapabt.nrdctabb = par_nrdctabb AND
                           crapabt.nrcnvcob = par_nrcnvcob AND
                           crapabt.nrdconta = par_nrdconta AND
                           crapabt.nrdocmto = par_nrdocmto NO-LOCK:
                                              
        CREATE tt-dsctit_bordero_restricoes.
        ASSIGN tt-dsctit_bordero_restricoes.nrborder = crapabt.nrborder
               tt-dsctit_bordero_restricoes.nrdocmto = crapabt.nrdocmto
               tt-dsctit_bordero_restricoes.dsrestri = crapabt.dsrestri
               tt-dsctit_bordero_restricoes.nrseqdig = crapabt.nrseqdig
               tt-dsctit_bordero_restricoes.flaprcoo = crapabt.flaprcoo
               tt-dsctit_bordero_restricoes.dsdetres = crapabt.dsdetres.
                                            
    END.  
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/*                  Buscar dados de um determinado bordero                   */
/*****************************************************************************/
PROCEDURE busca_dados_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_bordero.
    
    DEF VAR aux_cdtipdoc AS INTEGER                         NO-UNDO.
    DEF VAR aux_nrctrlim AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_bordero.
                         
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    

    FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND
                       crapbdt.nrborder = par_nrborder NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdt  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Registro de Bordero nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).            
            
            RETURN "NOK".
        END.
        
    IF  par_cddopcao = "N"   THEN
        DO:  
            IF  crapbdt.insitbdt > 2   THEN
                DO:
                    ASSIGN aux_cdcritic = 0.
                           aux_dscritic = "O bordero deve estar na situacao " +
                                          "EM ESTUDO ou ANALISADO.".
                                          
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                 
                    RETURN "NOK".                    
                END.
        END.
    ELSE
    IF  par_cddopcao = "L"  THEN
        DO:
            IF   crapbdt.insitbdt <> 2   THEN
                 DO:
                     ASSIGN aux_cdcritic = 0.
                            aux_dscritic = "O bordero deve estar" +
                                           " na situacao ANALISADO.".
          
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                 
                     RETURN "NOK".                
                 END.
        END.
    ELSE
    IF  par_cddopcao = "I"  THEN
        DO:  
            IF  crapbdt.insitbdt = 1  THEN  /* EM ESTUDO */ 
                DO:
                    ASSIGN aux_cdcritic = 0.
                           aux_dscritic = "O bordero deve estar na situacao " +
                                          "ANALISADO ou LIBERADO.".
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    RETURN "NOK".                    
                END.
        END.
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                       crapldc.cddlinha = crapbdt.cddlinha   AND
                       crapldc.tpdescto = 3 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapldc  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de linha " +
                                  "de desconto nao encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    /* Documentos computados ......................................... */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                       craplot.dtmvtolt = crapbdt.dtmvtolt   AND
                       craplot.cdagenci = crapbdt.cdagenci   AND
                       craplot.cdbccxlt = crapbdt.cdbccxlt   AND
                       craplot.nrdolote = crapbdt.nrdolote   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craplot   THEN
         DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Registro de Lote nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            RETURN "NOK".
         END.
         
    IF  par_cddopcao = "L" OR par_cddopcao = "N"  THEN
        DO:
            IF  craplot.qtinfoln <> craplot.qtcompln   OR
                craplot.vlinfodb <> craplot.vlcompdb   OR
                craplot.vlinfocr <> craplot.vlcompcr   THEN
                DO:
                    ASSIGN aux_cdcritic = 0.
                          aux_dscritic = "O lote do bordero nao esta' fechado.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
                END.
        END.

    FIND crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                       crawlim.nrdconta = par_nrdconta AND
                       crawlim.tpctrlim = 3            AND
                       crawlim.nrctrlim = crapbdt.nrctrlim
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crawlim  THEN
        IF  crawlim.nrctrmnt > 0  THEN
            ASSIGN aux_nrctrlim = crawlim.nrctrmnt.
        ELSE
            ASSIGN aux_nrctrlim = crapbdt.nrctrlim.
    ELSE
        ASSIGN aux_nrctrlim = crapbdt.nrctrlim.

    CREATE tt-dsctit_dados_bordero.
    /* Operadores ............................................... */
    FIND crapope WHERE crapope.cdcooper = par_cdcooper      AND
                       crapope.cdoperad = crapbdt.cdoperad  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapope   THEN
         ASSIGN tt-dsctit_dados_bordero.dsopedig = 
                                STRING(crapbdt.cdoperad) + "- NAO CADASTRADO".
    ELSE
         ASSIGN tt-dsctit_dados_bordero.dsopedig = 
                                ENTRY(1,crapope.nmoperad," ").

    IF  crapbdt.dtlibbdt <> ?   THEN             /*  Quem liberou  */
        DO:
            FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                               crapope.cdoperad = crapbdt.cdopelib
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapope  THEN
                ASSIGN tt-dsctit_dados_bordero.dsopelib = 
                                STRING(crapbdt.cdopelib) + "- NAO CADASTRADO".
            ELSE
                ASSIGN tt-dsctit_dados_bordero.dsopelib = 
                                ENTRY(1,crapope.nmoperad," ").
        END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND         
                       craptab.nmsistem = "CRED"        AND         
                       craptab.tptabela = "GENERI"      AND         
                       craptab.cdempres = 00            AND         
                       craptab.cdacesso = "DIGITALIZA"  AND
                       craptab.tpregist = 4 
                       NO-LOCK NO-ERROR.    

    IF  NOT AVAIL craptab THEN
        DO:
            ASSIGN aux_dscritic = 'Falta registro na Tabela "DIGITALIZA". '.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                    
            RETURN "NOK".
        END. 

    ASSIGN aux_cdtipdoc = INTE(ENTRY(3,craptab.dstextab,";")).
    
    ASSIGN tt-dsctit_dados_bordero.nrborder = crapbdt.nrborder
           tt-dsctit_dados_bordero.nrctrlim = aux_nrctrlim
           tt-dsctit_dados_bordero.insitbdt = crapbdt.insitbdt
           tt-dsctit_dados_bordero.txmensal = crapbdt.txmensal
           tt-dsctit_dados_bordero.dtlibbdt = crapbdt.dtlibbdt
           tt-dsctit_dados_bordero.txdiaria = crapldc.txdiaria
           tt-dsctit_dados_bordero.txjurmor = crapldc.txjurmor
           tt-dsctit_dados_bordero.qttitulo = craplot.qtcompln
           tt-dsctit_dados_bordero.vltitulo = craplot.vlcompcr
           tt-dsctit_dados_bordero.dspesqui = 
                            STRING(crapbdt.dtmvtolt,"99/99/9999") + "-" +
                            STRING(crapbdt.cdagenci,"999")        + "-" +
                            STRING(crapbdt.cdbccxlt,"999")        + "-" +
                            STRING(crapbdt.nrdolote,"999999")     + "-" +
                            STRING(crapbdt.hrtransa,"HH:MM:SS")
           tt-dsctit_dados_bordero.dsdlinha = STRING(crapbdt.cddlinha,"999") + 
                                              "-" + crapldc.dsdlinha
           tt-dsctit_dados_bordero.flgdigit = crapbdt.flgdigit
           tt-dsctit_dados_bordero.cdtipdoc = aux_cdtipdoc.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*          Buscar dados do Principal (@) da rotina Desconto de Titulos      */
/*****************************************************************************/
PROCEDURE busca_dados_dsctit:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-desconto_titulos.
    
    DEF VAR h-b1wgen0001 AS HANDLE NO-UNDO.
    DEF VAR aux_perrenov AS INTEGER                         NO-UNDO.
    DEF VAR aux_difdays AS INTEGER                          NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-desconto_titulos.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados de desconto de titulos.".
    
    RUN sistema/generico/procedures/b1wgen0001.p
        PERSISTENT SET h-b1wgen0001.
        
    IF  VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
            RUN ver_capital IN h-b1wgen0001(INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT 0, /* cod-agencia */
                                            INPUT 0, /* nro-caixa   */
                                            INPUT 0,
                                            INPUT par_dtmvtolt,
                                            INPUT "desconto_titulos",
                                            INPUT par_idorigem, /* AYLLOS */
                                            OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:  
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
                    
                    DELETE PROCEDURE h-b1wgen0001.
                    RETURN "NOK".
                END.            
           DELETE PROCEDURE h-b1wgen0001.     
    END.
    
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper   AND
                             craplim.nrdconta = par_nrdconta   AND
              /* titulos */  craplim.tpctrlim = 3              AND
                             craplim.insitlim = 2  /* ATIVO */ NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplim   THEN 
         DO:
             CREATE tt-desconto_titulos.
             ASSIGN tt-desconto_titulos.nrctrlim = 0
                    tt-desconto_titulos.dtinivig = ?
                    tt-desconto_titulos.qtdiavig = 0
                    tt-desconto_titulos.vllimite = 0
                    tt-desconto_titulos.qtrenova = 0
                    tt-desconto_titulos.dsdlinha = ""
                    tt-desconto_titulos.vlutiliz = 0
                    tt-desconto_titulos.qtutiliz = 0
                    tt-desconto_titulos.cddopcao = 2
                    tt-desconto_titulos.dtrenova = ?
                    tt-desconto_titulos.perrenov = 0
                    tt-desconto_titulos.cddlinha = 0
                    tt-desconto_titulos.flgstlcr = ?
                    tt-desconto_titulos.dtultmnt = ?.
                    
             FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper AND
                                     craptdb.nrdconta = par_nrdconta AND
                                     craptdb.insittit =  4)
                                    OR
                                    (craptdb.cdcooper = par_cdcooper AND
                                     craptdb.nrdconta = par_nrdconta AND
                                     craptdb.insittit = 2            AND
                                     craptdb.dtdpagto = par_dtmvtolt)
                                    NO-LOCK:

                 FIND FIRST crapcco WHERE crapcco.cdcooper = craptdb.cdcooper AND
                                          crapcco.nrconven = craptdb.nrcnvcob
                                                                NO-LOCK NO-ERROR.
                 
                 ASSIGN tt-desconto_titulos.vlutiliz = tt-desconto_titulos.vlutiliz + craptdb.vlsldtit
                        tt-desconto_titulos.qtutiliz = tt-desconto_titulos.qtutiliz + 1
                        tt-desconto_titulos.vlutilcr = tt-desconto_titulos.vlutilcr +
                                                       (IF crapcco.flgregis = TRUE THEN craptdb.vlsldtit ELSE 0)
                        tt-desconto_titulos.qtutilcr = tt-desconto_titulos.qtutilcr + 
                                                       (IF crapcco.flgregis = TRUE THEN 1 ELSE 0)
                        tt-desconto_titulos.vlutilsr = tt-desconto_titulos.vlutilsr + 
                                                       (IF crapcco.flgregis = FALSE THEN craptdb.vlsldtit ELSE 0)
                        tt-desconto_titulos.qtutilsr = tt-desconto_titulos.qtutilsr + 
                                                       (IF crapcco.flgregis = FALSE THEN 1 ELSE 0).

             END.  /*  Fim do FOR EACH craptdb  */                    
         END.
    ELSE
         DO:
             CREATE tt-desconto_titulos.
             FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                                crapldc.cddlinha = craplim.cddlinha   AND
                                crapldc.tpdescto = 3
                                NO-LOCK NO-ERROR.
           
             IF   NOT AVAILABLE crapldc   THEN
                  tt-desconto_titulos.dsdlinha = STRING(craplim.cddlinha) 
                                                 + " - " + "NAO CADASTRADA".
             ELSE
                  tt-desconto_titulos.dsdlinha = STRING(crapldc.cddlinha) 
                                                 + " - " + crapldc.dsdlinha.
                  tt-desconto_titulos.cddlinha = crapldc.cddlinha.
                  tt-desconto_titulos.flgstlcr = crapldc.flgstlcr.
                                                 
             aux_difdays = craplim.dtfimvig - par_dtmvtolt.
             IF aux_difdays > 15 OR aux_difdays < -60  THEN
                  aux_perrenov = 0.
             ELSE
                  aux_perrenov = 1.
                 
             ASSIGN tt-desconto_titulos.nrctrlim = craplim.nrctrlim
                    tt-desconto_titulos.dtinivig = craplim.dtinivig
                    tt-desconto_titulos.qtdiavig = craplim.qtdiavig
                    tt-desconto_titulos.vllimite = craplim.vllimite
                    tt-desconto_titulos.qtrenova = craplim.qtrenova
                    tt-desconto_titulos.cddopcao = 1
                    tt-desconto_titulos.dtrenova = craplim.dtrenova
                    tt-desconto_titulos.perrenov = aux_perrenov.
                    
             FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper AND
                                     craptdb.nrdconta = par_nrdconta AND
                                     craptdb.insittit =  4)
                                    OR
                                    (craptdb.cdcooper = par_cdcooper AND
                                     craptdb.nrdconta = par_nrdconta AND
                                     craptdb.insittit = 2            AND
                                     craptdb.dtdpagto = par_dtmvtolt)
                                    NO-LOCK,
                 FIRST crapcco WHERE crapcco.cdcooper = craptdb.cdcooper AND
                                     crapcco.nrconven = craptdb.nrcnvcob
                                                             NO-LOCK:

                 ASSIGN tt-desconto_titulos.vlutiliz = tt-desconto_titulos.vlutiliz + craptdb.vlsldtit
                        tt-desconto_titulos.qtutiliz = tt-desconto_titulos.qtutiliz + 1
                        tt-desconto_titulos.vlutilcr = tt-desconto_titulos.vlutilcr +
                                                       (IF crapcco.flgregis = TRUE THEN craptdb.vlsldtit ELSE 0)
                        tt-desconto_titulos.qtutilcr = tt-desconto_titulos.qtutilcr + 
                                                       (IF crapcco.flgregis = TRUE THEN 1 ELSE 0)
                        tt-desconto_titulos.vlutilsr = tt-desconto_titulos.vlutilsr + 
                                                       (IF crapcco.flgregis = FALSE THEN craptdb.vlsldtit ELSE 0)
                        tt-desconto_titulos.qtutilsr = tt-desconto_titulos.qtutilsr + 
                                                       (IF crapcco.flgregis = FALSE THEN 1 ELSE 0).

             END.  /*  Fim do FOR EACH craptdb  */                    

             FOR EACH crawlim WHERE crawlim.cdcooper = par_cdcooper     AND
                                    crawlim.nrdconta = par_nrdconta     AND
                                    crawlim.tpctrlim = 3                AND
                                    crawlim.nrctrmnt = craplim.nrctrlim AND
                                    crawlim.insitlim = 2
                                    NO-LOCK
                                    BY crawlim.dtpropos DESCENDING:
                 ASSIGN tt-desconto_titulos.dtultmnt = crawlim.dtpropos.
                 LEAVE.
         END.

         END.

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
/**            Buscar parametros gerais de desconto de titulo - TAB052       **/
/******************************************************************************/
PROCEDURE busca_parametros_dsctit:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_tpcobran AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.  


    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit.
    DEF OUTPUT PARAM TABLE FOR tt-dados_cecred_dsctit.   

    DEF VAR aux_cdacesso AS CHAR                            NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit.
    EMPTY TEMP-TABLE tt-dados_cecred_dsctit.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF par_inpessoa = 1 THEN /* Pessoa Física */
    DO:
    IF par_tpcobran = TRUE THEN /* Cobrança com Regisro */
    aux_cdacesso = "LIMDESCTITCRPF".
    ELSE
      aux_cdacesso = "LIMDESCTITPF".        
    END.
    ELSE
  DO: 
    IF par_inpessoa = 2 THEN /* Pessoa Jurídica */
    DO:   
      IF par_tpcobran = TRUE THEN /* Cobrança com Regisro */
      aux_cdacesso = "LIMDESCTITCRPJ".
    ELSE
        aux_cdacesso = "LIMDESCTITPJ".
    END.    
    END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "USUARI"        AND
                       craptab.cdempres = 11              AND
                       craptab.cdacesso = aux_cdacesso    AND
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        DO:
           CREATE tt-dsctit.
           ASSIGN tt-dsctit.vllimite = DECI(ENTRY(01,craptab.dstextab,";"))
                  tt-dsctit.vlconsul = DECI(ENTRY(02,craptab.dstextab,";"))
                  tt-dsctit.vlmaxsac = DECI(ENTRY(03,craptab.dstextab,";"))
                  tt-dsctit.vlminsac = DECI(ENTRY(04,craptab.dstextab,";"))
                  tt-dsctit.qtremcrt = INTE(ENTRY(05,craptab.dstextab,";"))
                  tt-dsctit.qttitprt = INTE(ENTRY(06,craptab.dstextab,";"))
                  tt-dsctit.qtrenova = INTE(ENTRY(07,craptab.dstextab,";"))
                  tt-dsctit.qtdiavig = INTE(ENTRY(08,craptab.dstextab,";"))
                  tt-dsctit.qtprzmin = INTE(ENTRY(09,craptab.dstextab,";"))
                  tt-dsctit.qtprzmax = INTE(ENTRY(10,craptab.dstextab,";"))
                  tt-dsctit.qtminfil = INTE(ENTRY(11,craptab.dstextab,";"))
                  tt-dsctit.nrmespsq = INTE(ENTRY(12,craptab.dstextab,";"))
                  /*tt-dsctit.pctitemi = DECI(ENTRY(13,craptab.dstextab,";"))*/
                  tt-dsctit.pctolera = DECI(ENTRY(14,craptab.dstextab,";"))
                  tt-dsctit.pcdmulta = DECI(ENTRY(15,craptab.dstextab,";"))
                  tt-dsctit.cardbtit = INTE(ENTRY(31,craptab.dstextab,";"))
                  tt-dsctit.pcnaopag = DECI(ENTRY(33,craptab.dstextab,";"))
                  tt-dsctit.qtnaopag = INTE(ENTRY(34,craptab.dstextab,";"))
                  tt-dsctit.pcmxctip = DECI(ENTRY(49,craptab.dstextab,";"))
                  tt-dsctit.qtprotes = INTE(ENTRY(35,craptab.dstextab,";")).
           
           CREATE tt-dados_cecred_dsctit.
           ASSIGN tt-dados_cecred_dsctit.vllimite = DECI(ENTRY(16,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.vlconsul = DECI(ENTRY(17,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.vlmaxsac = DECI(ENTRY(18,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.vlminsac = DECI(ENTRY(19,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtremcrt = INTE(ENTRY(20,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qttitprt = INTE(ENTRY(21,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtrenova = INTE(ENTRY(22,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtdiavig = INTE(ENTRY(23,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtprzmin = INTE(ENTRY(24,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtprzmax = INTE(ENTRY(25,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtminfil = INTE(ENTRY(26,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.nrmespsq = INTE(ENTRY(27,craptab.dstextab,";"))
                  /*tt-dados_cecred_dsctit.pctitemi = DECI(ENTRY(28,craptab.dstextab,";"))*/
                  tt-dados_cecred_dsctit.pctolera = DECI(ENTRY(29,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.pcdmulta = DECI(ENTRY(30,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.cardbtit = INTE(ENTRY(32,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.pcnaopag = DECI(ENTRY(36,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtnaopag = INTE(ENTRY(37,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.pcmxctip = DECI(ENTRY(65,craptab.dstextab,";"))
                  tt-dados_cecred_dsctit.qtprotes = INTE(ENTRY(38,craptab.dstextab,";")).
              
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de parametros de desconto" +
                                  " de titulos nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).                
                            
            RETURN "NOK".
        END.
        
    RETURN "OK".
        
END PROCEDURE.

/******************************************************************************/
/**            Gravar parametros gerais de desconto de titulo - TAB052       **/
/******************************************************************************/
PROCEDURE grava_parametros_dsctit:

    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                        NO-UNDO. 
    DEF INPUT PARAM par_tpcobran AS LOG                         NO-UNDO.
   
    DEF INPUT PARAM TABLE FOR tt-dados_dsctit.
    DEF INPUT PARAM TABLE FOR tt-dados_cecred_dsctit.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_cdacesso AS CHAR NO-UNDO.
    DEF VAR aux_cdacess2 AS CHAR NO-UNDO.

    DEF BUFFER b-craptab FOR craptab.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF par_tpcobran = TRUE THEN
      ASSIGN aux_cdacesso = "LIMDESCTITCR"
             aux_cdacess2 = "LIMDESCTIT".
    ELSE
      ASSIGN aux_cdacesso = "LIMDESCTIT"
             aux_cdacess2 = "LIMDESCTITCR".
    
    TRANS_1:
    DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN "NOK":

        /* Dez tentativas para alocar o registro */
        DO  aux_contador = 1 TO 10:

            FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "USUARI"        AND
                               craptab.cdempres = 11              AND
                               craptab.cdacesso = aux_cdacesso    AND
                               craptab.tpregist = 0            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.            
            
            IF   NOT AVAILABLE craptab   THEN
                 IF   LOCKED craptab   THEN
                      DO: 
                          IF aux_contador = 10 THEN
                             DO: 
                                ASSIGN aux_dscritic = "Registro de titulos sendo" +
                                                      " alterado. Tente Novamente.".
                                               
                                LEAVE.

                             END.
                          ELSE
                             NEXT.

                      END.
                 ELSE
                      DO:
                          ASSIGN aux_cdcritic = 55
                                 aux_dscritic = "".

                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                
                          UNDO TRANS_1, RETURN "NOK".
                          
                      END.

        END.  /*  Fim do DO .. TO  */
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                UNDO TRANS_1, RETURN "NOK".

            END.

        FIND FIRST tt-dados_dsctit NO-LOCK.
        FIND FIRST tt-dados_cecred_dsctit NO-LOCK.

        ASSIGN craptab.dstextab =   /* Operacional */
                                       STRING(tt-dados_dsctit.vllimite,"999999999.99")
                               + ";" + STRING(tt-dados_dsctit.vlconsul,"999999999.99")
                               + ";" + STRING(tt-dados_dsctit.vlmaxsac,"999999999.99")
                               + ";" + STRING(tt-dados_dsctit.vlminsac,"999999999.99") 
                               + ";" + STRING(tt-dados_dsctit.qtremcrt,"999")
                               + ";" + STRING(tt-dados_dsctit.qttitprt,"999")
                               + ";" + STRING(tt-dados_dsctit.qtrenova,"99")
                               + ";" + STRING(tt-dados_dsctit.qtdiavig,"9999")
                               + ";" + STRING(tt-dados_dsctit.qtprzmin,"999")
                               + ";" + STRING(tt-dados_dsctit.qtprzmax,"999")
                               + ";" + STRING(tt-dados_dsctit.qtminfil,"999")
                               + ";" + STRING(tt-dados_dsctit.nrmespsq,"99")
                               /*+ ";" + STRING(tt-dados_dsctit.pctitemi,"999")*/
                               + ";" + STRING(tt-dados_dsctit.pctolera,"999")
                               + ";" + STRING(tt-dados_dsctit.pcdmulta,"999.999999")
                                    /* CECRED */
                               + ";" + STRING(tt-dados_cecred_dsctit.vllimite,"999999999.99")
                               + ";" + STRING(tt-dados_cecred_dsctit.vlconsul,"999999999.99")
                               + ";" + STRING(tt-dados_cecred_dsctit.vlmaxsac,"999999999.99")
                               + ";" + STRING(tt-dados_cecred_dsctit.vlminsac,"999999999.99") 
                               + ";" + STRING(tt-dados_cecred_dsctit.qtremcrt,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qttitprt,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtrenova,"99")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtdiavig,"9999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtprzmin,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtprzmax,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtminfil,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.nrmespsq,"99")
                               /*+ ";" + STRING(tt-dados_cecred_dsctit.pctitemi,"999")*/
                               + ";" + STRING(tt-dados_cecred_dsctit.pctolera,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.pcdmulta,"999.999999")
                               /*carencia debito titulos vencidos*/
                               + ";" + STRING(tt-dados_dsctit.cardbtit,"999") 
                               + ";" + STRING(tt-dados_cecred_dsctit.cardbtit,"999")

                               + ";" + STRING(tt-dados_dsctit.pcnaopag,"999")
                               + ";" + STRING(tt-dados_dsctit.qtnaopag,"9999")
                               + ";" + STRING(tt-dados_dsctit.qtprotes,"9999")
                               + ";" + STRING(tt-dados_cecred_dsctit.pcnaopag,"999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtnaopag,"9999")
                               + ";" + STRING(tt-dados_cecred_dsctit.qtprotes,"9999").


        DO aux_contador = 1 TO 10:

            FIND b-craptab WHERE b-craptab.cdcooper = par_cdcooper    AND
                                 b-craptab.nmsistem = "CRED"          AND
                                 b-craptab.tptabela = "USUARI"        AND
                                 b-craptab.cdempres = 11              AND
                                 b-craptab.cdacesso = aux_cdacess2    AND
                                 b-craptab.tpregist = 0            
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

              IF  NOT AVAILABLE craptab   THEN
                  IF   LOCKED craptab   THEN
                      DO:
                          IF aux_contador = 10 THEN
                             DO:
                                 ASSIGN aux_dscritic = "Registro de titulos sendo" +
                                                       " alterado. Tente Novamente.".
                                 LEAVE.

                             END.
                          ELSE
                             NEXT.
                      END.
                 ELSE
                      DO:
                          ASSIGN aux_cdcritic = 55
                                 aux_dscritic = "".

                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                
                          UNDO TRANS_1, RETURN "NOK".
                          
                      END.
                                   
            
        END.

        ASSIGN ENTRY(01,b-craptab.dstextab,";") = STRING(tt-dados_dsctit.vllimite,"999999999.99")
               ENTRY(07,b-craptab.dstextab,";") = STRING(tt-dados_dsctit.qtrenova,"99")
               ENTRY(08,b-craptab.dstextab,";") = STRING(tt-dados_dsctit.qtdiavig,"9999")
               ENTRY(16,b-craptab.dstextab,";") = STRING(tt-dados_cecred_dsctit.vllimite,"999999999.99")
               ENTRY(22,b-craptab.dstextab,";") = STRING(tt-dados_cecred_dsctit.qtrenova,"99")
               ENTRY(23,b-craptab.dstextab,";") = STRING(tt-dados_cecred_dsctit.qtdiavig,"9999").
            
    END. /* Fim da Transacao */            
    
    FIND CURRENT craptab NO-LOCK.
    RELEASE craptab.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**       Bucar parametros de tarifas de desconto de titulo - TAB053         **/
/******************************************************************************/
PROCEDURE busca_tarifas_dsctit:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-tarifas_dsctit.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-tarifas_dsctit.

    DEF VAR aux_cdacesso AS CHAR                            NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "USUARI"        AND
                       craptab.cdempres = 11              AND
                       craptab.cdacesso = "TARDESCTIT"    AND
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        DO:
           CREATE tt-tarifas_dsctit.
           ASSIGN 
             tt-tarifas_dsctit.vltarctr = DECI(ENTRY(01,craptab.dstextab,";"))
             tt-tarifas_dsctit.vltarrnv = DECI(ENTRY(02,craptab.dstextab,";"))
             tt-tarifas_dsctit.vltarbdt = DECI(ENTRY(03,craptab.dstextab,";"))
             tt-tarifas_dsctit.vlttitcr = DECI(ENTRY(04,craptab.dstextab,";"))
             tt-tarifas_dsctit.vlttitsr = DECI(ENTRY(05,craptab.dstextab,";"))
             tt-tarifas_dsctit.vltrescr = DECI(ENTRY(06,craptab.dstextab,";"))
             tt-tarifas_dsctit.vltressr = DECI(ENTRY(07,craptab.dstextab,";")).
           
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de titulos de desconto de " +
                                  "titulos nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).                
                            
            RETURN "NOK".
        END.
        
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**       Gravar parametros de tarifas de desconto de titulo - TAB053        **/
/******************************************************************************/
PROCEDURE grava_tarifas_dsctit:

    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                        NO-UNDO. 

    DEF INPUT PARAM TABLE FOR tt-tarifas_dsctit.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_cdacesso AS CHAR NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    

    TRANS_1:
    DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN "NOK":

        /* Dez tentativas para alocar o registro */
        DO  aux_contador = 1 TO 10:

            FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "USUARI"        AND
                               craptab.cdempres = 11              AND
                               craptab.cdacesso = "TARDESCTIT"    AND
                               craptab.tpregist = 0            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.            
            
            IF   NOT AVAILABLE craptab   THEN
                 IF   LOCKED craptab   THEN
                      DO:
                          aux_dscritic = "Registro de tarifas sendo" +
                                         " alterado. Tente Novamente.".
                                         PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          ASSIGN aux_cdcritic = 55
                                 aux_dscritic = "".

                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                
                          UNDO TRANS_1, RETURN "NOK".
                          
                      END.

            FIND FIRST tt-tarifas_dsctit NO-LOCK NO-ERROR NO-WAIT.

            craptab.dstextab = STRING(tt-tarifas_dsctit.vltarctr,"999.99") + ";" +
                               STRING(tt-tarifas_dsctit.vltarrnv,"999.99") + ";" + 
                               STRING(tt-tarifas_dsctit.vltarbdt,"999.99") + ";" + 
                               STRING(tt-tarifas_dsctit.vlttitcr,"999.99") + ";" + 
                               STRING(tt-tarifas_dsctit.vlttitsr,"999.99") + ";" + 
                               STRING(tt-tarifas_dsctit.vltrescr,"999.99") + ";" + 
                               STRING(tt-tarifas_dsctit.vltressr,"999.99").

        END.  /*  Fim do DO .. TO  */
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                UNDO TRANS_1, RETURN "NOK".

            END.
            
    END. /* Fim da Transacao */            
    
    FIND CURRENT craptab NO-LOCK.
    RELEASE craptab.
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*                          USADAS NA LANBDT                                 */
/*****************************************************************************/
/*****************************************************************************/
/*              Busca titulos gerados por uma determinada conta              */
/*****************************************************************************/
PROCEDURE busca_titulos:
    
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tpcobran AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-titulos.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit_cr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-titulos.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    EMPTY TEMP-TABLE tt-dados_dsctit_cr.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".  

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE, /* COB.REGISTRADA */
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit_cr,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).
         
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT FALSE, /* COB.SEM REGISTRO */
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND 
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 3            AND
                             craplim.insitlim = 2            NO-LOCK NO-ERROR.

    /* Lista os titulos de uma determinada conta que ainda nao estejam pagos */
    /* Eh obrigatorio ter o sab cadastrado */
    FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                           crapcco.dsorgarq <> "PROTESTO"  AND
                          ((crapcco.flgregis = FALSE AND par_tpcobran = "S") OR
                           (crapcco.flgregis = TRUE  AND par_tpcobran = "R") OR
                           (par_tpcobran = "T")) NO-LOCK,                                               
        EACH crapceb WHERE crapceb.cdcooper = crapcco.cdcooper AND
                           crapceb.nrconven = crapcco.nrconven AND
                           crapceb.nrdconta = par_nrdconta     NO-LOCK,
        EACH crapcob WHERE crapcob.cdcooper = crapceb.cdcooper AND
                           crapcob.nrcnvcob = crapceb.nrconven AND
                           crapcob.nrdconta = crapceb.nrdconta AND
                           crapcob.dtdbaixa = ?                AND
                           crapcob.dtdpagto = ?                AND
                           crapcob.dtelimin = ?                AND
                           crapcob.dtvencto > par_dtmvtolt     AND
                           crapcob.incobran = 0 /* em aberto*/ NO-LOCK,
       FIRST crapsab WHERE crapsab.cdcooper = crapcob.cdcooper AND
                           crapsab.nrinssac = crapcob.nrinssac AND
                           crapsab.nrdconta = crapcob.nrdconta NO-LOCK:

        IF  crapcob.nrctasac <> 0  OR 
            crapcob.nrctremp <> 0  OR 
            crapcob.vltitulo  = 0  THEN
            NEXT.
/* Segundo Rafael nao deve mais efetuar esta validacao
        IF  crapcob.flgcbdda = TRUE AND
            crapcob.insitpro <> 3   THEN
            NEXT.
*/
        /* se titulo BB e cob. registrada, verificar conf. entrada */
        IF  crapcob.cdbandoc = 1 AND 
            crapcob.flgregis = TRUE THEN
            DO:
                IF  NOT CAN-FIND(FIRST crapret WHERE
                                       crapret.cdcooper = crapcob.cdcooper AND
                                       crapret.nrdconta = crapcob.nrdconta AND
                                       crapret.nrcnvcob = crapcob.nrcnvcob AND
                                       crapret.nrdocmto = crapcob.nrdocmto AND
                                       crapret.cdocorre = 2) THEN
                    NEXT.
            END.
        
        /* Se este titulo ja esta em um bordero e ele estiver pago, 
           a ser pago(liberado no bordero ou nao) */ 
        IF  CAN-FIND(FIRST craptdb WHERE
                           craptdb.cdcooper = crapcob.cdcooper AND
                           craptdb.cdbandoc = crapcob.cdbandoc AND
                           craptdb.nrdctabb = crapcob.nrdctabb AND
                           craptdb.nrcnvcob = crapcob.nrcnvcob AND
                           craptdb.nrdconta = crapcob.nrdconta AND
                           craptdb.nrdocmto = crapcob.nrdocmto AND
                           craptdb.insittit = 0) THEN
            NEXT.
                          
        IF  CAN-FIND(FIRST craptdb WHERE
                           craptdb.cdcooper = crapcob.cdcooper AND
                           craptdb.cdbandoc = crapcob.cdbandoc AND
                           craptdb.nrdctabb = crapcob.nrdctabb AND
                           craptdb.nrcnvcob = crapcob.nrcnvcob AND
                           craptdb.nrdconta = crapcob.nrdconta AND
                           craptdb.nrdocmto = crapcob.nrdocmto AND
                           craptdb.insittit = 2) THEN
            NEXT.

        IF  CAN-FIND(FIRST craptdb WHERE
                           craptdb.cdcooper = crapcob.cdcooper AND
                           craptdb.cdbandoc = crapcob.cdbandoc AND
                           craptdb.nrdctabb = crapcob.nrdctabb AND
                           craptdb.nrcnvcob = crapcob.nrcnvcob AND
                           craptdb.nrdconta = crapcob.nrdconta AND
                           craptdb.nrdocmto = crapcob.nrdocmto AND
                           craptdb.insittit = 4) THEN
            NEXT.      
              
        CREATE tt-titulos.
        /* Dados do crapcob */
        ASSIGN tt-titulos.cdbandoc = crapcob.cdbandoc
               tt-titulos.dsdoccop = crapcob.dsdoccop
               tt-titulos.dtmvtolt = crapcob.dtmvtolt
               tt-titulos.dtvencto = crapcob.dtvencto
               tt-titulos.idseqttl = crapcob.idseqttl
               tt-titulos.nmdsacad = crapsab.nmdsacad
               tt-titulos.nrcnvcob = crapcob.nrcnvcob
               tt-titulos.nrctrlim = craplim.nrctrlim
               tt-titulos.nrdctabb = crapcob.nrdctabb
               tt-titulos.nrdocmto = crapcob.nrdocmto
               tt-titulos.nrinssac = crapcob.nrinssac
               tt-titulos.vldescto = crapcob.vldescto
               tt-titulos.vldpagto = crapcob.vldpagto
               tt-titulos.vltitulo = crapcob.vltitulo
               tt-titulos.qtrenctr = craplim.qtrenctr
               tt-titulos.qtrenova = craplim.qtrenova
               tt-titulos.qtdiavig = craplim.qtdiavig
               tt-titulos.dtctrato = craplim.dtinivig
               tt-titulos.flgregis = crapcob.flgregis
               tt-titulos.tpcobran = IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc = 085  THEN
                                         "Coop. Emite"
                                     ELSE 
                                     IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc <> 085 THEN 
                                        "Banco emite"
                                     ELSE
                                     IF  tt-titulos.flgregis = FALSE THEN 
                                         "S/registro"
                                     ELSE
                                         " ".
    END. /* Final do FOR EACH */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*        Busca titulos de um determinado bordero a partir da craplot        */
/*****************************************************************************/
PROCEDURE busca_titulos_bordero_lote:
    
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    DEF OUTPUT PARAM TABLE FOR tt-titulos.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-titulos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
    /* Capa de lote */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                       craplot.dtmvtolt = par_dtmvtolt   AND
                       craplot.cdagenci = par_cdagenci   AND
                       craplot.cdbccxlt = par_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplot  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de lote nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    IF  craplot.tplotmov <> 34  THEN /* Descto de titulo */
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de lote deve ser 34 - Descto Titulos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND 
                       crapbdt.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdt  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de bordero nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    IF  par_cddopcao = "E"  THEN
        IF  crapbdt.insitbdt > 2   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                RETURN "NOK".
            END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND 
                       crapass.nrdconta = crapbdt.nrdconta NO-LOCK NO-ERROR.

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
                
            RETURN "NOK".

        END.
    
    FOR EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper AND
                           craptdb.nrborder = crapbdt.nrborder AND
                           craptdb.nrdconta = crapbdt.nrdconta NO-LOCK:
                                   
        FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapcob  THEN
            NEXT.
        
        FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper AND
                           crapsab.nrinssac = crapcob.nrinssac AND
                           crapsab.nrdconta = crapcob.nrdconta NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapsab  THEN
            NEXT.
        
        CREATE tt-titulos.
        ASSIGN tt-titulos.cdbandoc = crapcob.cdbandoc
               tt-titulos.dsdoccop = crapcob.dsdoccop
               tt-titulos.dtmvtolt = crapcob.dtmvtolt
               tt-titulos.dtvencto = crapcob.dtvencto
               tt-titulos.idseqttl = crapcob.idseqttl
               tt-titulos.nmdsacad = crapsab.nmdsacad
               tt-titulos.nrcnvcob = crapcob.nrcnvcob
               tt-titulos.nrctrlim = crapbdt.nrctrlim
               tt-titulos.nrdctabb = crapcob.nrdctabb
               tt-titulos.nrdocmto = crapcob.nrdocmto
               tt-titulos.nrinssac = crapcob.nrinssac
               tt-titulos.vldescto = crapcob.vldescto
               tt-titulos.vldpagto = crapcob.vldpagto
               tt-titulos.vltitulo = crapcob.vltitulo
               tt-titulos.nrdconta = crapass.nrdconta
               tt-titulos.nrborder = crapbdt.nrborder
               tt-titulos.flgregis = crapcob.flgregis
               tt-titulos.dssittit = IF craptdb.insittit = 0 THEN
                                        "Pendente"
                                     ELSE
                                     IF craptdb.insittit = 1 THEN
                                        "Resgatado"
                                     ELSE
                                     IF craptdb.insittit = 2 THEN
                                        "Pago"
                                     ELSE
                                     IF craptdb.insittit = 3 THEN
                                        "Vencido"
                                     ELSE
                                     IF craptdb.insittit = 4 THEN
                                        "Liberado"
                                     ELSE
                                        "------"
               tt-titulos.flgregis = crapcob.flgregis
               tt-titulos.tpcobran = IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc = 085  THEN
                                         "Coop. Emite"
                                     ELSE 
                                     IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc <> 085 THEN 
                                        "Banco emite"
                                     ELSE
                                     IF  tt-titulos.flgregis = FALSE THEN 
                                         "S/registro"
                                     ELSE
                                         " ".
               
    END. /* Final do FOR EACH */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*      Busca titulos de um determinado bordero para efetuar o resgate       */
/*****************************************************************************/
PROCEDURE busca_titulos_resgate:
    
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    DEF OUTPUT PARAM TABLE FOR tt-titulos.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-titulos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    /* Capa de lote */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                       craplot.dtmvtolt = par_dtmvtolt   AND
                       craplot.cdagenci = par_cdagenci   AND
                       craplot.cdbccxlt = par_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplot  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de lote nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    IF  craplot.tplotmov <> 34  THEN /* Descto de titulo */
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de lote deve ser 34 - Descto Titulos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND 
                       crapbdt.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdt  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de bordero nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    IF  crapbdt.insitbdt <> 3   THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Bordero nao esta LIBERADO.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND 
                       crapass.nrdconta = crapbdt.nrdconta NO-LOCK NO-ERROR.

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
                
            RETURN "NOK".

        END.
    
    /* Titulos do bordero que estao com a situacao liberado */
    FOR EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper AND
                           craptdb.nrborder = crapbdt.nrborder AND
                           craptdb.nrdconta = crapbdt.nrdconta AND
                           craptdb.insittit = 4 NO-LOCK:
                                   
        FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapcob  THEN
            NEXT.
        
        FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper AND
                           crapsab.nrinssac = crapcob.nrinssac AND
                           crapsab.nrdconta = crapcob.nrdconta NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapsab  THEN
            NEXT.
        
        CREATE tt-titulos.
        ASSIGN tt-titulos.cdbandoc = crapcob.cdbandoc
               tt-titulos.dsdoccop = crapcob.dsdoccop
               tt-titulos.dtmvtolt = crapcob.dtmvtolt
               tt-titulos.dtvencto = crapcob.dtvencto
               tt-titulos.idseqttl = crapcob.idseqttl
               tt-titulos.nmdsacad = crapsab.nmdsacad
               tt-titulos.nrcnvcob = crapcob.nrcnvcob
               tt-titulos.nrctrlim = crapbdt.nrctrlim
               tt-titulos.nrdctabb = crapcob.nrdctabb
               tt-titulos.nrdocmto = crapcob.nrdocmto
               tt-titulos.nrinssac = crapcob.nrinssac
               tt-titulos.vldescto = crapcob.vldescto
               tt-titulos.vldpagto = crapcob.vldpagto
               tt-titulos.vltitulo = crapcob.vltitulo
               tt-titulos.nrdconta = crapass.nrdconta
               tt-titulos.nrborder = crapbdt.nrborder
               tt-titulos.flgregis = crapcob.flgregis
               tt-titulos.tpcobran = IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc = 085  THEN
                                         "Coop. Emite"
                                     ELSE 
                                     IF  tt-titulos.flgregis = TRUE  AND
                                         tt-titulos.cdbandoc <> 085 THEN 
                                        "Banco emite"
                                     ELSE
                                     IF  tt-titulos.flgregis = FALSE THEN 
                                         "S/registro"
                                     ELSE
                                         " ".
               
    END. /* Final do FOR EACH */
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/*    Validar conta informada na inclusao do bordero e carregar os dados     */
/*****************************************************************************/
PROCEDURE valida_dados_inclusao:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    DEF OUTPUT PARAM TABLE FOR tt-dados_validacao.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    
    DEF VAR h-b1wgen0001 AS HANDLE  NO-UNDO.
    DEF VAR aux_vlutiliz AS DECIMAL NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-desconto_titulos.
    EMPTY TEMP-TABLE tt-msg-confirma.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
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
                
            RETURN "NOK".
        END.
    
    IF  crapass.dtdemiss <> ?   THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Associado DEMITIDO, desconto nao permitido.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
            
        END.
        
    IF  crapass.dtelimin <> ? THEN
        DO:
            ASSIGN aux_cdcritic = 410
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
            
        END.
               
    /* buscar quantidade maxima de digitos aceitos para o convenio */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                  
    RUN STORED-PROCEDURE pc_valida_adesao_produto
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 35, /* Desconto de Titulo */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */
                
    CLOSE STORED-PROC pc_valida_adesao_produto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic
                              WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
           aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                              WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    IF  CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
        DO:
            ASSIGN aux_cdcritic = 695.
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".        
        END.
               
     RUN sistema/generico/procedures/b1wgen0001.p
         PERSISTENT SET h-b1wgen0001.
      
     IF  VALID-HANDLE(h-b1wgen0001)   THEN
         DO:
             RUN ver_capital IN h-b1wgen0001(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* cod-agencia */
                                             INPUT 0, /* nro-caixa   */
                                             INPUT 0,        /* vllanmto */
                                             INPUT par_dtmvtolt,
                                             INPUT "LANBDTI",
                                             INPUT 1, /* AYLLOS */
                                             OUTPUT TABLE tt-erro).
                                             
             IF RETURN-VALUE = "NOK" THEN
             DO:
                DELETE PROCEDURE h-b1wgen0001.
                RETURN "NOK".
             END.
             ELSE
             DO:
                RUN ver_cadastro IN h-b1wgen0001(INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT 0, /* cod-agencia */
                                                 INPUT 0, /* nro-caixa   */
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_idorigem,
                                                OUTPUT TABLE tt-erro).


                IF  RETURN-VALUE = "NOK"  THEN
                DO:                               
                    DELETE PROCEDURE h-b1wgen0001.
                    RETURN "NOK".
                END.        
             END.             
             DELETE PROCEDURE h-b1wgen0001.
         END.
     
     FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                              craplim.nrdconta = par_nrdconta AND
                              craplim.tpctrlim = 3            AND
                              craplim.insitlim = 2 
                              NO-LOCK NO-ERROR.
                                        
     IF  NOT AVAILABLE craplim   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao ha contrato de limite de desconto " +
                                  "ATIVO.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".                             
         END.
                    
     FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                        crapldc.cddlinha = craplim.cddlinha AND
                        crapldc.tpdescto = 3
                        NO-LOCK NO-ERROR.
            
     IF  NOT AVAILABLE crapldc   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Linha de desconto nao cadastrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".             
             
         END.    

     /*  Verifica se a conta foi ou sera transferida .............  */
     FIND FIRST craptrf WHERE craptrf.cdcooper = par_cdcooper AND
                              craptrf.nrdconta = par_nrdconta AND
                              craptrf.tptransa = 1 
                              NO-LOCK NO-ERROR.
                                        
     IF AVAILABLE craptrf   THEN
        DO:
            IF   craptrf.insittrs = 1   THEN
                 DO:
                    CREATE tt-msg-confirma.
                    ASSIGN tt-msg-confirma.inconfir = 99
                           tt-msg-confirma.dsmensag = "Conta transferida " +
                           "para" + TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                 END.        
            ELSE
                 DO:
                    CREATE tt-msg-confirma.
                    ASSIGN tt-msg-confirma.inconfir = 99
                           tt-msg-confirma.dsmensag = "Conta a ser " +
                           "transferida para" +
                           TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                 END.        
        END.

    ASSIGN aux_vlutiliz = 0.
    
    FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper     AND
                            craptdb.nrdconta = crapass.nrdconta AND
                            craptdb.insittit = 2                AND
                            craptdb.dtdpagto = par_dtmvtolt) 
                           OR
                           (craptdb.cdcooper = par_cdcooper     AND
                            craptdb.nrdconta = crapass.nrdconta AND
                            craptdb.insittit = 4)
                            NO-LOCK:

        ASSIGN aux_vlutiliz = aux_vlutiliz + craptdb.vltitulo.
            
    END.  /*  Fim do FOR EACH  -- craptdb  */

    CREATE tt-dados_validacao.
    ASSIGN tt-dados_validacao.vlutiliz = aux_vlutiliz
           tt-dados_validacao.nmcustod = crapass.nmprimtl
           tt-dados_validacao.vllimite = craplim.vllimite.
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*           Buscar dados para exclusao de titulos de bordero                */
/*****************************************************************************/
PROCEDURE busca_dados_validacao_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados_validacao.
    
    DEF VAR aux_vlutiliz AS DECI NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_validacao.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    /* Capa de lote */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                       craplot.dtmvtolt = par_dtmvtolt   AND
                       craplot.cdagenci = par_cdagenci   AND
                       craplot.cdbccxlt = par_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplot  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de lote nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    IF  craplot.tplotmov <> 34  THEN /* Descto de titulo */
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de lote deve ser 34 - Descto Titulos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND 
                       crapbdt.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdt  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de bordero nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    IF  crapbdt.insitbdt = 3  AND
       (par_cddopcao = "A"    OR
        par_cddopcao = "E")   THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Bordero ja LIBERADO.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND 
                       crapass.nrdconta = crapbdt.nrdconta NO-LOCK NO-ERROR.

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
                
            RETURN "NOK".

        END.

    IF  par_cddopcao = "A"  OR
        par_cddopcao = "E"  THEN 
        DO:    
            FIND FIRST craplim WHERE craplim.cdcooper = crapbdt.cdcooper AND
                                     craplim.nrdconta = crapbdt.nrdconta AND
                                     craplim.tpctrlim = 3                AND
                                     craplim.insitlim = 2 
                                     NO-LOCK NO-ERROR.
                                                
            IF  NOT AVAILABLE craplim   THEN
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Nao ha contrato de limite de desconto " +
                                         "ATIVO.".
            
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,            /** Sequencia **/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
                        
                   RETURN "NOK".                             
                END.      
        END.
    
    ASSIGN aux_vlutiliz = 0.
    
    FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper     AND
                            craptdb.nrdconta = crapass.nrdconta AND
                            craptdb.insittit = 2                AND
                            craptdb.dtdpagto = par_dtmvtolt)
                           OR
                           (craptdb.cdcooper = par_cdcooper     AND
                            craptdb.nrdconta = crapass.nrdconta AND
                            craptdb.insittit = 4) NO-LOCK:

        ASSIGN aux_vlutiliz = aux_vlutiliz + craptdb.vltitulo.
            
    END.  /*  Fim do FOR EACH  -- craptdb  */
    
    CREATE tt-dados_validacao.
    ASSIGN tt-dados_validacao.dtvencto = craplot.dtmvtopg
           tt-dados_validacao.qtinfoln = craplot.qtinfoln
           tt-dados_validacao.qtcompln = craplot.qtcompln
           tt-dados_validacao.vlinfodb = craplot.vlinfodb 
           tt-dados_validacao.vlcompdb = craplot.vlcompdb
           tt-dados_validacao.vlinfocr = craplot.vlinfocr  
           tt-dados_validacao.vlcompcr = craplot.vlcompcr
           tt-dados_validacao.nrcustod = crapass.nrdconta
           tt-dados_validacao.nmcustod = crapass.nmprimtl
           tt-dados_validacao.nrborder = craplot.cdhistor
           tt-dados_validacao.nrcpfcgc = crapass.nrcpfcgc
           tt-dados_validacao.inpessoa = crapass.inpessoa
           tt-dados_validacao.nrdconta = crapass.nrdconta
           tt-dados_validacao.vllimite = IF  par_cddopcao = "A"  OR
                                             par_cddopcao = "E"  THEN craplim.vllimite
                                         ELSE
                                             0
           tt-dados_validacao.vlutiliz = aux_vlutiliz.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*               Buscar dados para resgate de titulos de bordero             */
/*****************************************************************************/
PROCEDURE busca_dados_resgate_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados_validacao.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_validacao.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    /* Capa de lote */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                       craplot.dtmvtolt = par_dtmvtolt   AND
                       craplot.cdagenci = par_cdagenci   AND
                       craplot.cdbccxlt = par_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplot  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de lote nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    IF  craplot.tplotmov <> 34  THEN /* Descto de titulo */
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de lote deve ser 34 - Descto Titulos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND 
                       crapbdt.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdt  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de bordero nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    IF  crapbdt.insitbdt <> 3   THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Bordero deve estar LIBERADO.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND 
                       crapass.nrdconta = crapbdt.nrdconta NO-LOCK NO-ERROR.

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
                
            RETURN "NOK".

        END.
    
    CREATE tt-dados_validacao.
    ASSIGN tt-dados_validacao.dtvencto = craplot.dtmvtopg
           tt-dados_validacao.qtinfoln = craplot.qtinfoln
           tt-dados_validacao.qtcompln = craplot.qtcompln
           tt-dados_validacao.vlinfodb = craplot.vlinfodb 
           tt-dados_validacao.vlcompdb = craplot.vlcompdb
           tt-dados_validacao.vlinfocr = craplot.vlinfocr  
           tt-dados_validacao.vlcompcr = craplot.vlcompcr
           tt-dados_validacao.nrcustod = crapass.nrdconta
           tt-dados_validacao.nmcustod = crapass.nmprimtl
           tt-dados_validacao.nrborder = craplot.cdhistor
           tt-dados_validacao.nrcpfcgc = crapass.nrcpfcgc
           tt-dados_validacao.inpessoa = crapass.inpessoa
           tt-dados_validacao.nrdconta = crapass.nrdconta.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/*                  Valida inclusao de titulos no bordero                    */
/*****************************************************************************/
PROCEDURE valida_inclusao_bordero:

    DEF  INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_qttottit AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_vltottit AS DECI                    NO-UNDO.
       
    DEF  INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM par_solcoord AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_nrborder AS INTE NO-UNDO.
    DEF VAR aux_ponteiro AS INTE NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI NO-UNDO.
    DEF VAR aux_flgsenha AS LOGI NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrborder = 0
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

        /* Validaçao de PAC afim de evitar registro do Bordero com PAC ZERO */
    IF  par_cdagenci <= 0 THEN
        DO:
            ASSIGN aux_dscritic = "Cod. do PA nao pode ser igual a zero.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.
		
	RUN valida_titulos_bordero(INPUT par_cdcooper,
							   INPUT par_cdagenci,
							   INPUT par_nrdcaixa,
							   INPUT par_cdoperad,
							   INPUT par_dtmvtolt,
							   INPUT par_idorigem,
							   INPUT par_nrdconta,
							   INPUT 0, /*nrborder*/
							   INPUT 2, /*tpvalida*/
							   INPUT TABLE tt-titulos,
							   OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
	   DO:
	      FIND FIRST tt-erro NO-LOCK NO-ERROR.

		  IF NOT AVAIL tt-erro THEN
		     DO:
		        ASSIGN aux_dscritic = "Nao foi possivel validar o bordero.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            END.

            RETURN "NOK".

        END.

    INCLUIR:
    DO TRANSACTION ON ERROR UNDO INCLUIR, LEAVE INCLUIR:
         
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo crapldt.nrsequen */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPBDT"
                                            ,INPUT "NRBORDER"
                                            ,STRING(par_cdcooper)
                                            ,INPUT "N"
                                            ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrborder = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                 craplim.nrdconta = par_nrdconta AND
                                 craplim.tpctrlim = 3            AND
                                 craplim.insitlim = 2
                                 NO-LOCK NO-ERROR.
         
        IF  NOT AVAILABLE craplim   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Limite de desconto de titulo nao " +
                                      "encontrado.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.
        
        IF  craplim.dtfimvig < par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "A vigencia do contrato deve ser maior que a data " +
                                      "de movimentação do sistema.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.
        
        FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                           crapldc.cddlinha = craplim.cddlinha   AND
                           crapldc.tpdescto = 3 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapldc  THEN 
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Regisro de linha " +
                                      "de desconto nao encontrada.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.        

        IF  CAN-FIND(FIRST tt-titulos WHERE tt-titulos.flgstats = 1   AND 
                                            tt-titulos.vltitulo = 0)  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Titulo com valor zerado. Operacao " +
                                      "cancelada.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_valida_valor_de_adesao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                             INPUT par_nrdconta, /* Numero da conta */
                                             INPUT 35,           /* Desconto de Titulo */
                                             INPUT STRING(par_vltottit), /* Valor contratado */
                                             INPUT par_idorigem, /* Codigo do produto */
                                             INPUT 0,            /* Codigo da chave */
                                            OUTPUT 0,            /* Solicita senha coordenador */
                                            OUTPUT 0,            /* Codigo da crítica */
                                            OUTPUT "").          /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_valida_valor_de_adesao
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_solcoord = 0
               aux_cdcritic = 0
               aux_dscritic = ""
               par_solcoord = pc_valida_valor_de_adesao.pr_solcoord 
                              WHEN pc_valida_valor_de_adesao.pr_solcoord <> ?
               aux_cdcritic = pc_valida_valor_de_adesao.pr_cdcritic 
                              WHEN pc_valida_valor_de_adesao.pr_cdcritic <> ?
               aux_dscritic = pc_valida_valor_de_adesao.pr_dscritic
                              WHEN pc_valida_valor_de_adesao.pr_dscritic <> ?.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
             DO:
                UNDO INCLUIR, LEAVE INCLUIR.
             END.
        
        ASSIGN aux_flgtrans = TRUE.

    END.  /*  Fim da transacao  */

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a operacao.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*                  Efetua inclusao de titulos no bordero                    */
/*****************************************************************************/
PROCEDURE efetua_inclusao_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_qttottit AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vltottit AS DECI                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_nrborder AS INTE NO-UNDO.
    DEF VAR aux_ponteiro AS INTE NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrborder = 0
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    /* Validaçao de PAC afim de evitar registro do Bordero com PAC ZERO */
    IF  par_cdagenci <= 0 THEN
        DO:
            ASSIGN aux_dscritic = "Cod. do PA nao pode ser igual a zero.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.
		
	RUN valida_titulos_bordero(INPUT par_cdcooper,
							   INPUT par_cdagenci,
							   INPUT par_nrdcaixa,
							   INPUT par_cdoperad,
							   INPUT par_dtmvtolt,
							   INPUT par_idorigem,
							   INPUT par_nrdconta,
							   INPUT 0, /*nrborder*/
							   INPUT 2, /*tpvalida*/
							   INPUT TABLE tt-titulos,
							   OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
	   DO:
	      FIND FIRST tt-erro NO-LOCK NO-ERROR.

		  IF NOT AVAIL tt-erro THEN
		     DO:
		        ASSIGN aux_dscritic = "Nao foi possivel validar o bordero.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            END.

            RETURN "NOK".

        END.

    INCLUIR:
    DO TRANSACTION ON ERROR UNDO INCLUIR, LEAVE INCLUIR:
         
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo crapldt.nrsequen */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPBDT"
                                            ,INPUT "NRBORDER"
                                            ,STRING(par_cdcooper)
                                            ,INPUT "N"
                                            ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrborder = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                 craplim.nrdconta = par_nrdconta AND
                                 craplim.tpctrlim = 3            AND
                                 craplim.insitlim = 2
                                 NO-LOCK NO-ERROR.
         
        IF  NOT AVAILABLE craplim   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Limite de desconto de titulo nao " +
                                      "encontrado.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.
        
        FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                           crapldc.cddlinha = craplim.cddlinha   AND
                           crapldc.tpdescto = 3 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapldc  THEN 
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Regisro de linha " +
                                      "de desconto nao encontrada.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.        

        IF  CAN-FIND(FIRST tt-titulos WHERE tt-titulos.flgstats = 1   AND 
                                            tt-titulos.vltitulo = 0)  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Titulo com valor zerado. Operacao " +
                                      "cancelada.".
                UNDO INCLUIR, LEAVE INCLUIR.
            END.
        
        CREATE craplot.
        ASSIGN craplot.dtmvtolt = par_dtmvtolt
               craplot.cdagenci = par_cdagenci
               craplot.cdbccxlt = par_cdbccxlt
               craplot.nrdolote = par_nrdolote
               craplot.tplotmov = 34
               craplot.cdoperad = par_cdoperad
               craplot.cdhistor = aux_nrborder
               craplot.cdcooper = par_cdcooper

               craplot.nrseqdig = par_qttottit
               craplot.qtinfoln = par_qttottit
               craplot.vlinfocr = par_vltottit
               craplot.vlinfodb = par_vltottit
               craplot.qtcompln = par_qttottit
               craplot.vlcompdb = par_vltottit
               craplot.vlcompcr = par_vltottit.
        VALIDATE craplot.

        CREATE crapbdt.
        ASSIGN crapbdt.dtmvtolt = craplot.dtmvtolt
               crapbdt.cdagenci = craplot.cdagenci
               crapbdt.cdbccxlt = craplot.cdbccxlt
               crapbdt.nrdolote = craplot.nrdolote
               crapbdt.nrborder = aux_nrborder
               crapbdt.cdoperad = craplot.cdoperad
               /* INICIO - dados para o BI em caso de cancelamento - MACIEL (RKAM) */
               crapbdt.cdopeori = par_cdoperad 
               crapbdt.cdageori = par_cdagenci
               crapbdt.dtinsori = TODAY
               /* FIM - dados para o BI em caso de cancelamento - MACIEL (RKAM) */
               crapbdt.nrctrlim = craplim.nrctrlim
               crapbdt.nrdconta = craplim.nrdconta
               crapbdt.cddlinha = craplim.cddlinha
               crapbdt.txmensal = crapldc.txmensal
               crapbdt.insitbdt = 1
               crapbdt.hrtransa = TIME
               crapbdt.cdcooper = par_cdcooper. 
        VALIDATE crapbdt.

        FOR EACH tt-titulos WHERE tt-titulos.flgstats = 1 NO-LOCK:
            
            CREATE craptdb.                                      
            ASSIGN craptdb.cdcooper = par_cdcooper
                   craptdb.cdbandoc = tt-titulos.cdbandoc
                   craptdb.cdoperad = par_cdoperad
                   craptdb.dtvencto = tt-titulos.dtvencto   
                   craptdb.nrctrlim = tt-titulos.nrctrlim
                   craptdb.nrborder = crapbdt.nrborder
                   craptdb.nrcnvcob = tt-titulos.nrcnvcob
                   craptdb.nrdconta = par_nrdconta
                   craptdb.nrdctabb = tt-titulos.nrdctabb
                   craptdb.nrdocmto = tt-titulos.nrdocmto
                   craptdb.nrseqdig = craplot.nrseqdig + 1
                   craptdb.vlliquid = tt-titulos.vldpagto
                   craptdb.vltitulo = tt-titulos.vltitulo
                   craptdb.nrinssac = tt-titulos.nrinssac.
            VALIDATE craptdb.

        END. /* Final do FOR EACH */

        ASSIGN aux_flgtrans = TRUE.

    END.  /*  Fim da transacao  */

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a operacao.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*   Efetuar alteracao de titulos no bordero - incluindo novos titulos nele  */
/*****************************************************************************/
PROCEDURE valida_alteracao_bordero:

    DEF  INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_qttottit AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_vltottit AS DECI                    NO-UNDO.
        
    DEF  INPUT PARAM TABLE FOR tt-titulos.
          
    DEF OUTPUT PARAM par_solcoord AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE   NO-UNDO.
    DEF VAR aux_nrborder AS INTE   NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI   NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrborder = 0
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ALTERAR:
    DO  TRANSACTION ON ERROR UNDO ALTERAR, LEAVE ALTERAR:
         
        DO  aux_contador = 1 TO 10:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND
                               crapbdt.nrborder = par_nrborder 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                DO:
                    IF  LOCKED crapbdt   THEN
                        DO:
                            aux_dscritic = "Registro de bordero esta em uso. " +
                                           "Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Registro de bordero nao " +
                                           "encontrado".
                            LEAVE.
                        END.    
                END.       
            ELSE
                DO:
                    IF  crapbdt.insitbdt <> 1 AND crapbdt.insitbdt <> 2  THEN
                        DO:
                            aux_dscritic = "Bordero deve estar em ESTUDO ou " +
                                           "ANALISADO.".
                            LEAVE.
                        END.
                END.
                
            aux_dscritic = "".
            LEAVE.
                                  
        END.  /*  Fim do DO .. TO  */
            
        IF  aux_dscritic <> ""  THEN
            UNDO ALTERAR, LEAVE ALTERAR.
        
        IF  crapbdt.insitbdt = 3   THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.
            
        IF  crapbdt.insitbdt = 4   THEN                    /*  Liquidado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIQUIDADO.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.
                    
        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = crapbdt.cdcooper AND 
                               craplot.dtmvtolt = crapbdt.dtmvtolt AND
                               craplot.cdagenci = crapbdt.cdagenci AND
                               craplot.cdbccxlt = crapbdt.cdbccxlt AND
                               craplot.nrdolote = crapbdt.nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            aux_dscritic = "341 - Registro sendo alterado " +
                                           "em outro terminal.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "060 - Lote inexistente.".
                            LEAVE.
                        END.
                ELSE
                    DO:   
                        IF  craplot.tplotmov <> 34   THEN
                            ASSIGN aux_dscritic = "100 - Tipo de lote nao " +
                                            "corresponde a esse lancamento.".
                        ELSE
                        IF  craplot.cdoperad <> par_cdoperad  THEN
                            ASSIGN aux_dscritic = "Operador deve ser o " +
                                                  "mesmo que criou o bordero." +
                                                  " Operador: " +
                                                  STRING(craplot.cdoperad).
                            
                        LEAVE.
                    END.
                    
                aux_dscritic = "".
                LEAVE.
            
        END.   /*  Fim do DO .. TO  */
            
        IF  aux_dscritic <> ""   THEN
            UNDO ALTERAR, LEAVE ALTERAR.

        IF  CAN-FIND(FIRST tt-titulos WHERE tt-titulos.flgstats = 1   AND 
                                            tt-titulos.vltitulo = 0)  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Titulo com valor zerado. Operacao " +
                                      "cancelada.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_valida_valor_de_adesao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                             INPUT par_nrdconta, /* Numero da conta */
                                             INPUT 35,           /* Desconto de Titulo */
                                             INPUT STRING(par_vltottit), /* Valor contratado */
                                             INPUT par_idorigem, /* Codigo do produto */
                                             INPUT 0,            /* Codigo da chave */
                                            OUTPUT 0,            /* Solicita senha coordenador */
                                            OUTPUT 0,            /* Codigo da crítica */
                                            OUTPUT "").          /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_valida_valor_de_adesao
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_solcoord = 0
               aux_cdcritic = 0
               aux_dscritic = ""
               par_solcoord = pc_valida_valor_de_adesao.pr_solcoord 
                              WHEN pc_valida_valor_de_adesao.pr_solcoord <> ?
               aux_cdcritic = pc_valida_valor_de_adesao.pr_cdcritic 
                              WHEN pc_valida_valor_de_adesao.pr_cdcritic <> ?
               aux_dscritic = pc_valida_valor_de_adesao.pr_dscritic
                              WHEN pc_valida_valor_de_adesao.pr_dscritic <> ?.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
             DO:
                UNDO ALTERAR, LEAVE ALTERAR.
                
             END.
        
        ASSIGN aux_flgtrans = TRUE.

    END.  /*  Fim da transacao  */

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a operacao.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*   Efetuar alteracao de titulos no bordero - incluindo novos titulos nele  */
/*****************************************************************************/
PROCEDURE efetua_alteracao_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_qttottit AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vltottit AS DECI                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE   NO-UNDO.
    DEF VAR aux_nrborder AS INTE   NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrborder = 0
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ALTERAR:
    DO  TRANSACTION ON ERROR UNDO ALTERAR, LEAVE ALTERAR:
         
        DO  aux_contador = 1 TO 10:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND
                               crapbdt.nrborder = par_nrborder 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                DO:
                    IF  LOCKED crapbdt   THEN
                        DO:
                            aux_dscritic = "Registro de bordero esta em uso. " +
                                           "Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Registro de bordero nao " +
                                           "encontrado".
                            LEAVE.
                        END.    
                END.       
            ELSE
                DO:
                    IF  crapbdt.insitbdt <> 1 AND crapbdt.insitbdt <> 2  THEN
                        DO:
                            aux_dscritic = "Bordero deve estar em ESTUDO ou " +
                                           "ANALISADO.".
                            LEAVE.
                        END.
                END.
                
            aux_dscritic = "".
            LEAVE.
                                  
        END.  /*  Fim do DO .. TO  */
            
        IF  aux_dscritic <> ""  THEN
            UNDO ALTERAR, LEAVE ALTERAR.
        
        IF  crapbdt.insitbdt = 3   THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.
            
        IF  crapbdt.insitbdt = 4   THEN                    /*  Liquidado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIQUIDADO.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.
                    
        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = crapbdt.cdcooper AND 
                               craplot.dtmvtolt = crapbdt.dtmvtolt AND
                               craplot.cdagenci = crapbdt.cdagenci AND
                               craplot.cdbccxlt = crapbdt.cdbccxlt AND
                               craplot.nrdolote = crapbdt.nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            aux_dscritic = "341 - Registro sendo alterado " +
                                           "em outro terminal.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "060 - Lote inexistente.".
                            LEAVE.
                        END.
                ELSE
                    DO:   
                        IF  craplot.tplotmov <> 34   THEN
                            ASSIGN aux_dscritic = "100 - Tipo de lote nao " +
                                            "corresponde a esse lancamento.".
                        ELSE
                        IF  craplot.cdoperad <> par_cdoperad  THEN
                            ASSIGN aux_dscritic = "Operador deve ser o " +
                                                  "mesmo que criou o bordero." +
                                                  " Operador: " +
                                                  STRING(craplot.cdoperad).
                            
                        LEAVE.
                    END.
                    
                aux_dscritic = "".
                LEAVE.
            
        END.   /*  Fim do DO .. TO  */
            
        IF  aux_dscritic <> ""   THEN
            UNDO ALTERAR, LEAVE ALTERAR.

        IF  CAN-FIND(FIRST tt-titulos WHERE tt-titulos.flgstats = 1   AND 
                                            tt-titulos.vltitulo = 0)  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Titulo com valor zerado. Operacao " +
                                      "cancelada.".
                UNDO ALTERAR, LEAVE ALTERAR.
            END.

        /* Somente altera dados do lote se alteracao for no dia da criacao
           do bordero */
        IF  par_dtmvtolt = crapbdt.dtmvtolt  THEN
            DO:
                ASSIGN craplot.nrseqdig = par_qttottit
                       craplot.qtinfoln = par_qttottit
                       craplot.vlinfocr = par_vltottit
                       craplot.vlinfodb = par_vltottit
                       craplot.qtcompln = par_qttottit
                       craplot.vlcompdb = par_vltottit
                       craplot.vlcompcr = par_vltottit

                       crapbdt.insitbdt = 1.
            END.
                   
        FOR EACH tt-titulos WHERE tt-titulos.flgstats = 1 NO-LOCK:
            
            CREATE craptdb.                                      
            ASSIGN craptdb.cdcooper = par_cdcooper
                   craptdb.cdbandoc = tt-titulos.cdbandoc
                   craptdb.cdoperad = par_cdoperad
                   craptdb.dtvencto = tt-titulos.dtvencto   
                   craptdb.nrctrlim = tt-titulos.nrctrlim
                   craptdb.nrborder = crapbdt.nrborder
                   craptdb.nrcnvcob = tt-titulos.nrcnvcob
                   craptdb.nrdconta = par_nrdconta
                   craptdb.nrdctabb = tt-titulos.nrdctabb
                   craptdb.nrdocmto = tt-titulos.nrdocmto
                   craptdb.vlliquid = tt-titulos.vldpagto
                   craptdb.vltitulo = tt-titulos.vltitulo
                   craptdb.nrinssac = tt-titulos.nrinssac.
            VALIDATE craptdb.

            UNIX SILENT 
                     VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                           " Operador " + par_cdoperad +
                           " Alterou o bordero " + 
                           STRING(crapbdt.nrborder) +
                           " incluindo o boleto: " + 
                           STRING(craplot.dtmvtolt,"99/99/99") + " " + 
                           STRING(craplot.cdagenci,"zz9") + " " +
                           STRING(craplot.cdbccxlt,"zz9") + " " +
                           STRING(craplot.nrdolote,"zzz,zz9") + " " +
                           STRING(par_nrdconta,"z,zzz,zz9,9") + " " +
                           STRING(tt-titulos.nrcnvcob,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.nrdocmto,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.vltitulo,"zzz,zz9.99") + "." +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/lanbdt.log").
        
        END. /* Final do FOR EACH */

        ASSIGN aux_flgtrans = TRUE.

    END.  /*  Fim da transacao  */

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a operacao.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*           Efetua exclusao de titulos de um determinado bordero            */
/*****************************************************************************/
PROCEDURE valida_exclusao_tit_bordero:

    DEF  INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_dtsistem AS DATE                    NO-UNDO.
    DEF  INPUT PARAM par_vltottit AS DECI                    NO-UNDO.
        
    DEF  INPUT PARAM TABLE FOR tt-titulos.
          
    DEF OUTPUT PARAM par_solcoord AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_vltottit AS INTE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    EXCLUIR:
    DO  TRANSACTION ON ERROR UNDO EXCLUIR, RETURN "NOK":
         
        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = par_cdbccxlt AND
                               craplot.nrdolote = par_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 60.
                            LEAVE.
                        END.
                ELSE
                    DO:   
                        IF  craplot.tplotmov <> 34   THEN
                            DO:
                                ASSIGN aux_cdcritic = 100.
                                LEAVE.
                            END.
                    END.
                    
                aux_cdcritic = 0.
                LEAVE.
            
        END.   /*  Fim do DO .. TO  */
            
        IF  aux_cdcritic > 0   THEN
            DO:
                ASSIGN aux_dscritic = "".
            
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                    
                UNDO EXCLUIR, RETURN "NOK".
            END.

        DO  WHILE TRUE:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND 
                               crapbdt.nrborder = craplot.cdhistor
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                IF  LOCKED crapbdt   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    UNDO EXCLUIR, RETURN "NOK".
               
            LEAVE.
                                  
        END.  /*  Fim do DO WHILE TRUE  */

        IF  crapbdt.insitbdt = 3   THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                UNDO EXCLUIR, RETURN "NOK".
            END.
            
         
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_valida_valor_de_adesao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                             INPUT par_nrdconta, /* Numero da conta */
                                             INPUT 35,           /* Desconto de Titulo */
                                             INPUT STRING(par_vltottit), /* Valor contratado */
                                             INPUT par_idorigem, /* Codigo do produto */
                                             INPUT 0,            /* Codigo da chave */
                                            OUTPUT 0,            /* Solicita senha coordenador */
                                            OUTPUT 0,            /* Codigo da crítica */
                                            OUTPUT "").          /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_valida_valor_de_adesao
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_solcoord = 0
               aux_cdcritic = 0
               aux_dscritic = ""
               par_solcoord = pc_valida_valor_de_adesao.pr_solcoord 
                              WHEN pc_valida_valor_de_adesao.pr_solcoord <> ?
               aux_cdcritic = pc_valida_valor_de_adesao.pr_cdcritic 
                              WHEN pc_valida_valor_de_adesao.pr_cdcritic <> ?
               aux_dscritic = pc_valida_valor_de_adesao.pr_dscritic
                              WHEN pc_valida_valor_de_adesao.pr_dscritic <> ?.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
             DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                UNDO EXCLUIR, RETURN "NOK".
             END.
        
    END.  /*  Fim da transacao  */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*           Efetua exclusao de titulos de um determinado bordero            */
/*****************************************************************************/
PROCEDURE efetua_exclusao_tit_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtsistem AS DATE                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INTE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    EXCLUIR:
    DO  TRANSACTION ON ERROR UNDO EXCLUIR, RETURN "NOK":
         
        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = par_cdbccxlt AND
                               craplot.nrdolote = par_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 60.
                            LEAVE.
                        END.
                ELSE
                    DO:   
                        IF  craplot.tplotmov <> 34   THEN
                            DO:
                                ASSIGN aux_cdcritic = 100.
                                LEAVE.
                            END.
                    END.
                    
                aux_cdcritic = 0.
                LEAVE.
            
        END.   /*  Fim do DO .. TO  */
            
        IF  aux_cdcritic > 0   THEN
            DO:
                ASSIGN aux_dscritic = "".
            
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                    
                UNDO EXCLUIR, RETURN "NOK".
            END.

        DO  WHILE TRUE:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND 
                               crapbdt.nrborder = craplot.cdhistor
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                IF  LOCKED crapbdt   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    UNDO EXCLUIR, RETURN "NOK".
               
            LEAVE.
                                  
        END.  /*  Fim do DO WHILE TRUE  */

        IF  crapbdt.insitbdt = 3   THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                UNDO EXCLUIR, RETURN "NOK".
            END.
        ELSE
            IF  crapbdt.insitbdt = 2   THEN    /*  Analisado  */
                ASSIGN crapbdt.insitbdt = 1.   /*  Em estudo  */

        FOR EACH tt-titulos WHERE tt-titulos.flgstats = 1 NO-LOCK:
        
            FIND craptdb  WHERE craptdb.cdcooper = par_cdcooper        AND
                                craptdb.nrdconta = tt-titulos.nrdconta AND
                                craptdb.nrborder = tt-titulos.nrborder AND
                                craptdb.cdbandoc = tt-titulos.cdbandoc AND
                                craptdb.nrdctabb = tt-titulos.nrdctabb AND
                                craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
                                craptdb.nrdocmto = tt-titulos.nrdocmto AND
                                craptdb.insittit = 0
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAIL craptdb  THEN
                NEXT.
                
            IF  par_dtmvtolt = par_dtsistem  THEN
                DO:
                    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                           craplot.qtinfoln = craplot.qtinfoln - 1
                           craplot.vlinfodb = craplot.vlinfodb - 
                                                       tt-titulos.vltitulo
                           craplot.vlinfocr = craplot.vlinfocr -
                                                       tt-titulos.vltitulo
                           craplot.vlcompdb = craplot.vlcompdb -
                                                        tt-titulos.vltitulo
                           craplot.vlcompcr = craplot.vlcompcr - 
                                                        tt-titulos.vltitulo
                           craplot.nrseqdig = craplot.nrseqdig - 1.
                   
                    IF  craplot.qtcompln = 0  THEN
                        DELETE craplot.
                END.
            ELSE
                DO:
                    UNIX SILENT 
                     VALUE("echo " + STRING(par_dtsistem,"99/99/9999") + " " +
                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                           " Operador " + par_cdoperad +
                           " Excluiu o boleto: " + 
                           STRING(par_dtmvtolt,"99/99/99") + " " + 
                           STRING(par_cdagenci,"zz9") + " " +
                           STRING(par_cdbccxlt,"zz9") + " " +
                           STRING(par_nrdolote,"zzz,zz9") + " " +
                           STRING(par_nrdconta,"z,zzz,zz9,9") + " " +
                           STRING(tt-titulos.nrcnvcob,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.nrdocmto,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.vltitulo,"zzz,zz9.99") + " " +
                           " do bordero " +
                           STRING(tt-titulos.nrborder,"zzz,zz9") + "." +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/lanbdt.log").
                END.
            
            DELETE craptdb.
            
            /* Se o bordero nao possuir mais nenhum titulo remove o bordero */
            IF  NOT CAN-FIND(FIRST craptdb WHERE 
                                   craptdb.cdcooper = crapbdt.cdcooper AND
                                   craptdb.nrdconta = crapbdt.nrdconta AND
                                   craptdb.nrborder = crapbdt.nrborder 
                                   NO-LOCK) THEN
                DO:
                    UNIX SILENT 
                     VALUE("echo " + STRING(par_dtsistem,"99/99/9999") + " " +
                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                           " Operador " + par_cdoperad +
                           " Excluiu o bordero: " + 
                           STRING(crapbdt.nrborder,"zzz,zz9") + "." +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/lanbdt.log").                
                    DELETE crapbdt.
                END.
            
        END. /* Final do FOR EACH */

    END.  /*  Fim da transacao  */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*           Efetua resgate de titulos de um determinado bordero             */
/*****************************************************************************/
PROCEDURE efetua_resgate_tit_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtresgat AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_qtdprazo AS INTE    NO-UNDO.
    DEF VAR aux_vltitulo AS DECI    NO-UNDO.
    DEF VAR aux_dtperiod AS DATE    NO-UNDO.
    DEF VAR aux_vldjuros AS DECI    NO-UNDO.
    DEF VAR aux_vljurper AS DECI    NO-UNDO.
    DEF VAR aux_vlliqori AS DECI    NO-UNDO.
    DEF VAR aux_contador AS INTE    NO-UNDO.
    DEF VAR aux_contado1 AS INTE    NO-UNDO.
    DEF VAR aux_txdiaria AS DECI    NO-UNDO.
    DEF VAR aux_dtrefjur AS DATE    NO-UNDO.
    DEF VAR aux_vlliqnov AS DECI    NO-UNDO.
    DEF VAR aux_dtultdat AS DATE    NO-UNDO.
    DEF VAR aux_vltarres AS DECI    NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE  NO-UNDO.
    
    DEF BUFFER crablot FOR craplot.
    DEF BUFFER cra2lot FOR craplot.
    DEF BUFFER crablcm FOR craplcm.

    DEF VAR aux_cdbattar AS CHAR    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
    RESGATE:
    DO  TRANSACTION ON ERROR UNDO RESGATE, RETURN "NOK":
         
        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = par_cdbccxlt AND
                               craplot.nrdolote = par_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE craplot   THEN
                IF  LOCKED craplot   THEN
                    DO:
                        ASSIGN aux_dscritic = "Registro de lote esta sendo " +
                                              "usado no momento.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                    ASSIGN aux_dscritic = "Registro de lote nao encontrado.".
                    LEAVE.
                    END.
            ELSE
                DO:   
                    IF  craplot.tplotmov <> 34   THEN
                        DO:
                        ASSIGN aux_dscritic = "Tipo de lote deve ser 34-" +
                                              "Descto de titulos.".
                        LEAVE.
                        END.
                END.
                    
            aux_dscritic = "".
            LEAVE.
            
        END.   /*  Fim do DO .. TO  */

        IF  aux_dscritic <> ""   THEN
            DO:
                ASSIGN aux_cdcritic = 0.
            
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                    
                UNDO RESGATE, RETURN "NOK".
            END.
        
        DO  aux_contador = 1 TO 10:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND 
                               crapbdt.nrborder = craplot.cdhistor
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                IF  LOCKED crapbdt   THEN
                    DO:
                        ASSIGN aux_dscritic = "Registro de bordero esta em " +
                                              "uso no momento.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Bordero nao encontrado.".
                
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                 
                        UNDO RESGATE, RETURN "NOK".
                    END.

            aux_dscritic = "".
            LEAVE.
                                  
        END.  /*  Fim do DO .. TO  */

        IF  aux_dscritic <> ""   THEN
            DO:
                ASSIGN aux_cdcritic = 0.
            
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                    
                UNDO RESGATE, RETURN "NOK".
            END.
        
        IF  crapbdt.insitbdt <> 3  THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero deve estar LIBERADO.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                UNDO RESGATE, RETURN "NOK".
            END.
        
        aux_txdiaria = ROUND((EXP(1 + (crapbdt.txmensal / 100),1 / 30) - 1),7).

        RUN sistema/generico/procedures/b1wgen0088.p
            PERSISTENT SET h-b1wgen0088.
        
        FOR EACH tt-titulos WHERE tt-titulos.flgstats = 1 NO-LOCK:

            FIND craptdb  WHERE craptdb.cdcooper = par_cdcooper        AND
                                craptdb.nrdconta = tt-titulos.nrdconta AND
                                craptdb.nrborder = crapbdt.nrborder    AND
                                craptdb.cdbandoc = tt-titulos.cdbandoc AND
                                craptdb.nrdctabb = tt-titulos.nrdctabb AND
                                craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
                                craptdb.nrdocmto = tt-titulos.nrdocmto
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAIL craptdb  THEN
                NEXT.
            /*
            RUN busca_tarifas_dsctit (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-tarifas_dsctit).        
            
            IF  RETURN-VALUE = "NOK"  THEN
                UNDO RESGATE, RETURN "NOK".                    
            */

            /* Assume como padrao pessoa fisica */
            ASSIGN aux_inpessoa = 1
                   aux_vltarres = 0.

            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = tt-titulos.nrdconta NO-LOCK NO-ERROR.

            IF AVAIL crapass THEN
                ASSIGN aux_inpessoa = crapass.inpessoa.

            IF aux_inpessoa = 1 THEN
            DO:
                IF  tt-titulos.flgregis = TRUE THEN
                    ASSIGN aux_cdbattar = "DSTRESCRPF".
                ELSE
                    ASSIGN aux_cdbattar = "DSTRESSRPF".
            END.
            ELSE
            DO:
                IF  tt-titulos.flgregis = TRUE THEN
                    ASSIGN aux_cdbattar = "DSTRESCRPJ".
                ELSE
                    ASSIGN aux_cdbattar = "DSTRESSRPJ".
            END.

            IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

            /*  Busca valor da tarifa de Emprestimo pessoa fisica*/
            RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                            (INPUT  par_cdcooper,
                                             INPUT  aux_cdbattar,       
                                             INPUT  1,   
                                             INPUT  "", /* cdprogra */
                                             OUTPUT aux_cdhistor,
                                             OUTPUT aux_cdhisest,
                                             OUTPUT aux_vltarres,
                                             OUTPUT aux_dtdivulg,
                                             OUTPUT aux_dtvigenc,
                                             OUTPUT aux_cdfvlcop,
                                             OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0153)  THEN
                DELETE PROCEDURE h-b1wgen0153.
                             /* Daniel */
/*
            IF  tt-titulos.flgregis = TRUE THEN
                ASSIGN aux_vltarres = tt-tarifas_dsctit.vltrescr.
            ELSE
                ASSIGN aux_vltarres = tt-tarifas_dsctit.vltressr.
               */                    
            IF  aux_vltarres > 0  THEN
                DO: /*
                    DO  aux_contador = 1 TO 10:

                        FIND cra2lot WHERE cra2lot.cdcooper = par_cdcooper AND 
                                           cra2lot.dtmvtolt = par_dtresgat AND
                                           cra2lot.cdagenci = 1            AND
                                           cra2lot.cdbccxlt = 100          AND
                                           cra2lot.nrdolote = 8452
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                        IF  NOT AVAILABLE cra2lot   THEN
                            IF  LOCKED cra2lot   THEN
                                DO:
                                    aux_cdcritic = 341.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    CREATE cra2lot.
                                    ASSIGN cra2lot.dtmvtolt = par_dtresgat
                                           cra2lot.cdagenci = 1 
                                           cra2lot.cdbccxlt = 100 
                                           cra2lot.nrdolote = 8452 
                                           cra2lot.tplotmov = 1
                                           cra2lot.cdoperad = par_cdoperad
                                           cra2lot.cdhistor = 598
                                           cra2lot.cdcooper = par_cdcooper.
                                END.
 
                        aux_cdcritic = 0.
                        LEAVE.
            
                    END.   /*  Fim do DO .. TO  */

                    IF  aux_cdcritic > 0   THEN
                        DO:
                            ASSIGN aux_dscritic = "".
            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                    
                            UNDO RESGATE, RETURN "NOK".
                        END.

                    CREATE craplcm.
                    ASSIGN craplcm.dtmvtolt = par_dtresgat
                           craplcm.cdagenci = 1
                           craplcm.cdbccxlt = 100 
                           craplcm.nrdolote = 8452
                           craplcm.nrdconta = craptdb.nrdconta
                           craplcm.nrdctabb = craptdb.nrdctabb
                           craplcm.nrdocmto = cra2lot.nrseqdig + 1
                           craplcm.cdhistor = 598 
                           craplcm.nrseqdig = cra2lot.nrseqdig + 1
                           craplcm.vllanmto = aux_vltarres
                           craplcm.cdpesqbb = "Docto " + 
                                              STRING(craptdb.nrdocmto) +
                                              "Trf de resg " +
                                              STRING(aux_vltarres,
                                                     "999.99")
                           craplcm.vldoipmf = 0
                           craplcm.cdcooper = par_cdcooper
                           cra2lot.nrseqdig = craplcm.nrseqdig
                           cra2lot.vlinfodb = cra2lot.vlinfodb + 
                                                            craplcm.vllanmto
                           cra2lot.vlcompdb = cra2lot.vlcompdb + 
                                                            craplcm.vllanmto
                           cra2lot.qtinfoln = cra2lot.qtinfoln + 1
                           cra2lot.qtcompln = cra2lot.qtcompln + 1
                           cra2lot.nrseqdig = cra2lot.nrseqdig + 1.
                    */
                    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

                    RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                   (INPUT par_cdcooper,
                                    INPUT craptdb.nrdconta,            
                                    INPUT par_dtresgat,
                                    INPUT aux_cdhistor, 
                                    INPUT aux_vltarres,
                                    INPUT par_cdoperad,                         /* cdoperad */
                                    INPUT 1,                                    /* cdagenci */
                                    INPUT 100,                                  /* cdbccxlt */         
                                    INPUT 8452,                                 /* nrdolote */        
                                    INPUT 1,                                    /* tpdolote */         
                                    INPUT 0 ,                                   /* nrdocmto */
                                    INPUT craptdb.nrdconta,                     /* nrdconta */
                                    INPUT STRING(craptdb.nrdconta,"99999999"),  /* nrdctitg */
                                    INPUT "Fato gerador tarifa:" + STRING(craptdb.nrdocmto),                 /* cdpesqbb */
                                    INPUT 0,                                    /* cdbanchq */
                                    INPUT 0,                                    /* cdagechq */
                                    INPUT 0,                                    /* nrctachq */
                                    INPUT FALSE,                                /* flgaviso */
                                    INPUT 0,                                    /* tpdaviso */
                                    INPUT aux_cdfvlcop,                         /* cdfvlcop */
                                    INPUT crapdat.inproces,                     /* inproces */
                                    OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                       IF AVAIL tt-erro THEN 
                       DO:
                            ASSIGN aux_dscritic = "".
            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT tt-erro.dscritic).
                    
                            UNDO RESGATE, RETURN "NOK".
                       END.
                           
                    END.
            
                    IF  VALID-HANDLE(h-b1wgen0153)  THEN
                           DELETE PROCEDURE h-b1wgen0153.
                END.   

            /**** RECALCULO DO TITULO(COBRANCA DE JUROS DE RESGATE) ****/
            ASSIGN aux_qtdprazo = IF craptdb.dtvencto > par_dtmvtoan AND
                                     craptdb.dtvencto < par_dtresgat 
                                  THEN craptdb.dtvencto - crapbdt.dtlibbdt
                                  ELSE par_dtresgat - crapbdt.dtlibbdt
                   aux_vltitulo = craptdb.vltitulo
                   aux_dtperiod = crapbdt.dtlibbdt
                   aux_vldjuros = 0
                   aux_vljurper = 0
                   aux_vlliqori = craptdb.vlliquid.
            
            /* Restituicao nao no mesmo dia da Liberacao */
            IF  aux_qtdprazo > 0 THEN    
                DO:
                    DO  aux_contador = 1 TO aux_qtdprazo:
   
                        ASSIGN aux_vldjuros = ROUND(aux_vltitulo * 
                                                    aux_txdiaria,2)
                               aux_vltitulo = aux_vltitulo + aux_vldjuros
                               aux_dtperiod = aux_dtperiod + 1
                               aux_dtrefjur = ((DATE(MONTH(aux_dtperiod),28,
                                               YEAR(aux_dtperiod)) + 4) -
                                               DAY(DATE(MONTH(aux_dtperiod),28,
                                               YEAR(aux_dtperiod)) + 4)).
          
                        DO  aux_contado1 = 1 TO 10: 
            
                            FIND crawljt WHERE 
                                 crawljt.cdcooper = craptdb.cdcooper AND
                                 crawljt.nrdconta = craptdb.nrdconta AND
                                 crawljt.nrborder = craptdb.nrborder AND
                                 crawljt.dtrefere = aux_dtrefjur     AND
                                 crawljt.cdbandoc = craptdb.cdbandoc AND
                                 crawljt.nrdctabb = craptdb.nrdctabb AND
                                 crawljt.nrcnvcob = craptdb.nrcnvcob AND
                                 crawljt.nrdocmto = craptdb.nrdocmto
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                            IF  NOT AVAILABLE crawljt  THEN
                                DO:
                                    IF  LOCKED crawljt  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE
                                        DO:
                                            CREATE crawljt.
                                            ASSIGN crawljt.cdcooper = 
                                                            craptdb.cdcooper 
                                                   crawljt.nrdconta = 
                                                            craptdb.nrdconta
                                                   crawljt.nrborder = 
                                                            craptdb.nrborder
                                                   crawljt.dtrefere = 
                                                            aux_dtrefjur
                                                   crawljt.cdbandoc = 
                                                            craptdb.cdbandoc
                                                   crawljt.nrdctabb = 
                                                            craptdb.nrdctabb
                                                   crawljt.nrcnvcob = 
                                                            craptdb.nrcnvcob
                                                   crawljt.nrdocmto = 
                                                            craptdb.nrdocmto.
                                        END.      
                                END.

                            ASSIGN aux_cdcritic = 0.
                            LEAVE. 
          
                        END. /* Fim do DO ... TO */
           
                        IF  aux_cdcritic > 0  THEN
                            DO:
                                ASSIGN aux_dscritic = "".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
    
                                UNDO RESGATE, RETURN "NOK".

                            END.
                  
                        crawljt.vldjuros = crawljt.vldjuros + aux_vldjuros.

                    END.  /*  Fim do DO .. TO  */

                    aux_vlliqnov = craptdb.vltitulo - (aux_vltitulo - 
                                                       craptdb.vltitulo).

                    /*  Atualiza registro de provisao de juros ..........  */
                    FOR EACH crawljt WHERE 
                             crawljt.cdcooper = par_cdcooper EXCLUSIVE-LOCK:
                
                        FIND crapljt WHERE 
                             crapljt.cdcooper = crawljt.cdcooper AND
                             crapljt.nrdconta = crawljt.nrdconta AND
                             crapljt.nrborder = crawljt.nrborder AND
                             crapljt.dtrefere = crawljt.dtrefere AND
                             crapljt.cdbandoc = crawljt.cdbandoc AND
                             crapljt.nrdctabb = crawljt.nrdctabb AND
                             crapljt.nrcnvcob = crawljt.nrcnvcob AND
                             crapljt.nrdocmto = crawljt.nrdocmto
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                        IF  NOT AVAILABLE crapljt  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro crapljt nao " +
                                                      "encontrado.".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                UNDO RESGATE, RETURN "NOK".
                            END.
                
                        IF  crapljt.vldjuros <> crawljt.vldjuros   THEN
                            IF  crapljt.vldjuros > crawljt.vldjuros   THEN
                                ASSIGN crapljt.vlrestit = crapljt.vldjuros - 
                                                          crawljt.vldjuros
                                       crapljt.vldjuros = crawljt.vldjuros.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Erro - Juros " +
                                                          "negativo: " +
                                                       STRING(crapljt.vldjuros).

                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1, /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).

                                    UNDO RESGATE, RETURN "NOK".
                                END.
                     
                        aux_dtultdat = crawljt.dtrefere.
                
                        DELETE crawljt.       

                    END.  /*  Fim do FOR EACH crawljt  */
                END.
            ELSE
                ASSIGN aux_dtultdat = par_dtresgat
                       aux_vlliqori = craptdb.vlliquid
                       aux_vlliqnov = craptdb.vltitulo.

            FOR EACH crapljt WHERE crapljt.cdcooper = par_cdcooper     AND 
                                   crapljt.nrdconta = craptdb.nrdconta AND
                                   crapljt.nrborder = craptdb.nrborder AND
                                   crapljt.dtrefere > aux_dtultdat     AND
                                   crapljt.cdbandoc = craptdb.cdbandoc AND
                                   crapljt.nrdctabb = craptdb.nrdctabb AND
                                   crapljt.nrcnvcob = craptdb.nrcnvcob AND
                                   crapljt.nrdocmto = craptdb.nrdocmto 
                                   EXCLUSIVE-LOCK:
                         
                ASSIGN crapljt.vlrestit = crapljt.vldjuros
                       crapljt.vldjuros = 0.
   
            END.  /*  Fim do FOR EACH crapljt  */
       
            /*  Cria lancamento no conta-corrente ....................  */
            DO  aux_contador = 1 TO 10:

                FIND crablot WHERE crablot.cdcooper = par_cdcooper AND 
                                   crablot.dtmvtolt = par_dtresgat AND
                                   crablot.cdagenci = 1            AND
                                   crablot.cdbccxlt = 100          AND
                                   crablot.nrdolote = 10300
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crablot   THEN
                    IF  LOCKED crablot   THEN
                        DO:
                            ASSIGN aux_dscritic = "Registo de lote esta em " +
                                                  "uso. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE crablot.
                            ASSIGN crablot.dtmvtolt = par_dtresgat
                                   crablot.cdagenci = 1 
                                   crablot.cdbccxlt = 100 
                                   crablot.nrdolote = 10300 
                                   crablot.tplotmov = 1
                                   crablot.cdoperad = par_cdoperad
                                   crablot.cdhistor = 687
                                   crablot.cdcooper = par_cdcooper.
                        END.
 
                ASSIGN aux_dscritic = "".
                LEAVE.
            
            END.  /*  Fim do DO .. TO  */

            IF  aux_dscritic <> ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro - Juros negativo: " +
                                          STRING(crapljt.vldjuros).
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    UNDO RESGATE, RETURN "NOK".       
           
                END.
   
            /*  Cria lancamento da conta do associado ..................  */
            CREATE crablcm.
            ASSIGN crablcm.dtmvtolt = crablot.dtmvtolt 
                   crablcm.cdagenci = crablot.cdagenci
                   crablcm.cdbccxlt = crablot.cdbccxlt 
                   crablcm.nrdolote = crablot.nrdolote
                   crablcm.nrdconta = craptdb.nrdconta
                   crablcm.nrdocmto = crablot.nrseqdig + 1
                   crablcm.vllanmto = craptdb.vltitulo - (aux_vlliqnov - 
                                                          aux_vlliqori) 
                   crablcm.cdhistor = 687
                   crablcm.nrseqdig = crablot.nrseqdig + 1 
                   crablcm.nrdctabb = craptdb.nrdconta
                   crablcm.nrautdoc = 0
                   crablcm.cdpesqbb = STRING(craptdb.nrdocmto) 
                   crablcm.cdcooper = par_cdcooper

                   crablot.nrseqdig = crablcm.nrseqdig
                   crablot.qtinfoln = crablot.qtinfoln + 1
                   crablot.qtcompln = crablot.qtcompln + 1
                   crablot.vlinfodb = crablot.vlinfodb + crablcm.vllanmto
                   crablot.vlcompdb = crablot.vlcompdb + crablcm.vllanmto
                   /**** FIM DO CALCULO DO RESGATE E LANCAMENTO ****/
            
                   craptdb.insittit = 1 /* resgatado */
                   craptdb.dtdpagto = ?
                   craptdb.dtresgat = par_dtresgat
                   craptdb.cdoperes = par_cdoperad
                   craptdb.vlliqres = aux_vlliqnov.

            VALIDATE crablot.
            VALIDATE crablcm.

                   FIND FIRST crapcob 
                        WHERE crapcob.cdcooper = craptdb.cdcooper
                          AND crapcob.cdbandoc = craptdb.cdbandoc
                          AND crapcob.nrdctabb = craptdb.nrdctabb
                          AND crapcob.nrdconta = craptdb.nrdconta
                          AND crapcob.nrcnvcob = craptdb.nrcnvcob
                          AND crapcob.nrdocmto = craptdb.nrdocmto
                          AND crapcob.flgregis = TRUE
                          NO-LOCK NO-ERROR.
    
                   IF  AVAIL crapcob THEN
                       DO:
                           RUN cria-log-cobranca IN h-b1wgen0088 
                               (INPUT ROWID(crapcob),
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT 'Titulo Resgatado').
                       END.
        
            
            /* Verifica se deve liquidar o bordero caso sim Liquida */
            RUN efetua_liquidacao_bordero(INPUT par_cdcooper, 
                                          INPUT par_cdagenci, 
                                          INPUT par_nrdcaixa, 
                                          INPUT par_cdoperad, 
                                          INPUT par_dtmvtolt, 
                                          INPUT par_idorigem, 
                                          INPUT par_nrdconta, 
                                          INPUT craptdb.nrborder, 
                                          OUTPUT TABLE tt-erro).
    
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        UNDO RESGATE, RETURN "NOK".                    
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Erro na liquidacao do " +
                                                  "bordero " +
                                                  STRING(craptdb.nrborder) +
                                                  " conta " +
                                                  STRING(craptdb.nrdconta).

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).

                            UNDO RESGATE, RETURN "NOK".                    
                        END.
                END.
            
        END. /* Final do FOR EACH */

        IF  VALID-HANDLE(h-b1wgen0088)  THEN
            DELETE PROCEDURE h-b1wgen0088.

    END.  /*  Fim da transacao  */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*      Buscar dados para montar contratos etc para desconto de titulos      */
/*****************************************************************************/
PROCEDURE busca_dados_impressao_dsctit:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_limorbor AS INTE                           NO-UNDO.
    /* 1 - LIMITE DSCTIT 2 - BORDERO DSCTIT */
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-emprsts.
    DEF OUTPUT PARAM TABLE FOR tt-proposta_limite.
    DEF OUTPUT PARAM TABLE FOR tt-contrato_limite.        
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-dados_nota_pro.
    DEF OUTPUT PARAM TABLE FOR tt-proposta_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-dados_tits_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-tits_do_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_bordero_restricoes.
    DEF OUTPUT PARAM TABLE FOR tt-sacado_nao_pagou.
                                          
    DEF VAR aux_dsmesref     AS CHAR          NO-UNDO.
    DEF VAR aux_nmcidade     AS CHAR          NO-UNDO.
    DEF VAR aux_nmcidage     AS CHAR          NO-UNDO.
    DEF VAR rel_nrcpfcgc     AS CHAR          NO-UNDO.
    DEF VAR aux_cdempres     AS INTE          NO-UNDO.
    DEF VAR aux_dsdtraco     AS CHAR          NO-UNDO.
    DEF VAR rel_nmempres     AS CHAR          NO-UNDO.
    DEF VAR rel_nmprimtl     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_nrdconta     AS INTE          NO-UNDO.
    DEF VAR rel_telefone     AS CHAR          NO-UNDO.
    DEF VAR rel_txdiaria     AS DECI          NO-UNDO.
    DEF VAR rel_txdanual     AS DECI          NO-UNDO.
    DEF VAR rel_txmensal     AS DECI          NO-UNDO.
    DEF VAR rel_ddmvtolt     AS INTE          NO-UNDO.
    DEF VAR rel_aamvtolt     AS INTE          NO-UNDO.
    DEF VAR rel_dsmesref     AS CHAR          NO-UNDO.
    DEF VAR rel_nmextcop     AS CHAR          NO-UNDO.
    DEF VAR rel_qtdbolet     AS INTE          NO-UNDO.
    DEF VAR aux_totbolet     AS DECI          NO-UNDO.
    DEF VAR rel_vlmedbol     AS DECI          NO-UNDO.
    DEF VAR h-b1wgen9999     AS HANDLE        NO-UNDO.
    DEF VAR rel_nmrescop     AS CHAR EXTENT 2 NO-UNDO.    
    DEF VAR aux_par_nrdconta AS INTE          NO-UNDO.
    DEF VAR aux_par_dsctrliq AS CHAR          NO-UNDO.
    DEF VAR aux_par_vlutiliz AS DECI          NO-UNDO.
    DEF VAR rel_txnrdcid     AS CHAR          NO-UNDO.
    DEF VAR rel_vllimchq     AS DECI          NO-UNDO.
    DEF VAR rel_dsdlinha     AS CHAR          NO-UNDO.
    DEF VAR rel_nmdaval1     AS CHAR          NO-UNDO.
    DEF VAR rel_dscpfav1     AS CHAR          NO-UNDO.
    DEF VAR rel_nmdcjav1     AS CHAR          NO-UNDO.
    DEF VAR rel_dscfcav1     AS CHAR          NO-UNDO.
    DEF VAR rel_dsendav1     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_nmdaval2     AS CHAR          NO-UNDO.
    DEF VAR rel_dscpfav2     AS CHAR          NO-UNDO.
    DEF VAR rel_nmdcjav2     AS CHAR          NO-UNDO.
    DEF VAR rel_dscfcav2     AS CHAR          NO-UNDO.
    DEF VAR rel_dsendav2     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR tel_dtcalcul     AS DATE          NO-UNDO.
    DEF VAR rel_dslimite     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR aux_dslinhax     AS CHAR          NO-UNDO.
    DEF VAR rel_dslinhax     AS CHAR EXTENT 4 NO-UNDO.
    DEF VAR rel_dsobserv     AS CHAR EXTENT 4 NO-UNDO.
    DEF VAR rel_txqtdvig     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_txjurmor     AS DECI          NO-UNDO.
    DEF VAR rel_dsjurmor     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_txdmulta     AS DECI          NO-UNDO.
    DEF VAR rel_txmulext     AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_dsdmoeda     AS CHAR EXTENT 2 INIT "R$" NO-UNDO.
    DEF VAR aux_dsemsnot     AS CHAR          NO-UNDO.
    DEF VAR rel_nmoperad     AS CHAR          NO-UNDO.
    DEF VAR aux_nrctrlim     AS INTE          NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-proposta_limite.
    EMPTY TEMP-TABLE tt-contrato_limite.        
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_nota_pro.
    EMPTY TEMP-TABLE tt-proposta_bordero.
    EMPTY TEMP-TABLE tt-dados_tits_bordero.
    EMPTY TEMP-TABLE tt-tits_do_bordero.
    EMPTY TEMP-TABLE tt-dsctit_bordero_restricoes.
    EMPTY TEMP-TABLE tt-sacado_nao_pagou.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                       crawlim.nrdconta = par_nrdconta AND
                       crawlim.tpctrlim = 3            AND
                       crawlim.nrctrlim = par_nrctrlim
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crawlim  THEN
        IF  crawlim.nrctrmnt > 0  THEN
            ASSIGN aux_nrctrlim = crawlim.nrctrmnt.
        ELSE
            ASSIGN aux_nrctrlim = par_nrctrlim.
    ELSE
        ASSIGN aux_nrctrlim = par_nrctrlim.
    
    IF  par_flgerlog  THEN
        DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF  par_idimpres = 1  THEN
                aux_dstransa = "Carregar dados para impressao completa " +
                               "de limite de desconto de titulo.".
            ELSE
            IF  par_idimpres = 2  THEN
                aux_dstransa = "Carregar dados para impressao do contrato " +
                               "de limite de desconto de titulo.".
            ELSE
            IF  par_idimpres = 3  THEN
                aux_dstransa = "Carregar dados para impressao da proposta " +
                               "de limite de desconto de titulo.".
            ELSE
            IF  par_idimpres = 4  THEN
                aux_dstransa = "Carregar dados para impressao da nota " +
                               "promissoria de limite de desconto de titulo.".
            ELSE
            IF  par_idimpres = 5  THEN
                aux_dstransa = "Carregar dados para impressao completa " +
                               "de bordero de desconto de titulo.".
            ELSE
            IF  par_idimpres = 6  THEN
                aux_dstransa = "Carregar dados para impressao da proposta " +
                               "de bordero de desconto de titulos.".
            ELSE
            IF  par_idimpres = 7  THEN
                aux_dstransa = "Carregar dados para impressao dos titulos " +
                               "de bordero de desconto de titulos.".
            ELSE
            IF  par_idimpres = 9  THEN
                aux_dstransa = "Carregar dados para impressao dos contratos " +
                               "do CET.".
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Tipo de impressao invalida.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        DO:
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
                        
                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).
                        
                        END.
                                          
                    RETURN "NOK".
                END.
        END.
    
    /*  Busca dados da cooperativa  */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.
            
            RETURN "NOK".                
        END.
        
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapope  THEN
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
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.            
            
            RETURN "NOK".
        END.        
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

    IF AVAIL crapage THEN
        ASSIGN aux_nmcidage = crapage.nmcidade.
    ELSE
        ASSIGN aux_nmcidage = crapcop.nmcidade.

    ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho," +
                          "Julho,Agosto,Setembro,Outubro,Novembro,Dezembro"
           aux_dsemsnot = SUBSTR(aux_nmcidage,1,15) + "," +
                          STRING(DAY(par_dtmvtolt),"99") + " de " +
                          ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) +
                          " de " +
                          STRING(YEAR(par_dtmvtolt),"9999")           
           rel_dsmesref = ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) 
           aux_dsdtraco = FILL("-",132)
           aux_nmcidade = TRIM(crapcop.nmcidade)
           rel_nmoperad = TRIM(crapope.nmoperad).

    /* Dados do associado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta  
                       NO-LOCK NO-ERROR.

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
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.
            
            RETURN "NOK".
        END.

    IF  crapass.inpessoa = 1  THEN
        DO:
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").
               
            FIND crapttl WHERE 
                 crapttl.cdcooper = par_cdcooper       AND
                 crapttl.nrdconta = crapass.nrdconta   AND
                 crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

            IF  AVAIL crapttl  THEN
                ASSIGN aux_cdempres = crapttl.cdempres.

            FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                              WHERE craptfc.cdcooper = par_cdcooper
                              AND   craptfc.nrdconta = crapass.nrdconta
                              AND   craptfc.tptelefo = 1
                              AND   craptfc.idseqttl = par_idseqttl
                              NO-LOCK:
                ASSIGN rel_telefone = STRING(craptfc.nrdddtfc) +
                                      STRING(craptfc.nrtelefo).
            END.
        END.
    ELSE
        DO:
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                         "xx.xxx.xxx/xxxx-xx").
                
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.

            IF  AVAIL crapjur  THEN
                ASSIGN aux_cdempres = crapjur.cdempres.

            FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                              WHERE craptfc.cdcooper = par_cdcooper
                              AND   craptfc.nrdconta = crapass.nrdconta
                              AND   craptfc.tptelefo = 3
                              AND   craptfc.idseqttl = par_idseqttl
                              NO-LOCK:
                ASSIGN rel_telefone = STRING(craptfc.nrdddtfc) +
                                      STRING(craptfc.nrtelefo).
            END.
        END.
        
    /* Dados da Empresa */
    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                       crapemp.cdempres = aux_cdempres   
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapemp   THEN
        rel_nmempres = STRING(aux_cdempres,"99999") + 
                              " - NAO CADASTRADA.".
    ELSE
        rel_nmempres = STRING(aux_cdempres,"99999") + 
                              " - " + crapemp.nmresemp.        

    ASSIGN rel_nmprimtl = crapass.nmprimtl
           rel_nrdconta = crapass.nrdconta
           rel_nrcpfcgc = TRIM(rel_nrcpfcgc).
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.
            
            RETURN "NOK".                
        END.
    
    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT rel_nmrescop[1],
                                         OUTPUT rel_nmrescop[2]).

    RUN busca_dados_proposta_consulta (INPUT par_cdcooper,
                                     INPUT par_cdagenci, 
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT par_idorigem, 
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl, 
                                     INPUT par_nmdatela,
                                       INPUT aux_nrctrlim,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dsctit_dados_limite,
                                    OUTPUT TABLE tt-dados-avais,
                                    OUTPUT TABLE tt-dados_dsctit).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.

            IF  par_flgerlog  THEN
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.
            
            RETURN "NOK".
        END.    
                
    FIND tt-dsctit_dados_limite NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de limite nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            DELETE PROCEDURE h-b1wgen9999.

            IF  par_flgerlog  THEN
                DO:
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
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT aux_nrctrlim).
                
                END.            
            
            RETURN "NOK".                
    END.

    /* Trata Observacoes */
    RUN quebra-str IN h-b1wgen9999 
                            (INPUT tt-dsctit_dados_limite.dsobserv, 
                             INPUT 94, 
                             INPUT 94,
                             INPUT 94,
                             INPUT 94,        
                             OUTPUT rel_dsobserv[1], 
                             OUTPUT rel_dsobserv[2],
                             OUTPUT rel_dsobserv[3],
                             OUTPUT rel_dsobserv[4]).

    /* Limite de desconto de titulo */
    IF  par_limorbor = 1 THEN
        DO:
            FIND tt-dados_dsctit NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-dados_dsctit  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro de limite craptab nao " +
                                          "encontrado.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF  par_flgerlog  THEN
                        DO:
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
                
                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).
                
                        END.            
                    
                        DELETE PROCEDURE h-b1wgen9999.
                        RETURN "NOK".
                    END.                
              
            RUN busca_total_descontos (INPUT par_cdcooper,
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

            ASSIGN aux_par_nrdconta = crapass.nrdconta
                   aux_par_dsctrliq = ""
                   aux_par_vlutiliz = 0.

            RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT aux_par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT aux_par_dsctrliq,
                                               INPUT par_inproces,
                                               INPUT FALSE,
                                              OUTPUT aux_par_vlutiliz,
                                              OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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
                
                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).
                                        
                        END.                
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    RETURN "NOK".
                END.
            
            IF   LENGTH(TRIM(crapass.tpdocptl)) > 0   THEN
                 rel_txnrdcid = crapass.tpdocptl + ": " + SUBSTR(TRIM(crapass.nrdocptl),1,15).
            ELSE 
                 rel_txnrdcid = "".  

            FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

            /*  Limite de desconto de cheque  */ 
            ASSIGN rel_vllimchq = tt-tot_descontos.vllimchq. 

            /* Linha de Desconto */ 
            ASSIGN rel_dsdlinha = STRING(tt-dsctit_dados_limite.codlinha,"999")
                                  + " - " + tt-dsctit_dados_limite.dsdlinha.

            /* Dados do 1o Avalista  */
            FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.

            IF  AVAIL tt-dados-avais  THEN
                ASSIGN rel_nmdaval1    = IF  tt-dados-avais.nmdavali = ""
                                         THEN FILL("_",40)
                                         ELSE tt-dados-avais.nmdavali
                       rel_dscpfav1    = IF  tt-dados-avais.nrcpfcgc > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcgc,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                         ELSE IF  tt-dados-avais.nrdocava = "" THEN
                                             FILL("_",40)
                                         ELSE tt-dados-avais.nrdocava
                       rel_nmdcjav1    = IF  tt-dados-avais.nmconjug = ""  THEN
                                             FILL("_",40)
                                         ELSE tt-dados-avais.nmconjug
                       rel_dscfcav1    = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                            "C.P.F. " +
                                            STRING(STRING(tt-dados-avais.nrcpfcjg,
                                            "99999999999"),"xxx.xxx.xxx-xx")                 
                                         ELSE IF  tt-dados-avais.nrdoccjg = ""  THEN
                                             FILL("_",40)
                                         ELSE tt-dados-avais.nrdoccjg
                       rel_dsendav1[1] = tt-dados-avais.dsendre1
                       rel_dsendav1[2] = tt-dados-avais.dsendre2.
            ELSE
                ASSIGN rel_nmdaval1 = FILL("_",40)
                       rel_dscpfav1 = FILL("_",40)
                       rel_nmdcjav1 = FILL("_",40)
                       rel_dscfcav1 = FILL("_",40).

            /* Dados do 2o Avalista  */
            FIND NEXT tt-dados-avais NO-LOCK NO-ERROR.

            IF   AVAIL tt-dados-avais  THEN
                 ASSIGN rel_nmdaval2    = IF   tt-dados-avais.nmdavali = ""
                                               THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmdavali
                        rel_dscpfav2    = IF   tt-dados-avais.nrcpfcgc > 0 THEN
                                               "C.P.F. " +
                                               STRING(STRING(tt-dados-avais.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx")
                                          ELSE IF tt-dados-avais.nrdocava = "" THEN
                                               FILL("_",40)
                                          ELSE tt-dados-avais.nrdocava
                        rel_nmdcjav2    = IF   tt-dados-avais.nmconjug = ""  
                                               THEN FILL("_",40)
                                               ELSE tt-dados-avais.nmconjug
                        rel_dscfcav2    = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcjg,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF   tt-dados-avais.nrdoccjg = "" THEN 
                                             FILL("_",40)
                                          ELSE tt-dados-avais.nrdoccjg
                        rel_dsendav2[1] = tt-dados-avais.dsendre1
                        rel_dsendav2[2] = tt-dados-avais.dsendre2.         
            ELSE
                 ASSIGN rel_nmdaval2 = FILL("_",40)
                        rel_dscpfav2 = FILL("_",40)
                        rel_nmdcjav2 = FILL("_",40)
                        rel_dscfcav2 = FILL("_",40).

            IF   tel_dtcalcul = ?   THEN
                 tel_dtcalcul = par_dtmvtolt.

            /*  Valor do limite .......................................... */
            RUN valor-extenso IN h-b1wgen9999 
                              (INPUT tt-dsctit_dados_limite.vllimite, 
                               INPUT 53, 
                               INPUT 70, 
                               INPUT "M", 
                               OUTPUT rel_dslimite[1], 
                               OUTPUT rel_dslimite[2]).

            ASSIGN rel_dslimite[1] = "(" + LC(rel_dslimite[1]).

            IF   LENGTH(TRIM(rel_dslimite[2])) = 0   THEN
                 ASSIGN rel_dslimite[1] = rel_dslimite[1] + ")" + FILL("*",31)
                        rel_dslimite[2] = "".
            ELSE
                 ASSIGN rel_dslimite[1] = rel_dslimite[1] + FILL("*",31)
                        rel_dslimite[2] = LC(rel_dslimite[2]) + ")".

            ASSIGN aux_dslinhax = "Inscrita no CNPJ " + 
                                  STRING(STRING(crapcop.nrdocnpj,
                                                "99999999999999"),
                                  "xx.xxx.xxx/xxxx-xx") + ", Inscricao " + 
                                  "Estadual Isenta, estabelecida na " +  
                                  crapcop.dsendcop + ", Nr. " + 
                                  STRING(crapcop.nrendcop) +
                                  ", Bairro " + crapcop.nmbairro + ", " +
                                  aux_nmcidade + ", " + crapcop.cdufdcop.
                      
            RUN quebra-str IN h-b1wgen9999 
                                    (INPUT aux_dslinhax, 
                                     INPUT 69, INPUT 69, 
                                     INPUT 69, INPUT 69, 
                                     OUTPUT rel_dslinhax[1], 
                                     OUTPUT rel_dslinhax[2],
                                     OUTPUT rel_dslinhax[3], 
                                     OUTPUT rel_dslinhax[4]).

            /*  Quantidade de dias para vigencia.................... */
            RUN valor-extenso IN h-b1wgen9999
                                 (INPUT tt-dsctit_dados_limite.qtdiavig, 
                                  INPUT 31, 
                                  INPUT 0, 
                                  INPUT "I", 
                                  OUTPUT rel_txqtdvig[1], 
                                  OUTPUT rel_txqtdvig[2]).

            ASSIGN rel_txqtdvig[1] = "(" + LC(rel_txqtdvig[1]) + ") dias.".

            /*  Taxa de juros de mora ............................. */
            ASSIGN rel_txjurmor = ROUND((EXP(1 + 
                     (tt-dsctit_dados_limite.txjurmor / 100),12) - 1) * 100,2).
 
            RUN valor-extenso IN h-b1wgen9999 
                                 (INPUT rel_txjurmor, 
                                  INPUT 52, 
                                  INPUT 37, 
                                  INPUT "P",
                                  OUTPUT rel_dsjurmor[1], 
                                  OUTPUT rel_dsjurmor[2]).

           ASSIGN rel_dsjurmor[1] = STRING(rel_txjurmor,"999.999999") + "% (" +
                                     LC(rel_dsjurmor[1]).

            IF  LENGTH(TRIM(rel_dsjurmor[2])) = 0   THEN
                 ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] + ")" + FILL("*",32)
                        rel_dsjurmor[2] = "ao ano; (" +
                                      STRING(tt-dsctit_dados_limite.txjurmor,
                                             "999.999999") + 
                                             " % a.m., capitalizados mensalmente)".
            ELSE
                 ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] + FILL("*",32)
                        rel_dsjurmor[2] = LC(rel_dsjurmor[2]) + " ao ano); (" +
                                      STRING(tt-dsctit_dados_limite.txjurmor,
                                             "999.999999") + 
                                             " % a.m., capitalizados mensalmente)".

            ASSIGN rel_txdmulta = tt-dados_dsctit.pcdmulta.

            /*  Taxa de multa por extenso ................................ */
            RUN valor-extenso IN h-b1wgen9999 
                                 (INPUT rel_txdmulta, 
                                  INPUT 36, 
                                  INPUT 50, 
                                  INPUT "P",
                                  OUTPUT rel_txmulext[1], 
                                  OUTPUT rel_txmulext[2]).

            ASSIGN rel_txmulext[1] = "(" + LC(rel_txmulext[1]).

            IF   LENGTH(TRIM(rel_txmulext[2])) = 0   THEN
                 ASSIGN rel_txmulext[1] = rel_txmulext[1] + ")" 
                        rel_txmulext[2] = "".
            ELSE
                 ASSIGN rel_txmulext[1] = rel_txmulext[1] 
                        rel_txmulext[2] = LC(rel_txmulext[2]) + ")".
        END.
    ELSE
    /* Bordero de desconto de titulo */
    IF  par_limorbor = 2  THEN    
        DO:
            RUN busca_dados_bordero (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT par_idseqttl,
                                     INPUT par_nrdconta,
                                     INPUT par_nrborder,
                                     INPUT "M",
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dsctit_dados_bordero).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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
                
                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).
                
                        END.                    

                    DELETE PROCEDURE h-b1wgen9999.
                    RETURN "NOK".

                END.    
              
            RUN busca_titulos_bordero
                                   (INPUT par_cdcooper,
                                    INPUT par_nrborder,
                                    INPUT par_nrdconta,
                                    OUTPUT TABLE tt-tits_do_bordero,
                                    OUTPUT TABLE tt-dsctit_bordero_restricoes).
                                    
            FIND FIRST tt-dsctit_dados_bordero NO-LOCK NO-ERROR.
         
            RUN busca_dados_limite (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa, 
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_idorigem, 
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl, 
                                    INPUT par_nmdatela,
                                    INPUT tt-dsctit_dados_bordero.nrctrlim,
                                    INPUT "M", 
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dsctit_dados_limite,
                                    OUTPUT TABLE tt-dados_dsctit).

            IF  RETURN-VALUE = "NOK"  THEN                        
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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
                
                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).
                
                        END.                
                    DELETE PROCEDURE h-b1wgen9999.
                    RETURN "NOK".
                END.    
              
            RUN busca_total_descontos (INPUT par_cdcooper,
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

            ASSIGN rel_txdiaria = ROUND((EXP(1 + 
                                       (tt-dsctit_dados_bordero.txmensal / 100),
                                        1 / 30) - 1) * 100,7)
                   rel_txdanual = ROUND((EXP(1 + 
                                      (tt-dsctit_dados_bordero.txmensal / 100),
                                       12) - 1) * 100,6)
                   rel_txmensal = tt-dsctit_dados_bordero.txmensal
                   rel_ddmvtolt = DAY(par_dtmvtolt)
                   rel_aamvtolt = YEAR(par_dtmvtolt)
                   rel_nmextcop = TRIM(crapcop.nmextcop).

            /*  Informacoes da Carteira de Cobranca */ 
            FOR EACH crapcob WHERE crapcob.cdcooper = par_cdcooper AND
                                   crapcob.nrdconta = par_nrdconta AND
                                   crapcob.dtelimin = ?
                                   NO-LOCK: 
                       
                /* Quantidade de Boletos */
                ASSIGN rel_qtdbolet = rel_qtdbolet + 1
                       aux_totbolet = aux_totbolet + crapcob.vltitulo.

            END.

            IF   rel_qtdbolet <> 0  THEN
                 /* Valor medio da carteira de cobranca */
                 ASSIGN rel_vlmedbol = ROUND(aux_totbolet / rel_qtdbolet, 2).
            ELSE
                 ASSIGN rel_vlmedbol = 0.        
        END.

    DELETE PROCEDURE h-b1wgen9999.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapage THEN
        RETURN "NOK".

    IF  par_idimpres = 1  THEN /* Limite - COMPLETA */
        DO: 
            RUN carrega_dados_proposta_limite
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT par_nrdconta,
                                       INPUT par_idorigem,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT par_inproces,
                                       INPUT TRIM(crapcop.nmextcop),
                                       INPUT rel_vllimchq,
                                       INPUT rel_nmempres,
                                       INPUT rel_dsdlinha,
                                       INPUT aux_par_vlutiliz,
                                       INPUT rel_dsobserv[1],
                                       INPUT rel_dsobserv[2],
                                       INPUT rel_dsobserv[3],
                                       INPUT rel_dsobserv[4],
                                       INPUT rel_dsmesref,
                                       INPUT TRIM(crapcop.nmcidade),
                                       INPUT TRIM(crapcop.nmrescop),
                                       INPUT rel_telefone,
                                       INPUT tt-dsctit_dados_limite.dsdbens1,
                                       INPUT tt-dsctit_dados_limite.dsdbens2,
                                       INPUT tt-dsctit_dados_limite.vlsalari,
                                       INPUT tt-dsctit_dados_limite.vlsalcon,
                                       INPUT tt-dsctit_dados_limite.vloutras,
                                       INPUT tt-dsctit_dados_limite.nrctrlim,
                                       INPUT tt-dsctit_dados_limite.vllimite,
                                       INPUT tt-dsctit_dados_limite.dsramati,
                                       INPUT tt-dsctit_dados_limite.vlfatura,
                                       INPUT tt-dsctit_dados_limite.vlmedtit,
                                       INPUT rel_nmoperad,
                                       INPUT rel_nmrescop[1],
                                       INPUT rel_nmrescop[2],
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-emprsts,
                                      OUTPUT TABLE tt-proposta_limite).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).    
                        END.
                                                          
                    RETURN "NOK".
                END.

            RUN carrega_dados_contrato_limite
                                         (INPUT crapage.nmcidade,
                                          INPUT crapcop.cdufdcop,
                                          INPUT tt-dsctit_dados_limite.nrctrlim,
                                          INPUT crapcop.nmextcop,
                                          INPUT crapass.cdagenci,
                                          INPUT rel_dslinhax[1],
                                          INPUT rel_dslinhax[2],
                                          INPUT rel_dslinhax[3],
                                          INPUT rel_dslinhax[4],
                                          INPUT rel_nmprimtl[1],
                                          INPUT rel_nmprimtl[2],
                                          INPUT rel_nrdconta,
                                          INPUT rel_nrcpfcgc,
                                          INPUT rel_txnrdcid,
                                          INPUT rel_dsdmoeda[1],
                                          INPUT tt-dsctit_dados_limite.vllimite,
                                          INPUT rel_dslimite[1],
                                          INPUT rel_dslimite[2],
                                          INPUT rel_dsdlinha,
                                          INPUT tt-dsctit_dados_limite.qtdiavig,
                                          INPUT rel_txqtdvig[1],
                                          INPUT rel_txqtdvig[2],
                                          INPUT rel_dsjurmor[1],
                                          INPUT rel_dsjurmor[2],
                                          INPUT rel_txdmulta,
                                          INPUT rel_txmulext[1],
                                          INPUT rel_txmulext[2],
                                          INPUT rel_nmrescop[1],
                                          INPUT rel_nmrescop[2],
                                          INPUT rel_nmdaval1,
                                          INPUT rel_nmdcjav1,
                                          INPUT rel_dscpfav1,
                                          INPUT rel_dscfcav1,
                                          INPUT rel_nmdaval2,
                                          INPUT rel_nmdcjav2,
                                          INPUT rel_dscpfav2,
                                          INPUT rel_dscfcav2,
                                          INPUT rel_nmoperad,
                                          OUTPUT TABLE tt-contrato_limite).    

            RUN carrega_dados_nota_promissoria  
                                      (INPUT par_cdcooper,
                                       INPUT crapass.cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nrdconta,
                                       INPUT rel_nrcpfcgc,
                                       INPUT aux_nrctrlim,
                                       INPUT tt-dsctit_dados_limite.vllimite,
                                       INPUT par_dtmvtolt,
                                       INPUT aux_dsmesref,
                                       INPUT aux_dsemsnot,
                                       INPUT rel_dsmesref,
                                       INPUT TRIM(crapcop.nmrescop),
                                       INPUT TRIM(crapcop.nmextcop),
                                       INPUT TRIM(STRING(crapcop.nrdocnpj)),
                                       INPUT rel_dsdmoeda[1],
                                       INPUT crapass.nmprimtl,
                                      INPUT-OUTPUT TABLE tt-dados-avais,
                                      OUTPUT TABLE tt-dados_nota_pro,
                                      OUTPUT TABLE tt-erro).
                                      
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).    
                        END.
                                                          
                    RETURN "NOK".
                END.

        END.
    ELSE
    IF  par_idimpres = 2  THEN /** Impressao CONTRATO LIMITE **/
        DO:
            RUN carrega_dados_contrato_limite
                                         (INPUT crapage.nmcidade,
                                          INPUT crapcop.cdufdcop,
                                          INPUT tt-dsctit_dados_limite.nrctrlim,
                                          INPUT crapcop.nmextcop,
                                          INPUT crapass.cdagenci,
                                          INPUT rel_dslinhax[1],
                                          INPUT rel_dslinhax[2],
                                          INPUT rel_dslinhax[3],
                                          INPUT rel_dslinhax[4],
                                          INPUT rel_nmprimtl[1],
                                          INPUT rel_nmprimtl[2],
                                          INPUT rel_nrdconta,
                                          INPUT rel_nrcpfcgc,
                                          INPUT rel_txnrdcid,
                                          INPUT rel_dsdmoeda[1],
                                          INPUT tt-dsctit_dados_limite.vllimite,
                                          INPUT rel_dslimite[1],
                                          INPUT rel_dslimite[2],
                                          INPUT rel_dsdlinha,
                                          INPUT tt-dsctit_dados_limite.qtdiavig,
                                          INPUT rel_txqtdvig[1],
                                          INPUT rel_txqtdvig[2],
                                          INPUT rel_dsjurmor[1],
                                          INPUT rel_dsjurmor[2],
                                          INPUT rel_txdmulta,
                                          INPUT rel_txmulext[1],
                                          INPUT rel_txmulext[2],
                                          INPUT rel_nmrescop[1],
                                          INPUT rel_nmrescop[2],
                                          INPUT rel_nmdaval1,
                                          INPUT rel_nmdcjav1,
                                          INPUT rel_dscpfav1,
                                          INPUT rel_dscfcav1,
                                          INPUT rel_nmdaval2,
                                          INPUT rel_nmdcjav2,
                                          INPUT rel_dscpfav2,
                                          INPUT rel_dscfcav2,
                                          INPUT rel_nmoperad,
                                          OUTPUT TABLE tt-contrato_limite).
        END.
    ELSE
    IF  par_idimpres = 3  THEN /** Impressao PROPOSTA **/
        DO:
            RUN carrega_dados_proposta_limite
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT par_nrdconta,
                                       INPUT par_idorigem,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT par_inproces,
                                       INPUT TRIM(crapcop.nmextcop),
                                       INPUT rel_vllimchq,
                                       INPUT rel_nmempres,
                                       INPUT rel_dsdlinha,
                                       INPUT aux_par_vlutiliz,
                                       INPUT rel_dsobserv[1],
                                       INPUT rel_dsobserv[2],
                                       INPUT rel_dsobserv[3],
                                       INPUT rel_dsobserv[4],
                                       INPUT rel_dsmesref,
                                       INPUT TRIM(crapcop.nmcidade),
                                       INPUT TRIM(crapcop.nmrescop),
                                       INPUT rel_telefone,
                                       INPUT tt-dsctit_dados_limite.dsdbens1,
                                       INPUT tt-dsctit_dados_limite.dsdbens2,
                                       INPUT tt-dsctit_dados_limite.vlsalari,
                                       INPUT tt-dsctit_dados_limite.vlsalcon,
                                       INPUT tt-dsctit_dados_limite.vloutras,
                                       INPUT tt-dsctit_dados_limite.nrctrlim,
                                       INPUT tt-dsctit_dados_limite.vllimite,
                                       INPUT tt-dsctit_dados_limite.dsramati,
                                       INPUT tt-dsctit_dados_limite.vlfatura,
                                       INPUT tt-dsctit_dados_limite.vlmedtit,
                                       INPUT rel_nmoperad,
                                       INPUT rel_nmrescop[1],
                                       INPUT rel_nmrescop[2],
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-emprsts,
                                      OUTPUT TABLE tt-proposta_limite).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).    
                        END.
                                                          
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_idimpres = 4  THEN /** Impressao Nota Promissoria **/
        DO:   
            RUN carrega_dados_nota_promissoria  
                                      (INPUT par_cdcooper,
                                       INPUT crapass.cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nrdconta,
                                       INPUT rel_nrcpfcgc,
                                       INPUT aux_nrctrlim,
                                       INPUT tt-dsctit_dados_limite.vllimite,
                                       INPUT par_dtmvtolt,
                                       INPUT aux_dsmesref,
                                       INPUT aux_dsemsnot,
                                       INPUT rel_dsmesref,
                                       INPUT TRIM(crapcop.nmrescop),
                                       INPUT TRIM(crapcop.nmextcop),
                                       INPUT TRIM(STRING(crapcop.nrdocnpj)),
                                       INPUT rel_dsdmoeda[1],
                                       INPUT crapass.nmprimtl,
                                      INPUT-OUTPUT TABLE tt-dados-avais,
                                      OUTPUT TABLE tt-dados_nota_pro,
                                      OUTPUT TABLE tt-erro).
                                      
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrctrlim",
                                                    INPUT "",
                                                    INPUT aux_nrctrlim).    
                        END.
                                                          
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_idimpres = 5  THEN /** Impressao Bordero Completa **/
        DO:
            RUN carrega_dados_proposta_bordero 
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_idorigem,
                                   INPUT par_idseqttl,
                                   INPUT par_nmdatela,
                                   INPUT par_inproces,
                                   INPUT rel_telefone,
                                   INPUT tt-dsctit_dados_limite.dsdbens1,
                                   INPUT tt-dsctit_dados_limite.dsdbens2,
                                   INPUT tt-dsctit_dados_limite.vlsalari,
                                   INPUT tt-dsctit_dados_limite.vlsalcon,
                                   INPUT tt-dsctit_dados_limite.vloutras,
                                   INPUT aux_nrctrlim,
                                   INPUT par_nrborder,
                                   INPUT tt-dsctit_dados_limite.vllimite,
                                   INPUT rel_dsobserv[1],
                                   INPUT rel_dsobserv[2],
                                   INPUT rel_dsobserv[3],
                                   INPUT rel_dsobserv[4],
                                   INPUT tt-tot_descontos.vldsctit,
                                   INPUT tt-tot_descontos.qtdsctit,
                                   INPUT tt-tot_descontos.vlmaxtit,
                                   INPUT IF tt-dsctit_dados_limite.insitlim = 2
                                         THEN tt-dsctit_dados_limite.vllimite
                                         ELSE 0,
                                   INPUT tt-tot_descontos.vllimchq,
                                   INPUT rel_nmempres,
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT tt-dsctit_dados_limite.dsramati,
                                   INPUT rel_qtdbolet,
                                   INPUT rel_vlmedbol,
                                   INPUT tt-dados_dsctit.nrmespsq,
                                   INPUT tt-dsctit_dados_limite.vlfatura,
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT TRIM(crapcop.nmcidade),
                                   INPUT rel_nmoperad,
                                  OUTPUT TABLE tt-proposta_bordero,
                                  OUTPUT TABLE tt-emprsts,
                                  OUTPUT TABLE tt-erro).
                                      
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrborder",
                                                    INPUT "",
                                                    INPUT par_nrborder).    
                        END.
                                                          
                    RETURN "NOK".
                END.

            RUN carrega_dados_bordero_titulos
                           (INPUT par_cdcooper, 
                            INPUT crapass.cdagenci, 
                            INPUT par_nrdconta, 
                            INPUT par_dtmvtolt, 
                            INPUT aux_nrctrlim, 
                            INPUT par_nrborder,
                            INPUT tt-dados_dsctit.nrmespsq,
                            INPUT rel_txdiaria,
                            INPUT rel_txmensal,
                            INPUT rel_txdanual,
                            INPUT tt-dsctit_dados_limite.vllimite,
                            INPUT rel_ddmvtolt,
                            INPUT rel_dsmesref,
                            INPUT rel_aamvtolt,
                            INPUT crapass.nmprimtl,
                            INPUT rel_nmrescop[1],
                            INPUT rel_nmrescop[2],
                            INPUT TRIM(crapcop.nmcidade),
                            INPUT rel_nmoperad,
                           OUTPUT TABLE tt-dados_tits_bordero,
                           OUTPUT TABLE tt-tits_do_bordero,
                           OUTPUT TABLE tt-dsctit_bordero_restricoes,
                           OUTPUT TABLE tt-sacado_nao_pagou).
 
        END.
    ELSE
    IF  par_idimpres = 6  THEN /** Impressao Proposta de bordero **/
        DO:
            RUN carrega_dados_proposta_bordero 
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_idorigem,
                                   INPUT par_idseqttl,
                                   INPUT par_nmdatela,
                                   INPUT par_inproces,
                                   INPUT rel_telefone,
                                   INPUT tt-dsctit_dados_limite.dsdbens1,
                                   INPUT tt-dsctit_dados_limite.dsdbens2,
                                   INPUT tt-dsctit_dados_limite.vlsalari,
                                   INPUT tt-dsctit_dados_limite.vlsalcon,
                                   INPUT tt-dsctit_dados_limite.vloutras,
                                   INPUT aux_nrctrlim,
                                   INPUT par_nrborder,
                                   INPUT tt-dsctit_dados_limite.vllimite,
                                   INPUT rel_dsobserv[1],
                                   INPUT rel_dsobserv[2],
                                   INPUT rel_dsobserv[3],
                                   INPUT rel_dsobserv[4],
                                   INPUT tt-tot_descontos.vldsctit,
                                   INPUT tt-tot_descontos.qtdsctit,
                                   INPUT tt-tot_descontos.vlmaxtit,
                                   INPUT IF tt-dsctit_dados_limite.insitlim = 2
                                         THEN tt-dsctit_dados_limite.vllimite
                                         ELSE 0,
                                   INPUT tt-tot_descontos.vllimchq,
                                   INPUT rel_nmempres,
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT tt-dsctit_dados_limite.dsramati,
                                   INPUT rel_qtdbolet,
                                   INPUT rel_vlmedbol,
                                   INPUT tt-dados_dsctit.nrmespsq,
                                   INPUT tt-dsctit_dados_limite.vlfatura,
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT TRIM(crapcop.nmcidade),
                                   INPUT rel_nmoperad,
                                  OUTPUT TABLE tt-proposta_bordero,
                                  OUTPUT TABLE tt-emprsts,
                                  OUTPUT TABLE tt-erro).
                                      
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrborder",
                                                    INPUT "",
                                                    INPUT par_nrborder).    
                        END.
                                                          
                    RETURN "NOK".
                END.
        END.        
    ELSE
    IF  par_idimpres = 7  THEN /** Impressao dos titulos do bordero **/
        DO:
            RUN carrega_dados_bordero_titulos
                           (INPUT par_cdcooper, 
                            INPUT crapass.cdagenci, 
                            INPUT par_nrdconta, 
                            INPUT par_dtmvtolt, 
                            INPUT aux_nrctrlim, 
                            INPUT par_nrborder,
                            INPUT tt-dados_dsctit.nrmespsq,
                            INPUT rel_txdiaria,
                            INPUT rel_txmensal,
                            INPUT rel_txdanual,
                            INPUT tt-dsctit_dados_limite.vllimite,
                            INPUT rel_ddmvtolt,
                            INPUT rel_dsmesref,
                            INPUT rel_aamvtolt,
                            INPUT crapass.nmprimtl,
                            INPUT rel_nmrescop[1],
                            INPUT rel_nmrescop[2],
                            INPUT TRIM(crapcop.nmcidade),
                            INPUT rel_nmoperad,
                           OUTPUT TABLE tt-dados_tits_bordero,
                           OUTPUT TABLE tt-tits_do_bordero,
                           OUTPUT TABLE tt-dsctit_bordero_restricoes,
                           OUTPUT TABLE tt-sacado_nao_pagou).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF  par_flgerlog  THEN
                        DO:
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

                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                    INPUT "nrborder",
                                                    INPUT "",
                                                    INPUT par_nrborder).    
                        END.
                                                          
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_idimpres = 9  THEN /** Impressao CONTRATO DO CET **/
        DO:
            RUN carrega_dados_contrato_limite
                                       (INPUT crapage.nmcidade,
                                        INPUT crapcop.cdufdcop,
                                        INPUT tt-dsctit_dados_limite.nrctrlim,
                                        INPUT crapcop.nmextcop,
                                        INPUT crapass.cdagenci,
                                        INPUT rel_dslinhax[1],
                                        INPUT rel_dslinhax[2],
                                        INPUT rel_dslinhax[3],
                                        INPUT rel_dslinhax[4],
                                        INPUT rel_nmprimtl[1],
                                        INPUT rel_nmprimtl[2],
                                        INPUT rel_nrdconta,
                                        INPUT rel_nrcpfcgc,
                                        INPUT rel_txnrdcid,
                                        INPUT rel_dsdmoeda[1],
                                        INPUT tt-dsctit_dados_limite.vllimite,
                                        INPUT rel_dslimite[1],
                                        INPUT rel_dslimite[2],
                                        INPUT rel_dsdlinha,
                                        INPUT tt-dsctit_dados_limite.qtdiavig,
                                        INPUT rel_txqtdvig[1],
                                        INPUT rel_txqtdvig[2],
                                        INPUT rel_dsjurmor[1],
                                        INPUT rel_dsjurmor[2],
                                        INPUT rel_txdmulta,
                                        INPUT rel_txmulext[1],
                                        INPUT rel_txmulext[2],
                                        INPUT rel_nmrescop[1],
                                        INPUT rel_nmrescop[2],
                                        INPUT rel_nmdaval1,
                                        INPUT rel_nmdcjav1,
                                        INPUT rel_dscpfav1,
                                        INPUT rel_dscfcav1,
                                        INPUT rel_nmdaval2,
                                        INPUT rel_nmdcjav2,
                                        INPUT rel_dscpfav2,
                                        INPUT rel_dscfcav2,
                                        INPUT rel_nmoperad,
                                        OUTPUT TABLE tt-contrato_limite).
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
                               
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT aux_nrctrlim).
        END.                       

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*              Carrega dados para impressao do contrato de limite           */
/*****************************************************************************/
PROCEDURE carrega_dados_contrato_limite:

    DEF INPUT PARAM par_nmcidade AS CHAR NO-UNDO.    
    DEF INPUT PARAM par_cdufdcop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmextcop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_dslinha1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dslinha2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dslinha3 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dslinha4 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmprimt1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmprimt2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS CHAR NO-UNDO.
    DEF INPUT PARAM par_txnrdcid AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdmoeda AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vllimite AS DECI NO-UNDO.
    DEF INPUT PARAM par_dslimit1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dslimit2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdlinha AS CHAR NO-UNDO.
    DEF INPUT PARAM par_qtdiavig AS INTE NO-UNDO.
    DEF INPUT PARAM par_txqtdvi1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_txqtdvi2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsjurmo1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsjurmo2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_txdmulta AS DECI NO-UNDO.
    DEF INPUT PARAM par_txmulex1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_txmulex2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdaval1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdcjav1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dscpfav1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dscfcav1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdaval2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdcjav2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dscpfav2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dscfcav2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmoperad AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-contrato_limite.

    EMPTY TEMP-TABLE tt-contrato_limite.
    
    CREATE tt-contrato_limite.
    ASSIGN tt-contrato_limite.nmcidade = SUBSTR(par_nmcidade,1,15) 
                                         + " " + par_cdufdcop + 
                                         ",___________________________"
           tt-contrato_limite.nrctrlim = par_nrctrlim
           tt-contrato_limite.nmextcop = par_nmextcop 
           tt-contrato_limite.cdagenci = par_cdagenci
           tt-contrato_limite.dslinha1 = par_dslinha1
           tt-contrato_limite.dslinha2 = par_dslinha2
           tt-contrato_limite.dslinha3 = par_dslinha3
           tt-contrato_limite.dslinha4 = par_dslinha4
           tt-contrato_limite.nmprimt1 = par_nmprimt1
           tt-contrato_limite.nmprimt2 = par_nmprimt2
           tt-contrato_limite.nrdconta = par_nrdconta
           tt-contrato_limite.nrcpfcgc = par_nrcpfcgc
           tt-contrato_limite.txnrdcid = par_txnrdcid
           tt-contrato_limite.dsdmoeda = par_dsdmoeda
           tt-contrato_limite.vllimite = par_vllimite
           tt-contrato_limite.dslimit1 = par_dslimit1
           tt-contrato_limite.dslimit2 = par_dslimit2
           tt-contrato_limite.dsdlinha = par_dsdlinha
           tt-contrato_limite.qtdiavig = par_qtdiavig
           tt-contrato_limite.txqtdvi1 = par_txqtdvi1
           tt-contrato_limite.txqtdvi2 = par_txqtdvi2
           tt-contrato_limite.dsjurmo1 = par_dsjurmo1
           tt-contrato_limite.dsjurmo2 = par_dsjurmo2
           tt-contrato_limite.txdmulta = STRING(par_txdmulta,"zz9.9999999")
           tt-contrato_limite.txmulex1 = par_txmulex1
           tt-contrato_limite.txmulex2 = par_txmulex2
           tt-contrato_limite.nmresco1 = par_nmresco1
           tt-contrato_limite.nmresco2 = par_nmresco2
           tt-contrato_limite.nmdaval1 = par_nmdaval1
           tt-contrato_limite.nmdcjav1 = par_nmdcjav1
           tt-contrato_limite.dscpfav1 = par_dscpfav1
           tt-contrato_limite.dscfcav1 = par_dscfcav1
           tt-contrato_limite.nmdaval2 = par_nmdaval2
           tt-contrato_limite.nmdcjav2 = par_nmdcjav2
           tt-contrato_limite.dscpfav2 = par_dscpfav2
           tt-contrato_limite.dscfcav2 = par_dscfcav2
           tt-contrato_limite.nmoperad = par_nmoperad.
           
    RETURN "OK".           

END PROCEDURE.

/*****************************************************************************/
/*              Carrega dados para a proposta de limite                      */
/*****************************************************************************/
PROCEDURE carrega_dados_proposta_limite:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.    
    DEF INPUT PARAM par_dtmvtopr AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmextcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_vllimchq AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_nmempres AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsdlinha AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_vlutiliz AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_dsobser1 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsobser2 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsobser3 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsobser4 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsmesref AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmcidade AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_telefone AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsdeben1 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsdeben2 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_vlsalari AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlsalcon AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vloutras AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vllimpro AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_dsramati AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_vlfatura AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlmedtit AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_nmoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmresco1 AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmresco2 AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-emprsts.
    DEF OUTPUT PARAM TABLE FOR tt-proposta_limite.
    
    DEF VAR h-b1wgen0001 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0002 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0004 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0006 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE                          NO-UNDO.
    DEF VAR rel_dsagenci AS CHAR                            NO-UNDO.
    DEF VAR rel_vlaplica AS DECI                            NO-UNDO.
    DEF VAR aux_vltotccr AS DECI                            NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR                            NO-UNDO.
    DEF VAR aux_dssitdct AS CHAR                            NO-UNDO.
    DEF VAR aux_vlsmdtri AS DECI                            NO-UNDO.
    DEF VAR aux_vltotemp AS DECI                            NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                            NO-UNDO.
    DEF VAR aux_qtprecal AS INTE                            NO-UNDO.
    DEF VAR aux_vlcaptal AS DECI                            NO-UNDO.
    DEF VAR aux_vlprepla AS DECI                            NO-UNDO.
    DEF VAR aux_vlsdrdpp AS DECI DECIMALS 8                 NO-UNDO.
    DEF VAR tot_vlsdeved AS DECI                            NO-UNDO.
    DEF VAR tot_vlpreemp AS DECI                            NO-UNDO.
    DEF VAR aux_flgativo AS LOG                             NO-UNDO.
    DEF VAR aux_nrctrhcj AS INT                             NO-UNDO.
    DEF VAR aux_flgliber AS LOG                             NO-UNDO.
    DEF VAR aux_qtregist AS INTE                            NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE                          NO-UNDO.    
    DEF VAR aux_vlsldrgt AS DEC                             NO-UNDO.
    DEF VAR aux_vlsldtot AS DEC                             NO-UNDO.
    DEF VAR aux_vlsldapl AS DEC                             NO-UNDO.

    DEF VAR aux_dtassele AS DATE                            NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                            NO-UNDO. /* Data de corte */

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-proposta_limite.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    FIND crapage WHERE crapage.cdcooper = par_cdcooper       AND
                       crapage.cdagenci = crapass.cdagenci   NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage   THEN
         ASSIGN rel_dsagenci = TRIM(STRING(crapass.cdagenci,"zz9")) + 
                               " - NAO CADASTRADA".
    ELSE
         ASSIGN rel_dsagenci = TRIM(STRING(crapass.cdagenci,"zz9")) + " - " +
                               crapage.nmresage.

        /** Saldo das aplicacoes **/
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                SET h-b1wgen0081.        
   
        IF  VALID-HANDLE(h-b1wgen0081)  THEN
                DO:
                        ASSIGN aux_vlsldtot = 0.

                        
                        RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                                                          (INPUT par_cdcooper,
                                                                           INPUT par_cdagenci,
                                                                           INPUT 1,
                                                                           INPUT 1,
                                                                           INPUT par_nmdatela,
                                                                           INPUT 1,
                                                                           INPUT par_nrdconta,
                                                                           INPUT 1,
                                                                           INPUT 0,
                                                                           INPUT par_nmdatela,
                                                                           INPUT FALSE,
                                                                           INPUT ?,
                                                                           INPUT ?,
                                                                           OUTPUT rel_vlaplica,
                                                                           OUTPUT TABLE tt-saldo-rdca,
                                                                           OUTPUT TABLE tt-erro).
                
                        IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                        DELETE PROCEDURE h-b1wgen0081.
                                        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                                        IF  AVAILABLE tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                        ELSE
                                                MESSAGE "Erro nos dados das aplicacoes.".
                
                                        NEXT.
                                END.

                        DELETE PROCEDURE h-b1wgen0081.
                END.
         
           DO TRANSACTION ON ERROR UNDO, RETRY:
                 /*Busca Saldo Novas Aplicacoes*/
                 
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                  RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                                                         INPUT '1',            /* Código do Operador */
                                                                         INPUT par_nmdatela, /* Nome da Tela */
                                                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                                         INPUT par_nrdconta, /* Número da Conta */
                                                                         INPUT 1,            /* Titular da Conta */
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
                                                                                          
                 ASSIGN rel_vlaplica = aux_vlsldrgt + rel_vlaplica.
         END.
         /*Fim Busca Saldo Novas Aplicacoes*/


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
                                                  OUTPUT aux_vlsdrdpp,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-dados-rpp). 
                                   
            DELETE PROCEDURE h-b1wgen0006.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    RETURN "NOK".
                END.
        
            ASSIGN rel_vlaplica = rel_vlaplica + aux_vlsdrdpp.
        END.
    
    /* Totaliza os limites de cartao de credito */
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
             
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
            IF  AVAIL tt-lim_total  THEN
                aux_vltotccr = tt-lim_total.vltotccr.
        END.
        
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.
        
    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0001.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem-cabecalho IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT "",
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.

    RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    DELETE PROCEDURE h-b1wgen0001.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-cabec NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-cabec  THEN
        ASSIGN aux_dstipcta = tt-cabec.dstipcta
               aux_dssitdct = tt-cabec.dssitdct.
        
    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-comp_medias  THEN
        ASSIGN aux_vlsmdtri = tt-comp_medias.vlsmdtri.

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0030",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".    
    
    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlsdeved <> 0 NO-LOCK:

        CREATE tt-emprsts. 
        ASSIGN tt-emprsts.nrctremp = tt-dados-epr.nrctremp
               tt-emprsts.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprsts.vlemprst = tt-dados-epr.vlemprst
               tt-emprsts.dspreapg = tt-dados-epr.dspreapg
               tt-emprsts.vlpreemp = tt-dados-epr.vlpreemp
               tt-emprsts.dslcremp = tt-dados-epr.dslcremp
               tt-emprsts.dsfinemp = tt-dados-epr.dsfinemp
               tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved
               tot_vlpreemp = tot_vlpreemp + tt-dados-epr.vlpreemp.            
    END.
        
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT FALSE, /** NAO GERAR LOG **/
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".    
        
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-dados-capital  THEN
        ASSIGN aux_vlcaptal = tt-dados-capital.vlcaptal
               aux_vlprepla = tt-dados-capital.vlprepla.
    

    CREATE tt-proposta_limite.
    ASSIGN tt-proposta_limite.dsagenci = rel_dsagenci
           tt-proposta_limite.vlaplica = rel_vlaplica
           tt-proposta_limite.vltotccr = aux_vltotccr
           tt-proposta_limite.telefone = par_telefone
           tt-proposta_limite.dstipcta = aux_dstipcta
           tt-proposta_limite.vlsmdtri = aux_vlsmdtri
           tt-proposta_limite.vlcaptal = aux_vlcaptal
           tt-proposta_limite.vlprepla = aux_vlprepla
           tt-proposta_limite.dsdeben1 = par_dsdeben1
           tt-proposta_limite.dsdeben2 = par_dsdeben2
           tt-proposta_limite.vlsalari = par_vlsalari
           tt-proposta_limite.vlsalcon = par_vlsalcon
           tt-proposta_limite.vloutras = par_vloutras
           tt-proposta_limite.ddmvtolt = DAY(par_dtmvtolt)
           tt-proposta_limite.aamvtolt = YEAR(par_dtmvtolt)
           tt-proposta_limite.nrctrlim = par_nrctrlim
           tt-proposta_limite.vllimpro = par_vllimpro
           tt-proposta_limite.nrdconta = par_nrdconta
           tt-proposta_limite.nrmatric = tt-cabec.nrmatric
           tt-proposta_limite.nmprimtl = tt-cabec.nmprimtl
           tt-proposta_limite.dtadmemp = tt-cabec.dtadmemp
           tt-proposta_limite.nmempres = par_nmempres
           tt-proposta_limite.nrcpfcgc = tt-cabec.nrcpfcgc
           tt-proposta_limite.dssitdct = aux_dssitdct
           tt-proposta_limite.dtadmiss = tt-cabec.dtadmiss
           tt-proposta_limite.nmextcop = par_nmextcop
           tt-proposta_limite.dsramati = par_dsramati
           tt-proposta_limite.vllimcre = tt-cabec.vllimcre
           tt-proposta_limite.vllimchq = par_vllimchq
           tt-proposta_limite.vlfatura = par_vlfatura
           tt-proposta_limite.vlmedtit = par_vlmedtit
           tt-proposta_limite.dsdlinha = par_dsdlinha
           tt-proposta_limite.vlsdeved = tot_vlsdeved
           tt-proposta_limite.vlpreemp = tot_vlpreemp
           tt-proposta_limite.dtcalcul = par_dtmvtolt
           tt-proposta_limite.vlutiliz = par_vlutiliz
           tt-proposta_limite.dsobser1 = par_dsobser1
           tt-proposta_limite.dsobser2 = par_dsobser2
           tt-proposta_limite.dsobser3 = par_dsobser3
           tt-proposta_limite.dsobser4 = par_dsobser4
           tt-proposta_limite.dsmesref = par_dsmesref
           tt-proposta_limite.nmcidade = par_nmcidade
           tt-proposta_limite.nmrescop = par_nmrescop
           tt-proposta_limite.nmresco1 = par_nmresco1
           tt-proposta_limite.nmresco2 = par_nmresco2
           tt-proposta_limite.nmoperad = par_nmoperad.
                                       

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*          Carregas dados para efetuar a impressao da nota promissoria      */
/*****************************************************************************/
PROCEDURE carrega_dados_nota_promissoria:

    DEF INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE            NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE            NO-UNDO.
    DEF INPUT PARAM par_vllimite AS DECI            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.
    DEF INPUT PARAM par_dsmesre2 AS CHAR            NO-UNDO. /*aux_dsmesref*/
    DEF INPUT PARAM par_dsemsnot AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_dsmesref AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_nmextcop AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_nrdocnpj AS CHAR            NO-UNDO. /*cnpj do cop*/
    DEF INPUT PARAM par_dsdmoeda AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR            NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT       PARAM TABLE FOR tt-dados_nota_pro.
    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen9999 AS HANDLE        NO-UNDO.
    DEF VAR rel_dsqtdava AS CHAR          NO-UNDO.
    DEF VAR aux_dsextens AS CHAR          NO-UNDO.   
    DEF VAR aux_dsbranco AS CHAR          NO-UNDO.
    DEF VAR rel_dsmvtolt AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR rel_dspreemp AS CHAR EXTENT 2 NO-UNDO.
    DEF VAR aux_nmcidpac AS CHAR          NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_nota_pro.

    /* Dados do 1o Avalista  */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 1 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   AVAIL tt-dados-avais  THEN
         ASSIGN tt-dados-avais.dsendre1 = IF TRIM(tt-dados-avais.dsendre1) = ""
                                          THEN FILL("_",40)
                                          ELSE 
                                          IF tt-dados-avais.nrendere > 0 
                                          THEN SUBSTR(tt-dados-avais.dsendre1,
                                                      1,32) + " " +
                                            TRIM(STRING(tt-dados-avais.nrendere,
                                                        "zzz,zz9"))
                                          ELSE tt-dados-avais.dsendre1
                                     
                tt-dados-avais.dsendre2 = IF TRIM(tt-dados-avais.dsendre2) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.dsendre2
                                               
                tt-dados-avais.dsendre3 = IF tt-dados-avais.nrcepend = 0  AND
                                             tt-dados-avais.nmcidade = "" AND
                                             tt-dados-avais.cdufresd = "" 
                                          THEN FILL("_",40)
                                          ELSE STRING(tt-dados-avais.nrcepend,
                                                      "99999,999") + " - " +
                                               tt-dados-avais.nmcidade + "/" +
                                               tt-dados-avais.cdufresd

                tt-dados-avais.nmdavali = IF TRIM(tt-dados-avais.nmdavali) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmdavali

                tt-dados-avais.nrdocava = IF TRIM(tt-dados-avais.nrdocava) = ""
                                               THEN FILL("_",40)
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nrdocava = IF tt-dados-avais.nrctaava > 0 THEN
                                             tt-dados-avais.nrdocava + " - " +
                                             TRIM(STRING(tt-dados-avais.nrctaava,
                                                           "zzzz,zzz,9"))
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nmconjug = IF TRIM(tt-dados-avais.nmconjug) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmconjug

                tt-dados-avais.nrdoccjg = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcjg,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF TRIM(tt-dados-avais.nrdoccjg) = "" THEN 
                                             FILL("_",40)
                                          ELSE tt-dados-avais.nrdoccjg.

    ELSE
         DO:
             CREATE tt-dados-avais.
             ASSIGN tt-dados-avais.idavalis = 1
                    tt-dados-avais.dsendre1 = FILL("_",40)
                    tt-dados-avais.dsendre2 = FILL("_",40)
                    tt-dados-avais.dsendre3 = FILL("_",40)
                    tt-dados-avais.nmdavali = FILL("_",40)
                    tt-dados-avais.nrdocava = FILL("_",40)
                    tt-dados-avais.nmconjug = FILL("_",40)
                    tt-dados-avais.nrdoccjg = FILL("_",40).
         END.                    
    
    ASSIGN rel_dsqtdava = "Avalista:".

    /* Dados do 2o Avalista  */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 2
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   AVAIL tt-dados-avais  THEN
         ASSIGN tt-dados-avais.dsendre1 = IF TRIM(tt-dados-avais.dsendre1) = ""
                                          THEN FILL("_",40)
                                          ELSE 
                                          IF tt-dados-avais.nrendere > 0 
                                          THEN SUBSTR(tt-dados-avais.dsendre1,
                                                      1,32) + " " +
                                            TRIM(STRING(tt-dados-avais.nrendere,
                                                        "zzz,zz9"))
                                          ELSE tt-dados-avais.dsendre1
                                     
                tt-dados-avais.dsendre2 = IF TRIM(tt-dados-avais.dsendre2) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.dsendre2
                                               
                tt-dados-avais.dsendre3 = IF tt-dados-avais.nrcepend = 0  AND
                                             tt-dados-avais.nmcidade = "" AND
                                             tt-dados-avais.cdufresd = "" 
                                          THEN FILL("_",40)
                                          ELSE STRING(tt-dados-avais.nrcepend,
                                                      "99999,999") + " - " +
                                               tt-dados-avais.nmcidade + "/" +
                                               tt-dados-avais.cdufresd

                tt-dados-avais.nmdavali = IF TRIM(tt-dados-avais.nmdavali) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmdavali
                
                tt-dados-avais.nrdocava = IF TRIM(tt-dados-avais.nrdocava) = ""
                                               THEN FILL("_",40)
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nrdocava = IF tt-dados-avais.nrctaava > 0 THEN
                                             tt-dados-avais.nrdocava + " - " +
                                             TRIM(STRING(tt-dados-avais.nrctaava,
                                                           "zzzz,zzz,9"))
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nmconjug = IF TRIM(tt-dados-avais.nmconjug) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmconjug

                tt-dados-avais.nrdoccjg = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcjg,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF TRIM(tt-dados-avais.nrdoccjg) = "" THEN 
                                             FILL("_",40)
                                          ELSE tt-dados-avais.nrdoccjg

                rel_dsqtdava = "Avalistas:".
    ELSE
        DO:
            CREATE tt-dados-avais.
            ASSIGN tt-dados-avais.idavalis = 2
                   tt-dados-avais.dsendre1 = FILL("_",40)
                   tt-dados-avais.dsendre2 = FILL("_",40)
                   tt-dados-avais.dsendre3 = FILL("_",40)
                   tt-dados-avais.nmdavali = FILL("_",40)
                   tt-dados-avais.nrdocava = FILL("_",40)
                   tt-dados-avais.nmconjug = FILL("_",40)
                   tt-dados-avais.nrdoccjg = FILL("_",40).
        END.                   

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.
    
    IF   LENGTH(par_dsemsnot) < 33   THEN
         ASSIGN par_dsemsnot = FILL(" ",33 - LENGTH(par_dsemsnot)) +
                               par_dsemsnot.    
    FIND crapenc WHERE 
         crapenc.cdcooper = par_cdcooper      AND
         crapenc.nrdconta = crapass.nrdconta  AND
         crapenc.idseqttl = 1                 AND
         crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

    IF  DAY(par_dtmvtolt) > 1  THEN
        DO:
            RUN valor-extenso IN h-b1wgen9999 (INPUT DAY(par_dtmvtolt), 
                                               INPUT 50,
                                               INPUT 50, 
                                               INPUT "I",
                                              OUTPUT aux_dsextens, 
                                              OUTPUT aux_dsbranco).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = aux_dsextens.
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.
        
            ASSIGN aux_dsextens = aux_dsextens + " DIAS DO MES DE " +
                                  CAPS(ENTRY(MONTH(par_dtmvtolt),par_dsmesre2)) 
                                  + " DE ".  

            RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                               INPUT 68 - LENGTH(aux_dsextens),
                                               INPUT 44, 
                                               INPUT "I",
                                              OUTPUT rel_dsmvtolt[1], 
                                              OUTPUT rel_dsmvtolt[2]).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = rel_dsmvtolt[1].
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.

            ASSIGN rel_dsmvtolt[1] = aux_dsextens + rel_dsmvtolt[1]
                   rel_dsmvtolt[1] = rel_dsmvtolt[1] + 
                                      FILL("*",78 - LENGTH(rel_dsmvtolt[1]))
                   rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                      FILL("*",8 - LENGTH(rel_dsmvtolt[2])).
        END.
    ELSE
        DO:            
            ASSIGN aux_dsextens = "PRIMEIRO DIA DO MES DE " +
                                  CAPS(ENTRY(MONTH(par_dtmvtolt),par_dsmesre2))
                                  + " DE ".

            RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                               INPUT 68 - LENGTH(aux_dsextens),
                                               INPUT 44, 
                                               INPUT "I",
                                              OUTPUT rel_dsmvtolt[1], 
                                              OUTPUT rel_dsmvtolt[2]).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = rel_dsmvtolt[1].
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.

            ASSIGN rel_dsmvtolt[1] = aux_dsextens + rel_dsmvtolt[1]
                   rel_dsmvtolt[1] = rel_dsmvtolt[1] + 
                                      FILL("*",78 - LENGTH(rel_dsmvtolt[1]))
                   rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                      FILL("*",8 - LENGTH(rel_dsmvtolt[2])).
        END.
            
    RUN valor-extenso IN h-b1wgen9999 
                     (INPUT par_vllimite, 
                      INPUT 45, 
                      INPUT 73, 
                      INPUT "M", 
                     OUTPUT rel_dspreemp[1], 
                     OUTPUT rel_dspreemp[2]).    
    
    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN rel_dspreemp[1] = "(" + rel_dspreemp[1]
           rel_dspreemp[2] = rel_dspreemp[2] + ")".
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapage  THEN
        aux_nmcidpac = "Pagavel em ____________________". 
    ELSE     
        aux_nmcidpac = "Pagavel em " + crapage.nmcidade.    
        
    CREATE tt-dados_nota_pro.
    ASSIGN tt-dados_nota_pro.ddmvtolt = DAY(par_dtmvtolt)
           tt-dados_nota_pro.aamvtolt = YEAR(par_dtmvtolt)
           tt-dados_nota_pro.vlpreemp = par_vllimite
           tt-dados_nota_pro.dsctremp = STRING(par_nrctrlim,"z,zzz,zz9") +
                                        "/001"
           tt-dados_nota_pro.dscpfcgc =  IF crapass.inpessoa = 1 THEN
                                            "C.P.F. " + TRIM(par_nrcpfcgc)
                                         ELSE
                                            "CNPJ " + TRIM(par_nrcpfcgc)
           tt-dados_nota_pro.dsendco1 = crapenc.dsendere + " " +
                                        TRIM(STRING(crapenc.nrendere,"zzz,zzz"))
           tt-dados_nota_pro.dsendco2 = TRIM(crapenc.nmbairro)
           tt-dados_nota_pro.dsendco3 = STRING(crapenc.nrcepend,"99999,999") + 
                                        " - " + TRIM(crapenc.nmcidade) + "/" +
                                        crapenc.cdufende
           tt-dados_nota_pro.dsmesref = par_dsmesref
           tt-dados_nota_pro.dsemsnot = par_dsemsnot
           tt-dados_nota_pro.dtvencto = par_dtmvtolt
           tt-dados_nota_pro.dsemsnot = par_dsemsnot
           tt-dados_nota_pro.dsextens = aux_dsextens
           tt-dados_nota_pro.dsbranco = aux_dsbranco
           tt-dados_nota_pro.dsmvtol1 = rel_dsmvtolt[1]
           tt-dados_nota_pro.dsmvtol2 = rel_dsmvtolt[2]
           tt-dados_nota_pro.dspremp1 = rel_dspreemp[1]
           tt-dados_nota_pro.dspremp2 = rel_dspreemp[2]
           tt-dados_nota_pro.nmrescop = par_nmrescop
           tt-dados_nota_pro.nmextcop = par_nmextcop
           tt-dados_nota_pro.nrdocnpj = STRING(STRING(par_nrdocnpj,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx")
           tt-dados_nota_pro.dsdmoeda = par_dsdmoeda
           tt-dados_nota_pro.nmprimtl = par_nmprimtl
           tt-dados_nota_pro.nrdconta = par_nrdconta
           tt-dados_nota_pro.nmcidpac = aux_nmcidpac
           tt-dados_nota_pro.dsqtdava = rel_dsqtdava.
                       
    RETURN "OK".
    
END PROCEDURE.

/*****************************************************************************/
/*          Carrega dados para a impressao da proposta de bordero            */
/*****************************************************************************/
PROCEDURE carrega_dados_proposta_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE NO-UNDO.
    DEF INPUT PARAM par_telefone AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdeben1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdeben2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlsalari AS DECI NO-UNDO.
    DEF INPUT PARAM par_vlsalcon AS DECI NO-UNDO.
    DEF INPUT PARAM par_vloutras AS DECI NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllimpro AS DECI NO-UNDO.
    DEF INPUT PARAM par_dsobser1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsobser2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsobser3 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsobser4 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlslddsc AS DECI NO-UNDO.
    DEF INPUT PARAM par_qtdscsld AS INTE NO-UNDO.
    DEF INPUT PARAM par_vlmaxdsc AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllimdsc AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllimchq AS DECI NO-UNDO.
    DEF INPUT PARAM par_nmempres AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmextcop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsramati AS CHAR NO-UNDO.
    DEF INPUT PARAM par_qtdbolet AS INTE NO-UNDO.
    DEF INPUT PARAM par_vlmedbol AS DECI NO-UNDO.
    DEF INPUT PARAM par_nrmespsq AS INTE NO-UNDO.
    DEF INPUT PARAM par_vlfatura AS DECI NO-UNDO.
    DEF INPUT PARAM par_dsmesref AS CHAR NO-UNDO. 
    DEF INPUT PARAM par_nmrescop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmcidade AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmoperad AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-proposta_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-emprsts.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0001 AS HANDLE          NO-UNDO.
    DEF VAR h-b1wgen0002 AS HANDLE          NO-UNDO.
    DEF VAR h-b1wgen0004 AS HANDLE          NO-UNDO.
    DEF VAR h-b1wgen0006 AS HANDLE          NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE          NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE          NO-UNDO.    
    DEF VAR rel_dsagenci AS CHAR            NO-UNDO.
    DEF VAR rel_vlaplica AS DECI            NO-UNDO.
    DEF VAR aux_vltotccr AS DECI            NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR            NO-UNDO.
    DEF VAR aux_dssitdct AS CHAR            NO-UNDO.
    DEF VAR aux_tpcobran AS CHAR            NO-UNDO.
    DEF VAR rel_tpcobran AS CHAR            NO-UNDO.
    DEF VAR rel_prtitpro AS CHAR            NO-UNDO.
    DEF VAR rel_prtitcar AS CHAR            NO-UNDO.
    DEF VAR aux_vlsmdtri AS DECI            NO-UNDO.
    DEF VAR tot_vlsdeved AS DECI            NO-UNDO.
    DEF VAR tot_vlpreemp AS DECI            NO-UNDO.
    DEF VAR aux_vlcaptal AS DECI            NO-UNDO.
    DEF VAR aux_vlprepla AS DECI            NO-UNDO.
    DEF VAR aux_vlsdrdpp AS DECI DECIMALS 8 NO-UNDO.
    DEF VAR rel_valormed AS DECI            NO-UNDO.
    DEF VAR rel_vltottit AS DECI            NO-UNDO.
    DEF VAR aux_calcotit AS DECI            NO-UNDO.
    DEF VAR rel_qttottit AS INTE            NO-UNDO.
    DEF VAR tot_qttitsac AS INTE            NO-UNDO.
    DEF VAR aux_qttitdsc AS INTE            NO-UNDO.
    DEF VAR aux_vltitdsc AS INTE            NO-UNDO.
    DEF VAR rel_qttitpro AS INTE            NO-UNDO.
    DEF VAR rel_qttitcar AS INTE            NO-UNDO.
    DEF VAR rel_qttittot AS INTE            NO-UNDO.
    DEF VAR aux_naopagos AS INTE            NO-UNDO.
    DEF VAR rel_perceden AS CHAR            NO-UNDO.
    DEF VAR rel_vlmeddsc AS DECI            NO-UNDO.
    DEF VAR aux_flgativo AS LOG             NO-UNDO.
    DEF VAR aux_nrctrhcj AS INT             NO-UNDO.
    DEF VAR rel_nrborder AS INT             NO-UNDO.
    DEF VAR rel_cdagenci AS INT             NO-UNDO.
    DEF VAR aux_flgliber AS LOG             NO-UNDO.
    DEF VAR aux_qtregist AS INTE            NO-UNDO.    
    DEF VAR h-b1wgen0081 AS HANDLE          NO-UNDO.    
    DEF VAR aux_vlsldrgt AS DEC             NO-UNDO.
    DEF VAR aux_vlsldtot AS DEC             NO-UNDO.
    DEF VAR aux_vlsldapl AS DEC             NO-UNDO.
    DEF VAR aux_dtassele AS DATE            NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR            NO-UNDO. /* Data de corte */

    EMPTY TEMP-TABLE tt-proposta_bordero.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper      AND
                       crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE crapage   THEN
         ASSIGN rel_dsagenci = STRING(crapass.cdagenci,"999") + 
                               " - NAO CADASTRADO"
                rel_cdagenci = crapass.cdagenci.
    ELSE     
         ASSIGN rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " 
                               + crapage.nmresage
                rel_cdagenci = crapage.cdagenci.

        /** Saldo das aplicacoes **/
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                SET h-b1wgen0081.        
   
        IF  VALID-HANDLE(h-b1wgen0081)  THEN
                DO:
                        ASSIGN aux_vlsldtot = 0.

                        
                        RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                                                          (INPUT par_cdcooper,
                                                                           INPUT par_cdagenci,
                                                                           INPUT 1,
                                                                           INPUT 1,
                                                                           INPUT par_nmdatela,
                                                                           INPUT 1,
                                                                           INPUT par_nrdconta,
                                                                           INPUT 1,
                                                                           INPUT 0,
                                                                           INPUT par_nmdatela,
                                                                           INPUT FALSE,
                                                                           INPUT ?,
                                                                           INPUT ?,
                                                                           OUTPUT rel_vlaplica,
                                                                           OUTPUT TABLE tt-saldo-rdca,
                                                                           OUTPUT TABLE tt-erro).
                
                        IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                        DELETE PROCEDURE h-b1wgen0081.
                                        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                                        IF  AVAILABLE tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                        ELSE
                                                MESSAGE "Erro nos dados das aplicacoes.".
                
                                        NEXT.
                                END.

                        DELETE PROCEDURE h-b1wgen0081.
                END.
         
           DO TRANSACTION ON ERROR UNDO, RETRY:
                 /*Busca Saldo Novas Aplicacoes*/
                 
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                  RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                                                         INPUT '1',            /* Código do Operador */
                                                                         INPUT par_nmdatela, /* Nome da Tela */
                                                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                                         INPUT par_nrdconta, /* Número da Conta */
                                                                         INPUT 1,            /* Titular da Conta */
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
                                                                                          
                 ASSIGN rel_vlaplica = aux_vlsldrgt + rel_vlaplica.
         END.
         /*Fim Busca Saldo Novas Aplicacoes*/

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
                                                  OUTPUT aux_vlsdrdpp,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-dados-rpp). 
                                  
            DELETE PROCEDURE h-b1wgen0006.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    RETURN "NOK".
                END.
        
            ASSIGN rel_vlaplica = rel_vlaplica + aux_vlsdrdpp.
        END.
    
    /* Totaliza os limites de cartao de credito */
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
             
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
            IF  AVAIL tt-lim_total  THEN
                aux_vltotccr = tt-lim_total.vltotccr.
        END.
        
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.
        
    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0001.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem-cabecalho IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT "",
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.

    RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    DELETE PROCEDURE h-b1wgen0001.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-cabec NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-cabec  THEN
        ASSIGN aux_dstipcta = tt-cabec.dstipcta
               aux_dssitdct = tt-cabec.dssitdct.
        
    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-comp_medias  THEN
        ASSIGN aux_vlsmdtri = tt-comp_medias.vlsmdtri.

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0030",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".    
    
    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlsdeved <> 0 NO-LOCK:

        CREATE tt-emprsts. 
        ASSIGN tt-emprsts.nrctremp = tt-dados-epr.nrctremp
               tt-emprsts.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprsts.vlemprst = tt-dados-epr.vlemprst
               tt-emprsts.dspreapg = tt-dados-epr.dspreapg
               tt-emprsts.vlpreemp = tt-dados-epr.vlpreemp
               tt-emprsts.dslcremp = tt-dados-epr.dslcremp
               tt-emprsts.dsfinemp = tt-dados-epr.dsfinemp
               tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved
               tot_vlpreemp = tot_vlpreemp + tt-dados-epr.vlpreemp.            
    END.
        
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT FALSE, /** NAO GERAR LOG **/
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".    
        
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-dados-capital  THEN
        ASSIGN aux_vlcaptal = tt-dados-capital.vlcaptal
               aux_vlprepla = tt-dados-capital.vlprepla.
    

    /*  Valor medio em desconto  */
    IF   (par_vlslddsc = 0) OR (par_~qtdscsld = 0)   THEN
         ASSIGN rel_valormed = 0. 
    ELSE
         ASSIGN rel_valormed = ROUND(par_vlslddsc / par_qtdscsld, 2).
         
    RUN busca_titulos_bordero (INPUT par_cdcooper,
                               INPUT par_nrborder,
                               INPUT par_nrdconta,
                               OUTPUT TABLE tt-tits_do_bordero,
                               OUTPUT TABLE tt-dsctit_bordero_restricoes).
    
    FOR EACH tt-tits_do_bordero NO-LOCK
                BREAK BY tt-tits_do_bordero.nrinssac:
       
        ASSIGN rel_vltottit = rel_vltottit + tt-tits_do_bordero.vltitulo
               rel_qttottit = rel_qttottit + 1.    

        IF  FIRST-OF(tt-tits_do_bordero.nrinssac)  THEN
            DO:
                /* Verifica TODOS os titulos nao pagos por Sacado */
                FOR EACH craptdb WHERE 
                         craptdb.cdcooper = par_cdcooper                AND
                         craptdb.insittit = 3                           AND
                         craptdb.nrinssac = tt-tits_do_bordero.nrinssac AND
                         craptdb.dtvencto > par_dtmvtolt - (par_nrmespsq * 30)
                         NO-LOCK:
                                                   
                    ASSIGN tot_qttitsac = tot_qttitsac + 1.
                END.                  
            
            END.
    END.
    
    ASSIGN aux_qttitdsc = 0
           aux_vltitdsc = 0
           aux_naopagos = 0.
 
    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrdconta = par_nrdconta AND
                           craptdb.insittit = 2 NO-LOCK:

        ASSIGN aux_qttitdsc = aux_qttitdsc + 1
               aux_vltitdsc = aux_vltitdsc + craptdb.vltitulo.

    END.

    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrdconta = par_nrdconta AND
                           craptdb.insittit = 3 NO-LOCK:

        ASSIGN aux_qttitdsc = aux_qttitdsc + 1
               aux_vltitdsc = aux_vltitdsc + craptdb.vltitulo
               aux_naopagos = aux_naopagos + 1.

    END.
       
    IF   aux_qttitdsc <> 0  THEN
         /* Valor medio por titulo descontado */ 
         ASSIGN rel_vlmeddsc = ROUND(aux_vltitdsc / aux_qttitdsc, 2)
            
                /* Percentual de titulos nao pagos pelo Cedente */
                rel_perceden = STRING(ROUND((aux_naopagos * 100) / 
                                             aux_qttitdsc, 2)) +
                               " % (" + STRING(aux_naopagos) + 
                               "/" + STRING(aux_qttitdsc) + ")".

    ELSE
         ASSIGN rel_vlmeddsc = 0 
                rel_perceden = "0 % (  0/  0)".                   

    /* Adquire os Tipos de Cobrança do Cooperado */
    RUN busca_tipos_cobranca (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT par_dtmvtolt,
                              INPUT 1,
                              INPUT par_nrdconta,
                              OUTPUT aux_tpcobran).

    IF  aux_tpcobran = "T" THEN
        ASSIGN rel_tpcobran = "REGISTRADA E SEM REGISTRO".
    ELSE
        IF  aux_tpcobran = "S" THEN
            ASSIGN rel_tpcobran = "SEM REGISTRO".
    ELSE    
        IF  aux_tpcobran = "R" THEN
            ASSIGN rel_tpcobran = "REGISTRADA".

    /* retorna qtd. total títulos do cedente (cooperado) */
    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                    INPUT par_nrdconta,     /* Conta/DV */
                                    INPUT 0,                /* Sacado */
                                    INPUT 0,                /* Ocorrencia */
                                    INPUT 0,                /* Motivo */
                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                    OUTPUT rel_qttittot,    /* Tot. Títulos */
                                    OUTPUT TABLE tt-erro).
                                  
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    /* retorna qtd. total títulos protestados do cedente (cooperado) */
    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                    INPUT par_nrdconta,     /* Conta/DV */
                                    INPUT 0,                /* Sacado */
                                    INPUT 9,                /* Ocorrencia */
                                    INPUT 14,               /* Motivo */
                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                    OUTPUT rel_qttitpro,    /* Tot. Títulos */
                                    OUTPUT TABLE tt-erro).
                                  
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    /* retorna qtd. total títulos em cartório do cedente (cooperado) */
    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                    INPUT par_nrdconta,     /* Conta/DV */
                                    INPUT 0,                /* Sacado */
                                    INPUT 23,               /* Ocorrencia */
                                    INPUT 0,                /* Motivo */
                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                    OUTPUT rel_qttitcar,    /* Tot. Títulos */
                                    OUTPUT TABLE tt-erro).
                                  
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    ASSIGN aux_calcotit = ROUND((rel_qttitpro * 100) / rel_qttittot, 2).

    IF  aux_calcotit <> ? THEN
        /* Percentual de titulos protestados do Cedente */
        ASSIGN rel_prtitpro = STRING(ROUND((rel_qttitpro * 100) / rel_qttittot, 2)) +
                              " % (" + TRIM(STRING(rel_qttitpro,"zzz,zz9"))         + 
                              "/" + TRIM(STRING(rel_qttittot,"zzz,zz9")) + ")".
    ELSE
        ASSIGN rel_prtitpro = "0 % (" + TRIM(STRING(rel_qttitpro,"zzz,zz9"))         + 
                              "/" + TRIM(STRING(rel_qttittot,"zzz,zz9")) + ")".
                        
    ASSIGN aux_calcotit = ROUND((rel_qttitcar * 100) / rel_qttittot, 2).

    IF  aux_calcotit <> ? THEN
        /* Percentual de titulos em cartorio do Cedente */
        ASSIGN rel_prtitcar = STRING(ROUND((rel_qttitcar * 100) /  rel_qttittot, 2)) +
                              " % (" + TRIM(STRING(rel_qttitcar,"zzz,zz9"))                 +
                              "/" + TRIM(STRING(rel_qttittot,"zzz,zz9")) + ")".
    ELSE
        ASSIGN rel_prtitcar = "0 % (" + TRIM(STRING(rel_qttitcar,"zzz,zz9"))                 +
                              "/" + TRIM(STRING(rel_qttittot,"zzz,zz9")) + ")".
        
    CREATE tt-proposta_bordero.
    ASSIGN tt-proposta_bordero.dsagenci = rel_dsagenci
           tt-proposta_bordero.vlaplica = rel_vlaplica
           tt-proposta_bordero.vltotccr = aux_vltotccr
           tt-proposta_bordero.telefone = par_telefone
           tt-proposta_bordero.dstipcta = aux_dstipcta
           tt-proposta_bordero.vlsmdtri = aux_vlsmdtri
           tt-proposta_bordero.vlcaptal = aux_vlcaptal
           tt-proposta_bordero.vlprepla = aux_vlprepla
           tt-proposta_bordero.dsdeben1 = par_dsdeben1
           tt-proposta_bordero.dsdeben2 = par_dsdeben2
           tt-proposta_bordero.vlsalari = par_vlsalari
           tt-proposta_bordero.vlsalcon = par_vlsalcon
           tt-proposta_bordero.vloutras = par_vloutras
           tt-proposta_bordero.ddmvtolt = DAY(par_dtmvtolt)
           tt-proposta_bordero.aamvtolt = YEAR(par_dtmvtolt)
           tt-proposta_bordero.nrctrlim = par_nrctrlim
           tt-proposta_bordero.vllimpro = par_vllimpro
           tt-proposta_bordero.nrdconta = par_nrdconta
           tt-proposta_bordero.nrmatric = tt-cabec.nrmatric
           tt-proposta_bordero.nmprimtl = tt-cabec.nmprimtl
           tt-proposta_bordero.dtadmemp = tt-cabec.dtadmemp
           tt-proposta_bordero.nmempres = par_nmempres
           tt-proposta_bordero.nrcpfcgc = tt-cabec.nrcpfcgc
           tt-proposta_bordero.dssitdct = aux_dssitdct
           tt-proposta_bordero.dtadmiss = tt-cabec.dtadmiss
           tt-proposta_bordero.nmextcop = par_nmextcop
           tt-proposta_bordero.dsramati = par_dsramati
           tt-proposta_bordero.vllimcre = tt-cabec.vllimcre
           tt-proposta_bordero.vllimchq = par_vllimchq
           tt-proposta_bordero.vlfatura = par_vlfatura
           tt-proposta_bordero.vlsdeved = tot_vlsdeved
           tt-proposta_bordero.vlpreemp = tot_vlpreemp
           tt-proposta_bordero.dtcalcul = par_dtmvtolt
           tt-proposta_bordero.dsobser1 = par_dsobser1
           tt-proposta_bordero.dsobser2 = par_dsobser2
           tt-proposta_bordero.dsobser3 = par_dsobser3
           tt-proposta_bordero.dsobser4 = par_dsobser4
           tt-proposta_bordero.dsmesref = par_dsmesref
           tt-proposta_bordero.nmcidade = par_nmcidade
           tt-proposta_bordero.nmrescop = par_nmrescop
           tt-proposta_bordero.vlmeddsc = rel_vlmeddsc
           tt-proposta_bordero.perceden = rel_perceden
           tt-proposta_bordero.naopagos = aux_naopagos
           tt-proposta_bordero.qttitsac = tot_qttitsac
           tt-proposta_bordero.vltottit = rel_vltottit
           tt-proposta_bordero.qttottit = rel_qttottit
           tt-proposta_bordero.valormed = rel_valormed
           tt-proposta_bordero.qtdbolet = par_qtdbolet
           tt-proposta_bordero.vlmedbol = par_vlmedbol
           tt-proposta_bordero.vlmaxdsc = par_vlmaxdsc
           tt-proposta_bordero.qtdscsld = par_qtdscsld
           tt-proposta_bordero.vlslddsc = par_vlslddsc
           tt-proposta_bordero.nrmespsq = par_nrmespsq
           tt-proposta_bordero.cdagenci = rel_cdagenci
           tt-proposta_bordero.nrborder = par_nrborder
           tt-proposta_bordero.tpcobran = rel_tpcobran
           tt-proposta_bordero.prtitpro = rel_prtitpro
           tt-proposta_bordero.prtitcar = rel_prtitcar
           tt-proposta_bordero.nmoperad = par_nmoperad.
    
    RETURN "OK".    
    
END PROCEDURE.

/*****************************************************************************/
/*                Carrega dados com os titulos do bordero                    */
/*****************************************************************************/
PROCEDURE carrega_dados_bordero_titulos:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE NO-UNDO. 
    DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrmespsq AS INTE NO-UNDO.
    DEF INPUT PARAM par_txdiaria AS DECI NO-UNDO.
    DEF INPUT PARAM par_txmensal AS DECI NO-UNDO.
    DEF INPUT PARAM par_txdanual AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllimite AS DECI NO-UNDO.
    DEF INPUT PARAM par_ddmvtolt AS INTE NO-UNDO.
    DEF INPUT PARAM par_dsmesref AS CHAR NO-UNDO.
    DEF INPUT PARAM par_aamvtolt AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmcidade AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmoperad AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados_tits_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-tits_do_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_bordero_restricoes.
    DEF OUTPUT PARAM TABLE FOR tt-sacado_nao_pagou.
    
    DEF VAR rel_qttitsac AS INTE NO-UNDO.
    DEF VAR aux_vltitsac AS DECI NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados_tits_bordero.
    EMPTY TEMP-TABLE tt-sacado_nao_pagou.
    EMPTY TEMP-TABLE tt-tits_do_bordero.
    EMPTY TEMP-TABLE tt-dsctit_bordero_restricoes.
    
    RUN busca_titulos_bordero (INPUT par_cdcooper,
                               INPUT par_nrborder,
                               INPUT par_nrdconta,
                               OUTPUT TABLE tt-tits_do_bordero,
                               OUTPUT TABLE tt-dsctit_bordero_restricoes).    
                               
    FOR EACH tt-tits_do_bordero NO-LOCK
             BREAK BY tt-tits_do_bordero.nrinssac:
       
        IF  FIRST-OF(tt-tits_do_bordero.nrinssac)  THEN
            DO:
                ASSIGN rel_qttitsac = 0
                       aux_vltitsac = 0.

                /* Verifica TODOS os titulos nao pagos por Sacado */
                FOR EACH craptdb WHERE 
                         craptdb.cdcooper = par_cdcooper                AND
                         craptdb.insittit = 3                           AND
                         craptdb.nrinssac = tt-tits_do_bordero.nrinssac AND
                         craptdb.dtvencto > par_dtmvtolt - (par_nrmespsq * 30)
                          NO-LOCK:
                                                   
                    ASSIGN rel_qttitsac = rel_qttitsac + 1
                           aux_vltitsac = aux_vltitsac + craptdb.vltitul.
                END.
                   
                IF  rel_qttitsac <> 0  THEN
                    DO:
                        CREATE tt-sacado_nao_pagou.
                        ASSIGN tt-sacado_nao_pagou.nmsacado = 
                                                   tt-tits_do_bordero.nmsacado
                               tt-sacado_nao_pagou.qtdtitul = rel_qttitsac
                               tt-sacado_nao_pagou.vlrtitul = aux_vltitsac. 
                                                        
                    END.
            END.
    END.

    CREATE tt-dados_tits_bordero.
    ASSIGN tt-dados_tits_bordero.nrdconta = par_nrdconta
           tt-dados_tits_bordero.cdagenci = par_cdagenci
           tt-dados_tits_bordero.nrctrlim = par_nrctrlim
           tt-dados_tits_bordero.nrborder = par_nrborder
           tt-dados_tits_bordero.nrmespsq = par_nrmespsq
           tt-dados_tits_bordero.txdiaria = par_txdiaria
           tt-dados_tits_bordero.txmensal = par_txmensal
           tt-dados_tits_bordero.txdanual = par_txdanual
           tt-dados_tits_bordero.vllimite = par_vllimite
           tt-dados_tits_bordero.ddmvtolt = par_ddmvtolt
           tt-dados_tits_bordero.dsmesref = par_dsmesref
           tt-dados_tits_bordero.aamvtolt = par_aamvtolt
           tt-dados_tits_bordero.nmprimtl = par_nmprimtl
           tt-dados_tits_bordero.nmresco1 = par_nmresco1
           tt-dados_tits_bordero.nmresco2 = par_nmresco2
           tt-dados_tits_bordero.nmcidade = par_nmcidade
           tt-dados_tits_bordero.nmoperad = par_nmoperad.
    
    RETURN "OK".    

END PROCEDURE.

/*****************************************************************************/
/*              Rotina de baixa de titulos por pagto ou vencto               */
/*****************************************************************************/
PROCEDURE efetua_baixa_titulo:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_indbaixa AS INTE                    NO-UNDO.
    /* 1-Pagamento 2- Vencimento */
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_vllanmto AS DECI NO-UNDO.
    DEF VAR aux_vldjuros AS DECI NO-UNDO.
    DEF VAR aux_qtdprazo AS INTE NO-UNDO.
    DEF VAR aux_txdiaria AS DECI NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_contado1 AS INTE NO-UNDO.
    DEF VAR aux_dtperiod AS DATE NO-UNDO.
    DEF VAR aux_dtrefjur AS DATE NO-UNDO.
    DEF VAR aux_vltotjur AS DECI NO-UNDO.
    DEF VAR aux_vltitulo AS DECI NO-UNDO.
    DEF VAR aux_dtultdat AS DATE NO-UNDO.
    DEF VAR flg_feriafds AS LOGI NO-UNDO.
    DEF VAR aux_dtprvenc AS DATE NO-UNDO.

    DEF VAR aux_tottitul_cr AS INTE NO-UNDO. /* Qtd. De Tit. Registrados */
    DEF VAR aux_tottitul_sr AS INTE NO-UNDO. /* Qtd. De Tit. S/ Registro */

    DEF VAR aux_vlttitsr AS DECI NO-UNDO.
    DEF VAR aux_vlttitcr AS DECI NO-UNDO.
    DEF VAR aux_inpessoa AS INTE NO-UNDO.
    DEF VAR aux_cdbattar AS CHAR NO-UNDO.

    DEF VAR aux_cdhisest AS INTE NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE NO-UNDO.
    DEF VAR aux_cdhistor AS INTE NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE NO-UNDO.
    DEF VAR aux_flgimune AS INTE NO-UNDO.

    DEF VAR aux_natjurid LIKE crapjur.natjurid  NO-UNDO.
    DEF VAR aux_tpregtrb LIKE crapjur.tpregtrb  NO-UNDO.
    DEF VAR aux_vliofpri AS DECIMAL             NO-UNDO.
    DEF VAR aux_vliofadi AS DECIMAL             NO-UNDO.
    DEF VAR aux_vliofcpl AS DECIMAL             NO-UNDO.
    DEF VAR aux_qtdiaiof AS INTEGER             NO-UNDO.
    DEF VAR aux_vltotal_liquido AS DECIMAL      NO-UNDO.
    DEF VAR aux_vltxiofatraso AS DECIMAL        NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE  NO-UNDO.
    
    DEF BUFFER crablot FOR craplot.
    DEF BUFFER cra2lot FOR craplot.
    DEF BUFFER crabtdb FOR craptdb.
    
    DEF VAR aux_flgdsair AS LOGICAL NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    /* Leitura dos titulos para serem baixados */
    BAIXA:
    DO  TRANSACTION ON ERROR UNDO BAIXA, RETURN "NOK":

        RUN sistema/generico/procedures/b1wgen0088.p
            PERSISTENT SET h-b1wgen0088.

        FOR EACH tt-titulos NO-LOCK BREAK BY tt-titulos.nrdconta:
        
            ASSIGN aux_flgdsair = FALSE
                   aux_vltotjur = 0.
    
            DO  aux_contador = 1 TO 10:
                
                FIND craptdb  WHERE craptdb.cdcooper = par_cdcooper        AND
                                    craptdb.cdbandoc = tt-titulos.cdbandoc AND
                                    craptdb.nrdctabb = tt-titulos.nrdctabb AND
                                    craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
                                    craptdb.nrdconta = tt-titulos.nrdconta AND
                                    craptdb.nrdocmto = tt-titulos.nrdocmto AND
                                    craptdb.insittit = 4                   
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
      
                IF  NOT AVAILABLE craptdb   THEN
                    IF  LOCKED craptdb   THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de titulo em uso. "
                                                + "Tente novamente."
                                   aux_cdcritic = 0.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE 
                        DO:
                            ASSIGN aux_flgdsair = TRUE.
                            LEAVE.
                        END.    
                    
                aux_dscritic = "".
                LEAVE.

            END. /* Final do DO .. TO */    
            
            IF  aux_dscritic <> ""  THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    UNDO BAIXA, RETURN "NOK".
                END.            
            
            IF  aux_flgdsair  THEN    
                NEXT.
        
            /* 
                Se caso o titulo vier pela COMPE o crps517 soh ira rodar a noite
                para baixar os titulos em descto, e nesse periodo(dia) o 
                titulo ser pago, nao deve ser considerado que ele esteja em
                descto de titulos
            */
            IF  CAN-DO("1,7",STRING(WEEKDAY(craptdb.dtvencto)))   OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                       crapfer.dtferiad = craptdb.dtvencto) THEN
                flg_feriafds = TRUE.
            ELSE
                flg_feriafds = FALSE.
            
            IF  par_indbaixa      = 1                AND
                craptdb.dtvencto  < par_dtmvtolt     AND
                /* POSTERGACAO DA DATA */
                NOT flg_feriafds                     AND
                par_idorigem     <> 1 /* Ayllos */   THEN
                NEXT.

            /* Pega o proximo dia util apos o vencimento */
            IF  par_idorigem <> 1  THEN
                DO:
                    /* 1o Dia util apos o vencto */
                    aux_dtprvenc = craptdb.dtvencto + 1.
                    DO  WHILE TRUE:

                        IF   WEEKDAY(aux_dtprvenc) = 1   OR
                             WEEKDAY(aux_dtprvenc) = 7   THEN
                             DO:
                                aux_dtprvenc = aux_dtprvenc + 1.
                                NEXT.
                             END.
                                    
                        FIND crapfer WHERE 
                             crapfer.cdcooper = par_cdcooper   AND
                             crapfer.dtferiad = aux_dtprvenc
                             NO-LOCK NO-ERROR.
                                                            
                        IF   AVAILABLE crapfer   THEN
                             DO:
                                aux_dtprvenc = aux_dtprvenc + 1.
                                NEXT.
                             END.

                        LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */
    
                    /*
                        Fazer a baixa de desconto de titulo somente se for
                        no 1o. dia util apos o vencimento
                        caso contrario da NEXT.
                    */
                    IF  flg_feriafds AND    /* venceu em feriado/fds */
                        craptdb.dtvencto <= par_dtmvtolt AND 
                        par_dtmvtolt <> aux_dtprvenc  THEN
                        NEXT.
                    
                END.

            FIND crapbdt WHERE crapbdt.cdcooper = craptdb.cdcooper AND
                               crapbdt.nrborder = craptdb.nrborder
                               NO-LOCK NO-ERROR.
            IF  NOT AVAIL crapbdt  THEN
                DO:
                    ASSIGN aux_dscritic = "Bordero nao encontrado."
                           aux_cdcritic = 0.
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    UNDO BAIXA, RETURN "NOK".
                END.                
            FIND crapdat WHERE crapdat.cdcooper = craptdb.cdcooper
                                       NO-LOCK NO-ERROR.

            /* Total de titulos para gerar a Tarifa */
            IF tt-titulos.flgregis = TRUE THEN
                ASSIGN aux_tottitul_cr = aux_tottitul_cr + 1. 
            ELSE
                ASSIGN aux_tottitul_sr = aux_tottitul_sr + 1. 
            /* 
                Valor pago eh menor que o titulo (Ex: Desconto de 10%)
                a diferenca eh cobrado o ajuste do titulo
            */
            IF  par_indbaixa = 1  THEN
                DO: 
                    /* se pagamento a menor */
                    IF  craptdb.vltitulo > tt-titulos.vltitulo  THEN
                        DO: 
                          
                            DO  aux_contador = 1 TO 10:
                                FIND craplot WHERE 
                                     craplot.cdcooper = par_cdcooper AND
                                     craplot.dtmvtolt = par_dtmvtolt AND
                                     craplot.cdagenci = 1            AND
                                     craplot.cdbccxlt = 100          AND
                                     craplot.nrdolote = 10300
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                               IF   NOT AVAILABLE craplot   THEN
                                    DO:
                                        IF   LOCKED craplot   THEN
                                             DO:                           
                                                 PAUSE 1 NO-MESSAGE.
                                                 ASSIGN aux_cdcritic = 341.
                                                 NEXT.
                                             END.
                                        ELSE
                                             DO:
                                                 CREATE craplot.
                                                 ASSIGN craplot.dtmvtolt = 
                                                                par_dtmvtolt
                                                        craplot.cdagenci = 1
                                                        craplot.cdbccxlt = 100
                                                        craplot.nrdolote = 10300
                                                        craplot.tplotmov = 1
                                                        craplot.cdoperad = 
                                                                par_cdoperad
                                                        craplot.cdhistor = 
                                                     (IF tt-titulos.flgregis = FALSE THEN 
                                                         590 /* pagto a menor - sem registro */
                                                      ELSE 
                                                         1101) /* pagto a menor - c/ registro */
                                                        craplot.cdcooper = 
                                                        par_cdcooper.
                                             END.       
                                    END.
                   
                               ASSIGN aux_cdcritic = 0.
                             
                               LEAVE.

                            END. /* Fim do DO ... TO */
            
                            IF  aux_cdcritic > 0  THEN
                                DO:
                                    ASSIGN aux_dscritic = "".
                    
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1, /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                                    UNDO BAIXA, RETURN "NOK".
                                END.                

                            CREATE craplcm.
                            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                                   craplcm.cdagenci = craplot.cdagenci
                                   craplcm.cdbccxlt = craplot.cdbccxlt 
                                   craplcm.nrdolote = craplot.nrdolote
                                   craplcm.nrdconta = craptdb.nrdconta
                                   craplcm.nrdocmto = craplot.nrseqdig + 1
                                   craplcm.vllanmto = craptdb.vltitulo -
                                                      tt-titulos.vltitulo
                                   craplcm.cdhistor = 
                                     (IF tt-titulos.flgregis = FALSE THEN 
                                         590 /* pagto a menor - sem registro */
                                      ELSE 
                                         1101) /* pagto a menor - c/ registro */
                                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                                   craplcm.nrdctabb = craptdb.nrdconta 

                                   craplcm.nrautdoc = 0
                           
                                   craplcm.cdcooper = par_cdcooper
                                   craplcm.cdpesqbb = STRING(craptdb.nrdocmto)

                                   craplot.nrseqdig = craplcm.nrseqdig
                                   craplot.qtinfoln = craplot.qtinfoln + 1
                                   craplot.qtcompln = craplot.qtcompln + 1
         
                                   craplot.vlinfocr = craplot.vlinfocr +
                                                      craplcm.vllanmto
                                   craplot.vlcompcr = craplot.vlcompcr +
                                                      craplcm.vllanmto
                                   aux_vllanmto     = aux_vllanmto + 
                                                      craplcm.vllanmto.
                            VALIDATE craplot.
                            VALIDATE craplcm.
                        END. /* Fim do IF */
                    ELSE
                        /* se pagamento a maior */
                        IF  craptdb.vltitulo < tt-titulos.vltitulo  THEN
                            DO:
                                DO  aux_contador = 1 TO 10:
                                    FIND craplot WHERE 
                                         craplot.cdcooper = par_cdcooper AND
                                         craplot.dtmvtolt = par_dtmvtolt AND
                                         craplot.cdagenci = 1            AND
                                         craplot.cdbccxlt = 100          AND
                                         craplot.nrdolote = 10300
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                                   IF   NOT AVAILABLE craplot   THEN
                                        DO:
                                            IF   LOCKED craplot   THEN
                                                 DO:                           
                                                     PAUSE 1 NO-MESSAGE.
                                                     ASSIGN aux_cdcritic = 341.
                                                     NEXT.
                                                 END.
                                            ELSE
                                                 DO:
                                                     CREATE craplot.
                                                     ASSIGN craplot.dtmvtolt = 
                                                                    par_dtmvtolt
                                                            craplot.cdagenci = 1
                                                            craplot.cdbccxlt = 100
                                                            craplot.nrdolote = 10300
                                                            craplot.tplotmov = 1
                                                            craplot.cdoperad = 
                                                                    par_cdoperad
                                                            craplot.cdhistor = 
                                                             (IF tt-titulos.flgregis = FALSE THEN 
                                                                 1100 /* pagto a maior - sem registro */
                                                              ELSE 
                                                                 1102) /* pagto a maior - c/ registro */

                                                            craplot.cdcooper = 
                                                            par_cdcooper.
                                                 END.       
                                        END.
                       
                                   ASSIGN aux_cdcritic = 0.
                                 
                                   LEAVE.
    
                                END. /* Fim do DO ... TO */
                
                                IF  aux_cdcritic > 0  THEN
                                    DO:
                                        ASSIGN aux_dscritic = "".
                        
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1, /** Sequencia **/
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).
                                        UNDO BAIXA, RETURN "NOK".
                                    END.                
    
                                CREATE craplcm.
                                ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                                       craplcm.cdagenci = craplot.cdagenci
                                       craplcm.cdbccxlt = craplot.cdbccxlt 
                                       craplcm.nrdolote = craplot.nrdolote
                                       craplcm.nrdconta = craptdb.nrdconta
                                       craplcm.nrdocmto = craplot.nrseqdig + 1
                                       craplcm.vllanmto = tt-titulos.vltitulo - craptdb.vltitulo
                                       craplcm.cdhistor = 
                                        (IF tt-titulos.flgregis = FALSE THEN 
                                            1100 /* pagto a maior - sem registro */
                                         ELSE 
                                            1102) /* pagto a maior - c/ registro */
                                       craplcm.nrseqdig = craplot.nrseqdig + 1 
                                       craplcm.nrdctabb = craptdb.nrdconta 
    
                                       craplcm.nrautdoc = 0
                               
                                       craplcm.cdcooper = par_cdcooper
                                       craplcm.cdpesqbb = STRING(craptdb.nrdocmto)
    
                                       craplot.nrseqdig = craplcm.nrseqdig
                                       craplot.qtinfoln = craplot.qtinfoln + 1
                                       craplot.qtcompln = craplot.qtcompln + 1
             
                                       craplot.vlinfocr = craplot.vlinfocr +
                                                          craplcm.vllanmto
                                       craplot.vlcompcr = craplot.vlcompcr +
                                                          craplcm.vllanmto
                                       aux_vllanmto     = aux_vllanmto + 
                                                          craplcm.vllanmto.
                                VALIDATE craplot.
                                VALIDATE craplcm.

                                END.


                    /* Se for pago via compe (crps375), o sistema lanca com
                       dtmvtopr na conta do associado, porem o desconto eh 
                       liquidado no dia do vencimento.
                       Se for pago via caixa on-line ou internet, a liquidacao
                       sera no dia informado na chamada desta procedure */
                 /*   FIND crapdat WHERE crapdat.cdcooper = craptdb.cdcooper
                                       NO-LOCK NO-ERROR. */
                                   
                    /*  Condicao para verificar se o Titulo estah em Atraso */
                    IF  NOT(craptdb.dtvencto > crapdat.dtmvtoan) AND craptdb.dtvencto <  par_dtmvtolt THEN
                       DO:
                           /* Busca o tipo de pessoa */
                           FOR crapass FIELDS (inpessoa)
                                       WHERE crapass.cdcooper = par_cdcooper     AND
                                             crapass.nrdconta = craptdb.nrdconta
                                             NO-LOCK: END.
                           IF NOT AVAIL crapass THEN
                              DO:
                                  ASSIGN aux_cdcritic = 9.
                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT 1, /** Sequencia **/
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).
                                  UNDO BAIXA, RETURN "NOK".
                              END.
                           ASSIGN aux_natjurid = 0
                                  aux_tpregtrb = 0.
                           /* Condicao para verificar se eh pessoa juridica */   
                           IF crapass.inpessoa >= 2 THEN
                              DO:
                                  FOR crapjur FIELDS(natjurid tpregtrb)
                                              WHERE crapjur.cdcooper = par_cdcooper     AND
                                                    crapjur.nrdconta = craptdb.nrdconta
                                                    NO-LOCK: END.
                                  IF AVAIL crapjur THEN
                                     DO:
                                         ASSIGN aux_natjurid = crapjur.natjurid
                                                aux_tpregtrb = crapjur.tpregtrb.
                                     END.
                              END.
                           /*------------------------------------------------------------------------
                                                    INICIO PARA CALCULAR IOF 
                             ------------------------------------------------------------------------*/
                           ASSIGN aux_vltotal_liquido = 0.
                           FOR EACH crabtdb FIELDS(vlliquid)
                                            WHERE crabtdb.cdcooper = par_cdcooper     AND
                                                  crabtdb.nrdconta = craptdb.nrdconta AND
                                                  crabtdb.nrborder = craptdb.nrborder
                                                  NO-LOCK:
                             ASSIGN aux_vltotal_liquido = aux_vltotal_liquido + crabtdb.vlliquid.
                           END.                        
                           /* Quantidade de Dias em atraso */
                           ASSIGN aux_qtdiaiof = par_dtmvtolt - craptdb.dtvencto.
                           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                           /* Efetuar a chamada a rotina Oracle */
                           RUN STORED-PROCEDURE pc_calcula_valor_iof_prg
                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT 2                   /* Desconto de Titulo */
                                                               ,INPUT 2                   /* Pagamento em Atraso */
                                                               ,INPUT par_cdcooper        /* Cooperativa    */ 
                                                               ,INPUT craptdb.nrdconta    /* Numero da conta */
                                                               ,INPUT crapass.inpessoa    /* Tipo de Pessoa */
                                                               ,INPUT aux_natjurid        /* Natureza Juridica */
                                                               ,INPUT aux_tpregtrb        /* Tipo de Regime de Tributacao */
                                                               ,INPUT par_dtmvtolt        /* Data de Movimento */
                                                               ,INPUT aux_qtdiaiof        /* Quantidade de dias de atraso. */
                                                               ,INPUT craptdb.vlliquid    /* Valor do Titulo  */
                                                               ,INPUT aux_vltotal_liquido /* Total do Bordero */
                                                               ,INPUT STRING(crapbdt.vltaxiof)    /* Valor da taxa de IOF de atraso */
                                                               ,OUTPUT 0                  /* IOF Principal */
                                                               ,OUTPUT 0                  /* IOF Adicinal  */
                                                               ,OUTPUT 0                  /* IOF Complemenar */
                                                               ,OUTPUT ""                  /* Taxa de IOF principal */
                                                               ,OUTPUT ?                    /* Flag da imunidade */
                                                               ,OUTPUT "").  /* Descrição da crítica */
                           /* Fechar o procedimento para buscarmos o resultado */ 
                           CLOSE STORED-PROC pc_calcula_valor_iof_prg
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                           ASSIGN aux_vliofpri = 0
                                  aux_vliofadi = 0
                                  aux_vliofcpl = 0
                                  aux_dscritic = ""
                                  aux_flgimune = 0
                                  aux_vliofpri = pc_calcula_valor_iof_prg.pr_vliofpri
                                                 WHEN pc_calcula_valor_iof_prg.pr_vliofpri <> ?
                                  aux_vliofadi = pc_calcula_valor_iof_prg.pr_vliofadi
                                                 WHEN pc_calcula_valor_iof_prg.pr_vliofadi <> ?
                                  aux_vliofcpl = pc_calcula_valor_iof_prg.pr_vliofcpl
                                                 WHEN pc_calcula_valor_iof_prg.pr_vliofcpl <> ?
                                  aux_dscritic = pc_calcula_valor_iof_prg.pr_dscritic
                                                 WHEN pc_calcula_valor_iof_prg.pr_dscritic <> ?
                                  aux_flgimune = pc_calcula_valor_iof_prg.pr_flgimune
                                                 WHEN pc_calcula_valor_iof_prg.pr_flgimune <> ?.
                                                 
                           /* Se retornou erro */
                           IF aux_dscritic <> "" THEN 
                              DO:
                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT 1, /** Sequencia **/
                                                 INPUT 0,
                                                 INPUT-OUTPUT aux_dscritic).
                                  UNDO BAIXA, RETURN "NOK".
                              END.
                           /* Condicao para verificar se o valor do complemento eh maior que 0 */    
                           IF aux_vliofcpl > 0 THEN
                              DO:
                                  DO aux_contador = 1 TO 10:
                                     FIND craplot WHERE 
                                          craplot.cdcooper = par_cdcooper AND
                                          craplot.dtmvtolt = par_dtmvtolt AND
                                          craplot.cdagenci = 1            AND
                                          craplot.cdbccxlt = 100          AND
                                          craplot.nrdolote = 10300
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    IF NOT AVAILABLE craplot   THEN
                                       DO:
                                           IF   LOCKED craplot   THEN
                                                DO:                           
                                                    PAUSE 1 NO-MESSAGE.
                                                    ASSIGN aux_cdcritic = 341.
                                                    NEXT.
                                                END.
                                           ELSE
                                                DO:
                                                    CREATE craplot.
                                                    ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                                           craplot.cdagenci = 1
                                                           craplot.cdbccxlt = 100
                                                           craplot.nrdolote = 10300
                                                           craplot.tplotmov = 1
                                                           craplot.cdoperad = par_cdoperad
                                                           craplot.cdhistor = 2321                                                        
                                                           craplot.cdcooper = par_cdcooper.
                                                END.       
                                       END.
                                    ASSIGN aux_cdcritic = 0.
                                    LEAVE.
                                 END. /* Fim do DO ... TO */
                                 IF  aux_cdcritic > 0  THEN
                                     DO:
                                         ASSIGN aux_dscritic = "".
                                         RUN gera_erro (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT 1, /** Sequencia **/
                                                        INPUT aux_cdcritic,
                                                        INPUT-OUTPUT aux_dscritic).
                                         UNDO BAIXA, RETURN "NOK".
                                     END.                
                                 CREATE craplcm.
                                 ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                                        craplcm.cdagenci = craplot.cdagenci
                                        craplcm.cdbccxlt = craplot.cdbccxlt 
                                        craplcm.nrdolote = craplot.nrdolote
                                        craplcm.nrdconta = craptdb.nrdconta
                                        craplcm.nrdocmto = craplot.nrseqdig + 1
                                        craplcm.vllanmto = aux_vliofcpl
                                        craplcm.cdhistor = 2321
                                        craplcm.nrseqdig = craplot.nrseqdig + 1 
                                        craplcm.nrdctabb = craptdb.nrdconta 
                                        craplcm.nrautdoc = 0
                                        craplcm.cdcooper = par_cdcooper
                                        craplcm.cdpesqbb = STRING(craptdb.nrdocmto)
                                        craplot.nrseqdig = craplcm.nrseqdig
                                        craplot.qtinfoln = craplot.qtinfoln + 1
                                        craplot.qtcompln = craplot.qtcompln + 1
                                        craplot.vlinfocr = craplot.vlinfocr +
                                                           craplcm.vllanmto
                                        craplot.vlcompcr = craplot.vlcompcr +
                                                           craplcm.vllanmto.                                        
                                  VALIDATE craplot.
                                  VALIDATE craplcm.                           
                             END.                           
                           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                           /* Efetuar a chamada a rotina Oracle */
                           RUN STORED-PROCEDURE pc_insere_iof
                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                                               ,INPUT craptdb.nrdconta    /* Numero da Conta Corrente */
                                                               ,INPUT par_dtmvtolt        /* Data de Movimento        */
                                                               ,INPUT 2                   /* Desconto de Titulo       */
                                                               ,INPUT craptdb.nrborder    /* Numero do Bordero        */
                                                               ,INPUT ?                   /* ID Lautom                */
                                                               ,INPUT craplcm.dtmvtolt    /* Data Movimento LCM       */
                                                               ,INPUT craplcm.cdagenci    /* Numero da Agencia LCM    */
                                                               ,INPUT craplcm.cdbccxlt    /* Numero do Caixa LCM      */
                                                               ,INPUT craplcm.nrdolote    /* Numero do Lote LCM       */
                                                               ,INPUT craplcm.nrseqdig    /* Sequencia LCM            */
                                                               ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                                               ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                                               ,INPUT aux_vliofcpl        /* Valor Complementar IOF   */
                                                               ,INPUT aux_flgimune        /* Flag da imunidade */
                                                               ,OUTPUT 0                  /* Codigo da Critica */
                                                               ,OUTPUT "").               /* Descrição da crítica */
                           /* Fechar o procedimento para buscarmos o resultado */ 
                           CLOSE STORED-PROC pc_insere_iof
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = ""
                                  aux_cdcritic = pc_insere_iof.pr_cdcritic
                                                 WHEN pc_insere_iof.pr_cdcritic <> ?
                                  aux_dscritic = pc_insere_iof.pr_dscritic
                                                 WHEN pc_insere_iof.pr_dscritic <> ?.
                           /* Se retornou erro */
                           IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                              DO:
                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT 1, /** Sequencia **/
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).
                                  UNDO BAIXA, RETURN "NOK".
                              END.                           
                           /*------------------------------------------------------------------------
                                                    FIM PARA CALCULAR IOF 
                             ------------------------------------------------------------------------*/                               
                       END. /* END IF craptdb.dtvencto <  par_dtmvtolt THEN */
                    /* Processado */
                    ASSIGN craptdb.insittit = 2
                           craptdb.dtdpagto = IF par_idorigem = 1 THEN
                                                 crapdat.dtmvtolt
                                              ELSE par_dtmvtolt.
                                 
                END. /* Final da baixa por pagamento */
            ELSE
            IF  par_indbaixa = 2  THEN
                DO:
                    DO  aux_contador = 1 TO 10:
                        FIND craplot WHERE 
                                     craplot.cdcooper = par_cdcooper AND
                                     craplot.dtmvtolt = par_dtmvtolt AND
                                     craplot.cdagenci = 1            AND
                                     craplot.cdbccxlt = 100          AND
                                     craplot.nrdolote = 10300
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craplot   THEN
                             DO:
                                 IF   LOCKED craplot   THEN
                                      DO:                           
                                          PAUSE 1 NO-MESSAGE.
                                          ASSIGN aux_cdcritic = 341.
                                          NEXT.
                                      END.
                                 ELSE
                                      DO:
                                          CREATE craplot.
                                          ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                                 craplot.cdagenci = 1
                                                 craplot.cdbccxlt = 100
                                                 craplot.nrdolote = 10300
                                                 craplot.tplotmov = 1
                                                 craplot.cdoperad = par_cdoperad
                                                 craplot.cdhistor = 591
                                                 craplot.cdcooper = 
                                                                par_cdcooper.
                                      END.       
                             END.
                   
                        ASSIGN aux_cdcritic = 0.
                            
                        LEAVE.

                    END. /* Fim do DO ... TO */
            
                    IF  aux_cdcritic > 0  THEN
                        DO:
                            ASSIGN aux_dscritic = "".
                    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            UNDO BAIXA, RETURN "NOK".
                        END.                

                    CREATE craplcm.
                    ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                           craplcm.cdagenci = craplot.cdagenci
                           craplcm.cdbccxlt = craplot.cdbccxlt 
                           craplcm.nrdolote = craplot.nrdolote
                           craplcm.nrdconta = craptdb.nrdconta
                           craplcm.nrdocmto = craplot.nrseqdig + 1
                           craplcm.vllanmto = tt-titulos.vltitulo
                           craplcm.cdhistor = 591

                           craplcm.nrseqdig = craplot.nrseqdig + 1 
                           craplcm.nrdctabb = craptdb.nrdconta 

                           craplcm.nrautdoc = 0
                           
                           craplcm.cdcooper = par_cdcooper
                           craplcm.cdpesqbb = STRING(craptdb.nrdocmto)

                           craplot.nrseqdig = craplcm.nrseqdig
                           craplot.qtinfoln = craplot.qtinfoln + 1
                           craplot.qtcompln = craplot.qtcompln + 1
         
                           craplot.vlinfocr = craplot.vlinfocr +
                                                      craplcm.vllanmto
                           craplot.vlcompcr = craplot.vlcompcr +
                                                      craplcm.vllanmto.
                    VALIDATE craplot.
                    VALIDATE craplcm.

                    ASSIGN craptdb.insittit = 3. /* Baixado s/ pagto */        

                    FIND FIRST crapcob 
                         WHERE crapcob.cdcooper = par_cdcooper
                           AND crapcob.cdbandoc = tt-titulos.cdbandoc
                           AND crapcob.nrdctabb = tt-titulos.nrdctabb
                           AND crapcob.nrdconta = tt-titulos.nrdconta
                           AND crapcob.nrcnvcob = tt-titulos.nrcnvcob
                           AND crapcob.nrdocmto = tt-titulos.nrdocmto
                           AND crapcob.flgregis = TRUE
                           NO-LOCK NO-ERROR.

                    IF  AVAIL crapcob THEN
                        DO:
                            RUN cria-log-cobranca IN h-b1wgen0088 
                                (INPUT ROWID(crapcob),
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT 'Tit baixado de desconto s/ pagto').
                        END.                                            
                    
                END. /* Final da baixa por vencimento */
                

                    


            
            /**** ABATIMENTO DE JUROS ****/
            ASSIGN aux_txdiaria = ROUND((EXP(1 + (crapbdt.txmensal / 100),
                                         1 / 30) - 1),7)
                   aux_qtdprazo = INT(craptdb.dtvencto - craptdb.dtlibbdt) -
                                  INT(craptdb.dtvencto - craptdb.dtdpagto)
                   aux_vltitulo = craptdb.vltitulo
                   aux_dtperiod = craptdb.dtlibbdt
                   aux_vldjuros = 0.
    
            /* Houve pagamento antecipado */
            IF  aux_qtdprazo     > 0                 AND
                craptdb.dtdpagto < craptdb.dtvencto  THEN
                DO:
                    DO  aux_contador = 1 TO aux_qtdprazo:
               
                        ASSIGN aux_vldjuros = ROUND(aux_vltitulo * 
                                                    aux_txdiaria,2)
                               aux_vltitulo = aux_vltitulo + aux_vldjuros
                               aux_dtperiod = aux_dtperiod + 1
                               aux_dtrefjur = ((DATE(MONTH(aux_dtperiod),28,
                                               YEAR(aux_dtperiod)) + 4) -
                                               DAY(DATE(MONTH(aux_dtperiod),28,
                                               YEAR(aux_dtperiod)) + 4)).
          
                        DO  aux_contado1 = 1 TO 10: 
            
                            FIND crawljt WHERE 
                                 crawljt.cdcooper = craptdb.cdcooper AND
                                 crawljt.nrdconta = craptdb.nrdconta AND
                                 crawljt.nrborder = craptdb.nrborder AND
                                 crawljt.dtrefere = aux_dtrefjur     AND
                                 crawljt.cdbandoc = craptdb.cdbandoc AND
                                 crawljt.nrdctabb = craptdb.nrdctabb AND
                                 crawljt.nrcnvcob = craptdb.nrcnvcob AND
                                 crawljt.nrdocmto = craptdb.nrdocmto
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                            IF  NOT AVAILABLE crawljt  THEN
                                DO:
                                    IF  LOCKED crawljt  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE
                                        DO:
                                            CREATE crawljt.
                                            ASSIGN crawljt.cdcooper = 
                                                            craptdb.cdcooper 
                                                   crawljt.nrdconta = 
                                                            craptdb.nrdconta
                                                   crawljt.nrborder = 
                                                            craptdb.nrborder
                                                   crawljt.dtrefere = 
                                                            aux_dtrefjur
                                                   crawljt.cdbandoc = 
                                                            craptdb.cdbandoc
                                                   crawljt.nrdctabb = 
                                                            craptdb.nrdctabb
                                                   crawljt.nrcnvcob = 
                                                            craptdb.nrcnvcob
                                                   crawljt.nrdocmto = 
                                                            craptdb.nrdocmto.
                                        END.      
                                END.

                            ASSIGN aux_cdcritic = 0.
                            LEAVE. 
          
                        END. /* Fim do DO ... TO */
           
                        IF  aux_cdcritic > 0  THEN
                            DO:
                                ASSIGN aux_dscritic = "".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
    
                                UNDO BAIXA, RETURN "NOK".

                            END.
                  
                        crawljt.vldjuros = crawljt.vldjuros + aux_vldjuros.
                        
                    END.  /*  Fim do DO .. TO  */

                    /*  Atualiza registro de provisao de juros ..........  */
                    FOR EACH crawljt WHERE 
                             crawljt.cdcooper = par_cdcooper EXCLUSIVE-LOCK:
                
                        FIND crapljt WHERE 
                             crapljt.cdcooper = crawljt.cdcooper AND
                             crapljt.nrdconta = crawljt.nrdconta AND
                             crapljt.nrborder = crawljt.nrborder AND
                             crapljt.dtrefere = crawljt.dtrefere AND
                             crapljt.cdbandoc = crawljt.cdbandoc AND
                             crapljt.nrdctabb = crawljt.nrdctabb AND
                             crapljt.nrcnvcob = crawljt.nrcnvcob AND
                             crapljt.nrdocmto = crawljt.nrdocmto
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                        IF  NOT AVAILABLE crapljt  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro crapljt nao " +
                                                      "encontrado.".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,     /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                UNDO BAIXA, RETURN "NOK".
                            END.
                
                        IF  crapljt.vldjuros <> crawljt.vldjuros   THEN
                            IF  crapljt.vldjuros > crawljt.vldjuros   THEN
                                ASSIGN crapljt.vlrestit = crapljt.vldjuros - 
                                                          crawljt.vldjuros
                                       crapljt.vldjuros = crawljt.vldjuros
                                       /* Juros a ser restituido */
                                       aux_vltotjur = crapljt.vlrestit.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Erro - Juros " +
                                                          "negativo: " +
                                                       STRING(crapljt.vldjuros).

                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1, /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).

                                    UNDO BAIXA, RETURN "NOK".
                                END.
                     
                        aux_dtultdat = crawljt.dtrefere.
                
                        DELETE crawljt.       

                    END.  /*  Fim do FOR EACH crawljt  */
                END.
            ELSE
                /* o juros sempre eh referente ao ultimo dia do mes */
                ASSIGN aux_dtultdat = ((DATE(MONTH(craptdb.dtdpagto),28,
                                        YEAR(craptdb.dtdpagto)) + 4) -
                                        DAY(DATE(MONTH(craptdb.dtdpagto),28,
                                        YEAR(craptdb.dtdpagto)) + 4)).

            /* Corrige os juros cobrados a mais no periodo */
            FOR EACH crapljt WHERE crapljt.cdcooper = par_cdcooper     AND 
                                   crapljt.nrdconta = craptdb.nrdconta AND
                                   crapljt.nrborder = craptdb.nrborder AND
                                   crapljt.dtrefere > aux_dtultdat     AND
                                   crapljt.cdbandoc = craptdb.cdbandoc AND
                                   crapljt.nrdctabb = craptdb.nrdctabb AND
                                   crapljt.nrcnvcob = craptdb.nrcnvcob AND
                                   crapljt.nrdocmto = craptdb.nrdocmto 
                                   EXCLUSIVE-LOCK:
                         
                ASSIGN aux_vltotjur     = aux_vltotjur + crapljt.vldjuros
                       crapljt.vlrestit = crapljt.vldjuros
                       crapljt.vldjuros = 0.
   
            END.  /*  Fim do FOR EACH crapljt  */
            
            IF  aux_vltotjur > 0  THEN
                DO:
                    DO  aux_contador = 1 TO 10:

                        FIND cra2lot WHERE cra2lot.cdcooper = par_cdcooper AND 
                                           cra2lot.dtmvtolt = par_dtmvtolt AND
                                           cra2lot.cdagenci = 1            AND
                                           cra2lot.cdbccxlt = 100          AND
                                           cra2lot.nrdolote = 10300
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                        IF  NOT AVAILABLE cra2lot   THEN
                            DO:
                                IF  LOCKED cra2lot   THEN
                                    DO:
                                        ASSIGN aux_dscritic = "Registro de" +
                                                              "lote esta " +
                                                              "em uso. Tente " +
                                                              "novamente.".
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE
                                    DO:
                                        CREATE cra2lot.
                                        ASSIGN cra2lot.dtmvtolt = par_dtmvtolt
                                               cra2lot.cdagenci = 1 
                                               cra2lot.cdbccxlt = 100
                                               cra2lot.nrdolote = 10300
                                               cra2lot.tplotmov = 1
                                               cra2lot.cdoperad = par_cdoperad
                                               cra2lot.cdhistor = 597
                                               cra2lot.cdcooper = par_cdcooper.
                                    END.
                            END.
                    
                        aux_dscritic = "".
                        LEAVE.
            
                    END.   /*  Fim do DO .. TO  */

                    IF  aux_dscritic <> ""   THEN
                        DO:
                            ASSIGN aux_cdcritic = 0.
            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                    
                            UNDO BAIXA, RETURN "NOK".
                        END.

                    CREATE craplcm.
                    ASSIGN craplcm.dtmvtolt = cra2lot.dtmvtolt 
                           craplcm.cdagenci = cra2lot.cdagenci
                           craplcm.cdbccxlt = cra2lot.cdbccxlt 
                           craplcm.nrdolote = cra2lot.nrdolote
                           craplcm.nrdconta = craptdb.nrdconta
                           craplcm.nrdocmto = cra2lot.nrseqdig + 1 
                           craplcm.vllanmto = aux_vltotjur
                           craplcm.cdhistor = 597
                           craplcm.nrseqdig = cra2lot.nrseqdig + 1 
                           craplcm.nrdctabb = craptdb.nrdconta
                           craplcm.nrautdoc = 0
                           craplcm.cdpesqbb = STRING(craptdb.nrdocmto)
                           craplcm.cdcooper = par_cdcooper

                           cra2lot.nrseqdig = craplcm.nrseqdig
                           cra2lot.vlinfodb = cra2lot.vlinfodb + aux_vltotjur
                           cra2lot.vlcompdb = cra2lot.vlcompdb + aux_vltotjur
                           cra2lot.qtinfoln = cra2lot.qtinfoln + 1
                           cra2lot.qtcompln = cra2lot.qtcompln + 1.           
                    VALIDATE cra2lot.
                    VALIDATE craplcm.
                END.
            
            VALIDATE craptdb.
            
            /* Verifica se deve liquidar o bordero caso sim Liquida */
            RUN efetua_liquidacao_bordero(INPUT par_cdcooper, 
                                          INPUT par_cdagenci, 
                                          INPUT par_nrdcaixa, 
                                          INPUT par_cdoperad, 
                                          INPUT par_dtmvtolt, 
                                          INPUT par_idorigem, 
                                          INPUT par_nrdconta, 
                                          INPUT craptdb.nrborder, 
                                          OUTPUT TABLE tt-erro).
    
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        UNDO BAIXA, RETURN "NOK".                    
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Erro na liquidacao do " +
                                                  "bordero " +
                                                  STRING(craptdb.nrborder) +
                                                  " conta " +
                                                  STRING(craptdb.nrdconta).

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            UNDO BAIXA, RETURN "NOK".                    
                        END.
                END.
            
            /* Gera a tarifa apenas uma vez para a conta */
            IF  LAST-OF(tt-titulos.nrdconta)  THEN
                DO:
                    /* Tarifa de titulos descontados */ /*
                    DO  aux_contador = 1 TO 10:

                        FIND crablot WHERE crablot.cdcooper = par_cdcooper AND 
                                           crablot.dtmvtolt = par_dtmvtolt AND
                                           crablot.cdagenci = 1            AND
                                           crablot.cdbccxlt = 100          AND
                                           crablot.nrdolote = 8452         
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                        IF  NOT AVAILABLE crablot   THEN
                            DO:
                                IF  LOCKED crablot   THEN
                                    DO:
                                        ASSIGN aux_dscritic = "Registro de" +
                                                              " lote esta " +
                                                              "em uso. Tente " +
                                                              "novamente.".
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE
                                    DO:
                                        CREATE crablot.
                                        ASSIGN crablot.dtmvtolt = par_dtmvtolt
                                               crablot.cdagenci = 1 
                                               crablot.cdbccxlt = 100 
                                               crablot.nrdolote = 8452 
                                               crablot.tplotmov = 1
                                               crablot.cdoperad = par_cdoperad
                                               crablot.cdhistor = 595
                                               crablot.cdcooper = par_cdcooper.
                                    END.
                            END.
                    
                        aux_dscritic = "".
                        LEAVE.
            
                    END.   /*  Fim do DO .. TO  */

                    IF  aux_dscritic <> ""   THEN
                        DO:
                            ASSIGN aux_cdcritic = 0.
            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                    
                            UNDO BAIXA, RETURN "NOK".
                        END.
                    
                    RUN busca_tarifas_dsctit (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_dtmvtolt,
                                              INPUT par_idorigem,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-tarifas_dsctit).

                    IF  RETURN-VALUE = "NOK"  THEN 
                        UNDO BAIXA, RETURN "NOK".  
                    */

                    ASSIGN aux_inpessoa = 1
                           aux_vlttitsr = 0
                           aux_vlttitcr = 0.

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                       crapass.nrdconta = craptdb.nrdconta
                                       NO-LOCK NO-ERROR .

                    IF AVAIL crapass THEN
                        aux_inpessoa = crapass.inpessoa.
                    
                    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

                    IF aux_inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "DSTTITSRPF".
                    ELSE
                        ASSIGN aux_cdbattar = "DSTTITSRPJ".
        
                    /*  Busca valor da tarifa sem registro*/
                    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                    (INPUT  par_cdcooper,
                                                     INPUT  aux_cdbattar,       
                                                     INPUT  1,   
                                                     INPUT  "", /* cdprogra */
                                                     OUTPUT aux_cdhistor,
                                                     OUTPUT aux_cdhisest,
                                                     OUTPUT aux_vlttitsr,
                                                     OUTPUT aux_dtdivulg,
                                                     OUTPUT aux_dtvigenc,
                                                     OUTPUT aux_cdfvlcop,
                                                     OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        IF  VALID-HANDLE(h-b1wgen0153)  THEN
                            DELETE PROCEDURE h-b1wgen0153.
                        UNDO BAIXA, RETURN "NOK".
                    END.
                        

                    IF aux_inpessoa = 1 THEN /* Fisica */
                        ASSIGN aux_cdbattar = "DSTTITCRPF".
                    ELSE
                        ASSIGN aux_cdbattar = "DSTTITCRPJ".
        
                    /*  Busca valor da tarifa com registro*/
                    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                    (INPUT  par_cdcooper,
                                                     INPUT  aux_cdbattar,       
                                                     INPUT  1,   
                                                     INPUT  "", /* cdprogra */
                                                     OUTPUT aux_cdhistor,
                                                     OUTPUT aux_cdhisest,
                                                     OUTPUT aux_vlttitcr,
                                                     OUTPUT aux_dtdivulg,
                                                     OUTPUT aux_dtvigenc,
                                                     OUTPUT aux_cdfvlcop,
                                                     OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK"  THEN 
                    DO:
                        IF  VALID-HANDLE(h-b1wgen0153)  THEN
                            DELETE PROCEDURE h-b1wgen0153.
                        UNDO BAIXA, RETURN "NOK".
                    END.

                    IF (aux_vlttitcr /* tt-tarifas_dsctit.vlttitcr */ * aux_tottitul_cr) > 0 OR
                       (aux_vlttitsr /* tt-tarifas_dsctit.vlttitsr */ * aux_tottitul_sr) > 0 THEN
                        DO:
                            /* Gera Tarifa de titulos descontados */ /*
                            CREATE craplcm.
                            ASSIGN craplcm.dtmvtolt = crablot.dtmvtolt 
                                   craplcm.cdagenci = crablot.cdagenci
                                   craplcm.cdbccxlt = crablot.cdbccxlt 
                                   craplcm.nrdolote = crablot.nrdolote
                                   craplcm.nrdconta = craptdb.nrdconta
                                   craplcm.nrdocmto = crablot.nrseqdig + 1 
                                   craplcm.vllanmto = (tt-tarifas_dsctit.vlttitcr * aux_tottitul_cr +
                                                       tt-tarifas_dsctit.vlttitsr * aux_tottitul_sr   )
                                   craplcm.cdhistor = 595
                                   craplcm.nrseqdig = crablot.nrseqdig + 1 
                                   craplcm.nrdctabb = craptdb.nrdconta

                                   craplcm.nrautdoc = 0
                                   craplcm.cdpesqbb = IF aux_tottitul_cr > 1 OR
                                                         aux_tottitul_sr > 1 THEN
                                                         "Tarifa de titulos " +
                                                         "descontados"
                                                      ELSE
                                                        STRING(craptdb.nrdocmto)
                                   craplcm.cdcooper = par_cdcooper
                
                                   crablot.nrseqdig = craplcm.nrseqdig
                                   crablot.vlinfodb = crablot.vlinfodb + 
                                                        aux_vllanmto
                                   crablot.vlcompdb = crablot.vlcompdb + 
                                                        aux_vllanmto
                                   crablot.qtinfoln = crablot.qtinfoln + 1
                                   crablot.qtcompln = crablot.qtcompln + 1 */

                            /* Gera Tarifa de titulos descontados */
                            RUN cria_lan_auto_tarifa IN h-b1wgen0153
                               (INPUT par_cdcooper,
                                INPUT craptdb.nrdconta,            
                                INPUT par_dtmvtolt,
                                INPUT aux_cdhistor, 
                                INPUT (aux_vlttitcr * aux_tottitul_cr +
                                       aux_vlttitsr * aux_tottitul_sr   ),
                                INPUT par_cdcooper,                         /* cdoperad */
                                INPUT 1,                                    /* cdagenci */
                                INPUT 100,                                  /* cdbccxlt */         
                                INPUT 8452,                                 /* nrdolote */        
                                INPUT 1,                                    /* tpdolote */         
                                INPUT 0 ,                                   /* nrdocmto */
                                INPUT craptdb.nrdconta,                     /* nrdconta */
                                INPUT STRING(craptdb.nrdconta,"99999999"),  /* nrdctitg */
                                INPUT IF aux_tottitul_cr > 1 OR
                                         aux_tottitul_sr > 1 THEN
                                         "Tarifa de titulos descontados"
                                      ELSE
                                        STRING(craptdb.nrdocmto),           /* cdpesqbb */
                                INPUT 0,                                    /* cdbanchq */
                                INPUT 0,                                    /* cdagechq */
                                INPUT 0,                                    /* nrctachq */
                                INPUT FALSE,                                /* flgaviso */
                                INPUT 0,                                    /* tpdaviso */
                                INPUT aux_cdfvlcop,                         /* cdfvlcop */
                                INPUT crapdat.inproces,                     /* inproces */
                                OUTPUT TABLE tt-erro).

                                IF  RETURN-VALUE = "NOK"  THEN
                                DO:

                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                                    IF AVAIL tt-erro THEN 
                                    DO:
                                        ASSIGN aux_cdcritic = 0.
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1,            /** Sequencia **/
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT tt-erro.dscritic).
                                    END.

                                    UNDO BAIXA, RETURN "NOK".
                                END.

                            ASSIGN aux_tottitul_cr  = 0
                                   aux_tottitul_sr  = 0.
                        END.

                        IF  VALID-HANDLE(h-b1wgen0153)  THEN
                            DELETE PROCEDURE h-b1wgen0153.

                END.
                
        END. /* Final da leitura dos titulos para sem baixados */

        IF  VALID-HANDLE(h-b1wgen0088)  THEN
            DELETE PROCEDURE h-b1wgen0088.
    
    END. /* Final da transacao */
      
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*              Validar os dados informados de lote na LANBDT                */
/*****************************************************************************/
PROCEDURE valida_dados_lote:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
    IF  CAN-FIND(craplot WHERE craplot.cdcooper = par_cdcooper  AND
                               craplot.dtmvtolt = par_dtmvtolt  AND
                               craplot.cdagenci = par_cdagenci  AND
                               craplot.cdbccxlt = par_cdbccxlt  AND
                               craplot.nrdolote = par_nrdolote)  THEN
        DO: 
            ASSIGN aux_cdcritic = 59
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
     
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.

    RUN critica_numero_lote IN h-b1wgen9999 (INPUT par_cdcooper,
                                             INPUT 0, /* agenci */
                                             INPUT 0, /* caixa  */
                                             INPUT par_nrdolote,
                                             OUTPUT TABLE tt-erro).
                               
    DELETE PROCEDURE h-b1wgen9999.    
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
     
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*          Verifica se o bordero deve se liquidado caso sim liquida         */
/*****************************************************************************/
/*
    Um bordero eh liquidado quando todos os titulos dele estiverem no estado
    diferente de "0 - nao processado"
*/
PROCEDURE efetua_liquidacao_bordero:
    
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    
    DEF VAR aux_contador AS INTE           NO-UNDO.
    DEF VAR aux_flgliqui AS LOGI INIT TRUE NO-UNDO.
    
    DEF BUFFER b-crapbdt FOR crapbdt.
    DEF BUFFER b-craptdb FOR craptdb.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    
    
    LIQUIDA:
    DO  TRANSACTION ON ERROR UNDO LIQUIDA, RETURN "NOK":
    
        DO  aux_contador = 1 TO 10:
       
            FIND b-crapbdt WHERE b-crapbdt.cdcooper = par_cdcooper AND
                                 b-crapbdt.nrborder = par_nrborder
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE b-crapbdt  THEN
                DO:
                    IF  LOCKED b-crapbdt  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de bordero esta " +
                                                  "em uso. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Bordero nao " +
                                                  "encontrado.".
                            LEAVE.
                        END.
                END.

            ASSIGN aux_dscritic = "".
          
            LEAVE.
          
        END.
       
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                UNDO LIQUIDA, RETURN "NOK".
            END.

        FOR EACH b-craptdb WHERE b-craptdb.cdcooper = b-crapbdt.cdcooper AND
                                 b-craptdb.nrborder = b-crapbdt.nrborder AND
                                 b-craptdb.nrdconta = b-crapbdt.nrdconta AND
                                 b-craptdb.insittit = 4 NO-LOCK:

            aux_flgliqui = FALSE.
                                       
        END.
        
        IF  aux_flgliqui  THEN DO:
            ASSIGN b-crapbdt.insitbdt = 4. /* Liquidado */
                        VALIDATE b-crapbdt.
                        
                        
                END.
            
        FIND CURRENT b-crapbdt NO-LOCK.
        RELEASE b-crapbdt.
        
    END. /* Final da Transacao */
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/*                   Rotina de estorno de baixa de titulos                   */
/*****************************************************************************/
PROCEDURE efetua_estorno_baixa_titulo:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_vllanmto AS DECI NO-UNDO.
    DEF VAR aux_vldjuros AS DECI NO-UNDO.
    DEF VAR aux_qtdprazo AS INTE NO-UNDO.
    DEF VAR aux_txdiaria AS DECI NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_contado1 AS INTE NO-UNDO.
    DEF VAR aux_dtperiod AS DATE NO-UNDO.
    DEF VAR aux_dtrefjur AS DATE NO-UNDO.
    
    DEF BUFFER crablot FOR craplot.
    DEF BUFFER cra2lot FOR craplot.
    DEF BUFFER crablcm FOR craplcm.
    
    DEF VAR aux_flgdsair AS LOGICAL NO-UNDO.
    DEF VAR flg_notfound AS LOGICAL NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    /* Leitura dos titulos para serem estornados */
    ESTORNO:
    DO  TRANSACTION ON ERROR UNDO ESTORNO, RETURN "NOK":
    
        FOR EACH tt-titulos NO-LOCK BREAK BY tt-titulos.nrdconta:

            ASSIGN aux_flgdsair = FALSE.
    
            DO  aux_contador = 1 TO 10:
                
                FIND craptdb  WHERE craptdb.cdcooper = par_cdcooper        AND
                                    craptdb.cdbandoc = tt-titulos.cdbandoc AND
                                    craptdb.nrdctabb = tt-titulos.nrdctabb AND
                                    craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
                                    craptdb.nrdconta = tt-titulos.nrdconta AND
                                    craptdb.nrdocmto = tt-titulos.nrdocmto AND
                                    craptdb.insittit = 2 /* Pago */
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craptdb   THEN
                    IF  LOCKED craptdb   THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de titulo em uso. "
                                                + "Tente novamente."
                                   aux_cdcritic = 0.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE 
                        DO:
                            ASSIGN aux_flgdsair = TRUE.
                            LEAVE.
                        END.    
                    
                aux_dscritic = "".
                LEAVE.

            END. /* Final do DO .. TO */    
            
            IF  aux_flgdsair  THEN    
                NEXT.
        
            IF  aux_dscritic <> ""  THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    UNDO ESTORNO, RETURN "NOK".
                END.            

            ASSIGN flg_notfound = FALSE.
                
            /* procura lcm de ajuste caso tenha acontecido deleta o lcm */
            DO  WHILE TRUE:
                
                DO  aux_contador = 1 TO 10:
                
                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                       craplcm.dtmvtolt = par_dtmvtolt AND
                                       craplcm.cdagenci = 1            AND
                                       craplcm.cdbccxlt = 100          AND
                                       craplcm.nrdolote = 10300        AND
                                       craplcm.nrdctabb = par_nrdconta AND
                                       craplcm.cdhistor = 590          AND
                                       craplcm.cdpesqbb = 
                                                    STRING(craptdb.nrdocmto)
                                       USE-INDEX craplcm1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplcm   THEN
                        DO:
                            IF  LOCKED craplcm   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                             ELSE
                                DO:
                                    flg_notfound = TRUE.
                                    LEAVE.
                                END.    
                        END.                                       

                    aux_cdcritic = 0.
                    LEAVE.                   

                END. /* Final do DO .. TO */
                                       
                IF  flg_notfound THEN
                    LEAVE.

                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                    
                DO  aux_contador = 1 TO 10:
                
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = par_dtmvtolt AND
                                       craplot.cdagenci = 1            AND
                                       craplot.cdbccxlt = 100          AND
                                       craplot.nrdolote = 10300
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot   THEN
                        DO:
                            IF  LOCKED craplot   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                        END.     

                    aux_cdcritic = 0.
                    LEAVE.    

                END. /* Final do DO .. TO */
                
                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                   
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                        
                ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                       craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.vlinfocr = craplot.vlinfocr -
                                                  craplcm.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr -
                                                  craplcm.vllanmto.
                /* 
                    Caso o lote tenha sido zerado o mesmo
                    eh removido.
                */
                IF  craplot.qtcompln = 0  THEN
                    DELETE craplot.

                DELETE craplcm.
                
                LEAVE.
            
            END.    

            /* Tratamento para estorno de pagamentos a maior - Cob. sem registro */
            ASSIGN flg_notfound = FALSE.

            DO  WHILE TRUE:
                
                DO  aux_contador = 1 TO 10:
                
                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                       craplcm.dtmvtolt = par_dtmvtolt AND
                                       craplcm.cdagenci = 1            AND
                                       craplcm.cdbccxlt = 100          AND
                                       craplcm.nrdolote = 10300        AND
                                       craplcm.nrdctabb = par_nrdconta AND
                                       craplcm.cdhistor = 1100         AND
                                       craplcm.cdpesqbb = 
                                                    STRING(craptdb.nrdocmto)
                                       USE-INDEX craplcm1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplcm   THEN
                        DO:
                            IF  LOCKED craplcm   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                             ELSE
                                DO:
                                    flg_notfound = TRUE.
                                    LEAVE.
                                END.    
                        END. 

                    aux_cdcritic = 0.
                    LEAVE.                   

                END. /* Final do DO .. TO */

                IF  flg_notfound THEN
                    LEAVE.

                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                    
                DO  aux_contador = 1 TO 10:
                
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = par_dtmvtolt AND
                                       craplot.cdagenci = 1            AND
                                       craplot.cdbccxlt = 100          AND
                                       craplot.nrdolote = 10300
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot   THEN
                        DO:
                            IF  LOCKED craplot   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                        END.  

                    aux_cdcritic = 0.
                    LEAVE.    

                END. /* Final do DO .. TO */
                
                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                   
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                        
                ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                       craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.vlinfocr = craplot.vlinfocr -
                                                  craplcm.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr -
                                                  craplcm.vllanmto.
                /* 
                    Caso o lote tenha sido zerado o mesmo
                    eh removido.
                */
                IF  craplot.qtcompln = 0  THEN
                    DELETE craplot.

                DELETE craplcm.
                
                LEAVE.
            
            END.
            
    
            /* Tratamento para estorno de pagamentos 
                       cdhistor = 1101 a menor - Cob. com registro 
                       cdhistor = 1102 a Maior - Cob. com registro */
            ASSIGN flg_notfound = FALSE.

            DO  WHILE TRUE:
                  
                  FOR EACH crablcm 
                     WHERE crablcm.cdcooper = par_cdcooper AND
                           crablcm.dtmvtolt = par_dtmvtolt AND
                           crablcm.cdagenci = 1            AND
                           crablcm.cdbccxlt = 100          AND
                           crablcm.nrdolote = 10300        AND
                           crablcm.nrdctabb = par_nrdconta AND
                           (crablcm.cdhistor = 1101 OR
                            crablcm.cdhistor = 1102       )AND
                           crablcm.cdpesqbb = 
                                        STRING(craptdb.nrdocmto)
                           USE-INDEX craplcm1
                           NO-LOCK:
                           
                    /* inicializar critica*/ 
                    ASSIGN aux_cdcritic = 0.
                    
                    DO  aux_contador = 1 TO 10:
                      
                      FIND craplcm 
                        WHERE ROWID(craplcm) = ROWID(crablcm)
                         EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                         
                      /* testar se está em lock*/
                      IF  LOCKED craplcm   THEN
                      DO:                           
                          /*caso estiver espera 
                            e guarda critica*/
                          PAUSE 1 NO-MESSAGE.
                          ASSIGN aux_cdcritic = 341.
                          NEXT.
                      END.
                      ELSE 
                      DO:
                        /* se nao esta em lock
                           limpa critica e sai do loop*/
                        ASSIGN aux_cdcritic = 0.
                        LEAVE.
                      END.  
                    END. /* Final do DO .. TO */
                    
                    /* verificar se saiu do loop com
                       alguma critica */
                    IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.                   
                    
                    /* buscar lote dos lançamentos buscados acima*/
                    DO  aux_contador = 1 TO 10:                
                        FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                           craplot.dtmvtolt = par_dtmvtolt AND
                                           craplot.cdagenci = 1            AND
                                           craplot.cdbccxlt = 100          AND
                                           craplot.nrdolote = 10300
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAILABLE craplot   THEN
                            DO:
                                IF  LOCKED craplot   THEN
                                    DO:                           
                                        PAUSE 1 NO-MESSAGE.
                                        ASSIGN aux_cdcritic = 341.
                                        NEXT.
                                    END.
                            END.     

                        aux_cdcritic = 0.
                        LEAVE.    

                    END. /* Final do DO .. TO */
                    
                    IF  aux_cdcritic > 0  THEN
                        DO:
                            ASSIGN aux_dscritic = "".
                       
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,     /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).

                            UNDO ESTORNO, RETURN "NOK".
                    
                        END.
                            
                    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                           craplot.qtinfoln = craplot.qtinfoln - 1
                           craplot.vlinfocr = craplot.vlinfocr -
                                                      craplcm.vllanmto
                           craplot.vlcompcr = craplot.vlcompcr -
                                                      craplcm.vllanmto.
                    /* 
                        Caso o lote tenha sido zerado o mesmo
                        eh removido.
                    */
                    IF  craplot.qtcompln = 0  THEN
                        DELETE craplot.

                    DELETE craplcm.
                    
                  END. /* FIM FOR EACH craplcm  */
                  
                  LEAVE.
            END.


            ASSIGN flg_notfound = FALSE.
                        
            /* 
                procura lcm de abatimento de juros
                caso tenha acontecido deleta o lcm 
            */
            DO  WHILE TRUE:
                
                DO  aux_contador = 1 TO 10:
                
                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                       craplcm.dtmvtolt = par_dtmvtolt AND
                                       craplcm.cdagenci = 1            AND
                                       craplcm.cdbccxlt = 100          AND
                                       craplcm.nrdolote = 10300        AND
                                       craplcm.nrdctabb = par_nrdconta AND
                                       craplcm.cdhistor = 597          AND
                                       craplcm.cdpesqbb = 
                                                    STRING(craptdb.nrdocmto)
                                       USE-INDEX craplcm1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplcm   THEN
                        DO:
                            IF  LOCKED craplcm   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                             ELSE
                                DO:
                                    flg_notfound = TRUE.
                                    LEAVE.
                                END.    
                        END.                                       

                    aux_cdcritic = 0.
                    LEAVE.                   

                END. /* Final do DO .. TO */
                                       
                IF  flg_notfound THEN
                    LEAVE.

                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                    
                DO  aux_contador = 1 TO 10:
                
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = par_dtmvtolt AND
                                       craplot.cdagenci = 1            AND
                                       craplot.cdbccxlt = 100          AND
                                       craplot.nrdolote = 10300
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot   THEN
                        DO:
                            IF  LOCKED craplot   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                        END.     

                    aux_cdcritic = 0.
                    LEAVE.    

                END. /* Final do DO .. TO */
                
                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                   
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                        
                ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                       craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.vlinfocr = craplot.vlinfocr -
                                                  craplcm.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr -
                                                  craplcm.vllanmto.
                /* 
                    Caso o lote tenha sido zerado o mesmo
                    eh removido.
                */
                IF  craplot.qtcompln = 0  THEN
                    DELETE craplot.

                DELETE craplcm.
                
                LEAVE.
            
            END.            
            
            ASSIGN flg_notfound = FALSE.
            
            /* procura lcm de tarifa de pagamento de titulo descontado */
            DO  WHILE TRUE:
                
                DO  aux_contador = 1 TO 10:
                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                                       craplcm.dtmvtolt = par_dtmvtolt AND
                                       craplcm.cdagenci = 1            AND
                                       craplcm.cdbccxlt = 100          AND
                                       craplcm.nrdolote = 8452         AND
                                       craplcm.nrdctabb = par_nrdconta AND
                                       craplcm.cdhistor = 595          AND
                                       craplcm.cdpesqbb = 
                                                    STRING(craptdb.nrdocmto)
                                       USE-INDEX craplcm1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplcm   THEN
                        DO:
                            IF  LOCKED craplcm   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    flg_notfound = TRUE.
                                    LEAVE.
                                END.
                        END.                                       

                    aux_cdcritic = 0.
                    LEAVE.                   

                END. /* Final do DO .. TO */
                                       
                IF  flg_notfound  THEN
                    LEAVE.
                
                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                    
                DO  aux_contador = 1 TO 10:
                
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = par_dtmvtolt AND
                                       craplot.cdagenci = 1            AND
                                       craplot.cdbccxlt = 100          AND
                                       craplot.nrdolote = 8452  
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot   THEN
                        DO:
                            IF  LOCKED craplot   THEN
                                DO:                           
                                    PAUSE 1 NO-MESSAGE.
                                    ASSIGN aux_cdcritic = 341.
                                    NEXT.
                                END.
                        END.     

                    aux_cdcritic = 0.
                    LEAVE.    

                END. /* Final do DO .. TO */

                IF  aux_cdcritic > 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "".
                   
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        UNDO ESTORNO, RETURN "NOK".
                
                    END.
                        
                ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                       craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.vlinfocr = craplot.vlinfocr -
                                                  craplcm.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr -
                                                  craplcm.vllanmto.
                /* 
                    Caso o lote tenha sido zerado o mesmo
                    eh removido.
                */
                IF  craplot.qtcompln = 0  THEN
                    DELETE craplot.

                DELETE craplcm.
                
                LEAVE.
            
            END. /* Final do DO WHILE */                   

            ASSIGN craptdb.insittit = 4
                   craptdb.dtdpagto = ?. 
            VALIDATE craptdb.            

            /* Se o bordero estava liquidado volta o status para liberado */
            DO  aux_contador = 1 TO 10:
       
                FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND
                                   crapbdt.nrborder = craptdb.nrborder 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapbdt  THEN
                    DO:
                        IF  LOCKED crapbdt  THEN
                            DO:
                                ASSIGN aux_dscritic = "Registro de bordero" +
                                                      " esta em uso." +
                                                      " Tente novamente.".                                

                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            DO:

                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Bordero nao " +
                                                      "encontrado.".
                                LEAVE.
                                
                            END.
                    END.

                ASSIGN aux_cdcritic     = 0
                       aux_dscritic     = ""
                       crapbdt.insitbdt = 3. /*Liberado*/
          
                LEAVE.                  
          
            END.
       
            IF  aux_dscritic <> ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0.
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    UNDO ESTORNO, RETURN "NOK".
                END.
            
            /* Corrige os juros que haviam sidos zerados anteriormente */
            FOR EACH crapljt WHERE crapljt.cdcooper = par_cdcooper     AND 
                                   crapljt.nrdconta = craptdb.nrdconta AND
                                   crapljt.nrborder = craptdb.nrborder AND
                                   crapljt.dtrefere > par_dtmvtolt     AND
                                   crapljt.cdbandoc = craptdb.cdbandoc AND
                                   crapljt.nrdctabb = craptdb.nrdctabb AND
                                   crapljt.nrcnvcob = craptdb.nrcnvcob AND
                                   crapljt.nrdocmto = craptdb.nrdocmto 
                                   EXCLUSIVE-LOCK:
                         
                ASSIGN crapljt.vldjuros = crapljt.vldjuros + crapljt.vlrestit
                       crapljt.vlrestit = 0.
   
            END.  /*  Fim do FOR EACH crapljt  */
            
        END. /* Final da leitura dos titulos para sem baixados */
    
    END. /* Final da transacao */

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca_desconto_titulos:
    /**********************************************************************
        Objetivo: Buscar desconto de titulos - Tela LISEPR
    **********************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-emprestimo.

    FOR EACH craplim WHERE 
             craplim.cdcooper  = par_cdcooper                       AND
             craplim.dtpropos >= par_dtinicio                       AND
             craplim.dtpropos <= par_dttermin                       AND  
             craplim.tpctrlim = 3                                   AND
             craplim.insitlim = 2  /* ATIVO */                      AND
            (craplim.cddlinha = par_cdlcremp OR par_cdlcremp = 0)   NO-LOCK,
       FIRST crapass WHERE                                          
             crapass.cdcooper = par_cdcooper                        AND
             crapass.nrdconta = craplim.nrdconta                    AND
            (crapass.cdagenci = par_cdagenci OR par_cdagenci = 0)   NO-LOCK
             BREAK BY crapass.cdagenci
                   BY crapass.nrdconta 
                   BY craplim.nrctrlim:

        CREATE tt-emprestimo.
        ASSIGN tt-emprestimo.cdagenci = crapass.cdagenci
               tt-emprestimo.nrdconta = craplim.nrdconta
               tt-emprestimo.nmprimtl = crapass.nmprimtl
               tt-emprestimo.nrctremp = craplim.nrctrlim
               tt-emprestimo.dtmvtolt = craplim.dtinivig
               tt-emprestimo.vlemprst = craplim.vllimite
               tt-emprestimo.cdlcremp = craplim.cddlinha
               tt-emprestimo.dtmvtprp = craplim.dtpropos
               tt-emprestimo.diaprmed = (craplim.dtinivig - craplim.dtpropos)
               tt-emprestimo.dsorigem = "titulos".

        FOR EACH craptdb WHERE 
                (craptdb.cdcooper = craplim.cdcooper AND
                 craptdb.nrdconta = craplim.nrdconta AND
                 craptdb.insittit = 4) 
                 OR                    
                (craptdb.cdcooper = craplim.cdcooper AND
                 craptdb.nrdconta = craplim.nrdconta AND
                 craptdb.insittit = 2                AND 
                 craptdb.dtdpagto = par_dtmvtolt)
                 NO-LOCK:

            ASSIGN tt-emprestimo.vlsdeved = tt-emprestimo.vlsdeved + 
                                            craptdb.vltitulo.
        
        END. /*  Fim do FOR EACH craptdb  */

    END. /* FOR EACH craplim */

END PROCEDURE. /* Fim  */

/*****************************************************************************/
/*             Rotina para listar linhas de desconto de títulos              */
/*****************************************************************************/
PROCEDURE lista-linhas-desc-tit:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddlinha AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-linhas_desc.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-linhas_desc.

    ASSIGN aux_nrregist = par_nrregist.

    /* Procura algum convenio ativo */
    FIND FIRST crapceb WHERE crapceb.cdcooper = par_cdcooper     AND
                             crapceb.nrdconta = par_nrdconta     AND   
                             crapceb.insitceb = 1 /* ATIVO */
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapceb THEN
        RETURN "NOK".

    FOR EACH crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                           crapldc.tpdescto = 3                AND
                           crapldc.flgstlcr = TRUE             AND
                          (IF par_cddlinha <> 0 THEN
                           crapldc.cddlinha = par_cddlinha ELSE TRUE) NO-LOCK,
        EACH crapcco WHERE crapcco.cdcooper = crapldc.cdcooper NO-LOCK
        BREAK BY crapldc.cddlinha:

        IF  FIRST-OF(crapldc.cddlinha) THEN
            DO:
                ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginaçao */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist >= 1 THEN
                DO:
                    CREATE tt-linhas_desc.
                    ASSIGN tt-linhas_desc.cddlinha = crapldc.cddlinha
                           tt-linhas_desc.dsdlinha = crapldc.dsdlinha
                           tt-linhas_desc.txmensal = crapldc.txmensal.
                    
                END.
                
                ASSIGN aux_nrregist = aux_nrregist - 1.

            END.
    END.

    RETURN "OK".

END PROCEDURE.
    
/*****************************************************************************/
/*             Buscas tipos de cobrança disponíveis para conta               */
/*****************************************************************************/
PROCEDURE busca_tipos_cobranca:

    DEF INPUT  PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT  PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_tpcobran AS CHAR                    NO-UNDO.

    FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper      AND
                           crapcco.dsorgarq <> "PROTESTO"       NO-LOCK,
        EACH crapceb WHERE crapceb.cdcooper = crapcco.cdcooper  AND
                           crapceb.nrconven = crapcco.nrconven  AND
                           crapceb.nrdconta = par_nrdconta      NO-LOCK:

        IF par_tpcobran = "R" AND
           crapcco.flgregis = FALSE THEN
            DO:
                ASSIGN par_tpcobran = "T".
                RETURN "OK".
            END.

        IF par_tpcobran = "S" AND
           crapcco.flgregis = TRUE THEN
            DO:
                ASSIGN par_tpcobran = "T".  
                RETURN "OK".
            END.

        IF crapcco.flgregis = TRUE THEN
            ASSIGN par_tpcobran = "R".
        ELSE
            ASSIGN par_tpcobran = "S".
    END.

    RETURN "OK".

END PROCEDURE.
               
/*****************************************************************************/
/*                   Valida Títulos para inclusao em Borderô                 */
/*****************************************************************************/
PROCEDURE valida-titulo-bordero:

    DEF INPUT  PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT  PARAM par_nrcnvcob AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdocmto AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_vlutiliz AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_vllimite AS DECI                    NO-UNDO.
                           
    DEF INPUT  PARAM TABLE FOR tt-titulos.
    DEF INPUT  PARAM TABLE FOR tt-dados_dsctit.
    DEF INPUT  PARAM TABLE FOR tt-dados_dsctit_cr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    /* buscar quantidade maxima de digitos aceitos para o convenio */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_valida_adesao_produto
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 35, /* Desconto de Titulo */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */
                
    CLOSE STORED-PROC pc_valida_adesao_produto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic
                              WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
           aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                              WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".
        END.
    
    FIND FIRST tt-dados_dsctit_cr NO-LOCK NO-ERROR.   
    FIND FIRST tt-dados_dsctit    NO-LOCK NO-ERROR.   

    FIND tt-titulos WHERE tt-titulos.nrcnvcob = par_nrcnvcob AND
                          tt-titulos.nrdocmto = par_nrdocmto NO-LOCK.

    IF  (tt-titulos.vltitulo < tt-dados_dsctit.vlminsac     AND tt-titulos.flgregis = FALSE) OR
        (tt-titulos.vltitulo < tt-dados_dsctit_cr.vlminsac  AND tt-titulos.flgregis = TRUE ) THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor minimo de titulo nao atingido. Titulos a partir R$ " +
                                   IF tt-titulos.flgregis = TRUE THEN 
                                       STRING(tt-dados_dsctit_cr.vlminsac,"zzz,zz9.99")
                                   ELSE 
                                       STRING(tt-dados_dsctit.vlminsac,"zzz,zz9.99").

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    /* Critica para tolerancia de limite excedido */
    par_vlutiliz = par_vlutiliz + tt-titulos.vltitulo.

    IF  (par_vlutiliz > 
        (par_vllimite * (1 + (tt-dados_dsctit.pctolera / 100)))    AND tt-titulos.flgregis = FALSE) OR
        (par_vlutiliz >
        (par_vllimite * (1 + (tt-dados_dsctit_cr.pctolera / 100))) AND tt-titulos.flgregis = TRUE ) THEN    
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tolerancia para limite excedida. Inclusao nao permitida."
                   par_vlutiliz = par_vlutiliz - tt-titulos.vltitulo.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
    
    /* Validacao de vigencia */
    /* O titulo deve estar entre os valores especificados na TAB052 */
    IF  ((tt-titulos.dtvencto < (par_dtmvtolt + tt-dados_dsctit.qtprzmin)     OR
          tt-titulos.dtvencto > (par_dtmvtolt + tt-dados_dsctit.qtprzmax))    AND tt-titulos.flgregis = FALSE) OR
        ((tt-titulos.dtvencto < (par_dtmvtolt + tt-dados_dsctit_cr.qtprzmin)  OR
          tt-titulos.dtvencto > (par_dtmvtolt + tt-dados_dsctit_cr.qtprzmax)) AND tt-titulos.flgregis = TRUE ) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   par_vlutiliz = par_vlutiliz - tt-titulos.vltitulo.
                   aux_dscritic = "O vencimento do titulo deve estar entre " +
                                   IF tt-titulos.flgregis = TRUE THEN 
                                       STRING((par_dtmvtolt + tt-dados_dsctit_cr.qtprzmin), "99/99/99")
                                       + " e " +
                                       STRING((par_dtmvtolt + tt-dados_dsctit_cr.qtprzmax), "99/99/99") + "."
                                   ELSE 
                                       STRING((par_dtmvtolt + tt-dados_dsctit.qtprzmin), "99/99/99")
                                       + " e " +
                                       STRING((par_dtmvtolt + tt-dados_dsctit.qtprzmax), "99/99/99") + ".".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
        
    RETURN "OK".

END PROCEDURE.

               
/*****************************************************************************/
/*           Faz a exclusao de um borderô e todos os títulos dele            */
/*****************************************************************************/
PROCEDURE excluir-bordero-inteiro:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtsistem AS DATE                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".    

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    EXCLUIR-BOR:
    DO  TRANSACTION ON ERROR UNDO EXCLUIR-BOR, RETURN "NOK":
         
        DO  aux_contador = 1 TO 10:

            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND 
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = par_cdbccxlt AND
                               craplot.nrdolote = par_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 60.
                            LEAVE.
                        END.
                ELSE
                    DO:   
                        IF  craplot.tplotmov <> 34   THEN
                            DO:
                                ASSIGN aux_cdcritic = 100.
                                LEAVE.
                            END.
                    END.
                    
                aux_cdcritic = 0.
                LEAVE.
            
        END.   /*  Fim do DO .. TO  */
            
        IF  aux_cdcritic > 0   THEN
            DO:
                ASSIGN aux_dscritic = "".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                    
                UNDO EXCLUIR-BOR, RETURN "NOK".
            END.

        DO  WHILE TRUE:
                                 
            FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper AND 
                               crapbdt.nrborder = craplot.cdhistor
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdt   THEN
                IF  LOCKED crapbdt   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    UNDO EXCLUIR-BOR, RETURN "NOK".
            LEAVE.

        END. /*  Fim do DO WHILE TRUE  */
            
        IF  crapbdt.insitbdt = 3   THEN                    /*  Liberado  */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Bordero ja LIBERADO".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                UNDO EXCLUIR-BOR, RETURN "NOK".
            END.
        ELSE
            IF  crapbdt.insitbdt = 2   THEN    /*  Analisado  */
                ASSIGN crapbdt.insitbdt = 1.   /*  Em estudo  */

        /* Seleciona todos os títulos do Borderô para exclusao */
        FOR EACH tt-titulos NO-LOCK:
        
            FIND craptdb  WHERE craptdb.cdcooper = par_cdcooper        AND
                                craptdb.nrdconta = tt-titulos.nrdconta AND
                                craptdb.nrborder = tt-titulos.nrborder AND
                                craptdb.cdbandoc = tt-titulos.cdbandoc AND
                                craptdb.nrdctabb = tt-titulos.nrdctabb AND
                                craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
                                craptdb.nrdocmto = tt-titulos.nrdocmto AND
                                craptdb.insittit = 0
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAIL craptdb  THEN
                NEXT.
                
            IF  par_dtmvtolt = par_dtsistem  THEN
                DO:
                    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                           craplot.qtinfoln = craplot.qtinfoln - 1
                           craplot.vlinfodb = craplot.vlinfodb - 
                                                       tt-titulos.vltitulo
                           craplot.vlinfocr = craplot.vlinfocr -
                                                       tt-titulos.vltitulo
                           craplot.vlcompdb = craplot.vlcompdb -
                                                        tt-titulos.vltitulo
                           craplot.vlcompcr = craplot.vlcompcr - 
                                                        tt-titulos.vltitulo
                           craplot.nrseqdig = craplot.nrseqdig - 1.
                   
                    IF  craplot.qtcompln = 0  THEN
                        DELETE craplot.
                END.
            ELSE
                DO:
                    UNIX SILENT 
                     VALUE("echo " + STRING(par_dtsistem,"99/99/9999") + " " +
                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                           " Operador " + par_cdoperad +
                           " Excluiu o boleto: " + 
                           STRING(par_dtmvtolt,"99/99/99") + " " + 
                           STRING(par_cdagenci,"zz9") + " " +
                           STRING(par_cdbccxlt,"zz9") + " " +
                           STRING(par_nrdolote,"zzz,zz9") + " " +
                           STRING(par_nrdconta,"z,zzz,zz9,9") + " " +
                           STRING(tt-titulos.nrcnvcob,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.nrdocmto,"zz,zzz,zz9") + " " +
                           STRING(tt-titulos.vltitulo,"zzz,zz9.99") + " " +
                           " do bordero " +
                           STRING(tt-titulos.nrborder,"zzz,zz9") + "." +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/lanbdt.log").
                END.
            
            DELETE craptdb.
            
            /* Se o bordero nao possuir mais nenhum titulo remove o bordero */
            IF  NOT CAN-FIND(FIRST craptdb WHERE 
                                   craptdb.cdcooper = crapbdt.cdcooper AND
                                   craptdb.nrdconta = crapbdt.nrdconta AND
                                   craptdb.nrborder = crapbdt.nrborder 
                                   NO-LOCK) THEN
                DO:
                    UNIX SILENT 
                     VALUE("echo " + STRING(par_dtsistem,"99/99/9999") + " " +
                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                           " Operador " + par_cdoperad +
                           " Excluiu o bordero: " + 
                           STRING(crapbdt.nrborder,"zzz,zz9") + "." +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/lanbdt.log").                
                    DELETE crapbdt.
                END.
            
        END. /* Final do FOR EACH */

    END.  /*  Fim da transacao  */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*                     Procura restriçoes de um borderô                      */
/*****************************************************************************/
PROCEDURE analisar-titulo-bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_indrestr AS INTE             NO-UNDO.

    DEF OUTPUT PARAM par_flsnhcoo AS LOGICAL                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_nrseqdig         AS INTE                    NO-UNDO.
    DEF VAR aux_cntqttit         AS INTE                    NO-UNDO.
    DEF VAR aux_dsrestri         AS CHAR                    NO-UNDO.
    DEF VAR aux_dsdetres         AS CHAR                    NO-UNDO.
    DEF VAR aux_vltotsac_cr      AS DECI                    NO-UNDO.
    DEF VAR aux_vltotsac_sr      AS DECI                    NO-UNDO.
    DEF VAR aux_vltotbdt_cr      AS DECI                    NO-UNDO.
    DEF VAR aux_vltotbdt_sr      AS DECI                    NO-UNDO.
    DEF VAR aux_vlcontit         AS DECI                    NO-UNDO.
    DEF VAR aux_pcnaopag_cr      AS DECI INIT 0             NO-UNDO.
    DEF VAR aux_qtnaopag_cr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_qtprotes_cr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_qttitdsc_cr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_naopagos_cr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_pcnaopag_sr      AS DECI INIT 0             NO-UNDO.
    DEF VAR aux_qtnaopag_sr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_qttitdsc_sr      AS INTE INIT 0             NO-UNDO.
    DEF VAR aux_naopagos_sr      AS INTE INIT 0             NO-UNDO.

    DEF BUFFER crabtdb  FOR craptdb.
    DEF BUFFER crabcob  FOR crapcob.

    /* GGS - Inicio */  
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL(crapass)  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                
            RETURN "NOK".    

        END.
    /* GGS - Fim */
    
    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT TRUE, /* COB.REGISTRADA */
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit_cr,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).
         
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN busca_parametros_dsctit (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT FALSE, /* COB.SEM REGISTRO */
                                 INPUT crapass.inpessoa, /* GGS: Novo: Tipo Pessoa = crapass.inpessoa */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dsctit,
                                 OUTPUT TABLE tt-dados_cecred_dsctit).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN busca_dados_dsctit (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT FALSE,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-desconto_titulos).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    /* Calcular valor Total dos Títulos desse bordero com COB. REGISTRADA e S/ REGISTRO */
    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper     AND
                           craptdb.nrborder = par_nrborder     AND
                           craptdb.nrdconta = par_nrdconta     AND
                           craptdb.insittit = 0                NO-LOCK,
        EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdocmto = craptdb.nrdocmto NO-LOCK:

            IF crapcob.flgregis = TRUE THEN 
                ASSIGN aux_vltotbdt_cr = (aux_vltotbdt_cr + craptdb.vltitulo).
            ELSE
            IF crapcob.flgregis = FALSE THEN
                ASSIGN aux_vltotbdt_sr = (aux_vltotbdt_sr + craptdb.vltitulo).
    END.

    /* Elimina todas as restriçoes do borderô */
    FOR EACH crapabt WHERE crapabt.cdcooper = par_cdcooper AND
                           crapabt.nrborder = par_nrborder EXCLUSIVE-LOCK.
        DELETE crapabt.
    END.

    FIND FIRST tt-desconto_titulos NO-LOCK NO-ERROR NO-WAIT.
    FIND FIRST tt-dados_dsctit_cr  NO-LOCK NO-ERROR NO-WAIT.
    FIND FIRST tt-dados_dsctit     NO-LOCK NO-ERROR NO-WAIT.

    /* Se for liberar, critica para tolerancia de limite excedido de acordo com o tipo de cobranca */
    IF  par_cddopcao = "L" THEN
        DO:
            IF  tt-desconto_titulos.vlutilsr > 0 THEN
                IF  ((tt-desconto_titulos.vlutilsr + aux_vltotbdt_sr) > (tt-desconto_titulos.vllimite * (1 + (tt-dados_dsctit.pctolera / 100)))) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Tolerancia para limite excedida.".
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
                    END.
        
            IF  tt-desconto_titulos.vlutilcr > 0 THEN
                IF ((tt-desconto_titulos.vlutilcr + aux_vltotbdt_cr) > (tt-desconto_titulos.vllimite * (1 + (tt-dados_dsctit_cr.pctolera / 100)))) THEN    
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Tolerancia para limite excedida.".
                
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
                    END.
        END.

    /* Seleciona cada Título do Borderô */
    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrborder = par_nrborder AND
                           craptdb.nrdconta = par_nrdconta NO-LOCK
                           BY craptdb.nrseqdig:

        /* Adquire informaçoes sobre o Tipo de Cobrança do Título */
        FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto
                           NO-LOCK NO-ERROR NO-WAIT.


        IF  NOT AVAIL crapcob THEN
            NEXT.

        /* Validaçoes */
        DO WHILE TRUE:

            ASSIGN aux_nrseqdig = 0
                   aux_dsrestri = "".
            
            /* Verifica se o titulo ja foi pago ou vencido */
            IF  crapcob.incobran = 5  THEN
                DO:
                    ASSIGN aux_dsrestri = "Titulo ja foi pago."
                           aux_nrseqdig = IF crapcob.flgregis = TRUE THEN 55
                                          ELSE 5.

                    /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT " ",   /* dsdetres */
                                                 INPUT FALSE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                END.

            /* Verifica se o titulo está baixado */
            IF  crapcob.incobran = 3 THEN
                DO:
                    ASSIGN aux_dsrestri = "Titulo baixado."
                           aux_nrseqdig = IF crapcob.flgregis = TRUE THEN 53
                                          ELSE 3.

                    /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT " ",   /* dsdetres */
                                                 INPUT FALSE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                END.

            /* Todos os titulos COB. REGISTRADA e S/ REGISTRO desse bordero 
                                                        de um determinado sacado */
            ASSIGN aux_vltotsac_cr = 0
                   aux_vltotsac_sr = 0
                   .

            FOR EACH crabtdb WHERE crabtdb.cdcooper = par_cdcooper     AND
                                   crabtdb.nrborder = par_nrborder     AND
                                   crabtdb.nrinssac = craptdb.nrinssac AND
                                   crabtdb.nrdconta = craptdb.nrdconta AND
                                   crabtdb.insittit = 0                NO-LOCK,
                EACH crabcob WHERE crabcob.cdcooper = crabtdb.cdcooper AND
                                   crabcob.cdbandoc = craptdb.cdbandoc AND
                                   crabcob.nrdctabb = craptdb.nrdctabb AND 
                                   crabcob.nrdconta = crabtdb.nrdconta AND
                                   crabcob.nrcnvcob = crabtdb.nrcnvcob AND
                                   crabcob.nrdocmto = crabtdb.nrdocmto NO-LOCK:

                    IF crabcob.flgregis = TRUE THEN 
                        ASSIGN aux_vltotsac_cr = aux_vltotsac_cr + crabtdb.vltitulo.
                    ELSE
                    IF crabcob.flgregis = FALSE THEN 
                        ASSIGN aux_vltotsac_sr = aux_vltotsac_sr + crabtdb.vltitulo.
                
            END.  /*  Fim do FOR EACH  -- crabtdb  */

            IF  ((aux_vltotsac_cr / aux_vltotbdt_cr) * 100) > tt-dados_dsctit_cr.pcmxctip  OR
                ((aux_vltotsac_sr / aux_vltotbdt_sr) * 100) > tt-dados_dsctit.pcmxctip     THEN
                DO:
                    ASSIGN aux_dsrestri = "Percentual de titulo do " +
                                          "pagador excedido no bordero"
                           aux_nrseqdig = IF crapcob.flgregis = TRUE THEN 52
                                          ELSE 2.

                    /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT " ",   /* dsdetres */
                                                 INPUT FALSE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                END.

            /* Restricao referente a consulta de CPF/CNPJ do Sacado */
            ASSIGN aux_vlcontit = IF crapcob.flgregis = TRUE THEN tt-dados_dsctit_cr.vlconsul
                                  ELSE tt-dados_dsctit.vlconsul.

            IF  craptdb.vltitulo >= aux_vlcontit  THEN
                DO:
                    ASSIGN aux_dsrestri = "Consultar o CPF/CNPJ do pagador."
                           aux_nrseqdig = IF crapcob.flgregis = TRUE THEN 54
                                          ELSE 4.

                    /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT " ",   /* dsdetres */
                                                 INPUT FALSE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                END.

            /* Verifica situaçao de inadimplencia do sacado */
            FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrcpfcgc = craptdb.nrinssac AND
                                   crapass.dtdemiss = ?                NO-LOCK:

                IF  crapass.inadimpl = 1 THEN
                    DO:
                        ASSIGN aux_dsrestri = "Pagador consta no SPC."
                               aux_nrseqdig = IF crapcob.flgregis = TRUE THEN 57
                                              ELSE 7.

                        /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                        RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nrborder,
                                                     INPUT aux_nrseqdig,
                                                     INPUT aux_dsrestri,
                                                     INPUT " ",   /* dsdetres */
                                                     INPUT FALSE, /* flaprcoo */
                                                     OUTPUT TABLE tt-erro).
                                                  
                        IF  RETURN-VALUE = "NOK" THEN
                            RETURN "NOK".

                    END.
            END.

            /* Se Cob. Registrada, valida num. de títulos protestados 
                                        e remetidos ao cartório */
            IF  crapcob.flgregis = TRUE THEN
                DO:
                    ASSIGN aux_cntqttit = 0.

                    /* Conta títulos protestados de cada sacado para esse cedente */
                    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,     /* Conta/DV */
                                                    INPUT craptdb.nrinssac, /* Sacado */
                                                    INPUT 9,                /* Ocorrencia */
                                                    INPUT 14,               /* Motivo */
                                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                                    OUTPUT aux_cntqttit,    /* Tot. Títulos */
                                                    OUTPUT TABLE tt-erro).
                                                  
                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                    /* Se nrm. de tít. protest. desse sacado for maior do que param. da TAB052 */
                    IF  aux_cntqttit >= tt-dados_dsctit_cr.qttitprt AND 
                        tt-dados_dsctit_cr.qttitprt > 0 THEN
                        DO:
                            ASSIGN aux_dsrestri = "Pagador com titulos protestados acima do permitido."
                                   aux_nrseqdig = 91
                                   par_flsnhcoo = TRUE
                                   par_indrestr = 1.
                          
                            /* Se nao passar na validaçao, grava na tabela a crítica referente a Restricao */
                            RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nrborder,
                                                         INPUT aux_nrseqdig,
                                                         INPUT aux_dsrestri,
                                                         INPUT STRING(aux_cntqttit), /* dsdetres */
                                                         INPUT TRUE,                 /* flaprcoo */
                                                         OUTPUT TABLE tt-erro).
                                                      
                            IF  RETURN-VALUE = "NOK" THEN
                                RETURN "NOK".

                        END.

                    ASSIGN aux_cntqttit = 0.

                    /* Conta títulos remetidos ao cartório de cada sacado para esse cedente */
                    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,     /* Conta/DV */
                                                    INPUT craptdb.nrinssac, /* Sacado */
                                                    INPUT 23,               /* Ocorrencia */
                                                    INPUT 0,                /* Motivo */
                                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                                    OUTPUT aux_cntqttit,    /* Tot. Títulos */
                                                    OUTPUT TABLE tt-erro).
                                                  
                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                    /* Se nrm. de tít. rem. ao cartorio desse sacado for maior do que param. da TAB052 */
                    IF  aux_cntqttit >= tt-dados_dsctit_cr.qtremcrt AND 
                        tt-dados_dsctit_cr.qtremcrt > 0 THEN
                        DO:
                            ASSIGN aux_dsrestri = "Pagador com titulos em cartorio acima do permitido."
                                   aux_nrseqdig = 90
                                   par_flsnhcoo = TRUE
                                   par_indrestr = 1.

                            /* Grava na tabela a crítica referente a Restricao */
                            RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nrborder,
                                                         INPUT aux_nrseqdig,
                                                         INPUT aux_dsrestri,
                                                         INPUT STRING(aux_cntqttit), /* dsdetres */
                                                         INPUT TRUE,                 /* flaprcoo */
                                                         OUTPUT TABLE tt-erro).
                                                      
                            IF  RETURN-VALUE = "NOK" THEN
                                RETURN "NOK".

                        END.

                END. /* crapcob.flgregis = TRUE */

            IF  craptdb.dtvencto <= par_dtmvtolt   THEN
                DO:                                  
                    ASSIGN aux_dscritic = "Ha titulos com data de liberacao " +
                                          "igual ou inferior a data do movimento.".
                    LEAVE.
                END.

            LEAVE.

        END. /* Final DO WHILE TRUE */

        IF  aux_nrseqdig > 0   OR
            aux_dsrestri <> "" THEN
                ASSIGN par_indrestr = 1.
        
        /* Gera erro e grava log */
        IF  aux_cdcritic > 0    OR
            aux_dscritic <> ""  THEN
            DO:
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

    END. /* Final do FOR EACH craptdb */
        
    /* Seleciona cada Título do Borderô */
    FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrdconta = par_nrdconta 
                           NO-LOCK:
        
        /* Adquire informaçoes sobre o Tipo de Cobrança do Título */
        FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcob THEN
           NEXT.
    
        /* Analisado */
        IF crapcob.flgregis = TRUE THEN
           DO:
               IF craptdb.insittit = 2 THEN
                  ASSIGN aux_qttitdsc_cr = aux_qttitdsc_cr + 1.
               ELSE 
               /* Liberado */
               IF craptdb.insittit = 3 THEN
                  ASSIGN aux_naopagos_cr = aux_naopagos_cr + 1.
           END.               
        ELSE
           DO:
               /* Analisado */
               IF craptdb.insittit = 2 THEN
                  ASSIGN aux_qttitdsc_sr = aux_qttitdsc_sr + 1.
               ELSE 
               /* Liberado */
               IF craptdb.insittit = 3 THEN
                  ASSIGN aux_naopagos_sr = aux_naopagos_sr + 1.
           END. /* crapcob.flgregis = FALSE */
                
    END.
    
    /* retorna qtd. total títulos protestados do cedente (cooperado) */
    RUN retorna-titulos-ocorrencia (INPUT par_cdcooper,
                                    INPUT par_nrdconta,     /* Conta/DV */
                                    INPUT 0,                /* Sacado */
                                    INPUT 9,                /* Ocorrencia */
                                    INPUT 14,               /* Motivo */
                                    INPUT FALSE,            /* Apenas tit. em bord.*/
                                    OUTPUT aux_qtprotes_cr, /* Tot. Títulos */
                                    OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
    
    /* Titulos contidos no bordero */ 
    FOR EACH craptdb FIELDS(nrinssac cdbandoc nrdctabb)
                     WHERE craptdb.cdcooper = par_cdcooper AND
                           craptdb.nrborder = par_nrborder AND
                           craptdb.nrdconta = par_nrdconta NO-LOCK
                           BREAK BY craptdb.nrinssac:
                 
        IF  FIRST-OF(craptdb.nrinssac)  THEN
            DO:
                /* Verifica TODOS os titulos nao pagos por Sacado */
                FOR EACH crabtdb FIELDS(cdcooper nrdconta nrcnvcob nrdocmto)
                                 WHERE crabtdb.cdcooper = par_cdcooper                                   AND
                                       crabtdb.insittit = 3                                              AND
                                       crabtdb.nrinssac = craptdb.nrinssac                               AND
                                       crabtdb.dtvencto > par_dtmvtolt - (tt-dados_dsctit.nrmespsq * 30)
                                       NO-LOCK,
                
                    EACH crabcob WHERE crabcob.cdcooper = crabtdb.cdcooper AND
                                       crabcob.cdbandoc = craptdb.cdbandoc AND
                                       crabcob.nrdctabb = craptdb.nrdctabb AND 
                                       crabcob.nrdconta = crabtdb.nrdconta AND
                                       crabcob.nrcnvcob = crabtdb.nrcnvcob AND
                                       crabcob.nrdocmto = crabtdb.nrdocmto NO-LOCK:
                    
                    IF crabcob.flgregis = TRUE THEN 
                        ASSIGN aux_qtnaopag_cr = aux_qtnaopag_cr + 1.
                    ELSE
                    IF crabcob.flgregis = FALSE THEN 
                        ASSIGN aux_qtnaopag_sr = aux_qtnaopag_sr + 1.
                END.
            END.
    END.
        
    /* Valor medio por titulo descontado */
    IF  aux_qttitdsc_cr > 0  THEN
        ASSIGN aux_pcnaopag_cr = ROUND((aux_naopagos_cr * 100) / aux_qttitdsc_cr, 2).

    /* Valor medio por titulo descontado */
    IF  aux_qttitdsc_sr > 0  THEN
        ASSIGN aux_pcnaopag_sr = ROUND((aux_naopagos_sr * 100) / aux_qttitdsc_sr, 2).

    FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper 
                         AND craptdb.nrborder = par_nrborder 
                         AND craptdb.nrdconta = par_nrdconta    
                         NO-LOCK NO-ERROR.

    IF  AVAILABLE craptdb  THEN
        DO:
            /* Valida Quantidade de Titulos protestados (carteira cooperado) */
            IF  aux_qtprotes_cr > tt-dados_dsctit_cr.qtprotes  THEN
                DO:
                   ASSIGN aux_dsrestri = "Cooperado com titulos protestados acima do permitido"
                          aux_nrseqdig = 12
                          par_flsnhcoo = TRUE
                          par_indrestr = 1.

                   /* Grava na tabela a crítica referente a Restricao */
                   RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT par_nrborder,
                                                INPUT aux_nrseqdig,
                                                INPUT aux_dsrestri,
                                                INPUT STRING(aux_qtprotes_cr), /* dsdetres */
                                                INPUT TRUE,                    /* flaprcoo */
                                                OUTPUT TABLE tt-erro).
                   IF  RETURN-VALUE <> "OK" THEN
                       RETURN "NOK".
                END.
    
            /* Valida Qtde de Titulos Nao Pago Pagador */
            IF  aux_qtnaopag_cr > tt-dados_dsctit_cr.qtnaopag  OR
                aux_qtnaopag_sr > tt-dados_dsctit.qtnaopag     THEN
                DO:
                    ASSIGN aux_dsrestri = "Pagador com titulos nao pagos acima do permitido"
                           aux_dsdetres = "Com Registro: " + STRING(aux_qtnaopag_cr) + 
                                          ". Sem Registro: " + STRING(aux_qtnaopag_sr)
                           aux_nrseqdig = 10
                           par_flsnhcoo = TRUE
                           par_indrestr = 1.

                    /* Grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT aux_dsdetres,
                                                 INPUT TRUE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".
                END.
       
            /* Valida Perc. de Titulos Nao Pago Beneficiario */
            IF  aux_pcnaopag_cr > tt-dados_dsctit_cr.pcnaopag  OR
                aux_qtnaopag_sr > tt-dados_dsctit.pcnaopag     THEN
                DO:
                    ASSIGN aux_dsrestri = "Cooperado com titulos nao pagos acima do permitido"
                           aux_dsdetres = "Com Registro: " + STRING(aux_pcnaopag_cr,"z,zz9") + 
                                          ". Sem Registro: " + STRING(aux_pcnaopag_sr,"z,zz9")
                           aux_nrseqdig = 11
                           par_flsnhcoo = TRUE
                           par_indrestr = 1.

                    /* Grava na tabela a crítica referente a Restricao */
                    RUN grava-restricao-bordero (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrborder,
                                                 INPUT aux_nrseqdig,
                                                 INPUT aux_dsrestri,
                                                 INPUT aux_dsdetres,
                                                 INPUT TRUE, /* flaprcoo */
                                                 OUTPUT TABLE tt-erro).
                   IF  RETURN-VALUE <> "OK" THEN
                       RETURN "NOK".
                END.

        END. /* AVAILABLE craptdb */
        
    RETURN "OK".
 
END PROCEDURE.

/*****************************************************************************/
/*                     Grava as restriçoes de um borderô                     */
/*****************************************************************************/
PROCEDURE grava-restricao-bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrseqdig AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsrestri AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dsdetres AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flaprcoo AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO  aux_contador = 1 TO 10:

        FIND crapabt WHERE crapabt.cdcooper = par_cdcooper     AND
                           crapabt.nrborder = par_nrborder     AND
                           crapabt.cdbandoc = craptdb.cdbandoc AND
                           crapabt.nrdctabb = craptdb.nrdctabb AND
                           crapabt.nrcnvcob = craptdb.nrcnvcob AND
                           crapabt.nrdconta = craptdb.nrdconta AND
                           crapabt.nrdocmto = craptdb.nrdocmto AND
                           crapabt.nrseqdig = par_nrseqdig
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapabt  THEN
            DO:
                IF  LOCKED crapabt   THEN
                    DO:
                        ASSIGN aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        /* Cria Restricao */
                        CREATE crapabt.
                        ASSIGN crapabt.cdcooper = par_cdcooper
                               crapabt.nrborder = crapbdt.nrborder
                               crapabt.cdbandoc = craptdb.cdbandoc
                               crapabt.nrdctabb = craptdb.nrdctabb
                               crapabt.nrcnvcob = craptdb.nrcnvcob
                               crapabt.nrdconta = craptdb.nrdconta
                               crapabt.nrdocmto = craptdb.nrdocmto
                               crapabt.cdoperad = par_cdoperad
                               crapabt.dsrestri = par_dsrestri
                               crapabt.nrseqdig = par_nrseqdig
                               crapabt.dsdetres = par_dsdetres
                               crapabt.flaprcoo = par_flaprcoo.
                        VALIDATE crapabt.
                    END.
            END.

    END. /* Fim do DO ... TO */

    RETURN "OK".
 
END PROCEDURE.

/*****************************************************************************/
/*         Retona a qtd. de Títulos de acordo com alguma ocorrencia          */
/*****************************************************************************/
PROCEDURE retorna-titulos-ocorrencia:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrinssac AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotivo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgtitde AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM par_cntqttit AS INTE                   NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_query            AS CHAR                    NO-UNDO.
    DEF VAR q_crapcob            AS HANDLE                  NO-UNDO.

    CREATE QUERY q_crapcob.
    q_crapcob:SET-BUFFERS(BUFFER crapcco:HANDLE).
    q_crapcob:ADD-BUFFER(BUFFER crapceb:HANDLE).
    q_crapcob:ADD-BUFFER(BUFFER crapcob:HANDLE).

    EMPTY TEMP-TABLE tt-erro.

    /* Monta a QUERY dinamicamente de acordo com parametros informados */
    ASSIGN aux_query = "FOR EACH crapcco WHERE crapcco.cdcooper = " + STRING(par_cdcooper) + 
                                         " AND crapcco.flgregis = TRUE".

    ASSIGN aux_query = aux_query + " NO-LOCK, " +
                           "EACH crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                           AND crapceb.nrconven = crapcco.nrconven".
    IF par_nrdconta > 0 THEN
        ASSIGN aux_query = aux_query + " AND crapceb.nrdconta = " + STRING(par_nrdconta).

    ASSIGN aux_query = aux_query + " NO-LOCK, " +
                           "EACH crapcob WHERE crapcob.cdcooper = crapceb.cdcooper
                                           AND crapcob.cdbandoc = crapcob.cdbandoc
                                           AND crapcob.nrdctabb = crapcob.nrdctabb 
                                           AND crapcob.nrdconta = crapceb.nrdconta 
                                           AND crapcob.nrcnvcob = crapceb.nrconven".
                                           
    IF par_cdocorre = 9 THEN /* protestado */               
        ASSIGN aux_query = aux_query + " AND crapcob.incobran = 3".

    IF par_nrinssac > 0 THEN
        ASSIGN aux_query = aux_query + " AND crapcob.nrinssac = " + STRING(par_nrinssac).
        
    IF par_flgtitde THEN
        DO:
            
            q_crapcob:ADD-BUFFER(BUFFER craptdb:HANDLE).

            ASSIGN aux_query = aux_query + " NO-LOCK, " +
                       "EACH craptdb NO-LOCK WHERE craptdb.cdcooper = crapcob.cdcooper
                                               AND craptdb.cdbandoc = crapcob.cdbandoc
                                               AND craptdb.nrdctabb = crapcob.nrdctabb 
                                               AND craptdb.nrcnvcob = crapcob.nrcnvcob 
                                               AND craptdb.nrdconta = crapcob.nrdconta 
                                               AND craptdb.nrdocmto = crapcob.nrdocmto
                                               AND craptdb.insittit = 4".
        END.

    IF par_cdocorre > 0 THEN
        DO:
            q_crapcob:ADD-BUFFER(BUFFER crapret:HANDLE).

            IF NOT par_flgtitde THEN
                ASSIGN aux_query = aux_query + " NO-LOCK, ".
            ELSE
                ASSIGN aux_query = aux_query + " ,".

            ASSIGN aux_query = aux_query + "EACH crapret NO-LOCK WHERE crapret.cdcooper = crapcob.cdcooper 
                                                                   AND crapret.nrdconta = crapcob.nrdconta 
                                                                   AND crapret.nrcnvcob = crapcob.nrcnvcob 
                                                                   AND crapret.nrdocmto = crapcob.nrdocmto
                                                                   AND crapret.cdocorre = " + STRING(par_cdocorre).
            IF par_cdmotivo > 0 THEN
                ASSIGN aux_query = aux_query + " AND crapret.cdmotivo = " + STRING("'" + STRING(par_cdmotivo) + "'").

        END.

    ASSIGN aux_query = aux_query + ".".

    q_crapcob:QUERY-CLOSE().
    q_crapcob:QUERY-PREPARE(aux_query).
    q_crapcob:QUERY-OPEN().

    q_crapcob:GET-FIRST().

    REPEAT:

      IF q_crapcob:QUERY-OFF-END THEN LEAVE.

      ASSIGN par_cntqttit = par_cntqttit + 1.    

      q_crapcob:GET-NEXT().

    END. /* REPEAT */
  
    DELETE OBJECT q_crapcob.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*****************************************************************************/
/*                    Procedures de Chamada para as SubBO's                  */
/*****************************************************************************/
/*****************************************************************************/
PROCEDURE carrega-impressao-dsctit:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0030i AS HANDLE                                 NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

    DEF VAR aux_nrctrlim AS INTE                                    NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0030i.p PERSISTENT SET h-b1wgen0030i.

    IF  NOT VALID-HANDLE(h-b1wgen0030i)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0030i.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    FIND crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                       crawlim.nrdconta = par_nrdconta AND
                       crawlim.tpctrlim = 3            AND
                       crawlim.nrctrlim = par_nrctrlim
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crawlim  THEN
        IF  crawlim.nrctrmnt > 0  THEN
            ASSIGN aux_nrctrlim = crawlim.nrctrmnt.
        ELSE
            ASSIGN aux_nrctrlim = par_nrctrlim.
    ELSE
        ASSIGN aux_nrctrlim = par_nrctrlim.

    IF  par_idimpres <= 4 OR par_idimpres = 9 THEN /* Impressoes de Limite */
        DO:
            RUN gera-impressao-limite IN h-b1wgen0030i (INPUT par_cdcooper,
                                                        INPUT par_cdagecxa,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_cdopecxa,
                                                        INPUT par_nmdatela,
                                                        INPUT par_idorigem,
                                                        INPUT par_nrdconta,
                                                        INPUT par_idseqttl,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_dtmvtopr,
                                                        INPUT par_inproces,
                                                        INPUT par_idimpres,
                                                        INPUT aux_nrctrlim,
                                                        INPUT par_dsiduser,
                                                        INPUT par_flgemail,
                                                        INPUT par_flgerlog,
                                                       OUTPUT par_nmarqimp,
                                                       OUTPUT par_nmarqpdf,
                                                       OUTPUT TABLE tt-erro).
                        
            DELETE PROCEDURE h-b1wgen0030i.

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

        END.
    ELSE                      /* Impressoes de Bordero */
        DO:
            RUN gera-impressao-bordero IN h-b1wgen0030i (INPUT par_cdcooper,
                                                         INPUT par_cdagecxa,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdopecxa,
                                                         INPUT par_nmdatela,
                                                         INPUT par_idorigem,
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_dtmvtopr,
                                                         INPUT par_inproces,
                                                         INPUT par_idimpres,
                                                         INPUT par_nrborder,
                                                         INPUT par_dsiduser,
                                                         INPUT par_flgemail,
                                                         INPUT par_flgerlog,
                                                        OUTPUT par_nmarqimp,
                                                        OUTPUT par_nmarqpdf,
                                                        OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h-b1wgen0030i.
            
            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_tarifa_desconto_titulo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlborder AS DECI                           NO-UNDO.
   
    DEF OUTPUT PARAM par_vltariva AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    
    DEF        VAR h-b1wgen0153        AS HANDLE                    NO-UNDO.

    DEF        VAR aux_cdbattar        AS CHAR                      NO-UNDO.
    DEF        VAR aux_cdhisest        AS INTE                      NO-UNDO.
    DEF        VAR aux_dtdivulg        AS DATE                      NO-UNDO.
    DEF        VAR aux_dtvigenc        AS DATE                      NO-UNDO.
    DEF        VAR aux_cdhistor        AS INTE                      NO-UNDO.
    DEF        VAR aux_cdfvlcop        AS INTE                      NO-UNDO.
    DEF        VAR aux_inpessoa        AS INTE                      NO-UNDO.  

    ASSIGN  aux_inpessoa = 1 /* Assume como padrao pessoa fisica */
            par_vltariva = 0.


    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR .

    /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
    IF AVAIL crapass THEN
        aux_inpessoa = crapass.inpessoa.

    IF aux_inpessoa = 1 THEN /* Fisica */
         ASSIGN aux_cdbattar = "DSTBORDEPF".
    ELSE
         ASSIGN aux_cdbattar = "DSTBORDEPJ".
                
    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

    /*  Busca valor da tarifa de Emprestimo pessoa fisica*/
    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT par_cdcooper,
                                     INPUT  aux_cdbattar,       
                                     INPUT  par_vlborder,   
                                     INPUT  "", /* cdprogra */
                                     OUTPUT aux_cdhistor,
                                     OUTPUT aux_cdhisest,
                                     OUTPUT par_vltariva,
                                     OUTPUT aux_dtdivulg,
                                     OUTPUT aux_dtvigenc,
                                     OUTPUT aux_cdfvlcop,
                                     OUTPUT TABLE tt-erro).

    ASSIGN par_cdfvlcop = aux_cdfvlcop
           par_cdhistor = aux_cdhistor.

    IF  VALID-HANDLE(h-b1wgen0153)  THEN
        DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF AVAIL tt-erro THEN 
           DO:
               ASSIGN aux_cdcritic = 0
                       aux_dscritic = tt-erro.dscritic.
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).                
                                
                RETURN "NOK".
           END.
           ELSE
           DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de titulos de desconto de " +
                                      "titulos nao encontrado.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).                
                                
                RETURN "NOK". 
           END.
        END.
        
    RETURN "OK".


END PROCEDURE.

PROCEDURE valida_situacao_pa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Validar se PA esta ativo */
    FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper AND
                             crapage.cdagenci = par_cdagenci 
                             NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapage   THEN
        ASSIGN aux_cdcritic = 15.
    ELSE    
    IF  crapage.insitage <> 1   AND   /* Ativo */
        crapage.insitage <> 3   THEN  /* Temporariamente Indisponivel */
        ASSIGN aux_cdcritic = 856.

    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).    

            RETURN "NOK".
        END.

    RETURN "OK".

END.

/***************************************************************************
 Procedure para alterar o numero da proposta de limite de desc de título.
 Opcao de Alterar na rotina Descontos da tela ATENDA. 
***************************************************************************/
PROCEDURE altera-numero-proposta-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR     aux_contador     AS INTE                           NO-UNDO.
    DEF  VAR     aux_dsoperac     AS CHAR                           NO-UNDO.
    DEF  VAR     aux_nrctrlim     AS INTE                           NO-UNDO.
    DEF  VAR     h-b1wgen0110     AS HANDLE                         NO-UNDO.
                                 
    DEF  BUFFER  crabavt          FOR crapavt.
    DEF  BUFFER  crabavl          FOR crapavl.
                                 
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o numero da proposta de limite desconto de titulos".

    IF  par_nrctrlim <= 0 THEN
        DO:
            ASSIGN aux_dscritic = "Numero da proposta deve ser diferente de zero.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 9.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
       END.

    IF  NOT VALID-HANDLE(h-b1wgen0110) THEN
        RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar o numero da proposta "  +
                          "de limite de desconto de titulos na conta " +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 11, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.

            RETURN "NOK".
        END.

    DO TRANSACTION WHILE TRUE:

        /* Verifica se ja existe contrato com o numero informado */
        FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper     AND
                                 craplim.nrdconta = par_nrdconta     AND
                                 craplim.tpctrlim = 3 /* Desc Tit */ AND
                                 craplim.nrctrlim = par_nrctrlim
                                 NO-LOCK NO-ERROR.

        IF   AVAIL craplim   THEN
             DO:
                 aux_dscritic =
                     "Numero da proposta de limite de desconto de titulos ja existente.".
                 LEAVE.
             END.

        /* Encontra contrato atual */
        FIND craplim WHERE craplim.cdcooper =  par_cdcooper     AND
                           craplim.nrdconta =  par_nrdconta     AND
                           craplim.tpctrlim =  3 /* Desc Tit */ AND
                           craplim.nrctrlim =  par_nrctrant     
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplim   THEN
             DO:
                aux_dscritic = "Proposta de limite nao existente.".
                LEAVE.
             END.

        /* Verifica se o contrato atual ja foi efetivado. */
        IF   craplim.insitlim <> 1   THEN
             DO:
                aux_dscritic = "Proposta de limite ja efetivada.".
                LEAVE.
             END.

        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper  AND
                                 crapprp.nrdconta = par_nrdconta  AND
                                 crapprp.nrctrato = par_nrctrlim  AND
                                 crapprp.tpctrato = 3 /* Desc Tit */
                                 NO-LOCK NO-ERROR.

        IF   AVAIL crapprp   THEN
             DO:
                aux_dscritic =
                     "Numero de proposta de limite ja existente.".
                 LEAVE.
             END.


        DO aux_contador = 1 TO 10:

            FIND craplim WHERE craplim.cdcooper =  par_cdcooper     AND
                               craplim.nrdconta =  par_nrdconta     AND
                               craplim.tpctrlim =  3 /* Desc Tit */ AND
                               craplim.nrctrlim =  par_nrctrant 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL craplim  THEN
                IF  LOCKED craplim THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* DO TO */

        IF  aux_cdcritic <> 0 OR
            aux_dscritic <> ""  THEN
            UNDO, LEAVE.

        /* Mudar o numero do contrato */
        ASSIGN aux_nrctrlim     = craplim.nrctrlim
               craplim.nrctrlim = par_nrctrlim.

        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper       AND
                               crapavt.tpctrato = 8 /* Desc Tit */   AND
                               crapavt.nrdconta = par_nrdconta       AND
                               crapavt.nrctremp = par_nrctrant       NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavt  THEN
                    IF  LOCKED crabavt THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF  aux_cdcritic <> 0   THEN
                LEAVE.

            /* Atualizar numero contrato */
            ASSIGN crabavt.nrctremp = par_nrctrlim.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Avalistas cooperados */
        FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper      AND
                               crapavl.nrctaavd = par_nrdconta      AND
                               crapavl.nrctravd = par_nrctrant      AND
                               crapavl.tpctrato = 8 /* Desc Tit */  NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavl WHERE crabavl.cdcooper = crapavl.cdcooper   AND
                                   crabavl.nrdconta = crapavl.nrdconta   AND
                                   crabavl.nrctravd = crapavl.nrctravd   AND
                                   crabavl.tpctrato = crapavl.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavl  THEN
                    IF  LOCKED crabavl THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Mudar o numero do contrato */
            ASSIGN crabavl.nrctravd = par_nrctrlim.
        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper      AND
                               crapprp.nrdconta = par_nrdconta      AND
                               crapprp.tpctrato = 3 /* Desc Tit */  AND
                               crapprp.nrctrato = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            IF  NOT AVAIL crapprp  THEN
                IF  LOCKED crapprp THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.
        END. /* TO DO */

        IF  aux_cdcritic <> 0   THEN
            UNDO, LEAVE.

        /* Novo numero de contrato */
        ASSIGN crapprp.nrctrato = par_nrctrlim.


        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao 
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT craplim.idcobope
                                              ,INPUT par_nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                UNDO, LEAVE.
           END.

        LEAVE.

    END. /* Fim TRANSACTION , tratamento criticas */

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
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

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
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

            IF  aux_nrctrlim <> par_nrctrlim THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctrlim",
                                         INPUT aux_nrctrlim,
                                         INPUT par_nrctrlim).
        END.
        
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
    Buscar titulos com suas restricoes liberada/analisada pelo coordenador
*****************************************************************************/
PROCEDURE busca_restricoes_coordenador:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-dsctit_bordero_restricoes.

    EMPTY TEMP-TABLE tt-dsctit_bordero_restricoes.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapabt WHERE crapabt.cdcooper = par_cdcooper  AND
                           crapabt.nrborder = par_nrborder  AND
                           crapabt.nrdconta = par_nrdconta  AND
                           crapabt.flaprcoo = TRUE          NO-LOCK:

        CREATE tt-dsctit_bordero_restricoes.
        ASSIGN tt-dsctit_bordero_restricoes.dsrestri = crapabt.dsrestri
               tt-dsctit_bordero_restricoes.dsdetres = crapabt.dsdetres.

    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*                  Verifica se os titulos ja estao em algum bordero         */
/*****************************************************************************/
PROCEDURE valida_titulos_bordero:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
	DEF INPUT PARAM par_nrborder AS INTE				    NO-UNDO.
	DEF INPUT PARAM par_tpvalida AS INTE                    NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-titulos.
         
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI NO-UNDO.

	DEF BUFFER b-craptdb FOR craptdb.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_contador = 0
		   aux_flgtrans = TRUE
		   aux_cdcritic = 0
           aux_dscritic = "".

    IF par_tpvalida = 1 THEN
	   DO:
	     FOR EACH craptdb WHERE craptdb.cdcooper = par_cdcooper AND
								craptdb.nrborder = par_nrborder 
								NO-LOCK:

	       /* Se este titulo ja esta em um bordero e ele estiver pago, 
			  a ser pago(liberado no bordero ou nao) */ 
		   FIND FIRST b-craptdb WHERE b-craptdb.cdcooper = craptdb.cdcooper  AND
			 					      b-craptdb.cdbandoc = craptdb.cdbandoc  AND
								      b-craptdb.nrdctabb = craptdb.nrdctabb  AND
					 			      b-craptdb.nrcnvcob = craptdb.nrcnvcob  AND
								      b-craptdb.nrdconta = craptdb.nrdconta  AND
								      b-craptdb.nrborder <> craptdb.nrborder AND
								      b-craptdb.nrdocmto = craptdb.nrdocmto  AND
								      b-craptdb.insittit = 0 
								      NO-LOCK NO-ERROR.
								                    
		   IF NOT AVAIL b-craptdb THEN									      
		      FIND FIRST b-craptdb WHERE b-craptdb.cdcooper = craptdb.cdcooper  AND
										 b-craptdb.cdbandoc = craptdb.cdbandoc  AND
										 b-craptdb.nrdctabb = craptdb.nrdctabb  AND
										 b-craptdb.nrcnvcob = craptdb.nrcnvcob  AND
										 b-craptdb.nrdconta = craptdb.nrdconta  AND
										 b-craptdb.nrborder <> craptdb.nrborder AND
										 b-craptdb.nrdocmto = craptdb.nrdocmto  AND
										 b-craptdb.insittit = 2
										 NO-LOCK NO-ERROR.

           IF NOT AVAIL b-craptdb THEN
		      FIND FIRST b-craptdb WHERE b-craptdb.cdcooper = craptdb.cdcooper  AND
				   						 b-craptdb.cdbandoc = craptdb.cdbandoc  AND
										 b-craptdb.nrdctabb = craptdb.nrdctabb  AND
										 b-craptdb.nrcnvcob = craptdb.nrcnvcob  AND
										 b-craptdb.nrdconta = craptdb.nrdconta  AND
										 b-craptdb.nrborder <> craptdb.nrborder AND
										 b-craptdb.nrdocmto = craptdb.nrdocmto  AND
										 b-craptdb.insittit = 4
										 NO-LOCK NO-ERROR.

		   IF AVAIL b-craptdb THEN
		      DO:
			     ASSIGN aux_contador = aux_contador + 1
			 	    	aux_dscritic = "Titulo " + string(b-craptdb.nrdocmto) + " ja incluso no bordero " + 
									   string(b-craptdb.nrborder) + "."
					    aux_flgtrans = FALSE.

			     RUN gera_erro (INPUT par_cdcooper,
				 			    INPUT par_cdagenci,
							    INPUT par_nrdcaixa,
							    INPUT aux_contador,      /** Sequencia **/
							    INPUT aux_cdcritic,
							    INPUT-OUTPUT aux_dscritic). 

		      END.

		 END.

	  END.
	ELSE
	  DO:
	     FOR EACH tt-titulos WHERE tt-titulos.flgstats = 1 NO-LOCK:
            
		   /* Se este titulo ja esta em um bordero e ele estiver pago, 
			  a ser pago(liberado no bordero ou nao) */ 
		   FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper        AND
							        craptdb.cdbandoc = tt-titulos.cdbandoc AND
							        craptdb.nrdctabb = tt-titulos.nrdctabb AND
							        craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
							        craptdb.nrdconta = par_nrdconta        AND
							        craptdb.nrdocmto = tt-titulos.nrdocmto AND
							        craptdb.insittit = 0
							        NO-LOCK NO-ERROR.
			
		   IF NOT AVAIL craptdb THEN				                            
		      FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper        AND
				 			           craptdb.cdbandoc = tt-titulos.cdbandoc AND
							           craptdb.nrdctabb = tt-titulos.nrdctabb AND
							           craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
							           craptdb.nrdconta = par_nrdconta        AND
							           craptdb.nrdocmto = tt-titulos.nrdocmto AND
							           craptdb.insittit = 2
							           NO-LOCK NO-ERROR.

           IF NOT AVAIL craptdb THEN
		      FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper        AND
				  			           craptdb.cdbandoc = tt-titulos.cdbandoc AND
							           craptdb.nrdctabb = tt-titulos.nrdctabb AND
							           craptdb.nrcnvcob = tt-titulos.nrcnvcob AND
							           craptdb.nrdconta = par_nrdconta        AND
							           craptdb.nrdocmto = tt-titulos.nrdocmto AND
							           craptdb.insittit = 4
							           NO-LOCK NO-ERROR.

          IF AVAIL craptdb THEN
		     DO:
			    ASSIGN aux_contador = aux_contador + 1
			           aux_dscritic = "Titulo " + string(craptdb.nrdocmto) + " ja incluso no bordero " + 
					  			      string(craptdb.nrborder) + "."
					   aux_flgtrans = FALSE.

			    RUN gera_erro (INPUT par_cdcooper,
							   INPUT par_cdagenci,
							   INPUT par_nrdcaixa,
							   INPUT aux_contador,      /** Sequencia **/
							   INPUT aux_cdcritic,
							   INPUT-OUTPUT aux_dscritic). 

    END.

		END. /* Final do FOR EACH */

	  END.
    
	IF aux_flgtrans = FALSE THEN
	   RETURN "NOK".
    RETURN "OK".
END PROCEDURE.


/***************************************************************************
    Buscar dados de um limite para manutencao 
***************************************************************************/
PROCEDURE busca_dados_limite_manutencao:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados_dsctit.

    DEF VAR aux_dsoperac AS CHAR   NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND crawlim WHERE (crawlim.cdcooper = par_cdcooper   AND
                        crawlim.nrdconta = par_nrdconta   AND
                        crawlim.tpctrlim = 3              AND
                        crawlim.nrctrmnt = par_nrctrlim   AND
                        crawlim.insitlim = 1 /*em estudo*/ )
                       OR
                       (crawlim.cdcooper = par_cdcooper   AND
                        crawlim.nrdconta = par_nrdconta   AND
                        crawlim.tpctrlim = 3              AND
                        crawlim.nrctrmnt = par_nrctrlim   AND
                        crawlim.insitlim = 5 /*aprovada*/ )
                       OR
                       (crawlim.cdcooper = par_cdcooper   AND
                        crawlim.nrdconta = par_nrdconta   AND
                        crawlim.tpctrlim = 3              AND
                        crawlim.nrctrmnt = par_nrctrlim   AND
                        crawlim.insitlim = 6 /*não aprovada*/ )
                       OR
                       (crawlim.cdcooper = par_cdcooper   AND
                        crawlim.nrdconta = par_nrdconta   AND
                        crawlim.tpctrlim = 3              AND
                        crawlim.nrctrmnt = par_nrctrlim   AND
                        crawlim.insitlim = 8 /*expirada por decurso de prazo*/)
                       OR
                       (crawlim.cdcooper = par_cdcooper   AND
                        crawlim.nrdconta = par_nrdconta   AND
                        crawlim.tpctrlim = 3              AND
                        crawlim.nrctrmnt = par_nrctrlim   AND
                        crawlim.insitlim = 9 /*Anulado - PRJ438 - Paulo Martins - (Mouts)*/)                        
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crawlim  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
            
            IF  crawlim.insitlim = 1  THEN
                ASSIGN aux_dscritic = "Manutenção solicitada não executada. Já existe a proposta " + STRING(crawlim.nrctrlim) +
                                      " com a situação EM ESTUDO".
            ELSE
            IF  crawlim.insitlim = 5  THEN
                ASSIGN aux_dscritic = "Manutenção solicitada não executada. Já existe a proposta " + STRING(crawlim.nrctrlim) +
                                      " com a situação APROVADA".
            ELSE
            IF  crawlim.insitlim = 6  THEN
                ASSIGN aux_dscritic = "Manutenção solicitada não executada. Já existe a proposta " + STRING(crawlim.nrctrlim) +
                                      " com a situação NÃO APROVADA".
            IF  crawlim.insitlim = 8  THEN
                ASSIGN aux_dscritic = "Manutenção solicitada não executada. Já existe a proposta " + STRING(crawlim.nrctrlim) +
                                      " com a situação EXPIRADA DECURSO DE PRAZO".
            IF  crawlim.insitlim = 9  THEN /*PRJ438 - Paulo Martins (Mouts)*/
                ASSIGN aux_dscritic = "Manutenção solicitada não executada. Já existe a proposta " + STRING(crawlim.nrctrlim) +
                                      " com a situação ANULADA".                                      

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
               
           RETURN "NOK".        

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de "  + 
                          "descontos de titulos na conta "                 +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 6, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.
    
    RUN busca_dados_limite(INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "A",
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dsctit_dados_limite,
                            OUTPUT TABLE tt-dados_dsctit).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-dsctit_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de limite nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
    
    
    RETURN "OK".

END PROCEDURE.




/*****************************************************************************
       Realizar a manutençao do contrato                                   
****************************************************************************/
PROCEDURE realizar_manutencao_contrato:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vllimite AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_cddlinha AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.
    
    DEF VAR aux_nrctrlim AS INTE    NO-UNDO.
    
    DEF VAR aux_nrctaav1 AS INTE    NO-UNDO.
    DEF VAR aux_nmdaval1 AS CHAR    NO-UNDO.
    DEF VAR aux_nrcpfav1 AS DECI    NO-UNDO.
    DEF VAR aux_tpdocav1 AS CHAR    NO-UNDO.
    DEF VAR aux_dsdocav1 AS CHAR    NO-UNDO.
    DEF VAR aux_nmdcjav1 AS CHAR    NO-UNDO.
    DEF VAR aux_cpfcjav1 AS DECI    NO-UNDO.
    DEF VAR aux_tdccjav1 AS CHAR    NO-UNDO.
    DEF VAR aux_doccjav1 AS CHAR    NO-UNDO.
    DEF VAR aux_ende1av1 AS CHAR    NO-UNDO.
    DEF VAR aux_ende2av1 AS CHAR    NO-UNDO.
    DEF VAR aux_nrfonav1 AS CHAR    NO-UNDO.
    DEF VAR aux_emailav1 AS CHAR    NO-UNDO.
    DEF VAR aux_nmcidav1 AS CHAR    NO-UNDO.
    DEF VAR aux_cdufava1 AS CHAR    NO-UNDO.
    DEF VAR aux_nrcepav1 AS INTE    NO-UNDO.
    DEF VAR aux_complen1 AS CHAR    NO-UNDO.
    DEF VAR aux_nrender1 AS INTE    NO-UNDO.
    DEF VAR aux_nrcxaps1 AS INTE    NO-UNDO.
    
    DEF VAR aux_nrctaav2 AS INTE    NO-UNDO.
    DEF VAR aux_nmdaval2 AS CHAR    NO-UNDO.
    DEF VAR aux_nrcpfav2 AS DECI    NO-UNDO.
    DEF VAR aux_tpdocav2 AS CHAR    NO-UNDO.
    DEF VAR aux_dsdocav2 AS CHAR    NO-UNDO.
    DEF VAR aux_nmdcjav2 AS CHAR    NO-UNDO.
    DEF VAR aux_cpfcjav2 AS DECI    NO-UNDO.
    DEF VAR aux_tdccjav2 AS CHAR    NO-UNDO.
    DEF VAR aux_doccjav2 AS CHAR    NO-UNDO.
    DEF VAR aux_ende1av2 AS CHAR    NO-UNDO.
    DEF VAR aux_ende2av2 AS CHAR    NO-UNDO.
    DEF VAR aux_nrfonav2 AS CHAR    NO-UNDO.
    DEF VAR aux_emailav2 AS CHAR    NO-UNDO.
    DEF VAR aux_nmcidav2 AS CHAR    NO-UNDO.
    DEF VAR aux_cdufava2 AS CHAR    NO-UNDO.
    DEF VAR aux_nrcepav2 AS INTE    NO-UNDO.
    DEF VAR aux_complen2 AS CHAR    NO-UNDO.
    DEF VAR aux_nrender2 AS INTE    NO-UNDO.
    DEF VAR aux_nrcxaps2 AS INTE    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_dsctit.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_nrctaav1 = 0
           aux_nmdaval1 = ""
           aux_nrcpfav1 = 0
           aux_tpdocav1 = "" 
           aux_dsdocav1 = ""
           aux_nmdcjav1 = ""
           aux_cpfcjav1 = 0
           aux_tdccjav1 = ""
           aux_doccjav1 = ""
           aux_ende1av1 = ""
           aux_ende2av1 = ""
           aux_nrfonav1 = ""
           aux_emailav1 = "" 
           aux_nmcidav1 = ""
           aux_cdufava1 = ""
           aux_nrcepav1 = 0
           aux_nrender1 = 0
           aux_complen1 = ""
           aux_nrcxaps1 = 0
           aux_nrctaav2 = 0
           aux_nmdaval2 = ""
           aux_nrcpfav2 = 0
           aux_tpdocav2 = ""
           aux_dsdocav2 = ""
           aux_nmdcjav2 = ""
           aux_cpfcjav2 = 0
           aux_tdccjav2 = ""
           aux_doccjav2 = ""
           aux_ende1av2 = ""
           aux_ende2av2 = ""
           aux_nrfonav2 = ""
           aux_emailav2 = ""
           aux_nmcidav2 = ""
           aux_cdufava2 = ""
           aux_nrcepav2 = 0
           aux_nrender2 = 0
           aux_complen2 = ""
           aux_nrcxaps2 = 0.
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper   AND
                      crapldc.cddlinha = par_cddlinha   AND
                      crapldc.tpdescto = 3              AND
                      crapldc.flgstlcr = TRUE /*ATIVA*/
                      NO-LOCK NO-ERROR.
   
    IF NOT AVAILABLE crapldc THEN
      DO:
          ASSIGN aux_cdcritic = 0
                 aux_dscritic = "Linha de desconto nao cadastrada ou bloqueada.".
                 
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".
          
      END.

    RUN busca_dados_limite_consulta(
                            INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dsctit_dados_limite,
                            OUTPUT TABLE tt-dados-avais,
                            OUTPUT TABLE tt-dados_dsctit).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel consultar dados do limite.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

        
          RETURN "NOK".

       END.
    ELSE
      DO:
        FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.

            IF  AVAIL tt-dados-avais  THEN
                ASSIGN  aux_nrctaav1 = tt-dados-avais.nrctaava
                        aux_nmdaval1 = tt-dados-avais.nmdavali
                        aux_nrcpfav1 = tt-dados-avais.nrcpfcgc
                        aux_tpdocav1 = tt-dados-avais.tpdocava
                        aux_dsdocav1 = tt-dados-avais.nrdocava
                        aux_nmdcjav1 = tt-dados-avais.nmconjug
                        aux_cpfcjav1 = tt-dados-avais.nrcpfcjg
                        aux_tdccjav1 = tt-dados-avais.tpdoccjg
                        aux_doccjav1 = tt-dados-avais.nrdoccjg
                        aux_ende1av1 = tt-dados-avais.dsendre1
                        aux_ende2av1 = tt-dados-avais.dsendre2
                        aux_nrfonav1 = tt-dados-avais.nrfonres
                        aux_emailav1 = tt-dados-avais.dsdemail
                        aux_nmcidav1 = tt-dados-avais.nmcidade
                        aux_cdufava1 = tt-dados-avais.cdufresd
                        aux_nrcepav1 = tt-dados-avais.nrcepend
                        aux_complen1 = tt-dados-avais.complend 
                        aux_nrender1 = tt-dados-avais.nrendere 
                        aux_nrcxaps1 = tt-dados-avais.nrcxapst.
            
            FIND NEXT tt-dados-avais NO-LOCK NO-ERROR.

            IF   AVAIL tt-dados-avais  THEN
                 ASSIGN aux_nrctaav2 = tt-dados-avais.nrctaava
                        aux_nmdaval2 = tt-dados-avais.nmdavali
                        aux_nrcpfav2 = tt-dados-avais.nrcpfcgc
                        aux_tpdocav2 = tt-dados-avais.tpdocava
                        aux_dsdocav2 = tt-dados-avais.nrdocava
                        aux_nmdcjav2 = tt-dados-avais.nmconjug
                        aux_cpfcjav2 = tt-dados-avais.nrcpfcjg
                        aux_tdccjav2 = tt-dados-avais.tpdoccjg
                        aux_doccjav2 = tt-dados-avais.nrdoccjg
                        aux_ende1av2 = tt-dados-avais.dsendre1
                        aux_ende2av2 = tt-dados-avais.dsendre2
                        aux_nrfonav2 = tt-dados-avais.nrfonres
                        aux_emailav2 = tt-dados-avais.dsdemail
                        aux_nmcidav2 = tt-dados-avais.nmcidade
                        aux_cdufava2 = tt-dados-avais.cdufresd
                        aux_nrcepav2 = tt-dados-avais.nrcepend
                        aux_complen2 = tt-dados-avais.complend 
                        aux_nrender2 = tt-dados-avais.nrendere 
                        aux_nrcxaps2 = tt-dados-avais.nrcxapst.
      END.
      
    
    RUN efetua_inclusao_limite(
                   INPUT par_cdcooper,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT par_nrdconta,
                   INPUT par_nmdatela,
                   INPUT par_idorigem,
                   INPUT par_idseqttl,
                   INPUT par_dtmvtolt,
                   INPUT par_cdoperad,
                   INPUT par_vllimite,
                   INPUT tt-dsctit_dados_limite.dsramati,
                   INPUT tt-dsctit_dados_limite.vlmedtit,
                   INPUT tt-dsctit_dados_limite.vlfatura,
                   INPUT tt-dsctit_dados_limite.vloutras,
                   INPUT tt-dsctit_dados_limite.vlsalari,
                   INPUT tt-dsctit_dados_limite.vlsalcon,
                   INPUT tt-dsctit_dados_limite.dsdbens1,
                   INPUT tt-dsctit_dados_limite.dsdbens2,
                   INPUT par_cddlinha,
                   INPUT tt-dsctit_dados_limite.dsobserv,   
                   INPUT tt-dsctit_dados_limite.qtdiavig, 
                   INPUT FALSE,
                   INPUT aux_nrctaav1,
                   INPUT aux_nmdaval1,
                   INPUT aux_nrcpfav1,
                   INPUT aux_tpdocav1,
                   INPUT aux_dsdocav1,
                   INPUT aux_nmdcjav1,
                   INPUT aux_cpfcjav1,
                   INPUT aux_tdccjav1,
                   INPUT aux_doccjav1,
                   INPUT aux_ende1av1,
                   INPUT aux_ende2av1,
                   INPUT aux_nrfonav1,
                   INPUT aux_emailav1,
                   INPUT aux_nmcidav1,
                   INPUT aux_cdufava1,
                   INPUT aux_nrcepav1,
                   INPUT aux_nrender1,
                   INPUT aux_complen1,
                   INPUT aux_nrcxaps1,
                   INPUT aux_nrctaav2,
                   INPUT aux_nmdaval2,
                   INPUT aux_nrcpfav2,
                   INPUT aux_tpdocav2,
                   INPUT aux_dsdocav2,
                   INPUT aux_nmdcjav2,
                   INPUT aux_cpfcjav2,
                   INPUT aux_tdccjav2,
                   INPUT aux_doccjav2,
                   INPUT aux_ende1av2,
                   INPUT aux_ende2av2,
                   INPUT aux_nrfonav2,
                   INPUT aux_emailav2,
                   INPUT aux_nmcidav2,
                   INPUT aux_cdufava2,
                   INPUT aux_nrcepav2,
                   INPUT aux_nrender2,
                   INPUT aux_complen2,
                   INPUT aux_nrcxaps2,
                   INPUT tt-dsctit_dados_limite.nrgarope,
                   INPUT tt-dsctit_dados_limite.nrinfcad,
                   INPUT tt-dsctit_dados_limite.nrliquid,
                   INPUT tt-dsctit_dados_limite.nrpatlvr,
                   INPUT tt-dsctit_dados_limite.nrperger,
                   INPUT tt-dsctit_dados_limite.vltotsfn,
                   INPUT tt-dsctit_dados_limite.perfatcl,
                   INPUT tt-dsctit_dados_limite.nrctrlim,
				   INPUT tt-dsctit_dados_limite.idcobope,
                   OUTPUT aux_nrctrlim,                                   
                   OUTPUT TABLE tt-erro,
                   OUTPUT TABLE tt-msg-confirma).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel efetuar inclusao da proposta.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.
   
    IF par_vllimite <= tt-dsctit_dados_limite.vllimite THEN
       DO:
          
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          RUN STORED-PROCEDURE pc_efetivar_proposta
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                  ,INPUT par_nrdconta
                                                  ,INPUT aux_nrctrlim
                                                  ,INPUT 3
                                                  ,INPUT par_cdoperad
                                                  ,INPUT par_cdagenci
                                                  ,INPUT par_nrdcaixa
                                                  ,INPUT par_idorigem
                                                  ,INPUT 3
                                                  ,OUTPUT 0
                                                  ,OUTPUT "").
          
          CLOSE STORED-PROC pc_efetivar_proposta
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
          ASSIGN aux_cdcritic  = INT(pc_efetivar_proposta.pr_cdcritic) WHEN pc_efetivar_proposta.pr_cdcritic <> ?
                 aux_dscritic  = pc_efetivar_proposta.pr_dscritic WHEN pc_efetivar_proposta.pr_dscritic <> ?.
          
          IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
             DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
           END.
           
      END.
   RETURN "OK".       

END PROCEDURE.

/***************************************************************************
    Buscar dados de uma proposta para alteração da manutencao/majoração
***************************************************************************/
PROCEDURE busca_dados_proposta_manuten:
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dsctit_dados_limite.
    DEF OUTPUT PARAM TABLE FOR tt-dados_dsctit.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dsctit_dados_limite.
    EMPTY TEMP-TABLE tt-dados_dsctit.

    DEF VAR aux_dsoperac AS CHAR   NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
               
           RETURN "NOK".        

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de "  + 
                          "descontos de titulos na conta "                 +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 6, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.
    
    RUN busca_dados_proposta(INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "A",
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dsctit_dados_limite,
                            OUTPUT TABLE tt-dados_dsctit).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-dsctit_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dsctit_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de limite nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
                Busca o valor do IOF para simples nacional                    
*****************************************************************************/
PROCEDURE buscar_valor_iof_simples_nacional:
    DEF INPUT PARAM par_vlborder AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-iof.
    DEF INPUT PARAM TABLE FOR tt-iof-sn.
    DEF OUTPUT PARAM aux_vltotaliofsn AS DECI NO-UNDO.
    /* Projeto 410 - RF 43 a 46:
     - Se o valor do borderô for maior que 30K, usa a seguinte regra:
        -> Para pessoa jurídica, taxa do IOF para simples nacional = 0.0041
        -> Para pessoa física, taxa do IOF para simples nacional = 0.0082
     - Se o valor do borderô for até 30K (inclusive), busca a taxa que estiver 
       cadastrada. */
    IF par_vlborder <= 30000 THEN
      DO:
        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                           crapjur.nrdconta = par_nrdconta       
                           NO-LOCK NO-ERROR.
        IF AVAILABLE crapjur AND (crapjur.idimpdsn = 1 OR crapjur.idimpdsn = 2) THEN
          DO:
            /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
            ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
            ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * tt-iof-sn.txccdiof, 2).
          END.
        ELSE
          DO:
            ASSIGN aux_vltotaliofsn = 0.
          END.
        RELEASE crapjur.
      END.
    ELSE
      DO:
        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta       
                           NO-LOCK NO-ERROR.
        IF AVAILABLE crapass THEN
          DO:
            IF crapass.inpessoa = 1 THEN /* Pessoa física */
              DO:                
                /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
                ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
                ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * const_txiofpf, 2).
              END.
            ELSE  /* Pessoa jurídica */
              DO:
                /* Verifica se o associado é cooperativa. Se for, taxa iof simples nacional deve ser zero */
                FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                   crapjur.nrdconta = par_nrdconta       
                                   NO-LOCK NO-ERROR.
                IF AVAILABLE crapjur AND (crapjur.natjurid = 2143) THEN /* 2143 = Coopertativa */
                  DO:
                    ASSIGN aux_vltotaliofsn = 0.
                  END.
                ELSE
                  DO:
                    /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
                    ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
                    ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * const_txiofpj, 2).
                  END.
                RELEASE crapjur.
              END.
          END.
        ELSE
          ASSIGN aux_vltotaliofsn = 0.
        RELEASE crapass.        
      END.

    RETURN "OK".
END PROCEDURE.

/* .......................................................................... */



