/*..............................................................................

   Programa: Fontes/crps395.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Maio/2004                         Ultima atualizacao: 17/07/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 82 ordem 84. 
               Solicitar a emissao de Novos Cartoes, 2 via de cartoes e senhas.
               Emite relatorio 355

   Alteracoes: 18/06/2004 - So efetua a solicitacao da 2 via se o cartao
                            estiver em uso (Julio).
                            
               20/12/2004 - Alterando o programa para rodar duas vezes por 
                            semana (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               31/03/2006 - Correcao na abertura do STREAM str_1. (Julio)

               04/10/2006 - Alterado texto do destino do relatorio para
                            ADMINISTRATIVO/FINANCEIRO (Elton).

               20/11/2006 - Envio de email pela BO b1wgen0011 (David).
               
               23/11/2006 - Acerto no envio de email e copiar anexo do email
                            para o diretorio salvar (David).

               11/12/2006 - Envio de email para makelly@cecred.coop.br e 
                            rosangela@cecred.coop.br (David).

               04/05/2007 - Enviar email para willian@cecred.coop.br e retirar
                            o email rosangela@cecred.coop.br (David).

               08/04/2008 - Enviar email para everton@cecred.coop.br,
                            carla@cecred.coop.br e david@cecred.coop.br
                           (Gabriel).

               01/09/2008 - Implementar solicitacao de 2via de senha (David).

               17/10/2008 - Acerto na condicao para obter solicitacoes de 2 via
                            de senha (David).

               26/02/2009 - Utilizar somente o campo crapadc.dsdemail para 
                            para envio de e-mail (David).
               
               22/04/2009 - Passado novos parametros para o script
                            "Pedido2vCartao.pl" e passado informacoes da
                            Credifiesc quando for cooperativa "6" (Elton).
                            
               07/07/2009 - Alterado endereco para remessa de cartoes da
                            Transpocred (Diego).
                            
               28/10/2010 - Unificar programas de geracao de relatorios e 
                            arquivos (crps382.p e crps395.p) - (Joao-RKAM).

               28/12/2010 - Ajuste no formato do Numero do Cartao
                            (9999,9999,9999,9999) Irlan.
                            
               24/01/2011 - Ajuste no programa para atender o novo layout
                            de cartões do Bradesco Cecred Visa.
                            Ajuste nos scripts "PedidoDeCartao.pl" e
                            "Pedido2vCartao.pl" para gerar o arquivo .xls
                            com as novas informações.
                            Criado o script "Pedido2vsCartao.pl" para
                            não alterar a rotina de solicitação de 
                            2a via de senha (Isara - RKAM).
                            
               14/03/2011 - Substituir dsdemail da ass para a crapcem (Gabriel)             
               
               17/06/2011 - Alteração no tratamento do limite de compra e saque
                            em dolar para solicitacao de novos cartoes.
                            (Irlan)
                            
               23/08/2011 - Incluir coluna Dia do Vencimento no rel. e na 
                            planilha (Ze).
                            
               28/09/2011 - Enviar e-mail para todas as datas de débito.
                            (Isara - RKAM)
                            
               20/10/2011 - Retirar data do débito dos arquivos de 
                            2 via de cartão e senha.
                          - Ajuste nos scripts "Pedido2vDeCartao.pl" e
                            "Pedido2vsCartao.pl" para não mostrar a 
                            data do débito.
                            (Isara - RKAM) 
                            
               28/10/2011 - Para solicitação de novos cartões criar uma única 
                            planilha por administradora, independente do dia 
                            de débito.
                          - Inserir uma coluna na planilha com o dia do débito.  
                          - Retirar no cabeçalho do arquivo a linha referente
                            ao dia de débito. 
                          - Ajuste no script "PedidoDeCartao.pl".
                            (Isara - RKAM) 
                            
               16/11/2011 - Realizado alteracao para que o valor de saques e 
                            compras em dolar, seja o mesmo valor que o real
                            (Adriano). 
                            
               24/01/2012 - Quando for Segunda Via de Cartao e motivo Mudança 
                            Data Vencimento, enviar no arquivo a informação
                            contida no campo crawcrd.dddebant.
                            (Isara - RKAM)
                            
               01/02/2012 - Para o relatorio,
                            quando for Segunda Via de Cartao e motivo Mudança 
                            Data Vencimento, enviar no arquivo a informação
                            contida no campo crawcrd.dddebant.
                            (Tiago).             
                            
               01/06/2012 - Criado campo 'Limite de credito' no arquivo de 
                            exportacao (Tiago).
                            
               20/06/2012 - Incluir novas informacoes no arquivos gerados
                            (Gabriel)             
                            
               10/07/2012 - Para geração de arquivo foi alterado campo nmtitcrd 
                            para nmextttl na coluna "Nome completo - Cliente" 
                            (Guilherme Maba).
                            
               02/08/2012 - Rodar diariamente na solicitacao 82 (Diego)
                          - Retirado tratamento para cooperativas 6 e 9 ref.
                            dados apresentados no cabecalho do arquivo
                           (Diego).
                           
               10/08/2012 - Enviar endereco para a 2a via de senha (Gabriel)
               
               14/02/2013 - Incluso geracao critica conforme solicitacao softdesk
                            42560 (Daniel). 
                            
               22/02/2013 - Alterado testo critica "CONTA -->" para "CONTA ="
                            (Daniel).     
                            
               26/02/2013 - Retirado RETURN na critica 018 e 251 e incluso NEXT
                            (Daniel).         
               
               18/04/2013 - Nao enviar as propostas aprovadas de novos cartoes
                            para a Bradesco. (Irlan)
                            
               12/06/2013 - Descomentada a procedure Atualiza_Sit_Cred para
                            liberar solicitações dos cartões bradesco. (Carlos)
                            
               26/06/2013 - Na procedure Atualiza_Sit_Cred, trocado o insitcrd 
                            de 2 (solicitado) para insitcrd 3 (liberado),
                            Softdesk 71086 (Daniel). 
                            
               24/07/2013 - Ajustado processo geracao arquivo de cartoes 
                            solicitados para usar insitcrd = 3 (Daniel). 
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).          
               
               02/01/2014 - Retirado comando unix relativo a fila de impressao
                            (Tiago).
                            
               07/01/2014 - Retirado critica do log quanto a solcitacao
                            de cartao e impresso no rel355 para controle
                            da cooperativa (Tiago).
               
               15/05/2014 - Alterado o LIKE da crapass para a gnetcvl do campo 
                            dsestcvl da tt-crawcrd, tt-crawcri e aux_dsestcvl 
                            (Douglas - Chamado 131253)
               
               04/02/2015 - Alterado rotina para não trazer os Cartões-Cecred
                            SD 250562 (Odirlei-AMcom)
               
               08/01/2015 - Ajuste na restrição para não trazer os Cartões-Cecred
                            SD 250562 (Odirlei-AMcom) 

				15/02/2017 - Ajustando o format do campo nrctrcrd nos relatórios que o utilizam.
			     		     SD 594718 (Kelvin).

			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

              19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                           PRJ339 - CRM (Odirlei-AMcom)             
                           
              17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)                

..............................................................................*/

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.

{ includes/var_batch.i }

/******************************************************************************/
/*************************** Definicoes de TEMP-TABLE's ***********************/
DEFINE TEMP-TABLE tt-crawcrd NO-UNDO
    FIELD cdcooper LIKE crawcrd.cdcooper
    FIELD cdagenci LIKE crawcrd.cdagenci
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD tppessoa AS CHARACTER FORMAT "!!" /* PF/PJ */
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd 
    FIELD nmextttl LIKE crawcrd.nmextttl
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD dtnasccr LIKE crawcrd.dtnasccr
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD cdlimcrd LIKE crawcrd.cdlimcrd
    FIELD tpcartao LIKE crawcrd.tpcartao
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD dtpropos LIKE crawcrd.dtpropos
    FIELD dtsol2vi LIKE crawcrd.dtsol2vi
    FIELD cdmotivo LIKE crawcrd.cdmotivo
    FIELD dsmotivo AS CHARACTER FORMAT "x(20)"
    FIELD dt2viasn LIKE crawcrd.dt2viasn
    FIELD vllimite AS DECIMAL
    FIELD vldsaque AS DECIMAL
    FIELD vlsaqdol AS DECIMAL
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD nrcepend AS CHARACTER
    FIELD cdufende LIKE crapenc.cdufende
    FIELD tpimpres AS CHARACTER
    FIELD cdsexotl AS CHARACTER
    FIELD dsdemail LIKE crapcem.dsdemail
    FIELD dsestcvl LIKE gnetcvl.dsestcvl
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD nmmaettl LIKE crapttl.nmmaettl
    FIELD complend LIKE crapenc.complend
    FIELD nrtelefo AS CHARACTER
    FIELD nrdoccrd LIKE crawcrd.nrdoccrd
    FIELD cdoedptl AS CHARACTER
    FIELD nrendere LIKE crapenc.nrendere
    FIELD idseqimp AS INTEGER
    FIELD dddebant LIKE crawcrd.dddebant. /* 2VIA/SENHAOLICIT */

DEFINE TEMP-TABLE tt-crawcri NO-UNDO
    FIELD cdcooper LIKE crawcrd.cdcooper
    FIELD cdagenci LIKE crawcrd.cdagenci
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD tppessoa AS CHARACTER FORMAT "!!" /* PF/PJ */
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd 
    FIELD nmextttl LIKE crawcrd.nmextttl
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD dtnasccr LIKE crawcrd.dtnasccr
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD cdlimcrd LIKE crawcrd.cdlimcrd
    FIELD tpcartao LIKE crawcrd.tpcartao
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD dtpropos LIKE crawcrd.dtpropos
    FIELD dtsol2vi LIKE crawcrd.dtsol2vi
    FIELD cdmotivo LIKE crawcrd.cdmotivo
    FIELD dsmotivo AS CHARACTER FORMAT "x(20)"
    FIELD dt2viasn LIKE crawcrd.dt2viasn
    FIELD vllimite AS DECIMAL
    FIELD vldsaque AS DECIMAL
    FIELD vlsaqdol AS DECIMAL
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD nrcepend AS CHARACTER
    FIELD cdufende LIKE crapenc.cdufende
    FIELD tpimpres AS CHARACTER
    FIELD cdsexotl AS CHARACTER
    FIELD dsdemail LIKE crapcem.dsdemail
    FIELD dsestcvl LIKE gnetcvl.dsestcvl
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD nmmaettl LIKE crapttl.nmmaettl
    FIELD complend LIKE crapenc.complend
    FIELD nrtelefo AS CHARACTER
    FIELD nrdoccrd LIKE crawcrd.nrdoccrd
    FIELD cdoedptl AS CHARACTER
    FIELD nrendere LIKE crapenc.nrendere
    FIELD idseqimp AS INTEGER
    FIELD dddebant LIKE crawcrd.dddebant /* 2VIA/SENHAOLICIT */
    FIELD tpsolici AS CHAR. 


/******************************************************************************/
/*************************** Definicoes de Variaveis **************************/
DEF VAR b1wgen0011   AS HANDLE                                         NO-UNDO.

DEF VAR aux_fl2viasn AS LOGI                                           NO-UNDO.
DEF VAR aux_fl2viacr AS LOGI                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_arqxlscr AS CHAR                                           NO-UNDO.
DEF VAR aux_arqxlssn AS CHAR                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR rel_nmadmcrd LIKE crapadc.nmadmcrd                             NO-UNDO.
DEF VAR rel_cdagecta LIKE crapadc.cdagecta                             NO-UNDO.
DEF VAR rel_nrctacor LIKE crapadc.nrctacor                             NO-UNDO.
DEF VAR rel_nrdigcta LIKE crapadc.nrdigcta FORMAT "9"                  NO-UNDO.
DEF VAR rel_cddigage LIKE crapadc.cddigage FORMAT "9"                  NO-UNDO.
DEF VAR rel_nmextcop LIKE crapcop.nmextcop                             NO-UNDO.
DEF VAR rel_nmrescop AS CHAR FORMAT "X(20)"                            NO-UNDO.
DEF VAR rel_nrdocnpj LIKE crapcop.nrdocnpj                             NO-UNDO.
                                                
DEF VAR rel_dslocdat AS CHAR FORMAT "x(80)"                            NO-UNDO.
DEF VAR rel_nmressbr AS CHAR FORMAT "x(60)" EXTENT 2                   NO-UNDO.
DEF VAR rel_nmresadm AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR rel_dsgravar AS CHAR FORMAT "x(20)"                            NO-UNDO. 
DEF VAR rel_dsmtvo2v AS CHAR FORMAT "x(16)"                            NO-UNDO. 
DEF VAR rel_dssolici AS CHAR FORMAT "x(80)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmempres AS CHAR                                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL      ",
                                   "EMPRESTIMOS    ","DIGITACAO    ",
                                   "GENERICO       "]                  NO-UNDO.
                                     
DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.

DEF VAR rel_dsendere AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR rel_nrendcop AS CHAR FORMAT "x(6)"                             NO-UNDO.
DEF VAR rel_bairrcop AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmcidcop AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR rel_cdufdcop AS CHAR FORMAT "x(2)"                             NO-UNDO.
DEF VAR rel_nrcepcop AS CHAR FORMAT "x(10)"                            NO-UNDO.

DEF VAR aux_fill     AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE FORMAT "99/99/99"                         NO-UNDO.
                                                            
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_sgnviacr AS INT                                            NO-UNDO.
DEF VAR aux_sgnviasn AS INT                                            NO-UNDO.
                                                            
DEF VAR aux_qtdcrsol AS INT                                            NO-UNDO.
DEF VAR aux_regexist AS LOGI                                           NO-UNDO.
DEF VAR aux_nmadmlog AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR aux_qtdemail AS INTE                                           NO-UNDO.
DEF VAR aux_dsarqath AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.                                                                 
                                                                 
DEF VAR tot_qtaprova AS INTE                                           NO-UNDO.
DEF VAR aux_dddebito LIKE crawcrd.dddebito                             NO-UNDO.
DEF VAR aux_admcarta AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                        NO-UNDO.

/******************************************************************************/
/*********************************** FORM'S ***********************************/

FORM SKIP
     rel_dslocdat  
     SKIP(3)
     WITH COLUMN 1 NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo_355.

FORM rel_dssolici
     SKIP(2)
     WITH COLUMN 1 NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo_355_1.

FORM rel_nmresadm AT 01 LABEL "ADMINISTRADORA"
     SKIP(1)
     WITH SIDE-LABELS WIDTH 80 FRAME f_administ_355.

/* Segunda via de cartoes */
FORM tt-crawcrd.cdagenci AT 11 FORMAT "zz9"        LABEL "PA"
     tt-crawcrd.nrdconta                           LABEL "CONTA/DV"
     tt-crawcrd.tppessoa       FORMAT "x(2)"       LABEL "TIPO"
     tt-crawcrd.nmtitcrd       FORMAT "x(30)"      LABEL "NOME"
     tt-crawcrd.dsmotivo       FORMAT "x(20)"      LABEL "MOTIVO"
     aux_dtmvtolt              FORMAT "99/99/99"   LABEL "DATA"
     aux_dddebito              FORMAT "99"         LABEL "DEBITO"
     aux_fill                  FORMAT "x(30)"      LABEL "OBSERVACAO" 
     SKIP(1)
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_lanctos_355.

/* Segunda via de senha */
FORM tt-crawcrd.cdagenci AT 11  FORMAT "zz9"       LABEL "PA"
     tt-crawcrd.nrdconta                           LABEL "CONTA/DV"
     tt-crawcrd.tppessoa        FORMAT "x(2)"      LABEL "TIPO"
     tt-crawcrd.nmtitcrd        FORMAT "x(30)"     LABEL "NOME"
     aux_dtmvtolt               FORMAT "99/99/99"  LABEL "DATA"
     aux_fill                   FORMAT "x(40)"     LABEL "OBSERVACAO" 
     SKIP(1)
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_lanctos2_355.

/* Solicitacao de Cartao */
FORM tt-crawcrd.cdagenci AT 10  FORMAT "zz9"            LABEL "PA"
     tt-crawcrd.nrdconta                                LABEL "CONTA/DV"
     tt-crawcrd.tppessoa        FORMAT "x(2)"           LABEL "TIPO"
     tt-crawcrd.nmtitcrd        FORMAT "x(29)"          LABEL "NOME"
     tt-crawcrd.vllimite        FORMAT "zzz,zzz,zz9.99" LABEL "LIMITE"
     tt-crawcrd.dddebito        FORMAT "99"             LABEL "DEBITO"
     tt-crawcrd.nrctrcrd        FORMAT "zzz,zzz,zz9"        LABEL "PROPOSTA"
     tt-crawcrd.dtpropos        FORMAT "99/99/99"       LABEL "DATA"
     tt-crawcrd.dddebito        FORMAT "99"             LABEL "DEBITO"
     aux_fill                   FORMAT "x(30)"          LABEL "OBSERVACAO"
     SKIP(1)
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_lanctos3_355.

FORM SKIP(4)
     "CONFERIDO POR: ________-______________________________________________"
     SKIP
     "CADASTRO" AT 16
     "VISTO ( CECRED )" AT 37
     SKIP(3)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_assina_355.

FORM SKIP(2)
     aux_contador LABEL "QUANTIDADE DE SEGUNDA VIA DE SENHAS SOLICITADAS" AT 10 
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_qtd_sol.

FORM SKIP(2)
     aux_contador LABEL "QUANTIDADE DE SEGUNDA VIA DE CARTOES SOLICITADOS" AT 10  
     SKIP(2)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_qtd2_sol.

FORM SKIP(2)
     aux_contador LABEL "QUANTIDADE DE CARTOES SOLICITADOS" AT 10
     SKIP(2)
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_final_355.

FORM SKIP(4)
     "QUANTIDADE DE CARTOES SOLICITADOS:"                AT 10
     tot_qtaprova                                        AT 60        
     "QUANTIDADE DE SEGUNDA VIA DE CARTOES SOLICITADOS:" AT 10
     aux_sgnviacr                                        AT 60
     "QUANTIDADE DE SEGUNDA VIA DE SENHAS SOLICITADAS:"  AT 10 
     aux_sgnviasn                                        AT 60
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_sol.

FORM SKIP(2)
     "RELATORIO DE CRITICAS:"
     SKIP(2)
     WITH NO-BOX WIDTH 132 FRAME f_critica_tit.

FORM tt-crawcri.nrdconta                    COLUMN-LABEL "CONTA/DV"
     tt-crawcri.tpsolici   FORMAT "x(30)"   COLUMN-LABEL "TIPO SOLICITACAO"
     aux_dscritic          FORMAT "x(40)"   COLUMN-LABEL "CRITICA"
     WITH NO-BOX WIDTH 132 FRAME f_critica.

/******************************************************************************/

/******************************************************************************/
/******************************* BLOCO PRINCIPAL ******************************/
&SCOPED-DEFINE TrataErro IF RETURN-VALUE = "NOK" THEN LEAVE Princ.
&SCOPED-DEFINE TrataErroInt IF RETURN-VALUE = "NOK" THEN RETURN "NOK".

Princ: DO ON ERROR UNDO Princ, LEAVE Princ:
  
  RUN Inicia_Programa. {&TrataErro} /*Executar rotinas p/ inicializar         */
  RUN Busca_Dados.     {&TrataErro} /*Buscar dados e "Popular" Temp-Table     */
  RUN Exporta_Dados.   {&TrataErro} /*Gerar arqs e enviar e-mails p/ Bancos   */
  RUN Imprime_Dados.   {&TrataErro} /*Imprimir dados Temp-Table               */
  
END.

RELEASE craptab NO-ERROR.

RUN fontes/fimprg.p.

/******************************************************************************/
/***************************** FIM - BLOCO PRINCIPAL **************************/

/******************************************************************************/
/********************************* FUNCOES ************************************/

/******************************************************************************/
/* Funcao para retornar dados do Associado/Cooperado */ 
FUNCTION Busca_Dados_Assoc RETURNS CHARACTER /* Tp.Pessoa: Fisica ou Juridica */
    (INPUT  par_nrdconta AS INTEGER,  /* Nr. Conta     */
     OUTPUT par_cdagenci AS INTEGER,  /* PA           */
     OUTPUT par_cdsitdct AS INTEGER): /* Cod.Sit.Conta */

  FOR FIRST crapass FIELDS(inpessoa cdagenci cdsitdct) 
      WHERE crapass.cdcooper = glb_cdcooper   AND
            crapass.nrdconta = par_nrdconta
            NO-LOCK:

      ASSIGN par_cdagenci = crapass.cdagenci
             par_cdsitdct = crapass.cdsitdct.

      CASE crapass.inpessoa:
          WHEN 1 THEN RETURN "PF".
          WHEN 2 OR 
          WHEN 3 THEN RETURN "PJ".
          OTHERWISE RETURN "??".
      END CASE.
  END. /* FOR FIRST crapass */

  IF   NOT AVAIL crapass   THEN
       DO:
           RUN Gera_Critica(251, "CONTA = " +
                                STRING(par_nrdconta,"zzzz,zz9,9")).
           RETURN "NOK".
       END.

END FUNCTION. /* Busca_Dados_Assoc */
/******************************************************************************/

/******************************************************************************/
FUNCTION Retira_Caracteres RETURN CHAR(INPUT par_string   AS CHARACTER,
                                       INPUT par_listacar AS CHARACTER):

  DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.

  DO aux_contador = 1 TO NUM-ENTRIES(par_listacar,";") 
      ON ERROR UNDO, RETURN "NOK":

      ASSIGN par_string = REPLACE(par_string,
                                  ENTRY(aux_contador,par_listacar,";"),"").

  END.

  RETURN par_string.
  
END. /* Retira_Caracteres */
/******************************************************************************/

/******************************************************************************/
/****************************** FIM - FUNCOES *********************************/

/******************************************************************************/
/******************************* PROCEDURES ***********************************/

/******************************************************************************/
PROCEDURE Inicia_Programa:
  
  DEF VAR aux_nmmesano AS CHAR EXTENT 12 INIT
                                         [" JANEIRO ","FEVEREIRO",
                                          "  MARCO  ","  ABRIL  ",
                                          "  MAIO   ","  JUNHO  ",
                                          " JULHO   "," AGOSTO  ",
                                          "SETEMBRO "," OUTUBRO ",
                                          "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.

  ASSIGN glb_cdprogra = "crps395".

  RUN fontes/iniprg.p.

  IF  glb_cdcritic > 0  THEN
      RETURN "NOK".
                                  
  ASSIGN aux_dtmvtolt = glb_dtmvtolt
         aux_fill     = FILL("_",40).

  /* Busca dados da cooperativa */
  FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE crapcop   THEN 
       DO: 
           RUN Gera_Critica(651,"").
           RETURN "NOK".
       END.

  RUN p_divinome.
  
  FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                     craptab.nmsistem = "CRED"       AND
                     craptab.tptabela = "GENERI"     AND
                     craptab.cdempres = 11           AND
                     craptab.cdacesso = "CONTR2VCRD" AND
                     craptab.tpregist = 0            
                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

  IF   NOT AVAILABLE craptab   THEN
       DO: 
           IF  LOCKED craptab   THEN
               DO:
                   RUN Gera_Critica(0,
                       "Registro [craptab] em uso por outro usuario!").
               END.
           ELSE
               DO:
                   RUN Gera_Critica(55,"").
               END.
       
           RETURN "NOK".
       END.
  
  FOR EACH crapadc WHERE crapadc.cdcooper = glb_cdcooper NO-LOCK:

      ASSIGN aux_admcarta = aux_admcarta + STRING(crapadc.cdadmcrd, "999") + 
                            ",".
  END. /*   Fim do FOR EACH crapadc   */
       
  ASSIGN rel_dslocdat = TRIM(crapcop.nmcidade) + ", " + 
                        STRING(DAY(glb_dtmvtopr),"99") + 
                        " DE " + TRIM(aux_nmmesano[MONTH(glb_dtmvtopr)]) + 
                        " DE " + STRING(YEAR(glb_dtmvtopr),"9999") + ".".

  RUN Atualiza_Sit_Cred.

  IF   RETURN-VALUE = "NOK"   THEN
       RETURN "NOK".

END PROCEDURE. /* Inicia_Programa */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Busca_Dados:
    
  &SCOPED-DEFINE Campos-2VIA cdcooper nrdconta nmtitcrd nrcrcard cdadmcrd cdlimcrd tpcartao dddebito cdmotivo nrcpftit dtnasccr nrctrcrd dtpropos nrdoccrd cdgraupr dddebant 

  &SCOPED-DEFINE Campos-Solic cdcooper nrdconta nmtitcrd nrcrcard cdadmcrd cdlimcrd tpcartao dddebito cdmotivo nrcpftit dtnasccr nrctrcrd dtpropos nrdoccrd cdgraupr
    
  DEF VAR aux_tppessoa AS CHAR                                         NO-UNDO.
  DEF VAR aux_cdsitdct AS INTE                                         NO-UNDO.
  DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
  DEF VAR aux_contador AS INTE                                         NO-UNDO.
  DEF VAR aux_nrtelefo AS CHAR                                         NO-UNDO.
  DEF VAR aux_dsendere LIKE crapenc.dsendere                           NO-UNDO.
  DEF VAR aux_cdsexotl AS CHAR                                         NO-UNDO.
  DEF VAR aux_cdoedttl AS CHAR                                         NO-UNDO.
  DEF VAR aux_dsnacion LIKE crapnac.dsnacion                           NO-UNDO.
  DEF VAR aux_nmmaettl LIKE crapttl.nmmaettl                           NO-UNDO.
  DEF VAR aux_dsestcvl LIKE gnetcvl.dsestcvl                           NO-UNDO.
  DEF VAR aux_cdgraupr LIKE crawcrd.cdgraupr                           NO-UNDO.
  DEF VAR h-b1wgen0060 AS HANDLE                                       NO-UNDO.

  /** Solicitacao de 2a. via de cartao e senha p/ administradoras **/
  FOR EACH crawcrd FIELDS({&Campos-2VIA} dtsol2vi dt2viasn nmextttl) NO-LOCK 
     WHERE crawcrd.cdcooper = glb_cdcooper            AND
           /* nao trazer os cartoes cecred - Cabal */
          (crawcrd.cdadmcrd < 10                      OR  
           crawcrd.cdadmcrd > 80                     )AND  
          (crawcrd.dt2viasn > DATE(craptab.dstextab)  OR
           crawcrd.dtsol2vi > DATE(craptab.dstextab)) AND 
          (crawcrd.insitcrd = 4  /* em uso */         OR
           crawcrd.insitcrd = 7) /* Dt.Ven */
     BREAK BY crawcrd.cdcooper 
           BY crawcrd.cdadmcrd 
           BY crawcrd.tpcartao
           BY crawcrd.dddebito
           BY crawcrd.cdlimcrd
           BY crawcrd.nmtitcrd ON ERROR UNDO, LEAVE:  
     
      ASSIGN aux_tppessoa = Busca_Dados_Assoc(INPUT  crawcrd.nrdconta,
                                              OUTPUT aux_cdagenci,
                                              OUTPUT aux_cdsitdct).

      IF   aux_tppessoa = "NOK"   THEN
           RETURN "NOK".
      
      IF   aux_cdsitdct <> 1 AND aux_cdsitdct <> 6   THEN
      DO:
           CREATE tt-crawcri.
           BUFFER-COPY crawcrd USING {&Campos-2VIA} dtsol2vi nmextttl TO tt-crawcri.
           ASSIGN tt-crawcri.tpsolici = "2 VIA CARTAO".
           NEXT.
      END.

      IF   FIRST-OF(crawcrd.dddebito)   THEN
           DO:
               IF   NOT(CAN-FIND(FIRST craptlc 
                                 WHERE craptlc.cdcooper = glb_cdcooper      AND
                                       craptlc.cdadmcrd = crawcrd.cdadmcrd  AND
                                       craptlc.dddebito = crawcrd.dddebito  AND
                                       craptlc.tpcartao = 0                 AND
                                       craptlc.cdlimcrd = 0  
                                       NO-LOCK))   THEN
                    DO:
                        RUN Gera_Critica(544,"   CONTA = " +
                                        STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
                        RETURN "NOK".
                    END.
           END. /* FIRST-OF(crawcrd.dddebito) */

      IF   FIRST-OF(crawcrd.cdlimcrd)   THEN
           DO:
               FOR FIRST craptlc FIELDS(vllimcrd) 
                   WHERE craptlc.cdcooper = glb_cdcooper      AND
                         craptlc.cdadmcrd = crawcrd.cdadmcrd  AND
                         craptlc.tpcartao = crawcrd.tpcartao  AND
                         craptlc.cdlimcrd = crawcrd.cdlimcrd  AND
                         craptlc.dddebito = 0   
                         NO-LOCK: END.

               IF   NOT AVAILABLE craptlc   THEN
                    DO:
                        RUN Gera_Critica(532,"  CONTA = " +
                                       STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
                        RETURN "NOK".
                    END.
           END. /* FIRST-OF(crawcrd.cdlimcrd) */

      /*Dados do Endereço*/
      FOR FIRST crapenc FIELDS(dsendere nrendere nmbairro nmcidade 
                               nrcepend cdufende complend tpendass)
          WHERE crapenc.cdcooper = glb_cdcooper     AND
                crapenc.nrdconta = crawcrd.nrdconta AND
                crapenc.idseqttl = 1                AND
                crapenc.cdseqinc = 1                NO-LOCK: 

          /* 9 - Residencial */
          /* 10 - Comercial  */
          CASE tpendass:
              WHEN 9 THEN
                  aux_dsendere = crapenc.dsendere.
              WHEN 10 THEN
                  aux_dsendere = crapenc.dsendere.
          END CASE.
          
      END.

      IF   NOT AVAIL crapenc   THEN
           DO:
               RUN Gera_Critica(0,
                                "Registro [crapenc] nao encontrado: CONTA = "
                                + STRING(tt-crawcrd.nrdconta,"zzzz,zz9,9")).
           END.

      IF crawcrd.cdgraupr = 5 OR 
         crawcrd.cdgraupr = 6 THEN 
      DO:

          aux_cdgraupr = IF crawcrd.cdgraupr = 5 THEN 1 ELSE 2.

          FIND LAST crapttl no-lock
              WHERE crapttl.cdcooper = crawcrd.cdcooper
                AND crapttl.nrdconta = crawcrd.nrdconta
                AND crapttl.idseqttl = aux_cdgraupr
                AND crapttl.nrcpfcgc = crawcrd.nrcpftit NO-ERROR.
          IF AVAIL crapttl THEN 
          DO:
              ASSIGN aux_cdsexotl = IF crapttl.cdsexotl = 1 THEN "M" ELSE "F"
                         aux_nmmaettl = crapttl.nmmaettl.

              /* Buscar nacionalidade */
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapttl.cdnacion
                   NO-LOCK NO-ERROR.
              
              IF  AVAILABLE crapnac THEN
                ASSIGN aux_dsnacion = crapnac.dsnacion.
              ELSE     
                ASSIGN aux_dsnacion = "".    

              IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                  RUN sistema/generico/procedures/b1wgen0060.p 
                      PERSISTENT SET h-b1wgen0060.

              DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                               INPUT crapttl.cdestcvl,
                               INPUT "dsestcvl",
                               OUTPUT aux_dsestcvl,
                               OUTPUT glb_dscritic).

              IF  VALID-HANDLE(h-b1wgen0060) THEN
                  DELETE PROCEDURE h-b1wgen0060.
              
              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.
              
              ASSIGN aux_cdoedttl = "".
              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT crapttl.idorgexp,
                                  OUTPUT aux_cdoedttl,
                                  OUTPUT glb_cdcritic, 
                                  OUTPUT glb_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.               
          
          END.
          ELSE
                  ASSIGN aux_cdsexotl = ""
                     aux_cdoedttl = ""
                     aux_dsnacion = ""
                     aux_nmmaettl = ""
                     aux_dsestcvl = "".
      END.
      ELSE
          ASSIGN aux_cdsexotl = ""
                 aux_cdoedttl = ""
                 aux_dsnacion = ""
                 aux_nmmaettl = ""
                 aux_dsestcvl = "".           

      FOR FIRST crapass FIELDS (inpessoa)
          WHERE crapass.cdcooper = glb_cdcooper
            AND crapass.nrdconta = crawcrd.nrdconta NO-LOCK: END.

      aux_nrtelefo = "".
      telefone:
      DO aux_contador = 1 TO 4:
          FOR FIRST craptfc FIELDS (tptelefo nrtelefo nrdddtfc)
              WHERE craptfc.cdcooper = glb_cdcooper     
                AND craptfc.nrdconta = crawcrd.nrdconta 
                AND craptfc.idseqttl = 1 
                AND craptfc.tptelefo = aux_contador NO-LOCK:

              /* 1 - Residencial */
              /* 2 - Celular     */
              /* 3 - Comercial   */
              /* 4 - Contato     */
              CASE aux_tppessoa:
                  WHEN "PF" THEN 
                  DO:
                      CASE tptelefo:
                          WHEN 1 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.

                          WHEN 2 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.

                          WHEN 4 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.
                      END CASE.
                  END.

                  WHEN "PJ" THEN 
                  DO:
                      CASE tptelefo:
                          WHEN 3 THEN 
                          DO:
                              aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                              LEAVE telefone.
                          END.
                      END CASE.
                  END.
              END CASE.
          END.
      END.

      /* Criar Registro - Segunda Via do Cartao */
      IF   crawcrd.dtsol2vi > DATE(craptab.dstextab)   THEN
           DO:
          
           CREATE tt-crawcrd.
           BUFFER-COPY crawcrd USING {&Campos-2VIA} dtsol2vi nmextttl TO tt-crawcrd
           ASSIGN tt-crawcrd.cdagenci = aux_cdagenci
                  tt-crawcrd.tpimpres = "2VIA"
                  tt-crawcrd.idseqimp = 2
                  tt-crawcrd.tppessoa = aux_tppessoa
                  tt-crawcrd.vllimite = craptlc.vllimcrd
                  tt-crawcrd.vldsaque = (tt-crawcrd.vllimite / 2)
                  tt-crawcrd.vlsaqdol = tt-crawcrd.vldsaque
                  tt-crawcrd.dsendere = REPLACE(SUBSTRING(aux_dsendere,1,33),",","") 
                  tt-crawcrd.nrendere = crapenc.nrendere                        WHEN AVAIL crapenc
                  tt-crawcrd.dsendere = Retira_Caracteres(tt-crawcrd.dsendere,
                                                          ".;/;-;:;=")
                  tt-crawcrd.nmbairro = Retira_Caracteres(crapenc.nmbairro,".") WHEN AVAIL crapenc
                  tt-crawcrd.nmcidade = Retira_Caracteres(crapenc.nmcidade,
                                                          ".;-;,")              WHEN AVAIL crapenc
                  tt-crawcrd.nrcepend = STRING(crapenc.nrcepend, "zzzzzzz9")    WHEN AVAIL crapenc
                  tt-crawcrd.cdufende = crapenc.cdufende                        WHEN AVAIL crapenc
                  tt-crawcrd.cdsexotl = aux_cdsexotl
                  tt-crawcrd.dsdemail = "cartoes@cecred.coop.br"                                       
                  tt-crawcrd.dsestcvl = aux_dsestcvl
                  tt-crawcrd.dsnacion = aux_dsnacion                            
                  tt-crawcrd.nmmaettl = aux_nmmaettl                            
                  tt-crawcrd.complend = crapenc.complend                        WHEN AVAIL crapenc
                  tt-crawcrd.nrtelefo = aux_nrtelefo
                  tt-crawcrd.cdoedptl = aux_cdoedttl.    

           CASE tt-crawcrd.cdmotivo:
               WHEN 1 THEN ASSIGN tt-crawcrd.dsmotivo = "Danificado".
               WHEN 2 THEN ASSIGN tt-crawcrd.dsmotivo = "Roubo/Perda".
               WHEN 5 THEN ASSIGN tt-crawcrd.dsmotivo = "Mudanca de Nome".
               WHEN 7 THEN ASSIGN tt-crawcrd.dsmotivo = 
                                            "Mudanca Data Vencimento".
           END CASE.
      END.
      /* FIM do Criar Registro - Segunda Via do Cartao */

      /* Criar Registro - Segunda Via de Senha */
      IF   crawcrd.dt2viasn > DATE(craptab.dstextab)    THEN 
           DO:
           CREATE tt-crawcrd.
           BUFFER-COPY crawcrd USING {&Campos-2VIA} dt2viasn TO tt-crawcrd
           ASSIGN tt-crawcrd.cdagenci = aux_cdagenci
                  tt-crawcrd.tpimpres = "SENHA"
                  tt-crawcrd.idseqimp = 3 
                  tt-crawcrd.tppessoa = aux_tppessoa
                  tt-crawcrd.dsmotivo = "2a. Via de Senha"
                  tt-crawcrd.dsendere = REPLACE(SUBSTRING(aux_dsendere,1,33),",","") 
                  tt-crawcrd.dsendere = Retira_Caracteres(tt-crawcrd.dsendere,
                                                          ".;/;-;:;=")
                  tt-crawcrd.nrendere = crapenc.nrendere WHEN AVAIL crapenc
                  tt-crawcrd.complend = crapenc.complend WHEN AVAIL crapenc
                  tt-crawcrd.nmbairro = Retira_Caracteres(crapenc.nmbairro,".") 
                                                         WHEN AVAIL crapenc
                  tt-crawcrd.nmcidade = Retira_Caracteres(crapenc.nmcidade,
                                                          ".;-;,") 
                                                         WHEN AVAIL crapenc
                  tt-crawcrd.cdufende = crapenc.cdufende WHEN AVAIL crapenc
                  tt-crawcrd.nrcepend = STRING(crapenc.nrcepend,"zzzzzzz9")  
                                                         WHEN AVAIL crapenc.
      END.
      /* FIM do Criar Registro - Segunda Via de Senha */
      
  END. /** Fim do FOR EACH crawcrd **/

  /** Solicitacao de cartoes p/ administradoras **/
  FOR EACH crawcrd FIELDS({&Campos-Solic} nmextttl)
     WHERE crawcrd.cdcooper = glb_cdcooper    AND
           /* nao trazer os cartoes cecred - Cabal */
          (crawcrd.cdadmcrd < 10              OR  
           crawcrd.cdadmcrd > 80             )AND  
          (crawcrd.insitcrd = 3               OR
           crawcrd.insitcrd = 7) /* Dt.Ven */ AND
           crawcrd.dtsolici = glb_dtmvtolt    NO-LOCK
      BREAK BY crawcrd.cdcooper 
            BY crawcrd.cdadmcrd 
            BY crawcrd.tpcartao 
            BY crawcrd.dddebito
            BY crawcrd.cdlimcrd
            BY crawcrd.nmtitcrd ON ERROR UNDO, LEAVE:

      IF   FIRST-OF(crawcrd.dddebito)   THEN
           DO:
               IF   NOT(CAN-FIND(FIRST craptlc 
                                 WHERE craptlc.cdcooper = glb_cdcooper      AND
                                       craptlc.cdadmcrd = crawcrd.cdadmcrd  AND
                                       craptlc.dddebito = crawcrd.dddebito  AND
                                       craptlc.tpcartao = 0                 AND
                                       craptlc.cdlimcrd = 0  
                                       NO-LOCK))   THEN
                    DO:
                        RUN Gera_Critica(544,"   CONTA = " +
                                        STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
                        RETURN "NOK".
                    END.
           END. /* FIRST-OF(crawcrd.dddebito) */

      IF   FIRST-OF(crawcrd.cdlimcrd)   THEN
           DO:
               FOR FIRST craptlc FIELDS(vllimcrd) 
                   WHERE craptlc.cdcooper = glb_cdcooper      AND
                         craptlc.cdadmcrd = crawcrd.cdadmcrd  AND
                         craptlc.tpcartao = crawcrd.tpcartao  AND
                         craptlc.cdlimcrd = crawcrd.cdlimcrd  AND
                         craptlc.dddebito = 0   
                         NO-LOCK: END.

               IF   NOT AVAILABLE craptlc   THEN
                    DO:
                        RUN Gera_Critica(532,"  CONTA = " +
                                       STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
                        RETURN "NOK".
                    END.
           END. /* FIRST-OF(crawcrd.cdlimcrd) */

      ASSIGN aux_tppessoa = Busca_Dados_Assoc(INPUT  crawcrd.nrdconta,
                                              OUTPUT aux_cdagenci,
                                              OUTPUT aux_cdsitdct).

      IF   aux_tppessoa = "NOK"   THEN
           RETURN "NOK".

      IF   aux_cdsitdct <> 1 AND aux_cdsitdct <> 6   THEN
      DO:
           CREATE tt-crawcri.
           BUFFER-COPY crawcrd USING {&Campos-Solic} nmextttl TO tt-crawcri.
           ASSIGN tt-crawcri.tpsolici = "SOLICITACAO CARTAO".
           NEXT.
      END.

      FOR FIRST crapenc FIELDS(dsendere nrendere nmbairro nmcidade 
                               nrcepend cdufende complend tpendass)
          WHERE crapenc.cdcooper = glb_cdcooper     AND
                crapenc.nrdconta = crawcrd.nrdconta AND
                crapenc.idseqttl = 1                AND
                crapenc.cdseqinc = 1 NO-LOCK: 

          /* 9 - Residencial */
          /* 10 - Comercial  */
          CASE tpendass:
              WHEN 9 THEN
                  aux_dsendere = crapenc.dsendere.
              WHEN 10 THEN
                  aux_dsendere = crapenc.dsendere.
          END CASE.

      END.

      IF   NOT AVAIL crapenc   THEN
           DO:
               RUN Gera_Critica(0,
                                "Registro [crapenc] nao encontrado: CONTA = "
                                + STRING(tt-crawcrd.nrdconta,"zzzz,zz9,9")).
           END.

      IF crawcrd.cdgraupr = 5 OR 
         crawcrd.cdgraupr = 6 THEN 
      DO:

          aux_cdgraupr = IF crawcrd.cdgraupr = 5 THEN 1 ELSE 2.

          FIND LAST crapttl no-lock
              WHERE crapttl.cdcooper = crawcrd.cdcooper
                AND crapttl.nrdconta = crawcrd.nrdconta
                AND crapttl.idseqttl = aux_cdgraupr
                AND crapttl.nrcpfcgc = crawcrd.nrcpftit NO-ERROR.
          IF AVAIL crapttl THEN 
          DO:
              ASSIGN aux_cdsexotl = IF crapttl.cdsexotl = 1 THEN "M" ELSE "F"
                         aux_nmmaettl = crapttl.nmmaettl.

              /* Buscar nacionalidade */
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapttl.cdnacion
                   NO-LOCK NO-ERROR.
              
              IF  AVAILABLE crapnac THEN
                ASSIGN aux_dsnacion = crapttl.dsnacion.
              ELSE     
                ASSIGN aux_dsnacion = "".
                
              IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                  RUN sistema/generico/procedures/b1wgen0060.p 
                      PERSISTENT SET h-b1wgen0060.

              DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                               INPUT crapttl.cdestcvl,
                               INPUT "dsestcvl",
                               OUTPUT aux_dsestcvl,
                               OUTPUT glb_dscritic).

              IF  VALID-HANDLE(h-b1wgen0060) THEN
                  DELETE PROCEDURE h-b1wgen0060.
                  
              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

              ASSIGN aux_cdoedttl = "".
              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT crapttl.idorgexp,
                                  OUTPUT aux_cdoedttl,
                                  OUTPUT glb_cdcritic, 
                                  OUTPUT glb_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.       
                  
                  
          END.
          ELSE
                  ASSIGN aux_cdsexotl = ""
                     aux_cdoedttl = ""
                     aux_dsnacion = ""
                     aux_nmmaettl = ""
                     aux_dsestcvl = "".
      END.
      ELSE
          ASSIGN aux_cdsexotl = ""
                 aux_cdoedttl = ""
                 aux_dsnacion = ""
                 aux_nmmaettl = ""
                 aux_dsestcvl = "".           

      FOR FIRST crapass FIELDS (inpessoa)
          WHERE crapass.cdcooper = glb_cdcooper
            AND crapass.nrdconta = crawcrd.nrdconta NO-LOCK: END.

      aux_nrtelefo = "".
      telefone:
      DO aux_contador = 1 TO 4:
          FOR FIRST craptfc FIELDS (tptelefo nrtelefo nrdddtfc)
              WHERE craptfc.cdcooper = glb_cdcooper     
                AND craptfc.nrdconta = crawcrd.nrdconta 
                AND craptfc.idseqttl = 1 
                AND craptfc.tptelefo = aux_contador NO-LOCK:

              /* 1 - Residencial */
              /* 2 - Celular     */
              /* 3 - Comercial   */
              /* 4 - Contato     */
              CASE aux_tppessoa:
                  WHEN "PF" THEN 
                  DO:
                      CASE tptelefo:
                          WHEN 1 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.

                          WHEN 2 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.

                          WHEN 4 THEN 
                          DO:
                              IF craptfc.nrtelefo > 0 THEN 
                              DO:
                                  aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                                  LEAVE telefone.
                              END.
                          END.
                      END CASE.
                  END.

                  WHEN "PJ" THEN 
                  DO:
                      CASE tptelefo:
                          WHEN 3 THEN 
                          DO:
                              aux_nrtelefo = string(craptfc.nrdddtfc) + string(craptfc.nrtelefo).
                              LEAVE telefone.
                          END.
                      END CASE.
                  END.
              END CASE.
          END.
      END.

      CREATE tt-crawcrd.
      BUFFER-COPY crawcrd USING {&Campos-Solic} nmextttl TO tt-crawcrd
      ASSIGN tt-crawcrd.cdagenci = aux_cdagenci
             tt-crawcrd.tpimpres = "SOLICIT"
             tt-crawcrd.idseqimp = 1
             tt-crawcrd.tppessoa = aux_tppessoa 
             tt-crawcrd.vllimite = craptlc.vllimcrd
             tt-crawcrd.vldsaque = (tt-crawcrd.vllimite / 2)
             tt-crawcrd.vlsaqdol = tt-crawcrd.vldsaque
             tt-crawcrd.dsendere = REPLACE(SUBSTRING(aux_dsendere,1,33),",","") 
             tt-crawcrd.nrendere = crapenc.nrendere
             tt-crawcrd.dsendere = Retira_Caracteres(tt-crawcrd.dsendere,
                                                     ".;/;-;:;=")
             tt-crawcrd.nmbairro = Retira_Caracteres(crapenc.nmbairro,".")
             tt-crawcrd.nmcidade = Retira_Caracteres(crapenc.nmcidade,
                                                     ".;-;,")
             tt-crawcrd.nrcepend = STRING(crapenc.nrcepend, "zzzzzzz9")
             tt-crawcrd.cdufende = crapenc.cdufende
             tt-crawcrd.cdsexotl = aux_cdsexotl  
             tt-crawcrd.dsdemail = "cartoes@cecred.coop.br"                                      
             tt-crawcrd.dsestcvl = aux_dsestcvl                           
             tt-crawcrd.dsnacion = aux_dsnacion                           
             tt-crawcrd.nmmaettl = aux_nmmaettl                           
             tt-crawcrd.complend = crapenc.complend WHEN AVAIL crapenc
             tt-crawcrd.nrtelefo = aux_nrtelefo
             tt-crawcrd.cdoedptl = aux_cdoedttl. 
  END. /** Fim do FOR EACH crawcrd **/

  RETURN.

END PROCEDURE. /* Busca_Dados */
/******************************************************************************/

/******************************************************************************/
/* Busca dados da Cooperativa e Adm. Credito */
PROCEDURE Busca_Dados_Coop:
  DEFINE INPUT  PARAMETER par_cdadmcrd AS INTEGER     NO-UNDO.
  DEFINE INPUT  PARAMETER par_tpimpres AS CHARACTER   NO-UNDO.

  DEF VAR aux_cdcooper AS INTE                        NO-UNDO.

  DEFINE BUFFER b-crapcop FOR crapcop.

  ASSIGN aux_cdcooper = glb_cdcooper.

  FOR FIRST crapadc FIELDS(nmadmcrd nrctacor nrdigcta cdagecta 
                           cddigage dsdemail ) 
      WHERE crapadc.cdcooper = glb_cdcooper   AND
            crapadc.cdadmcrd = par_cdadmcrd 
            NO-LOCK: END.

  IF   NOT AVAILABLE crapadc  THEN
       DO:
           RUN Gera_Critica(605,"  Cod.Adm.Cred. = " + STRING(par_cdadmcrd)).
           RETURN "NOK".
       END.

  IF   par_tpimpres = "SOLICIT"   THEN
       DO:
           IF   INDEX(aux_admcarta, STRING(par_cdadmcrd, "999")) = 0 THEN
                DO:
                    RUN fontes/fimprg.p.
                    RETURN "NOK".
                END.
       END.
  
  ASSIGN aux_cdcooper = 3.

  /* Busca dados da cooperativa */
  FIND b-crapcop WHERE b-crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE b-crapcop   THEN 
       DO: 
           RUN Gera_Critica(651,"").
           RETURN "NOK".
       END.

  ASSIGN rel_nmadmcrd = crapadc.nmadmcrd
         rel_nrctacor = crapadc.nrctacor
         rel_nrdigcta = crapadc.nrdigcta
         rel_cdagecta = crapadc.cdagecta
         rel_cddigage = crapadc.cddigage
         rel_dsgravar = b-crapcop.nmrescop
         rel_nmextcop = b-crapcop.nmextcop
         rel_nmrescop = b-crapcop.nmrescop
         rel_nrdocnpj = b-crapcop.nrdocnpj
         rel_dsendere = b-crapcop.dsendcop
         rel_nrendcop = STRING(b-crapcop.nrendcop)
         rel_bairrcop = b-crapcop.nmbairro
         rel_nmcidcop = b-crapcop.nmcidade
         rel_cdufdcop = b-crapcop.cdufdcop
         rel_nrcepcop = STRING(b-crapcop.nrcepend).

  IF   LOOKUP(par_tpimpres,"2VIA,SENHA") <> 0   THEN
       DO:
           IF   par_cdadmcrd = 3   THEN
                DO:

                    IF   rel_nmrescop = "CECRED"   THEN
                         ASSIGN rel_dsgravar = rel_dsgravar + 
                                               STRING(glb_cdcooper,"99").

                    ASSIGN aux_arqxlscr = "CECRED2v_" 
                           aux_arqxlssn = "CECRED2vs_".
                END.
                ELSE
                    ASSIGN aux_arqxlscr = rel_nmrescop + "2v_"
                           aux_arqxlssn = rel_nmrescop + "2vs_".

                ASSIGN aux_arqxlscr = aux_arqxlscr                     +
                                      STRING(b-crapcop.cdcooper,"99")  +
                                      STRING(par_cdadmcrd,"99")        +
                                      STRING(DAY(glb_dtmvtolt),"99")   + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + 
                                      STRING(YEAR(glb_dtmvtolt),"9999")
                       aux_arqxlssn = aux_arqxlssn                     + 
                                      STRING(b-crapcop.cdcooper,"99")  +
                                      STRING(par_cdadmcrd,"99")        +
                                      STRING(DAY(glb_dtmvtolt),"99")   + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + 
                                      STRING(YEAR(glb_dtmvtolt),"9999").

       END. /* "2VIA,SENHA" */

  RETURN.

END PROCEDURE. /* Busca_Dados_Coop */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Exporta_Dados:
  /* -> gerar arquivos separadamente p/ envio de e-mail's;
     -> Preparar rotina p/ gerar informacoes separadas por Bancos; */
    
  /* Gerar e enviar arquivos de solicitacao de 2a. via para administradoras */
  FOR EACH tt-crawcrd WHERE LOOKUP(tt-crawcrd.tpimpres,"2VIA,SENHA") <> 0 
                      BREAK BY tt-crawcrd.cdadmcrd
                            BY tt-crawcrd.dddebito
                            BY tt-crawcrd.cdlimcrd ON ERROR UNDO, LEAVE:

      IF  FIRST-OF(tt-crawcrd.cdadmcrd) THEN
          DO:
              /* Busca dados da Cooperativa e Adm. Credito */
              RUN Busca_Dados_Coop(INPUT tt-crawcrd.cdadmcrd,
                                   INPUT tt-crawcrd.tpimpres). {&TrataErroInt}
              /* Abre arquivos */
              RUN Gera_Arquivo("ABRE_ARQ","","str_1,str_2").
              /* Gera informacoes do cabecalho */
              RUN Gera_Arquivo("EXPORTA",
                               rel_nmextcop                           + "|"  + 
                               rel_dsgravar                           + "|"  + 
                               STRING(rel_nrdocnpj)                   + "|"  +
                               rel_dsendere                           + ", " + 
                               rel_nrendcop                           + "|"  +
                               rel_bairrcop                           + "|"  +
                               rel_nmcidcop                           + "|"  +
                               rel_cdufdcop                           + "|"  + 
                               rel_nrcepcop                           + "|"  +
                               STRING(rel_cdagecta)                   + "-" + 
                               STRING(rel_cddigage)                   + "|" + 
                               STRING(rel_nrctacor)                   + "-" + 
                               STRING(rel_nrdigcta),
                               "str_1,str_2").

          END.  /* IF  FIRST-OF(tt-crawcrd.cdadmcrd)*/

      IF  FIRST-OF(tt-crawcrd.cdlimcrd)  THEN
          DO:
              IF  NOT(CAN-FIND(FIRST craptlc 
                               WHERE craptlc.cdcooper = glb_cdcooper         AND
                                     craptlc.cdadmcrd = tt-crawcrd.cdadmcrd  AND
                                     craptlc.dddebito = tt-crawcrd.dddebito  AND
                                     craptlc.tpcartao = 0                    AND
                                     craptlc.cdlimcrd = 0  
                                     NO-LOCK))   THEN
                  DO:
                      RUN Gera_Critica(532,"   CONTA = " +
                                      STRING(tt-crawcrd.nrdconta,"zzzz,zz9,9")).
                      RETURN "NOK".
                  END.
          END. /* IF  FIRST-OF(tt-crawcrd.cdlimcrd) */

      CASE tt-crawcrd.tpimpres:
          WHEN "2VIA"  THEN ASSIGN aux_fl2viacr = TRUE WHEN NOT aux_fl2viacr.
          WHEN "SENHA" THEN ASSIGN aux_fl2viasn = TRUE WHEN NOT aux_fl2viasn.
      END CASE.

      IF   tt-crawcrd.nmextttl = ""  THEN
           ASSIGN aux_nmprimtl = tt-crawcrd.nmtitcrd.
      ELSE
           ASSIGN aux_nmprimtl = tt-crawcrd.nmextttl.

      CASE tt-crawcrd.tpimpres:
          WHEN "2VIA" THEN 
          DO:
              IF tt-crawcrd.cdmotivo = 7 THEN /* Mudanca Data Vencimento */
                  aux_dddebito = tt-crawcrd.dddebant.
              ELSE
                  aux_dddebito = tt-crawcrd.dddebito.

              CASE tt-crawcrd.tppessoa:
                  WHEN "PF" THEN 
                  DO: 
                      RUN Gera_Arquivo("EXPORTA", "~012" +
                                       aux_nmprimtl                           + "|" +  
                                       tt-crawcrd.nmtitcrd                    + "|" +                               
                                       tt-crawcrd.cdsexotl                    + "|" +  
                                       STRING(tt-crawcrd.dtnasccr)            + "|" +
                                       string(tt-crawcrd.nrcpftit)            + "|" +  
                                       tt-crawcrd.dsdemail                    + "|" +
                                       STRING(tt-crawcrd.nrdoccrd)            + "|" +
                                       tt-crawcrd.cdoedptl                    + "|" +
                                       /* Alterado o Like do campo, portanto o substring 
                                       para continuar enviando o mesmo tamanho do campo */
                                       SUBSTRING(tt-crawcrd.dsestcvl,1,15)    + "|" + 
                                       tt-crawcrd.dsnacion                    + "|" +
                                       tt-crawcrd.nmmaettl                    + "|" +
                                       tt-crawcrd.dsendere                    + "|" +
                                       string(tt-crawcrd.nrendere)            + "|" +
                                       tt-crawcrd.complend                    + "|" +
                                       tt-crawcrd.nmbairro                    + "|" + 
                                       tt-crawcrd.nmcidade                    + "|" +
                                       STRING(tt-crawcrd.cdufende)            + "|" +
                                       STRING(tt-crawcrd.nrcepend)            + "|" + 
                                       tt-crawcrd.nrtelefo                    + "|" + 
                                       STRING(tt-crawcrd.vllimite)            + "|" +                                
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       STRING(tt-crawcrd.cdcooper,"999")      + "|" +                                
                                       STRING(tt-crawcrd.nrdconta,"zzzzzzz9") + "|" + 
                                       tt-crawcrd.dsmotivo                    + "|" +                                      
                                       STRING(aux_dddebito,"99")              + "|" +
                                       STRING(tt-crawcrd.cdagenci,"zz9"),
                                       "str_1").
                  END.
        
                  WHEN "PJ" THEN 
                  DO:
                      RUN Gera_Arquivo("EXPORTA", "~012" +
                                       aux_nmprimtl                           + "|" +
                                       tt-crawcrd.nmtitcrd                    + "|" +                               
                                       " "                                    + "|" + 
                                       STRING(tt-crawcrd.dtnasccr)            + "|" +
                                       string(tt-crawcrd.nrcpftit)            + "|" +  
                                       tt-crawcrd.dsdemail                    + "|" +
                                       " "                                    + "|" +
                                       " "                                    + "|" +
                                       " "                                    + "|" +
                                       " "                                    + "|" +
                                       " "                                    + "|" +
                                       tt-crawcrd.dsendere                    + "|" +
                                       string(tt-crawcrd.nrendere)            + "|" +
                                       tt-crawcrd.complend                    + "|" +
                                       tt-crawcrd.nmbairro                    + "|" + 
                                       tt-crawcrd.nmcidade                    + "|" +
                                       STRING(tt-crawcrd.cdufende)            + "|" +
                                       STRING(tt-crawcrd.nrcepend)            + "|" + 
                                       tt-crawcrd.nrtelefo                    + "|" + 
                                       STRING(tt-crawcrd.vllimite)            + "|" +                                
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       "NO"                                   + "|" +
                                       STRING(tt-crawcrd.cdcooper,"999")      + "|" +                                
                                       STRING(tt-crawcrd.nrdconta,"zzzzzzz9") + "|" + 
                                       tt-crawcrd.dsmotivo                    + "|" +                                      
                                       STRING(aux_dddebito,"99")              + "|" +
                                       STRING(tt-crawcrd.cdagenci,"zz9"),
                                       "str_1").
                  END.
              END CASE.
          END.

          WHEN "SENHA" THEN 
          DO:
              RUN Gera_Arquivo("EXPORTA",
                               "~012" + STRING(tt-crawcrd.nrcrcard, "9999,9999,9999,9999") + "|" +
                                        tt-crawcrd.nmtitcrd + "|" +
                                        tt-crawcrd.dsmotivo + "|" + 
                                        STRING(tt-crawcrd.nrdconta,"zzzzzzz9") + "|" + 
                                        STRING(tt-crawcrd.cdagenci,"zz9")      + "|" +
                                        tt-crawcrd.dsendere + "|" + 
                                        STRING(tt-crawcrd.nrendere,"zzz,zz9")  + "|" + 
                                        tt-crawcrd.complend + "|" + 
                                        tt-crawcrd.nmbairro + "|" +
                                        tt-crawcrd.nmcidade + "|" +
                                        tt-crawcrd.cdufende + "|" + 
                                        tt-crawcrd.nrcepend,                                        
                               "str_2").
          END.
      END CASE.

      IF  LAST-OF(tt-crawcrd.cdadmcrd)  THEN
          DO:
              RUN Gera_Arquivo("FECH_ARQ","","str_1,str_2").

              RUN Enviar_Email.

          END. /* IF  LAST-OF(tt-crawcrd.cdadmcrd) */

  END. /** Fim do FOR EACH tt-crawcrd **/

  /** Gerar arquivo de solicitacao de cartao de credito **/
  FOR EACH tt-crawcrd WHERE tt-crawcrd.tpimpres = "SOLICIT"
                      BREAK BY tt-crawcrd.cdadmcrd
                            BY tt-crawcrd.tpcartao
                            BY tt-crawcrd.dddebito
                            BY tt-crawcrd.cdlimcrd
                            BY tt-crawcrd.nmtitcrd ON ERROR UNDO, LEAVE:
      
      IF FIRST-OF(tt-crawcrd.cdadmcrd) THEN
      DO:
          /* Busca dados da Cooperativa e Adm. Credito */
          RUN Busca_Dados_Coop(tt-crawcrd.cdadmcrd,
                               tt-crawcrd.tpimpres). {&TrataErroInt}

          ASSIGN aux_nmarqimp = "CECRED_"                   +
                           STRING(crapcop.cdcooper,"99")    +
                           STRING(tt-crawcrd.cdadmcrd,"99") +
                           STRING(DAY(glb_dtmvtolt),"99")   + 
                           STRING(MONTH(glb_dtmvtolt),"99") + 
                           STRING(YEAR(glb_dtmvtolt),"9999").

          RUN Gera_Arquivo("ABRE_ARQ","","str_3").

          ASSIGN aux_regexist = TRUE.

          RUN Gera_Arquivo("EXPORTA",
                            rel_nmextcop              + "|"  + 
                            rel_nmrescop              + "|"  +
                            STRING(rel_nrdocnpj)      + "|"  +
                            rel_dsendere              + ", " +
                            rel_nrendcop              + "|"  +
                            rel_bairrcop              + "|"  + 
                            rel_nmcidcop              + "|"  +
                            rel_cdufdcop              + "|"  + 
                            rel_nrcepcop              + "|"  +
                            STRING(glb_cdcooper,"99") + "|"  + 
                            STRING(rel_cdagecta)      + "-"  +
                            STRING(rel_cddigage)      + "|"  +    
                            STRING(rel_nrctacor)      + "-"  + 
                            STRING(rel_nrdigcta),
                            "str_3").

      END. /* FIRST-OF(tt-crawcrd.cdadmcrd) */

      IF   tt-crawcrd.nmextttl = ""  THEN
           ASSIGN aux_nmprimtl = tt-crawcrd.nmtitcrd.
      ELSE
           ASSIGN aux_nmprimtl = tt-crawcrd.nmextttl.

      CASE tt-crawcrd.tppessoa:
          WHEN "PF" THEN 
          DO:
              RUN Gera_Arquivo("EXPORTA", "~012" +
                               aux_nmprimtl                           + "|" + 
                               tt-crawcrd.nmtitcrd                    + "|" +                               
                               tt-crawcrd.cdsexotl                    + "|" +  
                               STRING(tt-crawcrd.dtnasccr)            + "|" +
                               string(tt-crawcrd.nrcpftit)            + "|" +  
                               tt-crawcrd.dsdemail                    + "|" +
                               STRING(tt-crawcrd.nrdoccrd)            + "|" +
                               tt-crawcrd.cdoedptl                    + "|" +
                               /* Alterado o Like do campo, portanto o substring 
                               para continuar enviando o mesmo tamanho do campo */
                               SUBSTRING(tt-crawcrd.dsestcvl,1,15)    + "|" +
                               tt-crawcrd.dsnacion                    + "|" +
                               tt-crawcrd.nmmaettl                    + "|" +
                               tt-crawcrd.dsendere                    + "|" +
                               string(tt-crawcrd.nrendere)            + "|" +
                               tt-crawcrd.complend                    + "|" +
                               tt-crawcrd.nmbairro                    + "|" + 
                               tt-crawcrd.nmcidade                    + "|" +
                               STRING(tt-crawcrd.cdufende)            + "|" +
                               STRING(tt-crawcrd.nrcepend)            + "|" + 
                               tt-crawcrd.nrtelefo                    + "|" + 
                               STRING(tt-crawcrd.vllimite)            + "|" +                                
                               "NO"                                   + "|" +  
                               "NO"                                   + "|" +                                  
                               "NO"                                   + "|" +  
                               "NO"                                   + "|" +  
                               STRING(tt-crawcrd.cdcooper,"999")      + "|" +                                
                               STRING(tt-crawcrd.nrdconta,"zzzzzzz9") + "|" +                                      
                               STRING(tt-crawcrd.dddebito,"99")       + "|" + 
                               STRING(tt-crawcrd.cdagenci,"zz9"),
                               "str_3").
          END.

          WHEN "PJ" THEN 
          DO:
              RUN Gera_Arquivo("EXPORTA", "~012" +
                               aux_nmprimtl                           + "|" + 
                               tt-crawcrd.nmtitcrd                    + "|" + 
                               " "                                    + "|" +
                               STRING(tt-crawcrd.dtnasccr)            + "|" +
                               string(tt-crawcrd.nrcpftit)            + "|" +  
                               tt-crawcrd.dsdemail                    + "|" +
                               " "                                    + "|" +
                               " "                                    + "|" +
                               " "                                    + "|" +
                               " "                                    + "|" +
                               " "                                    + "|" +
                               tt-crawcrd.dsendere                    + "|" +
                               string(tt-crawcrd.nrendere)            + "|" +
                               tt-crawcrd.complend                    + "|" +
                               tt-crawcrd.nmbairro                    + "|" + 
                               tt-crawcrd.nmcidade                    + "|" +
                               STRING(tt-crawcrd.cdufende)            + "|" +
                               STRING(tt-crawcrd.nrcepend)            + "|" + 
                               tt-crawcrd.nrtelefo                    + "|" + 
                               STRING(tt-crawcrd.vllimite)            + "|" +                                
                               "NO"                                   + "|" +
                               "NO"                                   + "|" +
                               "NO"                                   + "|" +
                               "NO"                                   + "|" +
                               STRING(tt-crawcrd.cdcooper,"999")      + "|" +                                
                               STRING(tt-crawcrd.nrdconta,"zzzzzzz9") + "|" +                                      
                               STRING(tt-crawcrd.dddebito,"99")       + "|" + 
                               STRING(tt-crawcrd.cdagenci),
                               "str_3").
          END.
      END CASE.

      IF   LAST(tt-crawcrd.cdadmcrd)   THEN
           DO:
               RUN Gera_Arquivo("FECH_ARQ","","str_3"). 

               RUN Converte_Arquivo. {&TrataErroInt}
           END.

  END.  /* FOR EACH tt-crawcrd */

  RETURN.

END PROCEDURE. /* Exporta_Dados */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Converte_Arquivo:

  FOR EACH craptlc WHERE craptlc.cdcooper = glb_cdcooper  AND
                         craptlc.cdadmcrd = 3             AND
                         craptlc.dddebito > 0             
                   NO-LOCK ON ERROR UNDO, RETURN "NOK":

      ASSIGN aux_nmarqimp = "CECRED_" + STRING(crapcop.cdcooper,"99")    +
                                        STRING(craptlc.cdadmcrd,"99") +
                                        STRING(DAY(glb_dtmvtolt),"99")   + 
                                        STRING(MONTH(glb_dtmvtolt),"99") + 
                                        STRING(YEAR(glb_dtmvtolt),"9999").

      IF   SEARCH("arq/" + aux_nmarqimp + ".lst") <> ? THEN       
           DO:
               UNIX SILENT VALUE("PedidoDeCartao.pl arq/" + aux_nmarqimp
                                  + ".lst converte/" + aux_nmarqimp +  
                                  ".xls").

               /* Concatena nome dos arquivos para uso na BO b1wgen0011 */
               ASSIGN aux_dsarqath = aux_nmarqimp + ".xls;".
               
               /*Enviar e-mail para todas as datas de débito*/
               RUN sistema/generico/procedures/b1wgen0011.p
                   PERSISTENT SET b1wgen0011.
               RUN enviar_email IN b1wgen0011 (INPUT glb_cdcooper,
                                               INPUT glb_cdprogra,
                                               INPUT crapadc.dsdemail,
                                               INPUT "PEDIDO DE CARTAO DE " + 
                                                     "CREDITO REFERENTE AO " +
                                                     "CENTRO DE CUSTO " + 
                                                     STRING(crapcop.cdcooper,"999"),
                                               INPUT aux_dsarqath,
                                               INPUT TRUE). 
               DELETE PROCEDURE b1wgen0011.
               /* FIM */ 
                                 
               UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + 
                                 ".lst 1>/dev/null 2>/dev/null"). 
              
               UNIX SILENT VALUE("cp converte/" + 
                                 aux_nmarqimp + ".xls salvar").
           END.

  END. /* FOR EACH craptlc */

  RETURN.

END PROCEDURE. /* Converte_Arquivo */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Imprime_Dados:

  DEF VAR aux_tpimpres AS CHAR                                         NO-UNDO.
  DEF VAR aux_contentr AS INTE                                         NO-UNDO.

  ASSIGN glb_cdempres = 11
         aux_nmarqimp = "rl/crrl355.lst"
         aux_dddebito = 0.

  { includes/cabrel132_2.i }  

  OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

  VIEW STREAM str_2 FRAME f_cabrel132_2.

  /** Gerar arquivo de solicitacao de cartao de credito **/
  FOR EACH tt-crawcrd 
      BREAK BY tt-crawcrd.cdadmcrd
            BY tt-crawcrd.idseqimp
            BY tt-crawcrd.tpimpres
            BY tt-crawcrd.nmtitcrd
            BY tt-crawcrd.nrdconta ON ERROR UNDO, LEAVE:

      IF   FIRST-OF(tt-crawcrd.cdadmcrd)   THEN
           DO:

               FOR FIRST crapadc FIELDS(nmresadm)
                   WHERE crapadc.cdcooper = glb_cdcooper          AND
                         crapadc.cdadmcrd = tt-crawcrd.cdadmcrd
                         NO-LOCK:
                   ASSIGN rel_nmresadm = crapadc.nmresadm.
               END.

               IF   NOT AVAILABLE crapadc  THEN
                    DO: 
                        RUN Gera_Critica(605,"  CONTA = " +
                             STRING(tt-crawcrd.nrdconta,"zzzz,zz9,9")).  
                        RETURN "NOK".
                    END.

               DISPLAY STREAM str_2 rel_dslocdat WITH FRAME f_titulo_355.

               DISPLAY STREAM str_2 rel_nmresadm WITH FRAME f_administ_355.

           END. /* FIRST-OF(tt-crawcrd.cdadmcrd) */

      IF   FIRST-OF(tt-crawcrd.tpimpres)   THEN
           DO:
               CASE tt-crawcrd.tpimpres:
                   WHEN "SOLICIT" THEN
                       ASSIGN rel_dssolici = "CARTOES DE CREDITO SOLICITADOS:"
                              aux_regexist = TRUE.

                   WHEN "2VIA"    THEN
                       ASSIGN rel_dssolici = "SEGUNDA VIA DE CARTOES " +
                                             "SOLICITADOS:".

                   WHEN "SENHA"   THEN
                       ASSIGN rel_dssolici = "SEGUNDA VIA DE SENHAS " +
                                             "SOLICITADAS:".

               END CASE.

               DISPLAY STREAM str_2 rel_dssolici WITH FRAME f_titulo_355_1.

           END. /* FIRST-OF(tt-crawcrd.tpimpres) */

      IF   LINE-COUNTER(str_2) >= 75   THEN
           DO:
              PAGE STREAM str_2.
           
              DISPLAY STREAM str_2 rel_dslocdat WITH FRAME f_titulo_355.

              DISPLAY STREAM str_2 rel_dssolici WITH FRAME f_titulo_355_1.
           END.

      CASE tt-crawcrd.tpimpres:
          WHEN "SOLICIT" THEN
              DO:
                  DISPLAY STREAM str_2
                          tt-crawcrd.cdagenci 
                          tt-crawcrd.nrdconta 
                          tt-crawcrd.tppessoa
                          tt-crawcrd.nmtitcrd
                          tt-crawcrd.vllimite
                          tt-crawcrd.dddebito
                          tt-crawcrd.nrctrcrd 
                          tt-crawcrd.dtpropos 
                          tt-crawcrd.dddebito
                          aux_fill    
                          WITH FRAME f_lanctos3_355.
                  
                  DOWN STREAM str_2 WITH FRAME f_lanctos3_355.

                  ASSIGN tot_qtaprova = tot_qtaprova + 1
                         aux_contador = aux_contador + 1. 

              END. /* SOLICIT */

          WHEN "2VIA"    THEN
              DO:

                  IF tt-crawcrd.cdmotivo = 7 THEN /* Mudanca Data Vencimento */
                    aux_dddebito = tt-crawcrd.dddebant.
                  ELSE
                    aux_dddebito = tt-crawcrd.dddebito.

                  DISPLAY STREAM str_2
                          tt-crawcrd.cdagenci
                          tt-crawcrd.nrdconta
                          tt-crawcrd.tppessoa
                          tt-crawcrd.nmtitcrd
                          tt-crawcrd.dsmotivo
                          aux_dtmvtolt
                          aux_dddebito
                          aux_fill
                          WITH FRAME f_lanctos_355.
    
                  DOWN STREAM str_2 WITH FRAME f_lanctos_355.

                  ASSIGN aux_sgnviacr = aux_sgnviacr + 1
                         aux_contador = aux_contador + 1.

              END. /* 2VIA */

          WHEN "SENHA"   THEN
              DO:
                  DISPLAY STREAM str_2 
                          tt-crawcrd.cdagenci
                          tt-crawcrd.nrdconta
                          tt-crawcrd.tppessoa
                          tt-crawcrd.nmtitcrd
                          aux_dtmvtolt
                          aux_fill
                          WITH FRAME f_lanctos2_355.

                  DOWN STREAM str_2 WITH FRAME f_lanctos2_355.

                  ASSIGN aux_sgnviasn = aux_sgnviasn + 1
                         aux_contador = aux_contador + 1.

              END. /* SENHA */
      END CASE.

      IF   LAST-OF(tt-crawcrd.tpimpres)   THEN
           DO:
               CASE tt-crawcrd.tpimpres:
                   WHEN "SOLICIT" THEN
                        DISPLAY STREAM str_2 aux_contador 
                                WITH FRAME f_final_355.

                   WHEN "2VIA"    THEN
                        DISPLAY STREAM str_2 aux_contador 
                                WITH FRAME f_qtd2_sol.

                   WHEN "SENHA"   THEN
                        DISPLAY STREAM str_2 aux_contador 
                                WITH FRAME f_qtd_sol.

               END CASE.

               ASSIGN aux_contador = 0.

           END. /* LAST-OF(tt-crawcrd.tpimpres) */

      IF   LAST-OF(tt-crawcrd.cdadmcrd)   THEN
           DO:
               IF LINE-COUNTER(str_2) > 65   THEN
                  PAGE STREAM str_2.

               DISPLAY STREAM str_2 WITH FRAME f_assina_355.
           
               IF NOT(LAST(tt-crawcrd.cdadmcrd)) THEN
                   PAGE STREAM str_2.
           
           END.

  END. /* FOR EACH tt-crawcrd */

  IF   LINE-COUNTER(str_2) >= 75  THEN
       DO:

           PAGE STREAM str_2.

           DISPLAY STREAM str_2 rel_dslocdat 
                   WITH FRAME f_titulo_355.  

       END. /* LINE-COUNTER(str_2) >= 75 */

  DISPLAY STREAM str_2 aux_sgnviacr aux_sgnviasn tot_qtaprova
          WITH FRAME f_total_sol.

  /*imprimir criticas aqui*/
  ASSIGN glb_cdcritic = 18.
  RUN fontes/critic.p.

  ASSIGN aux_dscritic = glb_dscritic.

  DISPLAY STREAM str_2 WITH FRAME f_critica_tit.

  FOR EACH tt-crawcri NO-LOCK:
      DISPLAY STREAM str_2 tt-crawcri.nrdconta tt-crawcri.tpsolici aux_dscritic
              WITH FRAME f_critica.
  END.

  ASSIGN glb_cdcritic = 0
         glb_dscritic = "".
  /*fim impressao criticas*/

  RUN Gera_Arquivo("FECH_ARQ","","str_2").

  IF   aux_regexist OR 
       aux_fl2viacr OR 
       aux_fl2viasn   THEN
       DO:
  
           ASSIGN glb_nmformul = "132col"
                  glb_nmarqimp = aux_nmarqimp.
           
           IF glb_cdcooper = 6   THEN
              glb_nrcopias = 1.
           ELSE
              glb_nrcopias = 2.
           
           RUN fontes/imprim.p. 
  
  END.

  ASSIGN craptab.dstextab = STRING(glb_dtmvtolt).

  RETURN.

END PROCEDURE. /* Imprime_Dados */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Atualiza_Sit_Cred:

  /* Atualizar situacoes das contas de 1-Aprovado p/ 3-Liberado */
  FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper     AND
                         crawcrd.insitcrd = 1                AND
                         crawcrd.cdadmcrd = 3 /* crapadc.cdadmcrd */
                   EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETURN "NOK":

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = crawcrd.nrdconta
                         NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass THEN
           DO:
               RUN Gera_Critica(251,"  CONTA = " +
                                STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
               NEXT.
           END.

      /*nao gerar mais critica no log
      IF (crapass.cdsitdct <> 1 AND crapass.cdsitdct <> 6)  THEN
      DO:
        RUN Gera_Critica(018,"  CONTA = " +
            STRING(crawcrd.nrdconta,"zzzz,zz9,9")).
        NEXT.
      END. */

      /* Nao mexer no 'insitcrd' se for administradora da conta integracao */
      IF   NOT CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd))   AND
          (crapass.cdsitdct = 1   OR   crapass.cdsitdct = 6)          THEN

           ASSIGN crawcrd.insitcrd = 3 /* atualizar p/ Liberado */
                  crawcrd.dtsolici = glb_dtmvtolt.

  END. /* FOR EACH crawcrd */
  
  RETURN.

END PROCEDURE. /* Atualiza_Sit_Cred */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Gera_Arquivo:
  DEFINE INPUT  PARAMETER par_comando AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER par_string  AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER par_lstream AS CHARACTER   NO-UNDO. /* Lista Stream */

  &SCOPED-DEFINE STR1 LOOKUP("str_1",par_lstream) <> 0
  &SCOPED-DEFINE STR2 LOOKUP("str_2",par_lstream) <> 0
  &SCOPED-DEFINE STR3 LOOKUP("str_3",par_lstream) <> 0

  CASE par_comando:
      WHEN "ABRE_ARQ"  THEN  /* Abrir Arquivo */
          DO:
              IF   {&STR1}   THEN 
                   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_arqxlscr + ".lst") 
                                       PAGED PAGE-SIZE 84.

              IF   {&STR2}   THEN
                   OUTPUT STREAM str_2 TO VALUE("arq/" + aux_arqxlssn + ".lst") 
                                       PAGED PAGE-SIZE 84.
              IF   {&STR3}   THEN
                   OUTPUT STREAM str_3 TO VALUE("arq/" + aux_nmarqimp + ".lst") 
                                       PAGED PAGE-SIZE 84.
          END.
      WHEN "FECH_ARQ"  THEN  /* Fechar Arquivo */
          DO:
              IF   {&STR1}   THEN
                   OUTPUT STREAM str_1 CLOSE.

              IF   {&STR2}   THEN
                   OUTPUT STREAM str_2 CLOSE.

              IF   {&STR3}   THEN
                   OUTPUT STREAM str_3 CLOSE.

          END.
      WHEN "EXPORTA"  THEN 
          DO:
              IF   {&STR1}   THEN
                   PUT STREAM str_1 UNFORMATTED par_string SKIP.

              IF   {&STR2}   THEN
                   PUT STREAM str_2 UNFORMATTED par_string SKIP.

              IF   {&STR3}   THEN
                   PUT STREAM str_3 UNFORMATTED par_string SKIP.
          END.
  END CASE.

END PROCEDURE. /* Gera_Arquivo */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Enviar_Email:

  RUN sistema/generico/procedures/b1wgen0011.p
      PERSISTENT SET b1wgen0011.

  IF  aux_fl2viacr  THEN
      DO:            
          UNIX SILENT VALUE ("Pedido2vCartao.pl arq/" + aux_arqxlscr +
                             ".lst converte/" + aux_arqxlscr + 
                             ".xls").

          UNIX SILENT VALUE ("cp converte/" + aux_arqxlscr + 
                             ".xls salvar").

          RUN enviar_email IN b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT glb_cdprogra,
                               INPUT crapadc.dsdemail,
                               INPUT "PEDIDO 2a. VIA DE CARTOES DE" + 
                                     " CREDITO REFERENTE A " + 
                                     rel_nmrescop,
                               INPUT aux_arqxlscr + ".xls",
                               INPUT TRUE). 
      END.
                     
  UNIX SILENT VALUE ("rm arq/" + aux_arqxlscr + 
                     ".lst 1>/dev/null 2>/dev/null"). 
    
  IF  aux_fl2viasn  THEN
      DO:            
          UNIX SILENT VALUE ("Pedido2vsCartao.pl arq/" + aux_arqxlssn +
                             ".lst converte/" + aux_arqxlssn + 
                             ".xls").

          UNIX SILENT VALUE ("cp converte/" + aux_arqxlssn + 
                             ".xls salvar").

          RUN enviar_email IN b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT glb_cdprogra,
                               INPUT crapadc.dsdemail,
                               INPUT "PEDIDO 2a. VIA DE SENHA DE " +
                                     "CARTOES DE CREDITO REFERENTE A "
                                     + rel_nmrescop,
                               INPUT aux_arqxlssn + ".xls",
                               INPUT TRUE).
      END.
                     
  UNIX SILENT VALUE ("rm arq/" + aux_arqxlssn +
                     ".lst 1>/dev/null 2>/dev/null").
    
  DELETE PROCEDURE b1wgen0011.

END PROCEDURE. /* Enviar_Email */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Gera_Critica:
  DEFINE INPUT  PARAM aux_cdcritic AS INTEGER   NO-UNDO. /* Cod.Critica     */
  DEFINE INPUT  PARAM aux_complmsg AS CHARACTER NO-UNDO. /* Complemento Msg */

  ASSIGN glb_cdcritic = aux_cdcritic.

  RUN fontes/critic.p.
  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                    " - " + glb_cdprogra + "' --> '"  +
                    glb_dscritic + aux_complmsg + " >> log/proc_batch.log").

  glb_cdcritic = 0.
  RETURN "NOK".

END PROCEDURE. /* Gera_Critica */
/******************************************************************************/

/******************************************************************************/
/******* Divide o campo crapcop.nmextcop em duas Strings *******/
PROCEDURE p_divinome:

  DEF VAR aux_qtpalavr AS INTE                                         NO-UNDO.
  DEF VAR aux_contapal AS INTE                                         NO-UNDO.

  
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                        rel_nmressbr = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
      
      IF  aux_contapal <= aux_qtpalavr  THEN
          rel_nmressbr[1] = rel_nmressbr[1] +   
                           (IF TRIM(rel_nmressbr[1]) = "" THEN "" ELSE " ") 
                            + ENTRY(aux_contapal,crapcop.nmextcop," ").
      ELSE
          rel_nmressbr[2] = rel_nmressbr[2] +
                           (IF TRIM(rel_nmressbr[2]) = "" THEN "" ELSE " ")
                            + ENTRY(aux_contapal,crapcop.nmextcop," ").
  
  END. /** Fim do DO .. TO **/ 
         
  IF  LENGTH(rel_nmressbr[1]) > LENGTH(rel_nmressbr[2])  THEN
      ASSIGN rel_nmressbr[1] = TRIM(rel_nmressbr[1])
             rel_nmressbr[2] = FILL(" ",INT(LENGTH(rel_nmressbr[1]) / 2) -
                                    INTE(LENGTH(rel_nmressbr[2]) / 2)) +
                               rel_nmressbr[2].
  ELSE
  IF  LENGTH(rel_nmressbr[1]) < LENGTH(rel_nmressbr[2])  THEN
      ASSIGN rel_nmressbr[1] = FILL(" ",INT(LENGTH(rel_nmressbr[2]) / 2) -
                                    INTE(LENGTH(rel_nmressbr[1]) / 2)) +
                               rel_nmressbr[1]
             rel_nmressbr[2] = TRIM(rel_nmressbr[2]).
  ELSE
      ASSIGN rel_nmressbr[1] = TRIM(rel_nmressbr[1])
             rel_nmressbr[2] = TRIM(rel_nmressbr[2]).

END PROCEDURE. /* p_dividenome */
/******************************************************************************/

/******************************************************************************/
/**************************** FIM - PROCEDURES ********************************/

/* .......................................................................... */
