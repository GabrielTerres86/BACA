/* .............................................................................

   Programa: Fontes/lanctri.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                      Ultima atualizacao: 30/05/2019

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela lanctr.

   Alteracoes: 20/06/94 - Alterado para nao permitir a inclusao de contratos
                          de emprestimo para associados demitidos (Edson).

               17/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o indica-
                          dor de linha com saldo devedor.

               06/03/95 - Alterado para inclusao de novos campos no crablem:
                          dtpagemp e txjurepr (Edson).

               11/06/96 - Alterado para zerar: crablem.vlpreemp,
                                               crabepr.qtprecal,
                                               crabepr.qtmesdec e
                                               crabepr.dtinipag.
                          (Edson).

               10/01/97 - Alterado para tratar datas do primeiro pagamento
                          que caducaram (Edson).

               14/05/97 - Alterado para nao permitir a entrada de emprestimos
                          com numeracao na faixa da automacao e que nao este-
                          jam no crawepr (Edson).

               30/10/97 - Verificar a idade dos avalistas (Odair).

               09/01/98 - Alterado para permitir somente debito em conta
                          corrente para conta duplicadas (Deborah).

               05/02/98 - Acerto na alteracao da data de pagamento - vinculados
                          a conta (Deborah).

               25/02/98 - Alterado para nao permitir a entrada de proposta
                          manual quando existir uma equivalente em estudo
                          (Edson).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               19/01/99 - Calcular o valor do IOF (Deborah).

               26/07/2000 - Tratar menor de 21 anos e nao 18 (Odair).

               06/09/2000 - Tratar habilitacao de menores (Deborah).

               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               08/12/2000 - Mostrar contratos avalizados pela mesmo fiador
                                              (Margarete/Planner).

               03/07/2001 - Mostrar o nome do fiador junto com a conta na
                            confirmacao de fiador (Junior).

               06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               08/01/2003 - Maioridade de 21 para 18 anos (Deborah).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               28/10/2003 - Nao permitir a entrada de contratos de emprestimos
                            sem ter a proposta preenchida (Edson).

               13/11/2003 - Incluido campo Nivel Risco(Mirtes).

               21/06/2004 - Acessar Tabela Avalistas Terceiros(Mirtes)

               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               04/08/2004 - Alterado mensagem 805, passando contratos
                            liquidados(Mirtes).

               11/08/2004 - Verificar valor maximo pessoa juridica(linha de
                            credito)(Mirtes)

               13/09/2004 - Atribuicao do tipo de desconto para emprestimo por
                            consignacao (Julio)

               14/10/2004 - Obter Risco do Rating(Associado)/Verificar
                            Atualizacao do Rating(Evandro).

               18/05/2005 - Alterada tabela craptab por crapcop (Diego).

               04/07/2005 - Alimentado campo cdcooper das tabelas crapavl,
                            crapavt, e dos buffers crabepr, e crablem (Diego).

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               25/08/2005 - Alterada procedure verificar_atualizacao_rating
                            (Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               09/02/2006 - Espeficacao de LOCKS em leituras de registros -
                            SQLWorks - Andre

               16/06/2006 - Modificados campos referente endereco para a
                            estrutura crapenc (Diego).

               27/06/2006 - Atualizar crapepr.dtdpagto se for emprestimo
                            consignado ou folha (Julio)

               24/10/2006 - Mostra mensagem quando valor de emprestimo for
                            maior do que o valor parametrizado (Elton).

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).

               26/07/2007 - Somente permitir a inclusao de contratos com status
                            "aprovado" ou "restricao" feito atraves da tela
                            CMAPRV (Evandro).

               24/09/2007 - Conversao de rotina ver_capital para BO
                            (Sidnei/Precise)

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               25/06/2009 - Caso o emprestimo for atrelado a emissao de boletos
                            confirmar a data do primeiro vencimento e criar o
                            crapsab (Fernando).

               05/08/2009 - Trocado campo cdgraupr da crapass para a crapttl.
                            Paulo - Precise.
                          - Para calcular o saldo utilizado desconsiderar os
                            emprestimos que estao sendo efetivados(Guilherme).

               03/09/2009 - Verifica se o emprestimo pode ser lancado
                            Proj. de Liberacao de Credito (Ze).

               15/10/2009 - Geracao do Rating (Gabriel).

               04/02/2011 - Atualiza nivel do risco da proposta de emprestimo
                            quando estiver diferente do nivel de risco do
                            contrato (Elton).

               09/06/2011 - Retirar tratamento de alteracao de avais (David).

               05/09/2011 - Adaptacoes Rating Central (Guilherme).

               09/11/2011 - Realizado a passagem de parametros para a includes
                            rating_singulares (Adriano).

               02/03/2012 - Adicionado critica para novo tipo de contrato da
                            b1wgen0134.p (Tiago).

               29/10/2012 - Incluir chamada da procedure calc_endivid_grupo
                            para mostrar frame f_ge-economico (Lucas R.).

               21/11/2012 - Retirado restriçao de numeracao de contratos de
                            emprestimos (David Kruger).

               17/01/2013 - Nao gerar critica = 9 quando nao encontra
                            outros emprestimos dos avalistas, pois pode haver
                            avalista de propostas nao efetivadas ou excluidas.
                            (Irlan).

               08/04/2013 - Ajuste realizados:
                             - Incluido a chamada da procedure alerta_fraude
                               dentro da pi-critica-fiador;
                             - Ajuste de layout no frame f_ge-economico
                              (Adriano).

               18/10/2013 - GRAVAMES - Valida bens alienados no
                            grava_efetivacao_proposta (Guilherme/SUPERO).

               10/12/2013 - Inclusao de VALIDATE crabepr, crablem e crapavl
                                                                   (Carlos)

               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).

               25/06/2014 - Inclusao do uso da temp-table tt-grupo na b1wgen0138tt.
                            (Chamado 130880) - (Tiago Castro - RKAM)

               03/09/2014 - Incluir ajustes para calcular o cet
                            (Lucas R./Gielow - Projeto Cet)

               20/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)

               27/04/2015 - Projeto 158 - Servico Folha de Pagto (SUPERO)

               04/05/2015 - Retirar criacao da crapavl. Sera criada na
                            proposta de emprestimo ja (Gabriel-RKAM).

               04/05/2015 - Validar situacao dos contratos a liquidar:
                            Informar quando contrato relacionado ja liquidado
                            (Guilherme/SUPERO)
                           
               28/05/2015 - Incluir parametro da Finalidade na procedure
                            "obtem_emprestimo_risco". (James)
                            
               16/06/2015 - Projeto 158 - Servico Folha de Pagto
                           (Andre Santos - SUPERO)
                           
               30/06/2015 - Incluir parametro da Finalidade na procedure
                            "obtem_emprestimo_risco". (James)
                           
               17/11/2015 - Passagem do parametro (par_cdfinemp) na procedure 
                            calcula_cet_novo usado para portabilidade. Projeto 
                            Portabilidade de credito (Carlos Rafael Tanholi).     
                            
               09/05/2016 - Incluido validacao da situacao esteira na 
                            valida_dados_efetivacao_proposta . 
                          - Gravar operador que realizou a efetivacao da 
                            proposta 
                            PRJ207 - Esteira (Odirlei-AMcom)
                            
               22/09/2016 - Incluido validacao de contrato de acordo, Prj. 302
                            (Jean Michel).             

               13/01/2017 - Implementar trava para não permitir efetivar empréstimo sem que 
                            as informações de Imóveis estejam preenchidas (Renato - Supero)

               30/01/2017 - Nao permitir efetuar lancamento para o produto Pos-Fixado.
                            (Jaison/James - PRJ298)

               17/02/2017 - Retirada a trava de efetivaçao de empréstimo sem que as informações 
                            de Imóveis estejam preenchidas, conforme solicitaçao antes da 
                            liberaçao do projeto (Renato - Supero)
               
               16/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)  
               
               12/07/2018 - PJ450 - Emininado acesso ao crapgrp e leitura do 
                            retorno da chamada da bo 138 para atribuir dados de
                            grupos economicos para a variável tt-ge-economico
                            (Renato/AMcom)

               03/09/2018 - Efetivaçao do seguro prestamista TR -- PRJ438 - Paulo Martins (Mouts)

               30/05/2019 - P450 - Rating (Guilherme/AMcom)
                            
               19/08/2019 - P450 - Rating, na obtem_emprestimo_risco, incluído pr_nrctremp (Elton/AMcom)
                            
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanctr.i }
{ includes/var_altava.i "NEW"}

{ sistema/generico/includes/var_oracle.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }

ON RETURN OF b-ge-economico
   DO:
        APPLY "GO".
   END.

DEF VAR h-b1wgen0001         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0043         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0134         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0138         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0110         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0171         AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0002         AS HANDLE                                NO-UNDO.

DEF VAR aux_totlinha         AS DECI                                  NO-UNDO.
DEF VAR aux_cdgraupr         LIKE crapttl.cdgraupr                    NO-UNDO.
DEF VAR ass_cdempres         AS INTE                                  NO-UNDO.
DEF VAR ass_nrcadast         AS INTE                                  NO-UNDO.
DEF VAR aux_flgpagto         AS LOGI                                  NO-UNDO.
DEF VAR aux_par_nrdconta     AS INTE                                  NO-UNDO.
DEF VAR aux_par_dsctrliq     AS CHAR                                  NO-UNDO.
DEF VAR aux_par_vlutiliz     AS DECI                                  NO-UNDO.
DEF VAR aux_vlr_maxleg       AS DECI                                  NO-UNDO.
DEF VAR aux_vlr_maxutl       AS DECI                                  NO-UNDO.
DEF VAR aux_vlr_minscr       AS DECI                                  NO-UNDO.
DEF VAR aux_vlr_excedido     AS LOGI                                  NO-UNDO.
DEF VAR aux_qtprecal_retorno LIKE crapepr.qtprecal                    NO-UNDO.
DEF VAR aux_mensagem_liq     AS CHAR FORMAT "x(40)"                   NO-UNDO.
DEF VAR aux_valor_maximo     AS DECI                                  NO-UNDO.
DEF VAR aux_tpdescto         LIKE crawepr.tpdescto                    NO-UNDO.
DEF VAR aux_cdtpinsc         LIKE crapsab.cdtpinsc                    NO-UNDO.
DEF VAR aux_nmdsacad         LIKE crapsab.nmdsacad                    NO-UNDO.
DEF VAR aux_dsendsac         LIKE crapsab.dsendsac                    NO-UNDO.
DEF VAR aux_nmbaisac         LIKE crapsab.nmbaisac                    NO-UNDO.
DEF VAR aux_nrcepsac         LIKE crapsab.nrcepsac                    NO-UNDO.
DEF VAR aux_nmcidsac         LIKE crapsab.nmcidsac                    NO-UNDO.
DEF VAR aux_cdufsaca         LIKE crapsab.cdufsaca                    NO-UNDO.
DEF VAR aux_complend         LIKE crapsab.complend                    NO-UNDO.
DEF VAR aux_nrendsac         LIKE crapsab.nrcepsac                    NO-UNDO.
DEF VAR aux_dsnivris         AS CHAR                                  NO-UNDO.
DEF VAR aux_nrdgrupo         AS INTE                                  NO-UNDO.
DEF VAR aux_gergrupo         AS CHAR                                  NO-UNDO.
DEF VAR aux_dsdrisco         AS CHAR                                  NO-UNDO.
DEF VAR aux_dsdrisgp         AS CHAR                                  NO-UNDO.
DEF VAR aux_pertengp         AS LOGI                                  NO-UNDO.
DEF VAR aux_dsrotina         AS CHAR                                  NO-UNDO.
DEF VAR aux_percetop         AS DECI                                  NO-UNDO.
DEF VAR aux_txcetmes         AS DECI                                  NO-UNDO.
DEF VAR aux_flctrliq         AS LOGI                                  NO-UNDO.
DEF VAR aux_flgativo         AS INTE                                  NO-UNDO.
DEF VAR aux_vltotiof         AS DECI                                  NO-UNDO.
DEF VAR aux_vliofpri         AS DECI                                  NO-UNDO.
DEF VAR aux_vliofadi         AS DECI                                  NO-UNDO.
DEF VAR aux_flgimune         AS DECI                                  NO-UNDO.
DEF VAR aux_dscatbem         AS CHAR                                  NO-UNDO.

DEF VAR aux_vlendivi         AS DECI                                  NO-UNDO.
DEF VAR aux_vlrating         AS DECI                                  NO-UNDO.
DEF VAR aux_flrating         AS INT                                   NO-UNDO.


DEF BUFFER b_crawepr FOR crawepr.

DEFINE TEMP-TABLE w_contas                           NO-UNDO
       FIELD  nrdconta  LIKE crapass.nrdconta.

EMPTY TEMP-TABLE tt-grupo.
EMPTY TEMP-TABLE tt-ge-economico.


ASSIGN tel_nrdconta = 0
       tel_nrctremp = 0
       tel_cdfinemp = 0
       tel_cdlcremp = 0
       tel_nivrisco = " "
       tel_vlemprst = 0
       tel_vlpreemp = 0
       tel_qtpreemp = 0
       tel_nrctaav1 = 0
       tel_nrctaav2 = 0
       tel_nrseqdig = 1
       tel_avalist1 = " "
       tel_avalist2 = " "
       aux_dsrotina = "".

INCLUSAO:
DO WHILE TRUE:

   RUN fontes/inicia.p.

   CLEAR FRAME f_emprestimos ALL.
   HIDE  FRAME f_emprestimos NO-PAUSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cdcritic > 0 OR glb_dscritic <> "" THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanctr.

             DISPLAY glb_cddopcao
                     tel_dtmvtolt
                     tel_cdagenci
                     tel_cdbccxlt
                     tel_nrdolote
                     WITH FRAME f_lanctr.

             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.

         END.

      UPDATE tel_nrdconta
             tel_nrctremp
             WITH FRAME f_lanctr.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal   THEN
         DO:
             ASSIGN glb_cdcritic = 8.
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
             NEXT.

         END.

      RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

      RUN valida_empr_tipo1 IN h-b1wgen0134
                               (INPUT glb_cdcooper,
                                INPUT tel_cdagenci,
                                INPUT 0,
                                INPUT tel_nrdconta,
                                INPUT tel_nrctremp,
                                OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0134.

      IF RETURN-VALUE = "OK" THEN
         DO:
             ASSIGN glb_cdcritic = 946.
             NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
             NEXT.

         END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = tel_nrdconta
                         NO-LOCK NO-ERROR.

      IF AVAILABLE crapass   THEN
         DO:
            IF crapass.inpessoa = 1   THEN
               DO:
                   FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper      AND
                                      crapttl.nrdconta = crapass.nrdconta  AND
                                      crapttl.idseqttl = 1
                                      NO-LOCK NO-ERROR.

                   IF AVAIL crapttl  THEN
                      ASSIGN aux_cdempres = crapttl.cdempres
                             aux_cdtpinsc = crapass.inpessoa
                             aux_nrinssac = crapttl.nrcpfcgc.

                   FIND LAST crapenc WHERE
                             crapenc.cdcooper = glb_cdcooper       AND
                             crapenc.nrdconta = tel_nrdconta       AND
                             crapenc.idseqttl = crapttl.idseqttl   AND
                             crapenc.tpendass = 10 /* Residencial */
                             NO-LOCK NO-ERROR.

                END.
             ELSE
                DO:
                   FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                                      crapjur.nrdconta = crapass.nrdconta
                                      NO-LOCK NO-ERROR.

                   IF AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres
                             aux_cdtpinsc = crapass.inpessoa
                             aux_nrinssac = crapass.nrcpfcgc.

                   FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper   AND
                                      crapenc.nrdconta = tel_nrdconta   AND
                                      crapenc.idseqttl = 1              AND
                                      crapenc.cdseqinc = 1              AND
                                      crapenc.tpendass = 9 /* Comercial */
                                      NO-LOCK NO-ERROR.

                END.

            IF NOT AVAILABLE crapenc   THEN
               ASSIGN aux_nmdsacad = crapass.nmprimtl
                      aux_dsendsac = ""
                      aux_nrendsac = 0
                      aux_complend = ""
                      aux_nmbaisac = ""
                      aux_nmcidsac = ""
                      aux_cdufsaca = ""
                      aux_nrcepsac = 0.
            ELSE
               ASSIGN aux_nmdsacad = crapass.nmprimtl
                      aux_dsendsac = crapenc.dsendere
                      aux_nrendsac = crapenc.nrendere
                      aux_complend = crapenc.complend
                      aux_nmbaisac = crapenc.nmbairro
                      aux_nmcidsac = crapenc.nmcidade
                      aux_cdufsaca = crapenc.cdufende
                      aux_nrcepsac = crapenc.nrcepend.

         END.

      IF NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN glb_cdcritic = 9.
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
             NEXT.

         END.

      RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

      IF VALID-HANDLE(h-b1wgen0001)   THEN
         DO:
            RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                            INPUT  tel_nrdconta,
                                            INPUT  0, /* cod-agencia */
                                            INPUT  0, /* nro-caixa   */
                                            0,        /* vllanmto */
                                            INPUT  glb_dtmvtolt,
                                            INPUT  "lanctri",
                                            INPUT  1, /* AYLLOS */
                                            OUTPUT TABLE tt-erro).
            /* Verifica se houve erro */
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF AVAILABLE tt-erro   THEN
               DO:
                  ASSIGN glb_cdcritic = tt-erro.cdcritic
                         glb_dscricpl = tt-erro.dscritic.
               END.

            DELETE PROCEDURE h-b1wgen0001.

         END.
         /************************************/

      IF glb_cdcritic > 0   THEN
         DO:
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
             NEXT.
         END.

      FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                         crapemp.cdempres = aux_cdempres
                         NO-LOCK NO-ERROR.

      IF NOT AVAILABLE crapemp   THEN
         DO:
             ASSIGN glb_cdcritic = 40.
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
             NEXT.

         END.

      /*  Calculo da data do primeiro pagto do emprestimo para esta empresa  */

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                         craptab.nmsistem = "CRED"           AND
                         craptab.tptabela = "GENERI"         AND
                         craptab.cdempres = 0                AND
                         craptab.cdacesso = "DIADOPAGTO"     AND
                         craptab.tpregist = crapemp.cdempres
                         NO-LOCK NO-ERROR.

      IF NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN glb_cdcritic = 55.
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
             NEXT.

         END.

      ASSIGN aux_ddmesnov = INTEGER(SUBSTRING(craptab.dstextab,1,2))
             aux_flgpagto = (crapemp.flgpagto OR crapemp.flgpgtib).

      IF DAY(glb_dtmvtolt) < aux_ddmesnov   THEN
         ASSIGN aux_dtdpagto = DATE(IF MONTH(glb_dtmvtolt) = 12 THEN
                                       1
                                    ELSE
                                       MONTH(glb_dtmvtolt) + 1, 10,
                                    IF MONTH(glb_dtmvtolt) = 12 THEN
                                       YEAR(glb_dtmvtolt) + 1
                                    ELSE
                                       YEAR(glb_dtmvtolt)).
      ELSE
         ASSIGN aux_dtdpagto = DATE(IF MONTH(glb_dtmvtolt) > 10 THEN
                                       IF MONTH(glb_dtmvtolt) = 11 THEN
                                          1
                                       ELSE
                                          2
                                       ELSE
                                          MONTH(glb_dtmvtolt) + 2, 10,
                                       IF MONTH(glb_dtmvtolt) > 10 THEN
                                          YEAR(glb_dtmvtolt) + 1
                                       ELSE
                                          YEAR(glb_dtmvtolt)).

      /* Salva empresa e cadastro do associado para posterior utilizacao */

      ASSIGN ass_cdempres = aux_cdempres
             ass_nrcadast = crapass.nrcadast
             tel_flgpagto = aux_flgpagto
             tel_dtdpagto = aux_dtdpagto.

      IF tel_nrctremp = 0   THEN
         DO:
             ASSIGN glb_cdcritic = 361.
             NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
             NEXT.

         END.

      IF CAN-FIND(crabepr WHERE crabepr.cdcooper = glb_cdcooper   AND
                                crabepr.dtmvtolt = tel_dtmvtolt   AND
                                crabepr.cdagenci = tel_cdagenci   AND
                                crabepr.cdbccxlt = tel_cdbccxlt   AND
                                crabepr.nrdolote = tel_nrdolote   AND
                                crabepr.nrdconta = tel_nrdconta   AND
                                crabepr.nrctremp = tel_nrctremp
                                USE-INDEX crapepr1)               OR
         CAN-FIND(crabepr WHERE crabepr.cdcooper = glb_cdcooper   AND
                                crabepr.nrdconta = tel_nrdconta   AND
                                crabepr.nrctremp = tel_nrctremp
                                USE-INDEX crapepr2)               OR
         CAN-FIND(crablem WHERE crablem.cdcooper = glb_cdcooper   AND
                                crablem.dtmvtolt = tel_dtmvtolt   AND
                                crablem.cdagenci = tel_cdagenci   AND
                                crablem.cdbccxlt = tel_cdbccxlt   AND
                                crablem.nrdolote = tel_nrdolote   AND
                                crablem.nrdconta = tel_nrdconta   AND
                                crablem.nrdocmto = tel_nrctremp
                                USE-INDEX craplem1)               THEN
         DO:
             ASSIGN glb_cdcritic = 92.
             NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
             NEXT.

         END.

      FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper   AND
                         crawepr.nrdconta = tel_nrdconta   AND
                         crawepr.nrctremp = tel_nrctremp
                         NO-LOCK NO-ERROR.

      IF NOT AVAILABLE crawepr   THEN
         DO:
             ASSIGN glb_cdcritic = 535.
             NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
             NEXT.

         END.
      ELSE
         DO:
            
            IF crawepr.insitest <> 3 AND 
               crawepr.dtenvest <> ? THEN
            DO:
                MESSAGE "A proposta nao pode ser efetivada,"
                        + " analise nao finalizada".
                NEXT.            
            END.

            /* Nao permite efetuar lancamento para o produto Pos-Fixado */
			IF crawepr.tpemprst = 2 THEN
            DO:
                ASSIGN glb_cdcritic = 946.
                NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
                NEXT.            
            END.
          
            /* Verifica se o emprestimo pode ser lancado */
            IF crawepr.insitapr <> 1   AND    /* Aprovado  */
               crawepr.insitapr <> 3   THEN   /* Aprovado com Restricao */
               DO:
                   MESSAGE "A proposta deve estar aprovada pelo Comite".
                   NEXT.
               END.            
            
            /* Verificar para nao permitir efetivar proposta de cartao de credito */
            FOR FIRST crapfin FIELDS(tpfinali)
                              WHERE crapfin.cdcooper = crawepr.cdcooper AND
                                    crapfin.cdfinemp = crawepr.cdfinemp
                                    NO-LOCK: END.

            IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
               DO:
                   MESSAGE "Finalidade " + STRING(crapfin.cdfinemp) + " " +
                           "nao pode ser usado para o produto TR.".
                   NEXT.
               END.
           
           /** Verificar "inliquid" do contrato relacionado
                a ser liquidado              **/
            DO  aux_contador = 1 TO 10 :

                IF  crawepr.nrctrliq[aux_contador] > 0 THEN DO:

                    IF  CAN-FIND(FIRST crabepr
                                 WHERE crabepr.cdcooper = crawepr.cdcooper
                                   AND crabepr.nrdconta = crawepr.nrdconta
                                   AND crabepr.nrctremp = crawepr.nrctrliq[aux_contador]
                                   AND crabepr.inliquid = 1) THEN DO:

                        MESSAGE "Atencao: Exclua da proposta os contratos ja liquidados!".

                        aux_flctrliq = TRUE.
                        LEAVE.
                    END.
                    
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    /* Verifica se ha contratos de acordo */
                    RUN STORED-PROCEDURE pc_verifica_acordo_ativo
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.cdcooper
                                                          ,INPUT crawepr.nrdconta
                                                          ,INPUT crawepr.nrctrliq[aux_contador]
														  ,INPUT 3
                                                          ,0
                                                          ,0
                                                          ,"").

                    CLOSE STORED-PROC pc_verifica_acordo_ativo
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    ASSIGN glb_cdcritic = 0
                           glb_dscritic = ""
                           glb_cdcritic = pc_verifica_acordo_ativo.pr_cdcritic WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                           glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                           aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).

					IF aux_flgativo = 1 THEN
					  LEAVE.
                                      
                END.
           END.
           
           IF glb_cdcritic > 0 THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  ASSIGN glb_cdcritic = 0.
                  NEXT.
              END.
            ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
              DO:
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
                NEXT.
              END.
              
            IF aux_flgativo = 1 THEN
              DO:
                MESSAGE "Lancamento nao permitido, contrato marcado para liquidar esta em acordo".
                PAUSE 3 NO-MESSAGE.
                NEXT.
              END.
              
           IF  aux_flctrliq THEN
               NEXT.


            /* Nao permitir Liq. Emprestimo mais de uma vez no dia */
            RUN verifica_emprestimos_lancados_dia.

            IF glb_cdcritic <> 0 THEN
               DO:
                  NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
                  NEXT.
               END.

            /** GRAVAMES **/
            RUN sistema/generico/procedures/b1wgen0171.p
                PERSISTENT SET h-b1wgen0171.

            RUN valida_bens_alienados IN h-b1wgen0171 (INPUT crawepr.cdcooper,
                                                       INPUT crawepr.nrdconta,
                                                       INPUT crawepr.nrctremp,
                                                       INPUT "",
                                                      OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h-b1wgen0171.

            IF  RETURN-VALUE <> "OK"   THEN
                DO:
                    /* Irlan Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF AVAILABLE tt-erro   THEN
                       DO:
                          MESSAGE tt-erro.dscritic.
                       END.

                    NEXT.

                END.

            ASSIGN tel_cdfinemp = crawepr.cdfinemp
                   tel_cdlcremp = crawepr.cdlcremp
                   tel_nivrisco = crawepr.dsnivris
                   tel_qtpreemp = crawepr.qtpreemp
                   tel_vlemprst = crawepr.vlemprst
                   tel_flgpagto = crawepr.flgpagto
                   tel_nrctaav1 = crawepr.nrctaav1
                   tel_nrctaav2 = crawepr.nrctaav2
                   aux_txjurlcr = crawepr.txdiaria
                   aux_tpdescto = crawepr.tpdescto.

            ASSIGN tel_avalist1 = " "
                   tel_avalist2 = " ".

            FOR EACH crapavt WHERE
                     crapavt.cdcooper = glb_cdcooper     AND
                     crapavt.tpctrato = 1                AND /*Emprestimo*/
                     crapavt.nrdconta = crawepr.nrdconta AND
                     crapavt.nrctremp = crawepr.nrctremp
                     NO-LOCK:

                IF crawepr.nrctaav1 = 0   AND
                   tel_avalist1     = " " THEN
                   tel_avalist1   = "CPF " + STRING(crapavt.nrcpfcgc).
                ELSE
                   IF crawepr.nrctaav2 = 0 AND
                      tel_avalist2     = " " THEN
                      tel_avalist2   = "CPF " + STRING(crapavt.nrcpfcgc).
            END.

            IF tel_avalist1     = " " AND
               tel_nrctaav1     = 0  THEN
               ASSIGN tel_avalist1 = crawepr.dscpfav1.

            IF tel_avalist2     = " " AND
               tel_nrctaav2     = 0   THEN
               ASSIGN tel_avalist2 = crawepr.dscpfav2.

            IF crawepr.tpdescto = 2   THEN
               DO:
                  IF DAY(glb_dtmvtolt) < crapemp.dtfchfol THEN
                     ASSIGN aux_dtdpagto = DATE(IF MONTH(glb_dtmvtolt) = 12
                                                THEN 1
                                                ELSE MONTH(glb_dtmvtolt) + 1,
                                                DAY(crawepr.dtdpagto),
                                                IF MONTH(glb_dtmvtolt) = 12
                                                THEN YEAR(glb_dtmvtolt) + 1
                                                ELSE YEAR(glb_dtmvtolt)).
                  ELSE
                     ASSIGN aux_dtdpagto = DATE(IF MONTH(glb_dtmvtolt) > 10
                                               THEN IF MONTH(glb_dtmvtolt) = 11
                                                    THEN 1
                                                    ELSE 2
                                               ELSE MONTH(glb_dtmvtolt) + 2,
                                               DAY(crawepr.dtdpagto),
                                               IF MONTH(glb_dtmvtolt) > 10
                                               THEN YEAR(glb_dtmvtolt) + 1
                                               ELSE YEAR(glb_dtmvtolt)).

               END.

            /*  Verifica se a data do primeiro pagamento nao caducou  */

            IF crawepr.flgpagto       OR     /*  Folha   ou */
               crawepr.tpdescto = 2   THEN   /*  Consignado */
               IF crawepr.dtdpagto <>  aux_dtdpagto    THEN
                  DO:
                      ASSIGN tel_dtdpagto = aux_dtdpagto.
                      BELL.
                      MESSAGE "Alterando a data do primeiro pagamento de"
                              crawepr.dtdpagto "para" tel_dtdpagto.
                  END.
               ELSE
                  ASSIGN tel_dtdpagto = crawepr.dtdpagto.
            ELSE                                                /*  Conta  */
               IF ((crawepr.dtdpagto <= glb_dtmvtolt)                 AND
                   (MONTH(crawepr.dtdpagto) = MONTH(glb_dtmvtolt)     AND
                     YEAR(crawepr.dtdpagto) <= YEAR(glb_dtmvtolt)))   AND
                    crawepr.qtpreemp > 1                              THEN
                    DO:
                        ASSIGN tel_dtdpagto = DATE(MONTH(aux_dtdpagto),
                                                   DAY(crawepr.dtdpagto),
                                                  YEAR(aux_dtdpagto)).
                        BELL.
                        MESSAGE "Alterando a data do primeiro pagamento de"
                                crawepr.dtdpagto "para" tel_dtdpagto.
                    END.
               ELSE
                  ASSIGN tel_dtdpagto = crawepr.dtdpagto.

            IF crawepr.cdlcremp = tab_cdlcrbol   THEN
               DO:
                  ASSIGN glb_dscritic = "A data " +
                                        STRING(tel_dtdpagto, "99/99/99") +
                                        " confere com o primeiro pagamento ?".

                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     MESSAGE glb_dscritic UPDATE aux_confirma.
                     LEAVE.

                  END.

                  IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                     aux_confirma <> "S"    THEN
                     NEXT.

               END.

            DISPLAY tel_cdfinemp
                    tel_cdlcremp
                    tel_nivrisco
                    tel_vlemprst
                    tel_vlpreemp
                    tel_qtpreemp
                    tel_flgpagto
                    tel_dtdpagto
                    tel_nrctaav1
                    tel_nrctaav2
                    tel_avalist1
                    tel_avalist2
                    WITH FRAME f_lanctr.


             FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                crapass.nrdconta = crawepr.nrdconta
                                NO-LOCK NO-ERROR.

             /*FOR EACH w_contas:
                 DELETE w_contas.
             END.*/
             EMPTY TEMP-TABLE w_contas.

             FOR  EACH crabass WHERE crabass.cdcooper  = glb_cdcooper AND
                                     crabass.nrcpfcgc  = crapass.nrcpfcgc
                                     NO-LOCK:
                  CREATE w_contas.
                  ASSIGN w_contas.nrdconta = crabass.nrdconta.
             END.

            ASSIGN aux_vlr_excedido = NO.

            RUN verifica_valores_linha.

            IF aux_vlr_excedido = YES THEN
               DO:
                  ASSIGN glb_cdcritic = 79.
                  NEXT-PROMPT tel_vlemprst WITH FRAME f_lanctr.
                  NEXT.

               END.

            ASSIGN aux_vlr_excedido = NO
                   aux_vlr_maxleg = 0
                   aux_vlr_maxutl = 0
                   aux_vlr_minscr = 0.

            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                               NO-LOCK NO-ERROR.

            IF AVAIL crapcop THEN
               ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
                      aux_vlr_maxutl = crapcop.vlmaxutl
                      aux_vlr_minscr = crapcop.vlcnsscr.

            ASSIGN aux_par_nrdconta = crawepr.nrdconta
                   aux_par_dsctrliq = ""
                   aux_par_vlutiliz = 0.

            /*
             Para buscar o valor utilizado desconsiderar os emprestimos
             que estoa sendo efetivados
            */
            DO  aux_contador = 1 TO 10:

                IF  crawepr.nrctrliq[aux_contador] <> 0  THEN
                    aux_par_dsctrliq = aux_par_dsctrliq +
                                       STRING(crawepr.nrctrliq[aux_contador])
                                       + ",".

            END.  /*  Fim do DO .. TO  */

            IF NOT VALID-HANDLE(h-b1wgen0138) THEN
               RUN sistema/generico/procedures/b1wgen0138.p
                   PERSISTENT SET h-b1wgen0138.

            ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo"
                                               IN h-b1wgen0138,
                                               INPUT glb_cdcooper,
                                               INPUT tel_nrdconta,
                                               OUTPUT aux_nrdgrupo,
                                               OUTPUT aux_gergrupo,
                                               OUTPUT aux_dsdrisgp).

            IF VALID-HANDLE(h-b1wgen0138) THEN
               DELETE OBJECT h-b1wgen0138.

            IF aux_gergrupo <> "" THEN
               MESSAGE COLOR NORMAL aux_gergrupo.

            IF aux_pertengp THEN
               DO:
                   IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                      RUN sistema/generico/procedures/b1wgen0138.p
                          PERSISTENT SET h-b1wgen0138.

                   /* Procedure responsavel para calcular o endividamento
                   do grupo */
                   RUN calc_endivid_grupo IN h-b1wgen0138
                                         (INPUT glb_cdcooper,
                                          INPUT tel_cdagenci,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT tel_dtmvtolt,
                                          INPUT glb_nmdatela,
                                          INPUT 1, /*Ayllos*/
                                          INPUT aux_nrdgrupo,
                                          INPUT TRUE, /*Consulta por conta*/
                                         OUTPUT aux_dsdrisco,
                                         OUTPUT aux_par_vlutiliz,
                                         OUTPUT TABLE tt-grupo,
                                         OUTPUT TABLE tt-erro).

                   IF VALID-HANDLE(h-b1wgen0138) THEN
                      DELETE PROCEDURE h-b1wgen0138.

                   IF RETURN-VALUE <> "OK"   THEN
                      RETURN "NOK".

                   IF aux_vlr_maxutl > 0 THEN
                      DO:
                         IF (aux_par_vlutiliz + tel_vlemprst) >
                             aux_vlr_maxutl THEN
                             DO:
                                ASSIGN aux_aprovavl = NO.
                                MESSAGE COLOR NORMAL
                                "Vlrs(Utl) Excedidos" +
                                "(Utiliz. "              +
                                TRIM(STRING(aux_par_vlutiliz,"zzz,zzz,zz9.99")) +
                                " Excedido "
                                TRIM(STRING((aux_par_vlutiliz + tel_vlemprst
                                 - aux_vlr_maxutl),"zzz,zzz,zz9.99")) +
                                ")Confirma? "
                                UPDATE aux_aprovavl.
                                IF  NOT aux_aprovavl THEN
                                    ASSIGN aux_vlr_excedido = YES.
                             END.

                         IF  aux_vlr_excedido = NO AND
                            ((aux_par_vlutiliz + tel_vlemprst)
                             > aux_vlr_maxleg) THEN
                             DO:
                                ASSIGN aux_qtctarel = 0.

                                /* PJ 450 - Renato Cordeiro -AMcom Julho 2018*/
                                FOR EACH tt-grupo:
                                   DO:
                                       CREATE tt-ge-economico.
                                       ASSIGN tt-ge-economico.nrctasoc = tt-grupo.nrctasoc
                                              tt-ge-economico.dsdrisgp = tt-grupo.dsdrisgp
                                              aux_qtctarel = aux_qtctarel + 1.
                                   END.
                                /*busca grupo economico*/
/*
                                FOR EACH crapgrp WHERE crapgrp.cdcooper = glb_cdcooper AND
                                                       crapgrp.nrdgrupo = aux_nrdgrupo
                                                       NO-LOCK BREAK BY crapgrp.nrctasoc:

                                    IF FIRST-OF(crapgrp.nrctasoc) THEN
                                        DO:
                                           CREATE tt-ge-economico.
                                           ASSIGN tt-ge-economico.nrctasoc = crapgrp.nrctasoc
                                                  tt-ge-economico.dsdrisgp = crapgrp.dsdrisgp
                                                  aux_qtctarel = aux_qtctarel + 1.
                                       END.
*/
                                END.

                                IF TEMP-TABLE tt-ge-economico:HAS-RECORDS THEN
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                            DISP tel_nrdconta
                                                 aux_qtctarel
                                                 WITH FRAME f_ge-economico.

                                            OPEN QUERY q-ge-economico FOR EACH tt-ge-economico
                                                                    NO-LOCK.

                                            UPDATE b-ge-economico
                                                   WITH FRAME f_ge-economico.

                                            LEAVE.

                                        END.

                                       CLOSE QUERY q-ge-economico.
                                       HIDE FRAME f_ge-economico.

                                    END.
                                    RETURN "OK".
                             END.

                         IF aux_vlr_excedido = YES THEN
                             DO:
                                ASSIGN glb_cdcritic = 79.
                                NEXT-PROMPT tel_vlemprst WITH FRAME f_lanctr.
                                NEXT.
                             END.

                      END.

               END.
            ELSE    /* nao e do grupo */
                DO:
                   /* Remover a virgula do final */
                   ASSIGN aux_par_dsctrliq  = SUBSTRING(aux_par_dsctrliq,
                                                        1,
                                              R-INDEX(aux_par_dsctrliq,",") - 1).

                   RUN fontes/saldo_utiliza.p (INPUT  aux_par_nrdconta,
                                               INPUT  aux_par_dsctrliq,
                                               OUTPUT aux_par_vlutiliz).

                   IF aux_vlr_maxutl > 0 THEN
                       DO:
                          IF (aux_par_vlutiliz + tel_vlemprst) >
                              aux_vlr_maxutl THEN
                              DO:
                                 ASSIGN aux_aprovavl = NO.
                                 MESSAGE COLOR NORMAL
                                 "Vlrs(Utl) Excedidos" +
                                 "(Utiliz. "              +
                                 TRIM(STRING(aux_par_vlutiliz,"zzz,zzz,zz9.99")) +
                                 " Excedido "
                                 TRIM(STRING((aux_par_vlutiliz + tel_vlemprst
                                  - aux_vlr_maxutl),"zzz,zzz,zz9.99")) +
                                 ")Confirma? "
                                 UPDATE aux_aprovavl.
                                 IF  NOT aux_aprovavl THEN
                                     ASSIGN aux_vlr_excedido = YES.
                              END.

                          IF aux_vlr_excedido = NO AND
                             ((aux_par_vlutiliz + tel_vlemprst)
                              > aux_vlr_maxleg) THEN
                              DO:
                                 ASSIGN aux_vlr_excedido = YES.
                                 MESSAGE COLOR NORMAL
                                 "Vlr(Legal) Excedido" +
                                 "(Utiliz. "              +
                                 TRIM(STRING(aux_par_vlutiliz,"zzz,zzz,zz9.99")) +
                                 " Excedido "
                                 TRIM(STRING((aux_par_vlutiliz + tel_vlemprst
                                 - aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                 ") ".

                              END.

                           IF aux_vlr_excedido = YES THEN
                              DO:
                                 ASSIGN glb_cdcritic = 79.
                                 NEXT-PROMPT tel_vlemprst WITH FRAME f_lanctr.
                                 NEXT.
                              END.

                       END.

                   IF (aux_par_vlutiliz + tel_vlemprst) > aux_vlr_minscr  THEN
                       MESSAGE "Efetue consulta no SCR.".

                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF glb_cdcritic > 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0.
                  END.

               IF  (crawepr.dtdpagto <= glb_dtmvtolt)   AND
                    crawepr.qtpreemp = 1                AND
                    NOT crawepr.flgpagto                THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           BELL.
                           MESSAGE "Altere a data do primeiro pagamento.".

                           UPDATE tel_dtdpagto WITH FRAME f_lanctr.

                           IF   tel_dtdpagto <= glb_dtmvtolt         OR
                               (tel_dtdpagto - glb_dtmvtolt) > 70    THEN
                                DO:
                                    ASSIGN glb_cdcritic = 13.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    ASSIGN glb_cdcritic = 0.
                                    NEXT.
                                END.

                           HIDE MESSAGE NO-PAUSE.

                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                           LEAVE.
                    END.

               UPDATE tel_vlpreemp
                      WITH FRAME f_lanctr

               EDITING:

                  READKEY.

                  IF FRAME-FIELD = "tel_vlpreemp"   THEN
                     IF LASTKEY =  KEYCODE(".")   THEN
                        APPLY 44.
                     ELSE
                        APPLY LASTKEY.
                  ELSE
                     APPLY LASTKEY.

               END.  /*  Fim do EDITING  */

               IF crawepr.qtpreemp > 1   THEN
                  DO:
                     IF tel_vlpreemp <> crawepr.vlpreemp   THEN
                        DO:
                            ASSIGN glb_cdcritic = 208.
                            NEXT-PROMPT tel_vlpreemp WITH FRAME f_lanctr.
                            NEXT.

                        END.

                  END.
               ELSE
                  ASSIGN tel_vlpreemp = crawepr.vlpreemp.

               /* Emprestimos com emissao de boletos nao tem avalistas */
               IF crawepr.cdlcremp = tab_cdlcrbol   THEN
                  LEAVE.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

         END.

      IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN   /*   F4 OU FIM   */
         NEXT.  /* Volta pedir a conta para o operador */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */



   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      RETURN.  /* Volta pedir a opcao para o operador */

   RELEASE craplot.
   RELEASE crablem.
   RELEASE crabepr.
   
   
   /* Buscar dados do associado */
   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta
                            NO-LOCK NO-ERROR.
   
   /* Montar lista de bens */   
   ASSIGN aux_dscatbem = "".
   FOR EACH crapbpr WHERE crapbpr.cdcooper = glb_cdcooper  AND
                          crapbpr.nrdconta = tel_nrdconta  AND
                          crapbpr.nrctrpro = tel_nrctremp  AND 
                          crapbpr.tpctrpro = 90 NO-LOCK:
       ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
   END.
       
   
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
   RUN STORED-PROCEDURE pc_calcula_iof_epr
   aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper       /* Código da cooperativa */
                                       ,INPUT tel_nrdconta       /* Número da conta */
                                       ,INPUT tel_nrctremp       /* Numero do contrato */
                                       ,INPUT tel_dtmvtolt       /* Data do movimento para busca na tabela de IOF */
                                       ,INPUT crapass.inpessoa   /* Tipo de Pessoa */
                                       ,INPUT tel_cdlcremp       /* Linha de crédito */
                                       ,INPUT tel_cdfinemp       /* Finalidade */
                                       ,INPUT tel_qtpreemp       /* Quantidade de parcelas */
                                       ,INPUT tel_vlpreemp       /* Valor da parcela do emprestimo */
                                       ,INPUT tel_vlemprst       /* Valor do emprestimo */
                                       ,INPUT tel_dtdpagto       /* Data de pagamento */
                                       ,INPUT crawepr.dtlibera   /* Data de liberação */
                                       ,INPUT crawepr.tpemprst   /* Tipo de emprestimo */
                                       ,INPUT crawepr.dtcarenc   /* Data de Carencia */
                                       ,INPUT 0                  /* dias de carencia */
                                       ,INPUT aux_dscatbem       /* Bens em garantia */
                                       ,INPUT crawepr.idfiniof   /* Indicador de financiamento de iof e tarifa */
                                       ,INPUT aux_par_dsctrliq   /* pr_dsctrliq */
                                       ,INPUT "S"
                                       ,OUTPUT 0                 /* Valor calculado da Parcela */
                                       ,OUTPUT 0                 /* Retorno do valor do IOF */
                                       ,OUTPUT 0                 /* pr_vliofpri Valor calculado do iof principal */
                                       ,OUTPUT 0                 /* pr_vliofadi Valor calculado do iof adicional */
                                       ,OUTPUT 0                 /* pr_flgimune Possui imunidade tributária (1 - Sim / 0 - Nao) */
                                       ,OUTPUT "").              /* Critica */

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_calcula_iof_epr
   
   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   /* Se retornou erro */
   ASSIGN glb_dscritic = ""
          glb_dscritic = pc_calcula_iof_epr.pr_dscritic
                         WHEN pc_calcula_iof_epr.pr_dscritic <> ?.
   IF glb_dscritic <> "" THEN
     LEAVE.
     
   /* Soma IOF principal, adicional e secundário */
   ASSIGN aux_vliofpri = 0
          aux_vliofadi = 0
          aux_vltotiof = 0.
   IF pc_calcula_iof_epr.pr_valoriof <> ? THEN
       ASSIGN aux_vltotiof = ROUND(DECI(pc_calcula_iof_epr.pr_valoriof),2).
   IF pc_calcula_iof_epr.pr_vliofpri <> ? THEN
       ASSIGN aux_vliofpri = ROUND(DECI(pc_calcula_iof_epr.pr_vliofpri),2).   
   IF pc_calcula_iof_epr.pr_vliofadi <> ? THEN
       ASSIGN aux_vliofadi = ROUND(DECI(pc_calcula_iof_epr.pr_vliofadi),2).   
   IF pc_calcula_iof_epr.pr_flgimune <> ? THEN
       ASSIGN aux_flgimune = pc_calcula_iof_epr.pr_flgimune.
       
  
       
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

      DO WHILE TRUE:

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE craplot   THEN
            IF LOCKED craplot   THEN
               DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               ASSIGN glb_cdcritic = 60.
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF glb_cdcritic = 0   THEN
         DO:
            IF craplot.tplotmov <> 4   THEN
               DO:
                   ASSIGN glb_cdcritic = 213.
                   NEXT.

               END.

         END.
      ELSE
         NEXT.

      CREATE crabepr.

      ASSIGN crabepr.dtmvtolt = tel_dtmvtolt
             crabepr.cdagenci = tel_cdagenci
             /* Gravar operador que efetivou a proposta */
             crabepr.cdopeefe = glb_cdoperad
             crabepr.cdbccxlt = tel_cdbccxlt
             crabepr.nrdolote = tel_nrdolote
             crabepr.nrdconta = tel_nrdconta
             crabepr.nrctremp = tel_nrctremp
             crabepr.cdfinemp = tel_cdfinemp
             crabepr.cdlcremp = tel_cdlcremp
             crabepr.vlemprst = tel_vlemprst
             crabepr.vlpreemp = tel_vlpreemp
             crabepr.qtpreemp = tel_qtpreemp
             crabepr.nrctaav1 = tel_nrctaav1
             crabepr.nrctaav2 = tel_nrctaav2
             crabepr.txjuremp = aux_txjurlcr
             crabepr.vlsdeved = tel_vlemprst
             crabepr.dtultpag = tel_dtmvtolt
             crabepr.cdempres = ass_cdempres
             crabepr.nrcadast = ass_nrcadast
             /** Caso for emprestimos com emissao de boletos, apenas e
                 aceito o debito em conta corrente **/
             crabepr.flgpagto = IF tel_cdlcremp = tab_cdlcrbol THEN
                                   FALSE
                                ELSE
                                   tel_flgpagto
             crabepr.dtdpagto = tel_dtdpagto
             crabepr.qtmesdec = 0
             crabepr.qtprecal = 0
             crabepr.dtinipag = ?
             crabepr.tpdescto = aux_tpdescto
             crabepr.vliofepr = aux_vltotiof
             crabepr.vliofpri = aux_vliofpri
             crabepr.vliofadc = aux_vliofadi
             crabepr.cdcooper = glb_cdcooper.

      IF tel_cdlcremp = 100   THEN
         ASSIGN crabepr.dtprejuz = glb_dtmvtolt
                crabepr.inprejuz = 1
                crabepr.vlsdprej = tel_vlemprst
                crabepr.vlprejuz = tel_vlemprst
                crabepr.inliquid = 1
                crabepr.vlsdeved = 0.

      VALIDATE crabepr.

      /* Atualizar o percentual do cet quando efetivar proposta */
      FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper AND
                         crawepr.nrdconta = tel_nrdconta AND
                         crawepr.nrctremp = tel_nrctremp
                         EXCLUSIVE-LOCK NO-ERROR.

      IF  AVAIL crawepr THEN DO:
      
        IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
            RUN sistema/generico/procedures/b1wgen0002.p
                PERSISTENT SET h-b1wgen0002.

        /* Calcular o cet automaticamente */
        RUN calcula_cet_novo IN h-b1wgen0002(
                             INPUT glb_cdcooper,
                             INPUT 0, /* agencia */
                             INPUT 0, /* caixa */
                             INPUT glb_cdoperad,
                             INPUT glb_nmdatela,
                             INPUT 1, /* ayllos*/
                             INPUT glb_dtmvtolt,
                             INPUT tel_nrdconta,
                             INPUT crapass.inpessoa,
                             INPUT 2, /* cdusolcr */
                             INPUT crawepr.cdlcremp,
                             INPUT crawepr.tpemprst,
                             INPUT crawepr.nrctremp,
                             INPUT glb_dtmvtolt,
                             INPUT tel_vlemprst,
                             INPUT tel_vlpreemp,
                             INPUT tel_qtpreemp,
                             INPUT tel_dtdpagto,
                             INPUT crawepr.cdfinemp,
                             INPUT aux_dscatbem, /* dscatbem */
                             INPUT crawepr.idfiniof, /* IDFINIOF */
                             INPUT aux_par_dsctrliq, /* dsctrliq */
                             INPUT "S",
                             INPUT crawepr.dtcarenc,
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
            END.

        ASSIGN crawepr.percetop = aux_percetop.
      END.
      
      RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

      RUN obtem_emprestimo_risco IN h-b1wgen0043
                                (INPUT glb_cdcooper,
                                 INPUT tel_cdagenci,
                                 INPUT 0, /* par_nrdcaixa */
                                 INPUT 0, /* par_cdoperad */
                                 INPUT tel_nrdconta,
                                 INPUT 0, /* par_idseqttl */
                                 INPUT 1, /* par_idorigem */
                                 INPUT 0, /* par_nmdatela */
                                 INPUT FALSE, /* par_flgerlog */
                                 INPUT tel_cdfinemp,
								 INPUT crawepr.cdlcremp,
                                 INPUT crawepr.nrctrliq,
                                 INPUT "", /* par_dsctrliq */
				 INPUT crawepr.nrctremp,  /* P450 */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT aux_dsnivris).

      DELETE PROCEDURE h-b1wgen0043.

      IF crawepr.dsnivris <> aux_dsnivris THEN DO:
         FIND CURRENT crawepr EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         MESSAGE 'O risco da proposta foi de "' + crawepr.dsnivris +
                 '" e o do contrato sera de "' + aux_dsnivris + '".'.
         PAUSE.
         ASSIGN crawepr.dsnivris = aux_dsnivris.
      END.


      CREATE crablem.
      ASSIGN tel_nrseqdig     = craplot.nrseqdig + 1
             crablem.dtmvtolt = tel_dtmvtolt
             crablem.cdagenci = tel_cdagenci
             crablem.cdbccxlt = tel_cdbccxlt
             crablem.nrdolote = tel_nrdolote
             crablem.nrdconta = tel_nrdconta
             crablem.nrctremp = tel_nrctremp
             crablem.nrdocmto = tel_nrctremp
             crablem.vllanmto = tel_vlemprst
             crablem.cdhistor = 99
             crablem.nrseqdig = tel_nrseqdig
             crablem.txjurepr = aux_txjurlcr
             crablem.cdcooper = glb_cdcooper

             crablem.vlpreemp = 0

             craplot.nrseqdig = tel_nrseqdig
             craplot.qtcompln = craplot.qtcompln + 1

             craplot.vlcompdb = craplot.vlcompdb + tel_vlemprst.

      VALIDATE crablem.
      

      /* Se houve valor de IOF calculado */
      IF aux_vliofpri + aux_vliofadi > 0 THEN DO:


          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
          /* Efetuar a chamada a rotina Oracle */
          RUN STORED-PROCEDURE pc_insere_iof
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper        /* Cooperativa              */ 
                                              ,INPUT tel_nrdconta        /* Numero da Conta Corrente */
                                              ,INPUT tel_dtmvtolt        /* Data de Movimento        */
                                              ,INPUT 1                   /* Emprestimo               */
                                              ,INPUT tel_nrctremp        /* Numero do Bordero        */
                                              ,INPUT ?                   /* ID Lautom                */
                                              ,INPUT tel_dtmvtolt        /* Data Movimento LCM       */
                                              ,INPUT tel_cdagenci        /* Numero da Agencia LCM    */
                                              ,INPUT 100                 /* Numero do Caixa LCM      */
                                              ,INPUT tel_nrdolote        /* Numero do Lote LCM       */
                                              ,INPUT tel_nrseqdig        /* Sequencia LCM            */
                                              ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                              ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                              ,INPUT 0                   /* Valor Complementar IOF   */
                                              ,INPUT aux_flgimune        /* Possui imunidade tributária (1 - Sim / 0 - Nao) */
                                              ,OUTPUT 0                  /* Codigo da Critica        */
                                              ,OUTPUT "").               /* Descriçao da crítica     */
                                              
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_insere_iof
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          ASSIGN glb_cdcritic = 0
                 glb_dscritic = ""
                 glb_cdcritic = pc_insere_iof.pr_cdcritic
                                WHEN pc_insere_iof.pr_cdcritic <> ?
                 glb_dscritic = pc_insere_iof.pr_dscritic
                                WHEN pc_insere_iof.pr_dscritic <> ?.
          /* Se retornou erro */
          IF glb_cdcritic > 0 OR glb_dscritic <> "" THEN DO:

              ASSIGN glb_dscritic = "Erro ao inserir lancamento de IOF: " +
                                    glb_dscritic.
                 MESSAGE glb_dscritic.
                 PAUSE 3 NO-MESSAGE.
                 UNDO, RETURN.
             END.
      
      END.
      
      /* Caso for emprestimos com emissao de boletos, criar crapsab
         Este tipo de emprestimo nao tem avalistas */
      IF crabepr.cdlcremp = tab_cdlcrbol  THEN
         DO:
            EMPTY TEMP-TABLE cratsab.

            CREATE cratsab.

            ASSIGN cratsab.cdcooper = glb_cdcooper
                   cratsab.nrdconta = tab_nrctabol
                   cratsab.nrctasac = tel_nrdconta
                   cratsab.nmdsacad = aux_nmdsacad
                   cratsab.cdtpinsc = aux_cdtpinsc
                   cratsab.nrinssac = aux_nrinssac
                   cratsab.dsendsac = aux_dsendsac
                   cratsab.nrendsac = aux_nrendsac
                   cratsab.nmbaisac = aux_nmbaisac
                   cratsab.nmcidsac = aux_nmcidsac
                   cratsab.cdufsaca = aux_cdufsaca
                   cratsab.nrcepsac = aux_nrcepsac
                   cratsab.cdoperad = glb_cdoperad
                   cratsab.dtmvtolt = glb_dtmvtolt.

            RUN sistema/generico/procedures/b1crapsab.p PERSISTENT
                SET h-b1crapsab.

            IF VALID-HANDLE(h-b1crapsab)  THEN
               DO:
                   ASSIGN glb_dscritic = "".

                   RUN cadastra_sacado IN h-b1crapsab (INPUT TABLE cratsab,
                                                       OUTPUT glb_dscritic).
               END.

            /* Caso ja exista o crapsab, atualizar os dados */
            IF glb_dscritic <> ""  THEN
               IF  VALID-HANDLE(h-b1crapsab)  THEN
                   DO:
                      ASSIGN glb_dscritic = "".

                      RUN altera_sacado IN h-b1crapsab(INPUT TABLE cratsab,
                                                       OUTPUT glb_dscritic).
                   END.

            DELETE PROCEDURE h-b1crapsab.

            ASSIGN aux_nmdsacad = ""
                   aux_dsendsac = ""
                   aux_nmbaisac = ""
                   aux_nmcidsac = ""
                   aux_cdufsaca = ""
                   aux_nrinssac = 0
                   aux_nrcepsac = 0
                   aux_nrendsac = 0
                   aux_cdtpinsc = 0.

            IF glb_dscritic <> ""  THEN
               DO:
                   MESSAGE glb_dscritic.
                   PAUSE 3 NO-MESSAGE.
                   UNDO, RETURN.
               END.

         END.

      ASSIGN tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      /*  Atualiza indicador de saldo devedor para a linha de credito  */

      DO WHILE TRUE:

         /*FIND craplcr OF crabepr EXCLUSIVE-LOCK NO-ERROR NO-WAIT.*/
         FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                            craplcr.cdlcremp = crabepr.cdlcremp
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE craplcr   THEN
            IF LOCKED craplcr   THEN
               DO:
                   PAUSE 2 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               DO:
                   ASSIGN glb_cdcritic = 363.
                   NEXT-PROMPT tel_cdlcremp WITH FRAME f_lanctr.
                   UNDO, LEAVE.

               END.

         ASSIGN craplcr.flgsaldo = TRUE.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */
      
      /* 17/02/2017 - Retirado a validaçao conforme solicitaçao 
      /* Se o tipo do contrato for igual a 3 -> Contratos de imóveis */
      IF craplcr.tpctrato = 3 THEN DO:
            
			   ASSIGN aux_flimovel = 0.

		     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

         /* Verifica se ha contratos de acordo */
         RUN STORED-PROCEDURE pc_valida_imoveis_epr
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                             ,INPUT tel_nrdconta
                                             ,INPUT crabepr.nrctremp
											 ,INPUT 3
                                             ,OUTPUT 0
                                             ,OUTPUT 0
                                             ,OUTPUT "").

         CLOSE STORED-PROC pc_valida_imoveis_epr
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

         ASSIGN glb_cdcritic = 0
                glb_dscritic = ""
                glb_cdcritic = pc_valida_imoveis_epr.pr_cdcritic
                                WHEN pc_valida_imoveis_epr.pr_cdcritic <> ?
                glb_dscritic = pc_valida_imoveis_epr.pr_dscritic
                                WHEN pc_valida_imoveis_epr.pr_dscritic <> ?
				        aux_flimovel = INT(pc_valida_imoveis_epr.pr_flimovel).
        
         IF glb_cdcritic > 0 THEN
            DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
               UNDO, NEXT.
            END.
         ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
            DO:
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
               UNDO, NEXT.
            END.  
          
         IF aux_flimovel = 1 THEN
            DO:
               MESSAGE "A proposta nao pode ser efetivada, dados dos Imoveis"
                       + "nao cadastrados.".
               PAUSE 3 NO-MESSAGE.
               UNDO, NEXT.
            END. /* IF aux_flimovel = 1 THEN */
      END. /* IF craplcr.tpctrato = 3 */
      FIM - 17/02/2017 - Retirado a validaçao conforme solicitaçao
      */

      /* Validaçao e efetivaçao do seguro prestamista -- PRJ438 
         Paulo Martins (Mouts)*/     
      IF crapass.inpessoa = 1 THEN DO:

      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
      RUN STORED-PROCEDURE pc_efetiva_proposta_sp
                           aux_handproc = PROC-HANDLE NO-ERROR
                    (INPUT glb_cdcooper,      /* Cooperativa */
                     INPUT tel_nrdconta,      /* Número da conta */
                     INPUT tel_nrctremp,      /* Número emrepstimo */
                     INPUT tel_cdagenci,      /* Agencia */
                     INPUT 100,                /* Caixa */
                     INPUT glb_cdoperad,      /* Operador   */
                     INPUT glb_nmdatela,      /* Tabela   */
                     INPUT 1,                 /* Origem - Ayllos */ 
                    OUTPUT 0,
                    OUTPUT "").

      CLOSE STORED-PROC pc_efetiva_proposta_sp 
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
      ASSIGN glb_cdcritic = pc_efetiva_proposta_sp.pr_cdcritic
                               WHEN pc_efetiva_proposta_sp.pr_cdcritic <> ?
             glb_dscritic = pc_efetiva_proposta_sp.pr_dscritic
                               WHEN pc_efetiva_proposta_sp.pr_dscritic <> ?.
          IF glb_cdcritic > 0 OR glb_dscritic <> "" THEN 
             DO:
                 ASSIGN glb_dscritic = "Erro ao efetivar prestamista: " 
                                       + glb_dscritic.
                 MESSAGE glb_dscritic.
                 PAUSE 3 NO-MESSAGE.
                 UNDO, RETURN.
             END.
      END.  	  

      IF glb_cdcritic > 0    THEN
         NEXT INCLUSAO.

      IF glb_cdcooper = 3  THEN DO:

             ASSIGN aux_nrdconta = tel_nrdconta.

             /* montar rating para cooperativas */
             { includes/rating_singulares.i tel_nrctremp 90 }

             IF glb_cdcritic > 0 OR glb_dscritic <> "" THEN
                UNDO, NEXT INCLUSAO.

             RUN fontes/gera_rating_singulares.p (INPUT glb_cdcooper,
                                                  INPUT tel_nrdconta,
                                                  INPUT 90, /* Emprestimo/ Financiamento */
                                                  INPUT tel_nrctremp,
                                                  INPUT TRUE, /* Gravar Rating */
                                                  INPUT TABLE tt-singulares).
         END.
      ELSE DO:

             RUN fontes/gera_rating.p (INPUT glb_cdcooper,
                                       INPUT tel_nrdconta,
                                       INPUT 90, /* Emprestimo/ Financiamento */
                                       INPUT tel_nrctremp,
                                       INPUT TRUE).  /* Gravar Rating */

/*--------  P450 Rating ------------------   */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* VALIDA RATING */
        RUN STORED-PROCEDURE pc_busca_status_rating aux_handproc = PROC-HANDLE
          (INPUT  glb_cdcooper
          ,INPUT  tel_nrdconta
          ,INPUT  90           /* Tipo do contrato */
          ,INPUT  tel_nrctremp /* Numero do contrato  */
          ,OUTPUT 0            /* Status do Rating */
          ,OUTPUT 0            /* Flag do Rating */
          ,OUTPUT 0
          ,OUTPUT "").

        CLOSE STORED-PROCEDURE pc_busca_status_rating
             WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN glb_dscritic = ""
               glb_cdcritic = 0
               aux_flrating = 0
               glb_dscritic = pc_busca_status_rating.pr_dscritic
                                WHEN pc_busca_status_rating.pr_dscritic <> ?
               glb_cdcritic = pc_busca_status_rating.pr_cdcritic
                                WHEN pc_busca_status_rating.pr_cdcritic <> ?
               aux_flrating = pc_busca_status_rating.pr_flgrating
                                WHEN pc_busca_status_rating.pr_flgrating <> ?
               .

        IF glb_cdcritic > 0 OR glb_dscritic <> "" THEN DO:
           MESSAGE glb_dscritic.
           PAUSE 3 NO-MESSAGE.
           UNDO, RETURN.

         END.


       /* RATING - Se nao tem rating valido */
       IF  aux_flrating = 0 THEN DO:

           ASSIGN glb_dscritic = "Contrato nao pode ser efetivado," +
                                 " pois nao ha Rating valido".
           MESSAGE glb_dscritic.
           PAUSE 3 NO-MESSAGE.
           UNDO, RETURN.

       END.
                                                   
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       RUN STORED-PROCEDURE pc_busca_endivid_param aux_handproc = PROC-HANDLE
           (INPUT  glb_cdcooper
           ,INPUT  tel_nrdconta
           ,OUTPUT 0  /*pr_vlendivi */
           ,OUTPUT 0  /*pr_vlrating */
           ,OUTPUT "").

       CLOSE STORED-PROCEDURE pc_busca_endivid_param
              WHERE PROC-HANDLE = aux_handproc.
       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN glb_dscritic = ""
              aux_vlendivi = 0
              aux_vlrating = 0
              glb_dscritic = pc_busca_endivid_param.pr_dscritic
                               WHEN pc_busca_endivid_param.pr_dscritic <> ?
              aux_vlrating = pc_busca_endivid_param.pr_vlrating
                               WHEN pc_busca_endivid_param.pr_vlrating <> ?
              aux_vlendivi = pc_busca_endivid_param.pr_vlendivi
                               WHEN pc_busca_endivid_param.pr_vlendivi <> ?
              .

       IF  glb_dscritic <> "" THEN DO:
           MESSAGE glb_dscritic.
           PAUSE 3 NO-MESSAGE.
           UNDO, RETURN.

       END.


       /* RATING - Se tem rating valido */
       /* Se Endividamento + Contrato atual > Parametro Rating (TAB036) */
       IF ((aux_vlendivi + tel_vlemprst) > aux_vlrating)  THEN DO:
           /* Gravar o Rating da operaçao, efetivando-o */

         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
           RUN STORED-PROCEDURE pc_grava_rating_operacao 
                 aux_handproc = PROC-HANDLE
               (INPUT  glb_cdcooper
               ,INPUT  tel_nrdconta
               ,INPUT 90            /* Tipo Contrato */
               ,INPUT tel_nrctremp
               ,INPUT ?
               ,INPUT ?     /* null para pr_ntrataut */
               ,INPUT glb_dtmvtolt  /* pr_dtrating */
               ,INPUT 4     /* pr_strating => 4 -- efetivado */
               ,INPUT ?     /* pr_orrating */
               ,INPUT glb_cdoperad
               ,INPUT ?     /* null para pr_dtrataut */
               ,INPUT ?     /* null pr_innivel_rating */
               ,INPUT Crapass.nrcpfcnpj_base
               ,INPUT ?     /* pr_inpontos_rating     */
               ,INPUT ?     /* pr_insegmento_rating   */
               ,INPUT ?     /* pr_inrisco_rat_inc     */
               ,INPUT ?     /* pr_innivel_rat_inc     */
               ,INPUT ?     /* pr_inpontos_rat_inc    */
               ,INPUT ?     /* pr_insegmento_rat_inc  */
               ,INPUT ?     /* pr_efetivacao_rating   */
               ,INPUT "1"   /* pr_cdoperad*/
               ,INPUT glb_dtmvtolt
               ,INPUT crawepr.vlpreemp
               ,INPUT ?     /*sugerido*/
               ,INPUT ""    /*Justif*/
               ,INPUT ?
               ,OUTPUT 0    /* pr_cdcritic */
               ,OUTPUT ""). /* pr_dscritic */

           CLOSE STORED-PROCEDURE pc_grava_rating_operacao
                WHERE PROC-HANDLE = aux_handproc.
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

           ASSIGN glb_dscritic = pc_grava_rating_operacao.pr_dscritic
                              WHEN pc_grava_rating_operacao.pr_dscritic <> ?.

           IF  glb_dscritic <> "" THEN DO:
               MESSAGE glb_dscritic.
               PAUSE 3 NO-MESSAGE.
               UNDO, RETURN.

           END.
       END.
/*--------  P450 Rating ------------------   */
         
      END.

      IF RETURN-VALUE <> "OK"   THEN
         UNDO, NEXT INCLUSAO.

   END.   /* Fim da transacao */

   RELEASE craplot.
   RELEASE crablem.
   RELEASE crabepr.
   RELEASE craplcr.

   IF tel_qtdifeln = 0  AND
      tel_vldifedb = 0  AND
      tel_vldifecr = 0  THEN
      DO:
          ASSIGN glb_nmdatela = "LOTE".
          RETURN.                        /* Volta ao lanctr.p */

      END.

   ASSIGN tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] = STRING(tel_nrdconta,"zzzz,zzz,9")         + "  " +
                            STRING(tel_nrctremp,"zz,zzz,zz9")          + "   " +
                            STRING(tel_cdfinemp,"zz9")                + " " +
                            STRING(tel_cdlcremp,"zzz9")                + " " +
                            tel_nivrisco                              + " " +
                            STRING(tel_vlemprst,"zzz,zzz,zzz,zz9.99") + "    " +
                            STRING(tel_vlpreemp,"zzz,zzz,zzz,zz9.99")

          tel_nrdconta = 0
          tel_nrctremp = 0
          tel_cdfinemp = 0
          tel_cdlcremp = 0
          tel_nivrisco = " "
          tel_vlemprst = 0
          tel_vlpreemp = 0
          tel_qtpreemp = 0
          tel_nrctaav1 = 0
          tel_nrctaav2 = 0
          tel_avalist1 = " "
          tel_avalist2 = " "
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln
           tel_vlinfodb
           tel_vlinfocr
           tel_qtcompln
           tel_vlcompdb
           tel_vlcompcr
           tel_qtdifeln
           tel_vldifedb
           tel_vldifecr
           tel_nrdconta
           tel_nrctremp
           tel_cdfinemp
           tel_cdlcremp
           tel_nivrisco
           tel_vlemprst
           tel_vlpreemp
           tel_qtpreemp
           tel_nrctaav1
           tel_nrctaav2
           tel_nrseqdig
           tel_avalist1
           tel_avalist2
           WITH FRAME f_lanctr.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1]
           tel_reganter[2]
           tel_reganter[3]
           WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  TRANS INCLUSAO */
        


PROCEDURE pi-critica-fiador:

   FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                      crabass.nrdconta = aux_nravlctr
                      NO-LOCK NO-ERROR.

   IF NOT AVAILABLE crabass THEN
      DO:
          ASSIGN glb_cdcritic = 9.
          RETURN "NOK".
      END.

  /*Monta a mensagem da rotina para envio no e-mail*/
   ASSIGN aux_dsrotina = "Inclusao/alteracao "                                +
                         "do Avalista conta "                                 +
                         STRING(crabass.nrdconta,"zzzz,zzz,9")                +
                         " - CPF/CNPJ "                                       +
                        (IF crabass.inpessoa = 1 THEN
                            STRING((STRING(crabass.nrcpfcgc,
                                  "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crabass.nrcpfcgc,
                                   "99999999999999")),"xx.xxx.xxx/xxxx-xx" )) +
                         " na conta "                                         +
                         STRING(tel_nrdconta,"zzzz,zzz,9").

   IF NOT VALID-HANDLE(h-b1wgen0110) THEN
      RUN sistema/generico/procedures/b1wgen0110.p
          PERSISTENT SET h-b1wgen0110.

   /*Verifica se o avalista esta no cadastro restritivo. Se estiver, sera
     enviado um e-mail informando a situacao*/
   RUN alerta_fraude IN h-b1wgen0110(INPUT glb_cdcooper,
                                     INPUT tel_cdagenci,
                                     INPUT 0, /*nrdcaixa*/
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT glb_dtmvtolt,
                                     INPUT 1, /*ayllos*/
                                     INPUT crabass.nrcpfcgc,
                                     INPUT crabass.nrdconta,
                                     INPUT 1, /*idseqttl*/
                                     INPUT FALSE, /*nao bloq. operacao*/
                                     INPUT 32, /*cdoperac*/
                                     INPUT aux_dsrotina,
                                     OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0110) THEN
      DELETE PROCEDURE h-b1wgen0110.

   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro THEN
            ASSIGN glb_cdcritic = tt-erro.cdcritic
                   glb_dscritic = tt-erro.dscritic.
         ELSE
            ASSIGN glb_cdcritic = 0
                   glb_dscritic = "Nao foi possivel verificar o cadastro " +
                                  "restritivo.".

         RETURN "NOK".

      END.

   IF crabass.inpessoa = 3  THEN  /** conta administrativa **/
      RETURN "OK".

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_qtlintel = 0
          aux_qtctaavl = 0.

   FOR EACH crabavl WHERE crabavl.cdcooper  = glb_cdcooper AND
                          crabavl.nrdconta  = aux_nravlctr AND
                          crabavl.nrctaavd <> tel_nrdconta AND
                          crabavl.nrctravd <> tel_nrctremp AND
                          crabavl.tpctrato  = 1
                          NO-LOCK BREAK BY crabavl.nrctaavd:

       IF FIRST-OF(crabavl.nrctaavd)  THEN
          ASSIGN aux_avljaacu = no.

       FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper      AND
                          crapepr.nrdconta = crabavl.nrctaavd  AND
                          crapepr.nrctremp = crabavl.nrctravd
                          USE-INDEX crapepr2 NO-LOCK NO-ERROR.

       IF AVAILABLE crapepr  THEN
          DO:
              IF crapepr.inliquid = 0  AND
                 NOT  aux_avljaacu      THEN
                 ASSIGN aux_qtctaavl  = aux_qtctaavl + 1
                        aux_avljaacu  = yes.

          END.

   END.

   IF aux_qtctaavl < 3  THEN
      RETURN "OK".

   CLEAR FRAME f_emprestimos ALL.

   /*FOR EACH w-emprestimo:
       DELETE w-emprestimo.
   END.*/
   EMPTY TEMP-TABLE w-emprestimo.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "USUARI"     AND
                      craptab.cdempres = 11           AND
                      craptab.cdacesso = "TAXATABELA" AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF NOT AVAILABLE craptab   THEN
      ASSIGN aux_inusatab = FALSE.
   ELSE
      ASSIGN aux_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0" THEN
                               FALSE
                            ELSE
                               TRUE.

   ASSIGN aux_titelavl = "Fiador = " + STRING(aux_nravlctr, ">>>,>>>,>")
                         + " - " + (crabass.nmprimtl).

   FOR EACH crabavl WHERE crabavl.cdcooper  = glb_cdcooper AND
                          crabavl.nrdconta  = aux_nravlctr AND
                          crabavl.nrctaavd <> tel_nrdconta AND
                          crabavl.nrctravd <> tel_nrctremp AND
                          crabavl.tpctrato  = 1
                          NO-LOCK:

       FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper     AND
                          crapepr.nrdconta = crabavl.nrctaavd AND
                          crapepr.nrctremp = crabavl.nrctravd
                          USE-INDEX crapepr2 NO-LOCK NO-ERROR.

       IF NOT AVAILABLE crapepr THEN
          DO: /* Se nao existe contrato efetivado devo desconsiderar */
              NEXT.

              /*
              glb_cdcritic = 9.
              RETURN.
              */

          END.

       IF crapepr.inliquid <> 0 THEN
          NEXT.

       FIND crabass WHERE crabass.cdcooper = glb_cdcooper     AND
                          crabass.nrdconta = crapepr.nrdconta
                          NO-LOCK NO-ERROR.

       IF AVAIL crabass  THEN
          DO:
             IF crabass.inpessoa = 1   THEN
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                       crapttl.nrdconta = crabass.nrdconta AND
                                       crapttl.idseqttl = 1
                                       NO-LOCK NO-ERROR.

                    IF AVAIL crapttl  THEN
                       ASSIGN aux_cdempres = crapttl.cdempres.

                END.
             ELSE
                DO:
                   FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                                      crapjur.nrdconta = crabass.nrdconta
                                      NO-LOCK NO-ERROR.

                   IF AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.

                END.

          END.

       IF NOT AVAILABLE crabass   THEN
          DO:
              ASSIGN glb_cdcritic = 9.
              RETURN "NOK".

          END.

       /*  Leitura do dia do pagamento da empresa  */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "GENERI"     AND
                          craptab.cdempres = 00           AND
                          craptab.cdacesso = "DIADOPAGTO" AND
                          craptab.tpregist = aux_cdempres
                          NO-LOCK NO-ERROR.

       IF NOT AVAILABLE craptab   THEN
          DO:
              ASSIGN glb_cdcritic = 55.
              RETURN "NOK".

          END.

       IF CAN-DO("1,3,4",STRING(crabass.cdtipsfx)) THEN
          ASSIGN tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)). /*Mensal*/
       ELSE
          ASSIGN tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)). /*Horis.*/

       ASSIGN tab_indpagto = INTEGER(SUBSTRING(craptab.dstextab,14,1)).

       /*  Verifica se a data do pagamento da empresa cai num dia util  */

       ASSIGN tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,
                                        YEAR(glb_dtmvtolt)).

       DO WHILE TRUE:

          IF WEEKDAY(tab_dtcalcul) = 1   OR
             WEEKDAY(tab_dtcalcul) = 7   THEN
             DO:
                 ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                 NEXT.

             END.

          FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                             crapfer.dtferiad = tab_dtcalcul
                             NO-LOCK NO-ERROR.

          IF AVAILABLE crapfer   THEN
             DO:
                 ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                 NEXT.

             END.

          ASSIGN tab_diapagto = DAY(tab_dtcalcul).

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

       /*** Taxa de Juros           **/
       IF aux_inusatab  THEN
          DO:
             /* FIND crablcr OF crapepr NO-LOCK NO-ERROR.*/
             FIND crablcr WHERE crablcr.cdcooper = glb_cdcooper AND
                                crablcr.cdlcremp = crapepr.cdlcremp
                                NO-LOCK NO-ERROR.

              IF NOT AVAILABLE crablcr   THEN
                 DO:
                     ASSIGN glb_cdcritic = 363.
                     RETURN "NOK".
                 END.
              ELSE
                 ASSIGN aux_txdjuros = crablcr.txdiaria.
          END.
       ELSE
          ASSIGN aux_txdjuros = crapepr.txjuremp.

       /*  Inicialiazacao das variaves para a rotina de calculo  */
       ASSIGN aux_nrdconta = crapepr.nrdconta
              aux_nrctremp = crapepr.nrctremp
              aux_vlsdeved = crapepr.vlsdeved
              aux_vljuracu = crapepr.vljuracu
              aux_qtprecal = crapepr.qtprecal
              aux_dtcalcul = today
              aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt))
                               + 4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                     YEAR(glb_dtmvtolt)) + 4)).

       /**** rotina para calculo do saldo devedor ***/
       { includes/lelem.i}

       CREATE w-emprestimo.

       ASSIGN w-emprestimo.nrdconta = crapepr.nrdconta
              w-emprestimo.nrctremp = crapepr.nrctremp
              w-emprestimo.dtmvtolt = crapepr.dtmvtolt
              w-emprestimo.vlemprst = crapepr.vlemprst
              w-emprestimo.qtpreemp = crapepr.qtpreemp
              w-emprestimo.vlpreemp = crapepr.vlpreemp
              w-emprestimo.vlsdeved = IF aux_vlsdeved > 0 THEN
                                         aux_vlsdeved
                                      ELSE 0.

   END.  /*  Fim do FOR EACH  */

   FOR EACH w-emprestimo NO-LOCK:

       ASSIGN aux_regexist = TRUE
              aux_qtlintel = aux_qtlintel + 1.

       IF aux_qtlintel = 1   THEN
          IF aux_flgretor   THEN
             DO:
                 PAUSE MESSAGE
                    "Tecle <Entra> para continuar ou <Fim> para encerrar".
                 CLEAR FRAME f_todos ALL NO-PAUSE.
             END.
       ELSE
          ASSIGN aux_flgretor = TRUE.

       DISPLAY w-emprestimo.nrdconta
               w-emprestimo.nrctremp
               w-emprestimo.dtmvtolt
               w-emprestimo.vlemprst
               w-emprestimo.qtpreemp
               w-emprestimo.vlpreemp
               w-emprestimo.vlsdeved
               WITH FRAME f_emprestimos.

       IF aux_qtlintel = 9   THEN
          ASSIGN aux_qtlintel = 0.
       ELSE
          DOWN WITH FRAME f_emprestimos.

   END.  /*  Fim do FOR EACH  */

   RETURN "OK".

END PROCEDURE.

PROCEDURE verifica_emprestimos_lancados_dia:

   FOR EACH crabepr WHERE crabepr.cdcooper = glb_cdcooper     AND
                          crabepr.nrdconta = crawepr.nrdconta AND
                          crabepr.dtmvtolt = glb_dtmvtolt
                          NO-LOCK,

       FIRST b_crawepr WHERE b_crawepr.cdcooper = glb_cdcooper     AND
                             b_crawepr.nrdconta = crabepr.nrdconta AND
                             b_crawepr.nrctremp = crabepr.nrctremp
                             NO-LOCK:

        ASSIGN aux_contador = 1.

        DO aux_contador = 1 TO 10 :

           IF b_crawepr.nrctrliq[aux_contador] > 0 THEN
              DO:
                 IF  crawepr.nrctrliq[1] =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[2]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[3]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[4]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[5]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[6]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[7]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[8]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[9]  =
                     b_crawepr.nrctrliq[aux_contador] OR
                     crawepr.nrctrliq[10] =
                     b_crawepr.nrctrliq[aux_contador] THEN
                     DO:
                        ASSIGN glb_cdcritic = 805.
                        RUN mensagem_contrato_liquidado.
                        LEAVE.

                     END.

              END.

        END.

   END.  /* FOR EACH */

END PROCEDURE.

PROCEDURE verifica_valores_linha:

   /*---   Verificar Valor Maximo Linha p/associado ------*/
   FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                      craplcr.cdlcremp = crawepr.cdlcremp
                      NO-LOCK NO-ERROR.

   FIND crabass WHERE crabass.cdcooper = glb_cdcooper     AND
                      crabass.nrdconta = crawepr.nrdconta
                      NO-LOCK NO-ERROR.

   IF  AVAIL craplcr           AND
     ((craplcr.vlmaxass > 0    AND
       crabass.inpessoa = 1)    OR    /* Pessoa Fisica */
      (craplcr.vlmaxasj > 0    AND
       crabass.inpessoa <> 1))THEN   /* Pessoa Juridica */
       DO:
          ASSIGN aux_totlinha = 0.

          FOR EACH w_contas NO-LOCK,

              EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper      AND
                                 crapepr.nrdconta = w_contas.nrdconta AND
                                 crapepr.inliquid = 0                 AND
                                 crapepr.cdlcremp = crawepr.cdlcremp
                                 NO-LOCK:

               RUN fontes/saldo_epr.p (INPUT  crapepr.nrdconta,
                                       INPUT  crapepr.nrctremp,
                                       OUTPUT aux_vlsdeved,
                                       OUTPUT aux_qtprecal_retorno).

               IF glb_cdcritic > 0   THEN
                  ASSIGN aux_vlsdeved = 0.

               IF aux_vlsdeved < 0 THEN
                  ASSIGN  aux_vlsdeved = 0.

               ASSIGN aux_totlinha = aux_totlinha + aux_vlsdeved.

          END.

           IF crabass.inpessoa = 1 THEN
              ASSIGN aux_valor_maximo = craplcr.vlmaxass.
           ELSE
              ASSIGN aux_valor_maximo = craplcr.vlmaxasj.

          IF (aux_totlinha + crawepr.vlemprst) >
              aux_valor_maximo THEN
              DO:
                 ASSIGN aux_aprovavl = NO.
                 MESSAGE COLOR NORMAL
                             "Vlrs(Linha) Excedidos"
                             "(Utiliz. "      +
                            TRIM(STRING(aux_totlinha,"zzz,zzz,zz9.99")) +
                             " Excedido "
                             TRIM(STRING((aux_totlinha + crawepr.vlemprst
                                     - aux_valor_maximo),"zzz,zzz,zz9.99")) +
                              ")Confirma? "
                             UPDATE aux_aprovavl.
                 IF NOT aux_aprovavl THEN
                    ASSIGN aux_vlr_excedido = YES.

              END.

       END.

END PROCEDURE.

PROCEDURE mensagem_contrato_liquidado:

   ASSIGN aux_mensagem_liq = " ".

   IF crawepr.nrctrliq[1] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[1]) +
                          " , ".
   IF crawepr.nrctrliq[2] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[2]) +
                         " , ".
   IF crawepr.nrctrliq[3] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[3]) +
                         " , ".
   IF crawepr.nrctrliq[4] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[4]) +
                         " , ".
   IF crawepr.nrctrliq[5] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[5]) +
                         " , ".
   IF crawepr.nrctrliq[6] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[6]) +
                         " , ".
   IF crawepr.nrctrliq[7] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[7]) +
                         " , ".
   IF crawepr.nrctrliq[8] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[8]) +
                         " , ".
   IF crawepr.nrctrliq[9] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[9]) +
                         " , ".
   IF crawepr.nrctrliq[10] =
      b_crawepr.nrctrliq[aux_contador] THEN
      aux_mensagem_liq = aux_mensagem_liq + STRING(crawepr.nrctrliq[10]) +
                         " , ".
   IF aux_mensagem_liq <> " " THEN
      DO:
         MESSAGE "Altere proposta:  contrato " +
                 TRIM(aux_mensagem_liq) + " foi liquidado no"
                 + " Contrato " + STRING(b_crawepr.nrctremp).
      END.

END PROCEDURE.


/* .......................................................................... */


