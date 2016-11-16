 /* ..........................................................................

   Programa: Fontes/crps388.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                          Ultima atualizacao: 15/08/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 092
               Gerar arquivo de arrecadacao de faturas(Debito Automatico)
               Emite relatorio 350.

   Alteracoes: 29/06/2004 - Tratamento de erros nos relatorios (Ze Eduardo).
   
               30/06/2004 - Nomear arquivo de dados dentro do FOR EACH crapndb
                            caso este ainda nao tenha sido nomeado (Julio).
  
               06/10/2004 - Sequenciar pelo numero do convenio(Mirtes). 

               03/11/2004 - Inclusao dos convenios 5 e 15 (Julio) 

               26/11/2004 - Inclusao do convenio 16 (Julio) 

               30/11/2004 - Cooperativa 1, nunca vai com "9001" na frente do
                            numero da conta (Julio)

               07/01/2005 - Referencia de cliente  VIVO deve ter 11 digitos
                            (Julio)

               28/01/2005 - Tratamento SAMAE GASPAR (CECRED) -> Hist. 635
                            convenio 19 
                            SAMAE TIMBO -> Hist. 628 convenio 16 (Julio)
                            
               02/02/2005 - Tratamento SAMAE BLUMENAU CECRED -> 643 (Julio)
                 
               25/04/2005 - Tratamento para UNIMED -> 509 (Julio)  

               31/05/2005 - Tratamento para AGUAS ITAPEMA -> 24 Hist. 455
                            (Julio)

               12/07/2005 - Alteracoes no tratamento de SAMAE GASPAR -> 19
                            (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crabcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Quando for UNIMED (22), sempre colocar o codigo da
                            cooperativa no numero da conta, mesmo quendo for
                            VIACREDI. (Julio)

               12/01/2006 - Tratamento para email's em branco (Julio)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               13/10/2006 - Tratamento para CELESC Distribuicao (Julio)

               27/11/2006 - Acerto no envio de email pela BO b1wgen0011 (David).
               
               29/11/2006 - Inclusao do convenio 28 - Unimed (Elton).
               
               02/02/2007 - Tratamento para DAE Navegantes -> 31 (Elton).
               
               29/05/2007 - Inclusao de registros "J" no caso do convenio
                            solicitar arquivos de confirmacao (Elton).
                            
               30/05/2007 - Inclusao do convenio 32 - Uniodonto (Elton).
               
               01/06/2007 - Incluido possibilidade de envio de arquivo para
                            Accestage (Elton).
               
               27/07/2007 - Acertado total de registros no trailer "Z" quando
                            houver registros do tipo "J" (Elton).
                            
               19/11/2007 - Tratamento para Aguas de Joinville -> 33 (Elton).
               
               28/11/2007 - Tratamento para SEMASA Itajai -> 34 (Elton).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               15/08/2008 - Tratamento para o convenio SAMAE Jaragua -> 9
                            (Diego).
                            
               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).
                            
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - Paulo
                            
               16/10/2009 - Tratamento para convenio 38 -> Unimed Planalto Norte
                            e convenio 43 -> Servmed (Elton). 
                            
               15/04/2010 - Tratamento para convenio 46 -> Uniodonto Federacao
                            (Elton).
                            
               18/05/2010 - Tratamento para convenio 48 -> TIM Celular, conforme
                            convenio 3 (Elton).
               
               09/06/2010 - Tratamento para convenio 47 -> Unimed Credcrea 
                            (Elton).
               
               01/10/2010 - Tratamento para convenio 49 -> Samae Rio Negrinho e
                            convenio 50 -> HDI (Elton). 
                            
               08/11/2010 - Acerto no retorno de lancamentos nao debitados para
                            VIVO (Elton).             
                            
               11/05/2011 - Tratamento para convenio 53 -> Foz do Brasil e 
                            convenio 54 -> Aguas de Massaranduba (Elton).
                            
               27/05/2011 - Tratamento para convenio 55 -> Liberty
                            Tratamento para convenio 57 -> Jornal de SC (Elton).
               
               02/06/2011 - Incluido no for each a condição -
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               03/11/2011 - Tratamento para convenio 58 -> Porto Seguro (Elton).

               23/01/2012 - Tratamento para unificacao arqs. Convenios
                            (Guilherme/Supero)
                            
               22/06/2012 - Substituido gncoper por crabcop (Tiago).       
               
               03/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                            código do convênio (Guilherme Maba).                
                            
               29/11/2102 - Tratamento migracao Alto Vale (Elton).
               
               03/06/2013 - Incluindo no FIND FIRST craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               04/07/2013 - Tratamento para Azul Seguros (Elton).
               
               08/08/2013 - Nao cria registro de controle na gncontr se for 
                            Cecred e o convenio for unificado (Elton).
                            
               20/09/2013 - Retirada condicao para atribuicao da variavel 
                            aux_nragenci;
                          - Retirado tratamento para GLOBAL TELECOM;
                          - Agrupados convenios: SAMAE Jaragua, SAMAE Gaspar,
                            SAMAE Blumenau Viacredi, SAMAE Blumenau Creditextil,
                            SAMAE Blumenau CECRED, SAMAE Timbo CECRED,
                            SAMAE Rio Negrinho em uma mesma condicao para a 
                            atribuicao da variavel aux_dslinreg;
                          - Adicionada condicao para os convenios: 1,25,26,33,
                            39,41,43,62;
                          - Adionado ultimo else no for each do craplcm. 
                            (Reinert)
               
               07/11/2013 - Tratamento migracao Acredi (Elton).
               
               22/11/2013 - Ajustes de format na exportacao convenios (Lucas R)
               
               22/01/2014 - Incluir VALIDATE gncontr, gncvuni (Lucas R.)
               
               01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               26/05/2014 - Retirado mensagens do log: "Sem movtos Convenio"; 
                            "Executando Convenio"; conforme chamado: 146206
                            data: 07/04/2014 - chamado:146223 data: 07/04/2014
                            chamado: 146226 data: 07/04/2014. Jéssica (DB1)
                            
               29/05/2014 - Retirado Criticas: 657; 748; 696 e 905 conforme 
                            chamado: 146231 data: 07/04/2014 - chamado:146236 
                            data: 07/04/2014. Jéssica (DB1)
                            
               25/09/2014 - Inclusao do convenio PREVISUL (cdconven = 66)
                            para montagem do arquivo de retorno com campo
                            de identificacao do cliente com 20 posicoes.
                            Removido das verificacoes alguns convenios 
                            que estao inativos. (Chamado 101648) - (Fabricio)
                            
               23/10/2014 - Tratamento para o campo Usa Agencia 
                            (gnconve.flgagenc); convenios a partir de 2014.
                            (Fabricio)
                            
               14/11/2014 - Ajuste para montar os registros da crapndb no
                            arquivo da mesma forma que quando montado atraves
                            da leitura da craplcm. (Chamado 173646) - (Fabricio)
                            
               28/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela
                            Oi). (Chamado 192004) - (Fabricio)
                            
               07/04/2015 - Logs migrados para proc_message.log que nao eram
                            referentes ao processo (SD273550 - Tiago).
                            
               03/06/2015 - Retirado validacoes para o convenio 53 Foz do brasil
                            (Lucas Ranghetti #292200)
                            
               19/06/2015 - Alterado ordem do calculo da data aux_dtmvtopr
                            (Lucas Ranghetti #296615)
                            
               13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, 
                            referencia e conta (Lucas Ranghetti #292988 )
               
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
                            
               27/11/2015 - Alterar proc_batch pelo proc_message e tambem
                            retirado os logs do proc_message que eram gerados
                            com linhas em branco (Lucas Ranghetti #366033)

			   04/04/2016 - Incluido a regra Caso a data de inicio da
				        	 autorização seja maior que 01/09/2013 ira gravar a 
							 agencia com formato novo. 

               15/06/2016 - Adicnioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)

               23/06/2016 - P333.1 - Devolução de arquivos com tipo de envio 
			                6 - WebService (Marcos)
               
               15/08/2016 - Alterado ordem da leitura da crapatr (Lucas Ranghetti #499449)

			   05/10/2016 - Incluir tratamento para a CASAN enviar a angecia 1294 para autorizacoes
							mais antigas (Lucas Ranghetti ##534110)
............................................................................. */
 
{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR b1wgen0011       AS HANDLE                           NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"           NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"           NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5  NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 9
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "CADASTROS",
                                     "PROCESSOS",
                                     "PARAMETRIZACAO",
                                     "SOLICITACOES",
                                     "GENERICO       "]             NO-UNDO.

DEF  VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       [" JANEIRO ","FEVEREIRO",
                                        "  MARCO  ","  ABRIL  ",
                                        "  MAIO   ","  JUNHO  ",
                                        " JULHO   "," AGOSTO  ",
                                        "SETEMBRO "," OUTUBRO ",
                                        "NOVEMBRO ","DEZEMBRO "]    NO-UNDO.

DEF  VAR aux_nmarqdat    AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR aux_nmarqped    AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR aux_nmdirdes    AS CHAR                                    NO-UNDO.
DEF  VAR aux_nroentries  AS INTE                                    NO-UNDO.
DEF  VAR aux_contador    AS INTE                                    NO-UNDO.
DEF  VAR aux_dsdemail    AS CHAR                                    NO-UNDO.
DEF  VAR aux_nrdconta    AS CHAR    FORMAT "x(14)"                  NO-UNDO.
DEF  VAR aux_cdcooperativa AS CHAR  FORMAT "x(04)"                  NO-UNDO.
DEF  VAR aux_dtgerarq    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dtintarq    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dtmvtolt    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dtmvtolt_aux AS CHAR                                   NO-UNDO.
DEF  VAR aux_dtmvtopr    AS DATE                                    NO-UNDO.
DEF  VAR aux_cdrefere    AS CHAR                                    NO-UNDO.
DEF  VAR aux_anomovto    AS CHAR     FORMAT "x(05)"                 NO-UNDO.
DEF  VAR aux_diamovto    AS INT      FORMAT "99"                    NO-UNDO.
DEF  VAR aux_mesmovto    AS CHAR     FORMAT "x(09)"                 NO-UNDO.
DEF  VAR aux_vltarifa    AS DECIMAL                                 NO-UNDO.
DEF  VAR aux_vllanmto    AS DECIMAL                                 NO-UNDO.
DEF  VAR aux_vlfatndb    AS DECIMAL                                 NO-UNDO.
DEF  VAR aux_vltotarq    AS DECIMAL                                 NO-UNDO.

DEF  VAR aux_diavecto    AS CHAR     FORMAT "x(02)"                 NO-UNDO.
DEF  VAR aux_mesvecto    AS CHAR     FORMAT "x(02)"                 NO-UNDO.
DEF  VAR aux_anovecto    AS CHAR     FORMAT "x(04)"                 NO-UNDO.
DEF  VAR aux_nrseqatu    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dsobserv    AS CHAR     FORMAT "x(15)"                 NO-UNDO.

DEF  VAR  aux_nrsequen   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nmarqrel   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nmempcov   AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR  aux_nrconven   AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR  aux_nrseqarq   AS INT      FORMAT "999999"                NO-UNDO.
DEF  VAR  aux_nmdbanco   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nrdbanco   AS INT   FORMAT "999"                      NO-UNDO.
DEF  VAR  aux_nragenci   AS CHAR  FORMAT "x(04)"                    NO-UNDO.

DEF  VAR  aux_flgfirst   AS LOGICAL                                 NO-UNDO.
DEF  VAR  aux_flgrelat   AS LOGICAL                                 NO-UNDO.

DEF  VAR  aux_nrseqdig   AS INTEGER                                 NO-UNDO.
DEF  VAR  aux_nrseqndb   AS INTEGER                                 NO-UNDO.
DEF  VAR  aux_nrseqtot   AS INTEGER                                 NO-UNDO.
DEF  VAR  aux_nrsequni   AS INTEGER                                 NO-UNDO.
DEF  VAR  aux_nmcidade   AS CHAR  EXTENT 2                          NO-UNDO.
DEF  VAR  aux_nmempres   AS CHAR  FORMAT "x(20)"                    NO-UNDO.
DEF  VAR  aux_nrseqret   AS INTEGER                                 NO-UNDO.

DEF  VAR  tot_vlfatura   AS DECIMAL                                 NO-UNDO.
DEF  VAR  tot_vltarifa   AS DECIMAL                                 NO-UNDO.
DEF  VAR  tot_vlapagar   AS DECIMAL                                 NO-UNDO.

DEF VAR rel_nmrescop AS CHAR extent 2.
DEF VAR aux_qtpalavr AS INTE.
DEF VAR aux_contapal AS INTE.
DEF VAR aux_vldocto2 AS DECI                                        NO-UNDO.

DEF  VAR  aux_dslinreg    LIKE gncvuni.dsmovtos                     NO-UNDO.

DEF  VAR  aux_ctamigra   AS LOGICAL                                 NO-UNDO.

DEF BUFFER gbconve FOR gnconve.
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER b-crapcop FOR crapcop. 

DEF  STREAM str_1.  /* Para relatorios */
DEF  STREAM str_2.  /* Para arquivo auxiliar */

FORM SKIP(1)
     aux_nmarqdat   AT  06  LABEL "NOME DO ARQUIVO"
     aux_dtmvtopr   AT  49  LABEL "DATA DO CREDITO" FORMAT "99/99/9999"
     SKIP(1)
     aux_nmempcov   AT  06  LABEL "NOME DO CONVENIO" 
     SKIP(2)
     WITH NO-BOX DOWN SIDE-LABELS  WIDTH 80 FRAME f_label.

FORM
     craplcm.nrdconta   AT 03  FORMAT "zzzz,zz9,9"      LABEL "CONTA/DV"
     aux_cdrefere       AT 15  FORMAT "x(13)"           LABEL "CONTRATO"
     craplcm.vllanmto   AT 30  FORMAT "zzz,zzz,zzz,zz9.99"
                                                        LABEL "VALOR DO DEBITO"
     craplcm.dtmvtolt   AT 50  FORMAT "99/99/9999"      LABEL "DATA DEBITO"
     aux_dsobserv       AT 63                           LABEL "OBSERVACAO"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lancto.

FORM SKIP(2)
     aux_nrseqdig   AT 20  FORMAT "       zzz,zz9" LABEL "QUANTIDADE DE DEBITOS"
     tot_vlfatura   AT 27  FORMAT "zzz,zzz,zz9.99" LABEL "TOTAL DEBITADO"
     tot_vltarifa   AT 25  FORMAT "zzz,zzz,zz9.99" LABEL "TOTAL DE TARIFAS"
     tot_vlapagar   AT 28  FORMAT "zzz,zzz,zz9.99" LABEL "TOTAL A PAGAR"
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_total.

FORM SKIP(2)
     "DATA DA TRANSMISSAO: _____/_____/_____ AS  _____:_____  POR:" AT 01
     "_________________"
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_final.

FORM  SKIP(08)
      aux_nmcidade[1]  AT 09 FORMAT "X(70)"
      SKIP(4)
      " A  " aux_nmempres     AT 09 SKIP
      aux_nmcidade[2]         AT 09 FORMAT "X(60)" 
      SKIP(3)
      "RESUMO DOS DEBITOS"  AT  25
      "=================="  AT  25
      SKIP(3)
      WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_cabec.

FORM  "DATA DO CREDITO:"     AT 26
      aux_dtmvtopr           AT 49 FORMAT "99/99/9999"
      SKIP(1)
      "ARQUIVO TRANSMITIDO:" AT 22
      aux_nmarqdat           AT 46
      SKIP(2)
      "DATA DA TRANSMISSAO: _____/_____/_____"  AT 22
      SKIP(4)
      "ATENCIOSAMENTE" AT 09
      SKIP(3)
      rel_nmrescop[1] FORMAT "x(40)" AT 09
      rel_nmrescop[2] FORMAT "x(40)" AT 09
      WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_coop.

ASSIGN glb_cdprogra = "crps388".

RUN fontes/iniprg.p.            

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop   THEN
     DO:
         ASSIGN glb_cdcritic = 057.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_nmcidade[1] = TRIM(crabcop.nmcidade)
                       + ", "
       aux_nmcidade[2] = trim(crabcop.nmcidade)
                       + " - "
                       + trim(crabcop.cdufdcop).

RUN p_divinome.

ASSIGN aux_dtmvtolt = STRING(YEAR(glb_dtmvtolt),"9999") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(DAY(glb_dtmvtolt),"99")
       aux_flgfirst = TRUE     
       aux_diamovto = DAY(glb_dtmvtolt)
       aux_mesmovto = aux_nmmesano[MONTH(glb_dtmvtolt)]
       aux_anomovto = STRING(YEAR(glb_dtmvtolt),"9999") + "." 
       aux_nmcidade[1] = aux_nmcidade[1] 
                    + string(aux_diamovto) 
                    + " DE "
                    + aux_mesmovto
                    + " DE "
                    + aux_anomovto.



{ includes/cabrel080_1.i }

FOR EACH gncvcop NO-LOCK WHERE
         gncvcop.cdcooper = crabcop.cdcooper
    BREAK BY gncvcop.cdconven  :

    FOR EACH  gnconve NO-LOCK WHERE
              gnconve.cdconven = gncvcop.cdconven AND
              gnconve.flgativo = YES              AND
              gnconve.cdhisdeb > 0                AND
              gnconve.nmarqdeb <> " ", /* Somente convenios deb.autom. */     
        FIRST crapcop NO-LOCK WHERE     
              crapcop.cdcooper = gnconve.cdcooper
              TRANSACTION ON ERROR UNDO, NEXT:
              
        /* D+1 */
        IF  gnconve.tprepass = 1 THEN
            aux_dtmvtopr = glb_dtmvtopr.
        ELSE /* D+2 */
            aux_dtmvtopr = glb_dtmvtopr + 1.

        DO WHILE TRUE:          /*  Procura pela proxima data */
        
           IF   NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtopr))) AND
                NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                           crapfer.dtferiad = aux_dtmvtopr)  THEN
                LEAVE.
        
           aux_dtmvtopr = aux_dtmvtopr + 1.
        
        END.  /*  Fim do DO WHILE TRUE  */
        
        ASSIGN aux_anovecto =  STRING(YEAR(aux_dtmvtopr),"9999")
               aux_mesvecto =  STRING(MONTH(aux_dtmvtopr),"99")
               aux_diavecto =  STRING(DAY(aux_dtmvtopr),"99").

        ASSIGN aux_nmempres = gnconve.nmempres.
       
        ASSIGN  aux_flgfirst = YES
                aux_nrseqdig = 0
                tot_vlfatura = 0 
                tot_vltarifa = 0 
                tot_vlapagar = 0
                aux_nrseqndb = 0
                aux_vlfatndb = 0
                aux_flgrelat = FALSE
                aux_nrseqret = 0
                aux_vldocto2 = 0.
                
                 
        FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                               craplcm.dtmvtolt = glb_dtmvtolt      AND
                               craplcm.cdhistor = gnconve.cdhisdeb  
                               USE-INDEX craplcm4 NO-LOCK:
             
            ASSIGN aux_dsobserv = ""
                   aux_ctamigra = FALSE 
                   aux_nragenci = STRING(crabcop.cdagectl, "9999").
            


            IF  gnconve.cdconven = 4 THEN   /* CASAN */
			    DO:
				    FIND crapatr WHERE 
                         crapatr.cdcooper = glb_cdcooper     AND
                         crapatr.nrdconta = craplcm.nrdconta AND
                         crapatr.cdhistor = craplcm.cdhistor AND
                         crapatr.cdrefere = DECIMAL(ENTRY(6,SUBSTR(craplcm.cdpesqbb,6,100),"-")) AND
						 crapatr.dtiniatr < 10/05/2016
                         NO-LOCK NO-ERROR.

				    IF  AVAIL crapatr THEN
                ASSIGN aux_nragenci = '1294'.
				END.
                

            IF  aux_flgfirst THEN
                DO:
       
                   RUN nomeia_arquivos.
                   
                   ASSIGN aux_nmarqrel = "rl/crrl350_c" +  
                                         STRING(gnconve.cdconven,"9999") +
                                          ".lst".
                   
                   OUTPUT STREAM str_2 TO VALUE(aux_nmarqped). 
                   OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel)
                                         PAGED PAGE-SIZE 84.
 
                   VIEW STREAM str_1 FRAME f_cabrel080_1.

                   ASSIGN aux_nmempcov = gnconve.nmempres.
                   DISPLAY STREAM str_1 aux_nmarqdat 
                                        aux_dtmvtopr
                                        aux_nmempcov
                                        WITH FRAME f_label.

                   PUT STREAM str_2 "A2"  
                                aux_nrconven  FORMAT "99999999999999999999"
                                aux_nmempcov  FORMAT "x(20)" 
                                aux_nrdbanco  FORMAT "999"
                                aux_nmdbanco  FORMAT "x(20)"
                                aux_dtmvtolt  FORMAT "x(08)"
                                aux_nrseqarq  FORMAT "999999"
                                "04DEBITO AUTOMATICO" 
                                FILL(" ",52) FORMAT "x(52)" SKIP.

                   ASSIGN aux_flgfirst = FALSE                            
                          aux_flgrelat = TRUE.
                
                END.
            
            /*** Verifica se eh conta migrada ***/                
            FIND craptco WHERE craptco.cdcooper = craplcm.cdcooper    AND
                               craptco.nrdconta = craplcm.nrdconta    AND
                               craptco.tpctatrf = 1                   AND
                               craptco.flgativo = TRUE 
                               NO-LOCK NO-ERROR.
                                  
            IF  AVAIL craptco THEN
                DO:
                    ASSIGN aux_ctamigra = TRUE.
                END.
            
            
            FIND FIRST craplau WHERE craplau.cdcooper  = glb_cdcooper      AND
                                     craplau.nrdconta  = craplcm.nrdconta  AND
                                     craplau.cdhistor  = craplcm.cdhistor  AND
                                     craplau.dtdebito  = craplcm.dtmvtolt  AND
                                     craplau.dsorigem <> "CAIXA"           AND
                                     craplau.dsorigem <> "INTERNET"        AND
                                     craplau.dsorigem <> "TAA"             AND
                                     craplau.dsorigem <> "PG555"           AND
                                     craplau.dsorigem <> "CARTAOBB"        AND
                                     craplau.dsorigem <> "BLOQJUD"         AND
                                     craplau.dsorigem <> "DAUT BANCOOB"    AND
                                     craplau.nrdocmto  = 
                         DECIMAL(ENTRY(6,SUBSTR(craplcm.cdpesqbb,6,100),"-")) 
                                     NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craplau THEN
                DO:          
                   /** Verifica se eh conta migrada e se foi enviado 
                       para agendamento na coop. anterior ***/
                   IF  aux_ctamigra = TRUE  THEN
                       DO:                                                              
                            FIND FIRST craplau WHERE   craplau.cdcooper  = craptco.cdcopant  AND
                                                       craplau.nrdconta  = craptco.nrctaant  AND
                                                       craplau.cdhistor  = craplcm.cdhistor  AND
                                                       craplau.dtdebito  = craplcm.dtmvtolt  AND
                                                       craplau.dsorigem <> "CAIXA"           AND
                                                       craplau.dsorigem <> "INTERNET"        AND
                                                       craplau.dsorigem <> "TAA"             AND
                                                       craplau.dsorigem <> "PG555"           AND
                                                       craplau.dsorigem <> "CARTAOBB"        AND
                                                       craplau.dsorigem <> "BLOQJUD"         AND
                                                       craplau.dsorigem <> "DAUT BANCOOB"    AND
                                                       craplau.nrdocmto  = 
                                            DECIMAL(ENTRY(6,SUBSTR(craplcm.cdpesqbb,6,100),"-")) 
                                                       NO-LOCK NO-ERROR.
                       END.

                   IF  NOT AVAILABLE craplau THEN
                       DO:
                           glb_cdcritic = 501.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                                             + STRING(TIME,"HH:MM:SS") + " " 
                                             + glb_cdprogra  +  "' --> '" 
                                             + glb_dscritic  + "Conta = " 
                                             + STRING(craplcm.nrdconta,"zzzz,zz9,9") 
                                             + " Documento = " + STRING(craplcm.nrdocmto)   
                                             + " >> log/proc_message.log").
                           NEXT.
                
                       END.
                   
                END.
                                            
            IF  gnconve.cdconven = 1  OR     /* OI SA (BRASIL TELECOM) */
                gnconve.cdconven = 22 OR     /* UNIMED */  
                gnconve.cdconven = 32 OR     /* UNIODONTO */
                gnconve.cdconven = 38 OR     /* UNIM.PLAN.NORTE */  
                gnconve.cdconven = 46 OR     /* UNIODONTO FEDERACAO */
                gnconve.cdconven = 47 OR     /* UNIMED CREDCREA */
                gnconve.cdconven = 48 OR     /* TIM CELULAR */
                gnconve.cdconven = 50 OR     /* HDI */ 
                gnconve.cdconven = 55 OR     /* LIBERTY */
                gnconve.cdconven = 57 OR     /* RBS - JORNAL SC */ 
                gnconve.cdconven = 58 OR     /* PORTO SEGURO */
                gnconve.cdconven = 64 OR     /* AZUL SEGUROS */ 
                gnconve.cdconven = 66 THEN   /* PREVISUL */
                DO: 
                IF  CAN-DO("31,288,505,509,553,697,834,993",
                           STRING(craplau.cdhistor)) THEN
                       FIND crapatr WHERE
                            crapatr.cdcooper = glb_cdcooper      AND
                            crapatr.nrdconta = craplcm.nrdconta  AND
                            crapatr.cdhistor = craplau.cdhistor  AND
                            crapatr.cdrefere = craplau.nrcrcard  
                            NO-LOCK NO-ERROR.
                   ELSE
                       FIND crapatr WHERE 
                            crapatr.cdcooper = glb_cdcooper     AND
                            crapatr.nrdconta = craplcm.nrdconta AND
                            crapatr.cdhistor = craplau.cdhistor AND
                            crapatr.cdrefere = craplau.nrdocmto 
                            NO-LOCK NO-ERROR.
              
                   IF  NOT AVAILABLE crapatr THEN
                       DO:
                           glb_cdcritic = 453.
                           RUN fontes/critic.p.
                           UNIX SILENT
                                VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                                + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + "Conta = " +
                                STRING(craplcm.nrdconta,"zzzz,zz9,9") +
                                " Documento = " + STRING(craplcm.nrdocmto) +
                                " >> log/proc_message.log").
                           NEXT.
                       END.

                   IF gnconve.cdconven = 1 THEN  
                      DO:
                         IF LENGTH(TRIM(STRING(crapatr.cdrefere,
                                              "zzzzzzzzzzzzzz9"))) > 11  THEN
                            DO:
                               glb_cdcritic = 654.
                               RUN fontes/critic.p.
                               UNIX SILENT
                               VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                                     + STRING(TIME,"HH:MM:SS") +
                                     " - " + glb_cdprogra + "' --> '" +
                                     glb_dscritic + "Conta = " +
                                     STRING(craplcm.nrdconta,"zzzz,zz9,9") +
                                     " Documento = " +
                                     STRING(craplcm.nrdocmto) +
                                     " >> log/proc_message.log").
                               NEXT.
                            END.
                      END.
                
                   IF gnconve.cdconven = 1 THEN 
                      aux_cdrefere = STRING(crapatr.cdrefere,"999,999,999,9").
                   ELSE
                      aux_cdrefere =
                   TRIM(STRING(crapatr.cdrefere,"zzzzzzzzzzzzzzzzzzzzzzzz9")).
                END.
            ELSE 
                DO:
                   IF  gnconve.cdconven = 9  OR
                       gnconve.cdconven = 16 OR
                       gnconve.cdconven = 24 OR
                       gnconve.cdconven = 31 OR   /* DAE Navegantes */
                       gnconve.cdconven = 33 OR   /* Aguas de Joinville */
                       gnconve.cdconven = 34 OR   /* SEMASA Itajai */
                       gnconve.cdconven = 53 OR   /* Foz do Brasil */
                       gnconve.cdconven = 54 THEN /* Aguas de Massaranduba */
                       aux_cdrefere = STRING(craplau.nrdocmto,"9999,999,9").
                   ELSE
                       ASSIGN aux_cdrefere = 
                       STRING(craplau.nrdocmto,"zzzzzzzzzzzzzzzzzzzzzzzz9").

			FIND crapatr WHERE 
				crapatr.cdcooper = glb_cdcooper     AND
				crapatr.nrdconta = craplcm.nrdconta AND
				crapatr.cdhistor = craplau.cdhistor AND
				crapatr.cdrefere = craplau.nrdocmto 
				NO-LOCK NO-ERROR.

				 IF  NOT AVAILABLE crapatr THEN
                       DO:
                           glb_cdcritic = 453.
                           RUN fontes/critic.p.
                           UNIX SILENT
                                VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                                + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + "Conta = " +
                                STRING(craplcm.nrdconta,"zzzz,zz9,9") +
                                " Documento = " + STRING(craplcm.nrdocmto) +
                                " >> log/proc_message.log").
                           NEXT.
                END.                                   
                       END.
	  
            ASSIGN aux_nrseqdig = aux_nrseqdig + 1
                   tot_vlfatura = tot_vlfatura + craplcm.vllanmto.
            
            aux_dtmvtolt_aux = STRING(YEAR(craplau.dtmvtopg),"9999") +
                               STRING(MONTH(craplau.dtmvtopg),"99") +
                               STRING(DAY(craplau.dtmvtopg),"99").

 
            IF  (gnconve.cdcooper = crabcop.cdcooper  OR
                 crabcop.cdcooper = 1                 OR
                 gnconve.flgagenc = TRUE              OR
				 crapatr.dtiniatr > date("01/09/2013")) AND
                 gnconve.cdconven <> 22               AND
                 gnconve.cdconven <> 32               AND  /*UNIODONTO*/ 
                 gnconve.cdconven <> 38               AND  /*UNIM.PLAN.NORTE*/
                 gnconve.cdconven <> 43               AND  /*SERVMED*/
                 gnconve.cdconven <> 46               AND  /*UNIODONTO FEDER.*/
                 gnconve.cdconven <> 47               AND  /*UNIMED CREDCREA*/
                 gnconve.cdconven <> 55               AND  /*LIBERTY*/
                 gnconve.cdconven <> 57               AND  /*RBS*/
                 gnconve.cdconven <> 58               THEN /*PORTO SEGURO*/
                 ASSIGN aux_cdcooperativa = " ".
            ELSE
                 ASSIGN aux_cdcooperativa = "9" + 
                                            STRING(crabcop.cdcooper,"999").

            /****** Tratamento migracao *******/     
            IF  aux_ctamigra     = TRUE  THEN
                DO:   
                   IF (craplau.cdcooper = craptco.cdcopant   OR  
                       craplau.cdcritic = 951)  THEN
                       DO:
                           IF    craptco.cdcopant = 1                 AND 
                                 gnconve.cdconven <> 22               AND
                                 gnconve.cdconven <> 32               AND  /*UNIODONTO*/ 
                                 gnconve.cdconven <> 38               AND  /*UNIM.PLAN.NORTE*/
                                 gnconve.cdconven <> 43               AND  /*SERVMED*/
                                 gnconve.cdconven <> 46               AND  /*UNIODONTO FEDER.*/
                                 gnconve.cdconven <> 47               AND  /*UNIMED CREDCREA*/
                                 gnconve.cdconven <> 55               AND  /*LIBERTY*/
                                 gnconve.cdconven <> 57               AND  /*RBS*/
                                 gnconve.cdconven <> 58               THEN /*PORTO SEGURO*/
                                 ASSIGN aux_cdcooperativa = " ".
                           ELSE
                                 ASSIGN aux_cdcooperativa = "9" + 
                                                            STRING(craptco.cdcopant,"999"). 
                           ASSIGN aux_dsobserv = "Debito migrado.".

                            /*** Verifica agencia na Cecred da coop. da conta migrada ***/
                           FIND b-crapcop WHERE b-crapcop.cdcooper = craptco.cdcopant 
                                                NO-LOCK NO-ERROR.
                           
                           IF  AVAIL b-crapcop THEN
                               ASSIGN aux_nragenci = STRING(b-crapcop.cdagectl, "9999").
                   END.
                END.

            IF   aux_cdcooperativa = " " THEN 
                 DO:
                     IF  gnconve.cdconven = 9  OR 
                         gnconve.cdconven = 74 OR 
                         gnconve.cdconven = 75 THEN
                         DO:
                             ASSIGN aux_nrdconta = STRING(craplcm.nrdconta,
                                                             "99999999999999").
                             IF aux_ctamigra AND aux_dsobserv <> "" THEN                 
                                ASSIGN aux_nrdconta = STRING(craptco.nrctaant, 
                                                             "99999999999999"). 
                         END.
                     ELSE
                         DO:
                             ASSIGN aux_nrdconta = STRING(craplcm.nrdconta,
                                                           "99999999") +  "    ".
                             IF  aux_ctamigra AND aux_dsobserv <> "" THEN                 
                                 aux_nrdconta = STRING(craptco.nrctaant, 
                                                           "99999999") +  "    ".
                         END.
                 END.
            ELSE
                 DO:
                     IF  gnconve.cdconven = 9 THEN
                         DO:
                             ASSIGN aux_nrdconta = "  " + 
                                                   STRING(aux_cdcooperativa,
                                                          "9999")  +
                                                   STRING(craplcm.nrdconta,
                                                          "99999999").
                             IF  aux_ctamigra AND aux_dsobserv <> "" THEN                 
                                 ASSIGN aux_nrdconta = "  " + 
                                                   STRING(aux_cdcooperativa,
                                                          "9999")  +
                                                   STRING(craptco.nrctaant,
                                                          "99999999").
                         END.
                     ELSE
                         DO:
                             ASSIGN aux_nrdconta = STRING(aux_cdcooperativa,
                                                          "9999")  +
                                                   STRING(craplcm.nrdconta,
                                                          "99999999").

                             IF  aux_ctamigra AND aux_dsobserv <> "" THEN                 
                                 ASSIGN aux_nrdconta = STRING(aux_cdcooperativa,
                                                          "9999")  +
                                                   STRING(craptco.nrctaant,
                                                          "99999999").
                         END.
                 END.

            
            IF  LINE-COUNTER(str_1) > 82 THEN
                DO:
                   PAGE STREAM str_1.

                   ASSIGN aux_nmempcov = gnconve.nmempres.
                   DISPLAY STREAM str_1 aux_nmarqdat
                                        aux_dtmvtopr
                                        aux_nmempcov
                                        WITH FRAME f_label.

                   DOWN STREAM str_1 WITH FRAME f_label.
                END.

            aux_cdrefere = TRIM(aux_cdrefere).

            DISPLAY STREAM str_1
                    craplcm.nrdconta 
                    aux_cdrefere  
                    craplcm.vllanmto
                    craplcm.dtmvtolt  
                    aux_dsobserv
                    WITH FRAME f_lancto.

            DOWN STREAM str_1 WITH FRAME f_lancto.

            IF  gnconve.cdconven = 30 OR     /* Celesc Distribuicao*/
                gnconve.cdconven = 45 THEN   /* Aguas Pres.Getulio */
                
                aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto,"999999999") +
                               FILL(" ",16) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt_aux,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               FILL(" ",20) + "0".
            ELSE
            IF  gnconve.cdconven = 4   OR    /* CASAN */
                gnconve.cdconven = 24  OR    /* AGUAS ITAPEMA */
                gnconve.cdconven = 31  OR    /* DAE NAVEGANTES */
                gnconve.cdconven = 33  OR    /* AGUAS JOINVILLE */
                gnconve.cdconven = 34  OR    /* SEMASA ITAJAI */
                gnconve.cdconven = 53  OR   /* Foz do Brasil */
                gnconve.cdconven = 54  THEN  /* AGUAS DE MASSARANDUBA */

                aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto,"99999999") +
                               FILL(" ",17) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               FILL(" ",20) + "0".

            ELSE
            IF  gnconve.cdconven = 48 OR    /* TIM Celular */
                gnconve.cdconven = 50 OR    /* HDI */
                gnconve.cdconven = 55 OR    /* LIBERTY */
                gnconve.cdconven = 58 OR    /* PORTO SEGURO */
                gnconve.cdconven = 66 THEN  /* PREVISUL */
                                 
                aux_dslinreg = "F" +
                               STRING(crapatr.cdrefere,"99999999999999999999")
                               + FILL(" ",5) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               STRING(aux_anovecto,"9999") +
                               STRING(aux_mesvecto,"99")   +
                               STRING(aux_diavecto,"99")   +
                               FILL(" ",12) + "0".

            ELSE
            IF  gnconve.cdconven = 47 OR    /* UNIMED CREDCREA */
                gnconve.cdconven = 57 THEN  /* RBS */

                aux_dslinreg = "F" +
                               STRING(crapatr.cdrefere,"99999999999999999") +
                               FILL(" ",8) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               STRING(aux_anovecto,"9999") +
                               STRING(aux_mesvecto,"99")   +
                               STRING(aux_diavecto,"99")   +
                               FILL(" ",12) + "0".

            ELSE
            IF  gnconve.cdconven = 22 OR     /* UNIMED */
                gnconve.cdconven = 32 OR     /* UNIODONTO */
                gnconve.cdconven = 38 OR     /* UNIM.PLAN.NORTE */ 
                gnconve.cdconven = 46 OR     /* UNIODONTO FEDERACAO */
                gnconve.cdconven = 64 THEN   /* AZUL SEGUROS */   
                aux_dslinreg = "F" +
                          STRING(crapatr.cdrefere,"9999999999999999999999999")
                               +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt,"x(08)") +
                            STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               STRING(aux_anovecto,"9999") +
                               STRING(aux_mesvecto,"99")   +
                               STRING(aux_diavecto,"99")   +
                               FILL(" ",12) + "0".
            ELSE
            IF  gnconve.cdconven = 15   THEN /* VIVO */

                aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto,"99999999999") +
                               FILL(" ",14) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt_aux,"x(08)") +
                            STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               FILL(" ",20) + "0".

            ELSE
            IF  gnconve.cdconven = 9  OR    /*SAMAE Jaragua*/
                gnconve.cdconven = 19 OR    /*SAMAE Gaspar */
                gnconve.cdconven = 20 OR    /*SAMAE Blumenau CECRED*/
                gnconve.cdconven = 16 OR    /*SAMAE Timbo CECRED*/
                gnconve.cdconven = 49 THEN  /*SAMAE Rio Negrinho*/
                aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto,"999999") +
                               FILL(" ",19) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt_aux,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               FILL(" ",20) + "0".
            ELSE
            IF  gnconve.cdconven = 1  OR /* BRASIL TELECOM/SC */
                gnconve.cdconven = 25 OR /* SAMAE BRUSQUE */
                gnconve.cdconven = 26 OR /* SAMAE POMERODE */
                gnconve.cdconven = 33 OR /* AGUAS DE JOINVILLE */
                gnconve.cdconven = 39 OR /* SEGURO AUTO */
                gnconve.cdconven = 41 OR /* SAMAE SAO BENTO */
                gnconve.cdconven = 43 OR /* SERVMED */
                gnconve.cdconven = 62 THEN /* AGUAS DE ITAPOCOROY */ 
                aux_dslinreg = "F" +
                             STRING(craplau.nrdocmto, "9999999999") +
                             FILL(" ", 15) + 
                             STRING(aux_nragenci, "9999")  +
                             STRING(aux_nrdconta, "x(14)") + 
                             STRING(aux_dtmvtolt, "x(8)")  + 
                             STRING(craplcm.vllanmto * 100,"999999999999999")
                             + "00" +
                             STRING(craplau.cdseqtel, "x(60)") + 
                             STRING(aux_anovecto, "x(4)")  +
                             STRING(aux_mesvecto, "x(2)")  +
                             STRING(aux_diavecto, "x(2)")  +
                             FILL(" ", 12) +
                             "0".
            ELSE
            IF  gnconve.cdconven = 74 OR /* MAPFRE VERA CRUZ SEG */
                gnconve.cdconven = 75 THEN
                aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto)
                               + FILL(" ",25 - LENGTH(STRING(craplau.nrdocmto)))  +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"99999999999999") +
                               STRING(aux_dtmvtolt,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               FILL(" ",20) + "0".
            ELSE
                 aux_dslinreg = "F" +
                               STRING(craplau.nrdocmto,"9999999999999999999999")
                               + FILL(" ",3) +
                               STRING(aux_nragenci,"9999") +
                               STRING(aux_nrdconta,"x(14)") +
                               STRING(aux_dtmvtolt,"x(08)") +
                               STRING((craplcm.vllanmto * 100),"999999999999999")
                               + "00" +
                               STRING(craplau.cdseqtel,"x(60)") +
                               STRING(aux_anovecto,"9999") +
                               STRING(aux_mesvecto,"99")   +
                               STRING(aux_diavecto,"99")   +
                               FILL(" ",12) + "0".



            PUT STREAM str_2 aux_dslinreg FORMAT "x(150)" SKIP.

            /* Cria Registro unificado */
            IF  gnconve.flgcvuni   THEN
                DO:
                    CREATE gncvuni.
                    ASSIGN gncvuni.cdcooper = crabcop.cdcooper
                           gncvuni.cdconven = gnconve.cdconven
                           gncvuni.dtmvtolt = glb_dtmvtolt
                           gncvuni.flgproce = FALSE
                           gncvuni.nrseqreg = aux_nrseqdig
                           gncvuni.dsmovtos = aux_dslinreg
                           gncvuni.tpdcontr = 2. /* Tipo Deb.Autom.*/
                    VALIDATE gncvuni.
                END.  

        END.  /* For each craplcm */ 

        ASSIGN aux_nrsequni = aux_nrseqdig.

        FOR EACH crapndb WHERE crapndb.cdcooper = glb_cdcooper      AND
                               crapndb.dtmvtolt = glb_dtmvtolt      AND
                               crapndb.cdhistor = gnconve.cdhisdeb  NO-LOCK:

            IF  aux_flgfirst THEN
                DO:
                   RUN nomeia_arquivos.

                   OUTPUT STREAM str_2 TO VALUE("arq/" + aux_nmarqdat).

                   PUT STREAM str_2
                       "A2"  
                       aux_nrconven  FORMAT "99999999999999999999"
                       aux_nmempcov  FORMAT "x(20)" 
                       aux_nrdbanco  FORMAT "999"
                       aux_nmdbanco  FORMAT "x(20)"
                       aux_dtmvtolt  FORMAT "x(08)"
                       aux_nrseqarq  FORMAT "999999"
                       "04DEBITO AUTOMATICO" 
                       FILL(" ",52)  FORMAT "x(52)" SKIP.

                   aux_flgfirst = FALSE.
                END.

            
            IF  gnconve.cdconven = 19 THEN

                aux_dslinreg = STRING(SUBSTR(crapndb.dstexarq,1,127),"x(127)") +
                               FILL(" ",22) + "0".

            ELSE
            IF  gnconve.cdconven = 4 OR   
                gnconve.cdconven = 15 OR /** VIVO **/
                gnconve.cdconven = 16 OR
                gnconve.cdconven = 45 OR /** Aguas Pres.Getulio **/
                gnconve.cdconven = 50 OR /** HDI **/
                gnconve.cdconven = 9  OR 
                gnconve.cdconven = 74 OR 
                gnconve.cdconven = 75 THEN
                aux_dslinreg = STRING(crapndb.dstexarq,"x(150)").
            ELSE
                /* Gravar o gncvuni */
                aux_dslinreg = STRING(SUBSTR(crapndb.dstexarq,1,129),"x(129)") +
                               STRING(aux_anovecto, "x(4)")  +
                               STRING(aux_mesvecto, "x(2)")  +
                               STRING(aux_diavecto, "x(2)")  +
                               FILL(" ",12) + "0".



            PUT STREAM str_2 aux_dslinreg FORMAT "x(150)" SKIP.

            /* Cria Registro unificado */
            IF   gnconve.flgcvuni   THEN
              DO:

                 /* Contador para o gncvuni */
                 ASSIGN aux_nrsequni = aux_nrsequni + 1.

                 CREATE gncvuni.
                 ASSIGN gncvuni.cdcooper = crapndb.cdcooper
                        gncvuni.cdconven = gnconve.cdconven
                        gncvuni.dtmvtolt = glb_dtmvtolt
                        gncvuni.flgproce = FALSE
                        gncvuni.nrseqreg = aux_nrsequni
                        gncvuni.dsmovtos = aux_dslinreg
                        gncvuni.tpdcontr = 2. /* Tipo Deb.Autom.*/
                 VALIDATE gncvuni.
            END.


            ASSIGN aux_nrseqndb = aux_nrseqndb + 1
                   aux_vllanmto = DECIMAL(SUBSTRING(crapndb.dstexarq,53,15))
                   aux_vllanmto = aux_vllanmto / 100
                   aux_vlfatndb = aux_vlfatndb + aux_vllanmto.

        END.  /* For each crapndb */

        IF gnconve.flggeraj = TRUE THEN
           DO:         
               
               FOR EACH gnarqrx WHERE gnarqrx.cdconven = gnconve.cdconven AND
                                      gnarqrx.flgretor = FALSE
                                      EXCLUSIVE-LOCK :

                   /** Entra se houver somente registros tipo "J" **/
                   IF  aux_flgfirst THEN    
                       DO:
                            RUN nomeia_arquivos.     

                            OUTPUT STREAM str_2 TO VALUE(aux_nmarqped).
                       
                            PUT STREAM str_2
                                    "A2"  
                                    aux_nrconven  FORMAT "99999999999999999999"
                                    aux_nmempcov  FORMAT "x(20)" 
                                    aux_nrdbanco  FORMAT "999"
                                    aux_nmdbanco  FORMAT "x(20)"
                                    aux_dtmvtolt  FORMAT "x(08)"
                                    aux_nrseqarq  FORMAT "999999"
                                    "04DEBITO AUTOMATICO" 
                                    FILL(" ",52)  FORMAT "x(52)" SKIP.
                       
                            ASSIGN  aux_flgfirst = FALSE.          
                       END.
           
                   ASSIGN aux_dtgerarq = STRING(gnarqrx.dtgerarq,"99999999")
                          aux_dtgerarq = (SUBSTR(aux_dtgerarq,5,4) + 
                                         SUBSTR(aux_dtgerarq,3,2) +
                                         SUBSTR(aux_dtgerarq,1,2))
                          aux_dtintarq = STRING(gnarqrx.dtmvtolt,"99999999")
                          aux_dtintarq = (SUBSTR(aux_dtintarq,5,4) +
                                         SUBSTR(aux_dtintarq,3,2) +
                                         SUBSTR(aux_dtintarq,1,2)).
                    
                   PUT STREAM str_2
                       "J"
                       gnarqrx.nrsequen          FORMAT "999999"
                       aux_dtgerarq              FORMAT "99999999" 
                       gnarqrx.qtregarq          FORMAT "999999"
                       (gnarqrx.vltotarq  * 100) FORMAT "99999999999999999" 
                       aux_dtintarq              FORMAT "99999999"
                       FILL(" ",104)             FORMAT "x(104)"
                       SKIP.
                   
                   ASSIGN gnarqrx.flgretor = TRUE
                          aux_nrseqret = aux_nrseqret + 1.
                   
               END.
           END.


        IF  NOT aux_flgfirst THEN
            DO:
                                                
               ASSIGN tot_vltarifa = aux_nrseqdig * aux_vltarifa
                      tot_vlapagar = tot_vlfatura - tot_vltarifa.

               IF  aux_flgrelat  THEN
                   DO:
                      IF  LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 10) THEN
                          DO:
                             PAGE STREAM str_1.

                             ASSIGN aux_nmempcov = gnconve.nmempres.
                             DISPLAY STREAM str_1 
                                     aux_nmarqdat
                                     aux_dtmvtopr
                                     aux_nmempcov
                                     WITH FRAME f_label.

                             DOWN STREAM str_1 WITH FRAME f_label.

                          END.

                      DISPLAY STREAM str_1
                              aux_nrseqdig
                              tot_vlfatura
                              tot_vltarifa 
                              tot_vlapagar WITH FRAME f_total.

                      DOWN STREAM str_1 WITH FRAME f_total.

                      VIEW STREAM str_1 FRAME f_final.

                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              aux_nmcidade[1]
                              aux_nmcidade[2]
                              aux_nmempres
                              WITH FRAME f_cabec.

                      DOWN STREAM str_1 WITH FRAME f_cabec.              
                      DISPLAY STREAM str_1
                              aux_nrseqdig
                              tot_vlfatura
                              tot_vltarifa
                              tot_vlapagar WITH FRAME f_total.

                      DOWN STREAM str_1 WITH FRAME f_total.

                      DISPLAY STREAM str_1
                              aux_dtmvtopr
                              aux_nmarqdat 
                              rel_nmrescop[1] 
                              rel_nmrescop[2]
                              WITH FRAME f_coop.

                      OUTPUT STREAM str_1 CLOSE.
                                         
                      ASSIGN glb_nrcopias = 1
                             glb_nmformul = "80d".
                   
                      ASSIGN aux_nmarqrel = "rl/crrl350_c" +  
                                             STRING(gnconve.cdconven,"9999") +
                                            ".lst".
                      
                      ASSIGN glb_nmarqimp = aux_nmarqrel.
                                 
                      RUN fontes/imprim.p.   
                                        
                   END.

               ASSIGN aux_nrseqtot = aux_nrseqdig + aux_nrseqndb + aux_nrseqret
                      aux_vltotarq = tot_vlfatura + aux_vlfatndb.

               PUT STREAM str_2
                     "Z" (aux_nrseqtot + 2) FORMAT "999999"
                     (aux_vltotarq * 100)   FORMAT "99999999999999999"
                     FILL(" ",126) FORMAT "x(126)" SKIP.

               OUTPUT STREAM str_2 CLOSE.
                             
               RUN atualiza_controle.

            END.  /* Fim do flgfirst */
    
    END. /* for each gnconve */
                  
END. /* for each gncvcop */
                  
RUN fontes/fimprg.p.                                

PROCEDURE p_divinome:
/******* Divide o campo crabcop.nmextcop em duas Strings *******/
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crabcop.nmextcop)," ") / 2
                        rel_nmrescop = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crabcop.nmextcop)," "):
     IF   aux_contapal <= aux_qtpalavr   THEN
          rel_nmrescop[1] = rel_nmrescop[1] +   
                      (IF TRIM(rel_nmrescop[1]) = "" THEN "" ELSE " ") 
                           + ENTRY(aux_contapal,crabcop.nmextcop," ").
     ELSE
          rel_nmrescop[2] = rel_nmrescop[2] +
                           (IF TRIM(rel_nmrescop[2]) = "" THEN "" ELSE " ") +
                           ENTRY(aux_contapal,crabcop.nmextcop," ").
  END.  /*  Fim DO .. TO  */ 
           
  ASSIGN rel_nmrescop[1] = 
           FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) + rel_nmrescop[1]
           rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
           rel_nmrescop[2].

END PROCEDURE.


PROCEDURE nomeia_arquivos.

   FIND gncontr  WHERE
        gncontr.cdcooper = crabcop.cdcooper     AND
        gncontr.tpdcontr = 4                    AND /* Debito Automatico */
        gncontr.cdconven = gnconve.cdconven     AND
        gncontr.dtmvtolt = glb_dtmvtolt NO-ERROR.

   IF  AVAIL gncontr THEN
       ASSIGN aux_nrseqarq = gncontr.nrsequen.               
   ELSE                                         
       RUN obtem_atualiza_sequencia.                     
        
   ASSIGN aux_nmdbanco = crapcop.nmrescop.
   
   ASSIGN  aux_nrdbanco = gnconve.cddbanco
           aux_nragenci = STRING(crabcop.cdagectl, "9999")
           aux_nrconven = gnconve.nrcnvfbr
           aux_nmempcov = gnconve.nmempres
           aux_vltarifa = gnconve.vltrfdeb.

   IF  gnconve.cdconven = 4 THEN   /* CASAN */
       ASSIGN aux_nragenci = '1294'.

   ASSIGN  aux_nrsequen = STRING(aux_nrseqarq,"999999").

   /*--  Padrao 
   IF  SUBSTR(gnconve.nmarqdeb,5,2)  = "MM" AND
       SUBSTR(gnconve.nmarqdeb,7,2)  = "DD" AND
       SUBSTR(gnconve.nmarqdeb,10,3) = "SEQ" THEN 
   --*/   

   ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqdeb,1,4)) +
                          STRING(MONTH(glb_dtmvtolt),"99")   +
                          STRING(DAY(glb_dtmvtolt),"99")     +  "." +
                          SUBSTR(aux_nrsequen,4,3) .
   
   IF  SUBSTR(gnconve.nmarqdeb,5,2)  = "MM" AND
       SUBSTR(gnconve.nmarqdeb,7,2)  = "DD" AND
       SUBSTR(gnconve.nmarqdeb,10,3) = "TXT" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqdeb,1,4)) +            
                              STRING(MONTH(glb_dtmvtolt),"99")   +
                              STRING(DAY(glb_dtmvtolt),"99")     + "." +
                              "txt".
  
   IF  SUBSTR(gnconve.nmarqdeb,5,2)  = "DD" AND
       SUBSTR(gnconve.nmarqdeb,7,2)  = "MM" AND
       SUBSTR(gnconve.nmarqdeb,10,3) = "RET" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqdeb,1,4)) +   
                              STRING(DAY(glb_dtmvtolt),"99")     +
                              STRING(MONTH(glb_dtmvtolt),"99")   + "." +
                              "ret".
 
   IF  SUBSTR(gnconve.nmarqdeb,5,2)  = "CP" AND   /* Cooperativa */
       SUBSTR(gnconve.nmarqdeb,7,2)  = "MM" AND
       SUBSTR(gnconve.nmarqdeb,9,2)  = "DD" AND
       SUBSTR(gnconve.nmarqdeb,12,3) = "SEQ" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqdeb,1,4)) +
                              STRING(gnconve.cdcooper,"99")      +
                              STRING(MONTH(glb_dtmvtolt),"99")   +
                              STRING(DAY(glb_dtmvtolt),"99")     +
                              "." +  SUBSTR(aux_nrsequen,4,3).
                                    
   IF  SUBSTR(gnconve.nmarqdeb,4,1)  = "C" AND
       SUBSTR(gnconve.nmarqdeb,5,4)  = "SEQU" AND
       SUBSTR(gnconve.nmarqdeb,10,3) = "RET" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqdeb,1,3)) +
                              STRING(gnconve.cdcooper,"9")       +
                              SUBSTR(aux_nrsequen,3,4) + "."     +
                              "ret".
         
    ASSIGN  aux_nmarqped = "arq/" + aux_nmarqdat.
       
END PROCEDURE.


PROCEDURE obtem_atualiza_sequencia.

    DO TRANSACTION:

        /* Verificar arquivo controle - se existir nao somar seq. */

        DO WHILE TRUE:

           FIND gbconve WHERE RECID(gbconve) = RECID(gnconve)
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE gbconve   THEN
                IF   LOCKED gbconve  THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " "
                                           + STRING(TIME,"HH:MM:SS") + " - " 
                                           + glb_cdprogra + "' --> '" 
                                           + glb_dscritic + " >> log/proc_message.log").
                         UNDO, RETURN.
                      END.
           LEAVE.
              
       END. /* do while true */    
         
       ASSIGN aux_nrseqarq = gbconve.nrseqatu.

       IF   NOT gbconve.flgcvuni   THEN
            ASSIGN gbconve.nrseqatu = gbconve.nrseqatu + 1.

       /*** Nao cria registro de controle se convenio for unificado e a 
            execucao for na Cecred, pois quando roda programa que faz a 
            unificacao nao atualiza a sequencia do convenio  ***/
       IF  (glb_cdcooper <> 3         OR  
            gnconve.flgcvuni = FALSE) THEN
            DO:
               CREATE gncontr.
               ASSIGN gncontr.cdcooper = crabcop.cdcooper    
                      gncontr.tpdcontr = 4                
                      gncontr.cdconven = gnconve.cdconven 
                      gncontr.dtmvtolt = glb_dtmvtolt 
                      gncontr.nrsequen = aux_nrseqarq.
               VALIDATE gncontr.
            END.

       RELEASE gbconve.

   END.
END PROCEDURE.        
 


PROCEDURE atualiza_controle.
  

 IF NOT gnconve.flgcvuni   THEN DO:

   IF  gnconve.tpdenvio = 1 OR     /* Internet */ 
       gnconve.tpdenvio = 2 THEN  /* E-Sales */
       DO:
          RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT
          SET b1wgen0011.
          
           /* faz ux2dos */
          RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                              INPUT aux_nmarqped,
                                              INPUT aux_nmarqdat).
           
          /* Buscar arquivo convertido e enviar para o connect/esales */ 
          IF  gnconve.tpdenvio = 2 THEN  /* E-Sales */
              UNIX SILENT VALUE("cp " + "converte/" + aux_nmarqdat + " /usr/connect/esales/envia/").
             
       END.       

   IF  gnconve.tpdenvio = 3 THEN  /* Nexxera */
       DO:
          UNIX SILENT VALUE("cp " + aux_nmarqped + " /usr/nexxera/envia/").
       END.               
   
   IF  gnconve.tpdenvio = 5 THEN  /* Accestage */     
       DO:
          UNIX SILENT VALUE("cp " + aux_nmarqped + " salvar").
       END.
   ELSE
       UNIX SILENT VALUE("mv " + aux_nmarqped + " salvar " + "2> /dev/null").
   
   IF  gnconve.tpdenvio = 6 THEN  /* WebServices */
     DO:
       
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
       
       /* Efetuar a chamada a rotina Oracle  */
       RUN STORED-PROCEDURE pc_armazena_arquivo_conven
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT gnconve.cdconven,
                                                INPUT glb_dtmvtolt,
                                                INPUT 'F', /* Retorno a empresa */
												INPUT 0, /* Nao retornado ainda */
                                                INPUT '/usr/coop/' + crabcop.dsdircop + '/salvar', 
                                                INPUT SUBSTR(aux_nmarqped,R-INDEX(aux_nmarqped,'/') + 1),
                                                OUTPUT 0, 
                                                OUTPUT "").

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_armazena_arquivo_conven
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

       /* Busca possíveis erros */
       IF pc_armazena_arquivo_conven.pr_cdretorn <> 202 THEN
          DO:
             UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " "
                               + STRING(TIME,"HH:MM:SS") + " - " 
                               + glb_cdprogra + "' --> '" 
                               + pc_armazena_arquivo_conven.pr_dsmsgret + " - Convenio: "
                               + STRING(gncvcop.cdconven) + " >> log/proc_message.log").
          END.
     END.
  
   IF  gnconve.tpdenvio = 1 THEN DO: /* Internet */
   
       ASSIGN aux_nroentries = NUM-ENTRIES(gnconve.dsenddeb).
                
       ASSIGN aux_contador   = 1.
    
       DO WHILE aux_contador LE aux_nroentries:
    
           ASSIGN aux_dsdemail = TRIM(ENTRY(aux_contador,gnconve.dsenddeb)).
    
           IF   TRIM(aux_dsdemail) = ""   THEN
               DO:
                   aux_contador = aux_contador + 1.
                   NEXT.
               END.
           
           RUN enviar_email IN b1wgen0011 
                                      (INPUT glb_cdcooper,
                                       INPUT glb_cdprogra,
                                       INPUT aux_dsdemail,
                                       INPUT "ARQUIVO DEBITO AUTOMATICO " +
                                             "DA" + crabcop.nmrescop,
                                       INPUT aux_nmarqdat,
                                       INPUT TRUE).
                                      
           ASSIGN aux_contador = aux_contador + 1.
       END.     
    
       DELETE PROCEDURE b1wgen0011.

   END.
              
 END. /* FIM IF NOT gnconve.flgcvuni*/
 ELSE
   UNIX SILENT VALUE("mv " + aux_nmarqped + " salvar " + "2> /dev/null").

 
 /*** Nao atualiza registro de controle se convenio for unificado e a 
      execucao for na Cecred, pois quando roda programa que faz a 
      unificacao, nao atualiza a sequencia do convenio  ***/
 IF  (glb_cdcooper <> 3         OR  
      gnconve.flgcvuni = FALSE) THEN
      DO:
           ASSIGN gncontr.dtcredit = aux_dtmvtopr
                  gncontr.nmarquiv = aux_nmarqdat
                  gncontr.qtdoctos = aux_nrseqdig
                  gncontr.vldoctos = tot_vlfatura
                  gncontr.vltarifa = tot_vltarifa
                  gncontr.vlapagar = tot_vlapagar.                 
      END. 
       
   RELEASE gncontr.
     
END PROCEDURE. 


/* .......................................................................... */
