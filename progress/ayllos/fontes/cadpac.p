/*..............................................................................

   Programa: Fontes/cadpac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Marco/2004                        Ultima Atualizacao: 30/11/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Cadastramento de PACS.

   ALTERACAO : Incluida opcao "B"(Boletim de Caixa) e criacao tabelas horarios
               Titulo/Compel.
               
                07/07/2004 - Acessar tabela GENERI(LOCALIDADE)- Cidade do PAC
                            (Mirtes)

                23/08/2004 - Acrescentar Endereco dos PAC nos talonarios (ZE).
                
                03/05/2005 - Acrescentar Ag.Relacionamento COBAN(Mirtes).

                26/08/2005 - Tratar situacao do PAC (Edson).


                12/01/2006 - Incluir dados para Progrid (Rosangela).
                
                08/02/2006 - Incluida a digitacao dos horarios de guias GPS e
                             de DOCTOS (Evandro).

                10/01/2007 - Incluido novos campos na tela e substituido dados 
                             da craptab por dados da crapage (Elton). 

                17/01/2007 - Zerado campo tel_cdagenci apos inclusao ou
                             alteracao de algum  PAC (Elton). 
                             
                27/04/2007 - Tratar browse caso nao haja registros (Evandro).

                22/06/2007 - O PAC 90 somente podera ser alterado pelo
                             SUPER-USUARIO (cdoperad = 1)
                           - Gravar craptab "HRTRANSFER" 
                           - Horario inicial e final para titulo (David).
                           
                11/09/2007 - Permitir que o PAC 90 seja alterado pelos
                             operadores 1, 996, 997 e 799 (Evandro).
                             
                28/09/2007 - Alterado HELP para horario minimo/maximo para 
                             pagamentos e transferencia, pac 90 (Guilherme).
               
                18/10/2007 - Incluidos os campos Orgao pagador (cdorgpag) e
                             Agencia Pioneira (tpagenci) (Gabriel).
                             
                16/11/2007 - Incluido novo campo horario p/ alteracao 
                             plano de capital
                           - Ajustes no Layuot da tela(Guilherme).
                           
                11/12/2007 - Acerto em criticas e HELPs (Guilherme).           
                  
                25/04/2008 - Alterado browse dos pac`s para listar por ordem 
                             alfabetica (Gabriel).
                           - Incluir campos (qtddaglf,qtddlslf) e parametro
                             para segundo processo de agendamentos (David).
                           - Incluido campo "Verificar Pend.COBAN" com
                             informacoes da crapage.vercoban (Elton).
                           - Somente operadores "1", "996", "997" e "999" podem
                             alterar campo "Verificar Pend.COBAN" (Elton). 
                           - Incluir horario limite para canc. de pagamentos e
                             incluir fax do pac(90) para envio de cancelamentos
                             (Guilherme).

                23/01/2009 - Retirar permissao do operador 799 e liberar 
                             o 979 (Gabriel).
                             
                11/05/2009 - Alteracao CDOPERAD (Kbase).
                
                26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                             para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                             (Sidnei - Precise). 
                             
                09/10/2009 - Aumentado o campo de email de 30 para 40 
                             caracteres (Elton).                        
                             
                30/11/2009 - Incluir campo crapage.vllimapv que armazena o
                             Valor de Aprovacao do Comite Local para crédito
                             (David).
                             
                19/05/2010 - Incluido na tela campo "Envelopes"
                             (Sandro-GATI)
                             
                10/06/2010 - Utilizar mesmos tratamentos do PAC 90 para o 
                             PAC 91 (Diego).
                             
                30/06/2010 - Incluida opcao "X" (GATI). 
                
                11/10/2010 - Incluido o campo "Qtde. Max. de cheques por previa"
                             (Adriano).
                             
                22/02/2011 - Incluir campo de 'Regional' (Gabriel)             
                 
                10/05/2011 - Incluido campo "Geracao Boletos Registrada"
                             (Adriano).
                             
                02/06/2011 - Alterado label "Geracao Boletos Registrada" para 
                             "Geracao/Instrucoes Cobranca Registrada".
                             (Fabricio).
                             
                09/02/2012 - Retirado os tratamentos de malote, agencia 
                             agrupadora para a inclusao da agencia do PAC
                             (Adriano).              
                 
                16/04/2012 - Fonte substituido por cadpacp.p (Tiago).     
                
                24/05/2012 - Retirado opção "M" e incluido na opção "A" para
                             alteração do PAC Sede.(David Kruger).     
                             
                01/04/2013 - Adicionados campos relativos ao horário limite para
                             pagmto de conv. SICREDI 
                           - Inclusao campos convenios SICREDI (Lucas).
                            
                11/04/2013 - Incluir campos tel_vlminsgr, tel_vlmaxsgr em tela
                             (Lucas R.)
                             
                18/04/2013 - Inclusão de campos de horários limite para pagtos
                             e cancelamentos de Convenios SICREDI (Lucas).
                             
                20/06/2013 - Inclusão de campos da agencia pioneira e orgao
                             pagador SICREDI (Reinert).
                             
                04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                14/01/2014 - Alterado de PAC para PA na procedure gera_log_cadpac
                             (Reinert)
                             
                25/06/2014 - #141385 Log para os horarios das faturas SICREDI
                            (Carlos)
                            
                18/08/2014 - Inclusao dos Horarios do Credito Pre Aprovado.
                             (Jaison)
                             
                20/08/2014 - Ajuste para que o horario limite de capital seja
                             utilizado tambem pela captacao
                             (Adriano).
                             
                15/09/2014 - Inclusao do parametro de quantidade de meses
                             para agendamento de aplicacao/resgate (Tiago/Gielow)
                             
                26/10/2015 - Conversão Oracle da rotina busca-crapreg da b1wgen0086
                             Adaptação para a nova chamda - Jéssica (DB1)
                             
                24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).

                18/07/2016 - Incluido campo tel_nrtelvoz.
                             PRJ229 - Melhorias OQS (Odirlei - AMcom)
                             
                30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)             
..............................................................................*/

{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0086tt.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
                                                                       
/* Variaveis para o XML */                                             
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.  
DEF VAR xField        AS HANDLE                                        NO-UNDO. 
DEF VAR xText         AS HANDLE                                        NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

DEF VAR tel_cdagenci LIKE crapage.cdagenci                             NO-UNDO.
DEF VAR tel_insitage LIKE crapage.insitage                             NO-UNDO.
DEF VAR tel_nmextage LIKE crapage.nmextage                             NO-UNDO.
DEF VAR tel_nmresage LIKE crapage.nmresage                             NO-UNDO.
DEF VAR tel_cdcomchq LIKE crapage.cdcomchq                             NO-UNDO.
DEF VAR tel_cdcxaage LIKE crapage.cdcxaage                             NO-UNDO.
DEF VAR tel_cdccuage LIKE crapage.cdccuage                             NO-UNDO.
DEF VAR tel_cdagetit LIKE crapage.cdagetit                             NO-UNDO.
DEF VAR tel_cdagechq LIKE crapage.cdagechq                             NO-UNDO.
DEF VAR tel_cdagedoc LIKE crapage.cdagedoc                             NO-UNDO.
DEF VAR tel_cdorgpag LIKE crapage.cdorgpag                             NO-UNDO. 
DEF VAR tel_tpagenci LIKE crapage.tpagenci                             NO-UNDO.
DEF VAR tel_dsendcop LIKE crapage.dsendcop                             NO-UNDO.
DEF VAR tel_dscomple LIKE crapage.dscomple                             NO-UNDO.
DEF VAR tel_nmbairro LIKE crapage.nmbairro                             NO-UNDO.
DEF VAR tel_nrcepend LIKE crapage.nrcepend                             NO-UNDO.
DEF VAR tel_cdufdcop LIKE crapage.cdufdcop                             NO-UNDO.
DEF VAR tel_nmcidade LIKE crapage.nmcidade                             NO-UNDO.
DEF VAR tel_cdagecbn LIKE crapage.cdagecbn                             NO-UNDO.
DEF VAR tel_cdbantit LIKE crapage.cdbantit                             NO-UNDO.
DEF VAR tel_cdbanchq LIKE crapage.cdbanchq                             NO-UNDO.
DEF VAR tel_cdbandoc LIKE crapage.cdbandoc                             NO-UNDO.
DEF VAR tel_flgdopgd LIKE crapage.flgdopgd                             NO-UNDO.
DEF VAR tel_cdageagr LIKE crapage.cdageagr                             NO-UNDO.
DEF VAR tel_dtmvtolt LIKE crapbcx.dtmvtolt                             NO-UNDO.
DEF VAR tel_nrdcaixa LIKE crapbcx.nrdcaixa                             NO-UNDO.
DEF VAR tel_qtddaglf LIKE crapage.qtddaglf                             NO-UNDO.
DEF VAR tel_qtmesage LIKE crapage.qtmesage                             NO-UNDO.
DEF VAR tel_qtddlslf LIKE crapage.qtddlslf                             NO-UNDO.
DEF VAR tel_vllimapv LIKE crapage.vllimapv                             NO-UNDO.
DEF VAR tel_qtchqprv AS INT FORMAT "zz9"                               NO-UNDO.
DEF VAR tel_nrtelfax LIKE crapage.nrtelfax                             NO-UNDO.
DEF VAR tel_nrtelvoz LIKE crapage.nrtelvoz                             NO-UNDO.
DEF VAR tel_cdagepac LIKE crapage.cdagepac                             NO-UNDO.
                                                      
DEF VAR tel_hhtitini AS INTE                                           NO-UNDO.
DEF VAR tel_mmtitini AS INTE                                           NO-UNDO.
DEF VAR tel_hhtitfim AS INTE                                           NO-UNDO.
DEF VAR tel_mmtitfim AS INTE                                           NO-UNDO.
DEF VAR tel_hhcompel AS INTE                                           NO-UNDO.
DEF VAR tel_mmcompel AS INTE                                           NO-UNDO.
DEF VAR tel_hhguigps AS INTE                                           NO-UNDO.
DEF VAR tel_mmguigps AS INTE                                           NO-UNDO.
DEF VAR tel_hhenvelo AS INTE                                           NO-UNDO.
DEF VAR tel_mmenvelo AS INTE                                           NO-UNDO.
DEF VAR tel_hhdoctos AS INTE                                           NO-UNDO.
DEF VAR tel_mmdoctos AS INTE                                           NO-UNDO.
DEF VAR tel_hhbolini AS INTE                                           NO-UNDO.
DEF VAR tel_mmbolini AS INTE                                           NO-UNDO.
DEF VAR tel_hhbolfim AS INTE                                           NO-UNDO.
DEF VAR tel_mmbolfim AS INTE                                           NO-UNDO.
DEF VAR tel_hhtrfini AS INTE                                           NO-UNDO.
DEF VAR tel_mmtrfini AS INTE                                           NO-UNDO.
DEF VAR tel_hhtrffim AS INTE                                           NO-UNDO.
DEF VAR tel_mmtrffim AS INTE                                           NO-UNDO.
DEF VAR tel_hhcapini AS INTE                                           NO-UNDO.
DEF VAR tel_mmcapini AS INTE                                           NO-UNDO.
DEF VAR tel_hhcapfim AS INTE                                           NO-UNDO.
DEF VAR tel_mmcapfim AS INTE                                           NO-UNDO.
DEF VAR tel_hhlimcan AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_mmlimcan AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_dsinform AS CHAR FORMAT "x(40)" EXTENT 3                   NO-UNDO. 
DEF VAR tel_dssitage AS CHAR FORMAT "x(8)"                             NO-UNDO.
DEF VAR tel_dsdemail AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_cdopecxa AS CHAR FORMAT "x(10)"                            NO-UNDO.
DEF VAR tel_flsgproc AS LOGI                                           NO-UNDO.
DEF VAR tel_vercoban AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR tel_flgdsede AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR tel_cddregio LIKE crapreg.cddregio                             NO-UNDO.
DEF VAR tel_dsdregio LIKE crapreg.dsdregio                             NO-UNDO.
DEF VAR tel_vlminsgr LIKE crapage.vlminsgr                             NO-UNDO.
DEF VAR tel_vlmaxsgr LIKE crapage.vlmaxsgr                             NO-UNDO.
DEF VAR tel_tpageins LIKE crapage.tpageins                             NO-UNDO.
DEF VAR tel_cdorgins LIKE crapage.cdorgins                             NO-UNDO.

DEF VAR log_cdagenci LIKE crapage.cdagenci                             NO-UNDO.
DEF VAR log_insitage LIKE crapage.insitage                             NO-UNDO.
DEF VAR log_nmextage LIKE crapage.nmextage                             NO-UNDO.
DEF VAR log_nmresage LIKE crapage.nmresage                             NO-UNDO.
DEF VAR log_cdcomchq LIKE crapage.cdcomchq                             NO-UNDO.
DEF VAR log_cdcxaage LIKE crapage.cdcxaage                             NO-UNDO.
DEF VAR log_cdccuage LIKE crapage.cdccuage                             NO-UNDO.
DEF VAR log_cdagetit LIKE crapage.cdagetit                             NO-UNDO.
DEF VAR log_cdagechq LIKE crapage.cdagechq                             NO-UNDO.
DEF VAR log_cdagedoc LIKE crapage.cdagedoc                             NO-UNDO.
DEF VAR log_cdorgpag LIKE crapage.cdorgpag                             NO-UNDO. 
DEF VAR log_tpagenci LIKE crapage.tpagenci                             NO-UNDO.
DEF VAR log_dsendcop LIKE crapage.dsendcop                             NO-UNDO.
DEF VAR log_dscomple LIKE crapage.dscomple                             NO-UNDO.
DEF VAR log_nmbairro LIKE crapage.nmbairro                             NO-UNDO.
DEF VAR log_nrcepend LIKE crapage.nrcepend                             NO-UNDO.
DEF VAR log_cdufdcop LIKE crapage.cdufdcop                             NO-UNDO.
DEF VAR log_nmcidade LIKE crapage.nmcidade                             NO-UNDO.
DEF VAR log_cdagecbn LIKE crapage.cdagecbn                             NO-UNDO.
DEF VAR log_cdbantit LIKE crapage.cdbantit                             NO-UNDO.
DEF VAR log_cdbanchq LIKE crapage.cdbanchq                             NO-UNDO.
DEF VAR log_cdbandoc LIKE crapage.cdbandoc                             NO-UNDO.
DEF VAR log_flgdopgd LIKE crapage.flgdopgd                             NO-UNDO.
DEF VAR log_cdageagr LIKE crapage.cdageagr                             NO-UNDO.
DEF VAR log_dtmvtolt LIKE crapbcx.dtmvtolt                             NO-UNDO.
DEF VAR log_nrdcaixa LIKE crapbcx.nrdcaixa                             NO-UNDO.
DEF VAR log_qtddaglf LIKE crapage.qtddaglf                             NO-UNDO.
DEF VAR log_qtmesage LIKE crapage.qtmesage                             NO-UNDO.
DEF VAR log_qtddlslf LIKE crapage.qtddlslf                             NO-UNDO.
DEF VAR log_vllimapv LIKE crapage.vllimapv                             NO-UNDO.
DEF VAR log_qtchqprv LIKE crapage.qtchqprv                             NO-UNDO.
DEF VAR log_nrtelfax LIKE crapage.nrtelfax                             NO-UNDO.
DEF VAR log_nrtelvoz LIKE crapage.nrtelvoz                             NO-UNDO.
DEF VAR log_flgdsede LIKE crapage.flgdsede                             NO-UNDO.
DEF VAR log_cdagectl LIKE crapage.cdagectl                             NO-UNDO.
DEF VAR log_cdagepac LIKE crapage.cdagepac                             NO-UNDO.
DEF VAR log_hrtitini AS INTE                                           NO-UNDO.
DEF VAR log_hrtitfim AS INTE                                           NO-UNDO.
DEF VAR log_hrtrfini AS INTE                                           NO-UNDO.
DEF VAR log_hrtrffim AS INTE                                           NO-UNDO.
DEF VAR log_hrbolini AS INTE                                           NO-UNDO.
DEF VAR log_hrbolfim AS INTE                                           NO-UNDO.
DEF VAR log_hrcapini AS INTE                                           NO-UNDO.
DEF VAR log_hrcapfim AS INTE                                           NO-UNDO.
DEF VAR log_hrcompel AS INTE                                           NO-UNDO.
DEF VAR log_hrdoctos AS INTE                                           NO-UNDO.
DEF VAR log_hrguigps AS INTE                                           NO-UNDO.
DEF VAR log_hrenvelo AS INTE                                           NO-UNDO.
DEF VAR log_hrcancel AS INTE                                           NO-UNDO.
                                                                   
DEF VAR log_dsinform AS CHAR FORMAT "x(40)" EXTENT 3                   NO-UNDO. 
DEF VAR log_dsdemail AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR log_flsgproc AS LOGI                                           NO-UNDO.
DEF VAR log_vercoban AS LOGI FORMAT "Sim/Nao"                          NO-UNDO.
DEF VAR log_cddregio LIKE crapreg.cddregio                             NO-UNDO.
DEF VAR log_tpageins LIKE crapage.tpageins                             NO-UNDO.
DEF VAR log_cdorgins LIKE crapage.cdorgins                             NO-UNDO.
DEF VAR log_vlminsgr LIKE crapage.vlminsgr                             NO-UNDO.
DEF VAR log_vlmaxsgr LIKE crapage.vlmaxsgr                             NO-UNDO.

DEF VAR log_hhsicini AS CHAR                                           NO-UNDO.
DEF VAR log_hhsicfim AS CHAR                                           NO-UNDO.
DEF VAR log_hhsiccan AS CHAR                                           NO-UNDO.

DEF VAR aux_hrtitini AS INTE                                           NO-UNDO.
DEF VAR aux_hrtitfim AS INTE                                           NO-UNDO.
DEF VAR aux_hrtrfini AS INTE                                           NO-UNDO.
DEF VAR aux_hrtrffim AS INTE                                           NO-UNDO.
DEF VAR aux_hrbolini AS INTE                                           NO-UNDO.
DEF VAR aux_hrbolfim AS INTE                                           NO-UNDO.
DEF VAR aux_hrcapini AS INTE                                           NO-UNDO.
DEF VAR aux_hrcapfim AS INTE                                           NO-UNDO.
DEF VAR aux_hrcompel AS INTE                                           NO-UNDO.
DEF VAR aux_hrdoctos AS INTE                                           NO-UNDO.
DEF VAR aux_hrguigps AS INTE                                           NO-UNDO.
DEF VAR aux_hrenvelo AS INTE                                           NO-UNDO.
DEF VAR aux_hrcancel AS INTE                                           NO-UNDO.
DEF VAR aux_cdsituac AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE FORMAT "z9"                               NO-UNDO.
                                                                   
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_loginusr AS CHAR                                           NO-UNDO.
DEF VAR aux_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR aux_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR aux_numipusr AS CHAR                                           NO-UNDO.
DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR aux_cddigag1 AS INT                                            NO-UNDO.
DEF VAR aux_cddigag2 AS INT                                            NO-UNDO.

/* Horário limite conv. SICREDI */
DEF VAR aux_hhsicini AS CHAR                                           NO-UNDO.
DEF VAR aux_hhsicfim AS CHAR                                           NO-UNDO.
DEF VAR aux_hhsiccan AS CHAR                                           NO-UNDO.
DEF VAR tel_hhsicini AS INTE                                           NO-UNDO.
DEF VAR tel_mmsicini AS INTE                                           NO-UNDO.
DEF VAR tel_hhsicfim AS INTE                                           NO-UNDO.
DEF VAR tel_mmsicfim AS INTE                                           NO-UNDO.
DEF VAR tel_hhsiccan AS INTE                                           NO-UNDO.
DEF VAR tel_mmsiccan AS INTE                                           NO-UNDO.

/* Horario Credito Pre Aprovado */
DEF VAR aux_hhcpaini AS CHAR                                           NO-UNDO.
DEF VAR aux_hhcpafim AS CHAR                                           NO-UNDO.
DEF VAR tel_hhcpaini AS INTE                                           NO-UNDO.
DEF VAR tel_mmcpaini AS INTE                                           NO-UNDO.
DEF VAR tel_hhcpafim AS INTE                                           NO-UNDO.
DEF VAR tel_mmcpafim AS INTE                                           NO-UNDO.

DEF VAR aux_recid    AS RECID                                          NO-UNDO.
                                                                   
DEF VAR aux_cdagecbn  LIKE crapage.cdagecbn                            NO-UNDO.
DEF VAR aux_cdagecbn2 LIKE crapage.cdagecbn                            NO-UNDO.

DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

DEF BUFFER crabage FOR crapage.

DEF QUERY bagenci-q FOR crapage.
DEF QUERY q-crapreg FOR tt-crapreg.
    

DEF BROWSE bagenci-b QUERY bagenci-q
    DISP SPACE(5)
         crapage.nmresage COLUMN-LABEL "Nome Abreviado"
         SPACE(3)
         crapage.cdagenci COLUMN-LABEL "Codigo"
         SPACE(5)
         WITH 9 DOWN OVERLAY.    

DEF BROWSE b-crapreg QUERY q-crapreg
    DISP tt-crapreg.cddsregi COLUMN-LABEL "Regionais" FORMAT "x(44)"
         WITH 9 DOWN NO-BOX.

FORM SKIP
     glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
         HELP "Informe a opcao desejada(A,C,I,B,X)."  
         VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                   glb_cddopcao = "I" OR glb_cddopcao = "B" OR
                   glb_cddopcao = "X", 
                   "014 - Opcao errada.")
     tel_cdagenci AT 20 LABEL "PA" 
         HELP "Informe o numero do PA ou pressione <F7> para listar todos."
     WITH SIDE-LABELS TITLE " Manutencao PA " ROW 4 COLUMN 1 OVERLAY 
     SIZE 80 BY 18 FRAME f_pac. 
     
FORM tel_nmextage AT 03 LABEL "Nome" 
                        HELP "Informe o nome do PA."
                        VALIDATE (tel_nmextage <> " ",
                                  "357 - O campo deve ser preenchido.")
     tel_insitage AT 50 LABEL "Sit. do PA"
                        HELP "0-Em obras, 1-Ativo ou 2-Inativo."
                        VALIDATE(tel_insitage < 3,"444 - Situacao errada.")
     "-"
     tel_dssitage NO-LABEL
     SKIP
     tel_nmresage AT 03 LABEL "Nome resumido"
                        HELP "Informe o nome resumido do PA."
                        VALIDATE (tel_nmresage <> " ",
                                  "357 - O campo deve ser preenchido.")
     tel_cdcxaage AT 49 LABEL "Codigo caixa"
                        HELP "Informe o codigo de caixa."
     SKIP(1)
     tel_tpagenci AT 03 LABEL "Agencia pioneira"
                        HELP  "Informe 0-convencional ou 1-pioneira."
     tel_cdccuage AT 52 LABEL "Centro de custo"
                        HELP  "Informe o codigo de centro de custo."
     SKIP
     tel_cdorgpag AT 06 LABEL "Orgao pagador"
                        HELP  "Informe numero do orgao pagador (INSS)."
     tel_cdagecbn AT 52 LABEL "Ag.relac. COBAN"
                        HELP  "Informe a agencia COBAN."
     SKIP
     tel_cdcomchq AT 04 LABEL "Codigo da COMPE"
                        HELP "Informe o codigo de compensacao."
                        VALIDATE (tel_cdcomchq <> 0 ,
                                 "357 - O campo deve ser preenchido.")
     tel_vercoban AT 47 LABEL "Verificar Pend.COBAN"  
                        HELP  "Informe se verifica pendencias com COBAN."
     SKIP(1)
     tel_cdbantit AT 04 LABEL "Banco compe TIT"
                        HELP  "Informe o codigo do banco de compensacao."
                        VALIDATE(CAN-FIND(crapban WHERE crapban.cdbccxlt = 
                                          INPUT tel_cdbantit),
                                          "057 - Banco nao cadastrado.")
     tel_cdagetit AT 54 LABEL "Ag. compe TIT"
                        HELP  "Informe a agencia de COMPE TIT."
     SKIP
     tel_cdbanchq AT 03 LABEL "Banco compe CHEQ"
                        HELP  "Informe o codigo do banco de compensacao."
                        VALIDATE(CAN-FIND(crapban WHERE crapban.cdbccxlt = 
                                          INPUT tel_cdbanchq),
                                          "057 - Banco nao cadastrado.")
     tel_cdagechq AT 53 LABEL "Ag. compe CHEQ"
                        HELP  "Informe a agencia de COMPE CHEQ."
     SKIP
     tel_cdbandoc AT 04 LABEL "Banco compe DOC"
                        HELP  "Informe o codigo do banco de compensacao."
                        VALIDATE(CAN-FIND(crapban WHERE crapban.cdbccxlt = 
                                          INPUT tel_cdbandoc),
                                          "057 - Banco nao cadastrado.")
     tel_cdagedoc AT 54 LABEL "Ag. compe DOC"
                        HELP  "Informe a agencia de COMPE DOC."
     SKIP(1)
     tel_flgdsede AT 11 LABEL "PA Sede"   
                        HELP  "Informe se o PA e sede da cooperativa."
     tel_cdagepac AT 53 LABEL "Agencia do PA" 
                        HELP  "Informe a agencia do PA."
    WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY WIDTH 78 FRAME f_pac01.

FORM tel_dsendcop AT 06 LABEL "Endereco" 
                        HELP  "Informe o endereco do PA."
     SKIP(1)
     tel_nmbairro AT 08 LABEL "Bairro"
                        HELP  "Informe o bairro do PA."
     SKIP(1)
     tel_dscomple AT 03 LABEL "Complemento"
                        HELP  "Informe o complemento do endereco do PA."
     SKIP(1)
     tel_nrcepend AT 11 LABEL "CEP"
                        HELP  "Informe o numero do CEP do PA."
     tel_nmcidade AT 29 LABEL "Cidade"
                        HELP  "Informe a cidade do PA."
     tel_cdufdcop AT 65 LABEL "UF" 
                        VALIDATE(CAN-DO("RS,SC,PR,SP,RJ,ES,MG,MS,MT,GO,DF," +
                                        "BA,PE,PA,PI,MA,RO,RR,AC,AM,TO,RN," +
                                        "CE,SE,AL,PB,AP",tel_cdufdcop),
                                        "033 - Unidade da federacao errada.")
                        HELP "Informe a sigla do Estado."

     SKIP(1)     
     tel_dsdemail AT 08 LABEL "E-mail"
                        HELP "Informe o enderego de e-mail do PA."
     SKIP(1) 
     tel_dsinform[1] AT 03 LABEL "Dados p/ impressao dos cheques"
     HELP "ESTA INFORMACAO SERA IMPRESSA NOS CHEQUES, ABAIXO DA LOGOMARCA"
     SKIP
     tel_dsinform[2] AT 35 NO-LABEL
     SKIP
     tel_dsinform[3] AT 35 NO-LABEL
     WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY WIDTH 78 FRAME f_pac02.
     
FORM tel_hhsicini AT 10 LABEL "Pagamentos Faturas Sicredi" AUTO-RETURN FORMAT "99"
                        HELP "Informe a hora inicial para pagamento de conv. SICREDI" 
                        VALIDATE(INPUT tel_hhsicini <= 23, "Hora invalida.")
     ":"          AT 40 
     tel_mmsicini AT 41 NO-LABEL FORMAT "99" 
                        HELP "Informe os minutos iniciais para pagamento de conv. SICREDI" 
                        VALIDATE(INPUT tel_mmsicini <= 59, "Minutos invalidos.")
     "ate"        AT 44
     tel_hhsicfim AT 48 NO-LABEL FORMAT "99"
                        HELP "Informe a hora final para pagamento de conv. SICREDI" 
                        VALIDATE(INPUT tel_hhsicfim <= 23, "Hora invalida.")
     ":"          AT 50
     tel_mmsicfim AT 51 NO-LABEL FORMAT "99"
                        HELP "Informe os minutos finais para pagamento de conv. SICREDI" 
                        VALIDATE(INPUT tel_mmsicfim <= 59, "Minutos invalidos.")
     "h"
     tel_hhtitini AT 10 LABEL "Pagamentos Titulos/Faturas" AUTO-RETURN
                  FORMAT "99" 
                  HELP "Informe a hora inicial do limite (10:00 a 19:59)."
     ":"          AT 40 
     tel_mmtitini AT 41 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "ate"        AT 44
     tel_hhtitfim AT 48 NO-LABEL FORMAT "99" 
                  HELP "Informe a hora final do limite (10:00 a 20:00)."
     ":"          AT 50
     tel_mmtitfim AT 51 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "h"
     tel_hhcompel AT 59 LABEL "Cheques" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora limite (10:00 a 20:00)."
     ":"          AT 70 
     tel_mmcompel AT 71 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "h"
     SKIP
     tel_hhcapini AT 14 LABEL "Plano Capital/Captacao" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora inicial do limite (06:00 a 22:59)."
     ":"          AT 40 
     tel_mmcapini AT 41 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "ate"        AT 44
     tel_hhcapfim AT 48 NO-LABEL FORMAT "99" 
                  HELP "Informe a hora final do limite (06:00 a 23:00)."
     ":"          AT 50
     tel_mmcapfim AT 51 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "h"     
     tel_hhdoctos AT 60 LABEL "Doctos" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora limite (10:00 a 20:00)."
     ":"          AT 70 
     tel_mmdoctos AT 71 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "h"
     SKIP
     tel_hhtrfini AT 23 LABEL "Transferencia" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora inicial do limite (06:00 a 22:59)."
     ":"          AT 40
     tel_mmtrfini AT 41 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "ate"        AT 44
     tel_hhtrffim AT 48 NO-LABEL FORMAT "99"
                  HELP "Informe a hora final do limite (06:00 a 23:00)."
     ":"          AT 50
     tel_mmtrffim AT 51 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "h"
     tel_hhguigps AT 57 LABEL "Guias GPS" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora limite (10:00 a 20:00)."
     ":"          AT 70 
     tel_mmguigps AT 71 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "h"
     SKIP    
     tel_hhbolini AT 02 LABEL "Geracao/Instrucoes Cob. Registrada"
                  FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora inicial do registro (06:00 a 22:59)."
     ":"          AT 40
     tel_mmbolini AT 41 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "ate"        AT 44
     tel_hhbolfim AT 48 NO-LABEL FORMAT "99"
                  HELP "Informe a hora final do registro (06:00 a 23:00)."
     ":"          AT 50
     tel_mmbolfim AT 51 NO-LABEL FORMAT "99"
                  HELP "Informe os minutos (0 a 59)."
     "h"
     tel_hhenvelo AT 57 LABEL "Depos.TAA" FORMAT "99" AUTO-RETURN
                  HELP "Informe a hora limite (10:00 a 20:00)."
     ":"          AT 70 
     tel_mmenvelo AT 71 NO-LABEL FORMAT "99" 
                  HELP "Informe os minutos (0 a 59)."
     "h"
     SKIP
     tel_hhcpaini AT 01 LABEL "Contratacao de Credito Pre-Aprovado" AUTO-RETURN FORMAT "99"
                        HELP "Informe a hora inicial para contratacao de Credito Pre-Aprovado" 
                        VALIDATE(INPUT tel_hhcpaini <= 23, "Hora invalida.")
     ":"          AT 40 
     tel_mmcpaini AT 41 NO-LABEL FORMAT "99" 
                        HELP "Informe os minutos iniciais para contratacao de Credito Pre-Aprovado" 
                        VALIDATE(INPUT tel_mmcpaini <= 59, "Minutos invalidos.")
     "ate"        AT 44
     tel_hhcpafim AT 48 NO-LABEL FORMAT "99"
                        HELP "Informe a hora final para contratacao de Credito Pre-Aprovado" 
                        VALIDATE(INPUT tel_hhcpafim <= 23, "Hora invalida.")
     ":"          AT 50
     tel_mmcpafim AT 51 NO-LABEL FORMAT "99"
                        HELP "Informe os minutos finais para contratacao de Credito Pre-Aprovado" 
                        VALIDATE(INPUT tel_mmcpafim <= 59, "Minutos invalidos.")
     "h"
     SKIP(1)
     "Cancelamento de pagamentos:   Horario:" AT 03
     tel_hhlimcan AT 42 NO-LABEL AUTO-RETURN        
                  HELP "Informe a hora limite para cancelamento de pagamentos."
     ":"          AT 44
     tel_mmlimcan AT 45 NO-LABEL 
                  HELP "Informe os minutos (0 a 59)." 
     "h"     
     tel_nrtelvoz AT 51 LABEL "Telefone" 
         HELP "Informe o numero do telefone."
     SKIP
     "Cancelamento pgto SICREDI:   Horario:" AT 04
     tel_hhsiccan AT 42 NO-LABEL AUTO-RETURN  FORMAT "99"      
                        HELP "Informe a hora limite para cancelamentos de pagtos SICREDI." 
                        VALIDATE(INPUT tel_hhsiccan <= 23 , "Hora invalida.")
     ":"          AT 44
     tel_mmsiccan AT 45 NO-LABEL FORMAT "99"
                        HELP "Informe o minuto limite para cancelamentos de pag. de conv. SICREDI" 
                        VALIDATE(INPUT tel_mmsiccan <= 59 , "Minutos invalidos.")
     "h"          
     tel_nrtelfax AT 56 LABEL "FAX" 
         HELP "Informe o numero do FAX para envio das solicitacoes."
     SKIP(1)
     "Parametros Agendamentos:" AT 06
     tel_qtddaglf AT 36 LABEL "Dias Agendamento" 
         FORMAT "zz9"
         HELP "Informe o numero de dias limite para agendamento"
     SKIP    
     tel_qtmesage AT 31 LABEL "Meses Agendt.Captacao" 
        FORMAT "zz9"
        HELP "Informe o numero de meses limite para agendamento"
     SKIP
     tel_qtddlslf AT 33 LABEL "Dias Lancto.Futuros" 
         FORMAT "zz9"
         HELP "Informe o numero de dias limite para listar lancamentos futuros"
     SKIP
     tel_flsgproc AT 37 LABEL "Processo Manual" 
         FORMAT "SIM/NAO"
         HELP "Informe se deve rodar o segundo processo p/ agendamentos"
     SKIP(1)
     WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY WIDTH 78 FRAME f_pac03.

FORM SKIP(1)
     tel_vllimapv AT 03 LABEL "Valor de Aprovacao do Comite Local" 
         FORMAT "zzz,zzz,zz9.99"
         HELP "Informe o valor de aprovacao do comite local."
     tel_qtchqprv AT 06 LABEL "Qtde Max. de Cheques por Previa"
         FORMAT "zz9"
         HELP "Informe a quantidade maxima de cheques por previa e por caixa."  
     SKIP(1)
     tel_flgdopgd AT 03 LABEL "Dados do PROGRID: PA participante"
         FORMAT "SIM/NAO" 
         HELP "<S> se o PA participa do Progrid ou <N> se nao participa."
     tel_cdageagr AT 50 LABEL "PA agrupador"
         HELP "Informe o PA concentrador da agenda do Progrid."
     SKIP(1)
     tel_cddregio AT 03 LABEL "Codigo da Regional"
         HELP "Informe o codigo da Regional ou <F7> para listar."
         VALIDATE (tel_cddregio = 0  OR 
                   CAN-FIND (crapreg WHERE crapreg.cdcooper = glb_cdcooper AND
                                           crapreg.cddregio = tel_cddregio),
                 "Codigo da Regional nao cadastrado.")
     tel_dsdregio AT 27 NO-LABEL FORMAT "x(50)"
     SKIP(1)
     tel_tpageins AT 03 LABEL "Convenio Sicredi: Agencia pioneira"
         FORMAT "z9"
         HELP "Entre com o tipo de agencia (0-Convencional, 1-Pioneira)"
     tel_cdorgins AT 24 LABEL "Orgao pagador"
         FORMAT "zzzzz9"
         HELP "Entre com o orgao pagador cadastrado junto ao INSS."
     SKIP(1)
     tel_vlminsgr AT 03 LABEL "Sangria de Caixa: Valor Minimo"
                        FORMAT "zzz,zzz,zz9.99" 
                        HELP "Informe o Valor minimo para sangria de caixa."
     SKIP
     tel_vlmaxsgr AT 21 LABEL "Valor Maximo"
                        FORMAT "zzz,zzz,zz9.99" 
                        HELP "Informe o Valor maximo para sangria de caixa."
                        VALIDATE(tel_vlmaxsgr <= 200000, "ATENCAO, limite " +
                                 "maximo permitido R$ 200.000,00.") 
     WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY WIDTH 78 FRAME f_pac04.

FORM SKIP (1)
     tel_nrdcaixa  AT 10 LABEL "Nro Caixa"
                         HELP "Informe o numero do caixa."
                         VALIDATE (tel_nrdcaixa <> 0 ,
                                  "357 - O campo deve ser preenchido.")
     SKIP (1)
     tel_cdopecxa  AT 10 LABEL "Operador                 " 
                         HELP "Informe o codigo do operador."
                         VALIDATE (tel_cdopecxa <> " ",
                                   "357 - O campo deve ser preenchido.")
     SKIP (1)
     tel_dtmvtolt  AT 10 LABEL "Data abertura caixa      "
                         HELP "Data Anterior ao inicio de utilizacao do Caixa"
                         VALIDATE (tel_dtmvtolt <> " ",
                                   "357 - O campo deve ser preenchido.")
     SKIP (1)
     WITH SIDE-LABELS TITLE " Manutencao Boletim de Caixa "
     ROW 12 COLUMN 2 OVERLAY WIDTH 78 FRAME f_boletim.

FORM SKIP (1)
     tel_vllimapv AT 03 LABEL "Valor de Aprovacao do Comite Local" 
         FORMAT "zzz,zzz,zz9.99"
         HELP "Informe o valor de aprovacao do comite local."
     SKIP (1)
     WITH SIDE-LABELS TITLE "Manutencao de Aprovacao do Comite Local"
     ROW 12 COLUMN 2 OVERLAY WIDTH 78 FRAME f_aprova.
     
FORM b-crapreg
        HELP "Use as SETAS para navegar e <F4> para sair"
     WITH OVERLAY ROW 7 WIDTH 50 COLUMN 29 FRAME f_crapreg. 

DEF FRAME f_zoom_pac
          bagenci-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

ON RETURN OF bagenci-b DO:

    IF  AVAILABLE crapage  THEN
        DO:
            tel_cdagenci = crapage.cdagenci.
            APPLY "GO".
        END.
END.

ON LEAVE OF tel_insitage DO:

    tel_dssitage = IF  INPUT tel_insitage = 0  THEN
                       "EM OBRAS"
                   ELSE
                   IF  INPUT tel_insitage = 1  THEN
                       "ATIVO"
                   ELSE
                       "INATIVO".

    DISPLAY tel_dssitage WITH FRAME f_pac01.

END. 

ON LEAVE OF tel_cdagecbn DO:     
   
    IF  glb_cddopcao = "A" THEN 
        DO:
            ASSIGN aux_cdagecbn  = INPUT tel_cdagecbn
                   aux_cdagecbn2 = crapage.cdagecbn.
 
            IF  (aux_cdagecbn <> aux_cdagecbn2) AND aux_cdagecbn <> 0  THEN 
                DO:
                    ASSIGN  tel_vercoban = TRUE.
                    DISPLAY tel_vercoban WITH FRAME f_pac01. 
                END.
            ELSE 
            IF  aux_cdagecbn = 0  THEN
                DO:
                    DISABLE tel_vercoban WITH FRAME f_pac01.
                    ASSIGN  tel_vercoban = FALSE.
                    DISPLAY tel_vercoban WITH FRAME f_pac01.

                END.
        END.
            
    IF  glb_cddepart <> 20 AND  /* TI                     */
        glb_cddepart <>  4 AND  /* COMPE                  */
        glb_cddepart <> 18 AND  /* SUPORTE                */
        glb_cddepart <>  8 AND  /* COORD.ADM/FINANCEIRO   */
        glb_cddepart <> 10 AND  /* DESENVOLVIMENTO CECRED */
        glb_cddepart <> 1  THEN /* CANAIS                 */
        DISABLE tel_vercoban WITH FRAME f_pac01.
       
END.


ON ENTRY, RETURN , GO OF tel_cddregio IN FRAME f_pac04 DO:

    FIND crapreg WHERE crapreg.cdcooper = glb_cdcooper       AND
                       crapreg.cddregio = INPUT tel_cddregio
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapreg   THEN
         ASSIGN tel_dsdregio = crapreg.dsdregio.        
    ELSE
         ASSIGN tel_dsdregio = "".

    DISPLAY tel_dsdregio 
            WITH FRAME f_pac04.

END.

ON RETURN OF b-crapreg IN FRAME f_crapreg DO:

    IF  NOT AVAIL tt-crapreg   THEN
        RETURN.

    ASSIGN tel_cddregio = tt-crapreg.cddregio
           tel_dsdregio = tt-crapreg.dsdregio.

    DISPLAY tel_cddregio
            tel_dsdregio 
            WITH FRAME f_pac04.

    APPLY "GO".

END.


RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:      

    NEXT-PROMPT tel_cdagenci WITH FRAME f_pac.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao 
               tel_cdagenci 
               WITH FRAME f_pac

        EDITING:

            READKEY.
      
            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:
                    IF  FRAME-FIELD = "tel_cdagenci"  THEN
                        DO:
                            OPEN QUERY bagenci-q 
                                 FOR EACH crapage WHERE
                                          crapage.cdcooper = glb_cdcooper 
                                          NO-LOCK BY crapage.nmresage.
   
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                UPDATE bagenci-b 
                                       WITH FRAME f_zoom_pac.

                                LEAVE.

                            END. /** Fim do DO WHILE TRUE **/

                            CLOSE QUERY bagenci-q.
   
                            HIDE FRAME f_zoom_pac NO-PAUSE.

                            DISPLAY tel_cdagenci 
                                    WITH FRAME f_pac.

                            APPLY "GO" TO tel_cdagenci.

                            PAUSE(0).
                        END.
                END.
            ELSE
                APPLY LASTKEY.
       
        END. /** Fim do EDITING **/

        LEAVE.
     
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "CADPAC"  THEN
                DO:
                    HIDE FRAME f_pac NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.

        END.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN glb_cdcritic = 651.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
            NEXT.

        END.
    
    IF (tel_cdagenci = 90 OR 
        tel_cdagenci = 91)    AND
        glb_cddopcao <> "C"   AND
        glb_cddepart <> 20    AND  /* TI                   */
        glb_cddepart <> 18    AND  /* SUPORTE              */
        glb_cddepart <>  8    AND  /* COORD.ADM/FINANCEIRO */
        glb_cddepart <>  9    AND  /* COORD.PRODUTOS       */
        glb_cddepart <>  4   THEN  /* COMPE                */
        DO:
            BELL.
            MESSAGE "PA 90 ou PA 91 podem ser alterados pelos deptos. TI,".
            MESSAGE "SUPORTE, COORD.ADM/FIN., COORD.PROD e COMPE.".
            NEXT.

        END.
         
    IF  glb_cddopcao = "A"  THEN
        DO:
            { includes/cadpaca.i }  
        END.
    ELSE 
      IF  glb_cddopcao = "C"  THEN
          DO:
              { includes/cadpacc.i } 
          END. 
      ELSE
        IF  glb_cddopcao = "I"  THEN
            DO:              
                { includes/cadpaci.i } 
            END.  
        ELSE
          IF  glb_cddopcao = "B"  THEN
              DO:              
                  { includes/cadpacb.i }
              END.  
         
    IF  glb_cddopcao = "X"  THEN
        DO:
           IF NOT  crapcop.flgcmtlc  THEN
              DO:
                  BELL.
                  MESSAGE "Comite Local nao cadastrado !".
                  NEXT.

              END.
            
            { includes/cadpacx.i }
             
        END.        

    ASSIGN tel_cdagenci = 0. 

END. /** Fim do DO WHILE TRUE **/

PROCEDURE gera_log_cadpac:

   IF glb_cddopcao = "X"  THEN 
      DO:
          RUN item_log (INPUT "", 
                        INPUT log_vllimapv, 
                        INPUT crapage.vllimapv).

      END.    
   ELSE
      IF glb_cddopcao = "A"  OR
         glb_cddopcao = "I"  THEN
         DO: 
             RUN item_log (INPUT "nome", 
                           INPUT log_nmextage, 
                           INPUT crapage.nmextage).
      
             RUN item_log (INPUT "situacao", 
                           INPUT STRING(log_insitage), 
                           INPUT STRING(crapage.insitage)).
      
             RUN item_log (INPUT "nome resumido", 
                           INPUT log_nmresage, 
                           INPUT crapage.nmresage).
      
             RUN item_log (INPUT "codigo caixa", 
                           INPUT STRING(log_cdcxaage), 
                           INPUT STRING(crapage.cdcxaage)).
      
             RUN item_log (INPUT "agencia pioneira", 
                           INPUT STRING(log_tpagenci), 
                           INPUT STRING(crapage.tpagenci)).
      
             RUN item_log (INPUT "centro custo", 
                           INPUT STRING(log_cdccuage), 
                           INPUT STRING(crapage.cdccuage)).
      
             RUN item_log (INPUT "orgao pagador", 
                           INPUT STRING(log_cdorgpag), 
                           INPUT STRING(crapage.cdorgpag)).
      
             RUN item_log (INPUT "agencia coban", 
                           INPUT STRING(log_cdagecbn), 
                           INPUT STRING(crapage.cdagecbn)).
      
             RUN item_log (INPUT "ver.pendencia coban", 
                           INPUT STRING(log_vercoban,"SIM/NAO"), 
                           INPUT STRING(crapage.vercoban,"SIM/NAO")).
      
             RUN item_log (INPUT "codigo compe", 
                           INPUT STRING(log_cdcomchq), 
                           INPUT STRING(crapage.cdcomchq)).
      
             RUN item_log (INPUT "banco compe titulos", 
                           INPUT STRING(log_cdbantit), 
                           INPUT STRING(crapage.cdbantit)).
      
             RUN item_log (INPUT "banco compe cheques", 
                           INPUT STRING(log_cdbanchq), 
                           INPUT STRING(crapage.cdbanchq)).
      
             RUN item_log (INPUT "banco compe docs", 
                           INPUT STRING(log_cdbandoc), 
                           INPUT STRING(crapage.cdbandoc)).
      
             RUN item_log (INPUT "agencia compe titulos", 
                           INPUT STRING(log_cdagetit), 
                           INPUT STRING(crapage.cdagetit)).
      
             RUN item_log (INPUT "agencia compe cheques", 
                           INPUT STRING(log_cdagechq), 
                           INPUT STRING(crapage.cdagechq)).
      
             RUN item_log (INPUT "agencia compe docs", 
                           INPUT STRING(log_cdagedoc), 
                           INPUT STRING(crapage.cdagedoc)).
      
             RUN item_log (INPUT "endereco", 
                           INPUT log_dsendcop, 
                           INPUT crapage.dsendcop).
      
             RUN item_log (INPUT "bairro", 
                           INPUT log_nmbairro, 
                           INPUT crapage.nmbairro).
      
             RUN item_log (INPUT "complemento", 
                           INPUT log_dscomple, 
                           INPUT crapage.dscomple).
      
             RUN item_log (INPUT "cep", 
                           INPUT STRING(log_nrcepend,"99999,999"), 
                           INPUT STRING(crapage.nrcepend,"99999,999")).
      
             RUN item_log (INPUT "cidade", 
                           INPUT log_nmcidade, 
                           INPUT crapage.nmcidade).
      
             RUN item_log (INPUT "UF", 
                           INPUT log_cdufdcop, 
                           INPUT crapage.cdufdcop).
      
             RUN item_log (INPUT "e-mail", 
                           INPUT log_dsdemail, 
                           INPUT crapage.dsdemail).
      
             RUN item_log (INPUT "dados impressao cheques", 
                           INPUT log_dsinform[1] + log_dsinform[2] + 
                                 log_dsinform[3], 
                           INPUT crapage.dsinform[1] + crapage.dsinform[2] + 
                                 crapage.dsinform[3]).
      
             RUN item_log (INPUT "horario inicial titulos", 
                           INPUT STRING(log_hrtitini,"HH:MM"), 
                           INPUT STRING(aux_hrtitini,"HH:MM")).
      
             RUN item_log (INPUT "horario final titulos", 
                           INPUT STRING(log_hrtitfim,"HH:MM"), 
                           INPUT STRING(aux_hrtitfim,"HH:MM")).
      
             RUN item_log (INPUT "horario cheques", 
                           INPUT STRING(log_hrcompel,"HH:MM"), 
                           INPUT STRING(aux_hrcompel,"HH:MM")).
      
             RUN item_log (INPUT "horario inicial capital/captacao", 
                           INPUT STRING(log_hrcapini,"HH:MM"), 
                           INPUT STRING(aux_hrcapini,"HH:MM")).
      
             RUN item_log (INPUT "horario final capital/captacao", 
                           INPUT STRING(log_hrcapfim,"HH:MM"), 
                           INPUT STRING(aux_hrcapfim,"HH:MM")).
      
             RUN item_log (INPUT "horario doctos", 
                           INPUT STRING(log_hrdoctos,"HH:MM"), 
                           INPUT STRING(aux_hrdoctos,"HH:MM")).
      
             RUN item_log (INPUT "horario inicial transferencia", 
                           INPUT STRING(log_hrtrfini,"HH:MM"), 
                           INPUT STRING(aux_hrtrfini,"HH:MM")).
      
             RUN item_log (INPUT "horario final transferencia", 
                           INPUT STRING(log_hrtrffim,"HH:MM"), 
                           INPUT STRING(aux_hrtrffim,"HH:MM")).
      
             RUN item_log (INPUT "horario inicial geracao boletos", 
                           INPUT STRING(log_hrbolini,"HH:MM"), 
                           INPUT STRING(aux_hrbolini,"HH:MM")).
      
             RUN item_log (INPUT "horario final geracao boletos",
                           INPUT STRING(log_hrbolfim,"HH:MM"),
                           INPUT STRING(aux_hrbolfim,"HH:MM")).
      
             RUN item_log (INPUT "horario gps", 
                           INPUT STRING(log_hrguigps,"HH:MM"), 
                           INPUT STRING(aux_hrguigps,"HH:MM")).
      
             RUN item_log (INPUT "horario envelopes",
                           INPUT STRING(log_hrenvelo,"HH:MM"), 
                           INPUT STRING(aux_hrenvelo,"HH:MM")).
      
             RUN item_log (INPUT "horario cancelamento pagamentos", 
                           INPUT STRING(log_hrcancel,"HH:MM"), 
                           INPUT STRING(crapage.hrcancel,"HH:MM")).
      
             RUN item_log (INPUT "fax cancelamento pagamentos", 
                           INPUT log_nrtelfax, 
                           INPUT crapage.nrtelfax).
             
             RUN item_log (INPUT "Telefone agencia", 
                           INPUT log_nrtelvoz, 
                           INPUT crapage.nrtelvoz).
      
             RUN item_log (INPUT "limite dias agendamento", 
                           INPUT STRING(log_qtddaglf), 
                           INPUT STRING(crapage.qtddaglf)).
      
             RUN item_log (INPUT "limite dias lancto.futuros", 
                           INPUT STRING(log_qtddlslf), 
                           INPUT STRING(crapage.qtddlslf)).
      
             RUN item_log (INPUT "processo manual", 
                           INPUT STRING(log_flsgproc,"SIM/NAO"), 
                           INPUT STRING(tel_flsgproc,"SIM/NAO")).
      
             RUN item_log (INPUT "valor aprovacao comite", 
                     INPUT TRIM(STRING(log_vllimapv,"zzz,zzz,zzz,zz9.99")), 
                     INPUT TRIM(STRING(crapage.vllimapv,"zzz,zzz,zzz,zz9.99"))).
      
             RUN item_log (INPUT "qtd. max. de cheques por previa", 
                     INPUT TRIM(STRING(log_qtchqprv,"zz9")), 
                     INPUT TRIM(STRING(crapage.qtchqprv,"zz9"))).
      
      
             RUN item_log (INPUT "participa progrid", 
                           INPUT STRING(log_flgdopgd,"SIM/NAO"), 
                           INPUT STRING(crapage.flgdopgd,"SIM/NAO")).
      
             RUN item_log (INPUT "pa agrupador progrid", 
                           INPUT STRING(log_cdageagr), 
                           INPUT STRING(crapage.cdageagr)).
      
             RUN item_log (INPUT "Codigo da Regional",
                           INPUT STRING(log_cddregio),
                           INPUT STRING(crapage.cddregio)).      
      
             RUN item_log (INPUT "Convenio Sicredi: Agencia pioneira",
                           INPUT STRING(log_tpageins),
                           INPUT STRING(crapage.tpageins)).

             RUN item_log (INPUT "Orgao pagador",
                           INPUT STRING(log_cdorgins),
                           INPUT STRING(crapage.cdorgins)).

             RUN item_log (INPUT "Agencia do PA",
                           INPUT STRING(LOG_cdagepac),
                           INPUT STRING(crapage.cdagepac)).

             RUN item_log (INPUT "PA sede", 
                           INPUT STRING(log_flgdsede,"SIM/NAO"), 
                           INPUT STRING(crapage.flgdsede,"SIM/NAO")).

             RUN item_log (INPUT "Valor minimo sangria",
                           INPUT STRING(log_vlminsgr),
                           INPUT STRING(crapage.vlminsgr)).

             RUN item_log (INPUT "Valor maximo sangria",
                           INPUT STRING(log_vlmaxsgr),
                           INPUT STRING(crapage.vlmaxsgr)).

             RUN item_log (INPUT "Horario inicio pagamentos faturas sicredi",
                           INPUT STRING(log_hhsicini),
                           INPUT STRING(aux_hhsicini)).

             RUN item_log (INPUT "Horario fim pagamentos faturas sicredi",
                           INPUT STRING(log_hhsicfim),
                           INPUT STRING(aux_hhsicfim)).

             RUN item_log (INPUT "Horario cancelamento faturas sicredi",
                           INPUT STRING(log_hhsiccan),
                           INPUT STRING(aux_hhsiccan)).
      
         END.  

END PROCEDURE.

PROCEDURE item_log:

    DEF  INPUT PARAM par_dsdcampo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldantes AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldepois AS CHAR                           NO-UNDO.  

    
    IF (glb_cddopcao = "A") AND 
        par_vldepois = par_vldantes               THEN
        RETURN.
  
    ASSIGN par_vldepois = "---" WHEN par_vldepois = ""
           par_vldantes = "---" WHEN par_vldantes = ""
           par_vldepois = REPLACE(REPLACE(par_vldepois,"("," "),")","-")
           par_vldantes = REPLACE(REPLACE(par_vldantes,"("," "),")","-").
         
    IF glb_cddopcao = "A"  THEN
       UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                         STRING(TIME,"HH:MM:SS") + " '-->' Operador "        +
                         glb_cdoperad + " alterou o campo " + par_dsdcampo   +
                         " de " + par_vldantes + " para " + par_vldepois     + 
                         " no PA " + STRING(tel_cdagenci)                   + 
                         " >> log/cadpac.log").
    ELSE
      IF glb_cddopcao = "I"  THEN
         UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                           STRING(TIME,"HH:MM:SS") + " '-->' Operador "        +
                           glb_cdoperad + " incluiu o campo " + par_dsdcampo   +
                           " com o valor " + par_vldepois + " no PA "         + 
                           STRING(tel_cdagenci) + " >> log/cadpac.log").
      ELSE
        IF glb_cddopcao = "X"  THEN
           UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") 
                             + " - " + STRING(TIME,"HH:MM:SS")                + 
                             " '-->' Operador " + glb_cdoperad                + 
                             " alterou o campo Valor de Aprovacao"            +
                             " do Comite Local de "                           + 
                             STRING(DEC(par_vldantes),"zzz,zzz,zz9.99")       +
                             " para "                                         + 
                             STRING(DEC(par_vldepois),"zzz,zzz,zz9.99")       +
                             " no PA " + STRING(tel_cdagenci)                +
                             " >> log/cadpac.log").

END PROCEDURE.

PROCEDURE Busca_Crapreg:

    EMPTY TEMP-TABLE tt-crapreg.
    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_crapreg_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/           
                                            INPUT 0, /*codigo da agencia*/                        
                                            INPUT 0, /*Numero do caixa*/                        
                                            INPUT 1, /*idorigem*/
                                            INPUT glb_cdoperad, /*codigo do operador*/                          
                                            INPUT glb_nmdatela, /*nome da tela*/                                                                                            
                                            INPUT glb_dtmvtolt, /*Nome do Avalista*/ 
                                            INPUT 0,
                                            INPUT 1, /*nriniseq*/
                                            INPUT 9999, /*nrregist*/
                                           OUTPUT "", /*Nome do Campo*/                
                                           OUTPUT "", /*Saida OK/NOK*/                          
                                           OUTPUT ?, /*Tabela Regionais*/                       
                                           OUTPUT 0, /*Codigo da critica*/                      
                                           OUTPUT ""). /*Descricao da critica*/ 
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_crapreg_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_crapreg_car.pr_cdcritic 
                          WHEN pc_busca_crapreg_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_crapreg_car.pr_dscritic 
                          WHEN pc_busca_crapreg_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1,          /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          MESSAGE aux_dscritic.          
          PAUSE 3 NO-MESSAGE.
          RETURN "NOK".
       
       END.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_crapreg_car.pr_clob_ret.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
     
    IF ponteiro_xml <> ? THEN
       DO:   
          xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
          xDoc:GET-DOCUMENT-ELEMENT(xRoot).
             
          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
             
             xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
     
             IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
           
             IF xRoot2:NUM-CHILDREN > 0 THEN
                DO:
             
                    CREATE tt-crapreg.

                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField:GET-CHILD(xText,1).

                ASSIGN tt-crapreg.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper".                
                ASSIGN tt-crapreg.cddregio = INT(xText:NODE-VALUE) WHEN xField:NAME = "cddregio".
                ASSIGN tt-crapreg.cddsregi = xText:NODE-VALUE WHEN xField:NAME = "cddsregi".
                ASSIGN tt-crapreg.dsoperad = xText:NODE-VALUE WHEN xField:NAME = "dsoperad".
                ASSIGN tt-crapreg.dsdregio = xText:NODE-VALUE WHEN xField:NAME = "dsdregio".
                ASSIGN tt-crapreg.cdopereg = xText:NODE-VALUE WHEN xField:NAME = "cdopereg".
                ASSIGN tt-crapreg.nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad".
                ASSIGN tt-crapreg.dsdemail = xText:NODE-VALUE WHEN xField:NAME = "dsdemail".
                                                                    

             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml) = 0. 
  
       END.
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
   
    HIDE MESSAGE NO-PAUSE.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Crapreg */

/*............................................................................*/

