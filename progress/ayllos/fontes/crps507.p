/* ...........................................................................

   Programa: fontes/crps507.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2008                         Ultima atualizacao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Atende a solicitacao 86.
               Relacao diaria BRADESCO(CECRED VISA) 
               alt.limite/data vcto/cancelamento
               Emite relatorio 480.

   Alteracoes: 19/06/2008 - Salvar arquivo no diretorio 'salvar' e enviar 
                            e-mail para o suporte (Gabriel).
                          - Alterado layout do arquivo a ser enviado para o
                            Bradesco e executado script para converter arquivo
                            para formato ".xls" (Elton).

               09/07/2008 - Incluido data no nome do arquivo ".xls" e alterado
                            para nao copiar arquivo ".lst" para o diretorio
                            salvar (Elton).

               13/08/2008 - Somente enviar para CRC@cartoes,solicitado pelo
                            Everton nesta data via MIC (Magui).
                            
               20/03/2009 - Utilizar somente o campo crapadc.dsdemail para 
                            envio de e-mail (Fernando).
                            
               28/04/2009 - Utilizar somente o campo crapadc.dsdemail para 
                            envio de e-mail (Mirtes).
                            
               15/12/2009 - Colocar nome da cooperativa no assunto do email e
                            utilizar crapadc.dsdemail para envio (David).
                            
               15/10/2010 - Unificar programas de geracao de relatorios e 
                            arquivos (crps193.p e crps507.p) - (Joao-RKAM).
                            
               29/11/2010 - Consulta de Cancelamento somente para a Adm.
                            Bradesco (Irlan)
                            
               14/02/2011 - Incluir resumo da totalização de valores e  
                            alterar o formato da data. (Isara - RKAM)
                            
               08/06/2011 - Inclusa a lógica do baca cartoes_chip.p, criada
                            a procedure lista_cartoes_entregues para 
                            executar o procedimento do baca. 
                            (Isara - RKAM)
                          
               01/06/2012 - Incluido campo 'Limite de credito' no arquivo
                            de exportacao (Tiago).
                            
               01/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
..............................................................................*/

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.  

{ includes/var_batch.i "NEW" }

/******************************************************************************/
/*************************** Definicoes de Variaveis **************************/
DEF   VAR b1wgen0011   AS HANDLE                                    NO-UNDO.

DEF   VAR aux_tiporela AS CHAR     FORMAT "x(42)"                   NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                   NO-UNDO.

DEF   VAR aux_regcance AS LOGICAL                                   NO-UNDO.
DEF   VAR aux_reglimit AS LOGICAL                                   NO-UNDO.
DEF   VAR aux_regvenci AS LOGICAL                                   NO-UNDO.

DEF   VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF   VAR aux_nmarqdat AS CHAR                                      NO-UNDO.
DEF   VAR aux_nmarqbra AS CHAR                                      NO-UNDO.

DEF   VAR aux_diamovto AS INT      FORMAT "99"                      NO-UNDO.
DEF   VAR aux_mesmovto AS CHAR     FORMAT "x(09)"                   NO-UNDO.
DEF   VAR aux_anomovto AS CHAR     FORMAT "x(05)"                   NO-UNDO.
DEF   VAR aux_nmcidade AS CHAR     FORMAT "x(40)"                   NO-UNDO.

DEF   VAR aux_nmsolici AS CHAR     FORMAT "x(20)"                   NO-UNDO.
DEF   VAR aux_dsdemail AS CHAR     FORMAT "x(25)"                   NO-UNDO.

DEF   VAR aux_nmmesano AS CHAR    EXTENT 12 INIT                            
                                         [" JANEIRO ","FEVEREIRO",          
                                          "  MARCO  ","  ABRIL  ",          
                                          "  MAIO   ","  JUNHO  ",          
                                          " JULHO   "," AGOSTO  ",          
                                          "SETEMBRO "," OUTUBRO ",          
                                          "NOVEMBRO ","DEZEMBRO "]  NO-UNDO.

DEF   VAR tot_qtcartao AS INT                                       NO-UNDO.

DEF   VAR rel_nmadmcrd LIKE crapadc.nmadmcrd                        NO-UNDO.
DEF   VAR rel_dsendere LIKE crapadc.dsendere                        NO-UNDO.
DEF   VAR rel_nrcepend LIKE crapadc.nrcepend                        NO-UNDO.
DEF   VAR rel_nmcidade LIKE crapadc.nmcidade                        NO-UNDO.
DEF   VAR rel_cdufende LIKE crapadc.cdufende                        NO-UNDO.
DEF   VAR rel_nmpescto LIKE crapadc.nmpescto                        NO-UNDO.
DEF   VAR rel_nmresadm LIKE crapadc.nmresadm                        NO-UNDO.

DEF   VAR rel_nmrescop AS CHAR EXTENT 2                             NO-UNDO.
DEF   VAR rel_nmressbr AS CHAR EXTENT 2                             NO-UNDO.

DEF   VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF   VAR rel_nmempres AS CHAR                                      NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL      ",
                                     "EMPRESTIMOS    ","DIGITACAO    ",
                                     "GENERICO       "]             NO-UNDO.
DEF   VAR rel_nrmodulo AS INTE FORMAT "9"                           NO-UNDO.

/* Resumo */
DEF   VAR tot_qtctoalt AS INT                                       NO-UNDO.
DEF   VAR tot_qtctoven AS INT                                       NO-UNDO.
DEF   VAR tot_qtctocan AS INT                                       NO-UNDO.

/******************************************************************************/
/*************************** Definicoes de TEMP-TABLE's ***********************/
DEFINE TEMP-TABLE tt-crawcrd NO-UNDO
    FIELD cdcooper LIKE crawcrd.cdcooper
    FIELD cdagenci LIKE crawcrd.cdagenci
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD tppessoa AS CHARACTER FORMAT "!!" /* PF/PJ */
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD vllimrea AS INTEGER
    FIELD lirsaque AS INTEGER
    FIELD vllimdol AS INTEGER
    FIELD lidsaque AS INTEGER
    FIELD dtcancel LIKE crawcrd.dtcancel
    FIELD tpimpres AS CHARACTER. /* LIMITE/VENCIMENTO/CANCELAMENTO */

DEF TEMP-TABLE tt-cartoes
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD vllimcrd LIKE craptlc.vllimcrd
    FIELD dtentreg LIKE crawcrd.dtentreg.

DEFINE BUFFER btt-crawcrd FOR tt-crawcrd.

/******************************************************************************/
/*********************************** FORM'S ***********************************/

FORM aux_nmcidade "," aux_diamovto "DE" aux_mesmovto
     "DE" aux_anomovto SKIP(4)
     "A " rel_nmadmcrd SKIP
     rel_dsendere
     SKIP
     rel_nrcepend " - " rel_nmcidade " - " rel_cdufende
     SKIP(2)
     "A/C " rel_nmpescto
     SKIP(2)
     WITH COLUMN 7 NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo.

FORM aux_tiporela
     /*SKIP(2)*/
     WITH COLUMN 7 NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo1.

FORM btt-crawcrd.cdagenci AT  03 LABEL "PA"
     btt-crawcrd.nrdconta        LABEL "CONTA/DV"
     btt-crawcrd.tppessoa        LABEL "TIPO"
     btt-crawcrd.nmtitcrd        LABEL "NOME" FORMAT "x(30)"
     btt-crawcrd.nrcrcard        LABEL "CARTAO"
     btt-crawcrd.dddebito        LABEL "VENCIMENTO"
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_vcto.
     
FORM btt-crawcrd.cdagenci AT  03 LABEL "PA"
     btt-crawcrd.nrdconta        LABEL "CONTA/DV"
     btt-crawcrd.tppessoa        LABEL "TIPO"
     btt-crawcrd.nmtitcrd        LABEL "NOME" FORMAT "x(30)"
     btt-crawcrd.nrcrcard        LABEL "CARTAO"
     btt-crawcrd.vllimrea        LABEL "LIM. COMPRA R$"
     btt-crawcrd.lirsaque        LABEL "LIM. SAQUE R$"
     btt-crawcrd.vllimdol        LABEL "LIM. COMPRA US$"
     btt-crawcrd.lidsaque        LABEL "LIM. SAQUE US$"
     WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_limite.
     
FORM btt-crawcrd.cdagenci AT  03 LABEL "PA"
     btt-crawcrd.nrdconta        LABEL "CONTA/DV"
     btt-crawcrd.tppessoa        LABEL "TIPO"
     btt-crawcrd.nmtitcrd        LABEL "NOME" FORMAT "x(24)"
     btt-crawcrd.nrcrcard        LABEL "CARTAO"
     FORMAT "9999,9999,9999,9999" 
     btt-crawcrd.dtcancel        LABEL "   DATA" FORMAT "99/99/99"  
     WITH DOWN NO-BOX NO-LABELS WIDTH 80 FRAME f_lanctos.

FORM 
     tot_qtcartao  AT 7 LABEL "QUANTIDADE DE CARTOES COM VENCIMENTO ALTERADO"
     SKIP(3)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_final_venc.

FORM 
     tot_qtcartao  AT 7 LABEL "QUANTIDADE DE CARTOES COM LIMITE ALTERADO"
     SKIP(3)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_final_lim.

FORM 
     tot_qtcartao  AT 7 LABEL "QUANTIDADE DE CARTOES CANCELADOS"
     SKIP(3)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_final_canc.

FORM SKIP(3)
     WITH FRAME f_salto.

FORM "ATENCIOSAMENTE"
     SKIP(4)
     rel_nmressbr[1] FORMAT "x(36)" SKIP
     rel_nmressbr[2] FORMAT "x(36)" 
     WITH COLUMN 7 NO-BOX NO-LABELS WIDTH 80 FRAME f_credi.

FORM SKIP
     "ADMINISTRADORA: "
     rel_nmresadm
     SKIP(1)
     WITH NO-BOX SIDE-LABELS NO-LABELS WIDTH 132 FRAME f_admcrd.     

FORM 
     "QUANTIDADE DE CARTOES COM LIMITE ALTERADO:"        AT 7
     tot_qtctoalt                                        AT 60        
     "QUANTIDADE DE CARTOES COM VENCIMENTO ALTERADO:"    AT 7
     tot_qtctoven                                        AT 60
     "QUANTIDADE DE CARTOES CANCELADOS:"                 AT 7 
     tot_qtctocan                                        AT 60
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_sol.

/******************************************************************************/

/******************************************************************************/
/******************************* BLOCO PRINCIPAL ******************************/
DO ON ERROR UNDO, LEAVE:
  
  RUN Inicia_Programa. /*Executar rotinas p/ inicializar                      */
  RUN Busca_Dados.     /*Buscar dados e "Popular" Temp-Table                  */
  RUN Imprime_Dados.   /*Imprimir dados Temp-Table/Gerar Arquivos/Env.e-mail's*/
  
  IF glb_cdcooper = 3 THEN
  DO:
      RUN Lista_Cartoes_Entregues.
  END.

END.

RUN fontes/fimprg.p.

/******************************************************************************/
/***************************** FIM - BLOCO PRINCIPAL **************************/

/******************************************************************************/
/********************************* FUNCOES ************************************/

/******************************************************************************/
/* Funcao para retornar dados do Associado/Cooperado */ 
FUNCTION Busca_Dados_Assoc RETURNS CHARACTER /* Tp.Pessoa: Fisica ou Juridica */
    (INPUT  aux_nrdconta AS INTEGER,  /* Nr. Conta */
     OUTPUT aux_cdagenci AS INTEGER): /* PA       */

  FOR FIRST crapass FIELDS(inpessoa cdagenci) 
      WHERE crapass.cdcooper = glb_cdcooper   AND
            crapass.nrdconta = aux_nrdconta
            NO-LOCK:

      ASSIGN aux_cdagenci = crapass.cdagenci.

      CASE crapass.inpessoa:
          WHEN 1 THEN RETURN "PF".
          WHEN 2 OR 
          WHEN 3 THEN RETURN "PJ".
          OTHERWISE RETURN "??".
      END CASE.
  END. /* FOR FIRST crapass */

  RETURN "??".

END FUNCTION. /* Busca_Dados_Assoc */
/******************************************************************************/

/******************************************************************************/
/****************************** FIM - FUNCOES *********************************/

/******************************************************************************/
/******************************* PROCEDURES ***********************************/

/******************************************************************************/
PROCEDURE Inicia_Programa:

  ASSIGN glb_cdprogra = "crps507".
  
  RUN fontes/iniprg.p.
  
  IF   glb_cdcritic > 0   THEN
       QUIT.
  
  /* Busca dados da cooperativa */
  FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
  IF   NOT AVAILABLE crapcop   THEN 
       DO: 
           RUN Gera_Critica(651,"").
       END.

  RUN p_divinome.

  ASSIGN aux_nmcidade    = TRIM(crapcop.nmcidade)
         aux_diamovto    = DAY (glb_dtmvtolt)
         aux_mesmovto    = aux_nmmesano[MONTH(glb_dtmvtolt)]
         aux_anomovto    = STRING(YEAR(glb_dtmvtolt))
         rel_nmressbr[1] = TRIM(rel_nmrescop[1])
         rel_nmressbr[2] = "    " + TRIM(rel_nmrescop[2])
         aux_nmsolici    = "CECRED"               
         aux_dsdemail    = "cpd@cecred.coop.br".

END PROCEDURE. /* Inicia_Programa */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Busca_Dados:

  &SCOPED-DEFINE Campos-Limite cdcooper nrdconta nmtitcrd nrcrcard tpcartao                            cdlimcrd cdadmcrd
                               
  &SCOPED-DEFINE Campos-Vcto cdcooper nrdconta nmtitcrd nrcrcard dddebito                              cdadmcrd 

  &SCOPED-DEFINE Campos-Canc cdcooper nrdconta nmtitcrd nrcrcard dtcancel                              cdadmcrd

  /****************************************************************************/
  /* Alteracao de valor limite */     
  FOR EACH crawcrd FIELDS({&Campos-Limite} nrctrcrd) 
      WHERE crawcrd.cdcooper = glb_cdcooper   AND  
            crawcrd.cdadmcrd = 3              AND /* Bradesco      */ 
            crawcrd.insitcrd = 4                  /* Cartoes em uso */ 
            NO-LOCK,    

      FIRST crapcrd FIELDS(nrdconta) 
      WHERE crapcrd.cdcooper = glb_cdcooper       AND
            crapcrd.nrdconta = crawcrd.nrdconta   AND
            crapcrd.nrctrcrd = crawcrd.nrctrcrd   AND
            crapcrd.dtaltlim = glb_dtmvtolt       
            NO-LOCK ON ERROR UNDO, LEAVE:
       
      CREATE tt-crawcrd.
      BUFFER-COPY crawcrd USING {&Campos-Limite} TO tt-crawcrd
      ASSIGN tt-crawcrd.tpimpres = "LIMITE"
             tt-crawcrd.tppessoa = Busca_Dados_Assoc(INPUT crawcrd.nrdconta,
                                                    OUTPUT tt-crawcrd.cdagenci).

      FOR FIRST craptlc FIELDS(vllimcrd) 
          WHERE craptlc.cdcooper = glb_cdcooper       AND
                craptlc.cdadmcrd = crawcrd.cdadmcrd   AND
                craptlc.tpcartao = crawcrd.tpcartao   AND
                craptlc.cdlimcrd = crawcrd.cdlimcrd   
                NO-LOCK:

          ASSIGN tt-crawcrd.vllimrea =  craptlc.vllimcrd     
                 tt-crawcrd.lirsaque = (craptlc.vllimcrd / 2)
                 tt-crawcrd.vllimdol =  tt-crawcrd.lirsaque         
                 tt-crawcrd.lidsaque = (tt-crawcrd.vllimdol / 2).   
      END. /* FOR FIRST craptlc */

  END. /* FOR EACH crawcrd - LIMITE */
  /****************************************************************************/

  /****************************************************************************/
  /* Alteracao de data vencimento */            
  FOR EACH crawcrd FIELDS({&Campos-Vcto} nrctrcrd) 
      WHERE crawcrd.cdcooper = glb_cdcooper   AND
            crawcrd.cdadmcrd = 3              AND /* Bradesco      */
            crawcrd.insitcrd = 4                  /* Cartao em uso */
            NO-LOCK,

      FIRST crapcrd FIELDS(nrdconta) 
      WHERE crapcrd.cdcooper = glb_cdcooper       AND
            crapcrd.nrdconta = crawcrd.nrdconta   AND
            crapcrd.nrctrcrd = crawcrd.nrctrcrd   AND
            crapcrd.dtaltddb = glb_dtmvtolt       
            NO-LOCK ON ERROR UNDO, LEAVE:
      
      CREATE tt-crawcrd.
      BUFFER-COPY crawcrd USING {&Campos-Vcto} TO tt-crawcrd
      ASSIGN tt-crawcrd.tpimpres = "VENCIMENTO"
             tt-crawcrd.tppessoa = Busca_Dados_Assoc(INPUT crawcrd.nrdconta,
                                                    OUTPUT tt-crawcrd.cdagenci).

  END. /* FOR EACH crawcrd - VENCIMENTO */
  /****************************************************************************/

  /****************************************************************************/
  /* Cancelamento */
  FOR EACH crawcrd FIELDS({&Campos-Canc}) 
      WHERE crawcrd.cdcooper = glb_cdcooper                 AND
            crawcrd.cdadmcrd = 3                            AND /*So Bradesco*/
            crawcrd.insitcrd = 5                            AND /*Cancelado*/
           (crawcrd.cdmotivo = 1 OR crawcrd.cdmotivo > 2)   AND /*Despr.Perda*/
            crawcrd.dtcancel = glb_dtmvtolt                     /*Roubo*/
            NO-LOCK ON ERROR UNDO, LEAVE:
      
      CREATE tt-crawcrd.
      BUFFER-COPY crawcrd USING {&Campos-Canc} TO tt-crawcrd
      ASSIGN tt-crawcrd.tpimpres = "CANCELAMENTO"
             tt-crawcrd.tppessoa = Busca_Dados_Assoc(INPUT crawcrd.nrdconta,
                                                    OUTPUT tt-crawcrd.cdagenci).

  END. /* FOR EACH crawcrd - CANCELAMENTO */
  /****************************************************************************/

END PROCEDURE. /* Busca_Dados */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Imprime_Dados:
 /* -> Imprimir todas as informacoes na mesma "folha/arquivo",continuar gerando
       arquivos separadamente p/ envio de e-mail's;
    -> Preparar rotina p/ gerar informacoes separadas por Bancos; */

  DEFINE VARIABLE aux_tpimpres AS CHARACTER NO-UNDO.
  DEFINE VARIABLE aux_contador AS INTEGER   NO-UNDO.

  {includes/cabrel132_2.i}

  /* Sequencia de Impressao */
  ASSIGN aux_tpimpres = "LIMITE,VENCIMENTO,CANCELAMENTO".

  FOR EACH tt-crawcrd
      BREAK BY tt-crawcrd.cdadmcrd ON ERROR UNDO, LEAVE:
      
      IF   FIRST-OF(tt-crawcrd.cdadmcrd)   THEN
           DO:
              
               FOR FIRST crapadc FIELDS(nmadmcrd dsendere nrcepend nmcidade 
                                        cdufende nmpescto dsdemail nmresadm)
                   WHERE crapadc.cdcooper = glb_cdcooper          AND
                         crapadc.cdadmcrd = tt-crawcrd.cdadmcrd 
                         NO-LOCK:

                   ASSIGN rel_nmadmcrd = crapadc.nmadmcrd 
                          rel_dsendere = crapadc.dsendere 
                          rel_nrcepend = crapadc.nrcepend
                          rel_nmcidade = crapadc.nmcidade
                          rel_cdufende = crapadc.cdufende
                          rel_nmpescto = crapadc.nmpescto
                          rel_nmresadm = crapadc.nmresadm.

               END. /* FOR FIRST crapadc */

               IF   NOT AVAILABLE crapadc   THEN
                    DO:
                        RUN Gera_Critica(605,"  CONTA --> " +
                                      STRING(tt-crawcrd.nrdconta,"zzzz,zz9,9")).
                    END.

               IF   FIRST(tt-crawcrd.cdadmcrd)   THEN
                    DO:
                        ASSIGN aux_nmarqimp = "rl/crrl480"+ ".lst".

                        OUTPUT STREAM str_2 TO VALUE (aux_nmarqimp) 
                                               PAGED PAGE-SIZE 84.
               
                        VIEW STREAM str_2 FRAME f_cabrel132_2.
                    END.

               DISPLAY STREAM str_2 rel_nmresadm
                       WITH FRAME f_admcrd.

               ASSIGN aux_regcance = FALSE
                      aux_reglimit = FALSE
                      aux_regvenci = FALSE.

               DO aux_contador = 1 TO NUM-ENTRIES(aux_tpimpres) 
                 ON ERROR UNDO, LEAVE:

                 CASE ENTRY(aux_contador,aux_tpimpres):
                    WHEN "LIMITE"       THEN 
                       DO:
                          ASSIGN aux_tiporela = "ALTERACOES DE LIMITE"
                                 aux_nmarqdat = "arq/crrl480_lim"      +
                                      STRING(DAY(glb_dtmvtolt),"99")   +
                                      STRING(MONTH(glb_dtmvtolt),"99") + ".dat"
                                 aux_nmarqbra = "salvar/crrl480_lim"   +
                                      STRING(DAY(glb_dtmvtolt),"99")   +
                                      STRING(MONTH(glb_dtmvtolt),"99") + ".xls".
                       END.
                        
                    WHEN "VENCIMENTO"   THEN
                       DO:
                          ASSIGN aux_tiporela = "ALTERACOES DE DATA DE " + 
                                                "VENCIMENTO"
                                 aux_nmarqdat = "arq/crrl480_vcto"     + 
                                      STRING(DAY(glb_dtmvtolt),"99")   +
                                      STRING(MONTH(glb_dtmvtolt),"99") + ".dat"
                                 aux_nmarqbra = "salvar/crrl480_vcto"  +
                                      STRING(DAY(glb_dtmvtolt),"99")   +
                                      STRING(MONTH(glb_dtmvtolt),"99") + ".xls".
                       END.

                    WHEN "CANCELAMENTO" THEN 
                       DO:
                    
                          ASSIGN aux_tiporela = "REF.: CANCELAMENTOS DE " + 
                                                "CARTOES"
                                 aux_nmarqdat = "rl/crrl480_can" + 
                                      STRING(tt-crawcrd.cdadmcrd,"99") + ".lst".

                          RUN Gera_Arquivo("ABRE_ARQ"). /* Abrir arquivo */

                          VIEW STREAM str_3 FRAME f_salto.                    

                          DISPLAY STREAM str_3  aux_nmcidade      aux_diamovto
                                                aux_mesmovto      aux_anomovto
                                                rel_nmadmcrd      rel_dsendere
                                                rel_nrcepend      rel_nmcidade
                                                rel_cdufende      rel_nmpescto
                                                WITH FRAME f_titulo.

                          DISPLAY STREAM str_3  aux_tiporela 
                                                WITH FRAME f_titulo1.

                          /* Espaçamento após o título do relatório */
                         IF CAN-FIND (FIRST btt-crawcrd 
                                      WHERE btt-crawcrd.cdadmcrd = tt-crawcrd.cdadmcrd 
                                        AND btt-crawcrd.tpimpres = "CANCELAMENTO") THEN
                             DISPLAY STREAM str_3 SKIP.

                       END.
                    OTHERWISE ASSIGN aux_tiporela = "".
                 END CASE.

                 IF   LOOKUP(ENTRY(aux_contador,aux_tpimpres),
                             "LIMITE,VENCIMENTO") <> 0   THEN
                      RUN Gera_Arquivo("ABRE_ARQ"). /* Abrir arquivo */

                 IF   ENTRY(aux_contador,aux_tpimpres) = "CANCELAMENTO"    THEN
                     DISPLAY STREAM str_2  SUBSTRING(aux_tiporela,7) @ 
                                           aux_tiporela
                                           WITH FRAME f_titulo1.
                 ELSE
                     DISPLAY STREAM str_2  aux_tiporela
                                           WITH FRAME f_titulo1.
                     
                 /* Espaçamento após o título do relatório */
                 IF CAN-FIND (FIRST btt-crawcrd 
                              WHERE btt-crawcrd.cdadmcrd = tt-crawcrd.cdadmcrd 
                                AND btt-crawcrd.tpimpres = ENTRY(aux_contador,aux_tpimpres)) THEN
                     DISPLAY STREAM str_2 SKIP(2).
                 
                 ASSIGN tot_qtcartao = 0.

                 FOR EACH btt-crawcrd 
                    WHERE btt-crawcrd.cdadmcrd = tt-crawcrd.cdadmcrd AND
                          btt-crawcrd.tpimpres = ENTRY(aux_contador,aux_tpimpres)
                          ON ERROR UNDO, LEAVE:

                    IF   LINE-COUNTER(str_2) >= 72   THEN
                         DO:
                             PAGE STREAM str_2.
                             VIEW STREAM str_2 FRAME f_salto.
                         END.

                    ASSIGN tot_qtcartao = tot_qtcartao + 1. 
                
                    CASE ENTRY(aux_contador,aux_tpimpres):
                       WHEN "LIMITE"         THEN 
                          DO:
                             DISPLAY STREAM str_2 btt-crawcrd.cdagenci
                                                  btt-crawcrd.nrdconta         
                                                  btt-crawcrd.tppessoa
                                                  btt-crawcrd.nmtitcrd 
                                                  btt-crawcrd.nrcrcard         
                                                  btt-crawcrd.vllimrea
                                                  btt-crawcrd.lirsaque
                                                  btt-crawcrd.vllimdol
                                                  btt-crawcrd.lidsaque       
                                                  WITH FRAME f_limite. 
                             
                             DOWN 2 STREAM str_2 WITH FRAME f_limite.

                             RUN Gera_Arquivo(ENTRY(aux_contador,aux_tpimpres)).

                             IF   NOT aux_reglimit THEN
                                  ASSIGN aux_reglimit = TRUE.

                             tot_qtctoalt = tot_qtctoalt + 1.
                          END.

                       WHEN "VENCIMENTO"     THEN 
                          DO:
                             DISPLAY STREAM str_2 btt-crawcrd.cdagenci
                                                  btt-crawcrd.nrdconta
                                                  btt-crawcrd.tppessoa
                                                  btt-crawcrd.nmtitcrd
                                                  btt-crawcrd.nrcrcard
                                                  btt-crawcrd.dddebito
                                                  WITH FRAME f_vcto.
                  
                             DOWN 2 STREAM str_2 WITH FRAME f_vcto.

                             RUN Gera_Arquivo(ENTRY(aux_contador,aux_tpimpres)).

                             IF   NOT aux_regvenci THEN
                                  ASSIGN aux_regvenci = TRUE.

                             tot_qtctoven = tot_qtctoven + 1.
                          END.

                       WHEN "CANCELAMENTO"   THEN 
                          DO:
                             DISPLAY STREAM str_2 btt-crawcrd.cdagenci
                                                  btt-crawcrd.nrdconta
                                                  btt-crawcrd.tppessoa
                                                  btt-crawcrd.nmtitcrd  
                                                  btt-crawcrd.nrcrcard
                                                  btt-crawcrd.dtcancel
                                                  WITH FRAME f_lanctos.
                  
                             DOWN 2 STREAM str_2 WITH FRAME f_lanctos.

                             DISPLAY STREAM str_3 btt-crawcrd.cdagenci
                                                  btt-crawcrd.nrdconta
                                                  btt-crawcrd.tppessoa
                                                  btt-crawcrd.nmtitcrd  
                                                  btt-crawcrd.nrcrcard
                                                  btt-crawcrd.dtcancel
                                                  WITH FRAME f_lanctos.
                  
                             DOWN 2 STREAM str_3 WITH FRAME f_lanctos.

                             IF   NOT aux_regcance THEN
                                  ASSIGN aux_regcance = TRUE.

                             tot_qtctocan = tot_qtctocan + 1.
                          END.
                
                    END CASE.

                    IF   NOT aux_regexist THEN
                         ASSIGN aux_regexist = TRUE. 
                 END. /* FOR EACH btt-crawcrd */

                 CASE ENTRY(aux_contador,aux_tpimpres):
                     WHEN "LIMITE"       THEN 
                     DO: 
                         /* Espaçamento antes do título de totalização */
                         IF tot_qtcartao > 0 THEN
                             DISPLAY STREAM str_2 SKIP.

                         DISPLAY STREAM str_2 tot_qtcartao 
                            WITH FRAME f_final_lim.
                     END.
                     WHEN "VENCIMENTO"   THEN 
                     DO: 
                         /* Espaçamento antes do título de totalização */
                         IF tot_qtcartao > 0 THEN
                             DISPLAY STREAM str_2 SKIP.

                         DISPLAY STREAM str_2 tot_qtcartao 
                            WITH FRAME f_final_venc.
                     END.
                     WHEN "CANCELAMENTO" THEN 
                         DO:
                             /* Espaçamento antes do título de totalização */
                             IF tot_qtcartao > 0 THEN
                                 DISPLAY STREAM str_2 SKIP.

                             DISPLAY STREAM str_2 tot_qtcartao 
                                 WITH FRAME f_final_canc.

                             DISPLAY STREAM str_3 tot_qtcartao 
                                 WITH FRAME f_final_canc.

                             IF   LINE-COUNTER(str_3) > 73   THEN
                                  DO:
                                      PAGE STREAM str_3.
                                      VIEW STREAM str_3.
                                  END.
                         END.
                 END CASE.

                 IF   LINE-COUNTER(str_2) > 73   THEN
                      DO:
                          PAGE STREAM str_2.
                          VIEW STREAM str_2.
                      END.
                      
                 IF   ENTRY(aux_contador,aux_tpimpres) = "CANCELAMENTO"   THEN
                      DO:
                          DISPLAY STREAM str_3 rel_nmressbr[1] rel_nmressbr[2] 
                              WITH FRAME f_credi.
                      END.
                      
                 IF ENTRY(aux_contador,aux_tpimpres) = "CANCELAMENTO" THEN
                     DISPLAY STREAM str_2 tot_qtctoalt tot_qtctoven tot_qtctocan
                         WITH FRAME f_total_sol.
                      
                 RUN Gera_Arquivo("FECH_ARQ"). /* Fechar arquivo */

                 IF   (aux_regcance AND ENTRY(aux_contador,aux_tpimpres) = "CANCELAMENTO") OR
                      (aux_regvenci AND ENTRY(aux_contador,aux_tpimpres) = "VENCIMENTO")   OR
                      (aux_reglimit AND ENTRY(aux_contador,aux_tpimpres) = "LIMITE")     THEN
                      DO:
                          RUN Enviar_Email(ENTRY(aux_contador,aux_tpimpres)).
                      END.

               END. /* DO aux_contador = 1 */

      END. /* IF FIRST-OF(tt-crawcrd.cdadmcrd) */

      IF   LAST(tt-crawcrd.cdadmcrd)   THEN
           DO:
               OUTPUT STREAM str_2 CLOSE.
               
               IF   NOT aux_regexist   THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null").
               
               UNIX SILENT VALUE ("rm " + aux_nmarqdat + " 2> /dev/null").
               
               ASSIGN glb_nmformul = "timbre"
                      glb_nmarqimp = aux_nmarqimp
                      glb_nrcopias = 1.
               
               RUN fontes/imprim.p.

           END. /* IF LAST(tt-crawcrd.cdadmcrd) */

  END. /* FOR EACH tt-crawcrd */


END PROCEDURE. /* Imprime_Dados */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Gera_Arquivo:
  DEFINE INPUT  PARAMETER aux_comando AS CHARACTER   NO-UNDO.

  CASE aux_comando:
      WHEN "ABRE_ARQ"  THEN  /* Abrir Arquivo */
          DO:
              OUTPUT STREAM str_3 TO VALUE (aux_nmarqdat) PAGED PAGE-SIZE 84.
          END.
      WHEN "FECH_ARQ"  THEN  /* Fechar Arquivo */
          DO:
              OUTPUT STREAM str_3 CLOSE.
          END.
      WHEN "LIMITE"  THEN 
          DO:                                     
             PUT STREAM str_3 btt-crawcrd.nrcrcard FORMAT "9999999999999999" ";"
                              btt-crawcrd.nmtitcrd                           ";"
                              btt-crawcrd.vllimrea FORMAT "zzzzzzzzz9"       ";"
                              "NO;NO;NO;NO;" 
                              aux_nmsolici                                   ";"
                              aux_dsdemail                                   ";"
                              SKIP.
          END.
      WHEN "VENCIMENTO" THEN
          DO:
             PUT STREAM str_3 btt-crawcrd.nrcrcard FORMAT "9999999999999999" ";"
                              btt-crawcrd.nmtitcrd                           ";"
                              btt-crawcrd.dddebito                           ";"
                              aux_nmsolici                                   ";"
                              aux_dsdemail                                   ";"
                              SKIP.
          END.
  END CASE.

END PROCEDURE. /* Gera_Arquivo */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Enviar_Email:

  DEFINE INPUT  PARAMETER aux_comando AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_assuntoe AS CHARACTER   NO-UNDO.

  &SCOPED-DEFINE CANC aux_comando = "CANCELAMENTO"

  ASSIGN glb_cdcritic = 655.
  RUN fontes/critic.p.

  RUN sistema/generico/procedures/b1wgen0011.p
      PERSISTENT SET b1wgen0011.

  IF   NOT VALID-HANDLE(b1wgen0011)   THEN
       DO:
           RUN Gera_Critica(0,"Handle invalido!").
       END.

  CASE aux_comando:
      WHEN "LIMITE"  THEN 
          DO:   
              /*** Transforma arquivo de dados em arquivo .xls ***/ 
              UNIX SILENT VALUE
                ("/usr/local/cecred/bin/AlteraLimiteBradesco.pl " +
                  aux_nmarqdat + " " + aux_nmarqbra).

              ASSIGN aux_assuntoe = "ALTERACOES DE LIMITE".
          END.
      WHEN "VENCIMENTO" THEN
          DO:                   
              /*** Transforme arquivo de dados em arquivo excel ***/
              UNIX SILENT VALUE
                ("/usr/local/cecred/bin/AlteraDataBradesco.pl " + 
                  aux_nmarqdat + " " + aux_nmarqbra).

              ASSIGN aux_assuntoe = "ALTERACOES DE DATA DE " + 
                                      "VENCIMENTO".
          END.
      WHEN "CANCELAMENTO"  THEN
          DO:
              RUN converte_arquivo IN b1wgen0011
                  (INPUT glb_cdcooper,
                   INPUT aux_nmarqdat,
                   INPUT SUBSTRING(aux_nmarqdat,4,14) + "doc").

              ASSIGN aux_assuntoe = "CANCELAMENTO DE " + 
                                    "CARTOES DE CREDITO".
          END.

  END CASE.

  IF   NOT {&CANC}   THEN /* Se nao for cancelamento */ 
       DO:
           /* Move para diretorio converte para utilizar na BO */
           UNIX SILENT VALUE
             ("cp " + aux_nmarqbra + " /usr/coop/" +
               crapcop.dsdircop + "/converte" + " 2> /dev/null").
       END.

  RUN enviar_email IN b1wgen0011
           (INPUT glb_cdcooper,
            INPUT glb_cdprogra,
            INPUT crapadc.dsdemail,
            INPUT aux_assuntoe + (IF {&CANC} THEN "" 
                  ELSE " - " + CAPS(crapcop.nmrescop)),
            INPUT (IF {&CANC} THEN SUBSTRING(aux_nmarqdat,4,14) + "doc"
                   ELSE SUBSTR(aux_nmarqbra,8)),  
            INPUT (NOT {&CANC})).
  
  IF   VALID-HANDLE(b1wgen0011)   THEN
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
  QUIT.

END PROCEDURE. /* Gera_Critica */
/******************************************************************************/

/******************************************************************************/
PROCEDURE p_divinome:

  DEF   VAR aux_qtpalavr AS INTE                                      NO-UNDO.
  DEF   VAR aux_contapal AS INTE                                      NO-UNDO.

  /******* Divide o campo crapcop.nmextcop em duas Strings *******/
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                        rel_nmrescop = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
     IF   aux_contapal <= aux_qtpalavr   THEN
          rel_nmrescop[1] = rel_nmrescop[1] +   
                      (IF TRIM(rel_nmrescop[1]) = "" THEN "" ELSE " ") 
                           + ENTRY(aux_contapal,crapcop.nmextcop," ").
     ELSE
          rel_nmrescop[2] = rel_nmrescop[2] +
                      (IF TRIM(rel_nmrescop[2]) = "" THEN "" ELSE " ") + 
                       ENTRY(aux_contapal,crapcop.nmextcop," ").
  END.  /*  Fim DO .. TO  */ 
           
  ASSIGN rel_nmrescop[1] = 
           FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) + rel_nmrescop[1]
         rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                           rel_nmrescop[2].

END PROCEDURE. /* p_dividenome */
/******************************************************************************/

/******************************************************************************/
PROCEDURE Lista_Cartoes_Entregues:

DEF VAR aux_dtentreg   AS DATE FORMAT 99/99/9999   NO-UNDO.
DEF VAR aux_nmarquiv   AS CHAR                     NO-UNDO.

    /*Alterar o nome do arquivo*/
    ASSIGN aux_dtentreg = glb_dtmvtolt
           aux_nmarquiv = "cartoes_bradesco_" + STRING(glb_dtmvtolt,"99999999") + 
                          ".txt".

    FOR EACH crapcop NO-LOCK 
       WHERE NOT crapcop.cdcooper = 3,
        EACH crawcrd NO-LOCK 
       WHERE crawcrd.cdcooper = crapcop.cdcooper AND
             crawcrd.cdadmcrd = 3                AND
             crawcrd.insitcrd = 4                AND
             crawcrd.dtentreg = aux_dtentreg,
        FIRST craptlc NO-LOCK
        WHERE craptlc.cdcooper = crawcrd.cdcooper AND
              craptlc.cdadmcrd = crawcrd.cdadmcrd AND
              craptlc.tpcartao = crawcrd.tpcartao AND
              craptlc.cdlimcrd = crawcrd.cdlimcrd AND
              craptlc.dddebito = 0:
    
        CREATE tt-cartoes.
        ASSIGN tt-cartoes.cdcooper = crapcop.cdcooper
               tt-cartoes.nmrescop = crapcop.nmrescop
               tt-cartoes.nrdconta = crawcrd.nrdconta
               tt-cartoes.nrcrcard = crawcrd.nrcrcard
               tt-cartoes.nmtitcrd = crawcrd.nmtitcrd
               tt-cartoes.vllimcrd = craptlc.vllimcrd
               tt-cartoes.dtentreg = crawcrd.dtentreg.
    END.

    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
    
    FOR EACH tt-cartoes NO-LOCK 
        BREAK BY tt-cartoes.cdcooper
              BY tt-cartoes.nrcrcard:
    
        IF FIRST-OF (tt-cartoes.cdcooper) THEN
        DO:
          DISPLAY STREAM str_1 tt-cartoes.nmrescop FORMAT "X(20)" NO-LABEL 
              WITH FRAME f_cooper.
        END.
    
        DISPLAY STREAM str_1
            tt-cartoes.cdcooper COLUMN-LABEL "Coop"
            tt-cartoes.nrdconta
            tt-cartoes.nrcrcard
            tt-cartoes.nmtitcrd COLUMN-LABEL "Portador"
            tt-cartoes.vllimcrd COLUMN-LABEL "Valor do Limite"
            tt-cartoes.dtentreg
            WITH WIDTH 130.
    END.
    
    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + " salvar 2>/dev/null"). 

    UNIX SILENT VALUE("cp salvar/" + aux_nmarquiv + " salvar/" + aux_nmarquiv + "_copy"). 

    UNIX SILENT VALUE("ux2dos salvar/" + aux_nmarquiv  + "_copy" + 
                      " > salvar/" + aux_nmarquiv + " 2>/dev/null").
    
    UNIX SILENT VALUE("rm salvar/" + aux_nmarquiv + "_copy").

    /* ENVIAR E-MAIL */
    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET b1wgen0011.

    IF NOT VALID-HANDLE(b1wgen0011) THEN
    DO:
        RUN Gera_Critica(0,"Handle invalido!").
    END.
    ELSE
    DO:
        RUN converte_arquivo IN b1wgen0011
                             (INPUT glb_cdcooper,
                              INPUT "salvar/" + aux_nmarquiv,
                              INPUT aux_nmarquiv).

        RUN enviar_email IN b1wgen0011
                   (INPUT glb_cdcooper,
                    INPUT glb_cdprogra,
                    INPUT "cartoes@cecred.coop.br",
                    INPUT "Cartoes Bradesco " + STRING(aux_dtentreg,"99999999"),
                    INPUT (aux_nmarquiv),
                    INPUT TRUE).

        IF VALID-HANDLE(b1wgen0011) THEN
            DELETE PROCEDURE b1wgen0011.
    END.

END PROCEDURE.
/******************************************************************************/

/**************************** FIM - PROCEDURES ********************************/

