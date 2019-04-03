/* ...........................................................................

   Programa: Fontes/proepr_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                     Ultima atualizacao: 21/03/2019

   Dados referentes ao programa: 

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento das alteracoes das propostas.

   Alteracoes: 19/03/97 - Alterado para trata FINANCIAMENTO COM HIPOTECA
                          (Edson).

               19/08/97 - Alterado para tratar nova regra para impressao da
                          proposta de emprestimo (Edson).

               25/09/97 - Alterado para emitir quantidade de promissorias
                          variavel (Edson).

               31/10/97 - Verificar se o associado tem menos de 18 anos e
                          avalistas (Odair).

               08/01/98 - Alterado para permitir somente debito em conta cor-
                          rente nos contratos de contas duplicadas (Deborah).

               03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               19/07/1999 - Exigir pelo menos um bem nos contratos de hipoteca
                            (Deborah).

               21/01/2000 - Alterado para 50 dias o primeiro pagamento
                            (Deborah).

               08/07/2000 - Tratar inhabmen, quando menor nao mostrar idade
                            (Odair)

               26/07/2000 - Tratar menor de 21 e nao de 18 (Odair)

               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               10/07/2001 - Aumentar a observacao nas propostas de emprestimos.
                            (Eduardo).

               01/08/2001 - Tratamento prejuizo de conta corrente (Margarete).

               16/12/2002 - Tratar nome e documento do conjuge dos fiadores
                            (Deborah).

               08/01/2003 - Maioridade de 21 para 18 anos (Deborah).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               01/12/2003 - Includi campo Nivel Risco(Mirtes)

               05/12/2003 - Incluido tratamento Concredi(Linha cred.24)(Mirtes)

               05/01/2004 - Subst.tratamento linha cred.24(Concredi), por nro
                            parcelas = 1 (Mirtes)

               03/06/2004 - Tratar linha com carencia da Viacredi

               11/06/2004 - Incluido campo tel_nivcalcu(Risco Calcul.(Evandro)

               16/06/2004 - Acessar dados Tabela Avalistas Terceiros(Mirtes)

               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               04/08/2004 - Erro critica dtdpagto (Margarete).

               11/08/2004 - Verificar valor maximo pessoa juridica(linha de
                            credito)(Mirtes)

               12/08/2004 - Tratar carencia na CREDITEXTIL (Edson).

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               30/08/2004 - Tratamento para linha de credito referente a
                            consignacao de emprestimo (Julio)

               08/10/2004 - Obter Risco do Rating(Associado)/Verificar
                            Atualizacao do Rating(Mirtes)

               12/11/2004 - Tratar linha (3) com carencia da Credifiesc
                            (Edson).

               18/11/2004 - Tratar linha (7) com carencia da Credifiesc
                            (Edson).

               10/12/2004 - Nao arredondar valores parcelas de emprestimo
                            (Mirtes).

               04/01/2005 - Corrigida a atribuicao ao campo crawepr.dscfcav2.
                            Era atribuido pro_cpfcgc2 e agora pro_cpfccg2.
                            (Evandro).

               14/01/2005 - Alterada a variavel aux_nrrenava de integer para
                           decimal (Julio)

               24/02/2005 - Forcar a alteracao da qftd de promissorias se
                            alterar a quantidade de prestacoes (Evandro).

               14/04/2005 - Tratar linha (8) com carencia da Credifiesc
                            (ZE).

               18/05/2005 - Alterada tabela craptab por crapcop (Diego).

               05/07/2005 - Alimentado campo cdcooper da tabela crapavt (Diego).

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               01/08/2005 - Alterado dias carencia de 120 p/180(Credifiesc)
                            na Linha de Credito 7 (Mirtes)

               25/08/2005 - Alterada procedure verificar_atualizacao_rating
                            (Mirtes)

               29/08/2005 - Incluido o estado civil dos fiadores na tabela
                            crapavt (Evandro).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               11/01/2006 - Inclusao do proprietario do bem;
                            Alterados dias de carencia da CREDIFIESC de 180
                            para 210 (Evandro).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               09/02/2006 - Inclusao de opcao NO-UNDO e tratamento de LOCKS
                            SQLWorks - Andre

               10/02/2006 - Comentados campos ali_uflicenc, aux_uflicenc ref.
                            "UF Licenciamento" (Diego).

               03/03/2006 - Carencia de 180 dias para linha de credito
                            38(Concredi)

               10/03/2006 - Carencia de 360 dias para linha de credito
                            116(Cecrisacred)

               14/03/2006 - Corrigido o display do campo da identidade e
                            busca de dados do avalista (Evandro).

               25/04/2006 - Alterado em "Dados dos Intervenientes Anuentes",
                            para permitir update em todos os campos somente
                            se conta = 0 (Diego).

               12/09/2006 - Excluidas opcoes "TAB" (Diego).

               19/09/2006 - Alterado para nao criticar(585) quando
                            interveniente anuente tiver menos de 18 anos e
                            for pessoa JURIDICA (Diego).

               16/10/2006 - Alterado para utilizar a tecla "F4" caso o usuario
                            deseje sair do frame f_observacao (Diego).

               25/10/2006 - Mostra mensagem quando valor do emprestimo for maior
                            que o estipulado na TAB033 (Elton).

               29/01/2007 - Nao habilitar liquidacao de outros emprestimos
                            quando craplcr.flgcrcta = FALSE (Diego).

               02/03/2007 - Carencia 270 dias p/ Creditextil linha 697(Mirtes)

               12/03/2007 - Carencia 190 dias p/ Viacredi(510/494)    (Mirtes)

               27/03/2007 - Substituido valores dos campos de endereco da
                            estrutura crapass pelos valores da estrutura
                            crapenc (Elton).

               30/03/2007 - Carencia 190 dias p/ Viacredi(496/497/498)(Mirtes)

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).

               01/10/2007 - Conversao de rotina ver_cadastro para BO
                            (Sidnei/Precise)

               08/10/2007 - Forcar flgpagto = false para linhas de credito
                            de emprestimo consignado (Julio)

               19/12/2007 - Incluir carencias para linhas de credito da
                            Transpocred (David).

              03/01/2008 - Carencia de 370 para a linha 497 (Magui).

              27/02/2008 - Nao permitir alterar nivel de risco(Mirtes).

              18/03/2008 - Incluida carencia de 360 para linha 216 Cecrisacred
                           (Mirtes)

              08/04/2008 - Alterado formato do campo "crawepr.qtpreemp"
                           de "z9" para "zz9"
                         - Kbase IT Solutions - Paulo Ricardo Maciel.

                         - Atualizar aux_qtdiacar = 270 quando CrediFoz e
                           craplcr.cdlcremp = 8 (Gabriel).

              13/05/2008 - Alterado para nao limpar os campos do Interveniente
                           Anuente quando ocorrer alteracao e nao for cooperado
                           (Elton).

              20/05/2008 - Utilizar a tabela crapccp para armazenar o
                           coeficiente da linhas de credito, no lugar do
                           extende atributo craplcr.incalpre(Sidnei - Precise)

              25/06/2008 - Carencia 270 dias para linha 8 Credicomin (Magui).

              14/07/2008 - Carencia 270 dias para linha 8
                           Crevisc e Scrcred (Magui).

              07/08/2008 - Carencia 190 dias linha 29 Transpocred (Magui).

              28/08/2008 - Na Credifiesc carencia de 280 linha 4 (Magui).

              23/09/2008 - Na Rodocredito carencia de 270 linha 8 (Magui).

              01/12/2008 - Carencia de 180 dias para linha 250 da Viacredi,
                           Credifiesc, Creditextil, Concredi e Credifoz (Magui).

              11/12/2008 - Carencia de 180 dias - linha 250 da Credcrea(Mirtes)

              16/12/2008 - Carencia de 180 dias - linha 251 da Viacredi(Mirtes)

              22/01/2009 - Alteracao cdempres (Diego).

              03/02/2009 - Nao permitir data de pagto > que o dia 28
                           para todas as linhas em todas as coops (Guilherme).

              12/02/2009 - Carencia de 90 dias nas linhas 34, 35 e 36 da
                           Transpocred (Magui).

              28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).

              25/05/2009 - Alteracao CDOPERAD e Tar.24969(Linha 92/carencia 370)
                           (Kbase/Mirtes).

              17/06/2009 - Substituida variavel pro_dsdebens por pro_dsrelbem
                           e variavel pro_vloutras por pro_vldrendi (Elton).

              06/07/2009 - Cadastro Pessoa fisica e juridica (Gabriel).

                         - Carencia 100 dias p/linha 17 e 18, Credelesc (Magui).

                         - Carencia 60 dias p/linha 24 e 25, Credifiesc (Magui).

              16/09/2009 - Padronizar o Prazo Minimo de Admissco para Concessao
                           de Credito (Ze).

              25/09/2009 - Ajuste na Liberacao Automatica de Credito (Ze).

              15/12/2009 - Ajuste para geracao do rating, incluir campo de
                           Qualif. Operacao (Gabriel).
                         - Alterar inhabmen da crapass para crapttl(Guilherme).
                         - Grava valores do rating nas tabelas crapttl quando
                           for fisica ou crapjur quando for juridica
                         - Gera valor do campo Qualif. Operacao automaticamente
                           (Elton).

              19/01/2010 - Alteracoes referente ao projeto CMAPRV 2 (David).

              03/02/2010 - Carencia de 190 dias na linha 598, Viacredi(Magui).

              01/03/2010 - Mostrar as criticas do Rating (Gabriel).

              18/03/2010 - Utilizar um browse dinamico.
                         - Corrigir problema quando mudança de estado
                           civil.
                         - Corrigir erro de associado nao encontrado
                           (Gabriel).

              01/06/2010 - Obter o risco a partir da BO 43 (Gabriel).
                           Carencia de 60dd para linha 32 (Magui).

              15/07/2010 - Automatizar dados vindo da central (Gabriel).

              21/07/2010 - Carencia de 190 dias, linha 30 Credifiesc (Magui).

              02/07/2010 - Projeto de melhorias de propostas (Gabriel).

              20/08/2010 - Carencia de 95 dias, linhas 57 e 58 Concredi(Magui).
                           Carencia de 190 dias, linha 43 Credcrea(Magui).

              24/11/2010 - Arrumado valor de prestacao (Gabriel).

              03/12/2010 - Ajuste no cadastro dos intervenientes (Gabriel).

              03/12/2010 - Bloquear o campo de 'CPF/CNPJ do Prop.' na
                           alienacao para as cooperativas com interveniente
                           bloqueado (Gabriel).

              27/01/2011 - Identificacao no procedure altera-valor-proposta
                           (Ze).

              13/04/2011 - Alterações realizados para CEP integrado. Campos
                           nrendere, complend e nrcxapst na tt-interv-anuentes
                           e tt-dados-avais. (André - DB1)

              07/06/2011 - Alteração de chamada para proepr_m. (André - DB1)

              04/07/2011 - Logar chamada das procedures (Gabriel).

              21/07/2011 - Inclusao do campo 'Tipo de Emprestimo' na tela
                                       com descricao inicial correspondente ao codigo 0.
                                       (Diego - GATI)

             06/09/2011 - Incluido a chamada da procedure alerta_fraude
                          (Adriano).

             13/09/2011 - Adicionado parametro par_tpemprst na procedure
                          valida dados gerais - INPUT 0. (Diego B. - GATI)

             25/11/2011 - Ajuste para a inclusao do campo "Justificativa"
                          (Adriano).

             12/06/2012 - Incluir liquidacao de contratos na 1a tela (Gabriel)

             06/10/2012 - Incluir function busca_grupo para verificar se
                          conta pertence ou nao a um grupo, incluir frames
                          f_ge_epr, f_ge_economico (Lucas R.).

             28/03/2013 - Ajustes realizados:
                          - Retirado todas as chamadas da procedure
                            alerta_fraude;
                          - Ajuste no layout dos frames f_ge_economico,
                            f_ge_epr (Adriano).

             27/06/2013 - Evitar passar na validacao do valida dados gerais
                          quando pressionado <F4> / END-ERROR (Gabriel).

             28/06/2013 - Verificar campo flgrefin antes de abrir a liquidacao
                          de contratos (Gabriel).

            08/01/2014 - Ajuste para desabilitar opcao "Imprimir" do campo
                         flgimpnp quando qtd de notas promissorias for 0.(Jorge)
                          
            23/01/2014 - Adicionados parametros para validação de   
                         CPF/CNPJ do proprietário dos bens como
                         interveniente (Lucas).
                          
            28/01/2014 - Exibicao do campo uflicenc no frame f_alienacao
                       - Novo parametro dschassi para valida-dados-alienacao
                         (Guilherme/SUPERO)
                         
            18/03/2014 - Novos parametros para valida-dados-alienacao
                         (Guilherme/SUPERO)                         
                         
            04/04/2014 - Alterado ordem do update tt-proposta-epr.cdfinemp 
                         no frame f_proepr. (Reinert)     
                         
            10/07/2014 - Alteraçao na temp table 
                         tt-grupo economico para utilizar b1wgen0138tt.i
                         (Chamado 130880) - (Tiago Castro - RKAM)
                         
            14/07/2014 - Adicionado tratamento para novos campos inpessoa e
                         dtnascto do avalista 1 e 2 (Daniel/Thiago) 
                         
            18/08/2014  - Projeto Automatização de Consultas em 
                          Propostas de Crédito (Jonata/RKAM).            
                         
            26/08/2014 - Ajustes referentes ao Projeto CET, chamar procedure 
                         para calcular automatico (Lucas R./Gielow)                   

            18/11/2014 - Inclusao do parametro nrcpfope na
                         procedure "valida-dados-gerais". (Jaison)
                         
            20/01/2015 - Adicionado parametro dstipbem, referente ao campo 
                         Tipo Veiculo. Adicionado campos na chamada da proc.
                         valida-dados-alienacao. (Jorge/Gielow) - SD 241854
                         
            10/04/2015 - Ajuste para aumentar o tempo que a mensagem de erro
                         fica em tela.(James)
                         
            21/05/2015 - Ajuste nos parametros da procedure 
                         "verifica-outras-propostas" (James)
                         
            28/05/2015 - Adicionado parametros na chamada da procedure 
                         obtem-dados-proposta-emprestimo. (Reinert)
                         
            29/05/2015 - Padronizacao das consultas automatizadas
                         (Gabriel-RKAM).
                         
            30/06/2015 - Ajuste nos parametros da procedure 
                         "valida-dados-gerais". (James)
                         
            30/09/2015 - Incluir parametro na procedure "altera-valor-proposta".(James)
			
			05/11/2015 - Incluido parametro cdmodali na chamada da procedure 
						 valida-dados-gerais. (Reinert)
                         
            17/11/2015 - Passagem do parametro (par_cdfinemp) na procedure 
                         calcula_cet_novo usado para portabilidade. Projeto 
                         Portabilidade de credito (Carlos Rafael Tanholi).                         
                         
            10/12/2015 - Adicionado validacoes para nao digitar caracteres
                         especiais e as letras "Q I O" no campo chassi
                         (Tiago/Gielow SD369691)                         
                         
            26/01/2016 - Incluido tratamento para apresentar mensagem,
                         caso o valor do bem for superior a 5 vezes ao 
                         valor do emprestimo. (James)        
						 
            14/03/2016 - Incluir campo cdpactra na chamada da rotina 
			             grava-proposta-completa. PRJ207 - Esteira 
						 (Odirlei-AMcom)						                  
                         
            15/12/2017 - Inserção do campo idcobope. PRJ404 (Lombardi)

            24/01/2018 - Passagem de parametros nulos. (Jaison/James - PRJ298)
            
            23/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)  

            21/03/2019 - P437 - Consignado - Inclusao dos parametros par_vlpreempi e par_vlrdoiof 
                         na chamada da rotina valida-dados-gerais - Josiane Stiehler - AMcom
						 
			25/03/2019 - P437 - Consignado - Inclusao do parametro par_vlrdoiof 
                         na chamada da rotina altera-valor-proposta - Fernanda Kelli de Oliveira - AMcom			 

........................................................................... */

DEF INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_nrctremp AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_vltotemp AS DECI                                   NO-UNDO.
DEF INPUT PARAM par_dsdidade AS CHAR                                   NO-UNDO.

DEF VAR aux_inconfi2 AS INTE                                           NO-UNDO.
DEF VAR aux_percetop AS DECI                                           NO-UNDO.
DEF VAR aux_txcetmes AS DECI                                           NO-UNDO.
DEF VAR aux_flmudfai AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsenha AS INTE                                           NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.
DEF VAR aux_nsenhaok AS LOGI                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dscatbem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsctrliq AS CHAR                                           NO-UNDO.
DEF VAR aux_idpeapro AS INT                                            NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }

{ includes/var_online.i   }
{ includes/var_proepr.i   }
{ includes/var_proposta.i }
{ includes/gg0000.i       }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }
{ sistema/ayllos/includes/verifica_caracter.i }

EMPTY TEMP-TABLE tt-grupo.

DEF QUERY q-ge-economico FOR tt-grupo.

DEF BROWSE b-ge-economico QUERY q-ge-economico
    DISPLAY tt-grupo.nrctasoc
    WITH 3 DOWN WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                      AT 7
     par_nrdconta
     "pertence a Grupo Economico."
     SKIP
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)
     "Grupo possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"
     SKIP
     "-------------------------------------"      AT 7
     SKIP
     b-ge-economico                               AT 18
     HELP "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_ge_economico.

DEF QUERY q-ge-epr FOR tt-grupo.

DEF BROWSE b-ge-epr QUERY q-ge-epr
    DISPLAY tt-grupo.nrctasoc
    WITH 3 DOWN CENTERED WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                 AT 6
     par_nrdconta
     "pertence a Grupo Economico."
     SKIP
     "Risco Atual do Grupo:"                 AT 6
     tt-grupo.dsdrisgp
     "."
     SKIP(1)
     "Grupo possui"                          AT 6
     aux_qtctarel
     "Contas Relacionadas:"
     SKIP
     "-------------------------------------" AT 6
     SKIP
     b-ge-epr                                AT 18
     HELP "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_ge_epr.

ON END-ERROR OF tt-proposta-epr.dsobserv IN FRAME f_observacao DO:

   NEXT-PROMPT btn_btaosair WITH FRAME f_observacao.
   RETURN NO-APPLY.

END.

ON RETURN OF btn_btaosair IN FRAME f_observacao DO:

   APPLY "GO".

END.

ON RETURN OF tt-proposta-epr.dsobserv DO:

   APPLY 32.

END.

ON RETURN OF b-ge-epr IN FRAME f_ge_epr DO:

   APPLY "GO".

END.

ON RETURN OF b-ge-economico IN FRAME f_ge_economico DO:

   APPLY "GO".

END.

/* Se for pessoa fisica e menor de idade  */
IF   par_dsdidade <> ""   THEN
     DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             BELL.

             DISPLAY SKIP(1)
                     par_dsdidade FORMAT "x(70)"
                     SKIP(1)
                     WITH ROW 13 NO-LABELS CENTERED OVERLAY FRAME f_idade.

             PAUSE MESSAGE "Tecle <Enter> para continuar...".

             LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         HIDE FRAME f_idade NO-PAUSE.

     END.

DISPLAY tel_btaltepr
        tel_btaltvlr
        tel_btalnume
        tel_btconsul
        WITH FRAME f_opcoes_alterar.

/* Tipo de alteracao (Total, valor ou numero da proposta ) */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    CHOOSE FIELD tel_btaltepr
                 tel_btaltvlr
                 tel_btalnume
                 tel_btconsul WITH FRAME f_opcoes_alterar.

    CASE FRAME-VALUE:

        WHEN tel_btaltepr THEN  ASSIGN aux_tpaltera = 1.
        WHEN tel_btaltvlr THEN  ASSIGN aux_tpaltera = 2.
        WHEN tel_btalnume THEN  ASSIGN aux_tpaltera = 3.
        WHEN tel_btconsul THEN  ASSIGN aux_tpaltera = 4.

    END CASE.

    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_opcoes_alterar NO-PAUSE.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    RETURN.

/* Verifica se o banco generico ja esta conectado */
ASSIGN aux_flggener = f_verconexaogener().

/* Se nao consegui se conectar */
IF   NOT aux_flggener     AND
     NOT f_conectagener() THEN
     RETURN.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT 1, /* Ayllos */
                                         INPUT par_nrdconta,
                                         INPUT 1, /* Tit. */
                                         INPUT glb_dtmvtolt,
                                         INPUT par_nrctremp,
                                         INPUT "A", /* Alteraçao */
                                         INPUT 1,
                                         INPUT TRUE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dados-coope,
                                         OUTPUT TABLE tt-dados-assoc,
                                         OUTPUT TABLE tt-tipo-rendi,
                                         OUTPUT TABLE tt-itens-topico-rating,

                                         OUTPUT TABLE tt-proposta-epr,
                                         OUTPUT TABLE tt-crapbem,
                                         OUTPUT TABLE tt-bens-alienacao,
                                         OUTPUT TABLE tt-rendimento,
                                         OUTPUT TABLE tt-faturam,
                                         OUTPUT TABLE tt-dados-analise,
                                         OUTPUT TABLE tt-interv-anuentes,
                                         OUTPUT TABLE tt-hipoteca,
                                         OUTPUT TABLE tt-dados-avais,
                                         OUTPUT TABLE tt-aval-crapbem,
                                         OUTPUT TABLE tt-msg-confirma).

DELETE PROCEDURE h-b1wgen0002.

/* Desconectar se nao estava conectado */
IF   NOT aux_flggener  THEN
     RUN p_desconectagener.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
         ELSE
              MESSAGE "Erro na busca dos dados da proposta.".

         RETURN.
     END.

/* Dados gerais da cooperativa */
FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.

/* Dados gerias do cooperado */
FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.

/* Dados na crawepr */
FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.

IF  tt-proposta-epr.tpemprst = 1 THEN
    DO:
        MESSAGE "Operacao invalida para esse tipo de contrato".
        RETURN.
    END.

ALTERACAO:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   aux_tpaltera = 4    THEN
        DO:
             RUN efetua_buscas.
             LEAVE.
        END.

   ASSIGN aux_vleprori = tt-proposta-epr.vlemprst
          aux_vlpreemp = tt-proposta-epr.vlpreemp
          ant_dslcremp = tt-proposta-epr.dslcremp
          ant_dsfinemp = tt-proposta-epr.dsfinemp.

   DISPLAY tt-proposta-epr.dslcremp
           tt-proposta-epr.dsfinemp
           tt-proposta-epr.vlpreemp
           tt-proposta-epr.idquapro
           tt-proposta-epr.dsquapro
           tt-proposta-epr.percetop
           fn_dstpempr(tt-proposta-epr.tpemprst,
                       tt-proposta-epr.cdtpempr,
                       tt-proposta-epr.dstpempr) @ aux_dstpempr
           WITH FRAME f_proepr.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

     DISPLAY tt-proposta-epr.nivrisco
             tt-proposta-epr.dsctrliq WITH FRAME f_proepr.

     IF    aux_tpaltera <> 2   THEN
           DISPLAY tt-proposta-epr.vlemprst WITH FRAME f_proepr.

     IF    aux_tpaltera <> 1   THEN
           DISPLAY tt-proposta-epr.qtpreemp tt-proposta-epr.cdlcremp
                   tt-proposta-epr.cdfinemp tt-proposta-epr.percetop
                   tt-proposta-epr.qtdialib tt-proposta-epr.flgpagto
                   tt-proposta-epr.dtdpagto tt-proposta-epr.flgimppr
                   tt-proposta-epr.flgimpnp WITH FRAME f_proepr.
    
     IF  tt-proposta-epr.qtpromis = 0  THEN
          DO:
              tt-proposta-epr.flgimpnp = FALSE.
              DISP tt-proposta-epr.flgimpnp WITH FRAME f_proepr.
          END.

     UPDATE tt-proposta-epr.vlemprst WHEN aux_tpaltera = 2
            tt-proposta-epr.qtpreemp WHEN aux_tpaltera = 1            
            tt-proposta-epr.cdfinemp WHEN aux_tpaltera = 1
            tt-proposta-epr.cdlcremp WHEN aux_tpaltera = 1
            tt-proposta-epr.qtdialib WHEN aux_tpaltera = 1
            tt-proposta-epr.flgpagto WHEN aux_tpaltera = 1
            tt-proposta-epr.dtdpagto WHEN aux_tpaltera = 1
            tt-proposta-epr.flgimppr WHEN aux_tpaltera = 1
            tt-proposta-epr.flgimpnp WHEN aux_tpaltera = 1 
                                      AND tt-proposta-epr.qtpromis <> 0
            WITH FRAME f_proepr

     EDITING:

        IF   FRAME-FIELD = "dtdpagto"  THEN
             DO:
                 IF  INPUT tt-proposta-epr.flgpagto   THEN
                      APPLY ant_cddtecla.
             END.

        READKEY.

        ant_cddtecla = LASTKEY.

        IF   FRAME-FIELD = "cdfinemp"  THEN
             DO:
                 IF   LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          RUN fontes/zoom_finalidades_de_emprestimo.p

                                            (INPUT glb_cdcooper,
                                             INPUT TRUE,
                                             OUTPUT tt-proposta-epr.cdfinemp,
                                             OUTPUT tt-proposta-epr.dsfinemp).

                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               NEXT.

                           DISPLAY tt-proposta-epr.cdfinemp
                                   tt-proposta-epr.dsfinemp
                                   WITH FRAME f_proepr.
                      END.
                 ELSE
                      APPLY LASTKEY.
             END.       
        ELSE
        IF   FRAME-FIELD = "cdlcremp"  THEN
             DO:
                 IF   LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          RUN fontes/zoom_linhas_de_credito.p
                                           (INPUT  glb_cdcooper,
                                      INPUT FRAME f_proepr tt-proposta-epr.cdfinemp,
                                            INPUT  TRUE, /*Somente liberadas*/
                                            OUTPUT tt-proposta-epr.cdlcremp,
                                            OUTPUT tt-proposta-epr.dslcremp).

                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                               NEXT.

                          DISPLAY tt-proposta-epr.cdlcremp
                                  tt-proposta-epr.dslcremp
                                  WITH FRAME f_proepr.

                      END.
                 ELSE
                      APPLY LASTKEY.
             END.
        ELSE
        IF   FRAME-FIELD = "flgpagto"  THEN
             DO:
                 ant_cddtecla = LASTKEY.

                 IF   NOT tt-dados-assoc.flgpagto      AND
                      INPUT tt-proposta-epr.flgpagto   THEN
                      DO:
                          tt-proposta-epr.flgpagto = FALSE.

                          DISPLAY tt-proposta-epr.flgpagto
                                  WITH FRAME f_proepr.
                      END.

                 APPLY LASTKEY.
             END.
        ELSE
        IF   FRAME-FIELD = "vlemprst"   THEN
             IF   LASTKEY =  KEYCODE(".")   THEN
                  APPLY 44.
             ELSE
                  APPLY LASTKEY.
        ELSE
        IF   FRAME-FIELD = "flgimppr"   THEN
             DO:
                 IF   INPUT tt-proposta-epr.vlemprst >
                      tt-dados-coope.vlemprst   THEN
                      DO:
                          tt-proposta-epr.flgimppr = TRUE.

                          DISPLAY tt-proposta-epr.flgimppr
                                  WITH FRAME f_proepr.
                          PAUSE 0.
                      END.

                 APPLY LASTKEY.

             END.
        ELSE
             APPLY LASTKEY.

     END.  /*  Fim do EDITING  */

     IF   aux_tpaltera = 1   THEN
          DO:
              IF   par_vltotemp > 0    AND
                   INPUT FRAME f_proepr tt-proposta-epr.cdlcremp <> 100 THEN
                   DO:
                        IF  glb_cdcooper = 4 AND       /* Probl.telas */
                            par_nrdconta = 5940 THEN
                            .
                        ELSE
                            RUN fontes/proepr_l.p
                               (INPUT tt-proposta-epr.cdlcremp,
                                INPUT INPUT tt-proposta-epr.vlemprst,
                                INPUT-OUTPUT tt-proposta-epr.dsctrliq).

                        IF   tt-proposta-epr.dsctrliq <> ""   THEN
                             RUN proc_qualif_operacao.
                   END.
              ELSE
                   tt-proposta-epr.dsctrliq = "Sem liquidacoes".

              DISPLAY tt-proposta-epr.dsctrliq
                      tt-proposta-epr.idquapro
                      tt-proposta-epr.dsquapro WITH FRAME f_proepr.
              PAUSE.
          END.

     /* Alteracao só do valor da proposta */
     IF aux_tpaltera = 2 THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    
               
               /* Valida os dados da tela */
               RUN valida_alteracao_valor_proposta.
                              
               IF RETURN-VALUE <> "OK" THEN
                  NEXT ALTERACAO.
                  
               LEAVE.   
                  
            END. /* END WHILE */
            
        END. /* END IF aux_tpaltera = 2 THEN */
        
     IF  aux_tpaltera = 1  OR       /* Alteracao de toda a proposta      */
         aux_tpaltera = 2  THEN     /* Alteracao só do valor da proposta */
         DO:
             ASSIGN aux_contador = 1
                    aux_inconfi2 = 30.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF NOT VALID-HANDLE(h-b1wgen0002) THEN
                   RUN sistema/generico/procedures/b1wgen0002.p
                       PERSISTENT SET h-b1wgen0002.

                RUN valida-dados-gerais IN h-b1wgen0002
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /* Ayllos */
                                         INPUT par_nrdconta,
                                         INPUT 1, /* Tit */
                                         INPUT glb_dtmvtolt,
                                         INPUT glb_dtmvtopr,
                                         INPUT "A", /* Alteracao */
                                         INPUT glb_inproces,
                                         INPUT tt-dados-assoc.cdagenci,
                                         INPUT par_nrctremp,
                                         INPUT tt-proposta-epr.cdlcremp,
                                         INPUT tt-proposta-epr.qtpreemp,
                                         INPUT tt-proposta-epr.dsctrliq,
                                         INPUT tt-dados-coope.vlmaxutl,
                                         INPUT tt-dados-coope.vlmaxleg,
                                         INPUT tt-dados-coope.vlcnsscr,
                                         INPUT tt-proposta-epr.vlemprst,
                                         INPUT tt-proposta-epr.dtdpagto,
                                         INPUT aux_contador,
                                         INPUT aux_tpaltera,
                                         INPUT tt-dados-assoc.cdempres,
                                         INPUT tt-proposta-epr.flgpagto,
                                         INPUT aux_dtdpagto,
                                         INPUT aux_ddmesnov,
                                         INPUT tt-proposta-epr.cdfinemp,
                                         INPUT tt-proposta-epr.qtdialib,
                                         INPUT tt-dados-assoc.inmatric,
                                         INPUT TRUE,
                                         INPUT 0, /* tpemprst */
                                         INPUT ?, /* dtlibera */
                                         INPUT aux_inconfi2,
                                         INPUT 0, /* nrcpfope */
										 INPUT "", /* cdmodali */
                                         INPUT ?, /* par_idcarenc */
                                         INPUT ?, /* par_dtcarenc */
										 INPUT tt-proposta-epr.idfiniof, /* par_idfiniof */
                                         INPUT tt-proposta-epr.idquapro,
                                         INPUT 0, /*par_vlpreempi*/
                                         INPUT -1, /*par_vlrdoiof*/
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-msg-confirma,
                                         OUTPUT TABLE tt-grupo,
                                         OUTPUT par_dsmesage,
                                         OUTPUT tt-proposta-epr.vlpreemp,
                                         OUTPUT tt-proposta-epr.dslcremp,
                                         OUTPUT tt-proposta-epr.dsfinemp,
                                         OUTPUT tt-proposta-epr.tplcremp,
                                         OUTPUT tt-proposta-epr.flgpagto,
                                         OUTPUT tt-proposta-epr.dtdpagto,
                                         OUTPUT par_vlutiliz,
                                         OUTPUT tt-proposta-epr.nivrisco).

                IF RETURN-VALUE <> "OK"   THEN
                   DO:
                      FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

                      /* Se tem mensagem de confirmacao */
                      IF AVAIL tt-msg-confirma   THEN
                         DO:
                             MESSAGE tt-msg-confirma.dsmensag.

                             /*Se a conta em questao faz parte de um grupo economico, serao
                               listados as contas que se relacionam com a mesma.*/
                             IF TEMP-TABLE tt-grupo:HAS-RECORDS AND
                                tt-msg-confirma.inconfir = 3              THEN
                                DO:
                                    ASSIGN aux_qtctarel = 0.

                                    FOR EACH tt-grupo NO-LOCK:

                                        ASSIGN aux_qtctarel = aux_qtctarel + 1.

                                    END.

                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                       DISP par_nrdconta
                                            aux_qtctarel
                                            WITH FRAME f_ge_economico.

                                       OPEN QUERY q-ge-economico
                                            FOR EACH tt-grupo NO-LOCK
                                                BY tt-grupo.cdagenci
                                                   BY tt-grupo.nrctasoc.

                                       UPDATE b-ge-economico
                                              WITH FRAME f_ge_economico.

                                       LEAVE.

                                    END.

                                    CLOSE QUERY q-ge-economico.
                                    HIDE FRAME f_ge_economico.

                                END.

                             HIDE MESSAGE.

                         END.

                      FIND FIRST tt-erro NO-LOCK NO-ERROR.

                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                         IF   AVAIL tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                         ELSE
                              MESSAGE "Erro na validaçao da proposta.".

                         PAUSE 5 NO-MESSAGE.
                         LEAVE.

                      END.

                      /* Voltar valores */
                      ASSIGN tt-proposta-epr.vlpreemp = aux_vlpreemp
                             tt-proposta-epr.vlemprst = aux_vleprori
                             tt-proposta-epr.dslcremp = ant_dslcremp
                             tt-proposta-epr.dsfinemp = ant_dsfinemp.

                      IF  VALID-HANDLE(h-b1wgen0002) THEN
                          DELETE OBJECT h-b1wgen0002.

                      NEXT ALTERACAO.

                   END.

                FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

                /* Se tem mensagem de confirmacao */
                IF AVAIL tt-msg-confirma   THEN
                   DO:
                      IF tt-msg-confirma.inconfir = 31 THEN
                         RUN fontes/confirma.p (INPUT tt-msg-confirma.dsmensag + "Confirma?",
                                                OUTPUT aux_confirma).
                      ELSE
                         RUN fontes/confirma.p (INPUT tt-msg-confirma.dsmensag,
                                                OUTPUT aux_confirma).

                      IF aux_confirma <> "S"   THEN
                         DO:
                             /* Voltar valores */
                             ASSIGN tt-proposta-epr.vlpreemp = aux_vlpreemp
                                    tt-proposta-epr.vlemprst = aux_vleprori
                                    tt-proposta-epr.dslcremp = ant_dslcremp
                                    tt-proposta-epr.dsfinemp = ant_dsfinemp.

                             NEXT ALTERACAO.

                         END.
                      ELSE
                         DO:
                           IF tt-msg-confirma.inconfir = 31 THEN
                               ASSIGN aux_inconfi2 = tt-msg-confirma.inconfir.
                           ELSE
                               ASSIGN aux_contador = tt-msg-confirma.inconfir + 1.
                           NEXT.
                         END.
                   END.

               ASSIGN aux_dscatbem = "".
               FOR EACH crapbpr WHERE crapbpr.cdcooper = glb_cdcooper  AND
                                     crapbpr.nrdconta = par_nrdconta  AND
                                     crapbpr.nrctrpro = tt-proposta-epr.nrctremp  AND 
                                     crapbpr.tpctrpro = 90 NO-LOCK:
                  ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
               END.
               
               RUN buscar_liquidacoes_contrato IN h-b1wgen0002(INPUT glb_cdcooper,
                                                               INPUT par_nrdconta,
                                                               INPUT tt-proposta-epr.nrctremp,
                                                               OUTPUT aux_dsctrliq).  
                                                              
                /* Calclar o cet automaticamente */
                RUN calcula_cet_novo IN h-b1wgen0002(
                                     INPUT glb_cdcooper,
                                     INPUT 0, /* agencia */
                                     INPUT 0, /* caixa */
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1, /* ayllos */
                                     INPUT glb_dtmvtolt,
                                     INPUT par_nrdconta,

                                     INPUT tt-proposta-epr.inpessoa, 
                                     INPUT 2, /* cdusolcr */
                                     INPUT tt-proposta-epr.cdlcremp, 
                                     INPUT tt-proposta-epr.tpemprst, 
                                     INPUT tt-proposta-epr.nrctremp, 
                                     INPUT (IF tt-proposta-epr.dtlibera <> ? THEN 
                                               tt-proposta-epr.dtlibera
                                            ELSE glb_dtmvtolt), 
                                     INPUT tt-proposta-epr.vlemprst, 
                                     INPUT tt-proposta-epr.vlpreemp, 
                                     INPUT tt-proposta-epr.qtpreemp, 
                                     INPUT tt-proposta-epr.dtdpagto, 
                                     INPUT tt-proposta-epr.cdfinemp,
                                     INPUT aux_dscatbem, /* dscatbem */
                                     INPUT tt-proposta-epr.idfiniof, /* idfiniof */
                                     INPUT aux_dsctrliq, /* dsctrliq */
                                     INPUT "N",
                                    OUTPUT aux_percetop, /* taxa cet ano */
                                    OUTPUT aux_txcetmes, /* taxa cet mes */
                                    OUTPUT TABLE tt-erro). 
                 
                 IF  VALID-HANDLE(h-b1wgen0002) THEN
                     DELETE OBJECT h-b1wgen0002.
        
                 IF  RETURN-VALUE <> "OK" THEN
                     DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             IF  AVAIL tt-erro THEN
                                 MESSAGE tt-erro.dscritic.
                                      
                             PAUSE 3 NO-MESSAGE.
                             LEAVE.
                         END.
                         
                         NEXT ALTERACAO.
                     END.

                 ASSIGN tt-proposta-epr.percetop = aux_percetop.
                
                 DISPLAY tt-proposta-epr.vlpreemp 
                         tt-proposta-epr.percetop WITH FRAME f_proepr.

                LEAVE.

             END. /* Fim do DO WHILE TRUE */
         END.

     IF  aux_tpaltera = 2 THEN /* Alteraçao só do valor da operacao */
         DO:
             DISPLAY tt-proposta-epr.vlpreemp WITH FRAME f_proepr.

             IF   par_dsmesage <> "" THEN
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      MESSAGE par_dsmesage.
                      PAUSE.
                      LEAVE.
                  END.

             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).

             IF  aux_confirma <> "S"   THEN
                 DO:
                     /* Volta valores */
                     ASSIGN tt-proposta-epr.vlpreemp = aux_vlpreemp
                            tt-proposta-epr.vlemprst = aux_vleprori.

                     NEXT ALTERACAO.
                 END.

             MESSAGE "Aguarde, efetuando a alteracao ...".

              DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                 PAUSE 2 NO-MESSAGE.
                 LEAVE.
             END.

             HIDE MESSAGE NO-PAUSE.

             ASSIGN aux_idpeapro = 0.
             RUN sistema/generico/procedures/b1wgen0002.p
                 PERSISTENT SET h-b1wgen0002.

             RUN altera-valor-proposta IN h-b1wgen0002
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1, /* Ayllos */
                                        INPUT par_nrdconta,
                                        INPUT 1, /* Tit*/
                                        INPUT glb_dtmvtolt,
                                        INPUT par_nrctremp,
                                        INPUT tt-dados-coope.flgcmtlc,
                                        INPUT tt-proposta-epr.vlemprst,
                                        INPUT tt-proposta-epr.vlpreemp,
                                        INPUT par_vlutiliz,
                                        INPUT aux_vleprori,
                                        INPUT tt-dados-coope.vllimapv,
                                        INPUT TRUE,
                                        INPUT "SVP",  /* Alt. Somente Valor */
                                        INPUT tt-proposta-epr.dtlibera,
										INPUT 0, /*par_idfiniof*/
										INPUT "", /*par_dscatbem*/
										INPUT 1, /*par_inresapr*/
										INPUT glb_dtmvtolt, /*par_dtdpagto*/
										INPUT 0,  /*par_vlrdoiof */ /* P437 Consignado */
                                        OUTPUT aux_flmudfai,
                                        INPUT-OUTPUT aux_idpeapro,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma).

             DELETE PROCEDURE h-b1wgen0002.

             HIDE MESSAGE NO-PAUSE.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.

                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE
                              "Erro na alteracao do valor da proposta.".

                      DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                          PAUSE 3 NO-MESSAGE.
                          LEAVE.
                      END.

                      /* Volta valores */
                     ASSIGN tt-proposta-epr.vlpreemp = aux_vlpreemp
                            tt-proposta-epr.vlemprst = aux_vleprori.

                      NEXT ALTERACAO.

                  END.

             /* Se nao houce mudanca de faixa de valor */
             IF   aux_flmudfai = "N"   THEN
                  DO:
                      RUN efetua_buscas.
                  END.

             /* Mensagens sobre a aprovacao da proposta */
             FOR EACH tt-msg-confirma NO-LOCK:

                 MESSAGE tt-msg-confirma.dsmensag.

                 DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                     PAUSE 3 NO-MESSAGE.
                     LEAVE.
                 END.

                 HIDE MESSAGE NO-PAUSE.

             END.

             HIDE FRAME f_proepr     NO-PAUSE.
             HIDE FRAME f_observacao NO-PAUSE.


             RETURN.

         END.   /* Fim da alteracao do valor da proposta */

     IF  aux_tpaltera = 3   THEN /* Alteracao soh do numero da proposta */
         DO:
             PAUSE 0.

             DISPLAY tt-proposta-epr.nrctremp WITH FRAME f_numero.

             DO WHILE TRUE ON ENDKEY UNDO , LEAVE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     UPDATE nov_nrctremp WITH FRAME f_numero.
                     LEAVE.

                END.

                IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                     DO:
                         HIDE FRAME f_numero.
                         RETURN.
                     END.

                RUN fontes/confirma.p (INPUT "",
                                       OUTPUT aux_confirma).

                IF   aux_confirma <> "S"   THEN
                     DO:
                         HIDE FRAME f_numero.
                         NEXT.
                     END.

                RUN sistema/generico/procedures/b1wgen0002.p
                    PERSISTEN SET h-b1wgen0002.

                RUN altera-numero-proposta IN h-b1wgen0002
                                           (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT 1, /* Ayllos*/
                                            INPUT par_nrdconta,
                                            INPUT 1, /* Tit */
                                            INPUT glb_dtmvtolt,
                                            INPUT tt-proposta-epr.nrctremp,
                                            INPUT nov_nrctremp,
                                            INPUT tt-proposta-epr.cdlcremp,
                                            INPUT TRUE,
                                            OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0002.

                IF   RETURN-VALUE <> "OK"   THEN
                     DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.

                         IF   AVAIL tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                         ELSE
                              MESSAGE
                                  "Erro na alteracao do numero da proposta.".

                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                         END.

                         NEXT.

                     END.

                LEAVE.

             END. /* Fim DO WHILE TRUE */

             HIDE FRAME f_numero.

             RETURN.

         END.

     PAUSE 0.

     /* Se chegou aqui , entao é alteracao da proposta toda */

     
     /* Cadastro de avalistas */
     RUN fontes/proepr_inp.p (INPUT par_nrdconta,
                              INPUT par_nrctremp,
                              INPUT tt-proposta-epr.qtpreemp,
                              INPUT TABLE tt-itens-topico-rating,
                              INPUT-OUTPUT tt-proposta-epr.qtpromis,
                              INPUT-OUTPUT TABLE tt-dados-avais,
                              INPUT-OUTPUT TABLE tt-aval-crapbem,
                              INPUT-OUTPUT TABLE tt-dados-analise).

     IF   RETURN-VALUE <> "OK"   THEN
          NEXT ALTERACAO.

     /* Bens / Rendimentos do cooperado/conjuge e Analise da proposta */
     RUN fontes/proepr_ipr.p (INPUT glb_cdcooper,
                              INPUT par_nrdconta,
                              INPUT TABLE tt-itens-topico-rating,
                              INPUT-OUTPUT TABLE tt-tipo-rendi,
                              INPUT-OUTPUT TABLE tt-rendimento,
                              INPUT-OUTPUT TABLE tt-faturam,
                              INPUT-OUTPUT TABLE tt-crapbem,
                              INPUT-OUTPUT TABLE tt-dados-analise).

     /* Obter o tipo de pessoa */
     FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

     /* Orgaos de protecao ao credito */
     RUN fontes/proepr_org.p (INPUT par_nrdconta,
                              INPUT par_nrctremp,
                              INPUT 0,
                              INPUT tt-rendimento.inpessoa,
                              INPUT par_nrdconta,
                              INPUT 0,
                              INPUT TABLE tt-itens-topico-rating,
                              INPUT-OUTPUT TABLE tt-dados-analise).
     
     IF   RETURN-VALUE <> "OK"   THEN
          NEXT ALTERACAO.

     /* Se tem que consultar ao conjuge  */
     IF   tt-rendimento.inconcje   THEN
          DO:
              /* Orgaos de protecao ao credito */
              RUN fontes/proepr_org.p (INPUT par_nrdconta,
                                       INPUT par_nrctremp,
                                       INPUT 99,
                                       INPUT 1,
                                       INPUT tt-dados-assoc.nrctacje,
                                       INPUT tt-dados-assoc.nrcpfcjg,
                                       INPUT TABLE tt-itens-topico-rating,
                                       INPUT-OUTPUT TABLE tt-dados-analise).
     
              IF   RETURN-VALUE <> "OK"   THEN
                   NEXT ALTERACAO.
          
          END.
         
     HIDE FRAME f_pro_fis NO-PAUSE.
     HIDE FRAME f_pro_jur NO-PAUSE.

     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
          NEXT.

     /* Mostrar prestacao , descricao da linha e finalidade */
     DISPLAY tt-proposta-epr.vlpreemp
             tt-proposta-epr.dslcremp
             tt-proposta-epr.dsfinemp
             tt-proposta-epr.idquapro
             tt-proposta-epr.dsquapro WITH FRAME f_proepr.

     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
          NEXT.

     IF   tt-proposta-epr.tplcremp = 2    THEN   /*  ALIENACAO FIDUCIARIA  */
          DO:
              ASSIGN aux_contador = 0.

              ALIENACAO:
              DO WHILE TRUE:

                 HIDE FRAME f_alienacao.

                 ASSIGN aux_contador = aux_contador + 1.

                 FIND tt-bens-alienacao WHERE
                      tt-bens-alienacao.idalibem = aux_contador
                      EXCLUSIVE-LOCK NO-ERROR.

                 IF   NOT AVAIL tt-bens-alienacao  THEN
                      DO:
                          CREATE tt-bens-alienacao.
                          ASSIGN tt-bens-alienacao.idalibem = aux_contador.
                                 tt-bens-alienacao.lsbemfin =
                                         "( " + STRING(aux_contador,"z9") +
                                         "º Bem )".

                           IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
                               RUN sistema/generico/procedures/b1wgen0002.p
                                   PERSISTENT SET h-b1wgen0002.

                           RUN retorna_UF_PA_ASS IN h-b1wgen0002
                                        (INPUT glb_cdcooper,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_uflicenc).

                           ASSIGN tt-bens-alienacao.uflicenc = aux_uflicenc.

                           IF  VALID-HANDLE(h-b1wgen0002) THEN
                               DELETE OBJECT h-b1wgen0002.
                 END.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    DISPLAY tt-bens-alienacao.lsbemfin
                            tt-bens-alienacao.uflicenc WITH FRAME f_alienacao.

                    /* O campo 'CPF/CNPJ do Prop' depende da TAB016 */
                    IF   NOT tt-dados-coope.flginter  THEN
                         DISPLAY tt-bens-alienacao.nrcpfbem
                                 WITH FRAME f_alienacao.

                    HIDE tt-bens-alienacao.dstipbem.

                    UPDATE tt-bens-alienacao.dscatbem
                           tt-bens-alienacao.dstipbem
                           tt-bens-alienacao.dsbemfin
                           tt-bens-alienacao.dscorbem
                           tt-bens-alienacao.vlmerbem
                           tt-bens-alienacao.dschassi
                           tt-bens-alienacao.tpchassi
                           tt-bens-alienacao.ufdplaca
                           tt-bens-alienacao.nrdplaca
                           tt-bens-alienacao.nrrenava
                           tt-bens-alienacao.nranobem
                           tt-bens-alienacao.nrmodbem
                           tt-bens-alienacao.nrcpfbem
                                   WHEN tt-dados-coope.flginter
                           WITH FRAME f_alienacao

                        TITLE " Dados para Alienacao Fiduciaria " +
                              "(" + STRING(aux_contador,"9")      + ") "

                    EDITING:

                       READKEY.

                       IF   FRAME-FIELD = "dscatbem"   THEN
                            DO:
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
                                     DO:
                                         aux_nrindcat = aux_nrindcat - 1.

                                         IF   aux_nrindcat <= 0   THEN
                                              aux_nrindcat =
                                                  NUM-ENTRIES(aux_lscatbem).

                                         tt-bens-alienacao.dscatbem =
                                             ENTRY(aux_nrindcat,
                                                   aux_lscatbem).

                                         DISPLAY tt-bens-alienacao.dscatbem
                                                 WITH FRAME f_alienacao.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
                                     DO:
                                         aux_nrindcat = aux_nrindcat + 1.

                                         IF   aux_nrindcat >
                                              NUM-ENTRIES(aux_lscatbem)   THEN
                                              aux_nrindcat = 1.

                                         tt-bens-alienacao.dscatbem =
                                             ENTRY(aux_nrindcat,
                                                   aux_lscatbem).

                                         DISPLAY tt-bens-alienacao.dscatbem
                                                 WITH FRAME f_alienacao.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                     KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                     KEYFUNCTION(LASTKEY) = "TAB"      OR
                                     KEYFUNCTION(LASTKEY) = "GO"       THEN
                                     DO:
                                         IF   LOOKUP(tt-bens-alienacao.dscatbem,
                                                     aux_lscatbem) > 0   THEN
                                              APPLY LASTKEY.
                                         ELSE
                                              DO:
                                                  MESSAGE
                                                  "Categoria nao encontrada.".
                                                  NEXT.
                                              END.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                     APPLY LASTKEY.
                                
                                IF CAN-DO("MOTO,AUTOMOVEL,CAMINHAO",tt-bens-alienacao.dscatbem) THEN
                                DO: 
                                    DISPLAY tt-bens-alienacao.dstipbem 
                                            WITH FRAME f_alienacao.
                                    DISPLAY tt-bens-alienacao.dschassi 
                                            FORMAT "x(17)" WITH FRAME f_alienacao.
                                END.
                                ELSE
                                DO:
                                    HIDE tt-bens-alienacao.dstipbem.
                                    DISPLAY tt-bens-alienacao.dschassi 
                                            FORMAT "x(20)" WITH FRAME f_alienacao.
                                END.
                            END.
                       ELSE
                       IF   FRAME-FIELD = "dstipbem"   THEN
                            DO:
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
                                     DO:
                                         aux_nrindvei = aux_nrindvei - 1.

                                         IF   aux_nrindvei <= 0   THEN
                                              aux_nrindvei =
                                                  NUM-ENTRIES(aux_lsveibem).

                                         tt-bens-alienacao.dstipbem =
                                             ENTRY(aux_nrindvei,
                                                   aux_lsveibem).

                                         DISPLAY tt-bens-alienacao.dstipbem
                                                 WITH FRAME f_alienacao.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
                                     DO:
                                         aux_nrindvei = aux_nrindvei + 1.

                                         IF   aux_nrindvei >
                                              NUM-ENTRIES(aux_lsveibem)   THEN
                                              aux_nrindvei = 1.

                                         tt-bens-alienacao.dstipbem =
                                             ENTRY(aux_nrindvei,
                                                   aux_lsveibem).

                                         DISPLAY tt-bens-alienacao.dstipbem
                                                 WITH FRAME f_alienacao.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                     KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                     KEYFUNCTION(LASTKEY) = "TAB"      OR
                                     KEYFUNCTION(LASTKEY) = "GO"       THEN
                                     DO:
                                         IF   LOOKUP(tt-bens-alienacao.dstipbem,
                                                     aux_lsveibem) > 0   THEN
                                              APPLY LASTKEY.
                                         ELSE
                                              DO:
                                                  MESSAGE
                                                  "Tipo Veiculo nao encontrada.".
                                                  NEXT.
                                              END.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                     APPLY LASTKEY.

                                IF tt-bens-alienacao.dstipbem = "ZERO KM" THEN
                                DO:
                                    HIDE tt-bens-alienacao.ufdplaca
                                         tt-bens-alienacao.nrdplaca
                                         tt-bens-alienacao.nrrenava.
                                END.
                                ELSE
                                DO:
                                    DISPLAY tt-bens-alienacao.ufdplaca
                                            tt-bens-alienacao.nrdplaca
                                            tt-bens-alienacao.nrrenava
                                            WITH FRAME f_alienacao.
                                END.
                            END.
                       ELSE
                       IF   FRAME-FIELD = "dschassi"   THEN
                            DO:     
                                IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                              INPUT "",
                                                              INPUT "") THEN
                                    NEXT.
                                ELSE
                                DO: 
                                    IF CAN-DO("AUTOMOVEL,MOTO,CAMINHAO",
                                              tt-bens-alienacao.dscatbem) THEN
                                    DO:   
                                        IF LENGTH(tt-bens-alienacao.dschassi) > 17 THEN
                                        DO:
                                            ASSIGN tt-bens-alienacao.dschassi = 
                                                SUBSTR(tt-bens-alienacao.dschassi,1,17).
                                            DISPLAY tt-bens-alienacao.dschassi WITH FRAME f_alienacao.
                                        END.          

                                        IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                                      INPUT "",
                                                                      INPUT "Q,I,O") THEN
                                            NEXT.
                                        ELSE
                                        DO:
                                            APPLY LASTKEY.
                                            ASSIGN tt-bens-alienacao.dschassi.      
                                        END.                       
                                    END.
                                    ELSE
                                    DO:
                                        APPLY LASTKEY.
                                        ASSIGN tt-bens-alienacao.dschassi.
                                    END.
                                END.
                            END.
                       ELSE
                            APPLY LASTKEY.

                       IF   GO-PENDING   THEN
                            DO:
                                RUN valida_alienacao.

                                IF   RETURN-VALUE <> "OK"   THEN
                                     DO:
                                       { sistema/generico/includes/foco_campo.i
                                             &VAR-GERAL=SIM
                                             &NOME-FRAME="f_alienacao"
                                             &NOME-CAMPO=par_nmdcampo }
                                     END.

                            END.

                    END.  /*  Fim do EDITING  */

                    IF   aux_contador > 1                  AND
                         tt-bens-alienacao.dscatbem = ""   AND
                         tt-bens-alienacao.dsbemfin = ""   THEN
                         DO:
                             DELETE tt-bens-alienacao.

                             /* Senao tiver proximo bem ... */
                             IF   NOT CAN-FIND
                               (tt-bens-alienacao WHERE
                                tt-bens-alienacao.idalibem = aux_contador + 1)
                                THEN

                                  LEAVE ALIENACAO.
                         END.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      LEAVE.

              END.  /*  Fim do FOR EACH alienacao  */

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                       HIDE FRAME f_alienacao NO-PAUSE.
                       NEXT.
                   END.

              /* O interveniente nao eh mais permitido pelo B. Central  */
              /* Mas existe o campo na TAB016 para desbloquear */

              IF   tt-dados-coope.flginter   THEN
                   RUN interveniente_anuente.

              IF   RETURN-VALUE <> "OK"   THEN
                   NEXT.

              HIDE FRAME f_interveniente NO-PAUSE.
              HIDE FRAME f_promissoria   NO-PAUSE.
              HIDE FRAME f_alienacao     NO-PAUSE.

          END.
     ELSE
     IF   tt-proposta-epr.tplcremp = 3    THEN   /*  HIPOTECA  */
          DO:
              ASSIGN aux_contador = 0.

              HIPOTECA:
              DO WHILE TRUE:

                 HIDE FRAME f_hipoteca.

                 ASSIGN aux_contador = aux_contador + 1.

                 FIND tt-hipoteca WHERE tt-hipoteca.idseqhip = aux_contador
                                        NO-LOCK NO-ERROR.

                 IF   NOT AVAIL tt-hipoteca   THEN
                      DO:
                          CREATE tt-hipoteca.
                          ASSIGN tt-hipoteca.idseqhip = aux_contador
                                 tt-hipoteca.lsbemfin =
                                          "( " + STRING(aux_contador,"z9") +
                                         "º Imovel )".
                      END.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    DISPLAY tt-hipoteca.lsbemfin WITH FRAME f_hipoteca.

                    UPDATE tt-hipoteca.dscatbem
                           tt-hipoteca.vlmerbem
                           tt-hipoteca.dsbemfin
                           tt-hipoteca.dscorbem
                           WITH FRAME f_hipoteca

                    EDITING:

                       READKEY.

                       IF   FRAME-FIELD = "dscatbem"   THEN
                            DO:
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
                                     DO:
                                         aux_nrindcat = aux_nrindcat - 1.

                                         IF   aux_nrindcat <= 0   THEN
                                              aux_nrindcat =
                                                  NUM-ENTRIES(aux_lscathip).

                                         tt-hipoteca.dscatbem = ENTRY(aux_nrindcat,
                                                                      aux_lscathip).

                                         DISPLAY tt-hipoteca.dscatbem
                                                 WITH FRAME f_hipoteca.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
                                     DO:
                                         aux_nrindcat = aux_nrindcat + 1.

                                         IF   aux_nrindcat >
                                              NUM-ENTRIES(aux_lscathip)   THEN
                                              aux_nrindcat = 1.

                                         tt-hipoteca.dscatbem = ENTRY(aux_nrindcat,
                                                                      aux_lscathip).

                                         DISPLAY tt-hipoteca.dscatbem
                                                 WITH FRAME f_hipoteca.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                     KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                     KEYFUNCTION(LASTKEY) = "TAB"      OR
                                     KEYFUNCTION(LASTKEY) = "GO"       THEN
                                     DO:
                                         IF   LOOKUP(tt-hipoteca.dscatbem,
                                                     aux_lscathip) > 0   THEN
                                              APPLY LASTKEY.
                                         ELSE
                                              DO:
                                                  MESSAGE
                                                  "Categoria nao encontrada.".
                                                  NEXT.
                                              END.
                                     END.
                                ELSE
                                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                     APPLY LASTKEY.
                            END.
                       ELSE
                            APPLY LASTKEY.

                       IF   GO-PENDING   THEN
                            DO:
                                RUN valida_hipoteca.

                                IF   RETURN-VALUE <> "OK"   THEN
                                     DO:
                                         { sistema/generico/includes/foco_campo.i

                                             &NOME-FRAME="f_hipoteca"
                                             &NOME-CAMPO=par_nmdcampo }
                                     END.

                            END.

                    END.  /*  Fim do EDITING  */

                    /* Pelo menos um imovel cadastrado */
                    IF   aux_contador > 1            AND
                         tt-hipoteca.dscatbem = ""   THEN
                         DO:
                             DELETE tt-hipoteca.

                             /* Se nao tiver nenhum a mais */
                             IF   NOT CAN-FIND(tt-hipoteca WHERE
                                  tt-hipoteca.idseqhip = aux_contador + 1) THEN

                                  LEAVE HIPOTECA.
                         END.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      LEAVE.

              END.  /*  Fim do DO .. TO  */

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                       HIDE FRAME f_hipoteca NO-PAUSE.
                       NEXT.
                   END.

              HIDE FRAME f_hipoteca NO-PAUSE.

          END.

     CLEAR FRAME f_observacao.

     HIDE FRAME f_observacao NO-PAUSE.

     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tt-proposta-epr.dsobserv
               btn_btaosair
               WITH FRAME f_observacao NO-ERROR.
        LEAVE.

     END.

     HIDE FRAME f_observacao NO-PAUSE.

     RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

     RUN verifica-outras-propostas IN h-b1wgen0002
                                     (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_nmdatela,
                                      INPUT 1, /* Ayllos*/
                                      INPUT par_nrdconta,
                                      INPUT tt-proposta-epr.nrctremp,
                                      INPUT 1, /* Tit.*/
                                      INPUT glb_dtmvtolt,
                                      INPUT glb_dtmvtopr,
                                      INPUT tt-proposta-epr.vlemprst,
                                      INPUT aux_vleprori,
                                      INPUT tt-dados-coope.vlminimo,
                                      INPUT tt-proposta-epr.qtpromis,
                                      INPUT tt-proposta-epr.qtpreemp,
                                      INPUT tt-proposta-epr.cdlcremp,
                                      INPUT  TABLE tt-interv-anuentes,
                                      INPUT  TABLE tt-bens-alienacao,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-msg-confirma,
                                      OUTPUT TABLE tt-grupo).

     DELETE PROCEDURE h-b1wgen0002.

     IF RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF AVAIL tt-erro   THEN
               MESSAGE tt-erro.dscritic.
            ELSE
                "Erro na verificacao das propostas do associado.".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
            END.

            NEXT.

        END.

     /* Exibir mensagens de alerta */
     FOR EACH tt-msg-confirma NO-LOCK:

         DISPLAY tt-msg-confirma.dsmensag

                 WITH FRAME f_alertas.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             PAUSE.
             LEAVE.
         END.

     END.

     HIDE FRAME f_alertas.

     IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
        DO:
            ASSIGN aux_qtctarel = 0.

            FOR EACH tt-grupo NO-LOCK:

                ASSIGN aux_qtctarel = aux_qtctarel + 1.

            END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                FIND FIRST tt-grupo NO-LOCK NO-ERROR.

                DISP par_nrdconta
                     tt-grupo.dsdrisgp
                     aux_qtctarel
                     WITH FRAME f_ge_epr.

                OPEN QUERY q-ge-epr FOR EACH tt-grupo
                                    NO-LOCK BY tt-grupo.cdagenci
                                              BY tt-grupo.nrctasoc.

                UPDATE b-ge-epr
                       WITH FRAME f_ge_epr.

                LEAVE.

            END.

            CLOSE QUERY q-ge-epr.
            HIDE FRAME f_ge_epr.

        END.

     /*  Confirmacao dos dados  */
     RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

     IF   aux_confirma <> "S" THEN
          NEXT.

     LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/confirma.p
                         (INPUT "Deseja abandonar esta proposta? (S/N)",
                          OUTPUT aux_confirma).

            IF   aux_confirma <> "S" THEN
                 NEXT ALTERACAO.

            HIDE FRAME f_proepr     NO-PAUSE.
            HIDE FRAME f_observacao NO-PAUSE.
            RETURN.
        END.


   /* Pegar as contas dos avalistas */
   FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 1  NO-LOCK NO-ERROR.

   IF    AVAIL tt-dados-avais  THEN
         aux_nrctaava = tt-dados-avais.nrctaava.
   ELSE
         aux_nrctaava = 0.

   FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 2 NO-LOCK NO-ERROR.

   IF    AVAIL tt-dados-avais  THEN
         aux_nrctaav2 = tt-dados-avais.nrctaava.
   ELSE
         aux_nrctaav2 = 0.

   /* Recuperar os valores da analise da proposta */
   FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.

   /* Recuperar os valores sobre os rendimentos */
   FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

   /* Juntar os registros para preparar os parametros  */
   RUN monta_registros_dinamicos.

   /* Buscar agencia do operador*/
   FIND FIRST crapope 
     WHERE crapope.cdcooper = glb_cdcooper
	   AND crapope.cdoperad = glb_cdoperad
	    NO-LOCK NO-ERROR.

   RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

   RUN grava-proposta-completa IN h-b1wgen0002
                               (INPUT glb_cdcooper,
                                INPUT 0,
								INPUT crapope.cdpactra,
                                INPUT 0,
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT 1, /* Ayllos*/
                                INPUT par_nrdconta,
                                INPUT 1, /* Tit.*/
                                INPUT glb_dtmvtolt,
                                INPUT tt-rendimento.inpessoa,
                                INPUT par_nrctremp, /* Contrato */
                                INPUT tt-proposta-epr.tpemprst,
                                INPUT tt-dados-coope.flgcmtlc, /*Comite Local*/
                                INPUT par_vlutiliz,
                                INPUT tt-dados-coope.vllimapv,
                                INPUT "A", /* Alteracao */
                                INPUT tt-proposta-epr.vlemprst,
                                INPUT aux_vlpreemp,
                                INPUT tt-proposta-epr.vlpreemp,
                                INPUT tt-proposta-epr.qtpreemp,
                                INPUT tt-proposta-epr.nivrisco,
                                INPUT tt-proposta-epr.cdlcremp,
                                INPUT tt-proposta-epr.cdfinemp,
                                INPUT tt-proposta-epr.qtdialib,
                                INPUT tt-proposta-epr.flgimppr,
                                INPUT tt-proposta-epr.flgimpnp,
                                INPUT tt-proposta-epr.percetop,
                                INPUT tt-proposta-epr.idquapro,
                                INPUT tt-proposta-epr.dtdpagto,
                                INPUT tt-proposta-epr.qtpromis,
                                INPUT tt-proposta-epr.flgpagto,
                                INPUT tt-proposta-epr.dsctrliq,
                                INPUT aux_nrctaava,
                                INPUT aux_nrctaav2,
                                INPUT ?, /* par_idcarenc */
                                INPUT ?, /* par_dtcarenc */
                                /* Analise da proposta*/
                                INPUT tt-dados-analise.nrgarope,
                                INPUT tt-dados-analise.nrperger,
                                INPUT tt-dados-analise.dtcnsspc,
                                INPUT tt-dados-analise.nrinfcad,
                                INPUT tt-dados-analise.dtdrisco,
                                INPUT tt-dados-analise.vltotsfn,
                                INPUT tt-dados-analise.qtopescr,
                                INPUT tt-dados-analise.qtifoper,
                                INPUT tt-dados-analise.nrliquid,
                                INPUT tt-dados-analise.vlopescr,
                                INPUT tt-dados-analise.vlrpreju,
                                INPUT tt-dados-analise.nrpatlvr,
                                INPUT tt-dados-analise.dtoutspc,
                                INPUT tt-dados-analise.dtoutris,
                                INPUT tt-dados-analise.vlsfnout,
                                /* Salario / Faturaqmento*/
                                INPUT tt-rendimento.vlsalari,
                                INPUT tt-rendimento.vloutras,
                                INPUT tt-rendimento.vlalugue,
                                INPUT tt-rendimento.vlsalcon,
                                INPUT tt-rendimento.nmextemp,
                                INPUT tt-rendimento.flgdocje,
                                INPUT tt-rendimento.nrctacje,
                                INPUT tt-rendimento.nrcpfcjg,
                                INPUT tt-rendimento.perfatcl,
                                INPUT tt-rendimento.vlmedfat,
                                INPUT tt-rendimento.inconcje,
                                INPUT (aux_confirma = "S"),
                                INPUT tt-proposta-epr.dsobserv,
                                INPUT par_dsdfinan,
                                INPUT par_dsdrendi,
                                INPUT par_dsdebens,
                                INPUT par_dsdalien,
                                INPUT par_dsinterv,
                                INPUT "",
                                /* Dados do 1 Aval */
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
                                INPUT aux_dsnacio1,
                                INPUT aux_vledvmt1,
                                INPUT aux_vlrenme1,
                                INPUT aux_nrender1,
                                INPUT aux_complen1,
                                INPUT aux_nrcxaps1,
                                INPUT aux_inpesso1,
                                INPUT aux_dtnasct1,
								INPUT 0, /* par_vlrecjg1 */
                                /* Dados do 2 Aval */
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
                                INPUT aux_dsnacio2,
                                INPUT aux_vledvmt2,
                                INPUT aux_vlrenme2,
                                INPUT aux_nrender2,
                                INPUT aux_complen2,
                                INPUT aux_nrcxaps2,
                                INPUT aux_inpesso2,
                                INPUT aux_dtnasct2,
								INPUT 0, /* par_vlrecjg2 */
                                /* Bens dos avalistas terceiros */
                                INPUT par_dsdbeavt,
                                INPUT TRUE,
                                INPUT tt-rendimento.dsjusren,
                                INPUT ?, /* dtlibera */
                                INPUT 0, /* idcobope */
								INPUT tt-proposta-epr.idfiniof, /* par_idfiniof */
								INPUT "", /* par_dscatbem */
								INPUT 1, /* par_inresapr */
                                INPUT 0,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-msg-confirma,
                                OUTPUT tt-proposta-epr.nrdrecid,
                                OUTPUT tt-proposta-epr.nrctremp,
                                OUTPUT aux_flmudfai).

   ASSIGN par_recidepr = tt-proposta-epr.nrdrecid.

   DELETE PROCEDURE h-b1wgen0002.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Erro na alteraçao da proposta de emprestimo.".

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PAUSE.
                 LEAVE.
             END.

             RETURN.
        END.

   /* Mensagens sobre a aprovacao da proposta */
   FOR EACH tt-msg-confirma NO-LOCK:
   
       MESSAGE tt-msg-confirma.dsmensag.
   
       DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
          PAUSE 3 NO-MESSAGE.
          LEAVE.
       END.
   
       HIDE MESSAGE NO-PAUSE.
   
   END.

   /* Revisao cadastral */
   ASSIGN aux_tpatlcad = 2
          aux_msgatcad = "764 - Registrar revisao cadastral? (S/N)"
          aux_chavealt = STRING(glb_cdcooper) + "," + STRING(par_nrdconta) +
                         "," + STRING(glb_dtmvtolt).

   /* Verificar se é necessario registrar o crapalt */
   RUN proc_altcad (INPUT "b1wgen0056.p").

   /* Listar as criticas do RATING (se existir) */
   RUN fontes/criticas_rating.p (INPUT glb_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT 90, /* Emprestimo */
                                 INPUT par_nrctremp).

   IF   aux_flmudfai = "N"    THEN
        RUN efetua_buscas.

   RUN fontes/proepr_m.p (INPUT par_recidepr,
                          INPUT TABLE tt-proposta-epr).

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_proepr     NO-PAUSE.
HIDE FRAME f_observacao NO-PAUSE.


PROCEDURE interveniente_anuente:

    /* Inclusão de CEP integrado. (André - DB1) */
    ON GO, LEAVE OF tt-interv-anuentes.nrcepend IN FRAME f_interveniente DO:
        IF  INPUT tt-interv-anuentes.nrcepend = 0  THEN
            RUN Limpa_Endereco.
    END.

    ON RETURN OF tt-interv-anuentes.nrcepend IN FRAME f_interveniente DO:

        HIDE MESSAGE NO-PAUSE.

        ASSIGN INPUT tt-interv-anuentes.nrcepend.

        IF  tt-interv-anuentes.nrcepend <> 0  THEN
            DO:
                RUN fontes/zoom_endereco.p (INPUT tt-interv-anuentes.nrcepend,
                                            OUTPUT TABLE tt-endereco).

                FIND FIRST tt-endereco NO-LOCK NO-ERROR.

                IF  AVAIL tt-endereco THEN
                    DO:
                        ASSIGN
                           tt-interv-anuentes.nrcepend = tt-endereco.nrcepend
                           tt-interv-anuentes.dsendres[1] = tt-endereco.dsendere
                           tt-interv-anuentes.dsendres[2] = tt-endereco.nmbairro
                           tt-interv-anuentes.nmcidade = tt-endereco.nmcidade
                           tt-interv-anuentes.cdufresd = tt-endereco.cdufende.
                    END.
                ELSE
                    DO:
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            RETURN NO-APPLY.

                        MESSAGE "CEP nao cadastrado.".
                        RUN Limpa_Endereco.
                        RETURN NO-APPLY.
                    END.
            END.
        ELSE
            RUN Limpa_Endereco.

        DISPLAY tt-interv-anuentes.nrcepend
                tt-interv-anuentes.dsendres
                tt-interv-anuentes.nmcidade
                tt-interv-anuentes.cdufresd
                WITH FRAME f_interveniente.

        NEXT-PROMPT tt-interv-anuentes.nrendere WITH FRAME f_interveniente.
    END.

    ON LEAVE OF tt-interv-anuentes.nrctaava IN FRAME f_interveniente DO:

       HIDE MESSAGE NO-PAUSE.

       /* Se cooperado */
       IF   INPUT tt-interv-anuentes.nrctaava <> 0  THEN
            DO:
                RUN lista_interveniente
                             (INPUT INPUT tt-interv-anuentes.nrcpfcgc,
                              INPUT INPUT tt-interv-anuentes.nrctaava ).

                IF   RETURN-VALUE <> "OK"  THEN
                     RETURN NO-APPLY.

            END.
    END.

    ON LEAVE OF tt-interv-anuentes.nrcpfcgc IN FRAME f_interveniente DO:

        HIDE MESSAGE NO-PAUSE.

        IF   INPUT tt-interv-anuentes.nrcpfcgc > 0   AND
             INPUT tt-interv-anuentes.nrctaava = 0   THEN
             DO:
                 RUN lista_interveniente
                             (INPUT INPUT tt-interv-anuentes.nrcpfcgc,
                              INPUT INPUT tt-interv-anuentes.nrctaava ).

                 IF   RETURN-VALUE <> "OK"  THEN
                      RETURN NO-APPLY.

             END.
    END.


    /*  maximo 5 intervenientes anuentes */
    DO aux_contador = 1 TO 5:

       /* Mostra/apaga os intervenientes anuentes de acordo com a alteracao */
       FIND tt-interv-anuentes WHERE
            tt-interv-anuentes.nrdindic = aux_contador
            EXCLUSIVE-LOCK NO-ERROR.

       IF   NOT AVAILABLE tt-interv-anuentes   THEN
            DO:
                CREATE tt-interv-anuentes.
                ASSIGN tt-interv-anuentes.nrdindic = aux_contador.
            END.

       HIDE FRAME f_interveniente NO-PAUSE.

       DISPLAY tt-interv-anuentes.nrcpfcgc   tt-interv-anuentes.nmdavali
               tt-interv-anuentes.nrdocava   tt-interv-anuentes.dsendres
               tt-interv-anuentes.nmcidade   tt-interv-anuentes.cdufresd
               tt-interv-anuentes.nrcepend   tt-interv-anuentes.dsnacion
               tt-interv-anuentes.nmconjug   tt-interv-anuentes.nrcpfcjg
               tt-interv-anuentes.nrdoccjg   tt-interv-anuentes.tpdoccjg
               tt-interv-anuentes.nrfonres   tt-interv-anuentes.dsdemail
               tt-interv-anuentes.nrcxapst   tt-interv-anuentes.complend
               tt-interv-anuentes.nrendere
               WITH FRAME f_interveniente.

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          UPDATE tt-interv-anuentes.nrctaava WITH FRAME f_interveniente

                 TITLE " Dados dos Intervenientes " +
                        "Anuentes (" + STRING(aux_contador,"9") + ") ".
          LEAVE.

       END.

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            RETURN "NOK".

       IF  tt-interv-anuentes.nrctaava = 0   THEN /* Conta nao prenchida */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   UPDATE
                      tt-interv-anuentes.nmdavali  tt-interv-anuentes.nrcpfcgc
                      tt-interv-anuentes.tpdocava  tt-interv-anuentes.nrdocava
                      tt-interv-anuentes.dsnacion  tt-interv-anuentes.nmconjug
                      tt-interv-anuentes.nrcpfcjg  tt-interv-anuentes.tpdoccjg
                      tt-interv-anuentes.nrdoccjg  tt-interv-anuentes.nrcepend
                      tt-interv-anuentes.nrendere  tt-interv-anuentes.complend
                      tt-interv-anuentes.nrcxapst  tt-interv-anuentes.nrfonres
                      tt-interv-anuentes.dsdemail
                      WITH FRAME f_interveniente

                       EDITING:

                           READKEY.

                           IF  LASTKEY = KEYCODE("F7")   THEN
                               DO:
                                   IF  FRAME-FIELD = "dsnacion"   THEN
                                       DO:
                                           RUN fontes/nacion.p.

                                           IF  shr_dsnacion <> "" THEN
                                               DO:

                                                   tt-interv-anuentes.dsnacion =
                                                                   shr_dsnacion.

                                                   DISPLAY
                                                   tt-interv-anuentes.dsnacion
                                                   WITH FRAME f_interveniente.

                                               END.
                                       END.
                                   ELSE
                                   IF  FRAME-FIELD = "nrcepend"  THEN
                                       DO:
                                   /* Inclusão de CEP integrado. (André - DB1) */
                                           RUN fontes/zoom_endereco.p
                                                     (INPUT 0,
                                                     OUTPUT TABLE tt-endereco).

                                           FIND FIRST tt-endereco
                                                      NO-LOCK NO-ERROR.

                                           IF  AVAIL tt-endereco THEN
                                               ASSIGN
                                                 tt-interv-anuentes.nrcepend =
                                                           tt-endereco.nrcepend
                                                 tt-interv-anuentes.dsendres[1] =
                                                           tt-endereco.dsendere
                                                 tt-interv-anuentes.dsendres[2] =
                                                           tt-endereco.nmbairro
                                                 tt-interv-anuentes.nmcidade =
                                                           tt-endereco.nmcidade
                                                 tt-interv-anuentes.cdufresd =
                                                           tt-endereco.cdufende.

                                           DISPLAY tt-interv-anuentes.nrcepend
                                                   tt-interv-anuentes.dsendres
                                                   tt-interv-anuentes.nmcidade
                                                   tt-interv-anuentes.cdufresd
                                                   WITH FRAME f_interveniente.
                                           IF  KEYFUNCTION(LASTKEY)
                                               <> "END-ERROR" THEN
                                               NEXT-PROMPT
                                                     tt-interv-anuentes.nrendere
                                                     WITH FRAME f_interveniente.
                                       END.
                                   ELSE
                                       APPLY LASTKEY.
                               END.
                           ELSE
                               APPLY LASTKEY.
                           /* Validação para CEP existente. (André - DB1)*/
                           IF  GO-PENDING  THEN
                               DO:
                                   IF  INPUT tt-interv-anuentes.nrcpfcgc <> 0 OR
                                       INPUT tt-interv-anuentes.nrctaava <> 0 THEN
                                       DO:
                                           RUN Valida_Interv.

                                           IF  RETURN-VALUE <> "OK"  THEN
                                               DO:
                                                   FIND FIRST tt-erro
                                                        NO-LOCK NO-ERROR.

                                                   IF  AVAIL tt-erro  THEN
                                                       MESSAGE tt-erro.dscritic.

                                         {sistema/generico/includes/foco_campo.i
                                             &VAR-GERAL=SIM
                                             &NOME-FRAME="f_interveniente"
                                             &NOME-CAMPO=par_nmdcampo }
                                               END.
                                       END.
                               END.

                       END. /* Fim do EDITING */

                   LEAVE.

               END.  /* Fim do DO WHILE TRUE */

               IF  KEYFUNCTION (LASTKEY) = "END-ERROR" THEN
                   RETURN "NOK".

           END.
       ELSE
           DO:
               DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   PAUSE.
                   LEAVE.
               END.
           END.

       /* CPF e conta em branco */
       IF  tt-interv-anuentes.nrcpfcgc = 0   AND
           tt-interv-anuentes.nrctaava = 0   THEN
           DO:
               DELETE tt-interv-anuentes.

               /* Se acabaram os avalistas, encerra */
               IF  NOT CAN-FIND(FIRST tt-interv-anuentes WHERE
                   tt-interv-anuentes.nrdindic = aux_contador + 1)   THEN

                   RETURN "OK".
           END.

    END.  /* fim do DO ... TO ... */

    HIDE FRAME f_interveniente NO-PAUSE.

    RETURN "OK".

END PROCEDURE.


PROCEDURE lista_interveniente:

    DEF INPUT PARAM par_nrcpfcgc AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrctaava AS INTE                            NO-UNDO.


    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN consulta-avalista IN h-b1wgen9999
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /* Ayllos*/
                           INPUT par_nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT par_nrctaava,
                           INPUT par_nrcpfcgc,
                           OUTPUT TABLE bb-dados-avais,
                           OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen9999.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na busca dos dados cadastrais.".

             RETURN "NOK".
         END.

    FIND FIRST bb-dados-avais NO-LOCK NO-ERROR.

    IF   NOT AVAIL bb-dados-avais  THEN
         RETURN "OK".

    ASSIGN tt-interv-anuentes.nrcpfcgc    = bb-dados-avais.nrcpfcgc
           tt-interv-anuentes.nmdavali    = bb-dados-avais.nmdavali
           tt-interv-anuentes.nrdocava    = bb-dados-avais.nrdocava
           tt-interv-anuentes.dsendres[1] = bb-dados-avais.dsendre1
           tt-interv-anuentes.dsendres[2] = bb-dados-avais.dsendre2
           tt-interv-anuentes.nmcidade    = bb-dados-avais.nmcidade
           tt-interv-anuentes.cdufresd    = bb-dados-avais.cdufresd
           tt-interv-anuentes.nrcepend    = bb-dados-avais.nrcepend
           tt-interv-anuentes.dsnacion    = bb-dados-avais.dsnacion
           tt-interv-anuentes.nmconjug    = bb-dados-avais.nmconjug
           tt-interv-anuentes.nrdoccjg    = bb-dados-avais.nrdoccjg
           tt-interv-anuentes.tpdocava    = bb-dados-avais.tpdocava
           tt-interv-anuentes.dsdemail    = bb-dados-avais.dsdemail
           tt-interv-anuentes.nrendere    = bb-dados-avais.nrendere
           tt-interv-anuentes.complend    = bb-dados-avais.complend
           tt-interv-anuentes.nrcxapst    = bb-dados-avais.nrcxapst.

    DISPLAY tt-interv-anuentes.nrcpfcgc     tt-interv-anuentes.nmdavali
            tt-interv-anuentes.nrdocava     tt-interv-anuentes.dsendres[1]
            tt-interv-anuentes.dsendres[2]  tt-interv-anuentes.nmcidade
            tt-interv-anuentes.cdufresd     tt-interv-anuentes.nrcepend
            tt-interv-anuentes.dsnacion     tt-interv-anuentes.nmconjug
            tt-interv-anuentes.nrdoccjg     tt-interv-anuentes.tpdocava
            tt-interv-anuentes.dsdemail     tt-interv-anuentes.nrendere
            tt-interv-anuentes.complend     tt-interv-anuentes.nrcxapst
            WITH FRAME f_interveniente.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_qualif_operacao:

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    RUN proc_qualif_operacao IN h-b1wgen0002 (INPUT  glb_cdcooper,
                                              INPUT  0,
                                              INPUT  0,
                                              INPUT  glb_cdoperad,
                                              INPUT  glb_nmdatela,
                                              INPUT  1, /* Ayllos*/
                                              INPUT  par_nrdconta,
                                              INPUT  tt-proposta-epr.dsctrliq,
                                              INPUT  glb_dtmvtolt,
                                              INPUT  glb_dtmvtopr,
                                              OUTPUT tt-proposta-epr.idquapro,
                                              OUTPUT tt-proposta-epr.dsquapro).
    DELETE PROCEDURE h-b1wgen0002.

END PROCEDURE.


PROCEDURE valida_alienacao:

    DO WITH FRAME f_alienacao:

        ASSIGN tt-bens-alienacao.dscatbem
               tt-bens-alienacao.dstipbem
               tt-bens-alienacao.vlmerbem
               tt-bens-alienacao.dsbemfin
               tt-bens-alienacao.tpchassi
               tt-bens-alienacao.dscorbem
               tt-bens-alienacao.ufdplaca
               tt-bens-alienacao.nrdplaca
               tt-bens-alienacao.uflicenc
               tt-bens-alienacao.dschassi
               tt-bens-alienacao.nrrenava
               tt-bens-alienacao.nranobem
               tt-bens-alienacao.nrmodbem
               tt-bens-alienacao.nrcpfbem.
    END.

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    RUN valida-dados-alienacao IN h-b1wgen0002
                                   (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1, /* Ayllos*/
                                    
                                    INPUT "A",
                                    INPUT par_nrdconta,
                                    INPUT par_nrctremp,
                                    INPUT tt-bens-alienacao.dscorbem,
                                    INPUT tt-bens-alienacao.nrdplaca,
                                    INPUT tt-bens-alienacao.idseqbem,
                                    
                                    INPUT tt-bens-alienacao.dscatbem,
                                    INPUT tt-bens-alienacao.dstipbem,
                                    INPUT tt-bens-alienacao.dsbemfin,
                                    INPUT tt-bens-alienacao.vlmerbem,
                                    INPUT tt-bens-alienacao.tpchassi,
                                    INPUT tt-bens-alienacao.dschassi,
                                    INPUT tt-bens-alienacao.ufdplaca,
                                    INPUT tt-bens-alienacao.uflicenc,
                                    INPUT tt-bens-alienacao.nrrenava,
                                    INPUT tt-bens-alienacao.nranobem,
                                    INPUT tt-bens-alienacao.nrmodbem,
                                    INPUT tt-bens-alienacao.nrcpfbem,
                                    INPUT aux_contador,
                                    INPUT TRUE,
                                    INPUT tt-proposta-epr.vlemprst,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT par_nmdcampo,
                                   OUTPUT aux_flgsenha,
                                   OUTPUT aux_dsmensag).

    DELETE PROCEDURE h-b1wgen0002.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.

              IF   AVAIL tt-erro  THEN
                   MESSAGE tt-erro.dscritic.
              ELSE
                   MESSAGE
                      "Erro na validacao dos dados alienados.".

              DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                  PAUSE 3 NO-MESSAGE.
                  LEAVE.
              END.

              RETURN "NOK".

         END.

    /* Condicao para verificar se apresenta mensagem em tela */
    IF aux_dsmensag <> "" THEN
        DO:
            MESSAGE aux_dsmensag.
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
               PAUSE 3 NO-MESSAGE.
               LEAVE.
            END.
           
            IF aux_flgsenha = 1 THEN
               DO:
                   RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                           INPUT 2,
                                           OUTPUT aux_nsenhaok,
                                           OUTPUT aux_cdoperad).

                   IF NOT aux_nsenhaok THEN
                      RETURN "NOK".
               END.
       
        END. /* END IF aux_dsmensag <> "" THEN */

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_hipoteca:

     DO WITH FRAME f_hipoteca:

         ASSIGN tt-hipoteca.dscatbem
                tt-hipoteca.dsbemfin
                tt-hipoteca.vlmerbem.

     END.

     RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

     RUN valida-dados-hipoteca IN h-b1wgen0002 (INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /* Ayllos*/
                                                INPUT tt-hipoteca.dscatbem,
                                                INPUT tt-hipoteca.dsbemfin,
                                                INPUT tt-hipoteca.vlmerbem,
                                                INPUT aux_contador,
                                                INPUT TRUE,
                                                INPUT tt-proposta-epr.vlemprst,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT par_nmdcampo,
                                                OUTPUT aux_flgsenha,
                                                OUTPUT aux_dsmensag).

     DELETE PROCEDURE h-b1wgen0002.

     IF   RETURN-VALUE <> "OK"   THEN
          DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.

              IF    AVAIL tt-erro    THEN
                    MESSAGE tt-erro.dscritic.
              ELSE
                    MESSAGE
                   "Erro na validação dos dados da hipoteca.".

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  PAUSE 3 NO-MESSAGE.
                  LEAVE.
              END.

              RETURN "NOK".

          END.
          
     /* Condicao para verificar se apresenta mensagem em tela */
     IF aux_dsmensag <> "" THEN
        DO:
            MESSAGE aux_dsmensag.
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
               PAUSE 3 NO-MESSAGE.
               LEAVE.
            END.
           
            IF aux_flgsenha = 1 THEN
               DO:
                   RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                           INPUT 2,
                                           OUTPUT aux_nsenhaok,
                                           OUTPUT aux_cdoperad).

                   IF NOT aux_nsenhaok THEN
                      RETURN "NOK".
               END.
       
        END. /* END IF aux_dsmensag <> "" THEN */ 
          
     RETURN "OK".

END PROCEDURE.


/* Procedure para montrar os registros numa variavel */
/* Pois sera utulizado como parametro na chamada da BO que grava os dados */
PROCEDURE monta_registros_dinamicos:

           /* Primeiro aval */
    ASSIGN aux_nmdaval1 = ""  aux_nrcpfav1 = 0   aux_tpdocav1 = ""
           aux_dsdocav1 = ""  aux_nmdcjav1 = ""  aux_cpfcjav1 = 0
           aux_tdccjav1 = ""  aux_doccjav1 = ""  aux_ende1av1 = ""
           aux_ende2av1 = ""  aux_nrfonav1 = ""  aux_emailav1 = ""
           aux_nmcidav1 = ""  aux_cdufava1 = ""  aux_nrcepav1 = 0
           aux_dsnacio1 = ""  aux_vledvmt1 = 0   aux_vlrenme1 = 0
           aux_nrender1 = 0   aux_nrcxaps1 = 0   aux_complen1 = ""
           aux_inpesso1 = 0   aux_dtnasct1 = ?
           /* Segundo aval */
           aux_nmdaval2 = ""  aux_nrcpfav2 = 0   aux_tpdocav2 = ""
           aux_dsdocav2 = ""  aux_nmdcjav2 = ""  aux_cpfcjav2 = 0
           aux_tdccjav2 = ""  aux_doccjav2 = ""  aux_ende1av2 = ""
           aux_ende2av2 = ""  aux_nrfonav2 = ""  aux_emailav2 = ""
           aux_nmcidav2 = ""  aux_cdufava2 = ""  aux_nrcepav2 = 0
           aux_dsnacio2 = ""  aux_vledvmt2 = 0   aux_vlrenme2 = 0
           aux_nrender2 = 0   aux_nrcxaps2 = 0   aux_complen2 = ""
           aux_inpesso2 = 0   aux_dtnasct2 = ?.

    /* Primeiro aval */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 1 NO-LOCK NO-ERROR.

    IF   AVAIL tt-dados-avais   THEN
         ASSIGN aux_nmdaval1 = tt-dados-avais.nmdavali
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
                aux_dsnacio1 = tt-dados-avais.dsnacion
                aux_vledvmt1 = tt-dados-avais.vledvmto
                aux_vlrenme1 = tt-dados-avais.vlrenmes
                aux_nrender1 = tt-dados-avais.nrendere
                aux_nrcxaps1 = tt-dados-avais.nrcxapst
                aux_complen1 = tt-dados-avais.complend
                aux_inpesso1 = tt-dados-avais.inpessoa
                aux_dtnasct1 = tt-dados-avais.dtnascto.

    /** Segundo aval */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 2 NO-LOCK NO-ERROR.

    IF   AVAIL tt-dados-avais THEN
         ASSIGN aux_nmdaval2 = tt-dados-avais.nmdavali
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
                aux_dsnacio2 = tt-dados-avais.dsnacion
                aux_vledvmt2 = tt-dados-avais.vledvmto
                aux_vlrenme2 = tt-dados-avais.vlrenmes
                aux_nrender2 = tt-dados-avais.nrendere
                aux_nrcxaps2 = tt-dados-avais.nrcxapst
                aux_complen2 = tt-dados-avais.complend
                aux_inpesso2 = tt-dados-avais.inpessoa
                aux_dtnasct2 = tt-dados-avais.dtnascto.

    RUN fontes/monta_registros_proposta.p (INPUT TABLE tt-aval-crapbem,
                                           INPUT TABLE tt-faturam,
                                           INPUT TABLE tt-crapbem,
                                           INPUT TABLE tt-bens-alienacao,
                                           INPUT TABLE tt-hipoteca,
                                           INPUT TABLE tt-interv-anuentes,
                                           INPUT tt-rendimento.tpdrendi,
                                           INPUT tt-rendimento.vldrendi,
                                           OUTPUT par_dsdbeavt,
                                           OUTPUT par_dsdfinan,
                                           OUTPUT par_dsdrendi,
                                           OUTPUT par_dsdebens,
                                           OUTPUT par_dsdalien,
                                           OUTPUT par_dsinterv).
END PROCEDURE.

PROCEDURE Limpa_Endereco:

    ASSIGN tt-interv-anuentes.nrcepend    = 0
           tt-interv-anuentes.dsendres[1] = ""
           tt-interv-anuentes.dsendres[2] = ""
           tt-interv-anuentes.nmcidade    = ""
           tt-interv-anuentes.cdufresd    = ""
           tt-interv-anuentes.nrendere    = 0
           tt-interv-anuentes.nrcxapst    = 0
           tt-interv-anuentes.complend    = "".

    DISPLAY tt-interv-anuentes.nrcepend
            tt-interv-anuentes.dsendres[1]
            tt-interv-anuentes.dsendres[2]
            tt-interv-anuentes.nmcidade
            tt-interv-anuentes.cdufresd
            tt-interv-anuentes.nrendere
            tt-interv-anuentes.nrcxapst
            tt-interv-anuentes.complend WITH FRAME f_interveniente.
END PROCEDURE.

PROCEDURE Valida_Interv:

    DO WITH FRAME f_interveniente:
        ASSIGN tt-interv-anuentes.nrcepend
               tt-interv-anuentes.dsendres
               tt-interv-anuentes.nrctaava
               tt-interv-anuentes.nmdavali
               tt-interv-anuentes.nrcpfcgc
               tt-interv-anuentes.tpdocava
               tt-interv-anuentes.nrdocava
               tt-interv-anuentes.dsnacion
               tt-interv-anuentes.nmconjug
               tt-interv-anuentes.nrcpfcjg
               tt-interv-anuentes.tpdoccjg
               tt-interv-anuentes.nrdoccjg
               tt-interv-anuentes.dsendres[1]
               tt-interv-anuentes.dsendres[2]
               tt-interv-anuentes.nrfonres
               tt-interv-anuentes.dsdemail
               tt-interv-anuentes.nmcidade
               tt-interv-anuentes.cdufresd
               tt-interv-anuentes.nrcepend.
    END.

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    RUN valida-interv IN h-b1wgen0002 (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_nmdatela,
                                       INPUT 1, /* Ayllos*/
                                       INPUT tt-interv-anuentes.nrctaava,
                                       INPUT tt-interv-anuentes.nmdavali,
                                       INPUT tt-interv-anuentes.nrcpfcgc,
                                       INPUT tt-interv-anuentes.tpdocava,
                                       INPUT tt-interv-anuentes.nrdocava,
                                       INPUT tt-interv-anuentes.dsnacion,
                                       INPUT tt-interv-anuentes.nmconjug,
                                       INPUT tt-interv-anuentes.nrcpfcjg,
                                       INPUT tt-interv-anuentes.tpdoccjg,
                                       INPUT tt-interv-anuentes.nrdoccjg,
                                       INPUT tt-interv-anuentes.dsendres[1],
                                       INPUT tt-interv-anuentes.dsendres[2],
                                       INPUT tt-interv-anuentes.nrfonres,
                                       INPUT tt-interv-anuentes.dsdemail,
                                       INPUT tt-interv-anuentes.nmcidade,
                                       INPUT tt-interv-anuentes.cdufresd,
                                       INPUT tt-interv-anuentes.nrcepend,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT par_nmdcampo).

     DELETE PROCEDURE h-b1wgen0002.

     IF  RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

     RETURN "OK".

END PROCEDURE.


PROCEDURE efetua_buscas:

     RUN fontes/confirma.p (INPUT "Deseja efetuar as consultas? (S/N):",
                           OUTPUT aux_confirma).
      
     HIDE MESSAGE NO-PAUSE.

     IF   aux_confirma = "S"   THEN
          DO:
             MESSAGE "Aguarde, efetuando consultas ...".
     
             RUN sistema/generico/procedures/b1wgen0191.p 
                 PERSISTENT SET h-b1wgen0191.
     
             RUN Solicita_Consulta_Biro IN h-b1wgen0191 (INPUT glb_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT 1,
                                                         INPUT par_nrctremp,
                                                         INPUT glb_cdoperad,
                                                        OUTPUT glb_cdcritic,
                                                        OUTPUT glb_dscritic,
                                                        OUTPUT aux_dsmensag).
             DELETE PROCEDURE h-b1wgen0191.
     
             HIDE MESSAGE NO-PAUSE.
     
             IF   RETURN-VALUE <> "OK"    THEN
                  DO:
                      MESSAGE glb_dscritic.                  
                      PAUSE.
                      HIDE MESSAGE.
                 END.
           
             IF   aux_dsmensag <> ""   THEN
                  DO:
                      MESSAGE aux_dsmensag.
                      PAUSE.
                      HIDE MESSAGE.
                  END.

          END.

     RUN sistema/generico/procedures/b1wgen0191.p PERSISTENT SET h-b1wgen0191.

     RUN efetua_analise_ctr IN h-b1wgen0191 (INPUT glb_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                            OUTPUT glb_cdcritic,
                                            OUTPUT glb_dscritic).

     DELETE PROCEDURE h-b1wgen0191.

     IF   RETURN-VALUE <> "OK" THEN
          DO:
              MESSAGE glb_dscritic.                  
              PAUSE.
              HIDE MESSAGE.
          END.

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    RUN atualiza_risco_proposta IN h-b1wgen0002 (INPUT glb_cdcooper,
                                                 INPUT 0, /* par_cdagenci */
                                                 INPUT 0, /* par_nrdcaixa */
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_nmdatela,
                                                 INPUT 1, /* par_idorigem */
                                                 INPUT glb_dtmvtolt,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrctremp,
                                                 OUTPUT TABLE tt-erro).
     IF VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

     IF RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF AVAIL tt-erro   THEN
               MESSAGE tt-erro.dscritic.
            ELSE
               MESSAGE "Erro na atualizacao do risco.".

            PAUSE.
            HIDE MESSAGE.
        END.
        
END PROCEDURE.

PROCEDURE valida_alteracao_valor_proposta:
  
     IF NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p
            PERSISTENT SET h-b1wgen0002.
                       
     /* Valida os dados na alteracao do valor da proposta */
     RUN valida_alteracao_valor_proposta IN h-b1wgen0002
                                         (INPUT glb_cdcooper,
                                          INPUT 0, /*par_cdagenci*/
                                          INPUT 0, /*par_nrdcaixa*/
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1, /*par_idorigem*/
                                          INPUT par_nrdconta,
                                          INPUT 1, /*par_idseqttl*/
                                          INPUT glb_dtmvtolt,
                                          INPUT par_nrctremp,
                                          INPUT tt-proposta-epr.vlemprst,
                                          OUTPUT aux_flgsenha,
                                          OUTPUT aux_dsmensag,
                                          OUTPUT glb_cdcritic,
                                          OUTPUT glb_dscritic).
    
     IF VALID-HANDLE(h-b1wgen0002) THEN
        DELETE OBJECT h-b1wgen0002.
        
     IF RETURN-VALUE <> "OK" THEN
        DO:
            MESSAGE glb_dscritic.
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               PAUSE 3 NO-MESSAGE.
               LEAVE.
            END.

            RETURN "NOK".
        END.
     
     /* Condicao para verificar se apresenta mensagem em tela */
     IF aux_dsmensag <> "" THEN
        DO:
            MESSAGE aux_dsmensag.
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
               PAUSE 3 NO-MESSAGE.
               LEAVE.
            END.
           
            IF aux_flgsenha = 1 THEN
               DO:
                   RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                           INPUT 2,
                                           OUTPUT aux_nsenhaok,
                                           OUTPUT aux_cdoperad).
                   
                   IF NOT aux_nsenhaok THEN
                      RETURN "NOK".
               END.
       
        END. /* END IF aux_dsmensag <> "" THEN */ 
        
     RETURN "OK".
                          
END PROCEDURE.
/* ........................................................................ */