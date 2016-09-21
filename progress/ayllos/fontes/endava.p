/* .............................................................................

   Programa: Fontes/endava.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes         
   Data    : Julho/2004.                         Ultima atualizacao: 20/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Alterar Enderecos Avalistas (Terceiros) 

   Alteracoes: 17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
   
               10/10/2006 - Alterado help dos campos (Elton). 

               11/06/2007 - Somente tipo de contrato menor que 5(Mirtes)
               
               25/04/2011 - Aumentar formato da cidade e do bairro (Gabriel)
               
               07/08/2013 - Criada BO para esta tela. Melhoria na selecao
                            do contrato do browse (Carlos)
                            
               11/09/2013 - Inclusao de novos campos de endereco e busca de CEP
                            integrada (Carlos)
               
               04/10/2013 - Retiradas as operacoes de leitura e gravacao de 
                            dados e passadas para a BO b1wgen0164 (Carlos)
                
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
               
               02/03/2015 - Alterado o tamanho do espaçamento do browse b-contr
                            de 2 para 1 (Kelvin - 259786)
............................................................................. */
{ includes/var_online.i }
{ includes/var_atenda.i "NEW"}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0164tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }


DEF VAR pro_nmdaval  AS CHAR                           NO-UNDO.
DEF VAR pro_dscpfav  AS CHAR                           NO-UNDO.
DEF VAR pro_dsendav  AS CHAR           EXTENT 2        NO-UNDO.
DEF VAR pro_nrendere AS INTE                           NO-UNDO.
DEF VAR pro_complend AS CHAR FORMAT "x(40)"            NO-UNDO.
DEF VAR pro_nrcxapst AS INTE FORMAT "zz,zz9"           NO-UNDO.
DEF VAR pro_dscfcav  AS CHAR                           NO-UNDO.
DEF VAR pro_nmcjgav  AS CHAR                           NO-UNDO.
DEF VAR pro_cpfcgc   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF VAR pro_cpfccg   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF VAR pro_tpdocav  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF VAR pro_tpdoccj  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF VAR pro_nrfonres AS CHAR FORMAT "x(20)"            NO-UNDO.
DEF VAR pro_dsdemail AS CHAR FORMAT "x(30)"            NO-UNDO.
DEF VAR pro_nrctremp AS INT  FORMAT "zz,zzz,zz9"        NO-UNDO.
DEF VAR pro_nrdconta AS INT  FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF VAR pro_tpctrato AS INT  FORMAT "99"               NO-UNDO.

DEF VAR pro_nmcidade AS CHAR FORMAT "x(15)"            NO-UNDO.
DEF VAR pro_cdufresd AS CHAR FORMAT "!(2)"             NO-UNDO.
DEF VAR pro_nrcepend AS INTE FORMAT "zz,zzz,zz9"       NO-UNDO.


DEF NEW SHARED VAR shr_inpessoa AS INT                 NO-UNDO.

DEF VAR tiposctr     AS CHAR FORMAT "x(2)" EXTENT 4  INIT ["EP","DC","LM","CR"]
                                                       NO-UNDO.

DEF QUERY q-contr FOR tt-crapavt.

DEF BROWSE b-contr QUERY q-contr
    DISPLAY tt-crapavt.nrctremp              LABEL "Contrato" 
            SPACE(1)
            tt-crapavt.nrdconta              LABEL "Conta/DV"
            SPACE(1)
            tiposctr[tt-crapavt.tpctrato]    LABEL "Tipo"
    WITH 13 DOWN NO-LABELS OVERLAY.

FORM SKIP(1)
     glb_cddopcao     AT  2   LABEL "Opcao" AUTO-RETURN
                              HELP "Informe a opcao desejada (C,A)."
                              VALIDATE(CAN-DO("C,A",glb_cddopcao),
                                              "014 - Opcao errada.")
     SKIP(1)
     "CPF      :"     AT  2
     pro_cpfcgc       AT 13 
                      HELP "Informe numero do CPF do avalista."
     "Contrato :"     AT 45
     pro_nrctremp     AT 56
     SKIP
     "Conta/dv :"     AT  2
     pro_nrdconta     AT 13
     "Tipo     :"     AT 45
     tiposctr[pro_tpctrato] AT 56
     SKIP(1)
     "Nome     :"     AT  2 
     pro_nmdaval      AT 13 FORMAT "x(40)"
     "Documento:"     AT  2
     pro_tpdocav      AT 13  
     pro_dscpfav      AT 30 FORMAT "x(40)"
     SKIP
     "Conjuge  :"     AT  2 
     pro_nmcjgav      AT 13 FORMAT "x(40)"
     "CPF      :"     AT  2
     pro_cpfccg       AT 13
     "Documento:"     AT 30 
     pro_tpdoccj      AT 41   
     pro_dscfcav      AT 48 FORMAT "x(30)"
     SKIP(1)
     
      
     "Fone:"          AT 4 
     pro_nrfonres     AT 10 FORMAT "x(20)"
                      HELP "Informe o numero do telefone."
     "CEP:"           AT 51
     pro_nrcepend     AT 56
                      HELP "Informe o numero do CEP."
     SKIP

     "End:"           AT  5
     pro_dsendav[1]   AT  10 FORMAT "x(40)"
                      HELP "Informe o endereco."

     "Nr:"            AT 52
     pro_nrendere     AT 56 
                      HELP "Informe o numero."
     SKIP

     "Compl.:"        AT  2
     pro_complend     AT 10
                      HELP "Informe o complemento."

     "Caixa Postal:"  AT 51
     pro_nrcxapst     AT 65
                      HELP "Informe a caixa postal."
     SKIP

     "Bairro: "       AT  2
     pro_dsendav[2]   AT 10 FORMAT "x(40)"
                      HELP "Informe o nome do bairro."    
     
     SKIP
     "E-mail:"        AT  2
     pro_dsdemail     AT 10 FORMAT "x(28)" 
                      HELP "Informe o endereco eletronico."  
     
     "Cidade:"        AT 39
     pro_nmcidade     AT 47 FORMAT "x(25)"
                      HELP "Informe o nome da cidade."

     "UF:"            AT 73
     pro_cdufresd     AT 77
                      HELP "Informe a sigla do estado."
     
     WITH ROW 4 NO-LABELS SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80
                FRAME f_endava.

FORM
     b-contr    HELP "Use as setas para navegar e <ENTER> para selecionar"
     WITH ROW 5 COLUMN 46 OVERLAY NO-BOX NO-LABELS FRAME f_listar.

DEF VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF VAR h-b1wgen0164 AS HANDLE                                NO-UNDO.

ASSIGN  glb_cddopcao = "C"
        glb_cdcritic = 0.

ON RETURN OF b-contr
   DO:
       APPLY "GO".
   END.

/* Inclusão de CEP integrado */
ON GO, LEAVE OF pro_nrcepend IN FRAME f_endava DO:
    IF  INPUT pro_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF pro_nrcepend IN FRAME f_endava DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT pro_nrcepend.

    IF  pro_nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT pro_nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN pro_nrcepend   = tt-endereco.nrcepend 
                           pro_dsendav[1] = tt-endereco.dsendere 
                           pro_nmcidade   = tt-endereco.nmcidade 
                           pro_cdufresd   = tt-endereco.cdufende.
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

    DISPLAY pro_nrcepend  pro_dsendav[1]
            pro_nmcidade  pro_cdufresd
            WITH FRAME f_endava.

    NEXT-PROMPT pro_nrendere WITH FRAME f_endava.
END.


DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_endava NO-PAUSE.
               glb_cdcritic = 0.
           END.

          UPDATE glb_cddopcao pro_cpfcgc WITH FRAME f_endava.
          LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
           RUN fontes/novatela.p.
           IF   glb_nmdatela <> "ENDAVA"   THEN
                DO:

                   IF VALID-HANDLE(h-b1wgen0164) THEN
                     DELETE PROCEDURE h-b1wgen0164.

                   HIDE FRAME f_endava.
                   RETURN.
                END.
           ELSE
                NEXT.
        END.

    RUN conecta_handle.
    RUN busca_crapavt IN h-b1wgen0164(
                      INPUT glb_cdcooper,
                      INPUT glb_cdagenci,
                      INPUT glb_cdoperad,
                      INPUT glb_dtmvtolt,
                      INPUT glb_nmdatela,
                      INPUT 4,           /* tpctrato */
                      INPUT INPUT pro_cpfcgc,
                      OUTPUT TABLE tt-crapavt,
                      OUTPUT TABLE tt-erro).

    IF TEMP-TABLE tt-crapavt:HAS-RECORDS THEN
        DO:
            OPEN QUERY q-contr FOR EACH tt-crapavt NO-LOCK.
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b-contr WITH FRAME f_listar.
                LEAVE.
            END.
            HIDE FRAME f_listar.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.

        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO: 
            FIND FIRST tt-erro NO-ERROR.
            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    NEXT.
                END.
        END.

   ASSIGN pro_nmdaval      = tt-crapavt.nmdavali 
          pro_tpdocav      = tt-crapavt.tpdocava
          pro_dscpfav      = tt-crapavt.nrdocava
          pro_nmcjgav      = tt-crapavt.nmconjug
          pro_cpfccg       = tt-crapavt.nrcpfcjg
          pro_tpdoccj      = tt-crapavt.tpdoccjg 
          pro_dscfcav      = tt-crapavt.nrdoccjg
          pro_nrfonres     = tt-crapavt.nrfonres
          pro_dsendav[1]   = tt-crapavt.dsendres[1]
          pro_dsendav[2]   = tt-crapavt.dsendres[2]
          pro_nrendere     = tt-crapavt.nrendere
          pro_complend     = tt-crapavt.complend
          pro_nrcxapst     = tt-crapavt.nrcxapst
          pro_dsdemail     = tt-crapavt.dsdemail
          pro_nmcidade     = tt-crapavt.nmcidade
          pro_cdufresd     = tt-crapavt.cdufresd
          pro_nrcepend     = tt-crapavt.nrcepend
          pro_nrctremp     = tt-crapavt.nrctremp
          pro_nrdconta     = tt-crapavt.nrdconta
          pro_tpctrato     = tt-crapavt.tpctrato.

   DISPLAY pro_nrctremp
           pro_nrdconta
           pro_nmdaval   
           pro_tpdocav 
           pro_dscpfav 
           pro_nmcjgav  
           pro_cpfccg       WHEN pro_cpfccg > 0 
           pro_tpdoccj 
           pro_dscfcav 
           pro_nrfonres
           pro_dsendav[1]
           pro_dsendav[2]  
           pro_nrendere
           pro_complend
           pro_nrcxapst
           pro_dsdemail
           tiposctr[pro_tpctrato]
           pro_nmcidade 
           pro_cdufresd 
           pro_nrcepend  
           WITH FRAME f_endava.

   IF   glb_cddopcao = "A"   THEN
        DO:
            { includes/acesso.i }

            UPDATE  pro_nrfonres
                    pro_nrcepend
                    pro_dsendav[1]
                    pro_nrendere
                    pro_complend
                    pro_nrcxapst
                    pro_dsendav[2]
                    pro_dsdemail
                    pro_nmcidade
                    pro_cdufresd 
                    WITH FRAME f_endava
            
            EDITING:
                READKEY.
                HIDE MESSAGE NO-PAUSE.
    
                IF  LASTKEY = KEYCODE("F7")  THEN
                    DO:
                        IF  FRAME-FIELD = "pro_nrcepend"  THEN
                            DO:
    
                                /* Inclusão de CEP integrado */
                                RUN fontes/zoom_endereco.p 
                                    ( INPUT 0,
                                     OUTPUT TABLE tt-endereco ).
    
                                FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
                                IF  AVAIL tt-endereco THEN
                                    ASSIGN pro_nrcepend   = tt-endereco.nrcepend 
                                           pro_dsendav[1] = tt-endereco.dsendere 
                                           pro_nmcidade   = tt-endereco.nmcidade 
                                           pro_cdufresd   = tt-endereco.cdufende.

                                DISPLAY pro_nrcepend    
                                        pro_dsendav[1]
                                        pro_nmcidade
                                        pro_cdufresd
                                        WITH FRAME f_endava.
    
                                IF  KEYFUNCTION(LASTKEY) <> "END-ERROR"  THEN
                                    NEXT-PROMPT pro_nrendere 
                                                WITH FRAME f_endava.
                            END.
                    END.
                ELSE
                    APPLY LASTKEY.
            END.

            RUN grava_crapavt IN h-b1wgen0164(
                INPUT glb_cdcooper,
                INPUT glb_cdagenci,
                INPUT pro_cpfcgc,
                INPUT pro_nrctremp,
                INPUT pro_nrdconta,
                INPUT pro_tpctrato,
                INPUT glb_dtmvtolt,
                INPUT pro_dsendav[1] ,
                INPUT pro_dsendav[2] ,
                INPUT pro_nrendere,
                INPUT pro_nrfonres,
                INPUT pro_complend,
                INPUT pro_nrcxapst,
                INPUT pro_dsdemail,
                INPUT pro_nmcidade,
                INPUT pro_cdufresd,
                INPUT pro_nrcepend,
                OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO: 
                    FIND FIRST tt-erro NO-ERROR.
                    IF  AVAILABLE tt-erro THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                        END.
                END.
        
            IF  VALID-HANDLE(h-b1wgen0164) THEN
                DELETE PROCEDURE h-b1wgen0164.

        END. /* opcao A */
END.  /*  Fim do WHILE TRUE  */


/* ----- Procedures ----------------------------------------------------- */
PROCEDURE conecta_handle:

   IF NOT VALID-HANDLE(h-b1wgen0164) THEN
      RUN sistema/generico/procedures/b1wgen0164.p
          PERSISTENT SET h-b1wgen0164.

END PROCEDURE.


PROCEDURE Limpa_Endereco:
    ASSIGN pro_dsendav[1] = ""
           pro_dsendav[2] = ""
           pro_nrcepend = 0  

           pro_nrendere = 0
           pro_complend = ""
           pro_nrcxapst = 0
           pro_nmcidade = ""
           pro_cdufresd = "".

    DISPLAY pro_dsendav[1]
            pro_dsendav[2]
            pro_nrcepend
            pro_nrendere
            pro_complend
            pro_nrcxapst
            pro_nmcidade
            pro_cdufresd WITH FRAME f_endava.
END PROCEDURE.
/* ...................................................................... */
