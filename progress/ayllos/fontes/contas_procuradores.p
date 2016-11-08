/* ............................................................................

   Programa: Fontes/contas_procuradores.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                         Ultima Atualizacao: 09/09/2016
      
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos procuradores do
               Associado pela tela CONTAS (Pessoa Juridica).

   Alteracoes: 08/08/2006 - Tratada a vigencia das procuracoes na temp-table
                            cratavt para o browse b_procuradoes (David).
                            
               12/11/2007 - Efetuado acerto na opcao "I", para verificar 
                            Data de Emancipacao(crapttl.dthabmen) quando
                            Procurador for menor de idade (Diego).
                            
               22/01/2008 - Idade minima para procuradores "< 16" critica 585.
                          - Criticas para alteracoes de procuradores vinculados
                            ao acesso a internet.
                          - Logar alteracoes na craplgm e craplgi.
                            (Guilherme).
                            
               25/03/2008 - Tratamentos de procuradores para cartao magnetico
                            (Guilherme).

               20/05/2008 - Alterada a chamada das Naturalidades (Evandro).
        
               14/08/2009 - Incluir campo endividamento e cadastrar os bens
                            dos representantes quando nao cooperados 
                            (Gabriel).

               01/09/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               15/12/2009 - Incluir novo campo data de admissao dos
                            socios (Gabriel).             

               08/02/2010 - Adaptar para utilizacao de BO (Jose Luis, DB1)
               
               08/02/2010 - Enviar 0 para idseqttl(nrctremp) (Jose Luis, DB1)
               
               14/04/2011 - Inclusão de CEP integrado. (André - DB1)
               
               15/08/2011 - Tratamento GE (Guilherme)
               
               14/10/2011 - Criado frame f_outras_fontes_renda, para ser
                            preenchido caso seja socio/proprietario e nao
                            dependa economicamente. (Fabricio)
                            
               18/10/2011 - Colocado em comentario os campos tel_tpdrendi,
                            tel_dstipren e tel_vldrendi, do frame 
                            f_procuradores. Colocado em comentario tambem,
                            o frame f_rendimentos. (Fabricio)
                            
              23/11/2011 -  Removido os campos tel_tpdrendi, tel_dstipren e 
                            tel_vldrendi, do frame f_procuradores. 
                            Removido tambem, o frame f_rendimentos.
                         -  Liberado os campos de percentual societario e de
                            dependencia economica para qualquer cargo que seja
                            informado. (Fabricio)
                            
              16/04/2012 - Ajuste para incluir responsavel legal quando,
                           repr/procurador for menor de idade. Projeto
                           GP - Socios Menores (Adriano).  
                           
              05/10/2012 - Ajuste no find first da procedure atualiza_tela
                           (Adriano).
              
              24/06/2013 - Inclusão da opção de poderes (Jean Michel).              
              
              30/09/2013 - Alteração referente a salvar poderes. (Jean Michel).  
              
              24/03/2014 - Excluido validaçao de dados antes da Exclusao.
                          (Daniele - Chamado 134639)

              27/05/2014 - Alterado o like do shared "shr_cdestcvl" de crapass 
                           para crapttl (Douglas - Chamado 131253)
           
              06/06/2014 - Adicionado "Valida_Dados" para a Exclusao. A validação 
                           para CPF será ajustado dentro da b1wgen0058.
                           Adicionado "Busca_Dados" para a Exclusao. No busca dados 
                           eh validado para nao excluir todos os procuradores.
                           (Douglas - Chamado 134639)
                           
              10/11/2014 - Permitido que seja tirado o poder de assinatura
                           em conjunto E de forma isolada. 
                           (Chamado 158762) - (Fabricio)
                           
              18/02/2015 - Incluir regra para validar cartões bancoob na exclusão
                           de representante, conforme SD 251759 ( Renato - Supero )
                           
              22/07/2015 - Reformulacao cadastral (Gabriel-RKAM).                                        
			  
			  05/11/2015 - Inclusao de tratamento para novo poder(cddpoder = 10),
						   PRJ 131 - Ass. Conjunta (Jean Michel).
						   
			  09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						   aux_qtminast referente a quantidade minima de assinatura
						   conjunta, SD 514239 (Jean Michel).			    
.............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgen0038tt.i }


DEF INPUT PARAM par_nmrotina AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_tpdopcao AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc                     NO-UNDO.
DEF OUTPUT PARAM par_permalte AS LOG                                   NO-UNDO.
DEF OUTPUT PARAM par_verrespo AS LOG                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR tt-resp.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-bens.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-crapavt.


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
DEF VAR tel_dtadmsoc LIKE crapavt.dtadmsoc                             NO-UNDO.
DEF VAR tel_dsproftl AS CHAR FORMAT "x(21)"                            NO-UNDO.
DEF VAR tel_dsprofan AS CHAR                                           NO-UNDO.

DEF VAR tel_dtnascto LIKE crapavt.dtnascto                             NO-UNDO.
DEF VAR tel_cdsexcto AS CHAR   FORMAT "!"                              NO-UNDO.
DEF VAR tel_cdestcvl LIKE crapavt.cdestcvl                             NO-UNDO.
DEF VAR tel_dsnacion LIKE crapavt.dsnacion                             NO-UNDO.
DEF VAR tel_dsnatura LIKE crapavt.dsnatura                             NO-UNDO.
DEF VAR tel_nmmaecto LIKE crapavt.nmmaecto                             NO-UNDO.
DEF VAR tel_nmpaicto LIKE crapavt.nmpaicto                             NO-UNDO.
DEF VAR tel_vledvmto LIKE crapavt.vledvmto                             NO-UNDO.

/* GE */
DEF VAR tel_persocio LIKE crapavt.persocio                             NO-UNDO.
DEF VAR tel_flgdepec LIKE crapavt.flgdepec                             NO-UNDO.

DEF VAR aux_persocio LIKE crapavt.persocio                             NO-UNDO.

DEF VAR tel_dsrelbem LIKE crapbem.dsrelbem                             NO-UNDO.

DEF VAR tel_nrcepend LIKE crapenc.nrcepend                             NO-UNDO.
DEF VAR tel_dsendere LIKE crapenc.dsendere                             NO-UNDO.
DEF VAR tel_nrendere LIKE crapenc.nrendere                             NO-UNDO.
DEF VAR tel_complend LIKE crapenc.complend                             NO-UNDO.
DEF VAR tel_nmbairro AS CHAR FORMAT "X(40)"                            NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(25)"                            NO-UNDO.
DEF VAR tel_cdufende LIKE crapenc.cdufende                             NO-UNDO.
DEF VAR tel_nrcxapst LIKE crapenc.nrcxapst                             NO-UNDO.

DEF VAR tel_dshabmen AS CHAR FORMAT "x(13)"                            NO-UNDO.
DEF VAR tel_inhabmen AS INTE FORMAT "9"                                NO-UNDO.
DEF VAR tel_dthabmen AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR aux_flgcarta AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgachou AS LOGICAL                                        NO-UNDO.

DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0058 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0052 AS HANDLE                                         NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR tel_vloutren   AS DECI                                         NO-UNDO.
DEF VAR tel_dsoutren_1 AS CHAR                                         NO-UNDO.
DEF VAR tel_dsoutren_2 AS CHAR                                         NO-UNDO.
DEF VAR tel_dsoutren_3 AS CHAR                                         NO-UNDO.
DEF VAR tel_dsoutren_4 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrcpfcgc   AS DEC                                          NO-UNDO.
DEF VAR aux_idseqttl   AS INT                                          NO-UNDO.
DEF VAR aux_flsincro   AS LOG                                          NO-UNDO.
DEF VAR aux_verrespo   AS LOG                                          NO-UNDO.
DEF VAR aux_nmdcampo   AS CHAR                                         NO-UNDO.
DEF VAR aux_rowidben   AS ROWID                                        NO-UNDO.
DEF VAR aux_cpfdoben   AS CHAR                                         NO-UNDO.
DEF VAR aux_lstpoder AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.

DEF VAR aux_descpode AS CHAR FORMAT "x(34)"                            NO-UNDO. 
DEF VAR aux_flgisola AS CHAR                                           NO-UNDO.
DEF VAR aux_flgconju AS CHAR                                           NO-UNDO.

DEF VAR aux_fisolado AS LOG                                           NO-UNDO.
DEF VAR aux_conjunto AS LOG                                           NO-UNDO.

DEF VAR aux_dsoutpo1 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo2 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo3 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo4 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_dsoutpo5 AS CHAR FORMAT "x(48)"                            NO-UNDO.
DEF VAR aux_contstri AS INT                                            NO-UNDO.
DEF VAR aux_codpoder AS INT                                            NO-UNDO.

DEF VAR aux_fltemcrd AS INT                                            NO-UNDO.

DEF VAR aux_flgerror   AS LOGI NO-UNDO.

DEF TEMP-TABLE cratavt    NO-UNDO LIKE tt-crapavt.
DEF TEMP-TABLE bens       NO-UNDO LIKE tt-bens.
DEF TEMP-TABLE tt-cravavt NO-UNDO LIKE tt-crapavt.
DEF TEMP-TABLE resp_legal NO-UNDO LIKE tt-resp.
DEF TEMP-TABLE tt-crabavt NO-UNDO LIKE tt-crapavt.
DEF TEMP-TABLE tt-bensb   NO-UNDO LIKE tt-bens.
DEF TEMP-TABLE tt-bensv   NO-UNDO LIKE tt-bens. 


DEF QUERY q_procuradores FOR cratavt.

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY cratavt.nrdctato  COLUMN-LABEL "Conta/dv"
            cratavt.nmdavali  COLUMN-LABEL "Nome"     FORMAT "x(13)"
            cratavt.cdcpfcgc  COLUMN-LABEL "C.P.F."   FORMAT "x(14)"
            cratavt.nrdocava  COLUMN-LABEL "C.I."     FORMAT "x(12)"
            cratavt.dsvalida  COLUMN-LABEL "Vigencia" FORMAT "x(10)"
            cratavt.dsproftl  COLUMN-LABEL "Cargo"    FORMAT "x(10)"
            WITH 9 DOWN NO-BOX.

FORM SKIP(12)
     reg_dsdopcao[1]  AT 10  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 21  NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3]  AT 36  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4]  AT 49  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[5]  AT 61  NO-LABEL FORMAT "x(7)"
     
     WITH ROW 7 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE " REPRESENTANTE/PROCURADOR " FRAME f_regua.

 
FORM b_procuradores
     WITH ROW 9 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.
     
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
                                         "CE,SE,AL,AP",tel_cdufddoc),
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
                                                 
     tel_cdsexcto   LABEL "Sexo"  HELP "(M)asculino / (F)eminino"

     tel_cdestcvl  LABEL "  Estado Civil"
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
                 HELP "Informe o CEP do endereco ou pressione F7 para pesquisar"
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
     tel_nmcidade AT 1  LABEL "Cidade"  AUTO-RETURN
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
     tel_dsrelbem  AT  1  LABEL "Descricao dos bens"  FORMAT "x(22)"
                          HELP "Pressione <ENTER> para visualizar os bens."   
     SKIP
     tel_dtvalida AT 6   LABEL "Vigencia"
     HELP "Entre com a data de vigencia ou 31/12/9999 para Indeterminado"
                        VALIDATE(tel_dtvalida > glb_dtmvtolt,
                                 "013 - Data errada.")

    tel_dsproftl AT 28  LABEL "Cargo"
                        HELP "Pressione <F7> para listar os cargos disponiveis."
                        VALIDATE(CAN-DO("SOCIO/PROPRIETARIO,DIRETOR/ADMINISTRADOR,PROCURADOR," +
                                        "SOCIO COTISTA,SOCIO ADMINISTRADOR,SINDICO,"           + 
                                        "TESOUREIRO,ADMINISTRADOR",STRING(tel_dsproftl)),
                                        "014 - Opcao errada.")


    tel_dtadmsoc  AT 58  LABEL "Admissao"
     HELP "Entre com a data de admissao do socio na empresa."
                        VALIDATE ((tel_dtadmsoc <= glb_dtmvtolt  AND
                                   YEAR(tel_dtadmsoc) >= 1000)  OR
                                  tel_dtadmsoc = ?,
                                  "013 - Data errada.")

     tel_vledvmto AT  1  LABEL "Endividamento"
      HELP "Entre com o valor do endividamento."
           
     tel_persocio AT 35 LABEL "% Societ." FORMAT "zz9.99"
                        HELP "Informe o percentual societario"

     tel_flgdepec AT 55 LABEL "Depend. Econ." 
                        HELP "Informe se o socio depende economicamente da empresa"
    WITH ROW 5 WIDTH 80 OVERLAY SIDE-LABELS TITLE " DADOS DO REPRESENTANTE/PROCURADOR "
          FRAME f_procuradores.

FORM SKIP(1)
     tel_vloutren LABEL "Valor"     FORMAT "zzz,zz9.99"
     VALIDATE(tel_vloutren > 0, "375 - O campo deve ser preenchido.")
     SKIP(1)
     tel_dsoutren_1   LABEL "Referente" FORMAT "x(50)"
     VALIDATE(LENGTH(TRIM(tel_dsoutren_1)) > 0, 
              "375 - O campo deve ser preenchido.")
     SKIP
     tel_dsoutren_2   NO-LABEL AT 12    FORMAT "x(50)"
     SKIP
     tel_dsoutren_3   NO-LABEL AT 12    FORMAT "x(50)"
     SKIP
     tel_dsoutren_4   NO-LABEL AT 12    FORMAT "x(50)"
     WITH OVERLAY SIDE-LABELS CENTERED 
     TITLE " Outras Fontes de Renda do Socio " ROW 12 
     FRAME f_outras_fontes_renda.

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_nrcepend DO:

    IF INPUT tel_nrcepend = 0  THEN
       RUN Limpa_Endereco.

END.


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


ON RETURN OF tel_nrcepend IN FRAME f_procuradores DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrcepend.

    IF tel_nrcepend <> 0  THEN 
       DO:
           RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                       OUTPUT TABLE tt-endereco).
    
           FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
           IF AVAIL tt-endereco THEN
              DO:
                  ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                         tel_dsendere = tt-endereco.dsendere 
                         tel_nmbairro = tt-endereco.nmbairro 
                         tel_nmcidade = tt-endereco.nmcidade 
                         tel_cdufende = tt-endereco.cdufende.
              END.
           ELSE
             DO:
                 IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    RETURN NO-APPLY.
                     
                 MESSAGE "CEP nao cadastrado.".
                 RUN Limpa_Endereco.
                 RETURN NO-APPLY.

             END.

       END.
    ELSE
       RUN Limpa_Endereco.

    DISPLAY tel_nrcepend  
            tel_dsendere
            tel_nmbairro  
            tel_nmcidade
            tel_cdufende 
            WITH FRAME f_procuradores.

    NEXT-PROMPT tel_nrendere WITH FRAME f_procuradores.

END.

ON ANY-KEY OF tel_dsproftl IN FRAME f_procuradores DO:
    
    HIDE MESSAGE NO-PAUSE.

    IF INPUT tel_dsproftl = "SOCIO/PROPRIETARIO" THEN
        DO:
            RUN busca_perc_socio IN h-b1wgen0058 (INPUT glb_cdcooper,
                                                  INPUT INPUT tel_dsproftl,
                                                  INPUT tel_persocio,
                                                 OUTPUT aux_persocio,
                                                 OUTPUT TABLE tt-erro).
       
            IF RETURN-VALUE <> "OK"  THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                   IF AVAIL tt-erro  THEN
                      DO:
                          MESSAGE tt-erro.dscritic.

                          /* volta a situacao anterior do campo */
                          APPLY "RECALL". 
                          RETURN.

                      END.
                   ELSE
                   DO:
                       MESSAGE "Nao foi possivel encontrar % Min " + 
                               "Socio - TAB036".

                       /* volta a situacao anterior do campo */
                       APPLY "RECALL". 
                       RETURN.

                   END.

               END.

        END.

    ENABLE tel_persocio 
           tel_flgdepec 
           WITH FRAME f_procuradores.

    NEXT-PROMPT tel_persocio WITH FRAME f_procuradores.
    PAUSE 0 NO-MESSAGE.

END.

ON RETURN OF tel_persocio IN FRAME f_procuradores DO:

    ASSIGN aux_flgerror = FALSE.

    IF INPUT tel_persocio > 0 THEN
       DO:
           RUN busca_perc_socio IN h-b1wgen0058 (INPUT glb_cdcooper,
                                                 INPUT INPUT tel_dsproftl,
                                                 INPUT INPUT tel_persocio,
                                                OUTPUT aux_persocio,
                                                OUTPUT TABLE tt-erro).
    
           IF RETURN-VALUE <> "OK"  THEN
              DO:
                  ASSIGN aux_flgerror = TRUE.
            
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF AVAIL tt-erro  THEN
                     DO:
                         MESSAGE tt-erro.dscritic.

                         /* volta a situacao anterior do campo */
                         APPLY "RECALL". 
                         /*RETURN.*/

                     END.
                  ELSE
                     DO:
                         MESSAGE "Nao foi possivel encontrar % Min " + 
                                 "Socio - TAB036".

                         /* volta a situacao anterior do campo */
                         APPLY "RECALL". 
                         /*RETURN.*/
                     END.

              END.

       END.
    ELSE
       ASSIGN aux_persocio = 0.

    IF (INPUT tel_persocio < aux_persocio) OR 
       (INPUT tel_persocio = 0)            OR
        aux_flgerror                       THEN
        DO:
            ASSIGN tel_flgdepec = FALSE 
                   tel_vloutren = 0
                   tel_dsoutren_1 = ""
                   tel_dsoutren_2 = ""
                   tel_dsoutren_3 = ""
                   tel_dsoutren_4 = "".
       
            DISPLAY tel_flgdepec WITH FRAME f_procuradores.
            DISABLE tel_flgdepec WITH FRAME f_procuradores.

        END.
    ELSE
      IF (INPUT tel_persocio >= aux_persocio) 
          AND NOT aux_flgerror                THEN
          ENABLE tel_flgdepec
                 WITH FRAME f_procuradores.

END.

ON RETURN OF tel_flgdepec IN FRAME f_procuradores DO:
    
    IF INPUT tel_flgdepec = FALSE THEN
    DO:
        /*IF tel_dsproftl = "SOCIO/PROPRIETARIO" THEN
        DO:*/
            FIND crapavt WHERE crapavt.cdcooper = glb_cdcooper AND
                               crapavt.nrdconta = tel_nrdconta AND
                               crapavt.nrdctato = tel_nrdctato AND
                               crapavt.nrcpfcgc = 
                               DEC(REPLACE(REPLACE(tel_nrcpfcgc, ".",""), "-",""))
                               NO-ERROR.

            IF AVAIL crapavt THEN
            DO:
                ASSIGN tel_vloutren = crapavt.vloutren.

                IF LENGTH(crapavt.dsoutren) > 150 THEN
                    ASSIGN tel_dsoutren_1 = SUBSTR(crapavt.dsoutren, 1, 50)
                           tel_dsoutren_2 = SUBSTR(crapavt.dsoutren, 51, 50)
                           tel_dsoutren_3 = SUBSTR(crapavt.dsoutren, 101, 50)
                           tel_dsoutren_4 = SUBSTR(crapavt.dsoutren, 151,
                                               LENGTH(crapavt.dsoutren) - 150).
                ELSE
                IF LENGTH(crapavt.dsoutren) > 100 THEN
                    ASSIGN tel_dsoutren_1 = SUBSTR(crapavt.dsoutren, 1, 50)
                           tel_dsoutren_2 = SUBSTR(crapavt.dsoutren, 51, 50)
                           tel_dsoutren_3 = SUBSTR(crapavt.dsoutren, 101,
                                               LENGTH(crapavt.dsoutren) - 100)
                           tel_dsoutren_4 = "".
                ELSE
                IF LENGTH(crapavt.dsoutren) > 50 THEN
                    ASSIGN tel_dsoutren_1 = SUBSTR(crapavt.dsoutren, 1, 50)
                           tel_dsoutren_2 = SUBSTR(crapavt.dsoutren, 51,
                                                LENGTH(crapavt.dsoutren) - 50)
                           tel_dsoutren_3 = ""
                           tel_dsoutren_4 = "".
                ELSE
                    ASSIGN tel_dsoutren_1 = crapavt.dsoutren
                           tel_dsoutren_2 = ""
                           tel_dsoutren_3 = ""
                           tel_dsoutren_4 = "".

            END.

            UPDATE tel_vloutren
                   tel_dsoutren_1
                   tel_dsoutren_2
                   tel_dsoutren_3
                   tel_dsoutren_4
                   WITH FRAME f_outras_fontes_renda.

        /*END.*/
    END.
    ELSE
        ASSIGN tel_vloutren   = 0
               tel_dsoutren_1 = ""
               tel_dsoutren_2 = ""
               tel_dsoutren_3 = ""
               tel_dsoutren_4 = "".
               
END.
                                                           
ON ANY-KEY OF tel_dsoutren_1 IN FRAME f_outras_fontes_renda DO:

    APPLY LASTKEY.

    IF NOT CAN-DO("CURSOR-RIGHT,CURSOR-LEFT", KEY-FUNCTION(LASTKEY)) THEN
        IF LENGTH(INPUT tel_dsoutren_1) = 50 THEN
        DO:
            APPLY "ENTRY" TO tel_dsoutren_2.
        END.

    RETURN NO-APPLY.

END.

ON ANY-KEY OF tel_dsoutren_2 IN FRAME f_outras_fontes_renda DO:
    
    APPLY LASTKEY.

    IF KEY-FUNCTION(LASTKEY) = "BACKSPACE" AND 
       LENGTH(INPUT tel_dsoutren_2) = 0 THEN
       DO:
           APPLY "ENTRY" TO tel_dsoutren_1.
       END.
    ELSE
       IF NOT CAN-DO("CURSOR-RIGHT,CURSOR-LEFT", KEY-FUNCTION(LASTKEY)) THEN
          IF LENGTH(INPUT tel_dsoutren_2) = 50 THEN
             DO:
                APPLY "ENTRY" TO tel_dsoutren_3.
             END.

    RETURN NO-APPLY.

END.

ON ANY-KEY OF tel_dsoutren_3 IN FRAME f_outras_fontes_renda DO:

    APPLY LASTKEY.

    IF KEY-FUNCTION(LASTKEY) = "BACKSPACE" AND 
       LENGTH(INPUT tel_dsoutren_3) = 0 THEN
       DO:
           APPLY "ENTRY" TO tel_dsoutren_2.
       END.
    ELSE
       IF NOT CAN-DO("CURSOR-RIGHT,CURSOR-LEFT", KEY-FUNCTION(LASTKEY)) THEN
          IF LENGTH(INPUT tel_dsoutren_3) = 50 THEN
              DO:
                 APPLY "ENTRY" TO tel_dsoutren_4.
              END.


    RETURN NO-APPLY.

END.

ON ANY-KEY OF tel_dsoutren_4 IN FRAME f_outras_fontes_renda DO:

    APPLY LASTKEY.

    IF KEY-FUNCTION(LASTKEY) = "BACKSPACE" AND 
       LENGTH(INPUT tel_dsoutren_4) = 0 THEN
       DO:
           APPLY "ENTRY" TO tel_dsoutren_3.
       END.

    RETURN NO-APPLY.

END.

ON ENTRY OF b_procuradores IN FRAME f_browse DO:

   IF aux_nrdlinha > 0   THEN
      REPOSITION q_procuradores TO ROW(aux_nrdlinha).

END.

ON ANY-KEY OF b_procuradores IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "GO"   THEN
        RETURN NO-APPLY.
   ELSE
   IF   CAN-DO("HELP,END-ERROR",KEY-FUNCTION(LASTKEY))   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
            IF AVAILABLE cratavt   THEN
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
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            IF   par_tpdopcao = "C"   THEN
                 RETURN NO-APPLY.

            reg_contador = reg_contador + 1.
        
            IF reg_contador > 5   THEN
               reg_contador = 1.
                
            glb_cddopcao = reg_cddopcao[reg_contador].
        
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            IF   par_tpdopcao = "C"   THEN
                 RETURN NO-APPLY.

            reg_contador = reg_contador - 1.
     
            IF reg_contador < 1   THEN
               reg_contador = 5.
                  
            glb_cddopcao = reg_cddopcao[reg_contador].

        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

/* Nao deixa passar pelo CPF sem ser um numero valido */
ON LEAVE OF tel_nrcpfcgc IN FRAME f_procuradores DO:

    ASSIGN INPUT tel_nrcpfcgc.

    IF NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
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

   IF NOT DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
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

   DISPLAY tel_dsestcvl 
           WITH FRAME f_procuradores.

   /* Quando estado civil for "Casado" e idade for menor que 18 anos,
      a pessoa passa automaticamente a ser emancipada.*/
   IF CAN-DO("2,3,4,8,9,11",STRING(tel_cdestcvl)) THEN
      DO:
         ASSIGN INPUT tel_dtnascto.

         RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                                   INPUT glb_dtmvtolt,
                                   OUTPUT aux_nrdeanos,
                                   OUTPUT aux_nrdmeses,
                                   OUTPUT aux_dsdidade).

         IF aux_nrdeanos < 18 AND 
            tel_inhabmen = 0 THEN
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

    IF par_nmrotina = "PROCURADORES" THEN
       DO:
          /* Cadastra os bens do procurador terceiro */
          RUN fontes/cadastra_bens.p (INPUT-OUTPUT TABLE tt-bens,
                                      INPUT par_nmrotina,
                                      INPUT ?,
                                      INPUT "").

          FIND FIRST tt-bens NO-LOCK NO-ERROR.
    
          IF AVAILABLE tt-bens   THEN
             tel_dsrelbem = tt-bens.dsrelbem.
          ELSE
             tel_dsrelbem = "".

       END.
    ELSE
       DO: 
           /* Cadastra os bens do procurador terceiro */
           RUN fontes/cadastra_bens.p (INPUT-OUTPUT TABLE tt-bensb,
                                       INPUT par_nmrotina,
                                       INPUT aux_rowidben,
                                       INPUT aux_cpfdoben).

           FIND FIRST tt-bensb NO-LOCK NO-ERROR.
           
           IF AVAILABLE tt-bensb   THEN
              tel_dsrelbem = tt-bensb.dsrelbem.
           ELSE
              tel_dsrelbem = "".

       END.

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

   RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                             INPUT glb_dtmvtolt,
                             OUTPUT aux_nrdeanos,
                             OUTPUT aux_nrdmeses,
                             OUTPUT aux_dsdidade).

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

   IF NOT VALID-HANDLE(h-b1wgen0060) THEN
      RUN sistema/generico/procedures/b1wgen0060.p 
          PERSISTENT SET h-b1wgen0060.

   IF NOT VALID-HANDLE(h-b1wgen0058) THEN
      RUN sistema/generico/procedures/b1wgen0058.p
          PERSISTENT SET h-b1wgen0058.

   IF NOT VALID-HANDLE(h-b1wgen9999) THEN
      RUN sistema/generico/procedures/b1wgen9999.p
          PERSISTENT SET h-b1wgen9999.

   ASSIGN glb_nmrotina = "PROCURADORES"
          glb_cddopcao = reg_cddopcao[reg_contador]
          glb_cdcritic = 0
          aux_verrespo = FALSE.
          
   HIDE  FRAME f_regua.
   HIDE  FRAME f_browse.
   HIDE  FRAME f_procuradores.
   HIDE  FRAME f_poderes.
   
   CLEAR FRAME f_procuradores.
   CLEAR FRAME f_poderes.

   IF par_nmrotina = "PROCURADORES" THEN
      DO:                      
          /* Limpa tabela dos bens do teceiros */ 
          EMPTY TEMP-TABLE tt-bens.

          /*Limpa a table dos responsaveis legal*/
          EMPTY TEMP-TABLE tt-resp.

          /*Limpa a table de procuradores/representantes */
          EMPTY TEMP-TABLE cratavt.
          
          RUN Busca_Dados ( INPUT "C" ).
          
          IF RETURN-VALUE <> "OK" THEN
             LEAVE.

      END.
   ELSE
      RUN Atualiza_Tabela.

   IF par_tpdopcao = "C" THEN
      DO:
          ASSIGN reg_contador = 2
                 glb_cddopcao = reg_cddopcao[reg_contador].
          
          DISPLAY reg_dsdopcao[2] WITH FRAME f_regua.

      END.
   ELSE
      DISPLAY reg_dsdopcao WITH FRAME f_regua.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   OPEN QUERY q_procuradores FOR EACH cratavt WHERE cratavt.deletado = NO
                                                    BY cratavt.nrdctato
                                                     BY cratavt.nrcpfcgc.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE b_procuradores WITH FRAME f_browse.
      LEAVE.

   END.                            
   
   IF KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
      LEAVE.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   { includes/acesso.i }
   
   IF glb_cddopcao = "I"   THEN
      DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
            ASSIGN tel_nrdctato = 0
                   tel_nrcpfcgc = ""
                   tel_persocio = 0  
                   tel_flgdepec = FALSE
                   tel_dtadmsoc = ?
                   aux_nrdrowid = ?.
         
            DISABLE tel_persocio 
                    tel_flgdepec 
                    WITH FRAME f_procuradores.
            
            DISPLAY tel_persocio
                    tel_flgdepec
                    WITH FRAME f_procuradores.
         
            PAUSE 0 NO-MESSAGE.
                   
            CLEAR FRAME f_procuradores.
            
            UPDATE tel_nrdctato 
                   WITH FRAME f_procuradores            
            EDITING:
              READKEY.
              HIDE MESSAGE NO-PAUSE.
         
              APPLY LASTKEY.
              IF GO-PENDING THEN
                 DO:
                    ASSIGN INPUT tel_nrdctato.
                    IF tel_nrdctato <> 0  THEN
                       DO: 
                          IF par_nmrotina = "PROCURADORES" THEN
                             DO:
                                RUN Busca_Dados ( INPUT glb_cddopcao ).
                               
                                IF  RETURN-VALUE <> "OK" THEN
                                    NEXT.

                             END.
                          ELSE
                             DO:
                                RUN Busca_Procurador (INPUT "I").

                                IF RETURN-VALUE = "NOK" THEN
                                   NEXT.

                                RUN Atualiza_Campos.

                                IF RETURN-VALUE <> "OK" THEN
                                   NEXT.
                             
                             END.

                       END.
                 END.
            END.
            
            IF tel_nrdctato = 0 THEN
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

                  IF par_nmrotina = "PROCURADORES" THEN
                     DO:
                         RUN Busca_Dados ( INPUT glb_cddopcao ).
         
                         IF RETURN-VALUE <> "OK" THEN
                            NEXT.

                     END.
                  ELSE
                     DO:
                         RUN Busca_Procurador (INPUT "I").
                  
                         IF RETURN-VALUE <> "OK" THEN
                            NEXT.

                         RUN Atualiza_Campos.

                         IF RETURN-VALUE <> "OK" THEN
                            NEXT.
                  
                     END.


               END.
               
            IF par_nmrotina = "PROCURADORES" THEN
               RUN Atualiza_Tela. 
               
            IF par_nmrotina = "PROCURADORES" THEN
               RUN Busca_Dados_Bens.
            
            INCLUI: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
               IF glb_cdcritic <> 0 THEN
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
                      tel_dsrelbem WHEN tel_nrdctato = 0
                      tel_dtvalida
                      tel_dsproftl 
                      tel_dtadmsoc
                      tel_vledvmto WHEN tel_nrdctato = 0
                      WITH FRAME f_procuradores
                      
               EDITING:
               
                   READKEY.
                   HIDE MESSAGE NO-PAUSE.
         
                   IF FRAME-FIELD = "tel_cdsexcto"   THEN
                      DO:
                          /* So deixa escrever M ou F */
                          IF NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                             "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                             "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                             KEY-FUNCTION(LASTKEY))   THEN
                             MESSAGE "Escolha (M)asculino / (F)eminino".
                          ELSE
                             DO:
                                 IF KEY-FUNCTION(LASTKEY) =
                                    "BACKSPACE"  THEN
                                    NEXT-PROMPT tel_cdsexcto
                                                WITH FRAME f_procuradores.
         
                                 HIDE MESSAGE NO-PAUSE.
                                 APPLY LASTKEY.
                             END.
                      END.
                   ELSE
                   IF LASTKEY = KEYCODE("F7") THEN
                      DO:
                         IF FRAME-FIELD = "tel_nrcepend"  THEN
                            DO:
                               /* Inclusão de CEP integrado. (André - DB1) */
                                RUN fontes/zoom_endereco.p 
                                              (INPUT 0,
                                               OUTPUT TABLE tt-endereco).
                         
                                FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                         
                                IF AVAIL tt-endereco THEN
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
         
                                IF KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                   NEXT-PROMPT tel_nrendere 
                                               WITH FRAME f_procuradores.

                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_dsnacion"  THEN
                            DO:
                                shr_dsnacion = INPUT tel_dsnacion.
                                RUN fontes/nacion.p.
                                IF shr_dsnacion <> " " THEN
                                   DO:
                                       tel_dsnacion = shr_dsnacion.
                                       DISPLAY tel_dsnacion
                                              WITH FRAME f_procuradores.

                                       NEXT-PROMPT tel_dsnacion
                                              WITH FRAME f_procuradores.
                                   END.
                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_cdestcvl"  THEN
                            DO:
                                shr_cdestcvl = INPUT tel_cdestcvl.
                                RUN fontes/zoom_estcivil.p.

                                IF shr_cdestcvl <> 0 THEN
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
                         IF FRAME-FIELD = "tel_dsnatura" THEN
                            DO:
                                RUN fontes/natura.p (OUTPUT shr_dsnatura).

                                IF shr_dsnatura <> "" THEN
                                   DO:
                                       tel_dsnatura = shr_dsnatura.

                                       DISPLAY tel_dsnatura
                                               WITH FRAME f_procuradores.

                                       NEXT-PROMPT tel_dsnatura
                                               WITH FRAME f_procuradores.

                                   END.
                            END.
                         ELSE
                            IF FRAME-FIELD = "tel_dsproftl" THEN
                               DO:
                                  HIDE MESSAGE.
                           
                                  RUN fontes/zoom_cargos.p
                                      (OUTPUT tel_dsproftl).
                           
                                  DISPLAY tel_dsproftl
                                      WITH FRAME f_procuradores.
                               END.
         
                      END. /* Fim do F7 */
                   ELSE
                      APPLY LASTKEY.
         
                   IF GO-PENDING THEN
                      DO:
                         DO WITH FRAME f_procuradores:
                         
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
                                   INPUT tel_dtvalida
                                   INPUT tel_dsproftl
                                   INPUT tel_dtadmsoc
                                   INPUT tel_persocio
                                   INPUT tel_flgdepec
                                   INPUT tel_nrcpfcgc.
                                    
                         END.

                         IF par_nmrotina = "PROCURADORES" THEN
                            DO: 
                               RUN Valida_Dados.
                      
                               IF RETURN-VALUE <> "OK" THEN
                                  NEXT INCLUI.
                      
                            END.
                         ELSE
                            DO:
                               
                               CREATE tt-cravavt.

                               ASSIGN tt-cravavt.dtmvtolt = glb_dtmvtolt
                                      tt-cravavt.nmdavali = tel_nmdavali
                                      tt-cravavt.tpdocava = tel_tpdocava
                                      tt-cravavt.nrdocava = tel_nrdocava
                                      tt-cravavt.cdoeddoc = tel_cdoeddoc
                                      tt-cravavt.cdufddoc = tel_cdufddoc
                                      tt-cravavt.dtemddoc = tel_dtemddoc
                                      tt-cravavt.dsproftl = tel_dsproftl
                                      tt-cravavt.dtnascto = tel_dtnascto
                                      tt-cravavt.cdsexcto = IF tel_cdsexcto = "M" THEN 
                                                               1 
                                                            ELSE 
                                                               2
                                      tt-cravavt.cdestcvl = tel_cdestcvl  
                                      tt-cravavt.dsestcvl = tel_dsestcvl  
                                      tt-cravavt.dsnacion = tel_dsnacion  
                                      tt-cravavt.dsnatura = tel_dsnatura  
                                      tt-cravavt.nmmaecto = tel_nmmaecto  
                                      tt-cravavt.nmpaicto = tel_nmpaicto  
                                      tt-cravavt.nrcepend = tel_nrcepend  
                                      tt-cravavt.dsendres[1] = tel_dsendere  
                                      tt-cravavt.nrendere = tel_nrendere  
                                      tt-cravavt.complend = tel_complend  
                                      tt-cravavt.nmbairro = tel_nmbairro  
                                      tt-cravavt.nmcidade = tel_nmcidade  
                                      tt-cravavt.cdufresd = tel_cdufende  
                                      tt-cravavt.dsrelbem[1] = tel_dsrelbem  
                                      tt-cravavt.nrcxapst = tel_nrcxapst  
                                      tt-cravavt.dtvalida = tel_dtvalida  
                                      tt-cravavt.dtadmsoc = tel_dtadmsoc  
                                      tt-cravavt.flgdepec = tel_flgdepec  
                                      tt-cravavt.persocio = tel_persocio  
                                      tt-cravavt.vledvmto = tel_vledvmto  
                                      tt-cravavt.inhabmen = tel_inhabmen  
                                      tt-cravavt.dthabmen = tel_dthabmen  
                                      tt-cravavt.dshabmen = tel_dshabmen  
                                      tt-cravavt.nrctremp = 0
                                      tt-cravavt.nrdctato = tel_nrdctato
                                      tt-cravavt.nrdconta = par_nrdconta
                                      tt-cravavt.cdcpfcgc = tel_nrcpfcgc
                                      tt-cravavt.nrcpfcgc = DEC(REPLACE(
                                        REPLACE(tel_nrcpfcgc,".",""),"-",""))
                                      tt-cravavt.vloutren = tel_vloutren
                                      tt-cravavt.dsoutren = tel_dsoutren_1 +
                                                            tel_dsoutren_2 +
                                                            tel_dsoutren_3 +
                                                            tel_dsoutren_4
                                      tt-cravavt.cddopcao = "I"
                                      tt-cravavt.rowidavt = ROWID(tt-cravavt)
                                      tt-cravavt.cdcooper = glb_cdcooper
                                      tt-cravavt.tpctrato = 6
                                      tt-cravavt.dsvalida = IF tt-cravavt.dtvalida = 12/31/9999 THEN
                                                               "INDETERMI."
                                                            ELSE 
                                                               STRING(tt-cravavt.dtvalida,
                                                               "99/99/9999").
                               
                               IF tel_nrdctato <> 0 THEN
                                  DO:                         
                                     ASSIGN aux_contador = 0.
                                     
                                     FOR EACH tt-bensb:

                                         ASSIGN aux_contador = aux_contador + 1
                                                tt-cravavt.dsrelbem[aux_contador] = CAPS(tt-bensb.dsrelbem)
                                                tt-cravavt.persemon[aux_contador] = tt-bensb.persemon
                                                tt-cravavt.qtprebem[aux_contador] = tt-bensb.qtprebem
                                                tt-cravavt.vlprebem[aux_contador] = tt-bensb.vlprebem
                                                tt-cravavt.vlrdobem[aux_contador] = tt-bensb.vlrdobem.
                                     
                                         IF ERROR-STATUS:ERROR THEN
                                            DO:
                                               aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                               UNDO INCLUI, NEXT INCLUI.

                                            END.

                                     END.

                                  END.
                               
                               /* Valida Procuradores */
                               RUN Valida_Procurador.
                               
                               IF RETURN-VALUE <> "OK"  THEN
                                  DO:
                                      DELETE tt-cravavt.
                                      UNDO INCLUI, NEXT INCLUI.
                                  END.
                      
                             
                            END.
                      
                      END.
         
               END. /* Fim do EDITING */

               IF RETURN-VALUE <> "OK" THEN
                  NEXT INCLUI.
         
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT INCLUI.
               
               LEAVE INCLUI.
         
            END.
         
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.
         
            LEAVE.
         
         END. /* Fim DO WHILE*/
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.
                  
         ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                tel_cdoeddoc = CAPS(tel_cdoeddoc)
                tel_cdufddoc = CAPS(tel_cdufddoc)
                tel_dsproftl = CAPS(tel_dsproftl)
                tel_dsnacion = CAPS(tel_dsnacion)
                tel_dsnatura = CAPS(tel_dsnatura)
                tel_dsendere = CAPS(tel_dsendere)
                tel_complend = CAPS(tel_complend)
                tel_nmbairro = CAPS(tel_nmbairro)
                tel_nmcidade = CAPS(tel_nmcidade)
                tel_cdufende = CAPS(tel_cdufende)
                tel_nmmaecto = CAPS(tel_nmmaecto)
                tel_nmpaicto = CAPS(tel_nmpaicto)
                tel_dsproftl = CAPS(tel_dsproftl).
                  
         DISPLAY tel_nmdavali    tel_cdoeddoc    tel_cdufddoc
                 tel_dsproftl    tel_dsnacion    tel_dsnatura
                 tel_dsendere    tel_complend    tel_nmbairro
                 tel_nmcidade    tel_cdufende    tel_nmmaecto
                 tel_nmpaicto    tel_dsproftl
                 WITH FRAME f_procuradores.
         
                  
         ASSIGN aux_nrcpfcgc = DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).
             
         
         IF par_nmrotina = "PROCURADORES" THEN
            DO:
                EMPTY TEMP-TABLE tt-resp.

                FOR EACH resp_legal NO-LOCK:

                    CREATE tt-resp.
                    BUFFER-COPY resp_legal TO tt-resp.

                END.

                RUN Valida_Dados.

                IF RETURN-VALUE = "NOK" THEN
                   NEXT.

            END.
         ELSE 
            DO:
               RUN Valida_Procurador.

               IF RETURN-VALUE = "NOK" THEN
                  NEXT.
         
            END.

         IF tel_inhabmen = 0 THEN
            DO:
               RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                                         INPUT glb_dtmvtolt,
                                         OUTPUT aux_nrdeanos,
                                         OUTPUT aux_nrdmeses,
                                         OUTPUT aux_dsdidade).   
               
               IF RETURN-VALUE <> "OK" THEN
                  UNDO, LEAVE.
             
            END.
         
         IF (tel_inhabmen = 0   AND
             aux_nrdeanos < 18) OR
             tel_inhabmen = 2   THEN
            DO:
                RUN fontes/contas_responsavel.p (INPUT glb_nmrotina,
                                                 INPUT tel_nrdctato,
                                                 INPUT tel_idseqttl, /*aux_idseqttl,*/
                                                 INPUT aux_nrcpfcgc,
                                                 INPUT tel_dtnascto,
                                                 INPUT tel_inhabmen,
                                                 OUTPUT par_permalte,
                                                 INPUT-OUTPUT TABLE resp_legal).
                
                ASSIGN glb_cddopcao = "I"
                       glb_nmrotina = "PROCURADORES"
                       tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                      "99999999999"),"XXX.XXX.XXX-XX")
                       aux_verrespo = TRUE
                       par_verrespo = aux_verrespo.

             END.
         
         IF par_nmrotina = "PROCURADORES" THEN
            DO:
                EMPTY TEMP-TABLE tt-resp.

                FOR EACH resp_legal NO-LOCK:

                    CREATE tt-resp.
                    BUFFER-COPY resp_legal TO tt-resp.

                END.

                RUN Valida_Dados.

                IF RETURN-VALUE = "NOK" THEN
                   NEXT.

            END.
         ELSE 
            DO:
               RUN Valida_Procurador.

               IF RETURN-VALUE = "NOK" THEN
                  NEXT.
         
            END.
    
         RUN proc_confirma.

         IF aux_confirma = "S" THEN
            DO:
               IF par_nmrotina <> "PROCURADORES" THEN
                  DO:
                   
                     CREATE cratavt.

                     ASSIGN cratavt.dtmvtolt = glb_dtmvtolt
                            cratavt.nmdavali = tel_nmdavali
                            cratavt.tpdocava = tel_tpdocava
                            cratavt.nrdocava = tel_nrdocava
                            cratavt.cdoeddoc = tel_cdoeddoc
                            cratavt.cdufddoc = tel_cdufddoc
                            cratavt.dtemddoc = tel_dtemddoc
                            cratavt.dsproftl = tel_dsproftl
                            cratavt.dtnascto = tel_dtnascto
                            cratavt.cdsexcto = IF tel_cdsexcto = "M" THEN 
                                                  1
                                               ELSE
                                                  2
                            cratavt.cdestcvl = tel_cdestcvl  
                            cratavt.dsestcvl = tel_dsestcvl  
                            cratavt.dsnacion = tel_dsnacion  
                            cratavt.dsnatura = tel_dsnatura  
                            cratavt.nmmaecto = tel_nmmaecto  
                            cratavt.nmpaicto = tel_nmpaicto  
                            cratavt.nrcepend = tel_nrcepend  
                            cratavt.dsendres[1] = tel_dsendere  
                            cratavt.nrendere = tel_nrendere  
                            cratavt.complend = tel_complend  
                            cratavt.nmbairro = tel_nmbairro  
                            cratavt.nmcidade = tel_nmcidade  
                            cratavt.cdufresd = tel_cdufende  
                            cratavt.dsrelbem[1] = tel_dsrelbem  
                            cratavt.nrcxapst = tel_nrcxapst  
                            cratavt.dtvalida = tel_dtvalida  
                            cratavt.dtadmsoc = tel_dtadmsoc  
                            cratavt.flgdepec = tel_flgdepec  
                            cratavt.persocio = tel_persocio  
                            cratavt.vledvmto = tel_vledvmto  
                            cratavt.inhabmen = tel_inhabmen  
                            cratavt.dthabmen = tel_dthabmen  
                            cratavt.dshabmen = tel_dshabmen  
                            cratavt.nrctremp = 0
                            cratavt.nrdctato = tel_nrdctato
                            cratavt.nrdconta = par_nrdconta
                            cratavt.cdcpfcgc = tel_nrcpfcgc
                            cratavt.nrcpfcgc = DEC(REPLACE(REPLACE(
                                               tel_nrcpfcgc,".",""),"-",""))
                            cratavt.vloutren = tel_vloutren
                            cratavt.dsoutren = tel_dsoutren_1 +
                                               tel_dsoutren_2 +
                                               tel_dsoutren_3 +
                                               tel_dsoutren_4
                            cratavt.cddopcao = "I"
                            cratavt.nrdrowid = ROWID(cratavt)
                            cratavt.cdcooper = glb_cdcooper
                            cratavt.tpctrato = 6
                            cratavt.dsvalida = IF cratavt.dtvalida = 12/31/9999 THEN
                                                  "INDETERMI."
                                               ELSE 
                                                  STRING(cratavt.dtvalida,
                                                  "99/99/9999").
                     
                     IF tel_nrdctato <> 0 THEN
                        DO:                         
                           ASSIGN aux_contador = 0.
                           
                           FOR EACH tt-bensb:
                        
                               ASSIGN aux_contador = aux_contador + 1
                                      cratavt.dsrelbem[aux_contador] = CAPS(tt-bensb.dsrelbem)
                                      cratavt.persemon[aux_contador] = tt-bensb.persemon
                                      cratavt.qtprebem[aux_contador] = tt-bensb.qtprebem
                                      cratavt.vlprebem[aux_contador] = tt-bensb.vlprebem
                                      cratavt.vlrdobem[aux_contador] = tt-bensb.vlrdobem.
                           
                               IF ERROR-STATUS:ERROR THEN
                                  DO:
                                     aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                     NEXT.
                                  END.

                           END.
                        
                        END.
                        
                  END.
               ELSE
                  DO:
                    
                     RUN Grava_Dados.
                     
                     IF RETURN-VALUE <> "OK" THEN
                        NEXT.

                  END.

            END.
         ELSE
            DO:
               IF par_nmrotina <> "PROCURADORES" THEN
                  DELETE tt-cravavt.

               NEXT.

            END.
        
      END.
   ELSE
   IF glb_cddopcao = "C"  AND aux_nrdrowid <> ? THEN
      DO:
         RUN Atualiza_Tela.

         RUN busca_perc_socio IN h-b1wgen0058 (INPUT glb_cdcooper,
                                               INPUT tel_dsproftl,
                                               INPUT tel_persocio,
                                               OUTPUT aux_persocio,
                                               OUTPUT TABLE tt-erro).
         
         IF NOT tel_flgdepec             AND 
            tel_persocio >= aux_persocio AND
            tel_persocio > 0             THEN
            DISPLAY  tel_vloutren
                     tel_dsoutren_1
                     tel_dsoutren_2
                     tel_dsoutren_3
                     tel_dsoutren_4
                     WITH FRAME f_outras_fontes_renda NO-ERROR.
           
         ASSIGN aux_nrcpfcgc = DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).
    
         IF (tel_inhabmen = 0   AND
             aux_nrdeanos < 18) OR
             tel_inhabmen = 2   THEN
             DO:
               IF par_nmrotina = "PROCURADORES" OR 
                 (par_nmrotina = "MATRIC"       AND 
                  par_tpdopcao = "C")           THEN
                  DO:
                      FIND FIRST crapcrl WHERE crapcrl.cdcooper = glb_cdcooper     AND
                                               crapcrl.nrctamen = tel_nrdctato     AND
                                              (IF tel_nrdctato = 0 THEN 
                                                  crapcrl.nrcpfmen = aux_nrcpfcgc
                                               ELSE
                                                  TRUE)                           AND
                                               crapcrl.idseqmen = tel_idseqttl /*aux_idseqttl */
                                               NO-LOCK NO-ERROR.
                                               
                     
                     IF AVAIL crapcrl THEN
                        DO:
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                              ASSIGN aux_confirma = "N".
                              
                              MESSAGE COLOR NORMAL "Deseja visualizar o Respon. " + 
                                                   "Legal (S/N)?"
                                                   UPDATE aux_confirma.
                              LEAVE.
                           
                           END.  /*  Fim do DO WHILE TRUE  */
                                                              
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                              aux_confirma <> "S"                THEN
                              NEXT.
                           ELSE
                              DO: 
                                  RUN fontes/contas_responsavel.p (INPUT "PROC_JUR_CONS",
                                                                   INPUT tel_nrdctato,
                                                                   INPUT tel_idseqttl, /*aux_idseqttl,*/
                                                                   INPUT aux_nrcpfcgc,
                                                                   INPUT tel_dtnascto,
                                                                   INPUT tel_inhabmen,
                                                                   OUTPUT par_permalte,
                                                                   INPUT-OUTPUT TABLE resp_legal).
                                  ASSIGN glb_cddopcao = "C"
                                         glb_nmrotina = "PROCURADORES"
                                         tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                                        "99999999999"),"XXX.XXX.XXX-XX").
                                        
                     
                              END.
                               
                        END.    

                  END.
               ELSE
                  DO: 
                     FIND FIRST tt-resp WHERE 
                          tt-resp.cdcooper = glb_cdcooper         AND
                          tt-resp.nrctamen = tel_nrdctato         AND
                          tt-resp.nrcpfmen = (IF tel_nrdctato = 0 THEN 
                                                       aux_nrcpfcgc
                                                    ELSE
                                                       0)                           
                          NO-LOCK NO-ERROR.
                    
                    
                     IF AVAIL tt-resp THEN
                        DO:
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                              ASSIGN aux_confirma = "N".
                    
                              MESSAGE COLOR NORMAL "Deseja visualizar o Respon. " + 
                                                   "Legal (S/N)?"
                                                   UPDATE aux_confirma.
                              LEAVE.
                    
                           END.  /*  Fim do DO WHILE TRUE  */
                    
                           IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                              aux_confirma <> "S"                THEN
                              NEXT.
                           ELSE
                              DO: 
                                  RUN fontes/contas_responsavel.p (INPUT "PROC_JUR_MATRIC",
                                                                   INPUT tel_nrdctato,
                                                                   INPUT tel_idseqttl, /*aux_idseqttl,*/
                                                                   INPUT aux_nrcpfcgc,
                                                                   INPUT tel_dtnascto,
                                                                   INPUT tel_inhabmen,
                                                                   OUTPUT par_permalte,
                                                                   INPUT-OUTPUT TABLE resp_legal).
                                  ASSIGN glb_cddopcao = "C"
                                         glb_nmrotina = "PROCURADORES"
                                         tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                                        "99999999999"),"XXX.XXX.XXX-XX").
                    
                    
                              END.
                    
                        END.    
                    

                  END.


             END.

      END.
   ELSE
   IF glb_cddopcao = "A"   AND  aux_nrdrowid <> ?    THEN
      DO:
         DO TRANSACTION WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            RUN Atualiza_Tela.
            
            DISABLE tel_persocio 
                    tel_flgdepec 
                    WITH FRAME f_procuradores.
            
            DISPLAY tel_persocio
                    tel_flgdepec
                    WITH FRAME f_procuradores.
            
            PAUSE 0 NO-MESSAGE.
                    
            IF par_nmrotina = "PROCURADORES" THEN
               RUN Busca_Dados_Bens.
            
            ASSIGN tel_dsrelbem:READ-ONLY IN FRAME f_procuradores = TRUE
                   tel_inhabmen:READ-ONLY IN FRAME f_procuradores = FALSE
                   tel_dthabmen:READ-ONLY IN FRAME f_procuradores = FALSE.

            
            ALTERA: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
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
                      tel_dsrelbem WHEN tel_nrdctato = 0
                      tel_dtvalida
                      tel_dsproftl 
                      tel_dtadmsoc
                      tel_vledvmto WHEN tel_nrdctato = 0
                      WITH FRAME f_procuradores
            
               EDITING:
                  
                  READKEY.
                  HIDE MESSAGE NO-PAUSE.
            
                  IF FRAME-FIELD = "tel_cdsexcto"   THEN
                     DO:
                         /* So deixa escrever M ou F */
                         IF NOT CAN-DO("GO,RETURN,TAB,BACK-TAB," +
                            "BACKSPACE,END-ERROR,HELP,CURSOR-UP," +
                            "CURSOR-DOWN,CURSOR-LEFT,CURSOR-RIGHT,M,F",
                            KEY-FUNCTION(LASTKEY))   THEN
                            MESSAGE "Escolha (M)asculino / (F)eminino".
                         ELSE 
                            DO:
                               IF KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
                                  NEXT-PROMPT tel_cdsexcto
                                              WITH FRAME f_procuradores.
                                                 
                               HIDE MESSAGE NO-PAUSE.
                               APPLY LASTKEY.

                            END.

                     END.
                  ELSE
                  IF LASTKEY = KEYCODE("F7") THEN
                     DO:
                        IF FRAME-FIELD = "tel_nrcepend"  THEN
                           DO:
                               /* Inclusão de CEP integrado. (André - DB1) */
                               RUN fontes/zoom_endereco.p 
                                                   (INPUT 0,
                                                    OUTPUT TABLE tt-endereco).
                         
                               FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                         
                               IF AVAIL tt-endereco THEN
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
            
                               IF KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                  NEXT-PROMPT tel_nrendere 
                                              WITH FRAME f_procuradores.

                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_dsnacion"  THEN
                           DO:
                               shr_dsnacion = INPUT tel_dsnacion.
                               RUN fontes/nacion.p.
                               IF shr_dsnacion <> " " THEN
                                  DO:
                                      tel_dsnacion = shr_dsnacion.
                                      DISPLAY tel_dsnacion
                                              WITH FRAME f_procuradores.

                                      NEXT-PROMPT tel_dsnacion
                                                  WITH FRAME f_procuradores.

                                  END.

                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_cdestcvl"  THEN
                           DO:
                               shr_cdestcvl = INPUT tel_cdestcvl.

                               RUN fontes/zoom_estcivil.p.

                               IF shr_cdestcvl <> 0 THEN
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
                        IF FRAME-FIELD = "tel_dsnatura" THEN
                           DO:
                               RUN fontes/natura.p (OUTPUT shr_dsnatura).
                               IF shr_dsnatura <> "" THEN
                                  DO:
                                      tel_dsnatura = shr_dsnatura.

                                      DISPLAY tel_dsnatura
                                              WITH FRAME f_procuradores.

                                      NEXT-PROMPT tel_dsnatura
                                                  WITH FRAME f_procuradores.

                                  END.

                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_dsproftl" THEN
                           DO:
                               HIDE MESSAGE.
            
                               RUN fontes/zoom_cargos.p 
                                   (OUTPUT tel_dsproftl).
            
                               DISPLAY tel_dsproftl 
                                   WITH FRAME f_procuradores.
            
                           END.    

                     END. /* Fim do F7 */
                  ELSE
                  IF FRAME-FIELD = "tel_dsproftl"   THEN
                     DO: 
                        APPLY LASTKEY.
                     END.     
                  ELSE
                     APPLY LASTKEY.

                  IF GO-PENDING THEN
                     DO:
                        DO WITH FRAME f_procuradores:
                            ASSIGN INPUT tel_nmdavali
                                   INPUT tel_tpdocava
                                   INPUT tel_nrdocava
                                   INPUT tel_cdoeddoc
                                   INPUT tel_cdufddoc
                                   INPUT tel_dtemddoc
                                   INPUT tel_dtnascto
                                   INPUT tel_inhabmen
                                   INPUT tel_dshabmen
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
                                   INPUT tel_dtvalida
                                   INPUT tel_dsproftl
                                   INPUT tel_dtadmsoc
                                   INPUT tel_persocio
                                   INPUT tel_flgdepec
                                   INPUT tel_nrcpfcgc.
            
                        END.
                                           
                        IF par_nmrotina = "PROCURADORES" THEN
                           RUN Valida_Dados.
                        ELSE
                           RUN Valida_Procurador.

                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.

                     END.

               END. /* Fim do EDITING */
            
               IF par_nmrotina <> "PROCURADORES" THEN
                  DO:
                     /* criar a temp-table para ser sincronizada no 
                        bloco externo */
                     FIND FIRST tt-cravavt WHERE
                                tt-cravavt.rowidavt = cratavt.nrdrowid 
                                NO-ERROR.
                     
                     IF AVAILABLE tt-cravavt THEN
                        DO:
                           ASSIGN tt-cravavt.nmdavali = tel_nmdavali
                                  tt-cravavt.tpdocava = tel_tpdocava
                                  tt-cravavt.nrdocava = tel_nrdocava
                                  tt-cravavt.cdoeddoc = tel_cdoeddoc
                                  tt-cravavt.cdufddoc = tel_cdufddoc
                                  tt-cravavt.dtemddoc = tel_dtemddoc
                                  tt-cravavt.dsproftl = tel_dsproftl
                                  tt-cravavt.dtnascto = tel_dtnascto
                                  tt-cravavt.cdsexcto = IF tel_cdsexcto = "M" THEN
                                                           1 
                                                        ELSE 
                                                           2
                                  tt-cravavt.cdestcvl = tel_cdestcvl  
                                  tt-cravavt.dsestcvl = tel_dsestcvl  
                                  tt-cravavt.dsnacion = tel_dsnacion  
                                  tt-cravavt.dsnatura = tel_dsnatura  
                                  tt-cravavt.nmmaecto = tel_nmmaecto  
                                  tt-cravavt.nmpaicto = tel_nmpaicto  
                                  tt-cravavt.nrcepend = tel_nrcepend  
                                  tt-cravavt.dsendres[1] = tel_dsendere  
                                  tt-cravavt.nrendere = tel_nrendere  
                                  tt-cravavt.complend = tel_complend  
                                  tt-cravavt.nmbairro = tel_nmbairro  
                                  tt-cravavt.nmcidade = tel_nmcidade  
                                  tt-cravavt.cdufresd = tel_cdufende  
                                  tt-cravavt.dsrelbem[1] = tel_dsrelbem  
                                  tt-cravavt.nrcxapst = tel_nrcxapst  
                                  tt-cravavt.dtvalida = tel_dtvalida  
                                  tt-cravavt.dtadmsoc = tel_dtadmsoc  
                                  tt-cravavt.flgdepec = tel_flgdepec  
                                  tt-cravavt.persocio = tel_persocio  
                                  tt-cravavt.vledvmto = tel_vledvmto  
                                  tt-cravavt.inhabmen = tel_inhabmen  
                                  tt-cravavt.dthabmen = tel_dthabmen  
                                  tt-cravavt.dshabmen = tel_dshabmen  
                                  tt-cravavt.nrctremp = 0
                                  tt-cravavt.nrdctato = tel_nrdctato
                                  tt-cravavt.nrdconta = par_nrdconta
                                  tt-cravavt.cdcpfcgc = tel_nrcpfcgc
                                  tt-cravavt.nrcpfcgc = DEC(REPLACE(REPLACE(
                                                        tel_nrcpfcgc,".",""),"-",""))
                                  tt-cravavt.vloutren = tel_vloutren
                                  tt-cravavt.dsoutren = tel_dsoutren_1 +
                                                        tel_dsoutren_2 +
                                                        tel_dsoutren_3 +
                                                        tel_dsoutren_4
                                  tt-cravavt.cddopcao = "A"
                                  tt-cravavt.cdcooper = glb_cdcooper
                                  tt-cravavt.tpctrato = 6
                                  tt-cravavt.dsvalida = IF tt-cravavt.dtvalida = 12/31/9999 THEN
                                                           "INDETERMI."
                                                        ELSE 
                                                           STRING(tt-cravavt.dtvalida,
                                                           "99/99/9999").


                           IF tel_nrdctato <> 0 THEN
                              DO:                         
                                  ASSIGN aux_contador = 0.
                                  
                                  FOR EACH tt-bensb:
                                
                                      ASSIGN aux_contador = aux_contador + 1
                                             tt-cravavt.dsrelbem[aux_contador] = CAPS(tt-bensb.dsrelbem)
                                             tt-cravavt.persemon[aux_contador] = tt-bensb.persemon
                                             tt-cravavt.qtprebem[aux_contador] = tt-bensb.qtprebem
                                             tt-cravavt.vlprebem[aux_contador] = tt-bensb.vlprebem
                                             tt-cravavt.vlrdobem[aux_contador] = tt-bensb.vlrdobem.
                                 
                                      IF  ERROR-STATUS:ERROR THEN
                                          DO:
                                             aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                             NEXT.
                                          END.
                                  END.
                              
                              END.

                        END.

                     /* Valida Procuradores */
                     RUN Valida_Procurador.
                     
                     IF RETURN-VALUE <> "OK" THEN 
                        DO:
                           UNDO ALTERA, NEXT ALTERA.

                        END.

                  END.

               LEAVE.
            
            END. /* Fim do DO WHILE TRUE , Update*/
            
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
               LEAVE.
            
            ASSIGN tel_nmdavali = CAPS(tel_nmdavali)
                   tel_cdoeddoc = CAPS(tel_cdoeddoc)
                   tel_cdufddoc = CAPS(tel_cdufddoc)
                   tel_dsproftl = CAPS(tel_dsproftl)
                   tel_dsnacion = CAPS(tel_dsnacion)
                   tel_dsnatura = CAPS(tel_dsnatura)
                   tel_dsendere = CAPS(tel_dsendere)
                   tel_complend = CAPS(tel_complend)
                   tel_nmbairro = CAPS(tel_nmbairro)
                   tel_nmcidade = CAPS(tel_nmcidade)
                   tel_cdufende = CAPS(tel_cdufende)
                   tel_nmmaecto = CAPS(tel_nmmaecto)
                   tel_nmpaicto = CAPS(tel_nmpaicto)
                   tel_dsproftl = CAPS(tel_dsproftl).
            
            DISPLAY tel_nmdavali    tel_cdoeddoc    tel_cdufddoc
                    tel_dsproftl    tel_dsnacion    tel_dsnatura
                    tel_dsendere    tel_complend    tel_nmbairro
                    tel_nmcidade    tel_cdufende    tel_nmmaecto
                    tel_nmpaicto    tel_dsproftl
                    WITH FRAME f_procuradores.
            
            IF par_nmrotina = "PROCURADORES" THEN
               DO: 
                  EMPTY TEMP-TABLE tt-resp.

                  FOR EACH resp_legal NO-LOCK:
                      
                      CREATE tt-resp.
                      BUFFER-COPY resp_legal TO tt-resp.

                  END.

                  RUN Valida_Dados.

                  IF RETURN-VALUE <> "OK" THEN
                     UNDO, LEAVE.
                  

               END. 
            ELSE   
               DO:
                  RUN Valida_Procurador.

                  IF RETURN-VALUE <> "OK" THEN
                    UNDO, LEAVE.

               END.

            ASSIGN aux_nrcpfcgc = DEC(REPLACE(REPLACE(
                                  tel_nrcpfcgc,".",""),"-","")).
            
            IF tel_inhabmen = 0 OR 
               tel_inhabmen = 1 THEN
               DO:
                  RUN idade IN h-b1wgen9999(INPUT tel_dtnascto,
                                            INPUT glb_dtmvtolt,
                                            OUTPUT aux_nrdeanos,
                                            OUTPUT aux_nrdmeses,
                                            OUTPUT aux_dsdidade).   

                  IF RETURN-VALUE <> "OK" THEN
                     UNDO, LEAVE.
                
               END.
            
               
             IF (tel_inhabmen = 0   AND
                 aux_nrdeanos < 18) OR
                 tel_inhabmen = 2   THEN
                 DO: 
                     RUN fontes/contas_responsavel.p (INPUT glb_nmrotina,
                                                      INPUT tel_nrdctato,
                                                      INPUT tel_idseqttl, /*aux_idseqttl,*/
                                                      INPUT aux_nrcpfcgc,
                                                      INPUT tel_dtnascto,
                                                      INPUT tel_inhabmen,
                                                      OUTPUT par_permalte,
                                                      INPUT-OUTPUT TABLE resp_legal).
                 
                     ASSIGN glb_cddopcao = "A"
                            glb_nmrotina = "PROCURADORES"
                            tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                           "99999999999"),"XXX.XXX.XXX-XX")
                            aux_verrespo = TRUE
                            par_verrespo = aux_verrespo
                            par_permalte = TRUE.
                     
                 
                 END. 
            
            IF par_nmrotina = "PROCURADORES" THEN
               DO: 
                  EMPTY TEMP-TABLE tt-resp.

                  FOR EACH resp_legal NO-LOCK:
                      
                      CREATE tt-resp.
                      BUFFER-COPY resp_legal TO tt-resp.

                  END.

                  RUN Valida_Dados.

                  IF RETURN-VALUE <> "OK" THEN
                     UNDO, LEAVE.

               END. 
            ELSE   
               DO:
                  RUN Valida_Procurador.

                  IF RETURN-VALUE <> "OK" THEN
                     UNDO, LEAVE.

               END.

            RUN proc_confirma.
            
            IF aux_confirma = "S" THEN
               DO:
                  IF par_nmrotina = "PROCURADORES" THEN
                     DO:
                         RUN Grava_Dados.
                        
                         IF RETURN-VALUE <> "OK" THEN
                            LEAVE.

                     END.
                  ELSE
                    DO:
                        FIND FIRST cratavt WHERE cratavt.nrdrowid = aux_nrdrowid 
                                                 EXCLUSIVE-LOCK NO-ERROR.

                        IF NOT AVAILABLE cratavt THEN
                           LEAVE.

                        ASSIGN cratavt.nmdavali = tel_nmdavali 
                               cratavt.tpdocava = tel_tpdocava 
                               cratavt.nrdocava = tel_nrdocava 
                               cratavt.cdoeddoc = tel_cdoeddoc 
                               cratavt.cdufddoc = tel_cdufddoc 
                               cratavt.dtemddoc = tel_dtemddoc 
                               cratavt.dsproftl = tel_dsproftl 
                               cratavt.dtnascto = tel_dtnascto 
                               cratavt.cdsexcto = IF tel_cdsexcto = "M" THEN 
                                                     1 
                                                  ELSE
                                                     2
                               cratavt.cdestcvl = tel_cdestcvl 
                               cratavt.dsestcvl = tel_dsestcvl 
                               cratavt.dsnacion = tel_dsnacion 
                               cratavt.dsnatura = tel_dsnatura 
                               cratavt.nmmaecto = tel_nmmaecto 
                               cratavt.nmpaicto = tel_nmpaicto 
                               cratavt.nrcepend = tel_nrcepend 
                               cratavt.dsendres[1] = tel_dsendere
                               cratavt.nrendere = tel_nrendere  
                               cratavt.complend = tel_complend  
                               cratavt.nmbairro = tel_nmbairro  
                               cratavt.nmcidade = tel_nmcidade  
                               cratavt.cdufresd = tel_cdufende 
                               cratavt.dsrelbem[1] = tel_dsrelbem
                               cratavt.nrcxapst = tel_nrcxapst 
                               cratavt.dtvalida = tel_dtvalida 
                               cratavt.dtadmsoc = tel_dtadmsoc 
                               cratavt.flgdepec = tel_flgdepec 
                               cratavt.persocio = tel_persocio 
                               cratavt.vledvmto = tel_vledvmto 
                               cratavt.inhabmen = tel_inhabmen 
                               cratavt.dthabmen = tel_dthabmen 
                               cratavt.dshabmen = tel_dshabmen 
                               cratavt.nrctremp = 0
                               cratavt.nrdctato = tel_nrdctato 
                               cratavt.nrdconta = par_nrdconta
                               cratavt.cdcpfcgc = tel_nrcpfcgc 
                               cratavt.nrcpfcgc = DEC(REPLACE(REPLACE(
                                                  tel_nrcpfcgc,".",""),"-",""))
                               cratavt.vloutren = tel_vloutren 
                               cratavt.dsoutren = tel_dsoutren_1
                               cratavt.dsoutren = tel_dsoutren_2
                               cratavt.dsoutren = tel_dsoutren_3
                               cratavt.dsoutren = tel_dsoutren_4
                               cratavt.cddopcao = "A"
                               cratavt.cdcooper = glb_cdcooper
                               cratavt.tpctrato = 6
                               cratavt.dsvalida = IF cratavt.dtvalida = 12/31/9999 THEN
                                                     "INDETERMI."
                                                  ELSE 
                                                     STRING(cratavt.dtvalida,
                                                     "99/99/9999").


                        IF tel_nrdctato <> 0 THEN
                           DO:                         
                               ASSIGN aux_contador = 0.
                               
                               FOR EACH tt-bensb:
                           
                                   ASSIGN aux_contador = aux_contador + 1
                                          cratavt.dsrelbem[aux_contador] = CAPS(tt-bensb.dsrelbem)
                                          cratavt.persemon[aux_contador] = tt-bensb.persemon
                                          cratavt.qtprebem[aux_contador] = tt-bensb.qtprebem
                                          cratavt.vlprebem[aux_contador] = tt-bensb.vlprebem
                                          cratavt.vlrdobem[aux_contador] = tt-bensb.vlrdobem.
                              
                                   IF ERROR-STATUS:ERROR THEN
                                      DO:
                                          aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                          NEXT.
                                      END.

                               END.
                           
                           END.

                    END.

               END.
            ELSE
               UNDO, LEAVE.
            
            LEAVE.

         END.

         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.
             
      END.
   ELSE
   IF glb_cddopcao = "E" AND aux_nrdrowid <> ? THEN
      DO: 
         RUN Busca_Dados ( INPUT glb_cddopcao ).

         IF RETURN-VALUE <> "OK" THEN
             DO:
                 NEXT.
             END.
       
         FIND FIRST cratavt WHERE cratavt.nrdrowid = aux_nrdrowid 
                                  NO-LOCK NO-ERROR.

         IF AVAILABLE cratavt THEN
            DO:       
                IF tel_nrcpfcgc = "" THEN
                   ASSIGN tel_nrcpfcgc = STRING(cratavt.nrcpfcgc).

                ASSIGN tel_nrdctato = cratavt.nrdctato.

            END.

         RUN Atualiza_Tela.

         IF par_nmrotina <> "PROCURADORES" THEN
            DO:
               FIND FIRST tt-cravavt WHERE tt-cravavt.rowidavt = cratavt.nrdrowid
                                           NO-ERROR.
              
               IF AVAILABLE tt-cravavt THEN
                  ASSIGN tt-cravavt.deletado = YES
                         tt-cravavt.cddopcao = "E".

               /* Valida Procuradores */
               RUN Valida_Procurador.
              
               IF RETURN-VALUE <> "OK" THEN
                  NEXT.
            END. 
        ELSE
           DO:
              RUN Valida_Dados.

              IF RETURN-VALUE <> "OK" THEN
                 DO:
                    PAUSE 7 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    NEXT.
                 END.
           END.
          
         /**********************************************************************************************/
         /* Setar a flag de cartao como zero */
         ASSIGN aux_fltemcrd = 0.
         
         /* Buscar os dados de cartoes bancoob, afim de verificar se o representante nao possui 
            cartoes ativos ou em processo de solicitaçao */
         FOR EACH crawcrd WHERE crawcrd.cdcooper = cratavt.cdcooper     AND
                                crawcrd.nrdconta = cratavt.nrdconta     AND
                                crawcrd.nrcpftit = cratavt.nrcpfcgc     AND
                               (crawcrd.cdadmcrd >= 10                  AND
                                crawcrd.cdadmcrd <= 80         )        AND
                               (crawcrd.insitcrd = 1   /* aprovado */    OR 
                                crawcrd.insitcrd = 2   /* solicitado */  OR 
                                crawcrd.insitcrd = 3   /* liberado */    OR 
                                crawcrd.insitcrd = 4   /* em uso */      OR 
                                crawcrd.insitcrd = 5   /* cancelado */ ) :
           
           /* Se encontrar um cartao com situaçao de aprovado ou solicitado */
           IF (crawcrd.insitcrd = 1     OR  
               crawcrd.insitcrd = 2  )  THEN 
               DO:
                   ASSIGN aux_fltemcrd = 2.   /* Seta a flag para 2 e sai do for */
                   LEAVE.
               END.
           ELSE
               DO:
                   /* Se encontrar cartoes bancoob na situaçao de liberado, em uso ou cancelado */
                   IF (crawcrd.insitcrd = 3   OR  
                       crawcrd.insitcrd = 4   OR  
                       crawcrd.insitcrd = 5)  THEN
                       ASSIGN aux_fltemcrd = 1.
               END.
         
         END.
         
         /* Verifica a existencia de cartoes */
         IF aux_fltemcrd = 2 THEN
             DO:
                  ASSIGN glb_dscritic = "Exclusao nao permitida, pois responsavel possui cartao aprovado/solicitado.".
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  RETURN "NOK".
             END.
         ELSE
           IF aux_fltemcrd = 1 THEN
               DO:
                   MESSAGE COLOR NORMAL "ATENCAO: Responsavel possui cartoes ativos.".
               END.

         /**********************************************************************************************/

         RUN proc_confirma.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.

         IF aux_confirma = "S" THEN
            DO: 

               IF par_nmrotina <> "PROCURADORES" THEN
                  DO:
                     FIND cratavt WHERE cratavt.nrdrowid = aux_nrdrowid 
                                        EXCLUSIVE-LOCK NO-ERROR.
                     
                     IF AVAILABLE cratavt THEN
                        ASSIGN cratavt.deletado = YES
                               cratavt.cddopcao = "E".

                  END.
               ELSE
                  DO:
                     RUN Exclui_Dados.
                     
                     IF  RETURN-VALUE <> "OK" THEN
                         NEXT.

                  END.


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
														       tt-crappod.cddpoder <> 10				
                                                               NO-LOCK.
                 
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

IF VALID-HANDLE(h-b1wgen9999) THEN
   DELETE OBJECT h-b1wgen9999.

HIDE FRAME f_regua.
HIDE FRAME f_browse.
HIDE FRAME f_procuradores.

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
                                       
    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
       aux_confirma <> "S"                THEN
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

    IF par_cddopcao = "C" THEN
       ASSIGN tel_nrdctato = 0
              tel_nrcpfcgc = ""
              aux_nrdrowid = ?.

    RUN Busca_Dados IN h-b1wgen0058 (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT par_nrdconta,
                                     INPUT 0,
                                     INPUT YES,
                                     INPUT par_cddopcao,
                                     INPUT tel_nrdctato,
                                     INPUT tel_nrcpfcgc,
                                     INPUT aux_nrdrowid,
                                    OUTPUT TABLE tt-crapavt,
                                    OUTPUT TABLE tt-bens,
									OUTPUT aux_qtminast,
                                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.
           
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(3) NO-MESSAGE.
                RETURN "NOK".
             END.
          
       END.

      EMPTY TEMP-TABLE cratavt.
      EMPTY TEMP-TABLE tt-bens.
                   
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

PROCEDURE zoom_tipo_rendimento:
    
    DEF INPUT-OUTPUT PARAM par_tpdrendi AS INTE                   NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dstipren AS CHAR                   NO-UNDO.
    
    DEFINE VARIABLE h-b1wgen0059 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_qtregist AS INTEGER     NO-UNDO.
    
    DEF QUERY q_rendim FOR tt-tipo-rendi.
    DEF BROWSE b_rendim QUERY q_rendim
        DISPLAY tt-tipo-rendi.tpdrendi COLUMN-LABEL "Codigo"    FORMAT "zz9"
                tt-tipo-rendi.dsdrendi COLUMN-LABEL "Descricao" FORMAT "x(25)"
                WITH 5 DOWN NO-BOX.
                
    FORM b_rendim HELP "Pressione ENTER para selecionar ou F4 para sair"
         WITH ROW 9 CENTERED TITLE "TIPO DE RENDIMENTO" OVERLAY NO-LABELS 
              FRAME f_rendimento.

    EMPTY TEMP-TABLE tt-tipo-rendi.

    IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
        RUN sistema/generico/procedures/b1wgen0059.p
            PERSISTENT SET h-b1wgen0059.


    RUN busca-tipo-rendi IN h-b1wgen0059
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT "",
          INPUT 99999,
          INPUT 0,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-tipo-rendi ).

    DELETE PROCEDURE h-b1wgen0059.
              
    ON RETURN OF b_rendim DO:

        IF AVAILABLE tt-tipo-rendi THEN
           ASSIGN par_tpdrendi = tt-tipo-rendi.tpdrendi
                  par_dstipren = tt-tipo-rendi.dsdrendi.

       APPLY "GO".
    END.
    
    OPEN QUERY q_rendim FOR EACH tt-tipo-rendi NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_rendim WITH FRAME f_rendimento.
       LEAVE.
    END.
    
    HIDE FRAME f_rendimento NO-PAUSE.
       
END PROCEDURE.

PROCEDURE Busca_Dados_Bens:

    IF par_nmrotina = "PROCURADORES" THEN
       RUN Busca_Dados_Bens IN h-b1wgen0058 (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT tel_nrdconta,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT YES,
                                             INPUT tel_nrdctato,
                                             INPUT tel_nrcpfcgc,
                                            OUTPUT TABLE tt-bens,
                                            OUTPUT TABLE tt-erro) NO-ERROR.


    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(2) NO-MESSAGE.
                RETURN "NOK".

             END.

       END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Tela:

    ASSIGN tel_nmdavali = ""
           tel_tpdocava = ""
           tel_nrdocava = ""
           tel_cdoeddoc = ""
           tel_cdufddoc = ""
           tel_dtemddoc = ?
           tel_dsproftl = ""
           tel_dsprofan = ""
           tel_dtnascto = ?
           tel_cdsexcto = ""
           tel_cdestcvl = 0
           tel_dsestcvl = ""
           tel_dsnacion = ""
           tel_dsnatura = ""
           tel_nmmaecto = ""
           tel_nmpaicto = ""
           tel_nrcepend = 0
           tel_dsendere = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nmbairro = ""
           tel_nmcidade = ""
           tel_cdufende = ""
           tel_dsrelbem = ""
           tel_nrcxapst = 0
           tel_dtvalida = ?
           tel_dtadmsoc = ?
           tel_flgdepec = FALSE
           tel_persocio = 0
           tel_vledvmto = 0
           tel_inhabmen = 0
           tel_dthabmen = ?
           tel_dshabmen = ""
           aux_idseqttl = 0
           tel_nrdctato = 0
           tel_vloutren = 0
           tel_dsoutren_1 = ""
           tel_dsoutren_2 = ""
           tel_dsoutren_3 = ""
           tel_dsoutren_4 = ""
           aux_rowidben = ?
           aux_cpfdoben = ""
           tel_nrcpfcgc = "" WHEN par_nmrotina <> "PROCURADORES". 

    DISPLAY tel_persocio
            tel_flgdepec
            WITH FRAME f_procuradores.

    ASSIGN INPUT tel_nrdctato.

   
    FIND FIRST cratavt WHERE (aux_nrdrowid <> ?                AND 
                              cratavt.nrdrowid = aux_nrdrowid) OR 
                             (aux_nrdrowid = ?                 AND
                              cratavt.nrdctato = tel_nrdctato  OR 
                              cratavt.nrdrowid = aux_nrdrowid)    
                              NO-ERROR.

    IF AVAIL cratavt THEN
       DO:
          ASSIGN tel_nmdavali = cratavt.nmdavali
                 tel_tpdocava = cratavt.tpdocava
                 tel_nrdocava = cratavt.nrdocava
                 tel_cdoeddoc = cratavt.cdoeddoc
                 tel_cdufddoc = cratavt.cdufddoc
                 tel_dtemddoc = cratavt.dtemddoc
                 tel_dsproftl = cratavt.dsproftl
                 tel_dsprofan = cratavt.dsproftl
                 tel_dtnascto = cratavt.dtnascto
                 tel_cdsexcto = IF cratavt.cdsexcto = 1 THEN 
                                   "M" 
                                ELSE 
                                   "F"
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
                 tel_dtadmsoc = cratavt.dtadmsoc
                 tel_flgdepec = cratavt.flgdepec
                 tel_persocio = cratavt.persocio
                 tel_vledvmto = cratavt.vledvmto
                 tel_inhabmen = cratavt.inhabmen
                 tel_dthabmen = cratavt.dthabmen
                 tel_dshabmen = cratavt.dshabmen
                 aux_idseqttl = cratavt.nrctremp
                 aux_rowidben = cratavt.nrdrowid
                 aux_cpfdoben = STRING(cratavt.nrcpfcgc).
          
          IF tel_nrdctato = 0 THEN
             ASSIGN tel_nrdctato = cratavt.nrdctato.
          
          IF tel_nrcpfcgc = "" THEN
             ASSIGN tel_nrcpfcgc = cratavt.cdcpfcgc.
          
          ASSIGN tel_vloutren = cratavt.vloutren.
          
          IF LENGTH(cratavt.dsoutren) > 150 THEN
             ASSIGN tel_dsoutren_1 = SUBSTR(cratavt.dsoutren, 1, 50)
                    tel_dsoutren_2 = SUBSTR(cratavt.dsoutren, 51, 50)
                    tel_dsoutren_3 = SUBSTR(cratavt.dsoutren, 101, 50)
                    tel_dsoutren_4 = SUBSTR(cratavt.dsoutren, 151,
                                           LENGTH(cratavt.dsoutren) - 150).
          ELSE
             IF LENGTH(cratavt.dsoutren) > 100 THEN
                ASSIGN tel_dsoutren_1 = SUBSTR(cratavt.dsoutren, 1, 50)
                       tel_dsoutren_2 = SUBSTR(cratavt.dsoutren, 51, 50)
                       tel_dsoutren_3 = SUBSTR(cratavt.dsoutren, 101,
                                              LENGTH(cratavt.dsoutren) - 100)
                       tel_dsoutren_4 = "".
             ELSE
                IF LENGTH(cratavt.dsoutren) > 50 THEN
                   ASSIGN tel_dsoutren_1 = SUBSTR(cratavt.dsoutren, 1, 50)
                          tel_dsoutren_2 = SUBSTR(cratavt.dsoutren, 51,
                                                 LENGTH(cratavt.dsoutren) - 50)
                           tel_dsoutren_3 = ""
                           tel_dsoutren_4 = "".
                ELSE
                   ASSIGN tel_dsoutren_1 = cratavt.dsoutren
                          tel_dsoutren_2 = ""
                          tel_dsoutren_3 = ""
                          tel_dsoutren_4 = "".
          
          DISPLAY tel_nrcpfcgc    tel_nmdavali    tel_tpdocava
                  tel_nrdocava    tel_cdoeddoc    tel_cdufddoc
                  tel_dtemddoc    tel_dtnascto    tel_cdsexcto
                  tel_cdestcvl    tel_dsestcvl    tel_dsnacion
                  tel_dsnatura    tel_nrcepend    tel_dsendere
                  tel_nrendere    tel_complend    tel_nmbairro
                  tel_nmcidade    tel_cdufende    tel_nrcxapst
                  tel_nmmaecto    tel_nmpaicto    tel_dtvalida
                  tel_dsproftl    tel_nrdctato    tel_vledvmto    
                  tel_dsrelbem    tel_dtvalida    tel_dsproftl    
                  tel_dtadmsoc    tel_flgdepec    tel_persocio
                  tel_inhabmen    tel_dshabmen    tel_dthabmen    
                  WITH FRAME f_procuradores.
          
          DISABLE tel_persocio 
                  tel_flgdepec 
                  WITH FRAME f_procuradores.

       END.
          
                          

END PROCEDURE.

PROCEDURE Valida_Dados:
    
    RUN Valida_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0, /*cdagenci*/
         INPUT 0, /*nrdcaixa*/
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1, /*idorigem*/
         INPUT par_nrdconta,
         INPUT 0, /*idseqttl*/
         INPUT YES, /*flgerlog*/
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
         INPUT tel_dsproftl,
         INPUT tel_dtadmsoc,
         INPUT tel_persocio,
         INPUT tel_flgdepec,
         INPUT tel_vloutren,
         INPUT tel_dsoutren_1,
         INPUT tel_inhabmen,
         INPUT tel_dthabmen,
         INPUT par_nmrotina,
         INPUT aux_verrespo,
         INPUT par_permalte,
         INPUT TABLE tt-bens,
         INPUT TABLE tt-resp,
         INPUT TABLE tt-crapavt,
        OUTPUT aux_msgalert,
        OUTPUT TABLE tt-erro,
        OUTPUT aux_nrdeanos,
        OUTPUT aux_nrdmeses,
        OUTPUT aux_dsdidade).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(3) NO-MESSAGE.
                RETURN "NOK".

             END.

       END.

    IF aux_msgalert <> "" THEN
       DO:
           MESSAGE aux_msgalert.
           PAUSE 7 NO-MESSAGE.

       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Grava_Dados:
    
    IF VALID-HANDLE(h-b1wgen0058) THEN
       DELETE OBJECT h-b1wgen0058.

    RUN sistema/generico/procedures/b1wgen0058.p 
        PERSISTENT SET h-b1wgen0058.

    RUN Grava_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT par_nrdconta,
         INPUT 0,
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
         INPUT tel_dsproftl,
         INPUT tel_dtadmsoc,
         INPUT tel_persocio,
         INPUT tel_flgdepec,
         INPUT tel_vloutren,
         INPUT tel_dsoutren_1 + tel_dsoutren_2 + tel_dsoutren_3 + 
               tel_dsoutren_4,
         INPUT tel_inhabmen,
         INPUT tel_dthabmen,
         INPUT glb_nmrotina,
         INPUT TABLE tt-bens,
         INPUT TABLE tt-resp,
        OUTPUT aux_msgalert,
        OUTPUT TABLE tt-erro) .

    HIDE MESSAGE NO-PAUSE.

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(3) NO-MESSAGE.
                RETURN "NOK".

             END.

       END.

    IF aux_msgalert <> "" THEN
       MESSAGE aux_msgalert.

    DELETE OBJECT h-b1wgen0058.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN h-b1wgen0058 (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_nmdatela,
                                      INPUT 1,
                                      INPUT par_nrdconta,
                                      INPUT 0,
                                      INPUT YES,
                                      INPUT tel_nrcpfcgc,
                                     OUTPUT TABLE tt-erro) .

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(3) NO-MESSAGE.

                RETURN "NOK".

             END.

       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Verifica_Bloqueio:

    RUN Verifica_Bloqueio IN h-b1wgen0058 ( INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            INPUT tel_dsproftl,
                                            INPUT cratavt.dsproftl,
                                           OUTPUT aux_msgalert ).

    IF aux_msgalert <> "" THEN
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

PROCEDURE Atualiza_Tabela:

    IF NOT aux_flsincro THEN
       DO:
          /* Carrega a lista de procuradores/representantes */
          EMPTY TEMP-TABLE cratavt.
    
          FOR EACH tt-crapavt NO-LOCK:
                             
              CREATE cratavt.
              BUFFER-COPY tt-crapavt TO cratavt.

              ASSIGN cratavt.nrdrowid = tt-crapavt.rowidavt
                     cratavt.cddopcao = tt-crapavt.cddopcao
                     cratavt.deletado = tt-crapavt.deletado.

              CREATE tt-cravavt.
              BUFFER-COPY tt-crapavt TO tt-cravavt.

                    
          END.

          FOR EACH tt-bens NO-LOCK:

              CREATE tt-bensb.
              BUFFER-COPY tt-bens TO tt-bensb.

              CREATE tt-bensv.
              BUFFER-COPY tt-bens TO tt-bensv.

          END.
    
          /* sincronizou as temptable's */
          ASSIGN aux_flsincro = YES.

       END.
    ELSE
       DO:
          EMPTY TEMP-TABLE tt-crapavt.
          EMPTY TEMP-TABLE tt-cravavt.
          EMPTY TEMP-TABLE tt-bens.

          FOR EACH cratavt:
              
              CREATE tt-crapavt.
              BUFFER-COPY cratavt TO tt-crapavt. 
              
              ASSIGN tt-crapavt.rowidavt = cratavt.nrdrowid
                     tt-crapavt.cddopcao = cratavt.cddopcao
                     tt-crapavt.deletado = cratavt.deletado.

              CREATE tt-cravavt.
              BUFFER-COPY tt-crapavt TO tt-cravavt.

          END.
           
          FOR EACH tt-bensb NO-LOCK:

              FIND FIRST tt-bensv WHERE 
                         tt-bensv.dsrelbem = tt-bensb.dsrelbem AND
                         tt-bensv.cddopcao = tt-bensv.cddopcao AND
                         tt-bensv.nrdrowid = tt-bensb.nrdrowid AND
                         tt-bensv.cpfdoben = tt-bensb.cpfdoben
                         NO-LOCK NO-ERROR.

              IF NOT AVAIL tt-bensv THEN
                 DO:
                    CREATE tt-bensv.
                    BUFFER-COPY tt-bensb TO tt-bensv.

                 END. 

          END.

          FOR EACH tt-bensv NO-LOCK:

              CREATE tt-bens.
              BUFFER-COPY tt-bensv TO tt-bens.

          END.

          FOR EACH resp_legal NO-LOCK:

              FIND FIRST tt-resp WHERE 
                         tt-resp.cdcooper = resp_legal.cdcooper AND
                         tt-resp.nrctamen = resp_legal.nrctamen AND
                         tt-resp.nrcpfmen = resp_legal.nrcpfmen AND
                         tt-resp.idseqmen = resp_legal.idseqmen AND
                         tt-resp.nrdconta = resp_legal.nrdconta AND
                         tt-resp.nrcpfcgc = resp_legal.nrcpfcgc
                         NO-LOCK NO-ERROR.

              IF NOT AVAIL tt-resp THEN
                 DO:
                    CREATE tt-resp.
                    BUFFER-COPY resp_legal TO tt-resp.

                 END.

          END.

       END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Busca_Procurador:

    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.

	DEF VAR aux_qtminast AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-crabavt.
    EMPTY TEMP-TABLE tt-bensb.
    EMPTY TEMP-TABLE tt-erro.

    RUN Busca_Dados IN h-b1wgen0058 (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT par_nrdconta,
                                     INPUT 0,
                                     INPUT YES,
                                     INPUT par_cddopcao,
                                     INPUT tel_nrdctato,
                                     INPUT tel_nrcpfcgc,
                                     INPUT aux_nrdrowid,
                                    OUTPUT TABLE tt-crabavt,
                                    OUTPUT TABLE tt-bensb,
									OUTPUT aux_qtminast,
                                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.
           
    IF RETURN-VALUE <> "OK" THEN
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


PROCEDURE Atualiza_Campos:

    ASSIGN tel_nmdavali = ""      
           tel_tpdocava = ""      
           tel_nrdocava = ""      
           tel_cdoeddoc = ""      
           tel_cdufddoc = ""      
           tel_dtemddoc = ?       
           tel_dsproftl = ""      
           tel_dsprofan = ""      
           tel_dtnascto = ?       
           tel_cdsexcto = ""      
           tel_cdestcvl = 0       
           tel_dsestcvl = ""      
           tel_dsnacion = ""      
           tel_dsnatura = ""      
           tel_nmmaecto = ""      
           tel_nmpaicto = ""      
           tel_nrcepend = 0       
           tel_dsendere = ""      
           tel_nrendere = 0       
           tel_complend = ""      
           tel_nmbairro = ""      
           tel_nmcidade = ""      
           tel_cdufende = ""      
           tel_dsrelbem = ""      
           tel_nrcxapst = 0       
           tel_dtvalida = ?       
           tel_dtadmsoc = ?       
           tel_flgdepec = FALSE   
           tel_persocio = 0       
           tel_vledvmto = 0       
           tel_inhabmen = 0       
           tel_dthabmen = ?       
           tel_dshabmen = ""      
           aux_idseqttl = 0       
           tel_nrdctato = 0       
           tel_vloutren = 0       
           tel_dsoutren_1 = ""    
           tel_dsoutren_2 = ""    
           tel_dsoutren_3 = ""    
           tel_dsoutren_4 = ""    
           aux_rowidben = ?
           aux_cpfdoben = "".      

    FIND FIRST tt-crabavt WHERE tt-crabavt.deletado = NO NO-ERROR.
    
    IF AVAIL tt-crabavt THEN
       DO: 
          ASSIGN tel_nmdavali = tt-crabavt.nmdavali
                 tel_tpdocava = tt-crabavt.tpdocava
                 tel_nrdocava = tt-crabavt.nrdocava
                 tel_cdoeddoc = tt-crabavt.cdoeddoc
                 tel_cdufddoc = tt-crabavt.cdufddoc
                 tel_dtemddoc = tt-crabavt.dtemddoc
                 tel_dsproftl = tt-crabavt.dsproftl
                 tel_dtnascto = tt-crabavt.dtnascto
                 tel_cdsexcto = IF tt-crabavt.cdsexcto = 1 THEN 
                                   "M" 
                                ELSE 
                                   "F"
                 tel_cdestcvl = tt-crabavt.cdestcvl
                 tel_dsestcvl = tt-crabavt.dsestcvl
                 tel_dsnacion = tt-crabavt.dsnacion
                 tel_dsnatura = tt-crabavt.dsnatura
                 tel_nmmaecto = tt-crabavt.nmmaecto
                 tel_nmpaicto = tt-crabavt.nmpaicto
                 tel_nrcepend = tt-crabavt.nrcepend
                 tel_dsendere = tt-crabavt.dsendres[1]
                 tel_nrendere = tt-crabavt.nrendere
                 tel_complend = tt-crabavt.complend
                 tel_nmbairro = tt-crabavt.nmbairro
                 tel_nmcidade = tt-crabavt.nmcidade
                 tel_cdufende = tt-crabavt.cdufresd
                 tel_dsrelbem = tt-crabavt.dsrelbem[1]
                 tel_nrcxapst = tt-crabavt.nrcxapst
                 tel_dtvalida = tt-crabavt.dtvalida
                 tel_dtadmsoc = tt-crabavt.dtadmsoc
                 tel_flgdepec = tt-crabavt.flgdepec
                 tel_persocio = tt-crabavt.persocio
                 tel_vledvmto = tt-crabavt.vledvmto
                 tel_inhabmen = tt-crabavt.inhabmen
                 tel_dthabmen = tt-crabavt.dthabmen
                 tel_dshabmen = tt-crabavt.dshabmen
                 aux_idseqttl = tt-crabavt.nrctremp
                 aux_rowidben = ROWID(tt-crabavt)
                 aux_cpfdoben = STRING(tt-crabavt.nrcpfcgc).
                                   
                                  
          IF tel_nrdctato = 0 THEN
             ASSIGN tel_nrdctato = tt-crabavt.nrdctato.
          
          IF tel_nrcpfcgc = "" THEN
             ASSIGN tel_nrcpfcgc = tt-crabavt.cdcpfcgc.
          
          ASSIGN tel_vloutren = tt-crabavt.vloutren.
          
          IF LENGTH(tt-crabavt.dsoutren) > 150 THEN
             ASSIGN tel_dsoutren_1 = SUBSTR(tt-crabavt.dsoutren, 1, 50)
                    tel_dsoutren_2 = SUBSTR(tt-crabavt.dsoutren, 51, 50)
                    tel_dsoutren_3 = SUBSTR(tt-crabavt.dsoutren, 101, 50)
                    tel_dsoutren_4 = SUBSTR(tt-crabavt.dsoutren, 151,
                                        LENGTH(tt-crabavt.dsoutren) - 150).
          ELSE
             IF LENGTH(tt-crabavt.dsoutren) > 100 THEN
                ASSIGN tel_dsoutren_1 = SUBSTR(tt-crabavt.dsoutren, 1, 50)
                       tel_dsoutren_2 = SUBSTR(tt-crabavt.dsoutren, 51, 50)
                       tel_dsoutren_3 = SUBSTR(tt-crabavt.dsoutren, 101,
                                           LENGTH(tt-crabavt.dsoutren) - 100)
                       tel_dsoutren_4 = "".
             ELSE
                IF LENGTH(tt-crabavt.dsoutren) > 50 THEN
                   ASSIGN tel_dsoutren_1 = SUBSTR(tt-crabavt.dsoutren, 1, 50)
                          tel_dsoutren_2 = SUBSTR(tt-crabavt.dsoutren, 51,
                                              LENGTH(tt-crabavt.dsoutren) - 50)
                          tel_dsoutren_3 = ""
                          tel_dsoutren_4 = "".
                ELSE
                   ASSIGN tel_dsoutren_1 = tt-crabavt.dsoutren
                          tel_dsoutren_2 = ""
                          tel_dsoutren_3 = ""
                          tel_dsoutren_4 = "".
          
          DISPLAY tel_nrcpfcgc    tel_nmdavali    tel_tpdocava
                  tel_nrdocava    tel_cdoeddoc    tel_cdufddoc
                  tel_dtemddoc    tel_dtnascto    tel_cdsexcto
                  tel_cdestcvl    tel_dsestcvl    tel_dsnacion
                  tel_dsnatura    tel_nrcepend    tel_dsendere
                  tel_nrendere    tel_complend    tel_nmbairro
                  tel_nmcidade    tel_cdufende    tel_nrcxapst
                  tel_nmmaecto    tel_nmpaicto    tel_dtvalida
                  tel_dsproftl    tel_nrdctato    tel_vledvmto    
                  tel_dsrelbem    tel_dtvalida    tel_dsproftl    
                  tel_dtadmsoc    tel_flgdepec    tel_persocio
                  tel_inhabmen    tel_dshabmen    tel_dthabmen    
                  WITH FRAME f_procuradores.
                
          DISABLE tel_persocio 
                  tel_flgdepec 
                  WITH FRAME f_procuradores.

       END.
    ELSE
       DO:
           /*Para controla o cadastro de bens para cpf que nao tenha
             conta na cooperativa*/
           ASSIGN INPUT tel_nrcpfcgc.
           ASSIGN aux_cpfdoben = STRING(REPLACE(REPLACE(
                                 tel_nrcpfcgc, ".",""), "-","")).


       END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE Valida_Procurador:

    RUN Valida_Dados IN h-b1wgen0058
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT par_nrdconta,
         INPUT 0,
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
         INPUT tel_dsproftl,
         INPUT tel_dtadmsoc,
         INPUT tel_persocio,
         INPUT tel_flgdepec,
         INPUT tel_vloutren,
         INPUT tel_dsoutren_1,
         INPUT tel_inhabmen,
         INPUT tel_dthabmen,
         INPUT par_nmrotina,
         INPUT aux_verrespo,
         INPUT par_permalte,
         INPUT TABLE tt-bens,
         INPUT TABLE resp_legal,
         INPUT TABLE tt-cravavt,
        OUTPUT aux_msgalert,
        OUTPUT TABLE tt-erro,
        OUTPUT aux_nrdeanos,
        OUTPUT aux_nrdmeses,
        OUTPUT aux_dsdidade) .
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                PAUSE(3) NO-MESSAGE.
                RETURN "NOK".

             END.

       END.

    IF aux_msgalert <> "" THEN
       DO:
           MESSAGE aux_msgalert.
           PAUSE 7 NO-MESSAGE.

       END.
      
    RETURN "OK".

END PROCEDURE.



/*...........................................................................*/
