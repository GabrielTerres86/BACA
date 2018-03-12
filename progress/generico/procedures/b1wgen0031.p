
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | procedures/b1wgen0031.p         |                                         |
  |   obtem-mensagens-alerta        | CADA0004.pc_obtem_mensagens_alerta      |
  |   verifica-vigencia-procurador  | CADA0004.pc_verif_vig_procurador        |
  |   valida_socios	                | CADA0004.pc_valida_socios               |
  |   Criticas_AltoVale             | CADA0004.pc_ret_criticas_altovale       |
  |                                 |                                         |  
  +---------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL ZIMMERMANN    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/
/*.............................................................................

    Programa: b1wgen0031.p
    Autor   : Guilherme/David
    Data    : Julho/2008                     Ultima Atualizacao: 30/11/2017
           
    Dados referentes ao programa:
                
    Objetivo  : BO de uso para Anotacoes e Mensagens criadas para a conta.
                    
    Alteracoes: 29/07/2009 - Acerto nas mensagens de fiador de emprestimo
                             (Guilherme).
   
                11/11/2009 - Ajuste para o novo Termo de Adesao - retirar o 
                             antigo Termo CI e Termo BANCCOB (Fernando).
                             
                11/10/2010 - Procedure para verificar vigencia dos 
                             procuradores (Gabrile, DB1).
                             
                07/12/2010 - Procedure com lógica de exibição das mensagens
                             da tela de Contas (Gabrile, DB1).
                             
                26/01/2011 - Ajuste na vericacao de fiadores em atraso (David).
                
                04/02/2011 - Incluir parametro par_flgcondc na procedure 
                             obtem-dados-emprestimos  (Gabriel - DB1).
                             
                18/03/2011 - Eliminar procedure busca_anota (David).
                
                28/06/2011 - Incluida procedure busca-alteracoes utilizada pela
                             tela ALTERA (Henrique).
                             
                27/07/2011 - Adicionado verificacao de demissao do contato 
                             em procedure obtem-mensagens-alerta (Jorge).
                             
                30/11/2011 - Criado procedure valida_socios. (Fabricio)
                
                24/02/2012 - Ajuste na procedure valida_socios para gerar
                             mensagens quando gncdntj.flgprsoc = true 
                             (Adriano).

                12/03/2012 - Msg cadastramento letras de seguranca (Guilherme).

                17/07/2012 - Tratar atraso do novo emprestimo (Gabriel).

                30/08/2012 - Incluir mensagens de alerta para a Viacredi
                             AltoVale (Gabriel).

                07/11/2012 - Utilização da procedure 'verifica-letras-seguranca'
                             para geração da mensagem de alerta (Lucas).

                12/11/2012 - Retirar matches dos find/for each (Gabriel).   

                21/12/2012 - Realizado a chamada da funcao verificacao_bloqueio
                             nas procedures obtem-mensagens-alerta,
                             obtem-mensagens-alerta-contas referente ao
                             projeto Prova de Vida (Adriano).

                18/01/2013 - Alterado consulta da crapttl para olhar tambem
                             o cpf da tt-crapris para so entao criticar com
                             16 (Tiago).  

                21/02/2013 - Ajustes realizados:
                             - Na procedure obtem-mensagens-alerta sera 
                               verificado, se a conta em questao for uma conta 
                               migrada da Viacredi Alto Vale entao, na funcao
                               verificacao_bloqueio sera verificado os 
                               beneficios desta conta na Viacredi;
                             - Retirado a chamada da funcao verificacao_bloqueio
                               dentro da procedure obtem-mensagens-alerta-contas.
                             - Criado a procedure bloqueio_prova_vida
                               (Adriano).

                11/06/2013 - RATING BNDES (Guilherme/Supero)
                
                12/08/2013 - Incluir Chamada da procedure retorna-valor-blqjud
                             que verifica se cooperado possui vlr bloq jud
                             (Lucas R.)
                
                01/07/2013 - Leitura de crapavt p/ impressao de cartão assinatura.
                             (Jean Michel)
                             
                03/09/2013 - Mensagem de aviso quando o cooperado possuir conta 
                             salario ativa (Carlos)

                04/10/2013 - Incluido mensagem de na tela ATENDA, referente ao
                             cartao de assinatura do resposavel legal 
                             (Jean Michel)
                             
                18/12/2013 - Incluir mensagens de alerta para a Viacredi
                             (Reinert).     
                             
                11/03/2014 - Correcao fechamento instancia b1wgen0002 (Daniel)
                
                17/03/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                             
                16/07/2014 - Incluido alerta de emprestimo BNDES em prejuizo
                             (Diego).
                             
                13/08/2014 - Inclusao de alerta de Credito Pre Aprovado
                             (Jaison)
                
                22/08/2014 - Adicionado condicao crapcrm.tptitcar <> 9 na 
                             "obtem-mensagens-alerta" para nao exibir mensagem 
                             quando encontrar cartao de operador para uma 
                             conta válida (Douglas - Chamado 151984)
                             
                05/09/2014 - Projeto Automatização de Consultas em 
                             Propostas de Crédito (Jonata/RKAM).

                11/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                             procedure "busca_dados" da "b1wgen0188". (Jaison)
                             
                16/01/2015 - Ajuste na procedure "obtem-mensagens-alerta" para
                             usar a quantidade de dias de vigencia do limite.
                             (James)
                
                22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                
                09/03/2015 - #257426 Troca de consulta de crapass do cooperado
                             crapavt.nrdctato por b-crapass para nao conflitar
                             com o registro crapass principal (Carlos)
                             
                30/03/2015 - Melhorias na tela CADCYB (Jonata-RKAM).
                
                07/04/2015 - Criado proc. obtem-msg-credito-atraso para 
                             Mensagens de operacao de credito em atraso. 
                             (Jorge/Rodrigo)  
                             
                18/06/2015 - Notificacao dos usuarios sobre os contratos de portabilidade
                             liquidados que ainda aparecem na tela ATENDA->PRESTACOES
                             Projeto Portabilidade de Credito(Carlos Rafael Tanholi)  
                             
                19/10/2015 - Projeto Reformulacao cadastral (Tiago Castro - RKAM). 
                
                20/10/2015 - Excluido o LEAVE da proceure obtem-mensagens-alerta
                             da condicao aux_epr_portabilidade <> "" para chamada da procedure
                             cria-registro-msg (Carlos Rafael Tanholi).
                             
                20/10/2015 - Incluido verificacao de cartoes Bancoob ativos na verificação
                             de letras de segurança na procedure obtem-mensagens-alerta
                             (Jean Michel).
                             
                28/10/2015 - Incluido mensagem de alerta para boletos de contrato
                             em aberto do cooperado. Projeto 210. (Rafael)
                             
                09/11/2015 - Incluir mensagem de cartao rejeitado na rotina
                             obtem-mensagens-alerta Projeto 126 - DV4 (Odirlei-AMcom)
                             
                10/11/2015 - Incluido verificacao para impressao de termo de
                             responsabilidade na procedure obtem-mensagens-alerta.
                             (Jean Michel)
                             
                01/12/2015 - Alterar validacao de contratos em cobrança no 
                             CYBER na procedure obtem-mensagens-alerta
                             Verificar na cracyc ao inves da crapcyb
                             (Douglas)
                
                22/01/2016 - Adicionada verificacao de comprovacao de vida na 
                             procedure obtem-mensagens-alerta-contas.
                             Projeto 255 - INSS (Lombardi).
                
				09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						     aux_qtminast referente a quantidade minima de assinatura
						     conjunta na procedure obtem-mensagens-alerta,
						     SD 514239 (Jean Michel).
                
                22/09/2016 - Alterado rotina obtem-mensagens-alerta 
                             para buscar o qtd dias de renovacao da tabela craprli
								  			     PRJ300 - Desconto de cheque (Odirlei-AMcom)             
                
                30/01/2017 - Exibir mensagem quando Cooperado/Fiador atrasar emprestimo Pos-Fixado.
                             (Jaison/James - PRJ298)

							
                30/11/2017 - Ajuste na verifica_prova_vida_inss - Chamado 784845 - 
				             Prova de vida nao aparecendo na AV - Andrei - Mouts							


                
.............................................................................*/

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/b1wgen0191tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.

DEF BUFFER crabass FOR crapass.
DEF BUFFER b-crapass FOR crapass.


/*****************************************************************************/
/**            Procedure obter mensagens de alerta para uma conta           **/
/*****************************************************************************/
PROCEDURE obtem-mensagens-alerta:

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
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens-atenda.
    
    DEF VAR h-b1wgen0002  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0060  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0032  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0058  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0091  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0155  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0188  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0025 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_flgpreju AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgcadas AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsprejuz AS CHAR                                    NO-UNDO.
    DEF VAR aux_vltotprv AS DECI                                    NO-UNDO.
    DEF VAR aux_qtempatr AS INTE                                    NO-UNDO.
    DEF VAR aux_dsvigpro AS CHAR                                    NO-UNDO.
    DEF VAR aux_sralerta AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_qttitula AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgachou AS LOGI                                    NO-UNDO.
    DEF VAR aux_tpbloque AS INT                                     NO-UNDO.
    DEF VAR aux_vlblqjud AS DECI                                    NO-UNDO.
    DEF VAR aux_vlresblq AS DECI                                    NO-UNDO.
    DEF VAR aux_flbndand AS LOGI                                    NO-UNDO.
    DEF VAR aux_flbndatr AS LOGI                                    NO-UNDO.
    DEF VAR aux_flbndnor AS LOGI                                    NO-UNDO.
    DEF VAR aux_flbndprj AS LOGICAL                                 NO-UNDO.
    DEF VAR flg_digitlib AS CHAR                                    NO-UNDO.  
    DEF VAR aux_titulare AS CHAR                                    NO-UNDO.  
    DEF VAR aux_flgexist AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_epr_portabilidade AS CHAR                           NO-UNDO.
    DEF VAR par_flgdinss AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_flgbinss AS LOGICAL                                 NO-UNDO.
    DEF VAR par_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtminast AS INTE								    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter mensagens de alerta para tela ATENDA.".
           

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAILABLE crapass  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                          
           RETURN "NOK".                   

       END.
                              
    FIND craptrf WHERE craptrf.cdcooper = par_cdcooper AND
                       craptrf.nrdconta = par_nrdconta AND
                       craptrf.tptransa = 1            AND
                       craptrf.insittrs = 2            
                       NO-LOCK NO-ERROR.

    IF AVAILABLE craptrf  THEN
       RUN cria-registro-msg ("Conta transferida para " +
                              TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")) +
                              ".").

    FIND craptab WHERE  craptab.cdcooper = par_cdcooper    AND
                        craptab.nmsistem = "CRED"          AND
                        craptab.tptabela = "GENERI"        AND
                        craptab.cdempres = 00              AND
                        craptab.cdacesso = "DIGITALIBE"    AND
                        craptab.tpregist = 1  NO-LOCK NO-ERROR.

    ASSIGN flg_digitlib = ENTRY(1,craptab.dstextab,";").
    
    /** Mensagem impressao de cartao de assinatura **/
    IF flg_digitlib = "S" THEN
        DO:
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                           crapavt.nrdconta = par_nrdconta          AND
                           crapavt.tpctrato = 6                     AND
                           crapavt.flgimpri = TRUE 
                           NO-LOCK:
    
           IF crapavt.nrdctato <> 0 THEN
              DO:
                    FIND b-crapass WHERE b-crapass.cdcooper = par_cdcooper AND
                                         b-crapass.nrdconta = crapavt.nrdctato
                                         NO-LOCK NO-ERROR.
    
                    RUN cria-registro-msg ("Imprimir Cartao de Assinatura - Procurador: " + b-crapass.nmprimtl).
    
              END.
           ELSE
                RUN cria-registro-msg ("Imprimir Cartao de Assinatura - Procurador: " + crapavt.nmdavali).
            
        END.
    
        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.flgimpri = TRUE AND 
                               (crapttl.idseqttl = 1 OR
                               crapttl.idseqttl = 2 OR 
                               crapttl.idseqttl = 3 OR 
                               crapttl.idseqttl = 4) NO-LOCK:
            
            RUN cria-registro-msg ("Imprimir Cartao de Assinatura - Titular: " + crapttl.nmextttl).
    
        END.

        FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                               crapcrl.nrctamen = par_nrdconta AND
                               crapcrl.flgimpri = TRUE NO-LOCK:
            
            IF crapcrl.nmrespon <> "" THEN
                RUN cria-registro-msg ("Imprimir Cartao de Assinatura - Responsavel Legal: " + crapcrl.nmrespon).
            ELSE
                DO:
                    FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = crapcrl.nrdconta and
                                       crapttl.idseqttl = 1 NO-LOCK. 

                    RUN cria-registro-msg ("Imprimir Cartao de Assinatura - Responsavel Legal: " + crapttl.nmextttl).
                END.
    
        END.
    END.
    
    /** Mensagem entrega de cartao **/
    FIND LAST crapcrm WHERE crapcrm.cdcooper  = par_cdcooper AND
                            crapcrm.nrdconta  = par_nrdconta AND
                            crapcrm.tptitcar <> 9            AND /* Tipo Titular Cartão <> 9 (Operador) */
                            crapcrm.dtcancel  = ?            AND
                            crapcrm.dtemscar <> ?            AND
                            crapcrm.dtentcrm  = ?            
                            NO-LOCK NO-ERROR. 
                               
    IF AVAILABLE crapcrm  THEN
       DO:
          FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "AUTOMA"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "CM" +     
                                             STRING(crapcrm.dtemscar,
                                                    "99999999") AND  
                             craptab.tpregist = 0            
                             NO-LOCK NO-ERROR.
                 
          IF AVAILABLE craptab AND TRIM(craptab.dstextab) = "1"  THEN
             RUN cria-registro-msg ("Cartao magnetico disponivel para " +
                                    "entrega.").

       END.

    ASSIGN aux_qttitula = 0.

    IF crapass.inpessoa = 1  THEN
       FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                              crapttl.nrdconta = par_nrdconta 
                              NO-LOCK:

           ASSIGN aux_qttitula = aux_qttitula + 1.
        
           IF aux_titulare = "" THEN
               ASSIGN aux_titulare = STRING(crapttl.idseqttl) + "," + STRING(crapttl.nrcpfcgc).
           ELSE
               ASSIGN aux_titulare = aux_titulare + "#" + STRING(crapttl.idseqttl) + "," + STRING(crapttl.nrcpfcgc).
       END.
    ELSE
       ASSIGN aux_qttitula = 1.

    IF NOT VALID-HANDLE(h-b1wgen0032) THEN
       RUN sistema/generico/procedures/b1wgen0032.p 
           PERSISTENT SET h-b1wgen0032.

    DO aux_contador = 1 TO aux_qttitula:
    
       FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                          crapsnh.nrdconta = par_nrdconta AND
                          crapsnh.idseqttl = aux_contador AND
                          crapsnh.tpdsenha = 1            AND
                          crapsnh.cdsitsnh = 1            
                          NO-LOCK NO-ERROR.

       FIND LAST crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta AND
                               crapcrm.tpusucar = aux_contador AND
                               crapcrm.cdsitcar = 2            AND
                               crapcrm.dtvalcar > par_dtmvtolt 
                               NO-LOCK NO-ERROR.
       
       IF crapass.inpessoa = 1  THEN
           DO:
               ASSIGN aux_flgexist = NO.

               FOR EACH crapcrd WHERE crapcrd.cdcooper = par_cdcooper
                                  AND crapcrd.nrdconta = par_nrdconta
                                  AND crapcrd.nrcpftit = INT(ENTRY(2,ENTRY(aux_contador,aux_titulare,"#"),","))
                                  AND crapcrd.cdadmcrd >= 10
                                  AND crapcrd.cdadmcrd <= 80
                                  AND crapcrd.inacetaa = 1 NO-LOCK,
               FIRST crawcrd WHERE crawcrd.cdcooper = crapcrd.cdcooper
                               AND crawcrd.nrdconta = crapcrd.nrdconta
                               AND crawcrd.nrctrcrd = crapcrd.nrctrcrd
                               AND (crawcrd.insitcrd = 4 
                                OR crawcrd.insitcrd = 6) NO-LOCK.
                 
                   ASSIGN aux_flgexist = YES.
                   LEAVE.

               END.
           END.
        ELSE
            DO:
               ASSIGN aux_flgexist = NO.
               FOR EACH crapcrd WHERE crapcrd.cdcooper = par_cdcooper
                                  AND crapcrd.nrdconta = par_nrdconta
                                  AND crapcrd.cdadmcrd >= 10
                                  AND crapcrd.cdadmcrd <= 80
                                  AND crapcrd.inacetaa = 1 NO-LOCK,
               FIRST crawcrd WHERE crawcrd.cdcooper = crapcrd.cdcooper
                               AND crawcrd.nrdconta = crapcrd.nrdconta
                               AND crawcrd.nrctrcrd = crapcrd.nrctrcrd
                               AND (crawcrd.insitcrd = 4 
                                OR crawcrd.insitcrd = 6) NO-LOCK.
                 
                   ASSIGN aux_flgexist = YES.
                   LEAVE.

               END.
            END.


       IF NOT AVAIL crapsnh  AND
          NOT AVAIL crapcrm  AND
          NOT aux_flgexist THEN
          NEXT.

       RUN verifica-letras-seguranca IN h-b1wgen0032 (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT aux_contador,
                                                     OUTPUT aux_flgcadas).

       IF NOT aux_flgcadas THEN
          DO:
              IF crapass.inpessoa = 1  THEN
                 ASSIGN aux_dsmensag = "Falta cadastro das letras de " +
                                       "seguranca - " + STRING(aux_contador) +
                                       "o titular.".  
              ELSE
                 DO:
                    IF crapass.idastcjt = 0 THEN
                       ASSIGN aux_dsmensag = "Falta cadastro das letras de " +
                                             "seguranca.".
                   ELSE
                       ASSIGN aux_dsmensag = "Falta cadastro das letras de " +
                                             "seguranca para TAA.".
                  END.                 

              RUN cria-registro-msg (aux_dsmensag).

          END.
       
    END.

    IF VALID-HANDLE(h-b1wgen0032) THEN
       DELETE OBJECT h-b1wgen0032.

    /**/
    IF NOT VALID-HANDLE(h-b1wgen0058) THEN
       RUN sistema/generico/procedures/b1wgen0058.p 
           PERSISTENT SET h-b1wgen0058.
    
    IF crapass.idastcjt = 1 THEN DO:
       RUN Busca_Dados IN h-b1wgen0058 (INPUT par_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT 0,
                                        INPUT FALSE,
                                        INPUT 'C',
                                        INPUT 0,
                                        INPUT '',
                                        INPUT ?,
                                       OUTPUT TABLE tt-crapavt,
                                       OUTPUT TABLE tt-bens,
									   OUTPUT aux_qtminast,
                                       OUTPUT TABLE tt-erro) NO-ERROR.

       FOR EACH tt-crapavt WHERE tt-crapavt.idrspleg = 1 NO-LOCK: 
       
          FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                  crapsnh.nrdconta = par_nrdconta AND
                                  crapsnh.tpdsenha = 3            AND
                                  crapsnh.nrcpfcgc = tt-crapavt.nrcpfcgc 
                                  NO-LOCK. END.
                                  
          IF NOT AVAIL crapsnh THEN DO:
             
            ASSIGN aux_dsmensag = "Falta cadastro das letras de " +
                                   "seguranca – CPF Responsavel " +
                                   STRING(STRING(tt-crapavt.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").
             
             RUN cria-registro-msg (aux_dsmensag).
             
          END.
       END.
    END.
    
    IF VALID-HANDLE(h-b1wgen0058) THEN
      DELETE OBJECT h-b1wgen0058.
    /**/
    
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 1            AND
                             craplim.insitlim = 2            
                             NO-LOCK NO-ERROR.

    IF AVAILABLE craplim THEN
       DO:
           IF craplim.dtfimvig <> ? THEN
              DO:
                  IF craplim.dtfimvig <= par_dtmvtolt THEN
                     RUN cria-registro-msg ("Contrato de limite de credito" +
                                            " vencido.").
              END.
           ELSE
           IF (craplim.dtinivig + craplim.qtdiavig) <= par_dtmvtolt  THEN
              RUN cria-registro-msg ("Contrato de limite de credito" +
                                     " vencido.").
       END.

    /** Buscar regra para renovaçao **/
    FIND FIRST craprli 
         WHERE craprli.cdcooper = par_cdcooper
           AND craprli.tplimite = 2
           AND craprli.inpessoa = crapass.inpessoa
           NO-LOCK NO-ERROR.

    IF NOT AVAILABLE craprli  THEN
       RUN cria-registro-msg ("Tabela Regra de limite nao cadastrada.").

    /** Verifica se ja excedeu a vigencia do limite de desconto de cheques **/
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 2            AND
                             craplim.insitlim = 2            
                             NO-LOCK NO-ERROR.

    IF AVAILABLE craplim  THEN
       DO:
           IF craplim.dtfimvig <> ? THEN
              DO:
                  IF craplim.dtfimvig <= par_dtmvtolt THEN
                     RUN cria-registro-msg ("Contrato de Desconto de Cheques" +
                                            " Vencido.").
              END.
           ELSE
           IF (craplim.dtinivig + craplim.qtdiavig) <= par_dtmvtolt  THEN
              RUN cria-registro-msg ("Contrato de Desconto de Cheques" +
                                     " Vencido.").
       END.

    ASSIGN aux_flgpreju = FALSE
           aux_dsprejuz = " - liquidado".

    FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND 
                           crapepr.inprejuz = 1            
                           NO-LOCK:

        ASSIGN aux_flgpreju = TRUE.
        
        IF crapepr.vlsdprej > 0  THEN
           ASSIGN aux_dsprejuz = "".

    END.
    
    IF CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)) OR aux_flgpreju  THEN
       RUN cria-registro-msg ("Houve prejuizo nessa conta" + aux_dsprejuz).

    IF par_cdcooper = 16 OR par_cdcooper = 1 THEN /* Se Viacredi AltoVale ou Viacredi*/
       DO:
          EMPTY TEMP-TABLE tt-alertas.
   
          RUN Criticas_AltoVale (INPUT par_cdcooper,
                                 INPUT crapass.nrcpfcgc,
                                 INPUT-OUTPUT aux_sralerta,
                                 INPUT-OUTPUT TABLE tt-alertas).             

          FOR EACH tt-alertas NO-LOCK:

              RUN cria-registro-msg (tt-alertas.dsalerta).     

          END.

       END.
    
    IF CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
       RUN cria-registro-msg ("Titular da conta bloqueado.").

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.
    
    IF NOT VALID-HANDLE(h-b1wgen0002)  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Handle invalido para BO b1wgen0002.".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/   
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
                                                 INPUT par_dtmvtolt,
                                                 INPUT 0,
                                                 INPUT "B1WGEN0030",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE OBJECT h-b1wgen0002.
        
    IF RETURN-VALUE = "NOK"  THEN
       RETURN "NOK".

    FOR EACH tt-dados-epr NO-LOCK: 

        ASSIGN aux_vltotprv = aux_vltotprv + tt-dados-epr.vlprovis.
             
        IF tt-dados-epr.vlsdeved <= 0  THEN
           NEXT.

        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper                AND
                           crapepr.nrdconta = par_nrdconta                AND
                           crapepr.nrctremp = INTE(tt-dados-epr.nrctremp) 
                           NO-LOCK NO-ERROR.
      
        IF AVAILABLE crapepr                AND   
           crapepr.tpdescto = 2             AND 
           par_dtmvtolt < crapepr.dtdpagto  THEN
           NEXT.

        ASSIGN aux_dsmensag = "".

        IF tt-dados-epr.tpemprst = 1   OR
		   tt-dados-epr.tpemprst = 2   THEN
           DO:
              IF tt-dados-epr.flgatras   THEN 
                 DO:
                     ASSIGN aux_dsmensag = "Associado com emprestimo em " +
                                           "atraso.".
                 END.            
           END.
        ELSE
          DO:
             IF (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  AND
                 tt-dados-epr.dtdpagto < par_dtmvtolt                    THEN
                 DO:
                    IF CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto))) OR
                       CAN-FIND(crapfer WHERE 
                                crapfer.cdcooper = par_cdcooper             AND
                                crapfer.dtferiad = tt-dados-epr.dtdpagto)   THEN
                       DO:
                          IF tt-dados-epr.dtdpagto < par_dtmvtoan  THEN
                             ASSIGN aux_dsmensag = "Associado com emprestimo " +
                                                   "em atraso.".
                       END.
                     ELSE 
                        ASSIGN aux_dsmensag = "Associado com emprestimo " + 
                                              "em atraso.".
                 END.
              ELSE
              IF tt-dados-epr.vlpreapg <> 0                               AND
                 tt-dados-epr.dtdpagto <> par_dtmvtolt                    AND        
                 (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  THEN      
                 DO:
                    IF CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto))) OR
                       CAN-FIND(crapfer WHERE 
                                crapfer.cdcooper = par_cdcooper             AND
                                crapfer.dtferiad = tt-dados-epr.dtdpagto)   THEN 
                       .
                    ELSE
                       ASSIGN aux_dsmensag = "Associado com emprestimo em " +
                                             "atraso.".
                 END.     
          END.                  

        IF aux_dsmensag <> ""  THEN
           DO:
               RUN cria-registro-msg (aux_dsmensag).
               
               LEAVE.
           END.    
    
    END.    

    /* PORTABILIDADE - verifica se o contrato liquidado foi portado para outra instituicao */
    FOR EACH tbepr_portabilidade FIELDS (nrctremp) 
                                   WHERE tbepr_portabilidade.cdcooper = par_cdcooper  AND
                                         tbepr_portabilidade.nrdconta = par_nrdconta  AND
                                         tbepr_portabilidade.tpoperacao = 2,  /* tipo 2 (Venda)*/
                                   FIRST crapepr FIELDS (cdlcremp dtultpag)
                                   WHERE crapepr.cdcooper = tbepr_portabilidade.cdcooper  AND
                                         crapepr.nrdconta = tbepr_portabilidade.nrdconta  AND
                                         crapepr.nrctremp = tbepr_portabilidade.nrctremp  AND
                                         crapepr.inliquid = 1 /* liquidado */
                                   NO-LOCK:
        
            /* busca dados da linha de credito */
            FOR FIRST craplcr FIELDS (nrdialiq) 
                               WHERE craplcr.cdcooper = crapepr.cdcooper AND
                                     craplcr.cdlcremp = crapepr.cdlcremp
                             NO-LOCK: END.
        
            IF  AVAILABLE craplcr THEN
            DO:
                IF (crapepr.dtultpag + craplcr.nrdialiq >= par_dtmvtolt) THEN
                DO:
                    IF aux_epr_portabilidade = "" THEN
                    DO:
                        ASSIGN aux_epr_portabilidade = STRING(tbepr_portabilidade.nrctremp).
                    END.
                    ELSE 
                    DO:
                        ASSIGN aux_epr_portabilidade = aux_epr_portabilidade + ',' + STRING(tbepr_portabilidade.nrctremp).
                    END.
                END.
            END.
    END.
    /*cria o registro para informar os contratos liquidados pela portabilidade*/
    IF aux_epr_portabilidade <> ""  THEN
    DO:
       aux_epr_portabilidade = 'Contrato(s) liquidado(s) por Portabilidade: ' + aux_epr_portabilidade. 
    
       RUN cria-registro-msg (aux_epr_portabilidade).           
    END.   

     
    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.
    
    IF NOT VALID-HANDLE(h-b1wgen0002)  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Handle invalido para BO b1wgen0002.".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/   
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                          
           RETURN "NOK".                   

       END. 

    EMPTY TEMP-TABLE tt-dados-epr.
    
    FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper AND
                           crapavl.nrdconta = par_nrdconta AND
                           crapavl.tpctrato = 1            
                           NO-LOCK,

        FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper     AND
                            crapepr.nrdconta = crapavl.nrctaavd AND
                            crapepr.nrctremp = crapavl.nrctravd 
                            NO-LOCK:

        IF NOT ((crapepr.inprejuz = 1  AND
                 crapepr.vlsdprej > 0)  OR
                 crapepr.inliquid = 0)   THEN
           NEXT.

        /** Ate 100 emprestimos em atraso **/
        ASSIGN aux_qtempatr = aux_qtempatr + 1. 
     
        IF  aux_qtempatr > 99  THEN 
            LEAVE.

        RUN obtem-dados-emprestimos IN h-b1wgen0002 
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT crapavl.nrctaavd,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT par_dtmvtolt,
                                                 INPUT crapavl.nrctravd,
                                                 INPUT "B1WGEN0030",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
            
        IF RETURN-VALUE = "NOK"  THEN
           DO:
               IF VALID-HANDLE(h-b1wgen0002) THEN
                  DELETE OBJECT h-b1wgen0002.
    
               RETURN "NOK".

           END.

        FIND tt-dados-epr NO-LOCK NO-ERROR.
            
        IF NOT AVAIL tt-dados-epr  THEN    
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Registro de emprestimo " + 
                                     "temporario nao encontrado.".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1, /** Sequencia **/   
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).

               IF VALID-HANDLE(h-b1wgen0002) THEN
                  DELETE OBJECT h-b1wgen0002.
                  
               RETURN "NOK".                        

           END.
                
        ASSIGN aux_dsmensag = "".
                
        IF tt-dados-epr.tpemprst = 1   OR
		   tt-dados-epr.tpemprst = 2   THEN
           DO:
              IF tt-dados-epr.flgatras   THEN 
                 DO:
                    ASSIGN aux_dsmensag = "Fiador de " +
                                          "emprestimo em atraso: ".
                 END.
           END.
        ELSE 
           DO:
              IF crapepr.inprejuz = 1 AND crapepr.vlsdprej > 0  THEN
                 ASSIGN aux_dsmensag = "Fiador de emprestimo em atraso: ".
              ELSE
                 DO:
                    IF tt-dados-epr.vlsdeved <= 0  THEN
                       NEXT.
                    
                    IF crapepr.tpdescto = 2             AND 
                       par_dtmvtolt < crapepr.dtdpagto  THEN
                       NEXT.
                    
                    IF (tt-dados-epr.qtmesdec - 
                        tt-dados-epr.qtprecal) >= 0.01       AND
                        tt-dados-epr.dtdpagto < par_dtmvtolt THEN
                        DO:
                           IF CAN-DO("1,7",STRING(
                                         WEEKDAY(tt-dados-epr.dtdpagto)))
                              OR
                              CAN-FIND(crapfer WHERE 
                                       crapfer.cdcooper = par_cdcooper AND
                                       crapfer.dtferiad = 
                                       tt-dados-epr.dtdpagto)   THEN
                              DO:
                                 IF tt-dados-epr.dtdpagto < par_dtmvtoan THEN
                                    ASSIGN aux_dsmensag = "Fiador de " +
                                                          "emprestimo em " +
                                                          "atraso: ".

                              END.
                           ELSE
                              ASSIGN aux_dsmensag = "Fiador de " +
                                                    "emprestimo em " +
                                                    "atraso: ".
                        END.
                    ELSE
                       IF tt-dados-epr.vlpreapg <> 0             AND
                          tt-dados-epr.dtdpagto <> par_dtmvtolt  THEN 
                          DO:
                             IF CAN-DO("1,7",
                                STRING(WEEKDAY(tt-dados-epr.dtdpagto))) OR
                                 CAN-FIND(crapfer WHERE 
                              crapfer.cdcooper = par_cdcooper            AND
                              crapfer.dtferiad = tt-dados-epr.dtdpagto)  THEN
                              .
                             ELSE 
                                ASSIGN aux_dsmensag = "Fiador de emprestimo " +
                                                      "em atraso: ".

                          END.

                 END.

           END.

        IF aux_dsmensag <> ""  THEN
           RUN cria-registro-msg (aux_dsmensag + "Conta: " +
                        TRIM(STRING(crapepr.nrdconta,"zzzz,zzz,9")) +
                        " Contrato: "  + 
                        TRIM(STRING(crapepr.nrctremp,"zz,zzz,zz9"))  + ".").

           
    END.


    ASSIGN aux_flbndand = FALSE  /* em andamento*/
           aux_flbndatr = FALSE  /* em atraso */ 
           aux_flbndprj = FALSE  /* em prejuizo */ 
           aux_flbndnor = FALSE. /* normal */ 
    
    /* Valida Emprestimo BNDES */
    FOR EACH crapprp
       WHERE crapprp.cdcooper = par_cdcooper
         AND crapprp.nrdconta = par_nrdconta
         AND crapprp.tpctrato = 90
         AND crapprp.vlctrbnd > 0
          NO-LOCK USE-INDEX crapprp1:

        FIND FIRST crapnrc 
             WHERE crapnrc.cdcooper = crapprp.cdcooper
               AND crapnrc.nrdconta = crapprp.nrdconta
               AND crapnrc.nrctrrat = crapprp.nrctrato
               AND crapnrc.tpctrrat = crapprp.tpctrato
                NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapnrc AND aux_flbndand = FALSE THEN  DO:
            ASSIGN aux_dsmensag = "Atencao! Cooperado possui proposta " +
                                  "de BNDES em andamento. Verifique.".
            RUN cria-registro-msg (aux_dsmensag).
            
            ASSIGN aux_flbndand = TRUE
                   aux_dsmensag = "".
            NEXT.
        END.

        /* Ativa e EM ATRASO */
        FIND FIRST crapebn
             WHERE crapebn.cdcooper = crapprp.cdcooper
               AND crapebn.nrdconta = crapprp.nrdconta
               AND crapebn.nrctremp = crapprp.nrctrato
               AND (crapebn.insitctr = "A" OR crapebn.insitctr = "P")
                NO-LOCK NO-ERROR.

        IF  AVAIL crapebn   THEN
            DO:
                IF  crapebn.insitctr = "P" AND aux_flbndprj = FALSE  THEN
                    ASSIGN aux_dsmensag = "Cooperado com emprestimo " +
                                           "BNDES em prejuizo!"
                           aux_flbndprj = TRUE.
                ELSE
                IF  crapebn.insitctr = "A" AND aux_flbndatr = FALSE  THEN
                    ASSIGN aux_dsmensag = "Cooperado com emprestimo " +
                                          "BNDES em atraso!"
                           aux_flbndatr = TRUE.

                RUN cria-registro-msg (aux_dsmensag).

                ASSIGN aux_dsmensag = "".
                NEXT.
            
            END.
            
        /* Ativa e NORMAL */
        FIND FIRST crapebn
             WHERE crapebn.cdcooper = crapprp.cdcooper
               AND crapebn.nrdconta = crapprp.nrdconta
               AND crapebn.nrctremp = crapprp.nrctrato
               AND crapebn.insitctr = "N"
                NO-LOCK NO-ERROR.

        IF  AVAIL crapebn AND aux_flbndnor = FALSE THEN DO:
            ASSIGN aux_dsmensag = "Atencao! Cooperado possui operacao " +
                                  "de BNDES.".
            RUN cria-registro-msg (aux_dsmensag).

            ASSIGN aux_flbndnor = TRUE
                   aux_dsmensag = "".
            NEXT.
        END.
    END.
    /* FIM Valida Emprestimo BNDES */

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE OBJECT h-b1wgen0002.

    IF aux_vltotprv > 0  THEN
       RUN cria-registro-msg ("Valor total provisionado no cheque salario: " +
                              TRIM(STRING(aux_vltotprv,"zzz,zzz,zz9.99"))).

    /** Verifica se esta no CCF **/    
    IF crapass.inlbacen <> 0  THEN
       RUN cria-registro-msg ("Associado esta no CCF.").

    /** Verifica se o CPF esta regularizado **/    
    IF crapass.cdsitcpf > 1  THEN
       DO: 
           ASSIGN aux_dsmensag = "Associado com CPF".
           
           CASE crapass.cdsitcpf:
                WHEN 2 THEN ASSIGN aux_dsmensag = aux_dsmensag + " pendente.".
                WHEN 3 THEN ASSIGN aux_dsmensag = aux_dsmensag + " cancelado.".
                WHEN 4 THEN ASSIGN aux_dsmensag = aux_dsmensag + " irregular.".
                WHEN 5 THEN ASSIGN aux_dsmensag = aux_dsmensag + " suspenso.".
           END CASE.
                       
           RUN cria-registro-msg (aux_dsmensag).
       END.
          
         
    /** Verifica se o endereco foi alterado pelo associado na internet **/
    FOR EACH crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                           crapenc.nrdconta = par_nrdconta AND
                           crapenc.tpendass = 12           
                           NO-LOCK:

        RUN cria-registro-msg ("Verifique atualizacao de endereco pela " +
                               "internet (" + STRING(crapenc.idseqttl) + 
                               "o titular)."). 

    END.         

    /*
        Verifica se conta salario está ativa (cdsitcta = 1) e retorna a 
        mensagem “Cooperado CPF (crapccs.cdcpfcgc) possui conta salário Ativa” 
    */
    FIND crapccs WHERE crapccs.cdcooper = par_cdcooper AND
                       crapccs.nrdconta = par_nrdconta AND
                       crapccs.cdsitcta = 1
                       NO-LOCK NO-ERROR.
    IF AVAIL crapccs THEN
    DO:
        RUN cria-registro-msg (INPUT 
            "Cooperado CPF ("         +
            STRING(crapccs.nrcpfcgc)  +
            ") possui conta salário ativa"
        ).
    END.
        

    IF NOT VALID-HANDLE(h-b1wgen0091) THEN
       RUN sistema/generico/procedures/b1wgen0091.p
           PERSISTENT SET h-b1wgen0091.

    ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                           IN h-b1wgen0091,
                                           INPUT par_cdcooper,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdagenci,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_dtmvtolt,
                                           INPUT crapass.nrcpfcgc,
                                           INPUT 0, /*nrbenefi/nrrecben*/
                                           INPUT 1 /*Verifica Qlqer bene.*/).
    
    /*Bloqueio por falta de comprovacao de vida ou comprovacao ainda 
      nao efetuada*/
    IF aux_tpbloque = 1 OR
       aux_tpbloque = 2 THEN
       RUN cria-registro-msg ("Beneficiario com Prova de Vida Pendente. " +
                              "Efetue Comprovacao atraves da COMPVI. ").
    ELSE /*Menos de 60 dias para expirar o perido de um ano da comprovacao*/
       IF aux_tpbloque = 3 THEN 
          RUN cria-registro-msg ("Este beneficiario devera efetuar a " + 
                                 "comprovacao de vida. A falta de "    +
                                 "renovacao  implicara no bloqueio do " + 
                                 "beneficio pelo INSS.").
          
    IF VALID-HANDLE(h-b1wgen0091) THEN
       DELETE OBJECT h-b1wgen0091.

    
    /** Verifica Se Tipo de Conta Individual e possui mais de um Titular **/
    IF crapass.inpessoa = 1  THEN
       DO:
           FIND LAST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta  
                                   NO-LOCK NO-ERROR.
                     
           IF AVAILABLE crapttl  THEN
              DO:
                  IF  (crapass.cdtipcta = 1   OR
                      crapass.cdtipcta = 2    OR
                      crapass.cdtipcta = 7    OR
                      crapass.cdtipcta = 8    OR
                      crapass.cdtipcta = 9    OR
                      crapass.cdtipcta = 12   OR
                      crapass.cdtipcta = 13   OR
                      crapass.cdtipcta = 18)  AND
                      crapttl.idseqttl > 1    THEN
                      RUN cria-registro-msg ("Tipo de conta nao permite " +
                                             "MAIS DE UM TITULAR.").
              END.
       END.

    /* Vigencia dos Procuradores - Jose Luis (DB1), 25/09/10 */
    RUN verifica-vigencia-procurador ( INPUT par_cdcooper,
                                       INPUT par_nmdatela,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtmvtolt,
                                       OUTPUT aux_dsvigpro ).

    IF aux_dsvigpro <> "" THEN
       RUN cria-registro-msg (aux_dsvigpro).

    IF crapass.inpessoa = 2 THEN
       DO:
           RUN valida_socios (INPUT par_cdcooper,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                             OUTPUT aux_dscritic).
      
           IF aux_dscritic <> "" THEN
              RUN cria-registro-msg (INPUT aux_dscritic).
      
       END.
      

    /* Procura registro de recadastramento - JORGE, 27/07/2011*/
    IF NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p
           PERSISTENT SET h-b1wgen0060.

    FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                            crapalt.nrdconta = par_nrdconta AND
                            crapalt.tpaltera = 1 
                            NO-LOCK NO-ERROR.

    IF NOT AVAILABLE (crapalt) THEN
       DO:
          IF crapass.dtdemiss = ?   THEN
             DO:
                 ASSIGN aux_cdcritic = 400.

                 RUN cria-registro-msg (INPUT (DYNAMIC-FUNCTION
                                               ("BuscaCritica" IN h-b1wgen0060,
                                                aux_cdcritic))).
                 ASSIGN aux_cdcritic = 0.

             END.

       END.
    ELSE
       DO:
          IF crapass.inpessoa = 1 THEN  /* Somente para pessoa fisica */
             DO:
                FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                                       crapavt.tpctrato = 5 /*contato*/ AND
                                       crapavt.nrdconta = par_nrdconta  
                                       NO-LOCK:
                                
                    /* Se o contato eh associado, 
                       verifica se esta demitido */
                    IF crapavt.nrdctato <> 0   THEN
                       DO:
                          FIND crabass WHERE 
                               crabass.cdcooper = crapavt.cdcooper AND
                               crabass.nrdconta = crapavt.nrdctato
                               NO-LOCK NO-ERROR.
                                               
                          IF NOT AVAILABLE crabass   THEN
                             ASSIGN aux_cdcritic = 491.
                          ELSE
                             IF crabass.dtdemiss <> ?   THEN
                                ASSIGN aux_cdcritic = 492.
                       
                          IF aux_cdcritic > 0   THEN
                             DO:
                                 RUN cria-registro-msg
                                               ( INPUT (DYNAMIC-FUNCTION
                                               ("BuscaCritica" IN 
                                                 h-b1wgen0060, 
                                                 aux_cdcritic))).
                                 ASSIGN aux_cdcritic = 0.
                                 LEAVE.

                             END.

                       END.

                END. /* fim for each */

             END.         

       END.

    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                             NO-LOCK NO-ERROR.
    
    /*** Busca Saldo Bloqueado Judicial ***/
    IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.
    
    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* nrcpfcgc */
                                             INPUT 0, /* 0-Para Exibir Msg */
                                             INPUT 0, /* 0-Para Exibir Msg */
                                             INPUT crapdat.dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).
    
    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

    IF  aux_vlblqjud > 0 THEN
        RUN cria-registro-msg (INPUT "Conta Possui Valor Bloqueado" +
                                     " Judicialmente.").    
       
    IF VALID-HANDLE(h-b1wgen0060)  THEN
       DELETE OBJECT h-b1wgen0060.

    /* Verifica se o Cooperado possui Credito Pre Aprovado */
    IF  NOT VALID-HANDLE(h-b1wgen0188) THEN
        RUN sistema/generico/procedures/b1wgen0188.p 
            PERSISTENT SET h-b1wgen0188.

    RUN busca_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_idorigem,
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT 0, /* nrcpfope */
                                     OUTPUT TABLE tt-dados-cpa,
                                     OUTPUT TABLE tt-erro).
 
    FIND tt-dados-cpa NO-LOCK NO-ERROR.

    IF  AVAIL tt-dados-cpa AND tt-dados-cpa.vldiscrd > 0 THEN
    DO:  
        RUN cria-registro-msg (INPUT "Atencao: Cooperado possui " +
                                     "Credito Pre-Aprovado, limite " +
                                     "maximo de R$ " +
                                     STRING(tt-dados-cpa.vldiscrd, 
                                            "zzz,zzz,zz9.99-")).
    END.

    IF  VALID-HANDLE(h-b1wgen0188) THEN
        DELETE PROCEDURE h-b1wgen0188.

    FIND FIRST crapcyc WHERE crapcyc.cdcooper = par_cdcooper   AND
                             crapcyc.nrdconta = par_nrdconta   AND
                            (crapcyc.flgjudic = TRUE   OR
                             crapcyc.flextjud = TRUE )
                             NO-LOCK NO-ERROR.

    IF   AVAIL crapcyc    THEN
         DO:
             RUN cria-registro-msg (INPUT "Existem contratos em cobrança – " + 
                                          "Consultar CADCYB ou CYBER").
         END.

    /* buscar boletos de contratos em aberto */
    FOR EACH tbepr_cobranca FIELDS (cdcooper nrdconta_cob nrcnvcob nrboleto nrctremp)
       WHERE tbepr_cobranca.cdcooper = par_cdcooper AND
             tbepr_cobranca.nrdconta = par_nrdconta 
             NO-LOCK:
        
            FOR FIRST crapcob FIELDS (dtvencto vltitulo)
                WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                  AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                  AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                  AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                  AND crapcob.incobran = 0 NO-LOCK:
                
                    RUN cria-registro-msg 
                        (INPUT "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + " em aberto." +
                               " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +
                               " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + "." ).    
            END.

            /* verificar se o boleto do contrato está em pago, pendente de processamento */
            FOR FIRST crapcob FIELDS (dtvencto vltitulo dtdpagto)
                WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                  AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                  AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                  AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                  AND crapcob.incobran = 5 NO-LOCK:
    
                    FOR FIRST crapret      
                        WHERE crapret.cdcooper = crapcob.cdcooper    
                          AND crapret.nrdconta = crapcob.nrdconta     
                          AND crapret.nrcnvcob = crapcob.nrcnvcob     
                          AND crapret.nrdocmto = crapcob.nrdocmto     
                          AND crapret.cdocorre = 6     
                          AND crapret.dtocorre = crapcob.dtdpagto     
                          AND crapret.flcredit = 0     
                          NO-LOCK:    

                        RUN cria-registro-msg 
                            (INPUT "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + 
                                   " esta pago pendente de processamento." +       
                                   " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                   " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".").    
                    END.
            END.   
    END.
   
    /* Apresentar alerta caso o cooperado possuir proposta de cartao rejeitada */
    FIND FIRST crawcrd 
         WHERE crawcrd.cdcooper = par_cdcooper
           AND crawcrd.nrdconta = par_nrdconta
           AND crawcrd.dtrejeit <> ?
           NO-LOCK NO-ERROR.
    IF AVAILABLE crawcrd THEN
    DO:                 
        RUN cria-registro-msg 
                            (INPUT "Cooperado possui cartao rejeitado, " + 
                                    "verificar relatorio de criticas numero (676).").
    END.
    

    /* Gerar aviso para impressão do termo de responsabilidade */ 
    IF crapass.idimprtr = 1 THEN
      RUN cria-registro-msg(INPUT "Imprimir Termo de Responsabilidade para acesso ao Autoatendimento e SAC.").
    
    /* Lombardi */
    
    IF NOT VALID-HANDLE(h-b1wgen0025) THEN
      RUN sistema/generico/procedures/b1wgen0025.p
          PERSISTENT SET h-b1wgen0025.

    RUN verifica_prova_vida_inss IN h-b1wgen0025
                                  (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                  OUTPUT par_flgdinss,
                                  OUTPUT aux_flgbinss,
                                  OUTPUT par_dscritic).
    
    IF  RETURN-VALUE <> "OK"   THEN
       LEAVE.
    
    IF par_flgdinss THEN
        RUN cria-registro-msg ( INPUT "Beneficiario com Prova de Vida Pendente. Efetue Comprovacao atraves da Tela INSS no Ayllos WEB. " ).
    
    RETURN "OK".

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*             REALIZA A VALIDACAO DAS CONTAS NA VIACREDI ALTOVALE          */
/* ------------------------------------------------------------------------ */
PROCEDURE Criticas_AltoVale: 
    
    DEF INPUT        PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF INPUT        PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_sqalerta AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-alertas.


    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
    DEF VAR aux_dsalerta AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtdemiss AS DATE                                    NO-UNDO.
    DEF VAR aux_dscripre AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscriliq AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdcoptmp AS INTE                                    NO-UNDO.
    DEF VAR aux_nmcoptmp AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass  FOR crapass.


    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   AVAIL crapdat   THEN
         ASSIGN aux_dtmvtolt = crapdat.dtmvtolt.

    IF par_cdcooper = 1 THEN
       ASSIGN aux_cdcoptmp = 2
              aux_nmcoptmp = "Acredicoop".
    ELSE
       ASSIGN aux_cdcoptmp = 1
              aux_nmcoptmp = "Viacredi".

    /* Obter a data atual menos 02 anos */
    ASSIGN aux_dtdemiss = ADD-INTERVAL(aux_dtmvtolt,-2,"YEARS")
        
           aux_dscripre = 
                "Cooperado com prejuizo na " + aux_nmcoptmp + "."
           aux_dscriliq = 
                "Cooperado ja causou prejuizo na " + aux_nmcoptmp + 
                " - Liquidado.".
    
    /* Verifica se existe alguma conta deste CPF/CNPJ na Viacredi*/   
    FOR EACH crabass WHERE crabass.cdcooper = aux_cdcoptmp AND
                           crabass.nrcpfcgc = par_nrcpfcgc NO-LOCK:

        FOR EACH crapepr WHERE crapepr.cdcooper = crabass.cdcooper AND
                               crapepr.nrdconta = crabass.nrdconta AND
                               crapepr.inprejuz = 1                
                               NO-LOCK BREAK BY crapepr.vlsdprej DESC:

            IF   crapepr.vlsdprej > 0   THEN
                 DO:
                     ASSIGN aux_dsalerta = aux_dscripre.
                 END.
            ELSE
                 DO:
                     ASSIGN aux_dsalerta = aux_dscriliq.
                 END.
                          
            FIND FIRST tt-alertas WHERE tt-alertas.dsalerta = aux_dsalerta 
                                        NO-LOCK NO-ERROR.
                     
            IF   AVAIL tt-alertas   THEN
                 NEXT.
                     
            CREATE tt-alertas.
            ASSIGN tt-alertas.cdalerta = par_sqalerta
                   tt-alertas.dsalerta = aux_dsalerta
                   par_sqalerta        = par_sqalerta + 1.   

            LEAVE.

        END.
        
        IF   crabass.dtdemiss <> ?              AND 
             crabass.dtdemiss > aux_dtdemiss    AND 
             NOT (CAN-FIND (craptco WHERE 
                            craptco.cdcopant = crabass.cdcooper    AND
                            craptco.nrctaant = crabass.nrdconta    AND
                            craptco.tpctatrf <> 3))  THEN
             DO:                  
                 ASSIGN aux_dsalerta =
                      "Cooperado com conta demitida na " + aux_nmcoptmp + ".".
              
                 FIND FIRST tt-alertas WHERE 
                            tt-alertas.dsalerta = aux_dsalerta 
                            NO-LOCK NO-ERROR.
              
                 IF   AVAIL tt-alertas   THEN
                      NEXT.
              
                 CREATE tt-alertas.
                 ASSIGN tt-alertas.cdalerta = par_sqalerta
                        tt-alertas.dsalerta = aux_dsalerta
                        par_sqalerta        = par_sqalerta + 1.
                           
             END.
    END.

    ASSIGN aux_contador = 0.

    FOR EACH tt-alertas NO-LOCK:

        IF   tt-alertas.dsalerta = aux_dscriliq   OR
             tt-alertas.dsalerta = aux_dscripre   THEN
             aux_contador = aux_contador + 1.
        
    END.

    /* Se existe ja as duas criticas de prejuizo, */
    /* deixar somente a de nao liquidado          */
    IF   aux_contador >= 2   THEN
         FOR EACH tt-alertas WHERE tt-alertas.dsalerta = aux_dscriliq:
             DELETE tt-alertas.                
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/**            Procedure verficar vigencia do procurador                    **/
/*****************************************************************************/
PROCEDURE verifica-vigencia-procurador:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_dsvigpro AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctremp AS INTE                                    NO-UNDO.
    
    /* verificar se e pessoa juridica ou fisica */
    IF  CAN-FIND(FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = par_nrdconta AND
                                     crapass.inpessoa = 1) THEN
        ASSIGN aux_nrctremp = par_idseqttl.
    ELSE
        ASSIGN aux_nrctremp = 0.    

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                           crapavt.tpctrato = 6            AND
                           crapavt.nrdconta = par_nrdconta AND
                           crapavt.nrctremp = aux_nrctremp NO-LOCK:
        
        IF  crapavt.dtvalida <> 12/31/9999   AND
            crapavt.dtvalida <  par_dtmvtolt THEN
            DO:
               ASSIGN par_dsvigpro = "Representante/Procurador com Procuracao/"
                                     + "Ata vencida." +
                                     (IF  par_nmdatela = "ATENDA" 
                                      THEN " Verifique tela Contas" ELSE "").
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/**         Procedure para criar registro de uma mensagem de alerta         **/
/*****************************************************************************/
PROCEDURE cria-registro-msg:
    
    DEF  INPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.
    
    CREATE tt-mensagens-atenda.
    ASSIGN aux_nrsequen = aux_nrsequen + 1
           tt-mensagens-atenda.nrsequen = aux_nrsequen
           tt-mensagens-atenda.dsmensag = par_dsmensag.
           
END PROCEDURE.

/*****************************************************************************/
/**         Procedure obter mensagens de alerta para tela de Contas         **/
/*****************************************************************************/

PROCEDURE obtem-mensagens-alerta-contas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens-contas.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0191 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0025 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvigpro AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrconbir AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqdet AS INTE                                    NO-UNDO.
    DEF VAR aux_cdbircon AS INTE                                    NO-UNDO.
    DEF VAR aux_dsbircon AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdmodbir AS INTE                                    NO-UNDO.
    DEF VAR aux_dssituac AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmodbir AS CHAR                                    NO-UNDO.
    DEF VAR par_flgdinss AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_flgbinss AS LOGICAL                                 NO-UNDO.
    DEF VAR par_dscritic AS CHAR                                    NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_returnvl = "NOK".

    Busca: 
    DO ON ERROR UNDO Busca, LEAVE Busca:

       EMPTY TEMP-TABLE tt-erro.
       EMPTY TEMP-TABLE tt-mensagens-contas.
       
       FOR FIRST crapass FIELDS(inpessoa cdtipcta dtdemiss)
                         WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK:

       END.

       IF NOT AVAILABLE crapass  THEN
          DO:
             ASSIGN aux_cdcritic = 9.
             LEAVE Busca.

          END.

       IF NOT VALID-HANDLE(h-b1wgen0060) THEN
          RUN sistema/generico/procedures/b1wgen0060.p
              PERSISTENT SET h-b1wgen0060.
       
       IF NOT VALID-HANDLE(h-b1wgen0191) THEN
          RUN sistema/generico/procedures/b1wgen0191.p
              PERSISTENT SET h-b1wgen0191.
              
       IF NOT VALID-HANDLE(h-b1wgen0025) THEN
          RUN sistema/generico/procedures/b1wgen0025.p
              PERSISTENT SET h-b1wgen0025.
              

       CASE crapass.inpessoa:
           WHEN 1 THEN DO:

               FOR LAST crapttl FIELDS(idseqttl)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta 
                                       NO-LOCK:
               END.

               IF AVAILABLE crapttl  THEN
                  DO:
                     IF (crapass.cdtipcta = 1   OR
                         crapass.cdtipcta = 2   OR
                         crapass.cdtipcta = 7   OR
                         crapass.cdtipcta = 8   OR
                         crapass.cdtipcta = 9   OR
                         crapass.cdtipcta = 12  OR
                         crapass.cdtipcta = 13  OR
                         crapass.cdtipcta = 18) AND
                         crapttl.idseqttl > 1   THEN
                         DO:
                            RUN cria-registro-msg-contas
                                    ( INPUT (DYNAMIC-FUNCTION
                                    ("BuscaCritica" IN h-b1wgen0060, 832))).
                         END.
                     
                   END.

           END.
           OTHERWISE DO:
               /* Procura registro de recadastramento */
               FOR LAST crapalt FIELDS(cdcooper)
                                 WHERE crapalt.cdcooper = par_cdcooper AND
                                       crapalt.nrdconta = par_nrdconta AND
                                       crapalt.tpaltera = 1            
                                       NO-LOCK:
               END.
    
               IF NOT AVAILABLE crapalt  AND
                  crapass.dtdemiss = ?   THEN
                  DO:
                     RUN cria-registro-msg-contas
                                    ( INPUT (DYNAMIC-FUNCTION
                                    ("BuscaCritica" IN h-b1wgen0060, 400))).
                  END.

               END.

       END CASE.
       
       RUN verifica-vigencia-procurador ( INPUT par_cdcooper,
                                          INPUT par_nmdatela,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtmvtolt,
                                         OUTPUT aux_dsvigpro ).
       
       IF aux_dsvigpro <> ""  THEN
          RUN cria-registro-msg-contas ( INPUT aux_dsvigpro ).

       IF crapass.inpessoa = 2 THEN
          DO:
              RUN valida_socios (INPUT par_cdcooper,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                 OUTPUT aux_dscritic).
         
              IF aux_dscritic <> "" THEN
                 RUN cria-registro-msg-contas (INPUT aux_dscritic).
                
          END.

       RUN Busca_Biro IN h-b1wgen0191
                  (INPUT par_cdcooper,
                   INPUT par_nrdconta,
                  OUTPUT aux_nrconbir,
                  OUTPUT aux_nrseqdet).

       IF  RETURN-VALUE <> "OK"   THEN
           LEAVE.
       
       RUN Busca_Situacao IN h-b1wgen0191 (INPUT aux_nrconbir,
                                           INPUT aux_nrseqdet,
                                          OUTPUT aux_cdbircon,
                                          OUTPUT aux_dsbircon,
                                          OUTPUT aux_cdmodbir,
                                          OUTPUT aux_dssituac,
                                          OUTPUT aux_dsmodbir).
       
       IF   RETURN-VALUE <> "OK"   THEN
            LEAVE.

       RUN Consulta_Geral IN h-b1wgen0191 (INPUT aux_nrconbir,
                                           INPUT aux_nrseqdet,
                                          OUTPUT aux_dscritic,
                                          OUTPUT TABLE tt-xml-geral).

       RUN Busca_Mensagens IN h-b1wgen0191 (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT TABLE tt-xml-geral,
                                           OUTPUT TABLE tt-msg-orgaos).

       DELETE PROCEDURE h-b1wgen0191.

       FOR EACH tt-msg-orgaos:
           RUN cria-registro-msg-contas (INPUT tt-msg-orgaos.dsmensag).
       END.
       
       /* Lombardi */
       
       RUN verifica_prova_vida_inss IN h-b1wgen0025
                                      (INPUT par_cdcooper,
                                       INPUT par_nrdconta,
                                      OUTPUT par_flgdinss,
                                      OUTPUT aux_flgbinss,
                                      OUTPUT par_dscritic).
                                      
       IF  RETURN-VALUE <> "OK"   THEN
           LEAVE.

       IF par_flgdinss THEN
          RUN cria-registro-msg-contas ( INPUT "Beneficiario com Prova de Vida Pendente. Efetue Comprovacao atraves da Tela INSS no Ayllos WEB. " ).
          
       ASSIGN aux_returnvl = "OK".

       LEAVE Busca.

    END.

    IF VALID-HANDLE(h-b1wgen0060)  THEN
       DELETE OBJECT h-b1wgen0060.

    IF VALID-HANDLE(h-b1wgen0191)  THEN
       DELETE OBJECT h-b1wgen0191.

    IF aux_returnvl = "NOK"  THEN 
       DO:
          IF  aux_dscritic = "" AND aux_cdcritic = 0  THEN 
              ASSIGN aux_dscritic = "Falha na leitura dos dados.".

          RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
       END.

    RETURN aux_returnvl.

END PROCEDURE.

/*****************************************************************************/
/**         Procedure para criar registro de uma mensagem de alerta         **/
/*****************************************************************************/
PROCEDURE cria-registro-msg-contas:
    
    DEF  INPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.
    
    CREATE tt-mensagens-contas.
    ASSIGN aux_nrsequen = aux_nrsequen + 1
           tt-mensagens-contas.nrsequen = aux_nrsequen
           tt-mensagens-contas.dsmensag = par_dsmensag.
           
END PROCEDURE.


/*****************************************************************************/
/**        Procedure para buscar as alteracoes da conta do cooperado        **/
/*****************************************************************************/
PROCEDURE busca-alteracoes:
    
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdctitg AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dssititg AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapalt.

    DEF VAR aux_dssititg AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-crapalt.
     
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
    DO:
        ASSIGN aux_cdcritic = 9.

        RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0, /* Agencia   */
                           INPUT 0, /* Caixa     */
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.

    IF   crapass.flgctitg = 2   THEN
         aux_dssititg = "Ativa".
    ELSE
    IF   crapass.flgctitg = 3   THEN
         aux_dssititg = "Inativa".
    ELSE
    IF   crapass.nrdctitg <> ""   THEN
         aux_dssititg = "Em Proc".
    ELSE
         aux_dssititg = "".

    ASSIGN par_nmprimtl = crapass.nmprimtl  
           par_nrdctitg = crapass.nrdctitg 
           par_dssititg = aux_dssititg.

    FOR EACH crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                           crapalt.nrdconta = par_nrdconta NO-LOCK
                           USE-INDEX crapalt1
                           BY crapalt.dtaltera DESCENDING:
    
        FIND crapope WHERE crapope.cdcooper = par_cdcooper      AND 
                           crapope.cdoperad = crapalt.cdoperad  NO-LOCK NO-ERROR.


        CREATE tt-crapalt.
        ASSIGN tt-crapalt.dtaltera = crapalt.dtaltera
               tt-crapalt.tpaltera = IF crapalt.tpaltera = 1 THEN
                                        "R"
                                     ELSE
                                        " "
               tt-crapalt.dsaltera = crapalt.dsaltera
               tt-crapalt.nmoperad = IF AVAIL crapope THEN 
                                        crapope.nmoperad
                                     ELSE
                                        STRING(crapalt.cdoperad) + 
                                        " - Nao Cadastrado".

    END. /* FIM FOR EACH crapalt */

    FIND FIRST tt-crapalt NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL tt-crapalt THEN
        DO:
            ASSIGN aux_cdcritic = 403.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0, /* Agencia   */
                           INPUT 0, /* Caixa     */
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE. /* FIM procedure busca-alteracoes */


/*****************************************************************************/
/** Procedure para validar se o percentual de todos os socios atingiu 100%  **/
/*****************************************************************************/

PROCEDURE valida_socios:

  DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
  DEF INPUT  PARAM par_nmdatela AS CHAR NO-UNDO.
  DEF INPUT  PARAM par_nrdconta AS INTE NO-UNDO.

  DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

  DEF VAR tot_persocio AS DECI INIT 0   NO-UNDO.


  /* procuradores da conta */
  FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                         crapavt.tpctrato = 6 /*procurad*/ AND
                         crapavt.nrdconta = par_nrdconta   AND
                         crapavt.nrctremp = 0              
                         NO-LOCK:

      ASSIGN tot_persocio = tot_persocio + crapavt.persocio.

  END.

  /* empresas quem tem participacao na empresa */
  FOR EACH crapepa WHERE crapepa.cdcooper = par_cdcooper AND
                         crapepa.nrdconta = par_nrdconta  
                         NO-LOCK:

      ASSIGN tot_persocio = tot_persocio + crapepa.persocio.

  END.
  
  FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                     crapjur.nrdconta = par_nrdconta
                     NO-LOCK NO-ERROR.

  IF AVAIL crapjur THEN
     DO:
        FIND gncdntj WHERE gncdntj.cdnatjur = crapjur.natjurid
                           NO-LOCK NO-ERROR.
  
        IF AVAIL gncdntj THEN
           DO:
              IF gncdntj.flgprsoc = TRUE THEN
                 DO:
                    IF tot_persocio = 0        THEN
                       ASSIGN par_dscritic = "GE: % societario nao " + 
                                             "informado na tela "    +
                                             "CONTAS."               + 
                                             " Verificar cadastro.".
                    ELSE
                       IF tot_persocio < 100 THEN
                          ASSIGN par_dscritic = "GE: % societario na tela" + 
                                                " CONTAS inferior a 100%." + 
                                                " Verificar cadastro.".

                 END.

           END.

     END.



END PROCEDURE.


/*Verifica se existe algum bloqueio referente a comprovacao de vida e gera 
  a devida mensagem para ser mostrada na tela CONTAS*/
PROCEDURE bloqueio_prova_vida:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INT                            NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-mensagens-contas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tpbloque AS INT                                     NO-UNDO.
    DEF VAR h-b1wgen0091  AS HANDLE                                 NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF NOT VALID-HANDLE(h-b1wgen0091) THEN
       RUN sistema/generico/procedures/b1wgen0091.p 
           PERSISTENT SET h-b1wgen0091.

    /*Como cada titular pode possuir o seu beneficio, sera pego cpf deste e 
      passado para a funcao verificacao_bloqueio.*/
    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                       crapttl.nrdconta = par_nrdconta AND
                       crapttl.idseqttl = par_idseqttl
                       NO-LOCK NO-ERROR.

    ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                           IN h-b1wgen0091,
                                           INPUT par_cdcooper,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdagenci,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_dtmvtolt,
                                           INPUT crapttl.nrcpfcgc,
                                           INPUT 0, /*nrbenefi/nrrecben*/
                                           INPUT 1 /*Verifica Qlqer bene.*/).

    /*Bloqueio por falta de comprovacao de vida ou comprovacao ainda 
      nao efetuada*/
    IF aux_tpbloque = 1 OR
       aux_tpbloque = 2 THEN
       RUN cria-registro-msg-contas ("Beneficiario com Prova de Vida Pendente. " +
                              "Efetue Comprovacao atraves da COMPVI. ").
    ELSE /*Menos de 60 dias para expirar o perido de um ano da comprovacao*/
       IF aux_tpbloque = 3 THEN 
          RUN cria-registro-msg-contas ("Este beneficiario devera efetuar a " + 
                                 "comprovacao de vida. A falta de "    +
                                 "renovacao  implicara no bloqueio do " + 
                                 "beneficio pelo INSS.").
         
    IF VALID-HANDLE(h-b1wgen0091) THEN
       DELETE OBJECT h-b1wgen0091.


    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/** Procedure obter mensagens de alerta para operacoes de credito em atraso **/
/*****************************************************************************/
PROCEDURE obtem-msg-credito-atraso:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
      
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_obtem_msg_credito_atraso 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT  par_cdcooper
                         ,INPUT  par_cdagenci
                         ,INPUT  par_nrdcaixa
                         ,INPUT  par_cdoperad
                         ,INPUT  par_nmdatela
                         ,INPUT  par_idorigem
                         ,INPUT  par_cdprogra
                         ,INPUT  par_nrdconta
                         ,INPUT  par_idseqttl
                         ,OUTPUT 0
                         ,OUTPUT "").  
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obtem_msg_credito_atraso
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    ASSIGN par_cdcritic = 0
           par_dscritic = ""
           par_cdcritic = pc_obtem_msg_credito_atraso.pr_cdcritic
                          WHEN pc_obtem_msg_credito_atraso.pr_cdcritic <> ?
           par_dscritic = pc_obtem_msg_credito_atraso.pr_dscritic
                          WHEN pc_obtem_msg_credito_atraso.pr_dscritic <> ?.
    
    
    RETURN "OK".
    
END PROCEDURE.
