/* ............................................................................

   Programa: fontes/contas_conjuge.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : 27/09/2006                     Ultima Atualizacao: 24/08/2015

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes ao Conjuge.

   Alteracoes: 29/11/2006 - Nao obrigar a digitacao do CNPJ (Ze).
   
               07/12/2006 - Nao obrigar a digitacao do CPF (Ze).
               
               22/12/2006 - Nao obrigar tipo de documento, numero,
                            orgao emissor, uf e data (Evandro).
                            
               31/01/2007 - Acerto na atualizacao dos campos da tabela 
                            crapcje (Diego).
                            
               01/02/2007 - Incluida Unidade Federativa "PB" (Diego).
               
               09/03/2007 - Tratamento caso nao encontrar o registro do
                            conjuge (Evandro).
               
               20/12/2007 - Nao permite alterar conjuge quando este for
                            titular na conta (Elton).             
                            
               10/01/2008 - Retirado tratamento caso nao encontre o registro
                            do conjuge (Diego).
                            
               20/03/2008 - Alterada descricao do tipo de contrato de trabalho
                            para "2-TEMP/TERCEIRO" (Evandro).
                            
               10/07/2009 - Caso nao encontrar registro de conjuge mostra
                            mensagem e volta para a CONTAS(Guilherme).

               21/08/2009 - Corrigir para puxar campo escolaridade (Gabriel).
               
               30/10/2009 - Ajustado erro na atribuicao das variaveis de log,
                            nao estava alimentando as variaveis do Titular da
                            Conta pois o registro da crapttl nao estava dispo-
                            nivel (Fernando).
                            
               10/12/2009 - Acerto para na consulta dos dados do conjuge, se o
                            mesmo possuir conta, mostrar os dados (Guilherme).
                            
               03/03/2010 - Adaptacao p/ funcionamento c/ BO (Jose Luis, DB1).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
               24/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
.............................................................................*/

{ sistema/generico/includes/b1wgen0057tt.i }  
{ sistema/generico/includes/var_internet.i}
{ includes/var_online.i }
{ includes/var_contas.i }   
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF NEW SHARED VAR shr_grescola      LIKE crapcje.grescola          NO-UNDO.
DEF NEW SHARED VAR shr_dsescola      AS CHAR  FORMAT "x(15)"        NO-UNDO.
DEF NEW SHARED VAR shr_formacao_pesq AS CHAR  FORMAT "x(15)"        NO-UNDO.
DEF NEW SHARED VAR shr_cdfrmttl      LIKE crapcje.cdfrmttl          NO-UNDO.
DEF NEW SHARED VAR shr_rsfrmttl      LIKE gncdfrm.rsfrmttl          NO-UNDO.

DEF NEW SHARED VAR shr_cdnatocp      LIKE crapcje.cdnatopc          NO-UNDO.
DEF NEW SHARED VAR shr_rsnatocp      LIKE gncdnto.rsnatocp          NO-UNDO.
DEF NEW SHARED VAR shr_ocupacao_pesq AS CHAR FORMAT "x(15)"         NO-UNDO.
DEF NEW SHARED VAR shr_cdocpttl      LIKE crapcje.cdnatopc          NO-UNDO.
DEF NEW SHARED VAR shr_rsdocupa      LIKE gncdnto.rsnatocp          NO-UNDO.
DEF NEW SHARED VAR shr_cdnvlcgo      LIKE gncdncg.cdnvlcgo          NO-UNDO.
DEF NEW SHARED VAR shr_rsnvlcgo      LIKE gncdncg.rsnvlcgo          NO-UNDO.  
  
DEF VAR tel_nmconjug                 LIKE crapcje.nmconjug          NO-UNDO.
DEF VAR tel_nrcpfcjg                 LIKE crapcje.nrcpfcjg          NO-UNDO. 
DEF VAR tel_nrctacje                 LIKE crapcje.nrctacje          NO-UNDO.
DEF VAR tel_dtnasccj                 LIKE crapcje.dtnasccj          NO-UNDO. 
DEF VAR tel_tpdoccje                 LIKE crapcje.tpdoccje          NO-UNDO.
DEF VAR tel_nrdoccje                 LIKE crapcje.nrdoccje          NO-UNDO.
DEF VAR tel_cdoedcje                 LIKE crapcje.cdoedcje          NO-UNDO.
DEF VAR tel_cdufdcje                 LIKE crapcje.cdufdcje          NO-UNDO.
DEF VAR tel_dtemdcje                 LIKE crapcje.dtemdcje          NO-UNDO.
                                                               
DEF VAR tel_gresccje                 LIKE crapcje.grescola INIT 0   NO-UNDO.
DEF VAR tel_dsescola                 AS CHAR FORMAT "x(15)"         NO-UNDO.
DEF VAR tel_cdfrmttl                 LIKE crapcje.cdfrmttl          NO-UNDO.
DEF VAR tel_rsfrmttl                 AS CHAR FORMAT "x(15)"         NO-UNDO.
DEF VAR tel_cdnatopc                 LIKE crapcje.cdnatopc          NO-UNDO.
DEF VAR tel_rsnatocp                 AS CHAR FORMAT "x(15)"         NO-UNDO.
DEF VAR tel_cdocpttl                 LIKE crapcje.cdocpcje          NO-UNDO.   
DEF VAR tel_rsdocupa                 AS CHAR FORMAT "x(15)"         NO-UNDO.   

DEF VAR tel_tpcttrab                 LIKE crapcje.tpcttrab          NO-UNDO.
DEF VAR tel_dsctrtab                 AS CHAR FORMAT "x(15)"         NO-UNDO. 
                                                                 
DEF VAR tel_nmextemp                 LIKE crapcje.nmextemp          NO-UNDO.
DEF VAR tel_nrcpfemp                 AS CHAR FORMAT "x(18)"         NO-UNDO.   
DEF VAR tel_dsproftl                 LIKE crapcje.dsproftl          NO-UNDO.
DEF VAR tel_cdnvlcgo                 LIKE crapcje.cdnvlcgo          NO-UNDO.   
DEF VAR tel_rsnvlcgo                 AS CHAR FORMAT "x(10)"         NO-UNDO.

DEF VAR tel_nrfonemp                 LIKE crapcje.nrfonemp          NO-UNDO.
DEF VAR tel_nrramemp                 LIKE crapcje.nrramemp          NO-UNDO.
DEF VAR tel_cdturnos                 LIKE crapcje.cdturnos          NO-UNDO.
DEF VAR tel_dsturnos                 AS CHAR FORMAT "x(11)"         NO-UNDO.
DEF VAR tel_dtadmemp                 LIKE crapcje.dtadmemp          NO-UNDO.
DEF VAR tel_vlsalari                 LIKE crapcje.vlsalari          NO-UNDO.
                                                                
DEF VAR reg_dsdopcao    AS CHAR INIT "Alterar" FORMAT "x(07)"       NO-UNDO.
DEF VAR aux_flgsuces                 AS LOGICAL                     NO-UNDO.

DEF VAR h-b1wgen0057                 AS HANDLE                      NO-UNDO.
DEF VAR h-b1wgen0060                 AS HANDLE                      NO-UNDO.
DEF VAR aux_cdgraupr                 LIKE crapttl.cdgraupr          NO-UNDO.
DEF VAR aux_msgalert                 AS CHAR                        NO-UNDO.
DEF VAR aux_dscritic                 AS CHAR                        NO-UNDO.
DEF VAR aux_nrdrowid                 AS ROWID                       NO-UNDO.
DEF VAR aux_msgconta                 AS CHAR                        NO-UNDO.
DEF VAR aux_msgrvcad                 AS CHAR                        NO-UNDO.

DEF BUFFER crabtab FOR craptab.  

FORM shr_formacao_pesq LABEL "Formacao"
     WITH ROW 9 COLUMN 15 OVERLAY SIDE-LABELS TITLE "PESQUISA FORMACAO"
          FRAME f_pesq_formacao.

FORM shr_ocupacao_pesq LABEL "Ocupacao"
     WITH ROW 9 CENTERED OVERLAY SIDE-LABELS TITLE "PESQUISA OCUPACAO"
          FRAME f_pesq_ocupacao.
 
FORM  
      tel_nrctacje LABEL "Conta/dv" 
        HELP "Informe conta do conjuge / F7 para listar / 0-nao cooperado"
      SPACE(7)
      tel_nrcpfcjg  LABEL "C.P.F."  
                    HELP "Informe o CPF do conjuge"
      SKIP
      tel_nmconjug  LABEL "Nome"   
                    HELP "Informe o nome do conjuge"
      SPACE(2)
      tel_dtnasccj  LABEL "Data Nascimento" 
                    HELP "Informe a data de nascimento do conjuge"
                    VALIDATE (INPUT tel_dtnasccj <> ?,
                              "Data de nascimento nao cadastrada.")
      SKIP
      tel_tpdoccje  LABEL "Documento"  AUTO-RETURN
                    HELP "Informe o tipo de documento do conjuge (CI,CH,CP,CT)"
                    VALIDATE(tel_tpdoccje = "CI" OR
                             tel_tpdoccje = "CH" OR
                             tel_tpdoccje = "CP" OR
                             tel_tpdoccje = "CT" OR
                             tel_tpdoccje = "",
                             "021 - Tipo de documento errado.")
                    
      tel_nrdoccje  NO-LABEL AUTO-RETURN
                    HELP "Informe o numero do documento do conjuge"
                              
      tel_cdoedcje  LABEL "Org.Emi." AUTO-RETURN
                    HELP "Orgao que emitiu o documento"
                    
      " U.F.:"              
      tel_cdufdcje  NO-LABEL AUTO-RETURN
                    HELP "Informe a Sigla do Estado que emitiu o documento"
                    VALIDATE(CAN-DO("RS,SC,PR,SP,RJ,ES,MG,MS,MT,GO,DF," +
                                    "BA,PE,PA,PI,MA,RO,RR,AC,AM,TO,AM," +
                                    "CE,SE,AL,PB,AP",tel_cdufdcje) OR
                             tel_cdufdcje = "",
                                    "033 - Unidade da federacao errada.")
                    
      " Data Emi.:" 
      tel_dtemdcje  NO-LABEL 
                    HELP "Informe a Data de emissao do documento"
      SKIP(1)
      tel_gresccje  LABEL "Escolaridade"   
             HELP "Informe o grau de escolaridade ou pressione F7 para listar"
                    VALIDATE (CAN-FIND(gngresc WHERE gngresc.grescola = 
                          tel_gresccje),"Grau de escolaridade nao cadastrado.")
              
      tel_dsescola  NO-LABEL 
      SPACE(4)
      tel_cdfrmttl  LABEL "Curso Superior" 
                    HELP "Informe o curso superior ou pressione F7 para listar"
                    VALIDATE (CAN-FIND(gncdfrm WHERE gncdfrm.cdfrmttl = 
                                       tel_cdfrmttl), 
                                       "Curso superior nao cadastrado.")
                    
      tel_rsfrmttl  NO-LABEL
      tel_cdnatopc  LABEL "Nat.Ocupacao"
            HELP "Informe a natureza de ocupacao ou pressione F7 para listar" 
                    VALIDATE (CAN-FIND(gncdnto WHERE gncdnto.cdnatocp = 
                                       tel_cdnatopc), 
                                       "Natureza de ocupacao nao cadastrado.")
                   
      tel_rsnatocp  NO-LABEL
      SPACE(10)
      tel_cdocpttl  VALIDATE (CAN-FIND(gncdocp WHERE gncdocp.cdocupa = 
                                      tel_cdocpttl),"Ocupacao nao cadastrada.")
                    HELP "Informe a ocupacao ou pressione F7 para listar"
      tel_rsdocupa  NO-LABEL 
      SKIP(1)
      tel_tpcttrab  
              HELP "Informe (1)PERMANENTE, (2)TEMP/TERCEIRO, (3)SEM VINCULO"
                    VALIDATE (CAN-DO("1,2,3",tel_tpcttrab), 
                              "Tipo de contrato de trabalho nao cadastrado.") 
                    LABEL "Tp.Ctr.Trab."  
      tel_dsctrtab  NO-LABEL
      SPACE(3)   
      tel_nmextemp  HELP "Informe a empresa onde o conjuge trabalha"
                    VALIDATE (INPUT tel_tpcttrab = 3 OR
                             (INPUT tel_tpcttrab <> 3 AND
                              INPUT tel_nmextemp <> ""),
                              "Empresa nao cadastrada.")
      tel_nrcpfemp  LABEL "    C.N.P.J."  
                    FORMAT "xx.xxx.xxx/xxxx-xx"
                    HELP "Informe o C.N.P.J. da empresa"
      SPACE(4)
      tel_dsproftl  LABEL "Cargo" 
                    HELP "Informe a cargo do conjuge na empresa"
                    VALIDATE (INPUT tel_tpcttrab = 3 OR
                             (INPUT tel_tpcttrab <> 3 AND
                              INPUT tel_dsproftl <> ""),
                              "Cargo nao cadastrado.")      SKIP
      tel_cdnvlcgo  LABEL " Nivel Cargo"
                    HELP "Informe o nivel do cargo ou pressione F7 para listar"
                    VALIDATE (INPUT tel_tpcttrab = 3 OR
                             (INPUT tel_tpcttrab <> 3 AND
                              CAN-FIND(gncdncg WHERE 
                                               gncdncg.cdnvlcgo = 
                                                       tel_cdnvlcgo         AND
                                                       gncdncg.cdnvlcgo <> 0)),
                              "Nivel do cargo nao cadastrado.")
                    
      tel_rsnvlcgo  NO-LABEL

      tel_nrfonemp  LABEL " Tel.Comercial" 
                    HELP  "Informe telefone comercial"
      tel_nrramemp  LABEL "   Ramal" 
                    HELP  "Informe ramal na empresa"
      SKIP
      SPACE(7)
      tel_cdturnos  AUTO-RETURN
                HELP "Informe o turno que trabalha ou pressione F7 para listar"
                    VALIDATE((INPUT tel_tpcttrab <> 3 AND
                              tel_cdturnos >= 1 AND 
                              tel_cdturnos <= 4) OR
                              INPUT tel_tpcttrab = 3,
                              "043 - Turno errado.")
      tel_dsturnos  NO-LABEL
      SPACE(5)
      tel_dtadmemp  HELP "Informe data de admissao na empresa"
      SPACE(3)
      tel_vlsalari  LABEL "Rendimento" FORMAT "zzz,zz9.99"
                    HELP  "Informe o valor do rendimento do conjuge"
      SKIP
      reg_dsdopcao AT 36 NO-LABEL
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
      WITH ROW 8 OVERLAY SIDE-LABELS TITLE " CONJUGE " CENTERED 
      FRAME f_conjuge.

/* Contrato de Trabalho */
ON RETURN OF tel_tpcttrab DO:
   IF   INPUT tel_tpcttrab = 3   THEN
        APPLY "GO".
   ELSE
   IF   CAN-DO("1,2", STRING(INPUT tel_tpcttrab)) THEN 
        APPLY "LEAVE" TO tel_tpcttrab.
END.

ON LEAVE OF tel_tpcttrab DO:

   ASSIGN INPUT tel_tpcttrab.

   DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                    INPUT tel_tpcttrab,
                    OUTPUT tel_dsctrtab,
                    OUTPUT aux_dscritic).

   DISPLAY tel_dsctrtab WITH FRAME f_conjuge.
   
   /* Controle dos campos */
   IF   INPUT tel_tpcttrab = 3   THEN
        DO:
            ASSIGN tel_nmextemp = ""
                   tel_nrcpfemp = ""
                   tel_dsproftl = ""
                   tel_cdnvlcgo = 0
                   tel_rsnvlcgo = ""
                   tel_nrfonemp = ""
                   tel_nrramemp = 0
                   tel_cdturnos = 0
                   tel_dsturnos = ""
                   tel_dtadmemp = ?
                   tel_vlsalari = 0.
                   
            DISPLAY tel_nmextemp    tel_nrcpfemp    tel_dsproftl
                    tel_cdnvlcgo    tel_rsnvlcgo    tel_nrfonemp
                    tel_nrramemp    tel_cdturnos    tel_dsturnos
                    tel_dtadmemp    tel_vlsalari
                    WITH FRAME f_conjuge.
                    
            DISABLE tel_nmextemp    tel_nrcpfemp    tel_dsproftl
                    tel_cdnvlcgo    tel_nrfonemp    tel_nrramemp
                    tel_cdturnos    tel_dtadmemp    tel_vlsalari
                    WITH FRAME f_conjuge.
                    
            NEXT-PROMPT tel_tpcttrab WITH FRAME f_conjuge.  
        END.
   ELSE
        DO:
            ENABLE tel_nmextemp    tel_nrcpfemp    tel_dsproftl
                   tel_cdnvlcgo    tel_nrfonemp    tel_nrramemp
                   tel_cdturnos    tel_dtadmemp    tel_vlsalari
                   WITH FRAME f_conjuge.

            NEXT-PROMPT tel_tpcttrab WITH FRAME f_conjuge.
        END.
END.
  

/* Nao deixa passar pelo CPF sem ser um numero valido */
ON  LEAVE OF tel_nrcpfcjg IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_nrcpfcjg.

    IF  NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
                             INPUT STRING(tel_nrcpfcjg),
                             OUTPUT aux_dscritic) AND 
        tel_nrcpfcjg <> 0 THEN
        DO:
            MESSAGE aux_dscritic.
            NEXT-PROMPT tel_nrcpfcjg WITH FRAME f_conjuge.
            RETURN NO-APPLY.
        END.

END.

/*Nivel do Cargo*/
ON  LEAVE OF tel_cdnvlcgo IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_cdnvlcgo.

    DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                     INPUT tel_cdnvlcgo,
                     OUTPUT tel_rsnvlcgo,
                     OUTPUT aux_dscritic).
    
    DISPLAY tel_rsnvlcgo WITH FRAME f_conjuge.

END.

/* Nao deixa passar pelo CNPJ sem ser um numero valido */
ON  LEAVE OF tel_nrcpfemp IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_nrcpfemp.

    IF  NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
                             INPUT STRING(tel_nrcpfemp),
                             OUTPUT aux_dscritic) AND
        REPLACE(REPLACE(REPLACE(tel_nrcpfemp,".",""),"/",""),"-","") <> "" 
        THEN
        DO:
            MESSAGE aux_dscritic .
            NEXT-PROMPT tel_nrcpfemp WITH FRAME f_conjuge.
            RETURN NO-APPLY.
        END.
    
    HIDE MESSAGE NO-PAUSE.

END.

/*Descricao Grau de Escolaridade*/
ON  LEAVE OF tel_gresccje IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_gresccje.

    DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060,
                     INPUT tel_gresccje,
                     OUTPUT tel_dsescola,
                     OUTPUT aux_dscritic).
                  
    DISPLAY tel_dsescola WITH FRAME f_conjuge.                  
END.

/* Formacao */
ON  LEAVE OF tel_cdfrmttl IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_cdfrmttl.

    DYNAMIC-FUNCTION("BuscaFormacao" IN h-b1wgen0060,
                     INPUT tel_cdfrmttl,
                     OUTPUT tel_rsfrmttl,
                     OUTPUT aux_dscritic).
                   
    DISPLAY tel_rsfrmttl WITH FRAME f_conjuge.
END.

/*Natureza de ocupacao*/
ON  LEAVE OF tel_cdnatopc IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_cdnatopc.

    DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                     INPUT tel_cdnatopc,
                     OUTPUT tel_rsnatocp,
                     OUTPUT aux_dscritic).
    
    DISPLAY tel_rsnatocp WITH FRAME f_conjuge.
    
    IF   INPUT tel_cdnatopc = 11   OR    /* SEM REMUNERACAO */
         INPUT tel_cdnatopc = 12   THEN  /* SEM VINCULO */
         DO:
             tel_tpcttrab = 3. /* Sem vinculo */
             
             DISPLAY tel_tpcttrab WITH FRAME f_conjuge.
             
             DISABLE tel_tpcttrab WITH FRAME f_conjuge.
             
             APPLY "LEAVE" TO tel_tpcttrab IN FRAME f_conjuge.
         END.
    ELSE
         DO:
             ENABLE tel_tpcttrab   tel_nmextemp   tel_nrcpfemp
                    tel_dsproftl   tel_cdnvlcgo   tel_nrfonemp
                    tel_nrramemp   tel_cdturnos   tel_dtadmemp
                    tel_vlsalari
                    WITH FRAME f_conjuge.
             
             NEXT-PROMPT tel_tpcttrab WITH FRAME f_conjuge.
         END.
    
END.

/* Ocupacao */
ON  LEAVE OF tel_cdocpttl IN FRAME f_conjuge DO:

    ASSIGN INPUT tel_cdocpttl.

    DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                     INPUT tel_cdocpttl,
                     OUTPUT tel_rsdocupa,
                     OUTPUT aux_dscritic).
    
    DISPLAY tel_rsdocupa WITH FRAME f_conjuge.

END. 


/* Turnos */
ON LEAVE OF tel_cdturnos DO:

   ASSIGN INPUT tel_cdturnos.
   
   DYNAMIC-FUNCTION("BuscaTurnos" IN h-b1wgen0060,
                    INPUT glb_cdcooper,
                    INPUT tel_cdturnos,
                    OUTPUT tel_dsturnos,
                    OUTPUT aux_dscritic).
   
   DISPLAY tel_dsturnos WITH FRAME f_conjuge.

END.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
        RUN sistema/generico/procedures/b1wgen0060.p PERSISTENT 
            SET h-b1wgen0060.

    IF  NOT VALID-HANDLE(h-b1wgen0057) THEN
        RUN sistema/generico/procedures/b1wgen0057.p PERSISTENT 
            SET h-b1wgen0057.
   
    ASSIGN 
        glb_cddopcao = "C"
        aux_nrdrowid = ?
        tel_nrctacje = 0
        tel_nrcpfcjg = 0.

    RUN Busca_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        LEAVE.

    CHOOSE FIELD reg_dsdopcao WITH FRAME f_conjuge.

    IF   FRAME-FIELD = "reg_dsdopcao"   THEN
         Edita: DO  TRANSACTION ON ENDKEY UNDO, NEXT:    
             
             ASSIGN glb_nmrotina = "CONJUGE"
                    glb_cddopcao = "A".
             
             /*Alteração: Mostra critica se usuario titular em outra conta 
             (Gabriel/DB1)*/
             IF  aux_msgconta <> "" THEN
                 DO:
                    MESSAGE aux_msgconta.
                    NEXT.
                 END.
             
             { includes/acesso.i }

             ASSIGN
                 tel_nrctacje = 0
                 tel_nrcpfcjg = 0.
             
             RUN Busca_Dados.

             IF  RETURN-VALUE <> "OK" THEN
                 NEXT.
             
             /*** Verifica se permite modificar o conjuge do titular ***/
             IF  aux_msgalert <> "" THEN
                 DO:
                    MESSAGE aux_msgalert.
                    NEXT.
                 END.
             
             UPDATE tel_nrctacje WITH FRAME f_conjuge
             
             EDITING:

               DO WHILE TRUE:

                  READKEY PAUSE 1.
               
                  IF   LASTKEY = KEYCODE("F7") THEN
                       DO:
                           RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                         OUTPUT tel_nrctacje).

                           IF   tel_nrctacje > 0   THEN
                                DO:
                                    DISPLAY tel_nrctacje 
                                            WITH FRAME f_conjuge.
                                            
                                    APPLY "GO".
                                END.
                       END.
                  ELSE
                       APPLY LASTKEY.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */
               IF  GO-PENDING THEN
                   DO:
                      ASSIGN INPUT tel_nrctacje.

                      IF  tel_nrctacje <> 0 THEN 
                          DO:
                             ASSIGN 
                                 tel_nrcpfcjg = 0
                                 aux_nrdrowid = ?.

                             RUN Busca_Dados .

                             IF  RETURN-VALUE <> "OK" THEN
                                 NEXT.

                          END. /**FIM IF tel_nrctacje */
                   END.
              
             END.  /*  Fim do EDITING  */

             UPDATE tel_nrcpfcjg WHEN tel_nrctacje = 0
                 WITH FRAME f_conjuge
             EDITING:
                READKEY.

                APPLY LASTKEY.
                IF  GO-PENDING THEN
                    DO:
                       ASSIGN INPUT tel_nrcpfcjg.
                       IF  tel_nrcpfcjg <> 0 AND tel_nrctacje = 0 THEN
                           DO:
                              ASSIGN aux_nrdrowid = ?.

                              RUN Busca_Dados.

                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.

                           END.
                    END.
             END.

             HIDE MESSAGE NO-PAUSE.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE   tel_nmconjug   WHEN tel_nrctacje = 0   
                         tel_dtnasccj   WHEN tel_nrctacje = 0
                         tel_tpdoccje   WHEN tel_nrctacje = 0
                         tel_nrdoccje   WHEN tel_nrctacje = 0  
                         tel_cdoedcje   WHEN tel_nrctacje = 0
                         tel_cdufdcje   WHEN tel_nrctacje = 0
                         tel_dtemdcje   WHEN tel_nrctacje = 0
                         tel_gresccje   WHEN tel_nrctacje = 0
                         tel_cdfrmttl   WHEN tel_nrctacje = 0   
                         tel_cdnatopc   WHEN tel_nrctacje = 0  
                         tel_cdocpttl   WHEN tel_nrctacje = 0
                         tel_tpcttrab   WHEN tel_nrctacje = 0
                         tel_nmextemp   WHEN tel_nrctacje = 0
                         tel_nrcpfemp   WHEN tel_nrctacje = 0
                         tel_dsproftl   WHEN tel_nrctacje = 0   
                         tel_cdnvlcgo   WHEN tel_nrctacje = 0  
                         tel_nrfonemp   WHEN tel_nrctacje = 0
                         tel_nrramemp   WHEN tel_nrctacje = 0   
                         tel_cdturnos   WHEN tel_nrctacje = 0  
                         tel_dtadmemp   WHEN tel_nrctacje = 0
                         tel_vlsalari   WHEN tel_nrctacje = 0   
                         WITH FRAME f_conjuge
               
                EDITING:
                   READKEY.
                   HIDE MESSAGE NO-PAUSE.
                    
                   IF LASTKEY = KEYCODE("F7") THEN
                      DO:
                         IF  FRAME-FIELD = "tel_gresccje" THEN
                             DO:
                                 shr_grescola = tel_gresccje.
                                 RUN fontes/zoom_grau_instrucao.p.
                                 IF shr_grescola <> 0 THEN
                                    DO:
                                        ASSIGN  tel_gresccje = shr_grescola
                                                tel_dsescola = shr_dsescola.
                                        DISPLAY tel_gresccje tel_dsescola
                                                WITH FRAME f_conjuge.
                                        NEXT-PROMPT tel_gresccje
                                                WITH FRAME f_conjuge.  
                                    END.
                             END.  
                         ELSE
                         IF FRAME-FIELD = "tel_cdfrmttl" THEN
                            DO:
                            FORMACAO_1:
                              DO WHILE TRUE ON ENDKEY UNDO FORMACAO_1, LEAVE:
                                 ASSIGN shr_formacao_pesq = "".
                                 UPDATE shr_formacao_pesq
                                        WITH FRAME f_pesq_formacao.
                               
                                 HIDE FRAME f_pesq_formacao.
                                 ASSIGN shr_cdfrmttl = tel_cdfrmttl.
                                 RUN fontes/zoom_curso_superior.p.
                                 IF shr_cdfrmttl <> 0 THEN
                                    DO:
                                       ASSIGN  tel_cdfrmttl =  shr_cdfrmttl
                                               tel_rsfrmttl =  shr_rsfrmttl.
                                       DISPLAY tel_cdfrmttl    tel_rsfrmttl
                                               WITH FRAME f_conjuge.
                                       NEXT-PROMPT tel_cdfrmttl
                                                   WITH FRAME f_conjuge.
                                    END.
                                 LEAVE.
                              END.    /**FORMACAO 1**/
                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_cdnatopc" THEN
                            DO:
                               ASSIGN shr_cdnatocp = tel_cdnatopc.
                               RUN fontes/zoom_natureza_ocupacao.p.
                               IF shr_cdnatocp <> 0 THEN
                                  DO:
                                     ASSIGN  tel_cdnatopc = shr_cdnatocp
                                             tel_rsnatocp = shr_rsnatocp.
                                     DISPLAY tel_cdnatopc   tel_rsnatocp
                                             WITH FRAME f_conjuge.
                                     NEXT-PROMPT tel_cdnatopc
                                                 WITH FRAME f_conjuge.  
                                  END.
                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_cdocpttl" THEN
                            DO:
                              OCUPACAO_1:
                              DO WHILE TRUE ON ENDKEY UNDO OCUPACAO_1,LEAVE: 
                                 ASSIGN shr_ocupacao_pesq  = "". 
                                 UPDATE shr_ocupacao_pesq
                                        WITH FRAME f_pesq_ocupacao.
                                 HIDE FRAME f_pesq_ocupacao.
                                 ASSIGN shr_cdocpttl = tel_cdocpttl.

                                 RUN fontes/zoom_ocupacao.p.
                                 IF shr_cdocpttl <> 0 THEN
                                    DO:
                                       ASSIGN tel_cdocpttl = shr_cdocpttl
                                              tel_rsdocupa  = shr_rsdocupa.
                                       DISPLAY tel_cdocpttl tel_rsdocupa
                                               WITH FRAME   f_conjuge.
                                       NEXT-PROMPT tel_cdocpttl
                                                   WITH FRAME f_conjuge.
                                    END.
                                 LEAVE.   
                              END.
                            END.
                         ELSE
                         IF FRAME-FIELD = "tel_cdnvlcgo" THEN
                            DO:
                               ASSIGN shr_cdnvlcgo = tel_cdnvlcgo.
                               RUN fontes/zoom_nivel_cargo.p.
                               IF shr_cdnvlcgo <> 0 THEN
                                  DO:
                                     ASSIGN  tel_cdnvlcgo = shr_cdnvlcgo
                                             tel_rsnvlcgo = shr_rsnvlcgo.
                                     DISPLAY tel_cdnvlcgo tel_rsnvlcgo
                                             WITH FRAME   f_conjuge.     
                                     NEXT-PROMPT tel_cdnvlcgo
                                                 WITH FRAME f_conjuge. 
                                  END.
                            END. 

                         IF FRAME-FIELD = "tel_cdturnos" THEN
                            DO:
                                RUN fontes/zoom_turnos.p
                                    (INPUT glb_cdcooper,
                                     OUTPUT tel_cdturnos,
                                     OUTPUT tel_dsturnos).
                                                         
                                DISPLAY tel_cdturnos    tel_dsturnos
                                        WITH FRAME f_conjuge.
                                NEXT-PROMPT tel_cdturnos 
                                            WITH FRAME f_conjuge.
                            END.
                      
                      END.     /** fim F7 */
                   ELSE     
                        APPLY LASTKEY.
                   IF  GO-PENDING THEN
                       DO:
                           ASSIGN
                               INPUT tel_nmconjug
                               INPUT tel_dtnasccj
                               INPUT tel_tpdoccje
                               INPUT tel_nrdoccje
                               INPUT tel_cdoedcje
                               INPUT tel_cdufdcje
                               INPUT tel_dtemdcje
                               INPUT tel_gresccje
                               INPUT tel_cdfrmttl
                               INPUT tel_cdnatopc
                               INPUT tel_cdocpttl
                               INPUT tel_tpcttrab
                               INPUT tel_nmextemp
                               INPUT tel_nrcpfemp
                               INPUT tel_dsproftl
                               INPUT tel_cdnvlcgo
                               INPUT tel_nrfonemp
                               INPUT tel_nrramemp
                               INPUT tel_cdturnos
                               INPUT tel_dtadmemp
                               INPUT tel_vlsalari.

                           RUN Valida_Dados.
    
                           IF  RETURN-VALUE <> "OK" THEN
                               NEXT.
                       END.
                
                END.   /* fim EDITING */

                ASSIGN tel_nmconjug = CAPS(tel_nmconjug)
                       tel_tpdoccje = CAPS(tel_tpdoccje)
                       tel_cdoedcje = CAPS(tel_cdoedcje)
                       tel_nmextemp = CAPS(tel_nmextemp)
                       tel_dsproftl = CAPS(tel_dsproftl).

                LEAVE.       
             END.   /*  Fim do While True  */

             IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.

             DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

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
                      NEXT.
                  END.
              ELSE 
                  DO:
                      MESSAGE "Aguarde... Gravando os dados do Conjuge".
    
                      IF  VALID-HANDLE(h-b1wgen0057) THEN
                          DELETE OBJECT h-b1wgen0057.

                      RUN sistema/generico/procedures/b1wgen0057.p 
                          PERSISTENT SET h-b1wgen0057.

                      RUN Grava_Dados IN h-b1wgen0057
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT glb_nmdatela,
                           INPUT 1,
                           INPUT tel_nrdconta,
                           INPUT tel_idseqttl,
                           INPUT TRUE,
                           INPUT tel_nrctacje,  
                           INPUT tel_nrcpfcjg,  
                           INPUT tel_nmconjug,  
                           INPUT tel_dtnasccj,  
                           INPUT tel_tpdoccje,  
                           INPUT tel_nrdoccje,  
                           INPUT tel_cdoedcje,  
                           INPUT tel_cdufdcje,  
                           INPUT tel_dtemdcje,  
                           INPUT tel_gresccje,  
                           INPUT tel_cdfrmttl,  
                           INPUT tel_cdnatopc,  
                           INPUT tel_cdocpttl,  
                           INPUT tel_tpcttrab,  
                           INPUT tel_nmextemp,  
                           INPUT tel_nrcpfemp,  
                           INPUT tel_dsproftl,  
                           INPUT tel_cdnvlcgo,  
                           INPUT tel_nrfonemp,  
                           INPUT tel_nrramemp,  
                           INPUT tel_cdturnos,  
                           INPUT tel_dtadmemp,  
                           INPUT tel_vlsalari,
                           INPUT glb_dtmvtolt,
                           INPUT glb_cddopcao,
                          OUTPUT aux_tpatlcad,
                          OUTPUT aux_msgatcad,
                          OUTPUT aux_chavealt,
                          OUTPUT aux_msgrvcad,
                          OUTPUT TABLE tt-erro).
    
                      HIDE MESSAGE NO-PAUSE.
    
                      IF  RETURN-VALUE = "NOK" OR 
                          TEMP-TABLE tt-erro:HAS-RECORDS THEN
                          DO:
                             FIND FIRST tt-erro NO-ERROR.
    
                             IF  AVAILABLE tt-erro THEN
                                 DO:
                                    MESSAGE tt-erro.dscritic.
                                    UNDO, RETRY.
                                 END.
                          END.
    
                      /* verificar se é necessario registrar o crapalt */
                      RUN proc_altcad (INPUT "b1wgen0057.p").

                      DELETE OBJECT h-b1wgen0057.

                      IF aux_msgrvcad <> "" THEN
                         MESSAGE aux_msgrvcad.
                             
                      IF  RETURN-VALUE <> "OK" THEN
                          NEXT.
                  END.

         END. /* FIM TRANSACTION ALTERACAO*/
    
    /** Rotina para mesagem de sucesso na alteracao*/
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S"                  THEN
         NEXT.
    ELSE
         DO:
            aux_flgsuces = YES.
            LEAVE.
         END.
END.

IF  VALID-HANDLE(h-b1wgen0057) THEN
    DELETE OBJECT h-b1wgen0057.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        MESSAGE "Alteracao efetuada com sucesso!".
        PAUSE 2 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.  
        LEAVE.
     END.

HIDE FRAME f_conjuge NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

PROCEDURE Busca_Dados:

    ASSIGN aux_msgalert = "".

    RUN Busca_Dados IN h-b1wgen0057
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT glb_cddopcao,
         INPUT aux_nrdrowid,
         INPUT tel_nrctacje,
         INPUT tel_nrcpfcjg,
        OUTPUT aux_msgconta,
        OUTPUT TABLE tt-crapcje,
        OUTPUT TABLE tt-erro).

    IF  (RETURN-VALUE = "NOK" OR TEMP-TABLE tt-erro:HAS-RECORDS) THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro  THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                    END.

                    HIDE MESSAGE NO-PAUSE.

                    RETURN "NOK".
                END.
        END.

    RUN Atualiza_Tela.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Tela:

    FIND FIRST tt-crapcje NO-ERROR.
    IF  NOT AVAILABLE tt-crapcje THEN
        CREATE tt-crapcje.

    IF  tt-crapcje.nmconjug <> "" THEN
        ASSIGN
           tel_nrcpfcjg = tt-crapcje.nrcpfcjg 
           tel_nmconjug = tt-crapcje.nmconjug
           tel_dtnasccj = tt-crapcje.dtnasccj
           tel_tpdoccje = tt-crapcje.tpdoccje
           tel_nrdoccje = tt-crapcje.nrdoccje
           tel_cdoedcje = tt-crapcje.cdoedcje
           tel_cdufdcje = tt-crapcje.cdufdcje
           tel_dtemdcje = tt-crapcje.dtemdcje
           tel_gresccje = tt-crapcje.grescola
           tel_dsescola = tt-crapcje.dsescola
           tel_cdfrmttl = tt-crapcje.cdfrmttl
           tel_rsfrmttl = tt-crapcje.rsfrmttl
           tel_cdnatopc = tt-crapcje.cdnatopc
           tel_rsnatocp = tt-crapcje.rsnatocp
           tel_cdocpttl = tt-crapcje.cdocpcje
           tel_rsdocupa = tt-crapcje.rsdocupa
           tel_tpcttrab = tt-crapcje.tpcttrab
           tel_dsctrtab = tt-crapcje.dsctrtab
           tel_nmextemp = tt-crapcje.nmextemp
           tel_nrcpfemp = STRING(tt-crapcje.nrdocnpj,"99999999999999")
           tel_dsproftl = tt-crapcje.dsproftl
           tel_cdnvlcgo = tt-crapcje.cdnvlcgo
           tel_rsnvlcgo = tt-crapcje.rsnvlcgo
           tel_nrfonemp = tt-crapcje.nrfonemp
           tel_cdturnos = tt-crapcje.cdturnos
           tel_dsturnos = tt-crapcje.dsturnos
           tel_dtadmemp = tt-crapcje.dtadmemp
           tel_vlsalari = tt-crapcje.vlsalari
           tel_nrctacje = tt-crapcje.nrctacje
           tel_nrramemp = tt-crapcje.nrramemp
           aux_cdgraupr = tt-crapcje.cdgraupr
           aux_nrdrowid = tt-crapcje.nrdrowid.

    IF  tt-crapcje.nrdocnpj = 0 AND DEC(tel_nrcpfemp) = 0 THEN
        ASSIGN tel_nrcpfemp = "".

    DISPLAY tel_nrctacje      tel_nrcpfcjg      tel_nmconjug      
            tel_dtnasccj      tel_tpdoccje      tel_nrdoccje     
            tel_cdoedcje      tel_cdufdcje      tel_dtemdcje     
            tel_gresccje      tel_dsescola      tel_cdfrmttl     
            tel_rsfrmttl      tel_cdnatopc      tel_rsnatocp     
            tel_cdocpttl      tel_rsdocupa      tel_tpcttrab     
            tel_dsctrtab      tel_nmextemp      tel_nrcpfemp     
            tel_dsproftl      tel_cdnvlcgo      tel_rsnvlcgo     
            tel_nrfonemp      tel_dtadmemp      tel_vlsalari     
            tel_nrramemp      tel_cdturnos      tel_dsturnos
            reg_dsdopcao     
            WITH FRAME f_conjuge.  

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0057
        (INPUT glb_cdcooper,
         INPUT 0,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT STRING(tel_nrcpfcjg),
         INPUT tel_nmconjug,
         INPUT tel_dtnasccj,
         INPUT tel_tpdoccje,
         INPUT tel_cdufdcje,
         INPUT tel_gresccje,
         INPUT tel_cdfrmttl,
         INPUT tel_cdnatopc,
         INPUT tel_cdocpttl,
         INPUT tel_tpcttrab,
         INPUT tel_nmextemp,
         INPUT tel_nrcpfemp,
         INPUT tel_dsproftl,
         INPUT tel_cdnvlcgo,
         INPUT tel_cdturnos,
         INPUT tel_dtadmemp,
         INPUT tel_nrctacje,
        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.
  
/*...........................................................................*/

