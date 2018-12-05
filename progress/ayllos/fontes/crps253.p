/*** CUIDADO - CUIDADO - CUIDADO 
     PROGRAMA MANDA E_MAIL PARA A EMPRESA QUE FABRICA O CARTAO
     MAGNETICO - COLOCAR COMENTARIO PARA TESTES ***/
/* .............................................................................

   Programa: Fontes/crps253.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/1999.                      Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Mensal ou por solicitacao.
   Objetivo  : Gerar arquivo com dados para emissao dos cartoes magneticos
               FORNECEDOR: ABNC
               Atende a solicitacao 82, ordem 60. Emite relatorio 206 (laser).

               29/12/1999 - Nao gerar mais pedido de impressao (Edson).

               04/01/2000 - Acerto nas mensagens (Deborah).

               10/02/2000 - Trocar ABNC para CBS e gerar pedido de impressao
                            (Deborah).

               14/04/2000 - Utilizar o numero de agencia do crapcop (Edson).

               18/01/2001 - Colocar frame para assinatura (Deborah).
               
               31/07/2001 - Mudar o nome do arquivo e copia-lo para o 
                            /micros (Junior).
                            
               08/03/2002 - Mostrar no relatorio renovacao de cartao magnetico
                            quando estiver vencido (Junior).

               09/09/2002 - Mudanca da CBS para Intelcav - VIACREDI (Deborah)

               19/09/2002 - Alterado para enviar arquivo de cartoes de C/C
                            automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando "MT SEND" (Junior).

               19/05/2003 - Ajustes para o cartao novo da Creditextil (Deborah)

               25/06/2003 - Mudanca do email (Edson).

               27/12/2004 - Ajustes para o cartao novo da Creditextil
                            Cartoes de operadores  (Edson).

               12/01/2005 - Alterado o termo TRANSMISSAO por RECEPCAO (Edson).
               
               30/06/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               28/10/2005 - Arquivo enviado por e_mail para Makelly(Mirtes)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               09/01/2007 - Incluido nome da cooperativa(email)(Mirtes)
               
               14/02/2007 - Alterado envio de e-mail de makelly@cecred.coop.br
                            para jonathan@cecred.coop.br (Elton).
                              
               23/05/2007 - Substituido caracteres especiais($ @ # ; ?) por
                            virgula (Guilherme).
               
               04/06/2007 - Alterado nome arquivo envio de e_mail(Mirtes)
               
               15/06/2007 - Separar campos por virgula(Mirtes).
               
               23/08/2007 - Enviar email com assunto diferenciado p/ cartoes
                            magneticos do tipo operador aux_tptitcar(Guilherme)
                            
               08/09/2007 - Cobranca para emitir 2 via cartao (Guilherme).
               
               20/11/2007 - Logar quando der erro na b1wgen0022
                          - Adicionado parametros na gera_lancamento(Guilherme).

               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)

               25/03/2009 - Rodar imprim.p mesmo se o relatorio 206 estiver
                            zerado
                          - Nao gerar craptab AUTOMA se nao existir solicitacao
                            de cartao (David).
                
               17/09/2009 - Nao cobrar tarifa da segunda via de cartoes magne-
                            ticos dos operadores (Fernando).
                            
               08/12/2009 - Alterar email de envio 
                            producao@grupocartaosul.com.br
                            cris@grupocartaosul.com.br (Guilherme).
                            
               23/12/2009 - Alterar formulario 132m para 132dm (David).
               
               26/07/2010 - Criado resumo ao final do relatorio com quantidade
                            de cartoes por PAC e o total (Adriano).
                            
               03/08/2010 - Adicionado emails de envio
                            arquivos@fbcards.com.br
                            fernanda@cecred.coop.br
                            fernanda.eccher@cecred.coop.br
                            lidianevieira@fbcards.com.br
                            daianedesidor@fbcards.com.br
                            Removido o email
                            jonathan@cecred.coop.br (Guilherme).
                            
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme).
               
               30/01/2013 - Excluidos os resumos de 'Quantidade Geral de Cartões' de 
                            associados e operadores para imprimir quantidades gerais 
                            de todos os cartões ao final do rel.260 (Lucas).
                            
               04/06/2013 - Retirado leitura craptab e retirado verificacao do valor
                            tarifa segunda via do cartao quando zerada (Daniel).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/01/2014 - Inclusao de VALIDATE craptab (Carlos)

               26/05/2014 - Alterado a geracao de segunda para quarta e sexta
                            (Douglas - Chamado 139166).
                            
               10/09/2014 - Retiradoo envio de e-mail aos destinatarios
                            abaixo:
                             - daianedesidor@fbcards.com.br
                             - lidianevieira@fbcards.com.br
                             - cris@grupocartaosul.com.br
                             - producao@grupocartaosul.com.br 
                            (Adriano - Chamado 182120).
               
               24/07/2015 - Alterado para nao mostrar o Limite e Saque
                            no relatorio. (James)
                            
               26/08/2015 - ALterado parametro par_cdpesqbb da chamada
                            da procedure gera_lancamento Prj. Tarifas 218 
                            (Jean Michel).             

			   28/04/2016 - Adicionada chamada para a procedure 
							pc_verifica_tarifa_operacao para verificar a isencao
							ou nao da cobranca de tarifa. PRJ 218/2. (Reinert)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

			   13/11/2018 - Adicionada parametros a procedure 
							pc_verifica_tarifa_operacao. PRJ 345. (Fabio Stein - Supero)

............................................................................. */

DEF STREAM str_1.  /*  Para relatorio dos cartoes magneticos  */
DEF STREAM str_2.  /*  Para o arquivo de saida */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF TEMP-TABLE tt-erro LIKE craperr.
DEF VAR par_flgtarif AS LOG.

DEF        VAR par_dscritic LIKE crapcri.dscritic                    NO-UNDO.
DEF        VAR b1wgen0022   AS HANDLE                                NO-UNDO.
DEF        VAR b1wgen0011   AS HANDLE                                NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtvalida AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR                                  NO-UNDO.
DEF        VAR rel_nvoperad AS CHAR                                  NO-UNDO.
DEF        VAR rel_tpoperad AS CHAR                                  NO-UNDO.

DEF        VAR tot_qtcartao AS INT                                   NO-UNDO.
DEF        VAR age_qtcartao AS INT                                   NO-UNDO.
DEF        VAR aux_qtcartas AS INT                                   NO-UNDO.
DEF        VAR tot_qtcartop AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl206.lst"         NO-UNDO.
DEF        VAR aux_nmarqsai AS CHAR                                  NO-UNDO.

DEF        VAR aux_nvoperad AS CHAR
               INIT "OPERADOR,SUPERVISOR,GERENTE"                    NO-UNDO.
               
DEF        VAR aux_tpoperad AS CHAR      
   INIT "TERMINAL,CAIXA,TERMINAL + CAIXA,RETAGUARDA,CASH + RETAGUARDA" NO-UNDO.

DEF        VAR aux_nrseqcar AS INT                                   NO-UNDO.
DEF        VAR rel_inrenova AS CHAR                                  NO-UNDO.

DEF        VAR aux_tptitcar AS INT                                   NO-UNDO.
DEF        VAR aux_vltr2via AS DECI                                  NO-UNDO.

DEF        VAR aux_qtacobra AS INTE                                  NO-UNDO.
DEF        VAR aux_fliseope AS INTE                                  NO-UNDO.
DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

FORM "CONTA/DV  TITULAR DO CARTAO" AT 3
     "NUMERO DO CARTAO REN VALIDADE  TITULAR DA CONTA" AT 44
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label.

FORM "CARTAO PARA OPERADORES" 
     SKIP(1)
     "OPERADOR  TITULAR DO CARTAO" AT 1
     "NUMERO DO CARTAO REN VALIDADE  NIVEL            TIPO" AT 44
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_ope.

FORM crapcrm.nrdconta AT   1 FORMAT "zzzz,zzz,9"
     crapcrm.nmtitcrd AT  13 FORMAT "x(28)"
     crapcrm.nrcartao AT  41 FORMAT "9999,9999,9999,9999"
     rel_inrenova     AT  62 FORMAT "x(1)"
     rel_dtvalida     AT  66 FORMAT "x(7)"
     crapass.nmprimtl AT  75 FORMAT "x(50)"
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_magnetico.
 
FORM crapcrm.nrdconta AT   5 FORMAT "zzz9"
     crapcrm.nmtitcrd AT  11 FORMAT "x(28)"
     crapcrm.nrcartao AT  41 FORMAT "9999,9999,9999,9999"
     rel_inrenova     AT  62 FORMAT "x(1)"
     rel_dtvalida     AT  66 FORMAT "x(7)"
     rel_nvoperad     AT  75 FORMAT "x(15)"
     rel_tpoperad     AT  92 FORMAT "x(25)"
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_magnetico_ope.

FORM rel_dsagenci AT 2 FORMAT "x(25)" LABEL "PA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS FRAME f_agencia.

FORM SKIP(1)
     age_qtcartao AT 1 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE CARTOES DO PA"
     WITH NO-BOX SIDE-LABELS FRAME f_total.

FORM SKIP(1)
     "***** CARTOES MAGNETICOS PARA AUTO-ATENDIMENTO *****" AT 24
     SKIP(1)
     glb_dtmvtolt AT 36 FORMAT "99/99/9999" LABEL "DATA DO PEDIDO"
     SKIP(1)
     aux_qtcartas AT 24 FORMAT "zzz,zz9" LABEL "QUANTIDADE GERAL DE CARTOES PARA ASSOCIADOS"
     SKIP(1)
     tot_qtcartop AT 24 FORMAT "zzz,zz9" LABEL "QUANTIDADE GERAL DE CARTOES PARA OPERADORES"
     SKIP(3)
     "ENVIADO EM:  ____/____/____  -  VISTO: _____________________"  AT 21
     SKIP(4)
     "RECEBIDO EM:  ____/____/____  -  VISTO: _____________________" AT 20
     WITH NO-BOX SIDE-LABELS FRAME f_total_geral. 

DEF TEMP-TABLE tt-cartaoas NO-UNDO
    FIELD aux_cdagenci     LIKE crapass.cdagenci
    FIELD aux_dsagenci     AS CHAR FORMAT "x(35)"
    FIELD aux_qtcartao     AS INT  FORMAT "zzz,zz9"
    INDEX tt-cartaoas aux_dsagenci aux_qtcartao.
    
DEF TEMP-TABLE tt-cartaoop NO-UNDO
    FIELD aux_cdagenci     LIKE crapope.cdagenci
    FIELD aux_dsagenci     AS CHAR FORMAT "x(25)"
    FIELD aux_qtcartao     AS INT  FORMAT "zzz,zz9"
    INDEX tt-cartaoop aux_dsagenci aux_qtcartao.

FORM "RESUMO GERAL DE CARTOES PARA ASSOCIADOS" SKIP(2)
     "PA" AT 10
     "QUANTIDADE" AT 68 SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_dsresumo_ass.

FORM "RESUMO GERAL DE CARTOES PARA OPERADORES" SKIP(2)
     "PA" AT 10
     "QUANTIDADE" AT 68 SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_dsresumo_ope.

FORM tt-cartaoas.aux_dsagenci AT 1
     tt-cartaoas.aux_qtcartao AT 71 SKIP
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_resumo_ass.

FORM tt-cartaoop.aux_dsagenci AT 1
     tt-cartaoop.aux_qtcartao AT 71 SKIP
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_resumo_ope.

FORM SKIP(1)
     "TOTAL" AT 63
     aux_qtcartas AT 71 FORMAT "zzz,zz9"
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_totresumo_ass.

FORM SKIP(1)
     "TOTAL" AT 63
     tot_qtcartao AT 71 FORMAT "zzz,zz9" 
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_totresumo_ope.

glb_cdprogra = "crps253".  
RUN fontes/iniprg.p.

glb_cdrelato[1] = 206.

IF  glb_cdcritic > 0   THEN
    RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.
ELSE
     aux_nmarqsai = "cm_arq" + STRING(glb_dtmvtolt,"99999999") +
     "_" + string(glb_cdcooper,"99") +    ".dat".

IF  glb_dtmvtolt <> 04/18/2008 THEN DO:
    /* Vamos gerar apenas na quarta e na sexta */
    IF   NOT CAN-DO("4,6",STRING(WEEKDAY(glb_dtmvtolt))) THEN
        DO:
            RUN fontes/fimprg.p.
            RETURN.
        END.
END.

{ includes/cabrel132_1.i }

IF   glb_inrestar = 0   THEN
     DO:
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
         OUTPUT STREAM str_2 TO VALUE("arq/" +  aux_nmarqsai).

         VIEW STREAM str_1 FRAME f_cabrel132_1.

         /*  Leitura dos cartoes a serem confeccionados para ASSOCIADOS ..... */
         FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper   AND
                                crapcrm.dtemscar = ?              AND
                                crapcrm.cdsitcar = 1              AND
                                crapcrm.tptitcar = 1              NO-LOCK,
             EACH crapass WHERE crapass.cdcooper = glb_cdcooper         AND
                                crapass.nrdconta = crapcrm.nrdconta     NO-LOCK
                                BREAK BY crapass.cdagenci
                                      BY crapass.nrdconta
                                      BY crapcrm.nrcartao:

             IF   FIRST-OF(crapass.cdagenci)   THEN
                  DO:
                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = crapass.cdagenci
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapage   THEN
                           rel_dsagenci = STRING(crapass.cdagenci,"zz9") +
                                          " - " + FILL("*",15).
                      ELSE
                           rel_dsagenci = STRING(crapage.cdagenci,"zz9") +
                                          " - " + crapage.nmresage.

                      DISPLAY STREAM str_1
                              rel_dsagenci WITH FRAME f_agencia.
             
                      VIEW STREAM str_1 FRAME f_label.
                  END.

             IF   crapcrm.nrviacar = 2  THEN
                  rel_inrenova = "R".
             ELSE
                  rel_inrenova = "".
             
             ASSIGN age_qtcartao = age_qtcartao + 1
                    aux_nrseqcar = aux_nrseqcar + 1
                    
                    rel_dtvalida = STRING(MONTH(crapcrm.dtvalcar),"99") + "/" +
                                   STRING(YEAR(crapcrm.dtvalcar),"9999").
             
             
             DISPLAY STREAM str_1
                     crapcrm.nrdconta  crapcrm.nmtitcrd  crapcrm.nrcartao
                     rel_inrenova      rel_dtvalida      crapass.nmprimtl
                     WITH FRAME f_magnetico.
                     
             DOWN STREAM str_1 WITH FRAME f_magnetico.
                    
             IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.
                      
                      DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.
                      
                      VIEW STREAM str_1 FRAME f_label.
                  END.
                  
             /*  Gera arquivo para ABNC  */
             
             IF   glb_cdcooper = 2 THEN   /* Monta linha 2 especial para a 
                                               Creditextil */
                  DO:
                      PUT STREAM str_2 
                          aux_nrseqcar     FORMAT "999999" ","
                          STRING(crapcrm.nrcartao,"9999999999999999") 
                                FORMAT "xxxx xxxx xxxx xxxx" "," 
                          TRIM(STRING(crapcrm.nrdconta,"zzzz,zzz,9"))   
                          ","
                          crapcrm.tpusucar FORMAT "99"                  ","
                          rel_dtvalida     FORMAT "x(7)"                ","
                          crapcrm.nmtitcrd FORMAT "x(30)"               ","
                          "5756"
                          crapcop.cdagebcb FORMAT "9999"
                          crapcrm.nrdconta FORMAT "99999999"
                          "="
                          MONTH(crapcrm.dtvalcar) FORMAT "99"
                          YEAR(crapcrm.dtvalcar)  FORMAT "9999"
                          crapcrm.tptitcar        FORMAT "99"
                          crapcrm.tpusucar        FORMAT "99"
                          "0000"
                          crapcrm.nrseqcar        FORMAT "999999" ","
                          SKIP.                  
                  END.
             ELSE
                  DO:
                      PUT STREAM str_2 
                          aux_nrseqcar     FORMAT "999999" ","
                          STRING(crapcrm.nrcartao,"9999999999999999") 
                                FORMAT "xxxx xxxx xxxx xxxx" "," 
                          crapcrm.nrdconta FORMAT "zzzz,zzz,9"          ","
                          crapcrm.tpusucar FORMAT "99"                  ","
                          rel_dtvalida     FORMAT "x(7)"                ","
                          crapcrm.nmtitcrd FORMAT "x(30)"               ","
                          "5756"
                          crapcop.cdagebcb FORMAT "9999"
                          crapcrm.nrdconta FORMAT "99999999"
                          "="
                          MONTH(crapcrm.dtvalcar) FORMAT "99"
                          YEAR(crapcrm.dtvalcar)  FORMAT "9999"
                          crapcrm.tptitcar        FORMAT "99"
                          crapcrm.tpusucar        FORMAT "99"
                          "0000"
                          crapcrm.nrseqcar        FORMAT "999999" ","
                          SKIP.                  
                  END.
                  
             IF   LAST-OF(crapass.cdagenci)   THEN
                  DO:
                      DISPLAY STREAM str_1
                              age_qtcartao WITH FRAME f_total.

                      PAGE STREAM str_1.

                      ASSIGN tot_qtcartao = tot_qtcartao + age_qtcartao.
                             
                      aux_qtcartas = tot_qtcartao.

                      FIND FIRST tt-cartaoas WHERE
                                 tt-cartaoas.aux_cdagenci = crapass.cdagenci
                                 NO-LOCK NO-ERROR.
                      
                      IF NOT AVAIL tt-cartaoas THEN
                      DO:
                         CREATE tt-cartaoas.
                         ASSIGN tt-cartaoas.aux_cdagenci = crapass.cdagenci
                                tt-cartaoas.aux_dsagenci = rel_dsagenci
                                tt-cartaoas.aux_qtcartao = age_qtcartao.
                                
                      END.
                      age_qtcartao = 0.
                  END.

         END.  /*  Fim do FOR EACH  --  Leitura dos cartoes  */

         ASSIGN aux_tptitcar = 0 
                tot_qtcartao = 0.

         OUTPUT STREAM str_1 CLOSE.
         
         IF   aux_nrseqcar > 0   THEN
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) 
                                     PAGED PAGE-SIZE 84 APPEND.
         ELSE
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

         VIEW STREAM str_1 FRAME f_cabrel132_1.

         VIEW STREAM str_1 FRAME f_label_ope.
 
         /*  Leitura dos cartoes a serem confeccionados para OPERADORES ..... */

         FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper     AND
                                crapcrm.dtemscar = ?                AND
                                crapcrm.cdsitcar = 1                AND
                                crapcrm.tptitcar = 9                NO-LOCK,
             EACH crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                                crapope.cdoperad = STRING(crapcrm.nrdconta)
                                NO-LOCK BREAK BY crapope.cdagenci
                                              BY crapcrm.nrdconta
                                              BY crapcrm.nrcartao:
                                              
             ASSIGN aux_tptitcar = 9
                    tot_qtcartao = tot_qtcartao + 1
                    aux_nrseqcar = aux_nrseqcar + 1
                    rel_dtvalida = STRING(MONTH(crapcrm.dtvalcar),"99") + "/" +
                                   STRING(YEAR(crapcrm.dtvalcar),"9999").

             FIND FIRST tt-cartaoop WHERE
                        tt-cartaoop.aux_cdagenci = crapope.cdagenci
                        NO-LOCK NO-ERROR.
                      
                  IF  NOT AVAIL tt-cartaoop THEN
                      DO:
                         FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                            crapage.cdagenci = crapope.cdagenci
                                            NO-LOCK NO-ERROR.

                         IF   NOT AVAILABLE crapage   THEN
                              rel_dsagenci = STRING(crapass.cdagenci,"zz9") +
                                             " - " + FILL("*",15).
                         ELSE
                              rel_dsagenci = STRING(crapage.cdagenci,"zz9") +
                                             " - " + crapage.nmresage.
                         CREATE tt-cartaoop.
                         ASSIGN tt-cartaoop.aux_cdagenci = crapope.cdagenci
                                tt-cartaoop.aux_dsagenci = rel_dsagenci
                                tt-cartaoop.aux_qtcartao = 1.
                      END.
                 ELSE
                    DO:
                        ASSIGN tt-cartaoop.aux_qtcartao = (tt-cartaoop.aux_qtcartao + 1).
                    END.

             IF   crapope.nvoperad > NUM-ENTRIES(aux_nvoperad)   THEN
                  rel_nvoperad = "** N/C ** " .
             ELSE                   
                  rel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad).

             IF   crapope.tpoperad > NUM-ENTRIES(aux_tpoperad)   THEN
                  rel_tpoperad = "** N/C ** " .
             ELSE
                  rel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad).
             
             IF   crapcrm.nrviacar = 2  THEN
                  rel_inrenova = "R".
             ELSE
                  rel_inrenova = "".
             
             DISPLAY STREAM str_1
                     crapcrm.nrdconta  crapcrm.nmtitcrd  crapcrm.nrcartao
                     rel_inrenova      rel_dtvalida      rel_nvoperad      
                     rel_tpoperad    
                     WITH FRAME f_magnetico_ope.
                     
             DOWN STREAM str_1 WITH FRAME f_magnetico_ope.
                    
             IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.
                      
                      VIEW STREAM str_1 FRAME f_label_ope.
                  END.
                  
             /*  Gera arquivo para ABNC  */
             
             IF   glb_cdcooper = 2 THEN   /* Monta linha 2 especial para a 
                                               Creditextil */
                  DO:
                      PUT STREAM str_2 
                          aux_nrseqcar     FORMAT "999999" ","
                          STRING(crapcrm.nrcartao,"9999999999999999") 
                          FORMAT "xxxx xxxx xxxx xxxx" "," 
                          crapcrm.nrdconta FORMAT "9999"                ","
                          rel_nvoperad     FORMAT "x(10)"               ","
                          rel_dtvalida     FORMAT "x(7)"                ","
                          crapcrm.nmtitcrd FORMAT "x(30)"               ","
                          "5756"
                          crapcop.cdagebcb FORMAT "9999"
                          crapcrm.nrdconta FORMAT "99999999"
                          "="
                          MONTH(crapcrm.dtvalcar) FORMAT "99"
                          YEAR(crapcrm.dtvalcar)  FORMAT "9999"
                          crapcrm.tptitcar        FORMAT "99"
                          crapcrm.tpusucar        FORMAT "99"
                          crapope.tpoperad        FORMAT "99"
                          crapope.nvoperad        FORMAT "99"
                          crapcrm.nrseqcar        FORMAT "999999" ","
                          SKIP.                  
                  END.
             ELSE
                  DO:
                      PUT STREAM str_2 
                          aux_nrseqcar     FORMAT "999999" ","
                          STRING(crapcrm.nrcartao,"9999999999999999") 
                          FORMAT "xxxx xxxx xxxx xxxx" "," 
                          crapcrm.nrdconta FORMAT "9999"                ","
                          rel_nvoperad     FORMAT "x(10)"               ","
                          crapope.nvoperad FORMAT "99"                  ","
                          rel_dtvalida     FORMAT "x(7)"                ","
                          crapcrm.nmtitcrd FORMAT "x(30)"               ","
                          "5756"
                          crapcop.cdagebcb FORMAT "9999"
                          crapcrm.nrdconta FORMAT "99999999"
                          "="
                          MONTH(crapcrm.dtvalcar) FORMAT "99"
                          YEAR(crapcrm.dtvalcar)  FORMAT "9999"
                          crapcrm.tptitcar        FORMAT "99"
                          crapcrm.tpusucar        FORMAT "99"
                          crapope.tpoperad        FORMAT "99"
                          crapope.nvoperad        FORMAT "99"
                          crapcrm.nrseqcar        FORMAT "999999" ","
                          SKIP.                  
                  END.

         END.  /*  Fim do FOR EACH  --  Leitura dos cartoes  */

         tot_qtcartop = tot_qtcartao.

         PAGE STREAM str_1.
         
         VIEW STREAM str_1 FRAME f_dsresumo_ass.

         FOR EACH tt-cartaoas NO-LOCK:

             DISPLAY STREAM str_1
                           tt-cartaoas.aux_dsagenci
                           tt-cartaoas.aux_qtcartao
                           WITH FRAME f_resumo_ass.

            DOWN STREAM str_1 WITH FRAME f_resumo_ass.
         
         END.
         

         DISPLAY STREAM str_1 
                        aux_qtcartas
                        WITH FRAME f_totresumo_ass.

         PAGE STREAM str_1.

         VIEW STREAM str_1 FRAME f_dsresumo_ope.
         
         FOR EACH tt-cartaoop NO-LOCK:
         
             DISPLAY STREAM str_1
                           tt-cartaoop.aux_dsagenci
                           tt-cartaoop.aux_qtcartao
                           WITH FRAME f_resumo_ope.
            
             DOWN STREAM str_1 WITH FRAME f_resumo_ope.
         
         END.
         
         DISPLAY STREAM str_1 
                        tot_qtcartao   
                        WITH FRAME f_totresumo_ope.


         /* OUTPUT STREAM str_1 CLOSE. */
         OUTPUT STREAM str_2 CLOSE.

         DO TRANSACTION ON ERROR UNDO, RETURN:

            DO WHILE TRUE:

               FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                                  crapres.cdprogra = glb_cdprogra
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crapres   THEN
                    IF   LOCKED crapres   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 151.
                             RUN fontes/critic.p.
                             UNIX SILENT VALUE("echo " + 
                                               STRING(TIME,"HH:MM:SS") +
                                               " - " + glb_cdprogra + 
                                               "' --> '" + glb_dscritic +
                                               " >> log/proc_batch.log").
                             UNDO, RETURN.
                         END.
               ELSE
                    LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            crapres.nrdconta = 1.

         END.  /*  Fim da transacao  */
     END.

PAGE STREAM str_1.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 glb_dtmvtolt
                     aux_qtcartas
                     tot_qtcartop
               WITH FRAME f_total_geral.

OUTPUT STREAM str_1 CLOSE.
     

/* Inicializa o processo de atualizacao dos cartoes magneticos */
FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper  AND
                       crapcrm.dtemscar = ?             AND
                       crapcrm.cdsitcar = 1
                       EXCLUSIVE-LOCK
                       TRANSACTION ON ERROR UNDO, RETURN:

    FIND crapass WHERE crapass.cdcooper = crapcrm.cdcooper AND
                       crapass.nrdconta = crapcrm.nrdconta
                       NO-LOCK NO-ERROR.
    /* Este comentario refere-se ao modo antigo
       "Se nrsencar igual a 1000000 cartao solicitado pelo sistema,
       os que estao para vencer, entao nao pode tarifar" */
    IF   crapcrm.dssencar = "NAOTARIFA"   THEN  
         crapcrm.dtemscar = glb_dtmvtolt.
    ELSE
         DO:
             ASSIGN crapcrm.dtemscar = glb_dtmvtolt.

             RUN sistema/generico/procedures/b1wgen0022.p
             PERSISTENT SET b1wgen0022.
             
             IF   VALID-HANDLE(b1wgen0022) THEN 
                  DO:
                    /* Verifica se eh segunda via */
                    RUN verifica_2via IN b1wgen0022 (INPUT glb_cdcooper, 
                                                     INPUT crapcrm.nrdconta, 
                                                     INPUT crapcrm.nrcartao, 
                                                     INPUT glb_dtmvtolt,
                                                     OUTPUT par_flgtarif, 
                                                     OUTPUT TABLE tt-erro).
                    
                    IF   RETURN-VALUE = "NOK"  THEN
                         DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                            IF  AVAILABLE tt-erro  THEN
                                glb_dscritic = tt-erro.dscritic.

                            UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta/dv: " +
                                       STRING(crapcrm.nrdconta,"zzzz,zzz,9") +
                                       " >> log/proc_batch.log").
                                          
                            DELETE PROCEDURE b1wgen0022.
                            
                            UNDO, RETURN.
                         END.

                 /* Nao cobrar tarifa da segunda via para cartao de operadores */
                    IF   par_flgtarif AND
                         crapcrm.tptitcar <> 9   THEN /* For segunda via */
                         DO:
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
                            /* Efetuar a chamada a rotina Oracle */
                            RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper         /* Cooperativa */
                                                                ,INPUT "1"                  /* Operador */
                                                                ,INPUT 1                    /* PA */ 
                                                                ,INPUT 100                  /* Banco */
                                                                ,INPUT glb_dtmvtolt         /* Data de movimento */
                                                                ,INPUT glb_cdprogra         /* Cód. programa */
                                                                ,INPUT 1                    /* Id. Origem*/
                                                                ,INPUT crapcrm.nrdconta     /* Nr. da conta */
                                                                ,INPUT 14                   /* Tipo de tarifa */
                                                                ,INPUT 0                    /* Tipo TAA */
                                                                ,INPUT 1                    /* Quantidade de operacoes */
																,INPUT 0					/* numero documento - adicionado por Valeria Supero outubro 2018 */ 
																,INPUT 0					/* hora de realização da operação -adicionado por Valeria Supero */  
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
                                DO:                                 
                                    UNIX SILENT VALUE("echo " + 
                                             STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             par_dscritic + " Conta/dv: " +
                                             STRING(crapcrm.nrdconta,"zzzz,zzz,9") +
                                             " >> log/proc_batch.log").
                                END.

                            /* Se não isenta tarifa */
                            IF  aux_fliseope <> 1 THEN
                                DO:                            
                                    /* Gera o craplat */
                                    RUN gera_lancamento IN b1wgen0022 
                                            (INPUT glb_cdcooper,
                                             INPUT glb_dtmvtolt,
                                             INPUT 1,               /* par_cdagenci */
                                             INPUT 100,             /* par_cdbccxlt */
                                             INPUT 10513,           /* par_nrdolote */
                                             INPUT "1",             /* par_cdoperad */
                                             INPUT 1,               /* par_tplotmov */
                                             INPUT 0,               /* par_nrautdoc */
                                             INPUT 513,             /* par_cdhistor */
                                             INPUT 0,               /* par_nrdcomto */
                                             INPUT 'Fato gerador tarifa:' + STRING(glb_dtmvtolt,"999999"), /* par_cdpesqbb*/
                                             INPUT crapcrm.nrdconta, 
                                             INPUT 0,               /* par_vllanmto */
                                             INPUT 0,               /* banco cheque */
                                             INPUT 0,               /* agencia cheque */
                                             INPUT 0,               /* conta cheque */
                                            OUTPUT par_dscritic). 
                                    
                                    IF  RETURN-VALUE = "NOK"  THEN
                                        UNIX SILENT VALUE("echo " + 
                                                 STRING(TIME,"HH:MM:SS") +
                                                 " - " + glb_cdprogra + "' --> '" +
                                                 par_dscritic + " Conta/dv: " +
                                                 STRING(crapcrm.nrdconta,"zzzz,zzz,9") +
                                                 " >> log/proc_batch.log").
                                END.
                         END.

                    DELETE PROCEDURE b1wgen0022.
                  END.
         END.
                
END.  /*  Fim do FOR EACH  --  Leitura do crapcrm  */

RUN fontes/fimprg.p.
               
IF   glb_cdcritic > 0   THEN
     RETURN.
 
ASSIGN glb_nrcopias = 2
       glb_nmformul = "132dm"
       glb_nmarqimp = aux_nmarqimp.

RUN fontes/imprim.p.

UNIX SILENT VALUE("cp " + aux_nmarqimp + " salvar/cm_rel" +
                                           STRING(glb_dtmvtolt,"99999999")).

UNIX SILENT VALUE("cp arq/" + aux_nmarqsai + " salvar"). 

RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET b1wgen0011.
              
RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                    INPUT "arq/" + aux_nmarqsai,
                                    INPUT aux_nmarqsai).

IF   aux_nrseqcar > 0   THEN
     DO: 
         DO TRANSACTION ON ERROR UNDO, RETURN:
         
            CREATE craptab.
            ASSIGN craptab.nmsistem = "CRED"
                   craptab.tptabela = "AUTOMA"
                   craptab.cdempres = 0 
                   craptab.cdacesso = "CM" + STRING(glb_dtmvtolt,"99999999")
                   craptab.tpregist = 0
                   craptab.dstextab = "0"
                   craptab.cdcooper = glb_cdcooper.
            VALIDATE craptab.
          
         END.               
                            
         /* Se cartao operador envia com assunto diferenciado */
         IF   aux_tptitcar = 9   THEN  /* Cartao OPERADOR */
              RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "arquivos@fbcards.com.br," +
                                        "fernanda@ailos.coop.br," +
                                        "fernanda.eccher@ailos.coop.br,",
                                  INPUT "CARTOES MAGNETICOS DA " + 
                                         crapcop.nmrescop +
                                        " - Cartao Operador" ,
                                  INPUT aux_nmarqsai,
                                  INPUT false).
         ELSE
              RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "arquivos@fbcards.com.br," +
                                        "fernanda@ailos.coop.br," +
                                        "fernanda.eccher@ailos.coop.br,",                                         
                                  INPUT "CARTOES MAGNETICOS DA " + 
                                         crapcop.nmrescop,
                                  INPUT aux_nmarqsai,
                                  INPUT false).
     END.
ELSE
     DO:
         glb_cdcritic = 656.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.

DELETE PROCEDURE b1wgen0011. 

/* .......................................................................... */
