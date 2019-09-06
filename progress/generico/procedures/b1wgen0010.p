/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                    |
  +---------------------------------+----------------------------------------+
  | procedures/b1wgen0010.p           | COBR0001                             |
  | pega_valor_tarifas                | pc_pega_valor_tarifas                |
  | gera_retorno_arq_cobranca_coopcob | pc_gera_retorno_arq_cob_coop         |
  | gera_retorno_arq_cobranca         | COBR0001.pc_gera_retorno_arq_cobranca|
  | p_gera_arquivo_febraban           | COBR0001.pc_gera_arquivo_febraban    |
  | p_gera_arquivo_outros             | COBR0001.pc_gera_arquivo_outros      | 
  | valida-arquivo-cobranca           | COBR0006.pc_valida_arquivo_cobranca  |
  | identifica-arq-cnab               | COBR0006.pc_identifica_arq_cnab      |
  | p_importa                         | COBR0006.pc_importa                  |
  | p_importa_cnab240_085             | COBR0006.pc_importa_cnab240_085      |
  | p_importa_cnab400_085             | COBR0006.pc_importa_cnab400_085      |  
  +---------------------------------+----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/










/* .............................................................................

   Programa: b1wgen0010.p                  
   Autora  : Ze Eduardo
   
   Data    : 12/09/2005                     Ultima atualizacao: 08/05/2019

   Dados referentes ao programa:

   Objetivo  : BO CONSULTA BLOQUETOS DE COBRANCA

   Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).
                            
               10/08/2006 - Alterado parametro "p-ini-documento" de INTEGER 
                            para DECIMEAL (Julio)

               16/10/2006 - Alterado estrutura da BO (David).

               04/12/2006 - Desabilitado calculo do digito verificador do nosso
                            numero. Alterada tabela crapttl para crapass na
                            gravacao da procedure proc_nosso_numero (David).
                            
               22/12/2006 - Buscar dados do sacado na tabela crapsab (David).
               
               19/03/2007 - Acerto ao obter convenio CECRED - nrcnvceb (David).
               
               20/03/2007 - Permitir pesquisa pelo nome do sacado, e por nr.
                            do documento - INTERNET (David).

               20/04/2007 - Efetuar retorno do campo "Complemento" na
                            temp-table (David).

               23/07/2007 - Tratamento para strings que contenham o caracter
                            especial "&" (David).

               11/03/2008 - Implementacao da rotina gera_retorno_arq_cobranca
                            com base no programa crps464 (Sidnei - Precise).
                          - Utilizar include para temp-tables (David).  

               02/04/2008 - Incluido na leitura do crapcob da rotina
                            gera_retorno_arq_cobranca a possiblidade de ler
                            registro com numero de convenio zerado (Elton).

               19/04/2008 - Limpar temp-table tt-arq-cobranca ao enviar arquivo
                            quando origem for AYLLOS (David).

               09/05/2008 - Retornar nome do titular nos boletos consultados
                            (David).

               25/07/2008 - Retornar situacao do boleto qndo nao for internet
                            (David).

               11/09/2008 - Corrigir forma para gravacao da quantidade de
                            registros encontrados na consulta efetuada pela
                            internet - campo tt-consulta-blt.nrregist (David).

               05/02/2009 - Incluir gera_retorno_arq_cobranca_viacredi. 
                            Procedure temporaria e especifica para somente 
                            um numero de convenio para a Viacredi. Utilizada
                            para atender o Software Alpes - Adilson (Ze).

               19/02/2009 - Melhorias no servico de cobranca (David).

               28/05/2009 - Carregar numero de variacao de carteira do convenio
                            para os boletos (David).

               01/06/2009 - Inclusao de procedures para validacao de arquivo  
                            de cobranca, anteriormente implementada no programa
                            valcob ( Sidnei - Precise ).

               31/07/2009 - Efetuado acerto na critica ref. Numero de inscricao
                            (Diego).

               10/06/2010 - Tratamento para pagamento realizado atraves de TAA
                            (Elton).

               22/07/2010 - Incluido parametro p-flgdpagto na procedure
                            gera_retorno_arq_cobranca_viacredi  (Elton).

               31/08/2010 - Incluido caminho completo nos arquivos gravados 
                            no diretorio "arq" (Elton).

               16/09/2010 - Alteracao dos parametros da procedure
                            gera_retorno_arq_cobranca_coopcob e alteracao da 
                            logica para processar apenas convenios com
                            indicador CoopCob TRUE (Guilherme/Supero).

               15/02/2011 - Critica para verificar a existencia do registro
                            do crapceb (Gabriel).

               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                           (Gabriel).

               12/05/2011 - Tratamento para incobran 0,3,4,5 (Guilherme).

               26/05/2011 - Novos relatorios 5 e 6 (Guilherme/Supero).
               
               27/05/2011 - Adicionado campos nrinsava e cdtpinav para a 
                            tt-consulta-blt (Jorge).
                            
               21/06/2011 - Alterado gera_retorno_arq_cobranca
                            incluido parametro para filtrar cob sem reg.
                            (Rafael)
                            
               24/06/2011 - replace de caracter especial em p_grava_boleto
                            tt-consulta-blt (Jorge).
                            
               08/07/2011 - Adicionado condicional em consulta-bloqueto (Jorge).
               
               13/07/2011 - Gravado crapret.dtocorre no campo 
                            tt-consulta-blt.dtocorre na procedure 
                            consulta-bloqueto (Adriano).
                            
               20/07/2011 - Adicionado em procedure consulta-bloqueto, quando 
                            p-consultar = 14, busca de descricao do motivo
                            Adicionado parametros de Motivo (Jorge).
                            
               22/07/2011 - Alteracao no tipo p-consultar = 14 para alimentar
                            os campos vloutdes, vloutcre (Adriano).
                            
               04/08/2011 - Alterado procedure proc_nosso_numero, adicionado 
                            condicoes 5 e 6 e 7 (Jorge).
                            
               25/08/2011 - Criado procedure retorna-convenios-remessa (Jorge).
               
               05/09/2011 - Tratamento na geracao do arq. CoopCob (Ze).
               
               06/09/2011 - Adicionado campo nrlinseq (Jorge).
               
               14/09/2011 - Criado procedure consulta-boleto-2via (Jorge)
               
               06/10/2011 - Removido o filtro por crapceb.insitceb = 1 no
                            FIND LAST da crapceb, para as procedures
                            p_grava_bloqueto e proc_nosso_numero. Na procedure
                            consulta-bloqueto, filtrado no tipo de consulta 7,
                            pelo parametro da conta(p-nro-conta). (Fabricio)
                            
               25/10/2011 - Tratamento de juros/multa/descto na rotina 
                            p_grava_bloqueto (Fabricio).
                            
               12/12/2011 - Adicionado nr do imovel no endereco do sacado
                            proc p_grava_bloqueto (Rafael).
                            
               12/03/2012 - Alterado rotina de geracao de arquivo de retorno
                            ao cooperado pois estava provocando erro na cadeia.
                            Tarefa 45747. (Rafael)
                            
               23/04/2012 - Quando consulta 6 utilizar conta/dv do cooperado
                            para localizar os titulos do sacado. (Rafael)
                            
               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).
                            
               13/08/2012 - Ajuste na tt-consulta-blt ref aos titulos da cob.
                            registrada descontados. (Rafael)
                          - Adicionado campo de tipo de cobranca na rotina
                            de exportar titulos. (Rafael)
                            
               27/08/2012 - Tratamento para Dt. de Venct. não informada
                            (conv. pré-impresso) (Lucas).
                            
               03/10/2012 - Ajuste na consulta de titulos ref a titulos pagos
                            com cheque (crapcob.dcmc7chq) (Rafael).
                            
               15/10/2012 - Ajustes de performance em consulta-bloqueto. 
                            (Rafael/Jorge)
                            
               07/01/2013 - Ler todos os convenios de Internet na procedure
                            gera_totais_cobranca (David)           
                            
               22/01/2013 - Ajuste na rotina de geracao de arquivo CoopCob
                            ref. aos titulos migrados Alto Vale. (Rafael)
                          - Ajuste em campo tt-consulta-blt.nrnosnum da proc.
                            proc_nosso_numero. (Jorge/Rafael)
                            
               19/02/2013 - Ajuste nossonumero ref. ao CEB 5 digitos (Rafael).
               
               08/03/2013 - Ajuste em gerar arquivo de retorno, data de credito
                            ajustada para pegar D + 1 ao invez de D + 0 quando
                            em condicao especial para boletos Banco do Brasil em
                            proc. p_gera_arquivo_febraban. (Jorge)
                            
               11/04/2013 - Retirado condicao para nao imprimir boletos DDA em 
                            proc. consulta-boleto-2via (Jorge).             
                            
               25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB240 - 085. (Rafael)
                            
               03/05/2013 - Projeto Melhorias da Cobranca - implementar 
                            instrucoes 7, 8 e 31 referentes a
                            "Conceder Desconto", "Cancelar Desconto" e 
                            "Alterar Dados do Sacado" em proc. grava_instrucoes
                            (Jorge)
                            
               31/05/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB400 - 085. 
                            (Anderson/AMCOM, Rafael)
               
               25/06/2013 - Buscar valores das tarifas da b1wgen00153 (Tiago). 
               
               15/07/2013 - Buscar primeiro titular como cedente do boleto qdo
                            cooperado for PF. (Rafael)
                            
               28/08/2013 - Incluso chamada para a procedure efetua-lancamento-tarifas-lat 
                            da b1wgen0090, incluso parametro tt-lat-consolidada nas chamadas
                            das procedures de instrucao "inst-" (Daniel) 
                            
               12/09/2013 - Ajuste no campo tt-consulta-blt.dtdocmto. (Rafael)
               
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               21/10/2013 - Incluido novo parametro nas procedures de 
                            instrucoes da b1wgen0088 ref. ao numero do arquivo
                            remessa. (Rafael).
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               13/12/2013 - Melhoria nas leituras efetuadas na tabela CRAPCOB (Daniel).        
               
               
               06/01/2014 - Ajuste leituras tabela crapcob na procedure consulta-bloqueto
                            (Daniel).      
                            
               10/12/2014 - Ajuste relatorio por cooperado sem registro (Daniel). 
               
               04/04/2014 - Ajuste para evitar busca de tarifa incorreta (Daniel).             
               
               09/05/2014 - Mostrar convenios de cobrança "IMPRESSO PELO SOFTWARE"
                            no InternetBanking apenas se o cooperado estiver
                            habilitado. (Rafael)
                            
               29/08/2014 - Float: Adição do campo dtcredit na temp-table
                            tt-consulta-blt. (Vanessa)
                            
               07/10/2014 - Remover crapcco.flgativo dos for each's (Rafael)
               
               01/12/2014 - Ajuste na geracao da 2a via de boleto ref. a
                            Incorporacao (Rafael).
               
               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).
               
               17/12/2014 - Ajustes nas rotinas abaixo devido a incorporaçao                            
                            - gera_retorno_arq_cobranca_coopcob
                            - p_gera_arquivo_febraban           
                            - p_gera_arquivo_outros             
                            (SD 234123 Odirlei-AMcom)                 
                            
               14/01/2015 - Ajustes para geração do 4-relatorio cedente,
                            montagem do relatorio de titulo descontados
                            (Odirlei-AMcom)
                            
               27/02/2015 - Ajustes para carregar as informações do email 
                            do pagador da crapsab. 
                            (Projeto Boleto por email - Douglas)
               
               17/03/2015 - Ajuste feito na procedure consulta-boleto-2via onde 
                            é feita a chamada da procedure verifica-vencimento-titulo            
                            em que foi mudado a passagem de parametro de "TODAY"
                            para crapdat.dtmvtocd SD - 134773 (Kelvin)
                            
               28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                            (Daniel/Rafael/Reinert) 
                            
               04/05/2015 - Adicionar validação para não emitir segunda via de boleto
                            quando o campo crapcob.dsinform possuir "LIQAPOSBX"
                            (Douglas - Chamado 273377)

               11/06/2015 - Ajustes para verificar se o boleto pertence a um
                            carne. (Projeto Boleto formato Carne - Douglas)
                            
               03/08/2015 - Alterado a rotina proc_nosso_numero para quando for titulo
                            migrado utilizar o nosso numero da propria CRAPCOB SD308717 
                            (Odirlei-AMcom)
                            
               18/08/2015 - Nao eh permitido gerar 2via de boleto do convenio 
                            EMPRESTIMO - Projeto 210. (Rafael)
               
               25/08/2015 - Alterado rotina consulta-boleto-2via para não 
                            atribuir valor de desconto caso o tipo de mensagem for zero
                            e o titulo ja esteja vencido SD323492 (Odirlei-AMcom)  
                            
               07/10/2015 - Ajuste na rotina proc_nosso_numero para caso exista a informacao no 
                            campo nrnosnum na crapcob, utilizar este nao sendo necessario montar essa
                            informacao SD339759 (Odirlei-AMcom)
                            
               17/11/2015 - Adicionado parametro de entrada p-inestcri em proc.
                            consulta-bloqueto. para consultas 1,2,3,4,5,6 e 8.
                            (Jorge/Andrino)             
                            
               09/12/2015 - Ajustado a procedure gera_relatorio, incluso novo parametro
                            inserasa. (Daniel/Andrino)           

               15/02/2016 - Inclusao do parametro conta na chamada da
                            carrega_dados_tarifa_cobranca. (Jaison/Marcos)

               25/02/2016 - Ajuste na rotina consulta-bloqueto  para considerar
                            a data de ocorrencia no relacionamento entre as tabelas
                            crapret/craprtc
                            (Adriano - SD 391157)

               08/03/2016 - Conversao da rotinas abaixo para PL SQL:
                          - valida-arquivo-cobranca   
                          - identifica-arq-cnab       
                          - p_importa                 
                          - p_importa_cnab240_085     
                          - p_importa_cnab400_085     
                          - f_EhData 
                          - f_numericos
                          (Andrei - RKAM).

               10/05/2016 - Ajustar a proc. consulta-bloqueto para filtrar o parametro
                            numero da conta nas consultas 2,3,4,5,6 
                            (Douglas - Chamado 441759)

               19/05/2016 - Ajustar a query da consulta-bloqueto na pesquisa
                            por sacado (Douglas - Chamado 454790)

               29/06/2016 - Adicionado ROUND para o calculo de Multa e Juros da 
                            consulta-boleto-2via para que arredonde os valores
                            (Douglas - Chamado 457956)
                            
               04/08/2016 - Alterado procedure gera_relatorio para permitir 
                            enviar relatorio de movimento de cobranca por 
                            e-mail. (Reinert)

               03/10/2016 - Ajustes referente a melhoria M271. (Kelvin)
               
               06/10/2016 - Ajuste consulta-boleto-2via para contemplar a origem de 
                            "ACORDO" e nao permitir gerar a segunda via do boleto,
                            Prj. 302 (Jean Michel).

               11/10/2016 - Inclusao dos campos de aviso por SMS. 
                            PRJ319 - SMS Cobrança.  (Odirlei-AMcom)

               24/11/2016 - A busca de conta transferida/migrada nao estava sendo
                            feita corretamente na consulta de 2via de boleto.
                            Nao estava considerando a conta retornada na pesquisa
                            da craptco ao buscar na crapass.
                            Heitor (Mouts) - Chamado 554866

               25/11/2016 - Correção no calculo de multa e juros da Melhoria 271
                            (Douglas Quisinski - Chamado 562804)
							
               02/12/2016 - Ajuste realizado para nao gerar em branco o relatorio		
                            da tela COBRAN, incluido tambem logs para identificar
                            erros futuros dessa mesma rotina, conforme solicitado
                            no chamado 563327. (Kelvin)
                      
               12/12/2016 - Correcao do relatorio da tela cobran que estavam sendo
                            gerado em branco, onde no chamado 563327 incluimos logs
                            para que futuramente podessemos identifcar o problema (Kelvin)	
							
               23/12/2016 - Realizado ajustes na rotina consulta-bloqueto e consulta-boleto-2via
                            para aumentar o desempenho na tela de manutencao do internet bank,
                            conforme solicitado no chamado 573538 (Kelvin).

               02/01/2017 - Melhorias referentes a performance no IB na parte
                            de cobrança rotinas consulta-bloqueto e 
                            consulta-boleto-2via (Tiago/Ademir SD573538).  
         
               02/01/2017 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Ricardo Linhares)                           
         
               06/01/2017 - Incluida atribuicao do campo flgdprot na rotina cria_tt-consulta-blt
                            Heitor (Mouts) - Chamado 574161

               13/01/2017 - Retirado create da tt-consulta-blt na procedure consulta-boleto-2via
                            pois ja estava criando no procedure proc_nosso_num
                            (Tiago/Ademir SD593608)
                            
               11/10/2016 - Inclusao dos campos de aviso por SMS. 
                            PRJ319 - SMS Cobrança.  (Odirlei-AMcom)

               07/02/2017 - Alterei a proc. consulta-bloqueto opcao 14 - Relatorio Francesa, obrigando
                            informar a conta para filtro sobre a craprtc. SD 560911 (Carlos Rafael Tanholi)
                            
               30/03/2017 - Adicionado o parametro par_idseqttl na procedure  busca-nome-imp-blt
                            e ajustado as procedures que a utilizam (Douglas - Chamado 637660)
                            
               20/04/2017 - Ajuste nas consultas de boleto referente ao 
                            Projeto 340 - NPC (Rafael).                           

               11/07/2017 - Ajuste nas consultas de boleto referente a
                            consulta de rollout, Prj. 340 - NPC (Jean Michel). 

               21/07/2017 - Ajustes para nao exibr valor cobrado
                            na segunda via de boleto a vencer.
                            PRJ340-NPC(Odirlei-AMcom)

               02/08/2017 - Ajuste na data de vencimento na emissao de segunda
                            via de boleto 085. (Rafael)
              
               22/09/2017 - Ajuste na proc_nosso_numero e na cria_tt-consulta-blt
                            para carregar os dados de Protesto e Serasa do boleto
                            e caso estejam zeradas atualizar com os dados do 
                            convenio (Douglas - Chamado 754911)

               26/10/2017 - Na impressao da segunda via a data de vencimento de um
			                titulo registrado na CIP deve ser atualizado no campo
							data de vencimento, mas o fator de vencimento deve ser mantido
							original no codigo de barras. (SD762954 - AJFink)

               31/10/2017 - Quando o titulo nao estiver registrado na cip, mesmo que
			                esteja dentro da faixa de rollout a segunda via deve ser emitida
							com data de vencimento e valor atualizados tanto nos campos
							quanto no codigo de barras. (SD784234 - AJFink)
							
               03/11/2017 - Ajuste na consulta-bloqueto: validacao do preenchimento 
                            do periodo de emissao ("1 - Em Aberto") (Carlos)

               07/12/2017 - Carregar o valor dos campos dtvctori, dtvencto, dtmvtatu e flgvenci
                            (Douglas - Chamado 805008)

               20/12/2017 - Ajuste na consulta-bloqueto: validacao do preenchimento 
                            do periodo, sem essa validacao esta sendo feito um loop
                            entre duas datas vazias, com isso o loop nao para de 
                            executar (Douglas - Chamado 807531)

               04/01/2018 - Ajuste na verifica-rollout para utilizar a procedure pc_verifica_rollout,
                            ao invés de executar "SELECT NPCB0001.fn_verifica_rollout FROM DUAL", pois
                            a execucao dessa funcao atraves de SELECT deixa o cursor aberto na sessao
                            do Oracle (Douglas - Chamado 824704)

               31/01/2018 - Realizado ajustes devido ao projeto do novo IB (PRJ285 - Rafael).

			   16/05/2018 - Ajuste para que o Internet Banking apresente na Tela: Cobrancas Bancarias >>
			                Manutencao, registros que possuam o campo cdmensag com o valor nulo.
			                Chamado INC0011898 - Gabriel (Mouts).

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
               08/06/2018 - Cobranças com campo "dtvctori" nulo não eram apresentados no Internet Banking
                            na Tela: Cobrancas Bancarias >> Manutencao. Logica alterada para verificar
                            o campo, caso ele seja nulo, utilizar dtvencto, se não utilizar o proprio campo.
                            Chamado INC0016935 - Gabriel (Mouts).

               16/06/2018 - Ajuste na situacao do boleto quando Protestado "P" 
                          - Popular dados do beneficiario na temp-table tt-consulta-blt (Carta de Anuencia)
                          - (PRJ352 - Rafael).

               16/08/2018 - Retirado mensagem de serviço de protesto pelo BB (PRJ352 - Rafael)

               08/08/2018 - Adicionado para não permitir geração de segunda via de boletos de Desconto de Título (Luis Fernando - GFT)

               15/10/2018 - Carregar o valor do campo INSITCRT na tt-consulta-blt (Douglas - Prj 285)
               
               30/11/2018 - Na procedure calcula_multa_juros_boleto alterar o ROUND por TRUNCATE 
                            (Lucas Ranghetti INC0027138)
               
			   06/03/2019 - Adicionado condicao para apresentar o status do titulo corretamente na COBRAN (Cassia de Oliveira - GFT)

               08/05/2019 - inc0012536 adicionada a validação do código da espécie 2 (duplicata de serviço) juntamente com a UF 
                            não autorizada. Duplicatas de serviço dos estados listados não podem ir para protesto (Carlos)

               22/08/2019 - INC0020897 Tratamento para os campos nulos (convertidos para espaço vazio) do sacado na exibição dos boletos.

........................................................................... */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.
DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR aux_dsorgarq AS CHAR NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR NO-UNDO.
DEF VAR aux_nrregist AS INTE NO-UNDO.               
DEF VAR aux_iniseque AS INTE NO-UNDO.
DEF VAR aux_fimseque AS INTE NO-UNDO.

DEF NEW SHARED VAR glb_nrcalcul AS DECIMAL                       NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGICAL                       NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                     NO-UNDO.
DEF VAR aux_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR aux_contador AS INTE                                     NO-UNDO.
DEF VAR aux_nmfisico AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                     NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                     NO-UNDO.
DEF VAR aux_seqarqui AS INTE                                     NO-UNDO.
DEF VAR h_b1wgen0011 AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0153 AS HANDLE                                   NO-UNDO.
DEF VAR aux_dsindpgt AS CHAR                                     NO-UNDO.
DEF VAR h-b1wgen0010i AS HANDLE                                  NO-UNDO.
DEF VAR aux_nrregis1 AS INTE                                     NO-UNDO.
DEF VAR aux_qtregist AS INTE                                     NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                     NO-UNDO.

/* Geracao de boletos */
DEF VAR aux_cdbancbb AS INTE                                     NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                     NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                     NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                     NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                     NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                     NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                     NO-UNDO.
DEF VAR aux_flgutceb AS LOGI                                     NO-UNDO.
DEF VAR aux_dsnosnum AS CHAR                                     NO-UNDO.
DEF VAR aux_cdcartei AS INTE                                     NO-UNDO.
DEF VAR aux_cddespec AS INTE                                     NO-UNDO.
DEF VAR aux_vltitulo AS DECI                                     NO-UNDO.
DEF VAR aux_vldescto AS DECI                                     NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                     NO-UNDO.
DEF VAR aux_nrbloque AS DECI                                     NO-UNDO.
DEF VAR aux_dtemscob AS DATE                                     NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                     NO-UNDO.
DEF VAR aux_cdtpinsc AS INTE                                     NO-UNDO.
DEF VAR aux_nrinssac AS DECI                                     NO-UNDO.
DEF VAR aux_nmdsacad AS CHAR                                     NO-UNDO.
DEF VAR aux_dsendsac AS CHAR                                     NO-UNDO.
DEF VAR aux_nmbaisac AS CHAR                                     NO-UNDO.
DEF VAR aux_nrcepsac AS INTE                                     NO-UNDO.
DEF VAR aux_nmcidsac AS CHAR                                     NO-UNDO.
DEF VAR aux_cdufsaca AS CHAR                                     NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                     NO-UNDO.
DEF VAR aux_nrinsava AS DECI                                     NO-UNDO.
DEF VAR aux_cdtpinav AS INTE                                     NO-UNDO.
DEF VAR aux_dsdinstr AS CHAR                                     NO-UNDO.
DEF VAR aux_dsdoccop LIKE crapcob.dsdoccop                       NO-UNDO.
DEF VAR h_b1crapcob  AS HANDLE                                   NO-UNDO.
DEF VAR h_b1crapsab  AS HANDLE                                   NO-UNDO.

DEF VAR tar_cdhistor AS INTE                                     NO-UNDO.
DEF VAR tar_cdhisest AS INTE                                     NO-UNDO.
DEF VAR tar_dtdivulg AS DATE                                     NO-UNDO.
DEF VAR tar_dtvigenc AS DATE                                     NO-UNDO.
DEF VAR tar_cdfvlcop AS INTE                                     NO-UNDO.

DEF VAR tar_vlrtarcx AS DECI                                     NO-UNDO.
DEF VAR tar_vlrtarnt AS DECI                                     NO-UNDO.
DEF VAR tar_vltrftaa AS DECI                                     NO-UNDO.
DEF VAR tar_vlrtarif AS DECI                                     NO-UNDO.

DEF VAR aux_inpessoa AS INTE                                     NO-UNDO.

DEF VAR aux_nrvarcar AS INTE                                     NO-UNDO.

DEF VAR aux_proximo  AS CHAR                                     NO-UNDO.                


/* motivos */
DEF VAR aux_cdmotivo AS CHAR                                     NO-UNDO.
DEF VAR aux_cdposini AS INTE   INIT 1                            NO-UNDO.
DEF VAR aux_dsmotivo AS CHAR                                     NO-UNDO.
DEF VAR aux_cdnrmoti AS INTE   INIT 0                            NO-UNDO.

/* auxs para controle de sacado nao cadastrado (na = not avail) */
DEF VAR aux_na_nmdsacad AS CHAR                                     NO-UNDO.
DEF VAR aux_na_dsendsac AS CHAR                                     NO-UNDO.
DEF VAR aux_na_complend AS CHAR                                     NO-UNDO.
DEF VAR aux_na_nmbaisac AS CHAR                                     NO-UNDO.
DEF VAR aux_na_nmcidsac AS CHAR                                     NO-UNDO.
DEF VAR aux_na_cdufsaca AS CHAR                                     NO-UNDO.
DEF VAR aux_na_nrcepsac AS INTE                                     NO-UNDO.

/* Variaveis necessarias na gera_retorno_arq_cobranca */
DEF STREAM str_1.   /*  Para arquivo de trabalho */
DEF STREAM str_2.
DEF STREAM str_3.

DEF BUFFER btt-consulta-blt FOR tt-consulta-blt.
DEF BUFFER crabceb FOR crapceb.

DEF VAR b1wgen0011   AS HANDLE                                NO-UNDO.
                        

DEF TEMP-TABLE tt-crapcob        LIKE crapcob.


PROCEDURE consulta-boleto-2via.

    DEF INPUT        PARAM p-cdcooper  AS INTE             NO-UNDO.
    DEF INPUT        PARAM p-nrcpfcgc  AS DECI             NO-UNDO.
    DEF INPUT        PARAM p-nrinssac  AS DECI             NO-UNDO.
    DEF INPUT        PARAM p-nrdconta  AS INTE             NO-UNDO.
    DEF INPUT        PARAM p-nrcnvcob  AS DECI             NO-UNDO.
    DEF INPUT        PARAM p-nrdocmto  AS DECI             NO-UNDO.
    DEF INPUT        PARAM p-dsdoccop  AS CHAR             NO-UNDO.
    DEF INPUT        PARAM p-idorigem  AS INTE             NO-UNDO.
    DEF INPUT        PARAM p-cdoperad  AS CHAR             NO-UNDO.
    
    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-consulta-blt.

    DEF VAR aux_critdata               AS LOGI             NO-UNDO.
    DEF VAR aux_contador               AS INTE             NO-UNDO.
    DEF VAR aux_vlrjuros               AS DECI             NO-UNDO.
    DEF VAR aux_vlrmulta               AS DECI             NO-UNDO.
    DEF VAR aux_vldescto               AS DECI             NO-UNDO.
    DEF VAR aux_vlabatim               AS DECI             NO-UNDO.
    DEF VAR aux_vlfatura               AS DECI             NO-UNDO.
    DEF VAR aux_dscritic               AS CHAR             NO-UNDO.

    DEF VAR aux_dtvencut               AS DATE             NO-UNDO.          
    DEF VAR aux_vltituut               AS DECI             NO-UNDO.
    DEF VAR aux_vlmormut               AS DECI             NO-UNDO.
    DEF VAR aux_dtvencut_atualizado    AS DATE             NO-UNDO.
    DEF VAR aux_vltituut_atualizado    AS DECI             NO-UNDO.
    DEF VAR aux_vlmormut_atualizado    AS DECI             NO-UNDO.
    DEF VAR aux_vldescut               AS DECI             NO-UNDO.
    DEF VAR aux_cdmensut               AS INTE             NO-UNDO.
	DEF VAR aux_nmdobnfc			   AS CHAR			   NO-UNDO.
	DEF VAR aux_des_erro			   AS CHAR			   NO-UNDO.

    DEF VAR h-b2crap14                 AS HANDLE           NO-UNDO.
    DEF VAR h-b1wgen0089               AS HANDLE           NO-UNDO.

    DEF VAR aux_rowidcob               AS ROWID            NO-UNDO.
    DEF VAR aux_rowidcco               AS ROWID            NO-UNDO.

    DEF QUERY q_crapcob FOR crapcob, crapcco.
    DEF VAR   aux_query                AS CHAR             NO-UNDO.

    DEF VAR aux_npc_cip                AS INTE             NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-blt. 

    /* verificar se conta nao eh migracao/incorporada */
    IF  p-nrdconta > 0 AND p-nrcpfcgc > 0 THEN DO:                  
        FOR FIRST craptco FIELDS (nrdconta) WHERE 
                  craptco.cdcooper = p-cdcooper AND 
                  craptco.nrctaant = p-nrdconta AND 
                  craptco.cdcopant <> p-cdcooper 
                  NO-LOCK
            ,EACH crapass WHERE
                  crapass.cdcooper = p-cdcooper AND
                  crapass.nrdconta = craptco.nrdconta AND
                  crapass.nrcpfcgc = p-nrcpfcgc
                  NO-LOCK:                       
            ASSIGN p-nrdconta = craptco.nrdconta.
        END.                                     
    END.

    IF p-nrdconta > 0 AND p-nrcpfcgc = 0 AND p-nrcnvcob > 0 THEN DO:

       FOR EACH craptco WHERE 
                craptco.cdcooper = p-cdcooper AND
                craptco.nrctaant = p-nrdconta 
                NO-LOCK
          ,EACH crapceb WHERE
                crapceb.cdcooper = craptco.cdcooper AND
                crapceb.nrdconta = craptco.nrdconta AND
                crapceb.nrconven = p-nrcnvcob
                NO-LOCK:
          ASSIGN p-nrdconta = craptco.nrdconta.
       END.

    END.

    IF  p-nrdconta = 0 AND p-nrcpfcgc > 0 THEN 
        DO:
            FIND LAST crapass WHERE crapass.cdcooper = p-cdcooper 
                                 AND crapass.nrcpfcgc = p-nrcpfcgc NO-ERROR.
            IF AVAIL crapass THEN
                ASSIGN p-nrdconta = crapass.nrdconta.
            ELSE
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "CPF/CNPJ nao encontrado.".
                    RETURN "NOK".
                END.
        END.

    FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapdat THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Data nao cadastrada no sistema.".
            RETURN "NOK".
        END.

    ASSIGN aux_query = "FOR EACH crapcob NO-LOCK " +
                       "WHERE crapcob.cdcooper = " + STRING(p-cdcooper).
        
    IF p-nrinssac > 0 THEN
       aux_query = aux_query + " AND (crapcob.nrinssac = " + 
                                      STRING(p-nrinssac) + ")".
    
    IF p-nrdconta > 0 THEN
       aux_query = aux_query + " AND (crapcob.nrdconta = " + 
                                      STRING(p-nrdconta) + ")".
       
    IF p-nrcnvcob > 0 THEN   
       aux_query = aux_query + " AND (crapcob.nrcnvcob = " + 
                                      STRING(p-nrcnvcob) + ")".
    
    IF p-nrdocmto > 0 THEN
       aux_query = aux_query + " AND (crapcob.nrdocmto = " + 
                                      STRING(p-nrdocmto) + ")".
    
    IF p-dsdoccop <> "" THEN                               
       aux_query = aux_query + " AND (crapcob.dsdoccop = """ + 
                   p-dsdoccop + """)".
    
    ASSIGN aux_query = aux_query + ", EACH crapcco NO-LOCK " + 
                       "WHERE crapcco.cdcooper = crapcob.cdcooper " + 
                       " AND crapcco.nrconven = crapcob.nrcnvcob " + 
                       " AND crapcco.cddbanco = 085 ". /* + 
                       " AND crapcco.flgregis = TRUE".*/

    QUERY q_crapcob:QUERY-CLOSE().
    QUERY q_crapcob:QUERY-PREPARE(aux_query).
    QUERY q_crapcob:QUERY-OPEN().

    GET FIRST q_crapcob NO-LOCK.

    IF NOT AVAIL crapcob THEN
    DO:  
        CREATE tt-erro.
        ASSIGN tt-erro.dscritic = "Nao ha boleto com os parametros " +
                                  "informados.".
        RETURN "NOK".
    END.
    
    DO WHILE AVAILABLE(crapcob):

        ASSIGN aux_contador = aux_contador + 1
               aux_rowidcob = ROWID(crapcob)
               aux_rowidcco = ROWID(crapcco).

        IF  aux_contador > 1 THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Existe mais de um boleto com " +
                                          "estes parametros.".
                RETURN "NOK".
            END.

        GET NEXT q_crapcob.
    END. /* FIM DO WHILE */   

    FIND FIRST crapcob WHERE ROWID(crapcob) = aux_rowidcob NO-LOCK NO-ERROR.

    FIND FIRST crapcco WHERE ROWID(crapcco) = aux_rowidcco NO-LOCK NO-ERROR.

    /* nao eh permitido gerar 2via de boleto do convenio EMPRESTIMO, ACORDO ou DESCONTO DE TITULO */
    IF  AVAIL(crapcco) AND (crapcco.dsorgarq = "EMPRESTIMO" OR crapcco.dsorgarq = "ACORDO" OR crapcco.dsorgarq = "DESCONTO DE TITULO") THEN 
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao eh permitito gerar 2a. via " + 
                                      "para este convenio.".
            RETURN "NOK".
        END.

    IF  NOT AVAIL crapcob OR NOT AVAIL crapcco THEN
        DO:  
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao ha boleto com os parametros " +
                                      "informados.".
            RETURN "NOK".
        END.
    
    /* ====  validacao do boleto ====*/
    IF crapcob.insitcrt = 3 THEN
         ASSIGN aux_dscritic = "Boleto bloqueado, entre em contato com o beneficiário".
    ELSE IF crapcob.incobran = 5 THEN
         ASSIGN aux_dscritic = "Boleto liquidado. Nao e possivel imprimi-lo.".
    ELSE IF crapcob.incobran = 3 AND crapcob.insitcrt = 1 THEN
         ASSIGN aux_dscritic = "Boleto enviado para protesto. " +
                               "Nao e possivel imprimi-lo.".
    ELSE IF crapcob.incobran = 3 AND crapcob.insitcrt = 0 THEN
         ASSIGN aux_dscritic = "Boleto baixado. Nao e possivel imprimi-lo.".
    ELSE IF crapcob.incobran = 4 THEN
         ASSIGN aux_dscritic = "Boleto rejeitado. Nao e possivel imprimi-lo.".
    ELSE IF crapcob.dsinform MATCHES "LIQAPOSBX*" THEN
         ASSIGN aux_dscritic = "Boleto nao gerado pelo sistema da cooperativa." +
                               " Nao e possivel imprimi-lo.".

    IF  aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".    
        END.
      
    /* atributos para proc. proc_nosso_numero. */
    ASSIGN aux_nrregist  = 0
           aux_iniseque  = 1
           aux_fimseque  = 2.

    FIND FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
                         AND crapass.nrdconta = crapcob.nrdconta
                         NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapass THEN
        DO:            
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel consultar " +
                                      "dados do cooperado.".
            RETURN "NOK".
        END.

    FIND FIRST crapsab WHERE crapsab.cdcooper = crapcob.cdcooper
                         AND crapsab.nrdconta = crapcob.nrdconta
                         AND crapsab.nrinssac = crapcob.nrinssac
        NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapsab THEN
        DO:            
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel consultar " +
                                      "dados do pagador.".
            RETURN "NOK".
        END.

    /*Busca nome impresso no boleto*/
    RUN busca-nome-imp-blt(INPUT  crapcob.cdcooper
                          ,INPUT  crapcob.nrdconta
                          ,INPUT  crapcob.idseqttl
                          ,INPUT  "consulta-boleto-2via" /*nmprogra*/
                          ,OUTPUT aux_nmdobnfc
                          ,OUTPUT aux_dscritic).

    IF  RETURN-VALUE <> "OK" OR
        aux_dscritic <> ""   THEN 
		DO: 
			IF  aux_dscritic = "" THEN 
			DO:   
				ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario para ser impresso no boleto".
			END.
			
			CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
			
            RETURN "NOK".
        END.
	
    RUN proc_nosso_numero(INPUT p-cdcooper,
                          INPUT 90,
                          INPUT 900,
                          INPUT 7 /*todos*/,
                          INPUT 1,
                          INPUT aux_nmdobnfc).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Erro ao gerar boleto.".
            RETURN "NOK".
        END.
        

    RUN sistema/generico/procedures/b1wgen0089.p PERSISTENT SET h-b1wgen0089.

    IF  NOT VALID-HANDLE(h-b1wgen0089) THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Handle invalido para BO " +
                                      "b1wgen0089.".
            RETURN "NOK".
        END.

    RUN cria-log-cobranca IN h-b1wgen0089 
                         (INPUT ROWID(crapcob),
                          INPUT p-cdoperad,
                          INPUT crapdat.dtmvtolt,
                          INPUT "2 via de boleto gerado pelo pagador.").
    DELETE PROCEDURE h-b1wgen0089.

	RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
								   INPUT crapcob.nrdconta,           
								   INPUT crapcob.dtvencto,
								   INPUT crapdat.dtmvtocd,           
								   INPUT crapcob.vlabatim,           
								   INPUT crapcob.vltitulo,           
								   INPUT crapcob.vlrmulta,           
								   INPUT crapcob.vljurdia,           
								   INPUT crapcob.cdmensag,           
								   INPUT crapcob.vldescto,           
								   INPUT crapcob.tpdmulta,           
								   INPUT crapcob.tpjurmor,           
								   INPUT YES,           
                                   INPUT crapcob.flgcbdda,
                                   INPUT crapdat.dtmvtolt,
                                   INPUT crapcob.dtvctori,
                   INPUT crapcob.incobran,
								   OUTPUT aux_dtvencut,           
								   OUTPUT aux_vltituut,           
								   OUTPUT aux_vlmormut,           
								   OUTPUT aux_dtvencut_atualizado,
								   OUTPUT aux_vltituut_atualizado,
								   OUTPUT aux_vlmormut_atualizado,          
								   OUTPUT aux_vldescut,           
								   OUTPUT aux_cdmensut,
								   OUTPUT aux_critdata).
    
	/* verifica se o titulo esta vencido */
	IF  aux_critdata  THEN
		DO: 
			/* se concede ate o vencimento */
			IF  crapcob.cdmensag = 1 OR
				crapcob.cdmensag = 0 THEN
				ASSIGN tt-consulta-blt.vldescto = aux_vldescut
					   tt-consulta-blt.cdmensag = aux_cdmensut.
		END.
   ELSE
     DO:
       /* Caso nao esteja vencido, enviar o valor 
          atualizado em branco, para que use o 
          valor original do documento */
       ASSIGN aux_vltituut = ?.
	END.
			
    IF AVAIL(tt-consulta-blt) THEN
    DO:
        ASSIGN tt-consulta-blt.vltitulo            = aux_vltituut
               tt-consulta-blt.vlmormul            = aux_vlmormut
               tt-consulta-blt.flg2viab            = IF aux_critdata = YES THEN 1 ELSE 0
               tt-consulta-blt.nmprimtl 	         = aux_nmdobnfc.
               
    /* Consulta se titulo esta na faixa de rollout e integrado na cip */
    RUN verifica-titulo-npc-cip(INPUT crapcob.cdcooper,
                                INPUT crapdat.dtmvtolt,
                                INPUT crapcob.vltitulo,
                                INPUT crapcob.flgcbdda,
                                OUTPUT aux_npc_cip).
					
    IF aux_npc_cip = 1 THEN
	 DO:
	    /* Se estiver na faixa do rollout, data de vencimento e valor do título devem ser mantidos os originais */
         ASSIGN aux_vltituut_atualizado = crapcob.vltitulo
                aux_dtvencut_atualizado = aux_dtvencut
				aux_dtvencut = IF crapcob.dtvctori = ? THEN crapcob.dtvencto ELSE crapcob.dtvctori.
	 END.

        ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
				   tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
				   tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
				   tt-consulta-blt.nrdconta = crapcob.nrdconta
				   tt-consulta-blt.vldocmto = crapcob.vltitulo
                   /* Valor de desconto calculado */
                   tt-consulta-blt.vldescto = aux_vldescut 
				   tt-consulta-blt.flgaceit = "N"
               tt-consulta-blt.flgcbdda = (IF aux_npc_cip = 1 THEN "S" ELSE "N")

               /* Carregar as datas do boleto que esta sendo consultado */
               tt-consulta-blt.dtvctori = crapcob.dtvctori
               tt-consulta-blt.dtvencto = crapcob.dtvencto
               /* Data de Movimento atualizada */ 
               tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
               /* Identificar se o boleto esta vencido */
               tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
               tt-consulta-blt.dtbloqueio = crapcob.dtbloque.

			VALIDATE tt-consulta-blt.
	   END.

    RETURN "OK".        
END PROCEDURE.  /* consulta-boleto-2via */

PROCEDURE consulta-bloqueto.
   
    DEF  INPUT PARAM p-cdcooper       AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-nro-conta      AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-ini-documento  AS DECI                      NO-UNDO.
    DEF  INPUT PARAM p-fim-documento  AS DECI                      NO-UNDO.
    DEF  INPUT PARAM p-nrins-sacado   AS DECI                      NO-UNDO.
    DEF  INPUT PARAM p-nome-sacado    AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM p-ind-situacao   AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-num-registros  AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-ini-sequencia  AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-ini-vencimento AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-fim-vencimento AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-ini-pagamento  AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-fim-pagamento  AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-ini-emissao    AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-fim-emissao    AS DATE                      NO-UNDO.
    DEF  INPUT PARAM p-consulta       AS INTE                      NO-UNDO. 
    DEF  INPUT PARAM p-tipo-consulta  AS INTE                      NO-UNDO. 
    DEF  INPUT PARAM p-origem         AS INTE                      NO-UNDO. 
    DEF  INPUT PARAM p-cod-agencia    AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-nro-caixa      AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-dsdoccop       AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM p-flgregis       AS LOGI                      NO-UNDO.
    DEF  INPUT PARAM p-inestcri       AS INTE                      NO-UNDO.
    DEF  INPUT PARAM p-inserasa       AS CHAR                      NO-UNDO.
                                                                   
    DEF OUTPUT PARAM par_qtregist     AS INTE                      NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo     AS CHAR                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR  tt-erro.
    DEF OUTPUT PARAM TABLE FOR  tt-consulta-blt. 

    DEF VAR aux_data             AS DATE                      NO-UNDO.
    DEF VAR h-b1wgen0030         AS HANDLE                    NO-UNDO.
    
    DEF VAR aux_dtvencut               AS DATE             NO-UNDO.          
    DEF VAR aux_vltituut               AS DECI             NO-UNDO.
    DEF VAR aux_vlmormut               AS DECI             NO-UNDO.
    DEF VAR aux_dtvencut_atualizado    AS DATE             NO-UNDO.
    DEF VAR aux_vltituut_atualizado    AS DECI             NO-UNDO.
    DEF VAR aux_vlmormut_atualizado    AS DECI             NO-UNDO.
    DEF VAR aux_vldescut               AS DECI             NO-UNDO.
    DEF VAR aux_cdmensut               AS INTE             NO-UNDO.
	DEF VAR aux_critdata               AS LOGI             NO-UNDO.
    DEF VAR aux_dscritic               AS CHAR             NO-UNDO.
    DEF VAR aux_nmdobnfc               AS CHAR             NO-UNDO.
    DEF VAR aux_des_erro               AS CHAR             NO-UNDO.
    DEF VAR aux_contaant             LIKE crapass.nrdconta NO-UNDO.
    DEF VAR aux_sqttlant             LIKE crapttl.idseqttl NO-UNDO.
	
 /******************************** CONSULTAS *********************************/
 /*                                                                          */
 /* p-tipo-consulta > 1-NAO COBRADOS/2-COBRADOS/3-TODOS                      */
 /*                                                                          */
 /* p-consulta      > 1-CONTA/2-DOCUMENTO/3-EMISSAO p/ tipo de consulta 1, 2 */
 /*                                                                          */
 /* p-consulta      > 1-CONTA/2-DOCUMENTO/3-EMISSAO/4-PAGAMENTO/5-VENCIMENTO */
 /*                   6-PERIODO (contempla emissao/pagto/vencto)             */
 /*                   6 somente para tipo de consulta 1                      */
 /*                                                                          */
 /* p-origem        > 1-AYLLOS/2-CAIXA ON-LINE/3-INTERNET                    */
 /*                                                                          */
 /* p-inserasa      Vazio ("") = Todos / 2. Não Negativado /  3. Sol. Enviadas         */ 
 /*                 4. Negativados / 5. Sol. Com Erros                       */
 /****************************************************************************/

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-blt.

    ASSIGN aux_nrregis1 = p-num-registros.

    IF  p-consulta < 1  OR
        p-consulta > 16 THEN
        DO:
            ASSIGN i-cod-erro = 329
                   c-dsc-erro = " ".

            {sistema/generico/includes/b1wgen0001.i}

            RETURN "NOK".
        END.

    IF  p-tipo-consulta = 1  AND  /* Boletos Nao Cobrados */
       (p-consulta > 3       AND
        p-consulta <> 8)     THEN
        DO:
            ASSIGN i-cod-erro = 329 
                   c-dsc-erro = " ".
           
            {sistema/generico/includes/b1wgen0001.i}

            RETURN "NOK".
        END.

    IF   p-consulta = 6 THEN
         DO:
             IF   p-nome-sacado = "" THEN
                  DO:
                      ASSIGN i-cod-erro   = 375 
                             c-dsc-erro   = " "
                             par_nmdcampo = "nmprimtl".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.
         END.
    
    ASSIGN p-nome-sacado = (IF TRIM(p-nome-sacado) <> "" THEN 
                               "*" + p-nome-sacado + "*" 
                            ELSE "") 
           aux_nrregist  = 0
           aux_iniseque  = p-ini-sequencia
           aux_fimseque  = p-ini-sequencia + p-num-registros.
    

    FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapdat  THEN
        DO:
			ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            {sistema/generico/includes/b1wgen0001.i}
             
            RETURN "NOK".
        END.
    
    IF  p-origem = 3  THEN  /* Internet */
        DO:
            FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                               crapass.nrdconta = p-nro-conta NO-LOCK NO-ERROR.
                       
            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN i-cod-erro = 9 
                           c-dsc-erro = " ".
           
                    {sistema/generico/includes/b1wgen0001.i}

                    RETURN "NOK".
                END.
        
            IF  crapass.inpessoa > 1  THEN
                ASSIGN aux_nmprimtl = REPLACE(crapass.nmprimtl,"&","%26").
        END.
    
    /*Guarda a conta que pode estar zerada*/
    ASSIGN aux_contaant = p-nro-conta
           aux_sqttlant = 0.
		
    CASE p-consulta:
         WHEN 1 THEN                                   /* Por Conta */
                DO:                    
                    FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper
                                       AND ((p-inestcri = 1 AND 
                                             crapcco.cddbanco = 85) OR
                                             p-inestcri = 0)
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper AND
                             crapceb.nrconven = crapcco.nrconven AND
                             crapceb.nrdconta = p-nro-conta
                             NO-LOCK
                       ,EACH crapcob WHERE 
                             crapcob.cdcooper = crapceb.cdcooper AND
                             crapcob.nrdconta = crapceb.nrdconta AND
                             crapcob.nrcnvcob = crapceb.nrconven
                             NO-LOCK
                             USE-INDEX crapcob8:

                        /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                        IF p-inestcri = 1 THEN
                        DO:
                            FIND FIRST crapret 
                                 WHERE crapret.cdcooper = crapcob.cdcooper
                                   AND crapret.nrcnvcob = crapcco.nrconven
                                   AND crapret.nrdconta = crapcob.nrdconta
                                   AND crapret.nrdocmto = crapcob.nrdocmto
                                   AND CAN-DO("6,17,76,77",
                                              STRING(crapret.cdocorre))
                                   AND crapret.vlrpagto >= 250000
                                   AND crapret.cdmotivo = "04"
                                   AND CAN-DO("1,2",STRING(crapret.inestcri))
                                   NO-LOCK NO-ERROR.
                            IF NOT AVAIL crapret THEN
                                NEXT.
                        END.

                        IF   p-tipo-consulta = 1    AND
                             crapcob.incobran <> 0  AND 
                             crapcob.incobran <> 3  THEN
                             NEXT.
                        ELSE
                        IF   p-tipo-consulta = 2    AND
                             crapcob.incobran <> 5  THEN
                             NEXT.

                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.

                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".
                        
                        RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                             INPUT p-cod-agencia, 
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).
                    END.
                END.
         WHEN 2 THEN
                DO:                                    /* Por Documento */
                    IF  p-ini-documento <= 0 THEN 
                        DO:
                            ASSIGN i-cod-erro = 22 
                                   c-dsc-erro = " "
                                   par_nmdcampo = "ininrdoc".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-documento > p-fim-documento OR p-fim-documento = 0 THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Boleto inicial maior que Boleto final"
                                   par_nmdcampo = "fimnrdoc".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    /* Restringir busca */
                    IF  ( p-fim-documento - p-ini-documento ) > 1000 THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Faixa de boletos solicitadas superior a 1000 (mil)"
                                   par_nmdcampo = "fimnrdoc".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                    
                    IF   p-origem = 3 THEN                /* Internet */
                         DO:
                             
                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper AND
                                      crapcco.flginter = TRUE
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper AND
                                      crapceb.nrconven = crapcco.nrconven AND
                                      crapceb.nrdconta = p-nro-conta
                                      NO-LOCK
                                ,EACH crapcob WHERE 
                                      crapcob.cdcooper = crapceb.cdcooper AND
                                      crapcob.nrdconta = crapceb.nrdconta AND
                                      crapcob.nrcnvcob = crapceb.nrconven AND
                                      crapcob.cdbandoc = crapcco.cddbanco AND
                                      crapcob.nrdctabb = crapcco.nrdctabb AND
                                      crapcob.nrdocmto >= p-ini-documento AND
                                      crapcob.nrdocmto <= p-fim-documento
                                      NO-LOCK
                                      USE-INDEX crapcob2:

                                 FIND crapsab WHERE 
                                      crapsab.cdcooper = p-cdcooper     AND
                                      crapsab.nrdconta = p-nro-conta    AND
                                      crapsab.nrinssac = crapcob.nrinssac
                                      NO-LOCK NO-ERROR.

                                 IF  p-nrins-sacado > 0 THEN
                                     DO:
                                        IF  crapcob.nrinssac <> p-nrins-sacado 
                                            THEN NEXT.
                                     END.
                                 
                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.

                                 /*Se mudou a conta devo busca o beneficiario*/
                                 RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                                            ,INPUT crapcob.nrdconta
                                                            ,INPUT crapcob.idseqttl
                                                            ,INPUT "consulta-bloqueto"
                                                            ,INPUT-OUTPUT aux_contaant /* Conta anterior */ 
                                                            ,INPUT-OUTPUT aux_sqttlant /* Sequencia do titular anterior */ 
                                                            ,INPUT-OUTPUT aux_nmdobnfc
                                                            ,OUTPUT aux_dscritic).

                                 IF  RETURN-VALUE <> "OK" THEN
                                     DO:             
                                        IF  aux_dscritic = "" THEN DO:   
                                            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
                                        END.
                                              
                                        RUN valida_caracteres(INPUT  aux_dscritic,
                                                              OUTPUT aux_dscritic).
                                              
                                        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                                               
                                        UNIX SILENT VALUE("echo " + 
                                                        STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto por documento ' --> '" + aux_dscritic + 
                                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                                        "/log/proc_message.log").

                                        RETURN "NOK".
                                     END.
                                 
                                 RUN proc_nosso_numero(INPUT p-cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT p-ind-situacao,
                                                       INPUT p-num-registros,
                                                       INPUT aux_nmdobnfc).

                                 IF   RETURN-VALUE = "NOK"  THEN
                                      RETURN "NOK".
                                      
                                 /* Se deu certo a criacao da tt-consulta-blt, calcular o valor atualizado */
                                 IF   RETURN-VALUE = "OK"  THEN
                                 DO:
                                 RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
                                                                INPUT crapcob.nrdconta,           
                                                                INPUT crapcob.dtvencto,           
                                                                INPUT crapdat.dtmvtocd,           
                                                                INPUT crapcob.vlabatim,           
                                                                INPUT crapcob.vltitulo,           
                                                                INPUT crapcob.vlrmulta,           
                                                                INPUT crapcob.vljurdia,           
                                                                INPUT crapcob.cdmensag,           
                                                                INPUT crapcob.vldescto,           
                                                                INPUT crapcob.tpdmulta,           
                                                                INPUT crapcob.tpjurmor,           
                                                                INPUT NO,           
                                                                INPUT crapcob.flgcbdda,
                                                                INPUT crapdat.dtmvtolt,
                                                                INPUT crapcob.dtvctori,
                                                                INPUT crapcob.incobran,
                                                                OUTPUT aux_dtvencut,           
                                                                OUTPUT aux_vltituut,           
                                                                OUTPUT aux_vlmormut,           
                                                                OUTPUT aux_dtvencut_atualizado,
                                                                OUTPUT aux_vltituut_atualizado,
                                                                OUTPUT aux_vlmormut_atualizado,          
                                                                OUTPUT aux_vldescut,           
                                                                OUTPUT aux_cdmensut,
                                                                OUTPUT aux_critdata).     
								 					 
                                 ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
                                        tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
                                        tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
                                        tt-consulta-blt.flg2viab            = (IF aux_critdata = YES THEN 1 ELSE 0)
										tt-consulta-blt.nmprimtl 			= aux_nmdobnfc
                                            tt-consulta-blt.vldescto            = aux_vldescut

                                            /* Carregar as datas do boleto que esta sendo consultado */
                                            tt-consulta-blt.dtvctori = crapcob.dtvctori
                                            tt-consulta-blt.dtbloqueio = crapcob.dtbloque
                                            tt-consulta-blt.dtvencto = crapcob.dtvencto
                                            /* Data de Movimento atualizada */ 
                                            tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
                                            /* Identificar se o boleto esta vencido */
                                            tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
                                            tt-consulta-blt.cddespec = crapcob.cddespec.
                                            
                                 END.
                                          
                             END.


                             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                             IF   AVAILABLE tt-consulta-blt  THEN
                                  tt-consulta-blt.nrregist            = aux_nrregist.
                         END.
                    ELSE
                         DO:
                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper AND
                                      ((p-inestcri = 1 AND crapcco.cddbanco = 85)
                                        OR p-inestcri = 0)
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                     (crapceb.nrdconta = p-nro-conta OR 
                                      p-nro-conta = 0)
                                      NO-LOCK
                                ,EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper       AND
                                      crapcob.cdbandoc  = crapcco.cddbanco AND
                                      crapcob.nrdctabb  = crapcco.nrdctabb AND
                                      crapcob.nrcnvcob  = crapceb.nrconven AND
                                      crapcob.nrdconta  = crapceb.nrdconta AND
                                      crapcob.nrdocmto >= p-ini-documento  AND
                                      crapcob.nrdocmto <= p-fim-documento
                                      NO-LOCK BY crapcob.nrdocmto
                                              BY crapcob.nrdconta:
                                 
                                 /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                                 IF p-inestcri = 1 THEN
                                 DO:
                                    FIND FIRST crapret 
                                         WHERE crapret.cdcooper = crapcob.cdcooper
                                           AND crapret.nrcnvcob = crapcco.nrconven
                                           AND crapret.nrdconta = crapcob.nrdconta
                                           AND crapret.nrdocmto = crapcob.nrdocmto
                                           AND CAN-DO("6,17,76,77",
                                                      STRING(crapret.cdocorre))
                                           AND crapret.vlrpagto >= 250000
                                           AND crapret.cdmotivo = "04"
                                           AND CAN-DO("1,2",STRING(crapret.inestcri))
                                           NO-LOCK NO-ERROR.
                                    IF NOT AVAIL crapret THEN
                                        NEXT.
                                 END.

                                 IF   p-tipo-consulta = 1    AND
                                      crapcob.incobran <> 0  AND
                                      crapcob.incobran <> 3  THEN
                                      NEXT.
                                 ELSE
                                 IF   p-tipo-consulta = 2    AND
                                      crapcob.incobran <> 5  THEN
                                      NEXT.

                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.
                               
                                 IF   AVAILABLE crapcco  THEN
                                      aux_dsorgarq = crapcco.dsorgarq.
                                 ELSE
                                      aux_dsorgarq = "".
                             
                                 RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                      INPUT p-cod-agencia, 
                                                      INPUT p-nro-caixa,
                                                      INPUT crapdat.dtmvtoan,
                                                      INPUT p-num-registros,
                                                      INPUT p-ini-sequencia,
                                                      INPUT-OUTPUT aux_nmdobnfc,
                                                      INPUT-OUTPUT aux_contaant,
                                                      INPUT-OUTPUT aux_sqttlant,
                                               INPUT-OUTPUT par_qtregist,
                                                     OUTPUT TABLE tt-consulta-blt).
                             END.    
                         END.    
                END.
         WHEN 3 THEN
                DO:       

				/* Por Data Emissao */
                    IF  p-ini-emissao = ? THEN
                        DO:
                            ASSIGN i-cod-erro = 13 
                                   c-dsc-erro = " "
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao OR p-fim-emissao = ? THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que a data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                    
                    IF   p-origem = 3 THEN                /* Internet */
                         DO:

                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                      crapceb.nrdconta = p-nro-conta
                                      NO-LOCK
                                ,EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper       AND
                                      crapcob.nrcnvcob  = crapceb.nrconven AND
                                      crapcob.nrdconta  = crapceb.nrdconta AND
                                      crapcob.dtmvtolt >= p-ini-emissao    AND
                                      crapcob.dtmvtolt <= p-fim-emissao
                                      NO-LOCK USE-INDEX crapcob8
                                              BY crapcob.nrdocmto:

                                 FIND crapsab WHERE 
                                      crapsab.cdcooper = p-cdcooper     AND
                                      crapsab.nrdconta = p-nro-conta    AND
                                      crapsab.nrinssac = crapcob.nrinssac
                                      NO-LOCK NO-ERROR.

                                 IF  TRIM(p-nome-sacado) <> "" THEN
                                     DO:
                                        IF  AVAIL crapsab THEN
                                            DO:
                                                IF  NOT crapsab.nmdsacad 
                                                    MATCHES p-nome-sacado 
                                                    THEN NEXT.
                                            END.
                                        ELSE
                                            NEXT.
                                     END.

                                 IF  p-nrins-sacado > 0 THEN
                                     DO:
                                        IF  crapcob.nrinssac <> p-nrins-sacado 
                                            THEN NEXT.
                                     END.
                                  
                                  IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.

                                 /*Se mudou a conta devo busca o beneficiario*/
                                 RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                                            ,INPUT crapcob.nrdconta
                                                            ,INPUT crapcob.idseqttl
                                                            ,INPUT "consulta-bloqueto"
                                                            ,INPUT-OUTPUT aux_contaant /* Conta anterior */ 
                                                            ,INPUT-OUTPUT aux_sqttlant /* Sequencia do titular anterior */ 
                                                            ,INPUT-OUTPUT aux_nmdobnfc
                                                            ,OUTPUT aux_dscritic).

                                 IF  RETURN-VALUE <> "OK" THEN
                                     DO:             
                                        IF  aux_dscritic = "" THEN DO:   
                                            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
                                        END.
                                              
                                        RUN valida_caracteres(INPUT  aux_dscritic,
                                                              OUTPUT aux_dscritic).
                                              
                                        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                                               
                                        UNIX SILENT VALUE("echo " + 
                                                        STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto por data emissao ' --> '" + aux_dscritic + 
                                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                                        "/log/proc_message.log").

                                        RETURN "NOK".
                                     END.

                                  RUN proc_nosso_numero(INPUT p-cdcooper,
                                                        INPUT p-cod-agencia,
                                                        INPUT p-nro-caixa,
                                                        INPUT p-ind-situacao,
                                                        INPUT p-num-registros,
                                                        INPUT aux_nmdobnfc).
                                                    
                                  IF   RETURN-VALUE = "NOK"  THEN
                                       RETURN "NOK".
                             
                                 /* Se deu certo a criacao da tt-consulta-blt, calcular o valor atualizado */
                                 IF   RETURN-VALUE = "OK"  THEN
                                 DO:                                                   
                             RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
                                                            INPUT crapcob.nrdconta,           
                                                            INPUT crapcob.dtvencto,           
                                                            INPUT crapdat.dtmvtocd,           
                                                            INPUT crapcob.vlabatim,           
                                                            INPUT crapcob.vltitulo,           
                                                            INPUT crapcob.vlrmulta,           
                                                            INPUT crapcob.vljurdia,           
                                                            INPUT crapcob.cdmensag,           
                                                            INPUT crapcob.vldescto,           
                                                            INPUT crapcob.tpdmulta,           
                                                            INPUT crapcob.tpjurmor,           
                                                            INPUT NO,           
                                                            INPUT crapcob.flgcbdda,
                                                            INPUT crapdat.dtmvtolt,
                                                            INPUT crapcob.dtvctori,
                                                            INPUT crapcob.incobran,
                                                            OUTPUT aux_dtvencut,           
                                                            OUTPUT aux_vltituut,           
                                                            OUTPUT aux_vlmormut,           
                                                            OUTPUT aux_dtvencut_atualizado,
                                                            OUTPUT aux_vltituut_atualizado,
                                                            OUTPUT aux_vlmormut_atualizado,          
                                                            OUTPUT aux_vldescut,           
                                                            OUTPUT aux_cdmensut,
                                                            OUTPUT aux_critdata).     
                             	 
                             ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
                                    tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
                                    tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
                                    tt-consulta-blt.flg2viab            = (IF aux_critdata = YES THEN 1 ELSE 0)
                                    tt-consulta-blt.nmprimtl            = aux_nmdobnfc
                                            tt-consulta-blt.vldescto            = aux_vldescut
                                              
                                            /* Carregar as datas do boleto que esta sendo consultado */
                                            tt-consulta-blt.dtvctori = crapcob.dtvctori
                                            tt-consulta-blt.dtbloqueio = crapcob.dtbloque
                                            tt-consulta-blt.dtvencto = crapcob.dtvencto
                                            /* Data de Movimento atualizada */ 
                                            tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
                                            /* Identificar se o boleto esta vencido */
                                            tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
                                            tt-consulta-blt.cddespec = crapcob.cddespec.
                                 
                                 END.
                             END.    

                             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                             IF   AVAILABLE tt-consulta-blt  THEN
                                  tt-consulta-blt.nrregist = aux_nrregist.
                         END.
                    ELSE     
                         DO:
                             FOR EACH crapcco WHERE
                                      crapcco.cdcooper = p-cdcooper AND
                                      ((p-inestcri = 1 AND crapcco.cddbanco = 85)
                                       OR p-inestcri = 0)
                                      NO-LOCK
                                ,EACH crapceb WHERE
                                      crapceb.cdcooper = crapcco.cdcooper AND
                                      crapceb.nrconven = crapcco.nrconven AND
                                     (crapceb.nrdconta = p-nro-conta OR 
                                      p-nro-conta = 0)
                                      NO-LOCK  
                                ,EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper       AND
                                      crapcob.nrdconta  = crapceb.nrdconta AND
                                      crapcob.nrcnvcob  = crapceb.nrconven AND
                                      crapcob.dtmvtolt >= p-ini-emissao    AND
                                      crapcob.dtmvtolt <= p-fim-emissao
                                      NO-LOCK USE-INDEX crapcob8                                    
                                              BY crapcob.nrdconta:

                                 /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                                 IF p-inestcri = 1 THEN
                                 DO:
                                    FIND FIRST crapret 
                                         WHERE crapret.cdcooper = crapcob.cdcooper
                                           AND crapret.nrcnvcob = crapcco.nrconven
                                           AND crapret.nrdconta = crapcob.nrdconta
                                           AND crapret.nrdocmto = crapcob.nrdocmto
                                           AND CAN-DO("6,17,76,77",
                                                      STRING(crapret.cdocorre))
                                           AND crapret.vlrpagto >= 250000
                                           AND crapret.cdmotivo = "04"
                                           AND CAN-DO("1,2",STRING(crapret.inestcri))
                                           NO-LOCK NO-ERROR.
                                    IF NOT AVAIL crapret THEN
                                        NEXT.
                                 END.

                                 IF   p-tipo-consulta = 1    AND
                                      crapcob.incobran <> 0  AND
                                      crapcob.incobran <> 3  THEN
                                      NEXT.
                                 ELSE
                                 IF   p-tipo-consulta = 2    AND
                                      crapcob.incobran <> 5  THEN
                                      NEXT.

                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.

                                 IF   AVAILABLE crapcco  THEN
                                      aux_dsorgarq = crapcco.dsorgarq.
                                 ELSE
                                      aux_dsorgarq = "".

                                 RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                      INPUT p-cod-agencia, 
                                                      INPUT p-nro-caixa,
                                                      INPUT crapdat.dtmvtoan,
                                                      INPUT p-num-registros,
                                                      INPUT p-ini-sequencia,
                                                      INPUT-OUTPUT aux_nmdobnfc,
                                                      INPUT-OUTPUT aux_contaant,
                                                      INPUT-OUTPUT aux_sqttlant,
                                               INPUT-OUTPUT par_qtregist,
                                                     OUTPUT TABLE tt-consulta-blt).
                                 
                             END.    
                         END.    
                END.
         WHEN 4 THEN                                   /* Por Data Pagto */
                DO:
                    IF  p-ini-pagamento = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 13 
                                   c-dsc-erro = " "
                                   par_nmdcampo = "inidtdpa".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-pagamento > p-fim-pagamento OR p-fim-pagamento = ? THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtdpa".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF   p-origem = 3 THEN                /* Internet */
                         DO:
                                      
                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                      crapceb.nrdconta = p-nro-conta
                                      NO-LOCK:   
                                 
                                DO aux_data = p-ini-pagamento TO p-fim-pagamento:
                                                                         
                                FOR EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper       AND
                                      crapcob.nrcnvcob  = crapceb.nrconven AND
                                      crapcob.dtdpagto  = aux_data         AND
                                      crapcob.nrdconta  = crapceb.nrdconta
                                      NO-LOCK BY crapcob.nrdconta
                                              BY crapcob.nrinssac
                                              BY crapcob.dtdpagto
                                              BY crapcob.nrdocmto:
                                 
                                 FIND crapsab WHERE
                                      crapsab.cdcooper = p-cdcooper      AND
                                      crapsab.nrdconta = p-nro-conta     AND
                                      crapsab.nrinssac = crapcob.nrinssac
                                      NO-LOCK NO-ERROR.
                                
                                 IF  TRIM(p-nome-sacado) <> "" THEN
                                     DO:
                                        IF  AVAIL crapsab THEN
                                            DO:
                                                IF  NOT crapsab.nmdsacad 
                                                    MATCHES p-nome-sacado 
                                                    THEN NEXT.
                                            END.
                                        ELSE
                                            NEXT.
                                     END.
                                 
                                 IF  p-nrins-sacado > 0 THEN
                                     DO:
                                        IF  crapcob.nrinssac <> p-nrins-sacado 
                                            THEN NEXT.
                                     END.

                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.
                                              
                                 /*Se mudou a conta devo busca o beneficiario*/
                                 RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                                            ,INPUT crapcob.nrdconta
                                                            ,INPUT crapcob.idseqttl
                                                            ,INPUT "consulta-bloqueto"
                                                            ,INPUT-OUTPUT aux_contaant /* Conta anterior */ 
                                                            ,INPUT-OUTPUT aux_sqttlant /* Sequencia do titular anterior */ 
                                                            ,INPUT-OUTPUT aux_nmdobnfc
                                                            ,OUTPUT aux_dscritic).

                                 IF  RETURN-VALUE <> "OK" THEN
                                     DO:             
                                        IF  aux_dscritic = "" THEN DO:   
                                            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
                                        END.
                                              
                                        RUN valida_caracteres(INPUT  aux_dscritic,
                                                              OUTPUT aux_dscritic).
                                              
                                        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                                               
                                        UNIX SILENT VALUE("echo " + 
                                                        STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto por data pagto ' --> '" + aux_dscritic + 
                                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                                        "/log/proc_message.log").

                                        RETURN "NOK".
                                     END.

                                 RUN proc_nosso_numero(INPUT p-cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT p-ind-situacao,
                                                       INPUT p-num-registros,
                                                       INPUT aux_nmdobnfc).

                                 IF   RETURN-VALUE = "NOK"  THEN
                                      RETURN "NOK".
                                      
                                         /* Se deu certo a criacao da tt-consulta-blt, calcular o valor atualizado */
                                         IF   RETURN-VALUE = "OK"  THEN
                                         DO:  
                                 RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
                                                                INPUT crapcob.nrdconta,           
                                                                INPUT crapcob.dtvencto,           
                                                                INPUT crapdat.dtmvtocd,           
                                                                INPUT crapcob.vlabatim,           
                                                                INPUT crapcob.vltitulo,           
                                                                INPUT crapcob.vlrmulta,           
                                                                INPUT crapcob.vljurdia,           
                                                                INPUT crapcob.cdmensag,           
                                                                INPUT crapcob.vldescto,           
                                                                INPUT crapcob.tpdmulta,           
                                                                INPUT crapcob.tpjurmor,           
                                                                INPUT NO,           
                                                                INPUT crapcob.flgcbdda,
                                                                INPUT crapdat.dtmvtolt,
                                                                INPUT crapcob.dtvctori,
                                                                INPUT crapcob.incobran,
                                                                OUTPUT aux_dtvencut,           
                                                                OUTPUT aux_vltituut,           
                                                                OUTPUT aux_vlmormut,           
                                                                OUTPUT aux_dtvencut_atualizado,
                                                                OUTPUT aux_vltituut_atualizado,
                                                                OUTPUT aux_vlmormut_atualizado,          
                                                                OUTPUT aux_vldescut,           
                                                                OUTPUT aux_cdmensut,
                                                                OUTPUT aux_critdata).     
                                 
                                 ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
                                        tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
                                        tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
                                        tt-consulta-blt.flg2viab            = IF aux_critdata = YES THEN 1 ELSE 0
                                        tt-consulta-blt.nmprimtl 			= aux_nmdobnfc
                                                      tt-consulta-blt.vldescto            = aux_vldescut
                                              
                                                      /* Carregar as datas do boleto que esta sendo consultado */
                                                      tt-consulta-blt.dtvctori = crapcob.dtvctori
                                                      tt-consulta-blt.dtbloqueio = crapcob.dtbloque
                                                      tt-consulta-blt.dtvencto = crapcob.dtvencto
                                                      /* Data de Movimento atualizada */ 
                                                      tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
                                                      /* Identificar se o boleto esta vencido */
                                                      tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
                                                      tt-consulta-blt.cddespec = crapcob.cddespec.

                                END.
                                END.
                             END.
                             END.

                             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                             IF   AVAILABLE tt-consulta-blt  THEN
                                  tt-consulta-blt.nrregist = aux_nrregist.
                         END.
                    ELSE
                         DO:
                            FOR EACH crapcco WHERE 
                                     crapcco.cdcooper = p-cdcooper AND
                                     ((p-inestcri = 1 AND crapcco.cddbanco = 85)
                                      OR p-inestcri = 0)
                                     NO-LOCK
                               ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                    ( crapceb.nrdconta = p-nro-conta       OR
                                      p-nro-conta = 0 )
                                      NO-LOCK:   

                               ASSIGN aux_dsorgarq = "".

                               DO aux_data = p-ini-pagamento TO p-fim-pagamento:

                                   FOR EACH crapcob WHERE 
                                            crapcob.cdcooper  = p-cdcooper       AND
                                            crapcob.nrcnvcob  = crapcco.nrconven AND 
                                            crapcob.dtdpagto  = aux_data         AND
                                            crapcob.nrdconta  = crapceb.nrdconta
                                            NO-LOCK BY crapcob.dtdpagto
                                                    BY crapcob.nrdconta:
                                    
                                     /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                                     IF p-inestcri = 1 THEN
                                     DO:
                                        FIND FIRST crapret 
                                             WHERE crapret.cdcooper = crapcob.cdcooper
                                               AND crapret.nrcnvcob = crapcco.nrconven
                                               AND crapret.nrdconta = crapcob.nrdconta
                                               AND crapret.nrdocmto = crapcob.nrdocmto
                                               AND CAN-DO("6,17,76,77",
                                                          STRING(crapret.cdocorre))
                                               AND crapret.vlrpagto >= 250000
                                               AND crapret.cdmotivo = "04"
                                               AND CAN-DO("1,2",STRING(crapret.inestcri))
                                               NO-LOCK NO-ERROR.
                                        IF NOT AVAIL crapret THEN
                                            NEXT.
                                     END.

                                     ASSIGN aux_dsorgarq = crapcco.dsorgarq.
    
                                     IF   crapcob.incobran <> 5  THEN
                                          NEXT.
    
                                     IF  p-flgregis <> ? THEN
                                         IF crapcob.flgregis <> p-flgregis THEN NEXT.
    
                                     IF p-nro-conta > 0 THEN
                                         IF crapcob.nrdconta <> p-nro-conta THEN NEXT.
    
                                     RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                          INPUT p-cod-agencia, 
                                                          INPUT p-nro-caixa,
                                                          INPUT crapdat.dtmvtoan,
                                                          INPUT p-num-registros,
                                                          INPUT p-ini-sequencia,
                                                          INPUT-OUTPUT aux_nmdobnfc,
                                                          INPUT-OUTPUT aux_contaant,
                                                          INPUT-OUTPUT aux_sqttlant,
                                                   INPUT-OUTPUT par_qtregist,
                                                         OUTPUT TABLE tt-consulta-blt).
                                   END.
                               END.
                            END.
                         END.    
                END.
         WHEN 5 THEN                                   /* Por Data Vencto */
                DO:
                    IF  p-ini-vencimento = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 13 
                                   c-dsc-erro = " "
                                   par_nmdcampo = "inidtven".
                    
                            {sistema/generico/includes/b1wgen0001.i}
                    
                            RETURN "NOK".
                        END.
                    
                    IF  p-ini-vencimento > p-fim-vencimento OR p-fim-vencimento = ? THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtven".
                    
                            {sistema/generico/includes/b1wgen0001.i}
                    
                            RETURN "NOK".
                        END.

                    IF   p-origem = 3 THEN                /* Internet */
                         DO:

                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper AND
                                      crapcco.flginter = TRUE
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                      crapceb.nrdconta = p-nro-conta
                                      NO-LOCK:

                                DO aux_data = p-ini-vencimento TO p-fim-vencimento:


                                FOR EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper       AND
                                      crapcob.nrcnvcob  = crapceb.nrconven AND
                                      crapcob.nrdconta  = crapceb.nrdconta AND 
                                      crapcob.dtvencto = aux_data
                                      NO-LOCK BY crapcob.nrdconta
                                              BY crapcob.dtvencto
                                              BY crapcob.nrinssac
                                              BY crapcob.nrdocmto:

                                 FIND crapsab WHERE
                                      crapsab.cdcooper = p-cdcooper      AND
                                      crapsab.nrdconta = p-nro-conta     AND
                                      crapsab.nrinssac = crapcob.nrinssac
                                      NO-LOCK NO-ERROR.
                                
                                 IF  TRIM(p-nome-sacado) <> "" THEN
                                     DO:
                                        IF  AVAIL crapsab THEN
                                            DO:
                                                IF  NOT crapsab.nmdsacad 
                                                    MATCHES p-nome-sacado 
                                                    THEN NEXT.
                                            END.
                                        ELSE
                                            NEXT.
                                     END.

                                 IF  p-nrins-sacado > 0 THEN
                                     DO:
                                        IF  crapcob.nrinssac <> p-nrins-sacado 
                                            THEN NEXT.
                                     END.              

                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.
                                     
                                 /*Se mudou a conta devo busca o beneficiario*/
                                 RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                                            ,INPUT crapcob.nrdconta
                                                            ,INPUT crapcob.idseqttl
                                                            ,INPUT "consulta-bloqueto"
                                                            ,INPUT-OUTPUT aux_contaant /* Conta anterior */ 
                                                            ,INPUT-OUTPUT aux_sqttlant /* Sequencia do titular anterior */ 
                                                            ,INPUT-OUTPUT aux_nmdobnfc
                                                            ,OUTPUT aux_dscritic).

                                 IF  RETURN-VALUE <> "OK" THEN
                                     DO:             
                                        IF  aux_dscritic = "" THEN DO:   
                                            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
                                        END.
                                              
                                        RUN valida_caracteres(INPUT  aux_dscritic,
                                                              OUTPUT aux_dscritic).
                                              
                                        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                                               
                                        UNIX SILENT VALUE("echo " + 
                                                        STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto por data vencto ' --> '" + aux_dscritic + 
                                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                                        "/log/proc_message.log").

                                        RETURN "NOK".
                                     END.

                                 RUN proc_nosso_numero(INPUT p-cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT p-ind-situacao,
                                                       INPUT p-num-registros,
                                                       INPUT aux_nmdobnfc).
                                                           
                                 IF   RETURN-VALUE = "NOK"  THEN
                                      RETURN "NOK".
                                      
                                     /* Se deu certo a criacao da tt-consulta-blt, calcular o valor atualizado */
                                     IF   RETURN-VALUE = "OK"  THEN
                                     DO:                                                   
                                 RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
                                                                INPUT crapcob.nrdconta,           
                                                                INPUT crapcob.dtvencto,           
                                                                INPUT crapdat.dtmvtocd,           
                                                                INPUT crapcob.vlabatim,           
                                                                INPUT crapcob.vltitulo,           
                                                                INPUT crapcob.vlrmulta,           
                                                                INPUT crapcob.vljurdia,           
                                                                INPUT crapcob.cdmensag,           
                                                                INPUT crapcob.vldescto,           
                                                                INPUT crapcob.tpdmulta,           
                                                                INPUT crapcob.tpjurmor,           
                                                                INPUT NO,           
                                                                INPUT crapcob.flgcbdda,
                                                                INPUT crapdat.dtmvtolt,
                                                                INPUT crapcob.dtvctori,
                                                                INPUT crapcob.incobran,
                                                                OUTPUT aux_dtvencut,           
                                                                OUTPUT aux_vltituut,           
                                                                OUTPUT aux_vlmormut,           
                                                                OUTPUT aux_dtvencut_atualizado,
                                                                OUTPUT aux_vltituut_atualizado,
                                                                OUTPUT aux_vlmormut_atualizado,          
                                                                OUTPUT aux_vldescut,           
                                                                OUTPUT aux_cdmensut,
                                                                OUTPUT aux_critdata).     
                                 
                                 ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
                                        tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
                                        tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
                                        tt-consulta-blt.flg2viab            = IF aux_critdata = YES THEN 1 ELSE 0
                                        tt-consulta-blt.nmprimtl 		    = aux_nmdobnfc
                                                tt-consulta-blt.vldescto            = aux_vldescut

                                                /* Carregar as datas do boleto que esta sendo consultado */
                                                tt-consulta-blt.dtvctori = crapcob.dtvctori
                                                tt-consulta-blt.dtbloqueio = crapcob.dtbloque
                                                tt-consulta-blt.dtvencto = crapcob.dtvencto
                                                /* Data de Movimento atualizada */ 
                                                tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
                                                /* Identificar se o boleto esta vencido */
                                                tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
                                                tt-consulta-blt.cddespec = crapcob.cddespec.
                                 
                                END.
                                END.
                             END.
                             END.

                             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                             IF   AVAILABLE tt-consulta-blt  THEN
                                  tt-consulta-blt.nrregist = aux_nrregist.

                         END.
                    ELSE
                         DO:
                             FOR EACH crapcco WHERE 
                                      crapcco.cdcooper = p-cdcooper AND
                                      ((p-inestcri = 1 AND crapcco.cddbanco = 85)
                                       OR p-inestcri = 0)
                                      NO-LOCK
                                ,EACH crapceb WHERE 
                                      crapceb.cdcooper = crapcco.cdcooper  AND
                                      crapceb.nrconven = crapcco.nrconven  AND
                                     (crapceb.nrdconta = p-nro-conta OR 
                                      p-nro-conta = 0)
                                      NO-LOCK:

                                DO aux_data = p-ini-vencimento TO p-fim-vencimento:

                                FOR EACH crapcob WHERE 
                                      crapcob.cdcooper  = p-cdcooper        AND
                                      crapcob.nrdconta  = crapceb.nrdconta  AND
                                      crapcob.nrcnvcob  = crapceb.nrconven  AND
                                      crapcob.dtvencto  = aux_data
                                      NO-LOCK BY crapcob.dtvencto
                                              BY crapcob.nrdconta:
                                
                                 /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                                 IF p-inestcri = 1 THEN
                                 DO:
                                    FIND FIRST crapret 
                                         WHERE crapret.cdcooper = crapcob.cdcooper
                                           AND crapret.nrcnvcob = crapcco.nrconven
                                           AND crapret.nrdconta = crapcob.nrdconta
                                           AND crapret.nrdocmto = crapcob.nrdocmto
                                           AND CAN-DO("6,17,76,77",
                                                      STRING(crapret.cdocorre))
                                           AND crapret.vlrpagto >= 250000
                                           AND crapret.cdmotivo = "04"
                                           AND CAN-DO("1,2",STRING(crapret.inestcri))
                                           NO-LOCK NO-ERROR.
                                    IF NOT AVAIL crapret THEN
                                        NEXT.
                                 END.

                                 IF  p-flgregis <> ? THEN
                                     IF crapcob.flgregis <> p-flgregis THEN NEXT.
                               
                                 IF   AVAILABLE crapcco  THEN
                                      aux_dsorgarq = crapcco.dsorgarq.
                                 ELSE
                                      aux_dsorgarq = "".
                             
                                 RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                      INPUT p-cod-agencia, 
                                                      INPUT p-nro-caixa,
                                                      INPUT crapdat.dtmvtoan,
                                                      INPUT p-num-registros,
                                                      INPUT p-ini-sequencia,
                                                      INPUT-OUTPUT aux_nmdobnfc,
                                                      INPUT-OUTPUT aux_contaant,
                                                      INPUT-OUTPUT aux_sqttlant,
                                               INPUT-OUTPUT par_qtregist,
                                                     OUTPUT TABLE tt-consulta-blt).
                                END.
                                END.
                             END.
                         END.        
                END.
         WHEN 6 THEN                             /* Por Sacado */
                DO:
                    /*IF   p-tipo-consulta <> 3    OR
                         p-origem <> 1           THEN
                         DO:
                             ASSIGN par_nmdcampo    = "nmprimtl"
                                    i-cod-erro      = 329 
                                    c-dsc-erro      = " ".
           
                             {sistema/generico/includes/b1wgen0001.i}

                             RETURN "NOK".
                         END.*/
                    
                    FOR EACH crapsab WHERE 
                             crapsab.cdcooper = p-cdcooper AND
                             crapsab.nmdsacad  MATCHES  p-nome-sacado AND
                            (crapsab.nrdconta = p-nro-conta OR 
                             p-nro-conta = 0)
                             NO-LOCK,
                        EACH crapcob WHERE 
                             crapcob.cdcooper = crapsab.cdcooper AND
                             crapcob.nrdconta = crapsab.nrdconta AND
                             crapcob.nrinssac = crapsab.nrinssac 
                             NO-LOCK BY crapcob.nrdconta
                                     BY crapsab.nrinssac:
                            
                             FIND FIRST crapcco WHERE
                                        crapcco.cdcooper = crapcob.cdcooper AND
                                        crapcco.nrconven = crapcob.nrcnvcob 
                             NO-LOCK NO-ERROR.
                            
                            /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                            IF AVAILABLE crapcco     AND 
                               p-inestcri = 1        AND 
                               crapcco.cddbanco = 85 THEN
                            DO:
                                FIND FIRST crapret 
                                     WHERE crapret.cdcooper = crapcob.cdcooper
                                       AND crapret.nrcnvcob = crapcco.nrconven
                                       AND crapret.nrdconta = crapcob.nrdconta
                                       AND crapret.nrdocmto = crapcob.nrdocmto
                                       AND CAN-DO("6,17,76,77",
                                                  STRING(crapret.cdocorre))
                                       AND crapret.vlrpagto >= 250000
                                       AND crapret.cdmotivo = "04"
                                       AND CAN-DO("1,2",STRING(crapret.inestcri))
                                       NO-LOCK NO-ERROR.
                                IF NOT AVAIL crapret THEN
                                    NEXT.
                            END.

                            IF  p-flgregis <> ? THEN
                                IF crapcob.flgregis <> p-flgregis THEN NEXT.

                            IF   AVAILABLE crapcco  THEN
                                 aux_dsorgarq = crapcco.dsorgarq.
                            ELSE
                                 aux_dsorgarq = "".

                            RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                 INPUT p-cod-agencia, 
                                                 INPUT p-nro-caixa,
                                                 INPUT crapdat.dtmvtoan,
                                                 INPUT p-num-registros,
                                                 INPUT p-ini-sequencia,
                                                 INPUT-OUTPUT aux_nmdobnfc,
                                                 INPUT-OUTPUT aux_contaant,
                                                 INPUT-OUTPUT aux_sqttlant,
                                          INPUT-OUTPUT par_qtregist,
                                                OUTPUT TABLE tt-consulta-blt).
                    END.
                END.
         WHEN 7 THEN                             /* Por Periodo */
                DO:
                    
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                    
                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper  AND
                             crapceb.nrconven = crapcco.nrconven
                             NO-LOCK:

                        IF p-nro-conta > 0 THEN
                            IF crapceb.nrdconta <> p-nro-conta THEN NEXT.


                        DO aux_data = p-ini-emissao TO p-fim-emissao:

                           FOR EACH crapcob WHERE 
                    			    crapcob.cdcooper  = p-cdcooper        AND
                                    crapcob.nrdconta  = crapceb.nrdconta  AND
                                    crapcob.nrcnvcob  = crapceb.nrconven  AND
                    			    crapcob.dtmvtolt  = aux_data
                    			    NO-LOCK USE-INDEX crapcob8:

                                IF  p-flgregis <> ? THEN
                                    IF crapcob.flgregis <> p-flgregis THEN NEXT.
                                
                                FIND FIRST tt-crapcob WHERE 
                            			   tt-crapcob.cdcooper = crapcob.cdcooper AND
                            			   tt-crapcob.cdbandoc = crapcob.cdbandoc AND
                            			   tt-crapcob.nrdctabb = crapcob.nrdctabb AND
                            			   tt-crapcob.nrcnvcob = crapcob.nrcnvcob AND
                                           tt-crapcob.nrdconta = crapcob.nrdconta AND                    
                                           tt-crapcob.nrdocmto = crapcob.nrdocmto
                                           NO-LOCK NO-ERROR.

                                IF NOT AVAIL(tt-crapcob) THEN DO:

                                    CREATE tt-crapcob.
                                    BUFFER-COPY crapcob TO tt-crapcob.

                                END.

                    			 
                    	   END.
                    	     
                    
                    	   FOR EACH crapcob WHERE 
                    			    crapcob.cdcooper  = p-cdcooper        AND
                    			    crapcob.dtvencto  = aux_data          AND 
                    			    crapcob.nrcnvcob  = crapceb.nrconven  AND
                    			    crapcob.nrdconta  = crapceb.nrdconta
                    			    NO-LOCK USE-INDEX crapcob9:

                                IF  p-flgregis <> ? THEN
                                    IF crapcob.flgregis <> p-flgregis THEN NEXT.

                                FIND FIRST tt-crapcob WHERE 
                            			   tt-crapcob.cdcooper = crapcob.cdcooper AND
                            			   tt-crapcob.cdbandoc = crapcob.cdbandoc AND
                            			   tt-crapcob.nrdctabb = crapcob.nrdctabb AND
                            			   tt-crapcob.nrcnvcob = crapcob.nrcnvcob AND
                                           tt-crapcob.nrdconta = crapcob.nrdconta AND                    
                                           tt-crapcob.nrdocmto = crapcob.nrdocmto
                                           NO-LOCK NO-ERROR.

                                IF NOT AVAIL(tt-crapcob) THEN DO:

                                    CREATE tt-crapcob.
                                    BUFFER-COPY crapcob TO tt-crapcob.

                                END.

                    	   END.
                    
                    
                    	   FOR EACH crapcob WHERE 
                    			    crapcob.cdcooper  = p-cdcooper        AND
                    			    crapcob.dtdpagto  = aux_data    	   AND
                    			    crapcob.nrcnvcob  = crapceb.nrconven  AND
                    			    crapcob.nrdconta  = crapceb.nrdconta
                    			    NO-LOCK USE-INDEX crapcob6:
                                
                                IF  p-flgregis <> ? THEN
                                    IF crapcob.flgregis <> p-flgregis THEN NEXT.

                                FIND FIRST tt-crapcob WHERE 
                            			   tt-crapcob.cdcooper = crapcob.cdcooper AND
                            			   tt-crapcob.cdbandoc = crapcob.cdbandoc AND
                            			   tt-crapcob.nrdctabb = crapcob.nrdctabb AND
                            			   tt-crapcob.nrcnvcob = crapcob.nrcnvcob AND
                                           tt-crapcob.nrdconta = crapcob.nrdconta AND                    
                                           tt-crapcob.nrdocmto = crapcob.nrdocmto
                                           NO-LOCK NO-ERROR.

                                IF NOT AVAIL(tt-crapcob) THEN DO:

                                    CREATE tt-crapcob.
                                    BUFFER-COPY crapcob TO tt-crapcob.

                                END.
                    	   END.
                        END. /* do */
                    END.  /* for cco */

                    /* Leitura tabela temporaria */
                    FOR EACH tt-crapcob NO-LOCK:

                       FOR EACH crapcob WHERE 
                                crapcob.cdcooper = tt-crapcob.cdcooper AND
                                crapcob.cdbandoc = tt-crapcob.cdbandoc AND
                                crapcob.nrdctabb = tt-crapcob.nrdctabb AND
                                crapcob.nrcnvcob = tt-crapcob.nrcnvcob AND
                                crapcob.nrdconta = tt-crapcob.nrdconta AND                    
                                crapcob.nrdocmto = tt-crapcob.nrdocmto
                                USE-INDEX crapcob1:

                            FIND crapcco WHERE crapcco.cdcooper = crapcob.cdcooper AND
                                               crapcco.nrconven = crapcob.nrcnvcob
                                               NO-LOCK NO-ERROR. 

                            IF   AVAILABLE crapcco  THEN
                                 aux_dsorgarq = crapcco.dsorgarq.
                            ELSE
                                 aux_dsorgarq = "".
    
                            RUN p_grava_bloqueto(INPUT p-cdcooper, 
                                                 INPUT p-cod-agencia, 
                                                 INPUT p-nro-caixa,
                                                 INPUT crapdat.dtmvtoan,
                                                 INPUT p-num-registros,
                                                 INPUT p-ini-sequencia,
                                                 INPUT-OUTPUT aux_nmdobnfc,
                                                 INPUT-OUTPUT aux_contaant,
                                                 INPUT-OUTPUT aux_sqttlant,
                                          INPUT-OUTPUT par_qtregist,
                                                OUTPUT TABLE tt-consulta-blt).

                       END.


                   END.

                END.
         WHEN 8 THEN                      /* Por Conta e Nr Doc Cop */
                DO:
				
                    IF  p-dsdoccop = "" THEN
                        DO:
                            ASSIGN i-cod-erro    = 22 
                                    c-dsc-erro   = " "
                                    par_nmdcampo = "dsdoccop".
           
                             {sistema/generico/includes/b1wgen0001.i}

                             RETURN "NOK".
                        END.
                   
                    IF   p-origem = 3 THEN                /* Internet */
                         DO:
                            
                            FOR EACH crapcco WHERE 
                                     crapcco.cdcooper = p-cdcooper 
                                     NO-LOCK
                               ,EACH crapceb WHERE 
                                     crapceb.cdcooper = crapcco.cdcooper  AND
                                     crapceb.nrconven = crapcco.nrconven  AND
                                     crapceb.nrdconta = p-nro-conta
                                     NO-LOCK
                               ,EACH crapcob WHERE 
                                     crapcob.cdcooper  = crapceb.cdcooper  AND
                                     crapcob.nrdconta  = crapceb.nrdconta  AND
                                     crapcob.nrcnvcob  = crapceb.nrconven  AND
                                     crapcob.dsdoccop MATCHES "*" + STRING(p-dsdoccop) + "*" 
                                     NO-LOCK
                                     BY crapcob.dtmvtolt:
                                
                                FIND crapsab WHERE 
                                     crapsab.cdcooper = p-cdcooper     AND
                                     crapsab.nrdconta = p-nro-conta    AND
                                     crapsab.nrinssac = crapcob.nrinssac
                                     NO-LOCK NO-ERROR.
                                     
                                IF  p-flgregis <> ? THEN
                                    IF crapcob.flgregis <> p-flgregis THEN NEXT.
                                       
                                IF   AVAILABLE crapcco  THEN
                                     aux_dsorgarq = crapcco.dsorgarq.
                                ELSE
                                     aux_dsorgarq = "".

                                 /*Se mudou a conta devo busca o beneficiario*/
                                 RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                                            ,INPUT crapcob.nrdconta
                                                            ,INPUT crapcob.idseqttl
                                                            ,INPUT "consulta-bloqueto"
                                                            ,INPUT-OUTPUT aux_contaant /* Conta anterior */ 
                                                            ,INPUT-OUTPUT aux_sqttlant /* Sequencia do titular anterior */ 
                                                            ,INPUT-OUTPUT aux_nmdobnfc
                                                            ,OUTPUT aux_dscritic).

                                 IF  RETURN-VALUE <> "OK" THEN
                                     DO:             
                                        IF  aux_dscritic = "" THEN DO:   
                                            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
                                        END.
                                              
                                        RUN valida_caracteres(INPUT  aux_dscritic,
                                                              OUTPUT aux_dscritic).
                                              
                                        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                                               
                                        UNIX SILENT VALUE("echo " + 
                                                        STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto por nro docto ' --> '" + aux_dscritic + 
                                                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                                        "/log/proc_message.log").

                                        RETURN "NOK".
                                     END.

                                RUN proc_nosso_numero(INPUT p-cdcooper,
                                                      INPUT p-cod-agencia,
                                                      INPUT p-nro-caixa,
                                                      INPUT p-ind-situacao,
                                                      INPUT p-num-registros,
                                                      INPUT aux_nmdobnfc).
                                                           
                                IF   RETURN-VALUE = "NOK"  THEN
                             RETURN "NOK".
                              
                                /* Se deu certo a criacao da tt-consulta-blt, calcular o valor atualizado */
                                IF   RETURN-VALUE = "OK"  THEN
                                DO:
                               RUN calcula_multa_juros_boleto(INPUT crapcob.cdcooper,           
                                                              INPUT crapcob.nrdconta,           
                                                              INPUT crapcob.dtvencto,           
                                                              INPUT crapdat.dtmvtocd,           
                                                              INPUT crapcob.vlabatim,           
                                                              INPUT crapcob.vltitulo,           
                                                              INPUT crapcob.vlrmulta,           
                                                              INPUT crapcob.vljurdia,           
                                                              INPUT crapcob.cdmensag,           
                                                              INPUT crapcob.vldescto,           
                                                              INPUT crapcob.tpdmulta,           
                                                              INPUT crapcob.tpjurmor,           
                                                              INPUT NO,           
                                                              INPUT crapcob.flgcbdda,
                                                              INPUT crapdat.dtmvtolt,
                                                              INPUT crapcob.dtvctori,
                                                              INPUT crapcob.incobran,
                                                              OUTPUT aux_dtvencut,           
                                                              OUTPUT aux_vltituut,           
                                                              OUTPUT aux_vlmormut,           
                                                              OUTPUT aux_dtvencut_atualizado,
                                                              OUTPUT aux_vltituut_atualizado,
                                                              OUTPUT aux_vlmormut_atualizado,          
                                                              OUTPUT aux_vldescut,           
                                                              OUTPUT aux_cdmensut,
                                                              OUTPUT aux_critdata).     
                               
                               ASSIGN tt-consulta-blt.dtvencto_atualizado = aux_dtvencut_atualizado
                                      tt-consulta-blt.vltitulo_atualizado = aux_vltituut_atualizado
                                      tt-consulta-blt.vlmormul_atualizado = aux_vlmormut_atualizado
                                      tt-consulta-blt.flg2viab            = IF aux_critdata = YES THEN 1 ELSE 0
									                    tt-consulta-blt.nmprimtl 			      = aux_nmdobnfc
                                            tt-consulta-blt.vldescto            = aux_vldescut

                                            /* Carregar as datas do boleto que esta sendo consultado */
                                            tt-consulta-blt.dtvctori = crapcob.dtvctori
                                            tt-consulta-blt.dtbloqueio = crapcob.dtbloque
                                            tt-consulta-blt.dtvencto = crapcob.dtvencto
                                            /* Data de Movimento atualizada */ 
                                            tt-consulta-blt.dtmvtatu = crapdat.dtmvtocd
                                            /* Identificar se o boleto esta vencido */
                                            tt-consulta-blt.flgvenci = IF aux_critdata = YES THEN 1 ELSE 0
                                            tt-consulta-blt.cddespec = crapcob.cddespec.
                                
                                END.
                            END.

                            FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                            IF   AVAILABLE tt-consulta-blt  THEN
                                 tt-consulta-blt.nrregist = aux_nrregist.
                         
                        END.
                    ELSE
                    DO:

                        FOR EACH crapcco WHERE 
                                 crapcco.cdcooper = p-cdcooper AND
                                 ((p-inestcri = 1 AND crapcco.cddbanco = 85)
                                  OR p-inestcri = 0)
                                 NO-LOCK
                           ,EACH crapceb WHERE 
                                 crapceb.cdcooper = crapcco.cdcooper  AND
                                 crapceb.nrconven = crapcco.nrconven  AND
                                 crapceb.nrdconta = p-nro-conta
                                 NO-LOCK
                           ,EACH crapcob WHERE 
                                 crapcob.cdcooper  = p-cdcooper        AND
                                 crapcob.nrdconta  = crapceb.nrdconta  AND
                                 crapcob.nrcnvcob  = crapceb.nrconven  AND
                                 crapcob.dsdoccop MATCHES "*" + STRING(p-dsdoccop) + "*" 
                                 NO-LOCK
                                 BY crapcob.dtmvtolt:

                        /* Se p-inescri = 1, mostrar VR boleto "somente crise". */
                        IF p-inestcri = 1 THEN
                        DO:
                            FIND FIRST crapret 
                                 WHERE crapret.cdcooper = crapcob.cdcooper
                                   AND crapret.nrcnvcob = crapcco.nrconven
                                   AND crapret.nrdconta = crapcob.nrdconta
                                   AND crapret.nrdocmto = crapcob.nrdocmto
                                   AND CAN-DO("6,17,76,77",
                                              STRING(crapret.cdocorre))
                                   AND crapret.vlrpagto >= 250000
                                   AND crapret.cdmotivo = "04"
                                   AND CAN-DO("1,2",STRING(crapret.inestcri))
                                   NO-LOCK NO-ERROR.
                            IF NOT AVAIL crapret THEN
                                NEXT.
                        END.

                        IF   p-tipo-consulta = 1    AND
                             crapcob.incobran <> 0  AND 
                             crapcob.incobran <> 3  THEN
                             NEXT.
                        ELSE
                        IF   p-tipo-consulta = 2    AND
                             crapcob.incobran <> 5  THEN
                             NEXT.

                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.
                               
                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia, 
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).
                    END.
         END.
         END.
         WHEN 9 THEN      /* Por Vencimento 1 - Em Aberto */
                DO:

                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                    DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".

                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                    DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".

                        {sistema/generico/includes/b1wgen0001.i}

                        RETURN "NOK".
                    END.

                    ASSIGN aux_nrregist = 0.

                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper  AND
                             crapceb.nrconven = crapcco.nrconven  AND
                             crapceb.nrdconta = p-nro-conta
                             NO-LOCK:

                       DO aux_data = p-ini-emissao TO p-fim-emissao:
                       FOR EACH crapcob WHERE 
                             crapcob.cdcooper  = p-cdcooper        AND
                             crapcob.nrdconta  = crapceb.nrdconta  AND
                             crapcob.nrcnvcob  = crapceb.nrconven  AND
                             crapcob.dtvencto = aux_data           AND 
                             crapcob.incobran = 0 /* em aberto */
                             NO-LOCK BY crapcob.nrdconta:
                    
                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.
                     
                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        IF p-inserasa <> "" THEN
                        DO:

                            RUN verifica_sit_serasa(INPUT p-inserasa,
                                                    INPUT crapcob.inserasa,
                                                    OUTPUT aux_proximo).

                           IF aux_proximo = "S" THEN
                               NEXT.

                        END.

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).

                        ASSIGN aux_nrregist = aux_nrregist + 1.

                       END.
                       END. /* DO */

                    END.

                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.
         END.
         WHEN 10 THEN      /* Por Data de Baixa - 2 - Baixado */
                DO:
                
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.                
                
                    ASSIGN aux_nrregist = 0.

                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper  AND
                             crapceb.nrconven = crapcco.nrconven  AND
                             crapceb.nrdconta = p-nro-conta
                             NO-LOCK
                       ,EACH crapcob WHERE 
                             crapcob.cdcooper  = p-cdcooper        AND
                             crapcob.nrdconta  = crapceb.nrdconta  AND
                             crapcob.nrcnvcob  = crapceb.nrconven  AND
                             crapcob.dtdbaixa >= p-ini-emissao     AND
                             crapcob.dtdbaixa <= p-fim-emissao     AND
                             crapcob.incobran = 3 /* baixado */
                             NO-LOCK:
                    
                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.

                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        IF p-inserasa <> "" THEN
                        DO:
                           RUN verifica_sit_serasa(INPUT p-inserasa,
                                                   INPUT crapcob.inserasa,
                                                   OUTPUT aux_proximo).

                           IF aux_proximo = "S" THEN
                               NEXT.
                        END.

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).

                        ASSIGN aux_nrregist = aux_nrregist + 1.
                    END.

                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.

         END.
         WHEN 11 THEN      /* Por Data de Liquidacao - 3 - Liquidado */
                DO:
                    
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                    
                    ASSIGN aux_nrregist = 0.
                    
                        FOR EACH crapcco WHERE 
                                 crapcco.cdcooper = p-cdcooper
                                 NO-LOCK
                           ,EACH crapceb WHERE 
                                 crapceb.cdcooper = crapcco.cdcooper  AND
                                 crapceb.nrconven = crapcco.nrconven  AND
                                 crapceb.nrdconta = p-nro-conta
                                 NO-LOCK:

                        DO aux_data = p-ini-emissao TO p-fim-emissao:

                           FOR EACH crapcob WHERE 
                                 crapcob.cdcooper  = p-cdcooper        AND
                                 crapcob.nrdconta  = crapceb.nrdconta  AND
                                 crapcob.nrcnvcob  = crapceb.nrconven  AND
                                 crapcob.dtdpagto  = aux_data           AND
                                 crapcob.incobran = 5 /* liquidado */
                                 NO-LOCK:
        
                            IF  p-flgregis <> ? THEN
                                IF crapcob.flgregis <> p-flgregis THEN NEXT.
        
                            IF   AVAILABLE crapcco  THEN
                                 aux_dsorgarq = crapcco.dsorgarq.
                            ELSE
                                 aux_dsorgarq = "".
    
                            IF p-inserasa <> "" THEN
							DO:
							  RUN verifica_sit_serasa(INPUT p-inserasa,
                                                      INPUT crapcob.inserasa,
                                                     OUTPUT aux_proximo).

                              IF aux_proximo = "S" THEN
                                   NEXT.
							END.
    
                            RUN p_grava_bloqueto(INPUT p-cdcooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT crapdat.dtmvtoan,
                                                 INPUT p-num-registros,
                                                 INPUT p-ini-sequencia,
                                                 INPUT-OUTPUT aux_nmdobnfc,
                                                 INPUT-OUTPUT aux_contaant,
                                                 INPUT-OUTPUT aux_sqttlant,
                                          INPUT-OUTPUT par_qtregist,
                                                OUTPUT TABLE tt-consulta-blt).
                            ASSIGN aux_nrregist = aux_nrregist + 1.
                        END.
                        END.
                    END.

                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.

         END.
         WHEN 12 THEN      /* Por Data de Emissao - 4 - Rejeitado */
                DO:
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                
                
                    ASSIGN aux_nrregist = 0.

                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper  AND
                             crapceb.nrconven = crapcco.nrconven  AND
                             crapceb.nrdconta = p-nro-conta
                             NO-LOCK:

                    DO aux_data = p-ini-emissao TO p-fim-emissao:

                       FOR EACH crapcob WHERE 
                                crapcob.cdcooper = p-cdcooper        AND
                                crapcob.nrdconta = crapceb.nrdconta  AND
                                crapcob.nrcnvcob = crapceb.nrconven  AND
                                crapcob.dtmvtolt = aux_data           AND  
                                crapcob.incobran = 4 /* rejeitado */
                                NO-LOCK:

                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.

                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        IF p-inserasa <> "" THEN
                        DO:
                          RUN verifica_sit_serasa(INPUT p-inserasa,
                                                      INPUT crapcob.inserasa,
                                                     OUTPUT aux_proximo).

                          IF aux_proximo = "S" THEN
                               NEXT.
                        END.

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).

                        ASSIGN aux_nrregist = aux_nrregist + 1.
                       END.
                    END.
                    END.

                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.
         END.
         WHEN 13 THEN      /* Por Data de Movimentacao Cartoraria - 5 - Cartoraria*/
                DO:
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                    
                    ASSIGN aux_nrregist = 0.

                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK
                       ,EACH crapceb WHERE 
                             crapceb.cdcooper = crapcco.cdcooper  AND
                             crapceb.nrconven = crapcco.nrconven  AND
                             crapceb.nrdconta = p-nro-conta
                             NO-LOCK
                       ,EACH crapcob WHERE 
                             crapcob.cdcooper  = p-cdcooper        AND
                             crapcob.nrdconta  = crapceb.nrdconta  AND
                             crapcob.nrcnvcob  = crapceb.nrconven  AND
                             crapcob.dtsitcrt >= p-ini-emissao     AND
                             crapcob.dtsitcrt <= p-fim-emissao     
                             NO-LOCK:

                        IF  p-flgregis <> ? THEN
                            IF crapcob.flgregis <> p-flgregis THEN NEXT.

                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        IF p-inserasa <> "" THEN
                        DO:
                          RUN verifica_sit_serasa(INPUT p-inserasa,
                                                  INPUT crapcob.inserasa,
                                                  OUTPUT aux_proximo).

                          IF aux_proximo = "S" THEN
                               NEXT.
                        END.

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).
                        ASSIGN aux_nrregist = aux_nrregist + 1.
                    END.

                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.
         END.
         WHEN 14 THEN  /* Relatorio Francesa - Com Registro */
                DO:
                    /* Validar se o periodo foi informado */
                    IF  p-ini-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Inicial nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-fim-emissao = ? THEN 
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data Final nao informada"
                                   par_nmdcampo = "inidtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.

                    IF  p-ini-emissao > p-fim-emissao THEN
                        DO:
                            ASSIGN i-cod-erro = 0 
                                   c-dsc-erro = "Data inicial maior que data final"
                                   par_nmdcampo = "fimdtmvt".
           
                            {sistema/generico/includes/b1wgen0001.i}

                            RETURN "NOK".
                        END.
                
					
                    ASSIGN aux_nrregist = 0.

                    FOR EACH crapcco WHERE 
                             crapcco.cdcooper = p-cdcooper
                             NO-LOCK:

                        ASSIGN aux_dsorgarq = "".

                        FOR EACH craprtc WHERE  craprtc.cdcooper = p-cdcooper
                                           AND  craprtc.nrcnvcob = crapcco.nrconven  
                                           AND  craprtc.nrdconta = p-nro-conta
                                           AND  craprtc.dtmvtolt >= p-ini-emissao
                                           AND  craprtc.dtmvtolt <= p-fim-emissao
                                           AND  craprtc.intipmvt = 2
                                       NO-LOCK,
                            EACH crapret WHERE  crapret.cdcooper = craprtc.cdcooper
                                           AND  crapret.nrcnvcob = craprtc.nrcnvcob
                                           AND  crapret.nrdconta = craprtc.nrdconta
                                           AND  crapret.nrretcoo = craprtc.nrremret
										   AND  crapret.dtocorre = craprtc.dtmvtolt
                                       NO-LOCK:
    
                            IF  crapret.nrdocmto <> 0 THEN
                                FIND crapcob WHERE  crapcob.cdcooper = crapret.cdcooper
                                               AND  crapcob.cdbandoc = crapcco.cddbanco
                                               AND  crapcob.nrdctabb = crapcco.nrdctabb
                                               AND  crapcob.nrdconta = crapret.nrdconta
                                               AND  crapcob.nrcnvcob = crapret.nrcnvcob
                                               AND  crapcob.nrdocmto = crapret.nrdocmto
                                          NO-LOCK NO-ERROR.
    
    
                            IF  crapret.nrdocmto <> 0 THEN
                                IF  p-flgregis <> ? THEN
                                    IF crapcob.flgregis <> p-flgregis THEN NEXT.
    
                            ASSIGN aux_dsorgarq = crapcco.dsorgarq.
    
                            FIND FIRST crapoco
                                 WHERE crapoco.cdcooper = crapcco.cdcooper
                                   AND crapoco.cddbanco = crapcco.cddbanco
                                   AND crapoco.cdocorre = crapret.cdocorre
                                   AND crapoco.tpocorre = 2 /* Retorno */
                                 NO-LOCK NO-ERROR.
        
                            IF  NOT AVAIL crapoco THEN NEXT.
                            
                            IF  crapret.nrdocmto <> 0 THEN
								DO:        

                                RUN p_grava_bloqueto(INPUT p-cdcooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT crapdat.dtmvtoan,
                                                     INPUT p-num-registros,
                                                     INPUT p-ini-sequencia,
                                                         INPUT-OUTPUT aux_nmdobnfc,
                                                         INPUT-OUTPUT aux_contaant,
                                                         INPUT-OUTPUT aux_sqttlant,
                                              INPUT-OUTPUT par_qtregist,
                                                    OUTPUT TABLE tt-consulta-blt).
									
									IF RETURN-VALUE = "NOK" THEN
									    DO:
											FOR EACH tt-consulta-blt NO-LOCK:
										        DELETE tt-consulta-blt.
										    END.
											LEAVE.
									    END.
									
								END.
                            ELSE
								DO:      

                                RUN p_grava_bloqueto_rej (INPUT p-cdcooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT crapdat.dtmvtoan,
                                                     INPUT p-num-registros,
                                                     INPUT p-ini-sequencia,
                                                              INPUT-OUTPUT aux_nmdobnfc,     
                                                              INPUT-OUTPUT aux_contaant,
                                                              INPUT-OUTPUT aux_sqttlant,
                                              INPUT-OUTPUT par_qtregist,
                                                    OUTPUT TABLE tt-consulta-blt).
    
									IF RETURN-VALUE = "NOK" THEN
									    DO:
									    	FOR EACH tt-consulta-blt NO-LOCK:
										        DELETE tt-consulta-blt.
										    END.
											LEAVE.
									    END.
										
								END.
                            ASSIGN aux_nrregist = aux_nrregist + 1.
    
                            /* Reatualiza tt-consulta-blt */                     
                            ASSIGN tt-consulta-blt.cdocorre = crapret.cdocorre
                                   tt-consulta-blt.dsocorre = crapoco.dsocorre
                                   tt-consulta-blt.vloutdes = crapret.vloutdes 
                                   tt-consulta-blt.vloutcre = crapret.vloutcre
                                   /*tt-consulta-blt.vltarifa = crapret.vltarass*/
                                   tt-consulta-blt.cdmotivo = crapret.cdmotivo
                                   tt-consulta-blt.dtocorre = crapret.dtocorre
                                   tt-consulta-blt.vldpagto = crapret.vlrpagto
                                   tt-consulta-blt.vltitulo = crapret.vltitulo
                                   tt-consulta-blt.vlabatim = crapret.vlabatim
                                   tt-consulta-blt.vldescto = crapret.vldescto
                                   tt-consulta-blt.vlrjuros = crapret.vljurmul
                                   tt-consulta-blt.dtcredit = crapret.dtcredit  
                                   aux_cdposini = 1
                                   aux_dsmotivo = ""
                                   aux_cdnrmoti = 0.
    
							IF STRING(crapret.vltarass) = ? THEN
								assign tt-consulta-blt.vltarifa = 0.
							ELSE
								assign tt-consulta-blt.vltarifa = crapret.vltarass.
								
                            IF  (crapret.cdocorre = 6  OR
                                 crapret.cdocorre = 17 OR 
                                 crapret.cdocorre = 76 OR
                                 crapret.cdocorre = 77) THEN
                                  IF (tt-consulta-blt.nrborder > 0) THEN
                                  ASSIGN tt-consulta-blt.dscredit = "* TD *".
                            ELSE
                                  ASSIGN tt-consulta-blt.dscredit = STRING(tt-consulta-blt.dtcredi,"99/99/99").
                            ELSE
                              ASSIGN tt-consulta-blt.dscredit = " ".
                                                                
                                IF  crapret.cdoperad = "996" THEN
                                    tt-consulta-blt.dsorigem = "INTERNET".
                                ELSE
                                IF crapret.cdoperad = "1" THEN
                                   tt-consulta-blt.dsorigem = "COMPE".
                                ELSE
                                    tt-consulta-blt.dsorigem = "COOP.".
                        
                            IF  crapret.nrremass > 0 THEN
                                tt-consulta-blt.dsorigem_proc = "REM-" + 
                                  STRING(crapret.nrremass).
                            ELSE
                                tt-consulta-blt.dsorigem_proc = tt-consulta-blt.dsorigem.
                        
                            /* Pega descricao do(s) Motivo(s) */
                            DO  aux_contador = 1 TO 5:
                                ASSIGN aux_cdmotivo = 
                                       TRIM(SUBSTR(tt-consulta-blt.cdmotivo, 
                                                   aux_cdposini, 2))
                                       aux_cdposini = aux_cdposini + 2.
    
                                IF aux_cdmotivo = "" THEN NEXT.                
                    
                                /* buscar os motivos da ocorrencia */
                                FIND FIRST crapmot WHERE crapmot.cdcooper = 
                                                         tt-consulta-blt.cdcooper
                                                     AND crapmot.cddbanco = 
                                                         tt-consulta-blt.cdbandoc
                                                     AND crapmot.cdocorre = 
                                                         tt-consulta-blt.cdocorre
                                                     AND crapmot.tpocorre = 
                                                         2 /* Mot. do retorno */
                                                     AND crapmot.cdmotivo = 
                                                         aux_cdmotivo
                                                     NO-LOCK NO-ERROR.
                    
                                IF  AVAIL crapmot THEN DO:
                                    ASSIGN aux_dsmotivo = 
                                       (IF aux_dsmotivo <> "" THEN
                                           aux_dsmotivo + " / " + crapmot.dsmotivo
                                        ELSE
                                           crapmot.dsmotivo)
                                           aux_cdnrmoti = aux_cdnrmoti + 1.
                                END.
                            END. /* END do DO 1 TO 5 */
                
                            IF  aux_cdnrmoti > 0 THEN
                                tt-consulta-blt.dsmotivo = TRIM(crapret.cdmotivo) + 
                                                           " - " + aux_dsmotivo.
                            ELSE
                                tt-consulta-blt.dsmotivo = TRIM(crapret.cdmotivo).
    
                        END.  /* FOR EACH craprtc */

                    END. /* FOR EACH crapcco */
                    
                    FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE tt-consulta-blt  THEN
                         tt-consulta-blt.nrregist = aux_nrregist.


         END. /* END do WHEN 14 */
         WHEN 15 THEN      /* Resumo das Carteiras */
                DO:
                    /* Em Aberto */
                    FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper
                        NO-LOCK
                        ,EACH crapceb WHERE
                              crapceb.cdcooper = crapcco.cdcooper  AND
                              crapceb.nrconven = crapcco.nrconven
                              NO-LOCK:

                        ASSIGN aux_dsorgarq = "".

                        DO aux_data = p-ini-emissao TO p-fim-emissao:

                            FOR EACH crapcob WHERE 
                                     crapcob.cdcooper = crapcco.cdcooper    AND
                                     crapcob.nrdconta = crapceb.nrdconta    AND
                                     crapcob.nrcnvcob = crapcco.nrconven    AND
                                     crapcob.dtmvtolt = aux_data            AND
                                     crapcob.incobran = 0 
                                     NO-LOCK:

                                ASSIGN aux_dsorgarq = crapcco.dsorgarq.

                                RUN p_grava_bloqueto(INPUT p-cdcooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT crapdat.dtmvtoan,
                                                     INPUT p-num-registros,
                                                     INPUT p-ini-sequencia,
                                                     INPUT-OUTPUT aux_nmdobnfc,
                                                     INPUT-OUTPUT aux_contaant,
                                                     INPUT-OUTPUT aux_sqttlant,
                                              INPUT-OUTPUT par_qtregist,
                                                    OUTPUT TABLE tt-consulta-blt).

                            END.
                        END.
                    END.

                    /* Copia a TT retorno para o buffer (BKP) */
                    FOR EACH tt-consulta-blt NO-LOCK:
                        BUFFER-COPY tt-consulta-blt TO btt-consulta-blt.
                    END.
 
                    ASSIGN aux_contaant = 0
                           aux_sqttlant = 0.

                    /* Liquidados */
                    FOR EACH crapcob WHERE crapcob.cdcooper  = p-cdcooper    AND
                                           crapcob.incobran  = 5             AND
                                           crapcob.dtdpagto >= p-ini-emissao AND
                                           crapcob.dtdpagto <= p-fim-emissao
                                           NO-LOCK:

                        FIND crapcco WHERE crapcco.cdcooper = p-cdcooper   AND
                                           crapcco.nrconven = crapcob.nrcnvcob
                                           NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapcco  THEN
                             aux_dsorgarq = crapcco.dsorgarq.
                        ELSE
                             aux_dsorgarq = "".

                        RUN p_grava_bloqueto(INPUT p-cdcooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT crapdat.dtmvtoan,
                                             INPUT p-num-registros,
                                             INPUT p-ini-sequencia,
                                             INPUT-OUTPUT aux_nmdobnfc,
                                             INPUT-OUTPUT aux_contaant,
                                             INPUT-OUTPUT aux_sqttlant,
                                      INPUT-OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-consulta-blt).
                    END.
                    
                    /* Copia o BKP para a TT de retorno */
                    FOR EACH btt-consulta-blt NO-LOCK:
                        BUFFER-COPY btt-consulta-blt TO tt-consulta-blt.
                    END.

         END. /* END do WHEN 15 */
         WHEN 16 THEN  /* Relatorio Cetente - 7 - Titulo Descontado */         
         DO:
              /*Listar Titulos em aberto*/
              FOR EACH craptdb WHERE craptdb.cdcooper = p-cdcooper AND
                                     craptdb.nrdconta = p-nro-conta AND
                                     craptdb.dtvencto >= crapdat.dtmvtolt and
                                     craptdb.insittit = 4 NO-LOCK,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                     crapcob.dtmvtolt >= p-ini-emissao     AND
                                     crapcob.dtmvtolt <= p-fim-emissao     AND
                                     crapcob.flgregis = p-flgregis       
                                     NO-LOCK
                                     BY crapcob.flgregis DESC
                                     BY crapcob.cdbandoc DESC
                                     BY crapass.nrdconta:

                  RUN cria_tt-consulta-blt_tdb 
                                      (INPUT p-cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT crapdat.dtmvtoan,
                                       INPUT "A" , /* par_cdsituac*/
                                       INPUT aux_nmdobnfc,
                                      OUTPUT TABLE tt-consulta-blt).
                  ASSIGN aux_nrregist = aux_nrregist + 1.
                  
              END.
              
              FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
              IF   AVAILABLE tt-consulta-blt  THEN
                  tt-consulta-blt.nrregist = aux_nrregist.
              
              /*Listar Titulos em vencidos*/
              FOR EACH craptdb WHERE craptdb.cdcooper = p-cdcooper AND
                                     craptdb.nrdconta = p-nro-conta AND
                                     craptdb.dtvencto < crapdat.dtmvtolt and
                                     craptdb.insittit = 4 NO-LOCK,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                     crapcob.dtmvtolt >= p-ini-emissao     AND
                                     crapcob.dtmvtolt <= p-fim-emissao     AND
                                     crapcob.flgregis = p-flgregis       
                                     NO-LOCK
                                     BY crapcob.flgregis DESC
                                     BY crapcob.cdbandoc DESC
                                     BY crapass.nrdconta:
                  
                  RUN cria_tt-consulta-blt_tdb 
                                      (INPUT p-cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT crapdat.dtmvtoan,
                                       INPUT "V" , /* par_cdsituac*/
                                       INPUT aux_nmdobnfc,
                                      OUTPUT TABLE tt-consulta-blt).
                                      
                  ASSIGN aux_nrregist = aux_nrregist + 1.
                  
              END.
              
              FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
              IF   AVAILABLE tt-consulta-blt  THEN
                  tt-consulta-blt.nrregist = aux_nrregist.
                  
             /*Listar Baixados sem pagamento*/
             FOR EACH craptdb WHERE craptdb.cdcooper = p-cdcooper AND
                                    craptdb.nrdconta = p-nro-conta AND
                                    craptdb.insittit = 3 NO-LOCK,
                 EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                    crapcob.nrdconta = craptdb.nrdconta AND
                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                    crapcob.nrdocmto = craptdb.nrdocmto AND
                                    crapcob.dtmvtolt >= p-ini-emissao     AND
                                    crapcob.dtmvtolt <= p-fim-emissao     AND
                                    crapcob.flgregis = p-flgregis       
                                    NO-LOCK
                                    BY crapcob.flgregis DESC
                                    BY crapcob.cdbandoc DESC
                                    BY crapass.nrdconta:
                                    
                  RUN cria_tt-consulta-blt_tdb 
                                      (INPUT p-cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT crapdat.dtmvtoan,
                                       INPUT "B" , /* par_cdsituac*/
                                       INPUT aux_nmdobnfc,
                                      OUTPUT TABLE tt-consulta-blt).
                  
                  ASSIGN aux_nrregist = aux_nrregist + 1.
                  
             END.
              
             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
             IF   AVAILABLE tt-consulta-blt  THEN
                 tt-consulta-blt.nrregist = aux_nrregist.     
             
             /*Listar Titulos pagos*/
             FOR EACH craptdb WHERE craptdb.cdcooper = p-cdcooper AND
                                    craptdb.nrdconta = p-nro-conta AND
                                    craptdb.insittit = 2 NO-LOCK,
                 EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                    crapcob.nrdconta = craptdb.nrdconta AND
                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                    crapcob.nrdocmto = craptdb.nrdocmto AND
                                    crapcob.dtmvtolt >= p-ini-emissao     AND
                                    crapcob.dtmvtolt <= p-fim-emissao     AND
                                    crapcob.flgregis = p-flgregis       
                                    NO-LOCK
                                    BY crapcob.flgregis DESC
                                    BY crapcob.cdbandoc DESC
                                    BY crapass.nrdconta:
                                    
                  RUN cria_tt-consulta-blt_tdb 
                                      (INPUT p-cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT crapdat.dtmvtoan,
                                       INPUT "P" , /* par_cdsituac*/
                                       INPUT aux_nmdobnfc,
                                      OUTPUT TABLE tt-consulta-blt).
                  
                  ASSIGN aux_nrregist = aux_nrregist + 1.
                  
             END.
              
             FIND LAST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
             IF   AVAILABLE tt-consulta-blt  THEN
                 tt-consulta-blt.nrregist = aux_nrregist.
             
             FIND FIRST tt-consulta-blt EXCLUSIVE-LOCK NO-ERROR.
             IF   AVAILABLE tt-consulta-blt  THEN
             DO:
             
               RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
               
               /* Valor total de Descontos */
               RUN busca_total_descontos IN h-b1wgen0030 (INPUT p-cdcooper ,
                                                          INPUT 0,     /** agencia  **/
                                                          INPUT 0,     /** caixa    **/
                                                          INPUT 0,
                                                          INPUT crapdat.dtmvtolt,
                                                          INPUT p-nro-conta,
                                                          INPUT 1,     /** idseqttl **/
                                                          INPUT 1,     /** origem   **/
                                                          INPUT "INTERNETBANK",
                                                          INPUT FALSE, /** log      **/
                                                         OUTPUT TABLE tt-tot_descontos).

               /* Busca saldo e limite de desconto de titulos */
               FIND FIRST craplim WHERE craplim.cdcooper = p-cdcooper  AND
                                        craplim.nrdconta = p-nro-conta AND
                                        craplim.tpctrlim = 3           AND
                                        craplim.insitlim = 2        
                                        NO-LOCK NO-ERROR.
               
               FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.
               IF  AVAILABLE tt-tot_descontos  THEN
               DO:
                 ASSIGN tt-consulta-blt.vllimtit = tt-tot_descontos.vllimtit
                        tt-consulta-blt.vltdscti = tt-tot_descontos.vldsctit
                        tt-consulta-blt.nrctrlim_ativo = craplim.nrctrlim WHEN AVAIL craplim.
               
               END.
               
               DELETE PROCEDURE h-b1wgen0030.
             END.
             
         END. /* END do WHEN 16 */   

    END CASE.
	
    /*Bloco para tratamento de erro do create da lcm try catch*/
    CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      
      ASSIGN aux_dscritic = eSysError:GetMessage(1).
     
      RUN valida_caracteres(INPUT aux_dscritic,
		 				    OUTPUT aux_dscritic).
      
      FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
      
      UNIX SILENT VALUE("echo " +  STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.consulta-bloqueto ' --> '" + aux_dscritic  +                          
                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/proc_message.log").
      RETURN "NOK".
    END CATCH.
    
END PROCEDURE. /* consulta-bloqueto */

PROCEDURE p_grava_bloqueto:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

   DEF INPUT-OUTPUT PARAM par_nmprimtl AS CHAR                     NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_contaant LIKE crapass.nrdconta       NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_sqttlant LIKE crapttl.idseqttl       NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                     NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-consulta-blt.

   Cria: DO ON ERROR UNDO, LEAVE:
        
        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            LEAVE Cria.
    
        IF  aux_nrregis1 > 0 THEN
            DO:
                RUN cria_tt-consulta-blt( INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_dtlimite,
                                          INPUT-OUTPUT par_nmprimtl,
                                          INPUT-OUTPUT par_contaant,
                                          INPUT-OUTPUT par_sqttlant,
                                         OUTPUT TABLE tt-consulta-blt).

				IF RETURN-VALUE = "NOK" THEN
					RETURN RETURN-VALUE.
            END.
    
        ASSIGN aux_nrregis1 = aux_nrregis1 - 1.
    
        LEAVE Cria.

    END. /* Cria */

    RETURN "OK".

END PROCEDURE. /* p_grava_bloqueto */

PROCEDURE p_grava_bloqueto_rej:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

   DEF INPUT-OUTPUT PARAM par_nmprimtl AS CHAR                     NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_contaant LIKE crapass.nrdconta       NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_sqttlant LIKE crapttl.idseqttl       NO-UNDO.
   DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                     NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-consulta-blt.

   Cria: DO ON ERROR UNDO, LEAVE:
        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            LEAVE Cria.
    
        IF  aux_nrregis1 > 0 THEN
            DO:
			
                RUN cria_tt-consulta-blt_rej( INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_dtlimite,
                                              INPUT-OUTPUT par_nmprimtl,
                                              INPUT-OUTPUT par_contaant,
                                              INPUT-OUTPUT par_sqttlant,
                                             OUTPUT TABLE tt-consulta-blt).

				IF RETURN-VALUE = "NOK" THEN
				  RETURN RETURN-VALUE.

            END.
    
        ASSIGN aux_nrregis1 = aux_nrregis1 - 1.
    
        LEAVE Cria.

    END. /* Cria */

    RETURN "OK".

END PROCEDURE. /* p_grava_bloqueto */


PROCEDURE busca_instrucoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_cdcoopex AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_cdbandoc AS INTE                NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapoco.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapoco.
        EMPTY TEMP-TABLE tt-erro.

        /* Carrega dados para a tela de instruções */
        FOR EACH crapoco WHERE crapoco.cdcooper = par_cdcoopex
                           AND crapoco.cddbanco = par_cdbandoc
                           AND crapoco.cdocorre > 1
                           AND crapoco.flgativo 
                           AND crapoco.tpocorre = 1 NO-LOCK:
    
            CREATE tt-crapoco.
            ASSIGN tt-crapoco.cdocorre = crapoco.cdocorre
                   tt-crapoco.dsocorre = crapoco.dsocorre
                   tt-crapoco.lsinstru = STRING(crapoco.cdocorre,"99") + ". " + 
                                         crapoco.dsocorre.
        END.

        IF  NOT TEMP-TABLE tt-crapoco:HAS-RECORDS THEN
            ASSIGN aux_dscritic = "Sem registro de instrucoes - Coop/Banco " +
                                  STRING(par_cdcoopex,"99") + "/" + 
                                  STRING(par_cdbandoc,"999").

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* busca_instrucoes */

PROCEDURE valida_instrucoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_cdinstru AS INTE                NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        /* Listagem de instrucoes que existem */
        IF  NOT CAN-FIND(FIRST crapoco WHERE 
                               crapoco.cdcooper = par_cdcooper AND 
                               crapoco.cdocorre = par_cdinstru AND
                               crapoco.flgativo) THEN
            DO:
                ASSIGN aux_dscritic = "Instrucao inativa/inexistente."
                       aux_cdcritic = 0.
                LEAVE Valida.
            END.

        LEAVE Valida.
        
    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* valida_instrucoes */

PROCEDURE grava_instrucoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdinstru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtpinsc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaprt AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
           

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_grava_instr_boleto
                 aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper, /* Cooperativa */ 
                                  INPUT par_dtmvtolt, /* Data */
                                  INPUT par_cdoperad, /* Operador */
                                  INPUT par_cdinstru, /* Instruçao */
                                  INPUT par_nrdconta, /* Conta */
                                  INPUT par_nrcnvcob, /* Convenio */
                                  INPUT par_nrdocmto, /* Boleto */
                                  INPUT par_vlabatim, /* Valor de Abatimento */
                                  INPUT par_dtvencto, /* Data de Vencimetno */
                                  INPUT par_qtdiaprt, /* Quantidade de dias para protesto */
                                 OUTPUT 0,            /* Codigo da Critica */
                                 OUTPUT "").          /* Descricao da Critica */
             
    CLOSE STORED-PROC pc_grava_instr_boleto
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_grava_instr_boleto.pr_cdcritic
                              WHEN pc_grava_instr_boleto.pr_cdcritic <> ?
           aux_dscritic = pc_grava_instr_boleto.pr_dscritic
                              WHEN pc_grava_instr_boleto.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0  OR
        aux_dscritic <> "" THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* grava_instrucoes */

PROCEDURE exporta_boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ininrdoc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_fimnrdoc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inidtven AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtven AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtdpa AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtdpa AS DATE                           NO-UNDO.
    DEF  INPUT PARAM aux_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM aux_fimdtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_consulta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpconsul AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoccop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgregis AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_dtdpagto AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtvencto AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmarqimp = "/micros/" + crabcop.dsdircop + "/compel/" +
                              par_dsiduser

               aux_nmendter = "/micros/" + crabcop.dsdircop + 
                              "/compel/temp.txt".

        RUN consulta-bloqueto
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_ininrdoc,
              INPUT par_fimnrdoc,
              INPUT 0,
              INPUT par_nmprimtl,
              INPUT 0,
              INPUT 999999,
              INPUT 1,
              INPUT par_inidtven,
              INPUT par_fimdtven,
              INPUT par_inidtdpa,
              INPUT par_fimdtdpa,
              INPUT aux_inidtmvt,
              INPUT aux_fimdtmvt,
              INPUT par_consulta, 
              INPUT par_tpconsul,
              INPUT par_idorigem,
              INPUT 0,
              INPUT 0,
              INPUT par_dsdoccop,
              INPUT par_flgregis,
              INPUT 0,
			  INPUT " ",
             OUTPUT aux_qtregist,
             OUTPUT aux_nmdcampo, 
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-consulta-blt).

        OUTPUT STREAM str_1 TO VALUE(aux_nmendter).

        PUT STREAM str_1 UNFORMATTED 
        "PA; Conta/DV;Tipo de Cobranca;Convenio;Nosso numero;CPF/CNPJ Pagador;Nome pagador;" +
        " Data Emissão;Data Vencimento;Vlr Titulo; Data Pagto;Vlr Pagto;Status"
        SKIP.

        FOR EACH tt-consulta-blt:
            
            /* Verifica de a Data do Pagto. foi encontrada */
            IF tt-consulta-blt.dtdpagto = ? THEN
                ASSIGN aux_dtdpagto = "".
            ELSE
                ASSIGN aux_dtdpagto = STRING(tt-consulta-blt.dtdpagto).

            /* Verifica de a Data do Vencto. foi encontrada */
            IF tt-consulta-blt.dtvencto = ? THEN
                ASSIGN aux_dtvencto = "".
            ELSE
                ASSIGN aux_dtvencto = STRING(tt-consulta-blt.dtvencto).

            PUT STREAM str_1 UNFORMATTED
                STRING(tt-consulta-blt.cdagenci) + ";" +
                STRING(tt-consulta-blt.nrdconta) + ";" +
                (IF LOGICAL(par_flgregis) THEN   
                     "Registrada"
                 ELSE
                     "Sem Registro")             + ";" + 
                STRING(tt-consulta-blt.nrcnvcob) + ";" +
                STRING(tt-consulta-blt.nrnosnum) + ";" +
                STRING(tt-consulta-blt.nrinssac) + ";" +
                STRING(tt-consulta-blt.nmdsacad) + ";" +
                STRING(tt-consulta-blt.dtmvtolt) + ";" +
                STRING(aux_dtvencto)             + ";" +
                STRING(tt-consulta-blt.vltitulo) + ";" +
                STRING(aux_dtdpagto)             + ";" +
                STRING(tt-consulta-blt.vldpagto) + ";" +  
                STRING(tt-consulta-blt.dssituac) + ";"
                SKIP.
        END.
    
        OUTPUT STREAM str_1 CLOSE.

        UNIX SILENT VALUE("ux2dos " + aux_nmendter + " > " + aux_nmarqimp).
        UNIX SILENT VALUE("rm " + aux_nmendter).

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    
    RETURN aux_returnvl.

END PROCEDURE. /* exporta_boleto */

PROCEDURE cria_tt-consulta-blt.

   DEF INPUT        PARAM p-cdcooper       AS INTE.
   DEF INPUT        PARAM p-cod-agencia    AS INTE.
   DEF INPUT        PARAM p-nro-caixa      AS INTE.
   DEF INPUT        PARAM p-data-limite    AS DATE.
   DEF INPUT-OUTPUT PARAM p-nmprimtl       AS CHAR.
   DEF INPUT-OUTPUT PARAM p-contaant       LIKE crapass.nrdconta.
   DEF INPUT-OUTPUT PARAM p-sqttlant       LIKE crapttl.idseqttl.

   DEF OUTPUT       PARAM TABLE FOR tt-consulta-blt.

   DEF VAR aux_nossonro AS CHAR FORMAT "x(19)" NO-UNDO.
   DEF VAR aux_flgdesco AS CHAR                NO-UNDO.
   DEF VAR aux_dsstaabr AS CHAR                NO-UNDO.
   DEF VAR aux_dsstacom AS CHAR                NO-UNDO.
   DEF VAR aux_dtsitcrt AS DATE                NO-UNDO.
   DEF VAR aux_vlrmulta AS DECI                NO-UNDO.
   DEF VAR aux_vlrjuros AS DECI                NO-UNDO.

   DEF VAR aux_nmprimtl AS CHAR                NO-UNDO.
   DEF VAR aux_dsdemail AS CHAR                NO-UNDO.
   DEF VAR aux_des_erro AS CHAR                NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                NO-UNDO.
   DEF VAR aux_msgerora AS CHAR                NO-UNDO.
   DEF VAR aux_qterrora AS INTE                NO-UNDO.
   
   DEF VAR aux_npc_cip  AS INTE                NO-UNDO.
   
   IF  NOT AVAILABLE crapcco  THEN
       DO:
           ASSIGN i-cod-erro = 0
                  c-dsc-erro = "Convenio nao cadastrado!".

           {sistema/generico/includes/b1wgen0001.i}

           RETURN "NOK".
       END.

   IF   crapcco.flgutceb THEN
        DO:
            FIND LAST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                    crapceb.nrdconta = crapcob.nrdconta AND
                                    crapceb.nrconven = crapcob.nrcnvcob
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.

            IF  NOT AVAILABLE crapceb  THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-dsc-erro = "Convenio CEB nao cadastrado!".

                    {sistema/generico/includes/b1wgen0001.i}

                    RETURN "NOK".
                END.
            
            IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                ASSIGN aux_nossonro = STRING(crapcob.nrcnvcob,"9999999") +
                                      STRING(crapceb.nrcnvceb,"9999")    +
                                      STRING(crapcob.nrdocmto,"999999").
            ELSE
                ASSIGN aux_nossonro = STRING(crapcob.nrcnvcob,"9999999")    +
                                      STRING(INT(SUBSTR(TRIM(STRING(
                                             crapceb.nrcnvceb, "zzzz9"))
                                             ,1,4)),"9999") +
                                      STRING(crapcob.nrdocmto,"999999").
        END.
    ELSE
        ASSIGN aux_nossonro = STRING(crapcob.nrdconta,"99999999") +
                              STRING(crapcob.nrdocmto,"999999999").
    
    /* Verificar se a crapceb está carregada */ 
    IF NOT AVAILABLE crapceb THEN
    DO:
        /* Se nao foi carregada, buscamos com base no boleto */
        FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper
                             AND crapceb.nrdconta = crapcob.nrdconta
                             AND crapceb.nrconven = crapcob.nrcnvcob
                           NO-LOCK NO-ERROR.
    END.
    
    /* Se a crapceb que foi carregada eh diferente do boleto, carregamos de novo a crapceb */ 
    IF crapceb.cdcooper <> crapcob.cdcooper OR 
       crapceb.nrdconta <> crapcob.nrdconta OR 
       crapceb.nrconven <> crapcob.nrcnvcob THEN
    DO:
        /* Se nao foi carregada, buscamos com base no boleto */
        FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper
                             AND crapceb.nrdconta = crapcob.nrdconta
                             AND crapceb.nrconven = crapcob.nrcnvcob
                           NO-LOCK NO-ERROR.
    END.
   
   
   DO TRANSACTION:

     CREATE tt-consulta-blt.

     FIND crabceb WHERE crabceb.cdcooper = crapcob.cdcooper
                    AND crabceb.nrconven = crapcob.nrcnvcob
                    AND crabceb.nrdconta = crapcob.nrdconta
                    NO-LOCK NO-ERROR.
       
     RUN busca_dados_beneficiario( INPUT crapcob.cdcooper,
                                   INPUT crapcob.nrdconta).
       
     IF AVAIL(crabceb) THEN
     DO:
	    ASSIGN tt-consulta-blt.flprotes = INTE(crabceb.flprotes).
       END.
     ELSE
		DO:
			ASSIGN tt-consulta-blt.flprotes = 0.
		END.
   
     /*  Verifica no Cadastro de Sacados Cobranca */
     FOR FIRST crapass FIELDS(nmprimtl)
         WHERE crapass.cdcooper = crapcob.cdcooper AND
               crapass.nrdconta = crapcob.nrdconta
               NO-LOCK: END.

     FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper AND
                        crapsab.nrdconta = crapcob.nrdconta AND
                        crapsab.nrinssac = crapcob.nrinssac NO-LOCK NO-ERROR.

     IF  AVAILABLE crapsab  THEN
         DO:
         ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapsab.nmdsacad,"&","%26")
                tt-consulta-blt.dsendsac = TRIM(TRIM(crapsab.dsendsac) + 
                                           IF crapsab.nrendsac > 0 THEN
                                              ", " + STRING(crapsab.nrendsac)
                                           ELSE "")
                tt-consulta-blt.nmdsacad = (IF tt-consulta-blt.nmdsacad <> ? THEN tt-consulta-blt.nmdsacad ELSE " ")
                tt-consulta-blt.dsendsac = (IF tt-consulta-blt.dsendsac <> ? THEN tt-consulta-blt.dsendsac ELSE " ")                                           
                tt-consulta-blt.complend = (IF crapsab.complend <> ? THEN crapsab.complend ELSE " ")
                tt-consulta-blt.nmbaisac = (IF crapsab.nmbaisac <> ? THEN crapsab.nmbaisac ELSE " ")
                tt-consulta-blt.nmcidsac = (IF crapsab.nmcidsac <> ? THEN crapsab.nmcidsac ELSE " ")
                tt-consulta-blt.cdufsaca = (IF crapsab.cdufsaca <> ? THEN crapsab.cdufsaca ELSE " ")
                    tt-consulta-blt.nrcepsac = crapsab.nrcepsac.
                    
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

             RUN STORED-PROCEDURE pc_busca_emails_pagador
                 aux_handproc = PROC-HANDLE NO-ERROR
                                         (INPUT crapsab.cdcooper,
                                          INPUT crapsab.nrdconta,
                                          INPUT crapsab.nrinssac,
                                         OUTPUT "",  /* pr_dsdemail */
                                         OUTPUT "",  /* pr_des_erro */
                                         OUTPUT ""). /* pr_dscritic */
             
             IF  ERROR-STATUS:ERROR  THEN DO:
       
                 ASSIGN aux_msgerora = ERROR-STATUS:GET-MESSAGE(ERROR-STATUS:NUM-MESSAGES).
                 
                 RUN valida_caracteres(INPUT aux_msgerora,
									   OUTPUT aux_msgerora).
                 
                 FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                 
                 UNIX SILENT VALUE("echo " + 
                                   STRING(TIME,"HH:MM:SS") + " - B1WGEN0010 Run pc_busca_emails_pagador  ' --> '" + aux_msgerora +                          
                                   " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                   "/log/proc_message.log").       
			     RETURN "NOK".
				 
             END.
             
             CLOSE STORED-PROC pc_busca_emails_pagador
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             ASSIGN aux_dsdemail = ""
                    aux_dscritic = ""
                    aux_des_erro = ""
                    aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                                       WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
                    aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                                       WHEN pc_busca_emails_pagador.pr_dscritic <> ?
                    aux_des_erro = pc_busca_emails_pagador.pr_des_erro
                                       WHEN pc_busca_emails_pagador.pr_des_erro <> ?.

              IF  aux_des_erro <> "OK" OR
                  aux_dscritic <> ""   THEN DO: 
                  
                  IF  aux_dscritic = "" THEN DO:   
                      ASSIGN aux_dscritic =  "Nao foi possivel buscar o email do pagador para ser impresso no boleto".
                  END.
                  
                  RUN valida_caracteres(INPUT aux_dscritic,
										OUTPUT aux_dscritic).
                  
                  FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                   
                  UNIX SILENT VALUE("echo " + 
                                    STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.cria_tt-consulta-blt3 ' --> '" + aux_dscritic +                          
                                    " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                    "/log/proc_message.log").
                  RETURN "NOK".
               END.
              
              ASSIGN tt-consulta-blt.dsdemail = aux_dsdemail
                     tt-consulta-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN TRUE ELSE FALSE).
         END.
                                            ELSE 
         ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapcob.nmdsacad,"&","%26")
                tt-consulta-blt.flgemail = FALSE.

      ASSIGN tt-consulta-blt.nmdavali = REPLACE(crapcob.nmdavali,"&","%26")
             tt-consulta-blt.cdtpinav = crapcob.cdtpinav
             tt-consulta-blt.nrinsava = crapcob.nrinsava
             tt-consulta-blt.vlrjuros = crapcob.vljurpag
             tt-consulta-blt.vlrmulta = crapcob.vlmulpag.

     /*Se mudou a conta devo busca o beneficiario*/
     RUN controla-busca-nmdobnfc(INPUT crapcob.cdcooper
                                ,INPUT crapcob.nrdconta
                                ,INPUT crapcob.idseqttl
                                ,INPUT "cria_tt-consulta-blt"
                                ,INPUT-OUTPUT p-contaant /* Conta anterior */ 
                                ,INPUT-OUTPUT p-sqttlant /* Sequencia do titular anterior */ 
                                ,INPUT-OUTPUT p-nmprimtl
                                ,OUTPUT aux_dscritic).

     IF  RETURN-VALUE <> "OK" THEN
         DO:             
            IF  aux_dscritic = "" THEN DO:   
                ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario.".
            END.
                  
            RUN valida_caracteres(INPUT  aux_dscritic,
                                  OUTPUT aux_dscritic).
                  
            FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
                   
            UNIX SILENT VALUE("echo " + 
                            STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.cria_tt-consulta-blt b1 ' --> '" + aux_dscritic +                          
                            " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                            "/log/proc_message.log").

            RETURN "NOK".
         END.                      

     /* Verificar se a crapdat está carregada */ 
     IF NOT AVAILABLE crapdat THEN
     DO:
       FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
     END.

     /* Consulta se titulo esta na faixa de rollout e integrado na cip */
     RUN verifica-titulo-npc-cip(INPUT crapcob.cdcooper,
                                 INPUT crapdat.dtmvtolt,
                                 INPUT crapcob.vltitulo,
                                 INPUT crapcob.flgcbdda,
                                 OUTPUT aux_npc_cip).

     ASSIGN tt-consulta-blt.cdcooper = crapcob.cdcooper
            tt-consulta-blt.nrdconta = crapcob.nrdconta
            tt-consulta-blt.nmprimtl = p-nmprimtl
            tt-consulta-blt.idseqttl = crapcob.idseqttl
            tt-consulta-blt.nossonro = aux_nossonro
            tt-consulta-blt.incobran = IF  crapcob.incobran = 0  THEN
                                           "N"
                                       ELSE
                                       IF  crapcob.incobran = 3  THEN
                                           "B"
                                       ELSE
                                           "C"
            tt-consulta-blt.nrdocmto = crapcob.nrdocmto
            tt-consulta-blt.dsdoccop = crapcob.dsdoccop
            tt-consulta-blt.nrdctabb = crapcob.nrdctabb
            tt-consulta-blt.nrcnvcob = crapcob.nrcnvcob
            tt-consulta-blt.dtmvtolt = (IF crapcob.dtmvtolt = ? THEN
                                           crapcob.dtdpagto
                                        ELSE
                                           crapcob.dtmvtolt)
            tt-consulta-blt.dtretcob = crapcob.dtretcob
            tt-consulta-blt.dtdpagto = crapcob.dtdpagto
            tt-consulta-blt.dtdbaixa = crapcob.dtdbaixa
            tt-consulta-blt.cdbandoc = crapcob.cdbandoc
            tt-consulta-blt.vldpagto = crapcob.vldpagto
            tt-consulta-blt.dtvencto = (IF crapcob.dtvencto = ? THEN
                                           crapcob.dtdpagto
                                        ELSE
                                           crapcob.dtvencto)
            tt-consulta-blt.dtvctori = crapcob.dtvctori /* P340 - Rafael */
            tt-consulta-blt.dtbloqueio = crapcob.dtbloque
            tt-consulta-blt.vltitulo = crapcob.vltitulo
                        tt-consulta-blt.insitcrt = crapcob.insitcrt
            tt-consulta-blt.nrinssac = crapcob.nrinssac
            tt-consulta-blt.cdtpinsc = crapcob.cdtpinsc
            tt-consulta-blt.vltarifa = crapcob.vltarifa
            tt-consulta-blt.flgregis = IF  crapcob.flgregis = TRUE  THEN
                                           " S"
                                       ELSE
                                           " N"
            tt-consulta-blt.flgaceit = IF  crapcob.flgaceit = TRUE  THEN
                                           " S"
                                       ELSE
                                           " N"
            tt-consulta-blt.inemiten = crapcob.inemiten
            tt-consulta-blt.nrnosnum = crapcob.nrnosnum
            tt-consulta-blt.dtdocmto = (IF crapcob.dtdocmto = ? THEN 
                                           IF  crapcob.dtdpagto = ? THEN
                                               crapcob.dtmvtolt
                                           ELSE
                                               crapcob.dtdpagto
                                        ELSE
                                           crapcob.dtdocmto)
            tt-consulta-blt.cddespec = crapcob.cddespec
            tt-consulta-blt.vldescto = (IF (crapcob.cdmensag = 1  OR   /* Desconto ate o vencimento */
                                            crapcob.cdmensag = 2) THEN /* Desconto apos o vencimento */ 
                                            crapcob.vldescto
                                        ELSE
                                            0)
            tt-consulta-blt.vlabatim = crapcob.vlabatim
            tt-consulta-blt.flgcbdda = (IF aux_npc_cip = 1 THEN "S" ELSE "N").

     /* Tratamento para Negativaçao Serasa e Protesto */ 
     ASSIGN tt-consulta-blt.flserasa = crapcob.flserasa
            tt-consulta-blt.qtdianeg = crapcob.qtdianeg
            tt-consulta-blt.inserasa = STRING(crapcob.inserasa)
            tt-consulta-blt.cdserasa = crapcob.inserasa
            tt-consulta-blt.flgdprot = crapcob.flgdprot
            tt-consulta-blt.qtdiaprt = crapcob.qtdiaprt
            tt-consulta-blt.insitcrt = crapcob.insitcrt.

     /* Se o boleto nao possui as informacoes de Negativacao, vamos buscar do convenio */
     IF (tt-consulta-blt.flserasa = FALSE OR 
         tt-consulta-blt.qtdianeg = 0)  AND
         tt-consulta-blt.inserasa = "0" THEN
     DO:
         IF NOT (tt-consulta-blt.flgdprot = TRUE AND 
                 tt-consulta-blt.qtdiaprt > 0)   THEN
         DO:
             ASSIGN tt-consulta-blt.qtdianeg = 0
                    tt-consulta-blt.flserasa = crapceb.flserasa.
         END.
         ELSE 
             DO:
                 ASSIGN tt-consulta-blt.qtdianeg = 0
                        tt-consulta-blt.flserasa = FALSE.
             END.
     END.

     /* Se o boleto nao possui as informacoes de Protesto, vamos buscar do convenio */
     IF tt-consulta-blt.flgdprot = FALSE OR 
        tt-consulta-blt.qtdiaprt = 0     THEN
     DO:
         IF NOT (tt-consulta-blt.flserasa = TRUE AND 
                 tt-consulta-blt.qtdianeg > 0)   OR
                 tt-consulta-blt.inserasa <> "0" THEN
         DO:
             ASSIGN tt-consulta-blt.qtdiaprt = 0
                    tt-consulta-blt.flgdprot = crapceb.flprotes.
         END.
         ELSE 
             DO:
                 ASSIGN tt-consulta-blt.qtdiaprt = 0
                        tt-consulta-blt.flgdprot = FALSE.
             END.
     END.

     /* Verificar se o boleto pertence a um carne.
        O boleto de um carne eh criado na crapcol com a informacao "CARNE"
        na coluna crapcol.dslogtit */
     FIND FIRST crapcol WHERE crapcol.cdcooper = crapcob.cdcooper
                          AND crapcol.nrdconta = crapcob.nrdconta
                          AND crapcol.nrdocmto = crapcob.nrdocmto
                          AND crapcol.nrcnvcob = crapcob.nrcnvcob
                          AND upper(crapcol.dslogtit) MATCHES "*CARNE*"
                        NO-LOCK NO-ERROR.
     tt-consulta-blt.flgcarne = (IF AVAIL crapcol THEN
                                     TRUE
                                 ELSE 
                                     FALSE).

     CASE tt-consulta-blt.inemiten:
         WHEN 1 THEN ASSIGN tt-consulta-blt.dsemiten = "1-BCO"
                            tt-consulta-blt.dsemitnt = "BCO".
         WHEN 2 THEN ASSIGN tt-consulta-blt.dsemiten = "2-COO"
                            tt-consulta-blt.dsemitnt = "COO".
         WHEN 3 THEN ASSIGN tt-consulta-blt.dsemiten = "3-CEE"
                            tt-consulta-blt.dsemitnt = "CEE".

     END CASE.

     CASE tt-consulta-blt.cddespec:
        WHEN  1 THEN tt-consulta-blt.dsdespec = "DM".
        WHEN  2 THEN tt-consulta-blt.dsdespec = "DS".
        WHEN  3 THEN tt-consulta-blt.dsdespec = "NP".
        WHEN  4 THEN tt-consulta-blt.dsdespec = "MENS".
        WHEN  5 THEN tt-consulta-blt.dsdespec = "NF".
        WHEN  6 THEN tt-consulta-blt.dsdespec = "RECI".
        WHEN  7 THEN tt-consulta-blt.dsdespec = "OUTR".
     END CASE.

     IF NOT AVAIL(crapcop) THEN
        FIND FIRST crapcop 
             WHERE crapcop.cdcooper = crapcob.cdcooper
                   NO-LOCK NO-ERROR.

     IF   crapcob.cdbanpag = 11 THEN
             ASSIGN tt-consulta-blt.cdbanpag = STRING(crapcop.cdbcoctl,"999")
                    tt-consulta-blt.cdagepag = STRING(crapcop.cdagectl,"9999")
                    tt-consulta-blt.dsbcoage = "COOP.".
     ELSE
            IF crapcob.cdbanpag > 0 THEN
               ASSIGN tt-consulta-blt.cdbanpag = STRING(crapcob.cdbanpag,"999")
                      tt-consulta-blt.cdagepag = STRING(crapcob.cdagepag,"9999")
                      tt-consulta-blt.dsbcoage = STRING(crapcob.cdbanpag,"999") + " / " + 
                         STRING(crapcob.cdagepag,"9999").

     IF  crapcob.dtdpagto = ? AND crapcob.incobran = 0  THEN
         DO:
             IF  crapcob.dtvencto <= p-data-limite THEN
                 ASSIGN tt-consulta-blt.cdsituac = "V".
             ELSE
                 ASSIGN tt-consulta-blt.cdsituac = "A".
         END.                       
     ELSE
     IF  crapcob.dtdpagto <> ? AND crapcob.dtdbaixa = ?  THEN
         ASSIGN tt-consulta-blt.cdsituac = "L".
     ELSE
     IF  crapcob.dtdbaixa <> ?  OR crapcob.incobran = 3 THEN 
         ASSIGN tt-consulta-blt.cdsituac = "B".
     ELSE
     IF  crapcob.dtelimin <> ?  THEN
         ASSIGN tt-consulta-blt.cdsituac = "E".

     CASE tt-consulta-blt.cdsituac:
          WHEN "A" THEN tt-consulta-blt.dssituac = "ABERTO".
          WHEN "V" THEN tt-consulta-blt.dssituac = "VENCIDO".
          WHEN "B" THEN tt-consulta-blt.dssituac = "BAIXADO".
          WHEN "E" THEN tt-consulta-blt.dssituac = "EXCLUIDO".
          WHEN "L" THEN tt-consulta-blt.dssituac = "LIQUIDADO".
     END CASE. 


     FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
     CASE crapcob.incobran:
         WHEN 0 THEN DO: 
             CASE crapcob.insitcrt:
                 WHEN 1 THEN DO:
                     IF  crapcob.dtvencto < crapdat.dtmvtolt THEN
                         ASSIGN aux_dsstaabr = "INS"
                                aux_dsstacom = "C/ INST PROT"
                                aux_dtsitcrt = crapcob.dtsitcrt.
                     ELSE
                         ASSIGN aux_dsstaabr = "ABE"
                                aux_dsstacom = "ABERTO"
                                aux_dtsitcrt = ?.
                 END.

                 WHEN 2 THEN DO: 
                    IF crapcob.cdbandoc = 001 THEN
                        ASSIGN aux_dsstaabr = "INS"
                                    aux_dsstacom = "C/ INST SUST"
                                    aux_dtsitcrt = crapcob.dtsitcrt.
                    ELSE
                        ASSIGN aux_dsstaabr = "INS"
                               aux_dsstacom = "REM CARTORIO "
                               aux_dtsitcrt = crapcob.dtsitcrt.                                  
                 END.
                 WHEN 3 THEN ASSIGN aux_dsstaabr = "CAR"
                                    aux_dsstacom = "EM CARTORIO"
                                    aux_dtsitcrt = crapcob.dtsitcrt.
                 WHEN 4 THEN ASSIGN aux_dsstaabr = "SUS"
                                    aux_dsstacom = "SUSTADO"
                                    aux_dtsitcrt = crapcob.dtsitcrt.

                 /* se não for nenhuma dos opções acima, então aberto
                    Rafael Cechet - 30/03/11 */
                 OTHERWISE ASSIGN aux_dsstaabr = "ABE"
                                  aux_dsstacom = "ABERTO"
                                  aux_dtsitcrt = ?.

             END CASE.
         END.
         WHEN 3 THEN DO:
            CASE crapcob.insitcrt:
                WHEN 5 THEN ASSIGN aux_dsstaabr = "PRT"
                                   aux_dsstacom = "PROTESTADO"
                                   aux_dtsitcrt = crapcob.dtsitcrt.
                OTHERWISE ASSIGN aux_dsstaabr = "BX"
                                   aux_dsstacom = "BAIXADO"
                                   aux_dtsitcrt = ?.
            END.
         END.
         WHEN 4 THEN ASSIGN aux_dsstaabr = "REJ"
                            aux_dsstacom = "REJEITADO"
                            aux_dtsitcrt = ?.
         WHEN 5 THEN DO:
             IF  crapcob.dtdpagto <> ?  THEN
                 ASSIGN aux_dsstaabr = "LIQ"
                        aux_dsstacom = "LIQUIDADO"
                        aux_dtsitcrt = ?.
             ELSE
                 ASSIGN aux_dsstaabr = "EXC"
                        aux_dsstacom = "EXCLUIDO"
                        aux_dtsitcrt = ?.
         END.
         OTHERWISE ASSIGN aux_dsstaabr = "ABE"
                          aux_dsstacom = "ABERTO"
                          aux_dtsitcrt = ?.
     END CASE.

     ASSIGN tt-consulta-blt.dsstaabr = aux_dsstaabr
            tt-consulta-blt.dsstacom = aux_dsstacom
            tt-consulta-blt.dtsitcrt = aux_dtsitcrt
            tt-consulta-blt.dssituac = IF crapcob.flgregis THEN 
                                          aux_dsstacom
                                       ELSE
                                          tt-consulta-blt.dssituac.

         IF crapcob.incobran = 5 AND
            crapcob.dtdpagto <> ? AND
                NOT tt-consulta-blt.flgdprot = FALSE AND
                crapcob.insitcrt <> 0 THEN
         DO:
                CASE crapcob.insitcrt:
           WHEN 3 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/EM CARTORIO".
        END CASE.
         END.

     IF crapcob.inserasa <> 0 THEN
     DO:
     
        CASE crapcob.inserasa:
           WHEN 1 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/ENVIADO A SERASA".
           WHEN 2 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/ENVIADO A SERASA".
           WHEN 3 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/ENVIADO CANCEL. SERASA".
           WHEN 4 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/ENVIADO CANCEL. SERASA".
           WHEN 5 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/INTEGRADO NA SERASA".
           WHEN 6 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/FALHA NA SERASA".
           WHEN 7 THEN ASSIGN tt-consulta-blt.dssituac =
                              tt-consulta-blt.dssituac + "/ACAO JUDICIAL SERASA".
        END CASE.
     END.

     FIND LAST craptdb 
         WHERE craptdb.cdcooper = crapcob.cdcooper   AND
               craptdb.nrdconta = crapcob.nrdconta   AND
               craptdb.cdbandoc = crapcob.cdbandoc   AND
               craptdb.nrdctabb = crapcob.nrdctabb   AND
               craptdb.nrcnvcob = crapcob.nrcnvcob   AND
               craptdb.nrdocmto = crapcob.nrdocmto   NO-LOCK NO-ERROR.

     /* esperando criar novo campo na crapcob - Rafael (remover) */
     IF  TRIM(crapcob.dcmc7chq) <> "" THEN
         ASSIGN tt-consulta-blt.dssituac = tt-consulta-blt.dssituac + "/" +
                                           ENTRY(1,crapcob.dcmc7chq,";").

     IF   AVAILABLE craptdb AND craptdb.insitapr <> 2 THEN
          DO:
              ASSIGN tt-consulta-blt.nrborder = craptdb.nrborder.

              CASE craptdb.insittit:
                   WHEN 0 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD PENDENTE"
                                      aux_flgdesco             = "".
                   WHEN 1 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD RESGATADO"
                                      aux_flgdesco             = "".
                   WHEN 2 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD PAGO"
                                      aux_flgdesco             = "*".
                   WHEN 3 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD VENCIDO"
                                      aux_flgdesco             = "*".
                   WHEN 4 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD LIBERADO"
                                      aux_flgdesco             = "*".
              END CASE.
          END.

     IF   tt-consulta-blt.cdsituac = "L" THEN
          CASE crapcob.indpagto:
               WHEN 0 THEN DO:
                               IF   crapcob.incobran = 5  AND
                                    crapcob.vldpagto > 0  THEN
                                    tt-consulta-blt.dsdpagto = "COMPENSACAO".
                               ELSE 
                                    tt-consulta-blt.dsdpagto = "".
                           END.                       
               WHEN 1 THEN tt-consulta-blt.dsdpagto = "CAIXA".
               WHEN 2 THEN tt-consulta-blt.dsdpagto = "LANCOB".
               WHEN 3 THEN tt-consulta-blt.dsdpagto = "INTERNET".
               WHEN 4 THEN tt-consulta-blt.dsdpagto = "TAA".
          END CASE.                    
     ELSE
          tt-consulta-blt.dsdpagto = "".

     ASSIGN tt-consulta-blt.dsorgarq = aux_dsorgarq
            tt-consulta-blt.flgdesco = aux_flgdesco.
            
     FIND crapass WHERE
          crapass.cdcooper = tt-consulta-blt.cdcooper   AND
          crapass.nrdconta = tt-consulta-blt.nrdconta   NO-LOCK NO-ERROR.
     IF   AVAIL crapass   THEN
          ASSIGN tt-consulta-blt.cdagenci = crapass.cdagenci.

     /* gravar na temptable agencia da cooperativa
        Utilizado na internet - Rafael Cechet - 01/04/11 */
     IF tt-consulta-blt.cdbandoc = 085 THEN 
     DO:
          FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
          ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagectl,"9999").
     END.
     ELSE
     DO:
         FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
         ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagedbb,"99999").
     END.

     /* MULTA PARA ATRASO */
     ASSIGN aux_vlrmulta = crapcob.vlrmulta
     /* MORA PARA ATRASO */
            aux_vlrjuros =  crapcob.vljurdia.
                             
     ASSIGN tt-consulta-blt.dscjuros = IF crapcob.tpjurmor = 1 THEN
                                           "R$ " + 
                                      TRIM(STRING(aux_vlrjuros, "z,zz9.99")) + 
                                            " a.d."
                                       ELSE IF crapcob.tpjurmor = 2 THEN
                                           STRING(aux_vlrjuros, "z9.99") + 
                                           "% a.m."
                                       ELSE IF crapcob.tpjurmor = 3 THEN
                                           "ISENTO"
                                       ELSE ""
            tt-consulta-blt.dscmulta = IF crapcob.tpdmulta = 1 THEN
                                           "R$ " + 
                                        TRIM(STRING(aux_vlrmulta, "z,zz9.99"))
                                       ELSE IF crapcob.tpdmulta = 2 THEN
                                           STRING(aux_vlrmulta, "z9.99") + "%"
                                       ELSE IF crapcob.tpdmulta = 3 THEN
                                           "ISENTO"
                                       ELSE ""
            tt-consulta-blt.dscdscto = IF crapcob.cdmensag = 1 THEN
                                           "R$ " + 
                                   TRIM(STRING(crapcob.vldescto, "z,zz9.99")) +
                                            " ate vencto"
                                       ELSE IF crapcob.cdmensag = 2 THEN
                                           "R$ " + 
                                   TRIM(STRING(crapcob.vldescto, "z,zz9.99")) +
                                            " apos vencto"
                                       ELSE "".

            IF  tt-consulta-blt.cdtpinsc = 1                  AND
                LENGTH(STRING(tt-consulta-blt.nrinssac)) > 1  THEN
                DO:
                    ASSIGN tt-consulta-blt.dsinssac = 
                                              STRING(tt-consulta-blt.nrinssac).

                    DO WHILE LENGTH(tt-consulta-blt.dsinssac) < 11:
                        ASSIGN tt-consulta-blt.dsinssac = "0" +
                                                      tt-consulta-blt.dsinssac.
                    END.

                    ASSIGN tt-consulta-blt.dsinssac = 
                                  SUBSTR(tt-consulta-blt.dsinssac,1,3) + "." +
                                  SUBSTR(tt-consulta-blt.dsinssac,4,3) + "." +
                                  SUBSTR(tt-consulta-blt.dsinssac,7,3) + "-" +
                                  SUBSTR(tt-consulta-blt.dsinssac,10,2).
                END.
            ELSE
            IF  tt-consulta-blt.cdtpinsc = 2                  AND
                LENGTH(STRING(tt-consulta-blt.nrinssac)) > 1  THEN
                DO:
                    ASSIGN tt-consulta-blt.dsinssac = 
                                              STRING(tt-consulta-blt.nrinssac).

                    DO WHILE LENGTH(tt-consulta-blt.dsinssac) < 14:
                        ASSIGN tt-consulta-blt.dsinssac = "0" + 
                                                      tt-consulta-blt.dsinssac.
                    END.

                    ASSIGN tt-consulta-blt.dsinssac = 
                                   SUBSTR(tt-consulta-blt.dsinssac,1,2) + "." +
                                   SUBSTR(tt-consulta-blt.dsinssac,3,3) + "." +
                                   SUBSTR(tt-consulta-blt.dsinssac,6,3) + "/" +
                                   SUBSTR(tt-consulta-blt.dsinssac,9,4) + "-" +
                                   SUBSTR(tt-consulta-blt.dsinssac,13,2).
                END.
            ELSE
                ASSIGN tt-consulta-blt.dsinssac = "".

            ASSIGN tt-consulta-blt.vldesabt = tt-consulta-blt.vldescto +
                                              tt-consulta-blt.vlabatim

                   tt-consulta-blt.vljurmul = tt-consulta-blt.vlrjuros +
                                              tt-consulta-blt.vlrmulta.

     /* Aviso SMS */
     ASSIGN tt-consulta-blt.inavisms = crapcob.inavisms
            tt-consulta-blt.insmsant = crapcob.insmsant
            tt-consulta-blt.insmsvct = crapcob.insmsvct
            tt-consulta-blt.insmspos = crapcob.insmspos
            tt-consulta-blt.dssmsant = IF crapcob.insmsant <> 0 THEN "S" ELSE "N"
            tt-consulta-blt.dssmsvct = IF crapcob.insmsvct <> 0 THEN "S" ELSE "N"
            tt-consulta-blt.dssmspos = IF crapcob.insmspos <> 0 THEN "S" ELSE "N".            

     
     CASE crapcob.inavisms:
         WHEN 0 THEN tt-consulta-blt.dsavisms = "Nao Enviar".
         WHEN 1 THEN tt-consulta-blt.dsavisms = "Linha Dig.".
         WHEN 2 THEN tt-consulta-blt.dsavisms = "Sem Linha Dig:".
     END CASE. 
     
     IF crapcob.cdmensag = 1 AND tt-consulta-blt.vldescto > 0 THEN
        ASSIGN tt-consulta-blt.dsdinst1 = 'MANTER DESCONTO ATE O VENCIMENTO'.
     ELSE IF crapcob.cdmensag = 2 THEN
        ASSIGN tt-consulta-blt.dsdinst1 = 'MANTER DESCONTO APOS O VENCIMENTO'.
     ELSE
        ASSIGN tt-consulta-blt.dsdinst1 = ' '.
     
     IF (crapcob.tpjurmor <> 3) OR (crapcob.tpdmulta <> 3) THEN DO:
      
       ASSIGN tt-consulta-blt.dsdinst2 = 'APOS VENCIMENTO, COBRAR: '.
       
       IF crapcob.tpjurmor = 1 THEN 
          tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'R$ ' + TRIM(STRING(crapcob.vljurdia, 'zzz,zzz,zz9.99')) + ' JUROS AO DIA'.
       ELSE 
         IF crapcob.tpjurmor = 2 THEN 
            tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + TRIM(STRING(crapcob.vljurdia, 'zzz,zzz,zz9.99')) + '% JUROS AO MES'.
                         
       IF crapcob.tpjurmor <> 3 AND
          crapcob.tpdmulta <> 3 THEN
          tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + ' E '.            
 
       IF crapcob.tpdmulta = 1 THEN 
          tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'MULTA DE R$ ' + TRIM(STRING(crapcob.vlrmulta, 'zzz,zzz,zz9.99')).
       ELSE IF crapcob.tpdmulta = 2 THEN 
          tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'MULTA DE ' + TRIM(STRING(crapcob.vlrmulta, 'zzz,zzz,zz9.99')) + '%'.
                                                       
     END.     

     IF crapcob.flgdprot = TRUE THEN
        ASSIGN tt-consulta-blt.dsdinst3 = 'PROTESTAR APOS ' + STRING(crapcob.qtdiaprt) + ' DIAS CORRIDOS DO VENCIMENTO' +
                                          (IF tt-consulta-blt.dtvencto <> ? AND tt-consulta-blt.cdsituac = "V" THEN
                                              ' ORIGINAL ' + STRING(tt-consulta-blt.dtvencto,'99/99/9999') + '.'
                                           ELSE 
                                              '.')
               tt-consulta-blt.dsdinst4 = ' '.
               
     IF crapcob.flserasa = TRUE AND crapcob.qtdianeg > 0  THEN
        ASSIGN tt-consulta-blt.dsdinst3 = 'NEGATIVAR NA SERASA APOS ' + STRING(crapcob.qtdianeg) + ' DIAS CORRIDOS DO VENCIMENTO' +
                                          (IF tt-consulta-blt.dtvencto <> ? AND tt-consulta-blt.cdsituac = "V" THEN
                                              ' ORIGINAL ' + STRING(tt-consulta-blt.dtvencto,'99/99/9999') + '.'
                                           ELSE 
                                              '.')
               tt-consulta-blt.dsdinst4 = ' '.     
     
   END. /* Fim do DO TRANSACTION */
  
   /*Bloco para tratamento de erro do create da lcm try catch*/
   CATCH eSysError AS Progress.Lang.SysError:
     /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
     ASSIGN aux_dscritic = eSysError:GetMessage(1).
     
     RUN valida_caracteres(INPUT aux_dscritic,
						   OUTPUT aux_dscritic).
      
     FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
      
     UNIX SILENT VALUE("echo " +  STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.cria_tt-consulta-blt geral' --> '" + aux_dscritic  +                          
                       " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/proc_message.log").
      
	 RETURN "NOK".
   END CATCH.
  
END PROCEDURE. /* cria_tt-consulta-blt */

PROCEDURE cria_tt-consulta-blt_rej. 

   DEF INPUT        PARAM p-cdcooper       AS INTE.
   DEF INPUT        PARAM p-cod-agencia    AS INTE.
   DEF INPUT        PARAM p-nro-caixa      AS INTE.
   DEF INPUT        PARAM p-data-limite    AS DATE.

   DEF INPUT-OUTPUT PARAM p-nmprimtl       AS CHAR.
   DEF INPUT-OUTPUT PARAM p-contaant       LIKE crapass.nrdconta.
   DEF INPUT-OUTPUT PARAM p-sqttlant       LIKE crapttl.idseqttl.

   DEF OUTPUT       PARAM TABLE FOR tt-consulta-blt.

   DEF VAR aux_nossonro AS CHAR FORMAT "x(19)" NO-UNDO.
   DEF VAR aux_flgdesco AS CHAR                NO-UNDO.
   DEF VAR aux_dsstaabr AS CHAR                NO-UNDO.
   DEF VAR aux_dsstacom AS CHAR                NO-UNDO.
   DEF VAR aux_dtsitcrt AS DATE                NO-UNDO.
   DEF VAR aux_vlrmulta AS DECI                NO-UNDO.
   DEF VAR aux_vlrjuros AS DECI                NO-UNDO.  
     
   DEF VAR aux_nmprimtl AS CHAR                NO-UNDO.
   DEF VAR aux_des_erro AS CHAR                NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                NO-UNDO.
   
   FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

   IF  NOT AVAILABLE crapcco  THEN
       DO:
           ASSIGN i-cod-erro = 0
                  c-dsc-erro = "Convenio nao cadastrado!".

           {sistema/generico/includes/b1wgen0001.i}

           RETURN "NOK".
       END.

   IF   crapcco.flgutceb THEN
        DO:
            FIND LAST crapceb WHERE crapceb.cdcooper = crapret.cdcooper AND
                                    crapceb.nrdconta = crapret.nrdconta AND
                                    crapceb.nrconven = crapret.nrcnvcob
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.

            IF  NOT AVAILABLE crapceb  THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-dsc-erro = "Convenio CEB nao cadastrado!".

                    {sistema/generico/includes/b1wgen0001.i}

                    RETURN "NOK".
                END.
            
            IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                ASSIGN aux_nossonro = STRING(crapret.nrcnvcob,"9999999") +
                                      STRING(crapceb.nrcnvceb,"9999")    +
                                      STRING(0,"999999").
            ELSE
                ASSIGN aux_nossonro = STRING(crapret.nrcnvcob,"9999999")    +
                                      STRING(INT(SUBSTR(TRIM(STRING(
                                             crapceb.nrcnvceb, "zzzz9"))
                                             ,1,4)),"9999") +
                                      STRING(0,"999999").
        END.
    ELSE
        ASSIGN aux_nossonro = STRING(crapret.nrnosnum,"99999999999999999").
    
   
   DO TRANSACTION:
	 CREATE tt-consulta-blt.
    
     /*  Verifica no Cadastro de Sacados Cobranca */

     FOR FIRST crapass FIELDS(nmprimtl cdagenci)
         WHERE crapass.cdcooper = crapret.cdcooper AND
               crapass.nrdconta = crapret.nrdconta
               NO-LOCK: END.
    
     RUN busca_dados_beneficiario( INPUT crapret.cdcooper,
                                   INPUT crapret.nrdconta).               
    
     ASSIGN tt-consulta-blt.nmdsacad = crapret.nrnosnum.

     ASSIGN tt-consulta-blt.nmdavali = ""
            tt-consulta-blt.cdtpinav = 0
            tt-consulta-blt.nrinsava = 0
            tt-consulta-blt.vlrjuros = 0
            tt-consulta-blt.vlrmulta = 0.
    
          /*Se mudou a conta devo busca o beneficiario*/
     RUN controla-busca-nmdobnfc(INPUT crapret.cdcooper
                                ,INPUT crapret.nrdconta
                                ,INPUT 0 /* idseqttl -- esta ZERO no campo da tt-consulta-blt abaixo */ 
                                ,INPUT "cria_tt-consulta-blt_rej"
                                ,INPUT-OUTPUT p-contaant
                                ,INPUT-OUTPUT p-sqttlant
                                ,INPUT-OUTPUT p-nmprimtl
                                ,OUTPUT aux_dscritic).

     IF  RETURN-VALUE <> "OK" THEN
         DO:     
			ASSIGN i-cod-erro = 0.

			IF aux_dscritic = "" THEN
               c-dsc-erro = "Nome do beneficiario nao encontrado!".
			ELSE
			   c-dsc-erro = aux_dscritic.

            {sistema/generico/includes/b1wgen0001.i}

            RETURN "NOK".
         END.                      

     ASSIGN tt-consulta-blt.cdcooper = crapret.cdcooper
            tt-consulta-blt.nrdconta = crapret.nrdconta
            tt-consulta-blt.nmprimtl = p-nmprimtl
            tt-consulta-blt.idseqttl = 0
            tt-consulta-blt.nossonro = aux_nossonro
            tt-consulta-blt.incobran = "R"
            tt-consulta-blt.nrdocmto = crapret.nrdocmto
            tt-consulta-blt.dsdoccop = TRIM(crapret.dsdoccop)
            tt-consulta-blt.nrdctabb = 0
            tt-consulta-blt.nrcnvcob = crapret.nrcnvcob
            tt-consulta-blt.dtmvtolt = crapret.dtocorre
            tt-consulta-blt.dtretcob = crapret.dtocorre
            tt-consulta-blt.dtdpagto = crapret.dtocorre
            tt-consulta-blt.dtdbaixa = crapret.dtocorre
            tt-consulta-blt.cdbandoc = crapcco.cddbanco
            tt-consulta-blt.vldpagto = 0
            tt-consulta-blt.dtvencto = IF crapret.dtvencto = ? THEN 
                                          crapret.dtocorre
                                       ELSE
                                          crapret.dtvencto
            tt-consulta-blt.vltitulo = crapret.vltitulo
            tt-consulta-blt.nrinssac = 0
            tt-consulta-blt.cdtpinsc = 0
            tt-consulta-blt.vltarifa = 0
            tt-consulta-blt.flgregis = IF  crapcco.flgregis = TRUE  THEN
                                           " S"
                                       ELSE
                                           " N"
            tt-consulta-blt.flgaceit = " N"
            tt-consulta-blt.inemiten = 0
            tt-consulta-blt.nrnosnum = crapret.nrnosnum
            tt-consulta-blt.qtdiaprt = 0
            tt-consulta-blt.dtdocmto = crapret.dtocorre
            tt-consulta-blt.cddespec = 0
            tt-consulta-blt.vldescto = 0
            tt-consulta-blt.vlabatim = 0
            tt-consulta-blt.flgcbdda = "N"
            tt-consulta-blt.dsdespec = "OUTR".
      
     CASE tt-consulta-blt.inemiten:
         WHEN 1 THEN ASSIGN tt-consulta-blt.dsemiten = "1-BCO"
                            tt-consulta-blt.dsemitnt = "BCO".
         WHEN 2 THEN ASSIGN tt-consulta-blt.dsemiten = "2-COO"
                            tt-consulta-blt.dsemitnt = "COO".
         WHEN 3 THEN ASSIGN tt-consulta-blt.dsemiten = "3-CEE"
                            tt-consulta-blt.dsemitnt = "CEE".
     END CASE.

     ASSIGN tt-consulta-blt.cdbanpag = STRING(0,"zzz")
            tt-consulta-blt.cdagepag = STRING(0,"zzzz").

     ASSIGN tt-consulta-blt.cdsituac = "A"
            tt-consulta-blt.dssituac = "ABERTO".

     ASSIGN aux_dsstaabr = "REJ"
            aux_dsstacom = "REJEITADO"
            aux_dtsitcrt = ?.

     ASSIGN tt-consulta-blt.dsstaabr = aux_dsstaabr
            tt-consulta-blt.dsstacom = aux_dsstacom
            tt-consulta-blt.dtsitcrt = aux_dtsitcrt
            tt-consulta-blt.dssituac = IF crapcco.flgregis THEN 
                                          aux_dsstacom
                                       ELSE
                                          tt-consulta-blt.dssituac.

     ASSIGN tt-consulta-blt.dsdpagto = "".

     ASSIGN tt-consulta-blt.dsorgarq = aux_dsorgarq
            tt-consulta-blt.flgdesco = aux_flgdesco.
            
     FIND crapass WHERE
          crapass.cdcooper = tt-consulta-blt.cdcooper   AND
          crapass.nrdconta = tt-consulta-blt.nrdconta   NO-LOCK NO-ERROR.

     IF   AVAIL crapass   THEN
          ASSIGN tt-consulta-blt.cdagenci = crapass.cdagenci.

     /* gravar na temptable agencia da cooperativa
        Utilizado na internet - Rafael Cechet - 01/04/11 */
     IF tt-consulta-blt.cdbandoc = 085 THEN 
     DO:
          FIND crapcop WHERE crapcop.cdcooper = crapret.cdcooper NO-LOCK.
          ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagectl,"9999").
     END.
     ELSE
     DO:
         FIND crapcop WHERE crapcop.cdcooper = crapret.cdcooper NO-LOCK.
         ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagedbb,"99999").
     END.

     /* MULTA PARA ATRASO */
     ASSIGN aux_vlrmulta = 0
     /* MORA PARA ATRASO */
            aux_vlrjuros =  0.
                             
     ASSIGN tt-consulta-blt.dscjuros = ""
            tt-consulta-blt.dscmulta = ""
            tt-consulta-blt.dscdscto = "".

     ASSIGN tt-consulta-blt.dsinssac = "".

     ASSIGN tt-consulta-blt.vldesabt = tt-consulta-blt.vldescto +
                                       tt-consulta-blt.vlabatim

            tt-consulta-blt.vljurmul = tt-consulta-blt.vlrjuros +
                                       tt-consulta-blt.vlrmulta.

   END. /* Fim do DO TRANSACTION */
  
   /*Bloco para tratamento de erro do create da lcm try catch*/
   CATCH eSysError AS Progress.Lang.SysError:
     
     /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
     ASSIGN aux_dscritic = eSysError:GetMessage(1).
     
     RUN valida_caracteres(INPUT aux_dscritic,
						   OUTPUT aux_dscritic).
	 
     
     FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
     
     UNIX SILENT VALUE("echo " +  STRING(TIME,"HH:MM:SS") + " - B1WGEN0010.cria_tt-consulta-blt_rej geral ' --> '" + aux_dscritic  +                          
                       " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/proc_message.log").
     RETURN "NOK".
	 	
   END CATCH.
  
END PROCEDURE. /* cria_tt-consulta-blt_rej */

/* criar temptable para os registros do relatorio de titulos descontados*/
PROCEDURE cria_tt-consulta-blt_tdb.

   DEF INPUT        PARAM p-cdcooper       AS INTE.
   DEF INPUT        PARAM p-cod-agencia    AS INTE.
   DEF INPUT        PARAM p-nro-caixa      AS INTE.
   DEF INPUT        PARAM p-data-limite    AS DATE.
   DEF INPUT        PARAM par_cdsituac     AS CHAR.
   DEF INPUT        PARAM par_nmprimtl     AS CHAR.

   DEF OUTPUT       PARAM TABLE FOR tt-consulta-blt.
   
   DEF VAR aux_dsdemail AS CHAR                NO-UNDO.
   DEF VAR aux_des_erro AS CHAR                NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                NO-UNDO.
   
   DEF VAR aux_npc_cip  AS INTE                NO-UNDO.

   FOR FIRST crapass FIELDS(nmprimtl cdagenci)
       WHERE crapass.cdcooper = crapcob.cdcooper AND
             crapass.nrdconta = crapcob.nrdconta
             NO-LOCK: END.
             
   DO TRANSACTION:
     CREATE tt-consulta-blt.
     
     FIND   crapsab 
      WHERE crapsab.cdcooper = crapcob.cdcooper AND
            crapsab.nrdconta = crapcob.nrdconta AND
            crapsab.nrinssac = crapcob.nrinssac NO-LOCK NO-ERROR.

     RUN busca_dados_beneficiario( INPUT crapcob.cdcooper,
                                   INPUT crapcob.nrdconta).            

     IF  AVAILABLE crapsab  THEN
         DO:
       ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapsab.nmdsacad,"&","%26")
              tt-consulta-blt.dsendsac = TRIM(TRIM(crapsab.dsendsac) + 
                                         IF crapsab.nrendsac > 0 THEN
                                            ", " + STRING(crapsab.nrendsac)
                                         ELSE "")
              tt-consulta-blt.nmdsacad = (IF tt-consulta-blt.nmdsacad <> ? THEN tt-consulta-blt.nmdsacad ELSE " ")
              tt-consulta-blt.dsendsac = (IF tt-consulta-blt.dsendsac <> ? THEN tt-consulta-blt.dsendsac ELSE " ")                                         
              tt-consulta-blt.complend = (IF crapsab.complend <> ? THEN crapsab.complend ELSE " ")
              tt-consulta-blt.nmbaisac = (IF crapsab.nmbaisac <> ? THEN crapsab.nmbaisac ELSE " ")
              tt-consulta-blt.nmcidsac = (IF crapsab.nmcidsac <> ? THEN crapsab.nmcidsac ELSE " ")
              tt-consulta-blt.cdufsaca = (IF crapsab.cdufsaca <> ? THEN crapsab.cdufsaca ELSE " ")
                    tt-consulta-blt.nrcepsac = crapsab.nrcepsac.

             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

             RUN STORED-PROCEDURE pc_busca_emails_pagador
                 aux_handproc = PROC-HANDLE NO-ERROR
                                         (INPUT crapsab.cdcooper,
                                          INPUT crapsab.nrdconta,
                                          INPUT crapsab.nrinssac,
                                         OUTPUT "",  /* pr_dsdemail */
                                         OUTPUT "",  /* pr_des_erro */
                                         OUTPUT ""). /* pr_dscritic */
             CLOSE STORED-PROC pc_busca_emails_pagador
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             ASSIGN aux_dsdemail = ""
                    aux_dscritic = ""
                    aux_des_erro = ""
                    aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                                       WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
                    aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                                       WHEN pc_busca_emails_pagador.pr_dscritic <> ?
                    aux_des_erro = pc_busca_emails_pagador.pr_des_erro
                                       WHEN pc_busca_emails_pagador.pr_des_erro <> ?.

              ASSIGN tt-consulta-blt.dsdemail = aux_dsdemail
                     tt-consulta-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN TRUE ELSE FALSE).                    
             
         END.
                                          ELSE 
           ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapcob.nmdsacad,"&","%26")
                  tt-consulta-blt.flgemail = FALSE.
           
       ASSIGN tt-consulta-blt.cdsituac = par_cdsituac.
       
       /* Verificar se o boleto pertence a um carne.
          O boleto de um carne eh criado na crapcol com a informacao "CARNE"
          na coluna crapcol.dslogtit */
       FIND FIRST crapcol WHERE crapcol.cdcooper = crapcob.cdcooper
                            AND crapcol.nrdconta = crapcob.nrdconta
                            AND crapcol.nrdocmto = crapcob.nrdocmto
                            AND crapcol.nrcnvcob = crapcob.nrcnvcob
                            AND upper(crapcol.dslogtit) MATCHES "*CARNE*"
                          NO-LOCK NO-ERROR.
       tt-consulta-blt.flgcarne = (IF AVAIL crapcol THEN
                                       TRUE
                                   ELSE 
                                       FALSE).

       CASE tt-consulta-blt.cdsituac:
            WHEN "A" THEN tt-consulta-blt.dssituac = "ABERTO".
            WHEN "V" THEN tt-consulta-blt.dssituac = "VENCIDO".
            WHEN "P" THEN tt-consulta-blt.dssituac = "PAGO".
            WHEN "B" THEN tt-consulta-blt.dssituac = "BAIXADO S/ PAGTO".
       END CASE. 
       
       /* Verificar se a crapdat está carregada */ 
       IF NOT AVAILABLE crapdat THEN
       DO:
         FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
       END.

       /* Consulta se titulo esta na faixa de rollout e integrado na cip */
       RUN verifica-titulo-npc-cip(INPUT crapcob.cdcooper,
                                   INPUT crapdat.dtmvtolt,
                                   INPUT crapcob.vltitulo,
                                   INPUT crapcob.flgcbdda,
                                   OUTPUT aux_npc_cip).

       ASSIGN tt-consulta-blt.cdcooper = crapcob.cdcooper
              tt-consulta-blt.nrdconta = crapcob.nrdconta
              tt-consulta-blt.nmprimtl = par_nmprimtl
              tt-consulta-blt.nrdocmto = crapcob.nrdocmto
              tt-consulta-blt.nrctrlim = craptdb.nrctrlim
              tt-consulta-blt.dsdoccop = crapcob.dsdoccop   
              tt-consulta-blt.nrborder = craptdb.nrborder
              tt-consulta-blt.dtmvtolt = (IF crapcob.dtmvtolt = ? THEN
                                             crapcob.dtdpagto
                                          ELSE
                                             crapcob.dtmvtolt)
              tt-consulta-blt.dtretcob = crapcob.dtretcob
              tt-consulta-blt.dtdpagto = craptdb.dtdpagto
              tt-consulta-blt.dtdbaixa = crapcob.dtdbaixa
              tt-consulta-blt.cdbandoc = crapcob.cdbandoc
              tt-consulta-blt.vldpagto = crapcob.vldpagto
              tt-consulta-blt.dtvencto = (IF craptdb.dtvencto = ? THEN
                                             craptdb.dtdpagto
                                          ELSE
                                             craptdb.dtvencto)
              tt-consulta-blt.dtvctori = crapcob.dtvctori /* P340 - Rafael */                                             
              tt-consulta-blt.dtbloqueio = crapcob.dtbloque
              tt-consulta-blt.flgcbdda = (IF aux_npc_cip = 1 THEN "S" ELSE "N")
              tt-consulta-blt.vltitulo = crapcob.vltitulo.
   END.
END PROCEDURE. /* cria_tt-consulta-blt_tdb */ 

PROCEDURE busca_associado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
           
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapass.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(nmprimtl cdagenci)
            WHERE crapass.cdcooper = par_cdcooper AND
                  crapass.nrdconta = par_nrdconta
                  NO-LOCK: END.

        IF  NOT AVAIL crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        BUFFER-COPY crapass TO tt-crapass.

        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.

    END. /* Busca */
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* busca_associado */

PROCEDURE proc_nosso_numero.
    
    DEF INPUT        PARAM p-cdcooper       AS INTE.
    DEF INPUT        PARAM p-cod-agencia    AS INTE.
    DEF INPUT        PARAM p-nro-caixa      AS INTE.
    DEF INPUT        PARAM p-ind-situacao   AS INTE.
    DEF INPUT        PARAM p-num-registros  AS INTE.
    DEF INPUT        PARAM p-nmprimtl       AS CHAR.
    
    DEF VAR aux_nossonro AS CHAR FORMAT "x(19)" NO-UNDO.
    DEF VAR aux_contador AS INTE INITIAL 17     NO-UNDO.
    DEF VAR aux_nrcnvceb AS INTE                NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                NO-UNDO.
    DEF VAR aux_cdsituac AS CHAR                NO-UNDO.
    DEF VAR aux_dssituac AS CHAR                NO-UNDO.
    DEF VAR aux_flgdesco AS CHAR                NO-UNDO.
    
    DEF VAR aux_nmprimtl AS CHAR                NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR                NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                NO-UNDO.   
    
    /* Variaveis auxiliares para calculo do digito verificador */
    DEF VAR aux_var01    AS INTE INITIAL 0      NO-UNDO.
    DEF VAR aux_var02    AS INTE INITIAL 2      NO-UNDO.
    DEF VAR aux_var03    AS INTE                NO-UNDO.
    DEF VAR aux_var04    AS INTE                NO-UNDO.
    DEF VAR aux_var05    AS CHAR                NO-UNDO.

    DEF VAR aux_npc_cip  AS INTE                NO-UNDO.

    /************************************************************************/
    /** p-ind-situacao > 1-ABERTO/2-BAIXADO/3-EXCLUIDO/4-LIQUIDADO         **/
    /**                  5-REJEITADO/6-CARTORARIA/7-TODOS                  **/
    /************************************************************************/ 
    
    ASSIGN aux_cdsituac = "".

    IF  p-ind-situacao = 1 OR p-ind-situacao = 7  THEN 
        IF  crapcob.dtdpagto = ? AND crapcob.incobran = 0  THEN
            ASSIGN aux_cdsituac = "A".

    IF  p-ind-situacao = 2 OR p-ind-situacao = 7  THEN 
        IF  crapcob.dtdbaixa <> ? OR crapcob.incobran = 3 THEN 
            ASSIGN aux_cdsituac = "B".

    IF  p-ind-situacao = 3 OR p-ind-situacao = 7  THEN 
        IF  crapcob.dtelimin <> ?  THEN
            ASSIGN aux_cdsituac = "E".
   
    IF  p-ind-situacao = 4 OR p-ind-situacao = 7  THEN 
        IF  crapcob.dtdpagto <> ? AND crapcob.dtdbaixa = ?  THEN
            ASSIGN aux_cdsituac = "L".

    IF  p-ind-situacao = 5 OR p-ind-situacao = 7  THEN 
        IF  crapcob.incobran = 4  THEN
            ASSIGN aux_cdsituac = "R".

    IF  p-ind-situacao = 6 OR p-ind-situacao = 7  THEN 
        IF  crapcob.dtsitcrt <> ? THEN
            CASE crapcob.incobran:
                WHEN 0 THEN ASSIGN aux_cdsituac = "A".
                WHEN 3 THEN 
                  IF crapcob.insitcrt = 5 THEN 
                    ASSIGN aux_cdsituac = "P". /* Ajuste - PRJ352 */
                  ELSE
                    ASSIGN aux_cdsituac = "B".
                WHEN 5 THEN ASSIGN aux_cdsituac = "L".
            END CASE.

    IF  aux_cdsituac = ""  THEN
        RETURN.
                     
    CASE aux_cdsituac:
          WHEN "A" THEN aux_dssituac = "ABERTO".
          WHEN "B" THEN aux_dssituac = "BAIXADO".
          WHEN "E" THEN aux_dssituac = "EXCLUIDO".
          WHEN "L" THEN aux_dssituac = "LIQUIDADO".
          WHEN "R" THEN aux_dssituac = "REJEITADO".
          WHEN "P" THEN aux_dssituac = "PROTESTADO". /* Ajuste - PRJ 352 */
     END CASE. 

     IF  TRIM(crapcob.dcmc7chq) <> "" THEN
         ASSIGN aux_dssituac = aux_dssituac + "/" +
                                           ENTRY(1,crapcob.dcmc7chq,";").
         
     FIND LAST craptdb 
         WHERE craptdb.cdcooper = crapcob.cdcooper   AND
               craptdb.nrdconta = crapcob.nrdconta   AND
               craptdb.cdbandoc = crapcob.cdbandoc   AND
               craptdb.nrdctabb = crapcob.nrdctabb   AND
               craptdb.nrcnvcob = crapcob.nrcnvcob   AND
               craptdb.nrdocmto = crapcob.nrdocmto   NO-LOCK NO-ERROR.
                       
     IF   AVAILABLE craptdb THEN
          DO:
              CASE craptdb.insittit:
                   WHEN 0 THEN ASSIGN aux_flgdesco = "".
                   WHEN 1 THEN ASSIGN aux_flgdesco = "".
                   WHEN 2 THEN ASSIGN aux_flgdesco = "*".
                   WHEN 3 THEN ASSIGN aux_flgdesco = "*".
                   WHEN 4 THEN ASSIGN aux_flgdesco = "*".
              END CASE.
          END.

    /* se cobranca registrada - Rafael Cechet - 29/03/11 */
    IF crapcob.flgregis = TRUE OR crapcob.cdbandoc = 085 OR 
       /* Se a informacao estiver preenchida na crapcob
          utilizar da tabela */
       crapcob.nrnosnum <> "" THEN
       DO: 
           ASSIGN aux_nossonro = crapcob.nrnosnum
                  aux_nrdocmto = crapcob.nrdocmto.

           FIND LAST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                    crapceb.nrdconta = crapcob.nrdconta AND
                                    crapceb.nrconven = crapcob.nrcnvcob
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.
             
            IF  AVAILABLE crapceb  THEN
              ASSIGN aux_nrcnvceb = crapceb.nrcnvceb.
            ELSE
              ASSIGN aux_nrcnvceb = 0.

       END.
    ELSE
    /* se cobranca registrada - Rafael Cechet - 29/03/11 */ 
    IF  LENGTH(STRING(crapcob.nrcnvcob)) = 7  THEN
        DO:
            FIND LAST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                    crapceb.nrdconta = crapcob.nrdconta AND
                                    crapceb.nrconven = crapcob.nrcnvcob
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.
             
            IF  NOT AVAILABLE crapceb  THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-dsc-erro = "Convenio CEB nao cadastrado!".
           
                    {sistema/generico/includes/b1wgen0001.i}

                    RETURN "NOK".
                END.
                
            ASSIGN aux_nrcnvceb = crapceb.nrcnvceb
                   aux_nrdocmto = crapcob.nrdocmto.

            IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                aux_nossonro = STRING(crapcob.nrcnvcob,"9999999") + 
                               STRING(aux_nrcnvceb,"9999") +
                               STRING(aux_nrdocmto,"999999").
            ELSE
                aux_nossonro = STRING(crapcob.nrcnvcob,"9999999")    +
                               STRING(INT(SUBSTR(TRIM(STRING(
                                      aux_nrcnvceb, "zzzz9")),1,4)),"9999") +
                               STRING(aux_nrdocmto,"999999").

        END.
    ELSE
    IF  LENGTH(STRING(crapcob.nrcnvcob)) = 6  THEN
        DO:
            ASSIGN aux_nrcnvceb = 0
                   aux_nrdocmto = crapcob.nrdocmto
                   aux_nossonro = STRING(crapcob.nrdconta,"99999999") +
                                  STRING(crapcob.nrdocmto,"999999999").
        END.
    

    ASSIGN aux_nrregist = aux_nrregist + 1.

    /* Se nao for um registro da sequencia desejada, retorna e nao grava */
    IF  p-num-registros > 0           AND 
       (aux_nrregist <  aux_iniseque  OR 
        aux_nrregist >= aux_fimseque) THEN
        RETURN.


    /* Verificar se a crapceb está carregada */ 
    IF NOT AVAILABLE crapceb THEN
    DO:
        /* Se nao foi carregada, buscamos com base no boleto */
        FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper
                             AND crapceb.nrdconta = crapcob.nrdconta
                             AND crapceb.nrconven = crapcob.nrcnvcob
                           NO-LOCK NO-ERROR.
    END.
    
    /* Se a crapceb que foi carregada eh diferente do boleto, carregamos de novo a crapceb */ 
    IF crapceb.cdcooper <> crapcob.cdcooper OR 
       crapceb.nrdconta <> crapcob.nrdconta OR 
       crapceb.nrconven <> crapcob.nrcnvcob THEN
    DO:
        /* Se nao foi carregada, buscamos com base no boleto */
        FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper
                             AND crapceb.nrdconta = crapcob.nrdconta
                             AND crapceb.nrconven = crapcob.nrcnvcob
                           NO-LOCK NO-ERROR.
    END.

    DO TRANSACTION:

        IF NOT AVAIL crapsab THEN
            ASSIGN aux_na_nmdsacad = "PAGADOR NAO CADASTRADO"
                   aux_na_dsendsac = "NAO CADASTRADO"
                   aux_na_complend = "NAO CADASTRADO"
                   aux_na_nmbaisac = "NAO CADASTRADO"
                   aux_na_nmcidsac = "NAO CADASTRADO"
                   aux_na_cdufsaca = "NA"
                   aux_na_nrcepsac = 00000000.
        ELSE
            ASSIGN aux_na_nmdsacad = (IF crapsab.nmdsacad <> ? THEN crapsab.nmdsacad ELSE " ") 
                   aux_na_dsendsac = (IF crapsab.dsendsac <> ? THEN crapsab.dsendsac ELSE " ")                   
                   aux_na_complend = (IF crapsab.complend <> ? THEN crapsab.complend ELSE " ")
                   aux_na_nmbaisac = (IF crapsab.nmbaisac <> ? THEN crapsab.nmbaisac ELSE " ")
                   aux_na_nmcidsac = (IF crapsab.nmcidsac <> ? THEN crapsab.nmcidsac ELSE " ")
                   aux_na_cdufsaca = (IF crapsab.cdufsaca <> ? THEN crapsab.cdufsaca ELSE " ")
                   aux_na_nrcepsac = crapsab.nrcepsac.

        /* Assume como Padrão Cooperado Emite e Expede*/
        aux_nrvarcar = 1.

        /* banco emite e expede */
        IF crapcob.inemiten = 2 THEN
          aux_nrvarcar = crapcco.nrvarcar.

        /* cooperativa emite e expede */
        IF crapcob.inemiten = 3 THEN
          aux_nrvarcar = 2.

        CREATE tt-consulta-blt. 
        
        ASSIGN tt-consulta-blt.cdserasa = crapcob.inserasa.

        RUN busca_dados_beneficiario( INPUT crapcob.cdcooper,
                                      INPUT crapcob.nrdconta).        

        CASE crapcob.inserasa:
          WHEN 1 THEN 
            DO:
              tt-consulta-blt.inserasa = "E".
              tt-consulta-blt.dsserasa = "ENVIADO NEGATIVACAO".
            END.
          WHEN 2 THEN 
            DO:
              tt-consulta-blt.inserasa = "E".
              tt-consulta-blt.dsserasa = "ENVIADO NEGATIVACAO".
            END.
          WHEN 3 THEN
            DO:
              tt-consulta-blt.inserasa = "C".
              tt-consulta-blt.dsserasa = "ENVIADO CANCELAMENTO".
            END.
          WHEN 4 THEN 
            DO:
              tt-consulta-blt.inserasa = "C".
              tt-consulta-blt.dsserasa = "ENVIADO CANCELAMENTO".
            END.
          WHEN 5 THEN
            DO:
              tt-consulta-blt.inserasa = "S".
              tt-consulta-blt.dsserasa = "SIM".
            END.
		  WHEN 6 THEN
            DO:
              tt-consulta-blt.inserasa = "F".
              tt-consulta-blt.dsserasa = "FALHA NA SOLICITACAO".
            END.
		  WHEN 7 THEN
            DO:
              tt-consulta-blt.inserasa = "A".
              tt-consulta-blt.dsserasa = "ACAO JUDICIAL".
            END. 
          OTHERWISE
            DO:
              tt-consulta-blt.inserasa = "N".
              tt-consulta-blt.dsserasa = "NAO".
            END.
        END CASE.

        ASSIGN tt-consulta-blt.nossonro = aux_nossonro
               tt-consulta-blt.nmprimtl = p-nmprimtl 
               tt-consulta-blt.nmdsacad = REPLACE(aux_na_nmdsacad,"&","%26")
               tt-consulta-blt.nrinssac = crapcob.nrinssac
                           tt-consulta-blt.insitcrt = crapcob.insitcrt
               tt-consulta-blt.cdtpinsc = (IF crapcob.nrinssac = 0 THEN
                                              1
                                           ELSE
                                              crapcob.cdtpinsc).

               IF AVAIL crapsab THEN 
                   DO:
                       ASSIGN tt-consulta-blt.dsendsac = 
                              IF crapsab.nrendsac = 0 THEN 
                                  REPLACE(crapsab.dsendsac,"&","%26")
                              ELSE
                                  REPLACE(crapsab.dsendsac,"&","%26")
                                  + ", " +
                                  TRIM(STRING(crapsab.nrendsac)).
                                  
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                       RUN STORED-PROCEDURE pc_busca_emails_pagador
                           aux_handproc = PROC-HANDLE NO-ERROR
                                                   (INPUT crapsab.cdcooper,
                                                    INPUT crapsab.nrdconta,
                                                    INPUT crapsab.nrinssac,
                                                   OUTPUT "",  /* pr_dsdemail */
                                                   OUTPUT "",  /* pr_des_erro */
                                                   OUTPUT ""). /* pr_dscritic */
                       CLOSE STORED-PROC pc_busca_emails_pagador
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                       ASSIGN aux_dsdemail = ""
                              aux_dscritic = ""
                              aux_des_erro = ""
                              aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                                                 WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
                              aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                                                 WHEN pc_busca_emails_pagador.pr_dscritic <> ?
                              aux_des_erro = pc_busca_emails_pagador.pr_des_erro
                                                 WHEN pc_busca_emails_pagador.pr_des_erro <> ?.

                        ASSIGN tt-consulta-blt.dsdemail = aux_dsdemail
                               tt-consulta-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN TRUE ELSE FALSE).                    
                              
                   END.
               ELSE
                   ASSIGN tt-consulta-blt.dsendsac = REPLACE(aux_na_dsendsac,"&","%26")
                          tt-consulta-blt.flgemail = FALSE.

               /* Verificar se a crapdat está carregada */ 
               IF NOT AVAILABLE crapdat THEN
               DO:
                 FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
               END.

               /* Consulta se titulo esta na faixa de rollout e integrado na cip */
               RUN verifica-titulo-npc-cip(INPUT crapcob.cdcooper,
                                           INPUT crapdat.dtmvtolt,
                                           INPUT crapcob.vltitulo,
                                           INPUT crapcob.flgcbdda,
                                           OUTPUT aux_npc_cip).

               ASSIGN tt-consulta-blt.complend = REPLACE(aux_na_complend,"&","%26")
               tt-consulta-blt.nmbaisac = REPLACE(aux_na_nmbaisac,"&","%26")
               tt-consulta-blt.nmcidsac = REPLACE(aux_na_nmcidsac,"&","%26")
               tt-consulta-blt.cdufsaca = aux_na_cdufsaca
               tt-consulta-blt.nrcepsac = aux_na_nrcepsac
               tt-consulta-blt.cdbandoc = crapcob.cdbandoc
               tt-consulta-blt.nmdavali = REPLACE(crapcob.nmdavali,"&","%26")
               tt-consulta-blt.nrinsava = crapcob.nrinsava
               tt-consulta-blt.cdtpinav = crapcob.cdtpinav
               tt-consulta-blt.nrcnvcob = crapcob.nrcnvcob
               tt-consulta-blt.nrcnvceb = aux_nrcnvceb
               tt-consulta-blt.nrdctabb = crapcob.nrdctabb
               tt-consulta-blt.nrcpfcgc = crapass.nrcpfcgc
               tt-consulta-blt.inpessoa = crapass.inpessoa
               tt-consulta-blt.nrdocmto = aux_nrdocmto
               tt-consulta-blt.dtmvtolt = (IF crapcob.dtmvtolt = ? THEN 
                                              crapcob.dtdpagto
                                           ELSE
                                              crapcob.dtmvtolt)
               tt-consulta-blt.cddespec = crapcob.cddespec
               tt-consulta-blt.cdcartei = crapcco.cdcartei
               tt-consulta-blt.nrvarcar = aux_nrvarcar
               tt-consulta-blt.dsdinstr = crapcob.dsdinstr
               tt-consulta-blt.dsinform = crapcob.dsinform
               tt-consulta-blt.dsdoccop = crapcob.dsdoccop
               tt-consulta-blt.dtdocmto = (IF crapcob.dtdocmto = ? THEN
                                              IF  crapcob.dtdpagto = ? THEN
                                                  crapcob.dtmvtolt
                                              ELSE
                                                  crapcob.dtdpagto 
                                           ELSE
                                              crapcob.dtdocmto)
               tt-consulta-blt.dtvencto = (IF crapcob.dtvencto = ? THEN 
                                              crapcob.dtdpagto 
                                           ELSE
                                              crapcob.dtvencto)
               tt-consulta-blt.dtvctori = crapcob.dtvctori /* P340 - Rafael */                                              
               tt-consulta-blt.dtdpagto = crapcob.dtdpagto
               tt-consulta-blt.dtelimin = crapcob.dtelimin
               tt-consulta-blt.vltitulo = crapcob.vltitulo
               tt-consulta-blt.vldpagto = crapcob.vldpagto
               tt-consulta-blt.vldescto = (IF (crapcob.cdmensag = 1  OR   /* Desconto ate o vencimento */
                                               crapcob.cdmensag = 2) THEN /* Desconto apos o vencimento */ 
                                               crapcob.vldescto
                                           ELSE
                                               0)
               tt-consulta-blt.vlabatim = crapcob.vlabatim
               tt-consulta-blt.cdmensag = (IF crapcob.cdmensag <> ? THEN
			                                  crapcob.cdmensag
										   ELSE
										      0)
               tt-consulta-blt.idbaiexc = IF (crapcob.incobran = 0  OR
                                              crapcob.incobran = 3)  AND
                                              crapcob.dtdpagto = ?  THEN
                                              1
                                          ELSE
                                              2
               tt-consulta-blt.cdsituac = aux_cdsituac
               tt-consulta-blt.dssituac = aux_dssituac
               tt-consulta-blt.flgdesco = aux_flgdesco
               tt-consulta-blt.flgaceit = IF (crapcob.flgaceit = TRUE) THEN
                                             "S" ELSE "N"

               tt-consulta-blt.vlrjuros = crapcob.vljurdia
               tt-consulta-blt.tpjurmor = crapcob.tpjurmor
               tt-consulta-blt.vlrmulta = crapcob.vlrmulta
               tt-consulta-blt.tpdmulta = crapcob.tpdmulta
               
               tt-consulta-blt.indiaprt = crapcob.indiaprt
               tt-consulta-blt.insitpro = crapcob.insitpro
               tt-consulta-blt.flgcbdda = (IF aux_npc_cip = 1 THEN "S" ELSE "N").

          IF (crapcob.tpjurmor <> 3) OR (crapcob.tpdmulta <> 3) THEN DO:
            
            ASSIGN tt-consulta-blt.dsdinst2 = 'APOS VENCIMENTO, COBRAR: '.
            
            IF crapcob.tpjurmor = 1 THEN 
               tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'R$ ' + TRIM(STRING(crapcob.vljurdia, 'zzz,zzz,zz9.99')) + ' JUROS AO DIA'.
            ELSE 
              IF crapcob.tpjurmor = 2 THEN 
                 tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + TRIM(STRING(crapcob.vljurdia, 'zzz,zzz,zz9.99')) + '% JUROS AO MES'.
                              
            IF crapcob.tpjurmor <> 3 AND
               crapcob.tpdmulta <> 3 THEN
               tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + ' E '.            

            IF crapcob.tpdmulta = 1 THEN 
               tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'MULTA DE R$ ' + TRIM(STRING(crapcob.vlrmulta, 'zzz,zzz,zz9.99')).
            ELSE IF crapcob.tpdmulta = 2 THEN 
               tt-consulta-blt.dsdinst2 = tt-consulta-blt.dsdinst2 + 'MULTA DE ' + TRIM(STRING(crapcob.vlrmulta, 'zzz,zzz,zz9.99')) + '%'.
                                                            
          END.
           
           /* Tratamento para Negativaçao Serasa e Protesto */ 
           ASSIGN tt-consulta-blt.flserasa = crapcob.flserasa
                  tt-consulta-blt.qtdianeg = crapcob.qtdianeg
                  tt-consulta-blt.flgdprot = crapcob.flgdprot
                  tt-consulta-blt.qtdiaprt = crapcob.qtdiaprt
                  tt-consulta-blt.insitcrt = crapcob.insitcrt.

           /* Se o boleto nao possui as informacoes de Negativacao, vamos buscar do convenio */
           IF (tt-consulta-blt.flserasa = FALSE OR 
               tt-consulta-blt.qtdianeg = 0 )   AND 
               tt-consulta-blt.inserasa = "N"  THEN
           DO:
               IF NOT (tt-consulta-blt.flgdprot = TRUE AND 
                       tt-consulta-blt.qtdiaprt > 0)   THEN
               DO:
                   ASSIGN tt-consulta-blt.qtdianeg = 0
                          tt-consulta-blt.flserasa = crapceb.flserasa.
               END.
               ELSE 
                   DO:
                       ASSIGN tt-consulta-blt.qtdianeg = 0
                              tt-consulta-blt.flserasa = FALSE.
                   END.
           END.

           /* Se o boleto nao possui as informacoes de Protesto, vamos buscar do convenio */
           IF tt-consulta-blt.flgdprot = FALSE OR 
              tt-consulta-blt.qtdiaprt = 0     THEN
           DO:
               IF NOT (tt-consulta-blt.flserasa = TRUE AND 
                       tt-consulta-blt.qtdianeg > 0 )  OR
                       tt-consulta-blt.inserasa <> "N" THEN
               DO:
                   ASSIGN tt-consulta-blt.qtdiaprt = 0
                          tt-consulta-blt.flgdprot = crapceb.flprotes.
               END.
               ELSE 
                   DO:
                       ASSIGN tt-consulta-blt.qtdiaprt = 0
                              tt-consulta-blt.flgdprot = FALSE.
                   END.
           END.

           /* Verificar se o boleto pertence a um carne.
              O boleto de um carne eh criado na crapcol com a informacao "CARNE"
              na coluna crapcol.dslogtit */
           FIND FIRST crapcol WHERE crapcol.cdcooper = crapcob.cdcooper
                                AND crapcol.nrdconta = crapcob.nrdconta
                                AND crapcol.nrdocmto = crapcob.nrdocmto
                                AND crapcol.nrcnvcob = crapcob.nrcnvcob
                                AND upper(crapcol.dslogtit) MATCHES "*CARNE*"
                              NO-LOCK NO-ERROR.
           tt-consulta-blt.flgcarne = (IF AVAIL crapcol THEN
                                           TRUE
                                       ELSE 
                                           FALSE).

        /* verificar se houve a ent confirmada do titulo no BB 
           condição especial para titulos BB - Banco Emite e Expede */
        IF  crapcob.flgregis       AND 
            crapcob.cdbandoc = 001 AND 
            crapcob.incobran = 0   THEN
            DO:
                IF  AVAIL crapcco AND
                    crapcco.dsorgarq <> "PROTESTO" THEN
                    DO:
                        FIND FIRST crapret WHERE 
                                   crapret.cdcooper = crapcob.cdcooper AND
                                   crapret.nrdconta = crapcob.nrdconta AND
                                   crapret.nrcnvcob = crapcob.nrcnvcob AND
                                   crapret.nrdocmto = crapcob.nrdocmto AND
                                   crapret.cdocorre = 2 /* ent confirmada */
                                   NO-LOCK NO-ERROR.
        
                        IF  AVAIL crapret THEN
                            DO:
                                /* registro processado no BB */
                                ASSIGN tt-consulta-blt.insitpro = 3.
                            END.
                    END.
            END.
               
        IF   tt-consulta-blt.cdsituac = "L" THEN
             CASE crapcob.indpagto:
                  WHEN 0 THEN DO:
                                 IF   crapcob.incobran = 5  AND
                                      crapcob.vldpagto > 0  THEN
                                      tt-consulta-blt.dsdpagto = "COMPENSACAO".
                                 ELSE 
                                      tt-consulta-blt.dsdpagto = "".
                              END.                       
                  WHEN 1 THEN tt-consulta-blt.dsdpagto = "CAIXA".
                  WHEN 2 THEN tt-consulta-blt.dsdpagto = "COMPENSACAO".
                  WHEN 3 THEN tt-consulta-blt.dsdpagto = "INTERNET".
                  WHEN 4 THEN tt-consulta-blt.dsdpagto = "TAA".
             END CASE. 
        ELSE
             tt-consulta-blt.dsdpagto = "".

        IF   crapcob.cdbanpag = 11 THEN
             ASSIGN tt-consulta-blt.cdbanpag = "COOP."
                    tt-consulta-blt.cdagepag = "".
        ELSE
             ASSIGN tt-consulta-blt.cdbanpag = STRING(crapcob.cdbanpag,"zzz")
                    tt-consulta-blt.cdagepag = STRING(crapcob.cdagepag,"zzzz").

        /* gravar na temptable agencia da cooperativa
           Utilizado na internet - Rafael Cechet - 01/04/11 */
        IF tt-consulta-blt.cdbandoc = 085 THEN 
        DO:
             FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
             ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagectl,"9999").
        END.
        ELSE
        DO:
            FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
            ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagedbb,"99999").
        END.

        ASSIGN tt-consulta-blt.nrnosnum = aux_nossonro
               tt-consulta-blt.flgregis = IF  crapcob.flgregis = TRUE  THEN
                                          " S"
                                          ELSE
                                          " N". 

										   IF AVAIL(crapceb) THEN
		   DO:
		     ASSIGN tt-consulta-blt.flprotes = INTE(crapceb.flprotes).
		   END.
        /* Aviso SMS */
       ASSIGN tt-consulta-blt.inavisms = crapcob.inavisms
              tt-consulta-blt.insmsant = crapcob.insmsant
              tt-consulta-blt.insmsvct = crapcob.insmsvct
              tt-consulta-blt.insmspos = crapcob.insmspos
              tt-consulta-blt.dssmsant = IF crapcob.insmsant <> 0 THEN "S" ELSE "N"
              tt-consulta-blt.dssmsvct = IF crapcob.insmsvct <> 0 THEN "S" ELSE "N"
              tt-consulta-blt.dssmspos = IF crapcob.insmspos <> 0 THEN "S" ELSE "N".            
       
       CASE crapcob.inavisms:
           WHEN 0 THEN tt-consulta-blt.dsavisms = "Nao Enviar".
           WHEN 1 THEN tt-consulta-blt.dsavisms = "Linha Dig.".
           WHEN 2 THEN tt-consulta-blt.dsavisms = "Sem Linha Dig:".
       END CASE. 

        /* fim-gravar na temptable - Rafael Cechet - 01/04/11 */

    END. /* Fim do DO TRANSACTION */
    
    RETURN "OK".
END PROCEDURE. /* proc_nosso_numero */

/********************************************************************/
PROCEDURE gera_retorno_arq_cobranca:

  DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-nro-conta    AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-dtpgtini     AS DATE                         NO-UNDO.
  DEF INPUT  PARAMETER p-dtpgtfim     AS DATE                         NO-UNDO.
  DEF INPUT  PARAMETER p-nrcnvcob     AS INTE                         NO-UNDO.
  /* agencia e caixa, usado para inserir tabela de erro */
  DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-origem       AS INTE NO-UNDO. 
                                         /* 1-AYLLOS/2-CAIXA/3-INTERNET */
  DEF INPUT  PARAMETER p-cdprogra     AS CHAR                         NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-arq-cobranca.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_dtcredit AS DATE                                        NO-UNDO.

  /*--  Busca dados da cooperativa  --*/
  FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE crapcop THEN
       DO:
           ASSIGN i-cod-erro = 651
                  c-dsc-erro = " ".
           
           { sistema/generico/includes/b1wgen0001.i }

           RETURN "NOK".
       END.

  EMPTY TEMP-TABLE crawarq.
  EMPTY TEMP-TABLE tt-arq-cobranca.

  FOR EACH crapcob WHERE crapcob.cdcooper  = p-cdcooper     AND
                         crapcob.dtdpagto >= p-dtpgtini     AND
                         crapcob.dtdpagto <= p-dtpgtfim     AND
                         /*flgregis = FALSE - cob sem reg */      
                         crapcob.flgregis  = FALSE          AND                         
                       ((crapcob.nrcnvcob  = p-nrcnvcob)     OR
                        (p-nrcnvcob        = 0))            AND
                       ((crapcob.nrdconta  = p-nro-conta)    OR
                        (p-nro-conta       = 0)) NO-LOCK:

      FIND crapcco WHERE crapcco.cdcooper = p-cdcooper      AND
                         crapcco.nrconven = crapcob.nrcnvcob
                         NO-LOCK NO-ERROR.
    
      IF   NOT  AVAILABLE crapcco THEN
           DO:
                ASSIGN i-cod-erro = 472
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
           END.
		   
	  /* Ajuste para evitar busca de tarifa incorreta */	   
	  IF crapcco.flgregis <> crapcob.flgregis THEN
	      NEXT.	

      ASSIGN aux_inpessoa = 2.

      IF  p-nro-conta <> 0 THEN
          DO:
              FIND crapass WHERE crapass.cdcooper = p-cdcooper AND
                                 crapass.nrdconta = p-nro-conta NO-LOCK NO-ERROR.
    
              IF  AVAIL(crapass) THEN
                  ASSIGN aux_inpessoa = crapass.inpessoa.
          END.

    
      RUN pega_valor_tarifas(
           INPUT  p-cdcooper,
           INPUT  p-nro-conta,
           INPUT  p-cdprogra,
           INPUT  crapcob.nrcnvcob,
           INPUT  aux_inpessoa,
           OUTPUT tar_cdhistor,
           OUTPUT tar_cdhisest,
           OUTPUT tar_dtdivulg,
           OUTPUT tar_dtvigenc,
           OUTPUT tar_cdfvlcop,
           OUTPUT tar_vlrtarcx,
           OUTPUT tar_vlrtarnt,
           OUTPUT tar_vltrftaa,
           OUTPUT tar_vlrtarif,
           OUTPUT TABLE tt-erro).

      IF  RETURN-VALUE <> "OK"   THEN
           NEXT.

      FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper   AND
                               crapceb.nrdconta = crapcob.nrdconta   AND
                               crapceb.nrconven = crapcob.nrcnvcob
                               NO-LOCK NO-ERROR.

      IF   NOT AVAIL crapceb   THEN
           NEXT.

      /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
      IF   p-origem <> 3 THEN
           DO:
               IF   crapcob.incobran <> 5   OR 
                    crapcob.vldpagto  = 0   THEN
                    NEXT.
           END.

      /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
      IF   p-origem <> 3 THEN
           DO:
               IF   crapceb.inarqcbr = 0  OR  /*  Nao recebe arq. de Retorno */
                   (crapceb.inarqcbr = 2 AND
                    crapcco.dsorgarq = "PRE-IMPRESSO")  THEN          
                    NEXT.
           END.
      ELSE
      IF   p-origem = 3 THEN   /* Internet */
           DO:
               IF   crapceb.inarqcbr = 0  OR  /*  Nao recebe arq. de Retorno */
                   (crapceb.inarqcbr = 2 AND
                    crapcco.dsorgarq = "PRE-IMPRESSO")  THEN          
                    DO:
                        ASSIGN i-cod-erro = 36
                               c-dsc-erro = " ".
                        {sistema/generico/includes/b1wgen0001.i}

                        RETURN "NOK".
                    END.
           END.

      FIND crapcem WHERE crapcem.cdcooper = crapcob.cdcooper   AND
                         crapcem.nrdconta = crapcob.nrdconta   AND
                         crapcem.idseqttl = 1                  AND
                         crapcem.cddemail = crapceb.cddemail
                         NO-LOCK NO-ERROR.
      
      IF  crapcob.cdbandoc = 1 AND crapcob.indpagto = 0 THEN
          DO:
              ASSIGN aux_dtcredit = crapcob.dtdpagto + 1.
              DO WHILE TRUE:
                 IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtcredit)))          OR
                     CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cdcooper AND
                                            crapfer.dtferiad = aux_dtcredit)
                     THEN
                     DO:
                         ASSIGN aux_dtcredit = aux_dtcredit + 1.
                         NEXT.
                     END.
                 LEAVE.  
              END. /** Fim do DO WHILE TRUE **/
          END.
      ELSE
          ASSIGN aux_dtcredit = crapcob.dtdpagto.

      
      CREATE crawarq.
      ASSIGN crawarq.tparquiv = crapceb.inarqcbr
             crawarq.nrdconta = crapcob.nrdconta
             crawarq.nrdocmto = crapcob.nrdocmto
             crawarq.nrconven = crapcob.nrcnvcob
             crawarq.tamannro = crapcco.tamannro
             crawarq.nrdctabb = crapcco.nrdctabb   
             crawarq.vldpagto = crapcob.vldpagto
             crawarq.vlrtarcx = tar_vlrtarcx
             crawarq.vlrtarnt = tar_vlrtarnt  
             crawarq.vltrftaa = tar_vltrftaa /** TAA **/
             crawarq.vlrtarcm = tar_vlrtarif
             crawarq.inarqcbr = crapceb.inarqcbr 
             crawarq.flgutceb = crapcco.flgutceb
             crawarq.dsorgarq = crapcco.dsorgarq
             crawarq.indpagto = crapcob.indpagto
             crawarq.dtdpagto = crapcob.dtdpagto
             crawarq.dsdemail = crapcem.dsdemail WHEN AVAIL crapcem
             crawarq.cdbandoc = crapcob.cdbandoc 
             crawarq.dtcredit = aux_dtcredit.
                   
  END. /* for each */

  FIND FIRST crawarq WHERE crawarq.tparquiv = 2 NO-LOCK NO-ERROR.
  IF   AVAILABLE crawarq THEN
       RUN p_gera_arquivo_febraban (INPUT p-cdcooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT p-origem,
                                    INPUT p-cdprogra,
                                    INPUT  TABLE crawarq,
                                    OUTPUT TABLE tt-arq-cobranca,
                                    OUTPUT TABLE tt-erro).
                                    
  FIND FIRST crawarq WHERE crawarq.tparquiv = 1 NO-LOCK NO-ERROR.
  IF   AVAILABLE crawarq THEN
       RUN p_gera_arquivo_outros   (INPUT p-cdcooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT p-origem,
                                    INPUT p-cdprogra,
                                    INPUT  TABLE crawarq,
                                    OUTPUT TABLE tt-arq-cobranca,
                                    OUTPUT TABLE tt-erro).

END PROCEDURE.  /*  Fim  da  Procedure gera_retorno_arq_cobranca */

/* ......................................................................... */

PROCEDURE p_gera_arquivo_febraban:

   DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-origem       AS INTE NO-UNDO. 
                                          /* 1-AYLLOS/2-CAIXA/3-INTERNET */
   DEF INPUT  PARAMETER p-cdprogra     AS CHAR                         NO-UNDO.
 
   DEF INPUT  PARAM TABLE FOR crawarq.
   DEF OUTPUT PARAM TABLE FOR tt-arq-cobranca.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
 
   DEF        VAR aux_nmarqind AS CHAR                                  NO-UNDO.
   DEF        VAR aux_nossonro AS CHAR                                  NO-UNDO.
   DEF        VAR aux_nossonr2 AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dtmvtolt AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dsdahora AS CHAR                                  NO-UNDO.
   DEF        VAR aux_qtregist AS INT                                   NO-UNDO.
   DEF        VAR aux_dsstring AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dsdatamv AS CHAR                                  NO-UNDO.
   DEF        VAR aux_vlcredit AS DECIMAL                               NO-UNDO.
   DEF        VAR aux_vlacumul AS DEC                                   NO-UNDO.
   DEF        VAR aux_vltarifa AS DEC                                   NO-UNDO.
   DEF        VAR aux_cdseqlin AS INTEGER                               NO-UNDO.
   DEF        VAR aux_dslinha  AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dtdpagto AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dtcredit AS CHAR                                  NO-UNDO.

   ASSIGN aux_dtmvtolt = STRING(DAY(TODAY),"99") +
                         STRING(MONTH(TODAY),"99") +
                         STRING(YEAR(TODAY),"9999")
          aux_dsdahora = (SUBSTR(STRING(time,"HH:MM:SS"),1,2) +
                          SUBSTR(STRING(time,"HH:MM:SS"),4,2) +
                          SUBSTR(STRING(time,"HH:MM:SS"),7,2)).

   FOR EACH crawarq WHERE crawarq.tparquiv = 2
                USE-INDEX crawarq1 BREAK BY crawarq.nrconven
                                         BY crawarq.nrdconta
                                         BY crawarq.dtdpagto:
       
       IF   FIRST-OF(crawarq.nrconven) OR FIRST-OF(crawarq.nrdconta)  THEN
            DO:               
                ASSIGN aux_cdseqlin = 1.

                /******** HEADER DO ARQUIVO ************/
                ASSIGN aux_dslinha = 
                    "00100000"  +
                    "         " +
                    "2"         +
                    STRING(crapcop.nrdocnpj, "99999999999999") +
                    STRING(crawarq.nrconven, "999999999")      +
                    "           "                              +
                    STRING(crapcop.cdagedbb, "999999")         +
                    STRING(crawarq.nrdctabb, "9999999999999")  + 
                    " "                                        +
                    STRING(crapcop.nmrescop, "x(30)")          +
                    "BANCO DO BRASIL" +
                    FILL(" ",25)      +
                    "2"               +
                    STRING(aux_dtmvtolt, "x(08)") +
                    STRING(aux_dsdahora, "x(06)") + 
                    "000001"                      +
                    "00001"                       +
                    FILL(" ",72).
                
                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.

                /******** HEADER DO LOTE ************/
                ASSIGN aux_dslinha =
                    "00100011T01  030 2" +
                    STRING(crapcop.nrdocnpj, "999999999999999") + 
                    STRING(crawarq.nrconven, "999999999")       +
                    "           "                               +
                    STRING(crapcop.cdagedbb, "999999")          + 
                    STRING(crawarq.nrdctabb, "9999999999999")   + 
                    " "                                         +
                    STRING(crapcop.nmrescop, "x(30)")           +
                    FILL(" ",80)                                +
                    "00000001"                                  +
                    STRING(aux_dtmvtolt, "x(08)")               +
                    STRING(aux_dtmvtolt, "x(08)")               +
                    FILL(" ",33).

                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.
            END.    
                
       ASSIGN aux_qtregist = aux_qtregist + 1.

       IF  crawarq.indpagto = 1 THEN    /** caixa **/
           ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                  (crawarq.vlrtarcx * 100))
                  aux_vltarifa = crawarq.vlrtarcx * 100.
       ELSE 
           IF  crawarq.indpagto = 3 THEN   /** internet **/
               ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                      (crawarq.vlrtarnt * 100))
                      aux_vltarifa = crawarq.vlrtarnt * 100.
       ELSE 
           IF  crawarq.indpagto = 4 THEN   /** TAA **/
               ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                      (crawarq.vltrftaa * 100))
                      aux_vltarifa = crawarq.vltrftaa * 100.
       
       IF   crawarq.dsorgarq = "IMPRESSO PELO SOFTWARE" OR
            crawarq.dsorgarq = "MIGRACAO"               OR 
            crawarq.dsorgarq = "INCORPORACAO"           OR 
            crawarq.dsorgarq = "INTERNET"               THEN
            DO:
                IF   crawarq.flgutceb THEN
                     DO:
                         FIND crapceb WHERE 
                                      crapceb.cdcooper = p-cdcooper       AND
                                      crapceb.nrdconta = crawarq.nrdconta AND
                                      crapceb.nrconven = crawarq.nrconven
                                      USE-INDEX crapceb2 NO-LOCK NO-ERROR.
                       
                         IF   NOT AVAILABLE crapceb THEN
                              DO:
                                  ASSIGN i-cod-erro = 563
                                         c-dsc-erro = " ".
              
                             {sistema/generico/includes/b1wgen0001.i}

                                  RETURN "NOK".
                              END.
                         
                         

                         IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                             aux_nossonro = STRING(crawarq.nrconven,"9999999") +
                                            STRING(crapceb.nrcnvceb,"9999")    +
                                            STRING(crawarq.nrdocmto,"999999").
                         ELSE
                             aux_nossonro = STRING(crawarq.nrconven,"9999999")    +
                                            STRING(INT(SUBSTR(TRIM(STRING(
                                                   crapceb.nrcnvceb, "zzzz9"))
                                                   ,1,4)),"9999") +
                                            STRING(crawarq.nrdocmto,"999999").

                     END.
                ELSE
                     aux_nossonro = STRING(crawarq.nrdconta,"99999999") +
                                    STRING(crawarq.nrdocmto,"999999999").
            END.
       ELSE
            DO:
                IF   crawarq.tamannro = 12 THEN
                     aux_nossonro = STRING(crawarq.nrconven,"999999") +
                                    STRING(crawarq.nrdocmto,"999999").
                ELSE
                     aux_nossonro = STRING(crawarq.nrconven,"9999999") +
                                    STRING(crawarq.nrdocmto,"9999999999").
            END.

       ASSIGN aux_nossonr2 = "21" + FILL(" ",23 - LENGTH(aux_nossonro)) +
                             aux_nossonro.
                             
       IF   aux_vlcredit < 0 THEN
            aux_vlcredit = 0. 

       ASSIGN aux_dslinha =       
                        "00100013"                    +
                        STRING(aux_qtregist, "99999") + 
                        "T 06"                        +
                        STRING(crapcop.cdagedbb, "999999")        +
                        STRING(crawarq.nrdctabb, "9999999999999") +
                        " "                                       +
                        STRING(aux_nossonro, "x(20)")             +
                        "1"                                       +
                        FILL(" ",15)                              +
                        "00000000"                                +
                        STRING((crawarq.vldpagto * 100), "999999999999999") +
                        "001"                                     +
                        STRING(crapcop.cdagedbb, "999999")        +
                        STRING(aux_nossonr2, "x(25)")             +
                        "09"                                      +
                        FILL("0",66)                              +
                        STRING(aux_vltarifa, "999999999999999")   +
                        "00        "                              +
                        FILL("0",17).

       CREATE tt-arq-cobranca.
       ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
              tt-arq-cobranca.dslinha  = aux_dslinha
              aux_cdseqlin = aux_cdseqlin + 1.
                                                 
       ASSIGN aux_qtregist = aux_qtregist + 1.


       ASSIGN aux_dtdpagto = STRING(DAY(crawarq.dtdpagto),"99") +
                             STRING(MONTH(crawarq.dtdpagto),"99") +
                             STRING(YEAR(crawarq.dtdpagto),"9999").
       
       ASSIGN aux_dtcredit = STRING(DAY(crawarq.dtcredit),"99") +
                             STRING(MONTH(crawarq.dtcredit),"99") +
                             STRING(YEAR(crawarq.dtcredit),"9999").

       ASSIGN aux_dslinha =
                        "00100013"            +
                        STRING(aux_qtregist, "99999") +
                        "U 06"                        +
                        FILL("0",60)                  +
                        STRING((crawarq.vldpagto * 100), "999999999999999") +
                        STRING(aux_vlcredit, "999999999999999") +
                        FILL("0",30)                            +
                        STRING(aux_dtdpagto, "x(08)")           +
                        STRING(aux_dtcredit, "x(08)")           + 
                        FILL(" ",12)                            +
                        FILL("0",15)                            +
                        FILL(" ",30)                            +
                        "000"                                   +
                        FILL(" ",27).

       CREATE tt-arq-cobranca.
       ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
              tt-arq-cobranca.dslinha  = aux_dslinha
              aux_cdseqlin = aux_cdseqlin + 1.

       IF   LAST-OF(crawarq.nrconven) OR LAST-OF(crawarq.nrdconta)  THEN
            DO:
                /******** TRAILER DO LOTE ************/
                ASSIGN aux_dslinha =
                    "00100015"                           +
                    "         "                          +
                    STRING((aux_qtregist + 2), "999999") +
                    FILL("0",123)                        +
                    FILL(" ",094).

                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.
                
                /******** TRAILER DO ARQUIVO ************/
                ASSIGN aux_dslinha =
                    "00199999"                           +
                    "         "                          +
                    "000001"                             +
                    STRING((aux_qtregist + 4), "999999") +
                    "000000"                             +
                    FILL(" ",156)                        +
                    FILL("0",029)                        +
                    FILL(" ",020).
                
                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.
                
                /* Quando rotina chamada do Ayllos, deve-se enviar o arquivo
                   de retorno de cobranca via e-mail */
                IF   p-origem <> 3 THEN
                     DO:
                         IF   p-origem = 2 THEN
                              aux_nmarqind = "RET-caixa-".
                         ELSE aux_nmarqind = "RET-compe-". 

                         ASSIGN aux_dsdatamv = STRING(DAY(TODAY),"99") +
                                               STRING(MONTH(TODAY),"99") +
                                               STRING(YEAR(TODAY),"9999")
                                aux_nmarqind = aux_nmarqind +
                                    STRING(crawarq.nrconven,"99999999") + "-" +
                                    STRING(crawarq.nrdconta,"99999999") + "-" +
                                    STRING(aux_dsdatamv,"99999999")
                                aux_qtregist = 0.

                         OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + 
                                                      crapcop.dsdircop + 
                                                      "/arq/" + aux_nmarqind).
                        
                         /* gravar arquivo */
                         FOR EACH tt-arq-cobranca NO-LOCK
                                                  BY tt-arq-cobranca.cdseqlin:
                             PUT STREAM str_1 
                                        tt-arq-cobranca.dslinha FORMAT "x(240)"
                                        SKIP.
                         END.
                
                         OUTPUT STREAM str_1 CLOSE.

                         /* Limpar registros enviados */
                         EMPTY TEMP-TABLE tt-arq-cobranca.

                         RUN sistema/generico/procedures/b1wgen0011.p
                             PERSISTENT SET b1wgen0011.

                         RUN converte_arquivo IN b1wgen0011
                                          (INPUT p-cdcooper,
                                           INPUT "/usr/coop/" + 
                                                 crapcop.dsdircop +
                                                 "/arq/" + aux_nmarqind,
                                           INPUT aux_nmarqind).
                                   
                         UNIX SILENT VALUE("mv /usr/coop/" +
                                           crapcop.dsdircop +
                                           "/arq/" + aux_nmarqind + 
                                           " salvar 2>/dev/null").

                         RUN enviar_email IN b1wgen0011
                                      (INPUT p-cdcooper,
                                       INPUT p-cdprogra,
                                       INPUT crawarq.dsdemail,
                                       INPUT "ARQUIVO DE COBRANCA DA " + 
                                             crapcop.nmrescop,
                                       INPUT aux_nmarqind,
                                       INPUT true).
                       
                         DELETE PROCEDURE b1wgen0011.
                     END.
            END.          
   END.  /*   Fim do For Each   */

END.  /*  Fim  da  Procedure  p_gera_arquivo_febraban */


PROCEDURE p_gera_arquivo_outros:

   DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                      NO-UNDO.
   DEF INPUT  PARAMETER p-origem       AS INTE NO-UNDO. 
                                          /* 1-AYLLOS/2-CAIXA/3-INTERNET */
   DEF INPUT  PARAMETER p-cdprogra     AS CHAR                         NO-UNDO.
 
   DEF INPUT  PARAM TABLE FOR crawarq.
   DEF OUTPUT PARAM TABLE FOR tt-arq-cobranca.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF        VAR aux_nmarqind AS CHAR                                  NO-UNDO.
   DEF        VAR aux_nossonro AS CHAR                                  NO-UNDO.
   DEF        VAR aux_nossonr2 AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dtmvtolt AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dsdahora AS CHAR                                  NO-UNDO.
   DEF        VAR aux_qtregist AS INT                                   NO-UNDO.
   DEF        VAR aux_dsstring AS CHAR                                  NO-UNDO.
   DEF        VAR aux_dsdatamv AS CHAR                                  NO-UNDO.
   DEF        VAR aux_vlcredit AS DECIMAL                               NO-UNDO.
   DEF        VAR aux_vlacumul AS DEC                                   NO-UNDO.
   DEF        VAR aux_vltarifa AS DEC                                   NO-UNDO.
   DEF        VAR aux_cdseqlin AS INTEGER                               NO-UNDO.
   DEF        VAR aux_dslinha  AS CHAR                                  NO-UNDO.

   FOR EACH crawarq WHERE crawarq.tparquiv = 1
                USE-INDEX crawarq1 BREAK BY crawarq.nrconven 
                                         BY crawarq.nrdconta
                                         BY crawarq.dtdpagto:
   
       IF   FIRST-OF(crawarq.nrdconta) THEN
            DO:
                ASSIGN aux_cdseqlin = 1.
                
                /******** HEADER DO ARQUIVO ************/
                ASSIGN aux_dslinha =
                    "00000000000000000000000000000000000000000000000" +
                    "IED241"               +         /* Nome arquivo */
                    "001"                  +         /* Comp. Origem - 1 */
                    "0001"                 +         /* Nro Versao - 1 */
                    "001"                  +         /* Banco Destinatario */
                    "0"                    +         /* Digito Verif. Banco */
                    "3"                    +         /* 3 - Remessa */
                    STRING(YEAR(TODAY), "9999") +
                    STRING(MONTH(TODAY), "99")  +
                    STRING(DAY(TODAY), "99")    +
                    FILL(" ",77)                +
                    STRING(aux_qtregist, "9999999999").

                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.
            END.    
                
       ASSIGN aux_vlacumul = aux_vlacumul + (crawarq.vldpagto * 100)
              aux_qtregist = aux_qtregist + 1.
       
       IF   crawarq.dsorgarq = "IMPRESSO PELO SOFTWARE" OR
            crawarq.dsorgarq = "MIGRACAO"               OR 
            crawarq.dsorgarq = "INCORPORACAO"           OR
            crawarq.dsorgarq = "INTERNET"               THEN
            DO:
                IF   crawarq.flgutceb THEN
                     DO:
                         FIND crapceb WHERE 
                                      crapceb.cdcooper = p-cdcooper     AND
                                      crapceb.nrconven = crawarq.nrconven AND
                                      crapceb.nrdconta = crawarq.nrdconta
                                      USE-INDEX crapceb2 NO-LOCK NO-ERROR.

                         IF   NOT AVAILABLE crapceb THEN
                              DO:
                                  ASSIGN i-cod-erro = 563
                                         c-dsc-erro = " ".
              
                             {sistema/generico/includes/b1wgen0001.i}

                                  RETURN "NOK".
                              END.
                         
                         IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                             aux_nossonro = STRING(crawarq.nrconven,"9999999") +
                                            STRING(crapceb.nrcnvceb,"9999")    +
                                            STRING(crawarq.nrdocmto,"999999").
                         ELSE
                             aux_nossonro = STRING(crawarq.nrconven,"9999999")    +
                                            STRING(INT(SUBSTR(TRIM(STRING(
                                                   crapceb.nrcnvceb, "zzzz9"))
                                                   ,1,4)),"9999") +
                                            STRING(crawarq.nrdocmto,"999999").
                     END.
                ELSE
                     aux_nossonro = STRING(crawarq.nrdconta,"99999999") +
                                    STRING(crawarq.nrdocmto,"999999999").
            END.
       ELSE
            DO:
                IF   crawarq.tamannro = 12 THEN
                     aux_nossonro = STRING(crawarq.nrconven,"999999") +
                                    STRING(crawarq.nrdocmto,"999999").
                ELSE
                     aux_nossonro = STRING(crawarq.nrconven,"9999999") +
                                    STRING(crawarq.nrdocmto,"9999999999").
            END.
       
       ASSIGN aux_dslinha =  
                        "001"                +   /* Codigo do Banco */
                        "9"                  +   /* Codigo da Moeda */
                        "000000000000000"    +
                        "1"                  +   /* Codigo da Carteira */
                        "0001"               +   /* Codigo da Cooperativa */
                        STRING(aux_nossonro, "x(20)") + 
                        "016 "               +   /* Compe.Origem */
                        "99 "                +   /* Constante igual a 99 */
                        "001"                +   /* Codigo do Banco */
                        "001"                +   /* Codigo da Agencia */
                        "0000001"            +   /* Codigo do Lote */
                        STRING(aux_qtregist, "999")            +
                        STRING(YEAR(crawarq.dtdpagto), "9999") +
                        STRING(MONTH(crawarq.dtdpagto), "99")  +
                        STRING(DAY(crawarq.dtdpagto), "99")    +
                        FILL(" ",06)                           +
                        STRING((crawarq.vldpagto * 100), "999999999999") +
                        FILL(" ",57)                           +
                        STRING(aux_qtregist, "9999999999").

       CREATE tt-arq-cobranca.
       ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
              tt-arq-cobranca.dslinha  = aux_dslinha
              aux_cdseqlin = aux_cdseqlin + 1.

       IF   LAST-OF(crawarq.nrdconta) THEN
            DO:
                ASSIGN aux_qtregist = aux_qtregist + 1.
                
                /******** TRAILER DO ARQUIVO ************/
                ASSIGN aux_dslinha =
                    "99999999999999999999999999999999999999999999999" +
                    "IED241"                        +  /* Nome arquivo */
                    "001"                           +  /* Comp. Origem - 1 */
                    "0001"                          +  /* Nro Versao - 1 */
                    "001"                           +  /* Banco Destinatario */
                    "0"                             +  /* Digito Banco */
                    "3"                             +  /* 3 - Remessa */
                    STRING(YEAR(TODAY), "9999") +
                    STRING(MONTH(TODAY), "99")  +
                    STRING(DAY(TODAY), "99")    +
                    STRING(aux_vlacumul, "99999999999999999") +
                    FILL(" ",60)                              +
                    STRING(aux_qtregist, "9999999999").     
                     
                CREATE tt-arq-cobranca.
                ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                       tt-arq-cobranca.dslinha  = aux_dslinha
                       aux_cdseqlin = aux_cdseqlin + 1.     

                /* Quando rotina chamada do Ayllos, deve-se enviar o arquivo
                   de retorno de cobranca via e-mail */
                IF   p-origem <> 3 THEN
                     DO:
                         IF   p-origem = 2 THEN
                              ASSIGN aux_nmarqind = "cb" + 
                                        STRING(crawarq.nrdconta,"99999999") + 
                                        STRING(DAY(TODAY),"99") +
                                        STRING(MONTH(TODAY),"99") +
                                        "-caixa" + ".cob".
                         ELSE 
                              ASSIGN aux_nmarqind = "cb" + 
                                        STRING(crawarq.nrdconta,"99999999") + 
                                        STRING(DAY(TODAY),"99") +
                                        STRING(MONTH(TODAY),"99") +
                                        "-compe" + ".cob".

                         ASSIGN aux_qtregist = 1
                                aux_vlacumul = 0.
                                                    
                         OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + 
                                                      crapcop.dsdircop +
                                                      "/arq/" + aux_nmarqind).

                         /* gravar arquivo */
                         FOR EACH tt-arq-cobranca NO-LOCK
                                                  BY tt-arq-cobranca.cdseqlin:
                             PUT STREAM str_1 
                                        tt-arq-cobranca.dslinha FORMAT "x(160)"
                                        SKIP.
                         END.

                         OUTPUT STREAM str_1 CLOSE.

                         /* Limpar registros enviados */
                         EMPTY TEMP-TABLE tt-arq-cobranca.
       
                         RUN sistema/generico/procedures/b1wgen0011.p
                             PERSISTENT SET b1wgen0011.
           
                         RUN converte_arquivo IN b1wgen0011
                                    (INPUT p-cdcooper,      
                                     INPUT "/usr/coop/" + 
                                           crapcop.dsdircop +
                                           "/arq/" + aux_nmarqind,
                                     INPUT aux_nmarqind).
                                                          
                         UNIX SILENT VALUE("mv /usr/coop/" +
                                           crapcop.dsdircop +
                                           "/arq/" + aux_nmarqind + 
                                           " salvar 2>/dev/null").

                         RUN enviar_email IN b1wgen0011
                                      (INPUT p-cdcooper,
                                       INPUT p-cdprogra,
                                       INPUT crawarq.dsdemail,
                                       INPUT "ARQUIVO DE COBRANCA DA " + 
                                             crapcop.nmrescop,
                                       INPUT aux_nmarqind,
                                       INPUT true).
                       
                         DELETE PROCEDURE b1wgen0011.
                     END.
            END.          
                
   END.  /*   Fim do For Each   */
END.  /*  Fim  da  Procedure p_gera_arquivo_outros */

PROCEDURE retorna-convenios:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-convenios-cobranca.

    /* FOR EACH crapcob WHERE crapcob.cdcooper = par_cdcooper AND
                           crapcob.nrdconta = par_nrdconta NO-LOCK
                           BREAK BY crapcob.nrcnvcob:
                           
        IF  FIRST-OF(crapcob.nrcnvcob)  THEN
            DO:
                CREATE tt-convenios-cobranca.
                ASSIGN tt-convenios-cobranca.nrcnvcob = crapcob.nrcnvcob.
            END. 

    END. /** Fim do FOR EACH crapcob **/ */

    FOR EACH crapcco WHERE 
             crapcco.cdcooper = par_cdcooper
             NO-LOCK
       ,EACH crapceb WHERE 
             crapceb.cdcooper = crapcco.cdcooper AND
             crapceb.nrconven = crapcco.nrconven AND
             crapceb.nrdconta = par_nrdconta
             BREAK BY crapceb.nrconven:

        IF  FIRST-OF(crapceb.nrconven)  THEN
            DO:
                CREATE tt-convenios-cobranca.
                ASSIGN tt-convenios-cobranca.nrcnvcob = crapceb.nrconven.
            END. 
    END. /** Fim do FOR EACH crapcco/crapceb **/

    RETURN "OK".
                           
END PROCEDURE. /* retorna-convenios */


PROCEDURE retorna-convenios-remessa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-convenios-cobrem.
    
    EMPTY TEMP-TABLE tt-convenios-cobrem.
    
    FOR EACH crapcco 
       WHERE crapcco.cdcooper = par_cdcooper
         AND crapcco.dsorgarq = "IMPRESSO PELO SOFTWARE"
         /* AND crapcco.flgativo = TRUE */
         NO-LOCK
       ,EACH crapceb
       WHERE crapceb.cdcooper = crapcco.cdcooper
         AND crapceb.nrdconta = par_nrdconta
         AND crapceb.nrconven = crapcco.nrconven
         AND crapceb.insitceb = 1
         NO-LOCK:
        
        FIND LAST craprtc
            WHERE craprtc.cdcooper = crapcco.cdcooper
              AND craprtc.nrcnvcob = crapcco.nrconven
              AND craprtc.nrdconta = par_nrdconta
              AND craprtc.intipmvt = 1 /* remessa */
              NO-LOCK NO-ERROR.

        CREATE tt-convenios-cobrem.
        ASSIGN tt-convenios-cobrem.cddbanco = crapcco.cddbanco
               tt-convenios-cobrem.nrconven = crapcco.nrconven
               tt-convenios-cobrem.nrremret = (IF AVAIL craprtc THEN 
                                               craprtc.nrremret 
                                               ELSE 0).
    END.

    RETURN "OK".
                           
END PROCEDURE. /* retorna-convenios */


PROCEDURE gera_retorno_arq_cobranca_coopcob:

  DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-dtmvtolt     AS DATE                         NO-UNDO.
  DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                      NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_nmarqind AS CHAR                                        NO-UNDO.
  DEF VAR aux_nossonro AS CHAR                                        NO-UNDO.
  DEF VAR aux_nossonr2 AS CHAR                                        NO-UNDO.
  DEF VAR aux_dtmvtolt AS CHAR                                        NO-UNDO.
  DEF VAR aux_dsdahora AS CHAR                                        NO-UNDO.
  DEF VAR aux_qtregist AS INT                                         NO-UNDO.
  DEF VAR aux_dsstring AS CHAR                                        NO-UNDO.
  DEF VAR aux_dsdatamv AS CHAR                                        NO-UNDO.
  DEF VAR aux_vlcredit AS DECIMAL                                     NO-UNDO.
  DEF VAR aux_vlacumul AS DEC                                         NO-UNDO.
  DEF VAR aux_vltarifa AS DEC                                         NO-UNDO.
  DEF VAR aux_cdseqlin AS INTEGER                                     NO-UNDO.
  DEF VAR aux_dslinha  AS CHAR                                        NO-UNDO.
  DEF VAR aux_dtdpagto AS CHAR                                        NO-UNDO.
  DEF VAR aux_dsdircob AS CHAR                                        NO-UNDO.
  DEF VAR aux_inarqcbr AS INT                                         NO-UNDO.
  DEF VAR aux_cddemail AS INT                                         NO-UNDO.
 
  /*--  Busca dados da cooperativa  --*/
  FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE crapcop THEN
       DO:
           ASSIGN i-cod-erro = 651
                  c-dsc-erro = " ".
           
           { sistema/generico/includes/b1wgen0001.i }

           RETURN "NOK".
       END.

  EMPTY TEMP-TABLE crawarq.
  EMPTY TEMP-TABLE tt-arq-cobranca.
    
  
  FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper
                     AND crapcco.flcopcob = TRUE NO-LOCK:


      FOR EACH crapcob WHERE crapcob.cdcooper  = p-cdcooper       AND
                             crapcob.dtdpagto  = p-dtmvtolt       AND
                             crapcob.nrcnvcob  = crapcco.nrconven NO-LOCK:

          /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
          IF   crapcob.incobran <> 5  THEN
               NEXT.  
    
          FIND FIRST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper   AND
                                   crapceb.nrdconta = crapcob.nrdconta   AND
                                   crapceb.nrconven = crapcob.nrcnvcob
                                   NO-LOCK NO-ERROR.

          IF   NOT AVAIL crapceb THEN
               ASSIGN aux_inarqcbr = 0
                      aux_cddemail = 0.
          ELSE 
               ASSIGN aux_inarqcbr = crapceb.inarqcbr
                      aux_cddemail = crapceb.cddemail.

          FIND crapcem WHERE crapcem.cdcooper = crapcob.cdcooper   AND
                             crapcem.nrdconta = crapcob.nrdconta   AND
                             crapcem.idseqttl = 1                  AND
                             crapcem.cddemail = aux_cddemail
                             NO-LOCK NO-ERROR.
          
          FIND crapass WHERE crapass.cdcooper = crapcob.cdcooper AND
                             crapass.nrdconta = crapcob.nrdconta
                             NO-LOCK NO-ERROR.

          IF  AVAIL(crapass) THEN
              ASSIGN aux_inpessoa = crapass.inpessoa.
          ELSE
              ASSIGN aux_inpessoa = 2.

          RUN pega_valor_tarifas(
              INPUT  p-cdcooper,
              INPUT  crapcob.nrdconta,
              INPUT  "",
              INPUT  crapcob.nrcnvcob,
              INPUT  aux_inpessoa,
              OUTPUT tar_cdhistor,
              OUTPUT tar_cdhisest,
              OUTPUT tar_dtdivulg,
              OUTPUT tar_dtvigenc,
              OUTPUT tar_cdfvlcop,
              OUTPUT tar_vlrtarcx,
              OUTPUT tar_vlrtarnt,
              OUTPUT tar_vltrftaa,
              OUTPUT tar_vlrtarif,
              OUTPUT TABLE tt-erro).

          IF  RETURN-VALUE <> "OK"   THEN
              NEXT.  


          CREATE crawarq.
          ASSIGN crawarq.tparquiv = aux_inarqcbr
                 crawarq.nrdconta = crapcob.nrdconta
                 crawarq.nrdocmto = crapcob.nrdocmto
                 crawarq.nrconven = crapcob.nrcnvcob
                 crawarq.tamannro = crapcco.tamannro
                 crawarq.nrdctabb = crapcco.nrdctabb   
                 crawarq.vldpagto = crapcob.vldpagto
                 crawarq.vlrtarcx = tar_vlrtarcx
                 crawarq.vlrtarnt = tar_vlrtarnt  
                 crawarq.vltrftaa = tar_vltrftaa /** TAA **/
                 crawarq.vlrtarcm = tar_vlrtarif
                 crawarq.inarqcbr = aux_inarqcbr
                 crawarq.flgutceb = crapcco.flgutceb
                 crawarq.dsorgarq = crapcco.dsorgarq
                 crawarq.indpagto = crapcob.indpagto
                 crawarq.dtdpagto = crapcob.dtdpagto
                 crawarq.dsdemail = crapcem.dsdemail WHEN AVAIL crapcem.
                  
          ASSIGN aux_dsdircob = TRIM(crapcco.nmdireto).
      
      END. /* for each CRAPCOB */

  END. /* for each CRAPCCO */

  FIND FIRST crawarq NO-LOCK NO-ERROR.
  IF   AVAILABLE crawarq THEN
       DO:
           ASSIGN aux_dtmvtolt = STRING(DAY(TODAY),"99") +
                                 STRING(MONTH(TODAY),"99") +
                                 STRING(YEAR(TODAY),"9999")
                  aux_dsdahora = (SUBSTR(STRING(time,"HH:MM:SS"),1,2) +
                                 SUBSTR(STRING(time,"HH:MM:SS"),4,2) +
                                 SUBSTR(STRING(time,"HH:MM:SS"),7,2)).

           FOR EACH crawarq WHERE crawarq.tparquiv = 2
                        USE-INDEX crawarq1 BREAK BY crawarq.nrconven
                                                 BY crawarq.nrdconta
                                                 BY crawarq.dtdpagto:
       
               IF   FIRST-OF(crawarq.nrconven)  THEN
                    DO:               
                        ASSIGN aux_cdseqlin = 1.

                        /******** HEADER DO ARQUIVO ************/
                        ASSIGN aux_dslinha = "00100000         2" +
                                   STRING(crapcop.nrdocnpj,"99999999999999") +
                                   STRING(crawarq.nrconven,"999999999")      +
                                   "           " + 
                                   STRING(crapcop.cdagedbb,"999999") +
                                   STRING(crawarq.nrdctabb,"9999999999999") + 
                                   " " + STRING(crapcop.nmrescop,"x(30)") +
                                   "BANCO DO BRASIL" + FILL(" ",25) + "2" + 
                                   STRING(aux_dtmvtolt,"x(08)") +
                                   STRING(aux_dsdahora, "x(06)") + 
                                   "00000100001" + FILL(" ",72).
                
                        CREATE tt-arq-cobranca.
                        ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                               tt-arq-cobranca.dslinha  = aux_dslinha
                               aux_cdseqlin = aux_cdseqlin + 1.

                        /******** HEADER DO LOTE ************/
                        ASSIGN aux_dslinha = "00100011T01  030 2" +
                               STRING(crapcop.nrdocnpj, "999999999999999") + 
                               STRING(crawarq.nrconven, "999999999") + 
                               "           " + 
                               ST~RING(crapcop.cdagedbb, "999999") + 
                               STRING(crawarq.nrdctabb, "9999999999999") + " " +
                               STRING(crapcop.nmrescop, "x(30)") + FILL(" ",80)
                               + "00000001" + STRING(aux_dtmvtolt, "x(08)") +
                               STRING(aux_dtmvtolt, "x(08)") + FILL(" ",33).

                        CREATE tt-arq-cobranca.
                        ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                               tt-arq-cobranca.dslinha  = aux_dslinha
                               aux_cdseqlin = aux_cdseqlin + 1.
                    END.    
                
               ASSIGN aux_qtregist = aux_qtregist + 1.

               
               IF   crawarq.indpagto = 0 THEN   /**   compe  **/
                    ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                           (crawarq.vlrtarcm * 100))
                           aux_vltarifa = crawarq.vlrtarcm * 100.
               ELSE
               IF   crawarq.indpagto = 1 THEN    /** caixa **/
                    ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                          (crawarq.vlrtarcx * 100))
                           aux_vltarifa = crawarq.vlrtarcx * 100.
               ELSE
               IF   crawarq.indpagto = 3 THEN   /** internet **/
                    ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                          (crawarq.vlrtarnt * 100))
                           aux_vltarifa = crawarq.vlrtarnt * 100.
               ELSE
               IF   crawarq.indpagto = 4 THEN   /** TAA **/
                    ASSIGN aux_vlcredit = ((crawarq.vldpagto * 100) -
                                          (crawarq.vltrftaa * 100))
                           aux_vltarifa = crawarq.vltrftaa * 100.


               IF   crawarq.dsorgarq = "IMPRESSO PELO SOFTWARE" OR
                    crawarq.dsorgarq = "INTERNET"               OR 
                    crawarq.dsorgarq = "INCORPORACAO"           OR 
                    crawarq.dsorgarq = "MIGRACAO"               THEN
                    aux_nossonro = STRING(crawarq.nrdconta,"99999999") +
                                   STRING(crawarq.nrdocmto,"999999999").

               IF  LENGTH(STRING(crawarq.nrconven)) = 7 THEN
                   DO:
                        FIND crapceb WHERE
                             crapceb.cdcooper = p-cdcooper        AND
                             crapceb.nrdconta = crawarq.nrdconta  AND
                             crapceb.nrconven = crawarq.nrconven
                             NO-LOCK NO-ERROR.

                        IF  AVAIL crapceb THEN
                            DO:
                                IF  LENGTH(TRIM(STRING(crapceb.nrcnvceb,"zzzz9"))) <= 4 THEN
                                    aux_nossonro = STRING(crawarq.nrconven,"9999999") +
                                                   STRING(crapceb.nrcnvceb,"9999") +
                                                   STRING(crawarq.nrdocmto,"999999").
                                ELSE
                                    aux_nossonro = STRING(crawarq.nrconven,"9999999")    +
                                                   STRING(INT(SUBSTR(TRIM(STRING(
                                                   crapceb.nrcnvceb, "zzzz9")) 
                                                   ,1,4)),"9999") +
                                                   STRING(crawarq.nrdocmto,"999999").
                            END.
                   END.
                                
               ASSIGN aux_nossonr2 = "21" + FILL(" ",23 - LENGTH(aux_nossonro))
                                     + aux_nossonro.

                             
               IF   aux_vlcredit < 0 THEN
                    aux_vlcredit = 0. 

               ASSIGN aux_dslinha = "00100013" + STRING(aux_qtregist, "99999") +
                                    "T 06" + STRING(crapcop.cdagedbb, "999999")
                                    + STRING(crawarq.nrdctabb, "9999999999999")
                                    + " " + STRING(aux_nossonro, "x(20)") + "1"
                                    + FILL(" ",15) + "00000000" +
                                    STRING((crawarq.vldpagto * 100),
                                               "999999999999999") +
                                    "001" + STRING(crapcop.cdagedbb, "999999") +
                                    STRING(aux_nossonr2,"x(25)") + "09" +
                                    FILL("0",66) + 
                                    STRING(aux_vltarifa, "999999999999999") +
                                    "00        " + FILL("0",17).

               CREATE tt-arq-cobranca.
               ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                      tt-arq-cobranca.dslinha  = aux_dslinha
                      aux_cdseqlin = aux_cdseqlin + 1.
                                                 
               ASSIGN aux_qtregist = aux_qtregist + 1 
                      aux_dtdpagto = STRING(DAY(crawarq.dtdpagto),"99") +
                                     STRING(MONTH(crawarq.dtdpagto),"99") +
                                     STRING(YEAR(crawarq.dtdpagto),"9999") 
                      aux_dslinha = "00100013" + STRING(aux_qtregist, "99999") +
                                    "U 06" + FILL("0",60) +
                                    STRING((crawarq.vldpagto * 100),
                                            "999999999999999") +
                                    STRING(aux_vlcredit,"999999999999999") +
                                    FILL("0",30) + STRING(aux_dtdpagto, "x(08)")
                                    + STRING(aux_dtdpagto, "x(08)") + 
                                    FILL(" ",12) + FILL("0",15) + FILL(" ",30) +
                                    "000" + FILL(" ",27).

               CREATE tt-arq-cobranca.
               ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                      tt-arq-cobranca.dslinha  = aux_dslinha
                      aux_cdseqlin = aux_cdseqlin + 1.

               IF   LAST-OF(crawarq.nrconven) THEN
                    DO:
                        /******** TRAILER DO LOTE ************/
                        ASSIGN aux_dslinha = "00100015         " +       
                                         STRING((aux_qtregist + 2), "999999") +
                                         FILL("0",123) + FILL(" ",094).
                        CREATE tt-arq-cobranca.
                        ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                               tt-arq-cobranca.dslinha  = aux_dslinha
                               aux_cdseqlin = aux_cdseqlin + 1.
                
                        /******** TRAILER DO ARQUIVO ************/
                        ASSIGN aux_dslinha = "00199999         000001" +
                                         STRING((aux_qtregist + 4), "999999") +
                                         "000000" + FILL(" ",156) +
                                         FILL("0",029) + FILL(" ",020).
                
                        CREATE tt-arq-cobranca.
                        ASSIGN tt-arq-cobranca.cdseqlin = aux_cdseqlin
                               tt-arq-cobranca.dslinha  = aux_dslinha
                               aux_cdseqlin = aux_cdseqlin + 1
                               aux_dsdatamv = STRING(DAY(TODAY),"99") +
                                              STRING(MONTH(TODAY),"99") +
                                              STRING(YEAR(TODAY),"9999").

                        ASSIGN aux_nmarqind = "CoopCob-" + 
                                  STRING(crawarq.nrconven,"99999999") + "-" +
                                  STRING(aux_dsdatamv,"99999999") + ".dat"
                               aux_qtregist = 0.
                                                          
                        OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + 
                                                     crapcop.dsdircop +
                                                     "/arq/" + aux_nmarqind).
                        
                        /* gravar arquivo */
                        FOR EACH tt-arq-cobranca NO-LOCK 
                             BY tt-arq-cobranca.cdseqlin:
                  
                            PUT STREAM str_1 
                                SKIP
                                tt-arq-cobranca.dslinha FORMAT "x(240)".
                        END.
                
                        OUTPUT STREAM str_1 CLOSE.

                        /* Limpar registros enviados */
                        EMPTY TEMP-TABLE tt-arq-cobranca.
                        
                        /* Salvar arq. no diret. /micros/viacredi/cobranca */
                        UNIX SILENT VALUE("ux2dos < /usr/coop/" + 
                                          crapcop.dsdircop +
                                          "/arq/" + aux_nmarqind + 
                                          ' | tr -d "\032" > ' + aux_dsdircob +
                                          "/" + aux_nmarqind + " 2>/dev/null").
                        
                        UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop +
                                          "/arq/" + aux_nmarqind + 
                                          " 2>/dev/null").
                    END.          
           END.  /*   Fim do For Each   */
       END.                             

END PROCEDURE.  /*  Fim  da  Procedure gera_retorno_arq_cobranca */



PROCEDURE gera_totais_cobranca:

  DEF INPUT  PARAMETER p-cdcooper     AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-nro-conta    AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-cod-agencia  AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-nro-caixa    AS INTEGER                      NO-UNDO.
  DEF INPUT  PARAMETER p-origem       AS INTEGER                      NO-UNDO. 

  DEF OUTPUT PARAMETER TABLE FOR tt-erro.
  DEF OUTPUT PARAMETER TABLE FOR tt-totais-cobranca.
  
  def var aux_contador as int.
  
  DEF VAR aux_cdsituac AS CHAR                                        NO-UNDO.
  DEF VAR aux_indicado AS INTE                                        NO-UNDO.
  /* 1 aberto(vencidos), 2 liquidados, 3 baixado, 4 descontados */
      
    IF   p-origem <> 3  THEN      /* Atualmente somente para Internet */
         DO:
             ASSIGN i-cod-erro = 329 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapdat  THEN
         DO:
             ASSIGN i-cod-erro = 1 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}
             
             RETURN "NOK".
         END.

    FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                       crapass.nrdconta = p-nro-conta NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapass  THEN
         DO:
             ASSIGN i-cod-erro = 9 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper  AND
/*                           crapcco.flgativo = TRUE        AND*/
                           crapcco.flginter = TRUE        AND
                           crapcco.flgregis = FALSE       NO-LOCK,
        EACH crapcob WHERE crapcob.cdcooper = crapcco.cdcooper AND
                           crapcob.nrdconta = p-nro-conta      AND
                           crapcob.cdbandoc = crapcco.cddbanco AND
                           crapcob.nrdctabb = crapcco.nrdctabb AND
                           crapcob.nrcnvcob = crapcco.nrconven 
                           USE-INDEX crapcob2 NO-LOCK:
    
        ASSIGN aux_cdsituac = ""
               aux_indicado = 0.
        
        IF   crapcob.dtdpagto = ? AND crapcob.incobran = 0  THEN
             DO:
                  IF   crapcob.dtvencto <= crapdat.dtmvtoan THEN
                       ASSIGN aux_cdsituac = "V".
                  ELSE
                       ASSIGN aux_cdsituac = "A".

                  ASSIGN aux_indicado = 1.
             END.                       
        ELSE
        IF   crapcob.dtdpagto <> ? AND crapcob.dtdbaixa = ?  THEN
             ASSIGN aux_cdsituac = "L"
                    aux_indicado = 2.
        ELSE
        IF   crapcob.dtdbaixa <> ? OR crapcob.incobran = 3 THEN 
             ASSIGN aux_cdsituac = "B"
                    aux_indicado = 3.
   
        FIND FIRST tt-totais-cobranca NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE tt-totais-cobranca THEN
             DO:
                 CREATE tt-totais-cobranca.
                 ASSIGN tt-totais-cobranca.cdcooper = p-cdcooper
                        tt-totais-cobranca.nrdconta = p-nro-conta
                        tt-totais-cobranca.nrcnvcob = crapcco.nrconven
                        tt-totais-cobranca.dtmvtolt = crapdat.dtmvtolt.
             END.           
                
        IF   aux_cdsituac = "V" THEN
             ASSIGN tt-totais-cobranca.qtvencid = 
                       tt-totais-cobranca.qtvencid + 1
                    tt-totais-cobranca.vlvencid =
                       tt-totais-cobranca.vlvencid + crapcob.vltitulo.

        IF   aux_cdsituac = "A" THEN
             RUN grava_totais(INPUT aux_indicado,
                              INPUT crapcob.dtvencto,
                              INPUT crapcob.vltitulo).
        ELSE
        IF   aux_cdsituac = "L" THEN
             RUN grava_totais(INPUT aux_indicado,
                              INPUT crapcob.dtdpagto,
                              INPUT crapcob.vldpagto).
        ELSE
        IF   aux_cdsituac = "B" THEN 
             RUN grava_totais(INPUT aux_indicado,
                              INPUT crapcob.dtdbaixa,
                              INPUT crapcob.vltitulo).
        
        FIND LAST craptdb 
            WHERE craptdb.cdcooper = crapcob.cdcooper AND
                  craptdb.nrdconta = crapcob.nrdconta AND
                  craptdb.cdbandoc = crapcob.cdbandoc AND
                  craptdb.nrdctabb = crapcob.nrdctabb AND
                  craptdb.nrcnvcob = crapcob.nrcnvcob AND
                  craptdb.nrdocmto = crapcob.nrdocmto   
                  NO-LOCK NO-ERROR.
                      
        IF   AVAILABLE craptdb THEN
             DO:
                 IF   craptdb.insittit = 2 OR
                      craptdb.insittit = 3 OR
                      craptdb.insittit = 4 THEN           
                      RUN grava_totais(INPUT 4,
                                       INPUT craptdb.dtlibbdt,
                                       INPUT crapcob.vltitulo).
             END.                          
    END.
        
    RETURN "OK".    

END PROCEDURE. /* gera_totais_cobranca */
    

PROCEDURE grava_totais:

  DEF INPUT        PARAM p-indicado       AS INTE.
  DEF INPUT        PARAM p-dttitulo       AS DATE.
  DEF INPUT        PARAM p-vltitulo       AS DECIMAL.

  IF   p-indicado = 1 THEN
       DO:
           IF   p-dttitulo = crapdat.dtmvtolt THEN
                ASSIGN tt-totais-cobranca.qtdatual[p-indicado] =
                         tt-totais-cobranca.qtdatual[p-indicado] + 1
                       tt-totais-cobranca.vldatual[p-indicado] =
                         tt-totais-cobranca.vldatual[p-indicado] + p-vltitulo.
           ELSE
           IF   p-dttitulo <= (crapdat.dtmvtolt + 10) THEN
                ASSIGN tt-totais-cobranca.qtate10d[p-indicado] =
                         tt-totais-cobranca.qtate10d[p-indicado] + 1
                       tt-totais-cobranca.vlate10d[p-indicado] =
                         tt-totais-cobranca.vlate10d[p-indicado] + p-vltitulo.
           ELSE
           IF   p-dttitulo <= (crapdat.dtmvtolt + 30) THEN
                ASSIGN tt-totais-cobranca.qtate30d[p-indicado] =
                         tt-totais-cobranca.qtate30d[p-indicado] + 1
                       tt-totais-cobranca.vlate30d[p-indicado] =
                         tt-totais-cobranca.vlate30d[p-indicado] + p-vltitulo.
           ELSE
                ASSIGN tt-totais-cobranca.qtsup30d[p-indicado] =
                         tt-totais-cobranca.qtsup30d[p-indicado] + 1
                       tt-totais-cobranca.vlsup30d[p-indicado] =
                         tt-totais-cobranca.vlsup30d[p-indicado] + p-vltitulo.
       END.
  ELSE
  IF   p-indicado = 2 THEN
       DO:
           IF   p-dttitulo = crapdat.dtmvtolt THEN
                ASSIGN tt-totais-cobranca.qtdatual[p-indicado] =
                         tt-totais-cobranca.qtdatual[p-indicado] + 1
                       tt-totais-cobranca.vldatual[p-indicado] =
                         tt-totais-cobranca.vldatual[p-indicado] + p-vltitulo.
           ELSE
                DO:
                   IF   p-dttitulo >= (crapdat.dtmvtolt - 10) THEN
                        ASSIGN tt-totais-cobranca.qtate10d[p-indicado] =
                                 tt-totais-cobranca.qtate10d[p-indicado] + 1
                               tt-totais-cobranca.vlate10d[p-indicado] =
                                 tt-totais-cobranca.vlate10d[p-indicado] +
                                 p-vltitulo.

                   IF   p-dttitulo >= (crapdat.dtmvtolt - 30) THEN
                        ASSIGN tt-totais-cobranca.qtate30d[p-indicado] =
                                 tt-totais-cobranca.qtate30d[p-indicado] + 1
                               tt-totais-cobranca.vlate30d[p-indicado] =
                                 tt-totais-cobranca.vlate30d[p-indicado] +
                                 p-vltitulo.
                END.

           ASSIGN tt-totais-cobranca.qtsup30d[p-indicado] =
                                 tt-totais-cobranca.qtsup30d[p-indicado] + 1
                  tt-totais-cobranca.vlsup30d[p-indicado] =
                                 tt-totais-cobranca.vlsup30d[p-indicado] +
                                 p-vltitulo.
       END.  
  ELSE
  IF   p-indicado = 3 OR
       p-indicado = 4 THEN
       DO:
           IF   p-dttitulo = crapdat.dtmvtolt THEN
                ASSIGN tt-totais-cobranca.qtdatual[p-indicado] =
                         tt-totais-cobranca.qtdatual[p-indicado] + 1
                       tt-totais-cobranca.vldatual[p-indicado] =
                         tt-totais-cobranca.vldatual[p-indicado] + p-vltitulo.
           ELSE
           IF   p-dttitulo  >= (crapdat.dtmvtolt - 10) THEN
                ASSIGN tt-totais-cobranca.qtate10d[p-indicado] =
                         tt-totais-cobranca.qtate10d[p-indicado] + 1
                       tt-totais-cobranca.vlate10d[p-indicado] =
                         tt-totais-cobranca.vlate10d[p-indicado] + p-vltitulo.
           ELSE
           IF   p-dttitulo >= (crapdat.dtmvtolt - 30) THEN
                ASSIGN tt-totais-cobranca.qtate30d[p-indicado] =
                         tt-totais-cobranca.qtate30d[p-indicado] + 1
                       tt-totais-cobranca.vlate30d[p-indicado] =
                         tt-totais-cobranca.vlate30d[p-indicado] + p-vltitulo.
           ELSE
                ASSIGN tt-totais-cobranca.qtsup30d[p-indicado] =
                         tt-totais-cobranca.qtsup30d[p-indicado] + 1
                       tt-totais-cobranca.vlsup30d[p-indicado] =
                         tt-totais-cobranca.vlsup30d[p-indicado] + p-vltitulo.
       END.
        
END PROCEDURE. /* grava_totais */

                       
/***************************************************************************/

PROCEDURE busca_critica.
 
   DEF  INPUT PARAM p_cdcritic AS INT     FORMAT "zz9"              NO-UNDO.
   DEF OUTPUT PARAM p_dscritic AS CHAR    FORMAT "x(40)"            NO-UNDO.

   FIND crapcri WHERE crapcri.cdcritic = p_cdcritic 
        NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapcri   THEN
        p_dscritic = STRING(p_cdcritic) + " - Critica nao cadastrada!".
   ELSE
        p_dscritic = crapcri.dscritic.

END. /* busca_critica */

/***************************************************************************/


PROCEDURE integra_boletos:
    /*************************************************************************
        Objetivo: Importar os boletos do(s) arquivo(s)
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR cratarq.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-erros-arq.
    DEF OUTPUT PARAM TABLE FOR tt-boletos-imp.
    DEF OUTPUT PARAM TABLE FOR tt-boletos-rej.

    EMPTY TEMP-TABLE tt-erros-arq.
    EMPTY TEMP-TABLE tt-boletos-imp.
    EMPTY TEMP-TABLE tt-boletos-rej.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.

    IF   NOT CAN-FIND(FIRST cratarq)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nao foram informados arquivos para " +
                                   "importacao"
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.

    IF   NOT CAN-FIND(FIRST cratarq WHERE cratarq.flgmarca = TRUE)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nao foram selecionados arquivos para " +
                                   "importacao"
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.
         
    bloco_arquivos:         
    FOR EACH cratarq WHERE cratarq.flgmarca BY cratarq.nrsequen:
    
        ASSIGN aux_contador = aux_contador + 1
               aux_nmfisico = "integra/cobran" + 
                              STRING(par_dtmvtolt,"999999") + "_" + 
                              STRING(aux_contador,"9999").
      
        UNIX SILENT VALUE("dos2ux " + cratarq.nmarquiv + " > " + 
                          aux_nmfisico + " 2> /dev/null").
                          
        ASSIGN aux_nmarquiv = aux_nmfisico /* + ".q" */
               aux_flgfirst = FALSE.

        EMPTY TEMP-TABLE tt-erro.
        INPUT STREAM str_3 FROM VALUE(aux_nmarquiv) NO-ECHO.
        
        /*   Header do Arquivo   */
        IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

        IF   SUBSTR(aux_setlinha,08,01) <> "0" THEN
             aux_cdcritic = 468.
             
        FIND crapcco WHERE 
             crapcco.cdcooper  = par_cdcooper                     AND
             crapcco.cddbanco  = 1                                AND
             crapcco.cdagenci  = 1                                AND
             crapcco.nrdctabb  = INT(SUBSTR(aux_setlinha,59,13))  AND
             crapcco.nrconven  = INT(SUBSTR(aux_setlinha,33,20))
             NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapcco   THEN
             aux_cdcritic = 563.
        ELSE
             ASSIGN aux_cdbancbb = crapcco.cddbanco 
                    aux_cdagenci = crapcco.cdagenci
                    aux_cdbccxlt = crapcco.cdbccxlt
                    aux_nrdolote = crapcco.nrdolote
                    aux_cdhistor = crapcco.cdhistor
                    aux_nrdctabb = crapcco.nrdctabb 
                    aux_nrcnvcob = crapcco.nrconven
                    aux_flgutceb = crapcco.flgutceb.
                    
        IF   aux_cdcritic <> 0   THEN
             DO:
                 /* apaga arquivo (integra) */
                 UNIX SILENT VALUE("rm " + aux_nmfisico + " 2> /dev/null").
                 
                 ASSIGN aux_dscritic = ""
                        aux_nrsequen = aux_nrsequen + 1.
                 
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT aux_nrsequen, /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                                
                 RUN gera_erro_arquivo (INPUT cratarq.nmarquiv,
                                        INPUT aux_dscritic).
                                   
             END.
             
        /********   Header do Lote   *********/
        IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

        IF   SUBSTR(aux_setlinha,08,01) <> "1" THEN
             aux_cdcritic = 468.

        IF   aux_cdcritic <> 0 THEN
             DO:
                 /* apaga arquivo (integra) */
                 UNIX SILENT VALUE("rm " + aux_nmfisico + " 2> /dev/null").
                 
                 ASSIGN aux_dscritic = ""
                        aux_nrsequen = aux_nrsequen + 1.
                 
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT aux_nrsequen, /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                                
                 RUN gera_erro_arquivo (INPUT cratarq.nmarquiv,
                                        INPUT aux_dscritic).
             END.
             
        /* Nao le detalhes se ocorreram erros pro arquivo 
           (procedure gera_erro_arquivo) */
        IF   CAN-FIND(FIRST tt-erros-arq WHERE
                      tt-erros-arq.nmarquiv = cratarq.nmarquiv)   THEN
             NEXT bloco_arquivos.
             
        /******   Detalhe   ******/
        bloco_detalhe:
        DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

             IF   INTEGER(SUBSTR(aux_setlinha,08,01)) = 3 THEN
                  DO:
                      IF   SUBSTR(aux_setlinha,14,01) = "P" THEN
                           DO: 
                             IF   aux_flgfirst  AND  aux_cdcritic = 0 THEN
                                  RUN grava_boleto (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_dtmvtolt).

                             ELSE
                                  ASSIGN aux_flgfirst = TRUE. 
                               
                             ASSIGN 
                                aux_dsnosnum = TRIM(SUBSTR(aux_setlinha,38,20))
                                aux_dsnosnum = LEFT-TRIM(aux_dsnosnum,"0")
                                aux_cdcartei = INT(SUBSTR(aux_setlinha,58,01))
                                aux_cddespec = INT(SUBSTR(aux_setlinha,107,2))
                                aux_vltitulo = DEC(SUBSTR(aux_setlinha,86,15)) 
                                                / 100
                                aux_vldescto = DEC(SUBSTR(aux_setlinha,151,15))
                                                / 100
                                aux_dsdoccop = SUBSTR(aux_setlinha,63,15).
                          
                             DO   WHILE LENGTH(aux_dsnosnum) < 17:
                                  ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
                             END.

                             IF   NOT aux_flgutceb THEN
                                  ASSIGN aux_nrdconta =
                                           INT(SUBSTR(aux_dsnosnum,01,08))
                                         aux_nrbloque = 
                                           DEC(SUBSTR(aux_dsnosnum,09,09)).
                             ELSE
                                  ASSIGN aux_nrdconta =
                                           INT(SUBSTR(aux_dsnosnum,08,04))
                                         aux_nrbloque = 
                                           DEC(SUBSTR(aux_dsnosnum,12,06)).
                          
                             IF   INT(SUBSTRING(aux_setlinha,112,2)) <> 0 THEN
                                  aux_dtemscob =
                                     DATE(INT(SUBSTRING(aux_setlinha,112,2)),
                                          INT(SUBSTRING(aux_setlinha,110,2)),
                                          INT(SUBSTRING(aux_setlinha,114,4))).
                             ELSE aux_dtemscob = ?.
                                                                    
                             IF   INT(SUBSTRING(aux_setlinha,078,2)) <> 0 THEN
                                  aux_dtvencto =
                                     DATE(INT(SUBSTRING(aux_setlinha,080,2)),
                                          INT(SUBSTRING(aux_setlinha,078,2)),
                                          INT(SUBSTRING(aux_setlinha,082,4))).
                             ELSE aux_dtvencto = ?.
                        
                           END. /*  Tipo de Registro P  */
                      ELSE     
                      IF   SUBSTR(aux_setlinha,14,01) = "Q" THEN
                           DO:
                             ASSIGN aux_cdcritic = 0
                                    aux_nmprimtl = "".

                             FIND crapass WHERE 
                                  crapass.cdcooper = par_cdcooper AND
                                  crapass.nrdconta = aux_nrdconta
                                  USE-INDEX crapass1 NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE crapass   THEN
                                  DO:
                                      ASSIGN aux_cdcritic = 9
                                             aux_dscritic = ""
                                             aux_nrsequen = aux_nrsequen + 1.

                                      RUN gera_erro 
                                          (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT aux_nrsequen, 
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                      
                                      ASSIGN aux_dscritic = aux_dscritic +
                                                            " -  C/C : " +
                                                     STRING(aux_nrdconta,
                                                            "zzzz,zzz,9").
                                                            
                                      /* cria rejeitado */
                                      CREATE tt-boletos-rej.
                                      ASSIGN 
                                         tt-boletos-rej.nmarquiv = 
                                                        cratarq.nmarquiv
                                         tt-boletos-rej.nrdconta = aux_nrdconta
                                         tt-boletos-rej.nrdocmto = aux_nrbloque
                                         tt-boletos-rej.dscritic =  
                                                        aux_dscritic + 
                                                        " -  C/C : " +
                                                        STRING(aux_nrdconta,
                                                               "zzzz,zzz,9").
                                      NEXT bloco_detalhe.
                                  END.
                             ELSE
                                  aux_nmprimtl = crapass.nmprimtl.
                             
                             /*  Possui convenio CECRED */
                             IF   aux_flgutceb   THEN
                                  DO:
                                      FIND crapceb WHERE 
                                           crapceb.cdcooper = par_cdcooper AND
                                           crapceb.nrconven = aux_nrcnvcob AND
                                           crapceb.nrcnvceb = aux_nrdconta 
                                           USE-INDEX crapceb3 NO-LOCK NO-ERROR.
                                  END.
                             ELSE
                                  DO:
                                      FIND crapceb WHERE
                                           crapceb.cdcooper = par_cdcooper AND
                                           crapceb.nrdconta = aux_nrdconta AND
                                           crapceb.nrconven = aux_nrcnvcob
                                           NO-LOCK NO-ERROR.
                                  END.

                             IF   NOT AVAILABLE crapceb  OR 
                                  crapceb.insitceb <> 1  THEN
                                  DO:
                                     IF  NOT AVAIL crapceb THEN
                                         ASSIGN aux_cdcritic = 563.
                                     ELSE
                                         ASSIGN aux_cdcritic = 933.

                                     ASSIGN aux_dscritic = ""
                                            aux_nrsequen = aux_nrsequen + 1.

                                     RUN gera_erro 
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT aux_nrsequen, 
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).

                                     /* cria rejeitado */
                                     CREATE tt-boletos-rej.
                                     ASSIGN
                                         tt-boletos-rej.nmarquiv =
                                                 cratarq.nmarquiv
                                         tt-boletos-rej.nrdconta = 
                                                 aux_nrdconta
                                         tt-boletos-rej.nmprimtl =
                                                 aux_nmprimtl
                                         tt-boletos-rej.nrdocmto = 
                                                 aux_nrbloque
                                         tt-boletos-rej.dscritic = 
                                                 aux_dscritic
                                                   + " -  CNV : " +
                                                STRING(aux_nrdconta,
                                                "zzzz,zzz,9").
                                     
                                     NEXT.
                                  END. /* IF NOT AVAILABLE crapceb */
                             ELSE
                                  ASSIGN aux_nrdconta = crapceb.nrdconta.
                                  
                              
                             ASSIGN 
                               aux_cdtpinsc = INT(SUBSTR(aux_setlinha,18,01))
                               aux_nrinssac = DEC(SUBSTR(aux_setlinha,19,15))
                               aux_nmdsacad = SUBSTR(aux_setlinha,34,40)
                               aux_dsendsac = SUBSTR(aux_setlinha,74,40)
                               aux_nmbaisac = SUBSTR(aux_setlinha,114,15)
                               aux_nrcepsac = INT(SUBSTR(aux_setlinha,129,8))
                               aux_nmcidsac = SUBSTR(aux_setlinha,137,15)
                               aux_cdufsaca = SUBSTR(aux_setlinha,152,02)
                               aux_nmdavali = SUBSTR(aux_setlinha,170,40)
                               aux_nrinsava = DEC(SUBSTR(aux_setlinha,155,15))
                               aux_cdtpinav = INT(SUBSTR(aux_setlinha,154,1)).
                             
                             RUN grava_sacado (INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt).

                           END.  /*  Tipo de  Registro  Q   */
                      ELSE     
                      IF   SUBSTR(aux_setlinha,14,01) = "S"   AND
                           INT(SUBSTR(aux_setlinha,18,1)) = 3 THEN
                           DO:
                             /*   Concatena instrucoes separadas por _   */
                             ASSIGN aux_dsdinstr = 
                                        SUBSTR(aux_setlinha,19,40)  + "_" +
                                        SUBSTR(aux_setlinha,59,40)  + "_" +
                                        SUBSTR(aux_setlinha,99,40)  + "_" +
                                        SUBSTR(aux_setlinha,139,40) + "_" +
                                        SUBSTR(aux_setlinha,179,40).
                                                 
                           END.  /*  Tipo de  Registro  S   */
                        
             END.  /*   Tipo de Registro 3  */

        END.  /*    Fim do While True   */

        IF   aux_cdcritic <> 0 THEN
             DO:
                 /* apaga arquivo (integra) */
                 UNIX SILENT VALUE("rm " + aux_nmfisico + " 2> /dev/null").
                 
                 NEXT bloco_arquivos.
             END.
             
        IF   aux_flgfirst  AND  aux_cdcritic = 0  THEN
             RUN grava_boleto (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_dtmvtolt).
                               
        INPUT STREAM str_3 CLOSE.
       
        /* move o arquivo UNIX para o "salvar" */
        UNIX SILENT VALUE("mv -f " + SUBSTRING(cratarq.nmarquiv,1,
                          LENGTH(cratarq.nmarquiv)) + " salvar").
                          
        /* apaga arquivo (integra) */
        UNIX SILENT VALUE("rm " + aux_nmfisico + " 2> /dev/null").
                          
    END.  /*   Fim do FOR EACH cratarq   */
    
    /* Se chegou ao final, apaga os erros para nao considerar no retorno */
    EMPTY TEMP-TABLE tt-erro.

    RETURN "OK".

END PROCEDURE. /* fim integra_boletos */

PROCEDURE busca_informacoes_associado:
    /*************************************************************************
        Objetivo: Buscar as informacoes do associado conforme conta informada
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR cratass.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE cratass.

    FIND crapass WHERE 
         crapass.cdcooper = par_cdcooper  AND
         crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.
    IF   NOT AVAIL crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.

    CREATE cratass.
    BUFFER-COPY crapass TO cratass.

    RETURN "OK".
           
END PROCEDURE. /* fim busca_informacoes_associado */

PROCEDURE grava_boleto:
    /************************************************************************
        Objetivo: Gerar boleto na base - uso interno da BO
    ************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    /* TRANS */
    DO   TRANSACTION:
         EMPTY TEMP-TABLE cratcob.
                             
         CREATE cratcob.
         ASSIGN cratcob.cdcooper = par_cdcooper
                cratcob.dtmvtolt = par_dtmvtolt
                cratcob.incobran = 0
                cratcob.nrdconta = aux_nrdconta
                cratcob.nrdctabb = aux_nrdctabb
                cratcob.cdbandoc = 1
                cratcob.nrdocmto = aux_nrbloque
                cratcob.nrcnvcob = aux_nrcnvcob
                cratcob.dtretcob = aux_dtemscob
                cratcob.dsdoccop = aux_dsdoccop
                cratcob.vltitulo = aux_vltitulo
                cratcob.vldescto = aux_vldescto
                cratcob.dtvencto = aux_dtvencto
                cratcob.cdcartei = aux_cdcartei
                cratcob.cddespec = aux_cddespec
                cratcob.cdtpinsc = aux_cdtpinsc
                cratcob.nrinssac = aux_nrinssac
                cratcob.nmdsacad = aux_nmdsacad
                cratcob.dsendsac = aux_dsendsac
                cratcob.nmbaisac = aux_nmbaisac
                cratcob.nmcidsac = aux_nmcidsac
                cratcob.cdufsaca = aux_cdufsaca
                cratcob.nrcepsac = aux_nrcepsac
                cratcob.nmdavali = aux_nmdavali
                cratcob.nrinsava = aux_nrinsava
                cratcob.cdtpinav = aux_cdtpinav
                cratcob.dsdinstr = aux_dsdinstr
                cratcob.cdimpcob = 2
                cratcob.flgimpre = TRUE
                aux_dscritic     = "".
                                    
         RUN sistema/generico/procedures/b1crapcob.p 
             PERSISTENT SET h_b1crapcob.
                             
         IF   VALID-HANDLE(h_b1crapcob)   THEN
              DO:
                  RUN inclui-registro IN h_b1crapcob (INPUT TABLE cratcob, 
                                                      OUTPUT aux_dscritic).
                  DELETE PROCEDURE h_b1crapcob.
              END.
              
         IF   aux_dscritic <> ""   THEN /* Erro na criacao do boleto */
              DO:
                  ASSIGN aux_nrsequen = aux_nrsequen + 1.

                  RUN gera_erro 
                      (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT aux_nrsequen, 
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

                  IF   aux_nmprimtl = ""   THEN
                       DO:
                           FIND crapass WHERE 
                                crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = aux_nrdconta
                                USE-INDEX crapass1 NO-LOCK NO-ERROR.
                           IF   AVAIL crapass   THEN
                                ASSIGN aux_nmprimtl = crapass.nmprimtl.
                       END.

                  /* cria rejeitado */
                  CREATE tt-boletos-rej.
                  ASSIGN tt-boletos-rej.nmarquiv = cratarq.nmarquiv
                         tt-boletos-rej.nrdconta = aux_nrdconta
                         tt-boletos-rej.nmprimtl = aux_nmprimtl
                         tt-boletos-rej.nrdocmto = aux_nrbloque
                         tt-boletos-rej.dscritic = aux_dscritic    + 
                                                   " -  Boleto : " +
                                                   STRING(cratcob.nrdocmto,
                                                          "99999999999999999").
                  UNDO, RETURN "NOK".
              END.  
         ELSE
              DO:
                  CREATE tt-boletos-imp.
                  ASSIGN tt-boletos-imp.nmarquiv = cratarq.nmarquiv
                         tt-boletos-imp.nrdconta = aux_nrdconta
                         tt-boletos-imp.nmprimtl = aux_nmprimtl
                         tt-boletos-imp.nrbloque = aux_nrbloque.

                  /*aux_qtbloque = aux_qtbloque + 1.*/
              END.
                                 
   END. /* Fim do DO TRANSACTON */

   ASSIGN aux_dsdinstr = "".

   RETURN "OK".

END PROCEDURE. /* fim grava_boleto */

PROCEDURE grava_sacado:
    /*************************************************************************
        Objetivo: Gravar sacado na base - uso interno da BO
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    IF   aux_nrinssac = 0   THEN
         RETURN.
         
    /*  Sacado possui registro */
    FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                       crapsab.nrdconta = aux_nrdconta AND
                       crapsab.nrinssac = aux_nrinssac NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapsab   THEN
         DO:
             EMPTY TEMP-TABLE cratsab.
    
             CREATE cratsab.
             ASSIGN cratsab.cdcooper = par_cdcooper
                    cratsab.nrdconta = aux_nrdconta
                    cratsab.nmdsacad = aux_nmdsacad
                    cratsab.cdtpinsc = aux_cdtpinsc
                    cratsab.nrinssac = aux_nrinssac
                    cratsab.dsendsac = aux_dsendsac
                    cratsab.nrendsac = 0
                    cratsab.nmbaisac = aux_nmbaisac
                    cratsab.nmcidsac = aux_nmcidsac
                    cratsab.cdufsaca = aux_cdufsaca
                    cratsab.nrcepsac = aux_nrcepsac
                    cratsab.cdoperad = par_cdoperad
                    cratsab.dtmvtolt = par_dtmvtolt.
                                        
             RUN sistema/generico/procedures/b1crapsab.p 
                 PERSISTENT SET h_b1crapsab.
    
             IF   VALID-HANDLE(h_b1crapsab)   THEN
                  DO:
                      ASSIGN aux_dscritic = "".
                                         
                      RUN cadastra_sacado IN h_b1crapsab (INPUT TABLE cratsab,
                                                          OUTPUT aux_dscritic).
                      DELETE PROCEDURE h_b1crapsab.
                  END.
    
             IF   aux_dscritic <> "" THEN
                  DO:
                      IF   aux_nmprimtl = ""   THEN
                           DO:
                               FIND crapass WHERE 
                                    crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = aux_nrdconta
                                    USE-INDEX crapass1 NO-LOCK NO-ERROR.
                               IF  AVAIL crapass   THEN
                                   ASSIGN aux_nmprimtl = crapass.nmprimtl.
                           END.

                      /* cria rejeitado */
                      CREATE tt-boletos-rej.
                      ASSIGN tt-boletos-rej.nmarquiv = cratarq.nmarquiv
                             tt-boletos-rej.nrdconta = aux_nrdconta
                             tt-boletos-rej.nmprimtl = aux_nmprimtl
                             tt-boletos-rej.nrdocmto = aux_nrbloque
                             tt-boletos-rej.dscritic = aux_dscritic + 
                                                       " -  C/C : " +
                                                       STRING(aux_nrdconta,
                                                              "zzzz,zzz,9").
                      NEXT.
                  END.
         END.
    
    ASSIGN aux_nmdsacad = ""
           aux_dsendsac = ""
           aux_nmbaisac = ""
           aux_nmcidsac = ""
           aux_cdufsaca = ""
           aux_nrcepsac = 0.
    
    RETURN "OK".
           
END PROCEDURE. /* fim grava_sacado */

PROCEDURE valida_pac:
    /*************************************************************************
        Objetivo: Validar o PAC  informado
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdpacval AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE cratass.

    IF NOT CAN-FIND(crapage WHERE 
                    crapage.cdcooper = par_cdcooper  AND 
                    crapage.cdagenci = par_cdpacval) THEN
         DO:
             ASSIGN aux_cdcritic = 15
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.

    RETURN "OK".
           
END PROCEDURE. /* fim valida_pac */

PROCEDURE obtem_arquivos_validos:
    /*************************************************************************
        Objetivo: Obter arquivos validos a partir de um caminho informado
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qtarquiv AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR cratarq.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE cratarq.
    
    ASSIGN par_qtarquiv = 0.

    INPUT STREAM str_3 THROUGH 
                       VALUE( "ls " + par_nmarquiv + " 2> /dev/null") NO-ECHO.
                       
    DO   WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
         IMPORT STREAM str_3 aux_nmarquiv.
         
         IF   SEARCH(aux_nmarquiv) = ?   THEN
              ASSIGN aux_nmarquiv = par_nmarquiv + aux_nmarquiv.
         
         IF   SEARCH(aux_nmarquiv) = ?   THEN
              NEXT.
              
         INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
         IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
         
         ASSIGN aux_nrsequen = INT(SUBSTR(aux_setlinha,158,06)) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN
             NEXT.
             
         CREATE cratarq.
         ASSIGN cratarq.flgmarca = YES
                cratarq.nrsequen = aux_nrsequen
                cratarq.nmarquiv = aux_nmarquiv
                par_qtarquiv     = par_qtarquiv + 1.
         RELEASE cratarq.
    END.      
    
    IF   NOT CAN-FIND(FIRST cratarq)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nao existem arquivos validos para o " +
                                   "caminho informado"
                    aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.
         
    RETURN "OK".
           
END PROCEDURE. /* fim obtem_arquivos_validos */

PROCEDURE gera_erro_arquivo: 
    /*************************************************************************
        Objetivo: Gerar erros na temp-table para cada arquivo validado
    *************************************************************************/
    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdoerro AS CHAR NO-UNDO.

    ASSIGN aux_seqarqui = 1.               

    FIND LAST tt-erros-arq USE-INDEX ch_seqarq WHERE
              tt-erros-arq.nmarquiv = par_nmarquiv NO-ERROR.
    IF   AVAIL tt-erros-arq   THEN 
         ASSIGN aux_seqarqui = tt-erros-arq.nrsequen + 1.
                      
    CREATE tt-erros-arq.
    ASSIGN tt-erros-arq.nmarquiv = par_nmarquiv
           tt-erros-arq.nrsequen = aux_seqarqui
           tt-erros-arq.dsdoerro = par_dsdoerro.

END PROCEDURE. /* gera_erro_arquivo */


PROCEDURE pi_gera_log:
    DEF INPUT PARAM par_texto AS CHAR NO-UNDO.


    UNIX SILENT VALUE ("echo " + STRING(TODAY) + 
                       " - " + STRING(TIME,"HH:MM:SS") +
                       " - " + STRING(ETIME) +
                       " - " + par_texto +
                       " >> log/proc_batch_375.log").


END PROCEDURE.

PROCEDURE gera_relatorio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdstatus AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inserasa AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_cddemail AS INTE                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR h-b1wgen0024  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0010i AS HANDLE                                 NO-UNDO.

    DEF VAR aux_inidtmvt AS DATE                                    NO-UNDO.
    DEF VAR aux_fimdtmvt AS DATE                                    NO-UNDO.
    DEF VAR aux_inidtdpa AS DATE                                    NO-UNDO.
    DEF VAR aux_fimdtdpa AS DATE                                    NO-UNDO.
    DEF VAR aux_consulta AS INTE                                    NO-UNDO.
    DEF VAR aux_flgregis AS LOGI                                    NO-UNDO.
    DEF VAR aux_cdstatus AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpconsul AS INTE                                    NO-UNDO.
    DEF VAR aux_direcoop AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqzip AS CHAR                                    NO-UNDO.
	
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  CAN-DO("2,6,8",STRING(par_tprelato)) THEN
            IF  NOT CAN-FIND(crapage WHERE
                             crapage.cdcooper = par_cdcooper AND
                             crapage.cdagenci = par_cdagencx) THEN
                DO:
                    ASSIGN aux_cdcritic = 15
                           aux_dscritic = "".
                    LEAVE Imprime.
                END.
				
        IF  par_tprelato = 1 OR
            par_tprelato = 2 OR
            par_tprelato = 3 THEN
            ASSIGN aux_inidtmvt = par_inidtper
                   aux_fimdtmvt = par_fimdtper
                   aux_consulta = 7.  /* Por periodo */
        ELSE
        IF  par_tprelato = 4 THEN
            ASSIGN aux_inidtdpa = par_inidtper 
                   aux_fimdtdpa = par_fimdtper 
                   aux_flgregis = FALSE
                   aux_consulta = 4.  /* Por data de pagamento */
        ELSE
        IF  par_tprelato = 5 THEN DO:

            CASE par_cdstatus:
                WHEN 1 THEN ASSIGN aux_consulta =  9 /* Em Aberto */
                                   aux_cdstatus = "A".
                WHEN 2 THEN ASSIGN aux_consulta = 10 /* Baixado */
                                   aux_cdstatus = "B".
                WHEN 3 THEN ASSIGN aux_consulta = 11 /* Liquidado */
                                   aux_cdstatus = "L".
                WHEN 4 THEN ASSIGN aux_consulta = 12 /* Rejeitado */
                                   aux_cdstatus = "B".
                WHEN 5 THEN ASSIGN aux_consulta = 13 /* Cartoraria */
                                   aux_cdstatus = "B".
            END.

            ASSIGN aux_inidtmvt = par_inidtper
                   aux_fimdtmvt = par_fimdtper
                   aux_flgregis = TRUE.
        END.
        IF  par_tprelato = 6 OR par_tprelato = 8 THEN
            ASSIGN aux_inidtmvt = par_inidtper
                   aux_fimdtmvt = par_fimdtper
                   aux_flgregis = TRUE
                   aux_consulta = 14.

        ASSIGN aux_tpconsul = 3. /* Cobrados e nao cobrados */

        RUN consulta-bloqueto
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT 0,
              INPUT 0,
              INPUT 0,
              INPUT par_nmprimtl,
              INPUT 0,
              INPUT 999999,
              INPUT 1,
              INPUT ?,
              INPUT ?,
              INPUT aux_inidtdpa,
              INPUT aux_fimdtdpa,
              INPUT aux_inidtmvt,
              INPUT aux_fimdtmvt,
              INPUT aux_consulta, 
              INPUT aux_tpconsul,
              INPUT par_idorigem,
              INPUT 0,
              INPUT 0,
              INPUT "",
              INPUT aux_flgregis,
              INPUT 0,
              INPUT par_inserasa,
             OUTPUT aux_qtregist,
             OUTPUT aux_nmdcampo,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-consulta-blt).

        IF RETURN-VALUE = "NOK" THEN
			LEAVE Imprime.			

        IF  NOT VALID-HANDLE(h-b1wgen0010i) THEN
            RUN sistema/generico/procedures/b1wgen0010i.p 
                PERSISTENT SET h-b1wgen0010i.

        CASE par_tprelato:
            WHEN 1 THEN
                RUN proc_crrl500 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                 INPUT TABLE tt-consulta-blt).

            WHEN 2 THEN
                RUN proc_crrl501 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT par_nrdconta,
                                 INPUT par_cdagencx,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                 INPUT TABLE tt-consulta-blt).

            WHEN 3 THEN
                RUN proc_crrl502 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                 INPUT TABLE tt-consulta-blt).

            WHEN 4 THEN
                RUN proc_crrl504 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT par_nrdconta,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                 INPUT aux_inidtdpa,
                                 INPUT aux_fimdtdpa,
                                 INPUT TABLE tt-consulta-blt).

            WHEN 5 THEN
                RUN proc_crrl600 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT par_cdagencx,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                 INPUT par_inserasa,
                                 INPUT TABLE tt-consulta-blt).

            WHEN 6 THEN DO:    
				RUN proc_crrl601 IN h-b1wgen0010i
                               ( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT aux_nmarqimp,
                                 INPUT par_cdagencx,
                                 INPUT aux_inidtmvt,
                                 INPUT aux_fimdtmvt,
                                                                                 INPUT par_tprelato,
                                 INPUT TABLE tt-consulta-blt).
                                 
                IF  par_idorigem = 3  THEN  /** Internet Bank **/
                    DO:
                        /*** Buscar diretorio root da cooperativa pelo oracle para 
                             funcionar corretamente em ambiente de desenvolvimento/homologacao  ***/
                        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                                    
                        RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
                                           (INPUT "CRED",           /* pr_nmsistem */
                                            INPUT par_cdcooper,     /* pr_cdcooper */
                                            INPUT "ROOT_DIRCOOP",  /* pr_cdacesso */
                                            OUTPUT ""               /* pr_dsvlrprm */
                                            ).
                    
                        CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
                        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                        
                        ASSIGN aux_direcoop = ""
                               aux_direcoop = pc_param_sistema.pr_dsvlrprm 
                                              WHEN pc_param_sistema.pr_dsvlrprm <> ?.                       
                        /** Fim Busca **/                        

                        FOR FIRST crapcem
                           FIELDS (dsdemail)
                            WHERE crapcem.cdcooper = par_cdcooper
                              AND crapcem.nrdconta = par_nrdconta
                              AND crapcem.idseqttl = 1
                              AND crapcem.cddemail = par_cddemail
                              NO-LOCK:
                              
                          IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                              RUN sistema/generico/procedures/b1wgen0024.p
                                  PERSISTENT SET h-b1wgen0024.

                          IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                              DO:
                                  ASSIGN aux_dscritic = "Nao foi possivel gerar o relatorio.".
                                  LEAVE Imprime.
                              END.

                          RUN gera-pdf-impressao IN h-b1wgen0024 
                              ( INPUT aux_nmarqimp,
                                INPUT aux_nmarqpdf).

                          IF  VALID-HANDLE(h-b1wgen0024)  THEN
                              DELETE PROCEDURE h-b1wgen0024.

                          IF  RETURN-VALUE <> "OK" THEN
                              RETURN "NOK".
                        
                          ASSIGN aux_nmarqzip = REPLACE(aux_nmarqpdf, ".pdf", ".zip").

                          UNIX SILENT VALUE("zipcecred.pl -silent -add " +
                                            aux_nmarqzip + " " + aux_nmarqpdf).
                                                            
                          ASSIGN aux_nmarqzip = REPLACE(aux_nmarqzip, "/usr/coop/", aux_direcoop).

                           /* Enviar e-mail informando para a empresa a falta de saldo. */
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

                           /* Efetuar a chamada a rotina Oracle */
                           RUN STORED-PROCEDURE pc_solicita_email_prog aux_handproc = PROC-HANDLE NO-ERROR
                                                             (INPUT  par_cdcooper        /* par_cdcooper         */
                                                             ,INPUT  ""                  /* par_cdprogra         */
                                                             ,INPUT  crapcem.dsdemail    /* par_des_destino      */
                                                             ,INPUT  "ARQUIVO DE MOVIMENTO DE COBRANÇA COM REGISTRO"     /* par_des_assunto      */
                                                             ,INPUT  ""                  /* par_des_corpo        */
                                                             ,INPUT  aux_nmarqzip        /* par_des_anexo        */
                                                             ,INPUT  "S"                 /* par_flg_remove_anex  */
                                                             ,INPUT  "N"                 /* par_flg_remete_coop  */                                                   
                                                             ,INPUT  ""                  /* PR_DES_NOME_REPLY */
                                                             ,INPUT  ""                  /* PR_DES_EMAIL_REPLY */
                                                             ,INPUT  "N"                 /* par_flg_log_batch    */
                                                             ,INPUT  "S"                 /* par_flg_enviar       */
                                                             ,OUTPUT "").      /* par_des_erro         */
                                                             
                          /* Fechar o procedimento para buscarmos o resultado */ 
                          CLOSE STORED-PROC pc_solicita_email_prog
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                          
                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                        
                        END.
                              
                    END.
            END.
                 
                 WHEN 8 THEN DO:
                    RUN proc_crrl601 IN h-b1wgen0010i
                                           ( INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT aux_nmarqimp,
                                             INPUT par_cdagencx,
                                             INPUT aux_inidtmvt,
                                             INPUT aux_fimdtmvt,
                                             INPUT par_tprelato,
                                             INPUT TABLE tt-consulta-blt).
            END.
                 
        END CASE.

        IF  VALID-HANDLE(h-b1wgen0010i) THEN
            DELETE PROCEDURE h-b1wgen0010i.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera_relatorio */

PROCEDURE integra_arquivo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqint AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsnmarqv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vrsarqvs AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR w-arquivos.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqim2 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpd2 AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdgcriti AS INTE                                    NO-UNDO.
    DEF VAR aux_dsgcriti AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE crawrej.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0010i) THEN
        RUN sistema/generico/procedures/b1wgen0010i.p 
            PERSISTENT SET h-b1wgen0010i.

    RUN integra_arquivo IN h-b1wgen0010i
                      ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_idorigem,
                        INPUT par_nmdatela,
                        INPUT par_cdprogra,
                        INPUT par_dtmvtolt,
                        INPUT par_cdoperad,
                        INPUT par_dsiduser,
                        INPUT par_nmarqint,
                        INPUT par_dsnmarqv,
                        INPUT par_vrsarqvs,
                        INPUT TABLE w-arquivos,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT TABLE tt-erro,
                 INPUT-OUTPUT TABLE crawrej).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            IF  aux_nmarqimp = "" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0010i) THEN
                        DELETE PROCEDURE h-b1wgen0010i.
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_cdgcriti = tt-erro.cdcritic
                       aux_dsgcriti = tt-erro.dscritic.
        END.

    RUN relatorio_rejeitado IN h-b1wgen0010i
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_idorigem,
                            INPUT par_nmdatela,
                            INPUT par_cdprogra,
                            INPUT par_dtmvtolt,
                            INPUT par_dsiduser,
                            INPUT TABLE crawrej,
                           OUTPUT aux_nmarqim2,
                           OUTPUT aux_nmarqpd2,
                           OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0010i) THEN
        DELETE PROCEDURE h-b1wgen0010i.

    IF  RETURN-VALUE <> "OK" OR aux_cdgcriti <> 0 OR aux_dsgcriti <> "" THEN 
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT (IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 2 ELSE 1),
                           INPUT aux_cdgcriti,
                           INPUT-OUTPUT aux_dsgcriti).

        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE. /* integra_arquivo */

PROCEDURE carrega_arquivos:

    DEF  INPUT PARAM par_nmarqint AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR w-arquivos.

    IF  NOT VALID-HANDLE(h-b1wgen0010i) THEN
        RUN sistema/generico/procedures/b1wgen0010i.p 
            PERSISTENT SET h-b1wgen0010i.

    RUN carrega_arquivos IN h-b1wgen0010i
                       ( INPUT par_nmarqint,
                        OUTPUT TABLE w-arquivos).

    IF  VALID-HANDLE(h-b1wgen0010i) THEN
        DELETE PROCEDURE h-b1wgen0010i.

    RETURN "OK".
    
END PROCEDURE. /* carrega_arquivos */

PROCEDURE buca_log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
                     
    DEF OUTPUT PARAM TABLE FOR tt-logcob.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsoperad AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-logcob.
        EMPTY TEMP-TABLE tt-erro.

        FOR EACH crapcol WHERE crapcol.cdcooper = par_cdcooper AND
                               crapcol.nrdconta = par_nrdconta AND
                               crapcol.nrcnvcob = par_nrcnvcob AND
                               crapcol.nrdocmto = par_nrdocmto NO-LOCK
                            BY crapcol.dtaltera DESC
                            BY crapcol.hrtransa DESC
                            BY ROWID(crapcol) DESC.

            FIND FIRST crapope WHERE
                       crapope.cdcooper = crapcol.cdcooper AND
                       crapope.cdoperad = crapcol.cdoperad
                       NO-LOCK NO-ERROR.

            IF  AVAIL crapope AND crapcol.cdoperad <> "1" THEN
                ASSIGN aux_dsoperad = crapope.cdoperad + "-" +
                                      crapope.nmoperad.
            ELSE
                DO:
                    FIND FIRST crapcco WHERE
                               crapcco.cdcooper = crapcol.cdcooper AND
                               crapcco.nrconven = crapcol.nrcnvcob
                               NO-LOCK NO-ERROR.

                    IF  AVAIL crapcco THEN
                        DO:
                            IF  crapcco.cddbanco = 001 THEN
                                ASSIGN aux_dsoperad = "001-BB".
                            ELSE
                            IF  crapcco.cddbanco = 085 THEN
                                ASSIGN aux_dsoperad = "085-AILOS".
                            ELSE
                                ASSIGN aux_dsoperad = "000-Nao encontrado".
                        END.
                    ELSE
                        ASSIGN aux_dsoperad = "000-Nao encontrado".
                END.

            CREATE tt-logcob.
            ASSIGN tt-logcob.dsdthora = STRING(crapcol.dtaltera,"99/99/99") +
                                        " " +
                                        STRING(crapcol.hrtransa,"HH:MM")
                   tt-logcob.dsdeslog = crapcol.dslogtit
                   tt-logcob.dsoperad = aux_dsoperad.

        END. /* FOR EACH crapcol */

        IF  NOT TEMP-TABLE tt-logcob:HAS-RECORDS THEN
            DO:
                ASSIGN aux_dscritic = "Sem registro de Log.".
                LEAVE Busca.
            END.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* buca_log */

/* ..........................................................................*/


PROCEDURE pega_valor_tarifas:

    DEF INPUT  PARAM par_cdcooper   AS  INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS  INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdprogra   AS  CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_nrcnvcob   LIKE    crapcob.nrcnvcob    NO-UNDO.
    DEF INPUT  PARAM par_inpessoa   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg   AS  DATE                    NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc   AS  DATE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_vlrtarcx   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_vlrtarnt   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_vltrftaa   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_vlrtarif   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN par_vlrtarcx = 0
           par_vlrtarnt = 0
           par_vltrftaa = 0
           par_vlrtarif = 0.

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "03", /* Caixa da cooperativa */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
					 INPUT  0, /* Nao apurar */
                     OUTPUT tar_cdhistor,
                     OUTPUT tar_cdhisest,
                     OUTPUT par_vlrtarcx,
                     OUTPUT tar_dtdivulg,
                     OUTPUT tar_dtvigenc,
                     OUTPUT tar_cdfvlcop,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        DO: 

          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  par_cdprogra <> "" THEN
              DO:
                  IF  AVAIL tt-erro THEN
                      UNIX SILENT VALUE("echo "    + 
                           STRING(TIME,"HH:MM:SS") +
                           " - " + par_cdprogra + "' --> '"
                           + tt-erro.dscritic + 
                           " >> log/proc_batch.log"). 
              END.
          ELSE
              DO:
                  IF  AVAIL tt-erro THEN
                      UNIX SILENT VALUE("echo "    + 
                           STRING(TIME,"HH:MM:SS") +
                           "' --> '" + tt-erro.dscritic + 
                           " >> log/proc_batch.log"). 
              END.

          RETURN "NOK".
        END. 

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "33", /* Internet Banking */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
					 INPUT  0, /* Nao apurar */
                     OUTPUT tar_cdhistor,
                     OUTPUT tar_cdhisest,
                     OUTPUT par_vlrtarnt,
                     OUTPUT tar_dtdivulg,
                     OUTPUT tar_dtvigenc,
                     OUTPUT tar_cdfvlcop,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        DO: 

          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  AVAIL tt-erro THEN
              UNIX SILENT VALUE("echo "    + 
                   STRING(TIME,"HH:MM:SS") +
                   " - " + par_cdprogra + "' --> '"
                   + tt-erro.dscritic + 
                   " >> log/proc_batch.log"). 

          RETURN "NOK".
        END. 

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "32", /* TAA */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
					 INPUT  0, /* Nao apurar */
                     OUTPUT tar_cdhistor,
                     OUTPUT tar_cdhisest,
                     OUTPUT par_vltrftaa,
                     OUTPUT tar_dtdivulg,
                     OUTPUT tar_dtvigenc,
                     OUTPUT tar_cdfvlcop,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        DO: 

          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  AVAIL tt-erro THEN
              UNIX SILENT VALUE("echo "    + 
                   STRING(TIME,"HH:MM:SS") +
                   " - " + par_cdprogra + "' --> '"
                   + tt-erro.dscritic + 
                   " >> log/proc_batch.log"). 

          RETURN "NOK".
        END. 

    RUN sistema/generico/procedures/b1wgen0153.p
        PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_cobranca IN
        h-b1wgen0153(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     INPUT  par_nrcnvcob,
                     INPUT  "RET",
                     INPUT  00,
                     INPUT  "31", /* Outras instituições financeiras */
                     INPUT  par_inpessoa,
                     INPUT  1,
                     INPUT  "", /* cdprogra */
					 INPUT  0, /* Nao apurar */
                     OUTPUT tar_cdhistor,
                     OUTPUT tar_cdhisest,
                     OUTPUT par_vlrtarif,
                     OUTPUT tar_dtdivulg,
                     OUTPUT tar_dtvigenc,
                     OUTPUT tar_cdfvlcop,
                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"   THEN
        DO: 

          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  AVAIL tt-erro THEN
              UNIX SILENT VALUE("echo "    + 
                   STRING(TIME,"HH:MM:SS") +
                   " - " + par_cdprogra + "' --> '"
                   + tt-erro.dscritic + 
                   " >> log/proc_batch.log"). 

          RETURN "NOK".
        END. 


    RETURN "OK".
END PROCEDURE.


PROCEDURE busca_par_emissao_cce:

   DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.

   DEF OUTPUT PARAM par_dtvencto AS INT                               NO-UNDO.
   DEF OUTPUT PARAM par_hrtransf AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM par_hrrecebi AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dstextab         AS CHAR                              NO-UNDO.
      
   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "DIASVCTOCEE"  AND
                      craptab.tpregist = 0           
                      NO-LOCK NO-ERROR.


    IF  NOT AVAILABLE craptab   THEN
        DO:
            ASSIGN aux_cdcritic = 55.
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".      

        END.
    ELSE 
        DO:
           ASSIGN aux_dstextab = craptab.dstextab
                  par_dtvencto = INTEGER(SUBSTRING(aux_dstextab,1,2)).
                       
        END.

   RELEASE craptab.

   FIND FIRST craphec 
        WHERE craphec.cdcooper = par_cdcooper   
          AND craphec.cdprogra = "CRPS693"
          NO-LOCK NO-ERROR.

       IF  NOT AVAILABLE craphec   THEN
        DO:

            ASSIGN aux_cdcritic = 55.
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".      

        END.
    ELSE 
        DO:
           ASSIGN aux_dstextab = STRING(craphec.hriniexe,"HH:MM")
                  par_hrtransf = aux_dstextab.
                       
        END.


   FIND FIRST craphec 
        WHERE craphec.cdcooper = 1 /* fixo */   
          AND craphec.cdprogra = "CRPS694"
          NO-LOCK NO-ERROR.

       IF  NOT AVAILABLE craphec   THEN
        DO:

            ASSIGN aux_cdcritic = 55.
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".      

        END.
    ELSE 
        DO:
           ASSIGN aux_dstextab = STRING(craphec.hriniexe,"HH:MM")
                  par_hrrecebi = aux_dstextab.
                       
        END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE altera_par_emissao_cce:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_hrtransf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_hrrecebi AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dstextab          AS CHAR                          NO-UNDO.
    DEF  VAR aux_flgtrans          AS LOGI                          NO-UNDO.
    DEF  VAR log_dstextab          AS DEC EXTENT 4                  NO-UNDO.
    DEF  VAR aux_msgdolog          AS CHAR                          NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_flgtrans = FALSE.
    
    
    EMPTY TEMP-TABLE tt-erro.

    /* Adquire valor anterior para o LOG */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "DIASVCTOCEE"  AND
                       craptab.tpregist = 000            
                       NO-LOCK NO-ERROR.

    ASSIGN aux_dstextab    = craptab.dstextab
           log_dstextab[1] = DEC(SUBSTRING(aux_dstextab,1,2)).

    RELEASE craptab.
            
    TRANS_TAB:
    DO  TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                    ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:


        ASSIGN aux_cdcritic = 0.
               
        DO  aux_contador = 1 TO 10:
            
            DO  WHILE TRUE:
                   
                FIND craptab WHERE 
                     craptab.cdcooper = par_cdcooper       AND
                     craptab.nmsistem = "CRED"             AND
                     craptab.tptabela = "GENERI"           AND
                     craptab.cdempres = 0                  AND
                     craptab.cdacesso = "DIASVCTOCEE"      AND
                     craptab.tpregist = 0
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          

                IF  NOT AVAILABLE craptab   THEN
                    DO:
                        
                        IF  LOCKED craptab   THEN
                            DO:
                                aux_cdcritic = 77.
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 55.
                            END.

                    END.
                
                aux_cdcritic = 0.
                LEAVE.
              
            END.  /*  Fim do DO WHILE TRUE  */
              
            IF  aux_cdcritic > 0 OR 
                aux_dscritic <> ""  THEN
                UNDO TRANS_TAB, LEAVE TRANS_TAB.
                          

            ASSIGN SUBSTR(craptab.dstextab,1,2)   = STRING(par_dtvencto,"99").
                
            
        END.  
            
        IF  aux_cdcritic > 0   THEN
            UNDO, NEXT.

        DO  aux_contador = 1 TO 10:
                   
            FIND FIRST craphec 
                 WHERE craphec.cdcooper = par_cdcooper   
                   AND craphec.cdprogra = "CRPS693"
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      

            IF  NOT AVAILABLE craphec   THEN
                DO:
                    
                    IF  LOCKED craphec   THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 55.
                        END.

                END.
            
            aux_cdcritic = 0.
            LEAVE.

        END.

        IF  aux_cdcritic > 0 OR 
            aux_dscritic <> ""  THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.
                          

        ASSIGN craphec.hriniexe =  INT(SUBSTR(par_hrtransf,1,2)) * 60 * 60 + INT(SUBSTR(par_hrtransf,4,2)) * 60.

        ASSIGN craphec.hrfimexe = (INT(SUBSTR(par_hrtransf,1,2)) + 2 ) * 60 * 60 + INT(SUBSTR(par_hrtransf,4,2)) * 60.

        IF INT(SUBSTR(par_hrtransf,1,2)) = 22  THEN
          ASSIGN craphec.hrfimexe = INT(SUBSTR(par_hrtransf,4,2)) * 60.

        IF INT(SUBSTR(par_hrtransf,1,2)) = 23  THEN
          ASSIGN craphec.hrfimexe = 1 * 60 * 60 + INT(SUBSTR(par_hrtransf,4,2)) * 60.


        FIND CURRENT craphec NO-LOCK NO-ERROR.
        RELEASE craphec.

        IF  aux_cdcritic > 0   THEN
            UNDO, NEXT.

        DO  aux_contador = 1 TO 10:
            
            FIND FIRST craphec 
                 WHERE craphec.cdcooper = 1 /* fixo */   
                   AND craphec.cdprogra = "CRPS694"
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      

            IF  NOT AVAILABLE craphec   THEN
                DO:
                    
                    IF  LOCKED craphec   THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 55.
                        END.

                END.
            
            aux_cdcritic = 0.
            LEAVE.
              
        END.  /*  Fim do DO WHILE TRUE  */
              
        IF  aux_cdcritic > 0 OR 
            aux_dscritic <> ""  THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.
                      

        ASSIGN craphec.hriniexe =  INT(SUBSTR(par_hrrecebi,1,2)) * 60 * 60 + INT(SUBSTR(par_hrrecebi,4,2)) * 60.

        ASSIGN craphec.hrfimexe = (INT(SUBSTR(par_hrrecebi,1,2)) + 2 ) * 60 * 60 + INT(SUBSTR(par_hrrecebi,4,2)) * 60.

        IF INT(SUBSTR(par_hrrecebi,1,2)) = 22  THEN
          ASSIGN craphec.hrfimexe = INT(SUBSTR(par_hrrecebi,4,2)) * 60.

        IF INT(SUBSTR(par_hrrecebi,1,2)) = 23  THEN
          ASSIGN craphec.hrfimexe = 1 * 60 * 60 + INT(SUBSTR(par_hrrecebi,4,2)) * 60.



        FIND CURRENT craptab NO-LOCK NO-ERROR.
        RELEASE craptab.

        FIND CURRENT craphec NO-LOCK NO-ERROR.
        RELEASE craphec.

        ASSIGN  aux_flgtrans = TRUE.

    END.  /*  Fim do DO TRANSACTION  */

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
    
    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar os valores.".
            
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


PROCEDURE verifica_sit_serasa:

    DEF  INPUT PARAM par_inserasa     AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cob_inserasa AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_proximo      AS CHAR                           NO-UNDO.

    ASSIGN par_proximo = "N".

    CASE par_inserasa:
    WHEN "2" THEN /* 2. Não Negativado - Buscar apenas quando CRAPCOB.INSERASA igual a 0 ou 6 */
    DO:
        IF par_cob_inserasa <> 0 AND
           par_cob_inserasa <> 6 THEN
            ASSIGN par_proximo = "S".
    END.
    WHEN "3" THEN /* 3. Sol. Enviadas - Buscar apenas quando CRAPCOB.INSERASA igual a 1 ou 2 */
    DO:
        IF par_cob_inserasa <> 1 AND
           par_cob_inserasa <> 2 THEN
            ASSIGN par_proximo = "S".
    END.
    WHEN "4" THEN /* 4. Sol. Cancel. Enviadas - Buscar apenas quando CRAPCOB.INSERASA igual a 3 ou 4 */
    DO:
        IF par_cob_inserasa <> 3 AND
           par_cob_inserasa <> 4 THEN
            ASSIGN par_proximo = "S".
    END.
    WHEN "5" THEN /* 5. Negativados - Buscar apenas quando CRAPCOB.INSERASA igual a 5 */
    DO:
        IF par_cob_inserasa <> 5 THEN
            ASSIGN par_proximo = "S".
    END.
    WHEN "6" THEN /* 6. Sol. Com Erros - Buscar apenas quando CRAPCOB.INSERASA igual a 6 */
    DO:
        IF par_cob_inserasa <> 6 THEN
            ASSIGN par_proximo = "S".
    END.
    WHEN "7" THEN /* 7. Acao Judicial - Buscar apenas quando CRAPCOB.INSERASA igual a 7 */
    DO:
        IF par_cob_inserasa <> 7 THEN
            ASSIGN par_proximo = "S".
    END.
  END CASE.

END PROCEDURE.

PROCEDURE verifica-rollout:
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_vltitulo AS DECI NO-UNDO.
    DEF OUTPUT PARAM par_rollout AS INTE NO-UNDO.
    
    DEF VAR aux_ponteiro      AS INTE                       NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
       
    RUN STORED-PROCEDURE pc_verifica_rollout
                 aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper, /* Cooperativa */ 
                                  INPUT STRING(par_dtmvtolt,"99/99/9999"),  /* Data de movimento */
                                  INPUT par_vltitulo, /* Vl. do Título */
                                  INPUT 2, /* Tipo de regra de rollout(1-registro,2-pagamento)  */
                                 OUTPUT 0). /* Está no Rollout */
       
    CLOSE STORED-PROC pc_verifica_rollout
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }    

    ASSIGN par_rollout = 0
           par_rollout = pc_verifica_rollout.pr_rollout
                           WHEN pc_verifica_rollout.pr_rollout <> ?.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-titulo-npc-cip:
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_vltitulo AS DECI NO-UNDO.
    DEF INPUT PARAM par_flgcbdda AS LOGI NO-UNDO.
    DEF OUTPUT PARAM par_npc_cip AS INTE NO-UNDO.

    DEF VAR aux_rollout AS INTE NO-UNDO.
    DEF VAR aux_npc_cip AS INTE NO-UNDO.

    /* Consulta Rollout */
    RUN verifica-rollout(INPUT par_cdcooper,
                         INPUT par_dtmvtolt,
                         INPUT par_vltitulo,
                         OUTPUT aux_rollout).

    ASSIGN aux_npc_cip = 0.

    IF aux_rollout = 1 THEN /*esta dentro do rollout*/
    DO:
      IF par_flgcbdda = TRUE THEN /*esta na CIP*/
      DO:
        ASSIGN aux_npc_cip = 1.
      END.
    END.

    ASSIGN par_npc_cip = aux_npc_cip.

    RETURN "OK".

END PROCEDURE.

PROCEDURE calcula_multa_juros_boleto:
    DEF INPUT PARAM par_cdcooper             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdconta             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtvencto             AS DATE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtocd             AS DATE              NO-UNDO.
    DEF INPUT PARAM par_vlabatim             AS DECI              NO-UNDO.
    DEF INPUT PARAM par_vltitulo             AS DECI              NO-UNDO.
    DEF INPUT PARAM par_vlrmulta             AS DECI              NO-UNDO.
    DEF INPUT PARAM par_vljurdia             AS DECI              NO-UNDO.
    DEF INPUT PARAM par_cdmensag             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_vldescto             AS DECI              NO-UNDO.
    DEF INPUT PARAM par_tpdmulta             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_tpjurmor             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_flag2via             AS LOGI              NO-UNDO.
    DEF INPUT PARAM par_flgcbdda             AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt             AS DATE              NO-UNDO.
    DEF INPUT PARAM par_dtvctori             AS DATE              NO-UNDO.
    DEF INPUT PARAM par_incobran             AS INTE              NO-UNDO.
    DEF OUTPUT PARAM par_dtvencut            AS DATE              NO-UNDO.
    DEF OUTPUT PARAM par_vltituut            AS DECI              NO-UNDO.
    DEF OUTPUT PARAM par_vlmormut            AS DECI              NO-UNDO.
    DEF OUTPUT PARAM par_dtvencut_atualizado AS DATE              NO-UNDO.
    DEF OUTPUT PARAM par_vltituut_atualizado AS DECI              NO-UNDO.
    DEF OUTPUT PARAM par_vlmormut_atualizado AS DECI              NO-UNDO.
    DEF OUTPUT PARAM par_vldescut            AS DECI              NO-UNDO.
    DEF OUTPUT PARAM par_cdmensut            AS INTE              NO-UNDO.
    DEF OUTPUT PARAM par_cridatut            AS LOGI              NO-UNDO.
                                             
    DEF VAR h-b2crap14                       AS HANDLE            NO-UNDO.
    DEF VAR aux_critdata                     AS LOGI              NO-UNDO.
    DEF VAR aux_vlrjuros                     AS DECI              NO-UNDO.
    DEF VAR aux_vlrmulta                     AS DECI              NO-UNDO.
    DEF VAR aux_vldescto                     AS DECI              NO-UNDO.
    DEF VAR aux_vlabatim                     AS DECI              NO-UNDO.
    DEF VAR aux_vlfatura                     AS DECI              NO-UNDO.
    DEF VAR aux_dscritic                     AS CHAR              NO-UNDO.
    DEF VAR aux_npc_cip                      AS INTE              NO-UNDO.
   
    
    /* Por padrao nao esta vencido */
    ASSIGN aux_critdata = FALSE.
    
    /* Somente será validado o vencimento do boleto para atualizar os dados
    caso esteja EM ABERTO */
    IF par_incobran = 0 THEN
    DO:
    /* rotina para criticar data de vencimento */
    RUN sistema/siscaixa/web/dbo/b2crap14.p PERSISTENT SET h-b2crap14.
    
    RUN verifica-vencimento-titulo IN h-b2crap14(INPUT par_cdcooper, 
                                                 INPUT 90 /*internet*/,
                                                 INPUT par_dtmvtocd,
                                                 INPUT par_dtvencto,
                                                OUTPUT aux_critdata).
    DELETE PROCEDURE h-b2crap14. 
    END.
    
    
    ASSIGN aux_vldescto = 0
           aux_vlabatim = par_vlabatim
           aux_vlfatura = par_vltitulo.

    /* Nao possui desconto, vmaos zerar o valor de desconto */
    IF  par_cdmensag = 0 THEN
        ASSIGN par_vldescto = 0. 

    /* abatimento deve ser calculado antes dos juros/multa */
    IF par_vlabatim > 0 THEN
       ASSIGN aux_vlfatura = aux_vlfatura - par_vlabatim.
   
    /* verifica se o titulo esta vencido */
    IF  aux_critdata  THEN
    DO: 
        /* MULTA PARA ATRASO */
        IF  par_tpdmulta = 1  THEN /* Valor */
            ASSIGN aux_vlrmulta = par_vlrmulta.
        ELSE
        IF  par_tpdmulta = 2  THEN /* % de multa */
            ASSIGN aux_vlrmulta = TRUNCATE( (par_vlrmulta * aux_vlfatura) / 100 , 2).

        /* MORA PARA ATRASO */
        IF  par_tpjurmor = 1  THEN /* dias */
            ASSIGN aux_vlrjuros =  par_vljurdia * 
                                  (par_dtmvtocd - par_dtvencto). 
        ELSE
        IF  par_tpjurmor = 2  THEN /* mes */
            ASSIGN aux_vlrjuros = TRUNCATE( (aux_vlfatura * 
                                  ((par_vljurdia / 100) / 30) * 
                                  (par_dtmvtocd - par_dtvencto)), 2). 
    
        /* se concede ate o vencimento */
        IF  par_cdmensag = 1 OR
            par_cdmensag = 0 THEN
            ASSIGN par_vldescut = 0
                   par_cdmensut = 0
                   aux_vldescto = 0.

    END.
    ELSE
    DO:       
        /* se concede ate o vencto, ja calculou */
        IF  par_cdmensag <> 2  THEN
            ASSIGN aux_vldescto = par_vldescto
                   aux_vlfatura = aux_vlfatura - aux_vldescto.
    END.

    /* se concede apos o vencimento */
    IF  par_cdmensag = 2  THEN
        ASSIGN aux_vldescto = par_vldescto
               aux_vlfatura = aux_vlfatura - aux_vldescto.


    /* valor final da tarifa */
    ASSIGN aux_vlfatura = aux_vlfatura + aux_vlrmulta + aux_vlrjuros.

    IF  par_flag2via  THEN
        DO:
            
            /* Verificar se o titulo está vencido e se está fora do rollout
               para atualizar a data de vencimento */
            ASSIGN par_dtvencut = (IF aux_critdata THEN /* Titulo Vencido */
                                       par_dtmvtocd 
                                   ELSE
                                       par_dtvencto)
                   par_vltituut = aux_vlfatura
                   par_vlmormut = (aux_vlrmulta + aux_vlrjuros).
           
        END.
    ELSE 
        DO:
            ASSIGN par_dtvencut_atualizado = (IF aux_critdata THEN 
                                                  par_dtmvtocd  
                                              ELSE
                                                  par_dtvencto)
                   par_vltituut_atualizado = (IF aux_critdata THEN 
                                                  aux_vlfatura  
                                              ELSE
                                                  par_vltitulo)
                   par_vlmormut_atualizado = (aux_vlrmulta + aux_vlrjuros)      
                   par_dtvencut = par_dtvencto
                   par_vltituut = par_vltitulo.
        END.

    ASSIGN par_cridatut = aux_critdata
           /* Devolver o valor do desconto calculado */
           par_vldescut = aux_vldescto.
           
    IF avail(tt-consulta-blt) THEN DO:

        /* Bloco do novo IB */    

        CASE tt-consulta-blt.cddespec:
          WHEN  1 THEN tt-consulta-blt.dsdespec = "DM".
          WHEN  2 THEN tt-consulta-blt.dsdespec = "DS".
          WHEN  3 THEN tt-consulta-blt.dsdespec = "NP".
          WHEN  4 THEN tt-consulta-blt.dsdespec = "MENS".
          WHEN  5 THEN tt-consulta-blt.dsdespec = "NF".
          WHEN  6 THEN tt-consulta-blt.dsdespec = "RECI".
          WHEN  7 THEN tt-consulta-blt.dsdespec = "OUTR".
        END CASE.    

        IF  tt-consulta-blt.cdmensag = 1 AND par_vldescut > 0 THEN
            ASSIGN tt-consulta-blt.dsdinst1 = 'MANTER DESCONTO ATE O VENCIMENTO'.
        ELSE IF tt-consulta-blt.cdmensag = 2 THEN
            ASSIGN tt-consulta-blt.dsdinst1 = 'MANTER DESCONTO APOS O VENCIMENTO'.
        ELSE
            ASSIGN tt-consulta-blt.dsdinst1 = ' '.
            
        IF crapcob.flgdprot = TRUE THEN
           ASSIGN tt-consulta-blt.dsdinst3 = 'PROTESTAR APOS ' + STRING(crapcob.qtdiaprt) + ' DIAS CORRIDOS DO VENCIMENTO' +
                                             (IF tt-consulta-blt.dtvencto <> ? AND par_cridatut THEN
                                                 ' ORIGINAL ' + STRING(tt-consulta-blt.dtvencto,'99/99/9999') + '.'
                                              ELSE 
                                                 '.')
                  tt-consulta-blt.dsdinst4 = ' '.
                  
        IF crapcob.flserasa = TRUE AND crapcob.qtdianeg > 0  THEN
           ASSIGN tt-consulta-blt.dsdinst3 = 'NEGATIVAR NA SERASA APOS ' + STRING(crapcob.qtdianeg) + ' DIAS CORRIDOS DO VENCIMENTO' +
                                             (IF tt-consulta-blt.dtvencto <> ? AND par_cridatut THEN
                                                 ' ORIGINAL ' + STRING(tt-consulta-blt.dtvencto,'99/99/9999') + '.'
                                              ELSE 
                                                 '.')
                  tt-consulta-blt.dsdinst4 = ' '.              

        IF NOT AVAIL(craptdb) THEN DO:
          FIND LAST craptdb 
              WHERE craptdb.cdcooper = tt-consulta-blt.cdcooper   AND
                    craptdb.nrdconta = tt-consulta-blt.nrdconta   AND
                    craptdb.cdbandoc = tt-consulta-blt.cdbandoc   AND
                    craptdb.nrdctabb = tt-consulta-blt.nrdctabb   AND
                    craptdb.nrcnvcob = tt-consulta-blt.nrcnvcob   AND
                    craptdb.nrdocmto = tt-consulta-blt.nrdocmto   
                    NO-LOCK NO-ERROR.

          IF AVAIL(craptdb) THEN
             ASSIGN tt-consulta-blt.nrborder = craptdb.nrborder.
        END.


        /* Consulta se titulo esta na faixa de rollout e integrado na cip */
        RUN verifica-titulo-npc-cip(INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_vltitulo,
                                    INPUT par_flgcbdda,
                                   OUTPUT aux_npc_cip).

        ASSIGN tt-consulta-blt.vldocmto_boleto  = par_vltitulo
               tt-consulta-blt.vlcobrado_boleto = IF par_cridatut THEN par_vltituut_atualizado ELSE 0
               tt-consulta-blt.dtvencto_boleto  = par_dtvencut_atualizado.        
           
        IF aux_npc_cip = 1 THEN
          DO:
              RUN p_calc_codigo_barras(INPUT tt-consulta-blt.cdbandoc,
                                       INPUT (IF par_dtvctori = ? THEN par_dtvencto ELSE par_dtvctori),
                                       INPUT tt-consulta-blt.vldocmto_boleto,
                                       INPUT tt-consulta-blt.nrcnvcob,
                                       INPUT tt-consulta-blt.nrnosnum,
                                       INPUT tt-consulta-blt.cdcartei,
                                      OUTPUT tt-consulta-blt.dscodbar). 
          END.
        ELSE        
          DO:
              RUN p_calc_codigo_barras(INPUT tt-consulta-blt.cdbandoc,
                                       INPUT tt-consulta-blt.dtvencto_boleto,
                                       INPUT par_vltituut_atualizado,
                                       INPUT tt-consulta-blt.nrcnvcob,
                                       INPUT tt-consulta-blt.nrnosnum,
                                       INPUT tt-consulta-blt.cdcartei,
                                      OUTPUT tt-consulta-blt.dscodbar).
          END.
          
        RUN p_calc_linha_digitavel(INPUT tt-consulta-blt.dscodbar,
                                  OUTPUT tt-consulta-blt.dslindig).                               
        /********************/

    END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE p_calc_codigo_barras:

    DEF INPUT  PARAM par_cdbandoc LIKE crapcob.cdbandoc               NO-UNDO.
    DEF INPUT  PARAM par_dtvencto LIKE crapcob.dtvencto               NO-UNDO.
    DEF INPUT  PARAM par_vltitulo LIKE crapcob.vltitulo               NO-UNDO.
    DEF INPUT  PARAM par_nrcnvcob LIKE crapcob.nrcnvcob               NO-UNDO.
    DEF INPUT  PARAM par_nrnosnum LIKE crapcob.nrnosnum               NO-UNDO.
    DEF INPUT  PARAM par_cdcartei LIKE crapcob.cdcartei               NO-UNDO.
    DEF OUTPUT PARAM par_cod_barras        AS CHAR                    NO-UNDO. 
    
    DEF VAR aux      AS CHAR                                          NO-UNDO.
    DEF VAR dtini    AS DATE INIT "10/07/1997"                        NO-UNDO.

    DEF VAR aux_ftvencto    AS INTE                                   NO-UNDO.
    
    IF par_dtvencto >= DATE("22/02/2025") THEN
           aux_ftvencto = (par_dtvencto - DATE("22/02/2025") ) + 1000.
        ELSE
           aux_ftvencto = (par_dtvencto - dtini).

	IF par_cdbandoc = 085 OR LENGTH(STRING(par_nrcnvcob)) <= 6 THEN
       ASSIGN aux = string(par_cdbandoc,"999")
                           + "9" /* moeda */
                           + "1" /* nao alterar - constante */
                           + STRING(aux_ftvencto, "9999") 
                           + string(par_vltitulo * 100, "9999999999")
                           + string(par_nrcnvcob, "999999")
                           + string(par_nrnosnum, "99999999999999999")
                           + string(par_cdcartei, "99")
              glb_nrcalcul = DECI(aux).
	ELSE
	   ASSIGN aux = string(par_cdbandoc,"999")
		 				   + "9" /* moeda */
						   + "1" /* nao alterar - constante */
						   + STRING(aux_ftvencto, "9999") 
						   + string(par_vltitulo * 100, "9999999999")
						   + "000000"
						   + string(par_nrnosnum, "99999999999999999")
						   + string(par_cdcartei, "99")
			  glb_nrcalcul = DECI(aux).

    RUN sistema/ayllos/fontes/digcbtit.p.
        ASSIGN par_cod_barras = STRING(glb_nrcalcul, 
           "99999999999999999999999999999999999999999999").
        
END PROCEDURE.

PROCEDURE p_calc_linha_digitavel:

      DEF INPUT  PARAM par_codbarras        AS CHAR                 NO-UNDO.
      DEF OUTPUT PARAM par_lindigit         AS CHAR                 NO-UNDO.
      
      DEF VAR aux_titulo1                   AS DEC                  NO-UNDO.
      DEF VAR aux_titulo2                   AS DEC                  NO-UNDO.
      DEF VAR aux_titulo3                   AS DEC                  NO-UNDO.
      DEF VAR aux_titulo4                   AS DEC                  NO-UNDO.
      DEF VAR aux_titulo5                   AS DEC                  NO-UNDO.      
      
      DEF VAR aux_digito                    AS DEC                  NO-UNDO.      
      DEF VAR aux_retorno                   AS LOGICAL              NO-UNDO.
      DEF VAR p-cod-agencia                 AS INTE INIT 1          NO-UNDO.
      DEF VAR p-nro-caixa                   AS INTE INIT 1          NO-UNDO.
      
     /* Modelo: 08599.90103 10085.000403 00000.118018 2 65310000032716 */
     
     ASSIGN aux_titulo1 = DEC(SUBSTRING(par_codbarras,1,3) + 
                              SUBSTRING(par_codbarras,4,1) + 
                              SUBSTRING(par_codbarras,20,5) + "0").
                          
     /*  Calcula digito- Primeiro campo da linha digitavel  */
     RUN dbo/pcrap03.p (INPUT-OUTPUT aux_titulo1,
                        INPUT        TRUE,  /* Validar zeros */ 
                        OUTPUT aux_digito,
                        OUTPUT aux_retorno).                                
        
     ASSIGN aux_titulo2 = DEC(SUBSTRING(par_codbarras,25,10) + "0").
                          
     /*  Calcula digito- Segundo campo da linha digitavel  */
     RUN dbo/pcrap03.p (INPUT-OUTPUT aux_titulo2,
                        INPUT        TRUE,  /* Validar zeros */ 
                        OUTPUT aux_digito,
                        OUTPUT aux_retorno).
                        
     ASSIGN aux_titulo3 = DEC(SUBSTRING(par_codbarras,35,10) + "0").
                          
     /*  Calcula digito- Terceiro campo da linha digitavel  */
     RUN dbo/pcrap03.p (INPUT-OUTPUT aux_titulo3,
                        INPUT        TRUE,  /* Validar zeros */ 
                        OUTPUT aux_digito,
                        OUTPUT aux_retorno).
                              
     /* Quarto Campo Linha Digitável = DV - Código de Barras */
     ASSIGN aux_titulo4 = DEC(SUBSTRING(par_codbarras,5,1)).
      
     /* Quinto Campo Linha Digitável = FV + Valor do titulo */
     ASSIGN aux_titulo5 = DEC(SUBSTRING(par_codbarras,6,4) + 
                              SUBSTRING(par_codbarras,10,10)).      
      
     ASSIGN par_lindigit = STRING(aux_titulo1,"9999999999") + 
                           STRING(aux_titulo2,"99999999999") + 
                           STRING(aux_titulo3,"99999999999") + 
                           STRING(aux_titulo4,"9") + 
                           STRING(aux_titulo5,"99999999999999").

     RETURN "OK".

END PROCEDURE.


PROCEDURE valida_caracteres:
    /* Rotina de validacao de caracteres com base parametros informados */

    /*  - par_validar  : Campo a ser validado.
        - par_validado : Retorna campo sem caracteres especiais. */

    DEF INPUT  PARAM par_validar     AS CHAR            NO-UNDO.
    DEF OUTPUT PARAM par_validado    AS CHAR            NO-UNDO.

    DEF VAR aux_numeros             AS CHAR             NO-UNDO.
    DEF VAR aux_letras              AS CHAR             NO-UNDO.
    DEF VAR aux_caracteres          AS CHAR             NO-UNDO.
    DEF VAR aux_contador            AS INTE             NO-UNDO.
    DEF VAR aux_posicao             AS CHAR             NO-UNDO.
	DEF VAR aux_especial			AS CHAR 			NO-UNDO.
 
    ASSIGN aux_especial = ".,-_ "
		   aux_numeros  = "1234567890"
		   aux_letras   = "ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÇabcdefghijklmnopqrstuvwxyzáàäâãéèëêíìïîóòöôõúùüûç".
   
    aux_caracteres = aux_caracteres + aux_numeros.

    aux_caracteres = aux_caracteres + aux_letras.

    aux_caracteres = aux_caracteres + aux_especial.

    DO aux_contador = 1 TO LENGTH(par_validar):
    
        ASSIGN aux_posicao = SUBSTRING(par_validar,aux_contador,1).

        IF INDEX(aux_caracteres,aux_posicao) > 0 THEN DO:
		  par_validado = par_validado + aux_posicao.
		END.

    END.

END PROCEDURE.

/*Busca o nome que ira imprimir no boleto*/
PROCEDURE busca-nome-imp-blt:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta    NO-UNDO.
    DEF INPUT PARAM par_idseqttl    LIKE    crapttl.idseqttl    NO-UNDO.
    DEF INPUT PARAM par_nmprogra    AS      CHAR                NO-UNDO.

    DEF OUTPUT PARAM par_nmprimtl   AS      CHAR                NO-UNDO.
    DEF OUTPUT PARAM par_dscritic   AS      CHAR                NO-UNDO.

    DEF VAR aux_des_erro	        AS      CHAR			    NO-UNDO.
    DEF VAR aux_dscritic            AS      CHAR                NO-UNDO.
    DEF VAR aux_msgerora            AS      CHAR                NO-UNDO.


    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_nome_imp_blt
      aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT deci(par_cdcooper),
                          INPUT deci(par_nrdconta),
                          INPUT deci(par_idseqttl),
                          OUTPUT "",
                          OUTPUT "",
                          OUTPUT "").

    IF  ERROR-STATUS:ERROR  THEN 
    DO:

        ASSIGN aux_msgerora = ERROR-STATUS:GET-MESSAGE(ERROR-STATUS:NUM-MESSAGES).

        RUN valida_caracteres(INPUT aux_msgerora,
                              OUTPUT aux_msgerora).

        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        UNIX SILENT VALUE("echo " + 
                          STRING(TIME,"HH:MM:SS") + " - B1WGEN0010 Run pc_busca_nome_imp_blt  ' --> '" + aux_msgerora +                          
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/proc_message.log").       

        RETURN "NOK".
    END.

    CLOSE STORED-PROC pc_busca_nome_imp_blt aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_nmprimtl = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_des_erro = pc_busca_nome_imp_blt.pr_des_erro
                          WHEN pc_busca_nome_imp_blt.pr_des_erro <> ?
           aux_dscritic = pc_busca_nome_imp_blt.pr_dscritic
                          WHEN pc_busca_nome_imp_blt.pr_dscritic <> ?
           par_nmprimtl = pc_busca_nome_imp_blt.pr_nmprimtl
                          WHEN pc_busca_nome_imp_blt.pr_nmprimtl <> ?.         

    IF  aux_des_erro <> "OK" OR
        aux_dscritic <> ""   THEN 
    DO: 
        RUN valida_caracteres(INPUT aux_dscritic,
                              OUTPUT aux_dscritic).

        IF  aux_dscritic = "" THEN DO:   
            ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario para ser impresso no boleto".
        END.

        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - B1WGEN0010." + par_nmprogra + "' --> '" + aux_dscritic +                          
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/proc_message.log").

        ASSIGN par_dscritic = aux_dscritic.
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

/*Controla se eh necessario ler novamente o nome do beneficiario*/
PROCEDURE controla-busca-nmdobnfc:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta        NO-UNDO.
    DEF INPUT PARAM par_idseqttl    LIKE    crapttl.idseqttl        NO-UNDO.
    DEF INPUT PARAM par_nmrotina    AS      CHAR                    NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM par_contaant LIKE crapass.nrdconta       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_sqttlant LIKE crapttl.idseqttl       NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_nmdobnfc AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic   AS      CHAR                    NO-UNDO.

    IF par_nrdconta <> par_contaant OR 
       par_idseqttl <> par_sqttlant THEN
    DO: 
        /*Busca nome impresso no boleto*/
        RUN busca-nome-imp-blt(INPUT  par_cdcooper
                              ,INPUT  par_nrdconta
                              ,INPUT  par_idseqttl
                              ,INPUT  par_nmrotina
                              ,OUTPUT par_nmdobnfc
                              ,OUTPUT aux_dscritic).
    
        IF  RETURN-VALUE <> "OK" OR
            aux_dscritic <> ""   THEN 
    		DO: 
    			IF  aux_dscritic = "" THEN 
    			DO:   
    				ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario para ser impresso no boleto".
    			END.
    			
    			CREATE tt-erro.
                ASSIGN tt-erro.dscritic = aux_dscritic.
    
                ASSIGN par_dscritic     = aux_dscritic.
    			
                RETURN "NOK".
            END.

        /* Armazenar o numero da conta e a Seq do titular */ 
        ASSIGN par_contaant = par_nrdconta
               par_sqttlant = par_idseqttl.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_dados_beneficiario:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta        NO-UNDO.

    /* buscar os dados cadastrais do cooperado beneficiario dos boletos */
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta
           NO-LOCK NO-ERROR.
           
    /* se cooperado-beneficiario for PF */
    IF crapass.inpessoa = 1 THEN 
       FIND FIRST crapenc
            WHERE crapenc.cdcooper = crapass.cdcooper
              AND crapenc.nrdconta = crapass.nrdconta
              AND crapenc.tpendass = 10 
              NO-LOCK NO-ERROR.
    ELSE
       FIND FIRST crapenc
            WHERE crapenc.cdcooper = crapass.cdcooper
              AND crapenc.nrdconta = crapass.nrdconta
              AND crapenc.tpendass = 9 
              NO-LOCK NO-ERROR.  
              
    IF AVAILABLE crapenc THEN
       ASSIGN tt-consulta-blt.dsendere_bnf = crapenc.dsendere
              tt-consulta-blt.nrendere_bnf = crapenc.nrendere
              tt-consulta-blt.nrcepend_bnf = crapenc.nrcepend
              tt-consulta-blt.complend_bnf = crapenc.complend
              tt-consulta-blt.nmbairro_bnf = crapenc.nmbairro
              tt-consulta-blt.nmcidade_bnf = crapenc.nmcidade
              tt-consulta-blt.cdufende_bnf = crapenc.cdufende.
    ELSE
       ASSIGN tt-consulta-blt.dsendere_bnf = 'NAO ENCONTRADO'
              tt-consulta-blt.nrendere_bnf = 0
              tt-consulta-blt.nrcepend_bnf = 0
              tt-consulta-blt.complend_bnf = ' '
              tt-consulta-blt.nmbairro_bnf = ' '
              tt-consulta-blt.nmcidade_bnf = ' '
              tt-consulta-blt.cdufende_bnf = ' '.

    RETURN "OK".

END PROCEDURE.
