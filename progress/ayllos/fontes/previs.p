/* ............................................................................

   Programa: Fontes/previs.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo       
   Data    : Outubro/2000                       Ultima atualizacao: 14/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PREVIS.

   Alteracao : 01/11/2000 - Erro ao calcular os totais e sub-totais (Eduardo).

               18/05/2001 - Acumular valores capturados dos titulos e cheques
                            acolhidos (Edson).
                            
               07/06/2001 - Incluir o KEYCODE(".") na digitacao dos valores.
                            (Ze Eduardo). 

               09/07/2001 - Alterado para ignorar os cheques com situacao igual
                            a 3 (comp. terceiros) - Edson.

               26/07/2001 - Alterado para tratar apenas os cheques de custodia
                            processados: insitchq = 2 (Edson).
               
               08/10/2004 - Tratar desconto de cheques (Edson).
               
               27/01/2005 - Mudado o HELP do campo "tel_cdagenci" de
                            "Informe a agencia" para "Informe o PAC";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapprv (Diego).

               31/01/2006 - Unififcacao dos Bancos - SQLWorks - Fernando 

               16/03/2010 - Inclusao da opcao "F" e consultar deb/cre DEV, DOC,
                            TED/TEC, TIT e CHQ. (Guilherme/Supero)
                            Alterado para que, quando for F e Coop CECRED,
                            apresente os valores de 085 calculados para todas
                            as COOP, exceto 3. (Guilherme/Supero)
                            
               17/11/2010 - Incluir opcao "F" para consultas do PAC 90 e 91 (Ze)
                            Incluir opcao "L" (Guilherme/Supero).

               15/02/2011 - Opcao "L"  - Processar as mesmas tabelas que a 
                            opcao "F" (Guilherme/Supero).

               23/02/2011 - Opcao "F" - Incluir combo de Coop logada e Todas
                           (Guilherme/Supero).
               05/04/2011 - Acertar atualizacao das TECS, passar a somar
                            pelo historico quando nossa IF (Magui).
                            
               18/04/2011 - Eliminar na somatoria para opcao L as devolucoes nr
                            do BB e Bancoob (Ze).
                            
               20/07/2011 - Tratamento para a opcao L - Tarefa 41364 (Ze).
               
               03/11/2011 - Inclusão da moeda de R$ 1,00 e as cédulas de 
                            R$ 20,00 e R$ 100,00 (Isara - RKAM)
                            
               09/12/2011 - Incluido informacoes de transferencia entre 
                            cooperativas (Elton).
                            
               19/12/2011 - Adaptado para o uso de BO. (Gabriel Capoia - DB1)
               
               17/04/2012 - Retirado chamada para o banco generico e substituido
                            fonte do programa previs.p pelo previsp.p (Elton).               
                            
               01/08/2012 - Criacao dos frames de Fluxo(Entrada, Saida, 
                            Resultado) (Tiago).
                            
               13/08/2012 - Ajustes referente ao projeto Fluxo Financeiro
                            (Adriano).
                            
               12/12/2012 - Tornar o campo do Mvto.Cta.ITG habilitado para
                            edição (Lucas).
                            
               14/03/2013 - Desabilitar o campo Mvto.Cta.ITG para edicao
                            (Adriano).             
              
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).           
 ............................................................................ */

{ sistema/generico/includes/b1wgen0131tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF VAR h-b1wgen0131 AS HANDLE                                         NO-UNDO.
DEF STREAM str_1.                                                      
                                                                       
DEF VAR tel_cdmovmto AS CHAR     INIT "E"   FORMAT "!(1)"              NO-UNDO.
DEF VAR tel_vldepesp AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vldvlnum AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vldvlbcb AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vlremdoc AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vlremtit AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
                                                                       
DEF VAR tel_qtremdoc AS INTE                FORMAT "zzz,zz9"           NO-UNDO.
DEF VAR tel_qtremtit AS INTE                FORMAT "zzz,zz9"           NO-UNDO.
DEF VAR tel_qtdvlbcb AS INTE                FORMAT "zzz,zz9"           NO-UNDO.
                                                                       
DEF VAR tel_qtmoedas AS INTE      EXTENT 6  FORMAT "zz9"               NO-UNDO.
DEF VAR tel_qtdnotas AS INTE      EXTENT 6  FORMAT "zzz,zz9"           NO-UNDO.
DEF VAR tel_dtmvtolt AS DATE                FORMAT "99/99/9999"        NO-UNDO.
DEF VAR tel_cdagenci AS INTE                FORMAT "z9"                NO-UNDO.
DEF VAR tel_vlmoedas AS DECI      EXTENT 6  FORMAT "zzz,zz9.99"        NO-UNDO.
DEF VAR tel_vldnotas AS DECI      EXTENT 6  FORMAT "zzz,zz9.99"        NO-UNDO.
DEF VAR tel_submoeda AS DECI      EXTENT 6  FORMAT "zzz,zz9.99"        NO-UNDO.
DEF VAR tel_subnotas AS DECI      EXTENT 6  FORMAT "zzz,zz9.99"        NO-UNDO.
DEF VAR tel_totmoeda AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_totnotas AS DECI                FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_nmoperad AS CHAR                FORMAT "x(30)"             NO-UNDO.
DEF VAR tel_hrtransa AS CHAR                FORMAT "x(08)"             NO-UNDO.
                                                                       
DEF VAR aux_qtmoepct AS INTE      EXTENT 6  FORMAT "zz9"               NO-UNDO.
DEF VAR aux_contador AS INTE                FORMAT "z9"                NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
                                                                     
DEF VAR tel_vlttcrdb AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
                                                                     
DEF VAR tel_vlcobbil AS DECI      FORMAT "zzz,zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF VAR tel_vlcobmlt AS DECI      FORMAT "zzz,zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF VAR tel_vlchqnot AS DECI      FORMAT "zzz,zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF VAR tel_vlchqdia AS DECI      FORMAT "zzz,zzz,zzz,zzz,zz9.99-"     NO-UNDO.
                                                                     
DEF VAR tel_cdbcoval AS CHAR      EXTENT 4                             NO-UNDO.
DEF VAR tel_vlcheque AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vltotdoc AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vltotted AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vltottit AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vldevolu AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlmvtitg AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlttinss AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vltrdeit AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlsatait AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vldivers AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlrepass AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlrfolha AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlnumera AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vloutros AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlfatbra AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlconven AS DECI      EXTENT 4  FORMAT "zzzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_vlresult AS DECI EXTENT 3  FORMAT "zz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR tel_vlentcen AS DECI EXTENT 3  FORMAT "zz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR tel_vlsaicen AS DECI EXTENT 3  FORMAT "zz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR tel_vlentrad AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF VAR tel_vlsaidas AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF VAR tel_vlsldcta AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF VAR tel_vlresgat AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vlaplica AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_vlsldfin AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF VAR tel_vltotcen AS DECI           FORMAT "zzzz,zzz,zzz,zz9.99-"   NO-UNDO.
                                                                       
DEF VAR tel_vlrmovto AS DECI          FORMAT "zzz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR tel_dscmovto AS CHAR                FORMAT "x(10)"             NO-UNDO.
DEF VAR tel_totmovto AS DECI          FORMAT "zzz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR tel_nmcooper AS CHAR                FORMAT "x(20) "            NO-UNDO.
DEF VAR aux_flgsenha AS LOG                                            NO-UNDO.
DEF VAR aux_permiace AS LOG                                            NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                           NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_hrpermit AS LOG                                            NO-UNDO.
DEF VAR aux_vlresgan AS DEC  FORMAT "zzzz,zzz,zzz,zz9.99"              NO-UNDO.
DEF VAR aux_vlaplian AS DEC  FORMAT "zzzz,zzz,zzz,zz9.99"              NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX          
                             INNER-LINES 10                            NO-UNDO.
DEF VAR tel_cdcoper2 AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX          
                             INNER-LINES 10                            NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao  AT 4 LABEL "Opcao" AUTO-RETURN 
                   HELP "Entre com a opcao desejada (A,C,F,I,L)" 
                    VALIDATE(CAN-DO("A,C,F,I,L",glb_cddopcao),
                                   "014 - Opcao errada.")
    WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_cdmovmto  AT 02 LABEL "Movimento"
                   HELP "Tipo movimento (E)ntrada (S)aida (R)esultado"
                   VALIDATE(CAN-DO("E,S,R",tel_cdmovmto),"014 - Opcao errada.")

     tel_dtmvtolt  AT 15 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_f.

FORM tel_cdmovmto  AT 02 LABEL "Movimento"
                   HELP "Tipo movimento (A)plicacao (E)ntrada (S)aida (R)esultado"
                   VALIDATE(CAN-DO("A,E,S,R",tel_cdmovmto),"014 - Opcao errada.")
     tel_dtmvtolt  AT 15 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_f_cecred.

FORM tel_cdcoper2        LABEL "Cooperativa" AUTO-RETURN
                         HELP "Selecione a Cooperativa"
     WITH OVERLAY ROW 6 COLUMN 50 SIDE-LABEL NO-BOX FRAME f_previs_f_cecred_coop.

FORM tel_dtmvtolt  AT 10 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."

     tel_cdagenci  AT 48 LABEL "Pa"
                   HELP "Pressione <F7> para Zoom ou '0' para Todos PAs"

     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_1.

FORM tel_dtmvtolt  AT  10 LABEL "Data de Liquidacao" AUTO-RETURN
                   HELP "Entre com a data de liquidacao."             
    WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_2.

FORM SKIP(1)
     "DEVOLUCAO"   AT 4           
     tel_vldepesp  AT 15 LABEL "Deposito Cooper"
     "TITULOS"     AT 48            
     "Qtd.:"       AT 57
     tel_qtremtit  AT 70 NO-LABEL 
     SKIP
     tel_vldvlnum  AT 21 LABEL "Numerario"  
     tel_vlremtit  AT 56 LABEL "Valor"
     SKIP
     tel_vldvlbcb  AT 17 LABEL "Cheques COMPE"  
     SKIP(1)
     "SUPRIMENTOS" AT 04           
     "Moedas"      AT 18
     "Pacotes"     AT 26
     "Total"       AT 38
     "Notas"       AT 52 
     "Quantid"     AT 59
     "Total"       AT 72 
     SKIP
     tel_vlmoedas[1]  AT 13  NO-LABEL
     tel_qtmoedas[1]  AT 28  NO-LABEL
     tel_submoeda[1]  AT 33  NO-LABEL
     tel_vldnotas[1]  AT 47  NO-LABEL
     tel_qtdnotas[1]  AT 59  NO-LABEL
     tel_subnotas[1]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[2]  AT 13  NO-LABEL
     tel_qtmoedas[2]  AT 28  NO-LABEL
     tel_submoeda[2]  AT 33  NO-LABEL
     tel_vldnotas[2]  AT 47  NO-LABEL
     tel_qtdnotas[2]  AT 59  NO-LABEL
     tel_subnotas[2]  AT 67  NO-LABEL
     SKIP     
     tel_vlmoedas[3]  AT 13  NO-LABEL
     tel_qtmoedas[3]  AT 28  NO-LABEL
     tel_submoeda[3]  AT 33  NO-LABEL
     tel_vldnotas[3]  AT 47  NO-LABEL
     tel_qtdnotas[3]  AT 59  NO-LABEL
     tel_subnotas[3]  AT 67  NO-LABEL
     SKIP     
     tel_vlmoedas[4]  AT 13  NO-LABEL
     tel_qtmoedas[4]  AT 28  NO-LABEL
     tel_submoeda[4]  AT 33  NO-LABEL
     tel_vldnotas[5]  AT 47  NO-LABEL
     tel_qtdnotas[5]  AT 59  NO-LABEL
     tel_subnotas[5]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[5]  AT 13  NO-LABEL
     tel_qtmoedas[5]  AT 28  NO-LABEL
     tel_submoeda[5]  AT 33  NO-LABEL
     tel_vldnotas[4]  AT 47  NO-LABEL
     tel_qtdnotas[4]  AT 59  NO-LABEL
     tel_subnotas[4]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[6]  AT 13  NO-LABEL
     tel_qtmoedas[6]  AT 28  NO-LABEL
     tel_submoeda[6]  AT 33  NO-LABEL
     tel_vldnotas[6]  AT 47  NO-LABEL
     tel_qtdnotas[6]  AT 59  NO-LABEL
     tel_subnotas[6]  AT 67  NO-LABEL
     SKIP
     "Totais:"      AT 04
     tel_totmoeda   AT 29 NO-LABEL
     tel_totnotas   AT 63 NO-LABEL
     SKIP
     tel_nmoperad   AT 04 LABEL "Operador" 
     tel_hrtransa   AT 58 NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs.
 
FORM SKIP
     tel_cdbcoval[1] AT 22 NO-LABEL
     tel_cdbcoval[2] AT 38 NO-LABEL
     tel_cdbcoval[3] AT 56 NO-LABEL
     tel_cdbcoval[4] AT 67 NO-LABEL
     SKIP
     "NR CHEQUES:"   AT 04
     tel_vlcheque[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlcheque[2] AT 32  NO-LABEL
     tel_vlcheque[3] AT 48  NO-LABEL
     tel_vlcheque[4] AT 64  NO-LABEL
     SKIP
     "SR DOC:"       AT 08
     tel_vltotdoc[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltotdoc[2] AT 32  NO-LABEL
     tel_vltotdoc[3] AT 48  NO-LABEL
     tel_vltotdoc[4] AT 64  NO-LABEL
     SKIP
     "SR TED:"       AT 08
     tel_vltotted[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltotted[2] AT 32  NO-LABEL
     tel_vltotted[3] AT 48  NO-LABEL
     tel_vltotted[4] AT 64  NO-LABEL
     SKIP
     "SR TITULOS:"   AT 04
     tel_vltottit[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltottit[2] AT 32  NO-LABEL
     tel_vltottit[3] AT 48  NO-LABEL
     tel_vltottit[4] AT 64  NO-LABEL
     SKIP
     "DEV CHEQ REM:" AT 02
     tel_vldevolu[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vldevolu[2] AT 32  NO-LABEL
     tel_vldevolu[3] AT 48  NO-LABEL
     tel_vldevolu[4] AT 64  NO-LABEL
     SKIP
     "MVTO CTA ITG:" AT 02
     tel_vlmvtitg[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlmvtitg[2] AT 32  NO-LABEL
     tel_vlmvtitg[3] AT 48  NO-LABEL
     tel_vlmvtitg[4] AT 64  NO-LABEL
     SKIP
     "INSS:"         AT 10
     tel_vlttinss[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlttinss[2] AT 32  NO-LABEL
     tel_vlttinss[3] AT 48  NO-LABEL
     tel_vlttinss[4] AT 64  NO-LABEL
     SKIP
     "TRF/DEP INTER:" AT 01
     tel_vltrdeit[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltrdeit[2] AT 32  NO-LABEL
     tel_vltrdeit[3] AT 48  NO-LABEL
     tel_vltrdeit[4] AT 64  NO-LABEL
     SKIP
     "SAQ TAA INTER:" AT 01
     tel_vlsatait[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlsatait[2] AT 32  NO-LABEL
     tel_vlsatait[3] AT 48  NO-LABEL
     tel_vlsatait[4] AT 64  NO-LABEL
     SKIP
     "DIVERSOS:"     AT 06
     tel_vldivers[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vldivers[2] AT 32  NO-LABEL
     tel_vldivers[3] AT 48  NO-LABEL
     tel_vldivers[4] AT 64  NO-LABEL 
     SKIP(2)
     "TOTAL CREDITO:"       AT 01
     tel_vlttcrdb[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlttcrdb[2] AT 32  NO-LABEL
     tel_vlttcrdb[3] AT 48  NO-LABEL
     tel_vlttcrdb[4] AT 64  NO-LABEL
     SKIP
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_entrada.

FORM SKIP
     tel_cdbcoval[1] AT 27 NO-LABEL
     tel_cdbcoval[2] AT 48 NO-LABEL
     tel_cdbcoval[3] AT 71 NO-LABEL
     SKIP
     "MVTO CTA ITG:" AT 03
     tel_vlmvtitg[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlmvtitg[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlmvtitg[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "NR CHEQUES:"   AT 05
     tel_vlcheque[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlcheque[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlcheque[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "SR DOC:"       AT 09
     tel_vltotdoc[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotdoc[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotdoc[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "SR TED:"       AT 09
     tel_vltotted[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotted[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotted[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "SR TITULOS:"   AT 05
     tel_vltottit[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltottit[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltottit[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "DEV CHEQ REM:" AT 03
     tel_vldevolu[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldevolu[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldevolu[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "INSS:"         AT 11
     tel_vlttinss[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttinss[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttinss[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "DIVERSOS:"     AT 07
     tel_vldivers[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldivers[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldivers[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP(2)
     "TOTAL CREDITO:" AT 2
     tel_vlttcrdb[1]  AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttcrdb[2]  AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttcrdb[3]  AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cecred_entrada.


FORM SKIP
     tel_cdbcoval[1] AT 22 NO-LABEL
     tel_cdbcoval[2] AT 38 NO-LABEL
     tel_cdbcoval[3] AT 56 NO-LABEL
     tel_cdbcoval[4] AT 67 NO-LABEL
     SKIP
     "SR CHEQUES:"   AT 04
     tel_vlcheque[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlcheque[2] AT 32  NO-LABEL
     tel_vlcheque[3] AT 48  NO-LABEL
     tel_vlcheque[4] AT 64  NO-LABEL
     SKIP
     "NR DOC:"       AT 08
     tel_vltotdoc[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltotdoc[2] AT 32  NO-LABEL
     tel_vltotdoc[3] AT 48  NO-LABEL
     tel_vltotdoc[4] AT 64  NO-LABEL
     SKIP
     "NR TED/TEC:"   AT 04
     tel_vltotted[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltotted[2] AT 32  NO-LABEL
     tel_vltotted[3] AT 48  NO-LABEL
     tel_vltotted[4] AT 64  NO-LABEL
     SKIP
     "NR TITULOS:"   AT 04
     tel_vltottit[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltottit[2] AT 32  NO-LABEL
     tel_vltottit[3] AT 48  NO-LABEL
     tel_vltottit[4] AT 64  NO-LABEL
     SKIP
     "DEV CHEQ REC:" AT 02
     tel_vldevolu[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vldevolu[2] AT 32  NO-LABEL
     tel_vldevolu[3] AT 48  NO-LABEL
     tel_vldevolu[4] AT 64  NO-LABEL
     SKIP
     "MVTO CTA ITG:" AT 02
     tel_vlmvtitg[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlmvtitg[2] AT 32  NO-LABEL
     tel_vlmvtitg[3] AT 48  NO-LABEL
     tel_vlmvtitg[4] AT 64  NO-LABEL
     SKIP
     "GPS:"          AT 11
     tel_vlttinss[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlttinss[2] AT 32  NO-LABEL
     tel_vlttinss[3] AT 48  NO-LABEL
     tel_vlttinss[4] AT 64  NO-LABEL
     SKIP
     "TRF/DEP INTER:" AT 01
     tel_vltrdeit[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vltrdeit[2] AT 32  NO-LABEL
     tel_vltrdeit[3] AT 48  NO-LABEL
     tel_vltrdeit[4] AT 64  NO-LABEL
     SKIP
     "SAQ TAA INTER:" AT 01
     tel_vlsatait[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlsatait[2] AT 32  NO-LABEL
     tel_vlsatait[3] AT 48  NO-LABEL
     tel_vlsatait[4] AT 64  NO-LABEL
     SKIP
     "CART BRADESCO:" AT 01
     tel_vlfatbra[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlfatbra[2] AT 32  NO-LABEL
     tel_vlfatbra[3] AT 48  NO-LABEL
     tel_vlfatbra[4] AT 64  NO-LABEL
     SKIP
     "CONVENIOS:"    AT 05
     tel_vlconven[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlconven[2] AT 32  NO-LABEL
     tel_vlconven[3] AT 48  NO-LABEL
     tel_vlconven[4] AT 64  NO-LABEL
     SKIP
     "DIVERSOS:"     AT 06
     tel_vldivers[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vldivers[2] AT 32  NO-LABEL
     tel_vldivers[3] AT 48  NO-LABEL
     tel_vldivers[4] AT 64  NO-LABEL 
     SKIP
     "TOTAL DEBITO:" AT 2
     tel_vlttcrdb[1] AT 15  NO-LABEL FORMAT "zzzzz,zzz,zz9.99"
     tel_vlttcrdb[2] AT 32  NO-LABEL
     tel_vlttcrdb[3] AT 48  NO-LABEL
     tel_vlttcrdb[4] AT 64  NO-LABEL
     SKIP
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_saida.

FORM SKIP
     "COOPERATIVA"   AT 04
     "OPERADOR"      AT 25
     "VALOR"         AT 59
     "MOVIMENTACAO"  AT 65
     SKIP(1)
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX 
                                 FRAME f_cecred_investimento_cab.

FORM SKIP
     tel_nmcooper    AT 04  FORMAT "X(20)"NO-LABEL
     tel_nmoperad    AT 25  FORMAT "X(15)" NO-LABEL
     tel_vlrmovto    AT 41  NO-LABEL
     tel_dscmovto    AT 70  NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY DOWN SIDE-LABELS NO-BOX 
                                      FRAME f_cecred_investimento.


FORM SKIP
     tel_cdbcoval[1] AT 27 NO-LABEL 
     tel_cdbcoval[2] AT 48 NO-LABEL
     tel_cdbcoval[3] AT 71 NO-LABEL
     SKIP
     "MVTO CTA ITG:" AT 03
     tel_vlmvtitg[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlmvtitg[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlmvtitg[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "SR CHEQUES:"   AT 05
     tel_vlcheque[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlcheque[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlcheque[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "NR DOC:"       AT 09
     tel_vltotdoc[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotdoc[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotdoc[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "NR TED/TEC:"   AT 05
     tel_vltotted[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotted[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltotted[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "NR TITULOS:"   AT 05
     tel_vltottit[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltottit[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vltottit[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "DEV CHEQ REC:" AT 03
     tel_vldevolu[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldevolu[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldevolu[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "GPS:"          AT 12
     tel_vlttinss[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttinss[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttinss[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     "DIVERSOS:"     AT 07
     tel_vldivers[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldivers[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vldivers[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP(1)
     "TOTAL DEBITO:" AT 03
     tel_vlttcrdb[1] AT 16  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttcrdb[2] AT 37  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     tel_vlttcrdb[3] AT 58  NO-LABEL FORMAT "zzzzz,zzz,zzz,zz9.99"
     SKIP
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cecred_saida.


FORM SKIP(2)
     "ENTRADAS:"      AT 16
     tel_vlentrad     AT 25  NO-LABEL
     "INVESTIMENTOS:" AT 46  
     SKIP
     "RESGATE:"       AT 52  
     tel_vlresgat     AT 60  NO-LABEL
     SKIP
     "SAIDAS:"        AT 18  
     tel_vlsaidas     AT 25  NO-LABEL
     "APLICACAO:"     AT 50 
     tel_vlaplica     AT 60  NO-LABEL
     SKIP(1)
     "RESULTADO CENTRALIZACAO:" AT 1
     tel_vltotcen     AT 25  NO-LABEL
     SKIP(1)
     "SALDO C/C DIA ANTERIOR:"  AT 2
     tel_vlsldcta     AT 25  NO-LABEL 
     SKIP(1)
     "SALDO FINAL C/C:"         AT 9
     tel_vlsldfin     AT 25  NO-LABEL
     SKIP(1)
     tel_nmoperad   AT 16 LABEL "Operador" 
     tel_hrtransa   AT 69 NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_result.


FORM SKIP
     tel_cdbcoval[1] AT 24 NO-LABEL
     tel_cdbcoval[2] AT 47 NO-LABEL
     tel_cdbcoval[3] AT 72 NO-LABEL
     SKIP
     "ENTRADAS:"     AT 02
     tel_vlentcen[1] AT 11  NO-LABEL
     tel_vlentcen[2] AT 34  NO-LABEL
     tel_vlentcen[3] AT 57  NO-LABEL
     SKIP
     "SAIDAS:"       AT 04
     tel_vlsaicen[1] AT 11  NO-LABEL
     tel_vlsaicen[2] AT 34  NO-LABEL
     tel_vlsaicen[3] AT 57  NO-LABEL
     SKIP
     "RESULTADO:"    AT 01
     tel_vlresult[1] AT 11  NO-LABEL
     tel_vlresult[2] AT 34  NO-LABEL
     tel_vlresult[3] AT 57  NO-LABEL
     SKIP(1)
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cecred_result.


FORM SKIP(1)
     tel_cdbcoval[1] AT 22 NO-LABEL
     tel_cdbcoval[2] AT 37 NO-LABEL
     tel_cdbcoval[3] AT 55 NO-LABEL
     tel_cdbcoval[4] AT 66 NO-LABEL
     SKIP
     "REP RECURSOS:" AT 01
     tel_vlrepass[1] AT 15  NO-LABEL
     tel_vlrepass[2] AT 31  NO-LABEL
     tel_vlrepass[3] AT 47  NO-LABEL
     tel_vlrepass[4] AT 63  NO-LABEL
     SKIP
     "FOLHA DE PAG:" AT 01
     tel_vlrfolha[1] AT 15  NO-LABEL
     tel_vlrfolha[2] AT 31  NO-LABEL
     tel_vlrfolha[3] AT 47  NO-LABEL
     tel_vlrfolha[4] AT 63  NO-LABEL
     SKIP
     "DEP. NUM:"     AT 05
     tel_vlnumera[1] AT 15  NO-LABEL
     tel_vlnumera[2] AT 31  NO-LABEL
     tel_vlnumera[3] AT 47  NO-LABEL
     tel_vlnumera[4] AT 63  NO-LABEL
     SKIP
     "OUTROS:"       AT 7
     tel_vloutros[1] AT 15  NO-LABEL
     tel_vloutros[2] AT 31  NO-LABEL
     tel_vloutros[3] AT 47  NO-LABEL
     tel_vloutros[4] AT 63  NO-LABEL 
     SKIP(1)
     WITH ROW 9 COLUMN 1 WIDTH 80 OVERLAY SIDE-LABELS TITLE "DIVERSOS" 
     FRAME f_previs_diversos.

FORM SKIP(1)
     tel_cdbcoval[1] AT 21 NO-LABEL
     tel_cdbcoval[2] AT 37 NO-LABEL
     tel_cdbcoval[3] AT 55 NO-LABEL
     tel_cdbcoval[4] AT 66 NO-LABEL
     SKIP
     "REP RECURSOS:" AT 01
     tel_vlrepass[1] AT 15  NO-LABEL
     tel_vlrepass[2] AT 31  NO-LABEL
     tel_vlrepass[3] AT 47  NO-LABEL
     tel_vlrepass[4] AT 63  NO-LABEL
     SKIP
     "SAQUE NUM:"    AT 04
     tel_vlrfolha[1] AT 15  NO-LABEL
     tel_vlrfolha[2] AT 31  NO-LABEL
     tel_vlrfolha[3] AT 47  NO-LABEL
     tel_vlrfolha[4] AT 63  NO-LABEL
     SKIP
     "ALIVIO NUM:"   AT 03
     tel_vlnumera[1] AT 15  NO-LABEL
     tel_vlnumera[2] AT 31  NO-LABEL
     tel_vlnumera[3] AT 47  NO-LABEL
     tel_vlnumera[4] AT 63  NO-LABEL
     SKIP
     "OUTROS:"       AT 7
     tel_vloutros[1] AT 15  NO-LABEL
     tel_vloutros[2] AT 31  NO-LABEL
     tel_vloutros[3] AT 47  NO-LABEL
     tel_vloutros[4] AT 63  NO-LABEL 
     SKIP(1)
     WITH ROW 9 COLUMN 1 WIDTH 80 OVERLAY SIDE-LABELS TITLE "DIVERSOS" 
     FRAME f_previs_diversos2.


FORM tel_dtmvtolt  AT 04 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."

     tel_cdcooper  AT 35 LABEL "Cooperativa" AUTO-RETURN
                         HELP "Selecione a Cooperativa"
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_l_cabec.

FORM SKIP(1)
     "SILOC (Cobranca NR + DOC NR)"       AT 12
     SKIP(1)
     tel_vlcobbil         TO 60 LABEL "Cobranca/DOC Bilateral"
     tel_vlcobmlt         TO 60 LABEL "Cobranca/DOC Multilateral"
     SKIP(2)
     "COMPE (Cheques NR)"                 AT 12
     SKIP(1)
     tel_vlchqnot         TO 60  LABEL "Compensacao Noturna"
     tel_vlchqdia         TO 60  LABEL "Compensacao Diurna"
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_l.


RUN Busca_Cooperativas.


ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper
       tel_cdcoper2:LIST-ITEM-PAIRS = aux_nmcooper.


ON RETURN OF tel_cdcoper2  IN FRAME f_previs_f_cecred_coop
   DO:
       ASSIGN tel_cdcoper2 = tel_cdcoper2:SCREEN-VALUE.
       APPLY "GO".

   END.
  
ON RETURN OF tel_cdcooper  IN FRAME f_previs_l_cabec
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
       APPLY "GO".

   END.


ON ANY-KEY OF tel_vldivers IN FRAME f_previs_entrada DO:

   IF (KEYFUNCTION(LASTKEY) = "END-ERROR") THEN
       LEAVE.
        
   RUN conecta_handle.
   
   DYNAMIC-FUNCTION("valida_horario" IN h-b1wgen0131,
                    INPUT glb_cdcooper,
                    INPUT TIME,
                    OUTPUT aux_hrpermit,
                    OUTPUT aux_dscritic).
   
   
   IF aux_hrpermit = FALSE  THEN
      DO:
         MESSAGE aux_dscritic.
         PAUSE(2) NO-MESSAGE.
         HIDE MESSAGE.
         VIEW FRAME f_previs_diversos.
                        
         DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                 tel_cdbcoval[2] FORMAT "X(15)"
                 tel_cdbcoval[3] FORMAT "X(7)"
                 tel_cdbcoval[4] FORMAT "X(12)"
                 tel_vlrepass 
                 tel_vlrfolha
                 tel_vlnumera 
                 tel_vloutros
                 WITH FRAME f_previs_diversos.
         
         READKEY.
         
         IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                HIDE MESSAGE.
                CLEAR FRAME f_previs_diversos NO-PAUSE.
                HIDE FRAME f_previs_diversos.
         
            END.
         
         HIDE MESSAGE.
         CLEAR FRAME f_previs_diversos NO-PAUSE.
         HIDE FRAME f_previs_diversos.

         RETURN NO-APPLY.
   
      END.
   
   VIEW FRAME f_previs_diversos.
   
   DO WHILE TRUE ON END-KEY UNDO, LEAVE:
   
      DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
              tel_cdbcoval[2] FORMAT "X(15)"
              tel_cdbcoval[3] FORMAT "X(7)"
              tel_cdbcoval[4] FORMAT "X(12)"
              WITH FRAME f_previs_diversos.
   
      ASSIGN tel_vlrepass[4]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlrfolha[1]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlrfolha[3]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlrfolha[4]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlnumera[1]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlnumera[3]:READ-ONLY IN FRAME f_previs_diversos = TRUE
             tel_vlnumera[4]:READ-ONLY IN FRAME f_previs_diversos = TRUE.
      
      UPDATE tel_vlrepass 
             tel_vlrfolha
             tel_vlnumera 
             tel_vloutros
             WITH FRAME f_previs_diversos.
   
      LEAVE.
   
   END.
   
   IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
      DO:
          CLEAR FRAME f_previs_diversos NO-PAUSE.
          HIDE FRAME f_previs_diversos.
   
      END.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN aux_confirma = "N".
   
      MESSAGE COLOR NORMAL "Deseja confirmar operacao (S/N)?" 
              UPDATE aux_confirma.
   
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */
   
   
   IF KEY-FUNCTION(LASTKEY) = "END-ERROR" OR 
      aux_confirma = "N"                  THEN
      DO:
          CLEAR FRAME f_previs_diversos NO-PAUSE.
          HIDE FRAME f_previs_diversos.
          RETURN NO-APPLY.
          
      END.

   RUN conecta_handle.

   RUN pi_diversos_f IN h-b1wgen0131(INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_nmdatela,
                                     INPUT tel_cdmovmto,
                                     INPUT tel_vlrepass,
                                     INPUT tel_vlnumera,
                                     INPUT tel_vlrfolha,
                                     INPUT tel_vloutros,
                                     OUTPUT TABLE tt-erro).
   
   
   IF RETURN-VALUE <> "OK" THEN 
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF AVAIL tt-erro THEN
            DO:
               MESSAGE tt-erro.dscritic.
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
         ELSE
            DO:
               MESSAGE "Nao foi possivel gravar o valor dos Diversos.".               
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
   
         RETURN.
      
      END.

   RUN busca_dados_fluxo_singular IN h-b1wgen0131
                                    (INPUT glb_cdcooper,
                                     INPUT tel_dtmvtolt,
                                     INPUT 1,
                                     OUTPUT TABLE tt-ffin-mvto-sing).
   
   IF RETURN-VALUE <> "OK" THEN 
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF AVAIL tt-erro THEN
            DO: 
               MESSAGE tt-erro.dscritic.
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
         ELSE
            DO:
               MESSAGE "Nao foi possivel buscar os dados do " + 
                       "fluxo singular.".
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
   
         RETURN NO-APPLY.
      
      END.
                      
   RUN atribuir-form-previs.

   ASSIGN tel_vldivers[1]:SCREEN-VALUE IN FRAME 
                          f_previs_entrada = STRING(tel_vldivers[1])
          tel_vldivers[2]:SCREEN-VALUE IN FRAME 
                          f_previs_entrada = STRING(tel_vldivers[2])
          tel_vldivers[3]:SCREEN-VALUE IN FRAME 
                          f_previs_entrada = STRING(tel_vldivers[3])
          tel_vldivers[4]:SCREEN-VALUE IN FRAME 
                          f_previs_entrada = STRING(tel_vldivers[4]).
        
   CLEAR FRAME f_previs_diversos NO-PAUSE.
   HIDE FRAME f_previs_diversos.
   
   RETURN NO-APPLY.
   
END.


ON ANY-KEY OF tel_vldivers IN FRAME f_previs_saida DO:

   IF (KEYFUNCTION(LASTKEY) = "END-ERROR") THEN
       LEAVE.
   
   RUN conecta_handle.
   
   DYNAMIC-FUNCTION("valida_horario" IN h-b1wgen0131,
                    INPUT glb_cdcooper,
                    INPUT TIME,
                    OUTPUT aux_hrpermit,
                    OUTPUT aux_dscritic).
   
   IF aux_hrpermit = FALSE THEN
      DO:
         MESSAGE aux_dscritic.
         PAUSE(2) NO-MESSAGE.
         HIDE MESSAGE.
         VIEW FRAME f_previs_diversos2.
                         
         DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                 tel_cdbcoval[2] FORMAT "X(15)"
                 tel_cdbcoval[3] FORMAT "X(7)"
                 tel_cdbcoval[4] FORMAT "X(12)"
                 tel_vlrepass 
                 tel_vlrfolha
                 tel_vlnumera 
                 tel_vloutros
                 WITH FRAME f_previs_diversos2.
         
         READKEY.
         
         IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                HIDE MESSAGE.
                CLEAR FRAME f_previs_diversos2 NO-PAUSE.
                HIDE FRAME f_previs_diversos2.
         
            END.
         
         HIDE MESSAGE.
         CLEAR FRAME f_previs_diversos2 NO-PAUSE.
         HIDE FRAME f_previs_diversos2.

         RETURN NO-APPLY.
   
      END.
   
      
   VIEW FRAME f_previs_diversos2.
   
   DO WHILE TRUE ON END-KEY UNDO, LEAVE:
   
       DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
               tel_cdbcoval[2] FORMAT "X(15)"
               tel_cdbcoval[3] FORMAT "X(7)"
               tel_cdbcoval[4] FORMAT "X(12)"
               WITH FRAME f_previs_diversos2.
   
   
       ASSIGN tel_vlrepass[4]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlrfolha[1]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlrfolha[3]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlrfolha[4]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlnumera[1]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlnumera[3]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE
              tel_vlnumera[4]:READ-ONLY IN FRAME f_previs_diversos2 = TRUE.
        
       UPDATE tel_vlrepass 
              tel_vlrfolha
              tel_vlnumera 
              tel_vloutros
              WITH FRAME f_previs_diversos2.
   
       LEAVE.
   
   END.
   
   IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
      DO:
          CLEAR FRAME f_previs_diversos2 NO-PAUSE.
          HIDE FRAME f_previs_diversos2.
   
      END.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN aux_confirma = "N".
   
      MESSAGE COLOR NORMAL "Deseja confirmar operacao (S/N)?" 
              UPDATE aux_confirma.
   
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */
   
   
   IF KEY-FUNCTION(LASTKEY) = "END-ERROR" OR 
      aux_confirma = "N"                  THEN
      DO:
          CLEAR FRAME f_previs_diversos2 NO-PAUSE.
          HIDE FRAME f_previs_diversos2.
          RETURN NO-APPLY.
   
      END.
   
   RUN conecta_handle.
   
   RUN pi_diversos_f IN h-b1wgen0131(INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_nmdatela,
                                     INPUT tel_cdmovmto,
                                     INPUT tel_vlrepass,
                                     INPUT tel_vlnumera,
                                     INPUT tel_vlrfolha,
                                     INPUT tel_vloutros,
                                     OUTPUT TABLE tt-erro).
   
   
   IF RETURN-VALUE <> "OK" THEN 
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF AVAIL tt-erro THEN
            DO: 
               MESSAGE tt-erro.dscritic.
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
         ELSE
            DO:
               MESSAGE "Nao foi possivel gravar o valor dos Diversos.".               
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
   
         RETURN.
      
      END.

   RUN busca_dados_fluxo_singular IN h-b1wgen0131
                                    (INPUT glb_cdcooper,
                                     INPUT tel_dtmvtolt,
                                     INPUT 2,
                                     OUTPUT TABLE tt-ffin-mvto-sing).
   
   IF RETURN-VALUE <> "OK" THEN 
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF AVAIL tt-erro THEN
            DO: 
               MESSAGE tt-erro.dscritic.
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
         ELSE
            DO:
               MESSAGE "Nao foi possivel buscar os dados do fluxo singular.".
               PAUSE(2) NO-MESSAGE.
               HIDE MESSAGE.
               RETURN NO-APPLY.
   
            END.
   
         RETURN NO-APPLY.
      
      END.
   
   RUN atribuir-form-previs.
      
   ASSIGN tel_vldivers[1]:SCREEN-VALUE IN FRAME 
                          f_previs_saida = STRING(tel_vldivers[1])
          tel_vldivers[2]:SCREEN-VALUE IN FRAME 
                          f_previs_saida = STRING(tel_vldivers[2])
          tel_vldivers[3]:SCREEN-VALUE IN FRAME 
                          f_previs_saida = STRING(tel_vldivers[3])
          tel_vldivers[4]:SCREEN-VALUE IN FRAME 
                          f_previs_saida = STRING(tel_vldivers[4]).

   CLEAR FRAME f_previs_diversos2 NO-PAUSE.
   HIDE FRAME f_previs_diversos2.

   RETURN NO-APPLY.


END.


ON LEAVE OF tel_vlresgat IN FRAME f_previs_result DO:

    ASSIGN INPUT tel_vlaplica
           INPUT tel_vlresgat.

    IF tel_vlresgat > 0 THEN
       DO:
          ASSIGN tel_vlaplica = 0.

          DISP tel_vlaplica WITH FRAME f_previs_result.

          ASSIGN tel_vlaplica:READ-ONLY IN FRAME f_previs_result = TRUE.

       END.
    ELSE
       ASSIGN tel_vlaplica:READ-ONLY IN FRAME f_previs_result = FALSE.


END.

ON LEAVE OF tel_vlaplica IN FRAME f_previs_result DO:

    ASSIGN INPUT tel_vlaplica
           INPUT tel_vlresgat.

    IF tel_vlaplica > 0 THEN
       DO:
          ASSIGN tel_vlresgat = 0.

          DISP tel_vlresgat WITH FRAME f_previs_result.

          ASSIGN tel_vlresgat:READ-ONLY IN FRAME f_previs_result = TRUE.

       END.
    ELSE
       ASSIGN tel_vlresgat:READ-ONLY IN FRAME f_previs_result = FALSE.

END.


VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "C"
       tel_dtmvtolt = glb_dtmvtolt.
          
PAUSE 0.

DO WHILE TRUE:

    CLEAR FRAME f_previs_1.
    CLEAR FRAME f_previs_2.
    CLEAR FRAME f_previs_debre.
    CLEAR FRAME f_previs_f.
    CLEAR FRAME f_previs_f_cecred.
    CLEAR FRAME f_previs_f_cecred_coop.
    CLEAR FRAME f_previs_entrada.
    CLEAR FRAME f_cecred_entrada.
    CLEAR FRAME f_previs_saida.
    CLEAR FRAME f_cecred_saida.
    CLEAR FRAME f_previs_result.
    CLEAR FRAME f_cecred_result.
    CLEAR FRAME f_previs.
    
    HIDE FRAME f_previs.
    HIDE FRAME f_previs_1.
    HIDE FRAME f_previs_2.
    HIDE FRAME f_previs_f.
    HIDE FRAME f_previs_f_cecred.
    HIDE FRAME f_previs_f_cecred_coop.
    HIDE FRAME f_previs_l_cabec.
    HIDE FRAME f_previs_l.
    HIDE FRAME f_previs_entrada.
    HIDE FRAME f_cecred_entrada.
    HIDE FRAME f_previs_saida.
    HIDE FRAME f_cecred_saida.
    HIDE FRAME f_previs_result.
    HIDE FRAME f_cecred_result.

    RUN fontes/inicia.p.
                    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
       ASSIGN tel_cdagenci = 0.

       UPDATE glb_cddopcao WITH FRAME f_opcao.
       LEAVE.

    END.
    
    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
       DO:
           RUN fontes/novatela.p.

           IF CAPS(glb_nmdatela) <> "PREVIS" THEN
              DO:
                  IF VALID-HANDLE(h-b1wgen0131) THEN
                     DELETE PROCEDURE h-b1wgen0131.

                  HIDE FRAME f_opcao.
                  HIDE FRAME f_previs.
                  HIDE FRAME f_previs_1.
                  HIDE FRAME f_previs_2.
                  HIDE FRAME f_previs_f.
                  HIDE FRAME f_previs_f_cecred.
                  HIDE FRAME f_previs_f_cecred_coop.
                  HIDE FRAME f_previs_l_cabec.
                  HIDE FRAME f_previs_l.
                  HIDE FRAME f_previs_entrada.
                  HIDE FRAME f_cecred_entrada.
                  HIDE FRAME f_previs_saida.
                  HIDE FRAME f_cecred_saida.
                  HIDE FRAME f_previs_result.
                  HIDE FRAME f_cecred_result.
                  HIDE FRAME f_moldura.
                  RETURN.

              END.
           ELSE
              NEXT.
       END.

    IF aux_cddopcao <> glb_cddopcao   THEN
       DO:
           { includes/acesso.i}
           ASSIGN aux_cddopcao = glb_cddopcao.

       END.

    ASSIGN glb_cdcritic = 0
           tel_cdbcoval[1] = "COMPE 085"
           tel_cdbcoval[2] = "B. BRASIL"
           tel_cdbcoval[3] = "BANCOOB"
           tel_cdbcoval[4] = "CONTA CECRED".

    CASE glb_cddopcao:

        WHEN "A" THEN DO:

            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_nmoperad = ""
                   tel_hrtransa = "".

            DISPLAY tel_dtmvtolt 
                    WITH FRAME f_previs_1.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_cdagenci 
                       WITH FRAME f_previs_1

                EDITING:
                    READKEY.
        
                    IF LASTKEY = KEYCODE("F7") THEN
                       DO:
                           IF FRAME-FIELD = "tel_cdagenci" THEN
                              DO:
                                  RUN fontes/zoom_pac.p(OUTPUT tel_cdagenci).
                                  DISPLAY tel_cdagenci WITH FRAME f_previs_1.

                              END.
                       END. 
                    ELSE 
                       APPLY LASTKEY.
        
                END. /*** Fim EDITING ***/

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                FIND FIRST tt-previs NO-ERROR.

                IF  NOT AVAIL tt-previs THEN
                    NEXT.

                DO aux_contador = 1 TO 6:

                    ASSIGN tel_vlmoedas[aux_contador] = 
                                              tt-previs.vlmoedas[aux_contador]
                           tel_qtmoedas[aux_contador] = 
                                              tt-previs.qtmoedas[aux_contador]
                           tel_submoeda[aux_contador] = 
                                              tt-previs.submoeda[aux_contador]
                           tel_vldnotas[aux_contador] =
                                              tt-previs.vldnotas[aux_contador]
                           tel_qtdnotas[aux_contador] =
                                              tt-previs.qtdnotas[aux_contador]
                           tel_subnotas[aux_contador] =
                                              tt-previs.subnotas[aux_contador]
                           aux_qtmoepct[aux_contador] =
                                              tt-previs.qtmoepct[aux_contador].
                    
                    DISPLAY tel_vlmoedas[aux_contador]
                            tel_qtmoedas[aux_contador]
                            tel_submoeda[aux_contador]
                            tel_vldnotas[aux_contador] 
                            tel_qtdnotas[aux_contador]
                            tel_subnotas[aux_contador]
                            WITH FRAME f_previs.
                END.

                ASSIGN tel_vldepesp = tt-previs.vldepesp
                       tel_vldvlnum = tt-previs.vldvlnum
                       tel_nmoperad = tt-previs.nmoperad
                       tel_totmoeda = tt-previs.totmoeda
                       tel_totnotas = tt-previs.totnotas
                       tel_hrtransa = tt-previs.hrtransa.

                DISPLAY tel_vldepesp 
                        tel_vldvlnum 
                        tel_nmoperad 
                        tel_totmoeda 
                        tel_totnotas 
                        tel_hrtransa
                        WITH FRAME f_previs.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_vldepesp 
                           tel_vldvlnum 
                           tel_qtmoedas[1] 
                           tel_qtmoedas[2] 
                           tel_qtmoedas[3]
                           tel_qtmoedas[4] 
                           tel_qtmoedas[5] 
                           tel_qtmoedas[6]
                           tel_qtdnotas[1] 
                           tel_qtdnotas[2] 
                           tel_qtdnotas[3]
                           tel_qtdnotas[5] 
                           tel_qtdnotas[4] 
                           tel_qtdnotas[6]
                           WITH FRAME f_previs

                    EDITING:
                        IF FRAME-FIELD = "tel_vldepesp"  OR
                           FRAME-FIELD = "tel_vldvlnum"  THEN
                           IF  LASTKEY =  KEYCODE(".")  THEN
                               APPLY 44.

                        IF FRAME-INDEX > 0 THEN
                           DO:
                               ASSIGN aux_contador = FRAME-INDEX.

                               IF FRAME-FIELD = "tel_qtmoedas" THEN
                                  DO: 
                                      ASSIGN tel_submoeda[aux_contador] =
                                             tel_vlmoedas[aux_contador] * 
                                             aux_qtmoepct[aux_contador] *
                                         INPUT tel_qtmoedas[aux_contador].

                                      DISPLAY tel_submoeda[aux_contador] 
                                                    WITH FRAME f_previs.

                                      IF aux_contador = 6 Then
                                         DO:
                                             ASSIGN tel_totmoeda =
                                                       tel_submoeda[1] +
                                                       tel_submoeda[2] +
                                                       tel_submoeda[3] +
                                                       tel_submoeda[4] +
                                                       tel_submoeda[5] +
                                                       tel_submoeda[6].
                                             
                                             DISPLAY tel_totmoeda
                                                     WITH FRAME f_previs.

                                         END.

                                  END.  /*   fim do IF   */
                               ELSE
                                  DO:
                                      ASSIGN tel_subnotas[aux_contador] =
                                             tel_vldnotas[aux_contador] * 
                                             INPUT tel_qtdnotas[aux_contador].

                                      DISPLAY tel_subnotas[aux_contador]
                                              WITH FRAME f_previs.

                                      IF aux_contador = 6 Then
                                         DO:
                                             ASSIGN tel_totnotas =
                                                       tel_subnotas[1] +
                                                       tel_subnotas[2] +
                                                       tel_subnotas[3] +
                                                       tel_subnotas[4] +
                                                       tel_subnotas[5] +
                                                       tel_subnotas[6].

                                             DISPLAY tel_totnotas
                                                     WITH FRAME f_previs.

                                         END.

                                  END. /*  fim do ELSE  */  

                           END. /*  fim  do IF FRAME-INDEX  */

                        READKEY.
                        APPLY LASTKEY.

                    END.  /*  fim do EDITING */
                        
                    RUN Grava_Dados.
                    
                    IF RETURN-VALUE <> "OK" THEN
                       NEXT.

                    LEAVE.

                END.

                LEAVE.

            END. /* Fim DO WHILE TRUE */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

            CLEAR FRAME f_previs NO-PAUSE.
            
            DISPLAY glb_cddopcao WITH FRAME f_opcao.

            PAUSE 0.
        
        END.  /*  END do WHEN "A" */
        
        WHEN "C" THEN DO:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                UPDATE tel_dtmvtolt 
                       tel_cdagenci 
                       WITH FRAME f_previs_1

                EDITING:
                    READKEY.
        
                    IF LASTKEY = KEYCODE("F7") THEN
                       DO:
                          IF FRAME-FIELD = "tel_cdagenci" THEN
                             DO:
                                 RUN fontes/zoom_pac.p(OUTPUT tel_cdagenci).
                                 DISPLAY tel_cdagenci WITH FRAME f_previs_1.

                             END.

                       END. 
                    ELSE 
                       APPLY LASTKEY.
        
                END. /*** Fim EDITING ***/

                ASSIGN tel_vldvlbcb = 0.

                RUN Busca_Dados.

                IF RETURN-VALUE <> "OK" THEN
                   NEXT.

                FIND FIRST tt-previs NO-ERROR.

                IF NOT AVAIL tt-previs THEN
                   NEXT.

                DO aux_contador = 1 TO 6:

                   ASSIGN tel_vlmoedas[aux_contador] = 
                                             tt-previs.vlmoedas[aux_contador]
                          tel_qtmoedas[aux_contador] = 
                                             tt-previs.qtmoedas[aux_contador]
                          tel_submoeda[aux_contador] = 
                                             tt-previs.submoeda[aux_contador]
                          tel_vldnotas[aux_contador] = 
                                             tt-previs.vldnotas[aux_contador]
                          tel_qtdnotas[aux_contador] = 
                                             tt-previs.qtdnotas[aux_contador]
                          tel_subnotas[aux_contador] = 
                                             tt-previs.subnotas[aux_contador].
                 
                   DISPLAY tel_vlmoedas[aux_contador]
                           tel_qtmoedas[aux_contador]
                           tel_submoeda[aux_contador]
                           tel_vldnotas[aux_contador] 
                           tel_qtdnotas[aux_contador]
                           tel_subnotas[aux_contador] 
                           WITH FRAME f_previs.

                END.

                ASSIGN tel_vldepesp = tt-previs.vldepesp
                       tel_vldvlnum = tt-previs.vldvlnum
                       tel_vldvlbcb = tt-previs.vldvlbcb 
                       tel_vlremtit = tt-previs.vlremtit
                       tel_qtremtit = tt-previs.qtremtit
                       tel_totmoeda = tt-previs.totmoeda
                       tel_totnotas = tt-previs.totnotas
                       tel_nmoperad = tt-previs.nmoperad
                       tel_hrtransa = tt-previs.hrtransa.

                DISPLAY tel_vldepesp 
                        tel_vldvlnum 
                        tel_vldvlbcb  
                        tel_vlremtit 
                        tel_qtremtit 
                        tel_totmoeda 
                        tel_totnotas 
                        tel_nmoperad 
                        tel_hrtransa
                        WITH FRAME f_previs.

            END. /*   fim do  Do  While   */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

        END.  /*  END do WHEN "C" */
        
        WHEN "I" THEN DO:

            ASSIGN tel_vldepesp = 0  
                   tel_vldvlnum = 0  
                   tel_vldvlbcb = 0                             
                   tel_vlremdoc = 0  
                   tel_qtremdoc = 0  
                   tel_qtmoedas = 0                             
                   tel_submoeda = 0  
                   tel_totmoeda = 0  
                   tel_qtdnotas = 0                             
                   tel_subnotas = 0                   
                   tel_totnotas = 0  
                   tel_cdagenci = 0
                   tel_dtmvtolt = glb_dtmvtolt.
            
            DISPLAY tel_dtmvtolt 
                    WITH FRAME f_previs_1.
             
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_cdagenci 
                       WITH FRAME f_previs_1

                EDITING:
                    READKEY.
        
                    IF LASTKEY = KEYCODE("F7") THEN
                       DO:
                           IF FRAME-FIELD = "tel_cdagenci" THEN
                              DO:
                                  RUN fontes/zoom_pac.p(OUTPUT tel_cdagenci).
                                  DISPLAY tel_cdagenci WITH FRAME f_previs_1.

                              END.

                       END. 
                    ELSE 
                       APPLY LASTKEY.
        
                END. /*** Fim EDITING ***/

                RUN Busca_Dados.

                IF RETURN-VALUE <> "OK" THEN
                   NEXT.

                LEAVE.

            END.
           
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

            FIND FIRST tt-previs NO-ERROR.

            IF NOT AVAIL tt-previs THEN
               NEXT.

            DO aux_contador = 1 TO 6:

               ASSIGN tel_vlmoedas[aux_contador] =
                                             tt-previs.vlmoedas[aux_contador]
                      aux_qtmoepct[aux_contador] =
                                             tt-previs.qtmoepct[aux_contador]
                      tel_vldnotas[aux_contador] =
                                             tt-previs.vldnotas[aux_contador].

               DISPLAY tel_vlmoedas[aux_contador]
                       tel_vldnotas[aux_contador] 
                       WITH FRAME f_previs.

            END.

            DO WHILE TRUE:

                UPDATE tel_vldepesp 
                       tel_vldvlnum 
                       tel_qtmoedas[1] 
                       tel_qtmoedas[2] 
                       tel_qtmoedas[3]
                       tel_qtmoedas[4] 
                       tel_qtmoedas[5] 
                       tel_qtmoedas[6]
                       tel_qtdnotas[1] 
                       tel_qtdnotas[2] 
                       tel_qtdnotas[3]
                       tel_qtdnotas[5] 
                       tel_qtdnotas[4] 
                       tel_qtdnotas[6] 
                       WITH FRAME f_previs

                EDITING:
                    IF FRAME-FIELD = "tel_vldepesp" OR
                       FRAME-FIELD = "tel_vldvlnum" THEN
                       IF LASTKEY =  KEYCODE(".") THEN
                          APPLY 44.

                    IF FRAME-INDEX > 0 THEN
                       DO:
                           ASSIGN aux_contador = FRAME-INDEX.

                           IF FRAME-FIELD = "tel_qtmoedas" THEN
                              DO: 
                                  ASSIGN tel_submoeda[aux_contador] =
                                            tel_vlmoedas[aux_contador] * 
                                            aux_qtmoepct[aux_contador] * 
                                            INPUT tel_qtmoedas[aux_contador].

                                  DISPLAY tel_submoeda[aux_contador] 
                                          WITH FRAME f_previs.

                                  IF aux_contador = 6 THEN
                                     DO:
                                         ASSIGN tel_totmoeda =
                                                          tel_submoeda[1] +
                                                          tel_submoeda[2] +
                                                          tel_submoeda[3] +
                                                          tel_submoeda[4] +
                                                          tel_submoeda[5] + 
                                                          tel_submoeda[6].

                                         DISPLAY tel_totmoeda
                                                 WITH FRAME f_previs.
                                     END.
                              END.
                           ELSE
                              DO:
                                  ASSIGN tel_subnotas[aux_contador] =
                                              tel_vldnotas[aux_contador] * 
                                              INPUT tel_qtdnotas[aux_contador].

                                  DISPLAY tel_subnotas[aux_contador]
                                          WITH FRAME f_previs.

                                  IF aux_contador = 6 THEN
                                     DO:
                                         ASSIGN tel_totnotas =
                                                           tel_subnotas[1] +
                                                           tel_subnotas[2] +
                                                           tel_subnotas[3] +
                                                           tel_subnotas[4] +
                                                           tel_subnotas[5] +
                                                           tel_subnotas[6].

                                         DISPLAY tel_totnotas 
                                                 WITH FRAME f_previs.

                                     END.

                                  END. /*  fim do ELSE  */  

                       END. /*  fim  do  IF FRAME-INDEX  */

                    READKEY.
                    APPLY LASTKEY.

                END.  /*  fim do EDITING */

                RUN Grava_Dados.

                IF RETURN-VALUE <> "OK" THEN
                   NEXT.

                LEAVE.

            END. /*  Fim DO WHILE TRUE  */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

            CLEAR FRAME f_previs   NO-PAUSE.

            DISPLAY glb_cddopcao 
                    WITH FRAME f_opcao.

            PAUSE 0.

        END.  /*  END do WHEN "I" */
        
        WHEN "F" THEN DO:

            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   aux_vlaplian = 0
                   aux_vlresgan = 0.
                         
            IF glb_cdcooper = 3 THEN
               DO: 
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                      HIDE FRAME f_previs_f_cecred.
                      VIEW FRAME f_previs_f_cecred.
                      
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                         HIDE MESSAGE.
                      
                         UPDATE tel_cdmovmto 
                                tel_dtmvtolt 
                                WITH FRAME f_previs_f_cecred.
                      
                         LEAVE.
                      
                      END.
                      
                      HIDE FRAME f_previs_entrada NO-PAUSE.
                      HIDE FRAME f_cecred_entrada NO-PAUSE.
                      HIDE FRAME f_previs_saida NO-PAUSE.
                      HIDE FRAME f_cecred_saida NO-PAUSE.
                      HIDE FRAME f_previs_result NO-PAUSE.
                      HIDE FRAME f_cecred_result NO-PAUSE.
                      HIDE FRAME f_previs NO-PAUSE.
                      HIDE FRAME f_previs_l_cabec NO-PAUSE.
                      HIDE FRAME f_previs_l NO-PAUSE.
                      HIDE FRAME f_previs_1 NO-PAUSE.
                      HIDE FRAME f_previs_2 NO-PAUSE.
                      HIDE FRAME f_previs_f NO-PAUSE.
                      
                      IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                         LEAVE.
                      
                      IF tel_cdmovmto <> "A" THEN
                         DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                               HIDE MESSAGE.
                      
                               UPDATE tel_cdcoper2 
                                      WITH FRAME f_previs_f_cecred_coop.
                      
                               LEAVE.
                      
                            END.
                      
                            IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                               LEAVE.
                      
                         END.
                      ELSE
                         HIDE FRAME f_previs_f_cecred_coop.

                      
                      IF tel_dtmvtolt = glb_dtmvtolt THEN
                         DO:
                            RUN verifica_acesso IN h-b1wgen0131 
                                     (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_nmoperad,
                                      INPUT (IF tel_cdmovmto <> "A" THEN 
                                                INT(tel_cdcoper2:SCREEN-VALUE)
                                             ELSE
                                                glb_cdcooper),
                                      OUTPUT aux_permiace,
                                      OUTPUT aux_dstextab,
                                      OUTPUT aux_msgaviso,
                                      OUTPUT TABLE tt-erro).
                            
                            IF RETURN-VALUE <> "OK" THEN 
                               DO:
                                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      
                                  IF AVAIL tt-erro THEN
                                     DO:
                                        MESSAGE tt-erro.dscritic.
                                        PAUSE(2) NO-MESSAGE.
                                        HIDE MESSAGE.

                                     END.
                                  ELSE
                                     DO:
                                        MESSAGE "Nao foi possivel verificar " +
                                                "acesso.".
                                        PAUSE(2) NO-MESSAGE.
                                        HIDE MESSAGE.

                                     END.
                      
                                  NEXT.
                            
                               END.
                          
                            IF aux_permiace = FALSE THEN
                               DO:
                                  MESSAGE aux_dstextab.
                                  MESSAGE aux_msgaviso.
                                  READKEY PAUSE 2.
                                  HIDE MESSAGE NO-PAUSE.
                      
                                  IF KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                                     DO:
                                        /* Forca a saida para a tela do MENU */
                                        ASSIGN glb_nmdatela = "".
                                    
                                        IF VALID-HANDLE(h-b1wgen0131) THEN
                                           DELETE OBJECT h-b1wgen0131.
                                    
                                     END.
                                  
                                  NEXT.
                      
                      
                               END.
                      
                         END.
                      
                      MESSAGE "Aguarde...".

                      RUN mostra-form-previs.

                      IF tel_dtmvtolt = glb_dtmvtolt THEN
                         DO:
                            RUN conecta_handle.
                         
                            RUN libera_acesso IN h-b1wgen0131
                                      (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT (IF tel_cdmovmto <> "A" THEN 
                                                 INT(tel_cdcoper2:SCREEN-VALUE)
                                              ELSE
                                                 glb_cdcooper),
                                       OUTPUT TABLE tt-erro).
                         
                            HIDE MESSAGE.
                         
                            IF RETURN-VALUE <> "OK" THEN 
                               DO:
                                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                      
                                  IF AVAIL tt-erro THEN
                                     DO: 
                                        MESSAGE tt-erro.dscritic.
                                        PAUSE(3) NO-MESSAGE.
                                        HIDE MESSAGE.
                                        
                                     END.
                                  ELSE
                                     DO:
                                        MESSAGE "Nao foi possivel liberar " +
                                                "acesso.".
                                        PAUSE(2) NO-MESSAGE.
                                        HIDE MESSAGE.
                         
                                     END.
                                  
                                  NEXT.
                         
                               END.
                         
                         END.
                      
                      
                   END. /*Fim do DO WHILE */

               END.
            ELSE
               DO:
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     VIEW FRAME f_previs_f.

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                         UPDATE tel_cdmovmto 
                                tel_dtmvtolt 
                                WITH FRAME f_previs_f.
                         
                         LEAVE.
                     
                     END. /* Fim do  DO WHILE */
                     
                     HIDE FRAME f_previs_entrada.
                     HIDE FRAME f_cecred_entrada.
                     HIDE FRAME f_previs_saida.
                     HIDE FRAME f_cecred_saida.
                     HIDE FRAME f_previs_result.
                     HIDE FRAME f_cecred_result.
                     HIDE FRAME f_previs.
                     HIDE FRAME f_previs_l_cabec.
                     HIDE FRAME f_previs_l.
                     HIDE FRAME f_previs_1.
                     HIDE FRAME f_previs_2.
                     HIDE FRAME f_previs_f_cecred.
                     HIDE FRAME f_previs_f_cecred_coop.


                     IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                        LEAVE.

                     IF tel_dtmvtolt = glb_dtmvtolt THEN
                        DO:
                           RUN verifica_acesso IN h-b1wgen0131 
                                                 (INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmoperad,
                                                  INPUT glb_cdcooper,
                                                  OUTPUT aux_permiace,
                                                  OUTPUT aux_dstextab,
                                                  OUTPUT aux_msgaviso,
                                                  OUTPUT TABLE tt-erro).
                           
                           IF RETURN-VALUE <> "OK" THEN 
                              DO:
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                 IF AVAIL tt-erro THEN
                                    DO:
                                       MESSAGE tt-erro.dscritic.
                                       PAUSE(2) NO-MESSAGE.
                                       HIDE MESSAGE.
                     
                                    END.
                                 ELSE
                                    DO:
                                       MESSAGE "Nao foi possivel verificar " +
                                               "acesso.".
                                       PAUSE(2) NO-MESSAGE.
                                       HIDE MESSAGE.
                     
                                    END.
                        
                                 NEXT.
                           
                              END.
                         
                           IF aux_permiace = FALSE THEN
                              DO:
                                 MESSAGE aux_dstextab.
                                 MESSAGE aux_msgaviso.
                                 READKEY PAUSE 2.
                                 HIDE MESSAGE NO-PAUSE.

                                 IF KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                                    DO:
                                       /* Forca a saida para a tela do MENU */
                                       ASSIGN glb_nmdatela = "".
                                   
                                       IF VALID-HANDLE(h-b1wgen0131) THEN
                                          DELETE OBJECT h-b1wgen0131.
                                   
                                    END.
                                 
                                 NEXT.
                        
                        
                              END.
                        
                        END.
                     
                     MESSAGE "Aguarde...".

                     RUN mostra-form-previs.

                     IF tel_dtmvtolt = glb_dtmvtolt THEN
                        DO:
                           RUN conecta_handle.
                        
                           RUN libera_acesso IN h-b1wgen0131
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_cdcooper,
                                                 OUTPUT TABLE tt-erro).
                        
                           HIDE MESSAGE.
                        
                           IF RETURN-VALUE <> "OK" THEN 
                              DO:
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                     
                                 IF AVAIL tt-erro THEN
                                    DO: 
                                       MESSAGE tt-erro.dscritic.
                                       PAUSE(3) NO-MESSAGE.
                                       HIDE MESSAGE.
                                       
                                    END.
                                 ELSE
                                     DO:
                                        MESSAGE "Nao foi possivel liberar " +
                                                "acesso.".
                                        PAUSE(2) NO-MESSAGE.
                                        HIDE MESSAGE.
                     
                                     END.
                                 
                                 NEXT.
                        
                              END.
                        
                        END.

                  END. /* Fim do DO WHILE */

               END.

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

        END. /* END do WHEN "F" */
        
        WHEN "L" THEN DO:

            ASSIGN tel_dtmvtolt = glb_dtmvtolt.

            DISPLAY tel_dtmvtolt 
                    WITH FRAME f_previs_l_cabec.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_dtmvtolt 
                       tel_cdcooper
                       WITH FRAME f_previs_l_cabec.

                HIDE FRAME f_previs_entrada.
                HIDE FRAME f_cecred_entrada.
                HIDE FRAME f_previs_saida.
                HIDE FRAME f_cecred_saida.
                HIDE FRAME f_previs_result.
                HIDE FRAME f_cecred_result.
                HIDE FRAME f_previs.
                HIDE FRAME f_previs_l.
                HIDE FRAME f_previs_1.
                HIDE FRAME f_previs_2.
                HIDE FRAME f_previs_f.
                HIDE FRAME f_previs_f_cecred.

                MESSAGE "Aguarde....Processando Cooperativa(s).".

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.

                HIDE MESSAGE NO-PAUSE.

                FIND FIRST tt-fluxo NO-ERROR.

                IF  NOT AVAIL tt-fluxo THEN
                    NEXT.

                ASSIGN tel_vlcobbil = tt-fluxo.vlcobbil
                       tel_vlcobmlt = tt-fluxo.vlcobmlt
                       tel_vlchqnot = tt-fluxo.vlchqnot
                       tel_vlchqdia = tt-fluxo.vlchqdia.

                DISPLAY tel_vlcobbil tel_vlcobmlt
                        tel_vlchqnot tel_vlchqdia 
                        WITH FRAME f_previs_l.
            
            END. /* END do DO WHILE TRUE */
            
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
               NEXT.

        END. /* END do WHEN "L" */
   
   END CASE.
   
END.

IF VALID-HANDLE(h-b1wgen0131) THEN
   DELETE PROCEDURE h-b1wgen0131.

/* ..........................................................................*/

PROCEDURE mostra-form-previs:
    
    RUN Busca_Dados.
    
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".

    RUN atribuir-form-previs.
    
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".


    IF tel_dtmvtolt = glb_dtmvtolt THEN
       DO:
          RUN conecta_handle.
            
          RUN libera_acesso IN h-b1wgen0131
                    (INPUT glb_cdcooper,
                     INPUT 0,
                     INPUT 0,
                     INPUT glb_cdoperad,
                     INPUT (IF tel_cdmovmto <> "A" AND glb_cdcooper = 3 THEN 
                               INT(tel_cdcoper2)
                            ELSE
                               glb_cdcooper),
                     OUTPUT TABLE tt-erro).
       
          HIDE MESSAGE.
          
          IF RETURN-VALUE <> "OK" THEN 
             DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                IF AVAIL tt-erro THEN
                   DO: 
                      MESSAGE tt-erro.dscritic.
                      PAUSE(3) NO-MESSAGE.
                      HIDE MESSAGE.
                      
                   END.
                ELSE
                   DO:
                      MESSAGE "Nao foi possivel liberar " +
                              "acesso.".
                      PAUSE(2) NO-MESSAGE.
                      HIDE MESSAGE.
       
                   END.
                
                RETURN "NOK".
       
             END.
       
       END.

    IF glb_cdcooper = 3 THEN
       DO:
           CASE tel_cdmovmto:

               WHEN "E" THEN
               DO:
                   DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                           tel_cdbcoval[2] FORMAT "X(15)"
                           tel_cdbcoval[3] FORMAT "X(7)"
                           tel_vlcheque[1] 
                           tel_vlcheque[2]  
                           tel_vlcheque[3]
                           tel_vltotdoc[1]  
                           tel_vltotdoc[2]
                           tel_vltotdoc[3]  
                           tel_vltotted[1]
                           tel_vltotted[2]  
                           tel_vltotted[3]
                           tel_vltottit[1]  
                           tel_vltottit[2]
                           tel_vltottit[3]  
                           tel_vldevolu[1]
                           tel_vldevolu[2]  
                           tel_vldevolu[3]
                           tel_vlmvtitg[1]  
                           tel_vlmvtitg[2]
                           tel_vlmvtitg[3]  
                           tel_vlttinss[1]
                           tel_vlttinss[2]  
                           tel_vlttinss[3]
                           tel_vldivers[1]  
                           tel_vldivers[2]
                           tel_vldivers[3]  
                           tel_vlttcrdb[1]  
                           tel_vlttcrdb[2]  
                           tel_vlttcrdb[3]  
                           WITH FRAME f_cecred_entrada.      

               END.

               WHEN "S" THEN
               DO:
                   DISPLAY tel_cdbcoval[1] FORMAT "X(9)"  
                           tel_cdbcoval[2] FORMAT "X(15)"
                           tel_cdbcoval[3] FORMAT "X(7)" 
                           tel_vlmvtitg[1]  
                           tel_vlmvtitg[2]
                           tel_vlmvtitg[3]
                           tel_vlcheque[1]
                           tel_vlcheque[1]  
                           tel_vlcheque[2]
                           tel_vlcheque[3]  
                           tel_vltotdoc[1]
                           tel_vltotdoc[2]  
                           tel_vltotdoc[3]
                           tel_vltotted[1]  
                           tel_vltotted[2]
                           tel_vltotted[3]  
                           tel_vltottit[1]     
                           tel_vltottit[2]  
                           tel_vltottit[3]
                           tel_vldevolu[1]  
                           tel_vldevolu[2]
                           tel_vldevolu[3]  
                           tel_vlttinss[1]  
                           tel_vlttinss[2]  
                           tel_vlttinss[3]  
                           tel_vldivers[1]  
                           tel_vldivers[2]  
                           tel_vldivers[3]  
                           tel_vlttcrdb[1]  
                           tel_vlttcrdb[2]  
                           tel_vlttcrdb[3]  
                           WITH FRAME f_cecred_saida.

               END.

               WHEN "R" THEN
               DO:                      
                   DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                           tel_cdbcoval[2] FORMAT "X(15)"
                           tel_cdbcoval[3] FORMAT "X(7)"
                           tel_vlentcen 
                           tel_vlsaicen    
                           tel_vlresult
                           WITH FRAME f_cecred_result.

               END.

               WHEN "A" THEN
               DO: 
                   OUTPUT STREAM str_1 TO VALUE("rl/prevismovto.lst") 
                          PAGED PAGE-SIZE 84.

                   DISPLAY STREAM str_1 
                                  WITH FRAME f_cecred_investimento_cab.
                   
                   ASSIGN tel_totmovto = 0.


                   FOR EACH tt-ffin-cons-sing NO-LOCK:
                   
                       ASSIGN tel_nmcooper = tt-ffin-cons-sing.nmrescop
                              tel_vlrmovto = 0
                              tel_dscmovto = "-"
                              tel_nmoperad = "".

                       IF tt-ffin-cons-sing.vlresgat > 0 THEN
                          ASSIGN tel_vlrmovto = - tt-ffin-cons-sing.vlresgat
                                 tel_dscmovto = "Resgate"
                                 tel_totmovto = tel_totmovto + tel_vlrmovto.
                       ELSE
                          IF tt-ffin-cons-sing.vlaplica > 0 THEN
                             ASSIGN tel_vlrmovto = tt-ffin-cons-sing.vlaplica
                                    tel_dscmovto = "Aplicacao"
                                    tel_totmovto = tel_totmovto + tel_vlrmovto.
                                                   
                        
                       ASSIGN tel_nmoperad = tt-ffin-cons-sing.nmoperad.
                       
                       DISPLAY STREAM str_1 tel_nmcooper
                                            tel_nmoperad
                                            tel_vlrmovto 
                                            tel_dscmovto
                                            WITH FRAME f_cecred_investimento.

                       DOWN WITH FRAME f_cecred_investimento.

                   END.

                   DISPLAY STREAM str_1 "Total Operacoes:" AT 4
                                        tel_totmovto       AT 42 
                                        WITH NO-LABEL.
                                        

                   OUTPUT STREAM str_1 CLOSE.

                   RUN fontes/visrel.p(INPUT "rl/prevismovto.lst").


               END.

           END CASE.

       END.
    ELSE
       DO:
          CASE tel_cdmovmto:

              WHEN "E" THEN
              DO:

                 lab: 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                            tel_cdbcoval[2] FORMAT "X(15)"    
                            tel_cdbcoval[3] FORMAT "X(7)"
                            tel_cdbcoval[4] FORMAT "X(12)"
                            tel_vlcheque
                            tel_vltotdoc    
                            tel_vltotted
                            tel_vltottit     
                            tel_vldevolu
                            tel_vlmvtitg     
                            tel_vlttinss
                            tel_vltrdeit     
                            tel_vlsatait
                            tel_vldivers
                            tel_vlttcrdb[1]  
                            tel_vlttcrdb[2]  
                            tel_vlttcrdb[3]  
                            tel_vlttcrdb[4]
                            WITH FRAME f_previs_entrada.

                    ASSIGN tel_vldivers[1]:HELP =  "Pressione algo para "    + 
                                                   "continuar - <F4>/<END> " + 
                                                   "para voltar.".

                    IF  tel_dtmvtolt = glb_dtmvtolt THEN
                        DO:
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE lab:
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                                
                                   
                                    UPDATE tel_vldivers[1]
                                           WITH FRAME f_previs_entrada.

                                END.

                                LEAVE.

                            END.

                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                 LEAVE.
                            
                        END.
                    ELSE
                       DO:
                          PAUSE MESSAGE  "Pressione algo para continuar - <F4>/<END> para voltar.".

                          VIEW FRAME f_previs_diversos.
                        
                          DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                                  tel_cdbcoval[2] FORMAT "X(15)"
                                  tel_cdbcoval[3] FORMAT "X(7)"
                                  tel_cdbcoval[4] FORMAT "X(12)"
                                  tel_vlrepass 
                                  tel_vlrfolha
                                  tel_vlnumera 
                                  tel_vloutros
                                  WITH FRAME f_previs_diversos.
                          
                          MESSAGE "Pressione qualquer tecla pra continuar...".

                          READKEY.
                        
                          IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
                             DO:
                                 HIDE MESSAGE.
                                 CLEAR FRAME f_previs_diversos NO-PAUSE.
                                 HIDE FRAME f_previs_diversos.
                          
                             END.
                        
                          HIDE MESSAGE.
                          CLEAR FRAME f_previs_diversos NO-PAUSE.
                          HIDE FRAME f_previs_diversos.
                        

                       END.

                    IF tel_dtmvtolt <> glb_dtmvtolt THEN
                       LEAVE.
                 END.

                 DISPLAY tel_cdbcoval     
                         tel_vlcheque
                         tel_vltotdoc     
                         tel_vltotted
                         tel_vltottit     
                         tel_vldevolu
                         tel_vlmvtitg     
                         tel_vlttinss
                         tel_vltrdeit     
                         tel_vlsatait
                         tel_vldivers     
                         tel_vlttcrdb[1]  
                         tel_vlttcrdb[2]  
                         tel_vlttcrdb[3]  
                         tel_vlttcrdb[4]
                         WITH FRAME f_previs_entrada.

              END.

              WHEN "S" THEN
              DO:
                 lab:
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                            tel_cdbcoval[2] FORMAT "X(15)"
                            tel_cdbcoval[3] FORMAT "X(7)"
                            tel_cdbcoval[4] FORMAT "X(12)"
                            tel_vlcheque
                            tel_vltotdoc     
                            tel_vltotted
                            tel_vltottit     
                            tel_vldevolu
                            tel_vlmvtitg     
                            tel_vlttinss
                            tel_vltrdeit     
                            tel_vlsatait
                            tel_vldivers     
                            tel_vlfatbra
                            tel_vlconven     
                            tel_vlttcrdb[1]  
                            tel_vlttcrdb[2]  
                            tel_vlttcrdb[3]  
                            tel_vlttcrdb[4]
                            WITH FRAME f_previs_saida.
    
                    ASSIGN tel_vldivers[1]:HELP =  "Pressione algo para "    + 
                                                   "continuar - <F4>/<END> " + 
                                                   "para voltar.".
                    
                    IF  tel_dtmvtolt = glb_dtmvtolt THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE lab:
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                                
                                   
                                    UPDATE tel_vldivers[1]
                                           WITH FRAME f_previs_saida.

                                END.

                                LEAVE.

                            END.

                            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                               LEAVE.

                        END.
                    ELSE
                       DO:
                          PAUSE MESSAGE  "Pressione algo para continuar - <F4>/<END> para voltar.".
                         
                          VIEW FRAME f_previs_diversos2.
                         
                          DISPLAY tel_cdbcoval[1] FORMAT "X(9)"
                                  tel_cdbcoval[2] FORMAT "X(15)"
                                  tel_cdbcoval[3] FORMAT "X(7)"
                                  tel_cdbcoval[4] FORMAT "X(12)"
                                  tel_vlrepass 
                                  tel_vlrfolha
                                  tel_vlnumera 
                                  tel_vloutros
                                  WITH FRAME f_previs_diversos2.
                         
                          MESSAGE "Pressione qualquer tecla pra continuar...".
                         
                          READKEY.
                         
                          IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
                             DO:
                                 HIDE MESSAGE.
                                 CLEAR FRAME f_previs_diversos2 NO-PAUSE.
                                 HIDE FRAME f_previs_diversos2.
                         
                             END.
                         
                          HIDE MESSAGE.
                          CLEAR FRAME f_previs_diversos2 NO-PAUSE.
                          HIDE FRAME f_previs_diversos2.

                    
                       END.

                    IF tel_dtmvtolt <> glb_dtmvtolt THEN
                       LEAVE.

                 END.
                 
                 DISPLAY tel_cdbcoval     
                         tel_vlcheque
                         tel_vltotdoc     
                         tel_vltotted
                         tel_vltottit     
                         tel_vldevolu
                         tel_vlmvtitg     
                         tel_vlttinss
                         tel_vltrdeit     
                         tel_vlsatait
                         tel_vldivers     
                         tel_vlfatbra
                         tel_vlconven     
                         tel_vlttcrdb[1]  
                         tel_vlttcrdb[2]  
                         tel_vlttcrdb[3]  
                         tel_vlttcrdb[4]
                         WITH FRAME f_previs_saida.

              END.

              WHEN "R" THEN
              DO:
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN aux_vlresgan = tel_vlresgat
                           aux_vlaplian = tel_vlaplica.

                    DISPLAY tel_vlentrad 
                            tel_vlresgat
                            tel_vlsaidas 
                            tel_vlaplica
                            tel_vltotcen 
                            tel_vlsldcta
                            tel_vlsldfin
                            tel_nmoperad
                            tel_hrtransa
                            WITH FRAME f_previs_result.

                    RUN conecta_handle.

                    DYNAMIC-FUNCTION("valida_horario" IN h-b1wgen0131,
                                     INPUT glb_cdcooper,
                                     INPUT TIME,
                                     OUTPUT aux_hrpermit,
                                     OUTPUT aux_dscritic).

                    IF (tel_dtmvtolt = glb_dtmvtolt) THEN
                        DO:
                           IF aux_hrpermit THEN
                              DO:
                                 ASSIGN tel_vlresgat:READ-ONLY IN FRAME 
                                                     f_previs_result = FALSE
                                        tel_vlaplica:READ-ONLY IN FRAME 
                                                     f_previs_result = FALSE.
                                 
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    UPDATE tel_vlresgat 
                                           tel_vlaplica
                                           WITH FRAME f_previs_result.
                                    
                                    ASSIGN INPUT tel_vlresgat
                                           INPUT tel_vlaplica.


                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    
                                       ASSIGN aux_confirma = "N".
                                    
                                       MESSAGE COLOR NORMAL "Deseja confirmar operacao (S/N)?" 
                                               UPDATE aux_confirma.
                                    
                                       LEAVE.
                                    
                                    END.  /*  Fim do DO WHILE TRUE  */
                                    
                                    IF KEY-FUNCTION(LASTKEY) = "END-ERROR" OR 
                                       aux_confirma = "N"                  THEN
                                       DO:
                                           DISPLAY tel_vlentrad 
                                                   aux_vlresgan @ tel_vlresgat
                                                   tel_vlsaidas 
                                                   aux_vlaplian @ tel_vlaplica
                                                   tel_vltotcen 
                                                   tel_vlsldcta
                                                   tel_vlsldfin
                                                   tel_nmoperad
                                                   tel_hrtransa
                                                   WITH FRAME f_previs_result.
                                    
                                           NEXT.
                                    
                                       END.

                                    RUN conecta_handle.
                                           
                                    RUN grava_apli_resg IN h-b1wgen0131
                                                 (INPUT glb_cdcooper,
                                                  INPUT glb_cdagenci,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_dtmvtolt,
                                                  INPUT tel_vlresgat,
                                                  INPUT aux_vlresgan,
                                                  INPUT tel_vlaplica,
                                                  INPUT aux_vlaplian,
                                                  OUTPUT TABLE tt-erro).
                                    
                                    IF RETURN-VALUE <> "OK" THEN
                                       DO:
                                          FIND tt-erro NO-LOCK NO-ERROR.
                                    
                                          IF AVAIL tt-erro THEN
                                             DO:
                                                MESSAGE tt-erro.dscritic.
                                                PAUSE(2) NO-MESSAGE.
                                                HIDE MESSAGE.
                                                LEAVE.
                                    
                                             END.
                                          ELSE
                                             DO:
                                                MESSAGE "Nao foi possivel gravar o " + 
                                                        "valor do resgate/aplicacao.".
                                                PAUSE(2) NO-MESSAGE.
                                                HIDE MESSAGE.
                                                LEAVE.
                                    
                                             END.
                                    
                                       END.
                                    
                                    RUN busca_dados_consolidado_singular IN h-b1wgen0131
                                                            (INPUT glb_cdcooper,
                                                             INPUT tel_dtmvtolt,
                                                             INPUT tel_cdcooper,
                                                             OUTPUT TABLE tt-ffin-cons-sing).
                                    
                                    
                                    IF RETURN-VALUE <> "OK" THEN
                                       DO:
                                          MESSAGE "Nao foi possivel buscar dos consolidados.".
                                          PAUSE(2) NO-MESSAGE.
                                          HIDE MESSAGE.
                                          LEAVE.
                                    
                                       END.
                                    
                                    
                                    RUN atribuir-form-previs.
                                    
                                    
                                    IF RETURN-VALUE <> "OK" THEN
                                       RETURN "NOK".
                                   
                                    DISPLAY tel_vlentrad 
                                            tel_vlresgat
                                            tel_vlsaidas 
                                            tel_vlaplica
                                            tel_vltotcen 
                                            tel_vlsldcta
                                            tel_vlsldfin
                                            tel_nmoperad
                                            tel_hrtransa
                                            WITH FRAME f_previs_result.

                                 END.

                                 IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                                    RETURN "NOK".

                              END.
                           ELSE
                              DO:
                                 MESSAGE aux_dscritic.
                                 PAUSE(2) NO-MESSAGE.
                                 HIDE MESSAGE.
                                 RETURN "NOK".

                              END.
                                 
                        END.
                    ELSE
                       RETURN "NOK".
                    
                    
                    LEAVE.

                 END.
                 
              END.

          END CASE.

       END.

    RETURN "OK".

END. 

PROCEDURE atribuir-form-previs:
          
   IF glb_cdcooper = 3 THEN
      DO:
          CASE tel_cdmovmto:

              WHEN "E" OR WHEN "S" THEN
              DO: 
                  FIND FIRST tt-ffin-mvto-cent NO-LOCK NO-ERROR.

                  IF NOT AVAIL tt-ffin-mvto-cent THEN
                     RETURN "NOK".

                  

                  ASSIGN tel_vlcheque[1] = tt-ffin-mvto-cent.vlcheque[1]
                         tel_vlcheque[2] = tt-ffin-mvto-cent.vlcheque[2]
                         tel_vlcheque[3] = tt-ffin-mvto-cent.vlcheque[3]

                         tel_vltotdoc[1] = tt-ffin-mvto-cent.vltotdoc[1]
                         tel_vltotdoc[2] = tt-ffin-mvto-cent.vltotdoc[2]
                         tel_vltotdoc[3] = tt-ffin-mvto-cent.vltotdoc[3]

                         tel_vltotted[1] = tt-ffin-mvto-cent.vltotted[1]
                         tel_vltotted[2] = tt-ffin-mvto-cent.vltotted[2]
                         tel_vltotted[3] = tt-ffin-mvto-cent.vltotted[3]

                         tel_vltottit[1] = tt-ffin-mvto-cent.vltottit[1]
                         tel_vltottit[2] = tt-ffin-mvto-cent.vltottit[2]
                         tel_vltottit[3] = tt-ffin-mvto-cent.vltottit[3]

                         tel_vldevolu[1] = tt-ffin-mvto-cent.vldevolu[1]
                         tel_vldevolu[2] = tt-ffin-mvto-cent.vldevolu[2]
                         tel_vldevolu[3] = tt-ffin-mvto-cent.vldevolu[3]

                         tel_vlmvtitg[1] = tt-ffin-mvto-cent.vlmvtitg[1]
                         tel_vlmvtitg[2] = tt-ffin-mvto-cent.vlmvtitg[2]
                         tel_vlmvtitg[3] = tt-ffin-mvto-cent.vlmvtitg[3]

                         tel_vlttinss[1] = tt-ffin-mvto-cent.vlttinss[1]
                         tel_vlttinss[2] = tt-ffin-mvto-cent.vlttinss[2]
                         tel_vlttinss[3] = tt-ffin-mvto-cent.vlttinss[3]

                         tel_vldivers[1] = tt-ffin-mvto-cent.vldivers[1]
                         tel_vldivers[2] = tt-ffin-mvto-cent.vldivers[2]
                         tel_vldivers[3] = tt-ffin-mvto-cent.vldivers[3]
                      
                         tel_vlttcrdb[1] = tt-ffin-mvto-cent.vlttcrdb[1]
                         tel_vlttcrdb[2] = tt-ffin-mvto-cent.vlttcrdb[2]
                         tel_vlttcrdb[3] = tt-ffin-mvto-cent.vlttcrdb[3].

              END.
              WHEN "R" THEN
              DO:
                  FIND FIRST tt-ffin-cons-cent NO-LOCK NO-ERROR.

                  IF NOT AVAIL tt-ffin-cons-cent THEN
                     RETURN "NOK".

                  ASSIGN tel_vlentcen[1] = tt-ffin-cons-cent.vlentrad[1]
                         tel_vlentcen[2] = tt-ffin-cons-cent.vlentrad[2]
                         tel_vlentcen[3] = tt-ffin-cons-cent.vlentrad[3]

                         tel_vlsaicen[1] = tt-ffin-cons-cent.vlsaidas[1]
                         tel_vlsaicen[2] = tt-ffin-cons-cent.vlsaidas[2]
                         tel_vlsaicen[3] = tt-ffin-cons-cent.vlsaidas[3]

                         tel_vlresult[1] = tt-ffin-cons-cent.vlresult[1]
                         tel_vlresult[2] = tt-ffin-cons-cent.vlresult[2]
                         tel_vlresult[3] = tt-ffin-cons-cent.vlresult[3].


              END. 

          END CASE.

      END.
   ELSE
      DO:
          CASE tel_cdmovmto:

              WHEN "E" OR WHEN "S" THEN
              DO: 
                  FIND FIRST tt-ffin-mvto-sing NO-LOCK NO-ERROR.

                  IF NOT AVAIL tt-ffin-mvto-sing THEN
                     RETURN "NOK".

                  ASSIGN tel_vlcheque[1] = tt-ffin-mvto-sing.vlcheque[1]
                         tel_vlcheque[2] = tt-ffin-mvto-sing.vlcheque[2]
                         tel_vlcheque[3] = tt-ffin-mvto-sing.vlcheque[3]
                         tel_vlcheque[4] = tt-ffin-mvto-sing.vlcheque[4]

                         tel_vltotdoc[1] = tt-ffin-mvto-sing.vltotdoc[1]
                         tel_vltotdoc[2] = tt-ffin-mvto-sing.vltotdoc[2]
                         tel_vltotdoc[3] = tt-ffin-mvto-sing.vltotdoc[3]
                         tel_vltotdoc[4] = tt-ffin-mvto-sing.vltotdoc[4]

                         tel_vltotted[1] = tt-ffin-mvto-sing.vltotted[1]
                         tel_vltotted[2] = tt-ffin-mvto-sing.vltotted[2]
                         tel_vltotted[3] = tt-ffin-mvto-sing.vltotted[3]
                         tel_vltotted[4] = tt-ffin-mvto-sing.vltotted[4]

                         tel_vltottit[1] = tt-ffin-mvto-sing.vltottit[1]
                         tel_vltottit[2] = tt-ffin-mvto-sing.vltottit[2]
                         tel_vltottit[3] = tt-ffin-mvto-sing.vltottit[3]
                         tel_vltottit[4] = tt-ffin-mvto-sing.vltottit[4]

                         tel_vldevolu[1] = tt-ffin-mvto-sing.vldevolu[1]
                         tel_vldevolu[2] = tt-ffin-mvto-sing.vldevolu[2]
                         tel_vldevolu[3] = tt-ffin-mvto-sing.vldevolu[3]
                         tel_vldevolu[4] = tt-ffin-mvto-sing.vldevolu[4]

                         tel_vlmvtitg[1] = tt-ffin-mvto-sing.vlmvtitg[1]
                         tel_vlmvtitg[2] = tt-ffin-mvto-sing.vlmvtitg[2]
                         tel_vlmvtitg[3] = tt-ffin-mvto-sing.vlmvtitg[3]
                         tel_vlmvtitg[4] = tt-ffin-mvto-sing.vlmvtitg[4]

                         tel_vlttinss[1] = tt-ffin-mvto-sing.vlttinss[1]
                         tel_vlttinss[2] = tt-ffin-mvto-sing.vlttinss[2]
                         tel_vlttinss[3] = tt-ffin-mvto-sing.vlttinss[3]
                         tel_vlttinss[4] = tt-ffin-mvto-sing.vlttinss[4]

                         tel_vltrdeit[1] = tt-ffin-mvto-sing.vltrdeit[1]
                         tel_vltrdeit[2] = tt-ffin-mvto-sing.vltrdeit[2]
                         tel_vltrdeit[3] = tt-ffin-mvto-sing.vltrdeit[3]
                         tel_vltrdeit[4] = tt-ffin-mvto-sing.vltrdeit[4]

                         tel_vlsatait[1] = tt-ffin-mvto-sing.vlsatait[1]
                         tel_vlsatait[2] = tt-ffin-mvto-sing.vlsatait[2]
                         tel_vlsatait[3] = tt-ffin-mvto-sing.vlsatait[3]
                         tel_vlsatait[4] = tt-ffin-mvto-sing.vlsatait[4]

                         tel_vlrepass[1] = tt-ffin-mvto-sing.vlrepass[1]
                         tel_vlrepass[2] = tt-ffin-mvto-sing.vlrepass[2]
                         tel_vlrepass[3] = tt-ffin-mvto-sing.vlrepass[3]
                         tel_vlrepass[4] = tt-ffin-mvto-sing.vlrepass[4]

                         tel_vlrfolha[1] = tt-ffin-mvto-sing.vlrfolha[1]
                         tel_vlrfolha[2] = tt-ffin-mvto-sing.vlrfolha[2]
                         tel_vlrfolha[3] = tt-ffin-mvto-sing.vlrfolha[3]
                         tel_vlrfolha[4] = tt-ffin-mvto-sing.vlrfolha[4]

                         tel_vlnumera[1] = tt-ffin-mvto-sing.vlnumera[1]
                         tel_vlnumera[2] = tt-ffin-mvto-sing.vlnumera[2]
                         tel_vlnumera[3] = tt-ffin-mvto-sing.vlnumera[3]
                         tel_vlnumera[4] = tt-ffin-mvto-sing.vlnumera[4]

                         tel_vloutros[1] = tt-ffin-mvto-sing.vloutros[1]
                         tel_vloutros[2] = tt-ffin-mvto-sing.vloutros[2]
                         tel_vloutros[3] = tt-ffin-mvto-sing.vloutros[3]
                         tel_vloutros[4] = tt-ffin-mvto-sing.vloutros[4]

                         tel_vlconven[1] = tt-ffin-mvto-sing.vlconven[1] 
                         tel_vlconven[2] = tt-ffin-mvto-sing.vlconven[2] 
                         tel_vlconven[3] = tt-ffin-mvto-sing.vlconven[3] 
                         tel_vlconven[4] = tt-ffin-mvto-sing.vlconven[4] 

                         tel_vlfatbra[1] = tt-ffin-mvto-sing.vlfatbra[1] 
                         tel_vlfatbra[2] = tt-ffin-mvto-sing.vlfatbra[2] 
                         tel_vlfatbra[3] = tt-ffin-mvto-sing.vlfatbra[3] 
                         tel_vlfatbra[4] = tt-ffin-mvto-sing.vlfatbra[4] 

                         tel_vldivers[1] = tt-ffin-mvto-sing.vldivers[1]
                        
                       
                        
                         tel_vldivers[2] = tt-ffin-mvto-sing.vldivers[2]
                         tel_vldivers[3] = tt-ffin-mvto-sing.vldivers[3]
                         tel_vldivers[4] = tt-ffin-mvto-sing.vldivers[4]

                         tel_vlttcrdb[1] = tt-ffin-mvto-sing.vlttcrdb[1]
                         tel_vlttcrdb[2] = tt-ffin-mvto-sing.vlttcrdb[2]
                         tel_vlttcrdb[3] = tt-ffin-mvto-sing.vlttcrdb[3]
                         tel_vlttcrdb[4] = tt-ffin-mvto-sing.vlttcrdb[4].

              END.
              WHEN "R" THEN
              DO:
                  ASSIGN tel_nmoperad = ""
                         tel_hrtransa = "".

                  FIND FIRST tt-ffin-cons-sing NO-LOCK NO-ERROR.

                  IF AVAIL tt-ffin-cons-sing THEN
                     ASSIGN tel_vlentrad = tt-ffin-cons-sing.vlentrad
                            tel_vlresgat = tt-ffin-cons-sing.vlresgat
                            tel_vlsaidas = tt-ffin-cons-sing.vlsaidas
                            tel_vlaplica = tt-ffin-cons-sing.vlaplica
                            tel_vltotcen = tt-ffin-cons-sing.vlresult
                            tel_vlsldcta = tt-ffin-cons-sing.vlsldcta
                            tel_vlsldfin = tt-ffin-cons-sing.vlsldfin
                            tel_nmoperad = tt-ffin-cons-sing.nmoperad
                            tel_hrtransa = tt-ffin-cons-sing.hrtransa.

                  
              END.

          END CASE.

      END.


   RETURN "OK".

END.

PROCEDURE Busca_Cooperativas:
    
    RUN conecta_handle.

    RUN Busca_Cooperativas IN h-b1wgen0131 (INPUT glb_cdcooper,
                                            OUTPUT aux_nmcooper).
      
    RETURN "OK".

END PROCEDURE. /* Busca_Cooperativas */

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-previs.
    EMPTY TEMP-TABLE tt-fluxo. 
    EMPTY TEMP-TABLE tt-ffin-mvto-cent.
    EMPTY TEMP-TABLE tt-ffin-mvto-sing.
    EMPTY TEMP-TABLE tt-erro.
     
    RUN conecta_handle.

    RUN Busca_Dados IN h-b1wgen0131
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_nmdatela,
          INPUT glb_dsdepart,
          INPUT glb_cddopcao,
          INPUT tel_dtmvtolt,
          INPUT tel_cdagenci,
          INPUT (IF glb_cddopcao = "F" THEN 
                    IF tel_cdmovmto = "A" THEN
                       0
                    ELSE
                       tel_cdcoper2
                 ELSE
                    tel_cdcooper),
          INPUT tel_cdmovmto,
          INPUT glb_dtmvtoan,
          INPUT 9999, /*cdagefim*/
          OUTPUT TABLE tt-previs,
          OUTPUT TABLE tt-fluxo,
          OUTPUT TABLE tt-ffin-mvto-cent,
          OUTPUT TABLE tt-ffin-mvto-sing,
          OUTPUT TABLE tt-ffin-cons-cent,
          OUTPUT TABLE tt-ffin-cons-sing,
          OUTPUT TABLE tt-erro).

    HIDE MESSAGE NO-PAUSE.

    IF RETURN-VALUE <> "OK" THEN
       DO: 
          FIND FIRST tt-erro NO-ERROR.
          
          IF AVAILABLE tt-erro THEN
             MESSAGE tt-erro.dscritic.
       
          RETURN "NOK".  
       
       END.
    ELSE
       IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
          DO: 
              FOR EACH tt-erro NO-LOCK:
          
                  MESSAGE tt-erro.dscritic.
          
              END.
      
          END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.
                      
    RUN conecta_handle.

    RUN Grava_Dados IN h-b1wgen0131
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_cddopcao,
          INPUT tel_cdagenci,
          INPUT tel_vldepesp,
          INPUT tel_vldvlnum,
          INPUT tel_vldvlbcb,
          INPUT tel_qtmoedas,
          INPUT tel_qtdnotas,
         OUTPUT TABLE tt-erro).
                        
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    IF  VALID-HANDLE(h-b1wgen0131)  THEN
        DELETE PROCEDURE h-b1wgen0131.

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

PROCEDURE conecta_handle:

   IF NOT VALID-HANDLE(h-b1wgen0131) THEN
      RUN sistema/generico/procedures/b1wgen0131.p
          PERSISTENT SET h-b1wgen0131.

END PROCEDURE.


