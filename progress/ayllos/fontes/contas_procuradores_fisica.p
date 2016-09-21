/* ............................................................................

   Programa: fontes/contas_procuradores_fisica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jose Luis Marchezoni (DB1 Informatica)
   Data    : Setembro/2010                     Ultima Atualizacao: 09/09/2016
      
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos procuradores do
               Associado pela tela CONTAS (Pessoa Fisica).

   Alteracoes: 14/04/2011 - Inclusão de CEP integrado. (André - DB1)
               
               14/10/2011 - Passado parametro par_vloutren com valor zero e
                            par_dsoutren com valor vazio, para as procedures
                            Valida_Dados e Grava_Dados, pois, estes campos
                            so interessam quando for PJ. (Fabricio)
                            
               23/11/2011 - Removido os parametros passados nas procedures
                            Valida_Dados e Grava_Dados inerentes aos campos
                            de tipo de rendimento e valor dos rendimentos.
                            (Fabricio)
                            
               16/04/2012 - Ajuste referente ao projeto GP - Socios menores
                           (Adriano).       
                           
               05/10/2012 - Ajuste no find first da procedure atualiza_tela
                            (Adriano).                 
               
               24/06/2013 - Inclusão da opção de poderes (Jean Michel).    
               
               30/09/2013 - Alteração referente a salvar poderes. (Jean Michel).

               27/05/2014 - Alterado o LIKE do shared "shr_cdestcvl" de 
                            crapass para crapttl (Douglas - Chamado 131253)
                            
               27/05/2015 - Reformulacao cadastral (Gabriel-RKAM).    

			   05/11/2015 - Inclusao de tratamento para novo poder(cddpoder = 10),
				            PRJ 131 - Ass. Conjunta (Jean Michel). 

               09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						   aux_qtminast referente a quantidade minima de assinatura
						   conjunta, SD 514239 (Jean Michel).
.............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgen0038tt.i }

DEF NEW SHARED  VAR shr_dsnacion AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF NEW SHARED  VAR shr_cdestcvl LIKE crapttl.cdestcvl                 NO-UNDO.
DEF NEW SHARED  VAR shr_dsestcvl AS CHAR   FORMAT "x(12)"              NO-UNDO.


/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 5 INIT ["Alterar",
                                            "Consultar",
                                            "Excluir",
                                            "Incluir",
                                            "Poderes"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 5 INIT ["A","C","E","I","P"]       NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
     
DEF VAR tel_nrdctato LIKE crapavt.nrdctato                             NO-UNDO.
DEF VAR tel_tpdocava LIKE crapavt.tpdocava                             NO-UNDO.
DEF VAR tel_nrdocava LIKE crapavt.nrdocava                             NO-UNDO.
DEF VAR tel_cdoeddoc LIKE crapavt.cdoeddoc                             NO-UNDO.
DEF VAR tel_cdufddoc LIKE crapavt.cdufddoc                             NO-UNDO.
DEF VAR tel_dtemddoc LIKE crapavt.dtemddoc                             NO-UNDO.
DEF VAR tel_dtvalida LIKE crapavt.dtvalida                             NO-UNDO.

DEF VAR tel_dtnascto LIKE crapavt.dtnascto                             NO-UNDO.
DEF VAR tel_cdsexcto AS CHAR   FORMAT "!"                              NO-UNDO.
DEF VAR tel_cdestcvl LIKE crapavt.cdestcvl                             NO-UNDO.
DEF VAR tel_dsnacion LIKE crapavt.dsnacion                             NO-UNDO.
DEF VAR tel_dsnatura LIKE crapavt.dsnatura                             NO-UNDO.
DEF VAR tel_nmmaecto LIKE crapavt.nmmaecto                             NO-UNDO.
DEF VAR tel_nmpaicto LIKE crapavt.nmpaicto                             NO-UNDO.
DEF VAR tel_vledvmto LIKE crapavt.vledvmto                             NO-UNDO.

DEF VAR tel_dsrelbem LIKE crapbem.dsrelbem                             NO-UNDO.

DEF VAR tel_nrcepend LIKE crapenc.nrcepend                             NO-UNDO.
DEF VAR tel_dsendere LIKE crapenc.dsendere                             NO-UNDO.
DEF VAR tel_nrendere LIKE crapenc.nrendere                             NO-UNDO.
DEF VAR tel_complend LIKE crapenc.complend                             NO-UNDO.
DEF VAR tel_nmbairro AS CHAR FORMAT "X(40)"                            NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(25)"                            NO-UNDO.
DEF VAR tel_cdufende LIKE crapenc.cdufende                             NO-UNDO.
DEF VAR tel_nrcxapst LIKE crapenc.nrcxapst                             NO-UNDO.

DEF VAR aux_flgcarta AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgachou AS LOGICAL                                        NO-UNDO.
                                                                 
DEF VAR tel_dshabmen AS CHAR FORMAT "x(13)"                            NO-UNDO.
DEF VAR tel_inhabmen AS INTE FORMAT "9"                                NO-UNDO.
DEF VAR tel_dthabmen AS DATE FORMAT "99/99/9999"                       NO-UNDO.
                                                                 
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0058 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_verrespo AS LOG                                            NO-UNDO.
DEF VAR aux_permalte AS LOG                                            NO-UNDO.
DEF VAR aux_lstpoder AS CHAR                                           NO-UNDO.

DEF VAR aux_descpode AS CHAR FORMAT "x(34)"                            NO-UNDO. 
DEF VAR aux_flgisola AS CHAR                                           NO-UNDO.
DEF VAR aux_flgconju AS CHAR                                           NO-UNDO.
DEF VAR aux_dsoutpo1 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo2 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo3 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo4 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo5 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_contstri AS INT                                            NO-UNDO.
DEF VAR aux_codpoder AS INT                                            NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.

DEF TEMP-TABLE cratavt NO-UNDO LIKE tt-crapavt.

DEF QUERY q_procuradores FOR cratavt.

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY cratavt.nrdctato  COLUMN-LABEL "Conta/dv"
            cratavt.nmdavali  COLUMN-LABEL "Nome"     FORMAT "x(23)"
            cratavt.cdcpfcgc  COLUMN-LABEL "C.P.F."   FORMAT "x(14)"
            cratavt.nrdocava  COLUMN-LABEL "C.I."     FORMAT "x(12)"
            cratavt.dsvalida  COLUMN-LABEL "Vigencia" FORMAT "x(10)"
            /*cratavt.dsproftl  COLUMN-LABEL "Cargo"    FORMAT "x(10)"*/
            WITH 9 DOWN NO-BOX.

FORM SKIP(13)
     reg_dsdopcao[1]  AT 10  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 21  NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3]  AT 36  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4]  AT 49  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[5]  AT 61  NO-LABEL FORMAT "x(7)"
     WITH ROW 6 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE " REPRESENTANTE/PROCURADOR " FRAME f_regua.

FORM b_procuradores
     WITH ROW 8 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.
     
FORM tel_nrdctato AT  1   LABEL " Conta/dv"
        HELP "Informe conta do representante/procurador ou 0 p/ nao cooperado"

     tel_nrcpfcgc AT 30   LABEL "   C.P.F."
                          HELP "Informe o CPF do representante/procurador"
                          VALIDATE(tel_nrcpfcgc <> ""  AND
                                   tel_nrcpfcgc <> "0",
                                   "375 - O campo deve ser preenchido.")
     SKIP
     tel_nmdavali AT  5  LABEL " Nome" 
                         HELP "Informe o nome do representante/procurador"
                         VALIDATE(tel_nmdavali <> "",
                                   "375 - O campo deve ser preenchido.")
     SKIP
     tel_tpdocava AT  1  LABEL "Documento"  AUTO-RETURN
                         HELP "Entre com o tipo de documento (CH, CI, CP, CT)"
                         VALIDATE(tel_tpdocava = "CH" OR
                                  tel_tpdocava = "CI" OR
                                  tel_tpdocava = "CP" OR
                                  tel_tpdocava = "CT",
                                  "021 - Tipo de documento errado.")

     tel_nrdocava        NO-LABEL           AUTO-RETURN
                         HELP "Informe o documento do representante/procurador"
                         VALIDATE(tel_nrdocava <> "",
                                  "022 - Numero do documento errado.")

     tel_cdoeddoc AT 31  LABEL "Org.Emi."   AUTO-RETURN
                         HELP "Informe o orgao emissor do documento"
                         VALIDATE(tel_cdoeddoc <> "",
                                  "375 - O campo deve ser preenchido.")
                         
     tel_cdufddoc AT 48  LABEL "U.F."       AUTO-RETURN
                         HELP "Informe o Estado onde o documento foi emitido"
                         VALIDATE(CAN-DO("RS,SC,PR,SP,RJ,ES,MG,MS,MT,GO,DF," +
                                         "BA,PE,PA,PI,MA,RO,RR,AC,AM,TO,AM," +
                                         "CE,SE,AP,AL",tel_cdufddoc),
                                         "033 - Unidade da federacao errada.")
     
     tel_dtemddoc AT 58  LABEL "Data Emi."  AUTO-RETURN
                         HELP "Informe a data de emissao do documento"
                         VALIDATE(tel_dtemddoc <= glb_dtmvtolt,
                                  "013 - Data errada.")
     SKIP
     tel_dtnascto AT  1  LABEL "Data Nascimento" AUTO-RETURN
                 HELP "Informe a data de nascimento do representante/procurador"
                                                 FORMAT "99/99/9999"
                         VALIDATE(tel_dtnascto <= glb_dtmvtolt,
                                  "013 - Data errada.")
     
     tel_inhabmen LABEL " Responsab. Legal"
            HELP "(0)-menor/maior (1)-menor emancipado (2)-incapacidade civil"
     tel_dshabmen       NO-LABEL
     SKIP
     tel_dthabmen  LABEL "Data Emancipacao"
                        HELP "Informe a data de emancipacao"                                            
     tel_cdsexcto AT 31  LABEL "Sexo"  HELP "(M)asculino / (F)eminino"

     tel_cdestcvl AT 38  LABEL "  Estado Civil"
             HELP "Informe o codigo do estado civil ou pressione F7 para listar"
     
     tel_dsestcvl        NO-LABEL
     SKIP
     tel_dsnacion AT  3  LABEL "Nacionalidade"   AUTO-RETURN
                      HELP "Informe a nacionalidade ou pressione F7 para listar"
                         VALIDATE(CAN-FIND(crapnac WHERE crapnac.dsnacion =
                                                         tel_dsnacion),
                                  "028 - Nacionalidade nao cadastrada.")

     tel_dsnatura AT 42  LABEL "Natural de"      AUTO-RETURN
                       HELP "Informe a naturalidade ou pressione F7 para listar"
                         VALIDATE(CAN-FIND(crapnat WHERE crapnat.dsnatura =
                                                         tel_dsnatura),
                                  "029 - Naturalidade nao cadastrada.")

     SKIP
     tel_nrcepend AT  4  LABEL "CEP" FORMAT "99999,999"
                HELP "Informe o CEP do endereco ou pressiona F7 para pesquisar"
                         VALIDATE(tel_nrcepend <> 0,
                                  "034 - CEP deve ser informado.")
                         
     tel_dsendere AT 22  LABEL "End.Residencial"        AUTO-RETURN
                         HELP "Informe o endereco do representante/procurador"
     SKIP
     tel_nrendere AT  3  LABEL "Nro."        AUTO-RETURN
                         HELP "Informe o numero da residencia"
     tel_complend AT 26  LABEL "Complemento" AUTO-RETURN
                         HELP "Informe o complemento do endereco"
     SKIP
     tel_nmbairro AT  1  LABEL "Bairro"  AUTO-RETURN
                         HELP "Informe o nome do bairro"
     tel_nrcxapst AT 50  LABEL "Caixa Postal"
                         HELP "Informe o numero da caixa postal"
     SKIP
     tel_nmcidade AT  1  LABEL "Cidade"  AUTO-RETURN
                         HELP "Informe o nome da cidade"
                         
     tel_cdufende AT 50  LABEL "U.F."      AUTO-RETURN
                         HELP "Informe o Estado do endereco"
     SKIP
     "Filiacao:"
     tel_nmmaecto AT 11  LABEL "Mae"
                         VALIDATE(tel_nmmaecto <> "",
                                  "375 - O campo deve ser preenchido.")
                         HELP "Informe o nome da mae do representante/procurador"
     SKIP
     tel_nmpaicto AT 11  LABEL "Pai"
                         HELP "Informe o nome do pai do representante/procurador"
     SKIP

     tel_vledvmto AT  1  LABEL "Endividamento"
                         HELP "Entre com o valor do endividamento."
           
     tel_dsrelbem AT 36  LABEL "Descricao dos bens"  FORMAT "x(22)"
                         HELP "Pressione <ENTER> para visualizar os bens."   
     
     tel_dtvalida AT 6   LABEL "Vigencia"
           HELP "Entre com a data de vigencia ou 31/12/9999 para Indeterminado"
                         VALIDATE(tel_dtvalida > glb_dtmvtolt,
                                  "013 - Data errada.")

    WITH ROW 7 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX 
          FRAME f_procuradores.

/* ...... Opcao de Poderes ....... */
DEF QUERY q-poderes FOR tt-crappod.

DEF BROWSE b-poderes QUERY q-poderes
  DISPLAY 
          aux_descpode                    FORMAT "x(34)" LABEL "Poder"
          aux_flgconju                                   LABEL "Em Conjunto"
          aux_flgisola                                   LABEL "Isolado"
          WITH 8 DOWN WIDTH 60 NO-LABELS CENTERED OVERLAY TITLE " Poderes ".

FORM b-poderes
   HELP "Use as SETAS para navegar, <F4> para sair, <ENTER> para editar."
   WITH ROW 8 WIDTH 60 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_poderes.

FORM 
   aux_dsoutpo1
   SKIP
   aux_dsoutpo2
   SKIP
   aux_dsoutpo3
   SKIP
   aux_dsoutpo4
   SKIP
   aux_dsoutpo5
   
   WITH ROW 10 WIDTH 50 SIDE-LABEL NO-LABELS CENTERED OVERLAY TITLE " Outros Poderes " FRAME f_poderes_outros.

ON ROW-DISPLAY OF b-poderes IN FRAM f_poderes DO:
    
    glb_dscritic = "".
    aux_descpode = "".
    aux_flgconju = "".
    aux_flgisola = "".
    aux_descpode = ENTRY(tt-crappod.cddpoder, aux_lstpoder).
    
    IF tt-crappod.cddpoder = 9 THEN
		DO:
			aux_descpode = TRIM(ENTRY(tt-crappod.cddpoder, aux_lstpoder)).
		END.
    ELSE
        DO:
			aux_descpode = TRIM(ENTRY(tt-crappod.cddpoder, aux_lstpoder)).
			aux_flgconju = IF tt-crappod.flgconju = NO THEN
								"Nao"
						   ELSE "Sim".
			aux_flgisola = IF tt-crappod.flgisola = NO THEN
								"Nao"
						   ELSE "Sim".
								   
            IF tt-crappod.cddpoder = 10 THEN
				DO:
					aux_flgisola = "Nao".
				END.
        END.
END.

ON ANY-KEY OF b-poderes IN FRAME f_poderes DO:
    
    ASSIGN aux_dsoutpo1 = ""
           aux_dsoutpo2 = ""
           aux_dsoutpo3 = ""
           aux_dsoutpo4 = ""
           aux_dsoutpo5 = ""
           aux_codpoder = tt-crappod.cddpoder.
       
    IF LASTKEY = 32 OR LASTKEY = 13 THEN
        DO:
           IF tt-crappod.cddpoder = 9 THEN
                DO:
                    DO  aux_contstri = 1 TO NUM-ENTRIES(tt-crappod.dsoutpod,"#"):
            
                        IF aux_contstri = 1 THEN
                           aux_dsoutpo1 = ENTRY(aux_contstri,tt-crappod.dsoutpod,"#").
                        ELSE
                            IF  aux_contstri = 2 THEN
                                aux_dsoutpo2 = ENTRY(aux_contstri,tt-crappod.dsoutpod,"#").
                        ELSE
                            IF aux_contstri = 3 THEN
                               aux_dsoutpo3 = ENTRY(aux_contstri,tt-crappod.dsoutpod,"#").
                        ELSE
                            IF aux_contstri = 4 THEN
                               aux_dsoutpo4 = ENTRY(aux_contstri,tt-crappod.dsoutpod,"#").
                        ELSE
                            IF aux_contstri = 5 THEN
                               aux_dsoutpo5 = ENTRY(aux_contstri,tt-crappod.dsoutpod,"#").
                    END.
         
                    UPDATE aux_dsoutpo1 aux_dsoutpo2 aux_dsoutpo3 aux_dsoutpo4 aux_dsoutpo5 WITH FRAME f_poderes_outros. 
                    tt-crappod.dsoutpod = aux_dsoutpo1 + "#" + 
                                          aux_dsoutpo2 + "#" +
                                          aux_dsoutpo3 + "#" +
                                          aux_dsoutpo4 + "#" +
                                          aux_dsoutpo5.
                END.
            ELSE
                DO:
					IF tt-crappod.flgconju = NO THEN
                        DO:
                            IF tt-crappod.flgisola = YES THEN
                                ASSIGN tt-crappod.flgisola = NO
                                       tt-crappod.flgconju = NO.
                            ELSE
                                ASSIGN tt-crappod.flgisola = NO
                                       tt-crappod.flgconju = YES.
                        END.
                    ELSE
                        DO:
                            ASSIGN tt-crappod.flgisola = YES
								   tt-crappod.flgconju = NO.
                        END.
								
					IF tt-crappod.cddpoder = 10 THEN
						DO:
							ASSIGN tt-crappod.flgisola = NO.
						END.
                END.        
   
            RUN Grava_Dados_Poderes IN h-b1wgen0058(
                            INPUT glb_cdcooper,
                            INPUT tel_nrdctato,
                            INPUT tel_nrdconta,
                            INPUT DEC(tel_nrcpfcgc),
                            INPUT 0, /*cdagenci*/
                            INPUT 0, /*nrdcaixa*/
                            INPUT glb_cdoperad,
                            INPUT glb_nmdatela,
                            INPUT 1, /*idorigem*/
                            INPUT glb_dtmvtolt,
                            INPUT tel_idseqttl, /*aux_idseqttl,*/
                            INPUT TABLE tt-crappod,
                            OUTPUT TABLE tt-crappod,
                            OUTPUT TABLE tt-erro).        
   
            IF RETURN-VALUE = "NOK" THEN
               DO:
                   FIND FIRST tt-erro NO-ERROR.
                
                   IF AVAILABLE tt-erro THEN
                      DO:
                        MESSAGE tt-erro.dscritic.
                        PAUSE(3) NO-MESSAGE.
                        NEXT.
                      END.
                   ELSE
                       DO:
                         BELL.
                         MESSAGE "Nao foi possivel atualizar poderes".
                         PAUSE(3) NO-MESSAGE.
                         NEXT.
                       END.
               END.
    
   
            CLEAR FRAME f_poderes_outros.
            HIDE  FRAME f_poderes_outros.
            CLOSE QUERY q-poderes.
    
            OPEN QUERY q-poderes FOR EACH tt-crappod WHERE tt-crappod.cdcooper = glb_cdcooper AND
                                                           tt-crappod.nrctapro = tel_nrdctato AND
                                                           tt-crappod.nrdconta = tel_nrdconta AND
                                                           tt-crappod.nrcpfpro = DEC(tel_nrcpfcgc) AND
														   tt-crappod.cddpoder <> 10															
                                                           NO-LOCK.
            REPOSITION q-poderes TO ROW(aux_codpoder).
        END.
END.
/* ...... Fim Opcao de Poderes ....... */

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_nrcepend DO:
    IF  INPUT tel_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tel_nrcepend IN FRAME f_procuradores DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrcepend.

    IF  tel_nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                           tel_dsendere = tt-endereco.dsendere 
                           tel_nmbairro = tt-endereco.nmbairro 
                           tel_nmcidade = tt-endereco.nmcidade 
                           tel_cdufende = tt-endereco.cdufende.
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

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende 
            WITH FRAME f_procuradores.

    NEXT-PROMPT tel_nrendere WITH FRAME f_procuradores.
END.

ON ENTRY OF b_procuradores IN FRAME f_browse DO:

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_procuradores TO ROW(aux_nrdlinha).

END.

ON ANY-KEY OF b_procuradores IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "GO"   THEN
        RETURN NO-APPLY.

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.
    
            IF   reg_contador > 5   THEN
                 reg_contador = 1.
                
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 5.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
            
           IF AVAILABLE cratavt THEN
                DO:   
                
                    ASSIGN aux_nrdrowid = cratavt.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_procuradores").
                         
                    /* Desmarca todas as linhas do browse para poder remarcar*/
                    b_procuradores:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.

           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

/* Nao deixa passar pelo CPF sem ser um numero valido */
ON LEAVE OF tel_nrcpfcgc IN FRAME f_procuradores DO:

    ASSIGN INPUT tel_nrcpfcgc.

    IF  NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
                             INPUT tel_nrcpfcgc,
                             OUTPUT aux_dscritic) THEN 
        DO:
            MESSAGE aux_dscritic.
            NEXT-PROMPT tel_nrcpfcgc WITH FRAME f_procuradores.
            RETURN NO-APPLY.
        END.
   
   HIDE MESSAGE NO-PAUSE.
END.

/* Atualiza o estado civil */
ON LEAVE, GO OF tel_cdestcvl IN FRAME f_procuradores DO:

   ASSIGN INPUT tel_cdestcvl.

   IF  NOT DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                            INPUT tel_cdestcvl, 
                            INPUT "dsestcvl",
                            OUTPUT tel_dsestcvl,
                            OUTPUT aux_dscritic) THEN 
       DO:
          DISPLAY tel_dsestcvl WITH FRAME f_procuradores.

          MESSAGE aux_dscritic.
          PAUSE 2 NO-MESSAGE. 
          RETURN NO-APPLY.
       END.

   DISPLAY tel_dsestcvl WITH FRAME f_procuradores.

   /* Quando estado civil for "Casado" e idade for menor que 18 anos,
      a pessoa passa automaticamente a ser emancipada.*/
   IF CAN-DO("2,3,4,8,9,11",STRING(tel_cdestcvl)) THEN
      DO:
         ASSIGN INPUT tel_dtnascto.

         IF VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT(h-b1wgen9999).

         RUN sistema/generico/procedures/b1wgen9999.p 
             PERSISTENT SET h-b1wgen9999.

         RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                                   INPUT glb_dtmvtolt,
                                   OUTPUT aux_nrdeanos,
                                   OUTPUT aux_nrdmeses,
                                   OUTPUT aux_dsdidade).

         IF VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT(h-b1wgen9999).

         IF aux_nrdeanos < 18 AND 
            tel_inhabmen = 0  THEN
            DO:
               ASSIGN tel_inhabmen = 1
                      tel_dthabmen = glb_dtmvtolt.
              
               DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                                INPUT tel_inhabmen,
                                OUTPUT tel_dshabmen,
                                OUTPUT glb_dscritic).
              
               DISP tel_inhabmen
                    tel_dthabmen
                    tel_dshabmen
                    WITH FRAME f_procuradores.

            END.

         ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_procuradores = TRUE
                tel_dthabmen:READ-ONLY IN FRAME f_procuradores = TRUE
                aux_nrdeanos = 0
                aux_nrdmeses = 0
                aux_dsdidade = "".
   
      END.
   ELSE
      ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_procuradores = FALSE
             tel_dthabmen:READ-ONLY IN FRAME f_procuradores = FALSE.
      
   
END.


ON RETURN OF tel_dsrelbem DO:

    /* Cadastra os bens do procurador terceiro */
    RUN fontes/cadastra_bens.p (INPUT-OUTPUT TABLE tt-bens,
                                INPUT "PROCURADORES",
                                INPUT ?,
                                INPUT "").

    FIND FIRST tt-bens NO-LOCK NO-ERROR.
    
    IF   AVAILABLE tt-bens   THEN
         tel_dsrelbem = tt-bens.dsrelbem.
    ELSE
         tel_dsrelbem = "".

    DISPLAY tel_dsrelbem WITH FRAME f_procuradores. 
         
END.

ON LEAVE OF tel_inhabmen IN FRAME f_procuradores DO:

   /* Habilitacao */
   ASSIGN INPUT tel_inhabmen.

   DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                    INPUT tel_inhabmen,
                    OUTPUT tel_dshabmen,
                    OUTPUT glb_dscritic).
                                       
   DISPLAY tel_dshabmen WITH FRAME f_procuradores.

   ASSIGN INPUT tel_dtnascto.

   IF VALID-HANDLE(h-b1wgen9999) THEN
      DELETE OBJECT(h-b1wgen9999).

   RUN sistema/generico/procedures/b1wgen9999.p 
       PERSISTENT SET h-b1wgen9999.

   RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                             INPUT glb_dtmvtolt,
                             OUTPUT aux_nrdeanos,
                             OUTPUT aux_nrdmeses,
                             OUTPUT aux_dsdidade).

   IF VALID-HANDLE(h-b1wgen9999) THEN
      DELETE OBJECT(h-b1wgen9999).


   IF tel_inhabmen = 0   AND 
      tel_cdestcvl <> 1  AND
      tel_cdestcvl <> 12 AND 
      aux_nrdeanos < 18  THEN
      ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_procuradores = FALSE.
   ELSE
      IF tel_inhabmen <> 1 THEN
         DO:
             ASSIGN tel_dthabmen = ?.
     
             ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_procuradores = TRUE.
     
             DISP tel_dthabmen WITH FRAME f_procuradores.
     
         END.
      ELSE
         ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_procuradores = FALSE.


   ASSIGN aux_nrdeanos = 0
          aux_nrdmeses = 0
          aux_dsdidade = "".

END.


DO WHILE TRUE:
    
   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   IF  NOT VALID-HANDLE(h-b1wgen0058) THEN
       RUN sistema/generico/procedures/b1wgen0058.p
           PERSISTENT SET h-b1wgen0058.

   ASSIGN glb_nmrotina = "PROCURADORES"
          glb_cddopcao = reg_cddopcao[reg_contador]
          glb_cdcritic = 0.
   
   CLEAR FRAME f_procuradores.
   CLEAR FRAME f_poderes.
   CLEAR FRAME f_poderes_outros.
   
   HIDE  FRAME f_regua.
   HIDE  FRAME f_poderes.
   HIDE  FRAME f_browse.
   HIDE  FRAME f_procuradores.
   HIDE  FRAME f_poderes_opcoes.
   
   /* Limpa tabela dos bens do teceiros */ 
   EMPTY TEMP-TABLE tt-bens.
   
   /* Carrega a lista de procuradores/representantes */
   EMPTY TEMP-TABLE cratavt.

   RUN Busca_Dados ( INPUT "C" ) .

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   OPEN QUERY q_procuradores FOR EACH cratavt BY cratavt.nrdctato
                                              BY cratavt.nrcpfcgc.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
      UPDATE b_procuradores WITH FRAME f_browse.
      LEAVE.

   END.
   
   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   { includes/acesso.i }
   
   ASSIGN glb_nmrotina = "PROCURADORES_FISICA".
   
   IF  glb_cddopcao = "I" THEN
       DO:
        
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
             ASSIGN tel_nrdctato = 0
                    tel_nrcpfcgc = ""
                    aux_nrdrowid = ?.
                    
             CLEAR FRAME f_procuradores.
             
             UPDATE tel_nrdctato WITH FRAME f_procuradores
          
             EDITING:
               READKEY.
               HIDE MESSAGE NO-PAUSE.
          
               APPLY LASTKEY.
               IF  GO-PENDING THEN
                   DO:
                      ASSIGN INPUT tel_nrdctato.
                      IF  tel_nrdctato <> 0  THEN
                          DO:
                            
                              RUN Busca_Dados ( INPUT glb_cddopcao ).
          
                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.
                          END.
                   END.
             END.
          
             IF  tel_nrdctato = 0 THEN
                 DO:
                    
                    UPDATE tel_nrcpfcgc WITH FRAME f_procuradores
                    
                    EDITING:
                      READKEY.
                      HIDE MESSAGE NO-PAUSE.
                      
                      APPLY LASTKEY.
                      IF  GO-PENDING THEN
                          DO:
                             ASSIGN INPUT tel_nrcpfcgc.
          
                             IF  NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" 
                                                      IN h-b1wgen0060,
                                                      INPUT tel_nrcpfcgc,
                                                      OUTPUT glb_dscritic) THEN
                                 DO:
                                    MESSAGE glb_dscritic.
                                    NEXT.
                                 END.
                          END.
                    END.
                    
                    RUN Busca_Dados ( INPUT glb_cddopcao ).
          
                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.
                 END.
          
             RUN Atualiza_Tela. 
          
             RUN Busca_Dados_Bens.
                
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                IF   glb_cdcritic <> 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                     END.
              
                tel_dsrelbem:READ-ONLY IN FRAME f_procuradores = TRUE.
                
                UPDATE tel_nmdavali WHEN tel_nrdctato = 0
                       tel_tpdocava WHEN tel_nrdctato = 0
                       tel_nrdocava WHEN tel_nrdctato = 0
                       tel_cdoeddoc WHEN tel_nrdctato = 0
                       tel_cdufddoc WHEN tel_nrdctato = 0
                       tel_dtemddoc WHEN tel_nrdctato = 0
                       tel_dtnascto WHEN tel_nrdctato = 0
                       tel_inhabmen WHEN tel_nrdctato = 0
                       tel_dthabmen WHEN tel_nrdctato = 0
                       tel_cdsexcto WHEN tel_nrdctato = 0
                       tel_cdestcvl WHEN tel_nrdctato = 0
                       tel_dsnacion WHEN tel_nrdctato = 0
                       tel_dsnatura WHEN tel_nrdctato = 0
                       tel_nrcepend WHEN tel_nrdctato = 0
                       tel_nrendere WHEN tel_nrdctato = 0
                       tel_complend WHEN tel_nrdctato = 0
                       tel_nrcxapst WHEN tel_nrdctato = 0
                       tel_nmmaecto WHEN tel_nrdctato = 0
                       tel_nmpaicto WHEN tel_nrdctato = 0
                       tel_vledvmto WHEN tel_nrdctato = 0
                       tel_dsrelbem WHEN tel_nrdctato = 0
                       tel_dtvalida
                       WITH FRAME f_procuradores
                       
                EDITING:
                
                    READKEY.
                    HIDE MESSAGE NO-PAUSE.
          
                    IF  FRAME-FIELD = "tel_cdsexcto"   THEN
                        DO:
                             /* So deixa escrever M ou F */
                             IF   NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                                  "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                                  "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                                  KEY-FUNCTION(LASTKEY))   THEN
                                  MESSAGE "Escolha (M)asculino / (F)eminino".
                             ELSE
                                  DO:
                                     IF  KEY-FUNCTION(LASTKEY) =
                                         "BACKSPACE"  THEN
                                         NEXT-PROMPT tel_cdsexcto
                                           WITH FRAME f_procuradores.
          
                                     HIDE MESSAGE NO-PAUSE.
                                     APPLY LASTKEY.
                                 END.
                         END.
                    ELSE
                    IF  LASTKEY = KEYCODE("F7") THEN
                        DO:
                            IF  FRAME-FIELD = "tel_nrcepend"  THEN
                                DO:
                                /* Inclusão de CEP integrado. (André - DB1) */
                                    RUN fontes/zoom_endereco.p 
                                                  (INPUT 0,
                                                   OUTPUT TABLE tt-endereco).
                            
                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                            
                                    IF  AVAIL tt-endereco THEN
                                        ASSIGN tel_nrcepend = 
                                                          tt-endereco.nrcepend
                                               tel_dsendere = 
                                                          tt-endereco.dsendere
                                               tel_nmbairro =
                                                          tt-endereco.nmbairro
                                               tel_nmcidade = 
                                                          tt-endereco.nmcidade
                                               tel_cdufende = 
                                                          tt-endereco.cdufende.
                                                              
                                    DISPLAY tel_nrcepend    
                                            tel_dsendere
                                            tel_nmbairro
                                            tel_nmcidade
                                            tel_cdufende
                                            WITH FRAME f_procuradores.

                                    IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                        NEXT-PROMPT tel_nrendere 
                                                    WITH FRAME f_procuradores.

                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_dsnacion"  THEN
                                DO:
                                    shr_dsnacion = INPUT tel_dsnacion.
                                    RUN fontes/nacion.p.
                                    IF   shr_dsnacion <> " " THEN
                                         DO:
                                             tel_dsnacion = shr_dsnacion.
                                             DISPLAY tel_dsnacion
                                                    WITH FRAME f_procuradores.
                                             NEXT-PROMPT tel_dsnacion
                                                    WITH FRAME f_procuradores.
                                         END.
                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_cdestcvl"  THEN
                                DO:
                                    shr_cdestcvl = INPUT tel_cdestcvl.
                                    RUN fontes/zoom_estcivil.p.
                                    IF  shr_cdestcvl <> 0 THEN
                                        DO:
                                           ASSIGN tel_cdestcvl = shr_cdestcvl
                                                  tel_dsestcvl = shr_dsestcvl.

                                           DISPLAY tel_cdestcvl
                                                   tel_dsestcvl
                                                   WITH FRAME f_procuradores.
          
                                           NEXT-PROMPT tel_cdestcvl
                                                     WITH FRAME f_procuradores.
                                        END.
          
                                    PAUSE 0.
                                    VIEW FRAME f_regua.
                                END.
                            ELSE
                            IF  FRAME-FIELD = "tel_dsnatura" THEN
                                DO:
                                    RUN fontes/natura.p (OUTPUT shr_dsnatura).
                                    IF  shr_dsnatura <> "" THEN
                                        DO:
                                            tel_dsnatura = shr_dsnatura.

                                            DISPLAY tel_dsnatura
                                                    WITH FRAME f_procuradores.

                                            NEXT-PROMPT tel_dsnatura
                                                    WITH FRAME f_procuradores.
                                        END.
                                END.
          
                        END. /* Fim do F7 */
                    ELSE
                         APPLY LASTKEY.
          
                    IF  GO-PENDING THEN
                        DO:
                            ASSIGN INPUT tel_nmdavali
                                   INPUT tel_tpdocava
                                   INPUT tel_nrdocava
                                   INPUT tel_cdoeddoc
                                   INPUT tel_cdufddoc
                                   INPUT tel_dtemddoc
                                   INPUT tel_dtnascto
                                   INPUT tel_inhabmen
                                   INPUT tel_dthabmen
                                   INPUT tel_cdsexcto
                                   INPUT tel_cdestcvl
                                   INPUT tel_dsnacion
                                   INPUT tel_dsnatura
                                   INPUT tel_nrcepend
                                   INPUT tel_dsendere
                                   INPUT tel_nrendere
                                   INPUT tel_complend
                                   INPUT tel_nmbairro
                                   INPUT tel_nmcidade
                                   INPUT tel_cdufende
                                   INPUT tel_nrcxapst
                                   INPUT tel_nmmaecto
                                   INPUT tel_nmpaicto
                                   INPUT tel_vledvmto
                                   INPUT tel_dsrelbem
                                   INPUT tel_dtvalida.
                           
                        END.

                END. /* Fim do EDITING */
                
                RUN Valida_Dados.
          
                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.
          
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.
          
                LEAVE.
          
             END.
          
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.
          
             LEAVE.
          
          END. /* Fim DO WHILE */
          
          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.
          
          ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                 tel_cdoeddoc = CAPS(tel_cdoeddoc)
                 tel_cdufddoc = CAPS(tel_cdufddoc)
                 tel_dsnacion = CAPS(tel_dsnacion)
                 tel_dsnatura = CAPS(tel_dsnatura)
                 tel_dsendere = CAPS(tel_dsendere)
                 tel_complend = CAPS(tel_complend)
                 tel_nmbairro = CAPS(tel_nmbairro)
                 tel_nmcidade = CAPS(tel_nmcidade)
                 tel_cdufende = CAPS(tel_cdufende)
                 tel_nmmaecto = CAPS(tel_nmmaecto)
                 tel_nmpaicto = CAPS(tel_nmpaicto).
                   
          DISPLAY tel_nmdavali    tel_cdoeddoc    tel_cdufddoc
                  tel_dsnacion    tel_dsnatura    tel_dsendere    
                  tel_complend    tel_nmbairro    tel_nmcidade    
                  tel_cdufende    tel_nmmaecto    tel_nmpaicto    
                  WITH FRAME f_procuradores.
              
          
          RUN proc_confirma.
          
          IF   aux_confirma = "S" THEN
               DO:
                  
                  RUN Grava_Dados.
          
                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT. 
          
               END.

       END.
   ELSE
   IF  glb_cddopcao = "C" AND aux_nrdrowid <> ? THEN
       DO:
          RUN Atualiza_Tela.

          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             PAUSE.
             LEAVE.
          END.
       END.
   ELSE
   IF  glb_cddopcao = "A"   AND  aux_nrdrowid <> ?    THEN
       DO:
        
          RUN Atualiza_Tela.
                  
          RUN Busca_Dados_Bens.

          tel_dsrelbem:READ-ONLY IN FRAME f_procuradores = TRUE. 
    
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             UPDATE tel_nmdavali WHEN tel_nrdctato = 0
                    tel_tpdocava WHEN tel_nrdctato = 0
                    tel_nrdocava WHEN tel_nrdctato = 0
                    tel_cdoeddoc WHEN tel_nrdctato = 0
                    tel_cdufddoc WHEN tel_nrdctato = 0
                    tel_dtemddoc WHEN tel_nrdctato = 0
                    tel_dtnascto WHEN tel_nrdctato = 0
                    tel_inhabmen WHEN tel_nrdctato = 0
                    tel_dthabmen WHEN tel_nrdctato = 0
                    tel_cdsexcto WHEN tel_nrdctato = 0
                    tel_cdestcvl WHEN tel_nrdctato = 0
                    tel_dsnacion WHEN tel_nrdctato = 0
                    tel_dsnatura WHEN tel_nrdctato = 0
                    tel_nrcepend WHEN tel_nrdctato = 0
                    tel_nrendere WHEN tel_nrdctato = 0
                    tel_complend WHEN tel_nrdctato = 0
                    tel_nrcxapst WHEN tel_nrdctato = 0
                    tel_nmmaecto WHEN tel_nrdctato = 0
                    tel_nmpaicto WHEN tel_nrdctato = 0
                    tel_vledvmto WHEN tel_nrdctato = 0
                    tel_dsrelbem WHEN tel_nrdctato = 0
                    tel_dtvalida
                    WITH FRAME f_procuradores
                 
             EDITING:
                
                READKEY.
                HIDE MESSAGE NO-PAUSE.
                IF  FRAME-FIELD = "tel_cdsexcto"   THEN
                    DO:
                        /* So deixa escrever M ou F */
                        IF   NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                             "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                             "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                             KEY-FUNCTION(LASTKEY))   THEN
                             MESSAGE "Escolha (M)asculino / (F)eminino".
                        ELSE 
                             DO:
                                IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
                                    NEXT-PROMPT tel_cdsexcto
                                                WITH FRAME f_procuradores.
                                                  
                                HIDE MESSAGE NO-PAUSE.
                                APPLY LASTKEY.
                             END.
                    END.
                ELSE
                IF  LASTKEY = KEYCODE("F7") THEN
                    DO:
                       IF  FRAME-FIELD = "tel_nrcepend"  THEN
                           DO:
                               /* Inclusão de CEP integrado. (André - DB1) */
                               RUN fontes/zoom_endereco.p 
                                             (INPUT 0,
                                              OUTPUT TABLE tt-endereco).
                            
                               FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                            
                               IF  AVAIL tt-endereco THEN
                                   ASSIGN tel_nrcepend = tt-endereco.nrcepend
                                          tel_dsendere = tt-endereco.dsendere
                                          tel_nmbairro = tt-endereco.nmbairro
                                          tel_nmcidade = tt-endereco.nmcidade
                                          tel_cdufende = tt-endereco.cdufende.
                            
                               DISPLAY tel_nrcepend    
                                       tel_dsendere
                                       tel_nmbairro
                                       tel_nmcidade
                                       tel_cdufende
                                       WITH FRAME f_procuradores.

                               IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                   NEXT-PROMPT tel_nrendere 
                                               WITH FRAME f_procuradores.
                           END.
                       ELSE
                       IF  FRAME-FIELD = "tel_dsnacion"  THEN
                           DO:
                               shr_dsnacion = INPUT tel_dsnacion.
                               RUN fontes/nacion.p.
                               IF   shr_dsnacion <> " " THEN
                                    DO:
                                        tel_dsnacion = shr_dsnacion.

                                        DISPLAY tel_dsnacion
                                                WITH FRAME f_procuradores.

                                        NEXT-PROMPT tel_dsnacion
                                                    WITH FRAME f_procuradores.
                                    END.
                           END.
                       ELSE
                       IF  FRAME-FIELD = "tel_cdestcvl"  THEN
                           DO:
                               shr_cdestcvl = INPUT tel_cdestcvl.
                               RUN fontes/zoom_estcivil.p.
                               IF   shr_cdestcvl <> 0 THEN
                                    DO:
                                        ASSIGN tel_cdestcvl = shr_cdestcvl
                                               tel_dsestcvl = shr_dsestcvl.

                                        DISPLAY tel_cdestcvl
                                                tel_dsestcvl
                                                WITH FRAME f_procuradores.
                                                      
                                        NEXT-PROMPT tel_cdestcvl
                                                    WITH FRAME f_procuradores.
                                    END.
                                    
                               PAUSE 0.
                               VIEW FRAME f_regua.
                           END.
                       ELSE    
                       IF  FRAME-FIELD = "tel_dsnatura" THEN
                           DO:
                               RUN fontes/natura.p (OUTPUT shr_dsnatura).
                               IF   shr_dsnatura <> "" THEN
                                    DO:
                                        tel_dsnatura = shr_dsnatura.

                                        DISPLAY tel_dsnatura
                                                WITH FRAME f_procuradores.

                                        NEXT-PROMPT tel_dsnatura
                                                    WITH FRAME f_procuradores.
                                    END.
                           END.
                    END. /* Fim do F7 */
                ELSE
                     APPLY LASTKEY.
                IF  GO-PENDING  THEN
                    DO:
                        ASSIGN INPUT tel_nmdavali
                               INPUT tel_tpdocava
                               INPUT tel_nrdocava
                               INPUT tel_cdoeddoc
                               INPUT tel_cdufddoc
                               INPUT tel_dtemddoc
                               INPUT tel_dtnascto
                               INPUT tel_inhabmen
                               INPUT tel_dthabmen
                               INPUT tel_cdsexcto
                               INPUT tel_cdestcvl
                               INPUT tel_dsnacion
                               INPUT tel_dsnatura
                               INPUT tel_nrcepend
                               INPUT tel_dsendere
                               INPUT tel_nrendere
                               INPUT tel_complend
                               INPUT tel_nmbairro
                               INPUT tel_nmcidade
                               INPUT tel_cdufende
                               INPUT tel_nrcxapst
                               INPUT tel_nmmaecto
                               INPUT tel_nmpaicto
                               INPUT tel_vledvmto
                               INPUT tel_dsrelbem
                               INPUT tel_dtvalida.

                       RUN Valida_Dados.
    
                       IF  RETURN-VALUE <> "OK" THEN
                           NEXT.
                    END.
             END. /* Fim do EDITING */

             LEAVE.

          END. /* Fim do DO WHILE TRUE , Update*/

          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.

          ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                 tel_cdoeddoc = CAPS(tel_cdoeddoc)
                 tel_cdufddoc = CAPS(tel_cdufddoc)
                 tel_dsnacion = CAPS(tel_dsnacion)
                 tel_dsnatura = CAPS(tel_dsnatura)
                 tel_dsendere = CAPS(tel_dsendere)
                 tel_complend = CAPS(tel_complend)
                 tel_nmbairro = CAPS(tel_nmbairro)
                 tel_nmcidade = CAPS(tel_nmcidade)
                 tel_cdufende = CAPS(tel_cdufende)
                 tel_nmmaecto = CAPS(tel_nmmaecto)
                 tel_nmpaicto = CAPS(tel_nmpaicto).

          DISPLAY tel_nmdavali    tel_cdoeddoc    tel_cdufddoc
                  tel_dsnacion    tel_dsnatura    tel_dsendere    
                  tel_complend    tel_nmbairro    tel_nmcidade    
                  tel_cdufende    tel_nmmaecto    tel_nmpaicto    
                  WITH FRAME f_procuradores.

          RUN proc_confirma.

          IF   aux_confirma = "S" THEN
               DO:
                  
                  RUN Grava_Dados.
    
                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT.
               END.
       END.
   ELSE
   IF   glb_cddopcao = "E" AND aux_nrdrowid <> ?    THEN
        DO:
            
           FIND FIRST cratavt WHERE cratavt.nrdrowid = aux_nrdrowid NO-ERROR.

           IF  AVAILABLE cratavt THEN
               DO:
                   IF  tel_nrcpfcgc = "" THEN
                       ASSIGN tel_nrcpfcgc = cratavt.cdcpfcgc.

                   ASSIGN tel_nrdctato = cratavt.nrdctato.
               END.

           RUN Valida_Dados.
    
           IF  RETURN-VALUE <> "OK" THEN
               DO:
                  PAUSE 7 NO-MESSAGE.
                  HIDE MESSAGE NO-PAUSE.
                  NEXT.
               END.
    
           RUN Atualiza_Tela.

           RUN proc_confirma.

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           IF  aux_confirma = "S" THEN
               DO:
                   RUN Exclui_Dados.
    
                   IF  RETURN-VALUE <> "OK" THEN
                       NEXT.
               END.
        END.
    ELSE
       IF glb_cddopcao = "P" AND aux_nrdrowid <> ? THEN
          DO:
             
             EMPTY TEMP-TABLE tt-crappod.
             EMPTY TEMP-TABLE tt-erro.
             
             FIND FIRST cratavt WHERE cratavt.nrdrowid = aux_nrdrowid NO-LOCK NO-ERROR.

             IF AVAILABLE cratavt THEN
                DO:
                   ASSIGN tel_nrdctato = cratavt.nrdctato
                          tel_nrcpfcgc = REPLACE(REPLACE(cratavt.cdcpfcgc,".",""),"-","").
                
                   RUN Busca_Dados_Poderes IN h-b1wgen0058(
                                           INPUT glb_cdcooper,
                                           INPUT 6,
                                           INPUT tel_nrdconta,
                                           INPUT tel_nrdctato,
                                           INPUT DEC(tel_nrcpfcgc),
                                           INPUT 0, /*cdagenci*/
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT 1, /*idorigem*/
                                           INPUT glb_dtmvtolt,
                                           INPUT tel_idseqttl, /*aux_idseqttl,*/
                                           OUTPUT aux_inpessoa,
                                           OUTPUT aux_idastcjt, 
                                           OUTPUT TABLE tt-crappod,
                                           OUTPUT TABLE tt-erro).
                    
                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                         FIND FIRST tt-erro NO-ERROR.
                        
                         IF AVAILABLE tt-erro THEN
                            DO:
                               MESSAGE tt-erro.dscritic.
                               PAUSE(3) NO-MESSAGE.
                               NEXT.
                            END.
                         ELSE
                             DO:
                                BELL.
                                MESSAGE "Nao foi posssivel encontrar poderes".
                                PAUSE(3) NO-MESSAGE.
                                NEXT.
                             END.
                      END.
                END.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                 
                 DYNAMIC-FUNCTION("ListaPoderes" IN h-b1wgen0058, OUTPUT aux_lstpoder).
                
                 OPEN QUERY q-poderes FOR EACH tt-crappod WHERE tt-crappod.cdcooper = glb_cdcooper AND
                                                                tt-crappod.nrctapro = tel_nrdctato AND
                                                                tt-crappod.nrdconta = tel_nrdconta AND
                                                                tt-crappod.nrcpfpro = DEC(tel_nrcpfcgc) AND
																tt-crappod.cddpoder <> 10 NO-LOCK.
                
                 UPDATE b-poderes WITH FRAME f_poderes.
                
                 LEAVE.
             
             END. 
          END.
          
END.

glb_cddopcao = "C".

IF VALID-HANDLE(h-b1wgen0060) THEN
   DELETE OBJECT h-b1wgen0060.

IF VALID-HANDLE(h-b1wgen0058) THEN
   DELETE OBJECT h-b1wgen0058.

CLEAR FRAME f_poderes.
CLEAR FRAME f_poderes_outros.

HIDE  FRAME f_regua.
HIDE  FRAME f_browse.
HIDE  FRAME f_procuradores.
HIDE  FRAME f_poderes.
HIDE  FRAME f_poderes_outros.

/*** PROCEDIMENTOS ***/
PROCEDURE proc_confirma:
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       glb_cdcritic = 0.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */
                                       
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    OR
         aux_confirma <> "S"                   THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Dados:
    
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.

	DEF VAR aux_qtminast AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-bens.
    EMPTY TEMP-TABLE tt-crapavt.

    IF  par_cddopcao = "C" THEN
        ASSIGN 
           tel_nrdctato = 0
           tel_nrcpfcgc = ""
           aux_nrdrowid = ?.
    

    RUN Busca_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT par_cddopcao,
         INPUT tel_nrdctato,
         INPUT tel_nrcpfcgc,
         INPUT aux_nrdrowid,
        OUTPUT TABLE tt-crapavt,
        OUTPUT TABLE tt-bens,
		OUTPUT aux_qtminast,
        OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

   EMPTY TEMP-TABLE cratavt.
   EMPTY TEMP-TABLE tt-bens.

   /*
   FOR EACH tt-crapavt:
       FIND cratavt OF tt-crapavt NO-ERROR.

       IF   NOT AVAILABLE cratavt THEN
            DO:
               CREATE cratavt.
               BUFFER-COPY tt-crapavt TO cratavt.
            END.

       DELETE tt-crapavt.
   END.*/

   FOR EACH tt-crapavt:
         
       FIND FIRST cratavt WHERE cratavt.cdcooper = tt-crapavt.cdcooper AND
                                cratavt.nrdconta = tt-crapavt.nrdconta AND
                                cratavt.nrctremp = tt-crapavt.nrctremp AND
                                cratavt.nrcpfcgc = tt-crapavt.nrcpfcgc 
                                NO-LOCK NO-ERROR.
      
       IF NOT AVAILABLE cratavt THEN
          DO:
             CREATE cratavt.
             BUFFER-COPY tt-crapavt TO cratavt.
          END.
       
      DELETE tt-crapavt.

   END.       

   RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Dados_Bens:

    EMPTY TEMP-TABLE tt-bens.

    RUN Busca_Dados_Bens IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT 0,
         INPUT YES,
         INPUT tel_nrdctato,
         INPUT tel_nrcpfcgc,
        OUTPUT TABLE tt-bens,
        OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Tela:

    FIND FIRST cratavt WHERE (aux_nrdrowid <> ?                AND 
                              cratavt.nrdrowid = aux_nrdrowid) OR 
                             (aux_nrdrowid = ?                 AND
                              cratavt.nrdctato = tel_nrdctato  OR 
                              cratavt.nrdrowid = aux_nrdrowid)    
                              NO-ERROR.
    
    IF  NOT AVAILABLE cratavt THEN
        CREATE cratavt.

    ASSIGN tel_nmdavali = cratavt.nmdavali
           tel_tpdocava = cratavt.tpdocava
           tel_nrdocava = cratavt.nrdocava
           tel_cdoeddoc = cratavt.cdoeddoc
           tel_cdufddoc = cratavt.cdufddoc
           tel_dtemddoc = cratavt.dtemddoc
           tel_dtnascto = cratavt.dtnascto
           tel_cdsexcto = IF cratavt.cdsexcto = 1 THEN "M" ELSE "F"
           tel_cdestcvl = cratavt.cdestcvl
           tel_dsestcvl = cratavt.dsestcvl
           tel_dsnacion = cratavt.dsnacion
           tel_dsnatura = cratavt.dsnatura
           tel_nmmaecto = cratavt.nmmaecto
           tel_nmpaicto = cratavt.nmpaicto
           tel_nrcepend = cratavt.nrcepend
           tel_dsendere = cratavt.dsendres[1]
           tel_nrendere = cratavt.nrendere
           tel_complend = cratavt.complend
           tel_nmbairro = cratavt.nmbairro
           tel_nmcidade = cratavt.nmcidade
           tel_cdufende = cratavt.cdufresd
           tel_dsrelbem = cratavt.dsrelbem[1]
           tel_nrcxapst = cratavt.nrcxapst
           tel_dtvalida = cratavt.dtvalida
           tel_vledvmto = cratavt.vledvmto
           tel_inhabmen = cratavt.inhabmen
           tel_dthabmen = cratavt.dthabmen
           tel_dshabmen = cratavt.dshabmen.
           

    IF  tel_nrdctato = 0 THEN
        ASSIGN tel_nrdctato = cratavt.nrdctato.

    IF  tel_nrcpfcgc = "" THEN
        ASSIGN tel_nrcpfcgc = cratavt.cdcpfcgc.

    DISPLAY tel_nrcpfcgc    tel_nmdavali    tel_tpdocava
            tel_nrdocava    tel_cdoeddoc    tel_cdufddoc
            tel_dtemddoc    tel_dtnascto    tel_cdsexcto
            tel_cdestcvl    tel_dsestcvl    tel_dsnacion
            tel_dsnatura    tel_nrcepend    tel_dsendere
            tel_nrendere    tel_complend    tel_nmbairro
            tel_nmcidade    tel_cdufende    tel_nrcxapst
            tel_nmmaecto    tel_nmpaicto    tel_dtvalida
            tel_nrdctato    tel_vledvmto    tel_dsrelbem    
            tel_dtvalida    tel_inhabmen    tel_dshabmen
            tel_dthabmen
            WITH FRAME f_procuradores.
    
END PROCEDURE.

PROCEDURE Valida_Dados:


    RUN Valida_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT glb_dtmvtolt,
         INPUT glb_cddopcao,
         INPUT tel_nrdctato,
         INPUT tel_nrcpfcgc,
         INPUT tel_nmdavali,
         INPUT tel_tpdocava,
         INPUT tel_nrdocava,
         INPUT tel_cdoeddoc,
         INPUT tel_cdufddoc,
         INPUT tel_dtemddoc,
         INPUT tel_dtnascto,
         INPUT tel_cdsexcto,
         INPUT tel_cdestcvl,
         INPUT tel_dsnacion,
         INPUT tel_dsnatura,
         INPUT tel_nrcepend,
         INPUT tel_dsendere,
         INPUT tel_nrendere,
         INPUT tel_complend,
         INPUT tel_nmbairro,
         INPUT tel_nmcidade,
         INPUT tel_cdufende,
         INPUT tel_nrcxapst,
         INPUT tel_nmmaecto,
         INPUT tel_nmpaicto,
         INPUT tel_vledvmto,
         INPUT tel_dsrelbem,
         INPUT tel_dtvalida,
         INPUT "",
         INPUT ?,
         INPUT 0,
         INPUT FALSE,
         INPUT 0,
         INPUT "",
         INPUT tel_inhabmen,
         INPUT tel_dthabmen,
         INPUT glb_nmrotina,
         INPUT aux_verrespo,
         INPUT aux_permalte,
         INPUT TABLE tt-bens,
         INPUT TABLE tt-resp,
         INPUT TABLE tt-crapavt,
        OUTPUT aux_msgalert,
        OUTPUT TABLE tt-erro,
        OUTPUT aux_nrdeanos,
        OUTPUT aux_nrdmeses,
        OUTPUT aux_dsdidade) .

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

    IF  aux_msgalert <> "" THEN
        DO:
            MESSAGE aux_msgalert.
            PAUSE 7 NO-MESSAGE.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0058) THEN
        DELETE OBJECT h-b1wgen0058.

    RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT SET h-b1wgen0058.

    RUN Grava_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT glb_dtmvtolt,
         INPUT glb_cddopcao,
         INPUT tel_nrdctato,
         INPUT tel_nrcpfcgc,
         INPUT tel_nmdavali,
         INPUT tel_tpdocava,
         INPUT tel_nrdocava,
         INPUT tel_cdoeddoc,
         INPUT tel_cdufddoc,
         INPUT tel_dtemddoc,
         INPUT tel_dtnascto,
         INPUT tel_cdsexcto,
         INPUT tel_cdestcvl,
         INPUT tel_dsnacion,
         INPUT tel_dsnatura,
         INPUT tel_nrcepend,
         INPUT tel_dsendere,
         INPUT tel_nrendere,
         INPUT tel_complend,
         INPUT tel_nmbairro,
         INPUT tel_nmcidade,
         INPUT tel_cdufende,
         INPUT tel_nrcxapst,
         INPUT tel_nmmaecto,
         INPUT tel_nmpaicto,
         INPUT tel_vledvmto,
         INPUT tel_dsrelbem,
         INPUT tel_dtvalida,
         INPUT "",
         INPUT ?,
         INPUT 0,
         INPUT FALSE,
         INPUT 0,
         INPUT "",
         INPUT tel_inhabmen,
         INPUT tel_dthabmen,
         INPUT glb_nmrotina,
         INPUT TABLE tt-bens,
         INPUT TABLE tt-resp,
        OUTPUT aux_msgalert,
        OUTPUT TABLE tt-erro) .

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

    IF  aux_msgalert <> "" THEN
        MESSAGE aux_msgalert.

    DELETE OBJECT h-b1wgen0058.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT tel_nrcpfcgc,
        OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Verifica_Bloqueio:

    RUN Verifica_Bloqueio IN h-b1wgen0058
        ( INPUT glb_cdcooper,
          INPUT tel_nrdconta,
          INPUT "",
          INPUT cratavt.dsproftl,
         OUTPUT aux_msgalert ).

    IF  aux_msgalert <> "" THEN
        DO:
           MESSAGE aux_msgalert.
           PAUSE 7 NO-MESSAGE.     
        END.
END.

PROCEDURE Limpa_Endereco:

    ASSIGN tel_nrcepend = 0  
           tel_dsendere = ""  
           tel_nmbairro = "" 
           tel_nmcidade = ""  
           tel_cdufende = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrcxapst = 0.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende  tel_nrendere
            tel_complend  tel_nrcxapst 
            WITH FRAME f_procuradores.

END PROCEDURE.

/*...........................................................................*/
