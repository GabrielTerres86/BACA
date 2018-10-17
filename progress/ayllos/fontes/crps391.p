/* ............................................................................

   Programa: Fontes/crps391.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                      Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Lanc. Arrecadacao Convenios Caixa(Executado somente na Central)
               Solicitacao : 5 (ordem 47)
               Exclusividade = 1
               Relatorio 348.
               Historico Debito = 749/Historico Credito 362/Lote = 10100

   Alteracoes: 07/10/2004 - Alterado leitura crapass(First)(Mirtes) 
                            
               22/10/2004 - Tratamento para convenios com dominio da CECRED
                            (Julio)

               14/12/2004 - Tratamento para Historico de repasse (Debito), para
                            cada convenio da CECRED (Julio)
               
               22/12/2004 - Gerar um relatorio separado para convenios CECRED
                            (Ze/Evandro)
                            
               22/02/2005 - Aceitar valor negativo para repasse (Julio)
               
               18/04/2005 - Nao lancar valores zerados (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplcm (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crabcop.cdcooper = glb_cdcooper (Diego).
                           
               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               26/01/2007 - Enviar e-mail referente relatorio crrl348 para
                            CECRED (Diego).

               14/05/2007 - Retirado o tratamento glb_infimsol (Julio)
             
               09/11/2007 - Alterado o relatorio via e-mail para               
                            karina@cecred.coop.br (Gabriel).

               11/12/2007 - Alterados os tamanhos das colunas do relatorio
                            (Gabriel).

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
               
               30/07/2008 - Alterada leitura crapass(Diego) 

               10/09/2008 - Gravar tipo de 1( lugar de lote 12) tabela craplot
                            (Mirtes)
                            
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta, CNPJ e Tipo (Diego).
                            
               06/11/2008 - Aumentado Format do campo tel_cdagercb (Diego).
               
               12/11/2008 - Substituidos campos:
                            gnconve.nrccdrcb => gnconve.dsccdrcb 
                            gnconve.cdagercb => gnconve.dsagercb (Diego).

               11/02/2009 - Desconsiderar seguro auto convenio (Gabriel).
                
               03/04/2009 - Incluido convenio Seguro Auto na atualizacao do
                            sequencial dos arquivos de integracao (Elton).
                            
               01/04/2010 - Alterado email's joice@cecred.coop.br e 
                            karina@cecred.coop.br por financeiro@cecred.coop.br
                            (Elton).
                            
               08/10/2010 - Inclusao dos numeros "0" no campo gnconve.cpfcgrcb e 
                            exclusao dos mumeros "0" no campo gnconve.dsccdrcb
                            (Vitor).
                            
               28/04/2011 - Tratamento para pagamento no caixa da 
                            Foz do Brasil (Elton).
                            
               14/05/2011 - Aumentados em 1 digito os campos "Vlr.Docs" e 
                            "A Pagar" do crrl348. Retirados 2 caracteres do 
                            campo "PARA" (Lucas).
               
               06/06/2012 - Alterado format do campo gnconve.nmempres no form
                             f_movtos_dom (Elton).
                             
               20/07/2012 - Incluido campos "Seq. Caixa" e "Seq. Debito"
                            no relatorio (Tiago).
                            
               31/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
                            
               22/01/2014 - Incluir VALIDATE craplot, craplcm (Lucas R.)
               
               04/04/2014 - Inclusao da coluna 'Forma de Repasse' 
                            (gnconve.tprepass) no relatorio crrl348.
                            Criada procedure enviar-ted para geracao de
                            arquivo xml 'a cabine do SPB, para os convenios
                            de repasse.
                            (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)

               16/06/2014 - #6850 Aumento de format nmrescop para 20 (Carlos)
               
               26/06/2014 - Removido create da craplcm na procedure enviar-ted,
                            juntamente com o create do lote para esses
                            lancamentos. (Fabricio)
                            
               27/06/2014 - Na procedure enviar-ted, tratado para passar a
                            variavel aux_dtagendt quando tipo de repasse = D+2;
                            aux_dtagendt deve sempre considerar dia util.
                            Alterado tambem dentro da procedure enviar-ted
                            para passar o cdbccxlt da craplot como 100; devido
                            batimento do lote processo. (Fabricio)
               
              29/08/2014 - Incluso parametro par_dshistor na proc_envia_tec_ted
                           referente a descrição do histórico(Vanessa). 
                           
              24/10/2014 - Enviar hora da transacao (Jonata-RKAM).
                            
              11/12/2014 - Conversão da fn_sequence para procedure para não
                           gerar cursores abertos no Oracle. (Dionathan)
                           
              03/06/2015 - Remover validacao do conveio 53 Foz do brasil
                           (Lucas Ranghetti #292200)
                           
              05/06/2015 - Inclusão do paramentro par_cdispbif = 0 na procedure
                           proc_envia_tec_ted (Vanessa - FDR041 SD271603)
                           
              02/09/2015 - Inclusao da geração do arquivo REPCNVFIL.TXT para 
                           cada cooperativa  PRJ-214 (Vanessa) 


              07/10/2016 - Alteração do diretório para geração de arquivo contábil.
                           P308 (Ricardo Linhares).                            
                            
                           
			  10/01/2017 - Ajuste para enviar TED somente se o valor for maior que zero 
						  (Adriano  - SD 597906).		       

              16/06/2017 - Adicionado e-mail convenios@cecred.coop.br, conforme
                           solicitado no chamado 687836 (Kelvin).

              06/03/2018 - Retirado filtro "cdtipcta = 1" e colocado filtro da conta buscando
                           do campo "nrctactl" da tabela "crapcop". PRJ366 (Lombardi).

			  26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

.............................................................................*/
                        
{ includes/var_batch.i}
{ sistema/generico/includes/var_oracle.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.

DEF BUFFER b_crapcop     FOR crapcop.
DEF BUFFER b_gnconve     FOR gnconve.
DEF BUFFER crabcop       FOR crapcop.
DEF BUFFER b-gncontr     FOR gncontr.

DEF VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF VAR aux_nmrescop     AS CHAR                              NO-UNDO.
DEF VAR aux_nmcopdom     AS CHAR    FORMAT "x(9)"             NO-UNDO.

DEF VAR aux_vlapagar     AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_vlpagcov     AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_vlrsalvo     AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_qtdoctos     AS DEC     FORMAT "zzz9"             NO-UNDO.
DEF VAR aux_vldoctos     AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_vltarifa     AS DEC     FORMAT "zz,zz9.99"        NO-UNDO.
DEF VAR aux_vlrrepas     AS DEC                               NO-UNDO.
DEF VAR aux_cdhisrep     AS INT                               NO-UNDO.
DEF VAR aux_ttvlapagar   AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_ttqtdoctos   AS DEC     FORMAT "zzz9"             NO-UNDO.
DEF VAR aux_ttvldoctos   AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_ttvltarifa   AS DEC     FORMAT "zz,zz9.99"        NO-UNDO.
DEF VAR aux_ttvlrrepas   AS DEC                               NO-UNDO.
DEF VAR aux_ggvlapagar   AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_ggqtdoctos   AS DEC     FORMAT "zzz9"             NO-UNDO.
DEF VAR aux_ggvldoctos   AS DEC     FORMAT "zzz,zz9.99"       NO-UNDO.
DEF VAR aux_ggvltarifa   AS DEC     FORMAT "zz,zz9.99"        NO-UNDO.
DEF VAR aux_ggvlrrepas   AS DEC                               NO-UNDO.
DEF VAR aux_tpdcontr_1   LIKE gncontr.tpdcontr                NO-UNDO.
DEF VAR aux_tpdcontr_2   LIKE gncontr.tpdcontr                NO-UNDO.
DEF VAR aux_tparrecada   AS CHAR    FORMAT "x(2)"             NO-UNDO.
DEF VAR aux_titulo_rel1  AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF VAR aux_titulo_rel2  AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF VAR aux_nrseqcxa     AS INTE                              NO-UNDO.
DEF VAR aux_nrseqdeb     AS INTE                              NO-UNDO.
DEF VAR aux_tprepass     AS CHAR    FORMAT "x(03)"            NO-UNDO.
DEF VAR aux_tprepas2     AS CHAR    FORMAT "x(03)"            NO-UNDO.
DEF VAR aux_linhaarq     AS CHAR                              NO-UNDO.  
DEF VAR aux_flgarqvi     AS LOGICAL                           NO-UNDO.
DEF VAR aux_nrdconta_debito  LIKE craplcm.nrdconta            NO-UNDO.
DEF VAR aux_nrdconta_credito LIKE craplcm.nrdconta            NO-UNDO.

DEF VAR aux_cdcopdom     AS INTEGER                           NO-UNDO.

DEF VAR aux_vldocto2     AS DECIMAL                           NO-UNDO. 
DEF VAR aux_vlapaga2     AS DECIMAL                           NO-UNDO.

DEF VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 9
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "CADASTROS",
                                     "PROCESSOS",
                                     "PARAMETRIZACAO",
                                     "SOLICITACOES",
                                     "GENERICO       "]       NO-UNDO.

DEF VAR aux_arqrel_1 AS CHAR                                  NO-UNDO.
DEF VAR aux_arqrel_2 AS CHAR                                  NO-UNDO.
DEF VAR aux_arqrel_3 AS CHAR                                  NO-UNDO.
DEF VAR aux_arqrel_4 AS CHAR                                  NO-UNDO.
DEF VAR aux_flgradar AS LOGICAL                               NO-UNDO.

DEF VAR rel_cpfcgrcb AS CHAR                                  NO-UNDO.
DEF VAR rel_cpfcgrcb2 AS CHAR      FORMAT "x(18)"             NO-UNDO. 

DEF VAR aux_dsccdrcb AS INTE    FORMAT "zzzzzzz9"             NO-UNDO.
DEF VAR aux_dsccdrcb2 LIKE gnconve.dsccdrcb                   NO-UNDO.    
DEF VAR aux_dsccdrcb3 LIKE gnconve.dsccdrcb                   NO-UNDO. 

DEF TEMP-TABLE tt-arq-conve NO-UNDO
         FIELD cdcooper LIKE gncontr.cdcooper
         FIELD dtmvtolt LIKE gncontr.dtmvtolt
		 FIELD nrctdbfl LIKE gnconve.nrctdbfl
		 FIELD vltarifa LIKE gncontr.vltarifa
		 FIELD nmempres LIKE gnconve.nmempres
		 FIELD dsdircop LIKE crapcop.dsdircop
		 FIELD cdconven LIKE gncontr.cdconven.
		 
DEF TEMP-TABLE tt-arq-radar NO-UNDO
         FIELD cdcooper LIKE gncontr.cdcooper
         FIELD dtmvtolt LIKE gncontr.dtmvtolt
         FIELD tpdcontr LIKE gncontr.tpdcontr
         FIELD nrctdbfl LIKE gnconve.nrctdbfl
         FIELD vlapagar LIKE gncontr.vlapagar
         FIELD nmempres LIKE gnconve.nmempres
         FIELD dsdircop LIKE crapcop.dsdircop.
    
FORM  SKIP(1)
      aux_titulo_rel1     AT   11               NO-LABEL
      WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_titulo_rel1.
      
FORM  SKIP(1)
      aux_titulo_rel2     AT   11               NO-LABEL
      WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_titulo_rel2.
                                    
FORM  aux_nmrescop       LABEL "DE"       FORMAT "x(20)"
      gnconve.nmempres   LABEL "Convenio"
      gncontr.qtdoctos   LABEL "Doc."     FORMAT "zz,zz9"
      gncontr.vldoctos   LABEL "Vlr.Docs" FORMAT "z,zzz,zz9.99"
      gncontr.vltarifa   LABEL "Tarifa"   FORMAT "z,zz9.99"
      gncontr.vlapagar   LABEL "A Pagar"  FORMAT "-zzzz,zz9.99"
      aux_nmcopdom       LABEL "PARA"     FORMAT "x(8)"
      aux_tparrecada     LABEL " " 
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos WIDTH 132.
  
FORM  aux_nmrescop       LABEL "Coopera."     FORMAT "x(20)"
      gnconve.nmempres   LABEL "Convenio"     FORMAT "x(17)"
      aux_qtdoctos       LABEL "Doc."         FORMAT "zz,zz9"
      aux_vldoctos       LABEL "Vlr.Bruto"    FORMAT "zz,zzz,zz9.99"
      aux_vltarifa       LABEL "Tarifa"       FORMAT "zz,zz9.99"
      aux_vlapagar       LABEL "Vlr.Liquido"  FORMAT "-z,zzz,zz9.99"
      aux_vlrrepas       LABEL "A Pagar"      FORMAT "-zz,zzz,zz9.99"
      aux_tparrecada     LABEL " "
      gnconve.cdbccrcb   LABEL "Banco"        
      gnconve.dsagercb   LABEL "Age."         
      aux_dsccdrcb2      LABEL "Conta"        
      rel_cpfcgrcb       LABEL "CNPJ"         FORMAT "x(18)"
      aux_nrseqcxa       LABEL "Seq.Arq.Cx"   FORMAT "zzzzz9"
      aux_nrseqdeb       LABEL "Seq.Arq.Deb." FORMAT "zzzzz9"
      aux_tprepass       LABEL "Forma de Repasse" FORMAT "x(03)"
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos_dom WIDTH 234.
  
 ASSIGN glb_cdprogra = "crps391"
        glb_cdempres = 11.

 RUN fontes/iniprg.p.
 
 
 IF   glb_cdcritic > 0 THEN
      RETURN.
 
 
 /* Busca dados da cooperativa */
 FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

 IF  NOT AVAILABLE crabcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

 ASSIGN aux_arqrel_1 = "rl/crrl348.lst"
        aux_arqrel_2 = "rl/crrl403.lst"
        aux_arqrel_3 = "contab/" + SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2)
                                 + STRING(MONTH(glb_dtmvtolt),"99")
                                 + STRING(DAY(glb_dtmvtolt),"99") + "_REPCNVFIL.txt"
								 
		aux_arqrel_4 = "contab/" + SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2)
                                 + STRING(MONTH(glb_dtmvtolt),"99")
                                 + STRING(DAY(glb_dtmvtolt),"99") + "_TARIFA_CONVENIOS.txt".
								 
                                 
 {includes/cabrel132_1.i }
 {includes/cabrel132_2.i }

 OUTPUT STREAM str_1 TO VALUE(aux_arqrel_1) PAGED PAGE-SIZE 62.
 OUTPUT STREAM str_2 TO VALUE(aux_arqrel_2) PAGED PAGE-SIZE 62.
 OUTPUT STREAM str_3 TO VALUE(aux_arqrel_3) PAGED PAGE-SIZE 62.
 OUTPUT STREAM str_4 TO VALUE(aux_arqrel_4) PAGED PAGE-SIZE 62.

 VIEW STREAM str_1 FRAME f_cabrel132_1.
 VIEW STREAM str_2 FRAME f_cabrel132_2.

 ASSIGN aux_tpdcontr_1 = 1 
        aux_tpdcontr_2 = 1.
 ASSIGN aux_tparrecada = "CX".
 ASSIGN aux_titulo_rel1 = "LANCAMENTOS - COOPERATIVA (CAIXA)"
        aux_titulo_rel2 = "REPASSE P/COOPERATIVAS (CAIXA)".
 

 RUN processa_convenios_deb_cred.            /* gncontr.tpdcontr = 1 */

 ASSIGN aux_vlapagar   = 0
        aux_qtdoctos   = 0
        aux_vldoctos   = 0
        aux_vltarifa   = 0
        aux_vlrrepas   = 0
        aux_ttvlapagar = 0 
        aux_ttqtdoctos = 0
        aux_ttvldoctos = 0
        aux_ttvltarifa = 0
        aux_ttvlrrepas = 0
        aux_ggvlapagar = 0
        aux_ggqtdoctos = 0
        aux_ggvldoctos = 0
        aux_ggvltarifa = 0
        aux_ggvlrrepas = 0
        aux_vlapaga2   = 0 
        aux_vldocto2   = 0.

 ASSIGN aux_tpdcontr_1 = 4
        aux_tpdcontr_2 = 4
        aux_flgradar = FALSE.
 ASSIGN aux_tparrecada = "DB".
 ASSIGN aux_titulo_rel1 = "LANCAMENTOS - COOPERATIVA (DEBITO AUTOMATICO)"
        aux_titulo_rel2 = "REPASSE P/COOPERATIVAS (DEBITO AUTOMATICO)".
  
 RUN processa_convenios_deb_cred.            /* gncontr.tpdcontr = 4 */

 ASSIGN aux_vlapagar   = 0
        aux_qtdoctos   = 0
        aux_vldoctos   = 0
        aux_vltarifa   = 0
        aux_vlrrepas   = 0
        aux_ttvlapagar = 0 
        aux_ttqtdoctos = 0
        aux_ttvldoctos = 0
        aux_ttvltarifa = 0
        aux_ttvlrrepas = 0
        aux_ggvlapagar = 0
        aux_ggqtdoctos = 0
        aux_ggvldoctos = 0
        aux_ggvltarifa = 0
        aux_ggvlrrepas = 0
        aux_vlapaga2   = 0 
        aux_vldocto2   = 0.

 ASSIGN aux_tpdcontr_1 = 1 
        aux_tpdcontr_2 = 4
        aux_flgradar = TRUE.
 ASSIGN aux_tparrecada = "".
 ASSIGN aux_titulo_rel1 = "LANCAMENTOS - COOPERATIVA (CAIXA/DEBITO AUTOMATICO)"
        aux_titulo_rel2 = "REPASSE P/COOPERATIVAS(CAIXA/DEBITO AUTOMATICO)".
 
 
 EMPTY TEMP-TABLE tt-arq-conve.
 
 RUN processa_convenios_deb_cred.   /* gncontr.tpdcontr = 1 ou 4 */
 
 
 ASSIGN aux_tpdcontr_1 = 3
        aux_flgradar = FALSE.
        
 RUN processa_sequencia_integracao.          /* gncontr.tpdcontr = 3 */
   
 OUTPUT STREAM str_1 CLOSE.
 OUTPUT STREAM str_2 CLOSE.

 
 ASSIGN glb_nrcopias = 2
        glb_nmformul = "234dh"
        glb_nmarqimp = aux_arqrel_1.

 RUN fontes/imprim.p.
 
 /* Cria o arquivo do projeto 214*/
 FOR EACH tt-arq-radar NO-LOCK
     BREAK BY tt-arq-radar.cdcooper:           
     
     IF tt-arq-radar.cdcooper <> 3 THEN
     DO:
         IF FIRST-OF (tt-arq-radar.cdcooper) THEN
         DO:         
            ASSIGN aux_arqrel_3 = "/usr/coop/" + tt-arq-radar.dsdircop + "/" + "contab/" 
                                 + SUBSTRING(STRING(YEAR(tt-arq-radar.dtmvtolt),"9999"),3,2)
                                 + STRING(MONTH(tt-arq-radar.dtmvtolt),"99")
                                 + STRING(DAY(tt-arq-radar.dtmvtolt),"99") + "_REPCNVFIL.txt".
                               
            OUTPUT STREAM str_3 TO VALUE(aux_arqrel_3).  
         END.
         IF tt-arq-radar.vlapagar > 0 THEN
         DO:
           ASSIGN aux_linhaarq = '50'
                                + STRING(DAY(tt-arq-radar.dtmvtolt),'99') 
                                + STRING(MONTH(tt-arq-radar.dtmvtolt),'99') 
                                + SUBSTRING(STRING(YEAR(tt-arq-radar.dtmvtolt),'9999'),3,2)
                                + ',' + STRING(DAY(tt-arq-radar.dtmvtolt),'99') 
                                      + STRING(MONTH(tt-arq-radar.dtmvtolt),'99') 
                                      + SUBSTRING(STRING(YEAR(tt-arq-radar.dtmvtolt),'9999'),3,2)
                                + ',' + STRING(tt-arq-radar.nrctdbfl, '9999')
                                + ',1452'
                                + ',' + TRIM(REPLACE(STRING(tt-arq-radar.vlapagar,'zzzzzzzz9.99'),',','.'))
                                + ',231'
                                + ',"ARRECADACAO CONVENIO ' + STRING(tt-arq-radar.nmempres)+ '"'.                              
                                  
           PUT STREAM str_3 aux_linhaarq FORMAT "x(150)" SKIP. 
         END.
           
         IF  LAST-OF(tt-arq-radar.cdcooper) THEN
         DO: 
            OUTPUT STREAM str_3 CLOSE.
            
            /* Move para nova pasta */
            
            UNIX SILENT VALUE("ux2dos " + aux_arqrel_3 + 
              " > /usr/sistemas/arquivos_contabeis/ayllos/"
                            + SUBSTRING(STRING(YEAR(tt-arq-radar.dtmvtolt),"9999"),3,2)
                            + STRING(MONTH(tt-arq-radar.dtmvtolt),"99")
                            + STRING(DAY(tt-arq-radar.dtmvtolt),"99") + "_" + STRING(tt-arq-radar.cdcooper,"99") + "_REPCNVFIL.txt 2>/dev/null").
                        
         END.
     END.
 END.
 
 /* criar arquivo contabil prj421*/
 
 ASSIGN aux_flgarqvi = FALSE.    

 FOR EACH tt-arq-conve NO-LOCK:           
         
         if not aux_flgarqvi then
         do:
            ASSIGN aux_arqrel_4 = "/usr/coop/" + crabcop.dsdircop + "/" + "contab/" 
                                 + SUBSTRING(STRING(YEAR(tt-arq-conve.dtmvtolt),"9999"),3,2)
                                 + STRING(MONTH(tt-arq-conve.dtmvtolt),"99")
                                 + STRING(DAY(tt-arq-conve.dtmvtolt),"99") + "_TARIFA_CONVENIOS.txt".
                               
            OUTPUT STREAM str_4 TO VALUE(aux_arqrel_4).  
            ASSIGN aux_flgarqvi = TRUE. 
         end.
          
         IF tt-arq-conve.vltarifa > 0 THEN
         DO:
           ASSIGN aux_linhaarq = STRING(YEAR(tt-arq-conve.dtmvtolt),'9999')		                         
                                + STRING(MONTH(tt-arq-conve.dtmvtolt),'99') 
                                + STRING(DAY(tt-arq-conve.dtmvtolt),'99')  
                                + ',' + STRING(DAY(tt-arq-conve.dtmvtolt),'99') 
                                      + STRING(MONTH(tt-arq-conve.dtmvtolt),'99') 
                                      + STRING(YEAR(tt-arq-conve.dtmvtolt),'9999')
						        + ',1889'
                                + ',' + STRING(tt-arq-conve.nrctdbfl, '9999')                                
                                + ',' + TRIM(REPLACE(STRING(tt-arq-conve.vltarifa,'zzzzzzzz9.99'),',','.'))
                                + ',5210'
                                + ',"TARIFA REPASSE CONVENIO ' + STRING(tt-arq-conve.nmempres) + ' DAS COOP. FILIADAS - A RECEBER"'.                              
                                  
           PUT STREAM str_4 aux_linhaarq FORMAT "x(150)" SKIP. 
         END.
                                             

 END.

 IF aux_flgarqvi THEN
 DO:
   OUTPUT STREAM str_4 CLOSE.
            
   /* Move para nova pasta */
            
   UNIX SILENT VALUE("ux2dos " + aux_arqrel_4 + 
              " > /usr/sistemas/arquivos_contabeis/ayllos/"
                            + SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2)
                            + STRING(MONTH(glb_dtmvtolt),"99")
                            + STRING(DAY(glb_dtmvtolt),"99") + "_" + string(glb_cdcooper,"99") + "_TARIFA_CONVENIOS.txt 2>/dev/null").

 END. 
 
 
 IF glb_cdcooper = 3  THEN
    DO:
        /* Move para diretorio converte para utilizar na BO */
        UNIX SILENT VALUE 
                    ("cp " + aux_arqrel_1 + " /usr/coop/" +
                     crabcop.dsdircop + "/converte" + 
                     " 2> /dev/null").

        /* envio de email */
        RUN sistema/generico/procedures/b1wgen0011.p
            PERSISTENT SET b1wgen0011.
             
        RUN enviar_email IN b1wgen0011
                         (INPUT glb_cdcooper,
                          INPUT glb_cdprogra,
                          INPUT "financeiro@ailos.coop.br," +
                                "convenios@ailos.coop.br",
                          INPUT '"Lancamentos Arrecadacoes Convenios"' +
                                " - " + CAPS(crabcop.nmrescop),
                          INPUT SUBSTRING(aux_arqrel_1, 4),
                          INPUT TRUE).
      
        DELETE PROCEDURE b1wgen0011. 
    END. 
 /* relatorio - CECRED */
 ASSIGN glb_nrcopias = 1
        glb_nmformul = "234dh"
        glb_nmarqimp = aux_arqrel_2.

 RUN fontes/imprim.p.  
    
 RUN fontes/fimprg.p.


PROCEDURE processa_convenios_deb_cred.

    DEF VAR aux_nrdocmto AS INTE   NO-UNDO.
    DEF VAR aux_nrrectvl AS RECID  NO-UNDO.
    DEF VAR aux_nrreclcm AS RECID  NO-UNDO.

    DEF VAR aux_dtagendt AS DATE   NO-UNDO.
    
    DEF VAR h-b1wgen0015 AS HANDLE NO-UNDO.

    ASSIGN aux_dtagendt = glb_dtmvtopr + 1.

    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

    IF VALID-HANDLE(h-b1wgen0015) THEN
    DO:
        RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                              INPUT TRUE, /* feriado */
                                              INPUT FALSE, /* proximo dia util*/
                                              INPUT-OUTPUT aux_dtagendt).

        DELETE PROCEDURE h-b1wgen0015.
    END.
    
    DISP  STREAM str_1 aux_titulo_rel1 
          WITH  FRAME f_titulo_rel1.

    DISP  STREAM str_2 aux_titulo_rel1
          WITH  FRAME f_titulo_rel1.

    FOR EACH  gncontr NO-LOCK WHERE
              gncontr.dtmvtolt = glb_dtmvtolt AND   
              gncontr.cdconven <> 39          AND   /* Seguro auto convenio */
             (gncontr.tpdcontr = aux_tpdcontr_1 OR
              gncontr.tpdcontr = aux_tpdcontr_2),
        FIRST crapcop NO-LOCK WHERE
              crapcop.cdcooper = gncontr.cdcooper,
        FIRST gnconve NO-LOCK WHERE
              gnconve.cdconven = gncontr.cdconven
        BREAK BY gncontr.cdcooper
              BY gnconve.cdcooper
              BY gncontr.cdconven:

        ASSIGN aux_nmrescop = crapcop.nmrescop.
     
        FIND b_crapcop NO-LOCK WHERE
             b_crapcop.cdcooper = gnconve.cdcooper NO-ERROR.
 
        ASSIGN aux_nmcopdom = b_crapcop.nmrescop.
        
        DISP STREAM str_1
             aux_nmrescop
             gnconve.nmempres
             gncontr.qtdoctos  
             gncontr.vldoctos  
             gncontr.vltarifa  
             gncontr.vlapagar 
             aux_nmcopdom    
             aux_tparrecada
             WITH FRAME f_movtos.
        
        DOWN STREAM str_1 WITH FRAME f_movtos.
        
        DISP STREAM str_1
             " " @ aux_nmrescop
             " " @ gnconve.nmempres
             " " @ gncontr.qtdoctos  
             " " @ gncontr.vldoctos  
             " " @ gncontr.vltarifa  
             " " @ gncontr.vlapagar 
             " " @ aux_nmcopdom    
             " " @ aux_tparrecada
             WITH FRAME f_movtos.
        
        DOWN STREAM str_1 WITH FRAME f_movtos.
    
        IF   TRIM(aux_nmrescop) = "AILOS"   OR
             TRIM(aux_nmcopdom) = "AILOS"   OR
             TRIM(aux_nmrescop) = "CECRED"  OR
             TRIM(aux_nmcopdom) = "CECRED"  THEN
             DO:
    
                DISP STREAM str_2
                     aux_nmrescop
                     gnconve.nmempres
                     gncontr.qtdoctos  
                     gncontr.vldoctos  
                     gncontr.vltarifa  
                     gncontr.vlapagar 
                     aux_nmcopdom    
                     aux_tparrecada
                     WITH FRAME f_movtos.
    
                DOWN STREAM str_2 WITH FRAME f_movtos.
     
                DISP STREAM str_2
                     " " @ aux_nmrescop
                     " " @ gnconve.nmempres
                     " " @ gncontr.qtdoctos  
                     " " @ gncontr.vldoctos  
                     " " @ gncontr.vltarifa  
                     " " @ gncontr.vlapagar 
                     " " @ aux_nmcopdom    
                     " " @ aux_tparrecada
                     WITH FRAME f_movtos.
    
                DOWN STREAM str_2 WITH FRAME f_movtos.
             END. 

       IF   gnconve.cdhisrep > 0   THEN
            DO:
                ASSIGN aux_cdhisrep = gnconve.cdhisrep
                       aux_vlrsalvo = aux_vlapagar
                       aux_vlapagar = gncontr.vlapagar
                       aux_vlpagcov = aux_vlpagcov + gncontr.vlapagar.

                IF  gncontr.cdcooper <> gnconve.cdcooper   AND 
                    aux_vlapagar > 0                       THEN
                    RUN prepara_lancamento.
                         
                ASSIGN aux_vlapagar = aux_vlrsalvo.
               
            END.
       ELSE
            DO:
                ASSIGN aux_vlapagar = aux_vlapagar +  gncontr.vlapagar
                       aux_cdhisrep = 749.
            END.
		
		// caso o valor de repasse for bruto então deve ser gerado 
		// no arquivo contabil PRJ421.
        IF  gnconve.flgrepas AND gnconve.nrctdbfl > 0  THEN
        DO:
		    FIND tt-arq-conve NO-LOCK WHERE
                 tt-arq-conve.cdconven = gncontr.cdconven NO-ERROR.
			//verifica se o convenio ja existe na tabela, se existir somar valor da tarifa
            // pois deve haver apenas um lancamento no arquivo do convenio com o valor total			
	        IF AVAIL tt-arq-conve THEN 
		       ASSIGN tt-arq-conve.vltarifa =  tt-arq-conve.vltarifa + gncontr.vltarifa.
			ELSE
			DO: 
				CREATE tt-arq-conve.
				ASSIGN tt-arq-conve.cdcooper = gncontr.cdcooper
					   tt-arq-conve.dtmvtolt = gncontr.dtmvtolt
					   tt-arq-conve.vltarifa = gncontr.vltarifa
					   tt-arq-conve.nmempres = gnconve.nmempres
					   tt-arq-conve.nrctdbfl = gnconve.nrctdbfl
					   tt-arq-conve.dsdircop = crapcop.dsdircop
					   tt-arq-conve.cdconven = gncontr.cdconven.
		    END.		   
		END.
		
        IF aux_flgradar  AND gnconve.nrctdbfl > 0  THEN  /*escreve a linha no arquivo*/
        DO: 
            CREATE tt-arq-radar. 
            ASSIGN tt-arq-radar.cdcooper = gncontr.cdcooper
                   tt-arq-radar.dtmvtolt = gncontr.dtmvtolt
                   tt-arq-radar.tpdcontr = gncontr.tpdcontr
                   tt-arq-radar.nrctdbfl = gnconve.nrctdbfl
                   tt-arq-radar.vlapagar = gncontr.vlapagar
                   tt-arq-radar.nmempres = gnconve.nmempres
                   tt-arq-radar.dsdircop = crapcop.dsdircop.
       END. 
       IF  LAST-OF(gncontr.cdcooper)  OR
           LAST-OF(gnconve.cdcooper) THEN
           DO:
         
               IF  gncontr.cdcooper <> gnconve.cdcooper  THEN
                   DO:
             
                       IF   aux_vlapagar = 0   THEN
                            DISP  STREAM str_1
                                  aux_nmrescop
                                  "TOTAL(LANCAMENTO P/)" @ gnconve.nmempres
                                  " " @ gncontr.qtdoctos  
                                  " " @ gncontr.vldoctos  
                                  " " @ gncontr.vltarifa  
                                  aux_vlpagcov @ gncontr.vlapagar 
                                  aux_nmcopdom    
                                  aux_tparrecada
                                  WITH FRAME f_movtos.                      
                       ELSE
                            DISP  STREAM str_1
                                  aux_nmrescop
                                  "TOTAL(LANCAMENTO P/)" @ gnconve.nmempres
                                  " " @ gncontr.qtdoctos  
                                  " " @ gncontr.vldoctos  
                                  " " @ gncontr.vltarifa  
                                  aux_vlapagar @ gncontr.vlapagar 
                                  aux_nmcopdom    
                                  aux_tparrecada
                                  WITH FRAME f_movtos.

                       DOWN STREAM str_1 WITH FRAME f_movtos.
               
                       DISP STREAM str_1
                            " " @ aux_nmrescop
                            " " @ gnconve.nmempres
                            " " @ gncontr.qtdoctos  
                            " " @ gncontr.vldoctos  
                            " " @ gncontr.vltarifa  
                            " " @ gncontr.vlapagar 
                            " " @ aux_nmcopdom    
                            " " @ aux_tparrecada
                            WITH FRAME f_movtos.

                       DOWN STREAM str_1 WITH FRAME f_movtos.

                       IF   aux_vlapagar > 0   THEN
                            RUN prepara_lancamento.
                   END.
               ELSE
                   DO:
                         
                      DISP  STREAM str_1
                            aux_nmrescop
                            " TOTAL " @ gnconve.nmempres
                            " " @ gncontr.qtdoctos  
                            " " @ gncontr.vldoctos  
                            " " @ gncontr.vltarifa  
                            aux_vlapagar @ gncontr.vlapagar 
                            aux_nmcopdom  
                            aux_tparrecada
                            WITH FRAME f_movtos.

                      DOWN STREAM str_1 WITH FRAME f_movtos.
 
                      DISP STREAM str_1
                           " " @ aux_nmrescop
                           " " @ gnconve.nmempres
                           " " @ gncontr.qtdoctos  
                           " " @ gncontr.vldoctos  
                           " " @ gncontr.vltarifa  
                           " " @ gncontr.vlapagar 
                           " " @ aux_nmcopdom    
                           " " @ aux_tparrecada
                           WITH FRAME f_movtos.
                     DOWN STREAM str_1 WITH FRAME f_movtos.

                   END.

              DISP  STREAM str_1
                    " " @ aux_nmrescop
                    " " @ gnconve.nmempres
                    " " @ gncontr.qtdoctos  
                    " " @ gncontr.vldoctos  
                    " " @ gncontr.vltarifa  
                    " " @ gncontr.vlapagar 
                    " " @ aux_nmcopdom    
                    " " @ aux_tparrecada  
                    WITH FRAME f_movtos.
              DOWN STREAM str_1 WITH FRAME f_movtos.
               
              DISP STREAM str_1
                   " " @ aux_nmrescop
                   " " @ gnconve.nmempres
                   " " @ gncontr.qtdoctos  
                   " " @ gncontr.vldoctos  
                   " " @ gncontr.vltarifa  
                   " " @ gncontr.vlapagar 
                   " " @ aux_nmcopdom    
                   " " @ aux_tparrecada
                   WITH FRAME f_movtos.
              DOWN STREAM str_1 WITH FRAME f_movtos.

              ASSIGN aux_vlapagar = 0
                     aux_vlpagcov = 0.   
                     
           END.
    END.     /* for each gncontr */ 
 
    PAGE STREAM str_1.
    PAGE STREAM str_2.
    
    
    ASSIGN aux_qtdoctos = 0
           aux_vldoctos = 0
           aux_vltarifa = 0
           aux_vlapagar = 0
           aux_vldocto2 = 0 
           aux_vlapaga2 = 0.
    
    DISP  STREAM str_1 aux_titulo_rel2 
          WITH  FRAME f_titulo_rel2.
    
    DISP  STREAM str_2 aux_titulo_rel2
          WITH  FRAME f_titulo_rel2.
    
    /*---- Resumo por Cooperativa(Dominio) /Convenio ---*/
    
    FOR EACH  gncontr NO-LOCK WHERE
              gncontr.dtmvtolt = glb_dtmvtolt AND 
              gncontr.cdconven <> 39          AND   /* Seguro auto convenio */
             (gncontr.tpdcontr = aux_tpdcontr_1 OR 
              gncontr.tpdcontr = aux_tpdcontr_2),
        FIRST gnconve NO-LOCK WHERE
              gnconve.cdconven = gncontr.cdconven,
        FIRST crapcop NO-LOCK WHERE
              crapcop.cdcooper = gnconve.cdcooper
        BREAK BY gnconve.cdcooper
                 BY gnconve.cdconven
                    BY gncontr.nrsequen:     

        IF  FIRST-OF(gnconve.cdcooper) THEN
            ASSIGN aux_nmrescop     = crapcop.nmrescop.
        
        ASSIGN  aux_qtdoctos = aux_qtdoctos +  gncontr.qtdoctos 
                aux_vldoctos = aux_vldoctos +  gncontr.vldoctos  
                aux_vltarifa = aux_vltarifa +  gncontr.vltarifa  
                aux_vlapagar = aux_vlapagar +  gncontr.vlapagar
                aux_vldocto2 = aux_vldocto2 +  gncontr.vldocto2. 
                
        ASSIGN  aux_ttqtdoctos = aux_ttqtdoctos +  gncontr.qtdoctos 
                aux_ttvldoctos = aux_ttvldoctos +  gncontr.vldoctos  
                aux_ttvltarifa = aux_ttvltarifa +  gncontr.vltarifa  
                aux_ttvlapagar = aux_ttvlapagar +  gncontr.vlapagar.

        ASSIGN  aux_ggqtdoctos = aux_ggqtdoctos +  gncontr.qtdoctos 
                aux_ggvldoctos = aux_ggvldoctos +  gncontr.vldoctos  
                aux_ggvltarifa = aux_ggvltarifa +  gncontr.vltarifa  
                aux_ggvlapagar = aux_ggvlapagar +  gncontr.vlapagar.
                
        ASSIGN rel_cpfcgrcb = STRING(gnconve.cpfcgrcb,"99999999999999")
               rel_cpfcgrcb = STRING(rel_cpfcgrcb,"xx.xxx.xxx/xxxx-xx").

        ASSIGN aux_dsccdrcb  = INT(SUBSTRING(gnconve.dsccdrcb,1,8))                        
               aux_dsccdrcb2 = STRING(aux_dsccdrcb,"zzzzzzz9") + SUBSTRING(gnconve.dsccdrcb,9,1). 

        IF  LAST-OF(gnconve.cdcooper) OR 
            LAST-OF(gnconve.cdconven) THEN
            DO:
                 
               ASSIGN aux_nrseqcxa = 0
                      aux_nrseqdeb = 0.

               /** Find sem cdcooper para pegar ultima sequencia 
                   de caixa independente da cooperativa **/
               FIND LAST b-gncontr WHERE 
                                   b-gncontr.cdconven = gncontr.cdconven AND
                                   b-gncontr.tpdcontr = 1                AND
                                   b-gncontr.dtmvtolt = gncontr.dtmvtolt
                                   NO-LOCK USE-INDEX gncontr2 NO-ERROR.

               IF  AVAIL(b-gncontr) THEN
                   aux_nrseqcxa = b-gncontr.nrsequen.     
                  
               /** Find sem cdcooper para pegar ultima sequencia 
                   de debito independente da cooperativa **/
               FIND LAST b-gncontr WHERE 
                                   b-gncontr.cdconven = gncontr.cdconven AND
                                   b-gncontr.tpdcontr = 4                AND
                                   b-gncontr.dtmvtolt = gncontr.dtmvtolt
                                   NO-LOCK USE-INDEX gncontr2 NO-ERROR.

               IF  AVAIL(b-gncontr) THEN
                   aux_nrseqdeb = b-gncontr.nrsequen.     


               IF   gnconve.flgrepas  THEN
                    ASSIGN aux_vlrrepas = aux_vldoctos.   /* Bruto */
               ELSE
                    ASSIGN aux_vlrrepas = aux_vlapagar.   /* Liquido */

               ASSIGN aux_ttvlrrepas = aux_ttvlrrepas + aux_vlrrepas
                      aux_ggvlrrepas = aux_ggvlrrepas + aux_vlrrepas.

               ASSIGN aux_tprepass = IF gnconve.tprepass = 1 THEN
                                         "D+1"
                                     ELSE
                                         "D+2".
                    
               DISP STREAM str_1
                    aux_nmrescop
                    gnconve.nmempres
                    aux_qtdoctos  
                    aux_vldoctos  
                    aux_vltarifa  
                    aux_vlapagar 
                    aux_vlrrepas
                    aux_tparrecada
                    gnconve.cdbccrcb
                    gnconve.dsagercb
                    aux_dsccdrcb2
                    rel_cpfcgrcb
                    aux_nrseqcxa
                    aux_nrseqdeb
                    aux_tprepass
                    WITH FRAME f_movtos_dom.
               DOWN STREAM str_1  WITH FRAME f_movtos_dom.
               
               DISP STREAM str_1
                    " " @ aux_nmrescop
                    " " @ gnconve.nmempres
                    " " @ aux_qtdoctos  
                    " " @ aux_vldoctos  
                    " " @ aux_vltarifa  
                    " " @ aux_vlapagar 
                    " " @ aux_vlrrepas
                    " " @ aux_tparrecada    
                    " " @ gnconve.cdbccrcb
                    " " @ gnconve.dsagercb
                    " " @ aux_dsccdrcb2
                    " " @ rel_cpfcgrcb
                    " " @ aux_nrseqcxa
                    " " @ aux_nrseqdeb
                    " " @ aux_tprepass
                    WITH FRAME f_movtos_dom.
               DOWN STREAM str_1 WITH FRAME f_movtos_dom.

               IF  TRIM(crapcop.nmrescop) = "AILOS" OR
                   TRIM(crapcop.nmrescop) = "CECRED" THEN
                   DO: 
                       DISP  STREAM str_2
                             aux_nmrescop
                             gnconve.nmempres
                             aux_qtdoctos  
                             aux_vldoctos  
                             aux_vltarifa  
                             aux_vlapagar
                             aux_vlrrepas
                             aux_tparrecada
                             gnconve.cdbccrcb
                             gnconve.dsagercb
                             aux_dsccdrcb2
                             rel_cpfcgrcb
                             aux_nrseqcxa
                             aux_nrseqdeb
                             WITH FRAME f_movtos_dom.
                       DOWN STREAM str_2 WITH FRAME f_movtos_dom.
               
                       DISP STREAM str_2
                            " " @ aux_nmrescop
                            " " @ gnconve.nmempres
                            " " @ aux_qtdoctos  
                            " " @ aux_vldoctos  
                            " " @ aux_vltarifa  
                            " " @ aux_vlapagar 
                            " " @ aux_vlrrepas
                            " " @ aux_tparrecada    
                            " " @ gnconve.cdbccrcb
                            " " @ gnconve.dsagercb
                            " " @ aux_dsccdrcb2
                            " " @ rel_cpfcgrcb
                            " " @ aux_nrseqcxa
                            " " @ aux_nrseqdeb
                            WITH FRAME f_movtos_dom.
                       DOWN STREAM str_2  WITH FRAME f_movtos_dom.

                       IF aux_tpdcontr_1 = 1 AND 
                          aux_tpdcontr_2 = 4 AND 
						  aux_vlrrepas > 0   THEN /*Somente enviar a TED se valor for maior que zero (SD  567906)*/
                       DO:
                           IF UPPER(SUBSTRING(aux_dsccdrcb2, 9, 1)) = "X" THEN
                               ASSIGN aux_dsccdrcb2 = 
                                   SUBSTRING(aux_dsccdrcb2, 1, 8) + "0".

                           ASSIGN aux_dsccdrcb  = INT(aux_dsccdrcb2).
                        
                           RUN enviar-ted (INPUT aux_nmrescop,
                                           INPUT 1, /* idorigem */
                                           INPUT 1, /* cdageope */
                                           INPUT 0, /* nrcxaope */
                                           INPUT "", /* cdoperad */
                                           INPUT "", /* cdopeaut */
                                           INPUT aux_vlrrepas, /* vldocmto */
                                           INPUT aux_nrdconta_debito, /* nrdconta */
                                           INPUT 1, /* idseqttl */
                                           INPUT "AILOS", /* nmprimtl */
                                           INPUT 05463212, /* nrcpfcgc */
                                           INPUT 2, /* inpessoa */
                                           INPUT gnconve.cdbccrcb, /* cdbanfav */
                                           INPUT gnconve.dsagercb, /* cdagefav */
                                           INPUT aux_dsccdrcb, /* nrctafav */
                                           INPUT gnconve.nmempres, /* nmfavore */
                                           INPUT gnconve.cpfcgrcb, /* nrcpffav */
                                           INPUT 2, /* inpesfav */
                                           INPUT 1, /* tpctafav - 1 = CC */
                                           INPUT "CRPS391", /* dshistor */
                                           INPUT STRING(crapcop.nrdocnpj), /* dstransf */
                                           INPUT 5, /* cdfinali */
                                           INPUT IF gnconve.tprepass = 2 THEN /* dtagendt */
                                                     aux_dtagendt
                                                 ELSE
                                                     ?,
                                           INPUT aux_nrseqcxa, /* nrseqarq */
                                           INPUT gnconve.cdconven, /* cdconven */
                                          OUTPUT aux_nrdocmto,
                                          OUTPUT aux_nrrectvl,
                                          OUTPUT aux_nrreclcm).    

                       END.
                   END.

               ASSIGN aux_qtdoctos = 0
                      aux_vldoctos = 0
                      aux_vltarifa = 0
                      aux_vlapagar = 0
                      aux_vlrrepas = 0
                      aux_nmrescop = " ".
            END.
 
        IF  LAST-OF(gnconve.cdcooper) THEN
            DO:
               DISP  STREAM str_1
                     aux_nmrescop
                     "TOTAL" @ gnconve.nmempres
                     aux_ttqtdoctos @ aux_qtdoctos  
                     aux_ttvldoctos @ aux_vldoctos
                     aux_ttvltarifa @ aux_vltarifa
                     aux_ttvlapagar @ aux_vlapagar
                     aux_ttvlrrepas @ aux_vlrrepas
                     aux_tparrecada 
                     WITH FRAME f_movtos_dom.
               DOWN STREAM str_1 WITH FRAME f_movtos_dom.

               DISP STREAM str_1
                    " " @ aux_nmrescop
                    " " @ gnconve.nmempres
                    " " @ aux_qtdoctos  
                    " " @ aux_vldoctos  
                    " " @ aux_vltarifa  
                    " " @ aux_vlapagar 
                    " " @ aux_vlrrepas
                    " " @ aux_tparrecada
                    " " @ gnconve.cdbccrcb
                    " " @ gnconve.dsagercb
                    " " @ aux_dsccdrcb2
                    " " @ rel_cpfcgrcb
                    WITH FRAME f_movtos_dom.
               DOWN STREAM str_1 WITH FRAME f_movtos_dom.
               
               IF   TRIM(crapcop.nmrescop) = "AILOS" OR
                    TRIM(crapcop.nmrescop) = "CECRED" THEN
                    DO:
                        DISP  STREAM str_2
                              aux_nmrescop
                              "TOTAL" @ gnconve.nmempres
                              aux_ttqtdoctos @ aux_qtdoctos  
                              aux_ttvldoctos @ aux_vldoctos
                              aux_ttvltarifa @ aux_vltarifa
                              aux_ttvlapagar @ aux_vlapagar
                              aux_ttvlrrepas @ aux_vlrrepas
                              aux_tparrecada 
                              WITH FRAME f_movtos_dom.
                        DOWN  STREAM str_2 WITH FRAME f_movtos_dom.

                        DISP STREAM str_2
                             " " @ aux_nmrescop
                             " " @ gnconve.nmempres
                             " " @ aux_qtdoctos  
                             " " @ aux_vldoctos  
                             " " @ aux_vltarifa  
                             " " @ aux_vlapagar 
                             " " @ aux_vlrrepas
                             " " @ aux_tparrecada
                             " " @ gnconve.cdbccrcb
                             " " @ gnconve.dsagercb
                             " " @ aux_dsccdrcb2
                             " " @ rel_cpfcgrcb
                             WITH FRAME f_movtos_dom.
                        DOWN  STREAM str_2 WITH FRAME f_movtos_dom.

                    END.
               
               ASSIGN aux_ttqtdoctos = 0
                      aux_ttvldoctos = 0
                      aux_ttvltarifa = 0
                      aux_ttvlapagar = 0
                      aux_ttvlrrepas = 0.
                      
               
            END.
            
         
            
     END.     /* for each gncontr */ 

     DISP  STREAM str_1
                  "TOTAL" @ aux_nmrescop
                  "GERAL" @ gnconve.nmempres
                  aux_ggqtdoctos @ aux_qtdoctos  
                  aux_ggvldoctos @ aux_vldoctos
                  aux_ggvltarifa @ aux_vltarifa
                  aux_ggvlapagar @ aux_vlapagar
                  aux_ggvlrrepas @ aux_vlrrepas
                  aux_tparrecada
                  WITH FRAME f_movtos_dom.
     DOWN STREAM str_1 WITH FRAME f_movtos_dom.
     
     PAGE STREAM str_1.
     PAGE STREAM str_2.
     PAGE STREAM str_3.

END PROCEDURE.

PROCEDURE prepara_lancamento.
   
   /* Cooperativa a ser efetuado o debito */
   FIND FIRST crapass WHERE
              crapass.cdcooper = glb_cdcooper      AND
              crapass.nrcpfcgc = crapcop.nrdocnpj  AND         
              crapass.nrdconta = crapcop.nrctactl  NO-ERROR.
              
   IF NOT AVAILABLE crapass THEN
      DO:
          ASSIGN glb_dscritic = "Conta para arrecadacao de convenio nao encontrada.".
          MESSAGE glb_dscritic.
          RETURN "NOK".
      END.
          
   ASSIGN aux_nrdconta_debito  = crapass.nrdconta.

   /* Cooperativa a receber o credito */
   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                            crapass.nrcpfcgc = b_crapcop.nrdocnpj
                            NO-LOCK NO-ERROR.
   ASSIGN aux_nrdconta_credito = crapass.nrdconta
          aux_cdcopdom         = b_crapcop.cdcooper.     

   /* Contr.p/ nao efetuar lancamento novamente qdo total */
   IF  aux_tpdcontr_1 = aux_tpdcontr_2 THEN
       RUN efetua_lancamento_debito. 
 
END.

PROCEDURE efetua_lancamento_debito.

    FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                       craplot.dtmvtolt = glb_dtmvtolt  AND
                       craplot.cdagenci = 1             AND
                       craplot.cdbccxlt = 100           AND
                       craplot.nrdolote = 10100
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE craplot   THEN
         DO:

            CREATE craplot.
            ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                   craplot.cdagenci = 1
                   craplot.cdbccxlt = 100
                   craplot.nrdolote = 10100
                   craplot.tplotmov = 1 
                   craplot.nrseqdig = 0
                   craplot.vlcompcr = 0
                   craplot.vlinfocr = 0
                   craplot.vlcompdb = 0
                   craplot.vlinfodb = 0
                   craplot.cdhistor = 0
                   craplot.cdoperad = "1"
                   craplot.dtmvtopg = ?
                   craplot.cdcooper = glb_cdcooper.
         END.

   CREATE craplcm.
   ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.qtinfoln = craplot.qtcompln
          craplot.vlcompdb = craplot.vlcompdb + aux_vlapagar
          craplot.vlinfodb = craplot.vlcompdb
          craplot.vlcompcr = craplot.vlcompcr + 0
          craplot.vlinfocr = craplot.vlcompcr 
                      
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.cdhistor = aux_cdhisrep  /* Debito  */
          craplcm.dtmvtolt = glb_dtmvtolt
          craplcm.cdpesqbb = ""
          craplcm.nrdconta = aux_nrdconta_debito
          craplcm.nrdctabb = craplcm.nrdconta
          craplcm.nrdctitg = STRING(craplcm.nrdconta,"99999999")
          craplcm.nrdocmto = craplot.nrseqdig          
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrseqdig = craplot.nrseqdig
          craplcm.vllanmto = aux_vlapagar
          craplcm.cdcooper = glb_cdcooper.
   VALIDATE craplcm.

   IF   aux_cdcopdom <> 3   THEN
        DO:        
            CREATE craplcm.
            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.qtinfoln = craplot.qtcompln
                   craplot.vlcompdb = craplot.vlcompdb + 0
                   craplot.vlinfodb = craplot.vlcompdb
                   craplot.vlcompcr = craplot.vlcompcr + aux_vlapagar
                   craplot.vlinfocr = craplot.vlcompcr 
                      
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.cdhistor = 362  /* Credito  */
                   craplcm.dtmvtolt = glb_dtmvtolt
                   craplcm.cdpesqbb = ""
                   craplcm.nrdconta = aux_nrdconta_credito
                   craplcm.nrdctabb = craplcm.nrdconta
                   craplcm.nrdctitg = STRING(craplcm.nrdconta,"99999999")
                   craplcm.nrdocmto = craplot.nrseqdig          
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrseqdig = craplot.nrseqdig
                   craplcm.vllanmto = aux_vlapagar
                   craplcm.cdcooper = glb_cdcooper.
            VALIDATE craplcm.
        END.
        
    VALIDATE craplot.

END PROCEDURE.  

PROCEDURE processa_sequencia_integracao.
 
    FOR EACH  gncontr NO-LOCK WHERE
              gncontr.dtmvtolt = glb_dtmvtolt AND
              gncontr.tpdcontr = aux_tpdcontr_1, 
        FIRST crapcop NO-LOCK WHERE
              crapcop.cdcooper = gncontr.cdcooper
        BREAK BY gncontr.cdconven
              BY gncontr.nrsequen:
       
        IF  LAST-OF(gncontr.cdconven) THEN
            DO:
       
               FIND FIRST gnconve WHERE
                          gnconve.cdconve = gncontr.cdconven NO-ERROR.
               IF  AVAIL gnconve THEN          
                   ASSIGN gnconve.nrseqint = gncontr.nrsequen + 1.
            END.
    END.
END PROCEDURE.

PROCEDURE enviar-ted:

    DEF  INPUT PARAM par_nmrescop AS CHAR  NO-UNDO. /* Cooperativa            */
    DEF  INPUT PARAM par_idorigem AS INTE  NO-UNDO. /* Origem                 */
    DEF  INPUT PARAM par_cdageope AS INTE  NO-UNDO. /* PAC Operador           */
    DEF  INPUT PARAM par_nrcxaope AS INTE  NO-UNDO. /* Caixa Operador         */
    DEF  INPUT PARAM par_cdoperad AS CHAR  NO-UNDO. /* Operador               */ 
    DEF  INPUT PARAM par_cdopeaut AS CHAR  NO-UNDO. /* Operador Autorizacao   */
    DEF  INPUT PARAM par_vldocmto AS DECI  NO-UNDO. /* Valor TED              */
    DEF  INPUT PARAM par_nrdconta AS INTE  NO-UNDO. /* Conta Remetente        */
    DEF  INPUT PARAM par_idseqttl AS INTE  NO-UNDO. /* Titular                */
    DEF  INPUT PARAM par_nmprimtl AS CHAR  NO-UNDO. /* Nome Remetente         */
    DEF  INPUT PARAM par_nrcpfcgc AS DECI  NO-UNDO. /* CPF/CNPJ Remetente     */
    DEF  INPUT PARAM par_inpessoa AS INTE  NO-UNDO. /* Tipo Pessoa Remetente  */
    DEF  INPUT PARAM par_cdbanfav AS INTE  NO-UNDO. /* Banco Favorecido       */
    DEF  INPUT PARAM par_cdagefav AS CHAR  NO-UNDO. /* Agencia Favorecido     */
    DEF  INPUT PARAM par_nrctafav AS DECI  NO-UNDO. /* Conta Favorecido       */ 
    DEF  INPUT PARAM par_nmfavore AS CHAR  NO-UNDO. /* Nome Favorecido        */
    DEF  INPUT PARAM par_nrcpffav AS DECI  NO-UNDO. /* CPF/CNPJ Favorecido    */
    DEF  INPUT PARAM par_inpesfav AS INTE  NO-UNDO. /* Tipo Pessoa Favorecido */
    DEF  INPUT PARAM par_tpctafav AS INTE  NO-UNDO. /* Tipo Conta Favorecido  */ 
    DEF  INPUT PARAM par_dshistor AS CHAR  NO-UNDO. /* Descricao Historico    */
    DEF  INPUT PARAM par_dstransf AS CHAR  NO-UNDO. /* Identificacao Transf.  */
    DEF  INPUT PARAM par_cdfinali AS INTE  NO-UNDO. /* Finalidade TED         */ 
    DEF  INPUT PARAM par_dtagendt AS DATE  NO-UNDO. /* Data Agendamento       */
    DEF  INPUT PARAM par_nrseqarq AS INTE  NO-UNDO. /* Sequencial arq arrecada*/
    DEF  INPUT PARAM par_cdconven AS INTE  NO-UNDO. /* Codigo do convenio     */

    DEF OUTPUT PARAM par_nrdocmto AS INTE  NO-UNDO. /* Documento TED          */
    DEF OUTPUT PARAM par_nrrectvl AS RECID NO-UNDO. /* Autenticacao TVL       */
    DEF OUTPUT PARAM par_nrreclcm AS RECID NO-UNDO. /* Autenticacao LCM       */

    DEF VAR aux_nrctrlif AS CHAR NO-UNDO.
    DEF VAR aux_dslitera AS CHAR NO-UNDO.
    DEF VAR aux_nrcxaope AS INTE NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_cdhisted AS INTE NO-UNDO.
    DEF VAR aux_cdhistor AS INTE NO-UNDO.
    DEF VAR aux_cdhistar AS INTE NO-UNDO.
    DEF VAR aux_nrdolote AS INTE NO-UNDO.
    DEF VAR aux_tpdolote AS INTE NO-UNDO.
    DEF VAR aux_nrultseq AS INTE NO-UNDO.
    DEF VAR aux_ultsqlcm AS INTE NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI NO-UNDO.
    
    DEF VAR aux_cdbattar AS CHAR                         NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                         NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                         NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                         NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                         NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                         NO-UNDO.

    DEF VAR h-b1wgen0046 AS HANDLE                       NO-UNDO.

    DEF VAR aux_nrseqted AS INTE                         NO-UNDO.

    DEF VAR aux_cdagefav AS INTE FORMAT "9999"           NO-UNDO.

    DEF BUFFER crabhis FOR craphis. 

    ASSIGN aux_nrcxaope = par_nrcxaope.

    ASSIGN aux_cdagefav = INTE(SUBSTRING(par_cdagefav, 1, 4)).

    ASSIGN glb_cdcritic = 0
           glb_dscritic = ""
           aux_flgtrans = FALSE.
   
    TRANS_TED:

    DO TRANSACTION ON ERROR  UNDO TRANS_TED, LEAVE TRANS_TED
                   ON ENDKEY UNDO TRANS_TED, LEAVE TRANS_TED:
            
        FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop  THEN
            DO:
                ASSIGN glb_cdcritic  = 651.

                UNDO TRANS_TED, LEAVE TRANS_TED.
            END.
       
        FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapdat  THEN
            DO:
                ASSIGN glb_dscritic = "Sistema sem data de movimento.".

                UNDO TRANS_TED, LEAVE TRANS_TED.
            END.
        
        IF  NOT crapcop.flgoppag  AND 
            NOT crapcop.flgopstr  THEN
            DO:
                ASSIGN glb_dscritic = "Cooperativa nao esta operando no SPB.". 
                
                UNDO TRANS_TED, LEAVE TRANS_TED.
            END.
            
        
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                           crapass.nrdconta = par_nrdconta     NO-LOCK NO-ERROR.
                                   
        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN glb_cdcritic  = 9.
                       
                UNDO TRANS_TED, LEAVE TRANS_TED.
            END.
        
        ASSIGN aux_nrdolote = 23000
               aux_tpdolote = 25
               aux_cdhistor = 523. 
        
        DO aux_contador = 1 TO 10:
    
            FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                               craplot.dtmvtolt = crapdat.dtmvtocd AND
                               craplot.cdagenci = par_cdageope     AND
                               /* alterado de 11 para 100 devido batimento de
                                  lote processo */
                               craplot.cdbccxlt = 100              AND 
                               craplot.nrdolote = aux_nrdolote     
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
            IF  NOT AVAIL craplot  THEN 
                DO: 
                    IF  LOCKED craplot  THEN 
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    ASSIGN glb_dscritic = "Tabela CRAPLOT em uso.".

                                    UNDO TRANS_TED, LEAVE TRANS_TED.
                                END.
                                
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.cdcooper = crapcop.cdcooper
                                   craplot.dtmvtolt = crapdat.dtmvtocd
                                   craplot.cdagenci = par_cdageope
                                   /* alterado de 11 para 100 devido batimento 
                                      de lote processo */
                                   craplot.cdbccxlt = 100              
                                   craplot.nrdolote = aux_nrdolote
                                   craplot.tplotmov = aux_tpdolote
                                   craplot.cdoperad = par_cdoperad
                                   craplot.cdhistor = aux_cdhistor
                                   craplot.nrdcaixa = par_nrcxaope
                                   craplot.cdopecxa = par_cdoperad.
                        END.
                END.
    
            LEAVE.
    
        END. /** Fim do DO ... TO **/
        
        /* Busca a proxima sequencia do campo crapmat.nrseqted */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                            ,INPUT "NRSEQTED"
                                            ,INPUT STRING(crapcop.cdcooper)
                                            ,INPUT "N"
                                            ,"").
        
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
        ASSIGN aux_nrseqted = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        ASSIGN par_nrdocmto = aux_nrseqted
               aux_nrctrlif = "1" + 
                              SUBSTRING(STRING(YEAR(crapdat.dtmvtopr)),3) +
                              STRING(MONTH(crapdat.dtmvtopr),"99") +
                              STRING(DAY(crapdat.dtmvtopr),"99") +
                              STRING(crapcop.cdagectl,"9999") +
                              STRING(par_nrdocmto,"99999999") + 
                              "A".
        
        FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper AND
                           craptvl.tpdoctrf = 3 /* TED SPB */  AND
                           craptvl.idopetrf = aux_nrctrlif     NO-LOCK NO-ERROR.
    
        IF  AVAILABLE craptvl  THEN
            DO:
                ASSIGN glb_dscritic = "ERRO!!! DOCUMENTO DUPLICADO, " + 
                                     "TENTE NOVAMENTE.".
                UNDO TRANS_TED, LEAVE TRANS_TED.
            END.
        
        CREATE craptvl.
        ASSIGN craptvl.cdcooper = crapcop.cdcooper
               craptvl.tpdoctrf = 3
               craptvl.idopetrf = aux_nrctrlif                              
               craptvl.nrdconta = par_nrcpfcgc
               craptvl.cpfcgemi = crapcop.nrdocnpj
               craptvl.nmpesemi = CAPS(par_nmprimtl)
               craptvl.nrdctitg = crapass.nrdctitg
               craptvl.cdbccrcb = par_cdbanfav
               craptvl.cdagercb = aux_cdagefav
               craptvl.cpfcgrcb = par_nrcpffav
               craptvl.nmpesrcb = CAPS(par_nmfavore)
               craptvl.cdbcoenv = crapcop.cdbcoctl
               craptvl.vldocrcb = par_vldocmto
               craptvl.dtmvtolt = crapdat.dtmvtocd
               craptvl.hrtransa = TIME
               craptvl.nrdolote = aux_nrdolote
               craptvl.cdagenci = par_cdageope
               craptvl.cdbccxlt = 11 /* mantido como 11 por compatibilidade */ 
               craptvl.nrdocmto = par_nrdocmto
               craptvl.nrseqdig = craplot.nrseqdig + 1   
               craptvl.nrcctrcb = par_nrctafav
               craptvl.cdfinrcb = par_cdfinali
               craptvl.tpdctacr = par_tpctafav
               craptvl.tpdctadb = 1  /** Conta Corrente **/
               craptvl.dshistor = par_dshistor
               craptvl.cdoperad = par_cdoperad
               craptvl.cdopeaut = par_cdopeaut
               craptvl.flgespec = FALSE
               craptvl.flgtitul = FALSE.
               craptvl.flgenvio = YES. 
          
        IF  par_inpessoa = 1  THEN
            ASSIGN craptvl.flgpesdb = YES.
        ELSE
            ASSIGN craptvl.flgpesdb = NO.
    
        IF  par_inpesfav = 1  THEN
            ASSIGN craptvl.flgpescr = YES.
        ELSE 
            ASSIGN craptvl.flgpescr = NO.
                   
        ASSIGN craplot.qtcompln = craplot.qtcompln + 1
               craplot.vlcompcr = craplot.vlcompcr + par_vldocmto
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.vlinfocr = craplot.vlinfocr + par_vldocmto
               craplot.nrseqdig = craptvl.nrseqdig.
        VALIDATE craplot.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        RUN STORED-PROCEDURE pc_proc_envia_tec_ted_prog 
        aux_handproc = PROC-HANDLE NO-ERROR
                                   (INPUT crapcop.cdcooper /* Cooperativa */
                                   ,INPUT par_cdageope     /* Cod. Agencia */
                                   ,INPUT par_nrcxaope     /* Numero  Caixa */
                                   ,INPUT par_cdoperad     /* Operador */
                                   ,INPUT (IF craptvl.flgtitul = TRUE THEN
                                          1
                                          ELSE
                                          0) /* Mesmo Titular */
                                   ,INPUT par_vldocmto     /* Vlr. DOCMTO */
                                   ,INPUT aux_nrctrlif     /* NumCtrlIF */
                                   ,INPUT par_nrdconta     /* Nro Conta */
                                   ,INPUT par_cdbanfav     /* Codigo Banco */
                                   ,INPUT aux_cdagefav     /* Cod Agencia */
                                   ,INPUT par_nrctafav     /* Nr.Ct.destino */
                                   ,INPUT par_cdfinali     /* Finalidade */
                                   ,INPUT craptvl.tpdctadb /* Tp. conta deb */
                                   ,INPUT par_tpctafav     /* Tp conta cred */
                                   ,INPUT par_nmprimtl     /* Nome Do titular */
                                   ,INPUT ""               /* Nome De 2TTT */
                                   ,INPUT par_nrcpfcgc     /* CPF/CNPJ Do titular */
                                   ,INPUT 0                /* CPF sec TTL */
                                   ,INPUT par_nmfavore     /* Nome Para */
                                   ,INPUT ""               /* Nome Para 2TTL */
                                   ,INPUT par_nrcpffav     /* CPF/CNPJ Para */
                                   ,INPUT 0                /* CPF Para 2TTL */
                                   ,INPUT par_inpessoa     /* Tp. pessoa De */
                                   ,INPUT par_inpesfav     /* Tp. pessoa Para */
                                   ,INPUT 0                /* FALSE - Conta Salario */
                                   ,INPUT par_dstransf     /* tipo de transferencia */
                                   ,INPUT par_idorigem     /* Caixa Online */   
                                   ,INPUT par_dtagendt     /* data egendamento */
                                   ,INPUT par_nrseqarq     /* nr. seq arq. */
                                   ,INPUT par_cdconven     /* Cod. Convenio */
                                   ,INPUT par_dshistor     /* Dsc do Hist. */
                                   ,INPUT TIME             /* Hora transacao */
                                   ,INPUT 0                /* ISPB Banco */
                                   ,INPUT 1 /* DEFAULT 1 --> Flag para verificar se deve validar o horario permitido para TED */
                                   ,OUTPUT 0    /* Codigo do erro */
                                   ,OUTPUT ""). /* Descriçao da crítica */
                                               
        
    
        CLOSE STORED-PROC pc_proc_envia_tec_ted_prog
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN glb_cdcritic = 0
               glb_dscritic = ""
               glb_cdcritic = pc_proc_envia_tec_ted_prog.pr_cdcritic
                               WHEN pc_proc_envia_tec_ted_prog.pr_cdcritic <> ?
               glb_dscritic = pc_proc_envia_tec_ted_prog.pr_dscritic
                               WHEN pc_proc_envia_tec_ted_prog.pr_dscritic <> ?.
        IF  glb_dscritic <> ""  THEN
        DO:
            MESSAGE glb_dscritic.
            UNDO TRANS_TED, LEAVE TRANS_TED.
        END.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION **/

    FIND CURRENT craptvl NO-LOCK NO-ERROR.
    FIND CURRENT craplot NO-LOCK NO-ERROR.

    RELEASE craptvl.
    RELEASE craplot.
    
    IF  NOT aux_flgtrans  THEN
        DO:
            RUN fontes/critic.p.

            IF glb_dscritic = "" THEN
                ASSIGN glb_dscritic = "Nao foi possivel concluir a transacao.".
                
            MESSAGE glb_dscritic.
            
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/*............................................................................*/
