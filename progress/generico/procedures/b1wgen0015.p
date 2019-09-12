/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +--------------------------------------+--------------------------------------+
  | Rotina Progress                      | Rotina Oracle PLSQL                  |
  +--------------------------------------+--------------------------------------+
  | b1wgen0015.p                         | INET0001                             |
  | PROCEDURES:                          | PROCEDURES:                          |
  |  busca_limites                       |  INET0001.pc_busca_limites           |
  |  horario_operacao                    |  INET0001.pc_horario_operacao        |
  |  valida-conta-destino                |  INET0001.pc_valida_conta_destino    |
  |  verifica_operacao                   |  INET0001.pc_verifica_operacao       |
  |  consulta-contas-cadastradas         |  INET0001.pc_con_contas_cadastradas  |
  |  consulta-finalidades                |  INET0001.pc_consulta_finalidades    |
  |  executa_transferencia               |  PAGA0001.pc_executa_transferencia   |
  |  verifica_agendamento_recorrente     |  PAGA0002.pc_verif_agend_recorrente  |
  |  verifica-dados-ted                  |  CXON0020.pc_verifica_dados_ted      |
  |  inclui-conta-transferencia          |  CADA0002.pc_inclui_conta_transf     |
  |  executa-envio-ted                   |  CXON0020.pc_executa_envio_ted       |
  |  obtem_situacao_ura                  |  CADA0004.fn_situacao_senha          |
  |  obtem_situacao_internet             |  CADA0004.fn_situacao_senha          |
  |  valida-inclusao-conta-transferencia |  CADA0002.pc_val_inclui_conta_transf |
  |  cancelar-senha-internet             |  CADA0003.pc_cancelar_senha_internet |
  +--------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
********************************************************************************/
/*...............................................................................

    Programa: b1wgen0015.p
    Autor   : Evandro
    Data    : Abril/2006                      Ultima Atualizacao: 26/03/2019
    
    Dados referentes ao programa:

    Objetivo  : BO para controlar horarios, limites e saldo em operacoes da
                internet e executar a transferencia entre contas.            

    Alteracoes: 09/08/2007 - Preparada procedure para validar diversas
                             operacoes da internet e nao somente a
                             transferencia (Evandro).
                28/09/2007 - Acrescentada validacao do limite quando for = 0 na 
                             procedure verifica_operacao (David);
                           - Deletar procedures persistentes (Evandro).
                           
                31/10/2007 - Incluida procedure verifica_limite_saque (Diego).
                    
                16/11/2007 - Alterar param para BO que gera protocolo (David).
                
                20/11/2007 - Alteracao para o Sistema EXTRACASH (Ze).

                21/12/2007 - Horario especial para pagamentos em finais de
                             semana e feriados (David).
                             
                27/12/2007 - Alteracao para o Sistema EXTRACASH (Ze).
                
                28/12/2007 - Tratamento para contas juridicas (David).
                
                31/01/2008 - Incluir nro cartao no executa transferencia (Ze).

                14/02/2008 - Incluir procedures para rotina de Tele-Atendimento
                           - Incluir procedures para rotina de Internet
                             (David).
                             
                12/03/2008 - Alterar crapnsu para uma transacao isolada (Ze).

                08/04/2008 - Implementar agendamento de pagamentos e 
                             transferencias (David).

                19/06/2008 - Incluir procedures para rotina de Internet (David)
                
                02/09/2008 - Nao permitir transferencia para mesma Conta
                            (Diego).

                19/12/2008 - Nao permitir pagamentos e agendamentos (pagamentos
                             e transferencias) para o dia 31/12 (David).
                             
                20/05/2009 - Alterar tratamento para verificacao de registros
                             que estao com EXCLUSIVE-LOCK (David).     
                                     
                27/07/2009 - Alteracoes do Projeto de Transferencia para 
                             Credito de Salario (David).
                             
                02/10/2009 - Aumento do campo nrterfin (Diego).
                
                04/01/2010 - Alterar tratamento para nao permitir pagamentos
                             no ultimo dia util do ano (David).
                             
                22/04/2010 - Verificar se existem agendamentos pendentes no
                             cancelamento do acesso ao InternetBank (David).
                             
                30/04/2010 - Adequacoes para o novo sistema cash, criada a
                             origem como 3 para manter o funcionamento da
                             BO para o cash da foton (Evandro).
                
                19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                             (Diego).
                             
                24/09/2010 - Bloquear agendamentos para o PAC 5 da Creditextil,
                             referente a sobreposicao de PACs (David).
                             
                21/10/2010 - Bloquear recebimento de transferencia para contas
                             do PAC 5 da Creditextil, referente a sobreposicao
                             de PAC (David).                
                             
                10/01/2011 - Retirar tratamentos que tratam de cobranca na 
                             rotina de INTERNET da ATENDA (Gabriel). 
                             
                24/02/2011 - Validar agendamento recorrente de transferenci 
                             para data passada (David).
                             
                01/05/2011 - Ajustes para a utilizacao das rotinas de 
                             transferencias no TAA Compartilhado (Henrique).
                             
                22/06/2011 - Ajustes na proc. horario_operacao, retirado o 
                             return NOK quando estouro de tempo (Jorge).
                             
                05/08/2011 - Efetuar geracao de protocolo (Gabriel).
                
                05/10/2011 - Adaptacoes para Operadores internet (Guilherme).
                
                25/11/2011 - Ajustar posicao do termo AGENDADO no campo
                             cdpesqbb na execucao de transferencia (David).
                             
                25/04/2012 - Criadas novas procedures para rotina INTERNET da
                             tela ATENDA (Lucas).
                             
                11/05/2012 - Projeto TED Internet (David);
                           - Eliminar EXTENT vldmovto (Evandro).
                           
                19/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                02/07/2012 - Alterado o campo aux_dslitera (David Kruger).
                           - Validar caracteres especiais no nome do favorecido
                             para transferencia de TED (David Kistner).
                             
                09/07/2012 - Alterado valor do parâmetro com Cód. do Histórico
                             da chamada da procedure 'grava-autenticacao' (Lucas).
                
                20/07/2012 - Tratamento dos valores de limite pessoa juridica e
                             pessoa fisica na procedure valida-dados-limites (Lucas R.).
                             
                08/11/2012 - Tratamento para Viacredi Alto Vale (David).
                
                28/11/2012 - Tratamento para evitar agendamentos de contas
                             migradas - tabela craptco - TAA (Evandro).
                             
                11/12/2012 - Tratamento para buscar valores e gravar dos novos campos
                             dtlimtrf, dtlimpgo, dtlimted e  dtlimweb (Daniel).            
                             
                17/12/2012 - Tratamento para impedir credito de transferencia 
                             para conta migrada (David).
                             
                02/01/2013 - Ajuste bloqueio pagamentos no ultimo dia util do
                             ano (David).  
                           - Alterada a procedure 'liberar-senha-internet' para
                             verificar se o cooperado possui letras cadastradas (Lucas).
                             
                14/01/2013 - Retirado controle de registro em LOCK para a tabela craptab
                             na procedure horario_operacao (Daniel). 
                        
                27/03/2013 - Transferencia intercooperativa (Gabriel).
                           
                18/04/2013 - Cadastro de limites Vr Boleto (David Kruger).
                
                11/07/2013   Alteraçoes na procedure 'executa-transferencia-intercooperativa':
                           - Gravar campos corretos da crapmvi de acordo com tipo de pessoa
                           - Alterada crítica "TED invalida" 
                           - Tratamento para informar flag de agendamento
                             na chamada da procedure 'gera_protocolo' (Lucas).
                             
                22/07/2013 - Implementacao de bloqueio de senha. (Jorge)
                
                
                23/07/2013 - Retirado buscar valor tarifa TED da craptab na
                             procedure verifica_operacao, sera utilizado
                             procedure busca-tarifa-ted da b1crap20 (Daniel).
                             
                17/09/2013 - Ajuste Tranf.Intercooperativa TAA. Separar
                             validacoes especificas da Internet. (David).
                             
                20/09/2013 - Alteracao de PAC/P.A.C para PA. (James)
                
                23/09/2013 - Ajuste na leitura de preposto na Tranferencia
                             Intercooperativa via Internet (David). 
                             
                27/09/2013 - Ajustar bloqueio de agendamentos para migracao
                             Acredi-Viacredi (David).
                             
                30/10/2013 - Incluida procedure cria_senha_ura para permitir
                             criar senha da ura pela tela atenda (Oliver - GATI).
                             
                16/12/2013 - Retirar bloqueio de transferencia para PAC migrado.
                             Validacao ja esta sendo feita na procedure
                             verifica_operacao, verificando se o cooperado
                             esta demitido (David).
                   
                19/12/2013 - Adicionado validate para as tabelas crapmvi,
                             crapltr, crablcm, crapsnh, crapcti (Tiago).
                             
                13/01/2014 - Alterada critica de "Agencia nao cadastrada" para
                             "PA nao cadastrado". (Reinert)
                             
                24/01/2014 - Incluir procedure valida_senha_ura para validar
                             criacao/alteracao da senha URA. 
                           - Adicionar bloco de transacao e validacoes na
                             procedure cria_senha_ura.
                           - Incluir parametro aux_dtmvtolt na procedure 
                             altera_senha_ura;
                           - Remodelar procedure carrega_dados_ura. (Reinert)
                           
                21/02/2014 - Para TED enviada por conta administrativa, utilizar
                             o tipo de pessoa 2 na validacao (David).
                             
                24/03/2014 - Retirar controles de sequencia na crapcti
                             (Gabriel)    
                             
                20/05/2014 - Adicionado verificacao de conta destino em transfe-
                             rencias Intra e Inter bancarias em 
                             proc. verifica_operacao
                             (Jorge/Adriano) SD - Emergencial

                22/05/2014 - Ajustado procedure "horario_operacao" quando
                             par_inpessoa maior que 1 utilizar sempre 2
                             (Douglas - Chamado 158501)
                             
                30/06/2014 - Buscar contas bloqueadas para a origem
                             internet (Chamado 161848) (Jonata - RKAM).
                             
                06/08/2014 - Nao sera configurada data limite para agendamentos 
                             provenientes de conta migrada da Concredi e
                             Credimilsul (David).
                           - Bloquear transferencia intercooperativa durante e
                             apos migracao para contas da Concredi e Credimilsul 
                             (David).
                                                          
                18/08/2014 - Inclusao do parametro par_dshistor na executa-envio-ted
                             em funçao da Obrigatoriedade do campo Histórico para TED/DOC  
                             com Finalidade "Outros" (Vanessa)
                             
                11/09/2014 - Buscar contas bloqueadas apenas para outras instituicoes 
                             (Chamado 161848) (Jonathan - RKAM).                           
                             
                22/09/2014 - Incluido verificacao de horario (horario_operacao)
                             p/ tpoperac = 11. (Debito Facil - Fabricio)
                             
                16/10/2014 - (Chamado 161844) Retirar critica para agendamento de dia 
                             nao util, tratamento agora sera feito na BO16
                             (Tiago Castro - RKAM).
                             
                13/11/2014 - (Chamado 217240) Alterar tab045, retirado o uso de substr
                             para utilizar entry a pedido de Adriano. (Tiago Castro - RKAM).
                             
                04/12/2014 - Permitir o envio de TEDs no ultimo dia do ano
                             (Diego).
                             
                08/12/2014 - Retirada da Validação da Agencia no cadatro de Contas 
                             para TEDs valida-inclusao-conta-transferencia 
                             SD231030 (Vanessa)
                             
                15/12/2014 - Melhorias Cadastro de Favorecidos TED
                            (André Santos - SUPERO)
                            
                03/03/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)

                26/03/2015 - Alterado tratamento para que todas as cooperativas 
                             utilizem as informações do PA 90 na mensagem de 
                             habilitação dos favorecidos de TED, e não mais 
                             apenas a VIACREDI (Douglas - Chamado 270431)
                             
                15/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)

                06/07/2015 - Validar retorno da procedure gera_protocolo, e em caso
                             de erro gerar log e enviar email para Elton/Diego
                             (Douglas - Chamado 294944)

                22/07/2015 - Ajustar o lock da craplot na executa_transferencia 
                             para diminuir a quantidade de mensagem de lote em
                             uso para o cooperado. (Douglas - Chamado 311167)
                             
                06/08/2015 - Incluir regra para evitar que sejam efetivadas
                             2 transferencias iguais enviadas pelo ambiente 
                             mobile (David).
                             
                21/10/2015 - Incluir Chamada da procedure gera_arquivo_log_ted ao
                             enviar teds e tambem efetuar tratamento de return-value
                             (Lucas ranghetti/Elton #343312)

               26/10/2015 - Inclusao de verificacao indicador estado de crise na 
                            horario_operacao. (Jaison/Andrino)

               30/10/2015 - Incluir validacao da crapaut ao enviar teds 
                            (Lucas Ranghetti #343312)
                            
               09/11/2015 - Incluir log na validacao da crapaut ao enviar teds
                            (Lucas Ranghetti #355418)
                            
               16/11/2015 - Estado de crise (Gabriel-RKAM).

							 17/11/2015 - Alterado a procedure obtem-dados-titulares para 
                            carregar os representantes utilizando a procedure
                            Busca_Dados da BO b1wgen0058, Prj. Ass. Conjunta (Jean Michel).
														 
               23/11/2015 - Ajustado para que seja utilizado a procedure
                            obtem-saldo-dia convertido em Oracle
                            (Douglas - Chamado 285228)
                            
               30/11/2015 - Efetuada correcao na procedure 
                            'valida-inclusao-conta-transferencia' relacionada a
                            inclusao do campo ISPB (Diego - Chamado 326256).
               
               20/11/2015 - Ajustado bloquear-senha-internet, cancelar-senha-internet, 
                             valida-dados-limites,  alterar-limites-internet, 
                             Criado replica-limite-internet para o Projeto 131
                             Multipla Assinatura PJ. (Jorge/David)
                            Adicionado validacao para contas PJ, assinatura multipla.
                             em proc. verifica_operacao. (Jorge/David) Proj. 131 Assinatura Multipla
             
               15/12/2015 - Ajustar regra para habilitar os limites da internet para
		                    os demais cargos do campo Representante/Procurador 
                            (Jonathan - RKAM)
                                         
               17/02/2016 - Melhorias para o envio e cadastro de novas contas para
                            TED, M. 118. Conversão Progress -> PL/SQL. (Jean Michel)

                          - Excluido validacao de conta nao cadastrada para TED (Jean Michel).
                                     
		       24/02/2016 - Adicionado validacao na procedure acesso-cadastro-favorecidos
							para listar somente bancos ativos flgdispb = TRUE (Lucas Ranghetti #400055)
							    
			   23/03/2016 - Ajuste para controlar o lock de tabelas de forma correta (Adriano).
										    
               24/03/2016 - Adicionados parâmetros para geraçao de LOG
                           (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)										    										    

               29/03/2016 - Ajuste na rotina executa_transferencia para não validar mais
                            TED duplicadas considerando um valor x de tempo entre uma 
                            TED e outra (Adriano). 

               04/04/2016 - Correcao no tratamento de uso dos sistema PAG e STR na 
                            horario_operacao para que ao usar ambos seja verificado 
                            a hora inicio e fim de operacao quando habilitados. 
                            (SD 428886 - Carlos Rafael Tanholi)
										    
               12/04/2016 - Remocao Aprovacao Favorecido. (Jaison/Marcos - SUPERO)

			   20/04/2016 - Remocao de caracteres invalidos no nome da agencia conforme
							solicitado no chamado 429584 (Kelvin)							    

			   16/05/2016 - Ajuste para retirar comentários e códigos desnecessários.
					       (Adriano - M117).
                            
               18/05/2016 - Projeto 117 - Verificacao de assinatura conjunta em 
                            acesso-cadastro-favorecidos (Carlos)
                            
               07/06/2016 - Inclusão de campos de controle de vendas ( Rafael Maciel [RKAM] )
							
			   09/06/2016 - Ajuste para corrigir rotinas que estejam ficando inteiramente como
                            um transacao (Adriano).			

               17/06/2016 - Inclusão de campos de controle de vendas ( Rafael Maciel [RKAM] )

			   30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

			   25/07/2016 - Ajuste na rotina executa-envio-ted para corrigir nomenclatura 
                            das tags do xml(Adriano).
                            
               30/08/2016 - Inclusao dos campos de último acesso via Mobile na procedure 
                            obtem-dados-titulares - PRJ286.5 - Cecred Mobile (Dionathan)

               02/09/2016 - Alteracao da procedure obtem-dados-titulares, SD 514239 (Jean Michel).

               21/09/2016 - Ajuste na validacao do horario de envio da TED (Diego).
			                  
			   28/09/2016 - #474660 Alterada a regra de impressao de termo de responsabilidade
                            na rotina liberar-senha-internet para nao imprimir quando o cooperado
                            estava com o acesso bloqueado ou quando o mesmo foi admitido na
                            cooperativa depois de 11/2015 (Carlos)

			   25/10/2016 - Novo ajuste na validacao do horario de envio da TED, solicitado 
			                pelo financeiro (Diego).

               03/11/2016 - Correçao de leitura "FIRST crabsnh" da procedure liberar-senha-internet,
                            Prj. Assinatura Conjunta (Jean Michel).

               12/01/2017 - Ajuste para nao permitir que um favorecido de TED seja desativado
					        caso o mesmo possua algum agendamento cadastrado
							(Adriano - SD 593235).
              
              31/01/2017 - Alteraçao dos termos na rotina gera-termo-responsabilidade.
                           Alteracao na rotina executa-envio-ted, incluido param de ip e dstransa
                           PRJ335 - Analise de fraude. (Odirlei-AMcom).
              
               12/05/2017 - Segunda fase da melhoria 342 (Kelvin).


              18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                          crapass, crapttl, crapjur (Adriano - P339).

			   26/06/2017 - Ajuste para chamar rotina convertida na procedure cancelar-senha-internet
			                (Jonata - RKAM P364).
                           
              12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                           pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
              08/02/2018 - Na procedure atualizar-preposto foi atualizado as transacoes pendentes
                           de aprovacao para o novo preposto qdo for PJ sem ass conjunta(Tiago #775776).

	          30/01/2018 - Adicionado tratamento na valida-inclusao-conta-transferencia
                           para trocar a mensagem quando a origem for InternetBank (Anderson).
						   
			  24/04/2018 - Normalizandos criticas para que busque apenas da tabela crapcri
						   tambem no "WHEN OTHERS THEN" para que nao mostre mais críticas
						   que o usuário não precise enxergar e então gravando em log. 
						   (SD 865935 - Kelvin)		   
              
              12/04/2018 - Inclusao de novos campo para realizaçao 
                           de analise de fraude. 
                           PRJ381 - AntiFraude (Odirlei-AMcom)
                           
              19/07/2018 - Ajustar a verifica_operacao para enviar o parametro de agencia corretamente
                           ao inves do valor fixo 90 (PRJ 363 - Douglas Quisinski)

			  29/08/2018 - Foi adicionado um campo na tabela tt-dados-titular para retornar o
						   Valor limite folha de pagamento (Felipe Fronza Mout`s)

			  08/09/2018 - Pagina na tela Contas de Outras IFs (Andrey Formigari - Mouts)

              12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta corrente(LANC0001) na tabela CRAPLCM  - José Carvalho(AMcom)
              
              16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

              26/03/2019 - PRB0040591 - Problema com CRAPSNH "perdidos" e inativos que impossibilitam
                           mudar o limite de titular (Andreatta-Mouts)

              11/06/2019 - Ajuste para tratar TED Judicial.
                           Jose Dill - Mouts (P475 - REQ39)


..............................................................................*/

{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0016tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW }
/* INCLUDE DA TEMP TABLE */ 
{ sistema/generico/includes/b1wgen0200tt.i }


DEF STREAM str_1.

DEF TEMP-TABLE cratlot NO-UNDO LIKE craplot.
DEF TEMP-TABLE cratlcm NO-UNDO LIKE craplcm.
DEF TEMP-TABLE crataut NO-UNDO LIKE crapaut.
DEF TEMP-TABLE cratmvi NO-UNDO LIKE crapmvi.
DEF TEMP-TABLE cratsnh NO-UNDO LIKE crapsnh.
DEF TEMP-TABLE cratopi NO-UNDO LIKE crapopi.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_cont_raiz AS INTEGER NO-UNDO.
DEF VAR aux_cont      AS INTEGER NO-UNDO.

/* Utilizadas para log */
DEF TEMP-TABLE tt-crapcti-old NO-UNDO LIKE crapcti
    FIELD nrcpfope AS DECI FORMAT "99999999999"
    FIELD nrcpfpre AS DECI FORMAT "99999999999999".
    
DEF TEMP-TABLE tt-crapcti-new NO-UNDO LIKE crapcti
    FIELD nrcpfope AS DECI FORMAT "99999999999"
    FIELD nrcpfpre AS DECI FORMAT "99999999999999".

DEF TEMP-TABLE tt-vlapagar NO-UNDO 
    FIELD dtmvtopg AS DATE
    FIELD vlapagar AS DECI.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**        Procedure para verificar horario permitido para transacoes        **/
/******************************************************************************/
PROCEDURE horario_operacao:
    
    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_tpoperac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa LIKE crapass.inpessoa             NO-UNDO.

    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-limite.   
    
    DEF VAR aux_flsgproc AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_hrinipag AS INTE                                    NO-UNDO.
    DEF VAR aux_hrfimpag AS INTE                                    NO-UNDO.
    DEF VAR aux_qtmesagd AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-limite.


    IF  par_tpoperac = 0  OR   /** Todos            **/ 
        par_tpoperac = 4  OR   par_tpoperac = 22 OR   /** TED **/ /*REQ39*/
        par_tpoperac = 6       /** VR-Boleto        **/
        /* par_tpoperac = 7  THEN */ /** Folha Pagamento  **/ /*Projeto 475 - Sprint D2 - Marcelo Coelho - não verificar crise para Folha */
        THEN
        DO:
            /* Busca o indicador estado de crise */
            FIND craptab WHERE craptab.cdcooper = 0           AND
                               craptab.nmsistem = "CRED"      AND
                               craptab.tptabela = "GENERI"    AND
                               craptab.cdempres = 0           AND
                               craptab.cdacesso = "ESTCRISE"  AND
                               craptab.tpregist = 0           
                               NO-LOCK NO-ERROR.
        
            IF AVAIL craptab  THEN  
               DO:
                   /* Se estiver setado como estado de crise */
                   IF craptab.dstextab = "S" THEN
                      DO:
                          par_dscritic = "Sistema indisponivel no momento. Tente mais tarde!".
                          RETURN "NOK".
                      END.
               END.
        END.

    IF  par_tpoperac = 0  OR    /** Todos         **/
        par_tpoperac = 1  OR    /** Transferencia **/
        par_tpoperac = 2  OR    /** Pagamento     **/
        par_tpoperac = 5  THEN  /* Transf. intercooperativa */
        DO:
            FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "LIMINTERNT"   AND
                               craptab.tpregist = IF par_inpessoa > 1 THEN 2 ELSE 1
                               NO-LOCK NO-ERROR.
                   
            IF  NOT AVAILABLE craptab  THEN
                DO:    
                    par_dscritic = "Tabela (LIMINTERNT) nao cadastrada.".
                    RETURN "NOK".
                END.

            ASSIGN aux_qtmesagd = INTE(ENTRY(05,craptab.dstextab,";")).
        END.
    
    IF  par_tpoperac = 0  OR 
        par_tpoperac = 1  OR
        par_tpoperac = 5  THEN /** Transferencia **/
        DO:
            /** Verifica horario inicial e final para transferencias **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 00           AND
                               craptab.cdacesso = "HRTRANSFER" AND
                               craptab.tpregist = par_cdagenci
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craptab  THEN
                DO:    
                    par_dscritic = "Tabela (HRTRANSFER) nao cadastrada.".
                    RETURN "NOK".
                END.

            ASSIGN aux_flsgproc = IF SUBSTR(craptab.dstextab,15,3) = "SIM" THEN
                                     TRUE
                                  ELSE
                                     FALSE.
                        
            /** Horario diferenciado para finais de semana e feriados **/
            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                ASSIGN aux_hrinipag = 21600       /** 06:00 horas **/
                       aux_hrfimpag = 82800.      /** 23:00 horas **/
            ELSE
                ASSIGN aux_hrinipag = INTE(SUBSTR(craptab.dstextab,9,5))
                       aux_hrfimpag = INTE(SUBSTR(craptab.dstextab,3,5)).

            CREATE tt-limite.
            ASSIGN tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                   tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                   tt-limite.nrhorini = aux_hrinipag
                   tt-limite.nrhorfim = aux_hrfimpag
                   tt-limite.idesthor = IF  TIME < aux_hrinipag  OR  
                                            TIME > aux_hrfimpag  THEN
                                            1  /** Estourou limite de horario **/
                                        ELSE
                                            2  /** Dentro do horario limite   **/
                   tt-limite.flsgproc = aux_flsgproc
                   tt-limite.qtmesagd = aux_qtmesagd
                   tt-limite.idtpdpag = 1.
        END. 
    
    IF  par_tpoperac = 0 OR par_tpoperac = 2  THEN /** Pagamento **/
        DO:
            /** Verifica horario limite para pagamentos via internet **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 00           AND
                               craptab.cdacesso = "HRTRTITULO" AND
                               craptab.tpregist = par_cdagenci
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craptab  THEN
                DO:    
                    par_dscritic = "Tabela (HRTRTITULO) nao cadastrada.".
                    RETURN "NOK".
                END.

            ASSIGN aux_flsgproc = IF SUBSTR(craptab.dstextab,15,3) = "SIM" THEN
                                     TRUE
                                  ELSE
                                     FALSE.
                        
            /** Horario diferenciado para finais de semana e feriados **/
            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                ASSIGN aux_hrinipag = 21600       /** 06:00 horas **/
                       aux_hrfimpag = 82800.      /** 23:00 horas **/
            ELSE
                ASSIGN aux_hrinipag = INTE(SUBSTR(craptab.dstextab,9,5))
                       aux_hrfimpag = INTE(SUBSTR(craptab.dstextab,3,5)).

            CREATE tt-limite.
            ASSIGN tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                   tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                   tt-limite.nrhorini = aux_hrinipag
                   tt-limite.nrhorfim = aux_hrfimpag
                   tt-limite.idesthor = IF  TIME < aux_hrinipag  OR  
                                            TIME > aux_hrfimpag  THEN
                                            1  /** Estourou limite de horario **/
                                        ELSE
                                            2  /** Dentro do horario limite   **/
                   tt-limite.flsgproc = aux_flsgproc
                   tt-limite.qtmesagd = aux_qtmesagd
                   tt-limite.idtpdpag = 2.
        END.
     
    IF  par_tpoperac = 0 OR par_tpoperac = 3  THEN /** Cobranca **/
        DO:
            /** Verifica horario inicial e final para geracao de cobranca **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 00           AND
                               craptab.cdacesso = "HRCOBRANCA" AND
                               craptab.tpregist = par_cdagenci
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craptab  THEN
                DO:
                    par_dscritic = "Tabela (HRCOBRANCA) nao cadastrada.".
                    RETURN "NOK".
                END.

            /** Horario diferenciado para finais de semana e feriados **/
            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                DO:
                     ASSIGN aux_hrinipag = INTE(SUBSTR(craptab.dstextab,6,6))
                            aux_hrfimpag = INTE(SUBSTR(craptab.dstextab,1,5)).

                    CREATE tt-limite.
                    ASSIGN tt-limite.idtpdpag = 3
                           tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                           tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                           tt-limite.nrhorini = aux_hrinipag
                           tt-limite.nrhorfim = aux_hrfimpag
                           tt-limite.idesthor = 1.  /** Estourou lim. de hor. **/
                END.
            ELSE
                DO:
                    ASSIGN aux_hrinipag = INTE(SUBSTR(craptab.dstextab,6,6))
                           aux_hrfimpag = INTE(SUBSTR(craptab.dstextab,1,5)).

                    CREATE tt-limite.
                    ASSIGN tt-limite.idtpdpag = 3
                           tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                           tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                           tt-limite.nrhorini = aux_hrinipag
                           tt-limite.nrhorfim = aux_hrfimpag
                           tt-limite.idesthor = IF  TIME < aux_hrinipag  OR  
                                                    TIME > aux_hrfimpag  THEN
                                                1  /** Estouro lim. hor. **/
                                                ELSE
                                                2. /** Dentro hor. lim.   **/
                END.
        END. 
    
    IF  par_tpoperac = 0 OR par_tpoperac = 4  OR par_tpoperac = 22 THEN /** TED **/ /*REQ39*/
        DO:
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapcop  THEN
                DO:
                    ASSIGN par_dscritic = "Registro de cooperativa nao " +
                                          "encontrado.".
                    RETURN "NOK".
                END.
                  
             /* SD 428886*/ 
            /* valida se ambos os servicos estao desabilitados */
            IF crapcop.flgopstr = false and crapcop.flgoppag = false THEN
              DO:
                ASSIGN par_dscritic = "Cooperativa nao esta operando no SPB.". 
                RETURN "NOK". 
              END.
            ELSE
              DO:

			    /*****
                Por solicitacao do financeiro, iremos apenas verificar se a cooperativa esta operante
                no STR/PAG, sem a necessidade de verificar o horario de operacao. Devera prevalecer o 
                horario da STR, e somente quando este nao estiver ATIVO mostrara horario da PAG.
                Por regra, o STR sempre terá um período maior    
                *****/
			 
                /*-- Operando com mensagens STR --*/
                IF   crapcop.flgopstr THEN
				     ASSIGN aux_hrinipag = crapcop.iniopstr
					        aux_hrfimpag = crapcop.fimopstr.
                     
					 /**
                     IF crapcop.iniopstr <= TIME AND crapcop.fimopstr >= TIME THEN
                        ASSIGN aux_flgutstr = TRUE.
				     **/
			    ELSE
				     DO:
                 /*-- Operando com mensagens PAG --*/
                         IF   crapcop.flgoppag  THEN 
						      ASSIGN aux_hrinipag = crapcop.inioppag
							         aux_hrfimpag = crapcop.fimoppag.

				              /**
                     IF crapcop.inioppag <= TIME AND crapcop.fimoppag >= TIME THEN  
                        ASSIGN aux_flgutpag = TRUE.
				              **/
				     END.
			  END.

            CREATE tt-limite.
            ASSIGN tt-limite.idtpdpag = 4
                   tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                   tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                   tt-limite.nrhorini = aux_hrinipag
                   tt-limite.nrhorfim = aux_hrfimpag.

            IF  TIME < aux_hrinipag  OR  
                TIME > aux_hrfimpag  THEN
                ASSIGN tt-limite.idesthor = 1. /** Estourou lim. de hor. **/ 
            ELSE
                ASSIGN tt-limite.idesthor = 2. /** Dentro do horario limite **/

            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                ASSIGN tt-limite.iddiauti = 2.  /* Nao eh dia util */
            ELSE
                ASSIGN tt-limite.iddiauti = 1.  /* Dia util */
        END.    

        IF  par_tpoperac = 0 OR par_tpoperac = 6  THEN /** VR-Boleto **/
            DO:
                /** Verifica horario inicial e final para geracao de cobranca **/
                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "GENERI"     AND
                                   craptab.cdempres = 00           AND
                                   craptab.cdacesso = "HRVRBOLETO"
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craptab  THEN
                    DO:
                        par_dscritic = "Tabela (HRVRBOLETO) nao cadastrada.".
                        RETURN "NOK".
                    END.

                /** Horario diferenciado para finais de semana e feriados **/
                IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                           crapfer.dtferiad = aux_datdodia) THEN
                    DO:
                         ASSIGN aux_hrinipag = INTE(ENTRY(2,craptab.dstextab,";"))
                                aux_hrfimpag = INTE(ENTRY(3,craptab.dstextab,";")).

                        CREATE tt-limite.
                        ASSIGN tt-limite.idtpdpag = 6
                               tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                               tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                               tt-limite.nrhorini = aux_hrinipag
                               tt-limite.nrhorfim = aux_hrfimpag
                               tt-limite.idesthor = 1.  /** Estourou lim. de hor. **/
                    END.
                ELSE
                    DO:
                        ASSIGN aux_hrinipag = INTE(ENTRY(2,craptab.dstextab,";"))
                               aux_hrfimpag = INTE(ENTRY(3,craptab.dstextab,";")).

                        CREATE tt-limite.
                        ASSIGN tt-limite.idtpdpag = 6
                               tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                               tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                               tt-limite.nrhorini = aux_hrinipag
                               tt-limite.nrhorfim = aux_hrfimpag
                               tt-limite.idesthor = IF  TIME < aux_hrinipag  OR  
                                                        TIME > aux_hrfimpag  THEN
                                                    1  /** Estouro lim. hor. **/
                                                    ELSE
                                                    2. /** Dentro hor. lim.   **/
                    END.
            END. 

        IF par_tpoperac = 0 OR par_tpoperac = 11 THEN /** Debito Facil **/
        DO:
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapcop  THEN
                DO:
                    ASSIGN par_dscritic = "Registro de cooperativa nao " +
                                          "encontrado.".
                    RETURN "NOK".
                END.
                  
            ASSIGN aux_hrinipag = crapcop.hriniatr
                   aux_hrfimpag = crapcop.hrfimatr.

            CREATE tt-limite.
            ASSIGN tt-limite.idtpdpag = 11
                   tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                   tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                   tt-limite.nrhorini = aux_hrinipag
                   tt-limite.nrhorfim = aux_hrfimpag.

            IF  TIME < aux_hrinipag  OR  
                TIME > aux_hrfimpag  THEN
                ASSIGN tt-limite.idesthor = 1. /** Estourou lim. de hor. **/ 
            ELSE
                ASSIGN tt-limite.idesthor = 2. /** Dentro do horario limite **/

            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                ASSIGN tt-limite.iddiauti = 2.  /* Nao eh dia util */
            ELSE
                ASSIGN tt-limite.iddiauti = 1.  /* Dia util */
        END.

        IF par_tpoperac = 12 OR   /** Desbloqueio Débito Fácil – Convenio Cecred **/
           par_tpoperac = 13 THEN /** Desbloqueio Débito Fácil – Convenio Sicredi **/
        DO:
         
            IF  par_tpoperac = 12 THEN /* CECRED */
                FIND FIRST craphec WHERE craphec.cdcooper = par_cdcooper AND
                                         craphec.cdprogra = "DEBNET"
                                         NO-LOCK NO-ERROR NO-WAIT.
            ELSE /* SICREDI */
                FIND FIRST craphec WHERE craphec.cdcooper = par_cdcooper AND
                                         craphec.cdprogra = "DEBSIC"
                                         NO-LOCK NO-ERROR NO-WAIT.
                
			/* Exemplo de horários encontrados nestes FINDs (convertidos):
			   DEBNET -> hriniexe = 21:04
			             hrfimexe = 21:30
			   DEBSIC -> hriniexe = 19:01
			             hrfimexe = 19:43 */

            /* Se for SICREDI , reduz 1h do prazo por segurança */      
            ASSIGN aux_hrinipag = IF par_tpoperac = 13 THEN (craphec.hriniexe - 3600) ELSE craphec.hriniexe
                   aux_hrfimpag = craphec.hrfimexe.

            CREATE tt-limite.
            ASSIGN tt-limite.idtpdpag = 11
                   tt-limite.hrinipag = STRING(aux_hrinipag,"HH:MM")
                   tt-limite.hrfimpag = STRING(aux_hrfimpag,"HH:MM")
                   tt-limite.nrhorini = aux_hrinipag
                   tt-limite.nrhorfim = aux_hrfimpag.

			/* Se passou o horário de início de execução do DEBNET / DEBSIC */
            IF  TIME >= aux_hrinipag  THEN
                ASSIGN tt-limite.idesthor = 1. /** Estourou lim. de hor. **/ 
            ELSE
                ASSIGN tt-limite.idesthor = 2. /** Dentro do horario limite **/

            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                       crapfer.dtferiad = aux_datdodia) THEN
                ASSIGN tt-limite.iddiauti = 2.  /* Nao eh dia util */
            ELSE
                ASSIGN tt-limite.iddiauti = 1.  /* Dia util */
        END.

    RETURN "OK".

END.

/******************************************************************************/
/**       Procedure para verificar se cooperativa esta operando no SPB       **/
/******************************************************************************/
PROCEDURE verifica-opera-spb:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.  
                                                                    
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_flgopspb AS LOGI                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Registro de cooperativa nao encontrado.".
            RETURN "NOK".
        END.

    ASSIGN par_flgopspb = FALSE.

    /** Verifica se cooperativa esta operando no SPB (STR ou PAG) **/
    IF  crapcop.flgopstr OR crapcop.flgoppag  THEN
        ASSIGN par_flgopspb = TRUE.

    RETURN "OK".

END.

/******************************************************************************/
/** Procedure para carregar dados para acesso ao cadastro de favorecido      **/
/******************************************************************************/
PROCEDURE acesso-cadastro-favorecidos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-bancos-favorecido.
    DEF OUTPUT PARAM TABLE FOR tt-tp-contas.
    DEF OUTPUT PARAM TABLE FOR tt-autorizacao-favorecido.

    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_nmresbcc LIKE crapban.nmresbcc                      NO-UNDO.
    DEF VAR aux_nmbcoctl LIKE crapban.nmextbcc                      NO-UNDO.
    DEF VAR aux_nmdbanco LIKE crapban.nmextbcc                      NO-UNDO.
    DEF VAR aux_idsequen AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmsegttl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmextttl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmprepos AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-bancos-favorecido.
    EMPTY TEMP-TABLE tt-tp-contas.
    EMPTY TEMP-TABLE tt-autorizacao-favorecido.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Registro de cooperativa nao encontrado.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.


    IF crapass.idastcjt = 0 THEN
        DO:        
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                     crapsnh.nrdconta = par_nrdconta    AND
                                     crapsnh.idseqttl = par_idseqttl    AND
                                     crapsnh.tpdsenha = 1                      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                     crapsnh.nrdconta = par_nrdconta    AND
                                     crapsnh.tpdsenha = 1                      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    
    IF  NOT AVAIL crapsnh  THEN
        DO:
            ASSIGN par_dscritic = "Senha para conta on-line nao cadastrada".
            
            RETURN "NOK".
        END.

    IF  crapass.inpessoa > 1  THEN
        DO:
            
            /* Busca dados preposto apenas quando nao possui assinatura conjunta */
            IF crapass.idastcjt = 0 THEN
							DO:
								FIND crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper AND
																	 crapavt.nrdconta = crapsnh.nrdconta AND
																	 crapavt.tpctrato = 6                AND
																	 crapavt.nrcpfcgc = crapsnh.nrcpfcgc
																	 NO-LOCK NO-ERROR.

								IF  AVAIL crapavt  THEN
										DO:
												FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
																					 crabass.nrdconta = crapavt.nrdctato
																					 NO-LOCK NO-ERROR.
											
												IF  AVAILABLE crabass  THEN
														ASSIGN aux_nmprepos = crabass.nmprimtl.
												ELSE
														ASSIGN aux_nmprepos = crapavt.nmdavali.
										END.
								END.
						ELSE
							DO:
								ASSIGN aux_nmprepos = "".
							END.

            ASSIGN aux_nmprimtl = crapass.nmprimtl
                   aux_nmextttl = crapass.nmprimtl.
        END.
    ELSE
        DO:
            FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta NO-LOCK:

                IF  crapttl.idseqttl = par_idseqttl  THEN
                    ASSIGN aux_nmextttl = crapttl.nmextttl.

                IF  crapttl.idseqttl = 1  THEN
                    ASSIGN aux_nmprimtl = crapttl.nmextttl.
                ELSE
                IF  crapttl.idseqttl = 2  THEN
                    ASSIGN aux_nmsegttl = crapttl.nmextttl.

            END.
        END.

    /* Vamos listar somente os bancos ativos */
    FOR EACH crapban WHERE crapban.flgdispb = TRUE NO-LOCK:
        
        IF  crapban.cdbccxlt = crapcop.cdbcoctl  THEN
            NEXT.

        ASSIGN aux_nmresbcc = REPLACE(CAPS(TRIM(crapban.nmresbcc)),"&","e").
 
        CREATE tt-bancos-favorecido.
        ASSIGN tt-bancos-favorecido.cddbanco = crapban.cdbccxlt
               tt-bancos-favorecido.nmresbcc = aux_nmresbcc
               tt-bancos-favorecido.nrispbif = crapban.nrispbif. 

    END. /** Fim do FOR EACH crapban **/

    IF  NOT TEMP-TABLE tt-bancos-favorecido:HAS-RECORDS  THEN
        DO:
            ASSIGN par_dscritic = "Bancos nao cadastrados.".
            RETURN "NOK".
        END.

    RUN consulta-tipos-contas (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               OUTPUT TABLE tt-tp-contas,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                ASSIGN par_dscritic = tt-erro.dscritic.

            RETURN "NOK".
        END.

    ASSIGN aux_idsequen = 0.

    IF  par_nrcpfope > 0  THEN
        DO:
            FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                               crapopi.nrdconta = par_nrdconta AND
                               crapopi.nrcpfope = par_nrcpfope NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapopi  THEN
                DO:
                    ASSIGN par_dscritic = "Operador nao cadastrado.".
                    RETURN "NOK".
                END.
        END.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = 90
                       NO-LOCK NO-ERROR.

    /** Consultar contas ainda pendentes e que nao foram removidos pelo usuario **/
    FOR EACH crapcti WHERE crapcti.cdcooper = par_cdcooper AND
                           crapcti.nrdconta = par_nrdconta AND
                           crapcti.insitcta = 1            AND
                           crapcti.insitfav <> 3           NO-LOCK: /* Registro Desativado */

        ASSIGN aux_idsequen = aux_idsequen + 1
               aux_nmbcoctl = ""
               aux_nmdbanco = "".

        FIND crapban WHERE crapban.cdbccxlt = crapcop.cdbcoctl NO-LOCK NO-ERROR.

        IF  AVAIL crapban  THEN
            ASSIGN aux_nmbcoctl = crapban.nmextbcc.

        IF crapcti.nrispbif = 0 THEN
            FIND crapban WHERE crapban.cdbccxlt = crapcti.cddbanco NO-LOCK NO-ERROR.
        ELSE
            FIND crapban WHERE crapban.nrispbif = crapcti.nrispbif NO-LOCK NO-ERROR.

        IF  AVAIL crapban  THEN
            ASSIGN aux_nmdbanco = REPLACE(CAPS(TRIM(crapban.nmextbcc)),"&","e").
            
        CREATE tt-autorizacao-favorecido.
        ASSIGN tt-autorizacao-favorecido.nmextcop = crapcop.nmextcop
               tt-autorizacao-favorecido.nmrescop = crapcop.nmrescop
               tt-autorizacao-favorecido.cdbcoctl = crapcop.cdbcoctl
               tt-autorizacao-favorecido.nmbcoctl = aux_nmbcoctl
               tt-autorizacao-favorecido.cdagectl = crapcop.cdagectl
               tt-autorizacao-favorecido.dttransa = crapcti.dttransa
               tt-autorizacao-favorecido.hrtransa = crapcti.hrtransa
               tt-autorizacao-favorecido.nrdconta = crapass.nrdconta
               tt-autorizacao-favorecido.nmextttl = aux_nmextttl
               tt-autorizacao-favorecido.nmprimtl = aux_nmprimtl
               tt-autorizacao-favorecido.nmsegttl = aux_nmsegttl
               tt-autorizacao-favorecido.cddbanco = crapcti.cddbanco
               tt-autorizacao-favorecido.nmdbanco = aux_nmdbanco
               tt-autorizacao-favorecido.cdageban = crapcti.cdageban
               tt-autorizacao-favorecido.nrctatrf = crapcti.nrctatrf
               tt-autorizacao-favorecido.nmtitula = crapcti.nmtitula
               tt-autorizacao-favorecido.dsprotoc = crapcti.dsprotoc
               tt-autorizacao-favorecido.nrtelfax = IF NOT AVAIL crapage OR
                                                       crapage.nrtelfax = ""
                                                    THEN crapcop.nrtelfax
                                                    ELSE crapage.nrtelfax
               tt-autorizacao-favorecido.dsdemail = IF NOT AVAIL crapage OR
                                                       crapage.dsdemail = ""
                                                    THEN crapcop.dsdemail
                                                    ELSE crapage.dsdemail
               tt-autorizacao-favorecido.nmopecad = IF par_nrcpfope > 0
                                                    THEN crapopi.nmoperad
                                                    ELSE
                                                    IF crapass.inpessoa > 1 AND
                                                       aux_nmprepos <> ""
                                                    THEN aux_nmprepos
                                                    ELSE aux_nmextttl
               tt-autorizacao-favorecido.idsequen = aux_idsequen
               tt-autorizacao-favorecido.intipcta = crapcti.intipcta
               tt-autorizacao-favorecido.inpessoa = crapcti.inpessoa
               tt-autorizacao-favorecido.nrcpfcgc = crapcti.nrcpfcgc
               tt-autorizacao-favorecido.nrispbif = crapcti.nrispbif
               tt-autorizacao-favorecido.indrecid = RECID(crapcti).

    END. /** Fim do FOR EACH crapcti **/

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
/******************************************************************************/
PROCEDURE verifica_operacao:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_idagenda AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopg LIKE craplau.dtmvtopg             NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdageban LIKE crapcti.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_cdtiptra AS INTE                           NO-UNDO.
    /* 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED / 22 - TED JUDICIAL*/ /*REQ39*/
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_tpoperac AS INTE                           NO-UNDO.
    /* 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */
    /* 4 - TED / 5 - Transferencia intercooperativa / 6 - VR Boleto */
    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplau.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_flgctrag AS LOGICAL                        NO-UNDO.
    /* Flag 'flgctrag' controla validacoes na efetivacao de agendamentos */
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-limite.
    DEF OUTPUT PARAM TABLE FOR tt-limites-internet.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_vlsldisp AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdiauti AS DATE                                    NO-UNDO.
    DEF VAR aux_dtdialim AS DATE                                    NO-UNDO.
    DEF VAR aux_dtiniper AS DATE                                    NO-UNDO.
    DEF VAR aux_dtfimper AS DATE                                    NO-UNDO.
    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1crap20   AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1crap22   AS HANDLE                                  NO-UNDO.

    DEF VAR aux_idttlope LIKE crapttl.idseqttl                      NO-UNDO.
    DEF VAR aux_vldspptl LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_vldspttl LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_vllimptl LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_vllimttl LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_vllimcop LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_flgctafa AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmtitula AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmtitul2 AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabcop FOR crapcop.
        
    EMPTY TEMP-TABLE tt-limite.
    EMPTY TEMP-TABLE tt-limites-internet.

    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
    DEF VAR aux_cont      AS INTEGER  NO-UNDO.

    /** Monta descricao da transacao **/
    ASSIGN par_dstransa = "Validar ".
    
    IF  par_idagenda = 2  OR   /** Agendamento            **/
        par_idagenda = 3  THEN /** Agendamento Recorrente **/
        ASSIGN par_dstransa = par_dstransa + "Agendamento de ".
    
    IF  par_tpoperac = 1  THEN /** Operacao de Transferencia **/
        DO:
            IF  par_cdtiptra = 1  THEN
                ASSIGN par_dstransa = par_dstransa + "Transferencia de Valores".
            ELSE
            IF  par_cdtiptra = 3  THEN
                ASSIGN par_dstransa = par_dstransa + "Credito de Salario". 
        END.    
    ELSE
    IF  par_tpoperac = 4 OR par_tpoperac = 22 THEN /*REQ39*/
        ASSIGN par_dstransa = par_dstransa + "TED".
    ELSE
    IF  par_tpoperac = 2  THEN /** Operacao de Pagamento **/
        ASSIGN par_dstransa = par_dstransa + "Pagamento de Titulos e Faturas".
    ELSE
    IF  par_tpoperac = 5  THEN
        ASSIGN par_dstransa = par_dstransa + "Transferencia Intercooperativa".
        ELSE
    IF  par_tpoperac = 6  THEN /** Operacao de Pagamento VR-Boleto **/
        ASSIGN par_dstransa = par_dstransa + "Pagamento de VR-Boletos ".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Registro de cooperativa nao encontrado.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag Root em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag horario em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag horario */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

	{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    /* Procedure para verificar horario permitido para transacoes (inet0001)*/
    RUN STORED-PROCEDURE pc_horario_operacao_prog
    aux_handproc = PROC-HANDLE NO-ERROR      
    (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_tpoperac,
                          INPUT crapass.inpessoa,
     OUTPUT "", 
     OUTPUT 0,
     OUTPUT "").

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_horario_operacao_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

	{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
	ASSIGN xml_req      = pc_horario_operacao_prog.pr_tab_limite
			aux_cdcritic = pc_horario_operacao_prog.pr_cdcritic 
								WHEN pc_horario_operacao_prog.pr_cdcritic <> ?
			aux_dscritic = pc_horario_operacao_prog.pr_dscritic
								WHEN pc_horario_operacao_prog.pr_dscritic <> ?. 
    
	IF aux_cdcritic <> 0  OR 
		aux_dscritic <> "" THEN
		DO: 
			IF aux_dscritic = "" THEN
				ASSIGN aux_dscritic =  "Nao foi possivel verificar o horario.".
    
			ASSIGN par_dscritic = aux_dscritic.
    
        RETURN "NOK".
		END.
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    IF ponteiro_xml <> ? THEN
    DO:
      xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
      xDoc:GET-DOCUMENT-ELEMENT(xRoot).

      DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

        IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 

        IF xRoot2:NUM-CHILDREN > 0 THEN               
        CREATE tt-limite.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
          xRoot2:GET-CHILD(xField,aux_cont).

          IF xField:SUBTYPE <> "ELEMENT" THEN 
             NEXT.

		  xField:GET-CHILD(xText,1) NO-ERROR.

		  /* Se nao vier conteudo na TAG */
          IF ERROR-STATUS:ERROR             OR
             ERROR-STATUS:NUM-MESSAGES > 0  THEN
             NEXT.
    
          ASSIGN tt-limite.hrinipag = STRING(xText:NODE-VALUE) WHEN xField:NAME = "hrinipag"
                 tt-limite.hrfimpag = STRING(xText:NODE-VALUE) WHEN xField:NAME = "hrfimpag"
                 tt-limite.nrhorini = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrhorini"
                 tt-limite.nrhorfim = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrhorfim"
                 tt-limite.idesthor = INTE(xText:NODE-VALUE) WHEN xField:NAME = "idesthor"
                 tt-limite.flsgproc = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flsgproc"
                 tt-limite.qtmesagd = INTE(xText:NODE-VALUE) WHEN xField:NAME = "qtmesagd"
                 tt-limite.idtpdpag = INTE(xText:NODE-VALUE) WHEN xField:NAME = "idtpdpag"
                 tt-limite.iddiauti = INTE(xText:NODE-VALUE) WHEN xField:NAME = "iddiauti".

        END.
      END.      

      SET-SIZE(ponteiro_xml) = 0.     
	   
    END.
	
	/* Elimina objetos para leitura do XML */ 
	DELETE OBJECT xDoc.    /* Vai conter o XML completo */ 
	DELETE OBJECT xRoot.   /* Vai conter a tag Root em diante */ 
	DELETE OBJECT xRoot2.  /* Vai conter a tag horario em diante */ 
	DELETE OBJECT xField.  /* Vai conter os campos dentro da tag horario */ 
	DELETE OBJECT xText.   /* Vai conter o texto que existe dentro da tag xField */

    

    /* Conta que exige assinatura conjunta nao possui primeiro titular  */
    /* Necessario obter o sequencial do primeiro representante legal    */
    /* Operacoes realizadas por operador de conta PJ utilizam titular 1 */
    ASSIGN aux_idttlope = par_idseqttl.
    IF  crapass.idastcjt = 1 AND par_idseqttl = 1  THEN 
        FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                crapsnh.nrdconta = par_nrdconta AND
                                crapsnh.tpdsenha = 1            AND
                                crapsnh.cdsitsnh = 1            
                                NO-LOCK: 
            ASSIGN aux_idttlope = crapsnh.idseqttl.
        END.

    RUN busca_limites (INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT aux_idttlope,
                       INPUT TRUE,
                       INPUT par_dtmvtopg,
                       INPUT par_flgctrag,
                       INPUT par_dsorigem,
                      OUTPUT par_dscritic,
                      OUTPUT TABLE tt-limites-internet).

    IF  RETURN-VALUE <> "OK"  THEN
        RETURN "NOK".
     
    /** Obtem limites do titular **/
    FIND tt-limites-internet WHERE tt-limites-internet.idseqttl = aux_idttlope
                                   NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-limites-internet  THEN
        DO:
            ASSIGN par_dscritic = "Registro de limite nao encontrado.".
            RETURN "NOK".
        END.
    
    IF  par_tpoperac = 6 THEN
        ASSIGN aux_vldspptl = tt-limites-internet.vllimvrb
               aux_vllimttl = tt-limites-internet.vllimvrb
               aux_vllimptl = tt-limites-internet.vllimvrb
               aux_vllimcop = tt-limites-internet.vlvrbcop.
        ELSE
    IF  par_tpoperac = 4 OR par_tpoperac = 22  THEN /* TED */ /*REQ39*/
        ASSIGN aux_vldspptl = tt-limites-internet.vldspted
               aux_vldspttl = tt-limites-internet.vldspted
               aux_vllimptl = tt-limites-internet.vllimted
               aux_vllimttl = tt-limites-internet.vllimted
               aux_vllimcop = tt-limites-internet.vltedcop.
    ELSE
    IF  crapass.inpessoa = 1   THEN
        ASSIGN aux_vldspptl = tt-limites-internet.vldspweb
               aux_vldspttl = tt-limites-internet.vldspweb
               aux_vllimptl = tt-limites-internet.vllimweb
               aux_vllimttl = tt-limites-internet.vllimweb
               aux_vllimcop = tt-limites-internet.vlwebcop.
    ELSE
    IF  crapass.inpessoa > 1   THEN
        DO:
            IF  par_tpoperac = 2  THEN
                ASSIGN aux_vldspptl = tt-limites-internet.vldsppgo
                       aux_vldspttl = tt-limites-internet.vldsppgo
                       aux_vllimptl = tt-limites-internet.vllimpgo
                       aux_vllimttl = tt-limites-internet.vllimpgo
                       aux_vllimcop = tt-limites-internet.vlpgocop.
            ELSE
                ASSIGN aux_vldspptl = tt-limites-internet.vldsptrf
                       aux_vldspttl = tt-limites-internet.vldsptrf
                       aux_vllimptl = tt-limites-internet.vllimtrf
                       aux_vllimttl = tt-limites-internet.vllimtrf
                       aux_vllimcop = tt-limites-internet.vltrfcop.
        END.
          
    IF  aux_vllimcop = 0  THEN
        DO:
            ASSIGN par_dscritic = "Este servico nao esta habilitado. " +
                                  "Duvidas entre em contato com a cooperativa.".
            RETURN "NOK".
        END.

    /** Obtem limites do primeiro titular se for pessoa fisica **/
    IF  crapass.inpessoa = 1 AND par_idseqttl > 1  THEN
        DO:
            FIND tt-limites-internet WHERE tt-limites-internet.idseqttl = 1
                                           NO-LOCK NO-ERROR.
        
            IF  NOT AVAIL tt-limites-internet  THEN
                DO:
                    ASSIGN par_dscritic = "Limite para internet nao cadastrado."
                                          + "\nEntre em contato com seu PA.".
                    RETURN "NOK".
                END.

                    IF  par_tpoperac = 6 THEN /* VR Boleto */
                ASSIGN aux_vllimptl = tt-limites-internet.vllimvrb.
                        ELSE                
            IF  par_tpoperac = 4 OR par_tpoperac = 22 THEN /* TED */ /*REQ39*/
                ASSIGN aux_vldspptl = tt-limites-internet.vldspted
                       aux_vllimptl = tt-limites-internet.vllimted.
            ELSE
            IF  crapass.inpessoa = 1   THEN
                ASSIGN aux_vldspptl = tt-limites-internet.vldspweb
                       aux_vllimptl = tt-limites-internet.vllimweb.
            ELSE
            IF  crapass.inpessoa > 1   THEN
                DO:
                    IF  par_tpoperac = 2  THEN
                        ASSIGN aux_vldspptl = tt-limites-internet.vldsppgo
                               aux_vllimptl = tt-limites-internet.vllimpgo.
                    ELSE
                        ASSIGN aux_vldspptl = tt-limites-internet.vldsptrf
                               aux_vllimptl = tt-limites-internet.vllimtrf.
                END.    
        END.

    IF  aux_vllimptl = 0  THEN
        DO:
            ASSIGN par_dscritic = "Limite para internet nao cadastrado.\n" +
                                  "Entre em contato com seu PA.".
            RETURN "NOK".
        END.

    IF  aux_vllimttl = 0  THEN
        DO:
            ASSIGN par_dscritic = "Limite para internet nao cadastrado.\n" +
                                  "Entre em contato com seu PA.".
            RETURN "NOK".
        END.

    /** Verifica limites necessarios para efetuar a operacao **/
    IF  NOT par_flgvalid  THEN
        RETURN "OK".

    /** Verificar se a conta pertence a um PAC migrado **/
    FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                       craptco.nrctaant = par_nrdconta AND
                       craptco.tpctatrf = 1           
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptco  AND 
        par_idagenda >= 2  THEN  /** Agendamento **/
        DO:
            /** Bloquear agendamentos para conta migrada **/
            IF  aux_datdodia >= 12/25/2013  AND
                craptco.cdcopant <> 4       AND  /* Exceto Concredi    */
                craptco.cdcopant <> 15      AND  /* Exceto Credimilsul */
                craptco.cdcopant <> 17      THEN /* Exceto Transulcred */
                DO:                                                  
                    ASSIGN par_dscritic = "Operacao de agendamento bloqueada." +
                                          " Entre em contato com seu PA.".
                    RETURN "NOK".                                      
                END.
        END.
    
    FIND FIRST tt-limite NO-LOCK NO-ERROR.
            
    IF  NOT AVAILABLE tt-limite  THEN
        DO:
            ASSIGN par_dscritic = "Tabela de limites nao encontrada.".
            RETURN "NOK".
        END.
                
    /** Validar horario para pagamento **/
    IF  par_flgctrag               AND  
        par_idagenda = 1           AND  /** Pagamento na data  **/
        tt-limite.idesthor = 1     THEN /** Estourou horario   **/
        DO:
            ASSIGN par_dscritic = "Horario esgotado para " +
                                 (IF  par_tpoperac = 1 OR 
                                      par_tpoperac = 5 THEN
                                      "transferencias."
                                  ELSE
                                  IF  par_tpoperac = 4 OR par_tpoperac = 22 THEN /*REQ39*/
                                      "envio de TED."
                                  ELSE
                                      "pagamentos.").
            RETURN "NOK".
        END.
        
    /** Ultimo dia util do ano da data do pagamento/agendamento **/
    ASSIGN aux_dtdialim = IF  par_idagenda = 1  THEN
                              DATE(12,31,YEAR(aux_datdodia))
                          ELSE
                              DATE(12,31,YEAR(par_dtmvtopg)).
     
    RUN retorna-dia-util (INPUT par_cdcooper,
                          INPUT FALSE, /** Feriado  **/
                          INPUT TRUE,  /** Anterior **/
                          INPUT-OUTPUT aux_dtdialim).
    IF  par_tpoperac = 1  OR    /** Transferencia **/
        par_tpoperac = 5  OR    /* Transf. Intercooperativa */
        par_tpoperac = 4  OR par_tpoperac = 22  THEN  /** TED **/ /*REQ39*/
        DO:
            /** Data do agendamento nao pode ser o ultimo dia util do ano **/
            IF (CAN-DO("1,5",STRING(par_tpoperac)) AND  
                par_idagenda = 2)                  AND /** Agendamento **/
                par_dtmvtopg = aux_dtdialim        THEN
                DO:
                    ASSIGN par_dscritic = "Nao e' possivel efetuar " +
                                          "agendamentos para este dia.".
                    RETURN "NOK".
                END.

            IF  (par_tpoperac = 4 OR par_tpoperac = 22) /*REQ39*/      AND 
                tt-limite.iddiauti = 2  AND
               (DAY(aux_dtdialim) <> 31 AND MONTH(aux_dtdialim) <> 12)  THEN
                DO: 
                    ASSIGN par_dscritic = "O envio de TED deve ser efetuado " +
                                          "em dias uteis.".
                    RETURN "NOK".
                END.
                    
            IF   par_tpoperac = 1    OR   /** Transferencia **/
                 par_tpoperac = 5    THEN /** Transf. intercop. **/
                 DO:  
                     RUN valida-conta-destino (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_cdageban,
                                               INPUT par_nrctatrf,
                                               INPUT par_dtmvtolt,
                                               INPUT par_cdtiptra,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT aux_flgctafa,
                                              OUTPUT aux_nmtitula,
                                              OUTPUT aux_nmtitul2,
                                              OUTPUT par_cddbanco).             
                     
                     IF   RETURN-VALUE <> "OK"   THEN
                          DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                              IF   AVAIL tt-erro   THEN
                                   ASSIGN par_dscritic = tt-erro.dscritic.
                              ELSE
                                   ASSIGN par_dscritic = 
                                       "Erro na validacao da conta destino.".
                 
                              RETURN "NOK".
                          END.                        

                     FIND FIRST crabcop WHERE crabcop.cdagectl = par_cdageban
                                        NO-LOCK NO-ERROR.

                     IF  NOT AVAIL crabcop  THEN
                         DO:
                             ASSIGN par_dscritic = "Problema ao consultar " +
                                                   "agencia destino.".
                             RETURN "NOK".
                         END.
                     
                     IF  par_tpoperac = 1                   AND 
                        (par_cdcooper <> crabcop.cdcooper)  THEN
                         DO:
                             ASSIGN par_dscritic = "Cooperativa destino diferente " +
                                                   "do esperado.".
                             RETURN "NOK".
                         END.

                     /* Nao permitir transf. intercooperativa para
                        contas da Concredi e Credimilsul, durante
                        e apos a migracao */
                     IF  par_tpoperac  = 5           AND
                         aux_datdodia >= 11/29/2014  AND
                        (crabcop.cdcooper = 4        OR 
                         crabcop.cdcooper = 15)      THEN
                         DO:
                             FIND craptco WHERE craptco.cdcooper = crabcop.cdcooper AND
                                                craptco.nrdconta = par_nrctatrf     AND
                                                craptco.tpctatrf = 1            
                                                NO-LOCK NO-ERROR.

                             IF  AVAIL craptco  THEN
                                 DO: 
                                     ASSIGN par_dscritic = "Conta destino nao habilitada " +
                                                           "para receber valores da " +
                                                           "transferencia.".
                                     RETURN "NOK".
                                 END.
                         END.
                        
                     /* Nao permitir transf. intercooperativa para
                        contas da Transulcred, durante
                        e apos a migracao */
                     IF  par_tpoperac     = 5           AND
                         aux_datdodia    >= 12/31/2016  AND
                         crabcop.cdcooper = 17          THEN                         
                         DO:
                             ASSIGN par_dscritic = "Conta destino nao habilitada " +
                                                   "para receber valores da " +
                                                   "transferencia.".
                             RETURN "NOK".
                         END.
                 END.      
            ELSE        /* TED */
                 DO:
                     /** Verifica se a conta que ira receber o valor esta   **/
                    /** cadastrada para a conta que ira transferir o valor **/
                    FIND crapcti WHERE crapcti.cdcooper = par_cdcooper AND
                                       crapcti.cddbanco = par_cddbanco AND
                                       crapcti.cdageban = par_cdageban AND
                                       crapcti.nrdconta = par_nrdconta AND
                                       crapcti.nrctatrf = par_nrctatrf NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE crapcti  AND crapcti.insitcta <> 2  THEN  /** Ativa **/
                        DO: 
                            ASSIGN par_dscritic = "Conta destino nao habilitada " +
                                                  "para receber valores da " +
                                                  "transferencia.".
                            RETURN "NOK".
                        END.               
                 END.
    END.
    ELSE
    IF  par_tpoperac = 2  THEN  /** Pagamento **/
        DO:
            /** Critica se data do pagamento for no ultimo dia util do ano **/
            IF (par_idagenda = 1             AND
                par_dtmvtolt = aux_dtdialim) OR
               (par_idagenda > 1             AND
                par_dtmvtopg = aux_dtdialim) THEN
                DO:
                    ASSIGN par_dscritic = "Nao e' possivel efetuar " +
                                         (IF  par_idagenda = 1  THEN
                                              "pagamentos neste dia."
                                          ELSE
                                              "agendamentos para este dia").
                    RETURN "NOK".
                END.
        END. 

        IF  par_vllanmto = 0   THEN
        DO:
            ASSIGN par_dscritic = "O valor da transacao nao pode ser 0 (zero).". 
            RETURN "NOK".
        END.
    
    /** Verifica se pode movimentar o valor desejado - limite diario **/
    IF  par_vllanmto > aux_vllimptl  THEN
        DO:
            ASSIGN par_dscritic = "O saldo do seu limite diario e' " +
                                  "insuficiente para esse pagamento.". 
            RETURN "NOK".
        END.

    IF  par_vllanmto > aux_vllimcop AND 
        par_tpoperac = 6 THEN
        DO:
            ASSIGN par_dscritic = "Valor da operacao superior ao limite " + 
                                  "da cooperativa.".
            RETURN "NOK".
        END.
    
    /** Verifica se titular tem limite para movimentar o valor **/
    IF  crapass.inpessoa = 1         AND 
        par_idseqttl > 1             AND 
        par_vllanmto > aux_vllimttl  THEN
        DO:
            ASSIGN par_dscritic = "O saldo do seu limite diario e' " +
                                  "insuficiente para esse pagamento.".
            RETURN "NOK".
        END.
         
    /** Verifica se pode movimentar em relacao ao que ja foi usado **/
    /** no dia por todos os titulares                              **/
    IF  par_vllanmto > aux_vldspptl  THEN
        DO:
            ASSIGN par_dscritic = "O saldo do seu limite diario e' " +
                                  "insuficiente para esse pagamento.".
            RETURN "NOK".
        END.

    /** Verifica se pode movimentar em relacao ao que ja foi usado **/
    /** no dia pelo titular                                        **/
    IF  crapass.inpessoa = 1         AND  
        par_idseqttl > 1             AND 
        par_vllanmto > aux_vldspttl  THEN
        DO:
            ASSIGN par_dscritic = "O saldo do seu limite diario e' " +
                                  "insuficiente para esse pagamento.".
            RETURN "NOK".
        END.
        
    IF  par_idagenda = 1  THEN 
        DO:
            /* Nao validar saldo para operadores na internet */
            IF  par_nrcpfope = 0  THEN
                DO:

                    TRANS_SALDO:
                    DO TRANSACTION ON ERROR UNDO, LEAVE:
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
                        /* Utilizar o tipo de busca A, para carregar do dia anterior
                          (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
                        RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                            aux_handproc = PROC-HANDLE NO-ERROR
                                                    (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad, 
                                                     INPUT par_nrdconta,
                                                     INPUT aux_datdodia,
                                                     INPUT "A", /* Tipo Busca */
                                                     OUTPUT 0,
                                                     OUTPUT "").
    
                        CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                                  WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                               aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                                  WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
    
                        IF aux_cdcritic <> 0  OR 
                           aux_dscritic <> "" THEN
                           DO: 
                               IF  aux_dscritic = "" THEN
                                   ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".
    
                               ASSIGN par_dscritic = aux_dscritic.
    
                               RETURN "NOK".
                           END.
    
                        FIND FIRST wt_saldos NO-LOCK NO-ERROR.
                        IF NOT AVAIL wt_saldos THEN
                        DO:
                            ASSIGN par_dscritic = "Nao foi possivel consultar" +
                                                  " o saldo para a operacao.".
                            RETURN "NOK".                      
                        END.

                        ASSIGN aux_vlsldisp = wt_saldos.vlsddisp + 
                                              wt_saldos.vllimcre.

                        IF  par_vllanmto > aux_vlsldisp  THEN
                        DO:
                            ASSIGN par_dscritic = "Nao ha saldo suficiente " +
                                                  "para a operacao.".
                            RETURN "NOK".
                        END.
                    END. 

                    /** Obtem valor da tarifa TED **/
                    IF  par_tpoperac = 4 OR par_tpoperac = 22 THEN /*REQ39*/
                        DO: 
                            RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.

                            RUN busca-tarifa-ted IN h-b1crap20 
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci, /* Projeto 363 - Novo ATM -> estava fixo 90 */ 
                                   INPUT par_nrdconta,
                                   INPUT par_vllanmto,
                                  OUTPUT aux_vltarifa,
                                  OUTPUT aux_cdhistor,
                                  OUTPUT aux_cdhisest,
                                  OUTPUT aux_cdfvlcop,
                                  OUTPUT par_dscritic).
                            
                            DELETE PROCEDURE h-b1crap20.

                            IF  RETURN-VALUE <> "OK"  THEN
                                RETURN "NOK".

                            ASSIGN par_vllanmto = par_vllanmto + aux_vltarifa.
                            
                        END.
                    ELSE
                    IF  par_tpoperac = 5  THEN /** Tarifa Transf.Intercoop. **/
                        DO:
                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                            RUN tarifa-transf-intercooperativa IN h-b1crap22 
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci, /* Projeto 363 - Novo ATM -> estava fixo 90 */ 
                                   INPUT par_nrdconta,
                                   INPUT par_vllanmto,
                                  OUTPUT aux_vltarifa,
                                  OUTPUT aux_cdhistor,
                                  OUTPUT aux_cdhisest,
                                  OUTPUT aux_cdfvlcop,
                                  OUTPUT par_dscritic).
                            
                            DELETE PROCEDURE h-b1crap22.
        
                            IF  RETURN-VALUE <> "OK"  THEN
                                RETURN "NOK".

                            ASSIGN par_vllanmto = par_vllanmto + aux_vltarifa.
                        END.
                    
                    IF  par_vllanmto > aux_vlsldisp  THEN
                        DO:
                            ASSIGN par_dscritic = "Saldo insuficiente para " +
                                                  "debito da tarifa.".
                            RETURN "NOK".
                        END.
                END.
        END.    
    ELSE
    DO:
    IF  par_idagenda >= 2  THEN /** Agendamento normal e recorrente **/ 
        DO:
            /** Verifica se data de debito e uma data futura **/
            IF  par_dtmvtopg <= aux_datdodia  THEN
                DO:
                    ASSIGN par_dscritic = "Agendamento deve ser " +
                                          "feito para uma data futura.".
                    RETURN "NOK".
                END.

            IF  par_idagenda = 2  THEN /** Agendamento normal **/
                DO:
                    IF  NOT tt-limite.flsgproc                       AND
                       (CAN-DO("1,7",STRING(WEEKDAY(aux_datdodia)))  OR   
                        CAN-FIND(crapfer WHERE 
                                 crapfer.cdcooper = par_cdcooper     AND
                                 crapfer.dtferiad = aux_datdodia))   AND
                        par_dtmvtopg = par_dtmvtolt                  THEN
                        DO:
                            ASSIGN aux_dtdialim = par_dtmvtolt + 1.
        
                            RUN retorna-dia-util (INPUT par_cdcooper,
                                                  INPUT TRUE,  /** Feriado **/
                                                  INPUT FALSE, /** Proxima **/
                                                  INPUT-OUTPUT aux_dtdialim).
                                    
                            ASSIGN par_dscritic = "A data minima para efetuar" +
                                       " agendamento e " +
                                       STRING(aux_dtdialim,"99/99/9999") + ".".
                            RETURN "NOK".
                        END.
        
                    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                                       crapage.cdagenci = par_cdagenci
                                       NO-LOCK NO-ERROR.
                                               
                    IF  NOT AVAILABLE crapage  THEN
                        DO:
                            ASSIGN par_dscritic = "PA nao cadastrado.".
                            RETURN "NOK".
                        END.
        
                    ASSIGN aux_dtdialim = aux_datdodia + crapage.qtddaglf. 
                            
                    IF  par_dtmvtopg > aux_dtdialim  THEN
                        DO:
                            RUN retorna-dia-util (INPUT par_cdcooper,
                                                  INPUT TRUE, /** Feriado  **/
                                                  INPUT TRUE, /** Anterior **/
                                                  INPUT-OUTPUT aux_dtdialim).
        
                            ASSIGN par_dscritic = "A data limite para efetuar" +
                                                  " agendamentos e " +
                                                  STRING(aux_dtdialim,"99/99/9999") +
                                                  ".".
                            RETURN "NOK".                      
                        END.
                END.
        END. 
    END.
                     

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_limites:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flglimdp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopg AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctrag AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigem AS CHAR                           NO-UNDO.
                                                                  
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-limites-internet.
    
    DEF VAR aux_vlutlweb LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR aux_vlutltrf LIKE crapsnh.vllimtrf                      NO-UNDO.
    DEF VAR aux_vlutlpgo LIKE crapsnh.vllimpgo                      NO-UNDO.
    DEF VAR aux_vlutlted LIKE crapsnh.vllimted                      NO-UNDO.
    DEF VAR aux_vlutlvrb LIKE crapsnh.vllimvrb                      NO-UNDO.

    DEF VAR tab_vllimweb LIKE crapsnh.vllimweb                      NO-UNDO.
    DEF VAR tab_vllimtrf LIKE crapsnh.vllimtrf                      NO-UNDO.
    DEF VAR tab_vllimpgo LIKE crapsnh.vllimpgo                      NO-UNDO.
    DEF VAR tab_vllimted LIKE crapsnh.vllimted                      NO-UNDO.
    DEF VAR tab_vllimvrb LIKE crapsnh.vllimvrb                      NO-UNDO.

    DEF BUFFER bb-limites-internet FOR tt-limites-internet.

    EMPTY TEMP-TABLE tt-limites-internet.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    /** Obtem limites da cooperativa **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "LIMINTERNT" AND
                       craptab.tpregist = IF crapass.inpessoa > 1 THEN 2 ELSE 1
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab  THEN
        DO:
            ASSIGN par_dscritic = "Tabela 'LIMINTERNT' nao cadastrada.".
            RETURN "NOK".
        END.

    ASSIGN tab_vllimweb = 0
           tab_vllimtrf = 0
           tab_vllimpgo = 0
           tab_vllimted = 0
           tab_vllimvrb = 0.

    IF  craptab.tpregist = 1  THEN  /** Pessoa fisica **/
        ASSIGN tab_vllimweb = DECI(ENTRY(01,craptab.dstextab,";"))
               tab_vllimted = DECI(ENTRY(13,craptab.dstextab,";"))
               tab_vllimvrb = DECI(ENTRY(15,craptab.dstextab,";")). 
        
    ELSE  /** Pessoa Juridica **/
        ASSIGN tab_vllimtrf = DECI(ENTRY(01,craptab.dstextab,";"))
               tab_vllimpgo = DECI(ENTRY(06,craptab.dstextab,";"))
               tab_vllimted = DECI(ENTRY(13,craptab.dstextab,";"))
               tab_vllimvrb = DECI(ENTRY(16,craptab.dstextab,";")). 
                       
    /** Valor limite para operacoes do titular **/
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.tpdsenha = 1            AND 
                       crapsnh.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
                      
    CREATE tt-limites-internet.
    ASSIGN tt-limites-internet.idseqttl = crapsnh.idseqttl
           tt-limites-internet.vlwebcop = tab_vllimweb
           tt-limites-internet.vlpgocop = tab_vllimpgo
           tt-limites-internet.vltrfcop = tab_vllimtrf
           tt-limites-internet.vltedcop = tab_vllimted
           tt-limites-internet.vllimweb = IF NOT AVAIL crapsnh  THEN 
                                             0
                                          /*ELSE
                                          IF crapsnh.vllimweb > tab_vllimweb THEN
                                             tab_vllimweb*/
                                          ELSE
                                             crapsnh.vllimweb 
           tt-limites-internet.vllimpgo = IF NOT AVAIL crapsnh  THEN 
                                             0
                                          /*ELSE
                                          IF crapsnh.vllimpgo > tab_vllimpgo THEN
                                             tab_vllimpgo*/
                                          ELSE
                                             crapsnh.vllimpgo 
           tt-limites-internet.vllimtrf = IF NOT AVAIL crapsnh  THEN 
                                             0
                                          /*ELSE
                                          IF crapsnh.vllimtrf > tab_vllimtrf THEN
                                             tab_vllimtrf*/
                                          ELSE
                                             crapsnh.vllimtrf 
           tt-limites-internet.vllimted = IF NOT AVAIL crapsnh  THEN 
                                             0
                                          /*ELSE
                                          IF crapsnh.vllimted > tab_vllimted THEN
                                             tab_vllimted*/
                                          ELSE
                                             crapsnh.vllimted
           tt-limites-internet.vlvrbcop = tab_vllimvrb  
                   tt-limites-internet.vllimvrb = crapsnh.vllimvrb. 
    
    IF  crapass.inpessoa = 1 AND par_idseqttl > 1  THEN
        DO:
            /** Valor limite para operacoes de todos titulares **/
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 1            AND 
                               crapsnh.idseqttl = 1
                               NO-LOCK NO-ERROR.
                                       
            CREATE tt-limites-internet.
            ASSIGN tt-limites-internet.idseqttl = crapsnh.idseqttl
                   tt-limites-internet.vlwebcop = tab_vllimweb
                   tt-limites-internet.vlpgocop = tab_vllimpgo
                   tt-limites-internet.vltrfcop = tab_vllimtrf
                   tt-limites-internet.vltedcop = tab_vllimted
                   tt-limites-internet.vllimweb = IF NOT AVAIL crapsnh  THEN 
                                                     0
                                                  /*ELSE
                                                  IF crapsnh.vllimweb > tab_vllimweb THEN
                                                     tab_vllimweb*/
                                                  ELSE
                                                     crapsnh.vllimweb 
                   tt-limites-internet.vllimpgo = IF NOT AVAIL crapsnh  THEN 
                                                     0
                                                  /*ELSE
                                                  IF crapsnh.vllimpgo > tab_vllimpgo THEN
                                                     tab_vllimpgo*/
                                                  ELSE
                                                     crapsnh.vllimpgo 
                   tt-limites-internet.vllimtrf = IF NOT AVAIL crapsnh  THEN 
                                                     0
                                                  /*ELSE
                                                  IF crapsnh.vllimtrf > tab_vllimtrf THEN
                                                     tab_vllimtrf*/
                                                  ELSE
                                                     crapsnh.vllimtrf 
                   tt-limites-internet.vllimted = IF NOT AVAIL crapsnh  THEN 
                                                     0
                                                  /*ELSE
                                                  IF crapsnh.vllimted > tab_vllimted THEN
                                                     tab_vllimted*/
                                                  ELSE
                                                     crapsnh.vllimted
                   tt-limites-internet.vlvrbcop = tab_vllimvrb  
                           tt-limites-internet.vllimvrb = crapsnh.vllimvrb. 
        END.

    /** Limite Disponivel (Total - Utilizado) **/
    IF  par_flglimdp  THEN
        DO:
            ASSIGN aux_vlutlweb = 0    
                   aux_vlutltrf = 0
                   aux_vlutlpgo = 0
                   aux_vlutlted = 0
                   aux_vlutlvrb = 0.

            /** Acumula valores movimentados pelo titular **/
            FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                               crapmvi.nrdconta = par_nrdconta AND
                               crapmvi.idseqttl = par_idseqttl AND
                               crapmvi.dtmvtolt = par_dtmvtopg NO-LOCK NO-ERROR.
            
            ASSIGN aux_vlutlweb = IF AVAIL crapmvi THEN crapmvi.vlmovweb ELSE 0
                   aux_vlutltrf = IF AVAIL crapmvi THEN crapmvi.vlmovtrf ELSE 0
                   aux_vlutlpgo = IF AVAIL crapmvi THEN crapmvi.vlmovpgo ELSE 0
                   aux_vlutlted = IF AVAIL crapmvi THEN crapmvi.vlmovted ELSE 0.
            
            /** Acumular valor de agendamentos do titular **/
            IF  par_flgctrag  THEN
                FOR EACH craplau WHERE craplau.cdcooper = par_cdcooper AND
                                       craplau.nrdconta = par_nrdconta AND
                                       craplau.idseqttl = par_idseqttl AND
                                       craplau.dtmvtopg = par_dtmvtopg AND
                                       craplau.insitlau = 1            AND
                                       craplau.dsorigem = par_dsorigem NO-LOCK:
                    
                    IF  crapass.inpessoa = 1  THEN
                        ASSIGN aux_vlutlweb = aux_vlutlweb + craplau.vllanaut.
                    ELSE
                    IF  craplau.cdtiptra = 1  OR 
                        craplau.cdtiptra = 3  OR 
                        craplau.cdtiptra = 5  THEN
                        ASSIGN aux_vlutltrf = aux_vlutltrf + craplau.vllanaut.
                    ELSE
                    IF  craplau.cdtiptra = 2  THEN
                        ASSIGN aux_vlutlpgo = aux_vlutlpgo + craplau.vllanaut.
                                                  
                END. /** Fim do FOR EACH craplau **/
            
            FIND tt-limites-internet WHERE 
                 tt-limites-internet.idseqttl = par_idseqttl 
                 EXCLUSIVE-LOCK NO-ERROR.

            IF  tt-limites-internet.vllimweb > 0  THEN
                ASSIGN tt-limites-internet.vlutlweb = aux_vlutlweb
                       tt-limites-internet.vldspweb = 
                                  tt-limites-internet.vllimweb - aux_vlutlweb.

            IF  tt-limites-internet.vllimtrf > 0  THEN
                ASSIGN tt-limites-internet.vlutltrf = aux_vlutltrf
                       tt-limites-internet.vldsptrf = 
                                  tt-limites-internet.vllimtrf - aux_vlutltrf.

            IF  tt-limites-internet.vllimpgo > 0  THEN
                ASSIGN tt-limites-internet.vlutlpgo = aux_vlutlpgo
                       tt-limites-internet.vldsppgo = 
                                  tt-limites-internet.vllimpgo - aux_vlutlpgo.
            
            IF  tt-limites-internet.vllimted > 0  THEN
                ASSIGN tt-limites-internet.vlutlted = aux_vlutlted
                       tt-limites-internet.vldspted = 
                                  tt-limites-internet.vllimted - aux_vlutlted.
            
            IF  crapass.inpessoa = 1 AND par_idseqttl > 1  THEN
                DO:
                    ASSIGN aux_vlutlweb = 0    
                           aux_vlutltrf = 0
                           aux_vlutlpgo = 0
                           aux_vlutlted = 0.

                    /** Acumula valores movimentados por todos os titulares **/
                    FOR EACH crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                                           crapmvi.nrdconta = par_nrdconta AND
                                           crapmvi.dtmvtolt = par_dtmvtopg 
                                           NO-LOCK:

                        ASSIGN aux_vlutlweb = aux_vlutlweb + crapmvi.vlmovweb
                               aux_vlutltrf = aux_vlutltrf + crapmvi.vlmovtrf
                               aux_vlutlpgo = aux_vlutlpgo + crapmvi.vlmovpgo
                               aux_vlutlted = aux_vlutlted + crapmvi.vlmovted.
           
                    END. /** Fim do FOR EACH crapmvi **/

                    /** Acumular valor de agendamentos para todos os titulares **/
                    IF  par_flgctrag  THEN
                        FOR EACH craplau WHERE 
                                 craplau.cdcooper = par_cdcooper AND
                                 craplau.nrdconta = par_nrdconta AND
                                 craplau.dtmvtopg = par_dtmvtopg AND
                                 craplau.insitlau = 1            AND
                                 craplau.dsorigem = par_dsorigem NO-LOCK:
                            
                            IF  crapass.inpessoa = 1  THEN
                                ASSIGN aux_vlutlweb = aux_vlutlweb + 
                                                      craplau.vllanaut.
                            ELSE
                            IF  craplau.cdtiptra = 1  OR 
                                craplau.cdtiptra = 3  OR 
                                craplau.cdtiptra = 5  THEN
                                ASSIGN aux_vlutltrf = aux_vlutltrf + 
                                                      craplau.vllanaut.
                            ELSE
                            IF  craplau.cdtiptra = 2  THEN
                                ASSIGN aux_vlutlpgo = aux_vlutlpgo + 
                                                      craplau.vllanaut.
                                                          
                        END. /** Fim do FOR EACH craplau **/

                    FIND tt-limites-internet WHERE 
                         tt-limites-internet.idseqttl = 1 
                         EXCLUSIVE-LOCK NO-ERROR.
        
                    IF  tt-limites-internet.vllimweb > 0  THEN
                        ASSIGN tt-limites-internet.vlutlweb = aux_vlutlweb
                               tt-limites-internet.vldspweb = 
                                  tt-limites-internet.vllimweb - aux_vlutlweb.
        
                    IF  tt-limites-internet.vllimtrf > 0  THEN
                        ASSIGN tt-limites-internet.vlutltrf = aux_vlutltrf
                               tt-limites-internet.vldsptrf = 
                                  tt-limites-internet.vllimtrf - aux_vlutltrf.
        
                    IF  tt-limites-internet.vllimpgo > 0  THEN
                        ASSIGN tt-limites-internet.vlutlpgo = aux_vlutlpgo
                               tt-limites-internet.vldsppgo = 
                                  tt-limites-internet.vllimpgo - aux_vlutlpgo.
        
                    IF  tt-limites-internet.vllimted > 0  THEN
                        ASSIGN tt-limites-internet.vlutlted = aux_vlutlted
                               tt-limites-internet.vldspted = 
                                  tt-limites-internet.vllimted - aux_vlutlted.

                    FIND bb-limites-internet WHERE
                         bb-limites-internet.idseqttl = par_idseqttl
                         EXCLUSIVE-LOCK NO-ERROR.

                    IF  bb-limites-internet.vldspweb > tt-limites-internet.vldspweb  THEN
                        ASSIGN bb-limites-internet.vldspweb = tt-limites-internet.vldspweb.
        
                    IF  bb-limites-internet.vldsptrf > tt-limites-internet.vldsptrf  THEN
                        ASSIGN bb-limites-internet.vldsptrf = tt-limites-internet.vldsptrf.
        
                    IF  bb-limites-internet.vldsppgo > tt-limites-internet.vldsppgo  THEN
                        ASSIGN bb-limites-internet.vldsppgo = tt-limites-internet.vldsppgo.
        
                    IF  bb-limites-internet.vldspted > tt-limites-internet.vldspted  THEN
                        ASSIGN bb-limites-internet.vldspted = tt-limites-internet.vldspted.
                END.
        END.
    
    RETURN "OK".

END.


/******************************************************************************/
/**              Procedure para validar agendamento recorrente               **/
/******************************************************************************/
PROCEDURE verifica_agendamento_recorrente:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_ddagenda AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtmesagd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdageban LIKE crapcti.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_cdtiptra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_lsdatagd AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_tpoperac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplau.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_lsvlapag AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-agenda-recorrente.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_ddagenda AS INTE                                    NO-UNDO.
    DEF VAR aux_mmagenda AS INTE                                    NO-UNDO.
    DEF VAR aux_yyagenda AS INTE                                    NO-UNDO.
    DEF VAR aux_dtpagext AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsdmeses AS CHAR                                    NO-UNDO.   
    DEF VAR aux_dtmvtopg LIKE craplau.dtmvtopg                      NO-UNDO.
    DEF VAR aux_lsvlapag AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlapagar AS DECI                                    NO-UNDO.
    DEF VAR aux_vllanmto AS DECI                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INT									    NO-UNDO.
	DEF VAR aux_dscritic AS CHAR									NO-UNDO.
  
    DEF VAR bkp_dtmvtopg LIKE craplau.dtmvtopg                      NO-UNDO.

    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag Root em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag horario em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag horario */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
        
    DEF VAR aux_nmdatela AS CHAR NO-UNDO.
    DEF VAR aux_flgtrans AS INTEGER NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                        
    /* Procedure para verificar agendamento recorrente (paga0002)*/    
    RUN STORED-PROCEDURE pc_verif_agend_recor_prog
    aux_handproc = PROC-HANDLE NO-ERROR      
    (INPUT par_cdcooper, /* Codigo da cooperativa */
     INPUT par_cdagenci, /* Codigo da agencia */
     INPUT par_nrdcaixa, /* Numero do caixa */
     INPUT par_nrdconta,  /* Numero da conta do cooperado */
     INPUT par_idseqttl,  /* Sequencial do titular */
     INPUT par_dtmvtolt,  /* Data do movimento */
     INPUT par_ddagenda,  /* Dia de agendamento */
     INPUT par_qtmesagd,  /* Quantidade de meses */
     INPUT par_dtinicio,  /* Data inicial */
     INPUT par_vllanmto,  /* Valor do lancamento automatico */
     INPUT par_cddbanco,  /* Codigo do banco */
     INPUT par_cdageban,  /* Codigo de agencia bancaria */
     INPUT par_nrctatrf,  /* Numero da conta destino */
     INPUT par_cdtiptra,  /* Tipo de transação */
     INPUT par_lsdatagd,  /* lista de datas agendamento */
     INPUT par_cdoperad,  /* Codigo do operador */
     INPUT par_tpoperac,  /* tipo de operação */
     INPUT par_dsorigem,  /* Descrição de origem do registro */
     INPUT par_nrcpfope,  /* Numero do cpf do operador juridico */
     INPUT aux_nmdatela,  /* Nome da tela   */
     OUTPUT "",  /* par_dstransa */
     OUTPUT "",  /*pr_tab_agenda_recorrente*/
     OUTPUT 0,   /*pr_cdcritic*/
     OUTPUT ""). /*pr_dscritic*/

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROCEDURE pc_verif_agend_recor_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
            
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
            
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req      = pc_verif_agend_recor_prog.pr_tab_agenda_recorrente   
           par_dstransa = pc_verif_agend_recor_prog.pr_dstransa
                     WHEN pc_verif_agend_recor_prog.pr_dstransa <> ?
	       aux_cdcritic = pc_verif_agend_recor_prog.pr_cdcritic 
                             WHEN pc_verif_agend_recor_prog.pr_cdcritic <> ?
           aux_dscritic = pc_verif_agend_recor_prog.pr_dscritic
                             WHEN pc_verif_agend_recor_prog.pr_dscritic <> ?. 
            
    IF aux_cdcritic <> 0  OR 
       aux_dscritic <> "" THEN
                DO:
           IF aux_dscritic = "" THEN
              ASSIGN aux_dscritic =  "Nao foi possivel verificar o horario.".
                
           ASSIGN par_dscritic = aux_dscritic.

                    RETURN "NOK".
                END.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    IF ponteiro_xml <> ? THEN
    DO:
      xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
      xDoc:GET-DOCUMENT-ELEMENT(xRoot).

      DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
        xRoot:GET-CHILD(xRoot2,aux_contador).

        IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 
        
        IF xRoot2:NUM-CHILDREN > 0 THEN               
        CREATE tt-agenda-recorrente.
            
        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
          xRoot2:GET-CHILD(xField,aux_cont).
            
          IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT.

          xField:GET-CHILD(xText,1) NO-ERROR.
            
		  /* Se nao vier conteudo na TAG */
          IF ERROR-STATUS:ERROR             OR
             ERROR-STATUS:NUM-MESSAGES > 0  THEN
             NEXT.          

          ASSIGN tt-agenda-recorrente.dtmvtopg = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtopg"
                 tt-agenda-recorrente.dtpagext = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dtpagext"
                 tt-agenda-recorrente.dscritic = (xText:NODE-VALUE) WHEN xField:NAME = "dscritic"
                 aux_flgtrans                  = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "flgtrans".

          IF aux_flgtrans = 1 THEN
            ASSIGN tt-agenda-recorrente.flgtrans = YES.
          ELSE 
            ASSIGN tt-agenda-recorrente.flgtrans = NO.

            END.
      END.    

      SET-SIZE(ponteiro_xml) = 0.   
                
            END.
            
	/* Elimina objetos para leitura do XML */ 
	DELETE OBJECT xDoc.    /* Vai conter o XML completo */ 
	DELETE OBJECT xRoot.   /* Vai conter a tag Root em diante */ 
	DELETE OBJECT xRoot2.  /* Vai conter a tag horario em diante */ 
	DELETE OBJECT xField.  /* Vai conter os campos dentro da tag horario */ 
	DELETE OBJECT xText.   /* Vai conter o texto que existe dentro da tag xField */
                                          
    RETURN "OK".
 
END PROCEDURE.


/******************************************************************************/
/**                  Procedure para verificar os dados da TED                **/
/******************************************************************************/
PROCEDURE verifica-dados-ted:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdageban LIKE crapcti.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_nmtitula LIKE crapcti.nmtitula             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc LIKE crapcti.nrcpfcgc             NO-UNDO.
    DEF  INPUT PARAM par_inpessoa LIKE crapcti.inpessoa             NO-UNDO.
    DEF  INPUT PARAM par_intipcta LIKE crapcti.intipcta             NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF  INPUT PARAM par_cdfinali AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdispbif LIKE crapcti.nrispbif             NO-UNDO.
    DEF  INPUT param par_idagenda AS INTE                           NO-UNDO.
    DEF  INPUT param par_tptransa AS INTE                           NO-UNDO. /*REQ39*/
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

	DEF VAR aux_cdcritic AS INT									    NO-UNDO.
	DEF VAR aux_dscritic AS CHAR									NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    /* Procedure para verificar dados ted (cxon0020)*/
    RUN STORED-PROCEDURE pc_verifica_dados_ted
    aux_handproc = PROC-HANDLE NO-ERROR      
    (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,    
     INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_cddbanco, 
                                   INPUT par_cdageban, 
                                   INPUT par_nrctatrf, 
                                   INPUT par_nmtitula, 
                                   INPUT par_nrcpfcgc, 
                                   INPUT par_inpessoa, 
                                   INPUT par_intipcta, 
     INPUT par_vllanmto,
                                   INPUT par_cdfinali,
                                   INPUT par_dshistor,
     INPUT par_cdispbif,
     INPUT par_idagenda,
     INPUT par_tptransa, /*REQ39 - Inclusao do parametro do tipo de transaçao */
     OUTPUT "",  /*par_dstransa*/     
     OUTPUT 0,  /*par_cdcritic*/     
     OUTPUT ""). /*par_dscritic*/

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_verifica_dados_ted
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
       
    ASSIGN par_dstransa = pc_verifica_dados_ted.pr_dstransa 
                     WHEN pc_verifica_dados_ted.pr_dstransa <> ?
		   aux_cdcritic = pc_verifica_dados_ted.pr_cdcritic
                     WHEN pc_verifica_dados_ted.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_dados_ted.pr_dscritic
                     WHEN pc_verifica_dados_ted.pr_dscritic <> ?.

    IF aux_cdcritic <> 0  OR 
       aux_dscritic <> "" THEN
        DO:
           IF aux_dscritic = "" THEN
              ASSIGN aux_dscritic =  "Nao foi possivel verificar dados da TED.".
                                      
           ASSIGN par_dscritic = aux_dscritic.
                  
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**                  Procedure para executar o envio da TED                 **/
/******************************************************************************/
PROCEDURE executa-envio-ted:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdageban LIKE crapcti.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_nmtitula LIKE crapcti.nmtitula             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc LIKE crapcti.nrcpfcgc             NO-UNDO.
    DEF  INPUT PARAM par_inpessoa LIKE crapcti.inpessoa             NO-UNDO.
    DEF  INPUT PARAM par_intipcta LIKE crapcti.intipcta             NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF  INPUT PARAM par_dstransf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinali AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdispbif LIKE crapcti.nrispbif             NO-UNDO. 
    DEF  INPUT PARAM par_flmobile AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_idagenda AS INTEGER                        NO-UNDO.
    DEF  INPUT PARAM par_iptransa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_iddispos AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-protocolo-ted.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
	DEF VAR aux_dscritic AS CHAR									NO-UNDO.
    DEF VAR aux_flmobile AS INTEGER                                 NO-UNDO.

    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
	/* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag Root em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag horario em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag horario */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
    
    IF par_flmobile THEN 
      ASSIGN aux_flmobile = 1.
                                        ELSE
      ASSIGN aux_flmobile = 0.
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
       
    /* Procedure para executar envio de ted (cxon0020)*/
    RUN STORED-PROCEDURE pc_executa_envio_ted_prog
    aux_handproc = PROC-HANDLE NO-ERROR      
    (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
     INPUT par_idorigem,
     INPUT par_dtmvtolt,     
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                         INPUT par_nrcpfope,
                                         INPUT par_cddbanco,
                                         INPUT par_cdageban,
                                         INPUT par_nrctatrf,
                                         INPUT par_nmtitula,
                                         INPUT par_nrcpfcgc,
                                         INPUT par_inpessoa,
                                         INPUT par_intipcta,
                                         INPUT par_vllanmto,
                                         INPUT par_dstransf,
                                         INPUT par_cdfinali,
     INPUT par_dshistor,
                                         INPUT par_cdispbif,
     INPUT aux_flmobile,
     INPUT par_idagenda,
     INPUT par_iptransa,  /* pr_iptransa */
     INPUT par_dstransa,  /* pr_dstransa */
                                         INPUT par_iddispos,

     
    OUTPUT "",  /*pr_dsprotoc*/
    OUTPUT "",  /*pr_tab_protocolo_ted CLOB --> dados do protocolo */
    OUTPUT 0,   /*pr_cdcritic               --> Codigo do erro*/
    OUTPUT ""). /*pr_dscritic*/    

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_executa_envio_ted_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

    ASSIGN xml_req      = pc_executa_envio_ted_prog.pr_tab_protocolo_ted                     

           par_dsprotoc = pc_executa_envio_ted_prog.pr_dsprotoc 
                     WHEN pc_executa_envio_ted_prog.pr_dsprotoc <> ?
        
           aux_cdcritic = pc_executa_envio_ted_prog.pr_cdcritic           
                     WHEN pc_executa_envio_ted_prog.pr_cdcritic <> ?
      
           aux_dscritic = pc_executa_envio_ted_prog.pr_dscritic           
                     WHEN pc_executa_envio_ted_prog.pr_dscritic <> ?.


    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
                        DO:
           IF aux_dscritic = "" THEN
              ASSIGN aux_dscritic =  "Nao foi possivel enviar a TED.".
        
           ASSIGN par_dscritic = aux_dscritic.

      RETURN "NOK".
            END.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:
      xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
      xDoc:GET-DOCUMENT-ELEMENT(xRoot).

      DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
        IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 
                    
        IF xRoot2:NUM-CHILDREN > 0 THEN               
                    CREATE tt-protocolo-ted.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
          xRoot2:GET-CHILD(xField,aux_cont).
    
          IF xField:SUBTYPE <> "ELEMENT" THEN 
                                NEXT.

          xField:GET-CHILD(xText,1) NO-ERROR.
        
		  /* Se nao vier conteudo na TAG */
          IF ERROR-STATUS:ERROR             OR
             ERROR-STATUS:NUM-MESSAGES > 0  THEN
                                NEXT.
        
          ASSIGN tt-protocolo-ted.cdtippro    = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "cdtippro"
                 tt-protocolo-ted.dtmvtolt    = DATE(xText:NODE-VALUE)    WHEN xField:NAME = "dtmvtolt"
                 tt-protocolo-ted.dttransa    = DATE(xText:NODE-VALUE)    WHEN xField:NAME = "dttransa"
                 tt-protocolo-ted.hrautent    = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "hrautent"
                 tt-protocolo-ted.vldocmto    = DECIMAL(xText:NODE-VALUE) WHEN xField:NAME = "vldocmto"
                 tt-protocolo-ted.nrdocmto    = DECIMAL(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto"
                 tt-protocolo-ted.nrseqaut    = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "nrseqaut"
                 tt-protocolo-ted.dsinform[1] = (xText:NODE-VALUE) WHEN xField:NAME        = "dsinform1"
                 tt-protocolo-ted.dsinform[2] = (xText:NODE-VALUE) WHEN xField:NAME        = "dsinform2"
                 tt-protocolo-ted.dsinform[3] = (xText:NODE-VALUE) WHEN xField:NAME        = "dsinform3"
                 tt-protocolo-ted.dsprotoc    = (xText:NODE-VALUE) WHEN xField:NAME        = "dsprotoc"
                 tt-protocolo-ted.nmprepos    = (xText:NODE-VALUE) WHEN xField:NAME        = "nmprepos"
                 tt-protocolo-ted.nrcpfpre    = DECIMAL(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfpre"
                 tt-protocolo-ted.nmoperad    = (xText:NODE-VALUE) WHEN xField:NAME        = "nmoperad"
                 tt-protocolo-ted.nrcpfope    = DECIMAL(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfope"
                 tt-protocolo-ted.cdbcoctl    = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "cdbcoctl"
                 tt-protocolo-ted.cdagectl    = INTEGER(xText:NODE-VALUE) WHEN xField:NAME = "cdagectl".
                            
                    END.
        END.
      SET-SIZE(ponteiro_xml) = 0.      

        END.

	/* Elimina objetos para leitura do XML */ 
	DELETE OBJECT xDoc.    /* Vai conter o XML completo */ 
	DELETE OBJECT xRoot.   /* Vai conter a tag Root em diante */ 
	DELETE OBJECT xRoot2.  /* Vai conter a tag horario em diante */ 
	DELETE OBJECT xField.  /* Vai conter os campos dentro da tag horario */ 
	DELETE OBJECT xText.   /* Vai conter o texto que existe dentro da tag xField */
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**      Procedure para verificar qual o historico para a transferencia      **/
/******************************************************************************/
PROCEDURE verifica-historico-transferencia:
    
    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_cdorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtiptra AS INTE                           NO-UNDO.
                     /** 1 - Transf.Normal / 3 - Credito Salario **/
                     
    DEF OUTPUT PARAM par_cdhiscre LIKE craphis.cdhistor             NO-UNDO.
    DEF OUTPUT PARAM par_cdhisdeb LIKE craphis.cdhistor             NO-UNDO.
    
	DEF VAR aux_nrcpfcgc1 LIKE crapttl.nrcpfcgc					    NO-UNDO.
	DEF VAR aux_nrcpfcgc2 LIKE crapttl.nrcpfcgc					    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
	    
	ASSIGN aux_nrcpfcgc1 = 0 
		   aux_nrcpfcgc2 = 0.
    
    /** Transferencia de credito de salario pela internet **/
    IF  par_cdorigem = 3 AND par_cdtiptra = 3  THEN
        DO:
            ASSIGN par_cdhiscre = 772   
                   par_cdhisdeb = 771.  
                   
            RETURN "OK".
        END.
        
    /** Conta Origem **/
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
					   NO-LOCK NO-ERROR.
    
	IF crapass.inpessoa = 1 THEN
	   DO:
	      FOR FIRST crapttl FIELDS(nrcpfcgc)
		                     WHERE crapttl.cdcooper = crapass.cdcooper AND
    							   crapttl.nrdconta = crapass.nrdconta AND
							       crapttl.idseqttl = 2
							       NO-LOCK:

            ASSIGN aux_nrcpfcgc1 = crapttl.nrcpfcgc.

		  END.

	   END.	
                       
    /** Conta Destino **/
    FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                       crabass.nrdconta = INTE(par_nrctatrf) 
					   NO-LOCK NO-ERROR.

	IF crabass.inpessoa = 1 THEN
	   DO:
	      FOR FIRST crapttl FIELDS(nrcpfcgc)
		                     WHERE crapttl.cdcooper = crabass.cdcooper AND
    							   crapttl.nrdconta = crabass.nrdconta AND
							       crapttl.idseqttl = 2
							       NO-LOCK:

            ASSIGN aux_nrcpfcgc2 = crapttl.nrcpfcgc.

		  END.

	   END.
                       
    /** Verifica titularidade das contas para ver qual historico utilizar **/
    IF  crapass.nrcpfcgc = crabass.nrcpfcgc  AND
        aux_nrcpfcgc1    = aux_nrcpfcgc2     THEN
        ASSIGN par_cdhisdeb = IF par_cdorigem = 3 THEN 538 ELSE 376.
    ELSE
    IF  aux_nrcpfcgc1    = crabass.nrcpfcgc  AND     
        crapass.nrcpfcgc = aux_nrcpfcgc2     THEN
        ASSIGN par_cdhisdeb = IF par_cdorigem = 3 THEN 538 ELSE 376.    
    ELSE
    IF  crapass.nrcpfcgc = crabass.nrcpfcgc  AND
        aux_nrcpfcgc2    = 0                 THEN
        ASSIGN par_cdhisdeb = IF par_cdorigem = 3 THEN 538 ELSE 376.    
    ELSE
    IF  aux_nrcpfcgc1    = crabass.nrcpfcgc  AND
        aux_nrcpfcgc2    = 0                 THEN
        ASSIGN par_cdhisdeb = IF par_cdorigem = 3 THEN 538 ELSE 376.
    ELSE
        ASSIGN par_cdhisdeb = IF par_cdorigem = 3 THEN 537 ELSE 375.
    
    ASSIGN par_cdhiscre = IF par_cdorigem = 3 THEN 539 ELSE 377.
    
    RETURN "OK".
    
END PROCEDURE.
 
/******************************************************************************/
/**             Procedure para efetuar transferencia da Internet             **/
/******************************************************************************/
PROCEDURE executa_transferencia:

    DEF INPUT  PARAM par_cdcooper LIKE craplcm.cdcooper             NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt LIKE craplcm.dtmvtolt             NO-UNDO.
    DEF INPUT  PARAM par_dtmvtocd LIKE craplcm.dtmvtolt             NO-UNDO.
    DEF INPUT  PARAM par_cdagenci LIKE craplcm.cdagenci             NO-UNDO.
    DEF INPUT  PARAM par_cdbccxlt LIKE craplcm.cdbccxlt             NO-UNDO.
    DEF INPUT  PARAM par_nrdolote LIKE craplcm.nrdolote             NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE craplcm.nrdconta             NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF INPUT  PARAM par_nrdocmto LIKE craplcm.nrdocmto             NO-UNDO.
    DEF INPUT  PARAM par_cdhiscre LIKE craplcm.cdhistor             NO-UNDO.
    DEF INPUT  PARAM par_cdhisdeb LIKE craplcm.cdhistor             NO-UNDO.
    DEF INPUT  PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF INPUT  PARAM par_cdoperad LIKE craplcm.cdoperad             NO-UNDO.
    DEF INPUT  PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF INPUT  PARAM par_flagenda AS LOGI                           NO-UNDO.
    DEF INPUT  PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdagetfn AS INTE                           NO-UNDO.    
    DEF INPUT  PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_dscartao AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_cdorigem AS INTE                           NO-UNDO. 
    DEF INPUT  PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_flmobile AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_idtipcar AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrcartao AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    DEF OUTPUT PARAM par_nrdocdeb LIKE craplcm.nrdocmto             NO-UNDO.
    DEF OUTPUT PARAM par_nrdoccre LIKE craplcm.nrdocmto             NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc             NO-UNDO.
    
    DEF VAR aux_nrautdoc          LIKE craplcm.nrautdoc             NO-UNDO.
    DEF VAR aux_dslitera          AS CHAR                           NO-UNDO.
    DEF VAR aux_dsinfor1          AS CHAR                           NO-UNDO.
    DEF VAR aux_dsinfor2          AS CHAR                           NO-UNDO.
    DEF VAR aux_dsinfor3          AS CHAR                           NO-UNDO.
    DEF VAR aux_nrdconta          AS CHAR                           NO-UNDO.
    DEF VAR aux_nmextttl          AS CHAR                           NO-UNDO.
    DEF VAR aux_nmarqdbo          AS CHAR                           NO-UNDO.    
    DEF VAR aux_nrdrecid          AS RECID                          NO-UNDO.
    DEF VAR aux_nrcartao          AS DECIMAL                        NO-UNDO.
    DEF VAR aux_nrctacar          AS INTE                           NO-UNDO.
    DEF VAR aux_contador          AS INTE                           NO-UNDO.
	DEF VAR aux_cdhistor 		  AS INTE             			    NO-UNDO.
	DEF VAR aux_cdhisest 		  AS INTE             			    NO-UNDO.
	DEF VAR aux_vltarifa 		  AS DECI             			    NO-UNDO.
	DEF VAR aux_dtdivulg 		  AS DATE             			    NO-UNDO.
	DEF VAR aux_dtvigenc 		  AS DATE             			    NO-UNDO.
	DEF VAR aux_cdfvlcop 		  AS INTE             			    NO-UNDO.
    DEF VAR aux_cdcritic          AS INTE                           NO-UNDO.
    DEF VAR aux_dscritic          AS CHAR                           NO-UNDO.
    
    DEF VAR h-b1craplot           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1craplcm           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1crapaut           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1crapmvi           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1crap00            AS HANDLE                         NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0025          AS HANDLE                         NO-UNDO.
	DEF VAR h-b1wgen0153          AS HANDLE              			NO-UNDO.

    DEFINE VARIABLE aux_nmprepos AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrcpfpre AS DECIMAL     NO-UNDO.

    DEF VAR aux_nrseqdig          LIKE craplot.nrseqdig             NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER cra2ass FOR crapass.
    
    /* Para origem 4-TAA, quando o par_nrterfin <> 0, esta efetuando a operacao on-line
       no proprio terminal, caso par_nrterfin = 0, esta efetuando debito de agendamento
       via batch, por exemplo */

    IF  par_cdhisdeb = 771  THEN 
        par_dstransa = "Credito de Salario".
    ELSE
        par_dstransa = "Transferencia de Valores".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop   THEN
         DO:
             IF   par_cdorigem = 2 THEN /* CASH */
                  par_dscritic = "616". /* Codigo Erro EXTRACASH */
             ELSE
                  par_dscritic = "Cooperativa nao cadastrada.".
         
             RETURN "NOK".
         END.
         
    /* Conta origem */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
                       
    /* Conta destino */
    FIND crabass WHERE crabass.cdcooper = par_cdcooper   AND
                       crabass.nrdconta = INTE(par_nrctatrf)   NO-LOCK NO-ERROR.
                       
    IF   par_cdorigem = 2 THEN   /* CASH */
         DO:
             IF   NOT AVAILABLE crabass THEN
                  DO:
                      par_dscritic = "002". /* Codigo Erro EXTRACASH */
                      
                      RETURN "NOK".
                  END.
                  
             /* Nao permite transferir para mesma conta */ 
             IF   crapass.nrdconta = crabass.nrdconta  THEN
                  DO:
                      par_dscritic = "002". /* Codigo Erro EXTRACASH */
                      
                      RETURN "NOK".
                  END.

             /*  Obtem o numero do cartao atraves da trilha do cartao */
             RUN sistema/generico/procedures/b1wgen0025.p
                 PERSISTENT SET h-b1wgen0025.
                 
             IF   VALID-HANDLE(h-b1wgen0025)   THEN    
                  DO:
                      RUN p_retorna_numero_cartao IN h-b1wgen0025(
                                                 INPUT  par_dscartao,
                                                 OUTPUT aux_nrcartao,
                                                 OUTPUT aux_nrctacar).

                      DELETE PROCEDURE h-b1wgen0025.
                  END.
         END.

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
       /* Leitura do lote */
       /* Revitalizacao - Remocao de lotes
       DO aux_contador = 1 TO 10:
           
          par_dscritic = "".
    
          FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                             craplot.dtmvtolt = par_dtmvtocd   AND
                             craplot.cdagenci = par_cdagenci   AND
                             craplot.cdbccxlt = par_cdbccxlt   AND 
                             craplot.nrdolote = par_nrdolote
                             USE-INDEX craplot1 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
          IF   NOT AVAILABLE craplot   THEN                
               IF   LOCKED craplot   THEN
                    DO:                        
                        par_dscritic = IF   par_cdorigem = 3   THEN
                                            "Registro de lote esta sendo " +
                                            "alterado. Tente novamente. " +
                                            "Lote: " + STRING(par_nrdolote)
                                       ELSE     
                                            "991".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        EMPTY TEMP-TABLE cratlot.
       
                        CREATE cratlot.
                        ASSIGN cratlot.cdcooper = par_cdcooper
                               cratlot.dtmvtolt = par_dtmvtocd
                               cratlot.cdagenci = par_cdagenci
                               cratlot.cdbccxlt = par_cdbccxlt
                               cratlot.nrdolote = par_nrdolote
                               cratlot.nrdcaixa = par_nrdcaixa
                               cratlot.cdoperad = par_cdoperad
                               cratlot.cdopecxa = par_cdoperad
                               cratlot.tplotmov = 1.
                               
                        RUN sistema/generico/procedures/b1craplot.p
                            PERSISTENT SET h-b1craplot.
                            
                        IF   VALID-HANDLE(h-b1craplot)   THEN
                             DO:
                                 RUN inclui-registro IN h-b1craplot
                                     (INPUT TABLE cratlot,
                                     OUTPUT par_dscritic).
                                 
                                 DELETE PROCEDURE h-b1craplot.
                             
                                 IF   RETURN-VALUE = "NOK"   THEN
                                      DO:
                                          IF   par_cdorigem = 2 THEN  /* CASH */
                                               par_dscritic = "990".
                      
                                          UNDO, RETURN "NOK".
                                      END.
                             END.
                        
                        NEXT. /* Para pegar o novo registro */
                    END.
          
          LEAVE.
          
       END. /* Fim do WHILE */
       
       IF   par_dscritic <> ""   THEN
            UNDO, RETURN "NOK".
       
       
       /* Atualiza a sequencia do digito do lote e libero o lock do craplot */
       ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
              aux_nrseqdig     = craplot.nrseqdig.

       EMPTY TEMP-TABLE cratlot.
       FIND CURRENT craplot NO-LOCK NO-ERROR.
       RELEASE craplot.
       */
       
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                          ,INPUT "NRSEQDIG"
                          ,STRING(par_cdcooper) + ";" + STRING(par_dtmvtocd,"99/99/9999") + ";" + STRING(par_cdagenci) + ";" + STRING(par_cdbccxlt) + ";" + STRING(par_nrdolote)
                          ,INPUT "N"
                          ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                    WHEN pc_sequence_progress.pr_sequence <> ?.
       
       IF   par_cdorigem = 3   OR     /* INTERNET */
            par_cdorigem = 4   THEN   /* TAA */
            DO:
                /* Grava uma autenticacao para a transferencia */
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
       
                IF   VALID-HANDLE(h-b1crap00)   THEN 
                     DO:
                         RUN grava-autenticacao IN h-b1crap00 
                                            (INPUT crapcop.nmrescop,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_vllanmto,
                                             INPUT aux_nrseqdig, 
                                             INPUT YES,    /* Debito  */
                                             INPUT "1",    /* On-Line */
                                             INPUT NO,     /* Estorno */ 
                                             INPUT par_cdhiscre, 
                                             INPUT ?, 
                                             INPUT 0, 
                                             INPUT 0, 
                                             INPUT 0, 
                                            OUTPUT aux_dslitera,
                                            OUTPUT aux_nrautdoc,
                                            OUTPUT aux_nrdrecid).
            
                         DELETE PROCEDURE h-b1crap00.
                
                         IF   RETURN-VALUE = "NOK"   THEN
                              DO:
                                  par_dscritic = "Erro na autenticacao da " +
                                                 "transferencia.".
                                  UNDO, RETURN "NOK".
                              END.
                     END.
            END.
       
       IF   (par_cdorigem = 2)   OR                              /* CASH */
            (par_cdorigem = 4   AND   par_nrterfin <> 0)   THEN   /* TAA */ 
            DO:
               /* Leitura do terminal  */
               DO aux_contador = 1 TO 10:
                    
                  ASSIGN par_dscritic = "".
                    
                   FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn   AND 
                                      craptfn.nrterfin = par_nrterfin
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                          
                   IF   NOT AVAILABLE craptfn   THEN
                        IF   LOCKED craptfn   THEN
                             DO:
                            ASSIGN par_dscritic = IF par_cdorigem = 3   THEN
                                                     "Registro de lote esta sendo " +
                                                     "alterado. Tente novamente. " +
                                                     "Lote: " + STRING(par_nrdolote)
                                                  ELSE     
                                                     "995".
                            PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                        ASSIGN par_dscritic = "Terminal Financeiro nao cadastrado.".
                
                   LEAVE.
                   
               END. /* Fim do WHILE */
                   
               IF par_dscritic <> ""   THEN
                  UNDO, RETURN "NOK".
            
               ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1.

           END.
       
       /* Cria o lancamento do DEBITO */
       EMPTY TEMP-TABLE cratlcm.
       CREATE cratlcm.
       ASSIGN cratlcm.cdcooper = par_cdcooper
              cratlcm.dtmvtolt = par_dtmvtocd
              cratlcm.cdagenci = par_cdagenci
              cratlcm.cdbccxlt = par_cdbccxlt
              cratlcm.nrdolote = par_nrdolote
              cratlcm.dtrefere = par_dtmvtocd
              cratlcm.hrtransa = TIME
              cratlcm.cdoperad = par_cdoperad
              cratlcm.nrdconta = par_nrdconta
              cratlcm.nrdctabb = par_nrdconta
              cratlcm.nrdctitg = STRING(par_nrdconta,"99999999")
              cratlcm.nrdocmto = aux_nrseqdig
              cratlcm.nrseqdig = aux_nrseqdig
              cratlcm.cdhistor = par_cdhisdeb
              cratlcm.vllanmto = par_vllanmto
              cratlcm.cdcoptfn = par_cdcoptfn
              cratlcm.cdagetfn = par_cdagetfn
              cratlcm.nrterfin = par_nrterfin
              par_nrdocdeb     = cratlcm.nrdocmto
              /* Atencao na alteracao da string pois o termo AGENDADO do * 
               * campo cdpesqbb eh utilizado em regra da BO b1wgen0001,  *
               * na composicao de saldo (procedure obtem-saldo-dia)      */
              cratlcm.cdpesqbb = IF   par_cdorigem = 3 THEN  /* INTERNET */
                                      'INTERNET - TRANSFERENCIA ON-LINE ' + 
                                      '- CONTA    ' +
                                      STRING(par_nrctatrf,'99999999') +
                                      (IF  par_flagenda  THEN
                                           " AGENDADO"
                                       ELSE
                                           "")
                                 ELSE 'TAA - TRANSFERENCIA ON-LINE ' + 
                                      '- CONTA         ' +
                                      STRING(par_nrctatrf,'99999999') +
                                      (IF  par_flagenda  THEN
                                           " AGENDADO"
                                       ELSE
                                           "").

       /* Para INTERNET ou em caso de TAA executando em BATCH */
       IF  par_cdorigem = 3    OR  /* INTERNET */
          (par_cdorigem = 4    AND /* TAA */
           par_nrterfin = 0)  THEN
           ASSIGN cratlcm.nrsequni = aux_nrseqdig
                  cratlcm.nrautdoc = aux_nrautdoc.
       ELSE /* TAA, execucao on-line */
           ASSIGN cratlcm.nrsequni = par_nrdocmto
                  cratlcm.nrautdoc = craptfn.nrultaut.
                                 
       RUN sistema/generico/procedures/b1craplcm.p
           PERSISTENT SET h-b1craplcm.
           
       IF   VALID-HANDLE(h-b1craplcm)   THEN
            DO:
                RUN inclui-registro IN h-b1craplcm (INPUT TABLE cratlcm,
                                                   OUTPUT par_dscritic).
                                                    
                DELETE PROCEDURE h-b1craplcm.
                
                IF   RETURN-VALUE = "NOK"   THEN
                     DO:
                         IF   par_cdorigem = 2 THEN  /* CASH */
                              par_dscritic = "990".

                         UNDO, RETURN "NOK".
                     END.    
            END.
       
       IF   par_cdorigem = 3    OR                              /* INTERNET */
           (par_cdorigem = 4   AND   par_nrterfin <> 0)   THEN     /* TAA */
            DO:
                /* Gera um protocolo para a transferencia */
                ASSIGN aux_nmarqdbo = "sistema/generico/procedures/" +
                                      "bo_algoritmo_seguranca.p".
                
                RUN VALUE(aux_nmarqdbo) PERSISTENT SET h-bo_algoritmo_seguranca.
           
                IF   VALID-HANDLE(h-bo_algoritmo_seguranca)   THEN
                     DO:
                         /* Formata nrdconta para visualizacao na internet */
                         aux_nrdconta = TRIM(STRING(crabass.nrdconta,
                                                    "zzzz,zz9,9")).
                         SUBSTR(aux_nrdconta,LENGTH(aux_nrdconta) - 1,1) = "-".
                
                         IF   crapass.inpessoa = 1  THEN
                              DO:
                                  /* Nome do titular que fez a transferencia */
                                  FIND crapttl WHERE 
                                       crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = par_idseqttl
                                       NO-LOCK NO-ERROR.
                                   
                                  IF   NOT AVAILABLE crapttl   THEN
                                       DO:
                                           par_dscritic = "Titular nao " +
                                                          "encontrado.".
                                           UNDO, RETURN "NOK".
                                       END.
                              
                                  aux_nmextttl = crapttl.nmextttl.
                              END.
                         ELSE
                              aux_nmextttl = crapass.nmprimtl.
                              
                         /* Campos da crappro para visualizacao na internet */
                         ASSIGN aux_dsinfor1 = IF  par_cdhisdeb = 771  THEN
                                                   "Credito de Salario" 
                                               ELSE    
                                                   "Transferencia"
                                aux_dsinfor2 = aux_nmextttl + "#" +
                                       "Conta/dv Destino: " + 
                                       aux_nrdconta + " - " +
                                       crabass.nmprimtl     + 
                                       "#" + STRING(crapcop.cdagectl,"9999") + 
                                       " - " + crapcop.nmrescop
                                
                                aux_dsinfor3 = IF   par_cdorigem = 3   THEN 
                                                    ""
                                               ELSE 
                                                    "TAA: " + 
                                             STRING(craptfn.cdcooper,"9999") +
                                                    "/"     +
                                             STRING(craptfn.cdagenci,"9999") +
                                                    "/"     +
                                             STRING(craptfn.nrterfin,"9999").
                
                         IF  par_cdorigem = 3  THEN
                         DO:

                             /* busca dados do preposto */
                             ASSIGN aux_nmprepos = ""
                                    aux_nrcpfpre = 0.
                             
                             /* Busca dados preposto apenas quando nao possui assinatura conjunta */
                             IF crapass.idastcjt = 0 THEN
                             DO:
                                 
                             FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                                crapsnh.nrdconta = par_nrdconta AND
                                                crapsnh.idseqttl = 1            AND
                                                crapsnh.tpdsenha = 1 NO-LOCK NO-ERROR.
                             IF  AVAIL crapsnh THEN
                             DO:
                                 ASSIGN aux_nrcpfpre = crapsnh.nrcpfcgc.
    
                                 FIND crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper AND
                                                    crapavt.nrdconta = crapsnh.nrdconta AND
                                                    crapavt.tpctrato = 6                AND
                                                    crapavt.nrcpfcgc = crapsnh.nrcpfcgc
                                                    NO-LOCK NO-ERROR.
                             
                                 IF  AVAIL crapavt  THEN
                                 DO:
                                     FIND cra2ass WHERE cra2ass.cdcooper = par_cdcooper     AND
                                                        cra2ass.nrdconta = crapavt.nrdctato
                                                        NO-LOCK NO-ERROR.
                             
                                     IF  AVAILABLE cra2ass  THEN
                                         ASSIGN aux_nmprepos = cra2ass.nmprimtl.
                                     ELSE
                                         ASSIGN aux_nmprepos = crapavt.nmdavali.
                                 END.
                             END.
                             /* fim - busca dados do preposto */

                         END.
                         END.

                         RUN gera_protocolo IN h-bo_algoritmo_seguranca
                                        (INPUT cratlcm.cdcooper,
                                         INPUT cratlcm.dtmvtolt,
                                         INPUT cratlcm.hrtransa,
                                         INPUT cratlcm.nrdconta,
                                         INPUT cratlcm.nrdocmto,
                                         INPUT aux_nrautdoc,
                                         INPUT cratlcm.vllanmto,
                                         INPUT par_nrdcaixa,
                                         INPUT YES,   /* Gravar crappro */
                                         INPUT IF  par_cdhisdeb = 771  THEN
                                                   4   /* Credito Salario */
                                               ELSE
                                                   1,  /* Transferencia   */
                                         INPUT aux_dsinfor1,
                                         INPUT aux_dsinfor2,
                                         INPUT aux_dsinfor3,
                                         INPUT "",    /* Cedente     */
                                         INPUT par_flagenda,
                                         INPUT par_nrcpfope,
                                         INPUT aux_nrcpfpre,
                                         INPUT aux_nmprepos,
                                        OUTPUT par_dsprotoc,
                                        OUTPUT par_dscritic).
                
                         DELETE PROCEDURE h-bo_algoritmo_seguranca.

                         IF  RETURN-VALUE <> "OK"  THEN
                             UNDO, RETURN "NOK".
                     END.                     
            
                EMPTY TEMP-TABLE crataut.
       
                FIND crapaut WHERE RECID(crapaut) = aux_nrdrecid 
                                   NO-LOCK NO-ERROR.
       
                IF   NOT AVAILABLE crapaut   THEN
                     DO:
                         par_dscritic = "Registro da autenticacao nao " +
                                        "encontrado.".
                         UNDO, RETURN "NOK".
                     END.

                CREATE crataut.
                BUFFER-COPY crapaut TO crataut.
                ASSIGN crataut.dsprotoc = par_dsprotoc.
       
                /* Grava protocolo no registro de autenticacao */
                RUN sistema/generico/procedures/b1crapaut.p
                PERSISTENT SET h-b1crapaut.
           
                IF   VALID-HANDLE(h-b1crapaut)   THEN
                     DO:
                         RUN altera-registro IN h-b1crapaut(INPUT TABLE crataut,
                                                           OUTPUT par_dscritic).

                         DELETE PROCEDURE h-b1crapaut.

                         IF   RETURN-VALUE = "NOK"   THEN
                              UNDO, RETURN "NOK".
                     END.
            END.

       IF   par_cdorigem = 2   OR    /* CASH */
           (par_cdorigem  = 4  AND   /* TAA */
            par_nrterfin <> 0) THEN  
            DO:
                CREATE crapltr.
                ASSIGN crapltr.cdcooper = par_cdcooper
                       crapltr.cdoperad = craptfn.cdoperad
                       crapltr.nrterfin = craptfn.nrterfin
                       crapltr.dtmvtolt = par_dtmvtocd
                       crapltr.nrautdoc = cratlcm.nrautdoc
                       crapltr.nrdconta = cratlcm.nrdconta
                       crapltr.nrdocmto = cratlcm.nrdocmto
                       crapltr.nrsequni = cratlcm.nrsequni
                       crapltr.cdhistor = cratlcm.cdhistor
                       crapltr.vllanmto = cratlcm.vllanmto
                       crapltr.dttransa = TODAY
                       crapltr.hrtransa = cratlcm.hrtransa
                       crapltr.nrcartao = aux_nrcartao
                       crapltr.tpautdoc = 1
                       crapltr.nrestdoc = 0
                       crapltr.cdsuperv = ''.
                VALIDATE crapltr.
            END.


       /* Leitura do lote - novamente */
       /* Revitalizacao - Remocao de lotes
       DO aux_contador = 1 TO 10:
           
          par_dscritic = "".
    
          FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                             craplot.dtmvtolt = par_dtmvtocd   AND
                             craplot.cdagenci = par_cdagenci   AND
                             craplot.cdbccxlt = par_cdbccxlt   AND 
                             craplot.nrdolote = par_nrdolote
                             USE-INDEX craplot1 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
          IF   NOT AVAILABLE craplot   THEN                
               IF   LOCKED craplot   THEN
                    DO:                        
                    ASSIGN par_dscritic = IF par_cdorigem = 3   THEN
                                            "Registro de lote esta sendo " +
                                            "alterado. Tente novamente. " +
                                            "Lote: " + STRING(par_nrdolote)
                                       ELSE     
                                            "991".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
             ELSE
               ASSIGN par_dscritic = "Lote nao cadastrado.".
               
          LEAVE.
          
       END. /* Fim do WHILE */
       
       IF   par_dscritic <> ""   THEN
            UNDO, RETURN "NOK".
       
       /* Atualiza as informações do lote e libera o lock da craplot */
       ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
              craplot.qtcompln = craplot.qtcompln + 1
              /* DEBITO */
              craplot.vlinfodb = craplot.vlinfodb + par_vllanmto
              craplot.vlcompdb = craplot.vlcompdb + par_vllanmto
              /* Sequencia */
              craplot.nrseqdig = craplot.nrseqdig + 1
              aux_nrseqdig     = craplot.nrseqdig.

       FIND CURRENT craplot NO-LOCK NO-ERROR.
       RELEASE craplot.
       */
       
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                          ,INPUT "NRSEQDIG"
                          ,STRING(par_cdcooper) + ";" + STRING(par_dtmvtocd,"99/99/9999") + ";" + STRING(par_cdagenci) + ";" + STRING(par_cdbccxlt) + ";" + STRING(par_nrdolote)
                          ,INPUT "N"
                          ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                    WHEN pc_sequence_progress.pr_sequence <> ?.
       
       IF   par_cdorigem = 3   OR    /* INTERNET */
            par_cdorigem = 4   THEN    /* TAA */
            DO:
                /* Grava uma autenticacao para a transferencia */
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
       
                IF   VALID-HANDLE(h-b1crap00)   THEN 
                     DO:
                         RUN grava-autenticacao IN h-b1crap00 
                                            (INPUT crapcop.nmrescop,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_vllanmto,
                                             INPUT aux_nrseqdig, 
                                             INPUT NO,     /* Credito       */
                                             INPUT "1",    /* On-Line       */
                                             INPUT NO,     /* Estorno       */ 
                                             INPUT par_cdhiscre,
                                             INPUT ?, 
                                             INPUT 0, 
                                             INPUT 0, 
                                             INPUT 0, 
                                            OUTPUT aux_dslitera,
                                            OUTPUT aux_nrautdoc,
                                            OUTPUT aux_nrdrecid).

                         DELETE PROCEDURE h-b1crap00.
                
                         IF   RETURN-VALUE = "NOK"   THEN
                              DO:
                                  par_dscritic = "Erro na autenticacao da " +
                                                 "transferencia.".
                                  UNDO, RETURN "NOK".
                              END.  
                     END. 
            END.
       
       IF   par_cdorigem = 2   OR    /* CASH */
           (par_cdorigem  = 4  AND   /* TAA  */
            par_nrterfin <> 0) THEN  
            DO:
               /* Leitura do terminal  */
               DO aux_contador = 1 TO 10:
                    
                  ASSIGN par_dscritic = "".
                    
                   FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn   AND 
                                      craptfn.nrterfin = par_nrterfin
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                          
                   IF   NOT AVAILABLE craptfn   THEN
                        IF   LOCKED craptfn   THEN
                             DO:
                           ASSIGN par_dscritic = "995".                            
                           PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                        ASSIGN par_dscritic = "Terminal Financeiro nao cadastrado.".
                
                   LEAVE.
                
               END. /* Fim do WHILE */
             
               IF par_dscritic <> "" THEN
                                 UNDO, RETURN "NOK".
                
               ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1.
                
            END.                                                  

       /* Cria o lancamento do CREDITO */
       EMPTY TEMP-TABLE cratlcm.
       CREATE cratlcm.
       ASSIGN cratlcm.cdcooper = par_cdcooper
              cratlcm.dtmvtolt = par_dtmvtocd
              cratlcm.cdagenci = par_cdagenci
              cratlcm.cdbccxlt = par_cdbccxlt
              cratlcm.nrdolote = par_nrdolote
              cratlcm.dtrefere = par_dtmvtocd
              cratlcm.hrtransa = TIME
              cratlcm.cdoperad = par_cdoperad
              cratlcm.nrdconta = INTE(par_nrctatrf)
              cratlcm.nrdctabb = INTE(par_nrctatrf)
              cratlcm.nrdctitg = STRING(par_nrctatrf,"99999999")
              cratlcm.nrseqdig = aux_nrseqdig
              cratlcm.nrdocmto = aux_nrseqdig
              cratlcm.cdhistor = par_cdhiscre
              cratlcm.vllanmto = par_vllanmto
              cratlcm.cdcoptfn = par_cdcoptfn
              cratlcm.cdagetfn = par_cdagetfn
              cratlcm.nrterfin = par_nrterfin
              par_nrdoccre     = cratlcm.nrdocmto
              /* Atencao na alteracao da string pois o termo AGENDADO do * 
               * campo cdpesqbb eh utilizado em regra da BO b1wgen0001,  *
               * na composicao de saldo (procedure obtem-saldo-dia)      */
              cratlcm.cdpesqbb = IF   par_cdorigem = 3 THEN  /* INTERNET */
                                      'INTERNET - TRANSFERENCIA ON-LINE ' + 
                                      '- CONTA    ' +
                                      STRING(par_nrdconta,'99999999') +
                                      (IF  par_flagenda  THEN
                                           " AGENDADO"
                                       ELSE
                                           "")
                                 ELSE 'TAA - TRANSFERENCIA ON-LINE ' + 
                                      '- CONTA         ' +
                                      STRING(par_nrdconta,'99999999') +
                                      (IF  par_flagenda  THEN
                                           " AGENDADO"
                                       ELSE
                                           "").

       /* Para INTERNET ou em caso de TAA executando em BATCH */
       IF  par_cdorigem = 3    OR  /* INTERNET */
          (par_cdorigem = 4    AND /* TAA */
           par_nrterfin = 0)  THEN
           ASSIGN cratlcm.nrsequni = aux_nrseqdig 
                  cratlcm.nrautdoc = aux_nrautdoc.
       ELSE /* TAA execucao on-line */
           ASSIGN cratlcm.nrsequni = par_nrdocmto
                  cratlcm.nrautdoc = craptfn.nrultaut.

       RUN sistema/generico/procedures/b1craplcm.p
           PERSISTENT SET h-b1craplcm.
           
       IF   VALID-HANDLE(h-b1craplcm)   THEN
            DO:
                RUN inclui-registro IN h-b1craplcm (INPUT TABLE cratlcm,
                                                   OUTPUT par_dscritic).
                                                    
                DELETE PROCEDURE h-b1craplcm.
                
                IF   RETURN-VALUE = "NOK"   THEN
                     DO:
                         IF   par_cdorigem = 2   THEN  /* CASH */
                              par_dscritic = "990".
    
                         UNDO, RETURN "NOK".
                     END.    
            END.

       IF   par_cdorigem = 3   THEN  /* INTERNET */
            DO:
                EMPTY TEMP-TABLE crataut.
       
                FIND crapaut WHERE RECID(crapaut) = aux_nrdrecid 
                                   NO-LOCK NO-ERROR.
       
                IF   NOT AVAILABLE crapaut   THEN
                     DO:
                         par_dscritic = "Registro da autenticacao nao " +
                                        "encontrado.".
                         UNDO, RETURN "NOK".
                     END.
            
                CREATE crataut.
                BUFFER-COPY crapaut TO crataut.
                ASSIGN crataut.dsprotoc = par_dsprotoc.
       
                /* Grava protocolo no registro de autenticacao */
                RUN sistema/generico/procedures/b1crapaut.p
                    PERSISTENT SET h-b1crapaut.
           
                IF   VALID-HANDLE(h-b1crapaut)   THEN
                     DO:
                         RUN altera-registro IN h-b1crapaut
                                            (INPUT TABLE crataut,
                                            OUTPUT par_dscritic).

                         DELETE PROCEDURE h-b1crapaut.

                         IF   RETURN-VALUE = "NOK"   THEN
                              UNDO, RETURN "NOK".
                     END.
            END.
       
       /* Leitura do lote - novamente */
       /* Revitalizacao - Remocao de lotes
       DO aux_contador = 1 TO 10:
           
          par_dscritic = "".
    
          FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                             craplot.dtmvtolt = par_dtmvtocd   AND
                             craplot.cdagenci = par_cdagenci   AND
                             craplot.cdbccxlt = par_cdbccxlt   AND 
                             craplot.nrdolote = par_nrdolote
                             USE-INDEX craplot1 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
          IF   NOT AVAILABLE craplot   THEN                
               IF   LOCKED craplot   THEN
                    DO:                        
                    ASSIGN par_dscritic = IF par_cdorigem = 3   THEN
                                            "Registro de lote esta sendo " +
                                            "alterado. Tente novamente. " +
                                            "Lote: " + STRING(par_nrdolote)
                                       ELSE     
                                            "991".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
             ELSE
                ASSIGN par_dscritic = "Lote nao cadastrado.".
                
          LEAVE.
          
       END. /* Fim do WHILE */
       
       IF   par_dscritic <> ""   THEN
            UNDO, RETURN "NOK".
       
       /* Atualiza as informações do lote e libera o lock da craplot */
       ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
              craplot.qtcompln = craplot.qtcompln + 1
              /* CREDITO */
              craplot.vlinfocr = craplot.vlinfocr + par_vllanmto
              craplot.vlcompcr = craplot.vlcompcr + par_vllanmto.

       FIND CURRENT craplot NO-LOCK NO-ERROR.
       RELEASE craplot.
       */
       
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                          ,INPUT "NRSEQDIG"
                          ,STRING(par_cdcooper) + ";" + STRING(par_dtmvtocd,"99/99/9999") + ";" + STRING(par_cdagenci) + ";" + STRING(par_cdbccxlt) + ";" + STRING(par_nrdolote)
                          ,INPUT "N"
                          ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                    WHEN pc_sequence_progress.pr_sequence <> ?.

       IF par_cdorigem = 3 THEN /* INTERNET */
            DO:

                IF crapass.idastcjt = 0 THEN
                    DO:
                        /* Cria o registro do movimento da internet */
                        RUN sistema/generico/procedures/b1crapmvi.p 
                            PERSISTENT SET h-b1crapmvi.
        
                        IF VALID-HANDLE(h-b1crapmvi)  THEN
                             DO:
                                 CREATE cratmvi.
                                 ASSIGN cratmvi.cdcooper = par_cdcooper
                                        cratmvi.cdoperad = par_cdoperad
                                        cratmvi.dtmvtolt = par_dtmvtocd
                                        cratmvi.dttransa = aux_datdodia
                                        cratmvi.hrtransa = TIME
                                        cratmvi.idseqttl = par_idseqttl
                                        cratmvi.nrdconta = par_nrdconta.
                                 
                                 /* Pessoa fisica utiliza mesmo campo na tabela */
                                 /* para transferencias e pagamentos            */
                                 IF   crapass.inpessoa = 1   THEN
                                      ASSIGN cratmvi.vlmovweb = par_vllanmto.
                                 ELSE
                                      ASSIGN cratmvi.vlmovtrf = par_vllanmto.
        
                                 FIND crapmvi WHERE 
                                              crapmvi.cdcooper = cratmvi.cdcooper AND
                                              crapmvi.nrdconta = cratmvi.nrdconta AND
                                              crapmvi.idseqttl = cratmvi.idseqttl AND
                                              crapmvi.dtmvtolt = cratmvi.dtmvtolt 
                                              NO-LOCK NO-ERROR.
                                           
                                 IF   NOT AVAILABLE crapmvi  THEN
                                      RUN inclui-registro IN h-b1crapmvi 
                                                      (INPUT TABLE cratmvi,
                                                      OUTPUT par_dscritic).
                                 ELSE
                                      DO:
                                          ASSIGN cratmvi.vlmovweb = crapmvi.vlmovweb
										         cratmvi.vlmovtrf = crapmvi.vlmovtrf
                                                 cratmvi.vlmovpgo = crapmvi.vlmovpgo
										         cratmvi.vlmovted = crapmvi.vlmovted.
        
                                          IF   crapass.inpessoa = 1   THEN
                                               ASSIGN cratmvi.vlmovweb = 
                                                    cratmvi.vlmovweb + par_vllanmto.
                                          ELSE
                                               ASSIGN cratmvi.vlmovtrf = 
                                                    cratmvi.vlmovtrf + par_vllanmto.
                                                          
                                          RUN altera-registro IN h-b1crapmvi 
                                                          (INPUT TABLE cratmvi,
                                                          OUTPUT par_dscritic).
                                      END.
                            
                                 DELETE PROCEDURE h-b1crapmvi.
                        
                                 IF   RETURN-VALUE = "NOK"   THEN
                                      UNDO, RETURN "NOK".
                             END.
                    END. /* FIM IF crapass.idastcjt = 0 */
                ELSE
                    DO:
                        FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                               crappod.nrdconta = par_nrdconta AND
                                               crappod.cddpoder = 10           AND
                                               crappod.flgconju = TRUE NO-LOCK:

                            EMPTY TEMP-TABLE cratmvi.

                            FOR FIRST crapsnh FIELDS(idseqttl) WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                                                     crapsnh.nrdconta = crappod.nrdconta AND
                                                                     crapsnh.nrcpfcgc = crappod.nrcpfpro AND
                                                                     crapsnh.tpdsenha = 1 NO-LOCK. END.

                                IF AVAIL crapsnh THEN
                                    DO:
                                        /* Cria o registro do movimento da internet */
                                        RUN sistema/generico/procedures/b1crapmvi.p 
                                            PERSISTENT SET h-b1crapmvi.
                        
                                        IF VALID-HANDLE(h-b1crapmvi)  THEN
                                             DO:
                                                 CREATE cratmvi.
                                                 ASSIGN cratmvi.cdcooper = par_cdcooper
                                                        cratmvi.cdoperad = par_cdoperad
                                                        cratmvi.dtmvtolt = par_dtmvtocd
                                                        cratmvi.dttransa = aux_datdodia
                                                        cratmvi.hrtransa = TIME
                                                        cratmvi.idseqttl = crapsnh.idseqttl
                                                        cratmvi.nrdconta = par_nrdconta.
                        
                                                 /* Pessoa fisica utiliza mesmo campo na tabela */
                                                 /* para transferencias e pagamentos            */
                                                 IF   crapass.inpessoa = 1   THEN
                                                      ASSIGN cratmvi.vlmovweb = par_vllanmto.
                                                 ELSE
                                                      ASSIGN cratmvi.vlmovtrf = par_vllanmto.
                        
                                                 FIND crapmvi WHERE 
                                                              crapmvi.cdcooper = cratmvi.cdcooper AND
                                                              crapmvi.nrdconta = cratmvi.nrdconta AND
                                                              crapmvi.idseqttl = cratmvi.idseqttl AND
                                                              crapmvi.dtmvtolt = cratmvi.dtmvtolt 
                                                              NO-LOCK NO-ERROR.
                                                           
                                                 IF   NOT AVAILABLE crapmvi  THEN
                                                      RUN inclui-registro IN h-b1crapmvi 
                                                                      (INPUT TABLE cratmvi,
                                                                      OUTPUT par_dscritic).
                                                 ELSE
                                                      DO:
                                                          ASSIGN cratmvi.vlmovweb = crapmvi.vlmovweb
										                         cratmvi.vlmovtrf = crapmvi.vlmovtrf
                                                                 cratmvi.vlmovpgo = crapmvi.vlmovpgo
											                     cratmvi.vlmovted = crapmvi.vlmovted.
                        
                                                          IF   crapass.inpessoa = 1   THEN
                                                               ASSIGN cratmvi.vlmovweb = 
                                                                    cratmvi.vlmovweb + par_vllanmto.
                                                          ELSE
                                                               ASSIGN cratmvi.vlmovtrf = 
                                                                    cratmvi.vlmovtrf + par_vllanmto.
                                                                          
                                                          RUN altera-registro IN h-b1crapmvi 
                                                                          (INPUT TABLE cratmvi,
                                                                          OUTPUT par_dscritic).
                                                      END.
                                            
                                                 DELETE PROCEDURE h-b1crapmvi.
                                        
                                                 IF   RETURN-VALUE = "NOK"   THEN
                                                      UNDO, RETURN "NOK".
                                             END.
                                    END. /* If avail crapsnh */
                        END. /* Fim for each crappod */        
                    END.
					
				FIND FIRST crapprm WHERE crapprm.cdcooper = par_cdcooper AND 
										 crapprm.nmsistem = 'CRED' 		 AND 
										 crapprm.cdacesso = 'FOLHAIB_TARI_TRF_TPSAL'
										 NO-LOCK NO-ERROR.
										 
				IF  crapprm.dsvlrprm = "1" AND /*Credito Salario*/
					par_cdhisdeb     = 771 THEN /*Tarifa = Sim*/
					DO:						
						FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
						
						RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
						
						IF  NOT VALID-HANDLE(h-b1wgen0153)  THEN
							DO: 						
								ASSIGN par_dscritic = "Nao foi possivel carregar a tarifa.".
								RETURN "NOK".
							END.
						
						RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
														(INPUT par_cdcooper,
														 INPUT 'TRANSTPSAL',
														 INPUT par_vllanmto,
														 INPUT "b1wgen0015", /* cdprogra */
														OUTPUT aux_cdhistor,
														OUTPUT aux_cdhisest,
														OUTPUT aux_vltarifa,
														OUTPUT aux_dtdivulg,
														OUTPUT aux_dtvigenc,
														OUTPUT aux_cdfvlcop,
														OUTPUT TABLE tt-erro).
						
						IF  RETURN-VALUE <> "OK"  THEN
							DO:
								DELETE PROCEDURE h-b1wgen0153.
								
								FIND FIRST tt-erro NO-LOCK NO-ERROR.

								IF  AVAIL tt-erro  THEN
									ASSIGN par_dscritic = tt-erro.dscritic.
								ELSE
									ASSIGN par_dscritic = "Nao foi possivel carregar a tarifa.".

								RETURN "NOK".
							END.
						
						RUN cria_lan_auto_tarifa IN h-b1wgen0153
											    (INPUT par_cdcooper,
												 INPUT par_nrdconta,           
												 INPUT par_dtmvtocd,
												 INPUT aux_cdhistor, 
												 INPUT aux_vltarifa,
												 INPUT '1',			                                      /* cdoperad */
												 INPUT 1,                                                 /* cdagenci */
												 INPUT 100,                                               /* cdbccxlt */         
												 INPUT 10299,                              				  /* nrdolote */        
												 INPUT 18,                                                /* tpdolote */         
												 INPUT aux_nrseqdig,                                      /* nrdocmto */
												 INPUT par_nrdconta,                                  	  /* nrdconta */
												 INPUT STRING(par_nrdconta,"99999999"),                   /* nrdctitg */
												 INPUT "Fato gerador tarifa:" + STRING(aux_nrseqdig),     /* cdpesqbb */
												 INPUT 0,                                                 /* cdbanchq */
												 INPUT 0,                                                 /* cdagechq */
												 INPUT 0,                                                 /* nrctachq */
												 INPUT FALSE,                                             /* flgaviso */
												 INPUT 0,                                                 /* tpdaviso */
												 INPUT aux_cdfvlcop,                                      /* cdfvlcop */
												 INPUT crapdat.inproces,                                  /* inproces */
												OUTPUT TABLE tt-erro).
						
						IF  RETURN-VALUE <> "OK"  THEN
							DO:
								DELETE PROCEDURE h-b1wgen0153.
								
								FIND FIRST tt-erro NO-LOCK NO-ERROR.

								IF  AVAIL tt-erro  THEN
									ASSIGN par_dscritic = tt-erro.dscritic.
								ELSE
									ASSIGN par_dscritic = "Nao foi possivel lancar a tarifa.".

								RETURN "NOK".
							END.
						
						DELETE PROCEDURE h-b1wgen0153.
						
					END.
										
            END. /* Fim IF origem = 3 */
            
    END. /* Fim do DO TRANSACTION */

    /* GERAÇAO DE LOG lançamento ORIGEM */    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_gera_log_ope_cartao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,     /* Código da Cooperativa */
                                 INPUT par_nrdconta,     /* Numero da Conta */ 
                                 INPUT 4,                /* Transferencia */
                                 INPUT IF  par_flmobile = 1 THEN 9 ELSE par_cdorigem,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */ 
                                 INPUT par_idtipcar,
                                 INPUT par_nrdocdeb,     /* Nrd Documento */               
                                 INPUT par_cdhisdeb,     /* HIST Debito */
                                 INPUT STRING(par_nrcartao),
                                 INPUT par_vllanmto,
                                 INPUT par_cdoperad,     /* Código do Operador */
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT par_cdagenci,
                                 INPUT 0,
                                 INPUT "",
                                 INPUT 0,                                 
                                OUTPUT "").              /* Descrição da crítica */

    /* Código da crítica */    
    CLOSE STORED-PROC pc_gera_log_ope_cartao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""           
           aux_dscritic = pc_gera_log_ope_cartao.pr_dscritic
                          WHEN pc_gera_log_ope_cartao.pr_dscritic <> ?.
                          
    IF (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
      DO:
         ASSIGN par_dscritic = aux_dscritic.
         RETURN "NOK".            
      END.    

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE executa-transferencia-intercooperativa:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_idagenda AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdagectl LIKE crapcti.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf AS   INTE                         NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto             NO-UNDO.
    DEF  INPUT PARAM par_nrsequni AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idtipcar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdocmto AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdoccre AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdlantar LIKE craplat.cdlantar             NO-UNDO.

    DEF VAR aux_nmextttl LIKE crapttl.nmextttl                      NO-UNDO.
    DEF VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprepos AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR par_recidcre AS RECID                                   NO-UNDO.
    DEF VAR par_reciddeb AS RECID                                   NO-UNDO.
    DEF VAR par_literala AS CHAR                                    NO-UNDO.
    DEF VAR par_ultsequa AS INTE                                    NO-UNDO.
    DEF VAR par_nrultaut AS INTE                                    NO-UNDO.

    DEF VAR h-b1crap22               AS HANDLE                      NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabcop FOR crapcop.
    
    TRANS_INTER:
    DO TRANSACTION ON ENDKEY UNDO TRANS_INTER, LEAVE TRANS_INTER
                   ON ERROR  UNDO TRANS_INTER, LEAVE TRANS_INTER
                   ON STOP   UNDO TRANS_INTER, LEAVE TRANS_INTER:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapcop  THEN
            DO:
                ASSIGN par_dscritic = 
                    "Registro de cooperativa origem nao encontrado.".
                UNDO TRANS_INTER, LEAVE TRANS_INTER.
            END.    
    
        FIND crabcop WHERE crabcop.cdagectl = par_cdagectl NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crabcop  THEN
            DO:
                ASSIGN par_dscritic = 
                    "Registro de cooperativa destino nao encontrado.".
                UNDO TRANS_INTER, LEAVE TRANS_INTER.
            END. 
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN par_dscritic = "Associado origem nao cadastrado.".
                UNDO TRANS_INTER, LEAVE TRANS_INTER.
            END.

        IF  crapass.inpessoa = 1  THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl 
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapttl  THEN
                    DO:
                        ASSIGN par_dscritic = "Titular nao cadastrado.".
                        UNDO TRANS_INTER, LEAVE TRANS_INTER.
                    END.
    
                ASSIGN aux_nmextttl = crapttl.nmextttl
                       aux_nrcpfcgc = crapttl.nrcpfcgc.
            END.
        ELSE
            DO:
                ASSIGN aux_nmextttl = crapass.nmprimtl
                       aux_nrcpfcgc = crapass.nrcpfcgc.
        
                IF  par_idorigem = 3  THEN /* Internet */
                    DO:
                        FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                           crapsnh.nrdconta = par_nrdconta AND
                                           crapsnh.idseqttl = par_idseqttl AND 
                                           crapsnh.tpdsenha = 1            
                                           NO-LOCK NO-ERROR.
                
                        IF  NOT AVAIL crapsnh  THEN
                            DO:
                                ASSIGN par_dscritic = "Senha para conta on-line nao cadastrada".
                                UNDO TRANS_INTER, LEAVE TRANS_INTER.
                            END.
                
                        /* Busca dados preposto apenas quando nao possui assinatura conjunta */
                        IF crapass.idastcjt = 0 THEN
                            DO:
                    
                                FIND crapavt WHERE crapavt.cdcooper = crapsnh.cdcooper AND
                                                   crapavt.nrdconta = crapsnh.nrdconta AND
                                                   crapavt.tpctrato = 6                AND
                                                   crapavt.nrcpfcgc = crapsnh.nrcpfcgc
                                                   NO-LOCK NO-ERROR.
                
                                IF  AVAIL crapavt  THEN
                                    DO:
                                        FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                                                           crabass.nrdconta = crapavt.nrdctato
                                                           NO-LOCK NO-ERROR.
                                      
                                        IF  AVAILABLE crabass  THEN
                                            ASSIGN aux_nmprepos = crabass.nmprimtl.
                                        ELSE
                                            ASSIGN aux_nmprepos = crapavt.nmdavali.
                                    END.
                            END.
                    END.
            END.

        /* Conta destino */
        FIND crabass WHERE crabass.cdcooper = crabcop.cdcooper AND
                           crabass.nrdconta = par_nrctatrf     NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabass   THEN
             DO:
                 ASSIGN par_dscritic = "Conta destino nao cadastrada.".
                 UNDO TRANS_INTER, LEAVE TRANS_INTER.
             END.
        
        IF  par_idorigem = 3  THEN  /* Internet */
            DO:
                /** Armazenar movimentacao da conta **/
                DO aux_contador = 1 TO 10:
                
                   IF crapass.idastcjt = 0 THEN
                    DO:
                        FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                                           crapmvi.nrdconta = par_nrdconta AND
                                           crapmvi.idseqttl = par_idseqttl AND
                                           crapmvi.dtmvtolt = par_dtmvtolt 
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF NOT AVAILABLE crapmvi THEN
                           DO:
                               IF  LOCKED crapmvi THEN
                                   DO:
                                       IF  aux_contador = 10  THEN
                                           DO:
                                               ASSIGN par_dscritic = "Registro de " +
                                                      "movimentacao esta sendo alterado.".
                                               UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                           END.
                       
                                       PAUSE 1 NO-MESSAGE.
                                       NEXT.
                                   END.
                               ELSE
                                   DO:
                                       CREATE crapmvi.
                                       ASSIGN crapmvi.cdcooper = par_cdcooper
                                              crapmvi.cdoperad = par_cdoperad
                                              crapmvi.dtmvtolt = par_dtmvtolt
                                              crapmvi.dttransa = aux_datdodia
                                              crapmvi.hrtransa = TIME
                                              crapmvi.idseqttl = par_idseqttl
                                              crapmvi.nrdconta = par_nrdconta.
                                       VALIDATE crapmvi.

                                       IF  crapass.inpessoa = 1  THEN
                                           ASSIGN crapmvi.vlmovweb = par_vllanmto.
                                       ELSE
                                           ASSIGN crapmvi.vlmovtrf = par_vllanmto.
                                       VALIDATE crapmvi.
                                   END.
                           END.
                       ELSE
                           DO:     
                               IF  crapass.inpessoa = 1  THEN
                                   ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb + 
                                                             par_vllanmto.
                               ELSE
                                   ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf +
                                                             par_vllanmto.
                               VALIDATE crapmvi.
                           END. 
                    END.
                   ELSE
                    DO:
                       FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                              crappod.nrdconta = par_nrdconta AND
                                              crappod.cddpoder = 10           AND
                                              crappod.flgconju = TRUE NO-LOCK:

                            FOR FIRST crapsnh FIELDS(idseqttl) WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                                                     crapsnh.nrdconta = crappod.nrdconta AND
                                                                     crapsnh.nrcpfcgc = crappod.nrcpfpro AND
                                                                     crapsnh.tpdsenha = 1 NO-LOCK. END.

                                IF AVAIL crapsnh THEN
                                    DO:
                                        FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper     AND
                                                           crapmvi.nrdconta = par_nrdconta     AND
                                                           crapmvi.idseqttl = crapsnh.idseqttl AND
                                                           crapmvi.dtmvtolt = par_dtmvtolt 
                                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                                        IF NOT AVAILABLE crapmvi THEN
                                           DO:
                                               IF  LOCKED crapmvi THEN
                                                   DO:
                                                       IF  aux_contador = 10  THEN
                                                           DO:
                                                               ASSIGN par_dscritic = "Registro de " +
                                                                      "movimentacao esta sendo alterado.".
                                                               UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                                           END.
                                       
                                                       PAUSE 1 NO-MESSAGE.
                                                       NEXT.
                                                   END.
                                               ELSE
                                                   DO:
                                                       CREATE crapmvi.
                                                       ASSIGN crapmvi.cdcooper = par_cdcooper
                                                              crapmvi.cdoperad = par_cdoperad
                                                              crapmvi.dtmvtolt = par_dtmvtolt
                                                              crapmvi.dttransa = aux_datdodia
                                                              crapmvi.hrtransa = TIME
                                                              crapmvi.idseqttl = crapsnh.idseqttl
                                                              crapmvi.nrdconta = par_nrdconta.
                                                       VALIDATE crapmvi.
                                                       IF  crapass.inpessoa = 1  THEN
                                                           ASSIGN crapmvi.vlmovweb = par_vllanmto.
                                                       ELSE
                                                           ASSIGN crapmvi.vlmovtrf = par_vllanmto.
                                                       VALIDATE crapmvi.
                                                   END.
                                           END.
                                       ELSE
                                           DO:     
                                               IF  crapass.inpessoa = 1  THEN
                                                   ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb + 
                                                                             par_vllanmto.
                                               ELSE
                                                   ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf +
                                                                             par_vllanmto.
                                               VALIDATE crapmvi.
                                           END. 
                                    END.
                       END.
                    END.

                   LEAVE.

                END. /** Fim do DO ... TO **/
            END.

        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
    
        IF  NOT VALID-HANDLE(h-b1crap22)  THEN
            DO:
                ASSIGN par_dscritic = "Handle invalido para BO b1crap22.".
                UNDO TRANS_INTER, LEAVE TRANS_INTER.
            END.
        
        RUN realiza-transferencia IN h-b1crap22
                                 (INPUT crapcop.nmrescop, /* Coop origem  */
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_idorigem,
                                  INPUT crabcop.nmrescop, /* Coop dest.   */
                                  INPUT par_nrdconta,     /* Conta origem */
                                  INPUT par_idseqttl,     /* Id. origem   */
                                  INPUT par_nrctatrf,     /* Conta dest.  */
                                  INPUT par_vllanmto,
                                  INPUT par_nrsequni,
                                  INPUT par_idagenda,
                                  INPUT par_cdcoptfn,
                                  INPUT par_nrterfin,
                                  INPUT par_idtipcar,
                                  INPUT "",
                                  INPUT "",
                                  INPUT par_nrcartao,                                  
                                 OUTPUT par_literala,
                                 OUTPUT par_ultsequa,
                                 OUTPUT par_nrdocmto, /* Dcmto Debt. */
                                 OUTPUT par_nrdoccre, /* Dcmto Cred. */
                                 OUTPUT par_cdlantar,
                                 OUTPUT par_reciddeb,
                                 OUTPUT par_recidcre,
                                 OUTPUT par_nrultaut).
    
        DELETE PROCEDURE h-b1crap22.
        
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST craperr WHERE craperr.cdcooper = par_cdcooper AND
                                         craperr.cdagenci = par_cdagenci AND
                                         craperr.nrdcaixa = 
                                                INTE(STRING(par_nrdconta) +
                                                     STRING(par_idseqttl))
                                          NO-LOCK NO-ERROR.
                                          
                IF  AVAILABLE craperr  THEN
                    ASSIGN par_dscritic = craperr.dscritic.
                ELSE
                    ASSIGN par_dscritic = "Nao foi possivel executar a transferencia.".
                      
                UNDO TRANS_INTER, LEAVE TRANS_INTER.
            END.

        /** Protocolo **/
        IF  par_idorigem = 3  OR     /* INTERNET */
           (par_idorigem = 4  AND    /* TAA */
            par_nrterfin <> 0) THEN  
            DO:
                DO aux_contador = 1 TO 10:
        
                    FIND crapaut WHERE RECID(crapaut) = par_reciddeb 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAIL crapaut  THEN
                        DO:
                            IF  LOCKED crapaut  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            ASSIGN par_dscritic = "Registro de " +
                                                   "autenticacao esta sendo alterado.".
                                            UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                        END.
        
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN par_dscritic = "Registro de " +
                                                          "autenticacao nao encontrado.".
                                    UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                END.
                        END.
        
                    LEAVE.
        
                END. /** Fim do DO ... TO **/
        
                IF  par_idorigem = 4 AND par_nrterfin <> 0  THEN   /* TAA */ 
                    DO:
                        FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn AND 
                                           craptfn.nrterfin = par_nrterfin
                                           NO-LOCK NO-ERROR.
                                                
                        IF  NOT AVAILABLE craptfn   THEN
                            DO:
                                par_dscritic = "Terminal financeiro nao cadastrado.". 
                                UNDO TRANS_INTER, LEAVE TRANS_INTER.
                            END.
                     END.
        
                ASSIGN aux_dsinfor1 = "Transferencia"
                       aux_dsinfor2 = aux_nmextttl + "#"   + 
                                      "Conta/dv Destino: " + 
                                      STRING(par_nrctatrf,"zzzz,zzz,9") + " - " + 
                                      crabass.nmprimtl     + 
                                      "#" + STRING(crabcop.cdagectl,"9999") + 
                                      " - " + crabcop.nmrescop
        
                       aux_dsinfor3 = IF   AVAIL craptfn    THEN
                                           "TAA: " + 
                                           STRING(craptfn.cdcooper,"9999") +
                                                  "/"     +
                                           STRING(craptfn.cdagenci,"9999") +
                                                  "/"     +
                                           STRING(craptfn.nrterfin,"9999")
                                      ELSE
                                           "".
                                    
                RUN sistema/generico/procedures/bo_algoritmo_seguranca.p PERSISTENT 
                    SET h-bo_algoritmo_seguranca.
        
                IF  NOT VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO.".
                        UNDO TRANS_INTER, LEAVE TRANS_INTER.
                    END.
        
                RUN gera_protocolo IN h-bo_algoritmo_seguranca
                                  (INPUT par_cdcooper,
                                   INPUT crapaut.dtmvtolt,
                                   INPUT crapaut.hrautent,
                                   INPUT par_nrdconta,
                                   INPUT par_nrdocmto,
                                   INPUT crapaut.nrsequen,
                                   INPUT par_vllanmto,
                                   INPUT crapaut.nrdcaixa,
                                   INPUT YES,   /** Gravar crappro **/
                                   INPUT 1,     /** Tipo Protocolo **/
                                   INPUT aux_dsinfor1,
                                   INPUT aux_dsinfor2,
                                   INPUT aux_dsinfor3,
                                   INPUT "",    /** Cedente        **/ 
                                   INPUT IF par_idagenda >= 2 THEN TRUE ELSE FALSE, /** Agendamento    **/
                                   INPUT par_nrcpfope,
                                   INPUT IF AVAIL crapsnh THEN crapsnh.nrcpfcgc ELSE 0,
                                   INPUT aux_nmprepos,
                                  OUTPUT par_dsprotoc,
                                  OUTPUT par_dscritic).
                                     
                DELETE PROCEDURE h-bo_algoritmo_seguranca.
        
                IF  RETURN-VALUE <> "OK"  THEN
                    UNDO TRANS_INTER, LEAVE TRANS_INTER.
        
                /** Armazena protocolo na autenticacao **/
                ASSIGN crapaut.dsprotoc = par_dsprotoc.
        
                /** Protocolo para registro na tabela craplcm **/
                DO aux_contador = 1 TO 10:
        
                    FIND crapaut WHERE RECID(crapaut) = par_recidcre 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAIL crapaut  THEN
                        DO:
                            IF  LOCKED crapaut  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            ASSIGN par_dscritic = "Registro de " +
                                                   "autenticacao esta sendo alterado.".
                                            UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                        END.
        
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN par_dscritic = "Registro de " +
                                                          "autenticacao nao encontrado.".
                                    UNDO TRANS_INTER, LEAVE TRANS_INTER.
                                END.
                        END.
                    ELSE
                        /** Armazena protocolo na autenticacao **/
                        ASSIGN crapaut.dsprotoc = par_dsprotoc.
        
                    LEAVE.
        
                END. /** Fim do DO ... TO **/
        
                IF (par_idorigem  = 4  AND   /* TAA */
                    par_nrterfin <> 0) THEN  
                    DO: 
                        RUN grava-crapltr (INPUT par_cdcooper,
                                           INPUT craptfn.cdoperad,
                                           INPUT craptfn.nrterfin,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrultaut,
                                           INPUT par_nrdconta,
                                           INPUT par_nrdocmto,
                                           INPUT par_nrsequni, 
                                           INPUT 1009, /* cdhistor */ 
                                           INPUT par_vllanmto).  
        
                        IF  RETURN-VALUE <> "OK"   THEN
                            UNDO TRANS_INTER, LEAVE TRANS_INTER.
                    END.
            END.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANS_INTER **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  par_dscritic = ""  THEN
                ASSIGN par_dscritic = 
                    "Nao foi possivel efetuar a transferencia.".

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/** Procedure para estornar transferencia intracooperativa efetuada Internet **/
/******************************************************************************/
PROCEDURE estorna-transferencia:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtocd LIKE crapdat.dtmvtocd             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplot.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrctadst LIKE craplau.nrctadst             NO-UNDO.
    DEF  INPUT PARAM par_cdhisdeb LIKE craplcm.cdhistor             NO-UNDO.
    DEF  INPUT PARAM par_cdhiscre LIKE craplcm.cdhistor             NO-UNDO.
    DEF  INPUT PARAM par_nrdocdeb LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_nrdoccre LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc AS CHAR                           NO-UNDO.

    DEF VAR aux_dslitera AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_sequenci AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INT                                     NO-UNDO.
    
    DEF VAR aux_nrdrecid AS RECID                                   NO-UNDO.

    DEF VAR h-b1crap00   AS HANDLE                                  NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.
    
    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    
    DEF BUFFER crablcm FOR craplcm.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Cooperativa nao cadastrada.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
        /** Busca registro do lote das transferencias **/
        /* Revitalizacao - Remocao de Lotes
        DO aux_contador = 1 TO 10:

            ASSIGN par_dscritic = "".
        
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtocd AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = 11           AND
                               craplot.nrdolote = 11000 + par_nrdcaixa
                               USE-INDEX craplot1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN par_dscritic = "O lote de debito esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN par_dscritic = "Lote nao cadastrado.". 
                END.
                               
            LEAVE.
                              
        END.*/
        /** Fim do DO ... TO **/
                                      
        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".

        /** Busca registro de lancamento do debito da transferencia **/
        FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.nrdconta = par_nrdconta AND
                           craplcm.dtmvtolt = par_dtmvtocd AND
                           craplcm.cdhistor = par_cdhisdeb AND
                           craplcm.nrdocmto = par_nrdocdeb 
                           USE-INDEX craplcm2 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craplcm  THEN
            DO:
                ASSIGN par_dscritic = "Lancamento do debito nao encontrado.".
                UNDO, RETURN "NOK".
            END.

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        
        IF  NOT VALID-HANDLE(h-b1crap00)  THEN
            DO:
                ASSIGN par_dscritic = "Handle invalido para BO b1crap00.".
                UNDO, RETURN "NOK".
            END.

        /** Grava autenticacao do estorno do debito da transferencia **/
        RUN grava-autenticacao IN h-b1crap00 (INPUT crapcop.nmrescop,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT craplcm.vllanmto,
                                              INPUT craplcm.nrdocmto, 
                                              INPUT YES, /** Debito/Credito **/
                                              INPUT "1", /** Status         **/
                                              INPUT YES, /** Estorno        **/
                                              INPUT craplcm.cdhistor, 
                                              INPUT ?, /** Data off-line    **/ 
                                              INPUT 0, /** Seq off-line     **/
                                              INPUT 0, /** Hora off-line    **/
                                              INPUT 0, /** Seq.Org.Off-line **/
                                             OUTPUT aux_dslitera,
                                             OUTPUT aux_sequenci,
                                             OUTPUT aux_nrdrecid).

        DELETE PROCEDURE h-b1crap00.
             
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN par_dscritic = "Nao foi possivel estornar autenticacao" +
                                      " do debito.".
                UNDO, RETURN "NOK".
            END.

        /* Para TAA nao faz estorno de protocolo */
        IF  par_cdagenci <> 91  THEN
            DO:
                /** Estornar protocolo da transferencia **/
                RUN sistema/generico/procedures/bo_algoritmo_seguranca.p
                    PERSISTENT SET h-bo_algoritmo_seguranca.
                    
                IF  NOT VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
                    DO:
                        ASSIGN par_dscritic = "Handle invalido para BO".
                        UNDO, RETURN "NOK".
                    END.
                                                                          
                RUN estorna_protocolo IN h-bo_algoritmo_seguranca 
                                     (INPUT par_cdcooper,
                                      INPUT par_dtmvtocd,
                                      INPUT par_nrdconta,
                                      INPUT IF  par_cdhisdeb = 771  THEN
                                                4  /** Credito Salario **/
                                            ELSE    
                                                1, /** Transferencia   **/
                                      INPUT par_nrdocdeb,
                                      INPUT par_cdoperad,
                                     OUTPUT par_dsprotoc).
                                                                            
                DELETE PROCEDURE h-bo_algoritmo_seguranca.
                         
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN par_dscritic = "Nao foi possivel estornar o protocolo.".
                        UNDO, RETURN "NOK".
                    END.
                
                /** Retirar lancamento do valor total de movimentos do dia **/
                DO aux_contador = 1 TO 10:
                
                    ASSIGN par_dscritic = "".
                    
                    IF crapass.idastcjt = 0 THEN
                        DO:
                            FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                                               crapmvi.nrdconta = par_nrdconta AND
                                               crapmvi.idseqttl = par_idseqttl AND
                                               crapmvi.dtmvtolt = par_dtmvtocd
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF NOT AVAILABLE crapmvi  THEN
                               DO:
                                   IF  LOCKED crapmvi  THEN
                                       DO:
                                           ASSIGN par_dscritic = "Registro de movimento " +
                                                                 "esta sendo alterado. Tente" +
                                                                 " novamente.".
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT.
                                       END.
                                   ELSE
                                       ASSIGN par_dscritic = "Registro de movimento nao " +
                                                             "encontrado.".
                               END.
                           ELSE              
                               DO:
                                   IF  crapass.inpessoa = 1  THEN
                                       ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb - 
                                                                 craplcm.vllanmto.
                                   ELSE
                                       ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf -
                                                                 craplcm.vllanmto.

                                   VALIDATE crapmvi.
                                END.
                        END.
                    ELSE
                        DO:
                            FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                   crappod.nrdconta = par_nrdconta AND
                                                   crappod.cddpoder = 10           AND
                                                   crappod.flgconju = TRUE NO-LOCK:

                                FOR FIRST crapsnh FIELDS(idseqttl) WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                                                         crapsnh.nrdconta = crappod.nrdconta AND
                                                                         crapsnh.nrcpfcgc = crappod.nrcpfpro AND
                                                                         crapsnh.tpdsenha = 1 NO-LOCK. END.
    
                                    IF AVAIL crapsnh THEN
                                        DO:
                                            FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                                                               crapmvi.nrdconta = par_nrdconta AND
                                                               crapmvi.idseqttl = crapsnh.idseqttl AND
                                                               crapmvi.dtmvtolt = par_dtmvtocd
                                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                            IF NOT AVAILABLE crapmvi  THEN
                                               DO:
                                                   IF  LOCKED crapmvi  THEN
                                                       DO:
                                                           ASSIGN par_dscritic = "Registro de movimento " +
                                                                                 "esta sendo alterado. Tente" +
                                                                                 " novamente.".
                                                           PAUSE 1 NO-MESSAGE.
                                                           NEXT.
                                                       END.
                                                   ELSE
                                                       ASSIGN par_dscritic = "Registro de movimento nao " +
                                                                             "encontrado.".
                                               END.
                                           ELSE              
                                               DO:
                                                   IF crapass.inpessoa = 1 THEN
                                                       ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb - 
                                                                                 craplcm.vllanmto.
                                                   ELSE
                                                       ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf -
                                                                                 craplcm.vllanmto.

                                                   VALIDATE crapmvi.
                                                END.

                                        END. /* Fim Avail Crapsnh */

                            END. /* Fim For Each crappod */
                        END.
                          
                    LEAVE.    
                
                END. /** Fim do DO ... TO **/
            END.

        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".
            
        /** Atualiza registro do lote **/
        /* Revitalizacao - Remocao de Lotes
        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1
               /** CREDITO ESTORNO **/
               craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
        */
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                            ,INPUT "NRSEQDIG"
                                            ,STRING(par_cdcooper) + ";" + STRING(par_dtmvtocd,"99/99/9999") + ";" + STRING(par_cdagenci) + ";11;" + STRING(11000 + par_nrdcaixa)
                                            ,INPUT "N"
                                            ,"").

        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.
        
        /** Cria lancamento para credito do estorno da transferencia **/
        IF  par_cdhisdeb = 537  THEN
            ASSIGN aux_cdhistor = 567.
                                  ELSE
                                  IF  par_cdhisdeb = 538  THEN
            ASSIGN aux_cdhistor = 568.
                                  ELSE
            ASSIGN aux_cdhistor = 773.
       
        /* BLOCO DA INSERÇAO DA CRAPLCM */
      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
          PERSISTENT SET h-b1wgen0200.

      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
        (INPUT par_dtmvtocd                   /* par_dtmvtolt */
        ,INPUT par_cdagenci                   /* par_cdagenci */
        ,INPUT 11                             /* par_cdbccxlt */
        ,INPUT (11000 + par_nrdcaixa)         /* par_nrdolote */
        ,INPUT par_nrdconta                   /* par_nrdconta */
        ,INPUT aux_nrseqdig                   /* par_nrdocmto */
        ,INPUT aux_cdhistor                   /* par_cdhistor */
        ,INPUT aux_nrseqdig                   /* par_nrseqdig */
        ,INPUT craplcm.vllanmto               /* par_vllanmto */
        ,INPUT par_nrdconta                   /* par_nrdctabb */
        ,INPUT "INTERNET - ESTORNO TRANSFERENCIA ON-LINE " + "- CONTA " + STRING(par_nrctadst,"99999999") /* par_cdpesqbb */
        ,INPUT 0                              /* par_vldoipmf */
        ,INPUT aux_sequenci                   /* par_nrautdoc */
        ,INPUT aux_nrseqdig                   /* par_nrsequni */
        ,INPUT 0                              /* par_cdbanchq */
        ,INPUT 0                              /* par_cdcmpchq */
        ,INPUT 0                              /* par_cdagechq */
        ,INPUT 0                              /* par_nrctachq */
        ,INPUT 0                              /* par_nrlotchq */
        ,INPUT 0                              /* par_sqlotchq */
        ,INPUT par_dtmvtocd                   /* par_dtrefere */
        ,INPUT TIME                           /* par_hrtransa */
        ,INPUT par_cdoperad                   /* par_cdoperad */
        ,INPUT 0                              /* par_dsidenti */
        ,INPUT par_cdcooper                   /* par_cdcooper */
        ,INPUT STRING(par_nrdconta,"99999999")/* par_nrdctitg */
        ,INPUT ""                             /* par_dscedent */
        ,INPUT 0                              /* par_cdcoptfn */
        ,INPUT 0                              /* par_cdagetfn */
        ,INPUT 0                              /* par_nrterfin */
        ,INPUT 0                              /* par_nrparepr */
        ,INPUT 0                              /* par_nrseqava */
        ,INPUT 0                              /* par_nraplica */
        ,INPUT 0                              /* par_cdorigem */
        ,INPUT 0                              /* par_idlautom */
        /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
        ,INPUT 0                              /* Processa lote                                 */
        ,INPUT 0                              /* Tipo de lote a movimentar                     */
        /* CAMPOS DE SAÍDA                                                                     */                                            
        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
        ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
        ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
        ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
        DO:  
            ASSIGN par_dscritic = aux_dscritic.
            UNDO, RETURN "NOK".
        END.   
        
        IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.


        /** Busca registro de lancamento do credito da transferencia **/
        FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.nrdconta = par_nrctadst AND
                           craplcm.dtmvtolt = par_dtmvtocd AND
                           craplcm.cdhistor = par_cdhiscre AND
                           craplcm.nrdocmto = par_nrdoccre 
                           USE-INDEX craplcm2 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craplcm  THEN
            DO:
                ASSIGN par_dscritic = "Lancamento do credito nao encontrado.".
                RETURN "NOK".
            END.
            
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        
        IF  NOT VALID-HANDLE(h-b1crap00)  THEN
            DO:
                ASSIGN par_dscritic = "Handle invalido para BO b1crap00.".
                UNDO, RETURN "NOK".
            END.

        /** Grava autenticacao do estorno do debito da transferencia **/
        RUN grava-autenticacao IN h-b1crap00 (INPUT crapcop.nmrescop,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT craplcm.vllanmto,
                                              INPUT craplcm.nrdocmto, 
                                              INPUT NO,  /** Debito/Credito **/
                                              INPUT "1", /** Status         **/
                                              INPUT YES, /** Estorno        **/
                                              INPUT craplcm.cdhistor, 
                                              INPUT ?, /** Data off-line    **/ 
                                              INPUT 0, /** Seq off-line     **/
                                              INPUT 0, /** Hora off-line    **/
                                              INPUT 0, /** Seq.Org.Off-line **/
                                             OUTPUT aux_dslitera,
                                             OUTPUT aux_sequenci,
                                             OUTPUT aux_nrdrecid).

        DELETE PROCEDURE h-b1crap00.
             
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN par_dscritic = "Nao foi possivel estornar autenticacao" +
                                      " do credito.".
                UNDO, RETURN "NOK".
            END.            

        /** Atualiza registro do lote **/
        /* Revitalizacao - Remocao de Lotes
        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1
               /** DEBITO ESTORNO **/
               craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
        */
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                            ,INPUT "NRSEQDIG"
                                            ,STRING(par_cdcooper) + ";" + STRING(par_dtmvtocd,"99/99/9999") + ";" + STRING(par_cdagenci) + ";11;" + STRING(11000 + par_nrdcaixa)
                                            ,INPUT "N"
                                            ,"").
 
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.
        
        IF  par_cdhiscre = 539  THEN
                  ASSIGN aux_cdhistor = 569.
                                  ELSE
                  ASSIGN aux_cdhistor = 774.
        
                    /* BLOCO DA INSERÇAO DA CRAPLCM */
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
            PERSISTENT SET h-b1wgen0200.

            RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
            (INPUT par_dtmvtocd                   /* par_dtmvtolt */
            ,INPUT par_cdagenci                   /* par_cdagenci */
            ,INPUT 11                             /* par_cdbccxlt */
            ,INPUT (11000 + par_nrdcaixa)         /* par_nrdolote */
            ,INPUT par_nrctadst                   /* par_nrdconta */
            ,INPUT aux_nrseqdig                   /* par_nrdocmto */
            ,INPUT aux_cdhistor                   /* par_cdhistor */
            ,INPUT aux_nrseqdig                   /* par_nrseqdig */
            ,INPUT craplcm.vllanmto               /* par_vllanmto */
            ,INPUT par_nrctadst                   /* par_nrdctabb */
            ,INPUT "INTERNET - ESTORNO TRANSFERENCIA ON-LINE " + "- CONTA " + STRING(par_nrdconta,"99999999")/* par_cdpesqbb */
            ,INPUT 0                              /* par_vldoipmf */
            ,INPUT aux_sequenci                   /* par_nrautdoc */
            ,INPUT aux_nrseqdig                   /* par_nrsequni */
            ,INPUT 0                              /* par_cdbanchq */
            ,INPUT 0                              /* par_cdcmpchq */
            ,INPUT 0                              /* par_cdagechq */
            ,INPUT 0                              /* par_nrctachq */
            ,INPUT 0                              /* par_nrlotchq */
            ,INPUT 0                              /* par_sqlotchq */
            ,INPUT par_dtmvtocd                   /* par_dtrefere */
            ,INPUT TIME                           /* par_hrtransa */
            ,INPUT par_cdoperad                   /* par_cdoperad */
            ,INPUT 0                              /* par_dsidenti */
            ,INPUT par_cdcooper                   /* par_cdcooper */
            ,INPUT STRING(par_nrctadst,"99999999")/* par_nrdctitg */
            ,INPUT ""                             /* par_dscedent */
            ,INPUT 0                              /* par_cdcoptfn */
            ,INPUT 0                              /* par_cdagetfn */
            ,INPUT 0                              /* par_nrterfin */
            ,INPUT 0                              /* par_nrparepr */
            ,INPUT 0                              /* par_nrseqava */
            ,INPUT 0                              /* par_nraplica */
            ,INPUT 0                              /* par_cdorigem */
            ,INPUT 0                              /* par_idlautom */
            /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
            ,INPUT 0                              /* Processa lote                                 */
            ,INPUT 0                              /* Tipo de lote a movimentar                     */ 
            /* CAMPOS DE SAÍDA                                                                     */                                            
            ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
            ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
            ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
            ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
         
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            DO:  
                MESSAGE  aux_cdcritic  aux_dscritic  aux_incrineg VIEW-AS ALERT-BOX.    
                RETURN "NOK".
            END.   
              
            IF  VALID-HANDLE(h-b1wgen0200) THEN
            DELETE PROCEDURE h-b1wgen0200.                      
                                  
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/** Procedure para estornar transferencia intercooperativa efetuada Internet **/
/******************************************************************************/
PROCEDURE estorna-transferencia-intercooperativa:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplot.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtocd LIKE crapdat.dtmvtocd             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctadst LIKE craplau.nrctadst             NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocdeb LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_nrdoccre LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_cdlantar LIKE craplat.cdlantar             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR h-b1crap22   AS HANDLE                                  NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Cooperativa nao cadastrada.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
        /* Para Conta on-line */
        IF  par_idorigem = 3  THEN
            DO:
                /** Estornar protocolo da transferencia **/
                RUN sistema/generico/procedures/bo_algoritmo_seguranca.p
                    PERSISTENT SET h-bo_algoritmo_seguranca.
                    
                IF  NOT VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
                    DO:
                        ASSIGN par_dscritic = "Handle invalido para BO".
                        UNDO, RETURN "NOK".
                    END.
                                                                          
                RUN estorna_protocolo IN h-bo_algoritmo_seguranca 
                                     (INPUT par_cdcooper,
                                      INPUT par_dtmvtocd,
                                      INPUT par_nrdconta,
                                      INPUT 1, /** Transferencia   **/
                                      INPUT par_nrdocdeb,
                                      INPUT par_cdoperad,
                                     OUTPUT par_dsprotoc).
                                                                            
                DELETE PROCEDURE h-bo_algoritmo_seguranca.
                         
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        ASSIGN par_dscritic = "Nao foi possivel estornar " +
                                              "o protocolo.".
                        UNDO, RETURN "NOK".
                    END.
                
                /** Retirar lancamento do valor total de movimentos do dia **/
                DO aux_contador = 1 TO 10:
                
                    ASSIGN par_dscritic = "".
                    
                    IF crapass.idastcjt = 0 THEN
                        DO:
                            FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper AND
                                               crapmvi.nrdconta = par_nrdconta AND
                                               crapmvi.idseqttl = par_idseqttl AND
                                               crapmvi.dtmvtolt = par_dtmvtocd
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                            IF  NOT AVAILABLE crapmvi  THEN
                                DO:
                                    IF  LOCKED crapmvi  THEN
                                        DO:
                                            ASSIGN par_dscritic = "Registro de movimento " +
                                                                  "esta sendo alterado. Tente" +
                                                                  " novamente.".
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE
                                        ASSIGN par_dscritic = "Registro de movimento nao " +
                                                              "encontrado.".
                                END.
                            ELSE              
                                DO:
                                    IF  crapass.inpessoa = 1  THEN
                                        ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb - 
                                                                  par_vllanmto.
                                    ELSE
                                        ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf -
                                                                  par_vllanmto.

                                    VALIDATE crapmvi.
                                END.
                        END.
                    ELSE
                        DO:
                            FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                   crappod.nrdconta = par_nrdconta AND
                                                   crappod.cddpoder = 10           AND
                                                   crappod.flgconju = TRUE NO-LOCK:

                                FOR FIRST crapsnh FIELDS(idseqttl) WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                                                         crapsnh.nrdconta = crappod.nrdconta AND
                                                                         crapsnh.nrcpfcgc = crappod.nrcpfpro AND
                                                                         crapsnh.tpdsenha = 1 NO-LOCK. END.
    
                                    IF AVAIL crapsnh THEN
                                        DO:
                                            FIND crapmvi WHERE crapmvi.cdcooper = par_cdcooper     AND
                                                               crapmvi.nrdconta = par_nrdconta     AND
                                                               crapmvi.idseqttl = crapsnh.idseqttl AND
                                                               crapmvi.dtmvtolt = par_dtmvtocd
                                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                               
                                            IF  NOT AVAILABLE crapmvi  THEN
                                                DO:
                                                    IF  LOCKED crapmvi  THEN
                                                        DO:
                                                            ASSIGN par_dscritic = "Registro de movimento " +
                                                                                  "esta sendo alterado. Tente" +
                                                                                  " novamente.".
                                                            PAUSE 1 NO-MESSAGE.
                                                            NEXT.
                                                        END.
                                                    ELSE
                                                        ASSIGN par_dscritic = "Registro de movimento nao " +
                                                                              "encontrado.".
                                                END.
                                            ELSE              
                                                DO:
                                                    IF crapass.inpessoa = 1 THEN
                                                        ASSIGN crapmvi.vlmovweb = crapmvi.vlmovweb - 
                                                                                  par_vllanmto.
                                                    ELSE
                                                        ASSIGN crapmvi.vlmovtrf = crapmvi.vlmovtrf -
                                                                                  par_vllanmto.

                                                    VALIDATE crapmvi.
                                                END.
                                        END. /* Fim avail crapsnh */

                            END. /* Fim For Each CRAPPOD */
                        END.

                    LEAVE.    
                
                END. /** Fim do DO ... TO **/
            END.

        RUN sistema/siscaixa/web/dbo/b1crap22.p PERSISTENT SET h-b1crap22.

        RUN estorna-transferencia-intercooperativa IN h-b1crap22 
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_idorigem,
                                                 INPUT par_cdagectl,
                                                 INPUT par_nrctadst,
                                                 INPUT par_nrdocdeb,
                                                 INPUT par_nrdoccre,
                                                 INPUT par_cdlantar,
                                                 INPUT par_cdoperad,
                                                OUTPUT par_dstransa,
                                                OUTPUT par_dscritic,
                                                OUTPUT par_dsprotoc).
        DELETE PROCEDURE h-b1crap22.

        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".
                                                     
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**        Procedure para obter situacao da senha do Tele-Atendimento        **/
/******************************************************************************/
PROCEDURE obtem_situacao_ura:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-situacao-ura.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem situacao da senha do Tele-Atendimento.".

    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.tpdsenha = 2            AND
                       crapsnh.idseqttl = 0            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            return "OK".
            /*
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Senha para Tele-Atendimento nao cadastrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
            */        
        END.
     
    CREATE tt-situacao-ura.
    ASSIGN tt-situacao-ura.dssitura = IF  crapsnh.cdsitsnh = 0  THEN
                                          "INATIVA"
                                      ELSE
                                      IF  crapsnh.cdsitsnh = 1  THEN
                                          "ATIVA"
                                      ELSE
                                      IF  crapsnh.cdsitsnh = 2  THEN
                                          "BLOQUEADA"
                                      ELSE
                                      IF  crapsnh.cdsitsnh = 3  THEN
                                          "CANCELADA"
                                      ELSE
                                          "".
        
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure para dados sobre senha do Tele-Atendimento           **/
/******************************************************************************/
PROCEDURE carrega_dados_ura:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgsnura AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dados-ura.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-dados-ura.
    EMPTY TEMP-TABLE tt-erro.
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar dados da senha do Tele-Atendimento.".

    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.tpdsenha = 2            AND
                       crapsnh.idseqttl = 0            NO-LOCK NO-ERROR.
    
    IF AVAIL crapsnh THEN
       DO:
          FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                             crapope.cdoperad = crapsnh.cdoperad NO-LOCK NO-ERROR.

          CREATE tt-dados-ura.
          ASSIGN tt-dados-ura.dtaltsnh = IF crapsnh.dtaltsnh = ?  THEN
                                            "SENHA NAO ALTERADA"
                                         ELSE
                                             STRING(crapsnh.dtaltsnh,"99/99/9999")
                 tt-dados-ura.nmopeura = IF AVAILABLE crapope  THEN
                                            crapope.nmoperad
                                         ELSE
                                            crapsnh.cdoperad + " - NAO CADASTRADO"
                 tt-dados-ura.cdsitsnh = crapsnh.cdsitsnh
                 par_flgsnura          = TRUE.

       END.
    ELSE
       DO:
          FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                             crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

          CREATE tt-dados-ura.          
          ASSIGN tt-dados-ura.nmopeura = IF AVAILABLE crapope  THEN 
                                            crapope.nmoperad
                                         ELSE
                                            par_cdoperad + " - NAO CADASTRADO"
                 tt-dados-ura.dtaltsnh = ?
                 tt-dados-ura.cdsitsnh = 0.
                 par_flgsnura          = FALSE.

          RETURN "OK".        

       END.       

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
/**             Procedure para alterar senha do Tele-Atendimento             **/
/******************************************************************************/
PROCEDURE altera_senha_ura:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdcooper AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar senha do Tele-Atendimento."
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
    
            ASSIGN aux_dscritic = "".
        
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 2            AND
                               crapsnh.idseqttl = 0            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapsnh  THEN
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            aux_dscritic = "Senha do Tele-Atendimento esta " +
                                           "sendo alterada. Tente Novamente.". 
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Senha do Tele-Atendimento nao " +
                                           "cadastrada.".
                            LEAVE.
                        END.
                END.
        
            LEAVE.
        
        END.
        
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
    
        IF  crapsnh.cdsitsnh <> 1  THEN  
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha do Tele-Atendimento precisa " +
                                      "estar ativa.".
                                  
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                          
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        ASSIGN aux_cdcooper = SUBSTR(STRING(par_cdcooper,"99"),1,2).
                  
        INTE(par_cddsenha) NO-ERROR.
               
        IF  ERROR-STATUS:ERROR OR SUBSTR(par_cddsenha,1,2) <> aux_cdcooper  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha Invalida.".
                                  
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                      
                UNDO TRANSACAO, LEAVE TRANSACAO. 
            END.

        ASSIGN crapsnh.cddsenha = par_cddsenha
               crapsnh.dtaltsnh = par_dtmvtolt
               crapsnh.cdoperad = par_cdoperad
               aux_flgtrans     = TRUE.
              
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel alterar a senha " +
                                          "do Tele-Atendimento.".

                    RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                END.
                
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
/**        Procedure para obter situacao da senha de acesso a Internet       **/
/******************************************************************************/
PROCEDURE obtem_situacao_internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-situacao-internet.
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem situacao da senha da internet.".

    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.idseqttl = 1            NO-LOCK NO-ERROR.
                       
    CREATE tt-situacao-internet.
    
    IF  AVAILABLE crapsnh  THEN
        DO:
            IF  crapsnh.cdsitsnh = 0  THEN
                ASSIGN tt-situacao-internet.dssitnet = "INATIVA".
            ELSE
            IF  crapsnh.cdsitsnh = 1  THEN
                ASSIGN tt-situacao-internet.dssitnet = "ATIVA".
            ELSE
            IF  crapsnh.cdsitsnh = 2  THEN
                ASSIGN tt-situacao-internet.dssitnet = "BLOQUEADA".
            ELSE
            IF  crapsnh.cdsitsnh = 3  THEN
                ASSIGN tt-situacao-internet.dssitnet = "CANCELADA".
        END.
    ELSE    
        ASSIGN tt-situacao-internet.dssitnet = "INATIVA".
        
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**       Procedure carregar dados dos titulares para acesso a Internet      **/
/******************************************************************************/
PROCEDURE obtem-dados-titulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_idastcjt AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-titular.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-dados-titular.
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR h-b1wgen0058 AS HANDLE NO-UNDO.

	DEF VAR aux_qtminast AS INTEGER NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados dos titulares".

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

    ASSIGN par_inpessoa = crapass.inpessoa
           par_idastcjt = crapass.idastcjt.
     
    IF  crapass.inpessoa = 1  THEN
        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta 
							   NO-LOCK BY crapttl.idseqttl:

            EMPTY TEMP-TABLE cratsnh.
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 1            AND
                               crapsnh.idseqttl = crapttl.idseqttl NO-LOCK NO-ERROR NO-WAIT.
            
            IF AVAILABLE crapsnh THEN
              DO:
                CREATE cratsnh.
                BUFFER-COPY crapsnh TO cratsnh.
              END.            
            
            RUN cria-registro-titular (INPUT crapttl.cdcooper,
                                       INPUT crapttl.nrdconta,
                                       INPUT crapttl.idseqttl,
                                       INPUT crapttl.nmextttl,
                                       INPUT TABLE cratsnh).
                                   
        END. /** Fim do FOR EACH crapttl **/
    ELSE
      DO:
        IF crapass.idastcjt = 0 THEN
          DO:
          
            EMPTY TEMP-TABLE cratsnh.
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 1            AND
                               crapsnh.idseqttl = 1 NO-LOCK NO-ERROR NO-WAIT.
            
            IF AVAILABLE crapsnh THEN
              DO:
                CREATE cratsnh.
                BUFFER-COPY crapsnh TO cratsnh.
              END. 
              
        RUN cria-registro-titular (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT 1,
                                       INPUT crapass.nmprimtl,
                                       INPUT TABLE cratsnh).
        
        FOR EACH crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta NO-LOCK:
									 
					EMPTY TEMP-TABLE cratopi.
					
					IF AVAILABLE crapopi THEN
					DO:  
						CREATE cratopi.
						BUFFER-COPY crapopi TO cratopi.
          END.
					
					RUN cria-registro-titular-conta-conjunta (INPUT crapopi.cdcooper,
											   INPUT crapopi.nrdconta,
											   INPUT 1,
											   INPUT crapopi.nmoperad,
											   INPUT TABLE cratopi).
				
				END.
        
        
        
				END.
        ELSE
          DO:
            RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT
                        SET h-b1wgen0058.
                
            IF VALID-HANDLE(h-b1wgen0058)  THEN
              DO: 
                RUN Busca_Dados IN h-b1wgen0058 (INPUT par_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT 0,
                                             INPUT FALSE,
                                             INPUT "C",
                                             INPUT 0,
                                             INPUT "",
                                             INPUT ?,
                                            OUTPUT TABLE tt-crapavt,
                                            OUTPUT TABLE tt-bens,
											OUTPUT aux_qtminast,
                                            OUTPUT TABLE tt-erro) NO-ERROR.
                
                /* Representantes Legais */
                FOR EACH tt-crapavt WHERE tt-crapavt.idrspleg = 1 NO-LOCK: 
                  
                  EMPTY TEMP-TABLE cratsnh.
                  
                  FIND crapsnh WHERE crapsnh.cdcooper = tt-crapavt.cdcooper AND
                                     crapsnh.nrdconta = tt-crapavt.nrdconta AND
                                     crapsnh.tpdsenha = 1                   AND
                                     crapsnh.nrcpfcgc = tt-crapavt.nrcpfcgc NO-LOCK NO-ERROR NO-WAIT.
                  
                  IF AVAILABLE crapsnh THEN
                     DO:  
                       CREATE cratsnh.
                       BUFFER-COPY crapsnh TO cratsnh.
                     END.
                  ELSE 
                     NEXT.
                           
                  RUN cria-registro-titular (INPUT tt-crapavt.cdcooper,
                                             INPUT tt-crapavt.nrdconta,
                                             INPUT crapsnh.idseqttl,
                                             INPUT tt-crapavt.nmdavali,
                                             INPUT TABLE cratsnh).

                END.
				
				FOR EACH crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta NO-LOCK:
									 
					EMPTY TEMP-TABLE cratopi.
					
					IF AVAILABLE crapopi THEN
					DO:  
						CREATE cratopi.
						BUFFER-COPY crapopi TO cratopi.
              END.
					
					RUN cria-registro-titular-conta-conjunta (INPUT crapopi.cdcooper,
											   INPUT crapopi.nrdconta,
											   INPUT 1,
											   INPUT crapopi.nmoperad,
											   INPUT TABLE cratopi).
				
				END.
              END.
            ELSE
              DO:
                RETURN "NOK".
              END.
          
            DELETE PROCEDURE h-b1wgen0058.
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
/**              Procedure bloquear senha de acesso a Internet               **/
/******************************************************************************/
PROCEDURE bloquear-senha-internet:

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
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsitsnh AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltsit AS DATE                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Bloquear senha de acesso ao InternetBank"
           aux_flgtrans = FALSE.
    
    FOR FIRST crabass WHERE crabass.cdcooper = par_cdcooper
                        AND crabass.nrdconta = par_nrdconta
                        NO-LOCK. END.
    
    IF NOT AVAIL crabass THEN
    DO:
        ASSIGN aux_cdcritic = 9.
                       
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic). 
    
        RETURN "NOK".
    END.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.idseqttl = par_idseqttl AND
                               crapsnh.tpdsenha = 1            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
            IF  NOT AVAILABLE crapsnh  THEN
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de senha esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Registro de senha nao " +
                                              "encontrado.".
                END.
            ELSE
                DO:
                    IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
                        DO.
                            ASSIGN aux_dscritic = "Senha deve estar ativa " +
                                                  "para bloqueio.".
                            LEAVE.
                        END.
                        
                    /** Armazena dados atuais para gerar log das alteracoes **/
                    ASSIGN aux_cdsitsnh = crapsnh.cdsitsnh
                           aux_dtaltsit = crapsnh.dtaltsit.

                    /** Atualiza dados **/
                    ASSIGN crapsnh.cdsitsnh = 2
                           crapsnh.cdoperad = par_cdoperad
                           crapsnh.dtaltsit = par_dtmvtolt.
                END.

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
            
                UNDO TRANSACAO, LEAVE TRANSACAO.            
            END.

        ASSIGN aux_flgtrans = TRUE.               
               
    END. /** Fim do DO TRANSACTION - TRANSACAO **/               
                
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel bloquear a senha.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
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
                                     INPUT "cdsitsnh",
                                     INPUT STRING(aux_cdsitsnh,"9"),
                                     INPUT STRING(crapsnh.cdsitsnh,"9")).
                                         
            IF  aux_dtaltsit <> crapsnh.dtaltsit  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaltsit",
                                         INPUT IF  aux_dtaltsit = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtaltsit,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtaltsit,
                                                      "99/99/9999")).
            
            /* gerar log especifico para multipla assinatura PJ */
            IF crabass.inpessoa > 1 THEN
            DO:
                /* Buscar dados do responsavel legal */
                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                    aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                   INPUT par_nrdconta, /* Numero da Conta */
                                   INPUT par_idseqttl, /* Sequencia Titularidade */
                                   INPUT par_idorigem, /* Codigo Origem */
                                  OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                                  OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                                  OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                                  OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                                  OUTPUT 0,            /* Codigo da critica */
                                  OUTPUT "").          /* Descricao da critica */
                
                CLOSE STORED-PROC pc_verifica_rep_assinatura
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_nrcpfcgc = 0
                       aux_nmprimtl = ""
                       aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                      WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                       aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                      WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                       aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                      WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                      WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
                
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
                     RETURN "NOK".
                                    
                END.
            
                IF  aux_nrcpfcgc > 0 THEN
                    DO:
                        /* Gerar o log com CPF do Rep./Proc. */
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "CPF Representante/Procurador" ,
                                                INPUT "",
                                                INPUT STRING(STRING(aux_nrcpfcgc,
                                                        "99999999999"),"xxx.xxx.xxx-xx")).
                    END.
                    
                IF aux_nmprimtl <> "" THEN
                    DO:
                        /* Gerar o log com Nome do Rep./Proc. */                                
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "Nome Representante/Procurador" ,
                                                INPUT "",
                                                INPUT aux_nmprimtl).
                    END.
                                        
                /* FIM Buscar dados responsavel legal */
            END.
        END.
        
    RETURN "OK".                       

END PROCEDURE.


/******************************************************************************/
/**              Procedure cancelar senha de acesso a Internet               **/
/******************************************************************************/
PROCEDURE cancelar-senha-internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
	/* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
    DEF VAR aux_cont      AS INTEGER  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    /* Inicializando objetos para leitura do XML */ 
	CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
	CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
	CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
	CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
	CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
       
	{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
                       
	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_cancelar_senha_internet_car
	 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Codigo da Cooperativa */
										  INPUT par_cdagenci, /* Codigo do agencia */
										  INPUT par_nrdcaixa, /* Caixa */
										  INPUT par_cdoperad, /* Operador */
										  INPUT par_nmdatela, /* Nome da tela */
										  INPUT par_idorigem, /* Origem */
										  INPUT par_nrdconta, /* Conta */
										  INPUT par_idseqttl, /* Titular */
										  INPUT par_dtmvtolt, /* Data de movimento */
										  INPUT par_inconfir, /* Confirmacao */
										  INPUT int(par_flgerlog), /* Gerar log */ 
										 OUTPUT ?,                 /* XML com informações de LOG */
										 OUTPUT 0,                 /* Código da crítica */
										 OUTPUT "").               /* Descrição da crítica */
    
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_cancelar_senha_internet_car
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
	{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

	EMPTY TEMP-TABLE tt-msg-confirma.

	/* Buscar o XML na tabela de retorno da procedure Progress */ 
	ASSIGN xml_req = pc_cancelar_senha_internet_car.pr_clobxmlc. 
                       
	/* Efetuar a leitura do XML*/ 
	SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
	PUT-STRING(ponteiro_xml,1) = xml_req. 

	IF ponteiro_xml <> ? THEN
                DO:
			xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
			xDoc:GET-DOCUMENT-ELEMENT(xRoot).

			DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
				xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                                              
				IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
					NEXT. 

				IF xRoot2:NUM-CHILDREN > 0 THEN               
                    CREATE tt-msg-confirma.

				DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
					xRoot2:GET-CHILD(xField,aux_cont).

					IF xField:SUBTYPE <> "ELEMENT" THEN 
                                NEXT.
                                            
					xField:GET-CHILD(xText,1).
                        
					ASSIGN tt-msg-confirma.inconfir = int(xText:NODE-VALUE) WHEN xField:NAME = "inconfir"
					       tt-msg-confirma.dsmensag = xText:NODE-VALUE WHEN xField:NAME = "dsmensag".
                            
					VALIDATE tt-msg-confirma.
                        
                END.

                END.
                                                
			SET-SIZE(ponteiro_xml) = 0.
                   
        END.

    RETURN "OK".                       

END PROCEDURE.


/******************************************************************************/
/**              Procedure alterar senha de acesso a Internet                **/
/******************************************************************************/
PROCEDURE alterar-senha-internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsnhnew AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsnhrep AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvldsnh AS DATE                                    NO-UNDO.

    DEF VAR h-b1wnet0002 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar senha de acesso ao InternetBank"
           aux_flgtrans = FALSE.

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
                    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.idseqttl = par_idseqttl AND
                               crapsnh.tpdsenha = 1            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
            IF  NOT AVAILABLE crapsnh  THEN
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de senha esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Registro de senha nao " +
                                              "encontrado.".
                END.
            ELSE
                DO:
                    IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
                        DO.
                            ASSIGN aux_dscritic = "Senha deve estar ativa " +
                                                  "para alteraracao.".
                            LEAVE.
                        END.

                    IF  crapsnh.cddsenha <> ENCODE(par_cddsenha)  THEN
                        DO:
                            ASSIGN aux_dscritic = "Senha atual invalida.".
                            LEAVE.
                        END.

                    INTE(par_cdsnhnew) NO-ERROR.

                    IF  ERROR-STATUS:ERROR            OR
                        par_cdsnhnew = par_cddsenha   OR
                        par_cdsnhnew <> par_cdsnhrep  OR
                        TRIM(par_cdsnhnew) = ""       OR
                        LENGTH(par_cdsnhnew) <> 8     THEN
                        DO:
                            ASSIGN aux_dscritic = "Nova senha invalida.".
                            LEAVE.
                        END.

                    RUN sistema/internet/procedures/b1wnet0002.p 
                        PERSISTENT SET h-b1wnet0002.
                            
                    RUN validar-senha-hsh IN h-b1wnet0002 (INPUT par_cdcooper,
                                                           INPUT par_nrdconta,
                                                           INPUT par_idseqttl,
                                                           INPUT 0,
                                                           INPUT par_cdsnhnew,
                                                           INPUT "",
                                                           INPUT 0,
                                                          OUTPUT aux_dscritic).
                    
                    DELETE PROCEDURE h-b1wnet0002.
            
                    IF  RETURN-VALUE <> "OK" OR aux_dscritic <> ""  THEN
                        LEAVE.
                        
                    /** Armazena dados atuais para gerar log das alteracoes **/
                    ASSIGN aux_dtaltsnh = crapsnh.dtaltsnh
                           aux_dtvldsnh = crapsnh.dtvldsnh.

                    /** Atualiza dados **/
                    ASSIGN crapsnh.cddsenha = ENCODE(par_cdsnhnew)
                           crapsnh.dtaltsnh = par_dtmvtolt
                           crapsnh.cdoperad = par_cdoperad
                           crapsnh.dtvldsnh = crapcop.dcprsweb + par_dtmvtolt
                           crapsnh.dssenweb = ""
                           crapsnh.qtacerro = 0
                           crapsnh.dtblutsh = ?. 

                    RUN sistema/internet/procedures/b1wnet0002.p 
                        PERSISTENT SET h-b1wnet0002.
            
                    RUN cadastrar-senha-hsh IN h-b1wnet0002 (INPUT par_cdcooper,
                                                             INPUT par_nrdconta,
                                                             INPUT par_idseqttl,
                                                             INPUT 0,
                                                             INPUT par_cdsnhnew,
                                                             INPUT "",
                                                             INPUT 1,
                                                            OUTPUT aux_dscritic).
            
                    DELETE PROCEDURE h-b1wnet0002.
            
                    IF  RETURN-VALUE <> "OK" OR aux_dscritic <> ""  THEN
                        LEAVE.
                END.

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
                                  
                UNDO TRANSACAO, LEAVE TRANSACAO.            
            END.

        ASSIGN aux_flgtrans = TRUE.               
               
    END. /** Fim do DO TRANSACTION - TRANSACAO **/               
                
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel alterar a senha.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
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
                       
            IF  aux_dtaltsnh <> crapsnh.dtaltsnh  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaltsnh",
                                         INPUT IF  aux_dtaltsnh = ?  THEN
                                                   ""
                                               ELSE    
                                                   STRING(aux_dtaltsnh,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtaltsnh,
                                                      "99/99/9999")).
                                                                      
            IF  aux_dtvldsnh <> crapsnh.dtvldsnh  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtvldsnh",
                                         INPUT IF  aux_dtvldsnh = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtvldsnh,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtvldsnh,
                                                      "99/99/9999")).
        END.
        
    RETURN "OK".                       

END PROCEDURE.


/******************************************************************************/
/**              Procedure liberar senha de acesso a Internet                **/
/******************************************************************************/
PROCEDURE liberar-senha-internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsnhnew AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsnhrep AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtdiaace AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_flgletca AS LOGI                           NO-UNDO.
	DEF OUTPUT PARAM par_flgimpte AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0032 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wnet0002 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsitsnh AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECIMAL                                 NO-UNDO.
    
    DEF VAR aux_dtvldsnh AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlibera AS DATE                                    NO-UNDO.
    DEF VAR aux_dtaltsit AS DATE                                    NO-UNDO.
    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO.
    
    DEF VAR aux_nrdrecid AS RECID                                   NO-UNDO.
    
    DEF BUFFER crabsnh FOR crapsnh.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Liberar senha de acesso ao InternetBank"
           aux_flgtrans = FALSE
           par_flgimpte = FALSE
           aux_nmprimtl = ""
           aux_nrcpfcgc = 0.
    
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
            
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            NO-LOCK NO-ERROR.

    IF  AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_nrdrecid = RECID(crapsnh).
            
            IF  crapsnh.cdsitsnh = 1 AND crapsnh.dssenweb <> ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "A Senha ja foi liberada.".

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

    /** Para os demais titulares somente eh permitido a liberacao do acesso **/
    /** a internet caso o 1o. titular tenha acesso ativo ou bloqueado       **/
    IF  par_idseqttl <> 1 AND crapass.idastcjt = 0 THEN
        DO:
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 1            AND
                               crapsnh.idseqttl = 1
                               NO-LOCK NO-ERROR.
                                        
            IF  NOT AVAILABLE crapsnh                       OR
                NOT CAN-DO("1,2",STRING(crapsnh.cdsitsnh))  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "1o titular deve possuir senha " +
                                          "ativa ou bloqueada para liberar.".

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

    INTE(par_cdsnhnew) NO-ERROR.

    IF  ERROR-STATUS:ERROR            OR
        par_cdsnhnew <> par_cdsnhrep  OR
        TRIM(par_cdsnhnew) = ""       OR
        LENGTH(par_cdsnhnew) <> 8     THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nova senha invalida.".
        
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
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        RUN sistema/internet/procedures/b1wnet0002.p 
            PERSISTENT SET h-b1wnet0002.
                
        RUN validar-senha-hsh IN h-b1wnet0002 (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT 0,
                                               INPUT par_cdsnhnew,
                                               INPUT "",
                                               INPUT 0,
                                              OUTPUT aux_dscritic).
        
        DELETE PROCEDURE h-b1wnet0002.

        IF  RETURN-VALUE <> "OK" OR aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  aux_nrdrecid = ?  THEN
			DO:

                /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                IF par_cdagenci = 0 THEN
                  ASSIGN par_cdagenci = glb_cdagenci.
                /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

            CREATE crapsnh.
                /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
            	ASSIGN crapsnh.cdopeori = par_cdoperad
                   crapsnh.cdageori = par_cdagenci
                   crapsnh.dtinsori = TODAY.
                /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
			END.
        ELSE
            DO:
                DO aux_contador = 1 TO 10:
                
                    ASSIGN aux_dscritic = "".
                    
                    FIND crapsnh WHERE RECID(crapsnh) = aux_nrdrecid
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                    IF  NOT AVAILABLE crapsnh  THEN
                        DO:
                            IF  LOCKED crapsnh  THEN
                                DO:
                                    aux_dscritic = "Registro de senha esta " +
                                                   "sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Registro de senha nao " +
                                               "encontrado.".
                        END.
                        
                    LEAVE.    
                        
                END. /** Fim do DO ... TO **/

                IF  RETURN-VALUE <> "OK" OR aux_dscritic <> ""  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0.
                        
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                              
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.

        /** Armazena dados atuais da senha **/
        ASSIGN aux_cdsitsnh = crapsnh.cdsitsnh   
               aux_dtvldsnh = crapsnh.dtvldsnh
               aux_dtlibera = crapsnh.dtlibera
               aux_dtaltsit = crapsnh.dtaltsit
               aux_dtaltsnh = crapsnh.dtaltsnh.
               
        /** Atualiza dados **/
        ASSIGN crapsnh.cdcooper = par_cdcooper
               crapsnh.nrdconta = par_nrdconta
               crapsnh.tpdsenha = 1 
               crapsnh.idseqttl = par_idseqttl
               crapsnh.cddsenha = ENCODE(par_cdsnhnew)
               crapsnh.dssenweb = ""
               crapsnh.cdsitsnh = 1   
               crapsnh.dtvldsnh = crapcop.dcprsweb + par_dtmvtolt
               crapsnh.dtlibera = par_dtmvtolt
               crapsnh.hrtransa = TIME
               crapsnh.cdoperad = par_cdoperad
               crapsnh.dtaltsit = IF  aux_dtaltsit = ?  THEN
                                      ?
                                  ELSE
                                      par_dtmvtolt
               crapsnh.dtaltsnh = par_dtmvtolt
               crapsnh.qtacerro = 0
               crapsnh.dtblutsh = ?.
               
        VALIDATE crapsnh.
        
        RUN sistema/internet/procedures/b1wnet0002.p 
            PERSISTENT SET h-b1wnet0002.

        RUN cadastrar-senha-hsh IN h-b1wnet0002 (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT 0,
                                                 INPUT par_cdsnhnew,
                                                 INPUT "",
                                                 INPUT 1,
                                                OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wnet0002.

        IF  RETURN-VALUE <> "OK" OR aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  crapass.inpessoa > 1 AND 
            crapass.idastcjt = 1 THEN
            DO:
                FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                        crappod.nrdconta = par_nrdconta AND
                                        crappod.cddpoder = 10           AND
                                        crappod.flgconju = TRUE         AND
                                        crappod.nrcpfpro <> crapsnh.nrcpfcgc
                                        NO-LOCK,
                    FIRST crabsnh WHERE crabsnh.cdcooper = par_cdcooper     AND
                                        crabsnh.nrdconta = par_nrdconta     AND
                                        crabsnh.tpdsenha = 1                AND
                                        crabsnh.nrcpfcgc = crappod.nrcpfpro AND
                                        (crabsnh.vllimweb > 0 OR
                                         crabsnh.vllimtrf > 0 OR
                                         crabsnh.vllimpgo > 0 OR
                                         crabsnh.vllimted > 0 OR
                                         crabsnh.vllimvrb > 0) NO-LOCK:
                
                    RUN replica-limite-internet (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nrdconta,
                                                 INPUT crabsnh.idseqttl,
                                                 INPUT crabsnh.vllimweb,
                                                 INPUT crabsnh.vllimtrf,
                                                 INPUT crabsnh.vllimpgo,
                                                 INPUT crabsnh.vllimted,
                                                 INPUT crabsnh.vllimvrb).
                  
                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = "Problema em replicar limites.".
                    
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT 1,            /** Sequencia **/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).
                                                           
                           UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                END.
            END.
        
        /* Buscar dados do responsavel legal da conta PJ */
        IF  crapass.inpessoa > 1 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
                RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper, /* Codigo da Cooperativa */
                         INPUT par_nrdconta, /* Numero da Conta */
                         INPUT par_idseqttl, /* Sequencia Titularidade */
                         INPUT par_idorigem, /* Codigo Origem */
                        OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                        OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                        OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                        OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                        OUTPUT 0,            /* Codigo da critica */
                        OUTPUT "").          /* Descricao da critica */
            
                CLOSE STORED-PROC pc_verifica_rep_assinatura
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
                ASSIGN aux_nrcpfcgc = 0
                       aux_nmprimtl = ""
                       aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                      WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                       aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                      WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                       aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                      WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                      WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
            
                IF  aux_cdcritic <> 0   OR
                    aux_dscritic <> ""  THEN
                    DO:
                       
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.

        ASSIGN aux_flgtrans = TRUE.               
               
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    RUN sistema/generico/procedures/b1wgen0032.p 
        PERSISTENT SET h-b1wgen0032.    

    /* Verifica se o cooperados já possui letras de segurança cadastradas */
    RUN verifica-letras-seguranca IN h-b1wgen0032 (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                  OUTPUT par_flgletca).

    DELETE PROCEDURE h-b1wgen0032.
              
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel alterar a senha.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
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

    IF  crapass.inpessoa = 1  THEN 
        DO:
            /** Tabela com os limites para internet **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 1            NO-LOCK NO-ERROR.
                   
            IF  AVAILABLE craptab  THEN
                ASSIGN par_qtdiaace =  INTE(ENTRY(3,craptab.dstextab,";")).
            ELSE
                ASSIGN par_qtdiaace = 3.          
        END.
    ELSE  
        DO:
            /** Tabela com os limites para internet **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 2            NO-LOCK NO-ERROR.
                   
            IF  AVAILABLE craptab  THEN
                ASSIGN par_qtdiaace = INTE(ENTRY(3,craptab.dstextab,";")).
            ELSE
                ASSIGN par_qtdiaace = 3.
        END.
  
    /* Condicoes para Imprimir Termo Responsabilidade*/
    IF  crapass.inpessoa = 1 OR 
        crapass.idastcjt = 0 OR 
       (crapass.idastcjt > 0 AND crapass.idimprtr = 1) THEN
        ASSIGN par_flgimpte = TRUE.

    /* Cooperados admitidos após novembro/2015 ou desbloqueio de senha,
       nao precisa imprimir termo de responsabilidade */
    IF (crapass.dtadmiss > 11/30/2015) OR 
       (aux_cdsitsnh = 2) THEN
        ASSIGN par_flgimpte = FALSE. 

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
                       
            IF  aux_cdsitsnh <> crapsnh.cdsitsnh  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdsitsnh",
                                         INPUT STRING(aux_cdsitsnh,"9"),
                                         INPUT STRING(crapsnh.cdsitsnh,"9")).
                                                                      
            IF  aux_dtvldsnh <> crapsnh.dtvldsnh  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtvldsnh",
                                         INPUT IF  aux_dtvldsnh = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtvldsnh,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtvldsnh, 
                                                      "99/99/9999")).
        
            IF  aux_dtlibera <> crapsnh.dtlibera  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtlibera",
                                         INPUT IF  aux_dtlibera = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtlibera,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtlibera, 
                                                      "99/99/9999")).

            IF  aux_dtaltsit <> crapsnh.dtaltsit  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaltsit",
                                         INPUT IF  aux_dtaltsit = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtaltsit,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtaltsit, 
                                                      "99/99/9999")).
            
            IF  aux_dtaltsnh <> crapsnh.dtaltsnh  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaltsnh",
                                         INPUT IF  aux_dtaltsnh = ?  THEN
                                                   ""
                                               ELSE
                                                   STRING(aux_dtaltsnh,
                                                          "99/99/9999"),
                                         INPUT STRING(crapsnh.dtaltsnh, 
                                                      "99/99/9999")).
            
            /* Gerar o log com CPF do Rep./Proc. */
            IF  aux_nrcpfcgc > 0    THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "CPF Representante/Procurador" ,
                                         INPUT "",
                                         INPUT STRING(STRING(aux_nrcpfcgc,
                                                      "99999999999"),"xxx.xxx.xxx-xx")).
    
            /* Gerar o log com Nome do Rep./Proc. */
            IF  aux_nmprimtl <> ""  THEN                         
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Nome Representante/Procurador" ,
                                         INPUT "",
                                         INPUT aux_nmprimtl).
        END.
    
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure carregar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE obtem-dados-limites:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-habilitacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-dados-habilitacao.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados de habilitacao da senha de acesso ao " +
                          "InternetBank".

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
        
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de senha nao encontrado.".

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
                
    IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Senha deve estar ativa para habilitacao.".
                
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

    CREATE tt-dados-habilitacao.
    ASSIGN tt-dados-habilitacao.inpessoa = crapass.inpessoa
           tt-dados-habilitacao.vllimweb = crapsnh.vllimweb 
           tt-dados-habilitacao.vllimtrf = crapsnh.vllimtrf
           tt-dados-habilitacao.vllimpgo = crapsnh.vllimpgo
           tt-dados-habilitacao.vllimted = crapsnh.vllimted
           tt-dados-habilitacao.vllimvrb = crapsnh.vllimvrb.
                       
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
/**            Procedure validar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE valida-dados-limites:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimweb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimtrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimpgo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimted AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimvrb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-preposto.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerros AS LOGI                                    NO-UNDO.
   
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimweb AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimted AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimvrb AS DECI                                    NO-UNDO.

    DEF VAR aux_vlwebant AS DECI                                    NO-UNDO.
    DEF VAR aux_vltedant AS DECI                                    NO-UNDO.
    DEF VAR aux_vltrfant AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpgoant AS DECI                                    NO-UNDO.
    DEF VAR aux_vlantvrb AS DECI                                    NO-UNDO.

    DEF BUFFER crabsnh FOR crapsnh.
    DEF BUFFER crabass FOR crapass.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-preposto.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar limites da senha de acesso ao InternetBank".

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
        
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            NO-LOCK NO-ERROR.
                           
        ASSIGN  aux_vlwebant = crapsnh.vllimweb
                aux_vltedant = crapsnh.vllimted
                aux_vltrfant = crapsnh.vllimtrf
                aux_vlpgoant = crapsnh.vllimpgo
                aux_vlantvrb = crapsnh.vllimvrb.


    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de senha nao encontrado.".

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
                
    IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Senha deve estar ativa para habilitacao.".
                
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
        
    DO WHILE TRUE:
        
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_flgerros = TRUE.
    
        IF crapass.idastcjt = 0 THEN
        DO:
          /** Demais titulares nao podem ter limites maiores que o 1o. titular **/
          IF  par_idseqttl <> 1  THEN
              DO:
                  FIND crabsnh WHERE crabsnh.cdcooper = par_cdcooper AND
                                     crabsnh.nrdconta = par_nrdconta AND
                                     crabsnh.tpdsenha = 1            AND
                                     crabsnh.idseqttl = 1            
                                     NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crabsnh  THEN
                    DO:
                        ASSIGN aux_dscritic = "1o. titular nao cadastrado.".
                        LEAVE.
                    END.
                                                                          
                ASSIGN aux_nrcpfcgc = crabsnh.nrcpfcgc.
            END.
        ELSE
            DO:
                ASSIGN aux_nrcpfcgc = crapsnh.nrcpfcgc
                       aux_vllimweb = 0
                       aux_vllimted = 0
                       aux_vllimvrb = 0. 
                
                FOR EACH crabsnh WHERE crabsnh.cdcooper  = par_cdcooper AND
                                       crabsnh.nrdconta  = par_nrdconta AND
                                       crabsnh.tpdsenha  = 1            AND
                                       crabsnh.cdsitsnh  = 1            AND /* Somente ativos */
                                       crabsnh.idseqttl <> 1 
                                       NO-LOCK:
                                                                          
                    ASSIGN aux_vllimweb = aux_vllimweb + crabsnh.vllimweb
                           aux_vllimted = aux_vllimted + crabsnh.vllimted
                           aux_vllimvrb = aux_vllimvrb + crabsnh.vllimvrb. 
                           
                END. /** Fim do FOR EACH crabsnh **/

              END.
        END.
        
        IF  crapass.inpessoa = 1  THEN
            DO:
                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "GENERI"     AND
                                   craptab.cdempres = 0            AND
                                   craptab.cdacesso = "LIMINTERNT" AND
                                   craptab.tpregist = 1            
                                   NO-LOCK NO-ERROR.
                       
                IF  NOT AVAILABLE craptab  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela LIMINTERNT nao " +
                                              "cadastrada.".
                        LEAVE.                      
                    END.

                IF aux_vlwebant <> par_vllimweb THEN
                    IF  par_vllimweb > DECI(ENTRY(1,craptab.dstextab,";"))  THEN
                        DO:
                            ASSIGN aux_dscritic = "Limite/Dia deve ser menor ou " +
                                                  "igual ao valor parametrizado " +
                                                  "pela cooperativa.".
                            LEAVE.
                        END.
                   
                IF aux_vltedant <> par_vllimted THEN 
                    IF  par_vllimted > DECI(ENTRY(13,craptab.dstextab,";"))  THEN
                        DO:
                            ASSIGN aux_dscritic = "Limite/Dia TED deve ser menor ou " +
                                                  "igual ao valor parametrizado " +
                                                  "pela cooperativa.".
                            LEAVE.
                        END.    

                IF aux_vlantvrb <> par_vllimvrb THEN  
                   IF  par_vllimvrb > DECI(ENTRY(15,craptab.dstextab,";"))  THEN
                       DO:
                           ASSIGN aux_dscritic = "Limite VR Boleto deve ser menor ou " +
                                                 "igual ao valor parametrizado " +
                                                 "pela cooperativa.".
                           LEAVE.
                       END.    
                    
                /** Limites dos demais nao pode ser maior que do 1o. tit **/
                IF  par_idseqttl <> 1  THEN
                    DO:
                        IF  crabsnh.vllimweb = 0 AND par_vllimweb <> 0  THEN
                            DO:
                                ASSIGN aux_dscritic = "Valor Limite/Dia deve " +
                                                      "ser 0 porque o 1o. " +
                                                      "titular nao possui " +
                                                      "limite cadastrado.".
                                LEAVE.
                            END.   

                        IF  crabsnh.vllimted = 0 AND par_vllimted <> 0  THEN
                            DO:
                                ASSIGN aux_dscritic = "Valor Limite/Dia TED deve " +
                                                      "ser 0 porque o 1o. " +
                                                      "titular nao possui " +
                                                      "limite cadastrado.".
                                LEAVE.
                            END.   
                        IF aux_vlwebant <> par_vllimweb THEN
                            IF  crabsnh.vllimweb < par_vllimweb  THEN
                                DO:
                                    ASSIGN aux_dscritic = "O valor maximo de " +   
                                                          "Limite/Dia nao pode " +
                                                          "ser maior que o do " +
                                                          "1o. titular.".
                                    LEAVE.
                                END.

                        IF aux_vltedant <> par_vllimted THEN
                            IF  crabsnh.vllimted < par_vllimted  THEN
                                DO:
                                    ASSIGN aux_dscritic = "O valor maximo de " +   
                                                          "Limite/Dia TED nao pode " +
                                                          "ser maior que o do " +
                                                          "1o. titular.".
                                    LEAVE.
                                END.

                    END.
                ELSE
                    DO:
                        IF aux_vlwebant <> par_vllimweb THEN
                            IF  par_vllimweb < aux_vllimweb  THEN
                                DO:
                                    ASSIGN aux_dscritic = "Valor Limite/Dia do " +
                                                          "1o. titular nao pode " +
                                                          "ser menor que o dos " +
                                                          "demais titulares.".
                                    LEAVE.
                                END.

                        IF aux_vltedant <> par_vllimted THEN
                            IF  par_vllimted < aux_vllimted  THEN
                                DO:
                                    ASSIGN aux_dscritic = "Valor Limite/Dia TED do " +
                                                          "1o. titular nao pode " +
                                                          "ser menor que o dos " +
                                                          "demais titulares.".
                                    LEAVE.
                                END.

                    END.       
            END.
        ELSE
            DO:
                IF  par_vllimtrf > 0 OR par_vllimpgo > 0 OR par_vllimted > 0 THEN
                    DO:
                        FIND FIRST crapavt WHERE 
                                   crapavt.cdcooper = par_cdcooper         AND
                                   crapavt.tpctrato = 6                    AND
                                   crapavt.nrdconta = par_nrdconta         AND 
                                   CAN-DO("SOCIO/PROPRIETARIO,SOCIO ADMINISTRADOR,DIRETOR/ADMINISTRADOR,SINDICO,ADMINISTRADOR",STRING(crapavt.dsproftl)) 
                                   NO-LOCK NO-ERROR.
                                 
                        IF  NOT AVAILABLE crapavt  THEN
                            DO:
                                aux_dscritic = "Para alterar/habilitar Limite" +
                                               " para transacoes e necessario" +
                                               " um SOCIO/PROPRIETARIO, SOCIO ADM," + 
											   " DIRETOR/ADM, SINDICO, ADMINISTRADOR." +
                                               " Va na tela CONTAS e informe.".
                                LEAVE.        
                            END.
                    END.
                                     
                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "GENERI"     AND
                                   craptab.cdempres = 0            AND
                                   craptab.cdacesso = "LIMINTERNT" AND
                                   craptab.tpregist = 2            
                                   NO-LOCK NO-ERROR.
                           
                IF  NOT AVAILABLE craptab  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela LIMINTERNT nao " +
                                              "cadastrada.".
                        LEAVE.                      
                    END.
             
             IF aux_vltrfant <> par_vllimtrf THEN
                 IF  par_vllimtrf > DECI(ENTRY(1,craptab.dstextab,";"))  THEN
                    DO:
                        ASSIGN aux_dscritic = "Limite/Dia Transferencia deve " +
                                              "ser menor ou igual ao valor " +
                                              "parametrizado pela cooperativa.".
                        LEAVE.
                    END.
             IF aux_vlpgoant <> par_vllimpgo THEN
                IF  par_vllimpgo > DECI(ENTRY(6,craptab.dstextab,";"))  THEN
                    DO:
                        ASSIGN aux_dscritic = "Limite/Dia Pagamento deve ser " +
                                              "menor ou igual ao valor " +
                                              "parametrizado pela cooperativa.".
                        LEAVE.
                    END.
             IF aux_vltedant <> par_vllimted THEN
                IF  par_vllimted > DECI(ENTRY(13,craptab.dstextab,";"))  THEN
                    DO:
                        ASSIGN aux_dscritic = "Limite/Dia TED deve ser " +
                                              "menor ou igual ao valor " +
                                              "parametrizado pela cooperativa.".
                        LEAVE.
                    END.

             IF aux_vlantvrb <> par_vllimvrb THEN  
                IF par_vllimvrb > DECI(ENTRY(16,craptab.dstextab,";"))  THEN
                   DO:
                      ASSIGN aux_dscritic = "Limite VR Boleto deve ser menor ou " +
                                            "igual ao valor parametrizado " +
                                            "pela cooperativa.".
                     LEAVE.
                   END.
                  
            END.   
        
        ASSIGN aux_flgerros = FALSE.
             
        LEAVE.             
    
    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerros  THEN
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
     
    /* Não retornar lista de representantes para contas de assinatura conjunta */
    IF  crapass.inpessoa > 1 AND  crapass.idastcjt = 0 AND (par_vllimtrf > 0 OR par_vllimpgo > 0 OR par_vllimted > 0)  THEN
        DO:
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                   crapavt.tpctrato = 6            AND
                                   crapavt.nrdconta = par_nrdconta NO-LOCK:

                CREATE tt-dados-preposto.
                ASSIGN tt-dados-preposto.nrdctato = crapavt.nrdctato
                       tt-dados-preposto.nmdavali = crapavt.nmdavali
                       tt-dados-preposto.nrcpfcgc = crapavt.nrcpfcgc
                       tt-dados-preposto.dscpfcgc = STRING(STRING(
                                                    crapavt.nrcpfcgc,
                                                    "99999999999"),
                                                    "xxx.xxx.xxx-xx")
                       tt-dados-preposto.dsproftl = crapavt.dsproftl.

                /** Se associado, pega os dados da crapass **/
                IF  crapavt.nrdctato <> 0  THEN
                    DO:
                        FIND crabass WHERE 
                             crabass.cdcooper = par_cdcooper     AND
                             crabass.nrdconta = crapavt.nrdctato
                             NO-LOCK NO-ERROR.
                        
                        IF  AVAILABLE crabass  THEN
                            DO:
                                ASSIGN tt-dados-preposto.nmdavali =
                                                               crabass.nmprimtl
                                       tt-dados-preposto.nrcpfcgc =
                                                               crabass.nrcpfcgc
                                       tt-dados-preposto.dscpfcgc =
                                               STRING(STRING(crabass.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx").
                            END.
                    END.

                /** Verifica se e o preposto atual **/
                IF  tt-dados-preposto.nrcpfcgc = aux_nrcpfcgc  THEN
                    ASSIGN tt-dados-preposto.flgatual = TRUE.
                ELSE
                    ASSIGN tt-dados-preposto.flgatual = FALSE.
                                
            END. /** Fim do FOR EACH crapavt **/
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                    Procedure para atualizar preposto                     **/
/******************************************************************************/
PROCEDURE atualizar-preposto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar preposto para InternetBank".

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
        
    IF  par_nrcpfcgc = 0  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Selecione um preposto.".
                   
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

    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.idseqttl = par_idseqttl AND
                               crapsnh.tpdsenha = 1            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
            IF  NOT AVAILABLE crapsnh  THEN   
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de senha esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Registro de senha nao " + 
                                              "encontrado.".
                END.

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
                                             
                UNDO TRANSACAO, LEAVE TRANSACAO.                           
            END.

        IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha deve estar ativa para " +
                                      "atualizacao do preposto.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                 
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_nrcpfcgc <> crapsnh.nrcpfcgc  THEN 
            DO:
                FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                         crapavt.tpctrato = 6            AND
                                         crapavt.nrdconta = par_nrdconta AND
                                         crapavt.nrcpfcgc = par_nrcpfcgc
                                         NO-LOCK NO-ERROR.
                                     
                IF  NOT AVAILABLE crapavt  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Preposto invalido.".
                       
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                 
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

                /** Armazena dados atuais da senha **/
                ASSIGN aux_nrcpfcgc = crapsnh.nrcpfcgc.
               
                /** Atualiza dados **/
                ASSIGN crapsnh.nrcpfcgc = par_nrcpfcgc.

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
                       
                        RUN proc_gerar_log_item 
                                       (INPUT aux_nrdrowid,
                                        INPUT "nrcpfcgc",
                                        INPUT STRING(STRING(aux_nrcpfcgc,
                                              "99999999999"),"xxx.xxx.xxx-xx"),
                                        INPUT STRING(STRING(par_nrcpfcgc, 
                                              "99999999999"),"xxx.xxx.xxx-xx")).
                    END.
            END.
        
        /*Atualizar as transaçoes pendentes de aprovaçao para o novo preposto
          quando for uma conta PJ sem assinatura conjunta Tiago*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_atu_trans_pend_prep
            aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper, /* Codigo da Cooperativa */
                           INPUT par_nrdconta, /* Numero da Conta */
                           INPUT par_nrcpfcgc, /* CPF/CGC */
                           INPUT crapass.inpessoa, /* Tipo Pessoa */
                           INPUT 1,            /* Tipo de senha (1=INTERNET) */
                           INPUT crapass.idastcjt, /* Exige Ass.Conjunta Nao=0 Sim=1 */
                          OUTPUT 0,            /* Codigo da critica */
                          OUTPUT "").          /* Descricao da critica */
        
        CLOSE STORED-PROC pc_atu_trans_pend_prep
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_atu_trans_pend_prep.pr_cdcritic 
                              WHEN pc_atu_trans_pend_prep.pr_cdcritic <> ?
               aux_dscritic = pc_atu_trans_pend_prep.pr_dscritic
                              WHEN pc_atu_trans_pend_prep.pr_dscritic <> ?.
        
        IF aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
        DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
                                       
          UNDO TRANSACAO, LEAVE TRANSACAO.                                   
        END.
        
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel atualizar o preposto.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
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

    RETURN "OK".        

END PROCEDURE.


/******************************************************************************/
/**            Procedure alterar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE alterar-limites-internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimweb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimtrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimpgo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimted AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimvrb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_vllimweb AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimtrf AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimpgo AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimted AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimvrb AS DECI                                    NO-UNDO.
	DEF VAR aux_nrcpfcgc AS DECI									NO-UNDO.

    DEF VAR aux_dtlimweb AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimtrf AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimpgo AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimted AS DATE                                    NO-UNDO.
    DEF VAR aux_dtlimvrb AS DATE                                    NO-UNDO.

    DEF VAR aux_dtlogalt AS CHAR                                    NO-UNDO.
	DEF VAR aux_nmprimtl AS CHAR									NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar limites da senha de acesso ao InternetBank"
           aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                               
            IF  NOT AVAILABLE crapass  THEN   
                DO:
                    IF  LOCKED crapass  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro do associado esta" +
                                                  " sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 9.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                             
                UNDO TRANSACAO, LEAVE TRANSACAO.                           
            END.
            
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_dscritic = "".
            
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.idseqttl = par_idseqttl AND
                               crapsnh.tpdsenha = 1            
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
            IF  NOT AVAILABLE crapsnh  THEN   
                DO:
                    IF  LOCKED crapsnh  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de senha esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Registro de senha nao " + 
                                              "encontrado.".
                END.

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
                                             
                UNDO TRANSACAO, LEAVE TRANSACAO.                           
            END.

        IF  crapsnh.cdsitsnh <> 1  THEN /** ATIVO **/
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Senha deve estar ativa para " +
                                      "habilitacao.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                 
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  crapass.inpessoa > 1  AND
            crapass.idastcjt = 0  AND /* se nao exigir assinatura multipla */
            crapsnh.nrcpfcgc = 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nenhum preposto foi selecionado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                 
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /** Armazena dados atuais da senha **/
        ASSIGN aux_vllimweb = crapsnh.vllimweb
               aux_vllimtrf = crapsnh.vllimtrf
               aux_vllimpgo = crapsnh.vllimpgo
               aux_vllimted = crapsnh.vllimted
               aux_vllimvrb = crapsnh.vllimvrb. 

        /** Armazena datas de alteracao limites **/
        ASSIGN aux_dtlimweb = crapsnh.dtlimweb
               aux_dtlimtrf = crapsnh.dtlimtrf
               aux_dtlimpgo = crapsnh.dtlimpgo
               aux_dtlimted = crapsnh.dtlimted
               aux_dtlimvrb = crapsnh.dtlimvrb. 
               
        IF crapsnh.cdsitsnh <> 1 THEN
        DO:
            /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
            ASSIGN crapsnh.cdopeori = par_cdoperad
               crapsnh.cdageori = par_cdagenci
               crapsnh.dtinsori = TODAY.
            /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        END. 
 
        /* inicio - pessoa fisica */
        IF crapsnh.vllimweb = 0 AND par_vllimweb > 0 THEN
        DO:
            ASSIGN  crapsnh.cdopepag = par_cdoperad
                    crapsnh.cdagepag = par_cdagenci
                    crapsnh.vlpagini = par_vllimweb
                    crapsnh.dtinspag = TODAY.
        END.
        IF crapsnh.vllimted = 0 AND par_vllimted > 0 THEN
        DO:
            ASSIGN  crapsnh.cdopetra = par_cdoperad
                    crapsnh.cdagetra = par_cdagenci
                    crapsnh.vltraini = par_vllimted
                    crapsnh.dtinstra = TODAY.
        END.
        /* fim - pessoa fisica */

        /* inicio - pessoa juridica */
        IF crapsnh.vllimpgo = 0 AND par_vllimpgo > 0 THEN
        DO:
            ASSIGN  crapsnh.cdopepag = par_cdoperad
                    crapsnh.cdagepag = par_cdagenci
                    crapsnh.vlpagini = par_vllimpgo
                    crapsnh.dtinspag = TODAY.
        END.
        IF crapsnh.vllimtrf = 0 AND par_vllimtrf > 0 THEN
        DO:
            ASSIGN  crapsnh.cdopetra = par_cdoperad
                    crapsnh.cdagetra = par_cdagenci
                    crapsnh.vltraini = par_vllimtrf
                    crapsnh.dtinstra = TODAY.
        END.




        /** Atualiza dados **/
        ASSIGN crapsnh.vllimweb = par_vllimweb
               crapsnh.vllimtrf = par_vllimtrf
               crapsnh.vllimpgo = par_vllimpgo
               crapsnh.cdoperad = par_cdoperad
               crapsnh.vllimted = par_vllimted
               crapsnh.vllimvrb = par_vllimvrb. 

        IF  aux_vllimweb <> par_vllimweb  THEN 
            ASSIGN crapsnh.dtlimweb = aux_datdodia.

        IF  aux_vllimtrf <> par_vllimtrf  THEN  
            ASSIGN crapsnh.dtlimtrf = aux_datdodia.

        IF  aux_vllimpgo <> par_vllimpgo  THEN
            ASSIGN crapsnh.dtlimpgo = aux_datdodia.

        IF  aux_vllimted <> par_vllimted  THEN
            ASSIGN crapsnh.dtlimted = aux_datdodia.

        IF  aux_vllimvrb <> par_vllimvrb THEN 
            ASSIGN crapsnh.dtlimvrb = aux_datdodia.
        
        /* Replicar limites aos demais responsaveis da assinatura conjunta */
        IF crapass.inpessoa > 1 THEN
        DO:
            RUN replica-limite-internet (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_vllimweb,
                                         INPUT par_vllimtrf,
                                         INPUT par_vllimpgo,
                                         INPUT par_vllimted,
                                         INPUT par_vllimvrb).

            IF RETURN-VALUE <> "OK" THEN
			DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Problema em replicar limites.".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                                               
               UNDO TRANSACAO, LEAVE TRANSACAO. 
            END.
         END. 
          
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
        
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel alterar limites.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
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
                                          
            IF  aux_vllimweb <> par_vllimweb  THEN
                DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vllimweb",
                                             INPUT TRIM(STRING(aux_vllimweb,
                                                               "zzz,zzz,zz9.99")),
                                             INPUT TRIM(STRING(par_vllimweb, 
                                                               "zzz,zzz,zz9.99"))).
                    IF aux_dtlimweb <> aux_datdodia THEN
                        DO:
                            aux_dtlogalt = "".

                            IF ( aux_dtlimweb <> ?) THEN
                                aux_dtlogalt = STRING(aux_dtlimweb,"99/99/9999").
                            

                            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dtlimweb",
                                                 INPUT aux_dtlogalt,
                                                 INPUT STRING(aux_datdodia,"99/99/9999")).
                        END.
                END.
                                                           
            IF  aux_vllimtrf <> par_vllimtrf  THEN
                DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vllimtrf",
                                             INPUT TRIM(STRING(aux_vllimtrf,
                                                               "zzz,zzz,zz9.99")),
                                             INPUT TRIM(STRING(par_vllimtrf, 
                                                               "zzz,zzz,zz9.99"))).
                    IF aux_dtlimtrf <> aux_datdodia THEN
                        DO:
                            aux_dtlogalt = "".

                            IF ( aux_dtlimtrf <> ?) THEN
                                aux_dtlogalt = STRING(aux_dtlimtrf,"99/99/9999").

                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                     INPUT "dtlimtrf",
                                                     INPUT aux_dtlogalt,
                                                     INPUT STRING(aux_datdodia,"99/99/9999")).
                        END.
                END.
                                                           
            IF  aux_vllimpgo <> par_vllimpgo  THEN
                DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vllimpgo",
                                             INPUT TRIM(STRING(aux_vllimpgo,
                                                               "zzz,zzz,zz9.99")),
                                             INPUT TRIM(STRING(par_vllimpgo, 
                                                               "zzz,zzz,zz9.99"))).
                    IF aux_dtlimpgo <> aux_datdodia THEN
                        DO:
                            aux_dtlogalt = "".

                            IF ( aux_dtlimpgo <> ?) THEN
                                aux_dtlogalt = STRING(aux_dtlimpgo,"99/99/9999").

                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                     INPUT "dtlimpgo",
                                                     INPUT aux_dtlogalt,
                                                     INPUT STRING(aux_datdodia,"99/99/9999")).
                        END.
                END.

            IF  aux_vllimted <> par_vllimted  THEN
                DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vllimted",
                                             INPUT TRIM(STRING(aux_vllimted,
                                                               "zzz,zzz,zz9.99")),
                                             INPUT TRIM(STRING(par_vllimted, 
                                                               "zzz,zzz,zz9.99"))).
                     IF aux_dtlimted <> aux_datdodia THEN
                        DO:
                            aux_dtlogalt = "".

                            IF ( aux_dtlimted <> ?) THEN
                                aux_dtlogalt = STRING(aux_dtlimted,"99/99/9999").

                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                     INPUT "dtlimted",
                                                     INPUT aux_dtlogalt,
                                                     INPUT STRING(aux_datdodia,"99/99/9999")).
                     END.
                END.
              
              IF  aux_vllimvrb <> par_vllimvrb  THEN
                  DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "vllimvrb",
                                             INPUT TRIM(STRING(aux_vllimvrb,
                                                               "zzz,zzz,zz9.99")),
                                             INPUT TRIM(STRING(par_vllimvrb, 
                                                               "zzz,zzz,zz9.99"))).
                     IF aux_dtlimvrb <> aux_datdodia THEN
                        DO:
                            aux_dtlogalt = "".

                            IF ( aux_dtlimvrb <> ?) THEN
                                aux_dtlogalt = STRING(aux_dtlimvrb,"99/99/9999").

                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                     INPUT "dtlimvrb",
                                                     INPUT aux_dtlogalt,
                                                     INPUT STRING(aux_datdodia,"99/99/9999")).
                        END.
                  END.
                  
              /* gerar log contas que exigem assinatura multipla */
              IF crapass.inpessoa > 1 THEN
              DO:
                  /* Buscar dados do responsavel legal */
                  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                  RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                      aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                     INPUT par_nrdconta, /* Numero da Conta */
                                     INPUT par_idseqttl, /* Sequencia Titularidade */
                                     INPUT par_idorigem, /* Codigo Origem */
                                    OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                                    OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                                    OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                                    OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                                    OUTPUT 0,            /* Codigo da critica */
                                    OUTPUT "").          /* Descricao da critica */
                  
                  CLOSE STORED-PROC pc_verifica_rep_assinatura
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  
                  ASSIGN aux_nrcpfcgc = 0
                         aux_nmprimtl = ""
                         aux_cdcritic = 0
                         aux_dscritic = ""
                         aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                        WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                         aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                        WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                         aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                        WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                         aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                        WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
                  
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
                       RETURN "NOK".
                                      
                  END.
                  
                  IF  aux_nrcpfcgc > 0 THEN
                    DO:
                        /* Gerar o log com CPF do Rep./Proc. */
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "CPF Representante/Procurador" ,
                                                INPUT "",
                                                INPUT STRING(STRING(aux_nrcpfcgc,
                                                        "99999999999"),"xxx.xxx.xxx-xx")).
                    END.
                    
                  IF aux_nmprimtl <> "" THEN
                    DO:
                        /* Gerar o log com Nome do Rep./Proc. */                                
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "Nome Representante/Procurador" ,
                                                INPUT "",
                                                INPUT aux_nmprimtl).
                    END.
                                          
                  /* FIM Buscar dados responsavel legal */
              END.

        END.
        
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**           Procedure para replicar limite internet para outros titulares  **/
/******************************************************************************/
PROCEDURE replica-limite-internet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimweb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimtrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimpgo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimted AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimvrb AS DECI                           NO-UNDO.
    
    DEF VAR aux_vllimweb AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimtrf AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimpgo AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimted AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimvrb AS DECI                                    NO-UNDO.
    
    DEF BUFFER crabsnh FOR crapsnh.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR  UNDO TRANSACAO, RETURN "NOK"
                   ON QUIT   UNDO TRANSACAO, RETURN "NOK"
                   ON STOP   UNDO TRANSACAO, RETURN "NOK"
                   ON ENDKEY UNDO TRANSACAO, RETURN "NOK":

        /* Replicar limites */
        FOR EACH crabsnh EXCLUSIVE-LOCK WHERE crabsnh.cdcooper  = par_cdcooper AND
                                              crabsnh.nrdconta  = par_nrdconta AND
                                              crabsnh.idseqttl <> par_idseqttl AND
                                              crabsnh.tpdsenha  = 1, 
            FIRST crappod NO-LOCK WHERE crappod.cdcooper = par_cdcooper     AND
                                        crappod.nrdconta = par_nrdconta     AND
                                        crappod.nrcpfpro = crabsnh.nrcpfcgc AND
                                        crappod.cddpoder = 10               AND
                                        crappod.flgconju = TRUE:
            
            /** Armazena dados atuais da senha **/
            ASSIGN aux_vllimweb = crabsnh.vllimweb
                   aux_vllimtrf = crabsnh.vllimtrf
                   aux_vllimpgo = crabsnh.vllimpgo
                   aux_vllimted = crabsnh.vllimted
                   aux_vllimvrb = crabsnh.vllimvrb. 
            
            /** Atualiza dados **/
            ASSIGN crabsnh.vllimweb = par_vllimweb
                   crabsnh.vllimtrf = par_vllimtrf
                   crabsnh.vllimpgo = par_vllimpgo
                   crabsnh.vllimted = par_vllimted
                   crabsnh.vllimvrb = par_vllimvrb
                   crabsnh.dtlimweb = aux_datdodia WHEN aux_vllimweb <> par_vllimweb
                   crabsnh.dtlimtrf = aux_datdodia WHEN aux_vllimtrf <> par_vllimtrf
                   crabsnh.dtlimpgo = aux_datdodia WHEN aux_vllimpgo <> par_vllimpgo
                   crabsnh.dtlimted = aux_datdodia WHEN aux_vllimted <> par_vllimted
                   crabsnh.dtlimvrb = aux_datdodia WHEN aux_vllimvrb <> par_vllimvrb.

            VALIDATE crabsnh.    

        END.

    END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE cria-registro-titular-conta-conjunta:

	DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR cratopi.
	
	CREATE tt-dados-titular.
	ASSIGN tt-dados-titular.idseqttl = 999
		   tt-dados-titular.nmextttl = par_nmextttl
		   tt-dados-titular.nrcpfcgc = cratopi.nrcpfope
		   tt-dados-titular.nmprepos = ""
		   tt-dados-titular.dssitsnh = "ATIVA"
		   tt-dados-titular.dtlibera = ?
		   tt-dados-titular.hrlibera = ""
		   tt-dados-titular.dtaltsnh = ?
		   tt-dados-titular.dtaltsit = ?
		   tt-dados-titular.dtultace = ?
		   tt-dados-titular.hrultace = ""
		   tt-dados-titular.dtacemob = ?
		   tt-dados-titular.hracemob = ""
		   tt-dados-titular.nmoperad = ""
		   tt-dados-titular.vllimweb = cratopi.vllbolet
		   tt-dados-titular.vllimtrf = cratopi.vllimtrf
		   tt-dados-titular.vllimpgo = cratopi.vllimflp
		   tt-dados-titular.vllimted = cratopi.vllimted
		   tt-dados-titular.vllimvrb = cratopi.vllimvrb
		   tt-dados-titular.dtlimtrf = ?
		   tt-dados-titular.dtlimpgo = ?
		   tt-dados-titular.dtlimted = ?
		   tt-dados-titular.dtlimweb = ?
		   tt-dados-titular.dtlimvrb = ?
		   tt-dados-titular.dtblutsh = ?
		   tt-dados-titular.vllimflp = cratopi.vllimflp.

END PROCEDURE.

/******************************************************************************/
/**           Procedure para criar registro dos titulares da conta           **/
/******************************************************************************/
PROCEDURE cria-registro-titular:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextttl AS CHAR                           NO-UNDO.
    DEF INPUT PARAM TABLE FOR cratsnh.
    
    DEF VAR aux_nmprepos AS CHAR                                    NO-UNDO.
    
    FIND FIRST cratsnh NO-LOCK NO-ERROR NO-WAIT.

    CREATE tt-dados-titular.
        
    IF  NOT AVAILABLE cratsnh  THEN
        DO: 
            ASSIGN tt-dados-titular.idseqttl = par_idseqttl
                   tt-dados-titular.nmextttl = par_nmextttl
                   tt-dados-titular.nmprepos = ""
                   tt-dados-titular.dssitsnh = "INATIVA"
                   tt-dados-titular.dtlibera = ?
                   tt-dados-titular.hrlibera = ""
                   tt-dados-titular.dtaltsnh = ?
                   tt-dados-titular.dtaltsit = ?
                   tt-dados-titular.dtultace = ?
                   tt-dados-titular.hrultace = ""
                   tt-dados-titular.dtacemob = ?
                   tt-dados-titular.hracemob = ""
                   tt-dados-titular.nmoperad = ""
                   tt-dados-titular.vllimweb = 0
                   tt-dados-titular.vllimtrf = 0
                   tt-dados-titular.vllimpgo = 0
                   tt-dados-titular.vllimted = 0
                   tt-dados-titular.vllimvrb = 0 
                   tt-dados-titular.dtlimtrf = ?
                   tt-dados-titular.dtlimpgo = ?
                   tt-dados-titular.dtlimted = ?
                   tt-dados-titular.dtlimweb = ?
                   tt-dados-titular.dtlimvrb = ?
                   tt-dados-titular.dtblutsh = ?
				   tt-dados-titular.vllimflp = 0. 
        END.
    ELSE
        DO: 
            FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                               crapope.cdoperad = cratsnh.cdoperad 
                               NO-LOCK NO-ERROR.
                           
            FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                                     crapavt.tpctrato = 6 /**JURIDICA**/ AND
                                     crapavt.nrdconta = par_nrdconta     AND
                                     crapavt.nrcpfcgc = cratsnh.nrcpfcgc
                                     NO-LOCK NO-ERROR.
                                     
            IF  AVAILABLE crapavt  THEN                         
                DO:
                    ASSIGN aux_nmprepos = crapavt.nmdavali.
                
                    /** Se for cooperado pega o nome da crapass **/
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                       crapass.nrdconta = crapavt.nrdctato
                                       NO-LOCK NO-ERROR.

                    IF  AVAILABLE crapass  THEN
                        ASSIGN aux_nmprepos = crapass.nmprimtl.
                END.   
            ELSE
                ASSIGN aux_nmprepos = "".                   
           
            ASSIGN tt-dados-titular.idseqttl = cratsnh.idseqttl
                   tt-dados-titular.nmextttl = par_nmextttl
                   tt-dados-titular.nrcpfcgc = cratsnh.nrcpfcgc
                   tt-dados-titular.nmprepos = aux_nmprepos
                   tt-dados-titular.dssitsnh = IF cratsnh.cdsitsnh = 0 THEN
                                                  "INATIVA"
                                               ELSE
                                               IF cratsnh.cdsitsnh = 1 THEN
                                                  "ATIVA"
                                               ELSE
                                               IF cratsnh.cdsitsnh = 2 THEN
                                                  "BLOQUEADA"
                                               ELSE
                                               IF cratsnh.cdsitsnh = 3 THEN
                                                  "CANCELADA"
                                               ELSE
                                                  ""
                   tt-dados-titular.dtlibera = cratsnh.dtlibera
                   tt-dados-titular.hrlibera = STRING(cratsnh.hrtransa,
                                                      "HH:MM:SS")
                   tt-dados-titular.dtaltsnh = cratsnh.dtaltsnh
                   tt-dados-titular.dtaltsit = cratsnh.dtaltsit
                   tt-dados-titular.dtultace = cratsnh.dtultace
                   tt-dados-titular.hrultace = STRING(cratsnh.hrultace,
                                                      "HH:MM:SS")
                   tt-dados-titular.dtacemob = cratsnh.dtacemob
                   tt-dados-titular.hracemob = STRING(cratsnh.hracemob,
                                                      "HH:MM:SS")
                   tt-dados-titular.vllimweb = cratsnh.vllimweb
                   tt-dados-titular.vllimtrf = cratsnh.vllimtrf
                   tt-dados-titular.vllimpgo = cratsnh.vllimpgo
                   tt-dados-titular.vllimted = cratsnh.vllimted
                   tt-dados-titular.vllimvrb = cratsnh.vllimvrb 
                   tt-dados-titular.nmoperad = IF  AVAILABLE crapope  THEN
                                                   crapope.nmoperad
                                               ELSE
                                                   cratsnh.cdoperad + 
                                                   " - NAO CADASTRADO"
                   tt-dados-titular.dtlimtrf = cratsnh.dtlimtrf
                   tt-dados-titular.dtlimpgo = cratsnh.dtlimpgo
                   tt-dados-titular.dtlimted = cratsnh.dtlimted
                   tt-dados-titular.dtlimweb = cratsnh.dtlimweb
                   tt-dados-titular.dtlimvrb = cratsnh.dtlimvrb
                   tt-dados-titular.dtblutsh = cratsnh.dtblutsh
				   tt-dados-titular.vllimflp = cratsnh.vllimflp. 
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**            Procedure para calcular proximo ou ultimo dia util            **/
/******************************************************************************/
PROCEDURE retorna-dia-util:

    DEF INPUT        PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF INPUT        PARAM par_flgferia AS LOGI                     NO-UNDO.
    DEF INPUT        PARAM par_flgcalcu AS LOGI                     NO-UNDO.    
    DEF INPUT-OUTPUT PARAM par_dtdiacal AS DATE                     NO-UNDO.
    
    DO WHILE TRUE:
                        
        IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtdiacal)))              OR
           (par_flgferia                                             AND
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                   crapfer.dtferiad = par_dtdiacal)) THEN
            DO:
                ASSIGN par_dtdiacal = IF  par_flgcalcu  THEN
                                          par_dtdiacal - 1
                                      ELSE
                                          par_dtdiacal + 1.
                NEXT.
            END.
                    
        LEAVE.
                
    END. /** Fim do DO WHILE TRUE **/

    RETURN "OK".

END.


/******************************************************************************/
/**   Procedure para criar registro de representante legal (tabela crapavt)  **/
/******************************************************************************/
PROCEDURE cria-represen-avt:

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    CREATE tt-represen-ctrnet.
    ASSIGN tt-represen-ctrnet.nrdctato = crapavt.nrdctato
           tt-represen-ctrnet.nmdavali = crapavt.nmdavali
           tt-represen-ctrnet.nrcpfcgc = STRING(STRING(crapavt.nrcpfcgc,
                                                "99999999999"),"xxx.xxx.xxx-xx")
           tt-represen-ctrnet.dsproftl = crapavt.dsproftl
           tt-represen-ctrnet.cdestcvl = crapavt.cdestcvl    
           tt-represen-ctrnet.dsendere = crapavt.dsendres[1] 
           tt-represen-ctrnet.nrendere = TRIM(STRING(crapavt.nrendere))
           tt-represen-ctrnet.complend = crapavt.complend    
           tt-represen-ctrnet.nmbairro = crapavt.nmbairro    
           tt-represen-ctrnet.nmcidade = crapavt.nmcidade    
           tt-represen-ctrnet.cdufende = crapavt.cdufresd
           tt-represen-ctrnet.flgprepo = IF crapsnh.nrcpfcgc = crapavt.nrcpfcgc
                                         THEN TRUE ELSE FALSE.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
                          
    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            RUN p-conectagener IN h-b1wgen9999.
                 
            IF  RETURN-VALUE = "OK"  THEN
                RUN sistema/generico/procedures/b1wgen0015a.p
                                           (INPUT tt-represen-ctrnet.cdestcvl,
                                           OUTPUT tt-represen-ctrnet.dsestcvl).
            ELSE
                ASSIGN tt-represen-ctrnet.dsestcvl = "NAO INFORMADO".
                              
            RUN p-desconectagener IN h-b1wgen9999.

            DELETE PROCEDURE h-b1wgen9999.
        END.
    ELSE
        ASSIGN tt-represen-ctrnet.dsestcvl = "NAO INFORMADO".
        
    RETURN "OK".        
                            
END PROCEDURE.


/******************************************************************************/
/**   Procedure para criar registro de representante legal (tabela crapass)  **/
/******************************************************************************/
PROCEDURE cria-represen-ass:

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    CREATE tt-represen-ctrnet.
    ASSIGN tt-represen-ctrnet.nrdctato = crapass.nrdconta
           tt-represen-ctrnet.nmdavali = crapttl.nmextttl
           tt-represen-ctrnet.nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,
                                                "99999999999"),"xxx.xxx.xxx-xx")
           tt-represen-ctrnet.dsproftl = crapavt.dsproftl
           tt-represen-ctrnet.cdestcvl = crapttl.cdestcvl    
           tt-represen-ctrnet.dsendere = crapenc.dsendere 
           tt-represen-ctrnet.nrendere = TRIM(STRING(crapenc.nrendere))
           tt-represen-ctrnet.complend = crapenc.complend    
           tt-represen-ctrnet.nmbairro = crapenc.nmbairro    
           tt-represen-ctrnet.nmcidade = crapenc.nmcidade    
           tt-represen-ctrnet.cdufende = crapenc.cdufende
           tt-represen-ctrnet.flgprepo = IF crapsnh.nrcpfcgc = crapavt.nrcpfcgc
                                         THEN TRUE ELSE FALSE.
                              
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
                          
    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            RUN p-conectagener IN h-b1wgen9999.
                 
            IF  RETURN-VALUE = "OK"  THEN
                RUN sistema/generico/procedures/b1wgen0015a.p
                                           (INPUT tt-represen-ctrnet.cdestcvl,
                                           OUTPUT tt-represen-ctrnet.dsestcvl).
            ELSE
                ASSIGN tt-represen-ctrnet.dsestcvl = "NAO INFORMADO".
                              
            RUN p-desconectagener IN h-b1wgen9999.

            DELETE PROCEDURE h-b1wgen9999.
        END.
    ELSE
        ASSIGN tt-represen-ctrnet.dsestcvl = "NAO INFORMADO".
          
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure para Impressao de contrato (internet_n.p)           **/
/******************************************************************************/
PROCEDURE gera_impressao_internet_n:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-dados-ctrnet.
    DEF INPUT PARAM TABLE FOR tt-represen-ctrnet.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF  VAR         aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nmarquiv AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dscidade AS CHAR                           NO-UNDO.

    DEF  VAR         aux_qtprepo  AS INT                            NO-UNDO.
    DEF  VAR         aux_qtsocadm AS INT                            NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

FORM "Aguarde... Imprimindo a Declaracao de Recebimento!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM 
     "\022\024\033\120" /* reseta impressora */ /*configs */
     "\0330\033x0\033\017" /* ajusta tamnho e fonte */
     SKIP(5) SPACE(10)
     "\033\016 ACESSO SERVICO INTERNET   -   SOLICITACAO, AUTORIZACAO DE" 
     SKIP SPACE(56) 
     "\033\016        ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JURIDICA"  
     "\022\024\033\120" /* reseta impressora */ /* configs */
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_titulo.
     
FORM SKIP(4)
     tt-dados-ctrnet.nmextcop FORMAT "x(50)" AT 4 NO-LABEL " - " tt-dados-ctrnet.nmrescop NO-LABEL     
     SKIP
     "CNPJ:"      AT 4 tt-dados-ctrnet.nrdocnpj NO-LABEL FORMAT "x(18)"
     SKIP(2)
     "Cooperado:" AT 4 tt-dados-ctrnet.nmprimlt NO-LABEL FORMAT "x(50)"  
     "C/C:"            tt-dados-ctrnet.nrdconta NO-LABEL FORMAT "zzzz,zzz,9"
     SKIP
     "CNPJ:"      AT 4 tt-dados-ctrnet.nrcpfcgc FORMAT "x(18)" 
     SKIP(3)
                  "Socio(s)/Proprietario(s) do Cooperado:" AT 4 
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_cabecalho.

FORM SKIP(2)
     "Nome:"  AT 4 tt-represen-ctrnet.nmdavali NO-LABEL FORMAT "x(50)" 
     SKIP                                              
     "CPF:"   AT 4 tt-represen-ctrnet.nrcpfcgc NO-LABEL FORMAT "x(18)" 
     "Estado Civil:" AT 24 tt-represen-ctrnet.dsestcvl  FORMAT "x(30)" NO-LABEL
     SKIP
     "Cargo:" AT 4 tt-represen-ctrnet.dsproftl NO-LABEL FORMAT "x(18)"
     SKIP
     "End.:"  AT 4 tt-represen-ctrnet.dsendere NO-LABEL FORMAT "x(34)" "," tt-represen-ctrnet.nrendere NO-LABEL 
                  tt-represen-ctrnet.complend           FORMAT "x(10)"
                  aux_dscidade   AT 10                  FORMAT "x(71)"
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_socioadmin.

FORM SKIP(1)
     "Preposto:"     AT  4 tt-represen-ctrnet.nmdavali NO-LABEL FORMAT "x(50)"
     SKIP                                              
     "CPF:"          AT  4 tt-represen-ctrnet.nrcpfcgc NO-LABEL FORMAT "x(18)" 
     "Estado Civil:" AT 24 tt-represen-ctrnet.dsestcvl NO-LABEL FORMAT "x(30)" 
     SKIP
     "End.:" AT 4  tt-represen-ctrnet.dsendere     NO-LABEL FORMAT "x(34)"
                   "," tt-represen-ctrnet.nrendere NO-LABEL 
                   tt-represen-ctrnet.complend              FORMAT "x(10)"
                   aux_dscidade  AT 10                      FORMAT "x(71)" 
     "Tipo de Vinculo:" AT 4 tt-represen-ctrnet.dsproftl FORMAT "x(15)" NO-LABEL                 
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_preposto.

FORM SKIP(5)SPACE(6)
     "\0332\033x0"
     "Solicitamos a Cooperativa  acima  qualificada, que  nos  seja  dado"  
     SKIP SPACE(7) 
     "acesso    aos   Servicos  de  Internet,   atraves   do   seu   site"  
     SKIP SPACE(7)
     "(" tt-dados-ctrnet.dsendweb FORMAT  "x(23)" "), com o qual poderemos realizar, atraves"
     SKIP SPACE(7)
     "de   nosso   computador, os   servicos   e  transacoes  financeiras" 
     SKIP SPACE(7)
     "disponiveis, com  acesso a nossa conta  corrente  acima assinalada,"
     SKIP SPACE(7)                                                  
     "em consonancia como estabelecido nas Condicoes Gerais Aplicaveis ao"
     SKIP SPACE(7)
     "Contrato de Conta Corrente e Investimento, subscrito na data da sua"
     SKIP SPACE(7)
     "abertura."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao.

FORM SKIP(2) SPACE(7)
     "Para a utilizacao dos Servicos de Internet,  autorizamos o Preposto"
     SKIP SPACE(7)                                           
     "acima  qualificado, para  que  individualmente, mediante  o  previo"
     SKIP SPACE(7)
     "cadastramento  de  senha  pessoal  necessaria  ao acesso, efetue as"
     SKIP SPACE(7)
     "transacoes disponibilizadas." 
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao2.

FORM SKIP(2) SPACE(7)
     "Pela  presente  autorizacao  concordamos  com a revogacao, enquanto"
     SKIP SPACE(7)
     "perdurar o presente  termo, de quaisquer  disposicoes em  contrario"
     SKIP SPACE(7)
     "estabelecidas nas  Condicoes Gerais Aplicaveis ao Contrato de Conta"
     SKIP SPACE(7)
     "Corrente   e  Investimento,  com  o  qual  anuimos   em   face   da"
     SKIP SPACE(7)
     "Proposta/Contrato de Abertura de Conta Corrente por nos subscrita."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao3.

FORM SKIP(2) SPACE(7)
     "Assumimos  plena  responsabilidade  sobre  os  atos praticados pelo"
     SKIP SPACE(7)
     "Preposto  acima  qualificado, na condicao  de  usuario dos Servicos"
     SKIP SPACE(7)
     "de Internet disponibilizados pela Cooperativa."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao4.
     
FORM SKIP(2) SPACE(7)
     "Declaramos que e de nosso conhecimento  que nao estao  contempladas"
     SKIP SPACE(7)
     "neste  servico  quaisquer  transacoes  que  envolvam  operacoes  de"
     SKIP SPACE(7)
     "emprestimos,  os  quais  devem   ser  formalizados  diretamente  em" 
     SKIP SPACE(7)
     "em qualquer dos Postos de Atendimento da Cooperativa."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao5.

FORM SKIP(2) SPACE(7)
     "Obrigamo-nos  a  comunicar,  por  escrito, a  Cooperativa, qualquer"
     SKIP SPACE(7)
     "alteracao com relacao as autorizacoes concedidas neste instrumento,"
     SKIP SPACE(7)
     "isentando esta de  qualquer  responsabilidade  pela ausencia de sua" 
     SKIP SPACE(7)
     "tempestiva realizacao."
     SKIP(3) SPACE(7)
     tt-dados-ctrnet.dsrefere FORMAT "x(50)" NO-LABEL       
     SKIP(3) SPACE(7)
     "Socio(s) Proprietario(s):"
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao6.
     
FORM SKIP(3)
     "__________________________________________________" AT 4  
     SKIP
     tt-represen-ctrnet.nmdavali FORMAT "x(45)" AT 4
     SKIP
     tt-represen-ctrnet.nrcpfcgc FORMAT "x(14)" AT 4 LABEL "CPF"
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_asssocioadmin.

FORM SKIP(4)
     "Testemunhas:" AT 4     
     SKIP(3)
     "_______________________________    ______________________________" AT 4
     SKIP(6)
     "De acordo"    AT 4
     SKIP(3)
     "__________________________________________________" AT 12  
     SKIP
     tt-dados-ctrnet.nmextcop FORMAT "x(50)"    AT 12
     SKIP
     tt-dados-ctrnet.nrdocnpj FORMAT "x(18)" AT 29 
     SKIP(4)
     "_____________________"  AT 5
     SKIP                        
     tt-dados-ctrnet.nmoperad FORMAT  "x(20)" NO-LABEL  AT 5
     SKIP
     tt-dados-ctrnet.dsmvtolt FORMAT  "x(22)" NO-LABEL  AT 5
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_operador.

EMPTY TEMP-TABLE tt-erro. 

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.

UNIX SILENT VALUE ("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser + "* 2>/dev/null").

/* Definiçoes de nomes do arquivo */
ASSIGN aux_nmarquiv = par_dsiduser + STRING(TIME)
       par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".ex"
       aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".pdf".

OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL. /* 1/6 */
 
PUT STREAM str_1 CONTROL "\0330\033x0\022\033\120" NULL.
         
VIEW STREAM str_1 FRAME f_titulo.

DISPLAY STREAM str_1 tt-dados-ctrnet.nmextcop tt-dados-ctrnet.nmrescop
                     tt-dados-ctrnet.nrdocnpj tt-dados-ctrnet.nmprimlt  
                     tt-dados-ctrnet.nrdconta tt-dados-ctrnet.nrcpfcgc 
                     WITH FRAME f_cabecalho.

/* Centraliza o nome do titular */
IF   LENGTH(tt-dados-ctrnet.nmprimlt) < 50   THEN 
     tt-dados-ctrnet.nmprimlt = FILL(" ",INT((50 - LENGTH(tt-dados-ctrnet.nmprimlt)) / 2)) + 
                                tt-dados-ctrnet.nmprimlt.
 

/* Centraliza o nome da cooperativa */
IF   LENGTH(tt-dados-ctrnet.nmextcop) < 50   THEN
     tt-dados-ctrnet.nmextcop = FILL(" ",INT((50 - LENGTH(tt-dados-ctrnet.nmextcop)) / 2)) +
                    tt-dados-ctrnet.nmextcop. 
                 
FOR EACH tt-represen-ctrnet NO-LOCK:

    IF  tt-represen-ctrnet.dsproftl = "SOCIO/PROPRIETARIO"  THEN 
        DO:
            ASSIGN aux_dscidade = TRIM(STRING(tt-represen-ctrnet.nmbairro,"x(40)")) + " " +  
                                   TRIM(STRING(tt-represen-ctrnet.nmcidade),"x(25)") + 
                                    " - " + tt-represen-ctrnet.cdufende.

            DISPLAY STREAM str_1 tt-represen-ctrnet.nrcpfcgc FORMAT "x(14)"
                                 tt-represen-ctrnet.nmdavali 
                                 tt-represen-ctrnet.dsendere 
                                 tt-represen-ctrnet.nrendere 
                                 tt-represen-ctrnet.complend FORMAT "x(20)" 
                                 tt-represen-ctrnet.dsproftl 
                                 tt-represen-ctrnet.dsestcvl
                                 aux_dscidade
                                 WITH FRAME f_socioadmin.
            
            DOWN WITH FRAME f_socioadmin.
    
        END.
END.

/* Aqui vem o preposto */
FIND FIRST tt-represen-ctrnet WHERE
             tt-represen-ctrnet.flgprepo = TRUE NO-LOCK NO-ERROR.

IF  AVAIL tt-represen-ctrnet  THEN
    DO:
        IF   LINE-COUNTER(str_1) > 68 THEN
             PAGE STREAM str_1.

        ASSIGN aux_dscidade = TRIM(STRING(tt-represen-ctrnet.nmbairro,"x(40)")) + " " +  
                              TRIM(STRING(tt-represen-ctrnet.nmcidade),"x(25)") + 
                              " - " + tt-represen-ctrnet.cdufende.

        DISPLAY STREAM str_1 tt-represen-ctrnet.nrcpfcgc FORMAT "x(14)"
                             tt-represen-ctrnet.nmdavali 
                             tt-represen-ctrnet.dsendere 
                             tt-represen-ctrnet.nrendere 
                             tt-represen-ctrnet.complend FORMAT "x(20)"
                             tt-represen-ctrnet.dsproftl 
                             tt-represen-ctrnet.dsestcvl
                             aux_dscidade
                             WITH FRAME f_preposto.
    END.

DISPLAY STREAM str_1 tt-dados-ctrnet.dsendweb WITH FRAME f_autorizacao.

VIEW STREAM str_1 FRAME f_autorizacao2.
VIEW STREAM str_1 FRAME f_autorizacao3.
VIEW STREAM str_1 FRAME f_autorizacao4.
VIEW STREAM str_1 FRAME f_autorizacao5.

DISPLAY STREAM str_1 tt-dados-ctrnet.dsrefere WITH FRAME f_autorizacao6.

FOR EACH tt-represen-ctrnet NO-LOCK:
    IF   tt-represen-ctrnet.flgprepo   THEN
         aux_qtprepo  = aux_qtprepo + 1.
    ELSE
         aux_qtsocadm = aux_qtsocadm + 1.
END.

FOR EACH tt-represen-ctrnet WHERE 
        tt-represen-ctrnet.dsproftl = "SOCIO/PROPRIETARIO" NO-LOCK:

    /* Se possui socio/prop e nao for o preposto, imprime sem o preposto */
    IF  (aux_qtsocadm >= aux_qtprepo)  THEN
        DO: 
            IF   LINE-COUNTER(str_1) > 60  THEN
                 PAGE STREAM str_1.
            DISPLAY STREAM str_1 tt-represen-ctrnet.nmdavali
                                 tt-represen-ctrnet.nrcpfcgc
                                 WITH FRAME f_asssocioadmin.
            DOWN WITH FRAME f_asssocioadmin.                      
     
         END.
    ELSE /* se tiver preposto e nao tiver socio/prop, imprime o preposto */
    IF   aux_qtprepo > aux_qtsocadm    AND
         tt-represen-ctrnet.flgprepo = TRUE THEN
         DO:
            IF   LINE-COUNTER(str_1) > 60  THEN
                 PAGE STREAM str_1.
            DISPLAY STREAM str_1 tt-represen-ctrnet.nmdavali
                                 tt-represen-ctrnet.nrcpfcgc
                                 WITH FRAME f_asssocioadmin.
            DOWN WITH FRAME f_asssocioadmin.
         END.
END.

IF   LINE-COUNTER(str_1) > 55  THEN
     PAGE STREAM str_1.

DISPLAY STREAM str_1 tt-dados-ctrnet.nmextcop
                     tt-dados-ctrnet.nrdocnpj
                     tt-dados-ctrnet.nmoperad
                     tt-dados-ctrnet.dsmvtolt
                     WITH FRAME f_operador.

OUTPUT STREAM str_1 CLOSE.

IF  par_idorigem = 5  THEN  /** Ayllos Web **/
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
            
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".
        ELSE
            DO:
                RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT par_nmarqimp,
                                                      OUTPUT par_nmarqimp,
                                                      OUTPUT TABLE tt-erro).
        
                DELETE PROCEDURE h-b1wgen0024.
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAILABLE tt-erro  THEN
                            ASSIGN aux_dscritic = tt-erro.dscritic.
                        ELSE
                            ASSIGN aux_dscritic = "Nao foi possivel " +
                                                  "gerar a impressao.".
                    END.
            END.
    
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
    END.            

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure para Impressao de contrato (internet_m.p)           **/
/******************************************************************************/
PROCEDURE gera_impressao_internet_m:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-dados-ctrnet.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nmarquiv AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

FORM "\022\024\033\120\0330\033x0\033\105" /* Reseta e seta a fonte */
     SKIP(4) SPACE (7)
     "DECLARACAO DE ACESSO E MOVIMENTACAO DE CONTAS POR MEIO DA INTERNET"  
     "\033\120\033\106"
     "\022\024\033\120" /* reseta impressora */
     SKIP(4)SPACE(6)
     "\0332\033x0"
     "Declaro-me ciente de que poderei acessar de forma personalizada, as"  
     SKIP SPACE(7) 
     "minhas contas de deposito por meio da internet, diretamente no site"  
     SKIP SPACE(7)
     "(" tt-dados-ctrnet.dsendweb FORMAT  "x(24)" "),  podendo  processar os  servicos  ali"
     SKIP SPACE(7)
     "disponibilizados,  sendo que,  para tanto, autorizo a Cooperativa a" 
     SKIP SPACE(7)
     "disponibilizar  no seu site  informacoes referentes  a  minha conta"
     SKIP SPACE(7)                                                  
     "corrente de numero" tt-dados-ctrnet.nrdconta FORMAT "zzzz,zzz,9"
     "e outros dados pessoais, " 
     "nos  termos"
     SKIP SPACE(7)
     "do  estabelecido  nas  Condicoes Gerais Aplicaveis  ao  Contrato de"
     SKIP SPACE(7)
     "Conta Corrente e Conta Investimento, disponivel no site da Coopera-"
     SKIP SPACE(7)                                           
     "tiva,  cuja copia,  na condicao de Cooperado(a),  recebi quando  da"
     SKIP SPACE(7)
     "abertura  de  minha conta corrente e/ou renovacao de cadastro."
     SKIP(1)SPACE(7)
     "Declaro-me igualmente  ciente de que,  apos  o  cadastramento da(s)" 
     SKIP SPACE(7)
     "senhas(s),  feito junto  ao PA (Posto de Atendimento) onde mantenho"
     SKIP SPACE(7)
     "minha conta corrente, terei o prazo de" tt-dados-ctrnet.dsdiaace "para  estabelecer o"
     SKIP SPACE(7)
     "primeiro acesso, caso contrario, o mesmo nao sera permitido, neces-"
     SKIP SPACE(7)
     "sitando um recadastramento, ficando sob minha inteira responsabili-"
     SKIP SPACE(7)
     "dade  a guarda  das  senhas  e codigos  de acesso  ao sistema,  nao"
     SKIP SPACE(7)
     "cabendo  a  Cooperativa   nenhuma   responsabilidade  pelo  seu uso"
     SKIP SPACE(7)
     "indevido."
     SKIP(3)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao.
     
FORM tt-dados-ctrnet.dsrefere  FORMAT "x(50)" NO-LABEL       AT 4
     SKIP(7)
     "______________________________________"   AT  19
     SKIP
     tt-dados-ctrnet.nmprimlt  FORMAT "x(50)"               NO-LABEL      AT  18
     SKIP                                              
     tt-dados-ctrnet.nrdconta  FORMAT "zzzz,zzz,9" LABEL "Conta/dv"  AT  28            
     SKIP(2)
     "De acordo"                                AT  4
     SKIP(3)
     "__________________________________________________" AT 12  
     SKIP
     tt-dados-ctrnet.nmextcop  FORMAT "x(50)"    AT 12
     SKIP
     tt-dados-ctrnet.nrdocnpj  FORMAT "x(18)" AT 29 
     SKIP(4)
     "_____________________"  AT 5
     SKIP
     tt-dados-ctrnet.nmoperad  FORMAT  "x(20)" NO-LABEL  AT 5
     SKIP
     tt-dados-ctrnet.dsmvtolt  FORMAT  "x(22)" NO-LABEL  AT 5
     
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_assinar.

EMPTY TEMP-TABLE tt-erro.

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.

UNIX SILENT VALUE ("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser + "* 2>/dev/null").

/* Definiçao de nomes do arquivo */
    ASSIGN aux_nmarquiv = par_dsiduser + STRING(TIME)
           par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".ex"
           aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".pdf".

OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL. /* 1/6 */
 
PUT STREAM str_1 CONTROL "\0330\033x0\022\033\120" NULL.
         
DISPLAY STREAM str_1 tt-dados-ctrnet.dsendweb
                     tt-dados-ctrnet.nrdconta 
                     tt-dados-ctrnet.dsdiaace
                     WITH FRAME f_autorizacao.

/* Centraliza o nome do titular */
IF   LENGTH(tt-dados-ctrnet.nmprimlt) < 50   THEN 
     tt-dados-ctrnet.nmprimlt = FILL(" ",INT((50 - LENGTH(tt-dados-ctrnet.nmprimlt)) / 2)) + 
                    tt-dados-ctrnet.nmprimlt.
 

/* Centraliza o nome da cooperativa */
IF   LENGTH(tt-dados-ctrnet.nmextcop) < 50   THEN
     tt-dados-ctrnet.nmextcop = FILL(" ",INT((50 - LENGTH(tt-dados-ctrnet.nmextcop)) / 2)) +
                    tt-dados-ctrnet.nmextcop. 
                 
DISPLAY STREAM str_1 tt-dados-ctrnet.dsrefere
                     tt-dados-ctrnet.nmprimlt
                     tt-dados-ctrnet.nrdconta
                     tt-dados-ctrnet.nmextcop
                     tt-dados-ctrnet.nrdocnpj
                     tt-dados-ctrnet.nmoperad
                     tt-dados-ctrnet.dsmvtolt
                     WITH FRAME f_assinar.     

OUTPUT STREAM str_1 CLOSE.

IF  par_idorigem = 5  THEN  /** Ayllos Web **/
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
            
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".
        ELSE
            DO:
                RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT par_nmarqimp,
                                                      OUTPUT par_nmarqimp,
                                                      OUTPUT TABLE tt-erro).
        
                DELETE PROCEDURE h-b1wgen0024.
        
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAILABLE tt-erro  THEN
                            ASSIGN aux_dscritic = tt-erro.dscritic.
                        ELSE
                            ASSIGN aux_dscritic = "Nao foi possivel " +
                                                  "gerar a impressao.".
                    END.
            END.
        
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
    END.                                                                      
    
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**           Procedure para consulta de contas de trnsf cadastradas         **/
/******************************************************************************/
PROCEDURE consulta-contas-cadastradas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tppeslst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_intipdif AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtitula AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_qtregini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtregfim AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-contas-cadastradas.
	DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssitcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsctatrf AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmextbcc AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmageban AS CHAR                                    NO-UNDO.

    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
            
    EMPTY TEMP-TABLE tt-contas-cadastradas.
    
    FOR EACH crapcti WHERE crapcti.cdcooper = par_cdcooper AND
                           crapcti.nrdconta = par_nrdconta AND
                          (crapcti.insitcta = 2            OR
                           crapcti.insitcta = 3)           AND
                           crapcti.intipdif = par_intipdif NO-LOCK:

        ASSIGN par_qtregist = par_qtregist + 1.
		
		IF par_qtregfim < par_qtregist THEN
			DO:
				NEXT.
			END.
			
		IF par_qtregini >= par_qtregist THEN
			DO:
				NEXT.
			END.

        /** Nao exibe contas bloqueadas para sistema cecred */
        IF  crapcti.insitcta = 3 AND par_intipdif = 1 AND par_idorigem = 3 THEN
            NEXT.

        /** Pesquisa contas pelo nome **/
        IF TRIM(par_nmtitula) <> "" AND
            NOT crapcti.nmtitula MATCHES "*" + par_nmtitula + "*"  THEN
            NEXT.

        FIND crapope WHERE crapope.cdcooper = crapcti.cdcooper AND
                           crapope.cdoperad = crapcti.cdoperad 
                           NO-LOCK NO-ERROR.

        ASSIGN aux_dsoperad = STRING(crapcti.cdoperad) + " - " +
                             (IF  AVAIL crapope  THEN
                                  STRING(crapope.nmoperad,"x(30)")
                              ELSE
                                  STRING("NAO CADASTRADO","x(30)"))
               aux_dstransa = STRING(crapcti.dttransa,"99/99/9999") + " - " +
                              STRING(crapcti.hrtransa,"HH:MM:SS")
               aux_dssitcta = IF  crapcti.insitcta = 2  THEN
                                  "Ativa"
                              ELSE
                                  "Bloqueada".              

        IF  crapcti.intipdif = 1  THEN /** Cooperativa **/
            DO:                
                FIND crapcop WHERE crapcop.cdagectl = crapcti.cdageban
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapcop   THEN
                     NEXT.                

                FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                   crapass.nrdconta = INTE(crapcti.nrctatrf) 
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapass  THEN
                     NEXT.

                IF   crapass.dtdemiss <> ?   THEN
                     NEXT.

                /** Verificar quais contas deve carregar (0 para todas) **/
                IF (par_tppeslst = 1 AND crapass.inpessoa > 1) OR   /** PF **/
                   (par_tppeslst = 2 AND crapass.inpessoa = 1) THEN /** PJ **/
                    NEXT.      

                ASSIGN aux_inpessoa = IF  crapass.inpessoa > 2  THEN
                                          2
                                      ELSE
                                          crapass.inpessoa.

                IF  crapass.inpessoa = 1  THEN
                    DO: 
                        FIND crapttl WHERE 
                             crapttl.cdcooper = crapcop.cdcooper       AND
                             crapttl.nrdconta = INTE(crapcti.nrctatrf) AND 
                             crapttl.idseqttl = 1
                             NO-LOCK NO-ERROR.
            
                        IF  AVAIL crapttl  THEN
                            ASSIGN aux_nmprimtl = crapttl.nmextttl
                                   aux_nrcpfcgc = STRING(crapttl.nrcpfcgc,
                                                         "99999999999").
                        ELSE
                            ASSIGN aux_nmprimtl = crapass.nmprimtl
                                   aux_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                         "99999999999").

                        ASSIGN aux_nrcpfcgc = STRING(aux_nrcpfcgc,
                                                     "xxx.xxx.xxx-xx").
													 
						FOR FIRST crapttl FIELDS(nmextttl) 
						                   WHERE crapttl.cdcooper = crapcop.cdcooper       AND
                                                 crapttl.nrdconta = INTE(crapcti.nrctatrf) AND 
                                                 crapttl.idseqttl = 2
                                                 NO-LOCK:

						  ASSIGN aux_nmprimtl = aux_nmprimtl + " " + crapttl.nmextttl.

						END.

                    END.
                ELSE
                    ASSIGN aux_nmprimtl = crapass.nmprimtl
                           aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                                 "99999999999999"),
                                                 "xx.xxx.xxx/xxxx-xx"). 

                ASSIGN aux_dsctatrf = STRING(crapass.nrdconta,"zzzzzzzz,zz9,9")
                       aux_dstipcta = "".

            END.
        ELSE  /** Contas IF's **/
            DO:
                ASSIGN aux_nmprimtl = crapcti.nmtitula
                       aux_inpessoa = crapcti.inpessoa.

                IF  aux_inpessoa = 1  THEN
                    ASSIGN aux_nrcpfcgc = STRING(STRING(crapcti.nrcpfcgc,
                                                 "99999999999"),
                                                 "xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN aux_nrcpfcgc = STRING(STRING(crapcti.nrcpfcgc,
                                                 "99999999999999"),
                                                 "xx.xxx.xxx/xxxx-xx"). 

                ASSIGN aux_dsctatrf = STRING(crapcti.nrctatrf,"zzzzzzzzzzzz,9").

                FIND craptab WHERE craptab.cdcooper = par_cdcooper     AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 00               AND
                                   craptab.cdacesso = "TPCTACRTED"     AND
                                   craptab.tpregist = crapcti.intipcta
                                   NO-LOCK NO-ERROR.

                ASSIGN aux_dstipcta = IF  NOT AVAIL craptab  THEN
                                          "NAO CADASTRADO"
                                      ELSE
                                          CAPS(craptab.dstextab). 
            END.

        FIND crapban WHERE crapban.cdbccxlt = crapcti.cddbanco
                           NO-LOCK NO-ERROR.
                                                   
        IF AVAIL crapban THEN 
             ASSIGN aux_nmextbcc = REPLACE(CAPS(TRIM(crapban.nmextbcc)),"&","e").
        ELSE
        DO:
            FIND crapban WHERE crapban.nrispbif = crapcti.nrispbif
                           NO-LOCK NO-ERROR.
            IF AVAIL crapban THEN 
               ASSIGN aux_nmextbcc = REPLACE(CAPS(TRIM(crapban.nmextbcc)),"&","e").
            ELSE
               ASSIGN aux_nmextbcc =  "NAO CADASTRADO".
        END.
                                

        FOR FIRST crapagb FIELDS(nmageban) WHERE crapagb.cddbanco = crapcti.cddbanco
                                             AND crapagb.cdageban = crapcti.cdageban NO-LOCK. END.

        IF AVAIL crapagb THEN
          ASSIGN aux_nmageban = crapagb.nmageban.
        ELSE
          ASSIGN aux_nmageban = "AGENCIA NAO CADASTRADA".

        RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_nmageban).

        CREATE tt-contas-cadastradas.
        ASSIGN tt-contas-cadastradas.intipdif = crapcti.intipdif
               tt-contas-cadastradas.cddbanco = crapcti.cddbanco
               tt-contas-cadastradas.nmextbcc = aux_nmextbcc
               tt-contas-cadastradas.cdageban = crapcti.cdageban
               tt-contas-cadastradas.nrctatrf = crapcti.nrctatrf
               tt-contas-cadastradas.nmtitula = aux_nmprimtl
               tt-contas-cadastradas.nrcpfcgc = crapcti.nrcpfcgc
               tt-contas-cadastradas.dscpfcgc = aux_nrcpfcgc
               tt-contas-cadastradas.dstransa = aux_dstransa
               tt-contas-cadastradas.dsoperad = aux_dsoperad
               tt-contas-cadastradas.insitcta = crapcti.insitcta
               tt-contas-cadastradas.dssitcta = aux_dssitcta
               tt-contas-cadastradas.inpessoa = aux_inpessoa
               tt-contas-cadastradas.dsctatrf = aux_dsctatrf
               tt-contas-cadastradas.nrseqcad = crapcti.nrseqcad
               tt-contas-cadastradas.dstipcta = aux_dstipcta
               tt-contas-cadastradas.intipcta = crapcti.intipcta
               tt-contas-cadastradas.nrispbif = crapcti.nrispbif
               tt-contas-cadastradas.nmageban = aux_nmageban.

        IF   crapcti.intipdif = 1   THEN
             ASSIGN tt-contas-cadastradas.dsageban = 
                 STRING(crapcti.cdageban,"9999") + " - " + crapcop.nmrescop. 
        ELSE
             ASSIGN tt-contas-cadastradas.dsageban = aux_nmextbcc.

    END. /** Fim do FOR EACH crapcti **/

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**      Procedure para alterar situaçao de contas de trnsf cadastradas      **/
/******************************************************************************/
PROCEDURE altera-dados-cont-cadastrada:

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

    DEF  INPUT PARAM par_nmtitula AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_intipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_insitcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_intipdif AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_insitcta AS INT                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-crapcti-old.
    EMPTY TEMP-TABLE tt-crapcti-new. 
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar dados de Conta para Transferencia.".

    ALTERA: DO TRANSACTION
        ON ERROR  UNDO ALTERA, LEAVE ALTERA
        ON QUIT   UNDO ALTERA, LEAVE ALTERA
        ON STOP   UNDO ALTERA, LEAVE ALTERA
        ON ENDKEY UNDO ALTERA, LEAVE ALTERA:
            
		    /** Se for conta de outras Instituições financeiras (TED) e for para 
			    desativar favorecido**/
		    IF par_intipdif = 2 AND 
			   par_insitcta = 3 THEN 
			   DO:
				   FIND FIRST craplau WHERE craplau.cdcooper = par_cdcooper   AND
											craplau.nrdconta = par_nrdconta   AND
											craplau.nrctadst = par_nrctatrf   AND
											craplau.cdtiptra = 4 /*TED*/      AND
											craplau.insitlau = 1 /*Pendente*/ AND
											craplau.cddbanco = par_cddbanco   AND
											craplau.cdageban = par_cdageban
											NO-LOCK NO-ERROR.

				   IF AVAIL craplau THEN
					  DO:
					     ASSIGN aux_dscritic = "Para desativar, desabilite a(s) ted(s) " + 
											   "agendada(s) para este favorecido.".

						 RUN gera_erro (INPUT par_cdcooper,
									    INPUT par_cdagenci,
									    INPUT par_nrdcaixa,
									    INPUT 1,            /** Sequencia **/
									    INPUT 0,            /** Critica   **/
									    INPUT-OUTPUT aux_dscritic).

						 UNDO ALTERA, LEAVE ALTERA.

					  END.

               END.

            Contador: DO aux_contador = 1 TO 10:

                FIND crapcti WHERE crapcti.cdcooper = par_cdcooper  AND
                                   crapcti.nrdconta = par_nrdconta  AND
                                   crapcti.nrctatrf = par_nrctatrf  AND
                                   crapcti.cddbanco = par_cddbanco  AND
                                   crapcti.cdageban = par_cdageban
                                   EXCLUSIVE-LOCK NO-WAIT NO-ERROR.                                     
                                              
                IF  NOT AVAILABLE crapcti THEN
                    DO:
                       IF  LOCKED crapcti THEN
                           DO:
                              IF  aux_contador = 10 THEN
                                  DO:
                                     ASSIGN aux_cdcritic = 341.
                                     LEAVE Contador.
                                  END.
              
                              PAUSE 1 NO-MESSAGE.
                              NEXT Contador.
                           END.
                       ELSE
                           DO:
                              ASSIGN aux_cdcritic = 9.
                              LEAVE Contador.
                           END.
                    END.
                ELSE
                    LEAVE Contador.
            END.

            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

               

                    UNDO ALTERA, LEAVE ALTERA.
                END.

            CREATE tt-crapcti-old.
            BUFFER-COPY crapcti TO tt-crapcti-old.
            ASSIGN tt-crapcti-old.nrctatrf = 0
                   tt-crapcti-old.intipdif = 0.

            IF  par_intipdif = 1 THEN /** Conta do Sistema **/
                ASSIGN par_nmtitula = ""
                       par_inpessoa = 0 
                       par_nrcpfcgc = 0
                       par_intipcta = 1.

            /* Atualiza os valores */
            ASSIGN crapcti.nmtitula = CAPS(par_nmtitula)
                   crapcti.nrcpfcgc = par_nrcpfcgc
                   crapcti.inpessoa = par_inpessoa
                   crapcti.intipcta = par_intipcta
                   crapcti.insitcta = par_insitcta /* Situaçao */
                   crapcti.dttransa = par_dtmvtolt
                   crapcti.hrtransa = TIME
                   crapcti.cdoperad = par_cdoperad.

            CREATE tt-crapcti-new.
            BUFFER-COPY crapcti TO tt-crapcti-new.
            ASSIGN tt-crapcti-new.nrctatrf = crapcti.nrctatrf
                   tt-crapcti-new.intipdif = crapcti.intipdif.

     END.

     IF aux_dscritic <> ""  THEN
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
          RUN proc_gerar_log_tab (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT "",
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT TRUE,
                                  INPUT par_idseqttl, 
                                  INPUT par_nmdatela, 
                                  INPUT par_nrdconta, 
                                  INPUT TRUE,
                                  INPUT BUFFER tt-crapcti-old:HANDLE,
                                  INPUT BUFFER tt-crapcti-new:HANDLE).

      RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**          Realiza a validaçao para inclusao de contas de trnsf            **/
/******************************************************************************/
PROCEDURE valida-inclusao-conta-transferencia:

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

    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdispbif AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_intipdif AS INTE                           NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_intipcta AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_insitcta AS INTE                           NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_nrcpfcgc AS DECI                    NO-UNDO.
    DEF  INPUT PARAM par_flvldinc AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM par_rowidcti AS CHAR                           NO-UNDO.

    DEF  INPUT-OUTPUT PARAM par_nmtitula AS CHAR                    NO-UNDO.

    DEF  OUTPUT PARAM par_dscpfcgc AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

	DEF VAR aux_dsibcrit AS CHAR                                    NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_val_inclui_conta_transf
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtmvtolt,
                                            INPUT INT(par_flgerlog),
                                            INPUT par_cddbanco,
                                            INPUT par_cdispbif,
                                            INPUT par_cdageban,
                                            INPUT par_nrctatrf,
                                            INPUT par_intipdif,
                                            INPUT par_intipcta,
                                            INPUT par_insitcta,
                                            INPUT par_inpessoa,
                                            INPUT DEC(par_nrcpfcgc),
                                            INPUT INT(par_flvldinc),
                                            INPUT INT(par_rowidcti),
                                            INPUT par_nmtitula,
                                           OUTPUT "",
                                           OUTPUT "",
                                           OUTPUT 0,
                                           OUTPUT "").          /* Descricao da critica */

    CLOSE STORED-PROC pc_val_inclui_conta_transf
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dscpfcgc = ""
           par_nmdcampo = ""
           par_nmtitula = "" 
           par_nrcpfcgc = 0
           par_inpessoa = 0
           par_intipcta = 0
           aux_dscritic = ""
           aux_cdcritic = 0
           par_dscpfcgc = pc_val_inclui_conta_transf.pr_dscpfcgc 
                          WHEN pc_val_inclui_conta_transf.pr_dscpfcgc <> ?
           par_nmdcampo = pc_val_inclui_conta_transf.pr_nmdcampo 
                          WHEN pc_val_inclui_conta_transf.pr_nmdcampo <> ?
           par_nmtitula = pc_val_inclui_conta_transf.pr_nmtitula 
                          WHEN pc_val_inclui_conta_transf.pr_nmtitula <> ?                          
           par_nrcpfcgc = pc_val_inclui_conta_transf.pr_nrcpfcgc 
                          WHEN pc_val_inclui_conta_transf.pr_nrcpfcgc <> ?                          
           par_inpessoa = pc_val_inclui_conta_transf.pr_inpessoa 
                          WHEN pc_val_inclui_conta_transf.pr_inpessoa <> ?
           par_intipcta = pc_val_inclui_conta_transf.pr_intipcta 
                          WHEN pc_val_inclui_conta_transf.pr_intipcta <> ?                          
           aux_cdcritic = pc_val_inclui_conta_transf.pr_cdcritic 
                          WHEN pc_val_inclui_conta_transf.pr_cdcritic <> ?
           aux_dscritic = pc_val_inclui_conta_transf.pr_dscritic
                          WHEN pc_val_inclui_conta_transf.pr_dscritic <> ?.

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
        DO:
          EMPTY TEMP-TABLE tt-erro.

          /* Se for InternetBank, monta critica mais adequada e grava no log a critica real */
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
      
      
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**                  Procedure para incluir conta de trnsf                   **/
/******************************************************************************/
PROCEDURE inclui-conta-transferencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf             NO-UNDO.
    DEF  INPUT PARAM par_nmtitula AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_intipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_intipdif AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidcti AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdispbif LIKE crapcti.nrispbif             NO-UNDO.

    DEF OUTPUT PARAM par_msgaviso AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
                
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_inclui_conta_transf
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                       INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_dtmvtolt,
                                       INPUT par_nrcpfope,
                                            INPUT INT(par_flgerlog),
                                            INPUT par_cddbanco,
                                            INPUT par_cdageban,
                                            INPUT par_nrctatrf,
                                            INPUT CAPS(par_nmtitula),
                                            INPUT DEC(par_nrcpfcgc),
                                            INPUT par_inpessoa,
                                            INPUT par_intipcta,
                                            INPUT par_intipdif,
                                            INPUT INT(par_rowidcti),
                                            INPUT par_cdispbif,
                                           OUTPUT "",  /* msgaviso */
                                           OUTPUT "",  /* des_erro */
                                           OUTPUT 0,   /* cdcritic */
                                           OUTPUT ""). /* dscritic */
    
    CLOSE STORED-PROC pc_inclui_conta_transf
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_msgaviso = "" 
           aux_dscritic = ""
           aux_cdcritic = 0
           par_msgaviso = pc_inclui_conta_transf.pr_msgaviso 
                          WHEN pc_inclui_conta_transf.pr_msgaviso <> ?
           aux_cdcritic = pc_inclui_conta_transf.pr_cdcritic 
                          WHEN pc_inclui_conta_transf.pr_cdcritic <> ?
           aux_dscritic = pc_inclui_conta_transf.pr_dscritic
                          WHEN pc_inclui_conta_transf.pr_dscritic <> ?.
                        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
                DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
                                           
            RETURN "NOK".                           
        END.

     RETURN "OK".
    
END PROCEDURE.
/******************************************************************************/
/**                  Procedure para remover conta de trnsf pendente          **/
/******************************************************************************/
PROCEDURE exclui-conta-transferencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rowidcti AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF VAR aux_dsmotivo AS CHAR                                    NO-UNDO.

    DEF BUFFER crabcti FOR crapcti.

    EMPTY TEMP-TABLE tt-erro.


    /* Verifica se o RECID da tabela */
    IF  par_rowidcti = "" THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Identificador de registro esta vazio!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.
        
    /* Busca o registro que sera desativado */
    FIND FIRST crapcti WHERE RECID(crapcti) = INT(par_rowidcti) EXCLUSIVE-LOCK NO-ERROR.

    IF  NOT AVAIL crapcti THEN DO: /* Se nao encontrou o registro */
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Registro nao localizado!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN /* Alteracao feita pelo cooperado */
           /* Dados do Sistema */
           crapcti.insitfav = 3 /* Registro Desativado */
           crapcti.cdoperad = par_cdoperad
           crapcti.dttransa = aux_datdodia
           crapcti.hrtransa = TIME
           aux_dsmotivo     = "O cooperado removeu o favorecido. " +
                              "Banco: " + STRING(crapcti.cddbanco) + " Agencia: " +
                              STRING(crapcti.cdageban) + " Conta: " + STRING(crapcti.nrctatrf).

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dsmotivo,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**       Procedure para verificaçao de senha de acesso a Internet           **/
/******************************************************************************/
PROCEDURE verifica-senha-internet:

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
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsnhrep AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro. 

    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            NO-LOCK NO-ERROR.
    DO WHILE TRUE:
    
        IF  NOT AVAILABLE crapsnh  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de senha nao encontrado.".
            LEAVE.
            END.
        
        IF  par_cddsenha <> par_cdsnhrep              OR
            ENCODE(par_cddsenha) <> crapsnh.cddsenha  THEN
            DO:
                ASSIGN aux_cdcritic = 3
                       aux_dscritic = "".
            END.

        LEAVE.
    END.

   IF aux_dscritic <> ""  OR 
      aux_cdcritic <> 0   THEN
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

END PROCEDURE.

/******************************************************************************/
/**                  Procedure para contar contas de transf                  **/
/******************************************************************************/
PROCEDURE resumo-cnts-internet:

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

    DEF  OUTPUT PARAM par_cntrgcad AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_cntrgpen AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtdregis AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-contas-cadastradas. 
    EMPTY TEMP-TABLE tt-erro.

    DO aux_contador = 1 TO 2:
        
        RUN consulta-contas-cadastradas (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,/* Caixa */
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem, /* Ayllos/WEB */
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_dtmvtolt,
                                         INPUT 0,
                                         INPUT aux_contador, /* 1 - Coop | 2 - Outras IFs */
                                         INPUT "",
                                         OUTPUT TABLE tt-contas-cadastradas).
        
        FOR EACH tt-contas-cadastradas NO-LOCK:
            ASSIGN par_cntrgcad = par_cntrgcad + 1. /* Total de Contas Cadastradas */
        END.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**     Procedure para retornar tipos de contas [consultados na CRAPTAB]     **/
/******************************************************************************/
PROCEDURE consulta-tipos-contas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-tp-contas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-tp-contas.
    EMPTY TEMP-TABLE tt-erro. 

    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "TPCTACRTED" NO-LOCK:

        CREATE tt-tp-contas.
        ASSIGN tt-tp-contas.nmtipcta = CAPS(craptab.dstextab)
               tt-tp-contas.intipcta = STRING(craptab.tpregist).

    END.

    IF  NOT TEMP-TABLE tt-tp-contas:HAS-RECORDS  THEN
        DO:
            ASSIGN aux_dscritic = "Tipos de Contas nao encontrados".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
     
            RETURN "NOK".
        END.
 
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**    Procedure para retornar finalidades da TED [consultados na CRAPTAB]   **/
/******************************************************************************/
PROCEDURE consulta-finalidades:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-finted.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-finted.
    EMPTY TEMP-TABLE tt-erro. 

    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "FINTRFTEDS" NO-LOCK:

        CREATE tt-finted.
        ASSIGN tt-finted.dsfinali = CAPS(craptab.dstextab)
               tt-finted.cdfinali = craptab.tpregist
               tt-finted.flgselec = IF craptab.tpregist = 10 
                                    THEN TRUE ELSE FALSE.

    END.

    IF  NOT TEMP-TABLE tt-finted:HAS-RECORDS  THEN
        DO:
            ASSIGN aux_dscritic = "Finalidades nao cadastradas".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
     
            RETURN "NOK".
        END.
 
    RETURN "OK".

END PROCEDURE.


PROCEDURE valida-conta-destino:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtiptra AS INTE                           NO-UNDO.
    /* 1 - Transf. Normal / 3 - Credito Salario */

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_flgctafa AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmtitula AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmtitul2 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cddbanco AS INTE                           NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.
    

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Validacao:
    DO ON ERROR UNDO, LEAVE Validacao:

        /* Cooperativa do assoc. logado */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcop   THEN
             DO:
                 ASSIGN aux_cdcritic = 651.
                 LEAVE Validacao.
             END.

        /* Conta do cooperado logado */
        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND 
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE Validacao.
             END.

        /* Cooperativa de destino */
        FIND crabcop WHERE crabcop.cdagectl = par_cdagectl NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabcop   THEN
             DO:
                 ASSIGN aux_dscritic = 
                        "Cooperativa selecionada nao existe no sistema.".
                 LEAVE Validacao.
             END.

        /* Conta destino */
        FIND crabass WHERE crabass.cdcooper = crabcop.cdcooper   AND
                           crabass.nrdconta = par_nrctatrf
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crabass   THEN
             DO:
                 ASSIGN aux_dscritic = 
                        "Conta destino nao possui cadastro na cooperativa.".
                 LEAVE Validacao.
             END.

        /* Se mesma coop. e conta */
        IF   crapass.cdcooper = crabass.cdcooper   AND
             crapass.nrdconta = crabass.nrdconta   THEN
             DO:
                 ASSIGN aux_dscritic = 
                        "Nao e' possivel transferir para sua conta.".
                 LEAVE Validacao.
             END.

        IF   crabass.dtdemiss <> ?   THEN
             DO:
                 ASSIGN aux_dscritic = "Conta destino encerrada. " +
                            "Nao sera possivel efetuar a transferencia.".
                 LEAVE Validacao.
             END.

        IF   par_cdtiptra = 3  THEN /* Credito Salario */
             DO:
                 IF  crapcop.cdagectl <> crabcop.cdagectl  THEN
                     DO:
                         ASSIGN aux_dscritic = "Credito de Salario deve ser " +
                                    "efetuado em contas de sua cooperativa.".
                         LEAVE Validacao.
                     END.

                 IF  crabass.inpessoa <> 1  THEN
                     DO:
                         ASSIGN aux_dscritic = "Credito de Salario deve ser " +
                                    "efetuado para pessoa fisica.".
                         LEAVE Validacao.
                     END.
             END.

        FIND crapcti WHERE crapcti.cdcooper = par_cdcooper     AND
                           crapcti.cddbanco = crapcop.cdbcoctl AND
                           crapcti.cdageban = crapcop.cdagectl AND
                           crapcti.nrdconta = par_nrdconta     AND
                           crapcti.nrctatrf = par_nrctatrf     
                           NO-LOCK NO-ERROR.
      
        ASSIGN par_flgctafa = AVAIL crapcti            
               par_nmtitula = crabass.nmprimtl 
               par_cddbanco = crabcop.cdbcoctl.

	    IF crabass.inpessoa = 1 THEN
		   DO:
		      FOR FIRST crapttl FIELDS(nmextttl) 
			                     WHERE crapttl.cdcooper = crabass.cdcooper AND
   								       crapttl.nrdconta = crabass.nrdconta AND
								       crapttl.idseqttl = 2
								       NO-LOCK:

			    ASSIGN par_nmtitul2 = crapttl.nmextttl.

			  END.

		   END.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN
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

END PROCEDURE.

PROCEDURE grava-crapltr:
    
    DEFINE INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_cdoperad AS CHAR                     NO-UNDO.
    DEFINE INPUT PARAM par_nrterfin AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT PARAM par_nrultaut AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_nrdocmto AS DECI                     NO-UNDO.
    DEFINE INPUT PARAM par_nrsequni AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_cdhistor AS INTE                     NO-UNDO.
    DEFINE INPUT PARAM par_vllanmto AS DECI                     NO-UNDO.

	DEF VAR aux_flgtrans AS LOG									NO-UNDO.

	TRANS_LTR:
    DO TRANSACTION ON ENDKEY UNDO TRANS_LTR, LEAVE TRANS_LTR
                   ON ERROR  UNDO TRANS_LTR, LEAVE TRANS_LTR
                   ON STOP   UNDO TRANS_LTR, LEAVE TRANS_LTR:

    CREATE crapltr.
    ASSIGN crapltr.cdcooper = par_cdcooper
           crapltr.cdoperad = par_cdoperad
           crapltr.nrterfin = par_nrterfin
           crapltr.dtmvtolt = par_dtmvtolt
           crapltr.nrautdoc = par_nrultaut
           crapltr.nrdconta = par_nrdconta
           crapltr.nrdocmto = par_nrdocmto
           crapltr.nrsequni = par_nrsequni 
           crapltr.cdhistor = par_cdhistor
           crapltr.vllanmto = par_vllanmto
           crapltr.dttransa = TODAY
           crapltr.hrtransa = TIME
           crapltr.nrcartao = 0
           crapltr.tpautdoc = 1
           crapltr.nrestdoc = 0
           crapltr.cdsuperv = "".

    VALIDATE crapltr.

	    ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANS_LTR **/

    IF NOT aux_flgtrans  THEN
       RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria_senha_ura:

    DEF INPUT  PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cddsenha AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    TRANSACAO:
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO: 

       DO aux_contador = 1 TO 10:

          FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                             crapsnh.nrdconta = par_nrdconta AND
                             crapsnh.tpdsenha = 2            AND
                             crapsnh.idseqttl = 0  
                             NO-LOCK NO-ERROR NO-WAIT.
          IF NOT AVAILABLE crapsnh   THEN
             DO:
                IF LOCKED crapsnh   THEN
                   DO:
                      aux_cdcritic = 72.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                   END.
             END.
          ELSE
             aux_cdcritic = 0.

          LEAVE.

       END.  /*  Fim do DO .. TO  */               
   
       IF   aux_cdcritic > 0    THEN
            DO:                               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
       IF   NOT AVAIL crapsnh   THEN
            DO:
                CREATE crapsnh.
                ASSIGN crapsnh.cdcooper = par_cdcooper
                       crapsnh.nrdconta = par_nrdconta
                       crapsnh.tpdsenha = 2 /* URA */
                       crapsnh.idseqttl = 0
                       crapsnh.cdsitsnh = 1 /* ATIVO */
                       crapsnh.cdoperad = par_cdoperad
                       crapsnh.dtlibera = par_dtmvtolt
                       crapsnh.dtaltsnh = par_dtmvtolt
                       crapsnh.cddsenha = STRING(par_cddsenha,"99999999")
                       crapsnh.dtemsenh = ? NO-ERROR.
                VALIDATE crapsnh.
            END.
       LEAVE.

    END. /* DO WHILE TRUE  */

    IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
        RETURN "NOK".
                
    RETURN "OK".

END PROCEDURE.
/*............................................................................*/

PROCEDURE valida_senha_ura:

    DEF INPUT  PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cddsenh1 AS CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_cddsenh2 AS CHAR                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcooper AS CHAR                                 NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                 NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                 NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.    

    DO WHILE TRUE:

        IF  (par_cddsenh1 <> par_cddsenh2) OR 
            (par_cddsenh1 = "")            OR
            (LENGTH(par_cddsenh1) <> 8)  THEN
            DO:
                 ASSIGN aux_cdcritic = 3
                        aux_dscritic = "".
                 LEAVE.
            END.
    
        IF  CAN-FIND(crapcop WHERE crapcop.cdcooper = par_cdcooper) THEN
            DO:
                ASSIGN aux_cdcooper = SUBSTR(STRING(par_cdcooper,"99"),1,2).
                IF  aux_cdcooper <> SUBSTR(STRING(par_cddsenh1),1,2)    THEN 
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Duas primeiras posicoes numericas " +
                                              "devem ser " + aux_cdcooper.
                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Duas primeiras posicoes numericas " +
                                      "devem ser " + aux_cdcooper.
                LEAVE.
            END.

       LEAVE.

    END. /* Fim do while true */

    IF  aux_dscritic <> ""  OR
        aux_cdcritic > 0    THEN
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

END PROCEDURE.



PROCEDURE busca_crapban:
    /* Pesquisa para BANCOS */
                                              
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextbcc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrispbif AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR  tt-crapban-ispb.
    
    EMPTY TEMP-TABLE tt-crapban-ispb.
    
    ASSIGN par_nmextbcc = TRIM(par_nmextbcc).
   
    FIND FIRST crapban WHERE (IF par_cdbccxlt <> 0 THEN
                           crapban.cdbccxlt = par_cdbccxlt ELSE TRUE)
                        AND (IF par_cdbccxlt = 0  THEN
                            crapban.nrispbif = par_nrispbif ELSE TRUE)
                        /*AND crapban.nmextbcc MATCHES("*" + par_nmextbcc + "*") */
                        NO-LOCK NO-ERROR.
                           
     
    IF NOT AVAIL tt-crapban-ispb THEN
        DO:
           CREATE  tt-crapban-ispb.
           IF AVAIL crapban THEN
             BUFFER-COPY crapban TO  tt-crapban-ispb.
        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-termo-responsabilidade:
    
    DEF INPUT  PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                                NO-UNDO.    
    DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                                NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_dsiduser AS CHAR                                NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0038 AS HANDLE                                       NO-UNDO.
    DEF VAR h-b1wgen0058 AS HANDLE                                       NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                       NO-UNDO.    
    
	DEF VAR aux_flgtrans AS LOG    										 NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                                         NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                         NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.
    DEF VAR aux_dsendcop AS CHAR FORMAT "x(74)"                          NO-UNDO.
    DEF VAR aux_dsendere AS CHAR FORMAT "x(74)"                          NO-UNDO.
    DEF VAR aux_dsrepres AS CHAR FORMAT "x(35)"                          NO-UNDO.
    DEF VAR aux_dsdatcop AS CHAR FORMAT "x(60)"                          NO-UNDO.
    DEF VAR aux_nmcoperd AS CHAR FORMAT "x(40)"                          NO-UNDO.
    DEF VAR aux_dsestcvl AS CHAR FORMAT "x(11)"                          NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(20)"                          NO-UNDO.
    DEF VAR aux_qtdiaace AS CHAR FORMAT "x(3)"                           NO-UNDO.
    DEF VAR aux_dsmesext AS CHAR FORMAT "x(17)"  EXTENT 12 
                                    INIT["DE  JANEIRO  DE","DE FEVEREIRO DE",
                                         "DE   MARCO   DE","DE   ABRIL   DE",
                                         "DE   MAIO    DE","DE   JUNHO   DE",
                                         "DE   JULHO   DE","DE   AGOSTO  DE",
                                         "DE  SETEMBRO DE","DE  OUTUBRO  DE",
                                         "DE  NOVEMBRO DE","DE  DEZEMBRO DE"]
                                                                     NO-UNDO.

    DEF VAR aux_qtminast AS INTE NO-UNDO.

    FORM  
        /* Titulo em negrito inicio */
        "\033\105\TERMO DE RESPONSABILIDADE PARA ACESSO E " AT 10
        "MOVIMENTACAO DA CONTA CORRENTE POR MEIO DE"
        SKIP 
        " CANAIS DE AUTOATENDIMENTO E SAC -– PESSOA FISICA\033\106" AT 25
        /* Titulo em negrito fim */
        SKIP(1)
        "\033\105\COOPERATIVA\033\106" 
        SKIP(1)
        "Razao Social: " crapcop.nmextcop
        SKIP(1)
        "CNPJ: " aux_nrcpfcgc
        SKIP(1)
        "Endereco: " aux_dsendcop
        SKIP(1)
        "Cidade: " crapcop.nmcidade
        "UF: " AT 50 crapcop.cdufdcop 
        "CEP: " crapcop.nrcepend
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_cabecalho_pf.

    FORM  
        /* Titulo em negrito inicio */
        "\033\105\TERMO DE RESPONSABILIDADE PARA ACESSO E " AT 10
        "MOVIMENTACAO DA CONTA CORRENTE POR MEIO DE"
        SKIP 
        " CANAIS DE AUTOATENDIMENTO E SAC–- PESSOA JURIDICA\033\106" AT 25
        /* Titulo em negrito fim */
        SKIP(2)
        "\033\105\COOPERATIVA\033\106" 
        SKIP(1)
        "Razao Social: " crapcop.nmextcop
        SKIP(1)
        "CNPJ: " aux_nrcpfcgc
        SKIP(1)
        "Endereco: " aux_dsendcop
        SKIP(1)
        "Cidade: " crapcop.nmcidade
        "UF: " AT 50 crapcop.cdufdcop 
        "CEP: " crapcop.nrcepend
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_cabecalho_pj.

    FORM 
        SKIP(2)
        "\033\105\COOPERADO\033\106" 
        SKIP(1)
        "Nome: " aux_nmcoperd
        "CPF: " aux_nrcpfcgc AT 63
        SKIP(1)
        "Endereco: " aux_dsendere
        SKIP(1)
        "Cidade: " tt-endereco-cooperado.nmcidade
        "UF: " AT 50 tt-endereco-cooperado.cdufende
        "CEP: " tt-endereco-cooperado.nrcepend
        SKIP(1)
        "Conta Corrente: " crapass.nrdconta
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_dados_pf.

    FORM 
        SKIP(2)
        "\033\105\COOPERADO\033\106" 
        SKIP(1)
        "Razao Social: " aux_nmcoperd
        "CNPJ: " aux_nrcpfcgc
        SKIP(1)
        "Endereco: " aux_dsendere
        SKIP(1)
        "Cidade: " tt-endereco-cooperado.nmcidade
        "UF: " AT 48 tt-endereco-cooperado.cdufende
        "CEP: " tt-endereco-cooperado.nrcepend
        SKIP(1)
        "Conta Corrente: " crapass.nrdconta
        "Representacao: " aux_dsrepres
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_dados_pj.

    FORM 
        SKIP(3)
        "\033\105\ REPRESENTANTE(S) LEGAL(IS)\033\106" 
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_tit_representantes.

    FORM
        SKIP(2)
        "Nome: " tt-crapavt.nmdavali
        "CPF: " aux_nrcpfcgc
        SKIP(1)
        "Estado Civil: " aux_dsestcvl
        "Cargo: " tt-crapavt.dsproftl FORMAT "x(60)"
        WITH WIDTH 100 NO-BOX NO-LABEL FRAME f_representantes.

    FORM
        SKIP(2)
        "Pelo presente instrumento, o \033\105\COOPERADO\033\106 acima identificado e qualificado, podera ter "
        SKIP
        "acesso aos canais de autoatendimento disponibilizados pela \033\105\COOPERATIVA\033\106, ou ainda, "
        SKIP
        "outros que venham a ser disponibilizados, para realizacao de movimentacoes, transacoes e "
        SKIP
        "contratacoes financeiras em sua conta corrente, conforme regras dispostas abaixo:"
        SKIP(1)
        "\033\105\ 1.\033\106  Sao considerados canais de autoatendimento a internet, aplicativo para celular, "
        SKIP
        "     terminais de autoatendimento, telefone e outros meios de comunicacao a distancia."
        SKIP(1)
        "\033\105\ 1.1\033\106  CONTA ONLINE: A conta online e o canal eletronico via internet, pelo qual o \033\105\COOPERADO\033\106 tem "
        SKIP
        "      acesso a informacoes sobre produtos e servicos da \033\105\COOPERATIVA\033\106, podendo realizar consultas, "
        SKIP
        "      movimentacoes, antecipacao de pagamento de contratos (observadas as regras "
        SKIP
        "      estipuladas para este servico), transacoes e contratacoes, inclusive de credito, "
        SKIP
        "      diretamente em sua conta. O \033\105\COOPERADO\033\106 se obriga a acessar este servico em ambiente "
        SKIP
        "      seguro, por meio de computadores e/ou celulares protegidos."
        SKIP(1)
        "\033\105\ 1.1.1\033\106  \033\105\CADASTRO DE REPRESENTANTES(S) lEGAL(IS):\033\106 Na liberacao de acesso da conta online, as "
        SKIP
        "consultas, movimentacoes, transacoes e contratacoes, inclusive de credito, serao realizadas de "
        AT 9 SKIP
        "acordo com o que dispuser os atos constitutivos do \033\105\COOPERADO\033\106 e nos limites de poderes de "
        AT 9 SKIP
        "representacao conferidos aos seus representantes legais."
        AT 9 SKIP(1)
        "\033\105\ 1.1.1.1\033\106  No caso de representacao por uma unica pessoa fisica, esta fara o uso de sua senha "
        SKIP
        "pessoal e intransferivel para realizacao de movimentacoes, transacoes e contratacoes."
        AT 9 SKIP(1)
        "\033\105\ 1.1.1.2\033\106  No caso de representacao por duas ou mais pessoas fisicas, as movimentacoes, "
        SKIP
        "transacoes e contratacoes somente serao concluidas mediante confirmacao das operacoes e com senha"
        AT 9 SKIP
        "pessoal de todos os representantes legais do \033\105\COOPERADO\033\106. Na ausencia de aprovacao de qualquer "
        AT 9 SKIP
        "representante legal do \033\105\COOPERADO\033\106, as operacoes serao canceladas e deverao ser "
        AT 9 SKIP
        "novamente registradas e aprovadas."
        
        AT 9 SKIP(1)
        "\033\105\ 1.1.1.3\033\106 Havendo a previsao nos atos constitutivos, a \033\105\COOPERATIVA\033\106 podera, a pedido do \033\105\COOPERADO\033\106,"
        SKIP
        "cadastrar \033\105\REPRESENTANTES(S) LEGAL(IS)\033\106 com alcada(s) individual(is) para utilizacao da conta online,"
        AT 9 SKIP
        "hipotese em que, necessariamente devara(ao) ser definida(s) a(s) senha(s) e respectiva(s)"
        AT 9 SKIP
        "alcada(s) para o(s) \033\105\REPRESENTANTES(S) LEGAL(IS)\033\106 cadastrado(s)."
        AT 9 SKIP(1)
        "\033\105\ 1.1.1.4\033\106 Para as transacoes financeiras realizadas pelo(s) \033\105\REPRESENTANTE(S) LEGAL(IS)\033\106 dentro da(s)"
        SKIP
        "alcada(s) fixada(s) nao sera necessaria a autorizacao mencionada no item 1.1.1.2. As transacoes"
        AT 9 SKIP
        "que excederem a(s) alcada(s) individual(is) deverao ser aprovadas nos tremos do item 1.1.1.2"
        AT 9 SKIP
        "mediante acessso a conta online no site da \033\105\COOPERATIVA\033\106. Nao havendo aprovacao, as operacoes serao"
        AT 9  SKIP
        "canceladas."
        AT 9 SKIP(1)
        "\033\105\ 1.1.2\033\106 \033\105\CADASTRO DE OPERADOR(ES):\033\106 O \033\105\COOPERADO\033\106 podera cadastrar OPERADOR(ES) para utilizacao "
        SKIP
        "da conta online, hipotese em que necessariamente devera(ao) ser definida(s) a(s) senha(s), as "
        AT 9 SKIP
        "permissoes de acesso e respectivas alcada(s) individual(is) para o(s) OPERADOR(ES) "
        AT 9 SKIP
        "cadastrado(s). O cadastros do(s) \033\105\OPERADORE(S)\033\106 seguira a mesma regra prevista no item 1.1.1.2."
        AT 9 SKIP(1)
        "\033\105\1.1.2.1\033\106 Para as transacoes financeiras realizadas pelo(s) \033\105\OPERADOR(ES)\033\106 dentro da(s) alcada(s)"
        SKIP
        "fixada(s) nao sera necessaria a autorizacao mensionada nos itens 1.1.1.1 ou 1.1.1.2. As "
        AT 9 SKIP
        " transacoes que excederem a(s) individual(is) deverao ser aprovadas nos termos dos itens "
        AT 9 SKIP
        "1.1.1.1 e 1.1.1.2 ediante acesso a conta online no site da COOPRATIVA. Nao havendo aprovacao, as"
        AT 9 SKIP
        "operacoes serao canceladas"
        AT 9 SKIP(1)
        "\033\105\ 1.1.2.2 A(s) alcada(s) do(s) OPERADOR(ES) poderao ser aumentanda(s) pelos representantes legais nos"
        SKIP
        "termos do item 1.1.1.2. A sua reducao ou cancelament poderá ser realizada pelos representantes"
        AT 9 SKIP
        "legais de forma isolada."
        AT 9 SKIP(1)
        "1.1.2.3 Quando houber diminuicao da(s) alacada(s) do(s) REPRESENTANTE(S) LEGAL(IS) do COOPERADO, a"
        SKIP
        "COOPERATIVA reduzira, unilateralmente as alcada(s) dos OPERADOR(ES)."
        AT 9 SKIP(1)
        "\033\105\ 1.2\033\106 APLCIATIVO PARA CELULAR: O aplicativo para celular e o canal pelo qual o \033\105\COOPERADO\033\106 tem acesso "
        SKIP
        "a sua conta, mediante uso da mesma senha de utilizacao da Conta Online, para realizar consultas, "
        AT 9 SKIP
        "      movimentacoes, transacoes e contratacoes relativas a produtos e servicos, inclusive de "
        AT 9 SKIP
        "      credito, diretamente em sua conta, conforme disponibilizado pela \033\105\COOPERATIVA\033\106."
        AT 9 SKIP(1)
        "\033\105\ 1.2.1\033\106  Por medida de seguranca, o \033\105\COOPERADO\033\106 devera autorizar uma unica vez o "
        SKIP
        "smartphone para poder realizar transacoes que movimentem valores diretamente "
        AT 9 SKIP
        "em sua conta."
        AT 9 SKIP(1)
        "\033\105\ 1.3\033\106 TERMINAL DE AUTOATENDIMENTO: O terminal de autoatendimento e o equipamento disponibilizado "
        SKIP
        "pela \033\105\COOPERATIVA\033\106 localizado nos Postos de Atendimento ou em outros locais de acesso publico, "
        AT 9 SKIP
        "devidamente identificados com as credenciais da \033\105\COOPERATIVA\033\106, para realizacao de consultas, "
        AT 9 SKIP
        "      movimentacoes, transacoes e contratacoes relativas a produtos e servicos, inclusive de "
        AT 9 SKIP
        "      credito, diretamente na conta do \033\105\COOPERADO\033\106. "
        AT 9 SKIP(1)
        "\033\105\ 1.4\033\106 SAC: O \033\105\COOPERADO\033\106 podera utilizar os servicos de Tele Saldo e SAC (Servico de "
        SKIP
        "      Atendimento ao Cooperado), por meio de atendimento telefonico, para realizar consultas, "
        AT 9 SKIP
        "      obter informacoes, solicitar e autorizar transacoes, inclusive as relativas a contratacao de "
        AT 9 SKIP
        "      produtos e servicos, ofertadas pela \033\105\COOPERATIVA\033\106."
        AT 9 SKIP(1)
        "\033\105\ 1.4.1\033\106  A \033\105\COOPERATIVA\033\106 se reserva no direito de, a qualquer tempo, e a seu exclusivo "
        SKIP
        "criterio, disponibilizar no SAC novas informacoes, operacoes e servicos, ou excluir "
        AT 9 SKIP
        "quaisquer daqueles ofertados na data da formalizacao da abertura da conta corrente."
        AT 9 SKIP(1)
        "\033\105\ 1.4.2\033\106  Para fins de seguranca mutua, o SAC (Servico de Atendimento ao Cooperado) podera "
        SKIP
        "solicitar ao \033\105\COOPERADO\033\106 informacoes adicionais ou confirmacoes por telefone, "
        AT 9 SKIP
        "tanto para sua utilizacao, como para outros servicos e/ou operacoes disponibilizados."
        AT 9 SKIP(1)
        "\033\105\ 1.4.3\033\106  Por medida de seguranca, o \033\105\COOPERADO\033\106 autoriza a \033\105\COOPERATIVA\033\106 a realizar "
        SKIP
        "gravacoes das solicitacoes e instrucoes telefonicas relacionadas a conta corrente, "
        AT 9 SKIP
        "comandadas via SAC ou qualquer outra forma que e, ou que venha ser oferecida "
        AT 9 SKIP
        "pela \033\105\COOPERATIVA\033\106, nao estando, no entanto, obrigado a faze-lo, podendo, "
        AT 9 SKIP
        "inclusive, utiliza-la como meio de prova valida e eficaz em juizo ou fora dele."
        AT 9 SKIP(1)
        "\033\105\ 1.5\033\106  O \033\105\COOPERADO\033\106 assume total responsabilidade pelas movimentacoes, transacoes e "
        SKIP
        "contratacoes realizadas por meio dos canais eletronicos, inclusive as que foram realizadas por "
        AT 9 SKIP
        "OPERADOR(ES) ou REPRESENTANTE(S) LEGAL(IS), isentando a \033\105\COOPERATIVA\033\106 de qualquer responsabilidade "
        AT 9 SKIP
        "por eventuais prejuizos sofridos, inclusive causados a terceiros, decorrentes de atos praticados mediante a "
        AT 9 SKIP
        "      utilizacao de senha pessoal."        
        AT 9 SKIP(1)
        "\033\105\ 1.6\033\106  O cooperado reconhece que a COOPERATIVA realiza, por amostragem, de forma moderada, "
        SKIP
        "      generalizada e impessoal, o monitoramento das movimentacoes, transacoes e contratacoes "
        AT 9 SKIP
        "      realizadas por meio dos canais de autoatendimento, podendo, sem aviso previo, reprovar "
        AT 9 SKIP
        "      determinada operacao ou ate mesmo bloquear o acesso do COOPERADO aos canais de autoatendimento, "
        AT 9 SKIP
        "      caso identifique indicios de irregularidades.  "
        AT 9 SKIP(1)
        "\033\105\ 1.6.1\033\106  Caso o acesso aos canais de autoatendimento seja bloqueado pela COOPERATIVA, "
        SKIP
        "         o COOPERADO devera comparecer ao Posto de Atendimento da COOPERATIVA para verificacao "
        AT 9 SKIP
        "         do ocorrido e eventual recadastramento de senha."
        AT 9 SKIP(1)
        "\033\105\ 1.7\033\106  A \033\105\COOPERATIVA\033\106 podera disponibilizar por meio dos canais de autoatendimento "
        SKIP
        "      existentes, ou ainda aqueles que venham a ser criados, a possibilidade de contratacao de "
        AT 9 SKIP
        "      operacao de credito, desde que o \033\105\COOPERADO\033\106 atenda aos requisitos necessarios para "
        AT 9 SKIP
        "      sua contratacao, observadas as regras estipuladas pela \033\105\COOPERATIVA\033\106 para cada produto "
        AT 9 SKIP
        "      ofertado."              
        AT 9 SKIP(5)
        WITH WIDTH 150 NO-BOX NO-LABEL FRAME f_termo_pj.

    FORM 
        SKIP(2)
        "Pelo presente instrumento, o \033\105\COOPERADO\033\106 acima identificado e qualificado, podera ter "
        SKIP
        "acesso aos canais de autoatendimento disponibilizados pela \033\105\COOPERATIVA\033\106, ou ainda, "
        SKIP
        "outros que venham a ser disponibilizados, para realizacao de movimentacoes, transacoes e "
        SKIP
        "contratacoes financeiras em sua conta corrente, conforme regras dispostas abaixo:"
        SKIP(1)
        "\033\105\ 1.\033\106  Sao considerados canais de autoatendimento a internet, aplicativo para celular, "
        SKIP
        "     terminais de autoatendimento, telefone e outros meios de comunicacao a distancia."
        SKIP(1)
        "\033\105\ 1.1\033\106  A conta online e o canal eletronico via internet, pelo qual o \033\105\COOPERADO\033\106 tem acesso a "
        SKIP
        "      informacoes sobre produtos e servicos da \033\105\COOPERATIVA\033\106, podendo realizar consultas, "
        SKIP
        "      movimentacoes, antecipacao de pagamento de contratos (observadas as regras "
        SKIP
        "      estipuladas para este servico), transacoes e contratacoes, inclusive de credito, "
        SKIP
        "      diretamente em sua conta. O \033\105\COOPERADO\033\106 se obriga a acessar este servico em ambiente "
        SKIP
        "      seguro, por meio de computadores e/ou celulares protegidos."
        SKIP(1)
        "\033\105\ 1.1.1\033\106  Apos a liberacao de acesso da conta online e cadastramento da senha no Posto de "
        SKIP
        "Atendimento da \033\105\COOPERATIVA\033\106, o \033\105\COOPERADO\033\106 tera o prazo de " AT 9 aux_qtdiaace " dias para "        
        SKIP 
        "realizar o primeiro acesso."        
        AT 9 SKIP(1)
        "\033\105\ 1.1.2\033\106  Caso o acesso nao seja realizado no prazo estipulado, a senha sera cancelada, "
        SKIP
        "devendo o \033\105\COOPERADO\033\106 comparecer novamente ao Posto de Atendimento da "
        AT 9 SKIP
        "\033\105\COOPERATIVA\033\106 para recadastramento de senha."        
        AT 9 SKIP(1)        
        "\033\105\ 1.2\033\106  O aplicativo para celular e o canal pelo qual o \033\105\COOPERADO\033\106 tem acesso a sua conta, "
        SKIP
        "      mediante uso da mesma senha de utilizacao da Conta Online, para realizar consultas, "
        SKIP
        "      movimentacoes, transacoes e contratacoes relativas a produtos e servicos, inclusive de "
        SKIP
        "      credito, diretamente em sua conta, conforme disponibilizado pela \033\105\COOPERATIVA\033\106."
        SKIP(1)
        "\033\105\ 1.2.1\033\106  Por medida de seguranca, o \033\105\COOPERADO\033\106 devera autorizar uma unica vez o "
        SKIP
        "smartphone para poder realizar transacoes que movimentem valores diretamente "
        AT 9 SKIP
        "em sua conta."
        AT 9 SKIP(1)
        "\033\105\ 1.3\033\106  O terminal de autoatendimento e o equipamento disponibilizado pela \033\105\COOPERATIVA\033\106 "
        SKIP
        "      localizado nos Postos de Atendimento ou em outros locais de acesso publico, devidamente "
        SKIP
        "      identificados com as credenciais da \033\105\COOPERATIVA\033\106, para realizacao de consultas, "
        SKIP
        "      movimentacoes, transacoes e contratacoes relativas a produtos e servicos, inclusive de "
        SKIP
        "      credito, diretamente na conta do \033\105\COOPERADO\033\106. "
        SKIP(1)
        "\033\105\ 1.4\033\106  O \033\105\COOPERADO\033\106 podera utilizar os servicos de Tele Saldo e SAC (Servico de "
        SKIP
        "      Atendimento ao Cooperado), por meio de atendimento telefonico, para realizar consultas, "
        SKIP
        "      obter informacoes, solicitar e autorizar transacoes, inclusive as relativas a contratacao de "
        SKIP
        "      produtos e servicos, ofertadas pela \033\105\COOPERATIVA\033\106."
        SKIP(1)
        "\033\105\ 1.4.1\033\106  A \033\105\COOPERATIVA\033\106 se reserva no direito de, a qualquer tempo, e a seu exclusivo "
        SKIP
        "criterio, disponibilizar no SAC novas informacoes, operacoes e servicos, ou excluir "
        AT 9 SKIP
        "quaisquer daqueles ofertados na data da formalizacao da abertura da conta corrente."
        AT 9 SKIP(1)
        "\033\105\ 1.4.2\033\106  Para fins de seguranca mutua, o SAC (Servico de Atendimento ao Cooperado) podera "
        SKIP
        "solicitar ao \033\105\COOPERADO\033\106 informacoes adicionais ou confirmacoes por telefone, "
        AT 9 SKIP
        "tanto para sua utilizacao, como para outros servicos e/ou operacoes disponibilizados."
        AT 9 SKIP(1)
        "\033\105\ 1.4.3\033\106  Por medida de seguranca, o \033\105\COOPERADO\033\106 autoriza a \033\105\COOPERATIVA\033\106 a realizar "
        SKIP
        "gravacoes das solicitacoes e instrucoes telefonicas relacionadas a conta corrente, "
        AT 9 SKIP
        "comandadas via SAC ou qualquer outra forma que e, ou que venha ser oferecida "
        AT 9 SKIP
        "pela \033\105\COOPERATIVA\033\106, nao estando, no entanto, obrigado a faze-lo, podendo, "
        AT 9 SKIP
        "inclusive, utiliza-la como meio de prova valida e eficaz em juizo ou fora dele."
        AT 9 SKIP(1)        
        "\033\105\ 1.5\033\106  O \033\105\COOPERADO\033\106 assume total responsabilidade pelas movimentacoes, transacoes e "
        SKIP
        "      contratacoes realizadas por meio deste canal eletronico, isentando a "
        SKIP
        "      \033\105\COOPERATIVA\033\106 de qualquer responsabilidade por eventuais prejuizos sofridos, "
        SKIP
        "      inclusive causados a terceiros, decorrentes de atos praticados mediante a "
        SKIP
        "      utilizacao de senha pessoal."
        SKIP(1)
        "\033\105\ 1.6\033\106  O cooperado reconhece que a COOPERATIVA realiza, por amostragem, de forma moderada, " 
        SKIP
        "      generalizada e impessoal, o monitoramento das movimentacoes, transacoes e contratacoes "
        SKIP
        "      realizadas por meio dos canais de autoatendimento, podendo, sem aviso previo, reprovar   "
        SKIP
        "      determinada operacao ou ate mesmo bloquear o acesso do COOPERADO aos canais de autoatendimento, "
        SKIP
        "      caso identifique indicios de irregularidades."
        SKIP(1)
        "\033\105\ 1.6.1\033\106  Caso o acesso aos canais de autoatendimento seja bloqueado pela COOPERATIVA, "
        SKIP
        "o COOPERADO devera comparecer ao Posto de Atendimento da COOPERATIVA para verificacao do "
        AT 9 SKIP
        "ocorrido e eventual recadastramento de senha."
        AT 9 SKIP(1)
        "\033\105\ 1.7\033\106  A \033\105\COOPERATIVA\033\106 podera disponibilizar por meio dos canais de autoatendimento "
        SKIP
        "      existentes, ou ainda aqueles que venham a ser criados, a possibilidade de contratacao de "
        SKIP
        "      operacao de credito, desde que o \033\105\COOPERADO\033\106 atenda aos requisitos necessarios para "
        SKIP
        "      sua contratacao, observadas as regras estipuladas pela \033\105\COOPERATIVA\033\106 para cada produto "
        SKIP
        "      ofertado."        
        SKIP(1)
        "\033\105\ 1.7.1\033\106  Tratando-se de conta conjunta, o \033\105\COOPERADO\033\106 se declara ciente que os demais "
        SKIP
        "titulares da conta tambem poderao realizar, em seu nome, as contratacoes "
        AT 9 SKIP
        "previstas no item acima, sendo de sua inteira reponsabilidade o adimplemento das "
        AT 9 SKIP
        "obrigacoes contraidas."
        AT 9 SKIP(5)
        WITH WIDTH 150 NO-BOX NO-LABEL FRAME f_termo_pf.

    FORM        
        aux_dsdatcop AT 40
        SKIP(3)
        "__________________________________________"
        SKIP
        "\033\105\COOPERADO\033\106"
        SKIP
        aux_nmcoperd
        SKIP(3)
        "De acordo:"
        SKIP(2)
        "__________________________________________"
        SKIP
        "\033\105\COOPERATIVA\033\106"
        SKIP
        crapcop.nmrescop
        WITH WIDTH 150 NO-BOX NO-LABEL FRAME f_assinatura.

    FOR FIRST crapcop 
        FIELDS (nmextcop nrdocnpj dsendcop nrendcop
                nmbairro nmcidade cdufdcop nrcepend
                dsdircop nmrescop)
         WHERE crapcop.cdcooper = par_cdcooper
       NO-LOCK:         
    END.

    IF  NOT AVAIL crapcop THEN
        DO:
            /*651 - Falta registro de controle da cooperativa - ERRO DE SISTEMA*/
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).      

            RETURN "NOK".
        END.

    IF  par_dsiduser <> ?   AND 
        par_dsiduser <> ""  THEN
        UNIX SILENT VALUE ("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser + "* 2>/dev/null").

    /* Definiçao de nomes do arquivo */
    ASSIGN aux_nmarquiv = par_dsiduser + STRING(TIME)
           par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".ex"
           aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + "/rl/" + aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) APPEND. /*PAGED PAGE-SIZE 84.*/

    ASSIGN aux_dsendcop = TRIM(crapcop.dsendcop) + ", " + STRING(crapcop.nrendcop)
                        + " - " + crapcop.nmbairro
           aux_dsdatcop = TRIM(crapcop.nmcidade) 
                        + "/" + crapcop.cdufdcop + ", ".

    FOR FIRST crapdat
       FIELDS (dtmvtolt)
        WHERE crapdat.cdcooper = par_cdcooper
      NO-LOCK:

        ASSIGN aux_dsdatcop = aux_dsdatcop 
                            + STRING(DAY(crapdat.dtmvtolt), "99") + " "
                            + aux_dsmesext[MONTH(crapdat.dtmvtolt)] + " "
                            + STRING(YEAR(crapdat.dtmvtolt), "9999") + ".".
    END.

    FOR FIRST crapass
       FIELDS (nmprimtl nrdconta idastcjt inpessoa)
        WHERE crapass.cdcooper = par_cdcooper
          AND crapass.nrdconta = par_nrdconta
      NO-LOCK:
        /* PF */
        IF  crapass.inpessoa = 1 THEN
            DO:
                FOR FIRST crapttl 
                   FIELDS (nmextttl nrcpfcgc)
                    WHERE crapttl.cdcooper = crapass.cdcooper
                      AND crapttl.nrdconta = crapass.nrdconta
                      AND crapttl.idseqttl = par_idseqttl
                 NO-LOCK:
                END.

                IF  NOT AVAIL crapttl THEN
                    DO:
                        /*009 - Associado nao cadastrado.*/
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Titular da conta nao encontrado.".
                
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).      
                
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmcoperd = crapttl.nmextttl.

                /** Tabela com os limites para internet **/
                FOR FIRST craptab 
                   FIELDS (dstextab)
                    WHERE craptab.cdcooper = par_cdcooper AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "GENERI"     AND
                          craptab.cdempres = 0            AND
                          craptab.cdacesso = "LIMINTERNT" AND
                          craptab.tpregist = 1            NO-LOCK:
                END.
                       
                IF  AVAILABLE craptab  THEN
                    ASSIGN aux_qtdiaace =  TRIM(ENTRY(3,craptab.dstextab,";")).
                ELSE
                    ASSIGN aux_qtdiaace = "3".

            END.
        ELSE
            ASSIGN aux_dsrepres = IF crapass.idastcjt = 0 THEN
                                  "Nao exige assinatura em conjunto" 
                                  ELSE
                                  "Exige assinatura em conjunto"
                   aux_nmcoperd = crapass.nmprimtl.
    END.

    IF  NOT AVAIL crapass THEN
        DO:
            /*009 - Associado nao cadastrado.*/
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
    
    RUN sistema/generico/procedures/b1wgen0038.p
        PERSISTENT SET h-b1wgen0038.
                
    IF  VALID-HANDLE(h-b1wgen0038)  THEN
        DO:        
    
            RUN obtem-endereco IN h-b1wgen0038 
                 (INPUT par_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT IF crapass.inpessoa = 2 THEN 1 ELSE par_idseqttl, /* Para conta PJ passar fixo 1 */
                  INPUT FALSE,
                 OUTPUT aux_msgconta,
                 OUTPUT aux_inpessoa,
                 OUTPUT TABLE tt-erro,
                 OUTPUT TABLE tt-endereco-cooperado).

            IF  RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF   NOT AVAIL tt-erro   THEN
                         ASSIGN aux_cdcritic = 0
                                aux_dscritic = "Erro ao obter endereco do cooperado".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).                  
                    
                    DELETE PROCEDURE h-b1wgen0038.

                    RETURN "NOK".
                END.                        

            DELETE PROCEDURE h-b1wgen0038.
        END.    

    FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-endereco-cooperado THEN
        DO:
            /*247 - Registro de endereco do cooperado nao encontrado*/
            ASSIGN aux_cdcritic = 247
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).                  
            
            RETURN "NOK".            
        END.

    ASSIGN aux_dsendere = TRIM(tt-endereco-cooperado.dsendere) + ", " 
                          + STRING(tt-endereco-cooperado.nrendere)
                          + " - " + tt-endereco-cooperado.nmbairro.


    IF  crapass.inpessoa <> 1 THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0058.p
                PERSISTENT SET h-b1wgen0058.
        
            IF  VALID-HANDLE(h-b1wgen0058)  THEN
                DO:        
                    RUN Busca_Dados IN h-b1wgen0058 (INPUT par_cdcooper,
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_idorigem,
                                                     INPUT par_nrdconta,
                                                     INPUT 0,
                                                     INPUT FALSE,
                                                     INPUT "C",
                                                     INPUT 0,
                                                     INPUT "",
                                                     INPUT ?,
                                                    OUTPUT TABLE tt-crapavt,
                                                    OUTPUT TABLE tt-bens,
													OUTPUT aux_qtminast,
                                                    OUTPUT TABLE tt-erro) NO-ERROR.
                
                    IF  RETURN-VALUE <> "OK"   THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF   NOT AVAIL tt-erro   THEN
                                 ASSIGN aux_cdcritic = 0
                                        aux_dscritic = "Erro ao obter dados do procurador/representante".
                
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).                  
                            
                            DELETE PROCEDURE h-b1wgen0058.
        
                            RETURN "NOK".
                        END.                        
        
                    DELETE PROCEDURE h-b1wgen0058.
        
                END.
        END.
    
    IF  crapass.inpessoa = 1 THEN
        DO:
            ASSIGN aux_nrcpfcgc = STRING(STRING(crapcop.nrdocnpj,"99999999999999"),"xx.xxx.xxx/xxxx-xx").

            DISP STREAM str_1
             crapcop.nmextcop 
             aux_nrcpfcgc
             aux_dsendcop         
             crapcop.nmcidade 
             crapcop.cdufdcop 
             crapcop.nrcepend WITH FRAME f_cabecalho_pf.

            ASSIGN aux_nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx").
            
            /* Imprime dados pf */
            DISP STREAM str_1
                aux_nmcoperd
                aux_nrcpfcgc
                aux_dsendere
                tt-endereco-cooperado.nmcidade
                tt-endereco-cooperado.cdufende
                tt-endereco-cooperado.nrcepend
                crapass.nrdconta
                WITH FRAME f_dados_pf.
    
            DISP STREAM str_1
                aux_qtdiaace
                WITH FRAME f_termo_pf.

        END.
    ELSE
        DO:
            ASSIGN aux_nrcpfcgc = STRING(STRING(crapcop.nrdocnpj,"99999999999999"),"xx.xxx.xxx/xxxx-xx").

            DISP STREAM str_1
             crapcop.nmextcop 
             aux_nrcpfcgc 
             aux_dsendcop         
             crapcop.nmcidade 
             crapcop.cdufdcop 
             crapcop.nrcepend WITH FRAME f_cabecalho_pj.

            ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999999"),"xx.xxx.xxx/xxxx-xx").

            /* Imprime dados pj */
            DISP STREAM str_1
                aux_nmcoperd
                aux_nrcpfcgc
                aux_dsendere
                tt-endereco-cooperado.nmcidade
                tt-endereco-cooperado.cdufende
                tt-endereco-cooperado.nrcepend
                crapass.nrdconta
                /*aux_nrcpfcgc*/
                aux_dsrepres
                WITH FRAME f_dados_pj.                                      

            FOR EACH tt-crapavt WHERE tt-crapavt.idrspleg = 1 
                                BREAK BY tt-crapavt.nrcpfcgc: /* Representante Legal */
                
                IF FIRST(tt-crapavt.nrcpfcgc) THEN
                    VIEW STREAM str_1 FRAME f_tit_representantes.

                ASSIGN aux_nrcpfcgc = STRING(STRING(tt-crapavt.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx")
                       aux_dsestcvl = ENTRY(1,tt-crapavt.dsestcvl,"-").

                DISP STREAM str_1
                    tt-crapavt.nmdavali         
                    aux_nrcpfcgc
                    aux_dsestcvl 
                    tt-crapavt.dsproftl        
                    WITH FRAME f_representantes.

                DOWN STREAM str_1 WITH FRAME f_representantes.

            END.

            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                PAGE STREAM str_1.

            VIEW STREAM str_1 FRAME f_termo_pj.

        END.

    DISP STREAM str_1
        aux_dsdatcop 
        aux_nmcoperd 
        crapcop.nmrescop 
        WITH FRAME f_assinatura.

    OUTPUT STREAM str_1 CLOSE.
  
    /** Copiar pdf para visualizacao no Ayllos WEB **/
    IF  par_idorigem = 5  THEN
        DO:

            RUN sistema/generico/procedures/b1wgen0024.p
                PERSISTENT SET h-b1wgen0024.

            RUN envia-arquivo-web IN h-b1wgen0024(INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_nmarqimp,
                                                  OUTPUT aux_nmarqpdf,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0024.

            ASSIGN par_nmarqimp = aux_nmarqpdf.

        END.
      
	TRANS_ASS:
    DO TRANSACTION ON ENDKEY UNDO TRANS_ASS, LEAVE TRANS_ASS
                   ON ERROR  UNDO TRANS_ASS, LEAVE TRANS_ASS
                   ON STOP   UNDO TRANS_ASS, LEAVE TRANS_ASS:

    FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
								crapass.nrdconta = par_nrdconta EXCLUSIVE-LOCK. 
		END.
        
    IF  AVAIL crapass  THEN
        DO:
            ASSIGN crapass.idimprtr = 0.
            VALIDATE crapass.
        END.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANS_ASS **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar o indicador de impressao.".

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
