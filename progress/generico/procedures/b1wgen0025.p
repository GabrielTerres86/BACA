/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL                      |
  +------------------------------------------+------------------------------------------+
  |   calcula_dia_util                       | GENE0005.fn_valida_dia_util              |
  |   busca_movto_saque_cooperativa          | CADA0001.pc_busca_movto_saque_cooper     |  
  |   taa_lancamento_tarifas_ext             | TARI0001.pc_taa_lancamento_tarifas_ext   |
  |   taa_lancto_titulos_convenios           | COBR0001.pc_taa_lancto_titulos_convenios |
  |   taa_agenda_titulos_convenios           | COBR0001.pc_taa_agenda_titulos_convenios |
  |   taa_transferencias                     | TRNF0001.pc_taa_transferencias           |
  |   taa_agenda_transferencias              | TRNF0001.pc_taa_agenda_transferencias    |
  +------------------------------------------+------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

    Programa: b1wgen0025.p
    Autor   : Ze Eduardo
    Data    : Novembro/2007                  Ultima Atualizacao: 03/10/2018
    
    Dados referentes ao programa:

    Objetivo  : BO referente a funcoes e transacoes do CASH DISPENSER
                trata layout de comunicacao com o sistema ExtraCash - Foton  

    Alteracoes: 09/01/2008 - Acerto no suprimento/recolhimento e Envelopes (Ze).

                12/02/2008 - Incluir trilha do cartao no grava_lancamento (Ze).
                
                29/07/2008 - Alterar crapnsu para uma transacao isolada 
                             e alterar dtransa para Today (Ze).
                             
                27/08/2008 - Incluido tratamento na procedure "valida_cartao"
                             referente Agencia Bancoob (Diego).
                             
                05/09/2008 - Tratar sensores do CASH na procedure status_ATM
                             (Diego).
                             
                10/12/2008 - Trata Resolucao 3518 - BACEN, cobrar tarifa de
                             extrato a partir do 3o extrato por mes (Ze).
                
                07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
                
                22/05/2009 - Implementado controle de estorno, somente efetuar
                             o estorno se houver saque anterior ainda nao
                             estornado (Evandro).
                             
                23/06/2009 - Alteracao nas procedures de Suprimento e 
                             Recolhimento - Verifica e Executa e
                           - Retira a Verificacao se a nova senha eh igual a
                             senha do tele-atendimento   (Ze).
                             
                02/10/2009 - Aumento do campo nrterfin (Diego).
                
                09/03/2010 - Incluidas procedures para o novo sistema do cash
                             Progress (Evandro).
                             
                30/06/2010 - Retirar telefone da ouvidoria (Evandro).
                
                16/07/2010 - Ajuste de controle de lock timeout (Evandro).
                
                30/07/2010 - Sobrescrever o saldo no momento virada de data
                             caso ja exista;
                             Contemplar o valor dos rejeitados (K7R) no
                             recolhimento que aparece na opcao "Operacao"
                             da tela "CASH" (Evandro).
                             
                01/09/2010 - Verificar dia util para busca de saque no
                             momento do estorno para contemplar o fim de 
                             semana e corrigido lancamento de estorno em
                             casos onde mudou a data de saque (maquina
                             desligada, por exemplo);
                           - Melhoria do tratamento de recolhimento
                             (Evandro).
                             
                08/09/2010 - Adicionada procedure de estatisticos de uso nos
                             moldes do sistema antigo (Evandro).
                             
                16/09/2010 - Melhorada procedure verifica transferencia
                            (Evandro).
                            
                08/10/2010 - Adequacoes para uso do TAA compartilhado e
                             retiradas as procedures da Foton (Evandro).

                15/10/2010 - Criacao das procedures:
                             - busca_movto_saque_cooperativa
                             - taa_lancamento_tarifas_ext
                             - taa_lancto_titulos_convenios
                             (Guilherme/Supero)

                22/10/2010 - Adicionado controle para que o saque e o estorno 
                             nao ocorram na mesma hora, minuto e segundo 
                             (Henrique).
                             
                02/12/2010 - Corrigido controle de valores ja sacados
                             utilizando TODAY devido a data de transacao;
                           - Ajuste p/ correcao de problemas na contabilizacao
                             de valores rejeitados (Evandro).
                             
                27/12/2010 - Na procedure vira_data, verificar os lancamentos
                             conforme a cooperativa do terminal (cdcoptfn)
                             devido a saque multicooperativa (Evandro).
                             
                23/02/2011 - Incluidas procedures de confirmacao de reboot e
                             confirmacao de update;
                           - Nao permitir configuracao se terminal ja tiver
                             algum valor de saldo (Evandro).
                             
                01/04/2011 - Ajuste devido ao agendamento de pagamentos e 
                             transferencias no TAA (Henrique).
                             
                08/08/2011 - Incluir no protocolo: a cooperativa , agencia e
                             terminal. Incluir TIME na entrega envelope
                             (Gabriel). 
                           - Trocada mensagem quando TAA desabilitado
                            (Evandro)
                            
                27/10/2011 - Parametros na gera_protocolo 
                           - Transformado a entrega_envelope em uma transacao,
                             pois se voltar erro na gera_protocolo desfaz tudo
                             (Guilherme).
                             
                19/12/2011 - Adicionada validacao da data de nascimento (Evandro).
                
                17/01/2012 - Adicionado controle de letras de seguranca (Evandro).
                
                13/06/2012 - Eliminar EXTENT vldmovto;
                           - Eliminar e-mails utilzados na epoca das fraudes de
                             clonagem de cartao (Evandro).
                             
                23/07/2012 - Tratamento para migracao VIACREDI ALTO VALE
                             (Evandro).
                             
                17/10/2012 - Temp-Tables transferidas para include b1wgen0025tt.i (Oscar)
                
                07/11/2012 - Ajustar letras de seguranca para utilizacao no
                             InternetBank (David).
                             
                28/11/2012 - Tratamento para evitar agendamentos de contas
                             migradas - tabela craptco - TAA (Evandro).
                             
                17/01/2013 - Retornar se eh uma conta migrada na procedure
                             busca_associado (Evandro).
                             
                05/02/2013 - Rotina de verificacao de prova de vida para o 
                             INSS (Evandro).
                             
                26/02/2013 - Corrigida falta de DELETE PROCEDURE para a
                             prova de vida do INSS (Evandro).

                19/03/2013 - Incluir historico 1009 de transf. intercoop.
                             na proc taa transferencias (Gabriel).
                             
                05/06/2013 - Adicionados valores de multa e juros ao valor total
                             das faturas, para DARFs (Lucas).
                            
                26/08/2013 - Nao permitir suprimento de notas inferiores a R$ 10;
                           - Adicionado e-mail de monitoramento de saques de fraude
                             (Evandro).
                             
                02/09/2013 - Ajuste no email de monitoracao (Evandro).
                
                03/09/2013 - Valor de limite minimo de 400,00 no email de
                             monitoracao (Evandro).
                             
                11/09/2013 - Adicionado email da multitask na monitoracao
                             (Evandro).
                             
                12/09/2013 - Alterado valor de saque limite na monitoracao para
                             400,00 e retirado e-mail de varios saques em 10
                             minutos (Evandro).
                             
                25/09/2013 - Alterada rotina de email para monitoracao de
                             terceiros conforme solicitacao da equipe de
                             seguranca (Evandro).
                             
                04/10/2013 - Tratamento para migracao da Acredicoop usando
                             "de/para" de cartoes magneticos e retirada do
                             email da multitask (Evandro).
                             
                07/10/2013 - Ajustar bloqueio de agendamento para contas
                             migradas (David).
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                13/11/2013 - Adicionado verificao e gravacao de historico qd
                             for alterada senha do cartao magnetico do operador
                             em proc. altera_senha. (Jorge)                          
                             
                09/12/2013 - Adicionar PA no assunto dos emails de monitoracao
                             (Evandro).
                             
                11/12/2013 - Enviar e-mail de monitoracao para as cooperativas
                             Viacredi, Alto Vale, Acredicoop, Concredi e
                             Credifoz;
                           - Tratar acoes antifraude nas procedures:
                             verifica_saque
                             verifica_transferencia
                             verifica_autorizacao
                             (Evandro)
                             
                12/12/2013 - Ajustado o valor de e-mails para 300,00 e adicionados
                            dados do TAA no assunto (Evandro).
                            
                05/03/2014 - Incluso VALIDATE (Daniel).
                
                14/03/2014 - Ajustar saque noturno para bloquear saque maior 
                             que 300,00 tambem em cartoes com parametro de 
                             saque livre (David).
                             
                24/03/2014 - Ajuste Oracle tratamento FIND LAST crapnsu para 
                             utilizar sequence (Daniel).
                             
                27/05/2014 - Alterar monitoracao de saque para disparar e-mail
                             independente do limite do cartao (David).
                   
                29/05/2014 - Ajuste na monitoracao do saque para enviar e-mail
                             considerando o limite do cartao (Adriano).
                             
                02/06/2014 - Ajsute realizados:
                            - Limite compartilhado nos finais de semana
                            - Saque noturno, considerar apenas os lancamentos
                              efetuados no mesmo period noturno.
                            - Incluido mais cooperativas para envio de email
                              da monitocacao.
                            (Adriano).
                            
                 03/07/2014 - Tratamento Deposito de envelope intercooperativa 
                            (Reinert/Diego).
                            
                08/08/2014 - Nao sera configurada data limite para agendamentos 
                             provenientes de conta migrada da Concredi (David).            
                             
                15/08/2014 - Alterar monitoracao de saque de 300,00 para
                             500,00 (David).
                             
                02/09/2014 - Implementar regra para bloquear utilizacao do 
                             cartao magnetico durante a incorporacao da 
                             Concredi (David).       
                           - Bloquear transferencia intercooperativa durante e
                             apos migracao para contas da Concredi e Credimilsul 
                             (David).
                             
                15/09/2014 - Tratamento para leitura de cartao na AltoVale,
                             pois a agencia do bancoob foi alterada na tabela
                             crapcop (David).
                             
                29/09/2014 - Ajustar validacao limite saque noturno para subtrair
                             valores de estorno (David).

                22/10/2014 - Efetuado ajustes deposito intercoop. (Reinert)
                
				25/10/2014 - Novos filtros para controle da monitoracao. 
                             (Chamado 198702) - (Jonata-RKAM).

                27/10/2014 - Incluido parametro de saida na procedure 
                             "verifica_cartao". (James)
                             
                28/10/2014 - Adicionada procedure obtem_sequencial_deposito e
                             ajustada procedure entrega_envelope. (Reinert)     
                             
                14/11/2014 - (Chamado 221702) - Alteracao no limite de saque e
                             transferencia. (Tiago Castro - RKAM)
                             
                09/01/2015 - Correção no cálculo de limite disponível para saque e
                             alteração nas procedures 'verifica_transferencia' e
                             'verifica_saque' para limite compartilhado entre
                             saque/transferencia em finais de semana. (Lunelli SD 239710)
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                20/02/2015 - Ajuste para considerar valores sacados em
                             feriados. (Jonata-RKAM)             
                             
                14/05/2015 - Ajuste na procedure verifica_transferencia para 
                             nao considerar o limite de valor de cartao vencido.
                             (Jaison/Elton - SD: 277000)
               
                06/07/2015 - Trocado em algumas situações o dtmvtolt por dtmvtocd 
                             e incluido um while na procedure verifica_movimento
                             para ficar validando lock da tabela, ajuste feito para
                             arrumar o problema relatado no chamado 303100. (Kelvin)
                
                27/07/2015 - Ajuste para verificar o limite de saque da tabela
                             TBTAA_LIMITE_SAQUE. (James)
                             
                31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                             de fontes (Adriano - SD 314469).
                             
                17/08/2015 - Incluir validacao para a data limite para agendamentos
                             nas procedures verifica_transferencia 
                             (Lucas Ranghetti #312614 ).
                             
                03/09/2015 - Incluido a chamada da procedure pc_verifica_tarifa_operacao
                             na procedure efetua_saque, Prj. Tarifas (Jean Michel).
                             
                15/09/2015 - Alterações para logar valores de saldo e limite em validação de 
                             operações de saque (Lunelli SD 306183).
                             
                26/10/2015 - Desenvolvimento do projeto 126. (James)
                
                26/11/2015 - Ajustar as procedures verifica_transferencia e verifica_saque
                             para utilizar a procedure obtem-saldo-dia do Oracle
                             (Douglas - Chamado 285228)
                             
                03/12/2015 - Inclusão de VALIDATE na crapstf (Lunelli SD 354547)
                
                23/02/2016 - Alteração na rotina de alteração de senha 
                           (Lucas Lunelli - [PROJ290])
                
                01/03/2016 - Chamada do procedimento da geração de LOG na rotina
                             efetua_saque 
                           - Alteração na rotina de alteração de senha 
                           - Criada rotina 'valida_senha_tp_cartao'
                           (Lucas Lunelli - [PROJ290])
                05/04/2016 - Incluidos novos parametros na procedure
                             pc_verifica_tarifa_operacao, Prj 218 (Jean Michel).           
                             
                25/07/2016 - #480602 tratada a verifica_saque para fazer a verificação do 
                             limite da pc_obtem_saldo_dia_prog e removida a chamada da 
                             procedure obtem-valor-limite (Carlos)
                             
                18/11/2016 - #559508 correção na verificação da existência do cartão
                             magnético de operador. Quando for um cartão de operador,
                             não consultar transferência de conta (Carlos)

                19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                             crapass, crapttl, crapjur (Adriano - P339).
                30/11/2017 - Ajuste na verifica_prova_vida_inss - Chamado 784845 - 
				                     Prova de vida nao aparecendo na AV - Andrei - Mouts							

                12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                             pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
                26/12/2017 - #820634 Aumentado o limite de saque noturno, 
                             de R$300 para R$500 (Carlos)

                26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
        
                19/07/2018 - Remover a acentuacao das mensagens de retorno, para que todas fiquem
                             identicas. (PRJ 363 - Douglas Quisinski)

                03/10/2018 - adicionado o parametro IDORIGEM nas procedures valida_senha,
                             valida_senha_cartao_magnetico, valida_senha_cartao_cecred                
                             para que seja possivel zerar a quantidade de senha incorretas quando
                             estiver sendo executado pela URA (Douglas - Prj 427 URA)								

				13/11/2018 - Adicionado parametros na procedure pc_verifica_tarifa_operacao. (PRJ 345 - Fabio Stein)

..............................................................................*/

{ sistema/generico/includes/b1wgen0025tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/gera_erro.i }

{ sistema/generico/includes/var_oracle.i }

PROCEDURE verifica_autorizacao:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR             NO-UNDO.

    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptfn  THEN
        DO:
            par_dscritic = "TAA nao cadastrado.".
            RETURN "NOK".
        END.
    ELSE
    IF  craptfn.cdsitfin = 3  THEN
        DO:
            par_dscritic = "TAA Bloqueado.".
            RETURN "NOK".
        END.
    ELSE
    IF  NOT craptfn.flsistaa  THEN
        DO:
            par_dscritic = "TAA Desabilitado.".
            RETURN "NOK".
        END.
    /** Desabilitado em 02/01/2014
    ELSE
    IF (STRING(TIME,"HH:MM") > "22:00"   OR
        STRING(TIME,"HH:MM") < "07:00")  THEN
        DO:
            par_dscritic = "TAA Bloqueado, horário excedido.".
            RETURN "NOK".
        END.
    **/

    RETURN "OK".

END PROCEDURE.
/* Fim verifica_autorizacao */


PROCEDURE confirma_reboot:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR             NO-UNDO.

    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    /* Reboot efetuado com sucesso */
    craptfn.inreboot = 2.

    FIND CURRENT craptfn NO-LOCK.

    RETURN "OK".

END PROCEDURE.
/* Fim confirma_reboot */



PROCEDURE confirma_update:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR             NO-UNDO.

    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    /* controle de versao do TAA */
    FIND craptab WHERE craptab.cdcooper = 3             AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "AUTOMA"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "DSVERTAA"    AND
                       craptab.tpregist = 1             NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            par_dscritic = "Versao Indisponivel".
            RETURN "NOK".
        END.


    /* Update efetuado com sucesso */
    ASSIGN craptfn.dsvertaa = craptab.dstextab
           craptfn.flupdate = NO.

    FIND CURRENT craptfn NO-LOCK.

    RETURN "OK".

END PROCEDURE.
/* Fim confirma_update */

PROCEDURE verifica_cartao:

    DEFINE         INPUT PARAM par_cdcoptfn    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_nrterfin    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_dscartao    AS CHAR      NO-UNDO.
    DEFINE         INPUT PARAM par_dtmvtocd    AS DATE      NO-UNDO.
    DEFINE        OUTPUT PARAM par_nrdconta    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_cdcooper    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_nrcartao    AS DEC       NO-UNDO.
    DEFINE        OUTPUT PARAM par_inpessoa    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_idsenlet    AS LOGICAL   NO-UNDO.
    DEFINE        OUTPUT PARAM par_tpusucar    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_idtipcar    AS INTEGER   NO-UNDO.
    DEFINE        OUTPUT PARAM par_dscritic    AS CHAR      NO-UNDO.

    DEFINE VARIABLE aux_nrcrcard  LIKE crapcrd.nrcrcard     NO-UNDO.    
    
    ASSIGN aux_nrcrcard = DECI(SUBSTR(par_dscartao,3,16))  NO-ERROR.
    
    IF ERROR-STATUS:ERROR THEN
       DO:
           par_dscritic = "Erro de leitura.".
           RETURN "NOK".
       END.    
    
    FOR FIRST crapcrd, crapcop FIELDS(cdcooper) 
                      WHERE crapcrd.nrcrcard = aux_nrcrcard
          				AND crapcop.cdcooper = crapcrd.cdcooper
          				AND crapcop.flgativo = TRUE
                            NO-LOCK: END.
    
    /* Cartao de credito CECRED */
    IF AVAILABLE crapcrd THEN
       DO:
           RUN verifica_cartao_cecred(INPUT par_cdcoptfn,
                                      INPUT par_nrterfin,
                                      INPUT par_dscartao,
                                      INPUT par_dtmvtocd,
                                      INPUT RECID(crapcrd),
                                      OUTPUT par_cdcooper,
                                      OUTPUT par_nrdconta,                                      
                                      OUTPUT par_nrcartao,
                                      OUTPUT par_inpessoa,
                                      OUTPUT par_idsenlet,
                                      OUTPUT par_tpusucar,
                                      OUTPUT par_dscritic).
                                      
           IF RETURN-VALUE <> "OK"  THEN
              RETURN "NOK".
           
           /* Cartao de Credito */
           ASSIGN par_idtipcar = 2.
           
       END.
    /* Cartao Magnetico */   
    ELSE     
    DO:
        ASSIGN par_nrdconta = INTEGER(SUBSTR(par_dscartao,11,08)).
        
        RUN verifica_cartao_magnetico(INPUT par_cdcoptfn,
                                      INPUT par_nrterfin,
                                      INPUT par_dscartao,
                                      INPUT par_dtmvtocd,
                                      INPUT-OUTPUT par_nrdconta,
                                      OUTPUT par_cdcooper,
                                      OUTPUT par_nrcartao,
                                      OUTPUT par_inpessoa,
                                      OUTPUT par_idsenlet,
                                      OUTPUT par_tpusucar,
                                      OUTPUT par_dscritic).
                                      
        IF RETURN-VALUE <> "OK"  THEN
           RETURN "NOK".
        
        /* Cartao Magnetico */
        ASSIGN par_idtipcar = 1.
        
    END.
      
    RETURN "OK".

END PROCEDURE.
/* Fim verifica_cartao */

PROCEDURE valida_senha:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dssencar    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dtnascto    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_idtipcar    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_idorigem    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_cdcritic    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    /* Cartão Magnético */
    IF par_idtipcar = 1 THEN
       DO:
           RUN valida_senha_cartao_magnetico(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrcartao,
                                             INPUT par_dssencar,
                                             INPUT par_dtnascto,
                                             INPUT par_idorigem,
                                             OUTPUT par_cdcritic,
                                             OUTPUT par_dscritic).
                                          
           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
       END.
    ELSE   
    /* Cartão Cecred */
    IF par_idtipcar = 2 THEN
       DO:
           RUN valida_senha_cartao_cecred(INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_nrcartao,
                                          INPUT par_dssencar,
                                          INPUT par_dtnascto,
                                          INPUT par_idorigem,
                                          OUTPUT par_cdcritic,
                                          OUTPUT par_dscritic).
                                          
           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
       END.    
    ELSE
       DO:
           ASSIGN par_dscritic = "Tipo de cartao invalido.".
           RETURN "NOK".    
       END.
    
    RETURN "OK".

END PROCEDURE.
/* Fim valida_senha */



PROCEDURE valida_senha_letras:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup1    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup2    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup3    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_idtipcar    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    /* Cartão Magnético */
    IF par_idtipcar = 1 THEN
       DO:
           RUN valida_senha_letras_cartao_magnetico(INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                    INPUT par_nrcartao,
                                                    INPUT par_dsdgrup1,
                                                    INPUT par_dsdgrup2,
                                                    INPUT par_dsdgrup3,
                                                    OUTPUT par_dscritic).
                                          
           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
              
       END.
    ELSE   
    /* Cartão Cecred */
    IF par_idtipcar = 2 THEN
       DO:
           RUN valida_senha_letras_cartao_cecred(INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrcartao,
                                                 INPUT par_dsdgrup1,
                                                 INPUT par_dsdgrup2,
                                                 INPUT par_dsdgrup3,
                                                 OUTPUT par_dscritic).
                                          
           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
              
       END.
    ELSE
       DO:
           ASSIGN par_dscritic = "Tipo de cartao invalido.".
           RETURN "NOK".
       END.
       
    RETURN "OK".   

END PROCEDURE.
/* Fim valida_senha_letras */


PROCEDURE valida_letras_seguranca:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_idseqttl    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup1    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup2    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup3    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_flgencod    AS LOGI         NO-UNDO.
    DEFINE OUTPUT PARAM par_flsenlet    AS LOGI         NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    DEFINE VARIABLE     tmp_contado1    AS INT          NO-UNDO.
    DEFINE VARIABLE     tmp_contado2    AS INT          NO-UNDO.
    DEFINE VARIABLE     tmp_contado3    AS INT          NO-UNDO.
    DEFINE VARIABLE     tmp_dsdletra    AS CHAR         NO-UNDO.
    DEFINE VARIABLE     tmp_dsdletr1    AS CHAR         NO-UNDO.
    DEFINE VARIABLE     tmp_dsdletr2    AS CHAR         NO-UNDO.
    DEFINE VARIABLE     tmp_dsdletr3    AS CHAR         NO-UNDO.
    DEFINE VARIABLE     tmp_dssenlet    AS CHAR         NO-UNDO.
    
    /* verifica o cartao */
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper  AND
                       crapsnh.nrdconta = par_nrdconta  AND
                       crapsnh.idseqttl = par_idseqttl  AND
                       crapsnh.tpdsenha = 3             NO-LOCK NO-ERROR.
                                                       
    IF  NOT AVAILABLE crapsnh   THEN
        DO:
            par_dscritic = "Letras de seguranca nao cadastradas.".
            RETURN "NOK".
        END.

    /* se a situacao nao estiver ativa no momento EXATO da validacao de senha */
    IF  crapsnh.cdsitsnh <> 1  THEN
        DO:
            par_dscritic = "Senha Invalida.".
            RETURN "NOK".
        END.                              

    /* faz BRUTE FORCE para "descobrir" cada letra dos grupos escolhidos
       pelo associado, para depois poder testar */
    
    ASSIGN tmp_dsdletra = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U".

    /* grupo 1 */
    DO tmp_contado1 = 1 TO 21.

        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(1,par_dsdgrup1,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(1,par_dsdgrup1,"-"))     THEN
            tmp_dsdletr1 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(2,par_dsdgrup1,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(2,par_dsdgrup1,"-"))     THEN
            tmp_dsdletr2 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(3,par_dsdgrup1,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(3,par_dsdgrup1,"-"))     THEN
            tmp_dsdletr3 = ENTRY(tmp_contado1,tmp_dsdletra).

    END.

    par_dsdgrup1 = tmp_dsdletr1 + "-" + tmp_dsdletr2 + "-" + tmp_dsdletr3.
    
    /* grupo 2 */
    DO tmp_contado1 = 1 TO 21.

        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(1,par_dsdgrup2,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(1,par_dsdgrup2,"-"))     THEN
            tmp_dsdletr1 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(2,par_dsdgrup2,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(2,par_dsdgrup2,"-"))     THEN
            tmp_dsdletr2 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(3,par_dsdgrup2,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(3,par_dsdgrup2,"-"))     THEN
            tmp_dsdletr3 = ENTRY(tmp_contado1,tmp_dsdletra).

    END.

    par_dsdgrup2 = tmp_dsdletr1 + "-" + tmp_dsdletr2 + "-" + tmp_dsdletr3.
    
    /* grupo 3 */
    DO tmp_contado1 = 1 TO 21.

        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(1,par_dsdgrup3,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(1,par_dsdgrup3,"-"))     THEN
            tmp_dsdletr1 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(2,par_dsdgrup3,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(2,par_dsdgrup3,"-"))     THEN
            tmp_dsdletr2 = ENTRY(tmp_contado1,tmp_dsdletra).
        
        IF (par_flgencod AND ENCODE(ENTRY(tmp_contado1,tmp_dsdletra)) = ENTRY(3,par_dsdgrup3,"-")) OR
           (NOT par_flgencod AND ENTRY(tmp_contado1,tmp_dsdletra) = ENTRY(3,par_dsdgrup3,"-"))     THEN
            tmp_dsdletr3 = ENTRY(tmp_contado1,tmp_dsdletra).

    END.

    par_dsdgrup3 = tmp_dsdletr1 + "-" + tmp_dsdletr2 + "-" + tmp_dsdletr3.
    
    par_flsenlet = NO.

    /* varre todas as possibilidades de montagem com os grupos recebidos */
    DO  tmp_contado1 = 1 TO 3:

        tmp_dsdletr1 = ENTRY(tmp_contado1,par_dsdgrup1,"-").

        DO  tmp_contado2 = 1 TO 3:

            tmp_dsdletr2 = ENTRY(tmp_contado2,par_dsdgrup2,"-").

            DO  tmp_contado3 = 1 TO 3:

                tmp_dsdletr3 = ENTRY(tmp_contado3,par_dsdgrup3,"-").
                
                /* monta a senha, inverte as letras */
                tmp_dssenlet = ENCODE(tmp_dsdletr3 + tmp_dsdletr2 + tmp_dsdletr1).

                IF  tmp_dssenlet = crapsnh.cddsenha  THEN
                    DO:
                        par_flsenlet = YES.
                        LEAVE.
                    END.

            END.

            IF  par_flsenlet  THEN
                LEAVE.

        END.

        IF  par_flsenlet  THEN
            LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.
/* Fim valida_letras_seguranca */


PROCEDURE altera_situacao:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_cdsitfin    AS INT              NO-UNDO.
    DEFINE  INPUT PARAM par_cdoperad    AS CHAR             NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE  INPUT PARAM par_vltransa    AS DEC              NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR             NO-UNDO.


    DEFINE     VARIABLE tmp_cdsitfin    AS INT              NO-UNDO.
    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    tmp_cdsitfin = craptfn.cdsitfin.

    ASSIGN craptfn.cdsitfin = par_cdsitfin
           craptfn.cdoperad = par_cdoperad.

    /* log de operacoes no servidor */
    CREATE craplfn.
    ASSIGN craplfn.cdcooper = par_cdcoptfn
           craplfn.cdoperad = par_cdoperad
           craplfn.dtmvtolt = par_dtmvtolt
           craplfn.nrterfin = par_nrterfin
           craplfn.dttransa = TODAY
           craplfn.hrtransa = TIME
           craplfn.tpdtrans = par_cdsitfin
           craplfn.vltransa = par_vltransa
           craplfn.cdsitatu = 1.
    

    /* se desbloqueou o TAA grava o registro como desbloqueio
       para ser visualizado na tela cash, porem o terminal nunca 
       ficara com a situacao 6-Desbloqueado */
    IF  tmp_cdsitfin  = 3  AND
        par_cdsitfin <> 3  THEN
        craplfn.tpdtrans = 6. /* Desbloqueado */

    VALIDATE craplfn.
        

    FIND CURRENT craptfn NO-LOCK.
    
    RETURN "OK".

END PROCEDURE.
/* Fim altera_situacao */



PROCEDURE efetua_suprimento:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_qtnotaK7    AS INT      EXTENT 5        NO-UNDO.
    DEFINE  INPUT PARAM par_vlnotaK7    AS DEC      EXTENT 5        NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     aux_contador    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_vltotsup    AS DEC                      NO-UNDO.
    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.


    /* nao permite suprimento inferior a 10,00 */
    DO  aux_contador = 1 TO 4:

        IF  par_vlnotaK7[aux_contador] <>  0  AND
            par_vlnotaK7[aux_contador] <  10  THEN
            DO:
                par_dscritic = "Suprimento Invalido.".
                RETURN "NOK".
            END.
    END.
    


    DO  aux_contador = 1 TO 4:
    
        ASSIGN craptfn.qtnotcas[aux_contador] = par_qtnotaK7[aux_contador]
               craptfn.vlnotcas[aux_contador] = par_vlnotaK7[aux_contador]
               craptfn.vltotcas[aux_contador] = par_qtnotaK7[aux_contador] * par_vlnotaK7[aux_contador]
               aux_vltotsup                   = aux_vltotsup + craptfn.vltotcas[aux_contador].
    END.


    craptfn.cdoperad = par_cdoperad.
    
    FIND CURRENT craptfn NO-LOCK.


    /* adiciona o valor suprido no saldo final */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcoptfn  NO-LOCK NO-ERROR.


    DO  WHILE TRUE:

        FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND
                           crapstf.nrterfin = par_nrterfin  AND
                           crapstf.dtmvtolt = crapdat.dtmvtocd
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  AVAILABLE crapstf  THEN
            DO:
                crapstf.vldsdfin = crapstf.vldsdfin + aux_vltotsup.
            
                FIND CURRENT crapstf NO-LOCK.
            END.
        ELSE
        IF  LOCKED crapstf  THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.

        LEAVE.
    END.

    VALIDATE crapstf.
    
    RETURN "OK".

END PROCEDURE.
/* Fim efetua_suprimento */




PROCEDURE efetua_recolhimento:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_tprecolh    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_vlrecolh    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     aux_contador    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_vlrejeit    AS DEC                      NO-UNDO.

    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    
    FIND crapdat WHERE crapdat.cdcooper = par_cdcoptfn  NO-LOCK NO-ERROR.


    /* Numerários */
    IF  par_tprecolh = 1  THEN
        DO  aux_contador = 1 TO 5:

            /* Valor recolhido dos cassetes (sem considerar K7R) */
            IF  aux_contador <> 5  THEN
                par_vlrecolh = par_vlrecolh + craptfn.vltotcas[aux_contador].
            ELSE
                /* valor das notas no K7R */
                aux_vlrejeit = craptfn.vlnotcas[aux_contador].

            ASSIGN craptfn.qtnotcas[aux_contador] = 0
                   craptfn.vlnotcas[aux_contador] = 0
                   craptfn.vltotcas[aux_contador] = 0.
        END.
    ELSE
        DO:
            /* Somente cria log e limpa a quantidade de envelopes,
               nao muda a situacao do TAA */
            craptfn.qtenvelo = 0.

            /* log de operacoes no servidor */
            CREATE craplfn.
            ASSIGN craplfn.cdcooper = par_cdcoptfn
                   craplfn.cdoperad = par_cdoperad
                   craplfn.dtmvtolt = crapdat.dtmvtocd
                   craplfn.nrterfin = par_nrterfin
                   craplfn.dttransa = TODAY
                   craplfn.hrtransa = TIME
                   craplfn.tpdtrans = 5 /* recolhimento */
                   craplfn.vltransa = 0 /* nao possui valor */
                   craplfn.cdsitatu = 1.

            /* Seta os envelopes em aberto do TAA como recolhidos */
            FOR EACH crapenl WHERE crapenl.cdcoptfn = par_cdcoptfn  AND
                                   crapenl.nrterfin = par_nrterfin  AND
                                   crapenl.cdsitenv = 0 /* nao liberados */
                                   EXCLUSIVE-LOCK:
                /* envelope recolhido */
                crapenl.cdsitenv = 3.
            END.

            VALIDATE craplfn.

            FIND CURRENT craplfn NO-LOCK.
        END.

    
    craptfn.cdoperad = par_cdoperad.

    FIND CURRENT craptfn NO-LOCK.



    /* Numerários: O valor recolhido é somado com o total as notas do K7R
                   para aparecer na rotina "Operacoes" da tela "CASH" e
                   fechar com os lancamentos contabeis */
    IF  par_tprecolh = 1  THEN
        DO:
            par_vlrecolh = par_vlrecolh + aux_vlrejeit.
            
            DO  WHILE TRUE:
                
                /* diminui o valor recolhido do saldo final */
                FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND
                                   crapstf.nrterfin = par_nrterfin  AND
                                   crapstf.dtmvtolt = crapdat.dtmvtocd
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF  AVAILABLE crapstf  THEN
                    DO:
                        crapstf.vldsdfin = crapstf.vldsdfin - par_vlrecolh.

                        RUN verifica_movimento(INPUT crapstf.cdcooper,
                                               INPUT crapstf.dtmvtolt,
                                               INPUT crapstf.nrterfin,
                                               INPUT 9999).

                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                par_dscritic = "TAA indisponivel.".
                                UNDO, RETURN "NOK".
                            END.

                        crapstd.vldmovto = crapstd.vldmovto + aux_vlrejeit.
                
                        FIND CURRENT crapstf NO-LOCK.
                        FIND CURRENT crapstd NO-LOCK.
                    END.
                ELSE
                IF  LOCKED crapstf  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
            
                LEAVE.
            END.

            VALIDATE crapstf.

        END.

    RETURN "OK".

END PROCEDURE.
/* Fim efetua_recolhimento */







PROCEDURE obtem_nsu:

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_nrsequni    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.
    
    DEFINE     VARIABLE aux_contador    AS INT                      NO-UNDO.

    DEFINE     VARIABLE aux_nrsequen    AS INT                      NO-UNDO.

    /* Busca a proxima sequencia do campo crapmat.nrseqcar */
	RUN STORED-PROCEDURE pc_sequence_progress
	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNSU"
										,INPUT "NRSEQUNI"
										,INPUT TRIM(STRING(par_cdcooper))
										,INPUT "N"
										,"").
	
	CLOSE STORED-PROC pc_sequence_progress
	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
			  
	ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
						  WHEN pc_sequence_progress.pr_sequence <> ?.
    
    ASSIGN  par_nrsequni = aux_nrsequen.

    RETURN "OK".

END PROCEDURE.
/* Fim obtem_nsu */

PROCEDURE obtem_sequencial_deposito:

    DEFINE OUTPUT PARAM par_nrsequni    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE     VARIABLE aux_contador    AS INT                      NO-UNDO.

    DEFINE     VARIABLE aux_ponteiro    AS INT                      NO-UNDO.
    DEFINE     VARIABLE aux_nrsequen    AS INT                      NO-UNDO.

    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement aux_ponteiro = PROC-HANDLE
        ("SELECT SEQENL_NRSEQENV.nextval FROM dual").


    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
        ASSIGN aux_nrsequen = INTE(proc-text).
    END.
    
    
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement WHERE PROC-HANDLE = aux_ponteiro.
    
    
    ASSIGN  par_nrsequni = aux_nrsequen.
    
    RETURN "OK".

END PROCEDURE.



PROCEDURE entrega_envelope:

    /* Cooperativa que acolheu o deposito */ 
    DEFINE  INPUT PARAM par_cdcoptfn                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcopdst                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrseqenv                AS INT                      NO-UNDO.    
    DEFINE  INPUT PARAM par_nrseqenl                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdocmto                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt                AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_nrctafav                AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldininf                AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_vlchqinf                AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dsprotoc                AS CHAR                     NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic                AS CHAR                     NO-UNDO.

    DEFINE     VARIABLE h-bo_algoritmo_seguranca    AS HANDLE                   NO-UNDO.
    DEFINE     VARIABLE aux_dsinform                AS CHAR     EXTENT  3       NO-UNDO.
    
    DO TRANSACTION ON ERROR UNDO, LEAVE: 

        FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                           craptfn.nrterfin = par_nrterfin
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAILABLE craptfn  THEN
            DO:
                IF  LOCKED(craptfn)  THEN
                    par_dscritic = "TAA indisponivel.".
                ELSE
                    par_dscritic = "TAA nao cadastrado.".
    
                RETURN "NOK".
            END.

        ASSIGN craptfn.qtenvelo = craptfn.qtenvelo + 1. /* Mais 1 envelope recebido */
   
        /* Deposito em conta corrente, identificado */
        IF  par_vldininf + par_vlchqinf > 0  THEN
        DO:
            /* Cria o deposito bloqueado para o associado */
            CREATE crapenl.
            ASSIGN crapenl.cdcoptfn = par_cdcoptfn     /* Cooperativa do terminal */
                   crapenl.cdagetfn = craptfn.cdagenci /* PAC do terminal */
                   crapenl.nrterfin = par_nrterfin     /* Terminal*/ 
                   crapenl.cdcooper = par_cdcopdst     /* Cooperativa do associado */
                   crapenl.nrseqenv = par_nrseqenl     /* Nr. sequencial de deposito */ 
                   crapenl.nrdconta = par_nrctafav     /* C/C Favorecida */
                   crapenl.dtmvtolt = par_dtmvtolt
                   crapenl.vldininf = par_vldininf
                   crapenl.vlchqinf = par_vlchqinf
                   crapenl.hrtransa = TIME  
                   crapenl.cdsitenv = 0. /* nao liberado */
            VALIDATE crapenl.

            /* gera um protocolo do deposito */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p PERSISTENT SET h-bo_algoritmo_seguranca.
       
            IF  VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
            DO:
                aux_dsinform[1] = "Deposito TAA".

                IF  par_vldininf > 0  THEN
                    aux_dsinform[1] = aux_dsinform[1] + " - DIN".
                ELSE
                    aux_dsinform[1] = aux_dsinform[1] + " - CHQ".


                /* dados da conta destino */
                FIND crapass WHERE crapass.cdcooper = par_cdcopdst  AND
                                   crapass.nrdconta = par_nrctafav
                                   NO-LOCK NO-ERROR.

                IF  AVAILABLE crapass  THEN
                    aux_dsinform[2] = "#Conta/dv Destino: " +
                                      STRING(par_nrctafav,"zzzz,zzz,9") + " - "  + 
                                      crapass.nmprimtl.

                aux_dsinform[3] = 
                    "Documento: " + STRING(par_nrdocmto,"99999")    + 
                    "#TAA: "      + STRING(craptfn.cdcooper,"9999") + 
                    "/"           + STRING(craptfn.cdagenci,"9999") + 
                    "/"           + STRING(craptfn.nrterfin,"9999").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                  (INPUT par_cdcopdst,    /* coop do associado        */
                   INPUT par_dtmvtolt,    /* data                     */
                   INPUT par_nrdocmto,    /* horario                  */
                   INPUT par_nrctafav,    /* conta do favorecido      */
                   INPUT par_nrdocmto,    /* documento                */
                   INPUT par_nrseqenv,    /* seq. autenticacao        */ 
                   INPUT par_vldininf + par_vlchqinf, /* valor        */
                   INPUT par_nrterfin,    /* caixa - usado nro do TAA */
                   INPUT YES,             /* Gravar crappro           */
                   INPUT 5,               /* Deposito TAA             */
                   INPUT aux_dsinform[1], /* Info 1                   */
                   INPUT aux_dsinform[2], /* Info 2                   */
                   INPUT aux_dsinform[3], /* Info 3                   */
                   INPUT "",              /* Sem Cedente              */
                   INPUT NO,              /* Nao Agendamento          */
                   INPUT 0,
                   INPUT 0,
                   INPUT "",
                  OUTPUT par_dsprotoc,
                  OUTPUT par_dscritic).
            
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF  RETURN-VALUE <> "OK"  THEN
                    UNDO, RETURN "NOK".
            END.

        END. /* fim deposito identificado */

        /* Log de transacoes no servidor */
        CREATE crapltr.
        ASSIGN crapltr.cdcooper = par_cdcopdst /* Coop do Associado */
               crapltr.cdcoptfn = par_cdcoptfn /* Coop do TAA */
               crapltr.cdhistor = 698
               crapltr.dtmvtolt = par_dtmvtolt
               crapltr.dttransa = TODAY
               crapltr.hrtransa = par_nrdocmto
               crapltr.nrdconta = par_nrctafav
               crapltr.nrdocmto = par_nrseqenv
               crapltr.nrsequni = par_nrseqenv
               crapltr.nrterfin = par_nrterfin
               crapltr.tpautdoc = 1
               crapltr.vllanmto = par_vldininf + par_vlchqinf.
        VALIDATE crapltr.

        FIND CURRENT craptfn NO-LOCK.
    END.

    RETURN "OK".

END PROCEDURE.
/* Fim entrega_envelope */



PROCEDURE vira_data:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_vldsdini    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldmovto    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldsdfin    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE     VARIABLE aux_vldsaque    AS DEC  EXTENT 2            NO-UNDO.
    DEFINE     VARIABLE aux_vldestor    AS DEC  EXTENT 2            NO-UNDO.


    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    /* verifica os saques e estornos efetuados na data */
    ASSIGN aux_vldsaque = 0
           aux_vldestor = 0

           /* para efeito contabil, o valor de rejeitados ainda nao
              recolhidos eh contabilizado como saldo */
           par_vldsdfin = par_vldsdfin + craptfn.vlnotcas[5].

         
    /* Saque/Estorno Coop */
    FOR EACH crapltr WHERE crapltr.cdcoptfn = par_cdcoptfn  AND
                           crapltr.dtmvtolt = par_dtmvtolt  AND
                           crapltr.nrterfin = par_nrterfin  AND
                          (crapltr.cdhistor = 316 OR
                           crapltr.cdhistor = 767)
                           NO-LOCK:

        IF  crapltr.cdhistor = 316  THEN
            aux_vldsaque[1] = aux_vldsaque[1] + crapltr.vllanmto.
        ELSE
            aux_vldestor[1] = aux_vldestor[1] + crapltr.vllanmto.
    END.


    /* Saque/Estorno Multicoop */
    FOR EACH crapltr WHERE crapltr.cdcoptfn = par_cdcoptfn  AND
                           crapltr.dtmvtolt = par_dtmvtolt  AND
                           crapltr.nrterfin = par_nrterfin  AND
                          (crapltr.cdhistor = 918 OR
                           crapltr.cdhistor = 920)
                           NO-LOCK:

        IF  crapltr.cdhistor = 918  THEN
            aux_vldsaque[2] = aux_vldsaque[2] + crapltr.vllanmto.
        ELSE
            aux_vldestor[2] = aux_vldestor[2] + crapltr.vllanmto.
    END.


    /* verifica se os valores computados pelo TAA estao
       de acordo com os valores no servidor */
    IF  par_vldmovto <> ((aux_vldsaque[1] - aux_vldestor[1]) +
                         (aux_vldsaque[2] - aux_vldestor[2])) THEN
        .


    DO  WHILE TRUE:
    
        /* atualiza o saldo final do dia */
        FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND
                           crapstf.nrterfin = par_nrterfin  AND
                           crapstf.dtmvtolt = par_dtmvtolt
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        
        IF  AVAILABLE crapstf  THEN
            DO:
                /* Saque Coop */
                RUN verifica_movimento(INPUT crapstf.cdcooper,
                                       INPUT crapstf.dtmvtolt,
                                       INPUT crapstf.nrterfin,
                                       INPUT 316).

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        par_dscritic = "TAA indisponivel.".
                        UNDO, RETURN "NOK".
                    END.

                crapstd.vldmovto = aux_vldsaque[1].

                /* estorno */
                RUN verifica_movimento(INPUT crapstf.cdcooper,
                                       INPUT crapstf.dtmvtolt,
                                       INPUT crapstf.nrterfin,
                                       INPUT 767).

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        par_dscritic = "TAA indisponivel.".
                        UNDO, RETURN "NOK".
                    END.

                crapstd.vldmovto = aux_vldestor[1].



                /* Saque Multicoop */
                RUN verifica_movimento(INPUT crapstf.cdcooper,
                                       INPUT crapstf.dtmvtolt,
                                       INPUT crapstf.nrterfin,
                                       INPUT 918).

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        par_dscritic = "TAA indisponivel.".
                        UNDO, RETURN "NOK".
                    END.

                crapstd.vldmovto = aux_vldsaque[2].


                /* estorno */
                RUN verifica_movimento(INPUT crapstf.cdcooper,
                                       INPUT crapstf.dtmvtolt,
                                       INPUT crapstf.nrterfin,
                                       INPUT 920).

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        par_dscritic = "TAA indisponivel.".
                        UNDO, RETURN "NOK".
                    END.

                crapstd.vldmovto = aux_vldestor[2].


                /* Atualiza o saldo final */
                crapstf.vldsdfin = par_vldsdfin.
                
                FIND CURRENT crapstf NO-LOCK.
                FIND CURRENT crapstd NO-LOCK.
            END.
        ELSE
        IF  LOCKED crapstf  THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.


        LEAVE.
    END.
        

    /* cria o saldo para a nova data ou substitui se ja existir */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcoptfn NO-LOCK NO-ERROR.


    DO  WHILE TRUE:
    
        FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND
                           crapstf.nrterfin = par_nrterfin  AND
                           crapstf.dtmvtolt = crapdat.dtmvtocd
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapstf  THEN
            DO:
                IF  LOCKED crapstf  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.

                CREATE crapstf.
                ASSIGN crapstf.cdcooper = par_cdcoptfn
                       crapstf.nrterfin = par_nrterfin
                       crapstf.dtmvtolt = crapdat.dtmvtocd.
                VALIDATE crapstf.
            END.

        LEAVE.
    END.


           /* saldo inicial da nova data eh o saldo final do dia anterior */
    ASSIGN crapstf.vldsdini = par_vldsdfin
           /* saldo final da nova data eh o mesmo que o inicial */
           crapstf.vldsdfin = par_vldsdfin.


    FIND CURRENT crapstf NO-LOCK.
    FIND CURRENT craptfn NO-LOCK.

    VALIDATE crapstf.

    RETURN "OK".

END PROCEDURE.
/* Fim vira_data */








PROCEDURE altera_senha:


    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_dssencar    AS CHAR                     NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEF VAR h-b1wgen0032 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgenprwd AS HANDLE                                  NO-UNDO.

    DEF VAR aux_dsdpsrwd AS INTE                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS CHAR                                    NO-UNDO.

    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper  AND
                       crapcrm.nrdconta = par_nrdconta  AND
                       crapcrm.nrcartao = par_nrcartao
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                       
    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            IF  LOCKED(crapcrm)  THEN
                par_dscritic = "Cartao sendo utilizado.".
            ELSE
                par_dscritic = "Cartao nao cadastrado.".

            RETURN "NOK".
        END.
    
    /* se for cartao magnetico de operador */
    IF crapcrm.tptitcar = 9 THEN
    DO:
       IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
           RUN  sistema/generico/procedures/b1wgen0032.p 
                PERSISTENT SET h-b1wgen0032.

       RUN validar-hist-cartmagope IN h-b1wgen0032 
                                  (INPUT crapcrm.cdcooper,
                                   INPUT crapcrm.nrdconta,
                                   INPUT crapcrm.tpusucar,
                                   INPUT par_dssencar,
                                   INPUT YES, /* ja vai encodada */
                                  OUTPUT par_dscritic).
       IF  par_dscritic <> "" THEN
       DO:
           DELETE PROCEDURE h-b1wgen0032.
           RETURN "NOK".
       END.
          

       RUN gravar-hist-cartmagope IN h-b1wgen0032 (INPUT crapcrm.cdcooper,
                                                   INPUT crapcrm.nrdconta,
                                                   INPUT crapcrm.tpusucar,
                                                   INPUT par_dssencar,
                                                  OUTPUT par_dscritic).
       DELETE PROCEDURE h-b1wgen0032.

       IF par_dscritic <> "" THEN
           RETURN "NOK".
    END.

    crapcrm.dssencar = par_dssencar.

    RUN sistema/generico/procedures/b1wgenpwrd.p 
            PERSISTENT SET h-b1wgenprwd ( INPUT crapcrm.dssencar,
                                         OUTPUT aux_dsdpsrwd).

    DELETE PROCEDURE h-b1wgenprwd.

    IF  aux_dsdpsrwd > 0 THEN
        DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_getPinBlockCripto
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT STRING(crapcrm.nrcartao)
                                                ,INPUT STRING(aux_dsdpsrwd)
                                                ,"").
                                                
            CLOSE STORED-PROC pc_getPinBlockCripto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_nrsequen = pc_getPinBlockCripto.pSenhaCrypto
                                  WHEN pc_getPinBlockCripto.pSenhaCrypto <> ?.
                                  
            IF  TRIM(aux_nrsequen) <> "" THEN
                ASSIGN crapcrm.dssenpin = TRIM(aux_nrsequen).
        END.

    FIND CURRENT crapcrm NO-LOCK.

    RETURN "OK".

END PROCEDURE.
/* Fim altera_senha */








PROCEDURE efetua_configuracao:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     aux_contador    AS INT                      NO-UNDO.


    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    /* verifica se possui algum valor de saldo */
    DO  aux_contador = 1 TO 5:
        
        IF  craptfn.qtnotcas[aux_contador] <> 0  OR
            craptfn.vlnotcas[aux_contador] <> 0  OR
            craptfn.vltotcas[aux_contador] <> 0  THEN
            DO:
                par_dscritic = "TAA ja possui saldo.".
                RETURN "NOK".
            END.
    END.

    /* controle de versao do TAA */
    FIND craptab WHERE craptab.cdcooper = 3             AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "AUTOMA"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "DSVERTAA"    AND
                       craptab.tpregist = 1             NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            par_dscritic = "Versao Indisponivel".
            RETURN "NOK".
        END.

    

    /* Zera todos os valores de suprimento e envelopes */
    ASSIGN craptfn.nrdlacre = 0
           craptfn.qtnotcas = 0
           craptfn.vlnotcas = 0
           craptfn.vltotcas = 0
           craptfn.qtenvelo = 0
           craptfn.cdsitfin = 2 /* Fechado */
           craptfn.dsvertaa = craptab.dstextab
           craptfn.flupdate = NO.


    /* cria um registro de saldo */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcoptfn NO-LOCK NO-ERROR.


    DO  WHILE TRUE:
    
        FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND
                           crapstf.nrterfin = par_nrterfin  AND
                           crapstf.dtmvtolt = crapdat.dtmvtocd
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapstf  THEN
            DO:
                IF  LOCKED crapstf  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.

                CREATE crapstf.
                ASSIGN crapstf.cdcooper = par_cdcoptfn
                       crapstf.nrterfin = par_nrterfin
                       crapstf.dtmvtolt = crapdat.dtmvtocd.
                VALIDATE crapstf.
            END.

        LEAVE.
    END.


    ASSIGN crapstf.vldsdini = 0 
           crapstf.vldsdfin = 0.

    FIND CURRENT crapstf NO-LOCK.
    FIND CURRENT craptfn NO-LOCK.

    RETURN "OK".

END PROCEDURE.
/* Fim efetua_configuracao */





PROCEDURE verifica_transferencia:

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdagetra    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrtransf    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_vltransf    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_dttransf    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_tpoperac    AS INTEGER                  NO-UNDO.
    DEFINE  INPUT PARAM par_flagenda    AS LOGICAL                  NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtocd    AS DATE                     NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     aux_limtrans    AS DEC                      NO-UNDO.
    DEFINE VARIABLE     aux_flgretor    AS LOGICAL                  NO-UNDO.
    DEFINE VARIABLE     aux_flgctafa    AS LOGICAL                  NO-UNDO.
    DEFINE VARIABLE     aux_nmtitula    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_nmtitul2    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_cddbanco    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_vltarifa    AS DECI                     NO-UNDO.
    DEFINE VARIABLE     aux_cdhistor    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_cdhisest    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_cdfvlcop    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_vltransf    AS DEC                      NO-UNDO.
    DEFINE VARIABLE     aux_vltrsnot    AS DEC                      NO-UNDO.
    DEFINE VARIABLE     aux_dtdialim    AS DATE                     NO-UNDO.
    DEFINE VARIABLE     aux_idastcjt    AS INTEGER                  NO-UNDO.

    DEFINE VARIABLE     aux_cdcritic    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     h-b1wgen0019    AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE     h-b1wgen0015    AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE     h-b1crap22      AS HANDLE                   NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    EMPTY TEMP-TABLE tt-erro.

    /* Valida as contas envolvidas */
    /* Conta origem */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                       crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            par_dscritic = "Conta Origem Nao Existe".
            RETURN "NOK".
        END.

    IF  crapass.dtdemiss <> ?  THEN
        DO: 
            par_dscritic =  "Conta encerrada. Nao sera possivel efetuar" + 
                            " a transferencia.".
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

    RUN valida-conta-destino IN h-b1wgen0015
                             (INPUT par_cdcooper,
                              INPUT 91,    /* cdagenci */
                              INPUT 900,   /* nrdcaixa */
                              INPUT "996", /* cdoperad */
                              INPUT par_nrdconta,
                              INPUT 1,     /* idseqttl */
                              INPUT par_cdagetra,
                              INPUT par_nrtransf,
                              INPUT par_dtmvtocd,
                              INPUT par_tpoperac, 
                             OUTPUT TABLE tt-erro,
                             OUTPUT aux_flgctafa,
                             OUTPUT aux_nmtitula,
                             OUTPUT aux_nmtitul2,
                             OUTPUT aux_cddbanco).    

    DELETE PROCEDURE h-b1wgen0015.

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

    FIND crabcop WHERE crabcop.cdagectl = par_cdagetra NO-LOCK NO-ERROR.

    IF  NOT AVAIL crabcop  THEN
        DO:
            ASSIGN par_dscritic = "Agencia destino nao cadastrada.".
            RETURN "NOK".
        END.

    /* Nao permitir transf. intercooperativa para contas da Concredi 
       e Credimilsul, durante e apos a migracao */
    IF  par_tpoperac  = 5           AND
        aux_datdodia >= 11/29/2014  AND
       (crabcop.cdcooper = 4        OR 
        crabcop.cdcooper = 15)      THEN
        DO:
            FIND craptco WHERE craptco.cdcooper = crabcop.cdcooper AND
                               craptco.nrdconta = par_nrtransf     AND
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

    /* Regra para impedir transferencia intercooperativa para 
                contas Transulcred que serao migradas no dia 31/12/2016. */
    IF  par_tpoperac     = 5           AND
        crabcop.cdcooper = 17          AND /* Transulcred */
        aux_datdodia    >= 12/31/2016  THEN
        DO: 
            ASSIGN par_dscritic = "Conta destino nao habilitada " +
                                  "para receber valores da " +
                                  "transferencia.".
            RETURN "NOK".
        END.

    /* Regra para impedir transferencia intercooperativa para 
                contas Transulcred que serao migradas no dia 31/12/2016. */
    IF  par_tpoperac     = 5           AND
        crabcop.cdcooper = 17          AND /* Transulcred */
        aux_datdodia    >= 12/31/2016  THEN
        DO: 
            ASSIGN par_dscritic = "Conta destino nao habilitada " +
                                  "para receber valores da " +
                                  "transferencia.".
            RETURN "NOK".
        END.
       
    IF  par_flagenda THEN
        DO:
            RUN calcula_dia_util(INPUT  par_cdcooper,
                                 INPUT  par_dttransf,
                                 OUTPUT aux_flgretor).

            IF NOT aux_flgretor THEN
                DO:
                    ASSIGN par_dscritic = "Data do agendamento deve ser um dia util.".
                    RETURN "NOK".
                END.

            FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                               crapage.cdagenci = 91
                               NO-LOCK NO-ERROR.
                                               
            IF  NOT AVAILABLE crapage  THEN
                DO:
                    ASSIGN par_dscritic = "PA nao cadastrado.".
                    RETURN "NOK".
                END.

            ASSIGN aux_dtdialim = aux_datdodia + crapage.qtddaglf. 

            agenda:
            DO  WHILE TRUE:

                RUN calcula_dia_util (INPUT par_cdcooper,
                                      INPUT aux_dtdialim,
                                     OUTPUT aux_flgretor).
                
                IF  NOT aux_flgretor THEN
                    DO:
                        ASSIGN aux_dtdialim = aux_dtdialim - 1.
                        NEXT agenda.
                    END.

                LEAVE agenda.
            END.

            IF  par_dttransf > aux_dtdialim  THEN
                DO:                          
                    ASSIGN par_dscritic = "A data limite para efetuar" +
                                          " agendamentos e " +
                                          STRING(aux_dtdialim,"99/99/9999") +
                                          ".".
                    RETURN "NOK".                      
                END. 
        END.
        
    /* valor limite para transferencia */            
    FIND craptab WHERE craptab.cdcooper = par_cdcooper     AND 
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "AUTOMA"         AND
                       craptab.cdempres = 0                AND
                       craptab.cdacesso = "VLMXTRANSF"     AND
                       craptab.tpregist = 1 
                       NO-LOCK NO-ERROR.
        
    IF  AVAILABLE craptab  THEN
        ASSIGN aux_limtrans = DECIMAL(craptab.dstextab).
    ELSE
        ASSIGN aux_limtrans = 0.
                          
    IF  par_vltransf > aux_limtrans  THEN
        DO:
            par_dscritic = "Limite de Transf. Excedido".
            RETURN "NOK".
        END.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
    
    /* Procedure para verificar horario permitido para transacoes */        
    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* Cooperativa */
                                 INPUT par_nrdconta, /* Nr. da conta */
                                 INPUT 1,   /* Sequencia de titular */
                                 INPUT 4,   /* Origem - TAA */
                                 OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                 OUTPUT 0,  /* CPF do Rep. Legal */
                                 OUTPUT "", /* Nome do Rep. Legal */
                                 OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                 OUTPUT 0,  /* Codigo do erro */
                                 OUTPUT ""). /* Descricao do erro */
    
    CLOSE STORED-PROC pc_verifica_rep_assinatura
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_idastcjt = 0
           aux_cdcritic = 0
           aux_dscritic = ""           
           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                              WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                              WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                              WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
      
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
            
            ASSIGN par_dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    IF  NOT par_flagenda THEN
        DO:
            /* Se nao exige assinatura conjunta */
            IF  aux_idastcjt = 0 THEN
                DO:
            /* SALDOS */
            TRANS_SALDO:
            DO TRANSACTION ON ERROR UNDO, LEAVE:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        
                /* Utilizar o tipo de busca A, para carregar do dia anterior
                  (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
                RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT par_cdcooper,
                                             INPUT 1,     /* cdagenci */
                                             INPUT 999,   /* nrdcaixa */
                                             INPUT "996", /* cdoperad */
                                             INPUT par_nrdconta,
                                             INPUT par_dtmvtocd,
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
                IF NOT AVAILABLE wt_saldos THEN
                DO:
                    ASSIGN par_dscritic = "Saldo nao encontrado.".
                    RETURN "NOK".
                END.
            END. 
                END.

            /* LIMITE */
            RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h-b1wgen0019.
        
            RUN obtem-valor-limite IN h-b1wgen0019 (INPUT par_cdcooper,
                                                    INPUT 1,            /* PAC */
                                                    INPUT 999,          /* Caixa */
                                                    INPUT "996",        /* Operador */
                                                    INPUT "TAA",       /* Tela */
                                                    INPUT 4,            /* Origem - TAA */
                                                    INPUT par_nrdconta,
                                                    INPUT 1,            /* Titular */
                                                    INPUT TRUE,         /* Log */
                                                   OUTPUT TABLE tt-limite-credito,
                                                   OUTPUT TABLE tt-erro).
        
            DELETE PROCEDURE h-b1wgen0019.
        
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
            IF  AVAILABLE tt-erro  THEN
                DO:
                    par_dscritic = tt-erro.dscritic.
                    RETURN "NOK".
                END.
        
            FIND FIRST tt-limite-credito NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE tt-limite-credito  THEN
                DO:
                    par_dscritic = "Limite nao encontrado.".
                    RETURN "NOK".
                END.
        
            IF   par_tpoperac = 5   THEN /* InterCooperativa */
                 DO:
                     /* Obtem valor da tarifa */
                     RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                     RUN tarifa-transf-intercooperativa IN h-b1crap22 
                           (INPUT par_cdcooper,
                            INPUT 91,    /* cdagenci*/
                            INPUT par_nrdconta,
                            INPUT par_vltransf,
                           OUTPUT aux_vltarifa,
                           OUTPUT aux_cdhistor,
                           OUTPUT aux_cdhisest,
                           OUTPUT aux_cdfvlcop,
                           OUTPUT par_dscritic).
                    
                     DELETE PROCEDURE h-b1crap22.

                     IF  RETURN-VALUE <> "OK"  THEN
                         RETURN "NOK".
                 END.
            ELSE                         /* IntraCooperativa */
                 ASSIGN aux_vltarifa = 0.
            
            /* verifica se possui saldo suficiente */
            IF   ( par_vltransf + aux_vltarifa ) > 
                 ( wt_saldos.vlsddisp + tt-limite-credito.vllimcre )  THEN
                 DO:
                     par_dscritic = "Saldo insuficiente".
                     RETURN "NOK".
                 END.




            /**********
            
            Controle de HORARIO e LIMITE para acao antifraude 
            
            **********/

            ASSIGN aux_vltransf = par_vltransf
                   aux_vltrsnot = par_vltransf.

            /*Nos finais de semana, o valor do limite sera compartilhado
              entre saque/transferencia.
              Ex.: Se o limite eh R$ 1.000,00 e houve um saque de 
                   R$ 1.000,00 nao podera mais sacar nem transferir, no final
                   de semana.
                   Durante a semana continuara como esta, no exemplo, poderia
                   sacar R$ 1.000,00 e transferir mais R$ 1.000,00.*/
            IF CAN-DO("1,7",STRING(WEEKDAY(TODAY))) THEN
               DO:
                  /* saques */
                  FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                                         crapltr.nrdconta = par_nrdconta  AND
                                         crapltr.dttransa = par_dtmvtocd  AND
                                        (crapltr.cdhistor = 316 OR
                                         crapltr.cdhistor = 918)          
                                         NO-LOCK:

                      ASSIGN aux_vltransf = aux_vltransf + crapltr.vllanmto.

                      IF STRING(crapltr.hrtransa,"HH:MM") > "20:00" OR
                         STRING(crapltr.hrtransa,"HH:MM") < "06:00" THEN
                         ASSIGN aux_vltrsnot = aux_vltrsnot + crapltr.vllanmto.

                  END.
                  
                  /* estornos */
                  FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                                         crapltr.nrdconta = par_nrdconta  AND
                                         crapltr.dttransa > par_dtmvtocd  AND
                                        (crapltr.cdhistor = 767 OR
                                         crapltr.cdhistor = 920)          
                                         NO-LOCK:

                      ASSIGN aux_vltransf = aux_vltransf - crapltr.vllanmto.
                      
                      IF STRING(crapltr.hrtransa,"HH:MM") > "20:00" OR
                         STRING(crapltr.hrtransa,"HH:MM") < "06:00" THEN
                         ASSIGN aux_vltrsnot = aux_vltrsnot - crapltr.vllanmto.
                      
                  END.

               END.

            /* transferencias */
            FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                                   crapltr.nrdconta = par_nrdconta  AND
                                   crapltr.dttransa = par_dtmvtocd  AND
                                  (crapltr.cdhistor = 375 OR
                                   crapltr.cdhistor = 376 OR
                                   crapltr.cdhistor = 1009)         
                                   NO-LOCK:

                ASSIGN aux_vltransf = aux_vltransf + crapltr.vllanmto.

                IF STRING(crapltr.hrtransa,"HH:MM") > "20:00" OR
                   STRING(crapltr.hrtransa,"HH:MM") < "06:00" THEN
                   ASSIGN aux_vltrsnot = aux_vltrsnot + 
                                         crapltr.vllanmto.

            END.
            
            /* verifica o limite de saque */
            FIND tbtaa_limite_saque WHERE tbtaa_limite_saque.cdcooper = par_cdcooper  AND
                                          tbtaa_limite_saque.nrdconta = par_nrdconta                       
                                          NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL tbtaa_limite_saque THEN
                DO:
                    par_dscritic = "Nenhum Limite Cadastrado".
                    RETURN "NOK".
                END.
            
            IF  aux_vltransf > tbtaa_limite_saque.vllimite_saque  THEN
                DO:
                    par_dscritic = "Limite de Transferencia Excedido. " +
                                   "Limite maximo de: R$ " + STRING(tbtaa_limite_saque.vllimite_saque,"zz,zz9.99").
                    RETURN "NOK".
                END.
             
            /* saque noturno forcado */
            IF STRING(TIME,"HH:MM") > "20:00"  OR
               STRING(TIME,"HH:MM") < "06:00"  THEN
               DO:
                  IF aux_vltrsnot > 300  THEN
                     DO:
                        par_dscritic = "Limite de Transferencia Excedido. "   +
                                       "  Limite   para    movimentacao     " +
                                       "noturna:    R$ 300,00".
                        RETURN "NOK".
                     END.
               END.
            /* FIM - Controle de HORARIO e LIMITE para acao antifraude */


        END. /* Fim if par_flagenda */
    ELSE
        DO:
            /** Verificar se a conta pertence a um PAC migrado **/
            FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                               craptco.nrctaant = par_nrdconta AND
                               craptco.tpctatrf = 1            
                               NO-LOCK NO-ERROR.

            /** Bloquear agendamentos para conta migrada **/
            IF  AVAIL craptco               AND
                aux_datdodia >= 12/25/2013  AND
                craptco.cdcopant <> 4       AND  /* Exceto Concredi    */
                craptco.cdcopant <> 15      AND  /* Exceto Credimilsul */
                craptco.cdcopant <> 17      THEN /* Exceto Transulcred */                
                DO:
                    ASSIGN par_dscritic = "Operacao de agendamento bloqueada." +
                                          " Entre em contato com seu PA.".
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE.
/* Fim verifica transferencia */




PROCEDURE verifica_saque:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldsaque    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtocd    AS DATE                     NO-UNDO.
    DEFINE OUTPUT PARAM par_dssaqmax    AS CHAR                     NO-UNDO.
    DEFINE OUTPUT PARAM par_vlsddisp    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_vllimcre    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_flgcompr    AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    
    DEFINE VARIABLE     aux_dtlimite    AS DATE                     NO-UNDO.
    DEFINE VARIABLE     aux_vldsaque    AS DEC                      NO-UNDO.
    DEFINE VARIABLE     aux_vlsaqnot    AS DEC                      NO-UNDO.
    DEFINE VARIABLE     aux_vlsaqmax    AS DECIMAL                  NO-UNDO.

    DEFINE VARIABLE     aux_cdcritic    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     h-b1wgen0019    AS HANDLE                   NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.


    /* SALDOS */
    TRANS_SALDO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

        /* Utilizar o tipo de busca A, para carregar do dia anterior
          (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
        RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT par_cdcooper,
                                     INPUT 1,     /* cdagenci */
                                     INPUT 999,   /* nrdcaixa */
                                     INPUT "996", /* cdoperad */
                                     INPUT par_nrdconta,
                                     INPUT par_dtmvtocd,
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
        IF NOT AVAILABLE wt_saldos THEN
        DO:
            ASSIGN par_dscritic = "Saldo nao encontrado.".
            RETURN "NOK".
        END.
    END. 


    /* LIMITE */

    ASSIGN par_vlsddisp = wt_saldos.vlsddisp
           par_vllimcre = wt_saldos.vllimcre.

    /* verifica se possui saldo suficiente */
    IF  par_vldsaque > (wt_saldos.vlsddisp +
                        wt_saldos.vllimcre)  THEN
        DO:
            par_dscritic = "Saldo insuficiente".
            RETURN "NOK".
        END.

    /* verifica o limite de saque */
    FIND tbtaa_limite_saque WHERE tbtaa_limite_saque.cdcooper = par_cdcooper  AND
                                  tbtaa_limite_saque.nrdconta = par_nrdconta                       
                                  NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL tbtaa_limite_saque  THEN
        DO:
            par_dscritic = "Limite de saque nao cadastrado".
            RETURN "NOK".
        END.
        
    ASSIGN par_dssaqmax = "Limite "
           par_flgcompr = tbtaa_limite_saque.flgemissao_recibo_saque.    
           
    /* A validacao eh feita conforme a data de transacao (dttransa), 
       portanto, usa o TODAY como referencia */
    /* Diario */
    ASSIGN aux_dtlimite = TODAY - 1
           par_dssaqmax = par_dssaqmax + "Diario "               
           
           /* verifica se ja sacou o total permitido */
           aux_vldsaque = par_vldsaque
           aux_vlsaqnot = par_vldsaque.

    /*Nos finais de semana, o valor do limite sera compartilhado
      entre saque/transferencia.
      Ex.: Se o limite eh R$ 1.000,00 e houve um saque de 
           R$ 1.000,00 nao podera mais sacar nem transferir, no final
           de semana.
           Durante a semana continuara como esta, no exemplo, poderia
           sacar R$ 1.000,00 e transferir mais R$ 1.000,00.*/
    IF CAN-DO("1,7",STRING(WEEKDAY(TODAY))) THEN
       DO:
          /* transferencias */
          FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                                 crapltr.nrdconta = par_nrdconta  AND
                                 crapltr.dttransa = par_dtmvtocd  AND
                                (crapltr.cdhistor = 375 OR
                                 crapltr.cdhistor = 376 OR
                                 crapltr.cdhistor = 1009)         
                                 NO-LOCK:
          
              ASSIGN aux_vldsaque = aux_vldsaque + crapltr.vllanmto.

              IF (STRING(crapltr.hrtransa,"HH:MM") > "20:00"   OR
                  STRING(crapltr.hrtransa,"HH:MM") < "06:00" ) THEN
                  ASSIGN aux_vlsaqnot = aux_vlsaqnot + crapltr.vllanmto.
          
          END.

       END.

    /* saques */
    FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                           crapltr.nrdconta = par_nrdconta  AND                           
                           crapltr.dttransa > aux_dtlimite  AND
                          (crapltr.cdhistor = 316 OR
                           crapltr.cdhistor = 918)          
                           NO-LOCK:

        ASSIGN aux_vldsaque = aux_vldsaque + crapltr.vllanmto.

        /* Se for dia nao util, nao verificar o ltr.dttransa */
        IF  CAN-DO("1,7",STRING(WEEKDAY(crapltr.dttransa)))   OR 
            CAN-FIND(crapfer WHERE 
                     crapfer.cdcooper = par_cdcooper          AND
                     crapfer.dtferiad = crapltr.dttransa)     THEN
            DO:
                IF   (STRING(crapltr.hrtransa,"HH:MM") > "20:00"     OR
                      STRING(crapltr.hrtransa,"HH:MM") < "06:00" )   THEN
                     ASSIGN aux_vlsaqnot = aux_vlsaqnot + crapltr.vllanmto.
            END.
        ELSE
            DO:
                IF   crapltr.dttransa = par_dtmvtocd               AND
                     (STRING(crapltr.hrtransa,"HH:MM") > "20:00"   OR
                      STRING(crapltr.hrtransa,"HH:MM") < "06:00" ) THEN
                     ASSIGN aux_vlsaqnot = aux_vlsaqnot + crapltr.vllanmto.
           END.

    END.
    
    /* estornos */
    FOR EACH crapltr WHERE crapltr.cdcooper = par_cdcooper  AND 
                           crapltr.nrdconta = par_nrdconta  AND                           
                           crapltr.dttransa > aux_dtlimite  AND
                          (crapltr.cdhistor = 767 OR
                           crapltr.cdhistor = 920)          
                           NO-LOCK:

        ASSIGN aux_vldsaque = aux_vldsaque - crapltr.vllanmto.

        /* Se for dia nao util, nao verificar o ltr.dttransa */
        IF   CAN-DO("1,7",STRING(WEEKDAY(crapltr.dttransa))) OR
             CAN-FIND(crapfer WHERE 
                      crapfer.cdcooper = par_cdcooper        AND
                      crapfer.dtferiad = crapltr.dttransa)   THEN 
            DO:
               IF   (STRING(crapltr.hrtransa,"HH:MM") > "20:00"   OR
                     STRING(crapltr.hrtransa,"HH:MM") < "06:00" ) THEN
                     ASSIGN aux_vlsaqnot = aux_vlsaqnot - crapltr.vllanmto.
            END.
        ELSE
            DO:
                 IF   crapltr.dttransa = par_dtmvtocd                AND 
                     (STRING(crapltr.hrtransa,"HH:MM") > "20:00"     OR
                      STRING(crapltr.hrtransa,"HH:MM") < "06:00" )   THEN
                      ASSIGN aux_vlsaqnot = aux_vlsaqnot - crapltr.vllanmto.    
            END.
              
    END.
    
    IF  aux_vldsaque > tbtaa_limite_saque.vllimite_saque  THEN
        DO:
            par_dssaqmax = par_dssaqmax + "de R$ " + TRIM(STRING(tbtaa_limite_saque.vllimite_saque,"zz,zz9.99")).
            par_dscritic = "Limite de Saque Excedido".
            RETURN "NOK".
        END.    

    /* controle de limite de saque por maquina - especifico */
    FIND craptab WHERE craptab.cdcooper = par_cdcoptfn  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "SAQMAXCASH"  AND
                       craptab.tpregist = par_nrterfin
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        /* controle de limite de saque por maquina - geral */
        FIND craptab WHERE craptab.cdcooper = par_cdcoptfn  AND
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "GENERI"      AND
                           craptab.cdempres = 0             AND
                           craptab.cdacesso = "SAQMAXCASH"  AND
                           craptab.tpregist = 0
                           NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        aux_vlsaqmax = 100.
    ELSE
        aux_vlsaqmax = DECIMAL(craptab.dstextab).

        
    IF  par_vldsaque > aux_vlsaqmax  THEN
        DO:
            par_dssaqmax = "Limite por transacao: R$ " + TRIM(STRING(aux_vlsaqmax,"zz,zz9.99")).
            par_dscritic = "Limite de Saque Excedido".
            RETURN "NOK".
        END.

    /**********
            
    Controle de HORARIO e LIMITE para acao antifraude 
            
    **********/

    IF  STRING(TIME,"HH:MM") > "20:00"  OR
        STRING(TIME,"HH:MM") < "06:00"  THEN
        DO:
            IF  aux_vlsaqnot > 500  THEN
                DO:
                    par_dssaqmax = "Para sua seguranca, apos 20h, o limite de saque e de R$ 500,00".
                    par_dscritic = "Limite saque noturno excedido. " + par_dssaqmax.
                    RETURN "NOK".
                END.
        END.


    RETURN "OK".

END PROCEDURE.
/* Fim verifica_saque */



PROCEDURE efetua_saque:

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldsaque    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtocd    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_nrsequni    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_hrtransa    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdagetfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.


    DEFINE VARIABLE     aux_cdbccxlt    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_nrdolote    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_dssaqmax    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_flgcompr    AS LOGICAL                  NO-UNDO.
    DEFINE VARIABLE     aux_cdhisdeb    AS INT                      NO-UNDO.
    DEFINE VARIABLE     h-b1craplot     AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE     h-b1craplcm     AS HANDLE                   NO-UNDO.

    /* Para monitoracao, e-mails */
    DEFINE VARIABLE     aux_dsdemail    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_dsassunt    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_dsdcorpo    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_vlsddisp    AS DECI                     NO-UNDO.
    DEFINE VARIABLE     aux_vllimcre    AS DECI                     NO-UNDO.
    DEFINE VARIABLE     aux_cdcritic    AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_dscritic    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     h-b1wgen0011    AS HANDLE                   NO-UNDO.

	DEFINE VARIABLE     aux_dscampos    AS CHAR                     NO-UNDO.

    DEFINE BUFFER crabass FOR crapass.


    /* Saque conforme a cooperativa */
    IF  par_cdcoptfn = par_cdcooper  THEN
        aux_cdhisdeb = 316.  /* Saque Coop */
    ELSE
        aux_cdhisdeb = 918.  /* Saque Multicoop */

    /* para evitar saque simultaneo em mais de uma maquina, verifica
       novamente o saque */
    RUN verifica_saque ( INPUT par_cdcoptfn,
                         INPUT par_nrterfin,
                         INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT par_nrcartao,
                         INPUT par_vldsaque,
                         INPUT par_dtmvtocd,
                        OUTPUT aux_dssaqmax,
                        OUTPUT aux_vlsddisp,
                        OUTPUT aux_vllimcre,
                        OUTPUT aux_flgcompr,
                        OUTPUT par_dscritic).

    IF  RETURN-VALUE  = "NOK"  OR
        par_dscritic <> ""     THEN
        RETURN "NOK".



    ASSIGN aux_cdbccxlt = 100
           aux_nrdolote = 320000 + par_nrterfin.

    DO  WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
        FIND craplot WHERE craplot.cdcooper = par_cdcooper  AND 
                           craplot.dtmvtolt = par_dtmvtocd  AND
                           craplot.cdagenci = par_cdagetfn  AND
                           craplot.cdbccxlt = aux_cdbccxlt  AND
                           craplot.nrdolote = aux_nrdolote
                           USE-INDEX craplot1 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAILABLE craplot  THEN
            IF  LOCKED craplot  THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                    EMPTY TEMP-TABLE cratlot.
        
                    CREATE cratlot.
                    ASSIGN cratlot.cdcooper = par_cdcooper
                           cratlot.dtmvtolt = par_dtmvtocd
                           cratlot.cdagenci = par_cdagetfn
                           cratlot.cdbccxlt = aux_cdbccxlt
                           cratlot.nrdolote = aux_nrdolote
                           cratlot.tplotmov = 1.
                    VALIDATE cratlot.
                     
                    RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.
                   
                    IF  VALID-HANDLE(h-b1craplot)  THEN
                        DO:
                            RUN inclui-registro IN h-b1craplot ( INPUT TABLE cratlot,
                                                                OUTPUT par_dscritic).
                        
                            DELETE PROCEDURE h-b1craplot.
                    
                            IF   RETURN-VALUE = "NOK"   THEN
                                 DO:
                                      par_dscritic = "Problemas ao criar o lote".
                                      UNDO, RETURN "NOK".
                                 END.
                        END.
                
                     NEXT. /* Para pegar o novo registro do lote */
                END.
        
        EMPTY TEMP-TABLE cratlot.
        BUFFER-COPY craplot TO cratlot.
    
        /* Atualiza o lote na TEMP-TABLE */
        ASSIGN cratlot.qtinfoln = cratlot.qtinfoln + 1
               cratlot.qtcompln = cratlot.qtcompln + 1
               cratlot.nrseqdig = cratlot.nrseqdig + 1
               cratlot.vlinfodb = cratlot.vlinfodb + par_vldsaque
               cratlot.vlcompdb = cratlot.vlcompdb + par_vldsaque.
    
        EMPTY TEMP-TABLE cratlcm.
        CREATE cratlcm.
        ASSIGN cratlcm.cdcooper = par_cdcooper
               cratlcm.dtmvtolt = par_dtmvtocd
               cratlcm.cdagenci = par_cdagetfn
               cratlcm.cdbccxlt = aux_cdbccxlt
               cratlcm.nrdolote = aux_nrdolote
               cratlcm.dtrefere = par_dtmvtocd
               cratlcm.hrtransa = par_hrtransa
               cratlcm.cdoperad = ""
               cratlcm.nrdconta = par_nrdconta
               cratlcm.nrdctabb = par_nrdconta
               cratlcm.nrdctitg = STRING(par_nrdconta,"99999999")
               cratlcm.nrdocmto = par_hrtransa
               cratlcm.nrautdoc = par_nrsequni
               cratlcm.nrsequni = par_nrsequni
               /* Dados do TAA */
               cratlcm.cdcoptfn = par_cdcoptfn
               cratlcm.cdagetfn = par_cdagetfn
               cratlcm.nrterfin = par_nrterfin
               cratlcm.cdpesqbb = 'CASH DISPENSER ' + STRING(par_nrterfin,"9999")
               cratlcm.cdhistor = aux_cdhisdeb /* SAQUE CARTAO */
               cratlcm.vllanmto = par_vldsaque
               cratlcm.nrseqdig = cratlot.nrseqdig.
               
                                               
        RUN sistema/generico/procedures/b1craplcm.p PERSISTENT SET h-b1craplcm.
               
        IF  VALID-HANDLE(h-b1craplcm)   THEN
            DO:
                RUN inclui-registro IN h-b1craplcm ( INPUT TABLE cratlcm,
                                                    OUTPUT par_dscritic).
                                               
                DELETE PROCEDURE h-b1craplcm.
            
                IF   RETURN-VALUE = "NOK"   THEN
                     DO:
                         IF par_dscritic <> ? OR par_dscritic <> "" THEN
                             par_dscritic = "Problemas ao criar lancamento - " + par_dscritic.
                         ELSE
                             par_dscritic = "Problemas ao criar lancamento".
                             
                         UNDO, RETURN "NOK".
                     END.
            END.

       /* inicio NOTIF */
       
        aux_dscampos = "#valorsaque=" + STRING(par_vldsaque,"zzz,zz9.99") + ";#datasaque=" + STRING(TODAY,"99/99/9999").
        
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_cria_notif_prgs
        aux_handproc = PROC-HANDLE NO-ERROR 
            ( INPUT 9                 /* pr_cdorigem_mensagem  */
             ,INPUT 2                 /* pr_cdmotivo_mensagem  */
             ,INPUT TODAY             /* pr_dhenvio  */
             ,INPUT par_cdcooper      /* pr_cdcooper  */
             ,INPUT par_nrdconta      /* pr_nrdconta  */
             ,INPUT 0                 /* pr_idseqttl  */
             ,INPUT aux_dscampos ).   /* pr_variaveis  */
                                    
        /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_cria_notif_prgs
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                           
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        /* fim NOTIF */   
                                                    
        /* Atualiza o registro do lote */
        RUN sistema/generico/procedures/b1craplot.p
            PERSISTENT SET h-b1craplot.
                        
        IF   VALID-HANDLE(h-b1craplot)   THEN
             DO:
                 RUN altera-registro IN h-b1craplot (INPUT  TABLE cratlot,
                                                    OUTPUT  par_dscritic).
                             
                 DELETE PROCEDURE h-b1craplot.
        
                 IF   RETURN-VALUE = "NOK"   THEN
                      DO:
                          par_dscritic = "Problemas ao atualizar lote".
                          UNDO, RETURN "NOK".
                      END.
             END.
                    
        
        /*  Log da transacao no servidor  */
        CREATE crapltr.
        ASSIGN crapltr.cdcooper = par_cdcooper /* Coop do Associado */
               crapltr.cdcoptfn = par_cdcoptfn /* Coop do TAA */
               crapltr.cdoperad = ""
               crapltr.nrterfin = par_nrterfin
               crapltr.dtmvtolt = par_dtmvtocd
               crapltr.nrautdoc = par_nrsequni
               crapltr.nrdconta = par_nrdconta
               crapltr.nrdocmto = cratlcm.nrdocmto
               crapltr.nrsequni = par_nrsequni
               crapltr.cdhistor = cratlcm.cdhistor
               crapltr.vllanmto = par_vldsaque
               crapltr.dttransa = TODAY
               crapltr.hrtransa = cratlcm.hrtransa
               crapltr.nrcartao = par_nrcartao
               crapltr.tpautdoc = 1
               crapltr.nrestdoc = 0
               crapltr.cdsuperv = ''.
        VALIDATE crapltr.
                           
        
        
        /* saldo do terminal no ayllos */
        DO  WHILE TRUE:
                     
            FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND 
                               crapstf.dtmvtolt = par_dtmvtocd  AND
                               crapstf.nrterfin = par_nrterfin
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                                
                IF  NOT AVAILABLE crapstf  THEN
                    IF  LOCKED crapstf  THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            par_dscritic = "Problemas ao atualizar TAA".
                            UNDO, RETURN "NOK".
                         END.
                                                           
                LEAVE.
        END.  /* Fim do WHILE */
 

        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT aux_cdhisdeb).

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                par_dscritic = "TAA indisponivel.".
                UNDO, RETURN "NOK".
            END.


        ASSIGN crapstd.vldmovto = crapstd.vldmovto + par_vldsaque
               crapstf.vldsdfin = crapstf.vldsdfin - par_vldsaque.
                   
        FIND CURRENT crapstf NO-LOCK.
        FIND CURRENT crapstd NO-LOCK.

        VALIDATE crapstf.

        LEAVE.
    END.  /*  Fim DO WHILE..  */
    
    /*VERIFICACAO TARIFAS DE SAQUE*/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* Código da Cooperativa */
                                 INPUT "1",          /* Código do Operador */
                                 INPUT 1,            /* Codigo Agencia */
                                 INPUT 100,          /* Codigo banco caixa */
                                 INPUT par_dtmvtocd, /* Data de Movimento */
                                 INPUT "TAA",        /* Nome da Tela */
                                 INPUT 4,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */   
                                 INPUT par_nrdconta, /* Numero da Conta */
                                 INPUT 1,            /* Tipo de Tarifa(1-Saque,2-Consulta) */
                                 INPUT 0,            /* Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus) */
                                 INPUT 0,            /* Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque) */
								 INPUT cratlcm.nrdocmto, /* numero documento - adicionado por Valeria Supero outubro 2018 */ 
								 INPUT par_hrtransa, /* hora de realização da operação -adicionado por Valeria Supero */  
                                 OUTPUT 0,           /* Quantidade de registros a cobrar tarifa na operação */
                                 OUTPUT 0,           /* Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta */
                                OUTPUT 0,            /* Código da crítica */
                                OUTPUT "").          /* Descrição da crítica */
    
    CLOSE STORED-PROC pc_verifica_tarifa_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_verifica_tarifa_operacao.pr_cdcritic 
                         WHEN pc_verifica_tarifa_operacao.pr_cdcritic <> ?
         aux_dscritic = pc_verifica_tarifa_operacao.pr_dscritic
                         WHEN pc_verifica_tarifa_operacao.pr_dscritic <> ?.
    
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
    
         
         RUN cria-erro (INPUT par_cdcooper,
                        INPUT 1,
                        INPUT 1,
                        INPUT aux_cdcritic,
                        INPUT aux_dscritic,
                        INPUT YES).
         RETURN "NOK".
                        
     END.
    /*FIM VERIFICACAO TARIFAS DE SAQUE*/

    /* E-mail de monitoracao para saques no valor do limite de saque do cartao - Somente em algumas */
    IF  CAN-DO("1,2,4,6,5,7,8,10,9,11,12,13,16",STRING(par_cdcooper))   THEN
        DO:
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                               NO-LOCK NO-ERROR.

            FIND tbtaa_limite_saque WHERE tbtaa_limite_saque.cdcooper = par_cdcooper  AND
                                          tbtaa_limite_saque.nrdconta = par_nrdconta                       
                                          NO-LOCK NO-ERROR.
            
            IF  AVAIL tbtaa_limite_saque THEN
                DO:
                    /* Verifica se o saque eh o limite da conta e se o valor */
                    /* do saque eh >= ao valor minimo para monitoracao */
                    IF  ((crapcop.insaqlim = 1   AND 
                         (tbtaa_limite_saque.vllimite_saque = par_vldsaque))  OR
                          crapcop.insaqlim = 0)  AND
                        par_vldsaque     >= crapcop.vlsaqind  THEN
                        DO:
                            FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn AND
                                               craptfn.nrterfin = par_nrterfin NO-LOCK NO-ERROR.

                            FIND crapage WHERE crapage.cdcooper = craptfn.cdcooper AND
                                               crapage.cdagenci = craptfn.cdagenci NO-LOCK NO-ERROR.
                            
                            FIND crapass WHERE crapass.cdcooper = tbtaa_limite_saque.cdcooper AND
                                               crapass.nrdconta = tbtaa_limite_saque.nrdconta 
                                               NO-LOCK NO-ERROR.
                            
                            ASSIGN aux_dsassunt = crapcop.nmrescop + " - Saque" + " - PA " + STRING(craptfn.cdagenci) +
                                                  " - " + crapage.nmcidade + " - " + STRING(craptfn.nrterfin) + " - " +
                                                  craptfn.nmterfin

                                   aux_dsdemail = "prevencaodefraudes@ailos.coop.br"
                                   
                                   aux_dsdcorpo = "PA: " + STRING(craptfn.cdagenci) + " - " + crapage.nmresage + "\n\n" + 
                                                  "Conta: " + STRING(par_nrdconta) + "\n".

                            IF  crapass.inpessoa = 1  THEN
                                DO:
                                    /* pega todos os titulares */
                                    FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper  AND
                                                           crapttl.nrdconta = crapass.nrdconta  NO-LOCK:
                            
                                        aux_dsdcorpo = aux_dsdcorpo +
                                                       "Titular " + STRING(crapttl.idseqttl) + ": " +
                                                       crapttl.nmextttl + "\n".
                                    END.
                                END.
                            ELSE
                                DO:
                                    /* pega o nome da empresa e os procuradores/representantes */
                                    FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper  AND
                                                       crapjur.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.
                                    
                                    aux_dsdcorpo = aux_dsdcorpo +
                                                   "Empresa: " + crapjur.nmextttl + "\n\n" +
                                                   "Procuradores/Representantes: " + "\n".
                            
                                    FOR EACH crapavt WHERE crapavt.cdcooper = crapass.cdcooper     AND
                                                           crapavt.tpctrato = 6 /* procurador */   AND
                                                           crapavt.nrdconta = crapass.nrdconta     NO-LOCK:
                            
                                        IF  crapavt.nrdctato <> 0  THEN
                                            DO:
                                                FIND crabass WHERE crabass.cdcooper = crapavt.cdcooper AND
                                                                   crabass.nrdconta = crapavt.nrdctato NO-LOCK.
                                                
                                                aux_dsdcorpo = aux_dsdcorpo +
                                                               crabass.nmprimtl + "\n".
                                            END.
                                        ELSE
                                            aux_dsdcorpo = aux_dsdcorpo +
                                                           crapavt.nmdavali + "\n".
                                    END.
                                END.
                            
                            aux_dsdcorpo = aux_dsdcorpo + "\nFones:\n".
                            
                            FOR EACH craptfc WHERE craptfc.cdcooper = tbtaa_limite_saque.cdcooper  AND
                                                   craptfc.nrdconta = tbtaa_limite_saque.nrdconta  NO-LOCK:
                            
                                aux_dsdcorpo = aux_dsdcorpo + 
                                               "(" + STRING(craptfc.nrdddtfc) + ") " + STRING(craptfc.nrtelefo) + "\n".
                            END.

                            aux_dsdcorpo = aux_dsdcorpo + "\nValor do Saque: R$ " + STRING(par_vldsaque,"zzz,zz9.99").
                            
                            /* E-mail de monitoracao para saques no valor
                               do limite de saque do cartao  */
                            RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET h-b1wgen0011.

                            RUN enviar_email_completo IN h-b1wgen0011
                                  (INPUT par_cdcooper,
                                   INPUT "b1wgen0025",
                                   INPUT "prevencaodefraudes@ailos.coop.br",
                                   INPUT aux_dsdemail,
                                   INPUT aux_dsassunt,
                                   INPUT "",
                                   INPUT "",
                                   INPUT aux_dsdcorpo, 
                                   INPUT FALSE).

                            DELETE PROCEDURE h-b1wgen0011.

                        END.
                END.
        END.

    /* GERAÇÃO DE LOG  */   
    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper   AND
                       crapcrm.nrdconta = par_nrdconta   AND
                       crapcrm.nrcartao = par_nrcartao
                       NO-LOCK NO-ERROR NO-WAIT.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gera_log_ope_cartao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,     /* Código da Cooperativa */
                                 INPUT par_nrdconta,     /* Numero da Conta */ 
                                 INPUT 1,                /* Saque */
                                 INPUT 4,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */ 
                                 INPUT IF AVAIL crapcrm THEN 1 ELSE 2,
                                 INPUT par_hrtransa,     /* Nrd Documento */               
                                 INPUT aux_cdhisdeb,     /* SAQUE CARTAO */
                                 INPUT STRING(par_nrcartao),
                                 INPUT par_vldsaque,
                                 INPUT "1",                /* Código do Operador */
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT par_cdagetfn,
                                 INPUT 0,
                                 INPUT "",
                                 INPUT 0,
                                OUTPUT "").              /* Descriçao da crítica */

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
            par_dscritic = aux_dscritic.
            UNDO, RETURN "NOK".       
        END.

    RETURN "OK".     
         
END PROCEDURE.
/* Fim efetua_saque */



PROCEDURE confere_saque:
    
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdagetfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_nrsequni    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_vldsaque    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    /* para o estorno */
    DEFINE VARIABLE     aux_nrsequni    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_cdhisdeb    AS INT                      NO-UNDO.
    DEFINE VARIABLE     aux_cdhiscre    AS INT                      NO-UNDO.
    DEFINE VARIABLE     h-b1craplot     AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE     h-b1craplcm     AS HANDLE                   NO-UNDO.
    
    DEFINE BUFFER crablcm FOR craplcm.


    /* Verifica historicos conforme a operacao */
    /* Saque Coop */
    IF  par_cdcoptfn = par_cdcooper  THEN
        ASSIGN aux_cdhisdeb = 316   /* Saque   */
               aux_cdhiscre = 767.  /* Estorno */
    ELSE
    /* Saque Multicoop */
        ASSIGN aux_cdhisdeb = 918   /* Saque */
               aux_cdhiscre = 920.  /* Estorno */


    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    /* verifica se a transacao ocorreu em dia util, caso contrario, busca
       o proximo dia util */
    DO  WHILE TRUE:

        IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtmvtolt))) OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                   crapfer.dtferiad = par_dtmvtolt)  THEN
            DO:
                par_dtmvtolt = par_dtmvtolt + 1.
                NEXT.
            END.

        LEAVE.
    END.


    /* verifica se o debito ja foi efetuado */
    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper  AND
                       craplcm.nrdconta = par_nrdconta  AND
                       craplcm.dtmvtolt = par_dtmvtolt  AND
                       /* Saque Cartao */
                       craplcm.cdhistor = aux_cdhisdeb  AND
                       craplcm.nrsequni = par_nrsequni  AND
                       craplcm.vllanmto = par_vldsaque
                       NO-LOCK NO-ERROR.

    /* se nao criou o debito, tudo OK */
    IF  NOT AVAILABLE craplcm  THEN
        RETURN "OK".


    /* verifica se o estorno ja foi efetuado na mesma data */
    FIND crablcm WHERE crablcm.cdcooper = par_cdcooper  AND
                       crablcm.nrdconta = par_nrdconta  AND
                       crablcm.dtmvtolt = par_dtmvtolt  AND
                       /* Estorno de Saque */
                       crablcm.cdhistor = aux_cdhiscre  AND
                       crablcm.nrsequni = par_nrsequni  AND
                       crablcm.vllanmto = par_vldsaque  AND
                       /* NSU do saque */
                       INT(SUBSTRING(crablcm.cdpesqbb,57,5)) = par_nrsequni
                       NO-LOCK NO-ERROR.


    /* se ja criou o estorno, tudo OK */
    IF  AVAILABLE crablcm  THEN
        RETURN "OK".



    /* verifica se o estorno foi no dia util corrente, casos onde a maquina
       foi desligada e subiu em outra data */
    FIND crablcm WHERE crablcm.cdcooper = par_cdcooper      AND
                       crablcm.nrdconta = par_nrdconta      AND
                       crablcm.dtmvtolt = crapdat.dtmvtocd  AND
                       /* Estorno de Saque */
                       crablcm.cdhistor = aux_cdhiscre      AND
                       crablcm.nrsequni = par_nrsequni      AND
                       crablcm.vllanmto = par_vldsaque      AND
                       /* NSU do saque */
                       INT(SUBSTRING(crablcm.cdpesqbb,57,5)) = par_nrsequni
                       NO-LOCK NO-ERROR.


    /* se ja criou o estorno, tudo OK */
    IF  AVAILABLE crablcm  THEN
        RETURN "OK".


    /* pega um novo NSU para o estorno */
    RUN obtem_nsu ( INPUT craplcm.cdcooper, /* Cooperativa */
                   OUTPUT aux_nrsequni,
                   OUTPUT par_dscritic).

    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* cria o estorno */
    DO  WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN "NOK":

        /* utiliza o mesmo lote do debito, porem com data DTMVTOCD */
        FIND craplot WHERE craplot.cdcooper = craplcm.cdcooper  AND 
                           craplot.dtmvtolt = crapdat.dtmvtocd  AND
                           craplot.cdagenci = craplcm.cdagenci  AND
                           craplot.cdbccxlt = craplcm.cdbccxlt  AND
                           craplot.nrdolote = craplcm.nrdolote
                           USE-INDEX craplot1 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craplot  THEN
            IF  LOCKED craplot  THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                    /* Cria o lote */
                    EMPTY TEMP-TABLE cratlot.
    
                    CREATE cratlot.
                    ASSIGN cratlot.cdcooper = craplcm.cdcooper
                           cratlot.dtmvtolt = crapdat.dtmvtocd
                           cratlot.cdagenci = craplcm.cdagenci
                           cratlot.cdbccxlt = craplcm.cdbccxlt
                           cratlot.nrdolote = craplcm.nrdolote
                           cratlot.tplotmov = 1.
    
                    RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.
    
                    IF  VALID-HANDLE(h-b1craplot)  THEN
                        DO:
                            RUN inclui-registro IN h-b1craplot ( INPUT TABLE cratlot,
                                                                OUTPUT par_dscritic).
    
                            DELETE PROCEDURE h-b1craplot.
    
                            IF   RETURN-VALUE = "NOK"   THEN
                                 DO:
                                      par_dscritic = "Problemas ao criar o lote".
                                      UNDO, RETURN "NOK".
                                 END.
                        END.
    
                     NEXT. /* Para pegar o novo registro do lote */
                END.


        EMPTY TEMP-TABLE cratlot.
        BUFFER-COPY craplot TO cratlot.

        /* Atualiza o lote na TEMP-TABLE */
        ASSIGN cratlot.qtinfoln = cratlot.qtinfoln + 1
               cratlot.qtcompln = cratlot.qtcompln + 1
               cratlot.nrseqdig = cratlot.nrseqdig + 1
               cratlot.vlinfocr = cratlot.vlinfocr + par_vldsaque
               cratlot.vlcompcr = cratlot.vlcompcr + par_vldsaque.

        
        /* Procura se existe um registro de saque da mesma data, horario, conta
           numero de lote e documento. Caso exista espera 1 segundo. */
        DO  WHILE TRUE:
            
            FIND crablcm WHERE crablcm.cdcooper = craplot.cdcooper  AND
                               crablcm.dtmvtolt = craplot.dtmvtolt  AND
                               crablcm.cdagenci = craplot.cdagenci  AND
                               crablcm.cdbccxlt = craplot.cdbccxlt  AND
                               crablcm.nrdolote = craplot.nrdolote  AND
                               crablcm.nrdctabb = craplcm.nrdconta  AND
                               crablcm.nrdocmto = TIME
                               NO-LOCK NO-ERROR.

            IF  AVAILABLE crablcm  THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            
            LEAVE.
        END.
        

        EMPTY TEMP-TABLE cratlcm.
        CREATE cratlcm.
        ASSIGN cratlcm.cdcooper = craplot.cdcooper
               cratlcm.dtmvtolt = craplot.dtmvtolt
               cratlcm.cdagenci = craplot.cdagenci
               cratlcm.cdbccxlt = craplot.cdbccxlt
               cratlcm.nrdolote = craplot.nrdolote
               cratlcm.dtrefere = craplcm.dtrefere
               cratlcm.hrtransa = TIME
               cratlcm.cdoperad = ""
               cratlcm.nrdconta = craplcm.nrdconta
               cratlcm.nrdctabb = craplcm.nrdconta
               cratlcm.nrdctitg = STRING(craplcm.nrdconta,"99999999")
               cratlcm.nrdocmto = TIME
               cratlcm.nrautdoc = aux_nrsequni  /* Novo NSU */
               cratlcm.nrsequni = aux_nrsequni
               cratlcm.cdhistor = aux_cdhiscre /* ESTORNO SAQUE */
               cratlcm.vllanmto = craplcm.vllanmto
               cratlcm.nrseqdig = cratlot.nrseqdig

               /* guarda a NSU do saque que foi estornado */
               cratlcm.cdpesqbb = 'CASH DISPENSER ' +
                                  SUBSTRING(craplcm.cdpesqbb,16,4) +
                                  "-CARTAO " + STRING(par_nrcartao) +
                                  "-ESTORNO NSU " + STRING(craplcm.nrsequni,"99999")

               /* Dados do TAA */
               cratlcm.cdcoptfn = par_cdcoptfn
               cratlcm.cdagetfn = par_cdagetfn
               cratlcm.nrterfin = par_nrterfin.


        RUN sistema/generico/procedures/b1craplcm.p PERSISTENT SET h-b1craplcm.
		/*chamar rotina oracle para estorno da tarifa correspondente ao estorno o saque, quando houver */
		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                     
                    /* Efetuar a chamada a rotina Oracle  */
                    		RUN STORED-PROCEDURE pc_estorno_tarifa_saque  aux_handproc = PROC-HANDLE NO-ERROR
								(INPUT 	craplcm.cdcooper,    /*Código da Cooperativa */
						 INPUT 1,		 			 /*Agencia*/
						 INPUT 1, 		 			 /*Caixa*/
						 INPUT '1',		 			 /*Operador*/
						 INPUT crapdat.dtmvtocd,	 /* Data Movimento */
						 INPUT "TAA",		     	 /* Nomte da Tela */
						 INPUT 1,					 /* Caixa online */
						 INPUT craplcm.nrdconta, 	 /* Numero da Conta */
						 INPUT craplcm.nrdocmto,    /* Numero do documento */
								 OUTPUT 0,
								 OUTPUT "").
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_estorno_tarifa_saque
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

        IF  VALID-HANDLE(h-b1craplcm)   THEN
            DO:
                RUN inclui-registro IN h-b1craplcm ( INPUT TABLE cratlcm,
                                                    OUTPUT par_dscritic).

                DELETE PROCEDURE h-b1craplcm.

                IF   RETURN-VALUE = "NOK"   THEN
                     DO:
                         par_dscritic = "Problemas ao criar lançamento".
                         UNDO, RETURN "NOK".
                     END.
            END.

        /* Atualiza o registro do lote */
        RUN sistema/generico/procedures/b1craplot.p
            PERSISTENT SET h-b1craplot.

        IF   VALID-HANDLE(h-b1craplot)   THEN
             DO:
                 RUN altera-registro IN h-b1craplot (INPUT  TABLE cratlot,
                                                    OUTPUT  par_dscritic).

                 DELETE PROCEDURE h-b1craplot.

                 IF   RETURN-VALUE = "NOK"   THEN
                      DO:
                          par_dscritic = "Problemas ao atualizar lote".
                          UNDO, RETURN "NOK".
                      END.
             END.



        /*  Log da transacao no servidor  */
        CREATE crapltr.
        ASSIGN crapltr.cdcooper = par_cdcooper /* Coop do Associado */
               crapltr.cdcoptfn = par_cdcoptfn /* Coop do TAA */
               crapltr.cdoperad = ""
               crapltr.nrterfin = par_nrterfin
               crapltr.dtmvtolt = par_dtmvtolt
               crapltr.nrautdoc = craplcm.nrsequni
               crapltr.nrdconta = par_nrdconta
               crapltr.nrdocmto = cratlcm.nrdocmto
               crapltr.nrsequni = cratlcm.nrsequni
               crapltr.cdhistor = cratlcm.cdhistor
               crapltr.vllanmto = par_vldsaque
               crapltr.dttransa = TODAY
               crapltr.hrtransa = cratlcm.hrtransa
               crapltr.nrcartao = par_nrcartao
               crapltr.tpautdoc = 1
               crapltr.nrestdoc = 0
               crapltr.cdsuperv = ''.
        VALIDATE crapltr.


        /* saldo do terminal no ayllos */ 
        DO  WHILE TRUE:

            FIND crapstf WHERE crapstf.cdcooper = par_cdcoptfn  AND 
                               crapstf.dtmvtolt = par_dtmvtolt  AND
                               crapstf.nrterfin = par_nrterfin
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapstf  THEN
                    IF  LOCKED crapstf  THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            par_dscritic = "Problemas ao atualizar TAA".
                            UNDO, RETURN "NOK".
                         END.

                LEAVE.
        END.  /* Fim do WHILE */



        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT aux_cdhiscre).

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                par_dscritic = "TAA indisponivel.".
                UNDO, RETURN "NOK".
            END.

        ASSIGN crapstd.vldmovto = crapstd.vldmovto + par_vldsaque
               crapstf.vldsdfin = crapstf.vldsdfin + par_vldsaque.

        FIND CURRENT crapstf NO-LOCK.
        FIND CURRENT crapstd NO-LOCK.

        VALIDATE crapstf.

        LEAVE.
    END.  /*  Fim DO WHILE..  */


    RETURN "OK".

END PROCEDURE.
/* Fim confere_saque */





PROCEDURE atualiza_saldo:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_qtnotaK7    AS INT      EXTENT 5        NO-UNDO.
    DEFINE  INPUT PARAM par_vlnotK7R    AS DEC                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     aux_contador    AS INT                      NO-UNDO.
    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            IF  LOCKED(craptfn)  THEN
                par_dscritic = "TAA indisponivel.".
            ELSE
                par_dscritic = "TAA nao cadastrado.".

            RETURN "NOK".
        END.

    DO  aux_contador = 1 TO 5:
    
        ASSIGN craptfn.qtnotcas[aux_contador] = par_qtnotaK7[aux_contador]
               craptfn.vltotcas[aux_contador] = par_qtnotaK7[aux_contador] * craptfn.vlnotcas[aux_contador].

        /* K7R possui diversos tipos de notas entao guarda a soma delas */
        IF  aux_contador = 5  THEN
            craptfn.vlnotcas[aux_contador] = par_vlnotK7R.
    END.

    FIND CURRENT craptfn NO-LOCK.
    
    RETURN "OK".

END PROCEDURE.
/* Fim atualiza_saldo */





PROCEDURE horario_deposito:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_flghorar    AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            par_dscritic = "TAA nao cadastrado.".
            RETURN "NOK".
        END.


    /* verifica horario de corte */
    FIND craptab WHERE craptab.cdcooper = craptfn.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 00                AND
                       craptab.cdacesso = "HRTRENVELO"      AND
                       craptab.tpregist = craptfn.cdagenci
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptab  THEN
        DO:
            IF  TIME > INTE(SUBSTRING(craptab.dstextab,1,5))  THEN
                par_flghorar = NO.
            ELSE
                par_flghorar = YES.
        END.
    ELSE
        par_flghorar = NO.



    /* no caso de fim de semana ou feriado, faz corte para 
       o proximo dia util */
    IF   CAN-DO("1,7",STRING(WEEKDAY(TODAY))) OR
         CAN-FIND(crapfer WHERE crapfer.cdcooper = craptfn.cdcooper  AND
                                crapfer.dtferiad = TODAY)   THEN
         par_flghorar = NO.

    
    RETURN "OK".

END PROCEDURE.
/* Fim horario_deposito */




PROCEDURE horario_pagamento:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_hrinipag    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_hrfimpag    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            par_dscritic = "TAA nao cadastrado.".
            RETURN "NOK".
        END.


    /* verifica horario de corte */
    FIND craptab WHERE craptab.cdcooper = par_cdcoptfn AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRTITULO" AND
                       craptab.tpregist = 91
                       NO-LOCK NO-ERROR.
    
    IF  AVAILABLE craptab  THEN
        ASSIGN par_hrinipag = INTE(SUBSTR(craptab.dstextab,9,5))
               par_hrfimpag = INTE(SUBSTR(craptab.dstextab,3,5)).
    ELSE
        DO:
            par_dscritic = "Horario nao Cadastrado".
            RETURN "OK".
        END.
                                                                 
    
    RETURN "OK".

END PROCEDURE.
/* Fim horario_pagamento */



PROCEDURE atualiza_noturno_temporizador:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_hrininot    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_hrfimnot    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_vlsaqnot    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrtempor    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.

    
    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                       craptfn.nrterfin = par_nrterfin
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craptfn  THEN
        DO:
            par_dscritic = "TAA nao cadastrado.".
            RETURN "NOK".
        END.

    ASSIGN craptfn.cdoperad = par_cdoperad
           craptfn.hrininot = par_hrininot
           craptfn.hrfimnot = par_hrfimnot
           craptfn.vlsaqnot = par_vlsaqnot
           craptfn.nrtempor = par_nrtempor.


    FIND CURRENT craptfn NO-LOCK.
    
    RETURN "OK".

END PROCEDURE.
/* Fim atualiza_noturno_temporizador */


PROCEDURE gera_estatistico:

    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrterfin    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dsprefix    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_tpextrat    AS INT                      NO-UNDO.


    /* tratamento de estatistico para versao 1 do sistema */
    DEFINE VARIABLE     aux_cdacesso    AS CHAR                     NO-UNDO.


    IF  par_dsprefix <> ""  THEN
        DO:
            aux_cdacesso = par_dsprefix +
                           STRING(YEAR(TODAY),'9999') +
                           STRING(MONTH(TODAY),'99')  +
                           STRING(DAY(TODAY),'99').
            
            DO  WHILE TRUE:
            
                FIND craptab WHERE craptab.cdcooper = par_cdcoptfn    AND
                                   craptab.nmsistem = "CRED"          AND
                                   craptab.tptabela = "AUTOMA"        AND
                                   craptab.cdempres = 0               AND
                                   craptab.cdacesso = aux_cdacesso    AND
                                   craptab.tpregist = par_nrterfin
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                IF  NOT AVAILABLE craptab  THEN
                    IF  LOCKED craptab  THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craptab.
                            ASSIGN craptab.cdcooper = par_cdcoptfn
                                   craptab.nmsistem = "CRED"
                                   craptab.tptabela = "AUTOMA"
                                   craptab.cdempres = 0
                                   craptab.cdacesso = aux_cdacesso
                                   craptab.tpregist = par_nrterfin.
                            VALIDATE craptab.
                        END.
                                
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            
            craptab.dstextab = STRING(INT(craptab.dstextab) + 1).
            
            FIND CURRENT craptab NO-LOCK.
        END.



    /* tratamento para estatistico versao 2 do sistema */
    IF  par_tpextrat > 0  THEN
        DO:
            /* tipo 1 - Extrato de C/C ja eh contabilizado na
               BO b1wgen0001 que gera o extrato */
            IF  par_tpextrat <> 1  THEN
                DO:
                    FIND craptfn WHERE craptfn.cdcooper = par_cdcoptfn  AND
                                       craptfn.nrterfin = par_nrterfin
                                       NO-LOCK NO-ERROR.
                    
                    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper
                                       NO-LOCK NO-ERROR.

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta
                                       NO-LOCK NO-ERROR.
                    
                    IF  NOT AVAIL craptfn  OR
                        NOT AVAIL crapdat  OR
                        NOT AVAIL crapass  THEN
                        RETURN "NOK".
                    
                    CREATE crapext.
                    ASSIGN crapext.cdcooper = crapass.cdcooper
                           crapext.cdagenci = crapass.cdagenci
                           crapext.nrdconta = crapass.nrdconta
                           crapext.dtrefere = crapdat.dtmvtocd
                           crapext.nranoref = 0
                           crapext.nrctremp = 0
                           crapext.nraplica = 0
                           crapext.inselext = 0
                           crapext.tpextrat = par_tpextrat
                           crapext.inisenta = 0
                           crapext.insitext = 1
                           crapext.cdcoptfn = par_cdcoptfn
                           crapext.cdagetfn = craptfn.cdagenci
                           crapext.nrterfin = par_nrterfin.
                    VALIDATE crapext.
                END.
        END.


    RETURN "OK".
    
END PROCEDURE.
/* Fim gera_estatistico */



PROCEDURE verifica_agencia_central:
    /* verifica a agencia da cooperativa na central, pode ser chamada tanto com
       a cooperativa do TAA, quanto com a cooperativa do associado que estiver
       utilizando o terminal */

    DEFINE  INPUT PARAM par_cdcooper     AS INT              NO-UNDO.
    DEFINE OUTPUT PARAM par_cdagectl     AS INT              NO-UNDO.

    DEFINE     VARIABLE h-b1wgen9999     AS HANDLE           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        RETURN "NOK".

    EMPTY TEMP-TABLE tt-erro.
    par_cdagectl = crapcop.cdagectl.

    RETURN "OK".

END PROCEDURE.
/* Fim verifica_agencia_central */



PROCEDURE busca_associado:
    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_cdagectl    AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_nmrescop    AS CHAR                     NO-UNDO.
    DEFINE OUTPUT PARAM par_nmtitula    AS CHAR     EXTENT 2        NO-UNDO.
    DEFINE OUTPUT PARAM par_flgmigra    AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR                     NO-UNDO.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop   THEN
        DO:
            par_dscritic = "Cooperativa nao encontrada.".
            RETURN "NOK".
        END.

    par_nmrescop = crapcop.nmrescop.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass   THEN
        DO:
            par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

	IF crapass.inpessoa = 1 THEN
	   DO:
	      FOR FIRST crapttl FIELDS(nmextttl) 
		                    WHERE crapttl.cdcooper = crapass.cdcooper AND
		                          crapttl.nrdconta = crapass.nrdconta AND
							      crapttl.idseqttl = 2
   							      NO-LOCK:

		     ASSIGN par_nmtitula[2] = crapttl.nmextttl.

		  END.
		  
	   END.

    ASSIGN par_nmtitula[1] = crapass.nmprimtl.

    /* agencia da cooperativa do associado */
    RUN verifica_agencia_central ( INPUT par_cdcooper,
                                  OUTPUT par_cdagectl).


    /* Verifica se a conta foi migrada para outra cooperativa */
    FIND craptco WHERE craptco.cdcopant = crapass.cdcooper  AND
                       craptco.nrctaant = crapass.nrdconta  AND
                       craptco.tpctatrf = 1 /* C/C */       AND
                       craptco.flgativo = YES
                       NO-LOCK NO-ERROR.

    par_flgmigra = AVAILABLE craptco.


    RETURN "OK".

END PROCEDURE.
/* Fim busca_associado */

/* .......................................................................... */

PROCEDURE busca_movto_saque_cooperativa:
/* Busca movimentos de SAQUE                                           */
/* Utilizada em CRPS580/CRPS581/CASH.                                  */
/* Consulta por:                                                       */
/* - Saques feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Saques feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */


    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.


    EMPTY TEMP-TABLE tt-lancamentos.

    IF par_cdcoptfn <> 0 THEN DO:
    /* Saques feitos no meu TAA por outras Coops     */

        FOR EACH craplcm NO-LOCK
           WHERE (craplcm.cdcoptfn  = par_cdcoptfn
              AND craplcm.cdhistor  = 918
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn)
              OR (craplcm.cdcoptfn  = par_cdcoptfn
              AND craplcm.cdhistor  = 920
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn)
            BREAK BY craplcm.cdcooper
                  BY craplcm.nrdconta:
    
    
           IF FIRST-OF(craplcm.nrdconta) THEN DO:
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplcm.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplcm.cdagetfn
                      AND tt-lancamentos.nrdconta = craplcm.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplcm.cdcooper
                          tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                          tt-lancamentos.cdagetfn = craplcm.cdagetfn
                          tt-lancamentos.nrdconta = craplcm.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Saque"
                          tt-lancamentos.tpconsul = "TAA".
                END.
           END.

           IF craplcm.cdhistor = 918 THEN
              ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                     tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal + 
                                               craplcm.vllanmto.
           ELSE
              ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto - 1
                     tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal -
                                               craplcm.vllanmto.
        
        END.  /* END do FOR EACH LCM */

    END. /* END do IF par_cdcoptfn */

    IF par_cdcooper <> 0 THEN DO:
    /* Saques feitos por meus Assoc. em outras Coops */

        FOR EACH craplcm NO-LOCK
           WHERE (craplcm.cdcooper  = par_cdcooper
              AND craplcm.cdhistor  = 918
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn
              AND craplcm.cdcoptfn <> 0)
             OR  (craplcm.cdcooper  = par_cdcooper
              AND craplcm.cdhistor  = 920
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn
              AND craplcm.cdcoptfn <> 0)
            BREAK BY craplcm.cdcoptfn
                  BY craplcm.nrdconta:
    
    
            IF FIRST-OF(craplcm.nrdconta) THEN DO:
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplcm.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplcm.cdagetfn
                      AND tt-lancamentos.nrdconta = craplcm.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplcm.cdcooper
                          tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                          tt-lancamentos.cdagetfn = craplcm.cdagetfn
                          tt-lancamentos.nrdconta = craplcm.nrdconta
                          tt-lancamentos.dstplanc = "Saque"
                          tt-lancamentos.tpconsul = "Outras Coop"
                          tt-lancamentos.qtdecoop = 1.
                END.
            END.
    
            IF craplcm.cdhistor = 918 THEN
               ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                      tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal + 
                                                craplcm.vllanmto.
            ELSE
               ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto - 1
                      tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal -
                                                craplcm.vllanmto.
    
        END. /* END do FOR EACH LCM */

    END. /* END do IF par_cdcooper */



END PROCEDURE.

/* .......................................................................... */

PROCEDURE  taa_lancamento_tarifas_ext:
/* Consulta por:                                                       */
/* - Saques feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Saques feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_tpextrat    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_insitext    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdhistor    AS CHAR                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    DEF             VAR aux_dstplanc    AS CHAR                     NO-UNDO.
    DEF             VAR aux_contador    AS INT                      NO-UNDO.


    EMPTY TEMP-TABLE tt-lancamentos.

    CASE par_cdtplanc:
        WHEN  5 OR WHEN  6 THEN aux_dstplanc = "Consulta de Saldo".
        WHEN  7 OR WHEN  8 THEN aux_dstplanc = "Impressao de Saldo".
        WHEN  9 OR WHEN 10 THEN aux_dstplanc = "Impressao de Extrato".
        WHEN 11 OR WHEN 12 THEN aux_dstplanc = "Imp. Extr. Aplicacao".
        WHEN 13 OR WHEN 14 THEN aux_dstplanc = "Consulta de Agendamento".
        WHEN 15 OR WHEN 16 THEN aux_dstplanc = "Exclusao de Agendamento".
        WHEN 23 OR WHEN 24 THEN aux_dstplanc = "Impressao comprovantes".
    END CASE.



    IF par_insitext <> "" THEN DO:
/*    Exclusivo para "Impressao de Extrato C/C" tpextrat = 1 e insitext = 5 
      ou Listagem do relatorio tpextrat = 1 e insitext 1 ou 5.
      O campo crapext.dtrefere armazenada o 1o dia do mes de referencia do
      extrato solicitado pelo cooperado, que pode ser do mes atual ou do mes
      anterior. Para poder verificar a quantidade de impressoes de extrato C/C
      no final de cada mes, sera utilizado o campo crapext.dtreffim, que
      gravara sempre o dia(crapdat.dtmvtocd) da impressao do extrato   */


        DO aux_contador = 1 TO NUM-ENTRIES(par_insitext):

            IF ENTRY(aux_contador,par_insitext) = "" THEN NEXT.

            IF par_cdcoptfn <> 0 THEN DO:

                FOR EACH crapext NO-LOCK
                   WHERE crapext.cdcoptfn  = par_cdcoptfn
                     AND crapext.tpextrat  = par_tpextrat
                     AND crapext.insitext  = INT(ENTRY(aux_contador,par_insitext))
                     AND crapext.dtreffim >= par_dtmvtoin
                     AND crapext.dtreffim <= par_dtmvtofi
                     AND crapext.cdcooper <> crapext.cdcoptfn
                   BREAK BY crapext.cdcooper
                         BY crapext.nrdconta:

                   IF FIRST-OF(crapext.nrdconta) THEN DO:
            
                       FIND FIRST tt-lancamentos NO-LOCK
                            WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                              AND tt-lancamentos.cdcooper = crapext.cdcooper
                              AND tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                              AND tt-lancamentos.cdagetfn = crapext.cdagetfn
                              AND tt-lancamentos.nrdconta = crapext.nrdconta
                            NO-ERROR.
                
                        IF NOT AVAIL tt-lancamentos THEN DO:
                           CREATE tt-lancamentos.
                           ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                                  tt-lancamentos.cdcooper = crapext.cdcooper
                                  tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                                  tt-lancamentos.cdagetfn = crapext.cdagetfn
                                  tt-lancamentos.nrdconta = crapext.nrdconta
                                  tt-lancamentos.qtdecoop = 1
                                  tt-lancamentos.dstplanc = aux_dstplanc
                                  tt-lancamentos.tpconsul = "TAA".
                        END.
                   END.
            
                   ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1.

                END. /* END do FOR EACH EXT */
            END. /* END do IF par_cdcoptfn */
    
            IF par_cdcooper <> 0 THEN DO:
                FOR EACH crapext NO-LOCK
                   WHERE crapext.cdcooper  = par_cdcooper
                     AND crapext.tpextrat  = par_tpextrat
                     AND crapext.insitext  = INT(ENTRY(aux_contador,par_insitext))
                     AND crapext.dtreffim >= par_dtmvtoin
                     AND crapext.dtreffim <= par_dtmvtofi
                     AND crapext.cdcooper <> crapext.cdcoptfn
                     AND crapext.cdcoptfn <> 0
                   BREAK BY crapext.cdcoptfn
                         BY crapext.nrdconta:
            
                   IF FIRST-OF(crapext.nrdconta) THEN DO:
            
                       FIND FIRST tt-lancamentos NO-LOCK
                            WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                              AND tt-lancamentos.cdcooper = crapext.cdcooper
                              AND tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                              AND tt-lancamentos.cdagetfn = crapext.cdagetfn
                              AND tt-lancamentos.nrdconta = crapext.nrdconta
                            NO-ERROR.
                
                        IF NOT AVAIL tt-lancamentos THEN DO:
                           CREATE tt-lancamentos.
                           ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                                  tt-lancamentos.cdcooper = crapext.cdcooper
                                  tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                                  tt-lancamentos.cdagetfn = crapext.cdagetfn
                                  tt-lancamentos.nrdconta = crapext.nrdconta
                                  tt-lancamentos.qtdecoop = 1
                                  tt-lancamentos.dstplanc = aux_dstplanc
                                  tt-lancamentos.tpconsul = "Outras Coop".
                        END.
                   END.

                   ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1.

                END. /* END do FOR EACH EXT */

            END. /* END do IF par_cdcooper */
            

        END. /* Fim do DO aux_contador = 1 TO NUM-ENTRIES */

    END.
    ELSE DO:

        IF par_cdcoptfn <> 0 THEN DO:

            FOR EACH crapext NO-LOCK
               WHERE crapext.cdcoptfn  = par_cdcoptfn
                 AND crapext.tpextrat  = par_tpextrat
                 AND crapext.dtrefere >= par_dtmvtoin
                 AND crapext.dtrefere <= par_dtmvtofi
                 AND crapext.cdcooper <> crapext.cdcoptfn
               BREAK BY crapext.cdcooper
                     BY crapext.nrdconta:

               IF FIRST-OF(crapext.nrdconta) THEN DO:
                   FIND FIRST tt-lancamentos NO-LOCK
                        WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                          AND tt-lancamentos.cdcooper = crapext.cdcooper
                          AND tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                          AND tt-lancamentos.cdagetfn = crapext.cdagetfn
                          AND tt-lancamentos.nrdconta = crapext.nrdconta
                        NO-ERROR.
            
                    IF NOT AVAIL tt-lancamentos THEN DO:
                       CREATE tt-lancamentos.
                       ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                              tt-lancamentos.cdcooper = crapext.cdcooper
                              tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                              tt-lancamentos.cdagetfn = crapext.cdagetfn
                              tt-lancamentos.nrdconta = crapext.nrdconta
                              tt-lancamentos.qtdecoop = 1
                              tt-lancamentos.dstplanc = aux_dstplanc
                              tt-lancamentos.tpconsul = "TAA".
                    END.
               END.

               ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1.

            END. /* END do FOR EACH EXT */
        END. /* END do IF par_cdcooper */

        IF par_cdcooper <> 0 THEN DO:

            FOR EACH crapext NO-LOCK
               WHERE crapext.cdcooper  = par_cdcooper
                 AND crapext.tpextrat  = par_tpextrat
                 AND crapext.dtrefere >= par_dtmvtoin
                 AND crapext.dtrefere <= par_dtmvtofi
                 AND crapext.cdcooper <> crapext.cdcoptfn
                 AND crapext.cdcoptfn <> 0
               BREAK BY crapext.cdcoptfn
                     BY crapext.nrdconta:

               IF FIRST-OF(crapext.nrdconta) THEN DO:
                   FIND FIRST tt-lancamentos NO-LOCK
                        WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                          AND tt-lancamentos.cdcooper = crapext.cdcooper
                          AND tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                          AND tt-lancamentos.cdagetfn = crapext.cdagetfn
                          AND tt-lancamentos.nrdconta = crapext.nrdconta
                        NO-ERROR.
            
                    IF NOT AVAIL tt-lancamentos THEN DO:
                       CREATE tt-lancamentos.
                       ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                              tt-lancamentos.cdcooper = crapext.cdcooper
                              tt-lancamentos.cdcoptfn = crapext.cdcoptfn
                              tt-lancamentos.cdagetfn = crapext.cdagetfn
                              tt-lancamentos.nrdconta = crapext.nrdconta
                              tt-lancamentos.qtdecoop = 1
                              tt-lancamentos.dstplanc = aux_dstplanc
                              tt-lancamentos.tpconsul = "Outras Coop".
                    END.
               END.

               ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1.

            END. /* END do FOR EACH EXT */
        END. /* END do IF par_cdcooper */

    END. /* END do ELSE do IF par_insitext <> "" */


END PROCEDURE.


/* .......................................................................... */


PROCEDURE  taa_lancto_titulos_convenios:
/* Consulta por:                                                       */
/* - Saques feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Saques feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-lancamentos.

    IF par_cdcoptfn <> 0 THEN DO:

        FOR EACH craptit NO-LOCK
           WHERE craptit.cdcoptfn  = par_cdcoptfn
             AND craptit.cdagenci  = 91 
             AND craptit.dtmvtolt >= par_dtmvtoin
             AND craptit.dtmvtolt <= par_dtmvtofi
             AND craptit.cdcooper <> craptit.cdcoptfn
           BREAK BY craptit.cdcooper
                 BY craptit.nrdconta:

           IF FIRST-OF(craptit.nrdconta) THEN DO:

               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craptit.cdcooper
                      AND tt-lancamentos.cdcoptfn = craptit.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craptit.cdagetfn
                      AND tt-lancamentos.nrdconta = craptit.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craptit.cdcooper
                          tt-lancamentos.cdcoptfn = craptit.cdcoptfn
                          tt-lancamentos.cdagetfn = craptit.cdagetfn
                          tt-lancamentos.nrdconta = craptit.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Pagamento"
                          tt-lancamentos.tpconsul = "TAA".
                END.
           END.
    
           ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                  tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                            craptit.vldpagto.

        END.
    
        FOR EACH craplft NO-LOCK
           WHERE craplft.cdcoptfn  = par_cdcoptfn
             AND craplft.cdagenci  = 91
             AND craplft.dtmvtolt >= par_dtmvtoin
             AND craplft.dtmvtolt <= par_dtmvtofi
             AND craplft.cdcooper <> craplft.cdcoptfn
           BREAK BY craplft.cdcooper
                 BY craplft.nrdconta:

           IF FIRST-OF(craplft.nrdconta) THEN DO:
    
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplft.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplft.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplft.cdagetfn
                      AND tt-lancamentos.nrdconta = craplft.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplft.cdcooper
                          tt-lancamentos.cdcoptfn = craplft.cdcoptfn
                          tt-lancamentos.cdagetfn = craplft.cdagetfn
                          tt-lancamentos.nrdconta = craplft.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Pagamento"
                          tt-lancamentos.tpconsul = "TAA".
                END.
           END.

           ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                  tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                            (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

        END.
    END. /* END do IF par_cdcoptfn */

    IF par_cdcooper <> 0 THEN DO:

        FOR EACH craptit NO-LOCK
           WHERE craptit.cdcooper  = par_cdcooper
             AND craptit.dtdpagto >= par_dtmvtoin
             AND craptit.dtdpagto <= par_dtmvtofi
             AND craptit.cdagenci = 91
             AND craptit.cdcooper <> craptit.cdcoptfn
             AND craptit.cdcoptfn <> 0
           BREAK BY craptit.cdcoptfn
                 BY craptit.nrdconta:

           IF FIRST-OF(craptit.nrdconta) THEN DO:

               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craptit.cdcooper
                      AND tt-lancamentos.cdcoptfn = craptit.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craptit.cdagetfn
                      AND tt-lancamentos.nrdconta = craptit.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craptit.cdcooper
                          tt-lancamentos.cdcoptfn = craptit.cdcoptfn
                          tt-lancamentos.cdagetfn = craptit.cdagetfn
                          tt-lancamentos.nrdconta = craptit.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Pagamento"
                          tt-lancamentos.tpconsul = "Outras Coop".
                END.

           END.

            ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                   tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                             craptit.vldpagto.

        END.
    
        FOR EACH craplft NO-LOCK
           WHERE craplft.cdcooper  = par_cdcooper
             AND craplft.dtmvtolt >= par_dtmvtoin
             AND craplft.dtmvtolt <= par_dtmvtofi
             AND craplft.cdagenci  = 91
             AND craplft.cdcooper <> craplft.cdcoptfn
             AND craplft.cdcoptfn <> 0
           BREAK BY craplft.cdcoptfn
                 BY craplft.nrdconta:

           IF FIRST-OF(craplft.nrdconta) THEN DO:
    
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplft.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplft.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplft.cdagetfn
                      AND tt-lancamentos.nrdconta = craplft.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplft.cdcooper
                          tt-lancamentos.cdcoptfn = craplft.cdcoptfn
                          tt-lancamentos.cdagetfn = craplft.cdagetfn
                          tt-lancamentos.nrdconta = craplft.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Pagamento"
                          tt-lancamentos.tpconsul = "Outras Coop".
                END.

           END.

            ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                   tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                             (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).

        END.
    END. /* END do IF par_cdcooper */


END PROCEDURE.

/* .......................................................................... */

PROCEDURE  taa_agenda_titulos_convenios:
/* Consulta por:                                                       */
/* - Agendamentos de pagamento feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Agendamentos de pagamento feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-lancamentos.

    IF par_cdcoptfn <> 0 THEN DO:

        FOR EACH craplau WHERE  craplau.cdcoptfn =  par_cdcoptfn
                           AND  craplau.cdagenci =  91
                           AND  craplau.cdtiptra =  2
                           AND  craplau.dtmvtolt >= par_dtmvtoin 
                           AND  craplau.dtmvtolt <= par_dtmvtofi 
                           AND  craplau.cdcooper <> craplau.cdcoptfn
                           NO-LOCK BREAK BY craplau.cdcooper
                                         BY craplau.nrdconta:

            IF FIRST-OF(craplau.nrdconta) THEN DO:

                FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplau.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplau.cdagetfn
                      AND tt-lancamentos.nrdconta = craplau.nrdconta
                      NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplau.cdcooper
                          tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                          tt-lancamentos.cdagetfn = craplau.cdagetfn
                          tt-lancamentos.nrdconta = craplau.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Agendamento de Pagamento"
                          tt-lancamentos.tpconsul = "TAA".
                END.                
            END.

            ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                   tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                             craplau.vllanaut.

        END. /* Fim for each craplau*/

    END. /* End If par_cdcopftn */

    IF par_cdcooper <> 0 THEN DO:

        FOR EACH craplau WHERE  craplau.cdcooper  = par_cdcooper
                           AND  craplau.cdagenci = 91 
                           AND  craplau.cdtiptra =  2
                           AND  craplau.dtmvtolt >= par_dtmvtoin
                           AND  craplau.dtmvtolt <= par_dtmvtofi
                           AND  craplau.cdcooper <> craplau.cdcoptfn
                           NO-LOCK BREAK BY craplau.cdcoptfn
                                         BY craplau.nrdconta:

           IF FIRST-OF(craplau.nrdconta) THEN DO:

               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplau.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplau.cdagetfn
                      AND tt-lancamentos.nrdconta = craplau.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplau.cdcooper
                          tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                          tt-lancamentos.cdagetfn = craplau.cdagetfn
                          tt-lancamentos.nrdconta = craplau.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Agendamento de Pagamento"
                          tt-lancamentos.tpconsul = "Outras Coop".
                END.

           END.

           ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                  tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                            craplau.vllanaut.

        END. /* Fim for each craplau*/

    END. /* End If par_cdcooper */

END PROCEDURE.

/* .......................................................................... */

PROCEDURE  taa_agenda_transferencias:
/* Consulta por:                                                       */
/* - Agendamentos de transferencias feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Agendamentos de transferencias feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-lancamentos.

    IF par_cdcoptfn <> 0 THEN DO:

        FOR EACH craplau WHERE  craplau.cdcoptfn =  par_cdcoptfn
                            AND CAN-DO("1,5",STRING(craplau.cdtiptra)) 
                           AND  craplau.dtmvtolt >= par_dtmvtoin 
                           AND  craplau.dtmvtolt <= par_dtmvtofi
                            AND craplau.cdagenci =  91         
                           AND  craplau.cdcooper <> craplau.cdcoptfn

                           NO-LOCK BREAK BY craplau.cdcooper
                                         BY craplau.nrdconta:

            IF FIRST-OF(craplau.nrdconta) THEN DO:

                FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplau.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplau.cdagetfn
                      AND tt-lancamentos.nrdconta = craplau.nrdconta
                      NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplau.cdcooper
                          tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                          tt-lancamentos.cdagetfn = craplau.cdagetfn
                          tt-lancamentos.nrdconta = craplau.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Agendamento de Transferencia" 
                          tt-lancamentos.tpconsul = "TAA".
                END.                
            END.

            ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                   tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                             craplau.vllanaut.

        END. /* Fim for each craplau*/

    END. /* End If par_cdcopftn */

    IF par_cdcooper <> 0 THEN DO:

        FOR EACH craplau WHERE  craplau.cdcooper  = par_cdcooper
                           AND CAN-DO("1,5",STRING(craplau.cdtiptra))
                           AND  craplau.cdagenci = 91 
                           AND  craplau.dtmvtolt >= par_dtmvtoin
                           AND  craplau.dtmvtolt <= par_dtmvtofi
                           AND  craplau.cdcooper <> craplau.cdcoptfn
                           NO-LOCK BREAK BY craplau.cdcoptfn
                                         BY craplau.nrdconta:

           IF FIRST-OF(craplau.nrdconta) THEN DO:

               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplau.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplau.cdagetfn
                      AND tt-lancamentos.nrdconta = craplau.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplau.cdcooper
                          tt-lancamentos.cdcoptfn = craplau.cdcoptfn
                          tt-lancamentos.cdagetfn = craplau.cdagetfn
                          tt-lancamentos.nrdconta = craplau.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Agendamento de Transferencia"
                          tt-lancamentos.tpconsul = "Outras Coop".
                END.

           END.

           ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                  tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal +
                                            craplau.vllanaut.

        END. /* Fim for each craplau*/

    END. /* End If par_cdcooper */

END PROCEDURE.

/* .......................................................................... */

PROCEDURE  taa_transferencias:
/* Consulta por:                                                       */
/* - Transferencias feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     */
/* - Transferencias feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */

    DEFINE  INPUT PARAM par_cdcooper    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_cdcoptfn    AS INT                      NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtoin    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtofi    AS DATE                     NO-UNDO.
    DEFINE  INPUT PARAM par_cdtplanc    AS INT                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-lancamentos.

    IF par_cdcoptfn <> 0 THEN DO:
    /* Saques feitos no meu TAA por outras Coops     */

        FOR EACH craplcm NO-LOCK
           WHERE 
                 (craplcm.cdcoptfn  = par_cdcoptfn
              AND craplcm.cdhistor  = 375
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn)
                OR 
                 (craplcm.cdcoptfn  = par_cdcoptfn
              AND craplcm.cdhistor  = 376
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn)
                OR 
                 (craplcm.cdcoptfn  = par_cdcoptfn
              AND craplcm.cdhistor  = 1009
              AND craplcm.cdagenci  = 91
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn) 
            BREAK BY craplcm.cdcooper
                  BY craplcm.nrdconta:
    
           IF FIRST-OF(craplcm.nrdconta) THEN DO:
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplcm.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplcm.cdagetfn
                      AND tt-lancamentos.nrdconta = craplcm.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplcm.cdcooper
                          tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                          tt-lancamentos.cdagetfn = craplcm.cdagetfn
                          tt-lancamentos.nrdconta = craplcm.nrdconta
                          tt-lancamentos.qtdecoop = 1
                          tt-lancamentos.dstplanc = "Transferencia"
                          tt-lancamentos.tpconsul = "TAA".
                END.
           END.

           ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                  tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal + 
                                            craplcm.vllanmto.

        
        END.  /* END do FOR EACH LCM */

    END. /* END do IF par_cdcoptfn */

    IF par_cdcooper <> 0 THEN DO:
    /* Saques feitos por meus Assoc. em outras Coops */

        FOR EACH craplcm NO-LOCK
           WHERE (craplcm.cdcooper  = par_cdcooper
              AND craplcm.cdhistor  = 375
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn
              AND craplcm.cdcoptfn <> 0)
             OR 
                 (craplcm.cdcooper  = par_cdcooper
              AND craplcm.cdhistor  = 376
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn
              AND craplcm.cdcoptfn <> 0)
            OR
                 (craplcm.cdcooper  = par_cdcooper
              AND craplcm.cdhistor  = 1009
              AND craplcm.cdagenci  = 91      
              AND craplcm.dtmvtolt >= par_dtmvtoin
              AND craplcm.dtmvtolt <= par_dtmvtofi
              AND craplcm.cdcooper <> craplcm.cdcoptfn
              AND craplcm.cdcoptfn <> 0)
            BREAK BY craplcm.cdcoptfn
                  BY craplcm.nrdconta:
    
            IF FIRST-OF(craplcm.nrdconta) THEN DO:
               FIND FIRST tt-lancamentos NO-LOCK
                    WHERE tt-lancamentos.cdtplanc = par_cdtplanc
                      AND tt-lancamentos.cdcooper = craplcm.cdcooper
                      AND tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                      AND tt-lancamentos.cdagetfn = craplcm.cdagetfn
                      AND tt-lancamentos.nrdconta = craplcm.nrdconta
                    NO-ERROR.
        
                IF NOT AVAIL tt-lancamentos THEN DO:
                   CREATE tt-lancamentos.
                   ASSIGN tt-lancamentos.cdtplanc = par_cdtplanc
                          tt-lancamentos.cdcooper = craplcm.cdcooper
                          tt-lancamentos.cdcoptfn = craplcm.cdcoptfn
                          tt-lancamentos.cdagetfn = craplcm.cdagetfn
                          tt-lancamentos.nrdconta = craplcm.nrdconta
                          tt-lancamentos.dstplanc = "Transferencia"
                          tt-lancamentos.tpconsul = "Outras Coop"
                          tt-lancamentos.qtdecoop = 1.
                END.
            END.
    

            ASSIGN tt-lancamentos.qtdmovto = tt-lancamentos.qtdmovto + 1
                   tt-lancamentos.vlrtotal = tt-lancamentos.vlrtotal + 
                                             craplcm.vllanmto.

    
        END. /* END do FOR EACH LCM */

    END. /* END do IF par_cdcooper */

END PROCEDURE.


PROCEDURE calcula_dia_util:
/* Calcula de o dia informado e util */
    DEF INPUT   PARAM par_cdcooper AS INT                           NO-UNDO.
    DEF INPUT   PARAM par_dtagenda AS DATE                          NO-UNDO.
    
    DEF OUTPUT  PARAM par_flgderro AS LOGICAL                       NO-UNDO.

    IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtagenda)))             OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                               crapfer.dtferiad = par_dtagenda) THEN
        DO:
            ASSIGN par_flgderro = FALSE.
        END.
    ELSE
        ASSIGN par_flgderro = TRUE.

END PROCEDURE.


PROCEDURE verifica_movimento:
    DEF INPUT   PARAM par_cdcooper AS INT                           NO-UNDO.
    DEF INPUT   PARAM par_dtmvtolt AS DATE                          NO-UNDO.
    DEF INPUT   PARAM par_nrterfin AS INT                           NO-UNDO.
    DEF INPUT   PARAM par_cdhistor AS INT                           NO-UNDO.

    DO WHILE TRUE:
        
        /* procura o registro, se nao houver, cria */
        FIND crapstd WHERE crapstd.cdcooper = par_cdcooper  AND
                           crapstd.dtmvtolt = par_dtmvtolt  AND
                           crapstd.nrterfin = par_nrterfin  AND
                           crapstd.cdhistor = par_cdhistor
                           EXCLUSIVE-LOCK  NO-ERROR.
        
        IF  NOT AVAILABLE crapstd  THEN
            DO:
                IF  LOCKED(crapstd)  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        CREATE crapstd.
                        ASSIGN crapstd.cdcooper = par_cdcooper
                               crapstd.dtmvtolt = par_dtmvtolt
                               crapstd.nrterfin = par_nrterfin
                               crapstd.cdhistor = par_cdhistor.
                        VALIDATE crapstd.
                        
                    END.
            END.
        
        LEAVE.    
    END.  /* Fim do WHILE */
    
    RETURN "OK".
END.



PROCEDURE verifica_prova_vida_inss:

    DEFINE INPUT  PARAM par_cdcooper                AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_nrdconta                AS INT                      NO-UNDO.
    DEFINE OUTPUT PARAM par_flgdinss                AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM par_flgbinss                AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic                AS CHAR                     NO-UNDO.

    DEFINE VARIABLE h_b1wgen0091                    AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE aux_cdretorn                    AS INT                      NO-UNDO.
    DEFINE VARIABLE aux_dtmvtolt                    AS DATE                     NO-UNDO.   
    DEFINE VARIABLE aux_ponteiro                    AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_flgpvida                    AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_flgbinss                    AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_cdmodali                    AS INTEGER                  NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

    IF  VALID-HANDLE(h_b1wgen0091)  THEN
        DO:

            /* varre todos os beneficios em busca de algum que precise comprovar vida */
            FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper  AND
                                   crapcbi.nrdconta = par_nrdconta  NO-LOCK:                

                aux_cdretorn = DYNAMIC-FUNCTION("verificacao_bloqueio" IN h_b1wgen0091,
                                                INPUT crapcbi.cdcooper,
                                                INPUT 0,  /* Caixa */
                                                INPUT 0,  /* PAC */
                                                INPUT "", /* Operador */
                                                INPUT "", /* Tela */
                                                INPUT 0,  /* Origem */
                                                INPUT aux_datdodia,
                                                INPUT crapcbi.nrcpfcgc,
                                                INPUT 0,  /* Procurador */
                                                INPUT 1). /* Tipo de consulta */

                /* 0- Beneficio OK
                   1- Beneficio bloqueado
                   2- Comprovacao nao efetuada
                   3- Menos de 60 dias para comprovar */
                IF  aux_cdretorn <> 0  THEN
                    DO:
                        par_flgdinss = YES.
                        LEAVE.
                    END.
            END.
        END.

    DELETE PROCEDURE h_b1wgen0091.

    FOR FIRST crapdat 
       FIELDS (dtmvtolt)
        WHERE crapdat.cdcooper = par_cdcooper
        NO-LOCK: 
        ASSIGN aux_dtmvtolt = crapdat.dtmvtolt.
    END.
    
    /* P485 - Validaçao para conta salário */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_busca_modalidade_conta aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT  par_cdcooper 
                  ,INPUT  par_nrdconta 
                  ,OUTPUT 0
                  ,OUTPUT ""
                  ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_busca_modalidade_conta aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN par_dscritic = ""
           aux_cdmodali = 0
           par_dscritic = pc_busca_modalidade_conta.pr_dscritic 
                          WHEN pc_busca_modalidade_conta.pr_dscritic <> ?
           aux_cdmodali = pc_busca_modalidade_conta.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_conta.pr_cdmodalidade_tipo <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    /* Se retornou crítica */
    IF  par_dscritic <> "" THEN
      DO:
           RETURN "NOK".
      END.
    
    /* Se a modalidade for 2 entao é conta salário */
    IF aux_cdmodali = 2 THEN
      DO:
        par_flgdinss = NO.
        RETURN "OK".
      END.
    
    /* P485 - Validaçao para conta salário */

    /* verificacao para banner prova de vida
       Cooperativas: 
       Viacredi; Concredi; Credcrea e Viacredi Alto Vale,
       Acredicoop; Credicomin; Credifiesc; Credifoz e Transpocred. */              
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_verifica_renovacao_vida
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,     /* Código da Cooperativa */
								 INPUT aux_dtmvtolt,     /* Data de movimento */
                                 INPUT par_nrdconta,     /* Numero da Conta */ 
                                 INPUT 0, 				 /* Nr. Rec. Ben */
                                OUTPUT 0).               /* Flag se renova */
    
    /* Código da crítica */    
    CLOSE STORED-PROC pc_verifica_renovacao_vida
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_flgpvida = pc_verifica_renovacao_vida.pr_flrenova
                          WHEN pc_verifica_renovacao_vida.pr_flrenova <> ?.
	
    IF aux_flgpvida = 1 THEN
        par_flgdinss = YES.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE {&sc2_dboraayl}.send-sql-statement
                       aux_ponteiro = PROC-HANDLE
                       ("SELECT DISTINCT 1 FROM tbinss_dcb dcb " +
                                          "WHERE dcb.cdcooper = " + STRING(par_cdcooper) + 
                                          "  AND dcb.nrdconta = " + STRING(par_nrdconta)).

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
       ASSIGN aux_flgbinss = INT(proc-text).
    END.

    IF aux_flgbinss = 1 THEN
        par_flgbinss = YES.

    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
       WHERE PROC-HANDLE = aux_ponteiro.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    RETURN "OK".

END PROCEDURE.

PROCEDURE envia_email_cartao_bloqueado:

    DEFINE INPUT PARAM par_cdcoptfn AS INT                            NO-UNDO.
    DEFINE INPUT PARAM par_nrterfin AS INT                            NO-UNDO.
    DEFINE INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEFINE INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEFINE INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.
    DEFINE INPUT PARAM par_dsassunt AS CHAR                           NO-UNDO.
    
    DEFINE VARIABLE aux_dsdemail AS CHAR                              NO-UNDO.
    DEFINE VARIABLE aux_dsassunt AS CHAR                              NO-UNDO.
    DEFINE VARIABLE aux_dsdcorpo AS CHAR                              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0011 AS HANDLE                            NO-UNDO.
    
    DEFINE BUFFER crabass FOR crapass.
    
    FOR craptfn FIELDS(cdcooper cdagenci nrterfin nmterfin)
                WHERE craptfn.cdcooper = par_cdcoptfn AND
                      craptfn.nrterfin = par_nrterfin
                      NO-LOCK: END.
    
    FOR crapage FIELDS(nmcidade nmresage) 
                WHERE crapage.cdcooper = craptfn.cdcooper AND
                      crapage.cdagenci = craptfn.cdagenci 
                      NO-LOCK: END.
  
    FOR crapass FIELDS(cdcooper nrdconta inpessoa)
                WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta
                      NO-LOCK: END.
                                       
    ASSIGN aux_dsassunt = par_nmrescop + " - " + par_dsassunt + " - PA " + STRING(craptfn.cdagenci) +
                          " - " + crapage.nmcidade + " - " + STRING(craptfn.nrterfin) + " - " +
                          craptfn.nmterfin

           aux_dsdemail = "prevencaodefraudes@ailos.coop.br"
           
           aux_dsdcorpo = "PA: " + STRING(craptfn.cdagenci) + " - " + crapage.nmresage + "\n\n" + 
                          "Conta: " + STRING(par_nrdconta) + "\n".

    IF crapass.inpessoa = 1 THEN
       DO:
           /* pega todos os titulares */
           FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper  AND
                                  crapttl.nrdconta = crapass.nrdconta  NO-LOCK:

               ASSIGN aux_dsdcorpo = aux_dsdcorpo +
                                     "Titular " + STRING(crapttl.idseqttl) + ": " +
                                     crapttl.nmextttl + "\n".
           END.
       END.
    ELSE
       DO:
           /* pega o nome da empresa e os procuradores/representantes */
           FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                              crapjur.nrdconta = crapass.nrdconta  
                              NO-LOCK NO-ERROR.
           
           ASSIGN aux_dsdcorpo = aux_dsdcorpo +
                                 "Empresa: " + crapjur.nmextttl + "\n\n" +
                                 "Procuradores/Representantes: " + "\n".

           FOR EACH crapavt WHERE crapavt.cdcooper = crapass.cdcooper     AND
                                  crapavt.tpctrato = 6 /* procurador */   AND
                                  crapavt.nrdconta = crapass.nrdconta     
                                  NO-LOCK:

               IF crapavt.nrdctato <> 0 THEN
                  DO:
                      FIND crabass WHERE crabass.cdcooper = crapavt.cdcooper AND
                                         crabass.nrdconta = crapavt.nrdctato NO-LOCK.
                      
                      ASSIGN aux_dsdcorpo = aux_dsdcorpo + crabass.nmprimtl + "\n".
                  END.
               ELSE
                  ASSIGN aux_dsdcorpo = aux_dsdcorpo + crapavt.nmdavali + "\n".
           END.
       END.

    ASSIGN aux_dsdcorpo = aux_dsdcorpo + "\nFones:\n".

    FOR EACH craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                           craptfc.nrdconta = par_nrdconta NO-LOCK:
    
        ASSIGN aux_dsdcorpo = aux_dsdcorpo + 
                              "(" + STRING(craptfc.nrdddtfc) + ") " + STRING(craptfc.nrtelefo) + "\n".
    END.

    /* E-mail de monitoracao para uso de cartoes bloqueados */
    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

    RUN enviar_email_completo IN h-b1wgen0011
                  (INPUT par_cdcooper,
                   INPUT "b1wgen0025",
                   INPUT "prevencaodefraudes@ailos.coop.br",                   
                   INPUT aux_dsdemail,
                   INPUT aux_dsassunt,
                   INPUT "",
                   INPUT "",
                   INPUT aux_dsdcorpo,
                   INPUT FALSE).

    DELETE PROCEDURE h-b1wgen0011.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica_cartao_magnetico:

    DEFINE         INPUT PARAM par_cdcoptfn    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_nrterfin    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_dscartao    AS CHAR      NO-UNDO.
    DEFINE         INPUT PARAM par_dtmvtocd    AS DATE      NO-UNDO.
    DEFINE  INPUT-OUTPUT PARAM par_nrdconta    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_cdcooper    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_nrcartao    AS DEC       NO-UNDO.
    DEFINE        OUTPUT PARAM par_inpessoa    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_idsenlet    AS LOGICAL   NO-UNDO.
    DEFINE        OUTPUT PARAM par_tpusucar    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_dscritic    AS CHAR      NO-UNDO.
    
    DEFINE VARIABLE     aux_cddbanco    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_cdageban    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_dtvalida    AS DATE             NO-UNDO.
    DEFINE VARIABLE     aux_tptitcar    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_nrseqcar    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_qtcartao    AS INT              NO-UNDO.
        
    DEFINE VARIABLE     h_b1wgen0032    AS HANDLE           NO-UNDO.

    DEFINE BUFFER crabdat FOR crapdat.
    
    /* separa os dados da trilha */
    ASSIGN  aux_cddbanco = INTEGER(SUBSTRING(par_dscartao,04,03))

            aux_cdageban = INTEGER(SUBSTRING(par_dscartao,07,04))
        
            /* dia 1 do mes e ano de validade */
            aux_dtvalida = DATE(INT(SUBSTR(par_dscartao,20,02)),1,
                                INT(SUBSTR(par_dscartao,22,04)))

            aux_tptitcar = INT(SUBSTR(par_dscartao,26,02))
        
            par_tpusucar = INT(SUBSTR(par_dscartao,28,02))

            aux_nrseqcar = INT(SUBSTR(par_dscartao,34,06)) NO-ERROR.


    IF  ERROR-STATUS:ERROR                        OR
       (aux_tptitcar <> 9 AND aux_tptitcar <> 1)  OR
        par_tpusucar  > 9                         THEN
        DO:
            par_dscritic = "Erro de leitura.".
            RETURN "NOK".
        END.


    IF   YEAR(aux_dtvalida) < YEAR(par_dtmvtocd)         OR
        (YEAR(aux_dtvalida) = YEAR(par_dtmvtocd)    AND
        MONTH(aux_dtvalida) < MONTH(par_dtmvtocd))       THEN
        DO:
            ASSIGN par_dscritic = "Cartao Vencido".
            RETURN "NOK".
        END.
        
    /* Sao aceitos seguintes cartoes:
         BANCO: 756 - BANCOOB
       AGENCIA: NNN - AGENCIA DA COOPERATIVA NO BANCOOB
       
          OU
          
         BANCO: 085 - CECRED
       AGENCIA: NNN - AGENCIA DA COOPERATIVA NA CECRED
    */
    IF  aux_cddbanco = 756  THEN
        DO:
            FIND crapcop WHERE crapcop.cdagebcb = aux_cdageban NO-LOCK NO-ERROR.

            /* Agencia do Bancoob na AltoVale foi alterada */
            IF  NOT AVAIL crapcop   AND 
                aux_cdageban = 115  THEN /* AltoVale */
                FIND crapcop WHERE crapcop.cdagectl = aux_cdageban 
                                   NO-LOCK NO-ERROR.
        END.
    ELSE
    IF  aux_cddbanco = 85  THEN
        FIND crapcop WHERE crapcop.cdagectl = aux_cdageban NO-LOCK NO-ERROR.


    IF  NOT AVAIL crapcop  THEN
        DO: 
            ASSIGN par_dscritic = "Cartao Invalido.".
            RETURN "NOK".
        END.
    ELSE
        DO:
            /* se for cartao de operador, somente permite na mesma
               cooperativa do TAA */
            IF  aux_tptitcar      = 9             AND
                crapcop.cdcooper <> par_cdcoptfn  THEN
                DO:
                    ASSIGN par_dscritic = "Cartao Invalido".
                    RETURN "NOK".
                END.

            IF  aux_tptitcar <> 9 THEN
            DO:
            /* Verifica se a conta foi migrada para outra cooperativa */
            FIND craptco WHERE craptco.cdcopant = crapcop.cdcooper  AND
                               craptco.nrctaant = par_nrdconta      AND
                               craptco.tpctatrf = 1 /* C/C */       AND
                               craptco.flgativo = YES
                               NO-LOCK NO-ERROR.

            IF  AVAILABLE craptco  THEN
                DO: 
                    /* Busca a nova cooperativa */
                    FIND crapcop WHERE crapcop.cdcooper = craptco.cdcooper
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapcop  THEN
                        DO:
                            ASSIGN par_dscritic = "Cooperativa Invalida.".
                            RETURN "NOK".
                        END.

                    /* Altera a conta para o novo numero */
                    par_nrdconta = craptco.nrdconta.


                    /* Se tem de/para de cartao, pega o novo sequencial do cartao */
                    IF  craptco.nrcarant <> ""  AND
                        craptco.nrcartao <> ""  THEN
                        DO:
                            DO  aux_qtcartao = 1 TO NUM-ENTRIES(craptco.nrcarant,";"):
                                
                                IF  aux_nrseqcar = INT(ENTRY(aux_qtcartao,craptco.nrcarant,";"))  THEN
                                    DO:
                                        aux_nrseqcar = INT(ENTRY(aux_qtcartao,craptco.nrcartao,";")).
                                        LEAVE.
                                    END.
                            END.
                        END.
                END.
            END.

            /* verifica se o sistema das 2 cooperativas em questao,
               estao com as mesmas datas de movimento para o TAA */
            IF  crapcop.cdcooper <> par_cdcoptfn  THEN
                DO:
                    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                                       NO-LOCK NO-ERROR.

                    FIND crabdat WHERE crabdat.cdcooper = par_cdcoptfn
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapdat  OR
                        NOT AVAILABLE crabdat  OR
                        crapdat.dtmvtocd <> crabdat.dtmvtocd  THEN
                        DO:
                            par_dscritic = "Datas Invalidas.".
                            RETURN "NOK".
                        END.
                END.

            /* pega a nova cooperativa */
            par_cdcooper = crapcop.cdcooper.
        END.


    /* cartao tratado */
    par_nrcartao = DECIMAL(STRING(aux_tptitcar,"9")        +
                           STRING(aux_nrseqcar,"999999")   +
                           STRING(par_nrdconta,"99999999") +
                           STRING(par_tpusucar,"9")).
    
    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper   AND
                       crapcrm.nrdconta = par_nrdconta   AND
                       crapcrm.nrcartao = par_nrcartao
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                       
    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            IF  LOCKED(crapcrm)  THEN
                par_dscritic = "Cartao indisponivel.".
            ELSE
                par_dscritic = "Cartao nao cadastrado.".

            RETURN "NOK".
        END.

    /* Atualiza ultimo acesso */
    ASSIGN crapcrm.dtultace = par_dtmvtocd
           crapcrm.hrultace = TIME
           crapcrm.tfultace = par_nrterfin.

    FIND CURRENT crapcrm NO-LOCK.

    /* se o cartao nao estiver ativo */
    IF  crapcrm.cdsitcar <> 2  THEN
        DO:
            par_dscritic = IF  crapcrm.cdsitcar = 1  THEN
                               "Cartao Invalido"
                           ELSE
                           IF  crapcrm.cdsitcar = 3  THEN
                               "Cartao Cancelado"
                           ELSE
                           IF  crapcrm.cdsitcar = 4  THEN
                               "Cartao Bloqueado"
                           ELSE
                               "Cartao Invalido".

            /* E-mail de monitoracao para uso de cartoes bloqueados */
            IF  crapcrm.cdsitcar  = 4           AND   /* Bloqueado */
                crapcrm.dtcancel >= 08/26/2013  AND   /* Data de corte - fraude */
                CAN-DO("1,2,4,11,16",STRING(crapcrm.cdcooper))   AND
                crapcop.inaleblq = 1                             THEN
                DO:
                    RUN envia_email_cartao_bloqueado(INPUT par_cdcoptfn,
                                                     INPUT par_nrterfin,
                                                     INPUT crapcrm.cdcooper,
                                                     INPUT crapcrm.nrdconta,
                                                     INPUT crapcop.nmrescop,
                                                     INPUT "Cartao Bloqueado").
                
                END.

            RETURN "NOK".
        END.


    IF  aux_tptitcar <> 9  THEN
        DO:
            /* verifica inpessoa, se nao encontrar associado, eh operador */
            FIND crapass WHERE crapass.cdcooper = crapcrm.cdcooper AND
                               crapass.nrdconta = crapcrm.nrdconta 
                               NO-LOCK NO-ERROR.
            
            IF  AVAIL crapass  THEN
                par_inpessoa = crapass.inpessoa.
        END.



    /* verifica quantidade maxima de senhas erradas */
    IF  crapcrm.qtsenerr >= crapcop.taamaxer  THEN
        DO:
            par_dscritic = "Cartao Bloqueado".
            RETURN "NOK".
        END.
    
    ASSIGN par_idsenlet = NO.

    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

    IF  VALID-HANDLE(h_b1wgen0032)  THEN
        DO:
            RUN verifica-letras-seguranca IN h_b1wgen0032 
                                         (INPUT crapcrm.cdcooper,
                                          INPUT crapcrm.nrdconta,
                                          INPUT crapcrm.tpusucar,
                                         OUTPUT par_idsenlet).

            DELETE PROCEDURE h_b1wgen0032.
        END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE verifica_cartao_cecred:

    DEFINE         INPUT PARAM par_cdcoptfn    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_nrterfin    AS INT       NO-UNDO.
    DEFINE         INPUT PARAM par_dscartao    AS CHAR      NO-UNDO.
    DEFINE         INPUT PARAM par_dtmvtocd    AS DATE      NO-UNDO.    
    DEFINE         INPUT PARAM par_nrdrecid    AS RECID     NO-UNDO.    
    DEFINE        OUTPUT PARAM par_cdcooper    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_nrdconta    AS INT       NO-UNDO.    
    DEFINE        OUTPUT PARAM par_nrcartao    AS DEC       NO-UNDO.
    DEFINE        OUTPUT PARAM par_inpessoa    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_idsenlet    AS LOGICAL   NO-UNDO.
    DEFINE        OUTPUT PARAM par_tpusucar    AS INT       NO-UNDO.
    DEFINE        OUTPUT PARAM par_dscritic    AS CHAR      NO-UNDO.    
    
    DEFINE VARIABLE aux_dtvalida AS DATE                    NO-UNDO.    
    DEFINE VARIABLE h_b1wgen0032 AS HANDLE                  NO-UNDO.

    DEFINE BUFFER crabdat FOR crapdat.
    DEFINE BUFFER crabcrd FOR crapcrd.
    
    FOR crabcrd FIELDS(cdcooper nrdconta nrctrcrd cdadmcrd inacetaa
                       qtsenerr nrcrcard nrcpftit)
                WHERE RECID(crabcrd) = par_nrdrecid
                      NO-LOCK: END.    
    
    FOR crapcop FIELDS(inaleblq nmrescop taamaxer)
                WHERE crapcop.cdcooper = crabcrd.cdcooper
                      NO-LOCK: END.
                      
    IF NOT AVAILABLE crapcop THEN
       DO:
           par_dscritic = "Cooperativa nao cadastrada.".
           RETURN "NOK".              
       END.
    
    FOR FIRST crapdat FIELDS(dtmvtocd)
                      WHERE crapdat.cdcooper = crabcrd.cdcooper 
                            NO-LOCK: END.
                           
    FOR FIRST crabdat FIELDS(dtmvtocd)
                      WHERE crabdat.cdcooper = par_cdcoptfn     
                            NO-LOCK: END.
    
    /* Verificar se datas do sistema Ayllos estão corretas. */  
    IF NOT AVAILABLE crapdat OR 
       NOT AVAILABLE crabdat OR 
       crapdat.dtmvtocd <> crabdat.dtmvtocd THEN
       DO:
           par_dscritic = "Data de sistema invalida.".
           RETURN "NOK".              
        END.
        
    FOR FIRST crapass FIELDS(inpessoa) 
                      WHERE crapass.cdcooper = crabcrd.cdcooper AND
                            crapass.nrdconta = crabcrd.nrdconta 
                            NO-LOCK: END.
                            
    IF NOT AVAILABLE crapass THEN
       DO:
           par_dscritic = "Cooperado nao cadastrado.".
           RETURN "NOK".              
       END.
       
    FOR crawcrd FIELDS(insitcrd flgdebit cdgraupr)
                WHERE crawcrd.cdcooper = crabcrd.cdcooper AND
                      crawcrd.nrdconta = crabcrd.nrdconta AND
                      crawcrd.nrctrcrd = crabcrd.nrctrcrd 
                      NO-LOCK: END.
                            
    IF NOT AVAILABLE crawcrd THEN
       DO:
           par_dscritic = "Cartao invalido.".
           RETURN "NOK".
       END.
       
    IF crabcrd.cdadmcrd < 10 OR crabcrd.cdadmcrd > 80 THEN
       DO:
           par_dscritic = "Cartao invalido.".
           RETURN "NOK".
       END.
       
    /* Verifica se estah habilitado a funcao de debito no cartao */
    IF (crawcrd.flgdebit = FALSE OR crawcrd.cdgraupr = 9) AND
       (par_nrterfin <> 0)                                THEN
       DO:
           par_dscritic = "Operacao nao autorizada.".
           RETURN "NOK".
       END.
    
    IF crawcrd.insitcrd <> 4 THEN
       DO:
          /* Bloqueio/Cancelamento */
          IF crawcrd.insitcrd = 5                           AND 
             CAN-DO("1,2,4,11,16",STRING(crabcrd.cdcooper)) AND
             crapcop.inaleblq = 1                           THEN
             DO:
                RUN envia_email_cartao_bloqueado (INPUT par_cdcoptfn,
                                                  INPUT par_nrterfin,
                                                  INPUT crabcrd.cdcooper,
                                                  INPUT crabcrd.nrdconta,
                                                  INPUT crapcop.nmrescop,
                                                  INPUT "Cartao de Credito " +
                                                        "Bancoob Bloqueado").
             END.              
       
          par_dscritic = "Cartao nao esta liberado.".
          RETURN "NOK".
       END.
    
    /* Verificar se o cartão está com acesso liberado. */
    IF (crabcrd.inacetaa <> 1 OR crabcrd.qtsenerr >= crapcop.taamaxer) AND
       (par_nrterfin <> 0)                                             THEN
       DO:
           par_dscritic = "Acesso bloqueado.".
           RETURN "NOK".
       END.
    
    /* Verificar se o cartão não está vencido. */           
    ASSIGN aux_dtvalida = DATE("01/" + SUBSTR(par_dscartao,22,2) + "/" +
                               SUBSTR(par_dscartao,20,2)) NO-ERROR.
                               
    IF ERROR-STATUS:ERROR THEN
       DO:
           par_dscritic = "Erro na leitura.".
           RETURN "NOK".
       END.
       
    IF YEAR(aux_dtvalida)   < YEAR(par_dtmvtocd)   OR
       (YEAR(aux_dtvalida)  = YEAR(par_dtmvtocd)   AND
        MONTH(aux_dtvalida) < MONTH(par_dtmvtocd)) THEN
       DO:
           par_dscritic = "Cartao esta vencido.".
           RETURN "NOK".
       END. 
    
    /* Obtem administradora do cartão para verificar o tipo de conta */
    FOR crapadc FIELDS(tpctahab)
                WHERE crapadc.cdcooper = crabcrd.cdcooper AND          
                      crapadc.cdadmcrd = crabcrd.cdadmcrd 
                      NO-LOCK: END.
                      
    IF NOT AVAILABLE crapadc THEN
       DO:
           par_dscritic = "Administradora nao cadastrada.".
           RETURN "NOK".
       END.
                            
    /* Conta Física */                        
    IF crapadc.tpctahab = 1 THEN
       DO:
           /* Obtem titular do cartão através do CPF */              
           FOR FIRST crapttl FIELDS(idseqttl)
                             WHERE crapttl.cdcooper = crabcrd.cdcooper AND
                                   crapttl.nrdconta = crabcrd.nrdconta AND
                                   crapttl.nrcpfcgc = crabcrd.nrcpftit 
                                   NO-LOCK: END.
                                   
           IF NOT AVAILABLE crapttl THEN
              DO:
                  par_dscritic = "Titular nao cadastrado.".
                  RETURN "NOK".
              END. 
           
           ASSIGN par_tpusucar = crapttl.idseqttl.
       END.
    ELSE /* Conta Jurídica */
       ASSIGN par_tpusucar = 1.
    
    IF NOT VALID-HANDLE(h_b1wgen0032) THEN
       RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.
    
    RUN verifica-letras-seguranca IN h_b1wgen0032 (INPUT crabcrd.cdcooper,
                                                   INPUT crabcrd.nrdconta,
                                                   INPUT par_tpusucar,
                                                   OUTPUT par_idsenlet).
                                                   
    IF VALID-HANDLE(h_b1wgen0032) THEN                                               
       DELETE PROCEDURE h_b1wgen0032.
    
    ASSIGN par_nrdconta = crabcrd.nrdconta
           par_cdcooper = crabcrd.cdcooper
           par_nrcartao = crabcrd.nrcrcard
           par_inpessoa = crapass.inpessoa.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida_cartao_cecred:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    
    DEFINE OUTPUT PARAM par_idseqttl    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_cdcritic    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    FOR crapcrd FIELDS(cdcooper nrdconta nrctrcrd cdadmcrd nrcpftit inacetaa)
                WHERE crapcrd.cdcooper = par_cdcooper AND
                      crapcrd.nrdconta = par_nrdconta AND
                      crapcrd.nrcrcard = par_nrcartao 
                      NO-LOCK: END.
                      
    IF NOT AVAILABLE crapcrd THEN
       DO:
           par_dscritic = "Cartao nao cadastrado.".
           RETURN "NOK".
       END.
       
    FOR crawcrd FIELDS(insitcrd flgdebit cdgraupr)
                WHERE crawcrd.cdcooper = crapcrd.cdcooper AND
                      crawcrd.nrdconta = crapcrd.nrdconta AND
                      crawcrd.nrctrcrd = crapcrd.nrctrcrd 
                      NO-LOCK: END.
                            
    IF NOT AVAILABLE crawcrd THEN
       DO:
           par_dscritic = "Cartao invalido.".
           RETURN "NOK".              
       END.   
    
    /* Verificar se é cartão de crédito da administradora Bancoob; */
    IF crapcrd.cdadmcrd < 10 OR crapcrd.cdadmcrd > 80 THEN
       DO:
           par_dscritic = "Cartao invalido.".
           RETURN "NOK".
       END.
    
    /* Obtem administradora do cartão para verificar o tipo de conta */
    FOR crapadc FIELDS(tpctahab)
                WHERE crapadc.cdcooper = crapcrd.cdcooper AND          
                      crapadc.cdadmcrd = crapcrd.cdadmcrd 
                      NO-LOCK: END.
                      
    IF NOT AVAILABLE crapadc THEN
       DO:
           par_dscritic = "Administradora nao cadastrada.".
           RETURN "NOK".
       END.
       
    /* Verifica se estah habilitado a funcao de debito no cartao */
    IF crawcrd.flgdebit = FALSE OR crawcrd.cdgraupr = 9 THEN
       DO:
           par_dscritic = "Operacao nao autorizada.".
           RETURN "NOK".
       END.   
       
     /* Verificar se a situacao estah em Entregue */   
    IF crawcrd.insitcrd <> 4 THEN
       DO:
           par_dscritic = "Cartao nao esta liberado.".
           RETURN "NOK".
       END.
     
    /* Verificar se o cartão está com acesso liberado. */
    IF crapcrd.inacetaa <> 1 THEN
       DO:
           ASSIGN par_cdcritic = 625
           par_dscritic = "Acesso bloqueado.".
           RETURN "NOK".
       END.
       
     /* Conta Física */                        
    IF crapadc.tpctahab = 1 THEN
       DO:
           /* Obtem titular do cartão através do CPF */              
           FOR FIRST crapttl FIELDS(idseqttl)
                             WHERE crapttl.cdcooper = crapcrd.cdcooper AND
                                   crapttl.nrdconta = crapcrd.nrdconta AND
                                   crapttl.nrcpfcgc = crapcrd.nrcpftit 
                                   NO-LOCK: END.
                                   
           IF NOT AVAILABLE crapttl THEN
              DO:
                  par_dscritic = "Titular nao cadastrado.".
                  RETURN "NOK".
              END. 
           
           ASSIGN par_idseqttl = crapttl.idseqttl.
       END.
    ELSE /* Conta Jurídica */
       ASSIGN par_idseqttl = 1.
       
    RETURN "OK".
  
END PROCEDURE.

PROCEDURE valida_senha_cartao_cecred:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dssencar    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dtnascto    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_idorigem    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_cdcritic    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    DEF VAR aux_idseqttl LIKE crapttl.idseqttl          NO-UNDO.
    DEF VAR aux_flgcadas AS LOGICAL                     NO-UNDO.
    DEF VAR aux_flgdata  AS LOGICAL                     NO-UNDO.
    DEF VAR h-b1wgen0032 AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE                      NO-UNDO.

    ASSIGN aux_flgdata = NO.

    /* Valida se os dados do cartao cecred estah OK */
    RUN valida_cartao_cecred (INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_nrcartao,
                              OUTPUT aux_idseqttl,
                              OUTPUT par_cdcritic,
                              OUTPUT par_dscritic).
    
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
       
    IF NOT VALID-HANDLE(h-b1wgen0032) THEN
       RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.
    
    RUN verifica-letras-seguranca IN h-b1wgen0032 (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   OUTPUT aux_flgcadas).
                                                   
    IF VALID-HANDLE(h-b1wgen0032) THEN
       DELETE PROCEDURE h-b1wgen0032.
       
    IF NOT aux_flgcadas THEN
       DO:       
           FOR crapass FIELDS(cdcooper nrdconta inpessoa nrcpfppt)
                       WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta 
                             NO-LOCK: END.
                             
           IF AVAILABLE crapass THEN
              DO:
                 IF crapass.inpessoa = 1 THEN
                    DO:
                       FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                              crapttl.nrdconta = crapass.nrdconta
                                              NO-LOCK:
                                      
                           IF par_dtnascto = ENCODE(SUBSTR(STRING(crapttl.nrcpfcgc,"99999999999"),1,4)) THEN
                              ASSIGN aux_flgdata = YES.
                              
                       END. /* END FOR EACH crapttl */
                       
                    END. /* END IF crapass.inpessoa = 1 */
                 ELSE
                    DO:
                        IF par_dtnascto = ENCODE(SUBSTR(STRING(crapass.nrcpfppt,"99999999999"),1,4)) THEN
                           ASSIGN aux_flgdata = YES.
                    END.
              END.
       END.
    ELSE
       ASSIGN aux_flgdata = YES.   

    FIND crapcrd WHERE crapcrd.cdcooper = par_cdcooper AND
                       crapcrd.nrdconta = par_nrdconta AND
                       crapcrd.nrcrcard = par_nrcartao
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE crapcrd THEN
       DO:
           par_dscritic = "Cartao indisponivel.".
           RETURN "NOK".
       END.     
       
    /* Condicao para verificar se o cooperado erro a senha no TAA */
    IF par_dssencar <> crapcrd.dssentaa OR NOT aux_flgdata THEN
       DO:
           ASSIGN crapcrd.qtsenerr = crapcrd.qtsenerr + 1.

           FIND CURRENT crapcrd NO-LOCK.            

           FOR crapcop FIELDS(taamaxer) WHERE crapcop.cdcooper = par_cdcooper
                                              NO-LOCK: END.
                                              
           IF NOT AVAILABLE crapcop THEN
              DO:
                  par_dscritic = "Cooperativa nao encontrada".
                  RETURN "NOK".
              END.

           /* verifica quantidade máxima de senhas erradas */
           IF crapcrd.qtsenerr = crapcop.taamaxer THEN
              DO:
                  IF aux_flgcadas  THEN
                     ASSIGN par_cdcritic = 1392
                            par_dscritic = "     Senha Invalida,      Acesso Bloqueado".
                  ELSE
                     ASSIGN par_cdcritic = 301
                            par_dscritic = " Dados nao conferem,      Acesso Bloqueado".

                  IF NOT VALID-HANDLE(h-b1wgen0028) THEN
                     RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.
       
                  RUN bloquear_cartao_credito_taa 
                   IN h-b1wgen0028(INPUT crapcrd.cdcooper,
                                   INPUT 0,     /* par_cdagenci */
                                   INPUT 0,     /* par_nrdcaixa */
                                   INPUT "1",   /* par_cdoperad */
                                   INPUT crapcrd.nrdconta,
                                   INPUT TODAY, /* par_dtmvtolt */
                                   INPUT 4,     /* par_idorigem */
                                   INPUT "TAA", /* par_nmdatela */
                                   INPUT crapcrd.nrctrcrd,
                                   INPUT crapcrd.nrcrcard,
                                   OUTPUT TABLE tt-erro).
       
                  IF VALID-HANDLE(h-b1wgen0028) THEN
                     DELETE PROCEDURE h-b1wgen0028.
                     
              END. /* END IF crapcrd.qtsenerr = crapcop.taamaxer THEN */
           ELSE
              DO:
                  /* Informa quantas tentativas ainda restam */
                  IF aux_flgcadas  THEN
                     ASSIGN par_cdcritic = 1391
                            par_dscritic = "      Senha Invalida,    Resta(m) " +
                                           STRING(crapcop.taamaxer - crapcrd.qtsenerr,"z9") +
                                           " Tentativa(s)".
                  ELSE
                     ASSIGN par_cdcritic = 301
                            par_dscritic = "  Dados nao conferem,    Resta(m) " +
                                           STRING(crapcop.taamaxer - crapcrd.qtsenerr,"z9") +
                                           " Tentativa(s)".
              END.

           RETURN "NOK".
            
       END.

    /* se acertou a senha e nao tem as letras, zera a quantidade de erros */
    /* se for URA, também zera a quantidade de erros  */
    IF NOT aux_flgcadas OR par_idorigem = 6 THEN
       DO:
           /* zera quantidade de erros de senha */
           ASSIGN crapcrd.qtsenerr = 0.

           FIND CURRENT crapcrd NO-LOCK.
       END.
       
    RETURN "OK".
  
END PROCEDURE.

PROCEDURE valida_senha_cartao_magnetico:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dssencar    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dtnascto    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_idorigem    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_cdcritic    AS INT          NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    DEF VAR aux_flgcadas AS LOGICAL                     NO-UNDO.
    DEF VAR aux_flgdata  AS LOGICAL                     NO-UNDO.
    DEF VAR h_b1wgen0032 AS HANDLE                      NO-UNDO.    
    
    ASSIGN aux_flgdata  = NO.
    
    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper  AND
                       crapcrm.nrdconta = par_nrdconta  AND
                       crapcrm.nrcartao = par_nrcartao
                       NO-LOCK NO-ERROR.
                                                       
    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            par_dscritic = "Cartao nao cadastrado.".
            RETURN "NOK".
        END.


    /* se a situacao nao estiver ativa no momento EXATO da validacao de senha */
    IF  crapcrm.cdsitcar <> 2  THEN
        DO:
            par_dscritic = "Cartao Invalido.".
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

    IF  VALID-HANDLE(h_b1wgen0032)  THEN
        DO:
            RUN verifica-letras-seguranca IN h_b1wgen0032 
                                         (INPUT crapcrm.cdcooper,
                                          INPUT crapcrm.nrdconta,
                                          INPUT crapcrm.tpusucar,
                                         OUTPUT aux_flgcadas).

            DELETE PROCEDURE h_b1wgen0032.
        END.
    
    /* se nao possui senha de letras, valida o cpf */
    IF  crapcrm.tpcarcta <> 9  AND
        NOT aux_flgcadas       THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                               crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.
            
            IF  AVAIL crapass  THEN
                DO:
                    IF  crapass.inpessoa = 1  THEN
                        DO: 
                            FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                                   crapttl.nrdconta = crapass.nrdconta NO-LOCK:
                    
                                IF  par_dtnascto = ENCODE(SUBSTRING(STRING(crapttl.nrcpfcgc,"99999999999"),1,4))  THEN
                                    aux_flgdata = YES.
                            END.
                        END.
                    ELSE
                        DO:
                            IF  par_dtnascto = ENCODE(SUBSTR(STRING(crapass.nrcpfppt,"99999999999"),1,4))   THEN
                                aux_flgdata = YES.
                        END.
                END.
        END.
    ELSE
        /* nao associado eh operador */
        aux_flgdata = YES.


    FIND CURRENT crapcrm EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            par_dscritic = "Cartao indisponivel.".
            RETURN "NOK".
        END.

    /* se errou a senha */
    IF  par_dssencar <> crapcrm.dssencar OR
        NOT aux_flgdata                  THEN 
        DO:
            crapcrm.qtsenerr = crapcrm.qtsenerr + 1.

            FIND CURRENT crapcrm NO-LOCK.

            FIND crapcop WHERE crapcop.cdcooper = crapcrm.cdcooper  NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapcop  THEN
                DO:
                    par_dscritic = "Cooperativa nao encontrada".
                    RETURN "NOK".
                END.


            /* verifica quantidade máxima de senhas erradas */
            IF  crapcrm.qtsenerr = crapcop.taamaxer  THEN
                DO:
                    IF  aux_flgcadas  THEN
                    DO:
                      ASSIGN par_cdcritic = 1392
                             par_dscritic = "     Senha Invalida,      Cartao Bloqueado".
                    END.
                    ELSE
                      ASSIGN par_cdcritic = 301
                        par_dscritic = " Dados nao conferem,      Cartao Bloqueado".

                    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

                    RUN bloquear-cartao-magnetico IN h_b1wgen0032
                                            (INPUT crapcrm.cdcooper,
                                             INPUT 0,                   /* pac */
                                             INPUT 0,                   /* caixa */ 
                                             INPUT "1",                 /* operador */
                                             INPUT "TAA",               /* tela */
                                             INPUT 4,                   /* origem 4-TAA */
                                             INPUT crapcrm.nrdconta,
                                             INPUT 1,                   /* titular - nao usa para achar o cartao */
                                             INPUT TODAY,               /* data da transacao */
                                             INPUT crapcrm.nrcartao,
                                             INPUT YES,                 /* gerar log */
                                            OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h_b1wgen0032.
                END.
            ELSE
                DO:
                    /* Informa quantas tentativas ainda restam */
                    IF  aux_flgcadas  THEN
                    DO:
                        ASSIGN par_cdcritic = 1391
                        par_dscritic = "      Senha Invalida,    Resta(m) " +
                                       STRING(crapcop.taamaxer - crapcrm.qtsenerr,"z9") +
                                       " Tentativa(s)".
                    END.
                    ELSE
                    DO:
                      ASSIGN par_cdcritic = 301
                        par_dscritic = "  Dados nao conferem,    Resta(m) " +
                                       STRING(crapcop.taamaxer - crapcrm.qtsenerr,"z9") +
                                       " Tentativa(s)".
                END.
                END.


            RETURN "NOK".
        END.


    /* se acertou a senha e nao tem as letras, zera a quantidade de erros */
    /* se for URA, também zera a quantidade de erros */
    IF  NOT aux_flgcadas OR par_idorigem = 6 THEN
        DO:
            /* zera quantidade de erros de senha */
            crapcrm.qtsenerr = 0.

            FIND CURRENT crapcrm NO-LOCK.
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_senha_letras_cartao_cecred:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup1    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup2    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup3    AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    DEFINE VARIABLE aux_flsenlet AS LOGICAL             NO-UNDO.
    DEFINE VARIABLE aux_idseqttl LIKE crapttl.idseqttl  NO-UNDO.
    DEFINE VARIABLE h-b1wgen0028 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE aux_cdcritic AS INT                 NO-UNDO.
    
    /* Valida se os dados do cartao cecred estah OK */
    RUN valida_cartao_cecred (INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_nrcartao,
                              OUTPUT aux_idseqttl,
                              OUTPUT aux_cdcritic,
                              OUTPUT par_dscritic).
    
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
    
    /* Valida os dados das letras de seguranca de estah OK */
    RUN valida_letras_seguranca (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT par_dsdgrup1,
                                 INPUT par_dsdgrup2,
                                 INPUT par_dsdgrup3,
                                 INPUT TRUE,
                                 OUTPUT aux_flsenlet,
                                 OUTPUT par_dscritic).
   
    IF RETURN-VALUE <> "OK" THEN
       DO:
           IF par_dscritic = "" THEN
              ASSIGN par_dscritic = "Cartao Invalido.".

           RETURN "NOK".
       END.
   
    /* verifica a cooperativa - parametro de quantidade de erros */
    FOR crapcop FIELDS(taamaxer) WHERE crapcop.cdcooper = par_cdcooper
                                       NO-LOCK: END.

    IF NOT AVAILABLE crapcop THEN
       DO:
           par_dscritic = "Cooperativa nao encontrada.".
           RETURN "NOK".
       END.
        
    FIND crapcrd WHERE crapcrd.cdcooper = par_cdcooper AND
                       crapcrd.nrdconta = par_nrdconta AND
                       crapcrd.nrcrcard = par_nrcartao
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE crapcrd THEN
       DO:
           par_dscritic = "Cartao indisponivel.".
           RETURN "NOK".
       END.     
       
    IF NOT aux_flsenlet THEN
       DO:
           ASSIGN crapcrd.qtsenerr = crapcrd.qtsenerr + 1.
           
           FIND CURRENT crapcrd NO-LOCK. 
           
           /* Verifica a quantidade máxima de senhas erradas */
           IF crapcrd.qtsenerr >= crapcop.taamaxer  THEN
              DO:
                  ASSIGN par_dscritic = "Senha Invalida, Acesso Bloqueado".

                  IF NOT VALID-HANDLE(h-b1wgen0028) THEN
                     RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.
       
                  RUN bloquear_cartao_credito_taa                   
                   IN h-b1wgen0028(INPUT crapcrd.cdcooper,
                                   INPUT 0,     /* par_cdagenci */
                                   INPUT 0,     /* par_nrdcaixa */
                                   INPUT "1",   /* par_cdoperad */
                                   INPUT crapcrd.nrdconta,
                                   INPUT TODAY, /* par_dtmvtolt */
                                   INPUT 4,     /* par_idorigem */
                                   INPUT "TAA", /* par_nmdatela */
                                   INPUT crapcrd.nrctrcrd,
                                   INPUT crapcrd.nrcrcard,
                                   OUTPUT TABLE tt-erro).
       
                  IF VALID-HANDLE(h-b1wgen0028) THEN
                     DELETE PROCEDURE h-b1wgen0028.
              END.
           ELSE
              /* Informa quantas tentativas ainda restam */
              ASSIGN par_dscritic = "      Senha Invalida,    Resta(m) " +
                                    STRING(crapcop.taamaxer - crapcrd.qtsenerr,"z9") +
                                    " Tentativa(s)".


           RETURN "NOK".
            
       END. /* END IF NOT aux_flgsenlet THEN */
    ELSE
       DO:
           /* zera quantidade de erros de senha */
           ASSIGN crapcrd.qtsenerr = 0.
           
           FIND CURRENT crapcrd NO-LOCK.
       END.
        
    RETURN "OK".
    
END.

PROCEDURE valida_senha_letras_cartao_magnetico:

    DEFINE  INPUT PARAM par_cdcooper    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao    AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup1    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup2    AS CHAR         NO-UNDO.
    DEFINE  INPUT PARAM par_dsdgrup3    AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic    AS CHAR         NO-UNDO.

    DEFINE VARIABLE     aux_flsenlet    AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE     h_b1wgen0032    AS HANDLE       NO-UNDO.    
    
    /* verifica a cooperativa - parametro de quantidade de erros */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop   THEN
        DO:
            par_dscritic = "Cooperativa nao encontrada.".
            RETURN "NOK".
        END.


    /* verifica o cartao */
    FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper  AND
                       crapcrm.nrdconta = par_nrdconta  AND
                       crapcrm.nrcartao = par_nrcartao
                       NO-LOCK NO-ERROR.
                                                       
    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            par_dscritic = "Cartao nao cadastrado.".
            RETURN "NOK".
        END.

    /* se a situacao nao estiver ativa no momento EXATO da validacao de senha */
    IF  crapcrm.cdsitcar <> 2  THEN
        DO:
            par_dscritic = "Cartao Invalido.".
            RETURN "NOK".
        END.

    RUN valida_letras_seguranca (INPUT crapcrm.cdcooper,
                                 INPUT crapcrm.nrdconta,
                                 INPUT crapcrm.tpusucar,
                                 INPUT par_dsdgrup1, 
                                 INPUT par_dsdgrup2, 
                                 INPUT par_dsdgrup3, 
                                 INPUT TRUE,
                                OUTPUT aux_flsenlet,
                                OUTPUT par_dscritic).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            IF  par_dscritic = ""  THEN
                par_dscritic = "Cartao Invalido.".

            RETURN "NOK".
        END.

    
    FIND CURRENT crapcrm EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crapcrm   THEN
        DO:
            par_dscritic = "Cartao indisponivel.".
            RETURN "NOK".
        END.


    IF  NOT aux_flsenlet  THEN
        DO:
            crapcrm.qtsenerr = crapcrm.qtsenerr + 1.

            FIND CURRENT crapcrm NO-LOCK.


            /* Verifica a quantidade máxima de senhas erradas */
            IF  crapcrm.qtsenerr >= crapcop.taamaxer  THEN
                DO:
                    par_dscritic = "Senha Invalida, Cartao Bloqueado".

                    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

                    RUN bloquear-cartao-magnetico IN h_b1wgen0032
                                            (INPUT crapcrm.cdcooper,
                                             INPUT 0,                   /* pac */
                                             INPUT 0,                   /* caixa */ 
                                             INPUT "1",                 /* operador */
                                             INPUT "TAA",               /* tela */
                                             INPUT 4,                   /* origem 4-TAA */
                                             INPUT crapcrm.nrdconta,
                                             INPUT 1,                   /* titular - nao usa para achar o cartao */
                                             INPUT TODAY,               /* data da transacao */
                                             INPUT crapcrm.nrcartao,
                                             INPUT YES,                 /* gerar log */
                                            OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h_b1wgen0032.
                END.
            ELSE
                /* Informa quantas tentativas ainda restam */
                par_dscritic = "      Senha Invalida,    Resta(m) " +
                               STRING(crapcop.taamaxer - crapcrm.qtsenerr,"z9") +
                               " Tentativa(s)".


            RETURN "NOK".
        END.
    ELSE
        DO:
            /* zera quantidade de erros de senha */
            crapcrm.qtsenerr = 0.

            FIND CURRENT crapcrm NO-LOCK.           
            
        END.
        
    RETURN "OK".    
    
END.

PROCEDURE alterar-senha-cartao-credito:

    DEFINE  INPUT PARAM par_cdcooper AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrdconta AS INT          NO-UNDO.
    DEFINE  INPUT PARAM par_nrcartao AS DEC          NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt AS DATE         NO-UNDO.   
    DEFINE  INPUT PARAM par_dssencar AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic AS CHAR         NO-UNDO.
    
    DEF VAR h-b1wgen0028 AS HANDLE                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FOR crapcrd FIELDS(nrctrcrd)
                WHERE crapcrd.cdcooper = par_cdcooper AND
                      crapcrd.nrdconta = par_nrdconta AND
                      crapcrd.nrcrcard = par_nrcartao 
                      NO-LOCK: END.
                      
    IF NOT AVAILABLE crapcrd THEN
       DO:
           par_dscritic = "Cartao nao cadastrado.".
           RETURN "NOK".
       END.
       
    IF NOT VALID-HANDLE(h-b1wgen0028) THEN
       RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.
    
    /* Valida os dados da senha numerica do TAA */
    RUN valida_dados_senha_numerica_taa IN h-b1wgen0028(INPUT par_cdcooper,
                                                        INPUT 91,    /* par_cdagenci */
                                                        INPUT 999,   /* par_nrdcaixa */
                                                        INPUT "996", /* par_cdoperad */
                                                        INPUT par_nrdconta,
                                                        INPUT par_dtmvtolt,
                                                        INPUT 4,     /* par_idorigem */
                                                        INPUT "TAA", /* par_nmdatela */
                                                        INPUT par_nrcartao,
                                                        INPUT crapcrd.nrctrcrd,
                                                        OUTPUT TABLE tt-erro). 
     
    IF RETURN-VALUE <> "OK" THEN
       DO:
           IF VALID-HANDLE(h-b1wgen0028) THEN
              DELETE PROCEDURE h-b1wgen0028. 
             
           FIND FIRST tt-erro NO-LOCK NO-ERROR.            
           IF AVAILABLE tt-erro THEN
              ASSIGN par_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN par_dscritic = "Erro na validacao da senha".
              
           RETURN "NOK".
       END.
    
    /* Valida os dados de gravacao da senha numerica do taa */
    RUN grava_dados_senha_numerica_taa IN h-b1wgen0028 (INPUT par_cdcooper,
                                                        INPUT 91,    /* par_cdagenci */
                                                        INPUT 999,   /* par_nrdcaixa */
                                                        INPUT "996", /* par_cdoperad */
                                                        INPUT par_nrdconta,
                                                        INPUT par_dtmvtolt,
                                                        INPUT 4,     /* par_idorigem */
                                                        INPUT "TAA", /* par_nmdatela */
                                                        INPUT par_nrcartao,
                                                        INPUT par_dssencar,
                                                        INPUT par_dssencar,
                                                        INPUT TRUE,
                                                        OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0028) THEN
       DELETE PROCEDURE h-b1wgen0028. 
       
    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.            
           IF AVAILABLE tt-erro THEN
              ASSIGN par_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN par_dscritic = "Erro na gravacao da senha".
              
           RETURN "NOK".       
       END.

    RETURN "OK".
    
END.

PROCEDURE busca_numero_conta:

    DEFINE INPUT  PARAM par_nrcrcard AS DEC                 NO-UNDO.
    DEFINE OUTPUT PARAM par_nrdconta AS INT                 NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic AS CHAR                NO-UNDO.

    FOR FIRST crapcrd, crapcop FIELDS(nrdconta) 
                      WHERE crapcrd.nrcrcard = par_nrcrcard
          AND crapcop.cdcooper = crapcrd.cdcooper
          AND crapcop.flgativo = TRUE
                            NO-LOCK: END.
    
    /* Cartao de credito CECRED */
    IF AVAILABLE crapcrd THEN
       ASSIGN par_nrdconta = crapcrd.nrdconta.
    ELSE
       ASSIGN par_nrdconta = INTEGER(SUBSTRING(STRING(par_nrcrcard),08,08)).
    
    RETURN "OK".
      
END PROCEDURE.

PROCEDURE valida_senha_tp_cartao:
    
    DEFINE   INPUT PARAM par_cdcooper    AS INT                   NO-UNDO.
    DEFINE   INPUT PARAM par_nrdconta    AS INT                   NO-UNDO.
    DEFINE   INPUT PARAM par_nrcrcard    AS DEC                   NO-UNDO.
    DEFINE   INPUT PARAM par_idtipcar    AS INT                   NO-UNDO.    
    DEFINE   INPUT PARAM par_dssencar    AS CHAR                  NO-UNDO.
    DEFINE   INPUT PARAM par_infocry     AS CHAR                  NO-UNDO.
    DEFINE   INPUT PARAM par_chvcry      AS CHAR                  NO-UNDO.    
    DEFINE  OUTPUT PARAM par_cdcritic    AS INT                   NO-UNDO.
    DEFINE  OUTPUT PARAM par_dscritic    AS CHAR                  NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
    DEF VAR aux_dspnblcr AS CHAR                                  NO-UNDO.

    IF  par_idtipcar = 1 THEN /* MAGNÉTICO */        
        DO:
            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper   AND
                               crapcrm.nrcartao = par_nrcrcard 
                               NO-LOCK NO-ERROR.
     
            IF  NOT AVAIL crapcrm   THEN
                DO:
                    FIND FIRST craptco WHERE  craptco.cdcooper = par_cdcooper AND
                                              craptco.nrctaant = INTE(SUBSTR(STRING(par_nrcrcard), 8, 8)) AND
                                              craptco.flgativo = TRUE
                                              NO-LOCK NO-ERROR.
                    IF  AVAIL craptco THEN
                        DO:
                            FIND crapcrm WHERE  crapcrm.cdcooper = craptco.cdcopant   AND
                                                crapcrm.nrcartao = par_nrcrcard 
                                                NO-LOCK NO-ERROR.
                          
                            IF  NOT AVAIL crapcrm   THEN
                                DO: 
                                    ASSIGN par_cdcritic  = 0
                                           par_dscritic = "Cartao nao encontrado. (01)".
                                    RETURN "NOK".
                                END.
                        END.
                END.
                  
            /* contém valores vindos da utilizaçao do PinPad Novo */
            IF  par_infocry <> ""   AND
                par_chvcry  <> ""   THEN
                DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                     
                    /* Efetuar a chamada a rotina Oracle  */
                    RUN STORED-PROCEDURE pc_get_pin_block_car
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_infocry, 
                                                             INPUT par_chvcry,
                                                            OUTPUT "",
                                                            OUTPUT 0,            /* Código da crítica */
                                                            OUTPUT "",           /* Descrição da crítica */                                     
                                                            OUTPUT "", 
                                                            OUTPUT "").
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_get_pin_block_car
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                     
                    /* Busca possíveis erros */ 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_get_pin_block_car.pr_cdcritic 
                                          WHEN pc_get_pin_block_car.pr_cdcritic <> ?
                           aux_dscritic = pc_get_pin_block_car.pr_dscritic 
                                          WHEN pc_get_pin_block_car.pr_dscritic <> ?
                           aux_dspnblcr = pc_get_pin_block_car.pr_dspnblcr 
                                          WHEN pc_get_pin_block_car.pr_dspnblcr <> ?.
                                          
                    IF  aux_cdcritic <> 0   OR
                        aux_dscritic <> ""  THEN                        
                        DO:                            
                            ASSIGN par_cdcritic  = aux_cdcritic
                                   par_dscritic  = aux_dscritic.
                            RETURN "NOK".                               
                         END.
                       
                    IF  TRIM(aux_dspnblcr) = ""   THEN
                        DO:
                            ASSIGN par_cdcritic  = 0
                                   par_dscritic  = "Erro na verificacao de senha. (01)".
                            RETURN "NOK".
                        END.
                       
                    IF  crapcrm.dssenpin <> TRIM(aux_dspnblcr)   THEN
                        DO:
                            ASSIGN par_cdcritic  = 0
                                   par_dscritic  = "Senha do cartao incorreta. (01)".
                            RETURN "NOK".
                        END.
                END. /* PinPad Novo */
            ELSE 
                DO:                                                           
                    IF  crapcrm.dssencar <> ENCODE(par_dssencar)   THEN
                        DO:
                            ASSIGN par_cdcritic  = 0
                                   par_dscritic  = "Senha do cartao incorreta. (01)".
                            RETURN "NOK".
                        END.
                END.
        END.
    ELSE /* CARTAO CECRED */
        DO:            
            FIND FIRST crapcrd WHERE crapcrd.cdcooper = par_cdcooper AND
                                     crapcrd.nrdconta = par_nrdconta AND
                                     crapcrd.nrcrcard = par_nrcrcard
                                     NO-LOCK NO-ERROR NO-WAIT.
                                     
            IF  NOT AVAILABLE crapcrd THEN
                DO:
                    ASSIGN par_cdcritic  = 0
                           par_dscritic  = "Erro na obtencao de dados do cartao AILOS.".
                    RETURN "NOK".
                END.
                
            /* contém valores vindos da utilizaçao do PinPad Novo */
            IF  par_infocry <> ""   AND
                par_chvcry  <> ""   THEN
                DO:
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

                   /* Efetuar a chamada a rotina Oracle  */
                   RUN STORED-PROCEDURE pc_get_pin_block_car
                       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_infocry, 
                                                            INPUT par_chvcry,
                                                           OUTPUT "",
                                                           OUTPUT 0,            /* Código da crítica */
                                                           OUTPUT "",           /* Descrição da crítica */                                     
                                                           OUTPUT "", 
                                                           OUTPUT "").

                   /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_get_pin_block_car
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                   
                   /* Busca possíveis erros */ 
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = ""
                          aux_cdcritic = pc_get_pin_block_car.pr_cdcritic 
                                         WHEN pc_get_pin_block_car.pr_cdcritic <> ?
                          aux_dscritic = pc_get_pin_block_car.pr_dscritic 
                                         WHEN pc_get_pin_block_car.pr_dscritic <> ?
                          aux_dspnblcr = pc_get_pin_block_car.pr_dspnblcr 
                                         WHEN pc_get_pin_block_car.pr_dspnblcr <> ?.

                   IF  aux_cdcritic <> 0 OR
                       aux_dscritic <> "" THEN
                       DO:
                          ASSIGN par_cdcritic  = aux_cdcritic
                                 par_dscritic  = aux_dscritic.
                          RETURN "NOK".                               
                       END.
                     
                   IF  TRIM(aux_dspnblcr) = ""   THEN
                       DO:
                          ASSIGN par_cdcritic  = 0
                                 par_dscritic  = "Erro na verificacao de senha (02).".
                          RETURN "NOK".
                       END.
                   
                   IF  crapcrd.dssenpin <> TRIM(aux_dspnblcr)   THEN
                       DO:
                          ASSIGN par_cdcritic  = 0
                                 par_dscritic  = "Senha do cartao incorreta. (02)".
                          RETURN "NOK".
                       END.
                END. /* PinPad Novo */
            ELSE
                DO:
                   IF   crapcrd.dssentaa <> ENCODE(par_dssencar)   THEN
                        DO:
                            ASSIGN par_cdcritic  = 0
                                   par_dscritic = "Senha do cartao incorreta. (02)".
                            RETURN "NOK".
                        END.
                END.                        
        END.  /* FIM CARTAO CECRED */
    
    RETURN "OK".
      
END PROCEDURE.


/* .......................................................................... */
