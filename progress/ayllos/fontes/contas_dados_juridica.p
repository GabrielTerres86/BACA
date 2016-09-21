/* .............................................................................

   Programa: fontes/contas_dados_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                          Ultima Atualizacao: 23/07/2015

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes a identificacao do
               Associado.

   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               11/01/2010 - Utilizacao de BO (Jose Luis - DB1).

               10/08/2010 - Inclusao de parametro na function 
               "BuscaNaturezaJuridica", INPUT "dsnatjur" - (Jose Luis, DB1)
               
               16/02/2010 - Ajuste devido a alteracao do campo nome (Henrique).
               
               23/07/2015 - Reformulacao cadastal (Gabriel-RKAM).
               
               05/08/2015 - Projeto 217 - Reformulacao cadastral 
                           (Tiago Castro RKAM)
		       
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
..............................................................................*/

{ sistema/generico/includes/b1wgen0053tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF NEW SHARED  VAR shr_cdnatjur LIKE crapjur.natjurid                 NO-UNDO.
DEF NEW SHARED  VAR shr_rsnatjur AS CHAR               FORMAT "x(15)"  NO-UNDO.
DEF NEW SHARED  VAR shr_dsnatjur AS CHAR               FORMAT "x(50)"  NO-UNDO.
DEF NEW SHARED  VAR shr_cdseteco AS INT                                NO-UNDO.
DEF NEW SHARED  VAR shr_nmseteco AS CHAR               FORMAT "x(20)"  NO-UNDO.
DEF NEW SHARED  VAR shr_cdrmativ AS INT                                NO-UNDO.
DEF NEW SHARED  VAR shr_nmrmativ AS CHAR               FORMAT "x(40)"  NO-UNDO.

DEF VAR tel_restpnac AS CHAR                           FORMAT "x(15)"  NO-UNDO.
DEF VAR tel_dssitcpf AS CHAR                           FORMAT "x(11)"  NO-UNDO.
DEF VAR tel_dsnatjur AS CHAR                           FORMAT "x(50)"  NO-UNDO.
DEF VAR tel_dsendweb AS CHAR                           FORMAT "x(40)"  NO-UNDO.
DEF VAR tel_cdrmativ AS INT                                            NO-UNDO.
DEF VAR tel_dsrmativ AS CHAR                           FORMAT "X(40)"  NO-UNDO.
DEF VAR tel_cdnatjur LIKE crapjur.natjurid                             NO-UNDO.
DEF VAR tel_nmtalttl LIKE crapjur.nmtalttl                             NO-UNDO.
DEF VAR tel_qtfoltal AS INTEGER                        FORMAT "99"     NO-UNDO.
DEF VAR tel_dtcnscpf LIKE crapass.dtcnscpf                             NO-UNDO.
DEF VAR tel_cdsitcpf LIKE crapass.cdsitcpf                             NO-UNDO.
DEF VAR tel_qtfilial LIKE crapjur.qtfilial                             NO-UNDO.
DEF VAR tel_qtfuncio LIKE crapjur.qtfuncio                             NO-UNDO.
DEF VAR tel_dtiniatv LIKE crapjur.dtiniatv                             NO-UNDO.
DEF VAR tel_cdseteco LIKE crapjur.cdseteco                             NO-UNDO.
DEF VAR tel_cdclcnae LIKE crapass.cdclcnae                             NO-UNDO.
DEF VAR tel_nmseteco AS CHAR                           FORMAT "x(11)"  NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR          FORMAT "x(07)"   INIT "Alterar"  NO-UNDO.
DEF VAR tel_nmprimtl LIKE crapass.nmprimtl                             NO-UNDO.
DEF VAR tel_inpessoa LIKE crapass.inpessoa                             NO-UNDO.

DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.
                                                                       
DEF VAR h-b1wgen0053 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

FORM  SKIP(1)
      tel_nmprimtl     AT  1 LABEL "Razao Social" AUTO-RETURN FORMAT "x(40)"

      tel_inpessoa     AT 56 LABEL "Tp.Natureza"
      
      tel_dspessoa           NO-LABEL
      SKIP
      tel_nmfatasi     AT  1 LABEL "Nome Fantasia"
                             HELP "Informe o nome fantasia da empresa"
                             VALIDATE(tel_nmfatasi <> "",
                                      "375 - O campo deve ser preenchido.")
      SKIP
      tel_nrcpfcgc     AT  1 LABEL "C.N.P.J." AUTO-RETURN

      tel_dtcnscpf     AT 33 LABEL "Consulta" AUTO-RETURN
                             VALIDATE(tel_dtcnscpf <> ?,"013 - Data errada.")
                    HELP "Informe a data da consulta do CPF na Receita Federal" 

      tel_cdsitcpf     AT 56 LABEL "Situacao" AUTO-RETURN
          HELP "Informe a situacao do CNPJ (1=Reg.,2=Pend.,3=Cancel.,4=Irreg.)"
    
      tel_dssitcpf           NO-LABEL
      SKIP(1)
      tel_cdnatjur     AT  1 LABEL "Natureza Juridica"   FORMAT "9999"
                             AUTO-RETURN
          HELP "Informe codigo da natureza juridica ou pressione F7 para listar"
                             VALIDATE(tel_cdnatjur <> 0,
                                     "375 - O campo deve ser preenchido.")
      tel_dsnatjur           NO-LABEL                    FORMAT "x(50)"
      SKIP
      tel_qtfilial     AT  6 LABEL "Qtd. Filiais"
                             HELP "Informe a quantidade de filiais da empresa"
      
      tel_qtfuncio     AT 49 LABEL "Qtd. Funcionarios"
                       HELP "Informe a quantidade de funcionarios da empresa"
      SKIP
      tel_dtiniatv     AT  2 LABEL "Inicio Atividade" 
                                   AUTO-RETURN FORMAT "99/99/9999"
                             HELP "Informe o inicio da atividade da empresa"
                             VALIDATE(tel_dtiniatv <> ?,
                                      "013 - Data errada.")
      
      tel_cdseteco     AT 33 LABEL "Setor Economico"  AUTO-RETURN
                       FORMAT "9"
                    HELP "Informe o setor economico ou pressione F7 para listar"
                       VALIDATE(tel_cdseteco <> 0,
                                "375 - O campo deve ser preenchido.")
      
      tel_nmseteco     NO-LABEL FORMAT "x(20)"
      SKIP                       
      tel_cdrmativ     AT  4 LABEL "Ramo Atividade"  FORMAT "zz9"
                       AUTO-RETURN
                     HELP "Informe o ramo atividade ou pressione F7 para listar"
                       VALIDATE(tel_cdrmativ <> 0,
                                "375 - O campo deve ser preenchido.")

      tel_dsrmativ     NO-LABEL FORMAT "x(30)"
      SKIP(1)
      tel_dsendweb     AT  1 LABEL "Endereco na Internet(Site)" 
                             HELP "Informe o endereco da empresa na internet"
      SKIP
      tel_nmtalttl     AT 1 LABEL "Nome Talao"   AUTO-RETURN
                        HELP "Informe o nome para impressao no talao de cheques"
                             VALIDATE(tel_nmtalttl <> "",
                                      "375 - O campo deve ser preenchido.")
      tel_qtfoltal    LABEL "Qtd. Folhas Talao"
                 HELP "Informe a quantidade de folhas para o talao de cheques"
                             VALIDATE(tel_qtfoltal = 10 OR tel_qtfoltal = 20,
                                      'Quantidade de folhas deve ser 10 ou 20')
      SKIP
      reg_dsdopcao     AT 35 NO-LABEL
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
      WITH ROW 7 OVERLAY SIDE-LABELS TITLE " IDENTIFICACAO "
                 CENTERED FRAME f_dados_juridica.

/* Situacao do CPF/CNPJ */
ON LEAVE OF tel_cdsitcpf IN FRAME f_dados_juridica DO:

   ASSIGN INPUT tel_cdsitcpf.

   DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                    INPUT tel_cdsitcpf,
                    OUTPUT tel_dssitcpf,
                    OUTPUT aux_dscritic).
        
   DISPLAY tel_dssitcpf WITH FRAME f_dados_juridica.        
END.

/* Natureza Juridica */
ON LEAVE OF tel_cdnatjur IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdnatjur.
    
    IF  NOT DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                             INPUT tel_cdnatjur,
                             INPUT "dsnatjur",
                             OUTPUT tel_dsnatjur,
                             OUTPUT aux_dscritic) THEN 
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_dsnatjur WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.
    
    DISPLAY tel_dsnatjur WITH FRAME f_dados_juridica.   

END.

/* Setor Economico */  
ON LEAVE OF tel_cdseteco IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdseteco.

    IF  NOT DYNAMIC-FUNCTION("BuscaSetorEconomico" IN h-b1wgen0060,
                             INPUT glb_cdcooper,
                             INPUT tel_cdseteco,
                             OUTPUT tel_nmseteco,
                             OUTPUT aux_dscritic) THEN
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_nmseteco WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.

    DISPLAY tel_nmseteco WITH FRAME f_dados_juridica.

END.

/* Ramo de Atividades */
ON LEAVE OF tel_cdrmativ IN FRAME f_dados_juridica DO:

    ASSIGN INPUT tel_cdrmativ.

    IF  NOT DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                             INPUT tel_cdseteco,
                             INPUT tel_cdrmativ,
                             OUTPUT tel_dsrmativ,
                             OUTPUT aux_dscritic) THEN
        DO:
           MESSAGE aux_dscritic.
           DISPLAY tel_dsrmativ WITH FRAME f_dados_juridica.
           RETURN NO-APPLY.
        END.

    DISPLAY tel_dsrmativ WITH FRAME f_dados_juridica.

END.

aux_flgsuces = FALSE.

Principal: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0053) THEN
       RUN sistema/generico/procedures/b1wgen0053.p 
           PERSISTENT SET h-b1wgen0053.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   EMPTY TEMP-TABLE tt-dados-jur.

   RUN Busca_dados IN h-b1wgen0053 (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,  
                                    INPUT glb_nmdatela,
                                    INPUT 1,
                                    INPUT tel_nrdconta,
                                    INPUT 1,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-dados-jur).

   IF  RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF  AVAIL tt-erro  THEN
               DO:
                   BELL.
                   MESSAGE tt-erro.dscritic.
               END.
    
           LEAVE Principal.
       END.

   RUN Atualiza-Tela.

   IF  RETURN-VALUE <> "OK" THEN
       DO:
          MESSAGE RETURN-VALUE.
          LEAVE Principal.
       END.

   DISPLAY tel_nmprimtl        tel_inpessoa        tel_dspessoa
           tel_nmfatasi        tel_nrcpfcgc        tel_dtcnscpf
           tel_cdsitcpf        tel_dssitcpf        tel_cdnatjur
           tel_dsnatjur        tel_qtfilial        tel_qtfuncio
           tel_dtiniatv        tel_cdseteco        tel_nmseteco
           tel_cdrmativ        tel_dsrmativ        tel_dsendweb
           tel_nmtalttl        tel_qtfoltal        reg_dsdopcao        
           WITH FRAME f_dados_juridica.

   CHOOSE FIELD reg_dsdopcao WITH FRAME f_dados_juridica.
   
   IF   FRAME-FIELD = "reg_dsdopcao"   THEN
        Edita: DO WHILE TRUE TRANSACTION:
           RUN Edita-Dados.
        
           IF  RETURN-VALUE <> "OK" THEN
               NEXT Edita.

           LEAVE Edita.     
        END. /* Fim TRANSACTION */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"                  THEN
        NEXT Principal.
   ELSE
        DO: 
            IF  aux_flgsuces THEN
                LEAVE Principal.
        END.
END.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         LEAVE.
     END.

IF  VALID-HANDLE(h-b1wgen0053) THEN
    DELETE OBJECT h-b1wgen0053.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

HIDE FRAME f_dados_juridica NO-PAUSE.
HIDE MESSAGE NO-PAUSE.

/*...........................................................................*/

PROCEDURE Atualiza-Tela:

    FIND FIRST tt-dados-jur NO-ERROR.

    IF  NOT AVAILABLE tt-dados-jur THEN
        DO:
           RETURN "Nao encontrei os dados da pessoa juridica".
        END.

    ASSIGN
        tel_nmprimtl = tt-dados-jur.nmprimtl
        tel_inpessoa = tt-dados-jur.inpessoa
        tel_dspessoa = tt-dados-jur.dspessoa
        tel_nmfatasi = tt-dados-jur.nmfatasi
        tel_nrcpfcgc = tt-dados-jur.nrcpfcgc
        tel_dtcnscpf = tt-dados-jur.dtcnscpf
        tel_cdsitcpf = tt-dados-jur.cdsitcpf
        tel_dssitcpf = tt-dados-jur.dssitcpf
        tel_cdnatjur = tt-dados-jur.cdnatjur
        tel_dsnatjur = tt-dados-jur.dsnatjur
        tel_qtfilial = tt-dados-jur.qtfilial
        tel_qtfuncio = tt-dados-jur.qtfuncio
        tel_dtiniatv = tt-dados-jur.dtiniatv
        tel_cdseteco = tt-dados-jur.cdseteco
        tel_nmseteco = tt-dados-jur.nmseteco
        tel_cdrmativ = tt-dados-jur.cdrmativ
        tel_dsrmativ = tt-dados-jur.dsrmativ
        tel_dsendweb = tt-dados-jur.dsendweb
        tel_nmtalttl = tt-dados-jur.nmtalttl
        tel_qtfoltal = tt-dados-jur.qtfoltal
        tel_cdclcnae = tt-dados-jur.cdclcnae.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Edita-Dados:

    ASSIGN glb_nmrotina = "IDENTIFICACAO"
           glb_cddopcao = "A".

   { includes/acesso.i }
   
   UPDATE tel_nmfatasi        tel_dtcnscpf
          tel_cdsitcpf        tel_cdnatjur
          tel_qtfilial        tel_qtfuncio
          tel_dtiniatv        tel_cdseteco
          tel_cdrmativ        tel_dsendweb
          tel_nmtalttl        tel_qtfoltal
          WITH FRAME f_dados_juridica

   EDITING:

       READKEY.
       HIDE MESSAGE NO-PAUSE.

       IF   LASTKEY = KEYCODE("F7") THEN
            DO:
                IF   FRAME-FIELD = "tel_cdnatjur"   THEN
                     DO:
                         ASSIGN shr_cdnatjur = INPUT tel_cdnatjur.
                         RUN fontes/zoom_natureza_juridica.p.
                         IF  shr_cdnatjur <> 0  THEN
                             DO:
                                ASSIGN tel_cdnatjur = shr_cdnatjur
                                       tel_dsnatjur = shr_dsnatjur.
                                DISPLAY tel_cdnatjur tel_dsnatjur
                                        WITH FRAME f_dados_juridica.
                                NEXT-PROMPT tel_cdnatjur
                                            WITH FRAME f_dados_juridica.
                              END.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_cdseteco"   THEN
                     DO:
                         ASSIGN shr_cdseteco = INPUT tel_cdseteco.
                         RUN fontes/zoom_setoreconomico.p
                                              (INPUT glb_cdcooper).
                         IF  shr_cdseteco <> 0  THEN
                             DO:
                                ASSIGN tel_cdseteco = shr_cdseteco
                                       tel_nmseteco = shr_nmseteco.
                                DISPLAY tel_cdseteco tel_nmseteco
                                        WITH FRAME f_dados_juridica.
                                NEXT-PROMPT tel_cdseteco
                                            WITH FRAME f_dados_juridica.
                             END.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_cdrmativ"   THEN
                     DO:
                         ASSIGN shr_cdrmativ = INPUT tel_cdrmativ
                                tel_cdseteco = INPUT tel_cdseteco.

                         RUN fontes/zoom_ramo_atividades.p
                             (INPUT tel_cdseteco).

                         IF  shr_cdrmativ <> 0  THEN
                             DO:
                                ASSIGN tel_cdrmativ = shr_cdrmativ
                                       tel_dsrmativ = shr_nmrmativ.
                                DISPLAY tel_cdrmativ tel_dsrmativ
                                       WITH FRAME f_dados_juridica.
                                NEXT-PROMPT tel_cdrmativ
                                            WITH FRAME f_dados_juridica.
                             END.
                     END.
            END. /* Fim do F7 */
       ELSE
       IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
               UNDO, RETURN "OK".
            END.
       ELSE 
            APPLY LASTKEY.

       IF  GO-PENDING THEN
           DO:
               RUN Valida_Dados IN h-b1wgen0053 (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,  
                                                 INPUT glb_nmdatela,
                                                 INPUT 1,
                                                 INPUT tel_nrdconta,
                                                 INPUT 1,
                                                 INPUT INPUT tel_nmfatasi,
                                                 INPUT INPUT tel_dtcnscpf,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT tt-dados-jur.dtcadass,
                                                 INPUT INPUT tel_dtiniatv,
                                                 INPUT INPUT tel_cdsitcpf,
                                                 INPUT INPUT tel_cdnatjur,
                                                 INPUT INPUT tel_cdseteco,
                                                 INPUT INPUT tel_cdrmativ,
                                                 INPUT INPUT tel_nmtalttl,
                                                 INPUT INPUT tel_qtfoltal,
                                                OUTPUT TABLE tt-erro).
    
               IF  RETURN-VALUE <> "OK" THEN
                   DO: 
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                       IF  AVAIL tt-erro  THEN
                           DO:
                               BELL.
                               MESSAGE tt-erro.dscritic.
                               NEXT.
                           END.
                       NEXT.
                   END.
           END.

   END.  /*  Fim do EDITING  */

   DISPLAY tel_nmfatasi   tel_dsendweb    tel_nmtalttl
           WITH FRAME f_dados_juridica.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic
      UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"                  THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
            RETURN "OK".
        END.
   ELSE 
        DO:
           IF  VALID-HANDLE(h-b1wgen0053) THEN
               DELETE OBJECT h-b1wgen0053.

           RUN sistema/generico/procedures/b1wgen0053.p 
               PERSISTENT SET h-b1wgen0053.

           RUN Grava_Dados IN h-b1wgen0053 (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,  
                                            INPUT glb_nmdatela,
                                            INPUT 1,
                                            INPUT tel_nrdconta,
                                            INPUT 1,
                                            INPUT YES, /* gravar log */
                                            INPUT tel_qtfoltal,
                                            INPUT tel_dtcnscpf,
                                            INPUT tel_cdsitcpf,
                                            INPUT CAPS(tel_nmfatasi),
                                            INPUT tel_cdnatjur,
                                            INPUT tel_dtiniatv,
                                            INPUT tel_cdrmativ,
                                            INPUT tel_qtfilial,
                                            INPUT tel_qtfuncio,
                                            INPUT LC(tel_dsendweb),
                                            INPUT CAPS(tel_nmtalttl),
                                            INPUT tel_cdseteco,
                                            INPUT tel_cdclcnae,
                                            INPUT "A",
                                            INPUT glb_dtmvtolt,
                                            INPUT 0,
                                           OUTPUT aux_tpatlcad,
                                           OUTPUT aux_msgatcad,
                                           OUTPUT aux_chavealt,
                                           OUTPUT TABLE tt-erro).
    
           IF  RETURN-VALUE <> "OK" THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                   IF  AVAIL tt-erro  THEN
                       DO:
                           BELL.
                           MESSAGE tt-erro.dscritic.
                       END.
    
                   RETURN "NOK".
               END.
           
           /* verificar se é necessario registrar o crapalt */
           RUN proc_altcad (INPUT "b1wgen0053.p").

           DELETE OBJECT h-b1wgen0053.

           IF  RETURN-VALUE <> "OK" THEN
               RETURN "NOK".

           aux_flgsuces = YES.
        END.

   RETURN "OK".

END PROCEDURE.
