/* ............................................................................
                    
   Programa: fontes/gera_arq_dirf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005                    Ultima atualizacao: 19/02/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar arquivo para a DIRF.
   
   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               11/01/2006 - Atualizacao para o Layout Dirf 2006 (Julio).

               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               14/02/2008 - Atualizacao layout Dirf 2008 (Julio).
               
               27/02/2009 - Desprezar contas sem movimentacao (Magui).
               
               27/01/2011 - Atualizacao de layout Dirf 2010 (Diego).
               
               08/01/2015 - Incluisão de tratamento para desprezar os lançamentos
                            de janeiro a novembro para as contas incorporadas.
                            (Dionathan)
                
			   18/01/2017 - Ajustado para nao gerar as informacoes das contas incorporadas 
                            no dia 31/12/2016 no arquivo DIRF da Transpocred 
                            (Douglas - Chamado 595087)
               19/02/2018 - Na linha BPFDEC inlcuido a informaçao fixa |N|N| (#839408 Tiago)
............................................................................ */

{ includes/var_batch.i }

DEF STREAM str_1.

DEF INPUT PARAM par_nmarqimp AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_aarefere AS INT                                    NO-UNDO.
DEF INPUT PARAM par_tpdeclar AS CHAR    FORMAT "x(1)"                  NO-UNDO.

DEF VAR aux_nrsequen AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_flsemmov AS LOG                                            NO-UNDO.
DEF VAR aux_nrultdec AS DEC                                            NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasdep AS CHAR                                           NO-UNDO.
DEF VAR aux_indplano AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF VAR aux_idviacon AS LOG                                            NO-UNDO.
DEF VAR aux_dtrefvir AS DATE                                          NO-UNDO.

DEF VAR aux_vlrdrtrt AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdrtpo AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdrtpp AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdrtdp AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdrtpa AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrrtirf AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdcjaa AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdcjac AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdesrt AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdespo AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdespp AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdesdp AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdespa AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdesir AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdesdj AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrridac AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrriirp AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrdriap AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrrimog AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.
DEF VAR aux_vlrrip65 AS DEC EXTENT 13  FORMAT "zzzzzzzzzzzz999"        NO-UNDO.

DEF VAR tot_vlrdrtrt AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdrtpo AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdrtpp AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdrtdp AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdrtpa AS DEC                                            NO-UNDO.
DEF VAR tot_vlrrtirf AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdcjaa AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdcjac AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdesrt AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdespo AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdespp AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdesdp AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdespa AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdesir AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdesdj AS DEC                                            NO-UNDO.
DEF VAR tot_vlrridac AS DEC                                            NO-UNDO.
DEF VAR tot_vlrriirp AS DEC                                            NO-UNDO.
DEF VAR tot_vlrdriap AS DEC                                            NO-UNDO.
DEF VAR tot_vlrrimog AS DEC                                            NO-UNDO.
DEF VAR tot_vlrrip65 AS DEC                                            NO-UNDO.

DEF VAR rel_nmbenefi LIKE crapdrf.nmbenefi                             NO-UNDO.


/* Tirar caracteres invalidos dos nomes, eh necessario utilizar apenas para 
   pessoa fisica (2005) */

FUNCTION f_tira_char_invalido RETURN CHAR(INPUT par_dsexpres AS CHAR,
                                          INPUT par_inpessoa AS INT):

  DEF   VAR   fun_nrindice  AS   INTEGER                      NO-UNDO.

  IF   par_inpessoa = 1   THEN
       DO fun_nrindice = 1 TO LENGTH(par_dsexpres):
  
          IF   CAN-DO("\,/,-,(,),&,$,@,+,?,:,;,<,>,`,[,]", 
                      SUBSTR(par_dsexpres, fun_nrindice, 1))   THEN

               par_dsexpres = REPLACE(par_dsexpres, 
                                  SUBSTR(par_dsexpres, fun_nrindice, 1), " ").
       END.
  ELSE
       DO fun_nrindice = 1 TO LENGTH(par_dsexpres):
  
          IF   CAN-DO("(,),$,@,:,;,',[,]", 
                      SUBSTR(par_dsexpres, fun_nrindice, 1))   THEN

               par_dsexpres = REPLACE(par_dsexpres, 
                                  SUBSTR(par_dsexpres, fun_nrindice, 1), " ").
       END.
  
  RETURN par_dsexpres.
  
END.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

MESSAGE "Aguarde... Gerando Arquivo...".

OUTPUT STREAM str_1 TO VALUE (par_nmarqimp).

ASSIGN aux_nrsequen = 0.

FOR EACH crapdrf WHERE crapdrf.cdcooper = glb_cdcooper  AND
                       crapdrf.nranocal = par_aarefere  NO-LOCK
                       BREAK BY crapdrf.tpregist
                                BY crapdrf.cdretenc
                                   BY crapdrf.inpessoa
                                      BY crapdrf.nrcpfbnf:
                    
    rel_nmbenefi = "".
    
    IF   FIRST-OF(crapdrf.nrcpfbnf)   OR   crapdrf.tporireg = 3   THEN
         ASSIGN aux_vlrdrtrt = 0
                aux_vlrdrtpo = 0
                aux_vlrdrtpp = 0
                aux_vlrdrtdp = 0
                aux_vlrdrtpa = 0
                aux_vlrrtirf = 0
                aux_vlrdcjaa = 0
                aux_vlrdcjac = 0
                aux_vlrdesrt = 0
                aux_vlrdespo = 0
                aux_vlrdespp = 0
                aux_vlrdesdp = 0
                aux_vlrdespa = 0
                aux_vlrdesir = 0
                aux_vlrdesdj = 0
                aux_vlrridac = 0
                aux_vlrriirp = 0
                aux_vlrdriap = 0
                aux_vlrrimog = 0
                aux_vlrrip65 = 0
                tot_vlrdrtrt = 0
                tot_vlrdrtpo = 0
                tot_vlrdrtpp = 0
                tot_vlrdrtdp = 0
                tot_vlrdrtpa = 0
                tot_vlrrtirf = 0
                tot_vlrdcjaa = 0
                tot_vlrdcjac = 0
                tot_vlrdesrt = 0
                tot_vlrdespo = 0
                tot_vlrdespp = 0
                tot_vlrdesdp = 0
                tot_vlrdespa = 0
                tot_vlrdesir = 0
                tot_vlrdesdj = 0
                tot_vlrridac = 0
                tot_vlrriirp = 0
                tot_vlrdriap = 0
                tot_vlrrimog = 0
                tot_vlrrip65 = 0
                aux_flsemmov = NO.

    /* No dia 31/12/2016 foi feita a incorporacao da Transulcred -> Transpocred
      com isso o "Informe de Rendimentos" deve existir na cooperativa antiga (Transulcred) para gerar o arquivo DIRF.
      Porém os dados de "Informe de Rendimentos" devem existir na cooperativa nova (Transpocred) para que o cooperado possa consultar na conta online,
      mas para os anos anteriores a incorporacao (2016), as informacoes geradas no arquivo DIRF da Transpocred nao devem possuir as contas incorporadas 
      (CHAMADO 595087) */
    IF par_aarefere <= 2016 AND glb_cdcooper = 9 THEN  
    DO:
        /* Apenas para a cooperativa 9 (Transpocred) e no ano anterior a 2016 */
    /* Verifica se a conta é originada das integrações da concredi/viacredi ou da credmilsul/scrcredi*/
        FIND craptco WHERE craptco.cdcooper = glb_cdcooper      AND
                           craptco.nrdconta = crapdrf.nrdconta  AND
                           craptco.cdcopant = 17                AND
                           craptco.flgativo = TRUE /* Transulcred */
                           NO-LOCK NO-ERROR.
        /* Se encontrar a conta migrada, vai para o proximo registro */
        IF  AVAILABLE craptco THEN
            NEXT.
    
    END.

    /* Verifica se a conta é originada das integrações da concredi/viacredi ou da credmilsul/scrcredi*/
    FIND craptco WHERE craptco.cdcooper = glb_cdcooper      AND
                       craptco.nrdconta = crapdrf.nrdconta  AND
                       (craptco.cdcopant = 4 OR craptco.cdcopant = 15)
                       NO-LOCK NO-ERROR.

    IF  AVAIL craptco THEN
        ASSIGN aux_idviacon = TRUE.
    ELSE
        ASSIGN aux_idviacon = FALSE.
            
    /* Le Valores de Imposto de Renda passando por todos os meses */ 
    FOR EACH crapvir WHERE crapvir.cdcooper = glb_cdcooper      AND
                           crapvir.nrcpfbnf = crapdrf.nrcpfbnf  AND
                           crapvir.nranocal = crapdrf.nranocal  AND
                           crapvir.cdretenc = crapdrf.cdretenc  AND
                           crapvir.nrseqdig = crapdrf.nrseqdig NO-LOCK:

        ASSIGN aux_dtrefvir = DATE(crapvir.nrmesref,1,crapvir.nranocal).
        
        /* Quando for uma conta incorporada, considera apenas dados acima de
           12/2014 (após a migração)*/
        IF  NOT aux_idviacon OR aux_dtrefvir >= 12/01/2014 THEN
            DO:

                ASSIGN  aux_vlrdrtrt[crapvir.nrmesref] =
                                    aux_vlrdrtrt[crapvir.nrmesref] + crapvir.vlrdrtrt
                                          tot_vlrdrtrt = tot_vlrdrtrt  +
                                                         aux_vlrdrtrt[crapvir.nrmesref]
                        aux_vlrdrtpo[crapvir.nrmesref] =
                                    aux_vlrdrtpo[crapvir.nrmesref] + crapvir.vlrdrtpo
                                          tot_vlrdrtpo = tot_vlrdrtpo + 
                                                         aux_vlrdrtpo[crapvir.nrmesref]
                        aux_vlrdrtpp[crapvir.nrmesref] = 
                                    aux_vlrdrtpp[crapvir.nrmesref] + crapvir.vlrdrtpp
                                          tot_vlrdrtpp = tot_vlrdrtpp +  
                                                         aux_vlrdrtpp[crapvir.nrmesref]
                        aux_vlrdrtdp[crapvir.nrmesref] = 
                                    aux_vlrdrtdp[crapvir.nrmesref] + crapvir.vlrdrtdp
                                          tot_vlrdrtdp = tot_vlrdrtdp + 
                                                         aux_vlrdrtdp[crapvir.nrmesref]
                        aux_vlrdrtpa[crapvir.nrmesref] = 
                                    aux_vlrdrtpa[crapvir.nrmesref] + crapvir.vlrdrtpa
                                          tot_vlrdrtpa = tot_vlrdrtpa + 
                                                         aux_vlrdrtpa[crapvir.nrmesref]
                        aux_vlrrtirf[crapvir.nrmesref] = 
                                    aux_vlrrtirf[crapvir.nrmesref] + crapvir.vlrrtirf
                                          tot_vlrrtirf = tot_vlrrtirf + 
                                                         aux_vlrrtirf[crapvir.nrmesref]
                        aux_vlrdcjaa[crapvir.nrmesref] = 
                                    aux_vlrdcjaa[crapvir.nrmesref] + crapvir.vlrdcjaa
                                          tot_vlrdcjaa = tot_vlrdcjaa + 
                                                         aux_vlrdcjaa[crapvir.nrmesref]
                        aux_vlrdcjac[crapvir.nrmesref] = 
                                    aux_vlrdcjac[crapvir.nrmesref] + crapvir.vlrdcjac
                                          tot_vlrdcjac = tot_vlrdcjac + 
                                                         aux_vlrdcjac[crapvir.nrmesref]
                        aux_vlrdesrt[crapvir.nrmesref] = 
                                    aux_vlrdesrt[crapvir.nrmesref] + crapvir.vlrdesrt  
                                          tot_vlrdesrt = tot_vlrdesrt + 
                                                         aux_vlrdesrt[crapvir.nrmesref]
                        aux_vlrdespo[crapvir.nrmesref] = 
                                    aux_vlrdespo[crapvir.nrmesref] + crapvir.vlrdespo
                                          tot_vlrdespo = tot_vlrdespo + 
                                                         aux_vlrdespo[crapvir.nrmesref]
                        aux_vlrdespp[crapvir.nrmesref] = 
                                    aux_vlrdespp[crapvir.nrmesref] + crapvir.vlrdespp
                                          tot_vlrdespp = tot_vlrdespp + 
                                                         aux_vlrdespp[crapvir.nrmesref]
                        aux_vlrdesdp[crapvir.nrmesref] = 
                                    aux_vlrdesdp[crapvir.nrmesref] + crapvir.vlrdesdp
                                          tot_vlrdesdp = tot_vlrdesdp + 
                                                         aux_vlrdesdp[crapvir.nrmesref]
                        aux_vlrdespa[crapvir.nrmesref] = 
                                    aux_vlrdespa[crapvir.nrmesref] + crapvir.vlrdespa
                                          tot_vlrdespa = tot_vlrdespa + 
                                                         aux_vlrdespa[crapvir.nrmesref]
                        aux_vlrdesir[crapvir.nrmesref] = 
                                    aux_vlrdesir[crapvir.nrmesref] + crapvir.vlrdesir
                                          tot_vlrdesir = tot_vlrdesir + 
                                                         aux_vlrdesir[crapvir.nrmesref]
                        aux_vlrdesdj[crapvir.nrmesref] = 
                                    aux_vlrdesdj[crapvir.nrmesref] + crapvir.vlrdesdj
                                          tot_vlrdesdj = tot_vlrdesdj + 
                                                         aux_vlrdesdj[crapvir.nrmesref]
                        aux_vlrridac[crapvir.nrmesref] = 
                                    aux_vlrridac[crapvir.nrmesref] + crapvir.vlrridac
                                          tot_vlrridac = tot_vlrridac + 
                                                         aux_vlrridac[crapvir.nrmesref]
                        aux_vlrriirp[crapvir.nrmesref] = 
                                    aux_vlrriirp[crapvir.nrmesref] + crapvir.vlrriirp
                                          tot_vlrriirp = tot_vlrriirp + 
                                                         aux_vlrriirp[crapvir.nrmesref]
                        aux_vlrdriap[crapvir.nrmesref] = 
                                    aux_vlrdriap[crapvir.nrmesref] + crapvir.vlrdriap
                                          tot_vlrdriap = tot_vlrdriap + 
                                                         aux_vlrdriap[crapvir.nrmesref]
                        aux_vlrrimog[crapvir.nrmesref] = 
                                    aux_vlrrimog[crapvir.nrmesref] + crapvir.vlrrimog
                                          tot_vlrrimog = tot_vlrrimog + 
                                                         aux_vlrrimog[crapvir.nrmesref]
                        aux_vlrrip65[crapvir.nrmesref] = 
                                    aux_vlrrip65[crapvir.nrmesref] + crapvir.vlrrip65
                                          tot_vlrrip65 = tot_vlrrip65 + 
                                                         aux_vlrrip65[crapvir.nrmesref].
        END.
    END.
    
    /* Quando o crapdrf eh gerado pelo Ayllos(tporireg = 1 ou 2), pode existir 
       mais de um registro para o mesmo beneficiario com o mesmo COD.RETENCAO, 
       no mesmo mes, diferenciados pelo crapdrf.nrseqdig. */
    IF   NOT LAST-OF(crapdrf.nrcpfbnf)  AND  crapdrf.tporireg <> 3   THEN
         NEXT.
            
    /*** Desprezar contas que nao tiveram movimentacao durante o ano ***/
    IF   tot_vlrdrtrt <> 0  OR
         tot_vlrdrtpo <> 0  OR
         tot_vlrdrtpp <> 0  OR
         tot_vlrdrtdp <> 0  OR
         tot_vlrdrtpa <> 0  OR
         tot_vlrrtirf <> 0  OR
         tot_vlrdcjaa <> 0  OR
         tot_vlrdcjac <> 0  OR
         tot_vlrdesrt <> 0  OR
         tot_vlrdespo <> 0  OR
         tot_vlrdespp <> 0  OR
         tot_vlrdesdp <> 0  OR
         tot_vlrdespa <> 0  OR
         tot_vlrdesir <> 0  OR
         tot_vlrdesdj <> 0  OR
         tot_vlrridac <> 0  OR
         tot_vlrriirp <> 0  OR
         tot_vlrdriap <> 0  OR
         tot_vlrrimog <> 0  OR
         tot_vlrrip65 <> 0  THEN
         ASSIGN aux_flsemmov = yes.
    
    IF   crapdrf.dsobserv = "GERACAO OK"  THEN 
         .   
    ELSE     
         IF   NOT aux_flsemmov   THEN
              NEXT.
         
    /* pegar o nome do dono do CPF */
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                       crapass.nrcpfcgc = crapdrf.nrcpfbnf   AND
                       crapass.inmatric = 1                  NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapass THEN
         rel_nmbenefi = crapass.nmprimtl.
    ELSE
         DO:
            FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                                   crapass.nrcpfcgc = crapdrf.nrcpfbnf  NO-LOCK
                                   BY crapass.dtadmiss
                                      BY crapass.dtabtcct:

                rel_nmbenefi = crapass.nmprimtl.
                LEAVE.  /* para pegar so a conta mais antiga */
            END.

            IF   rel_nmbenefi = ""   THEN 
                 rel_nmbenefi = crapdrf.nmbenefi.
         END.
    
    rel_nmbenefi = f_tira_char_invalido(rel_nmbenefi, crapdrf.inpessoa).

    aux_nrsequen = aux_nrsequen + 1.

    IF   crapdrf.tpregist = 1   THEN
         DO:  
            IF   par_tpdeclar = "R" THEN 
                 ASSIGN par_tpdeclar = "S". /* Retificadora */
            ELSE
                 ASSIGN par_tpdeclar = "N". /* Original */

            /* Cooperativas com plano de saude */ 
            IF   CAN-DO("1,2,3,4,5,6", STRING(crapcop.cdcoope))  THEN
                 ASSIGN aux_indplano = "S".
            ELSE
                 ASSIGN aux_indplano = "N".

            /* registro tipo 1  */
            PUT STREAM str_1 "Dirf" "|"
                             YEAR(glb_dtmvtolt) FORMAT "9999" "|" 
                             par_aarefere  FORMAT "9999" "|"
                             /* Ind. retificadora*/ 
                             par_tpdeclar  FORMAT "x(1)" "|".

                             IF   crapdrf.nrultdec <> 0 THEN
                                  PUT STREAM str_1 crapdrf.nrultdec 
                                                   FORMAT "999999999999"
                                                   "|".
                             ELSE 
                                  PUT STREAM str_1 "|".

            PUT STREAM str_1 "6E0E0AF" "|"
                             SKIP
                             /* Responsavel pelo preenchimento */ 
                             "RESPO" "|"   
                             crapdrf.nrcpfent FORMAT "99999999999" "|".
            
            PUT STREAM str_1 UNFORMATTED crapdrf.nmresent "|".
            
            PUT STREAM str_1 crapdrf.nrdddcop FORMAT "99" "|"
                             crapdrf.nrfoncop FORMAT "99999999" "|"
                             "|"   /* ramal */
                             "|" /* fax */
                             "|" /* correio eletronico */
                             SKIP
                             /* Declarante pessoa juridica */
                             "DECPJ" "|"  
                             crapdrf.nrcpfcgc FORMAT "99999999999999" "|".
            
            PUT STREAM str_1 UNFORMATTED crapdrf.nmdeclar "|".

            PUT STREAM str_1 "0" /* Natureza do declarante */ "|"
                             crapdrf.nrcpfres FORMAT "99999999999" "|"
                             "N" "|" /* Indicador de Socio Ostensivo */ 
                             "N" "|" /* Ind. decl. dep. decisao judicial */
                             "N" "|" /* Indicador declarante de inst. adm. */
                             "N" "|" /* Ind. decl. de rend. pagos no exterior */
                             /* Ind. plano privado assistencia saude */
                             aux_indplano "|" 
                             "N" "|" /* Indicador de situacao especial */ 
                             "|" /* Data do Evento */
                             SKIP.

            NEXT.
         END.
    ELSE
    IF   crapdrf.tpregist = 2   THEN  /* Inf. do beneficiario do declarante */
         DO:
             /* Identificacao de codigo da receita */
             IF   FIRST-OF(crapdrf.cdretenc) THEN
                  PUT STREAM str_1 "IDREC" "|"
                                   crapdrf.cdretenc FORMAT "9999"  "|"
                                   SKIP. 

             IF   crapdrf.inpessoa  = 1  THEN
                  DO:   
                      /* Beneficiario PF */ 
                      PUT STREAM str_1 "BPFDEC" "|"
                                 crapdrf.nrcpfbnf FORMAT "99999999999"  "|".

                      PUT STREAM str_1 UNFORMATTED rel_nmbenefi  "|"
                                                   "|N|N|"
                                                   SKIP.
                  END.
             ELSE
                  DO:
                      /* Beneficiario PJ */ 
                      PUT STREAM str_1 "BPJDEC" "|" 
                                 crapdrf.nrcpfbnf FORMAT "99999999999999"  "|".

                      PUT STREAM str_1 UNFORMATTED rel_nmbenefi  "|" SKIP.
                  END.
              
         END.

    IF   tot_vlrdrtrt <> 0  THEN
         DO:
             PUT STREAM str_1 "RTRT" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdrtrt[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdrtrt[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.
         
    IF   tot_vlrdrtpo <> 0  THEN
         DO:
             PUT STREAM str_1 "RTPO" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdrtpo[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdrtpo[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.
         
    IF   tot_vlrdrtpp  <> 0  THEN
         DO:
             PUT STREAM str_1 "RTPP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdrtpp[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdrtpp[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrdrtdp <> 0  THEN
         DO:
             PUT STREAM str_1 "RTDP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdrtdp[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdrtdp[aux_contador]
                                         "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrdrtpa <> 0  THEN
         DO:
             PUT STREAM str_1 "RTPA" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdrtpa[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdrtpa[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrrtirf <> 0  THEN
         DO:
             PUT STREAM str_1 "RTIRF" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrrtirf[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrrtirf[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrdcjaa <> 0  THEN
         DO:
             PUT STREAM str_1 "CJAA" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdcjaa[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdcjaa[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdcjac <> 0  THEN
         DO:
             PUT STREAM str_1 "CJAC" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdcjac[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdcjac[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdesrt <> 0  THEN
         DO:
             PUT STREAM str_1 "ESRT" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdesrt[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdesrt[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdespo <> 0  THEN
         DO:
             PUT STREAM str_1 "ESPO" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdespo[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdespo[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrdespp <> 0  THEN
         DO:
             PUT STREAM str_1 "ESPP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdespp[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdespp[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdesdp <> 0  THEN
         DO:
             PUT STREAM str_1 "ESDP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdesdp[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdesdp[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdespa <> 0  THEN
         DO:
             PUT STREAM str_1 "ESPA" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdespa[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdespa[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrdesir <> 0  THEN
         DO:
             PUT STREAM str_1 "ESIR" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdesir[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdesir[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      
     
    IF   tot_vlrdesdj <> 0  THEN
         DO:
             PUT STREAM str_1 "ESDJ" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdesdj[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdesdj[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrridac <> 0  THEN
         DO:
             PUT STREAM str_1 "RIDAC" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrridac[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrridac[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.       

    IF   tot_vlrriirp <> 0  THEN
         DO:
             PUT STREAM str_1 "RIIRP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrriirp[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrriirp[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.      

    IF   tot_vlrdriap <> 0  THEN
         DO:
             PUT STREAM str_1 "RIAP" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrdriap[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrdriap[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.    

    IF   tot_vlrrimog <> 0  THEN
         DO:
             PUT STREAM str_1 "RIMOG" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrrimog[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrrimog[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.     
     
    IF   tot_vlrrip65 <> 0  THEN
         DO:
             PUT STREAM str_1 "RIP65" "|".

             DO aux_contador = 1 TO 13:

                IF   aux_vlrrip65[aux_contador] <> 0 THEN
                     PUT STREAM str_1 UNFORMATTED aux_vlrrip65[aux_contador]
                                      "|".
                ELSE
                     PUT STREAM str_1 "|".

             END.

             PUT STREAM str_1 SKIP.
         END.    

    IF   crapdrf.vlrril96 <> 0 THEN
         PUT STREAM str_1 UNFORMATTED "RIL96" "|" 
                          crapdrf.vlrril96 "|".
      
    IF   crapdrf.vlrripts <> 0 THEN
         PUT STREAM str_1 UNFORMATTED "RIPTS" "|"
                          crapdrf.vlrripts "|".

    IF   crapdrf.vlrriade <> 0 THEN
         PUT STREAM str_1 UNFORMATTED "RIO" "|"
                          crapdrf.vlrriade "|"
                          crapdrf.dsrenis "|".

END.         

/* Verifica se existe informação ref. plano de saude */ 
FIND FIRST crapbps WHERE crapbps.cdcooper = glb_cdcooper  AND
                         crapbps.nranocal = par_aarefere 
                         NO-LOCK NO-ERROR.

IF   AVAIL crapbps THEN
     DO:
         PUT STREAM str_1 "PSE" "|" SKIP.
          
         /* Busca titulares de plano de saude */ 
         FOR EACH crapbps WHERE crapbps.cdcooper = glb_cdcooper NO-LOCK 
                  BREAK BY crapbps.nrcgcops
                         BY crapbps.nrcpfbnf:

             IF   FIRST-OF(crapbps.nrcgcops) THEN
                  DO:
                      /* Operadora do plano de saude */ 
                      PUT STREAM str_1 "OPSE" "|"
                                       crapbps.nrcgcops 
                                       FORMAT "99999999999999" "|".
                      
                      PUT STREAM str_1 UNFORMATTED crapbps.nmempops "|".

                      PUT STREAM str_1 crapbps.nrregops FORMAT "999999" "|"
                                       SKIP.

                  END.

             ASSIGN aux_nmprimtl = "". 
             FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                                      crapass.nrcpfcgc = crapbps.nrcpfbnf
                                      NO-LOCK NO-ERROR.

             IF   AVAIL crapass THEN
                  DO:
                      ASSIGN aux_nmprimtl = crapass.nmprimtl
                             aux_nmprimtl = f_tira_char_invalido
                                            (aux_nmprimtl, crapass.inpessoa).

                  END.

             /* Titular */ 
             PUT STREAM str_1 "TPSE" "|"
                               crapbps.nrcpfbnf
                               FORMAT "99999999999" "|".

             PUT STREAM str_1 UNFORMATTED aux_nmprimtl "|"
                                          crapbps.vlrsaude "|"
                                          SKIP.
             
             /*  Busca dependentes do titular do plano de saude */ 
             FOR EACH crapdps WHERE crapdps.cdcooper = crapbps.cdcooper  AND
                                    crapdps.nrcpfbnf = crapbps.nrcpfbnf  AND
                                    crapdps.nranocal = crapbps.nranocal
                                    NO-LOCK BY crapdps.nrcpfdep
                                              BY crapdps.dtnasdep:

                 ASSIGN aux_dtnasdep = STRING(YEAR(crapdps.dtnasdep),"9999") +
                                       STRING(MONTH(crapdps.dtnasdep),"99") +
                                       STRING(DAY(crapdps.dtnasdep),"99").

                 /* Dependente */
                 PUT STREAM str_1 "DTPSE" "|"
                               crapdps.nrcpfdep
                               FORMAT "99999999999" "|"
                               aux_dtnasdep "|".

                 PUT STREAM str_1 UNFORMATTED crapdps.nmdepbnf "|".
                 PUT STREAM str_1 crapdps.cdreldep  FORMAT "99"  "|".
                 PUT STREAM str_1 UNFORMATTED crapdps.vlrsaude "|" SKIP.

             END.
         END.
     END.

PUT STREAM str_1 "FIMDirf" "|".
         
OUTPUT STREAM str_1 CLOSE.

/* converte o arquivo de UNIX para DOS e move para "enviar" */
UNIX SILENT VALUE("ux2dos < " + par_nmarqimp + ' | tr -d "\032"' + 
                  " > /micros/" + crapcop.dsdircop + "/dirf/enviar/" + 
                   SUBSTRING(par_nmarqimp,4,LENGTH(par_nmarqimp) - 3) + 
                   " 2> /dev/null").
 
UNIX SILENT VALUE("rm " + par_nmarqimp + " 2> /dev/null").
   
/* mensagem de geracao com sucesso */
HIDE MESSAGE NO-PAUSE.
MESSAGE "Arquivo Gerado com Sucesso!!!".
PAUSE 1 NO-MESSAGE.

/* .......................................................................... */

