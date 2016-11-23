/* .............................................................................

   Programa: fontes/cadcop.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro/Diego
   Data    : Novembro/2006                      Ultima atualizacao: 06/10/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADCOP - Cadastro dos dados da Cooperativa.

   Alteracoes: 08/12/2006 - Permite opcao "A" somente para operadores 1 ou 997 
                            (Elton).
                             
               26/12/2006 - Pedir confirmacao quando presisonar F1 (Evandro).
               
               27/12/2006 - Incluido frame com clausula de contrato (Elton).
               
               02/01/2007 - Incluido frame contendo valores do campo
                            crapcop.dsclaccb (Elton).
                            
               01/08/2007 - Arrumado ordem de alteracao dos campos que nao
                            estavam na sequencia (Elton).
                                          
               19/08/2007 - Incluido hora ini, hora fin e anotacoes do processo
                          - Incluido valor limite aprovacao vllimapv(Guilherme)
                           
               03/10/2007 - Opcao "C" nao estava carregando horarios do processo
                            da tabela crapcop (David).
               
               24/10/2007 - Incluido campo crapcop.cdcrdarr (Gabriel).    
               
               06/11/2007 - Incluido campo crapcop.cdagsede (Gabriel).
                          - Opcao "A" nao estava carregando horarios do processo
                            da tabela crapcop (David)
                          - Alteracao nos HELPs de alguns campos para 
                            padronizacao(Guilherme).
                            
               25/03/2008 - Feito controle para que quando o campo
                            "crapcop.cdagsede" for preenchido, o campo
                            "crapcop.cdcrdarr" tambem seja preenchido;
                          - Controle de alteracao do campo "crapcop.cdcrdarr"
                            (Evandro).
                          - Retirado campo crapcop.vllimapv (Gabriel).
                          
               12/05/2008 - Incluido o campo "Informativo Chegada Cartao"
                            com informacoes da crapcop.cdsinfmg (Elton).
                            
               03/07/2008 - Incluir telefone URA (Guilherme).          
                                 
               06/10/2008 - Aumentado formato campo e_mail(Mirtes).
               
               12/12/2008 - Incluido Frame COBAN (Diego).
                          - Tratamentos para o DIMOF e inclusao da data da
                            inscricao do CNPJ da coop na Receita Fed.(Guilherme)
                          - Incluir log com valores Anterior/Atual(Gabriel).
            
               29/01/2009 - Retirar permissao do operador 799 e liberar
                            o 979 (Gabriel).
             
               19/03/2009 - Ajustado campo "Cartao magnetico" para apenas ser
                            atualizado como "Sim" se o campo "Agencia Bancoob"
                            for informado (Fernando).
               
                          - Aumentado campo dsnotifi para EXTENT 6 (Fernando).
                           
               11/05/2009 - Alteracao CDOPERAD (Kbase).
                          
               18/06/2009 - Adicionados os campos "Conta Coope Emis. Boleto" e
                            "Linha Credito Emis. Boleto" - Emprestimos com 
                            boletos (Fernando). 
                            
               29/07/2009 - Alterado para gravar informacoes em maiusculo 
                            (Diego).
               
               09/09/2009 - Incluido campo "Valor Limite Alcada Geral" e criada
                            a frame f_coop4 (Elton).
                            
               28/09/2009 - Incluir cdbcoctl, nrdvictl, cdagectl - IF CECRED 
                            (Guilherme).
                            
               02/12/2009 - Incluir campo flgcmtlc e nrctacmp (David).

               10/05/2010 - Ao alterar a COOP COMPE, emitir aviso para verificar
                             Agencia CECRED na tela CADPAC. (Guilherme/Supero)

               19/05/2010 - Incluido o campo nrtelouv (Sandro-GATI)  
               
               23/03/2011 - Incluido tratamento p/ nao permitir que o campo 
                            "Sede INSS" (crapcop.cdagsede) seja = 0 caso o 
                            campo "Creden.Arrecadacoes" (crapcop.cdcrdarr) 
                            esteja preenchido (Vitor)
                    
               25/03/2011 - Adicinado campos referente ao DDA, assim como para 
                            a geracao de LOG do mesmo.(Jorge)
                            
               21/07/2011 - Adicionado frame f_coop9, referente a COBRANCA REG.
                            (Fabricio)
                            
               26/07/2011 - Subsituido o campo nrlivdda , pelo idlivdda
                            na crapcop (Gabriel).
                            
               13/10/2011 - Adicionado campo para quantidade de dias para
                            verificacao de envelopes TAA pendentes (Evandro).
                            
               18/10/2011 - Incluido campos referente a "Central de Risco" 
                            no frame f_coop9 (Adriano).
                            
               17/01/2012 - Adicionado campo crapcop.taamaxer, referente a qtd
                            maxima de tentativas de senha no TAA (Jorge).
                            
               07/03/2012 - Removido a atualizacao do campo crapcop.dssigaut.
                            (Fabricio)
                            
               13/03/2013 - Incluir frame f_coop10 do SICREDI (Lucas R.). 
               
               01/04/2013 - Tratamento para VR Boleto (Lucas).
               
               12/04/2013 - Adicionar campo de Cnta. da Coop. no SICREDI (Lucas).
               
               19/06/2013 - Adicionados campos : crapcop.cdcrdins, 
                            crapcop.cdagsins, crapcop.nrcredis (Reinert).
                            
               24/06/2013 - Adicionado campo: crapcop.vltarsic (Reinert)
               
               26/06/2013 - Adicionado campo crapcop.qttmpsgr (Sangria de Caixa)
                            (Fabricio).
                            
               02/07/2013 - Removido campo crapcop.nrcredis e espaçamentos
                            no bloco "SICREDI" (Douglas Pagel). 

               31/07/2013 - Alterado format do campo crapcop.qttmpsgr; de: "HH"
                            para: "HH:MM". (Fabricio)

               27/08/2013 - Adicionado campos crapcop.vlmiplco e 
                            crapcop.vlmidbco. (Fabricio)

               26/09/2013 - Adicionado campos:
                            Codigo da financeira (crapcop.cdfingrv) 
                            Subcodigo do usuário (crapcop.cdsubgrv) 
                            Login do usuário     (crapcop.cdloggrv). (Reinert)

               04/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)

               18/12/2013 - Inclusao de VALIDATE craptab e crapmof (Carlos)

               23/12/2013 - Incluido tratamento para atualizacao da hora de
                            pagamento do VR Boleto na tela (Tiago).

               04/02/2014 - Inclusao do departamento "CONTROLE" na opcao A 
                            (Carlos)

               16/06/2014 - Adicionado campos vltardrf, vltarcrs, além dos 
                            campos de hora de início e fim para pagamento de GPS, 
                            no frame f_coop10. (Chamado 146711) - (Fabricio)

               26/06/2014 - Inclusao do campo Valor Limite Mes 'vllimmes' 
                            (Jaison) 

               26/08/2014 - Inclusao da Tela Débito Fácil após a tela Sangria. 
                            (Vanessa) 

               03/11/2014 - Alteraçao da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               27/01/2015 - Inclusao do campo Codigo Serasa, frame f_coop14
                            (Guilherme/Supero)
               
               29/01/2015 - Inclusao do campo "Horário Limite Pagamento", frame f_coop10 (SD 222608 - Kelvin)
               
               02/07/2015 - Projeto 217 - Inclusao de nova opcao 
                            M - Cadastro Municipio (Tiago Castro - RKAM)
                            
               30/07/2015 - #308980 Melhoria 144 - Duplicidade de pagamentos.
                            Inclusao do nr do telefone do SAC (Carlos)
               
               23/09/2015 - Ajustar o frame onde está sendo exibida as informações do SICREDI 
                            Projeto GPS (Carlos Rafael Tanholi).
               
               27/01/2016 - Inclusao do campo crapcop.flsaqpre, frame f_coop15 
                            (Lombardi - #393807)
               
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               06/04/2016 - Inclusao dos horarios de atendimento do SAC e
                            OUVIDORIA (melhoria 212 Tiago/Elton).

			   26/04/2016 - Ajustes para melhoria 212 (Tiago/Elton).

			   27/04/2016 - Ajustes para melhoria 212 (Tiago/Elton).

               01/08/2016 - Adicionado novo campo de arrecadacao GPS
                            conforme solicitado no chamado 460485. (Kelvin)

               06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                           (Guilherme/SUPERO)
..............................................................................*/

{ includes/var_online.i }

DEF  VAR aux_fechando AS LOGICAL                                     NO-UNDO.
DEF  VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF  VAR aux_confirma AS CHAR FORMAT "!(1)"                          NO-UNDO.
DEF  VAR aux_cdcrdarr LIKE crapcop.cdcrdarr                          NO-UNDO.
DEF  VAR aux_cddigage AS INT                                         NO-UNDO.
DEF  VAR aux_cdagectl LIKE crapcop.cdagectl                          NO-UNDO.

DEF  VAR tel_horproce AS INT  FORMAT "99"                            NO-UNDO.
DEF  VAR tel_minproce AS INT  FORMAT "99"                            NO-UNDO.
DEF  VAR tel_segproce AS INT  FORMAT "99"                            NO-UNDO.
DEF  VAR tel_hrfinprc AS INT  FORMAT "99"                            NO-UNDO.
DEF  VAR tel_mnfinprc AS INT  FORMAT "99"                            NO-UNDO.
DEF  VAR tel_sgfinprc AS INT  FORMAT "99"                            NO-UNDO.

DEF  VAR tel_dsclactr AS CHAR   EXTENT 06                            NO-UNDO.
DEF  VAR tel_dsclaccb AS CHAR   EXTENT 06                            NO-UNDO.

DEF  VAR tel_cdagectl LIKE crapcop.cdagectl                          NO-UNDO.

DEF  VAR aux_retorna  AS LOGICAL                                     NO-UNDO.
DEF  VAR aux_retorna2 AS LOGICAL                                     NO-UNDO.

DEF  VAR tel_cdsinfmg AS CHAR  FORMAT "x(13)"                        NO-UNDO.
DEF  VAR aux_cdsinfmg AS INT                                         NO-UNDO.

DEF  VAR aux_dsemlctr AS CHAR FORMAT "x(30)"                         NO-UNDO.
DEF  VAR old_dsemlctr AS CHAR FORMAT "x(30)"                         NO-UNDO.

DEF  VAR tel_nrconven AS INT                                         NO-UNDO.
DEF  VAR tel_nrversao AS INT                                         NO-UNDO.
DEF  VAR tel_vldataxa AS DEC                                         NO-UNDO.
DEF  VAR tel_vltxinss AS DEC                                         NO-UNDO.
DEF  VAR tel_flgargps AS LOGI FORMAT "SIM/NAO"                       NO-UNDO.  

/* GPS */
DEF  VAR tel_vltfcxsb AS DEC INIT 0                                  NO-UNDO.
DEF  VAR tel_vltfcxcb AS DEC INIT 0                                  NO-UNDO.
DEF  VAR tel_vlrtrfib AS DEC INIT 0                                  NO-UNDO.

/* VR Boleto */
DEF VAR tel_hhvrbini AS INTE                                         NO-UNDO.
DEF VAR tel_mmvrbini AS INTE                                         NO-UNDO.
DEF VAR tel_hhvrbfim AS INTE                                         NO-UNDO.
DEF VAR tel_mmvrbfim AS INTE                                         NO-UNDO.
DEF VAR aux_hrvrbini AS CHAR                                         NO-UNDO.
DEF VAR aux_hrvrbfim AS CHAR                                         NO-UNDO.
DEF VAR tel_flgvrbol AS LOGI                                         NO-UNDO.

/* Horarios de atendimento - SAC|OUVIDORIA */
DEF VAR tel_hrinisac AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_mminisac AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_hrfimsac AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_mmfimsac AS INTE   FORMAT "99"                           NO-UNDO.

DEF VAR tel_hriniouv AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_mminiouv AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_hrfimouv AS INTE   FORMAT "99"                           NO-UNDO.
DEF VAR tel_mmfimouv AS INTE   FORMAT "99"                           NO-UNDO.


DEF  VAR tel_nrctabol AS INT  FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF  VAR tel_cdlcrbol AS INT  FORMAT "zz9"                           NO-UNDO.

DEF  VAR aux_contador AS INT                                         NO-UNDO.
DEF  VAR aux_nrconven AS INT                                         NO-UNDO.
DEF  VAR aux_nrversao AS INT                                         NO-UNDO.
DEF  VAR aux_vldataxa AS DEC                                         NO-UNDO.
DEF  VAR aux_vltxinss AS DEC                                         NO-UNDO.
DEF  VAR aux_lsvalido AS CHAR                                        NO-UNDO.
DEF  VAR aux_dtcalcu2 AS DATE                                        NO-UNDO.
DEF  VAR aux_ultdiame AS DATE                                        NO-UNDO.
DEF  VAR aux_nrctabol AS INT                                         NO-UNDO.
DEF  VAR aux_cdlcrbol AS INT                                         NO-UNDO.
DEF  VAR aux_nmdcampo AS CHAR                                        NO-UNDO.

DEF VAR tel_flgopstr AS LOGI FORMAT "SIM/NAO"                        NO-UNDO.
DEF VAR tel_flgoppag AS LOGI FORMAT "SIM/NAO"                        NO-UNDO.

DEF VAR hor_inioppag AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_inioppag AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR hor_fimoppag AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_fimoppag AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR hor_iniopstr AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_iniopstr AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR hor_fimopstr AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_fimopstr AS INTE FORMAT "99"                             NO-UNDO.

DEF VAR hor_intersgr AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_intersgr AS INTE FORMAT "99"                             NO-UNDO.

DEF VAR hor_inipggps AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_inipggps AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR hor_fimpggps AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_fimpggps AS INTE FORMAT "99"                             NO-UNDO.

DEF VAR hor_limitsic AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_limitsic AS INTE FORMAT "99"                             NO-UNDO.

DEF VAR hor_inidebfa AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_inidebfa AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR hor_fimdebfa AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR min_fimdebfa AS INTE FORMAT "99"                             NO-UNDO.

DEF VAR tel_flgdebfa AS LOGI FORMAT "SIM/NAO"                        NO-UNDO.
DEF VAR tel_qtdiasus AS INTE                                         NO-UNDO. 

DEF VAR aux_dadosusr AS CHAR                                         NO-UNDO.
DEF VAR par_loginusr AS CHAR                                         NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                         NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                         NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                         NO-UNDO.
DEF VAR par_numipusr AS CHAR                                         NO-UNDO.
DEF VAR tel_flgkitbv AS LOGI FORMAT "SIM/NAO"                        NO-UNDO.
DEF VAR tel_flsaqpre AS LOGI FORMAT "Isentar/Nao isentar"              NO-UNDO.
DEF VAR tel_flrecpct AS LOGI FORMAT "Sim/Nao"                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.

DEF TEMP-TABLE w-crapcop NO-UNDO   LIKE crapcop.
DEF TEMP-TABLE w-crapmun NO-UNDO   LIKE crapmun.
DEF BUFFER bcrapcop  FOR crapcop.
DEF BUFFER crabtab   FOR craptab.

DEF VAR reg_dsdopcao AS CHAR EXTENT 2 INIT ["Incluir",
                                            "Excluir"]             NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 2 INIT ["I","E"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                       NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(50)"                        NO-UNDO.
DEF VAR tel_cduflogr AS CHAR FORMAT "X(2)"                         NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                      NO-UNDO.
def VAR aux_qtuf     AS INT                                        NO-UNDO.
DEF VAR aux_nmuf     LIKE crapmun.cdestado                         NO-UNDO.
DEF VAR aux_cidade   LIKE crapmun.cdcidade                         NO-UNDO.

FORM SKIP(1)
     glb_cddopcao  AT  2  LABEL "Opcao"
                          HELP "Informe a opcao desejada (A, C, M)"
                          VALIDATE(CAN-DO("A,C,M",glb_cddopcao),
                                   "014 - Opcao errada.")
     SKIP(14)
     WITH OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_opcao.

FORM crapcop.cdcooper  AT  3  LABEL "Cooperativa"
     "-"
     crapcop.nmrescop         NO-LABEL
                     HELP "Informe o nome resumido da Cooperativa."
     crapcop.nrdocnpj  AT 52
                     HELP "Informe o CNPJ da Cooperativa."
                     VALIDATE(INPUT crapcop.nrdocnpj <> "",
                                    "CNPJ deve ser informado.")
     SKIP
     crapcop.nmextcop  AT  2  LABEL "Nome extenso"
                     HELP "Informe o nome completo da Cooperativa."
     SKIP
     crapcop.dtcdcnpj  AT  5   LABEL "Data CNPJ"
             HELP "Informe a data de inscricao do CNPJ junto a Receita Federal"
     SKIP
     crapcop.dsendcop  AT  6  LABEL "Endereco"
                     HELP "Informe o endereco da Cooperativa."
     crapcop.nrendcop  AT 58
                     HELP "Informe o numero do endereco da Cooperativa."
     crapcop.dscomple  AT  3  
                     HELP "Informe o complemento do endereco da Cooperativa."
     crapcop.nmbairro  AT  8  
                     HELP "Informe o nome do bairro."
     crapcop.nrcepend  AT 61
                     LABEL "CEP"
                     HELP "Informe o CEP do endereco."
     crapcop.nmcidade  AT  8
                     HELP "Informe o nome da cidade."
     crapcop.cdufdcop  AT 62
                     LABEL "UF"
                     HELP "Informe a sigla do Estado."
                     VALIDATE(INPUT crapcop.cdufdcop <> "",
                                    "Unidade de federacao deve ser informado.")
     crapcop.nrcxapst  AT  2
                     LABEL "Caixa postal"
                     HELP "Informe o numero da caixa postal."
     SKIP(1)
     crapcop.nrtelvoz  AT  6  
                     LABEL "Telefone"
               HELP "Informe o numero do telefone da Cooperativa. (xx)xxxx-xxxx"
                     VALIDATE(INPUT crapcop.nrtelvoz <> "",
                                    "Telefone deve ser informado.")
        
     crapcop.nrtelouv AT 45
                     LABEL "Ouvidoria"
                     FORMAT "x(20)"
                     HELP "Informe o numero da Ouvidoria da Cooperativa."
     crapcop.dsendweb  AT 10  
                     LABEL "Site" 
                     FORMAT "x(34)"
                     HELP "Informe o endereco do site da Cooperativa."
     crapcop.nrtelura  AT 51  
                     LABEL "URA"
                     HELP "Informe o numero da URA da Cooperativa."  
     crapcop.dsdemail  AT  8   FORMAT "x(34)"
                     HELP "Informe o e-mail da Coopertativa."
     crapcop.nrtelfax  AT 51  
                     LABEL "FAX"
                     HELP "Informe o numero do FAX da Cooperativa."
     SKIP
     crapcop.dsdempst
                     LABEL "E-mail presidente"
                     HELP "Informe o e-mail do presidente da Cooperativa."
     
     
     crapcop.nrtelsac
                     LABEL "SAC"
                     HELP "Telefone do SAC da Cooperativa."

     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop1.
     
FORM crapcop.nmtitcop  AT  2  
                     LABEL "Presidente da Cooperativa"
                     HELP "Informe o nome do presidente da Cooperativa."
     crapcop.nrcpftit  AT 10
                     LABEL "CPF do Presidente"
                     HELP "Informe o CPF do presidente da Cooperativa."
                     VALIDATE(INPUT crapcop.nrcpftit <> "",
                                    "CPF do presidente deve ser informado.")
     SKIP(1)
     crapcop.nmctrcop  AT  8
                     LABEL "Nome do contador"
                     HELP "Informe o nome do contador da Cooperativa."
     crapcop.nrcpfctr  AT  9
                     LABEL "CPF do contador"
                     HELP "Informe o CPF do contador da Cooperativa."
                     VALIDATE(INPUT crapcop.nrcpfctr <> "",
                                    "CPF do contador deve ser informado.")
     crapcop.nrcrcctr  AT 41  LABEL "CRC"
                     HELP "Informe o CRC do contador da Cooperativa."
     aux_dsemlctr      AT  6 
                     LABEL "E-mail do contador"
                     HELP "Informe o e-mail do contador da Cooperativa."
     crapcop.nrrjunta  AT  7
                     HELP "Informe o numero do registro na Junta Comercial."
     crapcop.dtrjunta  AT 45
                     LABEL "Data do registro"
                     HELP "Informe a data do registro na Junta Comercial."
     SKIP
     crapcop.nrinsest  AT 10  LABEL "Inscr.Estadual"
                     HELP "Informe o numero da Inscricao Estadual."
     SKIP
     crapcop.nrinsmun  AT  9  LABEL "Inscr.Municipal"
                     HELP "Informe o numero da Inscricao Municipal."
     SKIP(1)
     crapcop.nrlivapl  AT  5  LABEL "Livro de aplicacoes"
                     HELP "Informe o numero do livro de aplicacoes."
     crapcop.nrlivcap  AT 45  LABEL "Livro de capital"
                     HELP "Informe o numero do livro de capital."
     crapcop.nrlivdpv  AT  6  LABEL "Livro Dep. a vista"
                     HELP "Informe o numero do livro para depositos a vista."
     crapcop.nrlivepr  AT 41  LABEL "Livro de emprestimos"
                     HELP "Informe o numero do livro de emprestimos."
     SKIP(1)
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop2.
     
FORM crapcop.cdbcoctl  AT  5  LABEL "Cod.COMPE Cecred" FORMAT "999"
        HELP "Informe o codigo da COMPE Cecred onde a coop. e filiada."
     tel_cdagectl      AT 44 FORMAT "9999" LABEL "Coop.COMPE Cecred"
        HELP "Informe o codigo de agencia da Compe Cecred."
        SPACE(0) "-"   AT 67 SPACE(0)
     aux_cddigage      AT 68 NO-LABEL FORMAT "9"
     SKIP
     crapcop.flgdsirc  AT 17 LABEL "SIRC"  FORMAT "CAPITAL/INTERIOR"
                     HELP "Informe a localizacao do SIRC (CAPITAL/INTERIOR)."
     tel_flgopstr      AT 04 LABEL "Opera com SPB-STR"
     hor_iniopstr      AT 40 LABEL "Horario"         
     ":"               AT 51
     min_iniopstr      AT 52 NO-LABEL   
     "ate"             AT 55 
     hor_fimopstr      AT 59 NO-LABEL
     ":"               AT 61
     min_fimopstr      AT 62 NO-LABEL

     tel_flgoppag      AT 04 LABEL "Opera com SPB-PAG"
     hor_inioppag      AT 40 LABEL "Horario"
     ":"               AT 51
     min_inioppag      AT 52 NO-LABEL
     "ate"             AT 55
     hor_fimoppag      AT 59 NO-LABEL
     ":"               AT 61
     min_fimoppag      AT 62 NO-LABEL

     tel_flgvrbol      AT 02 LABEL "Pagamento VR-Boleto" FORMAT "SIM/NAO"
     tel_hhvrbini      AT 40 LABEL "Horario" FORMAT "99"
                       HELP "Informe horário limite para pag. VR-Boletos (00:00 ate 17:00)."
                       VALIDATE(INTEGER(tel_hhvrbini) <= 17,"Hora incorreta (00h ate 17h).")
     ":"               AT 51
     tel_mmvrbini      AT 52 NO-LABEL FORMAT "99"
                       HELP "Informe horário limite para pag. VR-Boletos (00:00 ate 17:00)."
                       VALIDATE(INTEGER(tel_mmvrbini) <= 59,"Minutos incorretos (00 min ate 59 min).")
     "ate"             AT 55
     tel_hhvrbfim      AT 59 NO-LABEL FORMAT "99"
                       HELP "Informe horário limite para pag. VR-Boletos (00:00 ate 17:00)."
                       VALIDATE(INTEGER(tel_hhvrbfim) <= 17,"Hora incorreta (00h ate 17h).") 
     ":"               AT 61
     tel_mmvrbfim      AT 62 NO-LABEL FORMAT "99"
                       HELP "Informe horário limite para pag. VR-Boletos (00:00 ate 17:00)."
                       VALIDATE(INTEGER(tel_mmvrbfim) <= 59,"Minutos incorretos (00 min ate 59 min).")

     crapcop.cdagebcb  AT  6
                     HELP "Informe o numero da agencia Bancoob."
     crapcop.cdagedbb  AT 50
              HELP "Informe o numero da agencia BB onde esta a conta convenio."
     SKIP
     crapcop.cdageitg  AT 14
            HELP "Informe a agencia responsavel pela conta ITG da Cooperativa."
     crapcop.cdcnvitg  AT 52
            HELP "Informe o numero do convenio da conta ITG da Cooperativa." 
     SKIP
     crapcop.cdmasitg  AT  6
                     HELP "Informe o codigo massificado da conta de integracao."
     crapcop.dssigaut  AT 39
                     HELP "Informe a sigla na autenticacao."
     SKIP
     crapcop.nrctabbd  AT  4 LABEL "Conta convenio BB"
                     HELP "Informe o numero da conta BB(DOC)."
     crapcop.nrctactl  AT 45 
                     HELP "Informe o numero da conta na CECRED."
     crapcop.nrctaitg  AT  5 LABEL "Conta integracao"
                     HELP "Conta de integracao da Cooperativa."
     crapcop.nrctadbb  AT 40 LABEL "Conta convenio no BB"
                     HELP "Informe o numero da conta convenio no BB."
     crapcop.nrctacmp  AT  2 LABEL "Conta Compe. CECRED" 
            HELP "Informe o numero da conta movimento da compensacao na CECRED"
     crapcop.nrdconta  AT 52 LABEL "Conta/dv"
     SKIP 
     crapcop.flgcrmag  AT  5 LABEL "Cartao magnetico"
          HELP "Informe 'S' se utiliza cartao magnetico ou 'N' se nao utiliza."
     crapcop.qtdiaenl  AT 53 LABEL "Dep.TAA"
          HELP "Informe Qtd. de dias para verificacao de depositos TAA (SUMLOT)." 
     SKIP
     crapcop.cdsinfmg  AT 3 LABEL "Inf.Chegada Cartao"
          HELP "Informe opcao (0-Nao emite, 1-So na chegada, 2-Ate a retirada)"
          VALIDATE(CAN-DO("0,1,2",crapcop.cdsinfmg), "014 - Opcao errada.")
     tel_cdsinfmg NO-LABEL
     crapcop.taamaxer  AT 42 LABEL "Max.Tentativas TAA"
          HELP "Informe Qtd. Max. de tentivas da senha no TAA."
          WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop3.

FORM crapcop.flgcmtlc AT 10 LABEL "Possui Comite Local" FORMAT "SIM/NAO"
             HELP "Informe se a cooperativa possui comite de credito local."
     SKIP
     crapcop.vllimapv AT 04 LABEL "Valor Limite Alcada Geral"
             FORMAT "zzz,zzz,zzz,zz9.99"
             HELP "Informe o valor para o limite alcada geral."
     SKIP(1)
     crapcop.cdcrdarr AT 10 LABEL "Creden.Arrecadacoes"
             HELP "Numero do CAR (codigo de arrecadacao) p/ pagamento do GPS."
     crapcop.cdagsede AT 20 LABEL "Sede INSS"
             HELP "Informe o numero do PA considerado sede para o INSS."
     SKIP(1)
     crapcop.vlmaxcen AT 12 LABEL "Valor Max.Central"
             HELP " "
     crapcop.vlmaxleg AT 14 LABEL "Valor Max.Legal"
         HELP "Informe o valor maximo legal a ser emprestado pela Cooperativa."
     SKIP
     crapcop.vlmaxutl AT 10 LABEL "Valor Max.Utilizado"
         FORMAT "zzz,zzz,zzz,zz9.99"
         HELP "Informe o valor max. que pode ser emprestado p/ cada cooperado."
     SKIP
     crapcop.vlcnsscr AT 11 LABEL "Valor consulta SCR"  
                      HELP "Informe o valor para consulta SCR."
     SKIP
     crapcop.vllimmes AT 03 LABEL "Limite Disp. p/ Emprestimo"  
                      HELP "Informe o valor limite disponivel para emprestimo no mes."
     SKIP
     tel_nrctabol     AT 06 LABEL "Conta Coope Ems. Boleto"
             HELP "Informe a conta da cooperativa para emissao de boletos." 
     tel_cdlcrbol     AT 04 LABEL "Linha Credito Ems. Boleto" 
             HELP "Informe a linha de credito para emissao de boletos."
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop4.
 
 FORM SKIP
     "CLAUSULA DO CONTRATO C/C E C/I:"                               AT 02
     tel_dsclactr[01]        NO-LABEL   FORMAT "x(42)"               AT 34
     SKIP
     tel_dsclactr[02]        NO-LABEL   FORMAT "x(74)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclactr[03]        NO-LABEL   FORMAT "x(74)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclactr[04]        NO-LABEL   FORMAT "x(74)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclactr[05]        NO-LABEL   FORMAT "x(74)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclactr[06]        NO-LABEL   FORMAT "x(74)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP(7)   
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop5.

 FORM SKIP
     "TERMO ADESAO AOS SERVICOS DE COBRANCA BANCARIA:"               AT 02
     tel_dsclaccb[01]        NO-LABEL   FORMAT "x(15)"               AT 55
     SKIP
     tel_dsclaccb[02]        NO-LABEL   FORMAT "x(68)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclaccb[03]        NO-LABEL   FORMAT "x(68)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclaccb[04]        NO-LABEL   FORMAT "x(68)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclaccb[05]        NO-LABEL   FORMAT "x(68)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP
     tel_dsclaccb[06]        NO-LABEL   FORMAT "x(68)"               AT 02
                             HELP "Pressione <END> para finalizar"
     SKIP(7)   
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop6.


FORM crapcop.dsdircop  AT  2
                     HELP "Informe o diretorio da Cooperativa."   
     crapcop.nmdireto  AT  2  FORMAT "x(55)"
                     HELP "Informe o diretorio padrao de arquivos texto."
     crapcop.flgdopgd  AT  2
                     HELP "Informe se a cooperativa participa do Progrid."
     SKIP                
     "-- Verificacao do Processo --" AT 27
     SKIP (1)
     SPACE(1) tel_horproce AUTO-RETURN LABEL "Hora Ini" 
     HELP "Informe a hora inicial do comprovante"
     VALIDATE(tel_horproce < 24, "Horas estao incorretas.") 
     ":"  AT 14        
     tel_minproce AT 15 NO-LABEL AUTO-RETURN 
     HELP "Informe o(s) minuto(s) do comprovante" 
     VALIDATE(tel_minproce < 60, "Minutos estao incorretos.")
     ":" AT 17 
     tel_segproce AT 18 NO-LABEL AUTO-RETURN  
     HELP "Informe o(s) segundo(s) do comprovante"
     VALIDATE(tel_segproce < 60, "Segundos estao incorretos.")
     
     tel_hrfinprc AT 25  AUTO-RETURN LABEL "Hora Fin" 
     HELP "Informe a hora final do comprovante"
     VALIDATE(tel_hrfinprc < 24, "Horas estao incorretas.") 
     ":"  AT 37 
     tel_mnfinprc AT 38 NO-LABEL AUTO-RETURN 
     HELP "Informe o(s) minuto(s) do comprovante" 
     VALIDATE(tel_mnfinprc < 60, "Minutos estao incorretos.")
     ":" AT 40 
     tel_sgfinprc AT 41 NO-LABEL AUTO-RETURN  
     HELP "Informe o(s) segundo(s) do comprovante"
     VALIDATE(tel_sgfinprc < 60, "Segundos estao incorretos.")
     crapcop.dsnotifi[1] LABEL "Nota" FORMAT "x(68)"  AT 2
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     crapcop.dsnotifi[2] NO-LABEL     FORMAT "x(68)"  AT 8
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     crapcop.dsnotifi[3] NO-LABEL     FORMAT "x(68)"  AT 8
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     crapcop.dsnotifi[4] NO-LABEL     FORMAT "x(68)"  AT 8
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     crapcop.dsnotifi[5] NO-LABEL     FORMAT "x(68)"  AT 8
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     crapcop.dsnotifi[6] NO-LABEL     FORMAT "x(68)"  AT 8
           HELP "Informe o texto de notificacao para o responsavel pelo proc."
     SKIP(1)
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop7.

FORM SKIP
     "--- COBAN ---"   AT 31
     SKIP(1)
     tel_nrconven  FORMAT "999999999"     LABEL "Convenio"        AT 27
                   HELP "Informe o numero do convenio."
         tel_nrversao  FORMAT "999"           LABEL "Versao"          AT 50
                   HELP "Informe a versao do software."
     tel_vldataxa  FORMAT "999.99"        LABEL "Tarifa Pagto."   AT 22
                   HELP "Informe a tarifa de pagamento."
     tel_vltxinss  FORMAT "999.99"        LABEL "Tarifa INSS"     AT 24
                   HELP "Informe a tarifa de recebimento de INSS."
     crapcop.flgargps  FORMAT "SIM/NAO"       LABEL "Arrecada GPS"    AT 23
                       HELP "Informe a arrecadacao do GPS"
     
     SKIP(1)
     "-- DDA --"   AT 33
     SKIP(1)
     crapcop.dtctrdda LABEL "Data do Contrato"                   AT 11
                   HELP "Informe a data do contrato."
     crapcop.nrctrdda LABEL "Nr."                                AT 47
                   HELP "Informe o numero do contrato."
     crapcop.idlivdda LABEL "Livro"                              AT 22
                   HELP "Informe o numero do livro."
     crapcop.nrfoldda LABEL "Folha"                              AT 45
                   HELP "Informe o numero da folha."
     crapcop.dslocdda LABEL "Local do Registro"                  AT 10
                   HELP "Informe o local do registro."
     crapcop.dsciddda LABEL "Cidade"                             AT 21
                   HELP "Informe o nome da cidade."
     WITH ROW 6 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop8.

FORM SKIP
     "-- COBRANCA REGISTRADA --" AT 25
     SKIP(1)
     crapcop.dtregcob LABEL "Data do Contrato"                   AT 11
                   HELP "Informe a data do contrato."
     crapcop.idregcob LABEL "Nr."                                AT 47
                   HELP "Informe o numero do contrato."
     crapcop.idlivcob LABEL "Livro"                              AT 22
                   HELP "Informe o numero do livro."
     crapcop.nrfolcob LABEL "Folha"                              AT 45
                   HELP "Informe o numero da folha."
     crapcop.dsloccob LABEL "Local do Registro"                  AT 10
                   HELP "Informe o local do registro."
     crapcop.dscidcob LABEL "Cidade"                             AT 21
                   HELP "Informe o nome da cidade."
     SKIP(1)
     "-- CENTRAL DE RISCO --"   AT 25
     SKIP(1)
     crapcop.dsnomscr LABEL "Nome do Responsavel"                AT 11
                   HELP "Informe o nome do responsavel."
                   VALIDATE(crapcop.dsnomscr <> "",  
                            "357 - O campo deve ser preenchido.")
     crapcop.dsemascr LABEL "E-mail do Responsavel"              AT 9
                   HELP "Informe o e-mail do responsavel."
                   VALIDATE(crapcop.dsemascr <> "",  
                            "357 - O campo deve ser preenchido.")
     crapcop.dstelscr LABEL "Telefone do Responsavel"            AT 7
                   HELP "Informe o telefone do responsavel."
                   VALIDATE(crapcop.dstelscr <> "", 
                             "357 - O campo deve ser preenchido.")
     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop9.

FORM SKIP
     "-- SICREDI --" AT 33 
     SKIP(1)
     crapcop.cdagesic LABEL "Agencia Sicredi"                   AT 21
                      HELP "Informe a agencia Sicredi."
     crapcop.nrctasic LABEL "Conta Sicredi"                     AT 23
                      HELP "Informe a conta Sicredi."
     crapcop.cdcrdins LABEL "Creden. Arrecadacoes"              AT 16
                      FORMAT ">>>>>>>9"
                      HELP "Informe a credencial dos arrecadadores."
     crapcop.vltarsic LABEL "Tarifa INSS"                       AT 25
                      FORMAT "9.99"
                      HELP "Entre com o valor da tarifa do INSS."
     crapcop.vltardrf LABEL "Tarifa Tributo Federal"            AT 14
                      FORMAT "9.99"
                      HELP "Entre com o valor da tarifa de Tributo Federal."
    /*GPS*/

     tel_vltfcxsb    LABEL "Tarifa GPS Caixa Sem Cod.Barras"        AT 05
                      FORMAT "9.99"
                      HELP "Entre com o valor da tarifa de GPS sem Cod.Barras."
     
    tel_vltfcxcb     LABEL "Tarifa GPS Caixa Com Cod.Barras"       AT 05
                      FORMAT "9.99"
                      HELP "Entre com o valor da tarifa de GPS com Cod.Barras."
     
    tel_vlrtrfib     LABEL "Tarifa GPS Internet Banking"            AT 9
                      FORMAT "9.99"
                      HELP "Entre com o valor da tarifa de GPS Internet Banking."
    /*GPS*/

 
      hor_inipggps     LABEL "Horario Pagamento GPS"             AT 15
                      HELP "Entre com a hora de inicio para pagamento de GPS."
                      VALIDATE(INPUT hor_inipggps >= 0 AND 
                               INPUT hor_inipggps < 23,
                               "O intervalo em horas deve estar entre 0 e 23.")
     ":"                                                        AT 40
     min_inipggps     NO-LABEL                                  AT 41
                      HELP "Entre com a hora de inicio para pagamento de GPS."
                      VALIDATE(INPUT min_inipggps >= 0 AND 
                               INPUT min_inipggps < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.")
     "as"                                                       AT 44
     hor_fimpggps     NO-LABEL                                  AT 47
                      HELP "Entre com a hora de termino para pagamento de GPS."
                      VALIDATE(INPUT hor_fimpggps >= 0 AND 
                               INPUT hor_fimpggps < 25,
                               "O intervalo em horas deve estar entre 0 e 24.")
     ":"                                                        AT 49
     min_fimpggps     NO-LABEL                                  AT 50
                      HELP "Entre com a hora de termino para pagamento de GPS."
                      VALIDATE(INPUT min_fimpggps >= 0 AND 
                               INPUT min_fimpggps < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.") 
    SKIP 
    hor_limitsic      LABEL "Horário Limite Pagamento"          AT 12         
                      HELP "Entre com a hora limite de pagamento."
                      VALIDATE(INPUT hor_limitsic >= 0 AND 
                               INPUT hor_limitsic < 24,
                      "O intervalo em horas deve estar entre 0 e 23.") 
     ":"                                                        AT 40                                                      
     min_limitsic     NO-LABEL                                  AT 41
                      HELP "Entre com a hora limite de pagamento."
                      VALIDATE(INPUT min_limitsic >= 0 AND 
                               INPUT min_limitsic < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.")

     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop10.

FORM SKIP
     "-- SANGRIA DE CAIXA --" AT 28
     SKIP(1)
     hor_intersgr LABEL "Intervalo de Tempo"                    AT 10
           HELP "Informe o intervalo de tempo em horas para verificacao."
           VALIDATE(INPUT hor_intersgr >= 0 AND INPUT hor_intersgr < 25,
                      "O intervalo em horas deve estar entre 0 e 24.")
     ":"                                                        AT 32
     min_intersgr NO-LABEL                                      AT 33
           HELP "Informe o intervalo de tempo em minutos para verificacao."
           VALIDATE(INPUT min_intersgr >= 0 AND INPUT min_intersgr < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.")
     SKIP(1)
     "-- SERVICOS OFERTADOS --" AT 28
     SKIP(1)
     tel_flgkitbv LABEL "Oferece Kit Boas Vindas" AT 10 
     HELP "Cooperativa oferece kit de boas vindas na abertura da conta."
     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop11.


FORM SKIP
     "-- PLANO DE COTAS --" AT 28
     SKIP(1)
     crapcop.vlmiplco LABEL "Valor minimo para contratacao"      AT 14
           HELP "Informe o valor minimo para contratacao do plano de cotas."
     crapcop.vlmidbco LABEL "Valor minimo para debito de cotas"  AT 10
           HELP "Informe o valor minimo para debito de cotas."
     SKIP(2)
     "-- GRAVAMES --" AT 31
     SKIP(1)
     crapcop.cdfingrv LABEL "Codigo da financeira"               AT 23 
           HELP "Informe o codigo da financeira."
     crapcop.cdsubgrv LABEL "Subcodigo do usuario"               AT 23
           HELP "Informe o subcodigo do usuario."
     crapcop.cdloggrv LABEL "Login do usuario"                   AT 27
           HELP "Informe o Login do usuario."
     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop12.

FORM SKIP
     "-- DÉBITO FÁCIL --" AT 28
     
    SKIP(1)
    tel_qtdiasus LABEL "Prazo máximo para suspensao do débito (dias)"  AT 05
           HELP "Informe o Prazo máximo para suspensao do débito em dias."
     
     SKIP(1)
	 hor_inidebfa     LABEL "Horário para autorizaçao do débito"           AT 15
                      HELP "Entre com a hora de inicio para autorizaçao do débito."      
                      VALIDATE(INPUT hor_inidebfa >= 0 AND 
                               INPUT hor_inidebfa < 23,
                               "O intervalo em horas deve estar entre 0 e 23.")
     ":"                                                        AT 53
     min_inidebfa     NO-LABEL                                  AT 54
                      HELP "Entre com a hora de início para autorizaçao do débito."  
                      VALIDATE(INPUT min_inidebfa >= 0 AND 
                               INPUT min_inidebfa < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.")
     "as"                                                       AT 57
     hor_fimdebfa     NO-LABEL                                  AT 60
                      HELP "Entre com a hora de término para autorizaçao do débito."
                      VALIDATE(INPUT hor_fimdebfa >= 0 AND 
                               INPUT hor_fimdebfa < 25 AND hor_fimdebfa >= hor_inidebfa,
                               "O intervalo em horas deve estar entre 0 e 24 e maior ou igual que a hora inicial.")
     ":"                                                        AT 62
     min_fimdebfa     NO-LABEL                                  AT 63
                      HELP "Entre com a hora de término para autorizaçao do débito."
                      VALIDATE(INPUT min_fimdebfa >= 0 AND 
                               INPUT min_fimdebfa < 60,
                      "O intervalo em minutos deve estar entre 0 e 59.")
     
     SKIP(1)
	 tel_flgdebfa LABEL "Oferta pro ativa" AT 33 FORMAT "SIM/NAO"
     
     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop13.


FORM SKIP
     "-- SERASA --" AT 31
     SKIP(1)
     crapcop.cdcliser LABEL "Codigo na SERASA"               AT 23 
           HELP "Informe o codigo na SERASA."
     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop14.
     
FORM SKIP
     "-- TARIFA --" AT 32
     SKIP
     tel_flsaqpre LABEL "Saque Presencial" AT 22 FORMAT "Isentar/Nao isentar"
            HELP "I - Isentar / N - Nao isentar."
     SKIP(1)
     "-- SERVICOS COOPERATIVOS --" AT 26
     SKIP
     crapcop.permaxde LABEL "Percentual máximo de desconto manual" FORMAT "zz9.99" AT 2 
           HELP "Informe o percentual máximo de desconto manual."
     crapcop.qtmaxmes LABEL "Qtd. máxima meses de desconto"      AT 9
           HELP "Informe a quantidade máxima de meses de desconto."
     tel_flrecpct LABEL "Permitir reciprocidade"               AT 16 FORMAT "Sim/Nao"
           HELP "S - Permite / N - Nao Permite." 
     SKIP(1)
     "-- HORARIOS DE ATENDIMENTO --" AT 24
     SKIP(1)
     "SAC:"                AT 29 
     tel_hrinisac NO-LABEL AT 34 FORMAT "99"
        HELP "Informe horário inicial para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_hrinisac) <= 23,"Hora incorreta (00h ate 23h).")
     ":"                   AT 36
     tel_mminisac NO-LABEL AT 37 FORMAT "99"
        HELP "Informe horário inicial para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_mminisac) <= 59,"Minutos incorretos (00 min ate 59 min).")
     "as"                  AT 40 
     tel_hrfimsac NO-LABEL AT 43 FORMAT "99"
        HELP "Informe horário limite para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_hrfimsac) <= 23,"Hora incorreta (00h ate 23h).")
     ":"                   AT 45
     tel_mmfimsac NO-LABEL AT 46 FORMAT "99"
        HELP "Informe horário limite para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_mmfimsac) <= 59,"Minutos incorretos (00 min ate 59 min).")

     SKIP
     "OUVIDORIA:"          AT 23 
     tel_hriniouv NO-LABEL AT 34 FORMAT "99"
        HELP "Informe horário inicial para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_hriniouv) <= 23,"Hora incorreta (00h ate 23h).")
     ":"                   AT 36
     tel_mminiouv NO-LABEL AT 37 FORMAT "99"
        HELP "Informe horário inicial para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_mminiouv) <= 59,"Minutos incorretos (00 min ate 59 min).")
     "as"                  AT 40 
     tel_hrfimouv NO-LABEL AT 43 FORMAT "99"
        HELP "Informe horário limite para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_hrfimouv) <= 23,"Hora incorreta (00h ate 23h).")
     ":"                   AT 45
     tel_mmfimouv NO-LABEL AT 46 FORMAT "99"
        HELP "Informe horário limite para atendimento. (00:00 ate 23:59)."
        VALIDATE(INTEGER(tel_mmfimouv) <= 59,"Minutos incorretos (00 min ate 59 min).")

     WITH DOWN ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_coop15.


DEF QUERY q_cidades FOR w-crapmun.

DEF BROWSE b_cidades QUERY q_cidades DISPLAY
           w-crapmun.dscidade COLUMN-LABEL "Cidade"    FORMAT "x(30)"
           w-crapmun.cdestado COLUMN-LABEL "UF"        FORMAT "x(2)"
           WITH 3 DOWN WIDTH 35 CENTERED NO-BOX OVERLAY.
           
FORM SKIP(1)
     b_cidades HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP(1)    
     WITH ROW 9 WIDTH 40 CENTERED OVERLAY FRAME f_cidades.
     
FORM SKIP(10)
     reg_dsdopcao[1]  AT 20  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 38  NO-LABEL FORMAT "x(7)"     
     WITH ROW 7 COLUMN 8 WIDTH 65 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " CADASTRO DE MUNICIPIOS " FRAME f_cidades2.
     
FORM SKIP(1)
     "Municipio:" AT 2 tel_nmcidade
          HELP "Informe o nome do Municipio"
          VALIDATE(tel_nmcidade <> "",
                                "375 - O campo deve ser preenchido")
     "UF:" tel_cduflogr
                  HELP "Informe UF do municipio"
                  VALIDATE(tel_cduflogr <> "",
                                "375 - O campo deve ser preenchido")
     SKIP(1)
     WITH ROW 9 COLUMN 4 WIDTH 75 OVERLAY NO-LABEL FRAME f_inclusao.           


ON RETURN OF tel_nmcidade IN FRAME f_inclusao DO:
  ASSIGN  aux_qtuf = 0
          aux_nmuf = "".
  FOR EACH crapmun WHERE crapmun.dscidade = UPPER(INPUT tel_nmcidade) NO-LOCK:
     IF   crapmun.cdestado = aux_nmuf   THEN
          NEXT.
     aux_qtuf = aux_qtuf + 1.
     aux_nmuf = crapmun.cdestado.
  END. 
  IF   aux_qtuf = 1 THEN
       DO:
         ASSIGN tel_cduflogr = aux_nmuf.
         DISPLAY tel_cduflogr WITH FRAME f_inclusao.
       END.
  ELSE 
      IF   aux_qtuf = 0 THEN
           DO:
              BELL.
              MESSAGE "Municipio Inexistente!".
              PAUSE 3 NO-MESSAGE.
              RETURN NO-APPLY.
           END.
      ELSE   
           DO:
              ASSIGN  tel_cduflogr = ""
                      aux_nmuf = "".
              DISPLAY tel_cduflogr WITH FRAME f_inclusao.
           END.
END.

ON RETURN OF tel_cduflogr IN FRAME f_inclusao DO:

  FIND crapmun WHERE crapmun.dscidade = UPPER(INPUT tel_nmcidade) AND
                     crapmun.cdestado = UPPER(INPUT tel_cduflogr) NO-LOCK NO-ERROR.
     
    IF   NOT AVAILABLE crapmun THEN
           DO:
              BELL.
              MESSAGE "Municipio/UF Inexistente!".
              PAUSE 3 NO-MESSAGE.
              RETURN NO-APPLY.
           END.
END.

ON ANY-KEY OF b_cidades IN FRAME f_cidades DO:

       IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
            DO:
                reg_contador = reg_contador + 1.

                IF   reg_contador > 2   THEN
                     reg_contador = 1.
                     
                aux_cddopcao = reg_cddopcao[reg_contador].
            END.
       ELSE        
       IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
            DO:
                reg_contador = reg_contador - 1.

                IF   reg_contador < 1   THEN
                     reg_contador = 2.
                     
                aux_cddopcao = reg_cddopcao[reg_contador].
            END.
       ELSE
       IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
            DO:
               IF   AVAILABLE w-crapmun   THEN
                    DO:
                      ASSIGN aux_cidade = w-crapmun.cdcidade.
                             
                      /*Desmarca todas as linhas do browse para poder remarcar*/
                      b_cidades:DESELECT-ROWS(). 
                    END.
               ELSE
                  ASSIGN aux_cidade = 0. 
                    
               APPLY "GO".
            END.
       ELSE
       IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
       ELSE
        RETURN.                       
       /* Somente para marcar a opcao escolhida */
       CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_cidades2.
END.

ON LEAVE OF crapcop.cdsinfmg DO:

   ASSIGN aux_cdsinfmg  = INPUT crapcop.cdsinfmg.
   
   IF  aux_cdsinfmg = 0 THEN 
       tel_cdsinfmg = "- Nao Emite".
   ELSE 
   IF  aux_cdsinfmg = 1 THEN
       tel_cdsinfmg = "- Na Chegada".
   ELSE
   IF  aux_cdsinfmg = 2 THEN
       tel_cdsinfmg = "- Ate Retirar".
                      
   DISPLAY tel_cdsinfmg WITH FRAME f_coop3.
                      
END.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "C"
       aux_lsvalido = ", ,1,2,3,4,5,6,7,8,9,0," +
                      "RETURN,F4,F1,F8,F7,CURSOR-LEFT,CURSOR-RIGHT,END-ERROR," +
                      "BACKSPACE,DEL,DELETE,CURSOR-DOWN,CURSOR-UP," +
                      "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      HIDE MESSAGE.
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
     
      { includes/acesso.i }

      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:   
             RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADCOP"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_coop1.
                     HIDE FRAME f_coop2.
                     HIDE FRAME f_coop3.
                     HIDE FRAME f_coop4. 
                     HIDE FRAME f_coop5.
                     HIDE FRAME f_coop6. 
                     HIDE FRAME f_coop7.
                     HIDE FRAME f_coop8.
                     HIDE FRAME f_coop9.
                     HIDE FRAME f_coop10.
                     HIDE FRAME f_coop11.
                     HIDE FRAME f_coop12.
                     HIDE FRAME f_coop13.
                     HIDE FRAME f_coop14.
                     HIDE FRAME f_coop15.
                     RETURN.
                 END.
            ELSE     
                 NEXT.
        END.
        
   EMPTY TEMP-TABLE w-crapcop.
   
   IF   glb_cddopcao = "C"   THEN
        DO: 
            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                 NO-LOCK NO-ERROR.
            
            DO WHILE TRUE:
            
               /* Se pressionar ENTER no frame f_coop7, fechar TODOS FRAMES */
               IF   aux_fechando  THEN
                    DO:
                        ASSIGN aux_fechando = FALSE. 
                        LEAVE.
                    END.
               
               DISPLAY crapcop.cdcooper    crapcop.nmrescop    crapcop.nrdocnpj
                       crapcop.dtcdcnpj 
                       crapcop.nmextcop    crapcop.dsendcop    crapcop.nrendcop
                       crapcop.dscomple    crapcop.nmbairro    crapcop.nrcepend
                       crapcop.nmcidade    crapcop.cdufdcop    crapcop.nrcxapst
                       crapcop.nrtelvoz    crapcop.nrtelfax    crapcop.dsendweb
                       crapcop.dsdemail    crapcop.nrtelura    crapcop.nrtelouv
                       crapcop.nrtelsac
                       WITH FRAME f_coop1.
               
               MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
               
               WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.

               DO WHILE TRUE:          
               
                /* Se pressionar ENTER no frame f_coop7, fechar TODOS FRAMES */
                  IF   aux_fechando  THEN
                       LEAVE.
                  
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "USUARI"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "EMLCTBCOOP" AND
                                     craptab.tpregist = 0 NO-LOCK NO-ERROR.
                                     
                  IF  AVAIL craptab  THEN
                      aux_dsemlctr = craptab.dstextab.
                  ELSE
                      aux_dsemlctr = "".
                  
                  DISPLAY crapcop.nmtitcop    crapcop.nrcpftit
                          crapcop.nmctrcop    crapcop.nrcpfctr
                          aux_dsemlctr
                          crapcop.nrcrcctr    crapcop.dtrjunta
                          crapcop.nrrjunta    crapcop.nrinsest
                          crapcop.nrinsmun    crapcop.nrlivapl
                          crapcop.nrlivcap    crapcop.nrlivdpv
                          crapcop.nrlivepr    WITH FRAME f_coop2.
                
                  MESSAGE "Tecle <Enter> para continuar ou <End> para voltar".
                  
                  WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

                  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                       LEAVE.

                  /*** Mostra frame f_coop3 ***/
                  DO WHILE TRUE:     
                                       
                   /* Se ENTER no frame f_coop7, fechar TODOS FRAMES */
                   IF   aux_fechando  THEN
                        LEAVE.

                   /* Pagamento VR-Boleto */
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 00           AND
                                     craptab.cdacesso = "HRVRBOLETO" 
                                     NO-LOCK NO-ERROR.

                  IF  AVAILABLE craptab  THEN
                      ASSIGN tel_flgvrbol = LOGICAL(ENTRY(1,craptab.dstextab,";"))
                             aux_hrvrbini = STRING(INT(ENTRY(2,craptab.dstextab,";")),"HH:MM")
                             aux_hrvrbfim = STRING(INT(ENTRY(3,craptab.dstextab,";")),"HH:MM")
                             tel_hhvrbini = INTE(ENTRY(1, aux_hrvrbini, ":"))
                             tel_mmvrbini = INTE(ENTRY(2, aux_hrvrbini, ":"))
                             tel_hhvrbfim = INTE(ENTRY(1, aux_hrvrbfim, ":"))
                             tel_mmvrbfim = INTE(ENTRY(2, aux_hrvrbfim, ":")).
                                                                
                   IF  crapcop.cdsinfmg = 0 THEN
                       tel_cdsinfmg = "- Nao Emite".
                   ELSE 
                   IF  crapcop.cdsinfmg = 1 THEN
                       tel_cdsinfmg = "- Na Chegada".
                   ELSE
                   IF  crapcop.cdsinfmg = 2 THEN
                       tel_cdsinfmg = "- Ate Retirar".
                                     
                   ASSIGN hor_iniopstr = 
                            INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),1,2))
                          min_iniopstr = 
                            INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),4,2))
                          hor_fimopstr = 
                            INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),1,2))
                          min_fimopstr = 
                            INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),4,2))
                          hor_inioppag = 
                            INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),1,2))
                          min_inioppag = 
                            INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),4,2))
                          hor_fimoppag = 
                            INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),1,2))
                          min_fimoppag = 
                            INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),4,2))
                          tel_flgopstr = crapcop.flgopstr
                          tel_flgoppag = crapcop.flgoppag
                          tel_cdagectl = crapcop.cdagectl.

                   glb_nrcalcul = INTEGER(STRING(tel_cdagectl,"9999") + "0").
                   RUN fontes/digfun.p.
                   aux_cddigage = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                          LENGTH(STRING(glb_nrcalcul)),1)).

                   DISPLAY crapcop.cdbcoctl    tel_cdagectl
                           aux_cddigage 
                           tel_flgopstr        tel_flgoppag
                           hor_iniopstr        min_iniopstr
                           hor_fimopstr        min_fimopstr
                           hor_inioppag        min_inioppag
                           hor_fimoppag        min_fimoppag
                           crapcop.cdagebcb    crapcop.cdagedbb
                           crapcop.cdageitg    crapcop.cdcnvitg
                           crapcop.cdmasitg    crapcop.dssigaut
                           crapcop.nrctabbd    crapcop.nrctactl
                           crapcop.nrctaitg    crapcop.nrctadbb    
                           crapcop.nrctacmp    crapcop.nrdconta    
                           crapcop.flgdsirc    crapcop.flgcrmag
                           crapcop.qtdiaenl    crapcop.cdsinfmg    
                           tel_cdsinfmg        crapcop.taamaxer
                           tel_hhvrbfim        tel_hhvrbini
                           tel_mmvrbfim        tel_mmvrbfim
                           tel_flgvrbol        tel_mmvrbini
                           WITH FRAME f_coop3.
                    
                   MESSAGE "Tecle <Enter> para continuar ou <End> para voltar".
                     
                   WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                     
                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        LEAVE.
                     
                   /** Mostra frame f_coop4 **/
                   DO WHILE TRUE:   
                     
                     /* Se ENTER no frame f_coop7, fechar TODOS FRAMES */
                     IF   aux_fechando  THEN
                          LEAVE.
                     
                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                        craptab.nmsistem = "CRED"       AND
                                        craptab.tptabela = "GENERI"     AND
                                        craptab.cdempres = 00           AND
                                        craptab.cdacesso = "CTAEMISBOL" AND
                                        craptab.tpregist = 0 NO-LOCK NO-ERROR.
                                     
                     IF  AVAIL craptab  THEN
                         tel_nrctabol = INT(craptab.dstextab).
                     ELSE
                         tel_nrctabol = 0.

                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                        craptab.nmsistem = "CRED"       AND
                                        craptab.tptabela = "GENERI"     AND
                                        craptab.cdempres = 00           AND
                                        craptab.cdacesso = "LCREMISBOL" AND
                                        craptab.tpregist = 0 NO-LOCK NO-ERROR.
                     
                     IF   AVAIL craptab   THEN
                          tel_cdlcrbol = INT(craptab.dstextab).
                     ELSE
                          tel_cdlcrbol = 0.
                          
                     DISPLAY crapcop.flgcmtlc    crapcop.vllimapv
                             crapcop.vlmaxcen    crapcop.vlmaxleg    
                             crapcop.vlmaxutl    crapcop.cdcrdarr
                             crapcop.cdagsede    crapcop.vlcnsscr
                             crapcop.vllimmes
                             tel_nrctabol        tel_cdlcrbol
                             WITH FRAME f_coop4.
                     
                     MESSAGE 
                          "Tecle <Enter> para continuar ou <End> para voltar".
                     
                     WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                     
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                          LEAVE.
                     
                     /** Mostra frame f_coop5 **/
                     DO WHILE TRUE:    
                     
                        /*Se ENTER no frame f_coop7, fechar TODOS FRAMES*/
                        
                        IF   aux_fechando  THEN
                             LEAVE.

                        ASSIGN  tel_dsclactr[01] = crapcop.dsclactr[01]
                                tel_dsclactr[02] = crapcop.dsclactr[02]
                                tel_dsclactr[03] = crapcop.dsclactr[03]
                                tel_dsclactr[04] = crapcop.dsclactr[04]
                                tel_dsclactr[05] = crapcop.dsclactr[05]
                                tel_dsclactr[06] = crapcop.dsclactr[06].
                        
                        DISPLAY tel_dsclactr[1] tel_dsclactr[2] tel_dsclactr[3]
                                tel_dsclactr[4] tel_dsclactr[5] tel_dsclactr[6]
                                WITH FRAME f_coop5.
 
                        MESSAGE 
                            "Tecle <Enter> para continuar ou <End> para voltar".
                     
                        WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                     
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                             LEAVE.
                             
                        DO WHILE TRUE:
                     
                           /*Se pressionar ENTER no frame f_coop7, 
                             fechar TODOS FRAMES*/
                        
                           IF   aux_fechando  THEN
                                LEAVE.

                           ASSIGN  tel_dsclaccb[01] = crapcop.dsclaccb[01]
                                   tel_dsclaccb[02] = crapcop.dsclaccb[02]
                                   tel_dsclaccb[03] = crapcop.dsclaccb[03]
                                   tel_dsclaccb[04] = crapcop.dsclaccb[04]
                                   tel_dsclaccb[05] = crapcop.dsclaccb[05]
                                   tel_dsclaccb[06] = crapcop.dsclaccb[06].
                           
                           DISPLAY 
                                tel_dsclaccb[1] tel_dsclaccb[2] tel_dsclaccb[3]
                                tel_dsclaccb[4] tel_dsclaccb[5] tel_dsclaccb[6]
                                WITH FRAME f_coop6.
 
                           MESSAGE 
                            "Tecle <Enter> para continuar ou <End> para voltar".
                     
                           WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                     
                           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                LEAVE.
 
                           /** Horario inicial para verificar processo **/
                           tel_horproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                            "HH:MM:SS"),1,2)).
                           tel_minproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                            "HH:MM:SS"),4,2)). 
                           tel_segproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                            "HH:MM:SS"),7,2)).
                           
                           /** Horario final para verificar processo **/       
                           tel_hrfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                            "HH:MM:SS"),1,2)).
                           tel_mnfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                            "HH:MM:SS"),4,2)).
                           tel_sgfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                            "HH:MM:SS"),7,2)).
                                                                               
                           DO WHILE TRUE:               
                              
                              IF   aux_fechando  THEN
                                   LEAVE.
                              
                              DISP crapcop.dsdircop 
                                   crapcop.nmdireto
                                   crapcop.flgdopgd
                                   tel_horproce
                                   tel_minproce
                                   tel_segproce
                                   tel_hrfinprc
                                   tel_mnfinprc
                                   tel_sgfinprc
                                   crapcop.dsnotifi[1]
                                   crapcop.dsnotifi[2]
                                   crapcop.dsnotifi[3]
                                   crapcop.dsnotifi[4]
                                   crapcop.dsnotifi[5]
                                   crapcop.dsnotifi[6]
                                   WITH FRAME f_coop7.
                          
                              MESSAGE "Tecle <Enter> para continuar" 
                                      "ou <End> para voltar".
                           
                              WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                          
                              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                   LEAVE.

                              DO WHILE TRUE:

                                 IF aux_fechando THEN
                                    LEAVE.
               
                                 FIND craptab WHERE
                                      craptab.cdcooper = glb_cdcooper     AND
                                      craptab.nmsistem = "CRED"           AND
                                      craptab.tptabela = "USUARI"         AND
                                      craptab.cdempres = 11               AND
                                      craptab.cdacesso = "CORRESPOND"     AND
                                      craptab.tpregist = 000 NO-LOCK NO-ERROR.
                                      
                                 IF  AVAIL craptab  THEN
                                     ASSIGN
                                     tel_nrconven = INT(SUBSTR(craptab.dstextab,
                                                           1,9))
                                     tel_nrversao = INT(SUBSTR(craptab.dstextab,
                                                           11,3))
                                     tel_vldataxa = DEC(SUBSTR(craptab.dstextab,
                                                           15,6))
                                     tel_vltxinss = DEC(SUBSTR(craptab.dstextab,
                                                           22,6)).
                                
                                 DISPLAY tel_nrconven tel_nrversao 
                                         tel_vldataxa tel_vltxinss crapcop.flgargps 
                                         crapcop.dtctrdda crapcop.nrctrdda
                                         crapcop.idlivdda crapcop.nrfoldda
                                         crapcop.dslocdda crapcop.dsciddda
                                         WITH FRAME f_coop8.
                
                                 MESSAGE "Tecle <Enter> para continuar" 
                                         "ou <End> para voltar".
                  
                                 WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

                                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                      LEAVE.

                                 DO WHILE TRUE:

                                     IF aux_fechando THEN
                                         LEAVE.

                                     DISP crapcop.dtregcob crapcop.idregcob
                                          crapcop.idlivcob crapcop.nrfolcob
                                          crapcop.dsloccob crapcop.dscidcob
                                          crapcop.dsnomscr crapcop.dsemascr
                                          crapcop.dstelscr
                                          WITH FRAME f_coop9.

                                     MESSAGE "Tecle <Enter> para continuar"
                                             "ou <End> para voltar".

                                     WAIT-FOR RETURN, 
                                                END-ERROR OF CURRENT-WINDOW.

                                     IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                        LEAVE.

                                     DO WHILE TRUE:

                                         IF aux_fechando THEN
                                             LEAVE.

                                         /* Tarifa GPS Caixa Sem Cod.Barras */
                                         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                            craptab.nmsistem = "CRED"       AND
                                                            craptab.tptabela = "GENERI"     AND
                                                            craptab.cdempres = 00           AND
                                                            craptab.cdacesso = "GPSCXASCOD" AND
                                                            craptab.tpregist = 0 
                                                            NO-LOCK NO-ERROR.
                                        
                                         IF  AVAILABLE craptab  THEN
                                         DO:
                                            ASSIGN tel_vltfcxsb = DEC(craptab.dstextab).
                                         END.
                                            
                                         /* Tarifa GPS Caixa Com Cod.Barras */
                                         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                            craptab.nmsistem = "CRED"       AND
                                                            craptab.tptabela = "GENERI"     AND
                                                            craptab.cdempres = 00           AND
                                                            craptab.cdacesso = "GPSCXACCOD" AND
                                                            craptab.tpregist = 0 
                                                            NO-LOCK NO-ERROR.
                                        
                                         IF  AVAILABLE craptab  THEN
                                         DO:
                                            ASSIGN tel_vltfcxcb = DEC(craptab.dstextab).
                                         END.


                                         /* Tarifa GPS Internet Banking */
                                         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                            craptab.nmsistem = "CRED"       AND
                                                            craptab.tptabela = "GENERI"     AND
                                                            craptab.cdempres = 00           AND
                                                            craptab.cdacesso = "GPSINTBANK" AND
                                                            craptab.tpregist = 0 
                                                            NO-LOCK NO-ERROR.
                                        
                                         IF  AVAILABLE craptab  THEN
                                         DO:
                                            ASSIGN tel_vlrtrfib = DEC(craptab.dstextab).
                                         END.


                                         ASSIGN hor_inipggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrinigps,"HH:MM"),1,2))

                                                min_inipggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrinigps,"HH:MM"),4,2))

                                                hor_fimpggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimgps,"HH:MM"),1,2))

                                                min_fimpggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimgps,"HH:MM"),4,2)).
                                                
                                                hor_limitsic = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrlimsic,"HH:MM"),1,2)).

                                                min_limitsic = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrlimsic,"HH:MM"),4,2)).

                                         DISP crapcop.cdagesic 
                                              crapcop.nrctasic
                                              crapcop.cdcrdins
                                              crapcop.vltarsic
                                              crapcop.vltardrf
                                              tel_vltfcxsb 
                                              tel_vltfcxcb
                                              tel_vlrtrfib
                                              hor_inipggps
                                              min_inipggps
                                              hor_fimpggps
                                              min_fimpggps
                                              hor_limitsic
                                              min_limitsic
                                              WITH FRAME f_coop10.
    
                                         MESSAGE "Tecle <Enter> para continuar"
                                                     "ou <End> para voltar". 
                                         
                                         WAIT-FOR RETURN, 
                                                   END-ERROR OF CURRENT-WINDOW.
                                         
                                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                            LEAVE.
    
                                         DO WHILE TRUE:

                                             IF aux_fechando THEN
                                                 LEAVE.

                                             ASSIGN hor_intersgr = 
                                                    INTE(SUBSTR(STRING(
                                                        crapcop.qttmpsgr,
                                                        "HH:MM"), 1, 2))
                                                    min_intersgr = 
                                                    INTE(SUBSTR(STRING(
                                                        crapcop.qttmpsgr,
                                                        "HH:MM"), 4, 2)).
                                                        
                                             ASSIGN tel_flgkitbv = crapcop.flgkitbv.
                                             DISP hor_intersgr
                                                  min_intersgr
                                                  tel_flgkitbv
                                                  WITH FRAME f_coop11.
    
                                             MESSAGE "Tecle <Enter> para continuar"
                                                     "ou <End> para voltar".
    
                                             WAIT-FOR RETURN, 
                                                   END-ERROR OF CURRENT-WINDOW.
    
                                             IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                 LEAVE.
                                             /* FORM DÉBITO FÁCIL*/
                                             DO WHILE TRUE:

                                         IF aux_fechando THEN
                                             LEAVE.

                                         ASSIGN hor_inidebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hriniatr,"HH:MM"),1,2))

                                                min_inidebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hriniatr,"HH:MM"),4,2))

                                                hor_fimdebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimatr,"HH:MM"),1,2))

                                                min_fimdebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimatr,"HH:MM"),4,2)).
											 
                                             tel_flgdebfa = crapcop.flgofatr.

                                             tel_qtdiasus = INTE(crapcop.qtdiasus).
											 
                                         DISP tel_qtdiasus
                                              hor_inidebfa
                                              min_inidebfa
                                              hor_fimdebfa
                                              min_fimdebfa
                                              tel_flgdebfa
                                              WITH FRAME f_coop13.
    
                                         MESSAGE "Tecle <Enter> para continuar"
                                                     "ou <End> para voltar". 
                                         
                                         WAIT-FOR RETURN, 
                                                   END-ERROR OF CURRENT-WINDOW.
                                         
                                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                            LEAVE.
                                             /* FIM FORM DÉBITO FÁCIL*/



                                             /* FORM CLIENTE SERASA */
                                             DO WHILE TRUE:

                                         IF aux_fechando THEN
                                             LEAVE.
											 
                                         DISP crapcop.cdcliser
                                              WITH FRAME f_coop14.
    
                                         MESSAGE "Tecle <Enter> para continuar"
                                                     "ou <End> para voltar". 
                                         
                                         WAIT-FOR RETURN, 
                                                   END-ERROR OF CURRENT-WINDOW.
                                         
                                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                            LEAVE.
                                             /* FIM FORM CLIENTE SERASA */

                                               /* FORM  DE COTAS / GRAVAMES */
                                              DO WHILE TRUE:

                                                 IF aux_fechando THEN
                                                    LEAVE.

                                                 DISP crapcop.vlmiplco
                                                      crapcop.vlmidbco
                                                      crapcop.cdfingrv
                                                      crapcop.cdsubgrv
                                                      crapcop.cdloggrv
                                                      WITH FRAME f_coop12.

                                                 MESSAGE "Tecle <Enter> para continuar"
                                                         "ou <End> para voltar".

                                                 WAIT-FOR RETURN,
                                                     END-ERROR OF CURRENT-WINDOW.

                                                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                     LEAVE.
                                                  /* FIM FORM  DE COTAS / GRAVAMES */

                                                  /* FORM TARIFA DE SAQUE */
                                                  DO WHILE TRUE:

                                                     IF aux_fechando THEN
                                                        LEAVE.
                                                     
                                                     ASSIGN tel_flsaqpre = crapcop.flsaqpre
                                                            /* HORARIOS SAC */
                                                            tel_hrinisac = INT(SUBSTR(STRING(crapcop.hrinisac,"HH:MM:SS"),1,2))
                                                            tel_mminisac = INT(SUBSTR(STRING(crapcop.hrinisac,"HH:MM:SS"),4,2)) 
                                                            tel_hrfimsac = INT(SUBSTR(STRING(crapcop.hrfimsac,"HH:MM:SS"),1,2))
                                                            tel_mmfimsac = INT(SUBSTR(STRING(crapcop.hrfimsac,"HH:MM:SS"),4,2)) 
                                                            /* HORARIOS OUVIDORIA */
                                                            tel_hriniouv = INT(SUBSTR(STRING(crapcop.hriniouv,"HH:MM:SS"),1,2))
                                                            tel_mminiouv = INT(SUBSTR(STRING(crapcop.hriniouv,"HH:MM:SS"),4,2)) 
                                                            tel_hrfimouv = INT(SUBSTR(STRING(crapcop.hrfimouv,"HH:MM:SS"),1,2))
                                                            tel_mmfimouv = INT(SUBSTR(STRING(crapcop.hrfimouv,"HH:MM:SS"),4,2))
															tel_flsaqpre = crapcop.flsaqpre
                                                            tel_flrecpct = crapcop.flrecpct.

                                                     DISP tel_flsaqpre
													      crapcop.permaxde
                                                          crapcop.qtmaxmes
                                                          tel_flrecpct 
                                                          tel_hrinisac tel_mminisac
                                                          tel_hrfimsac tel_mmfimsac
                                                          tel_hriniouv tel_mminiouv
                                                          tel_hrfimouv tel_mmfimouv
                                                          WITH FRAME f_coop15.

                                                 MESSAGE "Tecle <Enter> para encerrar"
                                                         "ou <End> para voltar".

                                                 WAIT-FOR RETURN,
                                                     END-ERROR OF CURRENT-WINDOW.

                                                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                     LEAVE.

                                                 IF KEYFUNCTION(LASTKEY) = "RETURN" THEN
                                                 DO:
                                                     ASSIGN aux_fechando = TRUE.
                                                     LEAVE.
                                                 END.
                                               end.
                                             END.
                                           END.
                                         END.
                                       END.
                                     END.
                                 END. 
                              END.      
                           END.
                        END. /***Fim f_coop6***/   
                     END.   /***Fim f_coop5***/  
                   END.  /*** Fim f_coop4 ***/
                  END.  /*** Fim f_coop3 ***/
               END.
            END.  
        END.
   ELSE 
   IF   glb_cddopcao = "M"   THEN 
        DO: 
          DISPLAY   reg_dsdopcao[1]
                    reg_dsdopcao[2]
             WITH FRAME f_cidades2. 
          
          ASSIGN aux_cddopcao = reg_cddopcao[reg_contador].
          DISPLAY reg_dsdopcao WITH FRAME f_cidades2.
          CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_cidades2.
               
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            EMPTY TEMP-TABLE w-crapmun.
            FOR EACH tbgen_cid_atuacao_coop WHERE tbgen_cid_atuacao_coop.cdcooper = glb_cdcooper,
                EACH crapmun WHERE tbgen_cid_atuacao_coop.cdcidade = crapmun.cdcidade NO-LOCK:
              CREATE w-crapmun.
              BUFFER-COPY crapmun TO w-crapmun.
            END.
            OPEN QUERY q_cidades FOR EACH w-crapmun NO-LOCK
                                          BY w-crapmun.dscidade.   
            UPDATE b_cidades WITH FRAME f_cidades.  
            VIEW FRAME f_cidades.
            IF   aux_cddopcao = "I"   THEN
                 DO:
                    ASSIGN   tel_cduflogr = "".
                    ASSIGN   tel_nmcidade = "".
                    UPDATE tel_nmcidade tel_cduflogr WITH FRAME f_inclusao.  
                    RUN Confirma.
                    IF   aux_confirma = "S"  THEN
                    DO TRANSACTION:
                       FIND crapmun WHERE crapmun.dscidade = UPPER(tel_nmcidade) AND
                                          crapmun.cdestado = UPPER(tel_cduflogr) NO-LOCK NO-ERROR.
                       IF   AVAILABLE crapmun then                       
                            DO:  
                              FIND tbgen_cid_atuacao_coop WHERE tbgen_cid_atuacao_coop.cdcidade = crapmun.cdcidade AND 
                                                                tbgen_cid_atuacao_coop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                            
                              IF   AVAILABLE tbgen_cid_atuacao_coop THEN
                                   DO:
                                      MESSAGE "Municipio ja cadastrado.".
                                      PAUSE 2 NO-MESSAGE.
                                   END.
                              ELSE 
                                   DO:
                                      CREATE tbgen_cid_atuacao_coop.
                                      ASSIGN tbgen_cid_atuacao_coop.cdcidade = crapmun.cdcidade
                                             tbgen_cid_atuacao_coop.cdcooper = glb_cdcooper.
                                      VALIDATE tbgen_cid_atuacao_coop. 
                                      MESSAGE "Municipio incluido com sucesso.".
                                      PAUSE 2 NO-MESSAGE.
                                   END.                       
                            END.
                       ELSE
                       MESSAGE "Municipio/UF nao cadastrado.".
                       PAUSE 2 NO-MESSAGE.
                    END.
                    HIDE FRAME f_inclusao.                    
                 END.
            ELSE
            DO TRANSACTION:
                RUN Confirma.
                IF   aux_confirma = "S"  THEN
                DO:                    
                  FIND tbgen_cid_atuacao_coop WHERE tbgen_cid_atuacao_coop.cdcidade = aux_cidade AND 
                                                    tbgen_cid_atuacao_coop.cdcooper = glb_cdcooper EXCLUSIVE-LOCK NO-ERROR.                
                  IF   AVAIL tbgen_cid_atuacao_coop  THEN
                  DO:
                       DELETE tbgen_cid_atuacao_coop.
                       RELEASE tbgen_cid_atuacao_coop. 
                       MESSAGE "Municipio excluido com sucesso.".
                       PAUSE 2 NO-MESSAGE.
                  END.
                END.
                
                
                
            END.
          END. /* End do-while*/
            
        END. /* End opcao M */   
   ELSE 
   IF   glb_cddopcao = "A"  THEN
        DO TRANSACTION ON ERROR UNDO, LEAVE:

           /* critica para permitir somente os seguintes operadores  */
           IF   glb_dsdepart <> "TI"                    AND
                glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
                glb_dsdepart <> "COMPE"                 AND
                glb_dsdepart <> "SUPORTE"               AND
                glb_dsdepart <> "COORD.PRODUTOS"        AND
                glb_dsdepart <> "CONTABILIDADE"         AND
                glb_dsdepart <> "CONTROLE"              AND
                glb_dsdepart <> "PRODUTOS"              AND 
                glb_dsdepart <> "CANAIS"                THEN
                DO:
                    glb_cdcritic = 36.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
           
           ASSIGN aux_fechando = FALSE.
           
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "GENERI"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "CTAEMISBOL" AND
                              craptab.tpregist = 0 NO-LOCK NO-ERROR.
                              
           IF   NOT AVAILABLE craptab   THEN
                ASSIGN tel_nrctabol = 0.
           ELSE
                ASSIGN tel_nrctabol = INT(craptab.dstextab)
                       aux_nrctabol = INT(craptab.dstextab).
                
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "GENERI"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "LCREMISBOL" AND
                              craptab.tpregist = 0 NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE craptab   THEN
                ASSIGN tel_cdlcrbol = 0.
           ELSE
                ASSIGN tel_cdlcrbol = INT(craptab.dstextab)
                       aux_cdlcrbol = INT(craptab.dstextab).
                  
           FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                EXCLUSIVE-LOCK NO-ERROR.
                
           CREATE w-crapcop.
           BUFFER-COPY crapcop TO w-crapcop.
           
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "USUARI"     AND
                              craptab.cdempres = 0            AND
                              craptab.cdacesso = "EMLCTBCOOP" AND
                              craptab.tpregist = 0 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                              
           IF  NOT AVAIL craptab  THEN
               DO:
                   IF  LOCKED(craptab) THEN
                       DO:
                           MESSAGE "Registro craptab esta em uso no momento." +
                                   " Tente novamente.".
                           UNDO, LEAVE.
                       END.

                    CREATE craptab.
                    ASSIGN craptab.cdcooper = glb_cdcooper 
                           craptab.nmsistem = "CRED"       
                           craptab.tptabela = "USUARI"     
                           craptab.cdempres = 0            
                           craptab.cdacesso = "EMLCTBCOOP" 
                           craptab.tpregist = 0.
                    VALIDATE craptab.

               END.
           
           ASSIGN aux_dsemlctr = craptab.dstextab
                  old_dsemlctr = aux_dsemlctr.
           
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
               
              /* Se Confirma = "S" - FECHA todos os frames */ 
              IF   aux_fechando  THEN
                   DO:
                       ASSIGN aux_fechando = FALSE. 
                       LEAVE.
                   END.
                    
              DISPLAY crapcop.cdcooper WITH FRAME f_coop1.
               
              UPDATE crapcop.nmrescop crapcop.nrdocnpj crapcop.nmextcop
                     crapcop.dtcdcnpj crapcop.dsendcop crapcop.nrendcop    
                     crapcop.dscomple crapcop.nmbairro crapcop.nrcepend    
                     crapcop.nmcidade crapcop.cdufdcop crapcop.nrcxapst    
                     crapcop.nrtelvoz crapcop.nrtelouv crapcop.dsendweb    
                     crapcop.nrtelura crapcop.dsdemail crapcop.nrtelfax
                     crapcop.dsdempst crapcop.nrtelsac   
                     WITH FRAME f_coop1
              EDITING:
      
                      READKEY.

                      HIDE MESSAGE NO-PAUSE.
                      
                      IF (FRAME-FIELD = "nmrescop" OR
                          FRAME-FIELD = "nmextcop" OR
                          FRAME-FIELD = "dsendcop" OR
                          FRAME-FIELD = "dscomple" OR
                          FRAME-FIELD = "nmcidade" OR
                          FRAME-FIELD = "nmbairro") AND
                          NOT CAN-DO(aux_lsvalido, KEYLABEL(LASTKEY))  THEN
                          DO:
                              MESSAGE "Caracteres especiais nao validos. " +
                                      "Apenas letras e numeros.".
                              NEXT.   
                          END.
           
                      APPLY LASTKEY.
                                   
              END.  /* Fim do EDITING */
              
              /* Gravar em maiusculo */ 
              ASSIGN crapcop.nmextcop = UPPER(crapcop.nmextcop)
                     crapcop.dsendcop = UPPER(crapcop.dsendcop)
                     crapcop.dscomple = UPPER(crapcop.dscomple)
                     crapcop.nmbairro = UPPER(crapcop.nmbairro)
                     crapcop.nmcidade = UPPER(crapcop.nmcidade).
              
              /* 
                  alterar/criar registro de DIMOF somente se alterado o CNPJ
                  no ano corrente, caso o registro ja existe e ainda nao 
                  tenha sido enviado ao BC altera a data de inicio do periodo
              */
              IF  w-crapcop.dtcdcnpj <> crapcop.dtcdcnpj      AND
                  YEAR(crapcop.dtcdcnpj) = YEAR(glb_dtmvtolt) THEN
                  DO:
                      FIND FIRST crapmof WHERE 
                                 crapmof.cdcooper = crapcop.cdcooper 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF  NOT AVAIL crapmof  THEN
                          DO:
                              IF  MONTH(crapcop.dtcdcnpj) > 6  THEN
                                  DO:
                                      /* Segundo semestre do ano */
                                      CREATE crapmof.
                                      ASSIGN crapmof.cdcooper = crapcop.cdcooper
                                             crapmof.dtiniper = 
                                               crapcop.dtcdcnpj
                                             crapmof.dtfimper = 
                                               DATE(12,31,YEAR(glb_dtmvtolt)) 
                                      /* 
                                      Calcula o ultimo dia util do mes 
                                      02 do ano novo, data limite
                                      para envio do arquivo do segundo 
                                      semestre do ano que se inicia
                                      */
                                             aux_dtcalcu2 = 
                                             DATE(02,01,YEAR(glb_dtmvtolt) + 1)
                                             aux_ultdiame = 
                                            ((DATE(MONTH(aux_dtcalcu2),
                                                   28,
                                                   YEAR(aux_dtcalcu2))
                                                   + 4) - 
                                                   DAY(DATE(MONTH(aux_dtcalcu2),
                                                            28,
                                                            YEAR(aux_dtcalcu2)) 
                                                            + 4)).

                                      DO WHILE TRUE:
                                         IF   CAN-DO("1,7",
                                              STRING(WEEKDAY(aux_ultdiame)))   
                                              OR
                                              CAN-FIND(crapfer WHERE 
                                              crapfer.cdcooper = glb_cdcooper  
                                              AND
                                              crapfer.dtferiad = aux_ultdiame) 
                                              THEN
                                         DO:
                                              aux_ultdiame = aux_ultdiame - 1.
                                              NEXT.
                                         END.
                                         LEAVE.
                                      END.  /*  Fim do DO WHILE TRUE  */
               
                                      ASSIGN crapmof.dtenvpbc = aux_ultdiame
                                      /* 
                                      Fim do calculo do ultima 
                                      dia util do mes 08 
                                      */
        
                                             crapmof.dtenvarq = ?
                                             crapmof.flgenvio = FALSE.
                                      VALIDATE crapmof.

                                  END.
                              ELSE
                                  DO:
                                      /* Primeiro semestre do ano */
                                      CREATE crapmof.
                                      ASSIGN crapmof.cdcooper = crapcop.cdcooper
                                             crapmof.dtiniper = crapcop.dtcdcnpj
                                             crapmof.dtfimper = 
                                               DATE(06,30,YEAR(glb_dtmvtolt)) 
                                      /* 
                                      Calcula o ultimo dia util do mes 08, 
                                      data limite para envio do arquivo
                                      */
                                             aux_dtcalcu2 =                    
                                              DATE(08,01,YEAR(glb_dtmvtolt))
                                             aux_ultdiame = 
                                            ((DATE(MONTH(aux_dtcalcu2),
                                                   28,
                                                   YEAR(aux_dtcalcu2))
                                                   + 4) - 
                                                   DAY(DATE(MONTH(aux_dtcalcu2),
                                                            28,
                                                            YEAR(aux_dtcalcu2))
                                                            + 4)).

                                      DO WHILE TRUE:
                                          IF  CAN-DO("1,7",
                                              STRING(WEEKDAY(aux_ultdiame)))
                                              OR
                                              CAN-FIND(crapfer WHERE 
                                              crapfer.cdcooper = glb_cdcooper
                                              AND
                                              crapfer.dtferiad = aux_ultdiame) 
                                              THEN
                                          DO:
                                              aux_ultdiame = aux_ultdiame - 1.
                                              NEXT.
                                          END.
                                          LEAVE.
                                      END.  /*  Fim do DO WHILE TRUE  */
               
                                      ASSIGN crapmof.dtenvpbc = aux_ultdiame
                                      /* 
                                      Fim do calculo do ultima 
                                      dia util do mes 08 
                                      */
                                             crapmof.dtenvarq = ?
                                             crapmof.flgenvio = FALSE.
                                      VALIDATE crapmof.

                                      /* Segundo semestre do ano */
                                      CREATE crapmof.
                                      ASSIGN crapmof.cdcooper = crapcop.cdcooper
                                             crapmof.dtiniper = 
                                               DATE(07,01,YEAR(glb_dtmvtolt))
                                             crapmof.dtfimper = 
                                               DATE(12,31,YEAR(glb_dtmvtolt)).
                                      /* 
                                      Calcula o ultimo dia util do mes 
                                      02 do ano novo, data limite
                                      para envio do arquivo do segundo 
                                      semestre do ano que se inicia
                                      */
                                      ASSIGN aux_dtcalcu2 = 
                                             DATE(02,01,YEAR(glb_dtmvtolt) + 1)
                                             aux_ultdiame = 
                                            ((DATE(MONTH(aux_dtcalcu2),
                                                   28,
                                                   YEAR(aux_dtcalcu2))
                                                   + 4) - 
                                                   DAY(DATE(MONTH(aux_dtcalcu2),
                                                            28,
                                                            YEAR(aux_dtcalcu2)) 
                                                            + 4)).

                                      DO WHILE TRUE:
                                         IF   CAN-DO("1,7",
                                              STRING(WEEKDAY(aux_ultdiame)))   
                                              OR
                                              CAN-FIND(crapfer WHERE 
                                              crapfer.cdcooper = glb_cdcooper  
                                              AND
                                              crapfer.dtferiad = aux_ultdiame) 
                                              THEN
                                         DO:
                                              aux_ultdiame = aux_ultdiame - 1.
                                              NEXT.
                                         END.
                                         LEAVE.
                                      END.  /*  Fim do DO WHILE TRUE  */
               
                                      ASSIGN crapmof.dtenvpbc = aux_ultdiame
                                      /* 
                                      Fim do calculo do ultima 
                                      dia util do mes 08 
                                      */
        
                                             crapmof.dtenvarq = ?
                                             crapmof.flgenvio = FALSE.
                                      VALIDATE crapmof.

                                  END.
                          END.
                      ELSE
                          DO:
                              /* 
                              se ainda nao foi enviado altera a data
                              de inicio do periodo para envio ao BC
                              */
                              IF  NOT crapmof.flgenvio  AND 
                                  crapmof.dtenvarq = ?  THEN
                                  ASSIGN crapmof.dtiniper = crapcop.dtcdcnpj.
                          END.
                      
                  END.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:          

                 /* Se Confirma = "S" - FECHA todos os frames */
                 IF   aux_fechando  THEN
                      LEAVE.
                 
                 UPDATE crapcop.nmtitcop    crapcop.nrcpftit
                        crapcop.nmctrcop    crapcop.nrcpfctr
                        crapcop.nrcrcctr    aux_dsemlctr
                        crapcop.nrrjunta
                        crapcop.dtrjunta    crapcop.nrinsest
                        crapcop.nrinsmun    crapcop.nrlivapl
                        crapcop.nrlivcap    crapcop.nrlivdpv
                        crapcop.nrlivepr    WITH FRAME f_coop2
                 EDITING:
      
                      READKEY.

                      HIDE MESSAGE NO-PAUSE.
                      
                      IF (FRAME-FIELD = "nmtitcop" OR
                          FRAME-FIELD = "nmctrcop") AND
                          NOT CAN-DO(aux_lsvalido, KEYLABEL(LASTKEY))  THEN
                          DO:
                              MESSAGE "Caracteres especiais nao validos. " +
                                      "Apenas letras e numeros.".
                              NEXT.   
                          END.
           
                      APPLY LASTKEY.
                                   
                 END.  /* Fim do EDITING */
                 
                 craptab.dstextab = aux_dsemlctr.
                 
                 /* Valor atual do Creden.Arrecadacoes - GPS-BANCOOB */
                 aux_cdcrdarr = crapcop.cdcrdarr.
                 
                 ASSIGN aux_retorna  = FALSE   /*retorno frame4 para frame3*/
                        aux_retorna2 = FALSE.  /*retorno frame3 para frame2*/ 
                 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   /*** Frame f_coop3 ***/
                     
                   /* Se Confirma = "S" - FECHA todos os frames */
                   IF   aux_fechando  THEN
                        LEAVE.

                   /* Pagamento VR-Boleto */
                   FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper AND
                                      crabtab.nmsistem = "CRED"       AND
                                      crabtab.tptabela = "GENERI"     AND
                                      crabtab.cdempres = 00           AND
                                      crabtab.cdacesso = "HRVRBOLETO" 
                                      NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE crabtab  THEN
                       ASSIGN tel_flgvrbol = LOGICAL(ENTRY(1,crabtab.dstextab,";"))
                              aux_hrvrbini = STRING(INT(ENTRY(2,crabtab.dstextab,";")),"HH:MM")
                              aux_hrvrbfim = STRING(INT(ENTRY(3,crabtab.dstextab,";")),"HH:MM")
                              tel_hhvrbini = INTE(ENTRY(1, aux_hrvrbini, ":"))
                              tel_mmvrbini = INTE(ENTRY(2, aux_hrvrbini, ":"))
                              tel_hhvrbfim = INTE(ENTRY(1, aux_hrvrbfim, ":"))
                              tel_mmvrbfim = INTE(ENTRY(2, aux_hrvrbfim, ":")).
                      
                   ASSIGN hor_iniopstr = 
                            INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),1,2))
                          min_iniopstr = 
                            INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),4,2))
                          hor_fimopstr = 
                            INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),1,2))
                          min_fimopstr = 
                            INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),4,2))
                          hor_inioppag = 
                            INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),1,2))
                          min_inioppag = 
                            INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),4,2))
                          hor_fimoppag = 
                            INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),1,2))
                          min_fimoppag = 
                            INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),4,2))
                          tel_flgopstr = crapcop.flgopstr
                          tel_flgoppag = crapcop.flgoppag
                          tel_cdagectl = crapcop.cdagectl.

                   IF  aux_cdsinfmg = 0 THEN 
                       tel_cdsinfmg = "- Nao Emite".
                   ELSE 
                   IF  aux_cdsinfmg = 1 THEN
                       tel_cdsinfmg = "- Na Chegada".
                   ELSE
                   IF  aux_cdsinfmg = 2 THEN
                       tel_cdsinfmg = "- Ate Retirar".

                   glb_nrcalcul = INTEGER(STRING(tel_cdagectl,"9999") + "0").
                   RUN fontes/digfun.p.
                   aux_cddigage = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                          LENGTH(STRING(glb_nrcalcul)),1)).

                   ASSIGN aux_cdagectl = crapcop.cdagectl.

                   DISPLAY tel_flgopstr        tel_flgoppag
                           hor_iniopstr        min_iniopstr
                           hor_fimopstr        min_fimopstr
                           hor_inioppag        min_inioppag
                           hor_fimoppag        min_fimoppag
                           crapcop.cdbcoctl    aux_cddigage
                           tel_cdagectl        crapcop.cdagebcb
                           crapcop.cdagedbb    crapcop.cdageitg
                           crapcop.cdcnvitg    crapcop.cdmasitg
                           crapcop.dssigaut    crapcop.nrctabbd
                           crapcop.nrctactl    crapcop.nrctaitg
                           crapcop.nrctadbb    crapcop.nrctacmp
                           crapcop.nrdconta    crapcop.flgdsirc    
                           crapcop.flgcrmag    crapcop.qtdiaenl
                           crapcop.cdsinfmg    tel_cdsinfmg
                           crapcop.taamaxer
                           tel_hhvrbfim        tel_hhvrbini
                           tel_mmvrbfim        tel_mmvrbfim
                           tel_flgvrbol        tel_mmvrbini
                           WITH FRAME f_coop3.

                   UPDATE crapcop.cdbcoctl WITH FRAME f_coop3.

                   UPDATE tel_cdagectl WITH FRAME f_coop3.

                   FIND FIRST bcrapcop NO-LOCK
                        WHERE bcrapcop.cdagectl  = INPUT tel_cdagectl
                          AND bcrapcop.cdcooper <> glb_cdcooper  NO-ERROR.
                   IF AVAIL bcrapcop THEN DO:
                       BELL.
                       MESSAGE "Coop.COMPE Cecred ja utilizada por outra " + 
                               "Cooperativa".
                       PAUSE 3 NO-MESSAGE.
                       NEXT.
                   END.

                   IF  INPUT tel_cdagectl <> aux_cdagectl THEN DO:
                       BELL.
                       MESSAGE "Favor verificar Agencia CECRED na tela CADPAC".
                       PAUSE 3 NO-MESSAGE.
                   END.

                   
                   UPDATE tel_hhvrbini tel_mmvrbini 
                          tel_hhvrbfim tel_mmvrbfim WITH FRAME f_coop3.


                   /* Pagamento VR-Boleto */
                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                      craptab.nmsistem = "CRED"       AND
                                      craptab.tptabela = "GENERI"     AND
                                      craptab.cdempres = 00           AND
                                      craptab.cdacesso = "HRVRBOLETO" 
                                      EXCLUSIVE-LOCK NO-ERROR.

                   /*Atualizar TAB com o horario do pagamento VR-Boleto*/
                   IF  AVAILABLE craptab  THEN
                       DO:
                          ASSIGN ENTRY(2,craptab.dstextab,";") = 
                                 STRING((tel_hhvrbini * 3600) + (tel_mmvrbini * 60))
                                 ENTRY(3,craptab.dstextab,";") = 
                                 STRING((tel_hhvrbfim * 3600) + (tel_mmvrbfim * 60)).
                       END.

                   ASSIGN crapcop.cdagectl = tel_cdagectl.
                   
                   UPDATE crapcop.cdagebcb WITH FRAME f_coop3.

                   IF   crapcop.cdagebcb <> 0   THEN
                        DO:
                           UPDATE crapcop.cdagedbb    crapcop.cdageitg
                                  crapcop.cdcnvitg    crapcop.cdmasitg
                                  crapcop.nrctabbd    crapcop.nrctactl
                                  crapcop.nrctaitg    crapcop.nrctadbb
                                  crapcop.nrctacmp    crapcop.nrdconta
                                  crapcop.flgdsirc    crapcop.flgcrmag
                                  WITH FRAME f_coop3.
                        END.
                   ELSE
                        DO:       
                           ASSIGN crapcop.flgcrmag = FALSE  
                                  crapcop.qtdiaenl = 0
                                  aux_cdsinfmg     = 0     
                                  tel_cdsinfmg     = "- Nao Emite"
                                  crapcop.taamaxer = 0.   
                           
                           DISPLAY crapcop.flgcrmag 
                                   crapcop.qtdiaenl
                                   tel_cdsinfmg 
                                   crapcop.taamaxer WITH FRAME f_coop3.
                                             
                           UPDATE crapcop.cdagedbb    crapcop.cdageitg
                                  crapcop.cdcnvitg    crapcop.cdmasitg
                                  crapcop.nrctabbd    crapcop.nrctactl
                                  crapcop.nrctaitg    crapcop.nrctadbb
                                  crapcop.nrctacmp    crapcop.nrdconta
                                  crapcop.flgdsirc
                                  WITH FRAME f_coop3.
                        END.           
                        
                   ASSIGN aux_cdsinfmg = crapcop.cdsinfmg.  

                   IF  crapcop.flgcrmag  THEN
                       UPDATE crapcop.qtdiaenl
                              crapcop.cdsinfmg 
                              crapcop.taamaxer WITH FRAME f_coop3.  
                   ELSE 
                       DO: 
                           ASSIGN crapcop.qtdiaenl = 0
                                  crapcop.cdsinfmg = 0
                                  tel_cdsinfmg     = "- Nao Emite"
                                  crapcop.taamaxer = 0. 

                           DISPLAY crapcop.qtdiaenl
                                   crapcop.cdsinfmg 
                                   tel_cdsinfmg
                                   crapcop.taamaxer
                                   WITH FRAME f_coop3.
                       END.
                                         
                   ASSIGN aux_retorna  = TRUE.
                          aux_retorna2 = FALSE.
                                            
                   PAUSE(0).

                   /***  Frame f_coop4  ***/                 
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                     
                    /* Se Confirma = "S" - FECHA todos os frames */
                    IF   aux_fechando  THEN
                         LEAVE.
                   
                    /** retorna para frame 2 **/ 
                    IF  aux_retorna2 = TRUE THEN 
                        LEAVE. 
                    
                    ASSIGN aux_retorna = FALSE   
                           aux_retorna2 = TRUE.
                             
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                                 
                      /** retorna para frame3 **/
                     IF  aux_retorna = TRUE THEN 
                         LEAVE. 
                     
                     /* Se Confirma = "S" - FECHA todos os frames */
                     IF  aux_fechando  THEN
                         LEAVE.

                     DISPLAY crapcop.flgcmtlc   crapcop.vllimapv
                             crapcop.cdcrdarr   crapcop.cdagsede
                             crapcop.vlmaxcen   crapcop.vlmaxleg
                             crapcop.vlmaxutl   crapcop.vlcnsscr  
                             crapcop.vllimmes
                             tel_nrctabol       tel_cdlcrbol
                             WITH FRAME f_coop4.
                     
                     UPDATE crapcop.flgcmtlc WITH FRAME f_coop4.
                     
                     IF  crapcop.flgcmtlc  THEN
                         DO:
                             ASSIGN crapcop.vllimapv = 0.
                             DISPLAY crapcop.vllimapv WITH FRAME f_coop4.
                         END.
                         
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                         UPDATE crapcop.vllimapv WHEN NOT crapcop.flgcmtlc   
                                crapcop.cdcrdarr    crapcop.cdagsede
                                crapcop.vlmaxcen    crapcop.vlmaxleg
                                crapcop.vlmaxutl    crapcop.vlcnsscr  
                                crapcop.vllimmes
                                tel_nrctabol        tel_cdlcrbol        
                                WITH FRAME f_coop4.
                         LEAVE.

                     END.

                     IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                         NEXT.

                     /* Se tiver sede do INSS cadastrada, eh obrigado ter
                        credenciamento para GPS-BANCOOB */
                     IF   crapcop.cdagsede <> 0   AND
                          crapcop.cdcrdarr  = 0   THEN
                          DO:
                             glb_cdcritic = 375.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             PAUSE 3 NO-MESSAGE.
                             glb_cdcritic = 0.               
                             NEXT-PROMPT crapcop.cdcrdarr WITH FRAME f_coop4.
                                                               
                             NEXT.
                          END.

                     /* Se informado o campo "Creden.Arrecadacoes", o campo
                       "Sede INSS" deve ser preenchido (nao pode ser = 0).
                        Caso nao informado o pac sede, GERA ERRO na importaçao
                        dos beneficios */
                     IF   crapcop.cdcrdarr <> 0   AND
                          crapcop.cdagsede  = 0   THEN
                          DO:
                             BELL.
                             MESSAGE "O campo Sede INSS deve ser preenchido.".
                             PAUSE 3 NO-MESSAGE.
                             glb_cdcritic = 0.               
                             NEXT-PROMPT crapcop.cdagsede WITH FRAME f_coop4.
                                                               
                             NEXT.
                          END.
                         
                     /* Se zerou ou informou o credenciamento, faz validacao */
                     IF  (aux_cdcrdarr     <> 0   AND
                          crapcop.cdcrdarr  = 0)        OR

                         (aux_cdcrdarr      = 0   AND
                          crapcop.cdcrdarr <> 0)        THEN
                          DO:
                             FIND FIRST craplgp
                                  WHERE craplgp.cdcooper = glb_cdcooper
                                    AND craplgp.dtmvtolt = glb_dtmvtolt
                                    AND craplgp.flgativo = TRUE
                                        NO-LOCK NO-ERROR.

                             IF   AVAILABLE craplgp   THEN
                                  DO:
                                      BELL.
                                      MESSAGE "Ja existem guias pagas hoje,"
                                              "impossivel alterar.".
                                      PAUSE 3 NO-MESSAGE.
                                      crapcop.cdcrdarr = aux_cdcrdarr.
                                      NEXT-PROMPT crapcop.cdcrdarr 
                                                  WITH FRAME f_coop4.
                                      NEXT.
                                  END.
                          END.
                    
                     /* Verificar se Conta Emis. Boleto e valida */
                     FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                        crapass.nrdconta = tel_nrctabol NO-LOCK
                                        NO-ERROR.
                    
                     IF   NOT AVAILABLE crapass   THEN
                          IF   tel_nrctabol = 0   THEN
                               RUN altera_tab(INPUT "CTAEMISBOL",
                                              INPUT STRING(tel_nrctabol)).
                          ELSE 
                              ASSIGN glb_cdcritic = 564.
                     ELSE
                          IF   crapass.inpessoa <> 3  THEN
                               ASSIGN glb_cdcritic = 436.
                          ELSE
                               RUN altera_tab(INPUT "CTAEMISBOL",
                                              INPUT STRING(tel_nrctabol)).
                    
                     /* Se a linha de credito para emprestimo com emissao de 
                       boletos foi informada, deve-se informar tambem a conta */
                     IF  tel_nrctabol = 0 AND tel_cdlcrbol <> 0   THEN
                         ASSIGN glb_cdcritic = 564.
                    
                     IF   glb_cdcritic > 0   THEN 
                          DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            PAUSE 3 NO-MESSAGE.
                            NEXT-PROMPT tel_nrctabol WITH FRAME f_coop4.
                            NEXT.
                          END.

                     /*Verificar se a Linha de credito Emis. Boleto e valida*/ 
                     FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                        craplcr.cdlcremp = tel_cdlcrbol NO-LOCK 
                                        NO-ERROR.
                                       
                     IF   NOT AVAILABLE craplcr   THEN
                          IF   tel_cdlcrbol = 0   THEN
                               RUN altera_tab(INPUT "LCREMISBOL",
                                              INPUT STRING(tel_cdlcrbol)).
                          ELSE
                               ASSIGN glb_cdcritic = 363.
                     ELSE
                          IF   craplcr.cdusolcr = 2   THEN
                               RUN altera_tab(INPUT "LCREMISBOL",
                                              INPUT STRING(tel_cdlcrbol)).
                          ELSE
                               DO:
                                  MESSAGE "O codigo de uso da linha deve ser" +
                                          " 2 - EPR/BOLETOS.".
                                  NEXT-PROMPT tel_cdlcrbol WITH FRAME f_coop4.
                                  NEXT.
                               END.
                                        
                     /* Se a conta para emprestimo com emissao de boletos foi 
                        informada, deve-se informar tambem a linha de credito */
                     IF   tel_nrctabol <> 0 AND tel_cdlcrbol = 0   THEN
                          ASSIGN glb_cdcritic = 363.
                    
                     IF  glb_cdcritic > 0   THEN 
                         DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            PAUSE 3 NO-MESSAGE.
                            NEXT-PROMPT tel_cdlcrbol WITH FRAME f_coop4.
                            NEXT.
                         END.

                     ASSIGN  aux_retorna  = TRUE.
                             aux_retorna2 = FALSE.                  
                   
                    
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                       /* Se Confirma = "S" - FECHA todos os frames */
                       IF   aux_fechando  THEN
                            LEAVE.
                       
                       ASSIGN  tel_dsclactr[01] = crapcop.dsclactr[01]
                               tel_dsclactr[02] = crapcop.dsclactr[02]
                               tel_dsclactr[03] = crapcop.dsclactr[03]
                               tel_dsclactr[04] = crapcop.dsclactr[04]
                               tel_dsclactr[05] = crapcop.dsclactr[05]
                               tel_dsclactr[06] = crapcop.dsclactr[06].
       
                       DISPLAY  tel_dsclactr[1] tel_dsclactr[2] tel_dsclactr[3]
                                tel_dsclactr[4] tel_dsclactr[5] tel_dsclactr[6]
                                WITH FRAME f_coop5.
                    
                       UPDATE  tel_dsclactr[1] tel_dsclactr[2]  tel_dsclactr[3]
                               tel_dsclactr[4] tel_dsclactr[5]  tel_dsclactr[6]
                               WITH FRAME f_coop5.
        
                       ASSIGN  crapcop.dsclactr[01] = INPUT tel_dsclactr[01]
                               crapcop.dsclactr[02] = INPUT tel_dsclactr[02]
                               crapcop.dsclactr[03] = INPUT tel_dsclactr[03]
                               crapcop.dsclactr[04] = INPUT tel_dsclactr[04]
                               crapcop.dsclactr[05] = INPUT tel_dsclactr[05]
                               crapcop.dsclactr[06] = INPUT tel_dsclactr[06].

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                          /* Se Confirma = "S" - FECHA todos os frames */
                          IF   aux_fechando  THEN
                               LEAVE.

                          ASSIGN  tel_dsclaccb[01] = crapcop.dsclaccb[01]
                                  tel_dsclaccb[02] = crapcop.dsclaccb[02]
                                  tel_dsclaccb[03] = crapcop.dsclaccb[03]
                                  tel_dsclaccb[04] = crapcop.dsclaccb[04]
                                  tel_dsclaccb[05] = crapcop.dsclaccb[05]
                                  tel_dsclaccb[06] = crapcop.dsclaccb[06].
       
                          DISPLAY  
                                tel_dsclaccb[1] tel_dsclaccb[2] tel_dsclaccb[3]
                                tel_dsclaccb[4] tel_dsclaccb[5] tel_dsclaccb[6]
                                WITH FRAME f_coop6.
                    
                          UPDATE  
                                tel_dsclaccb[1] tel_dsclaccb[2] tel_dsclaccb[3]
                                tel_dsclaccb[4] tel_dsclaccb[5] tel_dsclaccb[6]
                                WITH FRAME f_coop6.
        
                          ASSIGN  crapcop.dsclaccb[01] = INPUT tel_dsclaccb[01]
                                  crapcop.dsclaccb[02] = INPUT tel_dsclaccb[02]
                                  crapcop.dsclaccb[03] = INPUT tel_dsclaccb[03]
                                  crapcop.dsclaccb[04] = INPUT tel_dsclaccb[04]
                                  crapcop.dsclaccb[05] = INPUT tel_dsclaccb[05]
                                  crapcop.dsclaccb[06] = INPUT tel_dsclaccb[06].

                       
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:              
                        
                             /* Se Confirma = "S" - FECHA todos os frames */
                             IF   aux_fechando  THEN
                                  LEAVE.
                            
                             /** Horario inicial para verificar processo **/
                             tel_horproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                              "HH:MM:SS"),1,2)).
                             tel_minproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                              "HH:MM:SS"),4,2)).
                             tel_segproce = INT(SUBSTR(STRING(crapcop.hrproces,
                                                              "HH:MM:SS"),7,2)).
                           
                             /** Horario final para verificar processo **/
                             tel_hrfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                              "HH:MM:SS"),1,2)).
                             tel_mnfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                              "HH:MM:SS"),4,2)).
                             tel_sgfinprc = INT(SUBSTR(STRING(crapcop.hrfinprc,
                                                              "HH:MM:SS"),7,2)).
                                                            
                             UPDATE crapcop.dsdircop  
                                    crapcop.nmdireto
                                    crapcop.flgdopgd
                                    tel_horproce
                                    tel_minproce
                                    tel_segproce
                                    tel_hrfinprc
                                    tel_mnfinprc
                                    tel_sgfinprc
                                    crapcop.dsnotifi[1]
                                    crapcop.dsnotifi[2]
                                    crapcop.dsnotifi[3]
                                    crapcop.dsnotifi[4]
                                    crapcop.dsnotifi[5]
                                    crapcop.dsnotifi[6]
                                    WITH FRAME f_coop7.
                             
                             ASSIGN crapcop.dsdircop = LC(crapcop.dsdircop)
                                    crapcop.hrproces = ((tel_horproce * 3600) +
                                                        (tel_minproce * 60)   +
                                                         tel_segproce)
                                    crapcop.hrfinprc = ((tel_hrfinprc * 3600) +
                                                        (tel_mnfinprc * 60)   +
                                                         tel_sgfinprc).
                       
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                IF aux_fechando THEN
                                    LEAVE.
                          
                                FIND craptab WHERE
                                     craptab.cdcooper = glb_cdcooper     AND
                                     craptab.nmsistem = "CRED"           AND
                                     craptab.tptabela = "USUARI"         AND
                                     craptab.cdempres = 11               AND
                                     craptab.cdacesso = "CORRESPOND"     AND
                                     craptab.tpregist = 000 
                                     EXCLUSIVE-LOCK NO-ERROR.
                                      
                                IF  AVAIL craptab  THEN
                                    ASSIGN
                                    tel_nrconven = INT(SUBSTR(craptab.dstextab,
                                                              1,9))
                                    aux_nrconven = tel_nrconven
                                    tel_nrversao = INT(SUBSTR(craptab.dstextab,
                                                              11,3))
                                    aux_nrversao = tel_nrversao
                                    tel_vldataxa = DEC(SUBSTR(craptab.dstextab,
                                                              15,6))
                                    aux_vldataxa = tel_vldataxa
                                    tel_vltxinss = DEC(SUBSTR(craptab.dstextab,
                                                              22,6))
                                    aux_vltxinss = tel_vltxinss.
                                ELSE
                                     DO:
                                         CREATE craptab.
                                         ASSIGN craptab.cdcooper = glb_cdcooper
                                                craptab.nmsistem = "CRED"      
                                                craptab.tptabela = "USUARI"
                                                craptab.cdempres = 11
                                                craptab.cdacesso = "CORRESPOND"
                                                craptab.tpregist = 000.
                                         VALIDATE craptab.
                                     END.
                                
                                UPDATE tel_nrconven tel_nrversao 
                                       tel_vldataxa tel_vltxinss crapcop.flgargps 
                                       crapcop.dtctrdda crapcop.nrctrdda
                                       crapcop.idlivdda crapcop.nrfoldda
                                       crapcop.dslocdda crapcop.dsciddda
                                       WITH FRAME f_coop8.
                                       
                                ASSIGN SUBSTR(craptab.dstextab,1,9)  = 
                                               STRING(tel_nrconven,"999999999")
                                       SUBSTR(craptab.dstextab,11,3) = 
                                               STRING(tel_nrversao,"999")
                                       SUBSTR(craptab.dstextab,15,6) = 
                                               STRING(tel_vldataxa,"999.99")
                                       SUBSTR(craptab.dstextab,22,6) = 
                                               STRING(tel_vltxinss,"999.99").
                                  
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    IF aux_fechando THEN
                                        LEAVE.
                          
                                    UPDATE crapcop.dtregcob crapcop.idregcob
                                           crapcop.idlivcob crapcop.nrfolcob
                                           crapcop.dsloccob crapcop.dscidcob
                                           crapcop.dsnomscr crapcop.dsemascr
                                           crapcop.dstelscr
                                           WITH FRAME f_coop9.

                                    IF LENGTH(crapcop.dstelscr) > 14 THEN
                                       DO:
                                           MESSAGE "O campo telefone excedeu o numero de caracters.".
                                           PAUSE(3) NO-MESSAGE.
                                           HIDE MESSAGE.
                                           NEXT.

                                       END.

                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        IF aux_fechando THEN
                                            LEAVE.

                                        /* Tarifa GPS Caixa Sem Cod.Barras */
                                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                           craptab.nmsistem = "CRED"       AND
                                                           craptab.tptabela = "GENERI"     AND
                                                           craptab.cdempres = 00           AND
                                                           craptab.cdacesso = "GPSCXASCOD" AND
                                                           craptab.tpregist = 0 
                                                           NO-LOCK NO-ERROR.

                                        IF  AVAILABLE craptab  THEN
                                        DO:
                                           ASSIGN tel_vltfcxsb = DEC(craptab.dstextab).
                                        END.

                                        /* Tarifa GPS Caixa Com Cod.Barras */
                                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                           craptab.nmsistem = "CRED"       AND
                                                           craptab.tptabela = "GENERI"     AND
                                                           craptab.cdempres = 00           AND
                                                           craptab.cdacesso = "GPSCXACCOD" AND
                                                           craptab.tpregist = 0 
                                                           NO-LOCK NO-ERROR.

                                        IF  AVAILABLE craptab  THEN
                                        DO:
                                           ASSIGN tel_vltfcxcb = DEC(craptab.dstextab).
                                        END.


                                        /* Tarifa GPS Internet Banking */
                                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                                           craptab.nmsistem = "CRED"       AND
                                                           craptab.tptabela = "GENERI"     AND
                                                           craptab.cdempres = 00           AND
                                                           craptab.cdacesso = "GPSINTBANK" AND
                                                           craptab.tpregist = 0 
                                                           NO-LOCK NO-ERROR.

                                        IF  AVAILABLE craptab  THEN
                                        DO:
                                           ASSIGN tel_vlrtrfib = DEC(craptab.dstextab).
                                        END.


                                        ASSIGN hor_inipggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrinigps,"HH:MM"),1,2))

                                                min_inipggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrinigps,"HH:MM"),4,2))

                                                hor_fimpggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimgps,"HH:MM"),1,2))

                                                min_fimpggps = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimgps,"HH:MM"),4,2)).
                                                
                                                hor_limitsic =
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrlimsic,"HH:MM"),1,2)).

                                                min_limitsic = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrlimsic,"HH:MM"),4,2)).

                                        UPDATE crapcop.cdagesic
                                               crapcop.nrctasic
                                               crapcop.cdcrdins
                                               crapcop.vltarsic
                                               crapcop.vltardrf
                                               tel_vltfcxsb 
                                               tel_vltfcxcb
                                               tel_vlrtrfib
                                               hor_inipggps
                                               min_inipggps
                                               hor_fimpggps
                                               min_fimpggps
                                               hor_limitsic
                                               min_limitsic
                                               WITH FRAME f_coop10.

                                        ASSIGN crapcop.hrinigps = 
                                                    (hor_inipggps * 3600) +
                                                    (min_inipggps * 60)
                                               crapcop.hrfimgps = 
                                                    (hor_fimpggps * 3600) +
                                                    (min_fimpggps * 60)

                                               crapcop.hrlimsic = 
                                                    (hor_limitsic * 3600) +
                                                    (min_limitsic * 60).
                
                                        RUN altera_tab(INPUT "GPSCXASCOD",INPUT STRING(tel_vltfcxsb)).
                                        RUN altera_tab(INPUT "GPSCXACCOD",INPUT STRING(tel_vltfcxcb)).
                                        RUN altera_tab(INPUT "GPSINTBANK",INPUT STRING(tel_vlrtrfib)).

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                            IF aux_fechando THEN
                                                LEAVE.

                                            ASSIGN hor_intersgr = 
                                                    INTE(SUBSTR(STRING(
                                                        crapcop.qttmpsgr,
                                                        "HH:MM"), 1, 2))
                                                    min_intersgr = 
                                                    INTE(SUBSTR(STRING(
                                                        crapcop.qttmpsgr,
                                                        "HH:MM"), 4, 2)).
                                            
                                            ASSIGN tel_flgkitbv = crapcop.flgkitbv.
                                            IF glb_dsdepart <> "TI" THEN
                                               DO:
                                                  DISP hor_intersgr
                                                       min_intersgr
                                                       WITH FRAME f_coop11.
                                                  UPDATE tel_flgkitbv
                                                       WITH FRAME f_coop11.
                                               END.
                                            ELSE
                                            DO:
                                                UPDATE hor_intersgr
                                                       min_intersgr
                                                       tel_flgkitbv
                                                       WITH FRAME f_coop11.

                                                IF hor_intersgr = 0 AND
                                                   min_intersgr = 0 THEN
                                                DO:
                                                    MESSAGE "Informe um intervalo de tempo para verificacao da sangria.".
                                                    PAUSE 3 NO-MESSAGE.
                                                    HIDE MESSAGE NO-PAUSE.
                                                    NEXT.
                                                END.
                                                ASSIGN crapcop.flgkitbv = tel_flgkitbv.
                                                ASSIGN crapcop.qttmpsgr = 
                                                        (hor_intersgr * 3600) +
                                                        (min_intersgr * 60).
                                            END.

                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        IF aux_fechando THEN
                                            LEAVE.

                                        ASSIGN hor_inidebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hriniatr,"HH:MM"),1,2))

                                                min_inidebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hriniatr,"HH:MM"),4,2))

                                                hor_fimdebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimatr,"HH:MM"),1,2))

                                                min_fimdebfa = 
                                             INTE(SUBSTR(STRING(
                                                 crapcop.hrfimatr,"HH:MM"),4,2))
                                             
                                             tel_flgdebfa = crapcop.flgofatr.
                                             tel_qtdiasus = INTE(crapcop.qtdiasus).
                                        
                                        UPDATE tel_qtdiasus
                                               hor_inidebfa
                                               min_inidebfa
                                               hor_fimdebfa
                                               min_fimdebfa
                                               tel_flgdebfa
                                               WITH FRAME f_coop13.

                                        ASSIGN crapcop.hriniatr = 
                                                    (hor_inidebfa * 3600) +
                                                    (min_inidebfa * 60)
                                               crapcop.hrfimatr = 
                                                    (hor_fimdebfa * 3600) +
                                                    (min_fimdebfa * 60)
                                               crapcop.flgofatr = tel_flgdebfa
                                               crapcop.qtdiasus = tel_qtdiasus.

                                        /** frame f_coop14 **/
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        IF aux_fechando THEN
                                            LEAVE.

                                        UPDATE crapcop.cdcliser
                                               WITH FRAME f_coop14.


                                            /** frame f_coop12 **/
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                                IF aux_fechando THEN
                                                LEAVE.

                                                UPDATE crapcop.vlmiplco
                                                       crapcop.vlmidbco
                                                       crapcop.cdfingrv
                                                       crapcop.cdsubgrv
                                                       crapcop.cdloggrv
                                                       WITH FRAME f_coop12.

                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                    
                                                    ASSIGN tel_flsaqpre = crapcop.flsaqpre
														   tel_hrinisac = INT(SUBSTR(STRING(crapcop.hrinisac,"HH:MM:SS"),1,2))
														   tel_mminisac = INT(SUBSTR(STRING(crapcop.hrinisac,"HH:MM:SS"),4,2)) 
														   tel_hrfimsac = INT(SUBSTR(STRING(crapcop.hrfimsac,"HH:MM:SS"),1,2))
														   tel_mmfimsac = INT(SUBSTR(STRING(crapcop.hrfimsac,"HH:MM:SS"),4,2)) 
														/* HORARIOS OUVIDORIA */
														   tel_hriniouv = INT(SUBSTR(STRING(crapcop.hriniouv,"HH:MM:SS"),1,2))
														   tel_mminiouv = INT(SUBSTR(STRING(crapcop.hriniouv,"HH:MM:SS"),4,2)) 
														   tel_hrfimouv = INT(SUBSTR(STRING(crapcop.hrfimouv,"HH:MM:SS"),1,2))
														   tel_mmfimouv = INT(SUBSTR(STRING(crapcop.hrfimouv,"HH:MM:SS"),4,2))
														   tel_flsaqpre = crapcop.flsaqpre
                                                           tel_flrecpct = crapcop.flrecpct.
                                                    
                                                    UPDATE tel_flsaqpre
													       crapcop.permaxde
                                                           crapcop.qtmaxmes
                                                           tel_flrecpct
                                                           tel_hrinisac tel_mminisac
                                                           tel_hrfimsac tel_mmfimsac
                                                           tel_hriniouv tel_mminiouv
                                                           tel_hrfimouv tel_mmfimouv
                                                           WITH FRAME f_coop15												    
                                                    EDITING:
                                                    DO:
                                                        READKEY.
                                                      HIDE MESSAGE NO-PAUSE.
                                                      
                                                      IF (FRAME-FIELD = "permaxde") THEN
                                                        DO:
                                                            IF NOT KEYLABEL(LASTKEY) = "," THEN
                                                              APPLY LASTKEY.                                                            
                                                        END.
                                                      ELSE
                                                        APPLY LASTKEY.

                                                        IF  GO-PENDING  THEN
                                                            DO:               
                                                                ASSIGN INPUT tel_flsaqpre 
                                                                             crapcop.permaxde
                                                                             crapcop.qtmaxmes
                                                                             tel_flrecpct  
                                                                             tel_hrinisac tel_mminisac
                                                                             tel_hrfimsac tel_mmfimsac
                                                                             tel_hriniouv tel_mminiouv
                                                                             tel_hrfimouv tel_mmfimouv.
                                                                              
                                                                ASSIGN aux_nmdcampo = "".

                                                                IF ((tel_hrinisac * 3600) + (tel_mminisac * 60)) >= ((tel_hrfimsac * 3600) + (tel_mmfimsac * 60)) THEN
                                                                DO: 
                                                                    ASSIGN aux_nmdcampo = "tel_hrinisac".
                                                                END.
                                                    
                                                                IF ((tel_hriniouv * 3600) + (tel_mminiouv * 60)) >= ((tel_hrfimouv * 3600) + (tel_mmfimouv * 60)) THEN
                                                    DO:
                                                                    ASSIGN aux_nmdcampo = "tel_hriniouv".

                                                    END.

                                                                IF  aux_nmdcampo <> "" THEN
                                                    DO:
                                                                    MESSAGE "Horario inicial maior que o final.".

                                                                    {sistema/generico/includes/foco_campo.i
                                                                        &VAR-GERAL="sim"
                                                                        &NOME-FRAME="f_coop15"
                                                                        &NOME-CAMPO=aux_nmdcampo }
                                                                END.


                                                            END.                                    

                                                    END.


                                                    ASSIGN crapcop.flsaqpre = tel_flsaqpre
													       crapcop.flrecpct = tel_flrecpct
                                                           crapcop.hrinisac = ((tel_hrinisac * 3600) + (tel_mminisac * 60))
                                                           crapcop.hrfimsac = ((tel_hrfimsac * 3600) + (tel_mmfimsac * 60))
                                                           crapcop.hriniouv = ((tel_hriniouv * 3600) + (tel_mminiouv * 60))
                                                           crapcop.hrfimouv = ((tel_hrfimouv * 3600) + (tel_mmfimouv * 60)).
                                                    
												END.
												    
                                                IF KEYFUNCTION(LASTKEY) = "RETURN" OR
                                                   KEYFUNCTION(LASTKEY) = "GO" THEN
                                                    RUN Confirma.

                                                IF aux_confirma <> "S" THEN
                                                    APPLY "ERROR".
                                                ELSE
                                                DO: 
                                                    RUN limpeza-limites-cmaprv.
                                                    ASSIGN aux_fechando = TRUE.
                                                    RUN Gera_log.
                                                    LEAVE.  
                                                END.
                                            END. /** frame f_coop15 **/
                                            END. /** frame f_coop12 **/
                                        END. /** frame f_coop14 **/
                                       END. /** frame f_coop13 **/
                                      END.
                                    END.
                                END.
                             END.
                          END.
                       END.
                     END. /** Fim f_coop5 **/
                    END. 
                   END. /** Fim f_coop4 **/   
                 END.  /** Fim f_coop3 **/
              END.
           END.
                                         
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                APPLY "ERROR".                   

       END.
END.

PROCEDURE Gera_log.
   
  RUN log ("nome res.",crapcop.nmrescop,w-crapcop.nmrescop).
       
  RUN log ("cnpj.",STRING(crapcop.nrdocnpj),STRING(w-crapcop.nrdocnpj)).
       
  RUN log ("nome ext.",crapcop.nmextcop,w-crapcop.nmextcop).
       
  RUN log ("end.coop",crapcop.dsendcop,w-crapcop.dsendcop).
       
  RUN log("nr.ender.",STRING(crapcop.nrendcop),STRING(w-crapcop.nrendcop)).

  RUN log ("complemento",crapcop.dscomple,w-crapcop.dscomple).
            
  RUN log ("bairro",crapcop.nmbairro,w-crapcop.nmbairro).
       
  RUN log ("cep",STRING(crapcop.nrcepend),STRING(w-crapcop.nrcepend)).
         
  RUN log ("cidade",crapcop.nmcidade,w-crapcop.nmcidade).
       
  RUN log ("uf",STRING(crapcop.cdufdcop),STRING(w-crapcop.cdufdcop)).
       
  RUN log ("c.postal",STRING(crapcop.nrcxapst),STRING(w-crapcop.nrcxapst)).
       
  RUN log ("telefone",STRING(crapcop.nrtelvoz),STRING(w-crapcop.nrtelvoz)).
       
  RUN log ("fax",STRING(crapcop.nrtelfax),STRING(w-crapcop.nrtelfax)).
       
  RUN log ("site",crapcop.dsendweb,w-crapcop.dsendweb).
       
  RUN log ("email",crapcop.dsdemail,w-crapcop.dsdemail).
       
  RUN log ("email presidente",crapcop.dsdempst,w-crapcop.dsdempst).
               
  RUN log ("titular da coop.",crapcop.nmtitcop,w-crapcop.nmtitcop).
       
  RUN log ("cpf tit.",STRING(crapcop.nrcpftit),STRING(w-crapcop.nrcpftit)).
              
  RUN log ("nome contador",crapcop.nmctrcop,w-crapcop.nmctrcop).

  RUN log ("email contador",aux_dsemlctr,old_dsemlctr).

  RUN log ("cpf contador",STRING(crapcop.nrcpfctr),STRING(w-crapcop.nrcpfctr)).
 
  RUN log ("crc contador",STRING(crapcop.nrcrcctr),STRING(w-crapcop.nrcrcctr)).

  RUN log ("reg.na junta",STRING(crapcop.nrrjunta),STRING(w-crapcop.nrrjunta)).
  
  RUN log ("data registro",STRING(crapcop.dtrjunta),STRING(w-crapcop.dtrjunta)).

  RUN log("inscr.estadual",STRING(crapcop.nrinsest),STRING(w-crapcop.nrinsest)).

  RUN log ("inscr.municipal",STRING(crapcop.nrinsmun),
                                         STRING(w-crapcop.nrinsmun)).
  
  RUN log ("livro aplicacoes",STRING(crapcop.nrlivapl),
                                         STRING(w-crapcop.nrlivapl)).
  
  RUN log ("livro de capital",STRING(crapcop.nrlivcap),
                                         STRING(w-crapcop.nrlivcap)).
  
  RUN log ("livro dep.vista",STRING(crapcop.nrlivdpv),
                                         STRING(w-crapcop.nrlivdpv)).
  
  RUN log ("livro de emprestimos",STRING(crapcop.nrlivepr),
                                         STRING(w-crapcop.nrlivepr)).
  
  RUN log ("Cod.COMPE Cecred",STRING(crapcop.cdbcoctl),
                               STRING(w-crapcop.cdbcoctl)).

  RUN log ("Nro.Age da Central",STRING(crapcop.cdagectl),
                                STRING(w-crapcop.cdagectl)).

  RUN log ("age.bancoob",STRING(crapcop.cdagebcb),STRING(w-crapcop.cdagebcb)).

  RUN log ("age.BB",STRING(crapcop.cdagedbb),STRING(w-crapcop.cdagedbb)).

  RUN log ("age.ITG",STRING(crapcop.cdageitg),STRING(w-crapcop.cdageitg)).
       
  RUN log ("cnv.ITG",STRING(crapcop.cdcnvitg),STRING(w-crapcop.cdcnvitg)).
                                                                           
  RUN log ("massificado ITG",STRING(crapcop.cdmasitg),
                                         STRING(w-crapcop.cdmasitg)).
                   
  RUN log ("cta.conv.BB",STRING(crapcop.nrctabbd),STRING(w-crapcop.nrctabbd)).

  RUN log ("conta na Cecred",STRING(crapcop.nrctactl),
                                         STRING(w-crapcop.nrctactl)).
  
  RUN log ("conta integracao",STRING(crapcop.nrctaitg),
                                         STRING(w-crapcop.nrctaitg)).
  
  RUN log ("cta.ITG",STRING(crapcop.nrctadbb),STRING(w-crapcop.nrctadbb)).
       
  RUN log ("cta.Compe CECRED",
           STRING(crapcop.nrctacmp),
           STRING(w-crapcop.nrctacmp)).
  
  RUN log ("conta/dv",STRING(crapcop.nrdconta),STRING(w-crapcop.nrdconta)).

  RUN log ("SIRC",
           STRING(crapcop.flgdsirc,"CAPITAL/INTERIOR"),
           STRING(w-crapcop.flgdsirc,"CAPITAL/INTERIOR")).

  RUN log("cartao magnetico",STRING(crapcop.flgcrmag,"Sim/Nao"),
                                         STRING(w-crapcop.flgcrmag,"Sim/Nao")). 

  RUN log("Dias Env.TAA",STRING(crapcop.flgcrmag,"zz9"),
                                         STRING(w-crapcop.flgcrmag,"zz9")). 
  
  RUN log("Emite informativo chegada cartao",STRING(crapcop.cdsinfmg),
                                         STRING(w-crapcop.cdsinfmg)).
  
  RUN log("valor Max.Central",STRING(crapcop.vlmaxcen,"zzz,zzz,zzz,zz9.99"),
                            STRING(w-crapcop.vlmaxcen,"zzz,zzz,zzz,zz9.99")).
  
  RUN log ("valor Max.Legal",STRING(crapcop.vlmaxleg,"zzz,zzz,zzz,zz9.99"),
                            STRING(w-crapcop.vlmaxleg,"zzz,zzz,zzz,zz9.99")).
  
  RUN log ("valor Max.Utilizado",STRING(crapcop.vlmaxutl,"zzz,zzz,zz9.99"),
                            STRING(w-crapcop.vlmaxutl,"zzz,zzz,zz9.99")).
  
  RUN log ("valor Consulta SCR",STRING(crapcop.vlcnsscr,"zzz,zzz,zzz,zz9.99"),
                            STRING(w-crapcop.vlcnsscr,"zzz,zzz,zzz,zz9.99")).

  RUN log ("Possui Comite Local", 
           STRING(crapcop.flgcmtlc,"SIM/NAO"),
           STRING(w-crapcop.flgcmtlc,"SIM/NAO")).
                                
  RUN log ("Valor Limite Alcada Geral", 
           STRING(crapcop.vllimapv,"zzz,zzz,zzz,zz9.99"),
           STRING(w-crapcop.vllimapv,"zzz,zzz,zzz,zz9.99")).
  
  RUN log ("diretorio onde esta sistema",crapcop.dsdircop,w-crapcop.dsdircop).
  
  RUN log ("diretorio padrao arq.textos",crapcop.nmdireto,w-crapcop.nmdireto).
  
  RUN log ("participa progrid",STRING(crapcop.flgdopgd,"Sim/Nao"),
                                         STRING(w-crapcop.flgdopgd,"Sim/Nao")).
  
  RUN log ("horario inicial processo",STRING(crapcop.hrproces,"HH:MM:SS"),
                                         STRING(w-crapcop.hrproces,"HH:MM:SS")).
  
  RUN log ("horario final processo",STRING(crapcop.hrfinprc,"HH:MM:SS"),
                                         STRING(w-crapcop.hrfinprc,"HH:MM:SS")).
  
  RUN log ("data do cnpj",STRING(crapcop.dtcdcnpj),STRING(w-crapcop.dtcdcnpj)).
 
  RUN log ("convenio - coban",STRING(tel_nrconven),STRING(aux_nrconven)).

  RUN log ("versao - coban",STRING(tel_nrversao),STRING(aux_nrversao)).
      
  RUN log ("tarifa pagto. - coban",STRING(tel_vldataxa,"zz9.99"),
                                         STRING(aux_vldataxa,"zz9.99")).
  RUN log ("tarifa inss - coban",STRING(tel_vltxinss,"zz9.99"),
                                         STRING(aux_vltxinss,"zz9.99")).
                                         
  RUN log ("Arrecadacao GPS - coban",STRING(crapcop.flgargps,"SIM/NAO"),
                                     STRING(w-crapcop.flgargps,"SIM/NAO")). 
  
  RUN log ("Data do Contrato - DDA",STRING(crapcop.dtctrdda),
                                    STRING(w-crapcop.dtctrdda)).
  RUN log ("N. do Contrato - DDA",STRING(crapcop.nrctrdda),
                                    STRING(w-crapcop.nrctrdda)).
  RUN log ("N. do Livro - DDA",crapcop.idlivdda,w-crapcop.idlivdda).
  RUN log ("N. da Folha - DDA",STRING(crapcop.nrfoldda),
                                    STRING(w-crapcop.nrfoldda)).
  RUN log ("Local de Registro - DDA",STRING(crapcop.dslocdda),
                                    STRING(w-crapcop.dslocdda)).
  RUN log ("Cidade - DDA",STRING(crapcop.dsciddda),
                                    STRING(w-crapcop.dsciddda)).

  RUN log ("conta coope Ems. Boleto",STRING(aux_nrctabol,"zzzz,zzz,9"), 
                                 STRING(tel_nrctabol,"zzzz,zzz,9")).                                       
  RUN log ("linha credito Ems. Boleto",STRING(aux_cdlcrbol,"zz9"),
                                 STRING(tel_cdlcrbol,"zz9")).

  RUN log ("Intervalo de Tempo Sangria",STRING(crapcop.qttmpsgr, "HH:MM"),
                                        STRING(w-crapcop.qttmpsgr, "HH:MM")).

  RUN log ("Valor minimo contratacao plano de cotas",STRING(crapcop.vlmiplco, "zzz,zzz,zz9.99"),
                                         STRING(w-crapcop.vlmiplco, "zzz,zzz,zz9.99")).

  RUN log ("Valor minimo debito de cotas",STRING(crapcop.vlmidbco, "zzz,zzz,zz9.99"),
                                         STRING(w-crapcop.vlmidbco, "zzz,zzz,zz9.99")).

  RUN log ("Codigo da financeira",STRING(crapcop.cdfingrv,   "999999999999999"),
                                  STRING(w-crapcop.cdfingrv, "999999999999999")).
                                  
  RUN log ("Subcodigo do usuário",STRING(crapcop.cdsubgrv,   "999"),
                                  STRING(w-crapcop.cdsubgrv, "999")).
                                  
  RUN log ("Login do usuario",STRING(crapcop.cdloggrv,       "X(8)"),
                                  STRING(w-crapcop.cdloggrv, "X(8)")).

  RUN log ("Agencia Sicredi",STRING(crapcop.cdagesic, ">>>,>>9"),
                             STRING(w-crapcop.cdagesic, ">>>,>>9")).

  RUN log ("Conta Sicredi",STRING(crapcop.nrctasic, "->,>>>,>>9"),
                            STRING(w-crapcop.nrctasic, "->,>>>,>>9")).

  RUN log ("Sede INSS",STRING(crapcop.cdagsins, "zz9"),
                       STRING(w-crapcop.cdagsins, "zz9")).

  RUN log ("Credencial dos arrecadadores",STRING(crapcop.cdcrdins, "zzzzzzz9"),
                                          STRING(w-crapcop.cdcrdins, "zzzzzzz9")).

  RUN log ("Tarifa Tributo Federal",STRING(crapcop.vltardrf, "zzz,zzz,zz9.99"),
                                    STRING(w-crapcop.vltardrf, "zzz,zzz,zz9.99")).

RUN log ("Horario inicio pagamento GPS",STRING(crapcop.hrinigps, "HH:MM"),
                                          STRING(w-crapcop.hrinigps, "HH:MM")).

  RUN log ("Horario fim pagamento GPS",STRING(crapcop.hrfimgps, "HH:MM"),
                                       STRING(w-crapcop.hrfimgps, "HH:MM")).
  
  RUN log ("Horario limite pagamento SICREDI",STRING(crapcop.hrlimsic, "HH:MM"),
                                              STRING(w-crapcop.hrlimsic, "HH:MM")).

  RUN log ("Saque presencial",STRING(crapcop.flsaqpre, "Isentar/Nao isentar"),
                                              STRING(w-crapcop.flsaqpre, "Isentar/Nao isentar")).

  RUN log ("Percentual máximo de desconto manual",STRING(crapcop.permaxde, "zz9.99"),
                                              STRING(w-crapcop.permaxde, "zz9.99")).
                                              
  RUN log ("Quantidade máxima de meses de desconto",STRING(crapcop.qtmaxmes, "zz9"),
                                              STRING(w-crapcop.qtmaxmes, "zz9")).
                                              
  RUN log ("Permitir reciprocidade",STRING(crapcop.flrecpct, "Sim/Nao"),
                                              STRING(w-crapcop.flrecpct, "Sim/Nao")).


END PROCEDURE.
       
PROCEDURE log:

  DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
  DEF INPUT PARAM par_vldepois AS CHAR NO-UNDO.
  DEF INPUT PARAM par_vldantes AS CHAR NO-UNDO.  

  IF   par_vldepois = par_vldantes   THEN
       RETURN.
  
  ASSIGN par_vldepois = "---" WHEN par_vldepois = ""
         par_vldantes = "---" WHEN par_vldantes = ""
         par_vldepois = REPLACE(REPLACE(par_vldepois,"("," "),")","-")
         par_vldantes = REPLACE(REPLACE(par_vldantes,"("," "),")","-").
         
  UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "       +
                    STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "      +
                    glb_cdoperad + " '-->' Alterou o campo " + par_dsdcampo +
                    " de " + par_vldantes + " para " + par_vldepois + "."   +
                    " >> log/cadcop.log").

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE altera_tab:

DEF INPUT PARAMETER par_cdacesso AS CHAR     NO-UNDO.
DEF INPUT PARAMETER par_dstextab AS CHAR     NO-UNDO.
                        
   DO aux_contador = 1 TO 10 TRANSACTION:
                     
      ASSIGN glb_cdcritic = 0.

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.nmsistem = "CRED"       AND
                         craptab.tptabela = "GENERI"     AND
                         craptab.cdempres = 00           AND
                         craptab.cdacesso = par_cdacesso AND
                         craptab.tpregist = 0 EXCLUSIVE-LOCK
                         NO-ERROR NO-WAIT.
                                         
      IF   NOT AVAILABLE craptab   THEN
           IF   LOCKED craptab   THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                                         
                    NEXT.

                END.
           ELSE
                DO:
                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper
                          craptab.nmsistem = "CRED"
                          craptab.tptabela = "GENERI"
                          craptab.cdempres = 0
                          craptab.cdacesso = par_cdacesso
                          craptab.tpregist = 0
                          craptab.dstextab = par_dstextab.
                   VALIDATE craptab.

                   LEAVE.
                END.
      ELSE
          craptab.dstextab = par_dstextab.
           
      LEAVE.
   END. /*** Fim do DO TO ***/

END PROCEDURE.

PROCEDURE limpeza-limites-cmaprv.

    IF  w-crapcop.flgcmtlc = crapcop.flgcmtlc  THEN
        RETURN.

    IF  crapcop.flgcmtlc  THEN
        DO:
            FOR EACH crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                   crapope.vlapvcre > 0
                                   EXCLUSIVE-LOCK TRANSACTION:

                ASSIGN crapope.vlapvcre = 0.

            END.
        END.
    ELSE
        DO:
            FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                   crapage.vllimapv > 0
                                   EXCLUSIVE-LOCK TRANSACTION:

                ASSIGN crapage.vllimapv = 0.

            END.

            FOR EACH crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                   crapope.cdcomite <> 0
                                   EXCLUSIVE-LOCK TRANSACTION:

                ASSIGN crapope.cdcomite = 0.

            END.
        END.

END PROCEDURE.

/* ......................................................................... */
 










