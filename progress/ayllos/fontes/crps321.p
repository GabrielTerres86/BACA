/*************************************************************************
    COMENTAR A INCLUDES envia_dados_postmix PARA NAO ENVIAR OS CONVITES 
    PARA A EMPRESA RESPONSAVEL PELA IMPRESSAO.
*************************************************************************/

/* ............................................................................

   Programa: Fontes/crps321.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Marco/2002.                        Ultima atualizacao: 10/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar informativo para o cooperado da chegada do cartao
               magnetico.
               Atende a solicitacao 090
               Ordem do programa na solicitacao: 002.
               Relatorio: 273 - Formulario LASER (" CRM-laser ").

   Alteracoes: 05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).

               29/04/2005 - Incluida na 3a linha, antes do campo "aux_incartao",
                            o nro do cadastro do cooperado na empresa (Evandro).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego). 

               19/10/2005 - Nao rodar quando Creditextil(Chamado 12601)
                            (Mirtes)
                            
               16/02/2006 - Unificacao do bancos - SQLWorks - Eder
                            
               19/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).

               05/07/2006 - Modificado na 1a linha o campo crapass.nmprimtl por
                            crapcrm.nmtitcrd (David).

               04/09/2006 - Alterado para gerar em FormPrint (Julio)
               
               17/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).
                            
               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)
                            
               13/02/2008 - Chamar nova include "gera_dados_inform_2_postmix.i"
                            e incluido campo cratext.complend (Diego)
                            Alteracao da chamada do FormPrint para envio para
                            PostMix (Julio).

               27/03/2008 - Acerto no envio do arquivo para a PostMix (Julio)
               
               16/04/2008 - Chamar nova includes "envia_dados_postmix.i" 
                            e incluir nova variavel para a includes
                            (Gabriel).
                          
                          - Utilizacao do parametro para emissao das cartas de
                            chegada do cartao magnetico (Gabriel).

               14/08/2008 - Alterado para evitar erro de upload (Gabriel).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                            includes/var_informativos.i (Diego).
                            
               27/05/2010 - Gravar na cratext o cdagenci ou nomedcdd 
                            dependendo o indespac.
                            Unificar as includes de geracao dos dados do
                            FORMPRINT (Gabriel).              
                            
               01/07/2011 - Ajuste nos formatos da cidade e do bairro
                            (Gabriel).             
                          - Inclusao do numero do CEP e da centralizadora dos 
                            correios no separador das cartas;
                          - Tratamento para envio das cartas para a Engecopy 
                            (Elton).
                            
               21/09/2011 - Alimentar sempre cratext.cdagenci.
                          - Atribuir cratext.indespac = 2(Balcao) quando
                            crapdes.indespac <> 1 (Correio) (Diego).
                            
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
............................................................................. */

{ includes/var_batch.i "NEW" }

{ includes/var_informativos.i }

DEF    VAR aux_dslinha1  AS CHAR   EXTENT 3 FORMAT "x(80)"  NO-UNDO.
DEF    VAR aux_dslinha2  AS CHAR   EXTENT 3 FORMAT "x(80)"  NO-UNDO.
DEF    VAR aux_dslinha3  AS CHAR   EXTENT 3 FORMAT "x(80)"  NO-UNDO.
DEF    VAR aux_dslinha4  AS CHAR   EXTENT 3 FORMAT "x(80)"  NO-UNDO.
DEF    VAR aux_nmresemp  AS CHAR   EXTENT 999               NO-UNDO.
DEF    VAR aux_nmagenci  AS CHAR                            NO-UNDO.
DEF    VAR aux_dsidenti  AS CHAR   EXTENT 3 FORMAT "x(30)"  NO-UNDO.

DEF    VAR aux_cdsecext  AS INT                             NO-UNDO.
DEF    VAR aux_cdcooper  AS INT                             NO-UNDO.
DEF    VAR aux_cdcorrei  AS CHAR                            NO-UNDO.

DEF    VAR aux_flgfxser  AS LOGICAL                         NO-UNDO.
DEF    VAR aux_incartao  AS INT                             NO-UNDO.
DEF    VAR aux_nmscript  AS CHAR                            NO-UNDO.

DEF    VAR aux_cdempres  AS INT                             NO-UNDO.

DEF    VAR aux_nmarqeml  AS CHAR                            NO-UNDO.
DEF    VAR aux_conteudo  AS CHAR                            NO-UNDO.
DEF    VAR b1wgen0011    AS HANDLE                          NO-UNDO.

DEF    BUFFER crabcrm FOR crapcrm. 

ASSIGN glb_cdprogra = "crps321".

RUN fontes/iniprg.p.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

IF   crapcop.cdsinfmg = 0    THEN
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

IF   glb_cdcritic > 0 THEN
     QUIT.

ASSIGN  aux_cdcooper = crapcop.cdcooper.

                         /* CARTAO NOVO */
ASSIGN aux_dslinha1[1] = "Informamos que o cartao magnetico de sua" +
                         " conta corrente ja esta disponivel. Esse"
       aux_dslinha2[1] = "cartao possibilitara consulta de saldos," +
                         "  emissao de extratos,  transferencias e"
       aux_dslinha3[1] = "saques no caixa eletronico. Venha logo b" +
                         "uscar o seu e facilite a sua vida."
       aux_dslinha4[1] = ""
       aux_dsidenti[1] = "       CARTAO MAGNETICO"
                         /* RENOVACAO DE CARTAO A VENCER */
       aux_dslinha1[2] = "Seu cartao magnetico  de  conta corrente" +
                         " estara  vencendo  nos  proximos  dias e"
       aux_dslinha2[2] = "deixara de ser aceito no caixa eletronic" +
                         "o. Para sua comodidade providenciamos um"
       aux_dslinha3[2] = "novo cartao.  Continue usufruindo das fa" +
                         "cilidades do caixa eletronico.  Passe no"
       aux_dslinha4[2] = "seu posto de atendimento e retire logo o" +
                         " novo cartao."
       aux_dsidenti[2] = "RENOVACAO DE CARTAO MAGNETICO"
                         /* RENOVACAO DE CARTAO A VENCIDO */
       aux_dslinha1[3] = "Seu cartao magnetico  de  conta corrente" +
                         " venceu e deixou de  ser aceito no caixa"
       aux_dslinha2[3] = "eletronico.  Para  sua  comodidade  prov" +
                         "idenciamos   um  novo  cartao.  Continue"
       aux_dslinha3[3] = "usufruindo  das  facilidades  do  caixa " +
                         " eletronico.   Passe  no  seu  posto  de"
       aux_dslinha4[3] = "atendimento e retire logo seu novo carta" +
                         "o."
       aux_dsidenti[3] = "RENOVACAO DE CARTAO MAGNETICO"
       aux_imlogoin = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                      "_interno.pcx"
       aux_imlogoex = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                      "_externo.pcx"
       aux_cdacesso = ""
       aux_nrsequen = 0
       aux_nmarqimp = "rl/crrl273.lst"
       aux_nmscript = "arq/crrl273.sh"
       aux_nmarqdat = "arq/" + STRING(glb_cdcooper, "99") +
                      "crrl273_" + STRING(DAY(glb_dtmvtolt), "99") + 
                      STRING(MONTH(glb_dtmvtolt), "99") + ".dat".
       
/* Empresas */

FOR EACH crapemp WHERE crapemp.cdcooper = glb_cdcooper  NO-LOCK:
    aux_nmresemp[crapemp.cdempres] = crapemp.nmresemp.
END.

ASSIGN aux_flgfxser = FALSE.

FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper, 

    EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapcrm.nrdconta  AND
                       crapcrm.cdsitcar = 1                 AND
                       crapcrm.tptitcar < 9                 AND
                       crapass.dtdemiss = ?                 NO-LOCK
                       BY crapass.cdagenci 
                          BY crapass.cdsecext 
                             BY crapass.nrdconta:
    
    IF   crapass.inpessoa = 1   THEN 
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

             IF   AVAIL crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.
        
             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.

    IF   crapcop.cdsinfmg = 1   AND
         crapcrm.cdsinfmg = 1   THEN
         NEXT.
        
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper              AND
                       craptab.nmsistem = "CRED"                    AND
                       craptab.tptabela = "AUTOMA"                  AND
                       craptab.cdempres = 00                        AND
                       craptab.cdacesso = "CM" + 
                               STRING(crapcrm.dtemscar,"99999999")  AND
                       craptab.tpregist = 0  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         NEXT.
            
    /* Verifica se o cartao ja esta disponivel */

    IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 1 THEN
         NEXT.
    
    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                       crapemp.cdempres = aux_cdempres      NO-LOCK NO-ERROR.

    
    IF   NOT AVAILABLE crapemp THEN
         DO:
             glb_cdcritic = 40.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0. 
             QUIT.
         END.

    IF   crapass.cdsecext = 0 THEN
         aux_cdsecext = 999.
    ELSE
         aux_cdsecext = crapass.cdsecext.

    FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                       crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage THEN
         DO:
             glb_cdcritic = 15.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0. 
             QUIT.
         END. 
    ELSE
         aux_nmagenci = crapage.nmresage.
    
    FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper      AND
                       crapdes.cdagenci = crapass.cdagenci  AND
                       crapdes.cdsecext = aux_cdsecext 
                       USE-INDEX crapdes1 NO-LOCK NO-ERROR.
        
    IF   NOT AVAILABLE crapdes THEN
         DO:
             glb_cdcritic = 19.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0. 
             QUIT.
         END.    
    
    IF   crapdes.nmsecext = "BALCAO"   THEN
         NEXT.
    
    IF   crapcrm.nrviacar = 1 THEN
         aux_incartao = 1.    
    ELSE
         IF   crapcrm.nrviacar = 2 THEN
              IF   DATE(MONTH(crapcrm.dtvalcar),DAY(crapcrm.dtvalcar),
                        YEAR(crapcrm.dtvalcar) - 3) < glb_dtmvtolt     THEN
                   aux_incartao = 2.
              ELSE
                   aux_incartao = 3.

    IF   NOT aux_flgfxser THEN
         aux_flgfxser = TRUE.
    
    ASSIGN aux_nrsequen = aux_nrsequen + 1.

    CREATE cratext.
    ASSIGN cratext.nrdconta    = crapass.nrdconta
           cratext.cdagenci    = crapass.cdagenci
           cratext.nmprimtl    = crapcrm.nmtitcrd
           cratext.indespac    = IF   crapdes.indespac = 1  THEN
                                      1 /* Destino Correio */ 
                                 ELSE 2 /* Destino Balcao */ 
           cratext.nrseqint    = aux_nrsequen
           cratext.nrdordem    = 1
           cratext.tpdocmto    = 3
           cratext.dtemissa    = glb_dtmvtopr
           cratext.dsintern[1] = STRING(cratext.nmprimtl, "x(43)") +
                                 STRING(cratext.nrdconta, "zzzz,zzz,9")
           cratext.dsintern[2] = aux_dsidenti[aux_incartao]
           cratext.dsintern[3] = "Prezado Sr(a): " + cratext.nmprimtl
           cratext.dsintern[4] = aux_dslinha1[aux_incartao]
           cratext.dsintern[5] = aux_dslinha2[aux_incartao]
           cratext.dsintern[6] = aux_dslinha3[aux_incartao]
           cratext.dsintern[7] = aux_dslinha4[aux_incartao]
           cratext.dsintern[8] = "#".

    IF   crapdes.indespac = 1   THEN    /*** CORREIO ***/
         DO:
            FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                               crapenc.nrdconta = crapass.nrdconta  AND
                               crapenc.idseqttl = 1                 AND
                               crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
            
            FIND crapcdd WHERE crapcdd.nrcepini <= crapenc.nrcepend  AND
                               crapcdd.nrcepfim >= crapenc.nrcepend 
                               NO-LOCK NO-ERROR.

            ASSIGN cratext.dsender1 = TRIM(crapenc.dsendere) + ", " + 
                                      TRIM(STRING(crapenc.nrendere, "zzz,zz9"))
                   cratext.dsender2 = TRIM(STRING(crapenc.nmbairro,"x(15)")) +
                                      "   " +
                                      TRIM(STRING(crapenc.nmcidade,"x(15)")) +
                                      " - " +
                                      TRIM(crapenc.cdufende)        
                   cratext.nrcepend = crapenc.nrcepend
                   cratext.nomedcdd = crapcdd.nomedcdd WHEN AVAIL crapcdd
                   
                   cratext.nrcepcdd    = (STRING(crapcdd.nrcepini,"99,999,999") + " - " + STRING(crapcdd.nrcepfim,"99,999,999")) WHEN AVAIL crapcdd
                   cratext.dscentra    = crapcdd.dscentra WHEN AVAIL crapcdd
                   
                   cratext.complend = STRING(crapenc.complend,"x(35)").
         END.
    ELSE         /*** SECAO ***/
         ASSIGN cratext.nmempres = crapemp.nmresemp
                cratext.nmsecext = crapdes.nmsecext
                cratext.nmagenci = aux_nmagenci
                cratext.complend = " ".
                
    DO TRANSACTION:
       FIND crabcrm WHERE crabcrm.cdcooper = glb_cdcooper       AND
                          crabcrm.nrcartao = crapcrm.nrcartao   
                          EXCLUSIVE-LOCK NO-ERROR.
                           
       IF   crabcrm.cdsinfmg <> crapcop.cdsinfmg   THEN 
            ASSIGN crabcrm.cdsinfmg = crapcop.cdsinfmg.
    END.

END.        /* Fim do For each crapcrm */

/* Gera arquivo de dados */
{ includes/gera_dados_inform.i } 

UNIX SILENT VALUE("rm " + aux_nmscript + " 2> /dev/null").

IF   aux_flgfxser   THEN
     DO:    

         UNIX SILENT VALUE("mv " + TRIM(aux_nmarqdat) + " salvar/" +
                              SUBSTRING(TRIM(aux_nmarqdat), 5, 
                              LENGTH(TRIM(aux_nmarqdat)))).

         ASSIGN  aux_nmarqdat = "salvar/" +
                              SUBSTRING(TRIM(aux_nmarqdat), 5,
                              LENGTH(TRIM(aux_nmarqdat)))
                 
                 aux_nmdatspt = aux_nmarqdat.
               
         
         /* COOPERATIVAS QUE TRABALHAM COM A ENGECOPY */
         IF   CAN-DO("1,2,4",STRING(glb_cdcooper))  THEN
              DO:
                  ASSIGN aux_nmarqeml = SUBSTR(aux_nmdatspt,
                                               R-INDEX(aux_nmdatspt,"/") + 1,
                                               LENGTH(aux_nmdatspt)).
                                               
                  RUN sistema/generico/procedures/b1wgen0011.p 
                      PERSISTENT SET b1wgen0011.

                  IF   NOT VALID-HANDLE (b1wgen0011)  THEN
                       DO:
                           UNIX SILENT VALUE("echo "
                                      + STRING(TIME,"HH:MM:SS") + " - "
                                      + glb_cdprogra + "' --> '" 
                                      + "Handle invalido para h-b1wgen0011."
                                      + " >> log/proc_batch.log").
                                      
                           RUN fontes/fimprg.p.           
                           QUIT.          
                       END.
                  
                  RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                                      INPUT aux_nmdatspt,
                                                      INPUT aux_nmarqeml).
            
                  ASSIGN aux_nmarqeml = SUBSTR(TRIM(aux_nmarqeml),1,
                                               R-INDEX(aux_nmarqeml,".") - 1).
            
                  UNIX SILENT VALUE("zipcecred.pl -silent -add converte/" + 
                                    aux_nmarqeml + ".zip" +
                                    " converte/" + aux_nmarqeml + ".dat").
                                      
                  ASSIGN aux_conteudo = "Em anexo o arquivo(" +
                                        aux_nmarqeml + ".zip) contendo as " +
                                        "cartas da " + crapcop.nmrescop +
                                        ".".
                               
                  RUN enviar_email_completo IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT "crps321",
                                   INPUT "cpd@cecred.coop.br",
                                   INPUT "vendas@blucopy.com.br," +
                                         "variaveis@blucopy.com.br",
                                   INPUT "Cartas " + crapcop.nmrescop ,
                                   INPUT "",
                                   INPUT aux_nmarqeml + ".zip",
                                   INPUT aux_conteudo,
                                   INPUT TRUE). 

                  DELETE PROCEDURE b1wgen0011.            
                    
              END.
         ELSE
              DO:                     
                  { includes/envia_dados_postmix.i }
              END. 

     END.

RUN fontes/fimprg.p.

/* .......................................................................... */
