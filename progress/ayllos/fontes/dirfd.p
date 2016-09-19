/* ..........................................................................

   Programa: fontes/dirfd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio/Evandro
   Data    : Fevereiro/2005                      Ultima atualizacao: 04/12/2013

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Atende a solicitacao 50 ordem _. 
               Tela para digitacao dos dados para DIRF.

   Alteracoes: 01/07/2005 - Alimentado campo cdcooper da tabela crapdrf (Diego).

               26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               12/09/2006 - Alterado help dos campos da tela (Elton).
               
               28/02/2011 - Inclusao dos novos campos para atender novo layout
                            da DIRF 2011 (GATI - Daniel/Eder)
                            
               04/12/2013 - Inclusao de VALIDATE crapvir e crapdrf (Carlos)
............................................................................ */

{ includes/var_online.i }
{ includes/var_conta.i  "NEW" }

DEF   VAR tel_dtrefere  AS DATE       FORMAT "99/99/9999"         NO-UNDO.
DEF   VAR tel_cdretenc  LIKE crapdrf.cdretenc                     NO-UNDO.
DEF   VAR tel_inpessoa  LIKE crapdrf.inpessoa                     NO-UNDO.
DEF   VAR tel_nrcpfbnf  LIKE crapdrf.nrcpfbnf                     NO-UNDO.
DEF   VAR tel_nmbenefi  LIKE crapdrf.nmbenefi                     NO-UNDO.

DEF   VAR tel_vlrdrtrt  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdrtpo  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdrtpp  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdrtdp  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdrtpa  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrrtirf  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdcjaa  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdcjac  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdesrt  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdespo  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdespp  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdesdp  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdespa  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdesir  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdesdj  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrridac  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrriirp  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrdriap  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrrimog  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlrrip65  AS DEC FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
                  
DEF   VAR tel_dspessoa  AS CHAR       EXTENT 3  
                                      INIT ["FISICA","JURIDICA",
                                            "AMBAS"]              NO-UNDO.
DEF   BUFFER crabdrf FOR crapdrf.
DEF   BUFFER crabvir FOR crapvir.

DEF QUERY q_retencao FOR gnrdirf.

DEF BROWSE b_retencao QUERY q_retencao
    DISPLAY gnrdirf.cdretenc NO-LABEL FORMAT "9999"
            gnrdirf.dsretenc NO-LABEL FORMAT "x(52)"
            tel_dspessoa[gnrdirf.inpessoa] NO-LABEL 
            WITH 10 DOWN.

FORM 
   SKIP(1)
   tel_dtrefere AT  5 LABEL "Referencia"
        HELP "Informe a data de referencia."
        VALIDATE(INPUT tel_dtrefere <> ? AND 
                 NOT CAN-FIND(crapdrf WHERE 
                 crapdrf.cdcooper = glb_cdcooper AND
                 crapdrf.nranocal = YEAR(INPUT tel_dtrefere) 
                 AND crapdrf.tpregist = 1                AND
                 TRIM(crapdrf.dsobserv) <> ""        NO-LOCK),
                  "A DIRF para o ano calendario informado ja esta finalizada!")
   SKIP(1)
   tel_cdretenc AT  3 LABEL "Cod.Retencao"
        HELP "Informe o codigo de retencao ou F7 para listar."
        VALIDATE(CAN-FIND(gnrdirf WHERE gnrdirf.cdretenc = INPUT tel_cdretenc),
                          "Codigo de Retencao nao encontrado")
   tel_inpessoa AT 25 LABEL "Tipo de Pessoa"
        HELP "Informe o tipo de pessoa (1-Fisica / 2-Juridica)."
        VALIDATE(INPUT tel_inpessoa = 1 OR INPUT tel_inpessoa = 2,
                 "436 - Tipo de pessoa errado.")
   tel_nrcpfbnf AT 46 LABEL "CPF/CNPJ"
        HELP "Informe o CPF/CNPJ do beneficiario."
        VALIDATE(INPUT tel_nrcpfbnf > 0, "375 - O campo deve ser preenchido.")
   SKIP(1)      
   tel_nmbenefi AT 11 LABEL "Nome"
        HELP "Informe o nome do beneficiario."
        VALIDATE(INPUT tel_nmbenefi <> "", "375 - O campo deve ser preenchido.")
   SKIP(1) 
   tel_vlrdrtrt TO 24 LABEL "RTRT"
        HELP "Informe rendimentos tributaveis - Rendimento Tributavel."
   tel_vlrdrtpo TO 50 LABEL "RTPO"
        HELP "Informe rendiment. tributaveis - Deducao - Previdencia Oficial."
   tel_vlrdrtpp TO 75 LABEL "RTPP"
        HELP "Informe rendiment. tributaveis - Deducao - Previdencia Privada."
   SKIP
   tel_vlrdrtdp TO 24 LABEL "RTDP"
        HELP "Informe rendiment. tributaveis - Deducao - Dependentes."
   tel_vlrdrtpa TO 50 LABEL "RTPA"
        HELP "Informe rendiment. tributaveis - Deducao - Pensao Alimenticia."
   tel_vlrrtirf TO 75 LABEL "RTIRF"
        HELP "Informe rendim. tributaveis - Imposto de Renda Retido na Fonte."
   SKIP
   tel_vlrdcjac TO 24 LABEL "CJAC"
        HELP "Informe Compens. de Imp. por Decisao Judicial - Ano Calendario."
   tel_vlrdcjaa TO 50 LABEL "CJAA"
        HELP "Informe Compens. de Imp. por Decisao Judic. - Anos Anteriores."
   tel_vlrdesrt TO 75 LABEL "ESRT"
        HELP "Informe Tributacao com Exigibilid. Suspensa - Rend. Tributavel."
   SKIP
   tel_vlrdespo TO 24 LABEL "ESPO"
        HELP "Informe Tribut. com Exigib. Suspensa - Deducao - Prev. Oficial."
   tel_vlrdespp TO 50 LABEL "ESPP"
        HELP "Informe Tribut. com Exigib. Suspensa - Deducao - Prev. Privada."
   tel_vlrdesdp TO 75 LABEL "ESDP"
        HELP "Informe Tribut. com Exigib. Suspensa - Deducao - Dependentes."
   SKIP
   tel_vlrdespa TO 24 LABEL "ESPA"
        HELP "Informe Tribut. com Exigib. Suspensa - Deducao - Pensao Alimen."
   tel_vlrdesir TO 50 LABEL "ESIR"
        HELP "Informe Tribut. com Exigib. Suspensa - Imp. de Renda na Fonte."
   tel_vlrdesdj TO 75 LABEL "ESDJ"
        HELP "Informe Tributacao com Exigibil. Suspensa - Deposito Judicial."
   SKIP         
   tel_vlrridac TO 24 LABEL "RIDAC"
        HELP "Informe rendimentos isentos - Diaria e Ajuda de Custo."
   tel_vlrriirp TO 50 LABEL "RIIRP"
        HELP "Informe rendim. isentos - Inden. por Recisao de Contr. de Trab."
   tel_vlrdriap TO 75 LABEL "RIAP"
        HELP "Informe rendimentos isentos - Abono Pecuniario."
   SKIP
   tel_vlrrimog TO 24 LABEL "RIMOG"
        HELP "Informe rendim. isentos - Pensao, Aposent., Ref. Molest. Grave."
   tel_vlrrip65 TO 50 LABEL "RIP65"
        HELP "Informe rendim. isentos - Parc. Isenta de Aposent. Maiores 65."
   SKIP(1)
   WITH WIDTH 78 OVERLAY ROW 5 CENTERED NO-LABELS SIDE-LABELS 
        TITLE "DIGITACAO DE DADOS DIRF" FRAME f_digitacao.

FORM b_retencao  HELP "Pressione ENTER para selecionar / F4 para sair"
     WITH NO-BOX NO-LABELS OVERLAY ROW 10 CENTERED FRAME f_browse.

ON RETURN OF b_retencao DO:
    tel_cdretenc = gnrdirf.cdretenc.
    DISPLAY tel_cdretenc WITH FRAME f_digitacao.

    APPLY "GO".
END.

ON LEAVE OF tel_nmbenefi DO:

   FIND FIRST crapdrf WHERE crapdrf.cdcooper = glb_cdcooper              AND
                            crapdrf.nrcpfbnf = INPUT tel_nrcpfbnf        AND
                            crapdrf.nranocal = YEAR(INPUT tel_dtrefere)
                            NO-LOCK NO-ERROR.

   IF   AVAILABLE crapdrf                        AND
        INPUT tel_nmbenefi <> crapdrf.nmbenefi   THEN
        DO:
            IF   INPUT tel_nmbenefi <> ""   THEN
                 DO:
                    tel_nmbenefi = crapdrf.nmbenefi.
                    DISPLAY tel_nmbenefi WITH FRAME f_digitacao.

                    MESSAGE "Nome do beneficiario ja cadastrado!"
                            "Nao pode ser alterado.".

                    PAUSE(3) NO-MESSAGE.
                    HIDE MESSAGE.
                 END.
            ELSE
                 DO:
                     tel_nmbenefi = crapdrf.nmbenefi.
                     DISPLAY tel_nmbenefi WITH FRAME f_digitacao.
                 END.
        
        END.
END.

ON LEAVE OF tel_nrcpfbnf DO:
   
   FIND FIRST crapdrf WHERE crapdrf.cdcooper = glb_cdcooper               AND
                            crapdrf.nrcpfbnf = INPUT tel_nrcpfbnf         AND
                            crapdrf.nranocal = YEAR(INPUT tel_dtrefere)
                            NO-LOCK NO-ERROR.
   
   IF   AVAILABLE crapdrf   THEN
        DO:
            ASSIGN tel_nmbenefi = crapdrf.nmbenefi.
            DISPLAY tel_nmbenefi WITH FRAME f_digitacao.
        END.

END.

ASSIGN glb_cddopcao = "D".

{ includes/acesso.i }

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

HIDE MESSAGE NO-PAUSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

UPDATE tel_dtrefere
       tel_cdretenc
       tel_inpessoa
       tel_nrcpfbnf
       tel_nmbenefi   
       tel_vlrdrtrt
       tel_vlrdrtpo
       tel_vlrdrtpp 
       tel_vlrdrtdp  
       tel_vlrdrtpa  
       tel_vlrrtirf 
       tel_vlrdcjac  
       tel_vlrdcjaa  
       tel_vlrdesrt  
       tel_vlrdespo  
       tel_vlrdespp  
       tel_vlrdesdp  
       tel_vlrdespa  
       tel_vlrdesir  
       tel_vlrdesdj  
       tel_vlrridac 
       tel_vlrriirp 
       tel_vlrdriap  
       tel_vlrrimog 
       tel_vlrrip65
       WITH FRAME f_digitacao

   EDITING:
            
       DO WHILE TRUE:
               
           READKEY PAUSE 1.
             
           IF   LASTKEY = KEYCODE("F7")        AND
                FRAME-FIELD = "tel_cdretenc"   THEN
                DO:
                    OPEN QUERY q_retencao FOR EACH gnrdirf NO-LOCK.
                        
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       UPDATE b_retencao WITH FRAME f_browse.
                       LEAVE.
                    END.
                    
                    HIDE FRAME f_browse.
                    NEXT.
                END.

           APPLY LASTKEY.
                          
           LEAVE.

       END. /* fim DO WHILE */
   END. /* fim do EDITING */

   /* validacao do tipo de pessoa em relcacao ao codigo de retencao */
   FIND gnrdirf WHERE gnrdirf.cdretenc = tel_cdretenc   AND
                     (gnrdirf.inpessoa = tel_inpessoa   OR
                      gnrdirf.inpessoa = 3)             NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE gnrdirf   THEN
        DO:
            MESSAGE "Tipo de pessoa nao corresponde ao codigo de retencao".

            VIEW FRAME f_digitacao.
            PAUSE(3) NO-MESSAGE.
            
            NEXT-PROMPT tel_inpessoa WITH FRAME f_digitacao.
            NEXT.
        END.
   
   /* verifica se o CPF/CNPJ esta correto */
   glb_nrcalcul = tel_nrcpfbnf.
   RUN fontes/cpfcgc.p.
   
   IF   glb_stsnrcal = NO   THEN
        DO:
            glb_cdcritic = 027.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_nrcpfbnf WITH FRAME f_digitacao.
            NEXT.
        END.

   /* verifica se o CPF/CNPJ esta correto em relacao ao tel_inpessoa */
   IF   shr_inpessoa <> tel_inpessoa   THEN
        DO:
            IF   tel_inpessoa = 1   THEN
                 MESSAGE "Este CPF/CNPJ nao eh pessoa FISICA".
            ELSE
                 MESSAGE "Este CPF/CNPJ nao eh pessoa JURIDICA".

            VIEW FRAME f_digitacao.
            PAUSE(3) NO-MESSAGE.

            NEXT-PROMPT tel_nrcpfbnf WITH FRAME f_digitacao.
            NEXT.
        END.

   /* verifica se o nome (cpf) ja esta cadastrado */
   APPLY "LEAVE" TO tel_nmbenefi.

   /* coloca o nome em letras maiusculas */
   tel_nmbenefi = CAPS(tel_nmbenefi).
   DISPLAY tel_nmbenefi WITH FRAME f_digitacao.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      aux_confirma = "N".
      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.

   IF   aux_confirma <> "S"   THEN
        NEXT.
            
   RUN verifica_registro.

END. /* fim do DO WHILE principal */

PROCEDURE verifica_registro:

    /* verifica se ja existe um registro desse beneficiario */
    FIND FIRST crapvir WHERE 
               crapvir.cdcooper = glb_cdcooper          AND
               crapvir.nrcpfbnf = tel_nrcpfbnf          AND
               crapvir.nranocal = YEAR(tel_dtrefere)    AND
               crapvir.nrmesref = MONTH(tel_dtrefere)   AND 
               crapvir.cdretenc = tel_cdretenc          
               EXCLUSIVE-LOCK NO-ERROR.

    IF    AVAIL crapvir    THEN
          DO:
              /* verifica se o mes esta "livre" */
              IF   crapvir.vlrdrtrt = 0   AND
                   crapvir.vlrdrtpo = 0   AND
                   crapvir.vlrdrtpp = 0   AND
                   crapvir.vlrdrtdp = 0   AND
                   crapvir.vlrdrtpa = 0   AND
                   crapvir.vlrrtirf = 0   AND
                   crapvir.vlrdcjac = 0   AND
                   crapvir.vlrdcjaa = 0   AND
                   crapvir.vlrdesrt = 0   AND
                   crapvir.vlrdespo = 0   AND
                   crapvir.vlrdespp = 0   AND
                   crapvir.vlrdesdp = 0   AND
                   crapvir.vlrdespa = 0   AND
                   crapvir.vlrdesir = 0   AND
                   crapvir.vlrdesdj = 0   AND
                   crapvir.vlrridac = 0   AND
                   crapvir.vlrriirp = 0   AND
                   crapvir.vlrdriap = 0   AND
                   crapvir.vlrrimog = 0   AND
                   crapvir.vlrrip65 = 0   THEN

                   ASSIGN crapvir.vlrdrtrt = tel_vlrdrtrt * 100
                          crapvir.vlrdrtpo = tel_vlrdrtpo * 100
                          crapvir.vlrdrtpp = tel_vlrdrtpp * 100
                          crapvir.vlrdrtdp = tel_vlrdrtdp * 100
                          crapvir.vlrdrtpa = tel_vlrdrtpa * 100
                          crapvir.vlrrtirf = tel_vlrrtirf * 100
                          crapvir.vlrdcjac = tel_vlrdcjac * 100
                          crapvir.vlrdcjaa = tel_vlrdcjaa * 100
                          crapvir.vlrdesrt = tel_vlrdesrt * 100
                          crapvir.vlrdespo = tel_vlrdespo * 100
                          crapvir.vlrdespp = tel_vlrdespp * 100
                          crapvir.vlrdesdp = tel_vlrdesdp * 100
                          crapvir.vlrdespa = tel_vlrdespa * 100
                          crapvir.vlrdesir = tel_vlrdesir * 100
                          crapvir.vlrdesdj = tel_vlrdesdj * 100
                          crapvir.vlrridac = tel_vlrridac * 100
                          crapvir.vlrriirp = tel_vlrriirp * 100
                          crapvir.vlrdriap = tel_vlrdriap * 100
                          crapvir.vlrrimog = tel_vlrrimog * 100
                          crapvir.vlrrip65 = tel_vlrrip65 * 100.
              ELSE
                   RUN cria_registro.
          END.
    ELSE
          RUN cria_registro.

    IF    AVAIL crapvir    THEN
          RELEASE crapvir.

    IF    AVAIL crapdrf    THEN
          RELEASE crapdrf.

    /* zerar os campos */
    ASSIGN tel_dtrefere = ?
           tel_cdretenc = 0
           tel_inpessoa = 1
           tel_nrcpfbnf = 0
           tel_nmbenefi = ""
           tel_vlrdrtrt = 0
           tel_vlrdrtpo = 0
           tel_vlrdrtpp = 0
           tel_vlrdrtdp = 0 
           tel_vlrdrtpa = 0 
           tel_vlrrtirf = 0
           tel_vlrdcjac = 0 
           tel_vlrdcjaa = 0 
           tel_vlrdesrt = 0 
           tel_vlrdespo = 0 
           tel_vlrdespp = 0 
           tel_vlrdesdp = 0 
           tel_vlrdespa = 0 
           tel_vlrdesir = 0 
           tel_vlrdesdj = 0 
           tel_vlrridac = 0
           tel_vlrriirp = 0
           tel_vlrdriap = 0 
           tel_vlrrimog = 0
           tel_vlrrip65 = 0.

END PROCEDURE.

PROCEDURE cria_registro:

    /* para pegar o ultimo nro de sequencia */
    FIND LAST crabvir WHERE crabvir.cdcooper = glb_cdcooper         AND
                            crabvir.nrcpfbnf = tel_nrcpfbnf         AND
                            crabvir.cdretenc = tel_cdretenc         AND
                            crabvir.nranocal = YEAR(tel_dtrefere)   AND
                            crabvir.nrmesref = MONTH(tel_dtrefere)
                            NO-LOCK NO-ERROR.

    CREATE crapvir.
    ASSIGN crapvir.cdcooper = glb_cdcooper       
           crapvir.nrcpfbnf = tel_nrcpfbnf       
           crapvir.nranocal = YEAR(tel_dtrefere) 
           crapvir.nrmesref = MONTH(tel_dtrefere)
           crapvir.nrseqdig = IF AVAIL crabvir THEN
                                crabvir.nrseqdig + 1
                             ELSE 0
           crapvir.cdretenc = tel_cdretenc
           crapvir.vlrdrtrt = tel_vlrdrtrt * 100
           crapvir.vlrdrtpo = tel_vlrdrtpo * 100
           crapvir.vlrdrtpp = tel_vlrdrtpp * 100
           crapvir.vlrdrtdp = tel_vlrdrtdp * 100
           crapvir.vlrdrtpa = tel_vlrdrtpa * 100
           crapvir.vlrrtirf = tel_vlrrtirf * 100
           crapvir.vlrdcjac = tel_vlrdcjac * 100
           crapvir.vlrdcjaa = tel_vlrdcjaa * 100
           crapvir.vlrdesrt = tel_vlrdesrt * 100
           crapvir.vlrdespo = tel_vlrdespo * 100
           crapvir.vlrdespp = tel_vlrdespp * 100
           crapvir.vlrdesdp = tel_vlrdesdp * 100
           crapvir.vlrdespa = tel_vlrdespa * 100
           crapvir.vlrdesir = tel_vlrdesir * 100
           crapvir.vlrdesdj = tel_vlrdesdj * 100
           crapvir.vlrridac = tel_vlrridac * 100
           crapvir.vlrriirp = tel_vlrriirp * 100
           crapvir.vlrdriap = tel_vlrdriap * 100
           crapvir.vlrrimog = tel_vlrrimog * 100
           crapvir.vlrrip65 = tel_vlrrip65 * 100.

    VALIDATE crapvir.

    /* para pegar o ultimo nro de sequencia */
    FIND crapdrf WHERE crapdrf.cdcooper = glb_cdcooper         AND
                       crapdrf.nrcpfbnf = tel_nrcpfbnf         AND
                       crapdrf.cdretenc = tel_cdretenc         AND
                       crapdrf.nranocal = YEAR(tel_dtrefere)   AND
                       crapdrf.nrseqdig = crapvir.nrseqdig
                       NO-LOCK NO-ERROR.
    IF   NOT AVAIL crapdrf   THEN
         DO:
            CREATE crapdrf.
            ASSIGN crapdrf.cdretenc = tel_cdretenc
                   crapdrf.tpregist = 2
                   crapdrf.tporireg = 2  /* digitacao */
                   crapdrf.dtmvtolt = glb_dtmvtolt
                   crapdrf.nranocal = YEAR(tel_dtrefere)
                   crapdrf.inpessoa = tel_inpessoa
                   crapdrf.nmbenefi = tel_nmbenefi
                   crapdrf.nrcpfbnf = tel_nrcpfbnf
                   crapdrf.nrcpfcgc = crapcop.nrdocnpj
                   crapdrf.nrseqdig = crapvir.nrseqdig
                   crapdrf.cdcooper = glb_cdcooper.


            VALIDATE crapdrf.

         END.

END PROCEDURE.

/* ......................................................................... */
