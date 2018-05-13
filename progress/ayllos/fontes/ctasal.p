/* .............................................................................

   Programa: Fontes/ctasal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze
   Data    : Novembro/2006                       Ultima Atualizacao: 23/02/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa para cadastramento da Conta Salario.

   Alteracoes: 03/08/2007 - Alterado o controle de criacao e reativacao de
                            conta salario (Evandro).
              
               12/08/2008 - Ajuste no ZOOM da agencia bancaria (Guilherme).
               
               23/01/2009 - Alteracao cdempres (Diego).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               18/03/2010 - Acerto na consulta da crapagb para obter o nome
                            da agencia (David).
                            
               13/09/2010 - Nao permitir transferencia para banco 85 (Diego).
               
               30/09/2011 - Retirar critica para banco 85 (Gabriel)
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               03/09/2013 - Incluida validacao de dados na opcao S para validar
                            conta salario (Carlos)
               
               04/09/2013 - Incluida confirmacao do gerente para opcoes A e I
                            (Carlos)
                            
               06/09/2013 - Incluida validacao de obrigatoriedade do digito da
                            conta salario. Se o cooperado tiver uma conta 
                            ativa, pedir senha do gerente. Validacao dos dados
                            passada para depois do preechimento do digito da
                            conta salario. (Carlos)
                            
               05/11/2013 - Retirado o pedido de senha do gerente (Carlos)
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               23/04/2015 - Ajustando tela CTASAL
                            Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
               
			   23/02/2016 - Validacao do nome do funcionario (Jean Michel)                          

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0151tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }

FUNCTION ValidaNome RETURNS LOGICAL PRIVATE
    ( INPUT  par_nomedttl AS CHARACTER,
      INPUT  par_inpessoa AS INTE,
      OUTPUT par_dscritic AS CHARACTER )  FORWARD.

DEF NEW SHARED  VAR shr_cdempres LIKE crapemp.cdempres               NO-UNDO.
DEF NEW SHARED  VAR shr_nmresemp LIKE crapemp.nmresemp               NO-UNDO.
DEF NEW SHARED  VAR shr_cdbccxlt LIKE crapban.cdbccxlt               NO-UNDO.
DEF NEW SHARED  VAR shr_nmresbcc LIKE crapban.nmresbcc               NO-UNDO.
DEF NEW SHARED  VAR shr_inpessoa LIKE crapass.inpessoa               NO-UNDO. 
DEF NEW SHARED  VAR shr_cdageban LIKE crapagb.cdageban               NO-UNDO. 
DEF NEW SHARED  VAR shr_nmageban LIKE crapagb.nmageban               NO-UNDO.

DEF STREAM str_1.

DEF VAR h-b1wgen0151 AS HANDLE                                       NO-UNDO.
DEF VAR hb1wgen0052v AS HANDLE                                       NO-UNDO.

DEF VAR aux_msgconfi AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(08)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(08)" INIT "Cancelar"       NO-UNDO.
DEF VAR aux_tpimprim AS LOGICAL FORMAT "Tela/Impressora"             NO-UNDO.

DEF        VAR tel_cdagenci LIKE crapccs.cdagenci                    NO-UNDO.
DEF        VAR tel_cdagetrf LIKE crapccs.cdagetrf                    NO-UNDO.
DEF        VAR tel_cdbantrf LIKE crapccs.cdbantrf                    NO-UNDO.
DEF        VAR tel_cdopeadm LIKE crapccs.cdopeadm                    NO-UNDO.
DEF        VAR tel_cdopecan LIKE crapccs.cdopecan                    NO-UNDO.
DEF        VAR tel_cdsitcta AS CHAR FORMAT "x(09)"                   NO-UNDO.
DEF        VAR tel_dtadmiss LIKE crapccs.dtadmiss                    NO-UNDO.
DEF        VAR tel_dtcantrf LIKE crapccs.dtcantrf                    NO-UNDO.
DEF        VAR tel_nmfuncio LIKE crapccs.nmfuncio                    NO-UNDO.
DEF        VAR tel_nrcpfcgc AS CHAR FORMAT "x(14)"                   NO-UNDO.
DEF        VAR tel_nrctatrf LIKE crapccs.nrctatrf                    NO-UNDO.
DEF        VAR tel_nrdconta LIKE crapccs.nrdconta                    NO-UNDO.
DEF        VAR tel_nrdigtrf LIKE crapccs.nrdigtrf                    NO-UNDO.
DEF        VAR tel_cdempres AS INT                                   NO-UNDO.
DEF        VAR tel_dsbantrf AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_dsagetrf AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_nmresage AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_nmresemp AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR rel_nmextemp AS CHAR    FORMAT "x(35)"                NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.


DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgsolic AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdecpf AS LOGI                                  NO-UNDO.
DEF        VAR aux_nrcpfcgc AS DECI                                  NO-UNDO.

DEF        VAR aut_flgsenha     AS LOGICAL                           NO-UNDO.
DEF        VAR aut_cdoperad     AS CHAR                              NO-UNDO.

DEF        BUFFER crabcop FOR crapcop.
DEF        BUFFER crabass FOR crapass.

DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.


FORM "Aguarde... Imprimindo termo de solicitacao de conta salario"
           WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_solicitacao.

FORM "Aguarde... Imprimindo termo de cancelamento de conta salario"
           WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_cancelamento.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, I, S ou X)"
                        VALIDATE(CAN-DO("A,C,E,I,S,X",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ctasal_opcao.

FORM tel_nrdconta AT  03 LABEL "Conta/dv" AUTO-RETURN
     HELP "Informe o numero da conta do associado ou  F7  para pesquisar"
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ctasal_conta.
     
FORM tel_nrdconta AT  03 LABEL "Conta/dv" AUTO-RETURN
     HELP "Informe o numero da conta salario"
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ctasal_contaI.

FORM tel_nmfuncio  AT 03 LABEL "Titular"
                         HELP "Informe o nome do Titular da Conta"
                         VALIDATE(tel_nmfuncio <> "", 
                                  "375 - O campo deve ser preenchido.")
     tel_nrcpfcgc  AT 04 LABEL "C.P.F."
                         HELP "Informe o numero do CPF do Titular"
                         VALIDATE(tel_nrcpfcgc <> ""  AND
                                  tel_nrcpfcgc <> "0",
                                  "375 - O campo deve ser preenchido.")
     SKIP
     tel_cdagenci  AT 07 LABEL "PA"      FORMAT "zz9"
                         HELP "Entre com o codigo do PA"
     tel_nmresage  AT 15 NO-LABEL
     SKIP
     tel_cdempres  AT 03 LABEL "Empresa"  FORMAT "zzzz9"
                         HELP "Informe o codigo da empresa ou F7 para pesquisar"
     tel_nmresemp  AT 17 NO-LABEL         FORMAT "x(18)"   
     SKIP(1)
     "Transferindo para =>  "  AT  10
     tel_cdbantrf  LABEL "Banco"
                   HELP "Informe o codigo do banco ou F7 para pesquisar"
                   VALIDATE(CAN-FIND(crapban WHERE 
                                     crapban.cdbccxlt = tel_cdbantrf),
                                     "057 - Banco nao Cadastrado.")
     tel_dsbantrf  NO-LABEL
     SKIP
     tel_cdagetrf  AT 31 LABEL "Agencia"
              HELP "Informe o codigo da agencia ou F7 para pesquisar"
     tel_dsagetrf  NO-LABEL
     SKIP
     tel_nrctatrf  AT 33 LABEL "Conta"
              HELP "Informe o numero da conta para transferencia de proventos" 
              VALIDATE(tel_nrctatrf <> 0,
                       "357 - O campo deve ser preenchido.")
     tel_nrdigtrf  AT 60 LABEL "Digito"
                   HELP "Informe o digito da conta de transferencia" 
                   VALIDATE(tel_nrdigtrf <> "",
                            "357 - O campo deve ser preenchido.")
     SKIP(1)
"---------------------------------- Situacao ----------------------------------"
     SKIP
     tel_dtadmiss   AT 01 LABEL "Data Abertura"     FORMAT "99/99/9999"
     tel_dtcantrf   AT 30 LABEL "Data Cancelamento" FORMAT "99/99/9999"
     tel_cdsitcta   AT 60 LABEL "Situacao"          FORMAT "x(09)"
     WITH ROW 10 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ctasal.

ON LEAVE OF tel_cdagenci IN FRAME f_ctasal DO:

    RUN busca_pac.

    FIND tt-crapage NO-LOCK NO-ERROR.

    ASSIGN tel_nmresage = IF   AVAILABLE tt-crapage THEN 
                                " - " + tt-crapage.dsagepac
                          ELSE  " - Nao Cadastrado".
                         
    DISPLAY tel_nmresage WITH FRAME f_ctasal.
     
    HIDE MESSAGE NO-PAUSE.
END.


ON LEAVE OF tel_cdbantrf IN FRAME f_ctasal DO:

    RUN busca_bancos.

    FIND tt-crapban NO-LOCK NO-ERROR.

/*     /* Banco */                                                                 */
    ASSIGN tel_dsbantrf = IF   AVAIL tt-crapban THEN 
                                " - " + tt-crapban.nmresbcc
                          ELSE  " - Nao Cadastrado".


    DISPLAY tel_dsbantrf WITH FRAME f_ctasal.

    IF  glb_cddopcao = "I" THEN
        ASSIGN tel_nrdigtrf = "".

    /* Campo Digito somente visivel se Banco diferente de 85 */
    tel_nrdigtrf:VISIBLE IN FRAME f_ctasal = NOT (INPUT tel_cdbantrf = 85).

    HIDE MESSAGE NO-PAUSE.

END.

ON LEAVE OF tel_cdagetrf IN FRAME f_ctasal DO:

    RUN busca_agencia.

    FIND tt-crapagb NO-LOCK NO-ERROR.

/*     /* Agencia */                                                               */
    ASSIGN tel_dsagetrf = IF   AVAIL tt-crapagb THEN 
                               " - " + STRING(tt-crapagb.nmageban,"x(29)")
                          ELSE " - Nao Cadastrado".
                         
     DISPLAY tel_dsagetrf WITH FRAME f_ctasal.
     
     HIDE MESSAGE NO-PAUSE.

END.

ON LEAVE OF tel_cdempres IN FRAME f_ctasal DO:

    RUN busca_empresa.

    FIND tt-crapemp NO-LOCK NO-ERROR.

/*     /* Empresa */                                                               */
    ASSIGN tel_nmresemp = IF   AVAIL tt-crapemp THEN
                               " - " + tt-crapemp.nmresemp
                          ELSE " - Nao Cadastrado".
                               
    DISPLAY tel_nmresemp WITH FRAME f_ctasal.
     
    HIDE MESSAGE NO-PAUSE.
END.

DEF QUERY  q_associados FOR tt-crapccs. 
DEF BROWSE b_associados QUERY q_associados
     DISP tt-crapccs.nrdconta                COLUMN-LABEL "Conta/dv"
          tt-crapccs.nmfuncio FORMAT "x(40)" COLUMN-LABEL "Nome do Associado"
          WITH 10 DOWN OVERLAY TITLE " Associados ".
           
FORM b_associados HELP "Use <TAB> para navegar" SKIP 
    WITH NO-BOX CENTERED OVERLAY ROW 7 FRAME f_alterar.
    
FORM SKIP(1)
     tel_nmprimtl LABEL " Nome a pesquisar" 
  HELP "Informe NOME ou PARTE dele, ou ainda BRANCOS para listar todos"
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Pesquisa de Associados " FRAME f_associado.

ON RETURN OF b_associados 
    DO:
        IF  AVAILABLE tt-crapccs  THEN
            DO:
                ASSIGN tel_nrdconta = tt-crapccs.nrdconta.
                DISPLAY tel_nrdconta WITH FRAME f_ctasal_conta.  
            END.

        APPLY "GO".  
    END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE TRANSACTION:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_ctasal_opcao.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "CTASAL"  THEN
                DO:
                    HIDE FRAME f_ctasal_opcao.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "A" THEN      /*   Alteracao   */
        DO:
			DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                RUN pesquisa_nome.
               
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.

            IF  aux_msgconfi <> "" THEN
                DO:
                    BELL.
                    MESSAGE aux_msgconfi.
                    NEXT.                 
                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nmfuncio  tel_cdagenci  tel_cdempres
                    WITH FRAME f_ctasal
					
                EDITING:
					
                    READKEY.
					
					IF FRAME-FIELD = "tel_nmfuncio" THEN
						DO:
							IF KEYFUNCTION(LASTKEY) = "RETURN" OR
							   KEYFUNCTION(LASTKEY) = "GO"  OR
							   KEYFUNCTION(LASTKEY) = "TAB" OR
							   KEYFUNCTION(LASTKEY) = "CURSOR-UP" OR
							   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" THEN
								DO:
									IF NOT ValidaNome(INPUT INPUT tel_nmfuncio, 
													  INPUT 1,
													  OUTPUT aux_dscritic) THEN
										DO:
										   MESSAGE aux_dscritic.
										   NEXT.
										END.
								END.
						END.

                    IF  FRAME-FIELD = "tel_cdempres"  THEN
                        DO:
                            IF  LASTKEY = KEYCODE("F7")  THEN
                                DO:
                                    ASSIGN shr_cdempres = INPUT tel_cdempres.
                                    RUN fontes/zoom_empresa.p.
                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdempres
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                    ELSE
                                    IF  shr_cdempres <> 0 THEN
                                        DO:
                                            tel_cdempres = shr_cdempres.
                                            tel_nmresemp = " - " +
                                                           shr_nmresemp.
                                       
                                            DISPLAY tel_cdempres tel_nmresemp
                                                 WITH FRAME f_ctasal.
                                            NEXT-PROMPT tel_cdempres
                                                 WITH FRAME f_ctasal.
                                                 
                                        END.

                                END.
                            ELSE
                            IF   KEYFUNCTION(LASTKEY) = "RETURN" OR
                                 KEYFUNCTION(LASTKEY) = "GO"  THEN
                                 DO:
                                     APPLY "LEAVE" TO tel_cdempres 
                                           IN FRAME f_ctasal.  
                                 END. 
                        END.

                    APPLY LASTKEY.

                END. /* Fim EDITING */
                
                ASSIGN tel_nmfuncio = CAPS(tel_nmfuncio).

                DISPLAY tel_nmfuncio WITH FRAME f_ctasal.

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.        
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.                              

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.

            ASSIGN aux_nrcpfcgc = DECI(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).


            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "C" THEN      /*   Consulta   */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                RUN pesquisa_nome.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.

            PAUSE 0 NO-MESSAGE.

        END.
    ELSE
    IF  glb_cddopcao = "E" THEN     /*  Exclusao  */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                RUN pesquisa_nome.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.
                
                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.
            
            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            ASSIGN aux_flgsolic = FALSE.
                 
            RUN Gera_Impressao.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "I" THEN  /* Inclusao */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdconta WITH FRAME f_ctasal_contaI.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.
                						    
                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.
                 
            ASSIGN tel_cdagenci = 0 
                   tel_cdagetrf = 0
                   tel_cdbantrf = 0
                   tel_cdempres = 0
                   tel_nrdigtrf = ""
                   tel_nrctatrf = 0
                   tel_nrcpfcgc = ""
                   tel_nmfuncio = ""
                   tel_dtcantrf = ?
                   tel_cdsitcta = ""
                   tel_dtadmiss = ?
                   tel_nmresemp = ""
                   tel_dsbantrf = ""
                   tel_dsagetrf = ""
                   tel_nmresage = "".

            DISPLAY tel_nmresemp tel_dsbantrf 
                    tel_nmresage tel_dsagetrf WITH FRAME f_ctasal.
                       
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE  tel_nmfuncio  tel_nrcpfcgc  tel_cdagenci
                        tel_cdempres  tel_cdbantrf  tel_cdagetrf
                        tel_nrctatrf  WITH FRAME f_ctasal

                EDITING:

                    READKEY.
					
					IF FRAME-FIELD = "tel_nmfuncio" THEN
						DO:
							IF KEYFUNCTION(LASTKEY) = "RETURN" OR
							   KEYFUNCTION(LASTKEY) = "GO"  OR
							   KEYFUNCTION(LASTKEY) = "TAB" OR
							   KEYFUNCTION(LASTKEY) = "CURSOR-UP" OR
							   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" THEN
								DO:
								
									IF NOT ValidaNome(INPUT INPUT tel_nmfuncio, 
													  INPUT 1,
													 OUTPUT aux_dscritic) THEN
										DO:
											MESSAGE aux_dscritic.
											NEXT.
										END.
								END.
						END.

                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
							IF  FRAME-FIELD = "tel_cdempres"  THEN
                                DO:
                                   ASSIGN shr_cdempres = INPUT tel_cdempres.
                                   RUN fontes/zoom_empresa.p.
                                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdempres
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                   ELSE
                                   IF   shr_cdempres <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdempres = shr_cdempres
                                                  tel_nmresemp = " - " +
                                                                 shr_nmresemp.
                                       
                                           DISPLAY tel_cdempres tel_nmresemp
                                                   WITH FRAME f_ctasal.
                                           NEXT-PROMPT tel_cdempres
                                                   WITH FRAME f_ctasal.
                                        END.
                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_cdbantrf"  THEN
                                DO:
                                   ASSIGN shr_cdbccxlt = INPUT tel_cdbantrf.
                                   RUN fontes/zoom_banco.p.
                                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdbantrf
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                   ELSE
                                   IF   shr_cdbccxlt <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdbantrf = shr_cdbccxlt
                                                  tel_dsbantrf = " - " +
                                                                 shr_nmresbcc.
                                       
                                           DISPLAY tel_cdbantrf tel_dsbantrf
                                                   WITH FRAME f_ctasal.
                                           NEXT-PROMPT tel_cdbantrf
                                                   WITH FRAME f_ctasal.
                                        END.
                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_cdagetrf"  THEN
                                DO:
                                   ASSIGN shr_cdageban = INPUT tel_cdagetrf.
                                   RUN fontes/zoom_agencia_bancaria.p
                                             (INPUT INPUT tel_cdbantrf).
                                     
                                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdagetrf
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                   ELSE
                                   IF   shr_cdageban <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdagetrf = shr_cdageban
                                                  tel_dsagetrf = " - " +
                                                                 shr_nmageban.
                                       
                                           DISPLAY tel_cdagetrf tel_dsagetrf
                                                   WITH FRAME f_ctasal.
                                           NEXT-PROMPT tel_cdagetrf
                                                   WITH FRAME f_ctasal.
                                        END.
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.

                END. /* Fim EDITING */
         /*
                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT. */

                ASSIGN tel_nmfuncio = CAPS(tel_nmfuncio).

                DISPLAY tel_nmfuncio WITH FRAME f_ctasal.

                IF  tel_cdbantrf <> 85    THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                            UPDATE tel_nrdigtrf  WITH FRAME f_ctasal.
                            LEAVE.
                        END.
                         
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            NEXT.
                    END.

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.
                
                LEAVE.        

            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.
                                              
            ASSIGN aux_nrcpfcgc = DECI(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).

            RUN Grava_Dados.
                   
            ASSIGN aux_flgsolic = TRUE.
            
            RUN Gera_Impressao.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
            
        END.
    ELSE
    IF  glb_cddopcao = "S" THEN     /*  Substituicao  */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                RUN pesquisa_nome.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.

            IF  aux_msgconfi <> "" THEN
                DO:
                    BELL.
                    MESSAGE aux_msgconfi.
                    NEXT.                 
                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE  tel_cdbantrf  tel_cdagetrf  tel_nrctatrf  
                    WITH FRAME f_ctasal
                EDITING:

                    READKEY.

                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            IF  FRAME-FIELD = "tel_cdbantrf"  THEN
                                DO:
                                    ASSIGN shr_cdbccxlt = INPUT tel_cdbantrf.
                                    RUN fontes/zoom_banco.p.
                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdbantrf
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                    ELSE
                                    IF  shr_cdbccxlt <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdbantrf = shr_cdbccxlt
                                                  tel_dsbantrf = " - " +
                                                                 shr_nmresbcc.
                                       
                                           DISPLAY tel_cdbantrf tel_dsbantrf
                                                 WITH FRAME f_ctasal.
                                           NEXT-PROMPT tel_cdbantrf
                                                 WITH FRAME f_ctasal.
                                        END.
                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_cdagetrf"  THEN
                                DO:
                                   ASSIGN shr_cdageban = INPUT tel_cdagetrf.
                                   RUN fontes/zoom_agencia_bancaria.p
                                             (INPUT INPUT tel_cdbantrf).
                                     
                                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        DO:
                                            NEXT-PROMPT tel_cdagetrf
                                                 WITH FRAME f_ctasal. 
                                            NEXT.
                                        END.
                                   ELSE
                                   IF   shr_cdageban <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdagetrf = shr_cdageban
                                                  tel_dsagetrf = " - " +
                                                                 shr_nmageban.
                                       
                                           DISPLAY tel_cdagetrf tel_dsagetrf
                                                   WITH FRAME f_ctasal.
                                           NEXT-PROMPT tel_cdagetrf
                                                   WITH FRAME f_ctasal.
                                        END.
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.

                END. /* Fim EDITING */

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                IF  tel_cdbantrf <> 85 THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                            UPDATE tel_nrdigtrf  WITH FRAME f_ctasal.
                            LEAVE.
                        END.
                      
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            NEXT.
                    END.

                LEAVE.        
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.   

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF  aux_confirma <> "S"   THEN
                NEXT.

            RUN Grava_Dados.

            ASSIGN aux_flgsolic = TRUE.

            RUN Gera_Impressao.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

        END.
    ELSE
    IF  glb_cddopcao = "X" THEN     /*  Reativar Conta  */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                RUN pesquisa_nome.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*  F4 OU FIM  */
                NEXT.

            RUN Valida_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF  aux_confirma <> "S"   THEN
                NEXT.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            ASSIGN aux_flgsolic = TRUE.

            RUN Gera_Impressao.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
        END.
   
END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE pesquisa_nome:

    UPDATE tel_nrdconta WITH FRAME f_ctasal_conta

    EDITING:

        DO WHILE TRUE:

            READKEY PAUSE 1.

            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        ASSIGN tel_nmprimtl = "".

                        UPDATE tel_nmprimtl WITH FRAME f_associado.

                        RUN Busca_Nome.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        LEAVE.                                     
                    END.  

                    HIDE FRAME f_associado NO-PAUSE.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        LEAVE.

                    OPEN QUERY q_associados FOR EACH tt-crapccs NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE b_associados WITH FRAME f_alterar.
                        LEAVE.
                    END.

                    HIDE FRAME f_alterar NO-PAUSE.    

                END. /* IF  LASTKEY = KEYCODE("F7") */

            APPLY LASTKEY. 
            LEAVE.                 

        END. /* fim DO WHILE */

    END. /* fim do EDITING */

END.
/* .......................................................................... */

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapccs.

    RUN conecta_handle.

    MESSAGE "Aguarde, carregando dados... ".

    RUN Busca_Dados IN h-b1wgen0151
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT tel_nrdconta,
          INPUT glb_cddopcao,
          INPUT FALSE, /* flgerlog */
         OUTPUT aux_msgconfi,
         OUTPUT TABLE tt-crapccs,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.
    
    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    IF  glb_cddopcao = "I" THEN
        RETURN "OK".

    FIND tt-crapccs NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-crapccs THEN
        NEXT.

    ASSIGN tel_cdagenci = tt-crapccs.cdagenci
           tel_cdempres = tt-crapccs.cdempres
           tel_cdagetrf = tt-crapccs.cdagetrf
           tel_cdbantrf = tt-crapccs.cdbantrf
           tel_nrdigtrf = tt-crapccs.nrdigtrf
           tel_nrctatrf = tt-crapccs.nrctatrf
           tel_nrcpfcgc = STRING(STRING(tt-crapccs.nrcpfcgc,
                                 "99999999999"),"xxx.xxx.xxx-xx")
           tel_nmfuncio = tt-crapccs.nmfuncio
           tel_dtcantrf = tt-crapccs.dtcantrf
           tel_dtadmiss = tt-crapccs.dtadmiss
           tel_cdsitcta = tt-crapccs.cdsitcta
           tel_nmresage = tt-crapccs.nmresage
           tel_nmresemp = tt-crapccs.nmresemp
           tel_dsbantrf = tt-crapccs.dsbantrf
           tel_dsagetrf = tt-crapccs.dsagetrf.

    ASSIGN 
        /* Campo Digito somente visivel se Banco diferente de 85 */
        tel_nrdigtrf:VISIBLE IN FRAME f_ctasal = NOT (tt-crapccs.cdbantrf = 85). 

    DISPLAY tel_nmfuncio  tel_nrcpfcgc  tel_cdagenci  tel_nmresage
            tel_cdempres  tel_nmresemp  tel_cdbantrf  tel_dsbantrf
            tel_cdagetrf  tel_dsagetrf  tel_nrctatrf  
            tel_nrdigtrf  WHEN tel_cdbantrf  <> 85 
            tel_dtadmiss  tel_dtcantrf  tel_cdsitcta  
            WITH FRAME f_ctasal.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Nome:
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapccs.

    RUN conecta_handle.

    MESSAGE "Aguarde, buscando dados... ".

    RUN Pesquisa_Nome IN h-b1wgen0151
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT tel_nmprimtl,
         OUTPUT TABLE tt-crapccs,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.
    
    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Nome */

PROCEDURE Valida_Dados:
    
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    ASSIGN aux_nrcpfcgc = DECI(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).

    MESSAGE "Aguarde, gravando dados... ".

    RUN Valida_Dados IN h-b1wgen0151
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */
          INPUT tel_nrdconta,
          INPUT glb_cddopcao,
          INPUT tel_cdagenci,
          INPUT tel_cdempres,
          INPUT tel_cdbantrf,
          INPUT tel_cdagetrf,
          INPUT tel_nrctatrf,
          INPUT tel_nrdigtrf,
          INPUT aux_nrcpfcgc,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.
    
    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Grava_Dados:
    
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    MESSAGE "Aguarde, gravando dados... ".

    ASSIGN aux_nrcpfcgc = DECI(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).
					
    RUN Grava_Dados IN h-b1wgen0151
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_dtmvtolt,
          INPUT 1, /* idorigem */
          INPUT tel_nrdconta,
          INPUT glb_cddopcao,
          INPUT tel_cdagenci,
          INPUT tel_cdempres,
          INPUT tel_nmfuncio,
          INPUT tel_cdagetrf,
          INPUT tel_cdbantrf,
          INPUT tel_nrdigtrf,
          INPUT tel_nrctatrf,
          INPUT aux_nrcpfcgc,
          INPUT FALSE, /* flgerlog */
         OUTPUT aux_nmdcampo,
         OUTPUT tel_dtcantrf,
         OUTPUT tel_dtadmiss,
         OUTPUT tel_cdsitcta,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.
    
    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:
    
    HIDE MESSAGE NO-PAUSE.

    IF   aux_flgsolic THEN
         DO:
             VIEW FRAME f_aguarde_solicitacao.
             PAUSE 2 NO-MESSAGE.
             HIDE FRAME f_aguarde_solicitacao NO-PAUSE.
         END.
    ELSE
         DO:
             VIEW FRAME f_aguarde_cancelamento.
             PAUSE 2 NO-MESSAGE.
             HIDE FRAME f_aguarde_cancelamento NO-PAUSE.
         END.
      
    EMPTY TEMP-TABLE tt-erro.

    /* Pega o nome do terminal */
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter. 

    RUN conecta_handle.
    
    RUN Gera_Impressao IN h-b1wgen0151
        ( INPUT glb_cdcooper,   
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,
          INPUT 1, /* idorigem */
          INPUT tel_nrdconta,
          INPUT tel_cdagenci,
          INPUT tel_cdempres,
          INPUT tel_cdbantrf,
          INPUT tel_cdagetrf,
          INPUT aux_flgsolic,
          INPUT aux_nmendter,
          INPUT TRUE, /*flgerlog*/
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro) NO-ERROR.

    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    ASSIGN par_flgrodar = TRUE.

    { includes/impressao.i }
    
    RETURN "OK".

END PROCEDURE. /* Gera_Impressao */

PROCEDURE busca_pac:

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.

    DO WITH FRAME f_ctasal:
    
        ASSIGN tel_cdagenci.
               
    END.

    RUN busca-crapage IN h-b1wgen0059
                    ( INPUT glb_cdcooper,
                      INPUT tel_cdagenci,
                      INPUT "", /*dsagepac*/
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapage ).

    IF  VALID-HANDLE(h-b1wgen0059) THEN
        DELETE OBJECT h-b1wgen0059.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE busca_bancos:

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.

    DO WITH FRAME f_ctasal:
    
        ASSIGN tel_cdbantrf.
               
    END.

    RUN busca-crapban IN h-b1wgen0059
                    ( INPUT tel_cdbantrf,
                      INPUT "", /* nmextbcc */
                      INPUT 999999,
                      INPUT 1,
                      INPUT 0, /* nrispbif */
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapban ).

    IF  VALID-HANDLE(h-b1wgen0059) THEN
        DELETE OBJECT h-b1wgen0059.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE busca_agencia:

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.

    DO WITH FRAME f_ctasal:
    
        ASSIGN tel_cdagetrf
               tel_cdbantrf.
               
    END.

    RUN busca-crapagb IN h-b1wgen0059
                    ( INPUT tel_cdbantrf,
                      INPUT tel_cdagetrf,
                      INPUT "", /* nmageban */
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapagb ).

    IF  VALID-HANDLE(h-b1wgen0059) THEN
        DELETE OBJECT h-b1wgen0059.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE busca_empresa:

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.

    DO WITH FRAME f_ctasal:
    
        ASSIGN tel_cdempres.
               
    END.

    RUN busca-crapemp IN h-b1wgen0059
                    ( INPUT glb_cdcooper,
                      INPUT tel_cdempres,
                      INPUT "", /* nmresemp */
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapemp ).

    IF  VALID-HANDLE(h-b1wgen0059) THEN
        DELETE OBJECT h-b1wgen0059.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0151) THEN
        RUN sistema/generico/procedures/b1wgen0151.p
            PERSISTENT SET h-b1wgen0151.

END PROCEDURE.

PROCEDURE desconecta_handle:

    IF  VALID-HANDLE(h-b1wgen0151) THEN
        DELETE OBJECT h-b1wgen0151.

END PROCEDURE.

FUNCTION ValidaNome RETURN LOGICAL
    (  INPUT par_nomedttl AS CHAR,     
       INPUT par_inpessoa AS INTE,       
      OUTPUT par_dscritic AS CHAR) :

    DEF VAR aux_listachr AS CHAR            NO-UNDO.
    DEF VAR aux_listanum AS CHAR            NO-UNDO.
    DEF VAR aux_nrextent AS HANDLE EXTENT   NO-UNDO.
    DEF VAR aux_nrextnum AS HANDLE EXTENT   NO-UNDO.
    DEF VAR aux_contador AS INTE            NO-UNDO.

    /* Verificacoes para o nome */
    ASSIGN aux_listachr = "=,%,&,#,+,?,',','.',/,;,[,],!,@,$,(,),*,|,\,:,<,>," +
                          "~{,~},~,,~~,À,Á,Â,Ã,Ä,Å,à,á,â,ã,ä,å,Ò,Ó,Ô,Õ,Ö,Ø,ò" +
						  "ó,ô,õ,ö,ø,È,É,Ê,Ë,è,é,ê,ë,Ç,ç,Ì,Í,Î,Ï,ì,í,î,ï,Ù,Ú,Û" +
						  "Ü,ù,ú,û,ü,ÿ,Ñ,ñ,~^,!,@,#,$,%,¨,&,*,<,>,:,´,`".

           aux_listanum = "0,1,2,3,4,5,6,7,8,9".

    EXTENT(aux_nrextent) = NUM-ENTRIES(aux_listachr).

    DO aux_contador = 1 TO EXTENT(aux_nrextent):
        IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listachr)) <> 0 THEN
            DO:
               ASSIGN par_dscritic = "O Caracter " + TRIM(ENTRY(aux_contador,
                                                                aux_listachr))
                                     + " nao permitido.".
               RETURN FALSE.
            END.
    END.
 
    IF  par_inpessoa = 1 THEN
        DO:
           
            EXTENT(aux_nrextnum) = NUM-ENTRIES(aux_listanum).
            
            DO aux_contador = 1 TO EXTENT(aux_nrextnum):
                IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listanum)) <> 0 THEN
                    DO:
                        ASSIGN par_dscritic = "Nao sao permitidos numeros".
                        RETURN FALSE.
                    END.
            END.
        END.

    RETURN TRUE.

END FUNCTION.