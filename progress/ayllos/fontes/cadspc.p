/******************************************************************************
   Programa: Fontes/cadspc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Dezembro/2005                   Ultima Atualizacao: 06/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir cadastros no SPC.

   ALTERACAO : 08/03/2006 - Implementada consulta por numero de conta (Diego).
   
               10/05/2006 - Melhorar critica 867 (Magui).

               23/05/2006 - Atualizar campo crapass.dtdsdspc quando
                            inclusao (Magui).
                            
               29/05/2006 - Implementada opcao "M", para impressao de 
                            relatorio (Diego).

               31/05/2006 - Atualizar campo crapass.inadimpl (Magui).
               
               08/06/2006 - Acrescentado campo referente PAC nas opcoes
                            "A", "B", "C", e "I" (Diego).

               04/07/2006 - Find last atualizando sem NO-ERROR (Magui).

               19/07/2006 - Modificado a opcao alterar para atualizar tambem o
                            Nro. de Contrato do SPC (Elton).

               25/08/2006 - Incluido zoom de registros do devedor informado
                            nas opcoes "A" e "B" (David).

               09/10/2006 - Incluir contrato na leitura do crapavt (Magui).
               
               17/01/2007 - Alterado campos com formato DATE de "99/99/99" para
                            "99/99/9999" (Elton).

               13/03/2007 - Atualizar campo crapass.dtdsdspc quando for baixa
                            (Evandro).

               13/04/2007 - Acertar atualizacao do campo crapass.dtdsdspc
                            quando os fiadores forem para o SPC (Magui)
               
               16/12/2008 - Criticar se a conta informada nao estiver no
                            contrato informado na baixa e inclusao (Guilherme).
                            
               22/12/2008 - Validacao acim somente para devedores(Guilherme).  
                                         
               10/08/2009 - Criticar se o registro da crapass estiver alocado
                            na inclusao
                          - Criticar se o contrato ja estiver incluso na mesma
                            data (Guilherme).
                            
               18/11/2009- Na baixa do SPC, se o Devedor e Fiador nao tiverem
                           outros contratos na crapspc, limpar a crapass.dtdsdspc
                           (Fernando).    
                           
               29/03/2010- Inclusao do campo tpinsttu (Sandro-GATI).
               
               13/01/2012 - Tratamento para o numero do contrato quando for 
                            opcao tipo "1-devedor" (Tiago).
                            
               30/01/2012 - Adaptar fonte para o uso de BO. (Gabriel-DB1)
               
               15/03/2012 - Correção tipo SPC/SERASA na impressão (Oscar).
               
               03/09/2013 - Retirado a opção de Incluir, Alterar e Baixar, para
                            as cooperativas "1,16,13" será feito pelo crps657.p 
                            de forma automatica. (James)
                            
               27/11/2013 - Retirado comentários e códigos comentados que não
                            são necessários. (Jéssica DB1)
                
               27/02/2014 - Retirado a opção de Incluir, Alterar e Baixar, para
                            as cooperativas "2,15,17,10,7,12,9" será feito pelo 
                            crps657.p de forma automatica. (Oscar)
                            
               01/04/2014 - Retirado a opção de Incluir, Alterar e Baixar, será
                            feito pelo crps657.p de forma automatica. (James)
                            
               04/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               06/02/2015 - Retirado LIKE da tabela CRAPCDV (Daniel). 
............................................................................. */

{ includes/var_online.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0133tt.i }

DEF VAR h-b1wgen0133 AS HANDLE                                  NO-UNDO.
DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
DEF VAR aux_flgassoc AS LOGI                                    NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
DEF VAR aux_operador AS CHAR                                    NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
 
DEF VAR tel_nrcpfcgc LIKE crapass.nrcpfcgc                      NO-UNDO.
DEF VAR tel_nrctremp AS INT FORMAT "zz,zzz,zz9"                 NO-UNDO.
DEF VAR tel_dtvencto LIKE crapspc.dtvencto                      NO-UNDO.
DEF VAR tel_vldivida LIKE crapspc.vldivida                      NO-UNDO.
DEF VAR tel_nrctrspc LIKE crapspc.nrctrspc                      NO-UNDO.
DEF VAR tel_dtdbaixa AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_dsoberv1 AS CHAR FORMAT "x(30)"                     NO-UNDO.
DEF VAR tel_dsoberv2 AS CHAR FORMAT "x(30)"                     NO-UNDO.
DEF VAR tel_operador AS CHAR FORMAT "x(28)"                     NO-UNDO.
DEF VAR tel_opebaixa AS CHAR FORMAT "x(28)"                     NO-UNDO.
DEF VAR tel_dtinclus AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_nrdconta LIKE crapspc.nrdconta                      NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(45)"                     NO-UNDO.
DEF VAR tel_tpidenti LIKE crapspc.tpidenti                      NO-UNDO.
DEF VAR tel_dsidenti AS CHAR FORMAT "x(10)"                     NO-UNDO.
DEF VAR tel_tpctrdev AS INT  FORMAT "9"                         NO-UNDO.
DEF VAR tel_nrctaavl LIKE crapass.nrdconta                      NO-UNDO.
DEF VAR tel_nmpriavl LIKE crapass.nmprimtl                      NO-UNDO.
DEF VAR tel_dtaltera AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_flgerror AS LOGICAL                                 NO-UNDO.
DEF VAR tel_cdagenci AS INT  FORMAT "zz9"                       NO-UNDO.
DEF VAR tel_nmresage AS CHAR FORMAT "x(15)"                     NO-UNDO.
DEF VAR tel_tpinsttu AS INT  FORMAT "9"                         NO-UNDO.
DEF VAR tel_dsinsttu AS CHAR FORMAT "x(10)"                     NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                    NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_contador AS INT                                     NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                     NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                 NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                 NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL    INIT TRUE                    NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL    INIT TRUE                    NO-UNDO.
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"     NO-UNDO.
DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                    NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5           NO-UNDO.
DEF VAR rel_nrmodulo AS INT   FORMAT "9"                        NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "] NO-UNDO.
DEF QUERY q_contas FOR tt-conta.
DEF BROWSE b_contas QUERY q_contas
    DISPLAY tt-conta.nrdconta NO-LABEL 
            WITH 5 DOWN WIDTH 14 NO-LABELS OVERLAY.
FORM SKIP(1)
     b_contas  HELP "Use ENTER para selecionar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 11 OVERLAY FRAME f_contas.

DEF QUERY q_cadspc FOR tt-devedor.
                                           
DEF BROWSE b_cadspc QUERY q_cadspc
    DISPLAY tt-devedor.dsidenti COLUMN-LABEL "Ide"       FORMAT "x(04)"
            tt-devedor.nrctremp COLUMN-LABEL "Contrato"  FORMAT "zz,zzz,zz9"
            tt-devedor.nrctrspc COLUMN-LABEL "Ctr.SPC"   FORMAT "x(11)"
            tt-devedor.dtvencto COLUMN-LABEL "Vencimen." FORMAT "99/99/99"
            tt-devedor.vldivida COLUMN-LABEL "Divida"    FORMAT "zzz,zz9.99-"
            tt-devedor.dtinclus COLUMN-LABEL "Inclusao"  FORMAT "99/99/99"
            tt-devedor.dtdbaixa COLUMN-LABEL "Baixa"     FORMAT "99/99/99"
            tt-devedor.dsinsttu COLUMN-LABEL "Insti."    FORMAT "x(06)"
            WITH 6 DOWN OVERLAY.

DEF QUERY q_zoom_cadspc FOR tt-contrato.

DEF BROWSE b_zoom_cadspc QUERY q_zoom_cadspc
    DISPLAY tt-contrato.nrctrspc COLUMN-LABEL "Ctr.SPC"  FORMAT "x(11)"
            tt-contrato.vldivida COLUMN-LABEL "Divida"   
            tt-contrato.dtinclus COLUMN-LABEL "Inclusao" FORMAT "99/99/9999"
            tt-contrato.dtdbaixa COLUMN-LABEL "Baixa"    FORMAT "99/99/9999"
            WITH 6 DOWN OVERLAY.

FORM SKIP(1)
    b_zoom_cadspc HELP "Use as SETAS para navegar ou F4 para sair"
    SKIP
    WITH NO-BOX ROW 6 COLUMN 2 OVERLAY CENTERED FRAME f_zoom_cadspc.
     
FORM SKIP(1)
     b_cadspc  HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH NO-BOX WIDTH 300 ROW 6 COLUMN 2 OVERLAY CENTERED FRAME f_cadspc.
                        
     
FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
          ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.
                       

FORM SKIP     
     glb_cddopcao LABEL "Opcao"
                  HELP "Informe a opcao desejada (A, B, C, I ou M)."
                  VALIDATE(CAN-DO("A,B,C,I,M", glb_cddopcao),
                                  "014 - Opcao errada.")

     tel_nrcpfcgc LABEL "      C.P.F/C.N.P.J."
                  HELP "Entre com o C.P.F/C.N.P.J"

     tel_tpidenti LABEL "    Identificacao"
                  HELP "Entre com o codigo(1-devedor1; 3-fiador1; 4-fiador2)"
                  VALIDATE(tel_tpidenti  = 1  OR  tel_tpidenti  = 3 OR
                           tel_tpidenti  = 4, "014 - Opcao errada.") 
     tel_dsidenti NO-LABEL
     SKIP(1)
     tel_nrdconta LABEL " Devedor"
         HELP "Informe a CONTA/Contrato ou (F7 - Apenas p/ devedor1) p/ listar"
         VALIDATE (tel_nrdconta <> 0, "375 - O campo deve ser preenchido")

     tel_nmprimtl NO-LABEL 
     SKIP
     tel_nrctaavl LABEL "  Fiador"
                  HELP "Informe o numero do CONTA ou F7 p/ listar" 
 
     tel_nmpriavl NO-LABEL 
     SKIP(1)
     SPACE(16) 
     tel_cdagenci LABEL "PA"  tel_nmresage    SKIP
     SPACE(15)
     tel_tpctrdev LABEL "Tipo"
             HELP "Informe o tipo (1-Conta, 2-Desconto Cheques, 3-Emprestimos)"
                  VALIDATE(tel_tpctrdev = 1  OR  tel_tpctrdev = 2 OR
                      tel_tpctrdev = 3, "014 - Opcao errada.") 
     SPACE(17)
     tel_nrctremp LABEL "Contrato" 
                  HELP "Entre com o numero do Contrato"
     SKIP
     tel_nrctrspc LABEL "Nro.Contrato do SPC"
                  HELP "Informe o numero do Contrato do SPC"
     SKIP
     SPACE(9)
     tel_dtvencto LABEL "Vencimento"
                  HELP "Informe a Data do Vencimento"
                  VALIDATE(tel_dtvencto <> ? ,
                               "375 - O campo deve ser preenchido") 
     SKIP
     SPACE(14)
     tel_vldivida LABEL "Valor"
                  HELP "Informe o Valor da Divida"
                  VALIDATE(tel_vldivida <> 0,
                               "375 - O campo deve ser preenchido")
     SKIP(1)
     tel_dtinclus LABEL "Inclusao => Data" AT 4   
                  HELP "Informe a Data da Inclusao"
                  VALIDATE(tel_dtinclus <> ? ,
                               "375 - O campo deve ser preenchido")
  
     tel_operador LABEL "Operador"        AT 40
     tel_dsoberv1 LABEL "Observacao"      AT 10
     tel_tpinsttu LABEL "Registro"            AT 40
                  HELP "Informe 1 para SPC ou 2 para SERASA"
                  VALIDATE(tel_tpinsttu = 1 OR tel_tpinsttu = 2 , "014 - Opcao errada.") 

     tel_dsinsttu NO-LABEL
     tel_dtdbaixa LABEL "Baixa => Data"      AT 7 
     tel_opebaixa LABEL "Operador"           AT 40  FORMAT "x(15)"
     tel_dsoberv2 LABEL "Observacao"         AT 10    
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_spc.
     
FORM SKIP     
     glb_cddopcao LABEL "Opcao"

     tel_nrcpfcgc LABEL "      C.P.F/C.N.P.J."
                  HELP "Entre com o C.P.F/C.N.P.J"

     tel_nrdconta LABEL "       Conta"
                  HELP "Informe o numero da Conta"
     WITH ROW 5 COLUMN 2 SIZE 78 BY 16 OVERLAY SIDE-LABELS NO-LABEL NO-BOX 
     FRAME f_spc_c.
     
FORM tel_nmprimtl  LABEL "Nome" 
     SKIP(1)
     tel_cdagenci  LABEL "PA"   AT 2
     tel_nmresage
     WITH ROW 17 COLUMN 5 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_spc_cc.
     
     
FORM SKIP
     glb_cddopcao LABEL "Opcao"
     tel_cdagenci LABEL "     PA"   
                  HELP "Informe o numero do PA para Relatorio."
     WITH ROW 5 COLUMN 2 SIZE 78 BY 16 OVERLAY SIDE-LABELS NO-LABEL NO-BOX 
     FRAME f_spc_m.
    
                                    
ON VALUE-CHANGED, ENTRY OF b_cadspc
    DO:
        IF  AVAIL tt-devedor THEN
            DO: 
                ASSIGN tel_nmprimtl = tt-devedor.nmprimtl
                       tel_cdagenci = tt-devedor.cdagenci
                       tel_nmresage = tt-devedor.nmresage.

                DISPLAY tel_nmprimtl tel_cdagenci tel_nmresage
                    WITH FRAME f_spc_cc.
                    PAUSE 0.
            END. 
    END.

ON RETURN OF b_zoom_cadspc
    DO:
        IF  AVAIL tt-contrato THEN
            DO:
                ASSIGN aux_nrdrowid = tt-contrato.nrdrowid.
                
                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.

            END.

        APPLY "GO".    
    END.
    
/* Retorna contas do associado */    
ON RETURN OF b_contas
    DO:
        IF  TEMP-TABLE tt-conta:HAS-RECORDS THEN
            DO:
                IF  tel_tpidenti = 1  THEN
                    DO:
                        ASSIGN tel_nrdconta = tt-conta.nrdconta
                               tel_nmprimtl = " - " + tt-conta.nmprimtl.
        
                        DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_spc.
                    END.
                ELSE
                    DO:
                        ASSIGN tel_nrctaavl = tt-conta.nrdconta
                               tel_nmpriavl = " - " + tt-conta.nmprimtl.
        
                        DISPLAY tel_nrctaavl tel_nmpriavl WITH FRAME f_spc.
                    END.
        
                APPLY "GO".
            END.
    END.
              
  
VIEW FRAME f_moldura. 
PAUSE(0). 

ASSIGN glb_cddopcao = "C"
       tel_dtaltera = glb_dtmvtolt.

RUN fontes/inicia.p.
                             
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE  glb_cddopcao WITH FRAME f_spc.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "CADSPC"   THEN
                DO:
                    RUN deleta_handle.
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
                   
    IF  CAN-DO("A,B,I",glb_cddopcao) THEN
        DO:
            MESSAGE "Essa opcao foi desabilitada.".
            PAUSE 2 NO-MESSAGE.
    
            NEXT.
        END.          

    ASSIGN tel_nrcpfcgc = 0
           tel_tpidenti = 0
           tel_dsidenti = ""
           tel_nrdconta = 0
           tel_nmprimtl = ""
           tel_nrctaavl = 0
           tel_nmpriavl = ""
           tel_cdagenci = 0
           tel_nmresage = ""
           tel_nrctremp = 0
           tel_tpctrdev = 0
           tel_nrctrspc = ""
           tel_dtvencto = ?
           tel_vldivida = 0
           tel_dtinclus = ?
           tel_dtdbaixa = ?
           tel_operador = ""
           tel_tpinsttu = 1
           tel_dsinsttu = "- " + "SPC"
           tel_opebaixa = ""
           tel_dsoberv1 = ""
           tel_dsoberv2 = "".

    DISPLAY tel_nrcpfcgc tel_tpidenti tel_dsidenti tel_nrdconta
            tel_nmprimtl tel_nrctaavl tel_nmpriavl tel_cdagenci
            tel_nmresage tel_nrctremp tel_tpctrdev tel_nrctrspc
            tel_dtvencto tel_vldivida tel_dtinclus tel_dtdbaixa
            tel_operador tel_tpinsttu tel_dsinsttu tel_opebaixa
            tel_dsoberv1 tel_dsoberv2 WITH FRAME f_spc.

    IF  glb_cddopcao = "I" THEN
        DO:
            DO WHILE TRUE:

                DISPLAY tel_nmpriavl WITH FRAME f_spc.

                UPDATE tel_nrcpfcgc tel_tpidenti WITH FRAME f_spc.

                IF  tel_tpidenti = 1  THEN
                    DO: 
                        ASSIGN tel_dsidenti = "- " + "devedor1"
                               tel_nrctaavl = 0
                               tel_nmpriavl = "".

                        DISPLAY tel_dsidenti tel_nmpriavl 
                                tel_nrctaavl WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc
                        EDITING:
                            DO WHILE TRUE:
                                READKEY PAUSE 1.

                                IF  LASTKEY = KEYCODE("F7")  AND
                                    FRAME-FIELD = "tel_nrdconta" THEN
                                    DO:
                                        HIDE MESSAGE.

                                        RUN Busca_Conta.

                                        IF  RETURN-VALUE <> "OK" THEN
                                            LEAVE.

                                        OPEN QUERY q_contas
                                            FOR EACH tt-conta NO-LOCK.

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            UPDATE b_contas 
                                                WITH FRAME f_contas.
                                            LEAVE.
                                        END.

                                        HIDE FRAME f_contas.
                                        NEXT.
                                    END.

                                APPLY LASTKEY.
                                LEAVE.

                            END. /* FIM DO WHILE */
                        END. /* FIM DO EDITING */

                        RUN Busca_Devedor.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.

                        UPDATE tel_tpctrdev WITH FRAME  f_spc. 

                        IF  tel_tpctrdev = 1 AND
                            tel_tpidenti = 1 THEN
                            DO:
                                ASSIGN tel_nrctremp = tel_nrdconta.
                                DISPLAY tel_nrctremp WITH FRAME f_spc.
                            END.                                
                        ELSE
                            UPDATE tel_nrctremp WITH FRAME f_spc.

                        RUN Busca_Contratos.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                    END. /* IF  tel_tpidenti = 1 */
                ELSE
                /* Quando inserir um Fiador no SPC, deve-se informar o CPF
                 do mesmo, nao informar o CPF do devedor. */
                IF  tel_tpidenti = 3  OR tel_tpidenti = 4  THEN
                    DO: 
                        
                        IF  tel_tpidenti = 3  THEN
                            ASSIGN tel_dsidenti = "- " + "fiador1".
                        ELSE
                            ASSIGN tel_dsidenti = "- " + "fiador2".

                        DISPLAY tel_dsidenti WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc.

                        RUN Busca_Fiador.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + 
                                                  tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.
                        
                        IF  aux_flgassoc THEN DO:
                            
                            UPDATE tel_nrctaavl WITH FRAME f_spc
                            EDITING:
                                DO WHILE TRUE:

                                    READKEY PAUSE 1.

                                    IF  LASTKEY = KEYCODE("F7")  AND
                                        FRAME-FIELD = "tel_nrctaavl" THEN
                                        DO:
                                            HIDE MESSAGE.

                                            RUN Busca_Conta.

                                            IF  RETURN-VALUE <> "OK" THEN
                                                LEAVE.

                                            OPEN QUERY q_contas
                                                FOR EACH tt-conta NO-LOCK.

                                            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                                UPDATE b_contas
                                                    WITH FRAME f_contas.
                                                LEAVE.
                                            END.

                                            HIDE FRAME f_contas.
                                            NEXT.
                                        END.

                                    APPLY LASTKEY.
                                    LEAVE.

                                END. /* fim DO WHILE */

                            END. /* fim do EDITING */

                            RUN Verifica_Fiador.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.

                            FIND FIRST tt-devedor NO-ERROR.

                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nrctaavl = tt-devedor.nrctaavl
                                       tel_nmpriavl = " - " +
                                                      tt-devedor.nmpriavl.

                            DISPLAY tel_nrdconta tel_nmpriavl 
                                WITH FRAME f_spc.

                        END. /* IF  aux_flgassoc */
                        ELSE DO:
                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nmpriavl = " - " + 
                                                      tt-devedor.nmpriavl.
                            DISPLAY tel_nmpriavl WITH FRAME f_spc.
                        END.

                        DISPLAY tel_cdagenci tel_nmresage WITH FRAME f_spc.

                        UPDATE tel_tpctrdev WITH FRAME f_spc. 

                        IF  tel_tpctrdev = 1 AND 
                            tel_tpidenti = 1 THEN
                            DO:
                                ASSIGN tel_nrctremp = tel_nrdconta.
                                DISPLAY tel_nrctremp WITH FRAME f_spc.
                            END.
                        ELSE
                            UPDATE tel_nrctremp WITH FRAME f_spc.

                        RUN Valida_Contrato.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                    END. /* Fim IF  tel_tpidenti = 3 ... */

                UPDATE tel_nrctrspc tel_dtvencto tel_vldivida
                       tel_dtinclus tel_tpinsttu WITH FRAME f_spc
                EDITING:
                    READKEY.
                    APPLY LASTKEY.
                    
                    HIDE MESSAGE NO-PAUSE.

                    IF  GO-PENDING THEN
                        DO:
                            ASSIGN  tel_nrctrspc = INPUT tel_nrctrspc
                                    tel_dtvencto = INPUT tel_dtvencto
                                    tel_vldivida = INPUT tel_vldivida
                                    tel_dtinclus = INPUT tel_dtinclus
                                    tel_tpinsttu = INPUT tel_tpinsttu.

                            RUN Valida_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    {sistema/generico/includes/foco_campo.i
                                        &VAR-GERAL=SIM
                                        &NOME-FRAME="f_spc"
                                        &NOME-CAMPO=aux_nmdcampo }
                                END.
                        END.
                END.  /*  Fim do EDITING  */

                UPDATE tel_dsoberv1 WITH FRAME f_spc.

                RUN confirma.

                IF  aux_confirma = "S" THEN
                    DO:
                        RUN Grava_dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        LEAVE.
                    END.

            END. /* Fim DO WHILE ... */

        END. /* Fim IF  glb_cddopcao = "I" */
    ELSE
    IF  glb_cddopcao = "A"  THEN
        DO:
            DO WHILE TRUE:
                UPDATE tel_nrcpfcgc tel_tpidenti WITH FRAME f_spc.

                IF  tel_tpidenti = 1  THEN
                    DO:
                        ASSIGN tel_dsidenti = "- " + "devedor1"
                               tel_nmprimtl = "" 
                               tel_nrctaavl = 0
                               tel_nmpriavl = "".

                        DISPLAY tel_dsidenti tel_nmprimtl 
                                tel_nrctaavl tel_nmpriavl WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc
                        EDITING:
                            DO WHILE TRUE:
                                READKEY PAUSE 1.

                                IF  LASTKEY = KEYCODE("F7")  AND
                                    FRAME-FIELD = "tel_nrdconta" THEN
                                    DO:
                                        HIDE MESSAGE.

                                        RUN Busca_Conta.

                                        IF  RETURN-VALUE <> "OK" THEN
                                            LEAVE.

                                        OPEN QUERY q_contas
                                            FOR EACH tt-conta NO-LOCK.

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            UPDATE b_contas 
                                                WITH FRAME f_contas.
                                            LEAVE.
                                        END.

                                        HIDE FRAME f_contas.
                                        NEXT.
                                    END.

                                APPLY LASTKEY.
                                LEAVE.

                            END. /* FIM DO WHILE */
                        END. /* FIM DO EDITING */

                        RUN Busca_Devedor.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.

                    END. /* Fim IF  tel_tpidenti = 1 */
                ELSE
                IF  tel_tpidenti = 3  OR tel_tpidenti = 4  THEN
                    DO:
                        IF  tel_tpidenti = 3  THEN
                            ASSIGN tel_dsidenti = "- " + "fiador1".
                        ELSE 
                            ASSIGN tel_dsidenti = "- " + "fiador2".

                        ASSIGN tel_nmprimtl = ""
                               tel_nrctaavl = 0
                               tel_nmpriavl = "".

                        DISPLAY tel_dsidenti tel_nmprimtl tel_nrctaavl
                                tel_nmpriavl WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc.

                        RUN Busca_Fiador.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.

                        IF  aux_flgassoc THEN DO:
                            UPDATE tel_nrctaavl WITH FRAME f_spc
                            EDITING:
                                DO WHILE TRUE:

                                    READKEY PAUSE 1.

                                    IF  LASTKEY = KEYCODE("F7")  AND
                                        FRAME-FIELD = "tel_nrctaavl" THEN
                                        DO:
                                            HIDE MESSAGE.

                                            RUN Busca_Conta.

                                            IF  RETURN-VALUE <> "OK" THEN
                                                LEAVE.

                                            OPEN QUERY q_contas
                                                FOR EACH tt-conta NO-LOCK.

                                            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                                UPDATE b_contas
                                                    WITH FRAME f_contas.
                                                LEAVE.
                                            END.

                                            HIDE FRAME f_contas.
                                            NEXT.
                                        END.

                                    APPLY LASTKEY.
                                    LEAVE.

                                END. /* fim DO WHILE */

                            END. /* fim do EDITING */

                            RUN Verifica_Fiador.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.

                            FIND FIRST tt-devedor NO-ERROR.

                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nrctaavl = tt-devedor.nrctaavl
                                       tel_nmpriavl = " - " +
                                                      tt-devedor.nmpriavl.

                            DISPLAY tel_nrdconta tel_nmpriavl 
                                WITH FRAME f_spc.

                        END. /* IF  aux_flgassoc */
                        ELSE DO:
                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nmpriavl = " - " + 
                                                      tt-devedor.nmpriavl.
                            DISPLAY tel_nmpriavl WITH FRAME f_spc.
                        END.

                    END. /* Fim IF  tel_tpidenti = 3  OR tel_tpidenti = 4 */

                DISPLAY tel_cdagenci tel_nmresage WITH FRAME f_spc.

                UPDATE tel_tpctrdev WITH FRAME f_spc.

                IF  tel_tpctrdev = 1 AND
                    tel_tpidenti = 1 THEN
                    DO:
                        ASSIGN tel_nrctremp = tel_nrdconta.
                        DISPLAY tel_nrctremp WITH FRAME f_spc.
                        PAUSE 0.    
                    END.
                ELSE
                    UPDATE tel_nrctremp WITH FRAME f_spc.
                    
                RUN Busca_Contratos.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                OPEN QUERY q_zoom_cadspc FOR EACH tt-contrato NO-LOCK.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                    UPDATE b_zoom_cadspc WITH FRAME f_zoom_cadspc.
                    LEAVE.
                END.

                HIDE FRAME f_zoom_cadspc.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.

                FIND FIRST tt-devedor NO-ERROR.

                IF  AVAIL tt-devedor THEN
                    ASSIGN tel_nrctrspc = tt-devedor.nrctrspc
                           tel_dtvencto = tt-devedor.dtvencto
                           tel_vldivida = tt-devedor.vldivida
                           tel_dtinclus = tt-devedor.dtinclus
                           tel_tpinsttu = tt-devedor.tpinsttu
                           tel_dtdbaixa = tt-devedor.dtdbaixa
                           tel_dsoberv1 = tt-devedor.dsoberv1
                           tel_dsoberv2 = tt-devedor.dsoberv2
                           tel_operador = tt-devedor.operador
                           tel_opebaixa = tt-devedor.opebaixa
                           tel_dsinsttu = tt-devedor.dsinsttu.

                DISP tel_nrctrspc tel_dtvencto tel_vldivida
                     tel_dtinclus tel_tpinsttu tel_dtdbaixa
                     tel_dsoberv1 tel_dsoberv2 tel_operador
                     tel_opebaixa tel_dsinsttu WITH FRAME f_spc.

                UPDATE tel_nrctrspc tel_dtvencto tel_vldivida
                       tel_dtinclus tel_tpinsttu WITH FRAME f_spc
                EDITING:
                    READKEY.
                    APPLY LASTKEY.
                    
                    HIDE MESSAGE NO-PAUSE.

                    IF  GO-PENDING THEN
                        DO:

                            ASSIGN  tel_nrctrspc = INPUT tel_nrctrspc
                                    tel_dtvencto = INPUT tel_dtvencto
                                    tel_vldivida = INPUT tel_vldivida
                                    tel_dtinclus = INPUT tel_dtinclus
                                    tel_tpinsttu = INPUT tel_tpinsttu.

                            RUN Valida_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    {sistema/generico/includes/foco_campo.i
                                        &NOME-FRAME="f_spc"
                                        &NOME-CAMPO=aux_nmdcampo }
                                END.
                        END.
                END.  /*  Fim do EDITING  */
                
                UPDATE tel_dsoberv1 WITH FRAME f_spc.

                RUN confirma.

                IF  aux_confirma = "S" THEN
                    DO:
                        ASSIGN aux_nrdrowid = tt-devedor.nrdrowid.

                        RUN Grava_dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        LEAVE.

                    END.

            END. /* Fim DO WHILE TRUE */

        END. /* Fim IF  glb_cddopcao = "A" */
    ELSE
    IF  glb_cddopcao = "B"  THEN
        DO:
            DO WHILE TRUE:

                UPDATE tel_nrcpfcgc tel_tpidenti WITH FRAME f_spc.

                IF  tel_tpidenti = 1 THEN
                    DO:
                        ASSIGN tel_dsidenti = "- " + "devedor1"
                               tel_nmprimtl = "" 
                               tel_nrctaavl = 0
                               tel_nmpriavl = "".

                        DISPLAY tel_dsidenti tel_nmprimtl 
                                 tel_nrctaavl tel_nmpriavl WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc
                        EDITING:
                            DO WHILE TRUE:

                                READKEY PAUSE 1.

                                IF  LASTKEY = KEYCODE("F7")  AND
                                    FRAME-FIELD = "tel_nrdconta"   THEN
                                    DO:

                                        HIDE MESSAGE.

                                        RUN Busca_Conta.

                                        IF  RETURN-VALUE <> "OK" THEN
                                            LEAVE.

                                        OPEN QUERY q_contas
                                            FOR EACH tt-conta NO-LOCK.

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            UPDATE b_contas 
                                                WITH FRAME f_contas.
                                            LEAVE.
                                        END.

                                        HIDE FRAME f_contas.
                                        NEXT.
                                    END.

                                APPLY LASTKEY.
                                LEAVE.

                            END. /* FIM DO WHILE */

                        END. /* FIM DO EDITING */

                        RUN Busca_Devedor.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.

                    END. /* Fim IF  tel_tpidenti = 1 */
                ELSE
                IF  tel_tpidenti = 3  OR tel_tpidenti = 4 THEN
                    DO:
                        IF  tel_tpidenti = 3  THEN
                            ASSIGN tel_dsidenti = "- " + "fiador1".
                        ELSE 
                            ASSIGN tel_dsidenti = "- " + "fiador2".

                        ASSIGN tel_nmprimtl = ""
                               tel_nrctaavl = 0
                               tel_nmpriavl = "".

                        DISPLAY tel_dsidenti tel_nmprimtl
                                tel_nrctaavl tel_nmpriavl WITH FRAME f_spc.

                        UPDATE tel_nrdconta WITH FRAME f_spc.

                        RUN Busca_Fiador.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-devedor NO-ERROR.

                        IF  AVAIL tt-devedor THEN
                            ASSIGN tel_nmprimtl = " - " + tt-devedor.nmprimtl
                                   tel_cdagenci = tt-devedor.cdagenci
                                   tel_nmresage = tt-devedor.nmresage.

                        DISPLAY tel_nmprimtl tel_cdagenci
                                tel_nmresage WITH FRAME f_spc.

                        IF  aux_flgassoc THEN DO:
                            UPDATE tel_nrctaavl WITH FRAME f_spc
                            EDITING:
                                DO WHILE TRUE:

                                    READKEY PAUSE 1.

                                    IF  LASTKEY = KEYCODE("F7")  AND
                                        FRAME-FIELD = "tel_nrctaavl" THEN
                                        DO:
                                            HIDE MESSAGE.

                                            RUN Busca_Conta.

                                            IF  RETURN-VALUE <> "OK" THEN
                                                LEAVE.

                                            OPEN QUERY q_contas
                                                FOR EACH tt-conta NO-LOCK.

                                            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                                UPDATE b_contas
                                                    WITH FRAME f_contas.
                                                LEAVE.
                                            END.

                                            HIDE FRAME f_contas.
                                            NEXT.
                                        END.

                                    APPLY LASTKEY.
                                    LEAVE.

                                END. /* fim DO WHILE */

                            END. /* fim do EDITING */

                            RUN Verifica_Fiador.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.

                            FIND FIRST tt-devedor NO-ERROR.

                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nrctaavl = tt-devedor.nrctaavl
                                       tel_nmpriavl = " - " +
                                                      tt-devedor.nmpriavl.

                            DISPLAY tel_nrdconta tel_nrctaavl tel_nmpriavl 
                                WITH FRAME f_spc.

                        END. /* IF  aux_flgassoc */
                        ELSE DO:
                            IF  AVAIL tt-devedor THEN
                                ASSIGN tel_nmpriavl = " - " + 
                                                      tt-devedor.nmpriavl.
                            DISPLAY tel_nmpriavl WITH FRAME f_spc.
                        END.

                    END. /* Fim IF  tel_tpidenti = 3  OR tel_tpidenti = 4 */

                DISPLAY tel_cdagenci tel_nmresage WITH FRAME f_spc.

                UPDATE tel_tpctrdev WITH FRAME f_spc.

                IF  tel_tpctrdev = 1 AND
                    tel_tpidenti = 1 THEN
                    DO:
                        ASSIGN tel_nrctremp = tel_nrdconta.
                        DISPLAY tel_nrctremp WITH FRAME f_spc.
                        PAUSE 0.    
                    END.
                ELSE
                    UPDATE tel_nrctremp WITH FRAME f_spc.
                    
                RUN Busca_Contratos.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                OPEN QUERY q_zoom_cadspc FOR EACH tt-contrato NO-LOCK.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                    UPDATE b_zoom_cadspc WITH FRAME f_zoom_cadspc.
                    LEAVE.
                END.

                HIDE FRAME f_zoom_cadspc.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.

                FIND FIRST tt-devedor NO-ERROR.

                IF  AVAIL tt-devedor THEN
                    ASSIGN tel_nrctrspc = tt-devedor.nrctrspc
                           tel_dtvencto = tt-devedor.dtvencto
                           tel_vldivida = tt-devedor.vldivida
                           tel_dtinclus = tt-devedor.dtinclus
                           tel_tpinsttu = tt-devedor.tpinsttu
                           tel_dtdbaixa = tt-devedor.dtdbaixa
                           tel_dsoberv1 = tt-devedor.dsoberv1
                           tel_dsoberv2 = tt-devedor.dsoberv2
                           tel_operador = tt-devedor.operador
                           tel_opebaixa = tt-devedor.opebaixa
                           tel_dsinsttu = tt-devedor.dsinsttu.

                DISP tel_nrctrspc tel_dtvencto tel_vldivida
                     tel_dtinclus tel_tpinsttu tel_dtdbaixa
                     tel_dsoberv1 tel_dsoberv2 tel_operador
                     tel_opebaixa tel_dsinsttu WITH FRAME f_spc.

                UPDATE tel_dtdbaixa WITH FRAME f_spc.

                RUN Valida_Dados.
                
                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                UPDATE tel_dsoberv2 WITH FRAME f_spc.

                RUN confirma.

                IF  aux_confirma = "S" THEN
                    DO:
                        ASSIGN aux_nrdrowid = tt-devedor.nrdrowid.

                        RUN Grava_dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.
                    END.

                LEAVE.

            END. /* Fim DO WHILE TRUE */

        END. /* Fim IF  glb_cddopcao = "B" */
    ELSE
    IF  glb_cddopcao = "C"  THEN
        DO:

            PAUSE 0.
            DISPLAY glb_cddopcao WITH FRAME f_spc_c.

            DO WHILE TRUE:

                ASSIGN tel_nmprimtl = ""
                       tel_nrdconta = 0. 

                DISPLAY tel_nrdconta WITH FRAME f_spc_c.
                
                UPDATE tel_nrcpfcgc WITH FRAME f_spc_c.

                IF  tel_nrcpfcgc <> 0  THEN
                    DO: 
                        RUN Busca_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        OPEN QUERY q_cadspc FOR EACH tt-devedor.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_cadspc WITH FRAME f_cadspc.
                            LEAVE.
                        END.

                        HIDE FRAME f_cadspc.
                        NEXT.
                          
                    END.    
                ELSE
                    DO:
                        UPDATE tel_nrdconta WITH FRAME f_spc_c.

                        RUN Busca_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        OPEN QUERY q_cadspc FOR EACH tt-devedor.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_cadspc WITH FRAME f_cadspc.
                            LEAVE.
                        END.

                        HIDE FRAME f_cadspc.
                        NEXT.
                    END.

            END. /* Fim DO WHILE TRUE */

        END. /* IF  glb_cddopcao = "C" */
    ELSE
    IF  glb_cddopcao = "M" THEN
        DO:
            PAUSE 0 NO-MESSAGE.

            DISPLAY glb_cddopcao WITH FRAME f_spc_m.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                

                UPDATE tel_cdagenci WITH FRAME f_spc_m.

                RUN Gera_Impressao.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.
            END.
        END. /* IF  glb_cddopcao = "M" */
END.

PROCEDURE confirma:

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

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_cadgps.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0133) THEN
        RUN sistema/generico/procedures/b1wgen0133.p 
            PERSISTENT SET h-b1wgen0133.

END PROCEDURE. /* conecta_handle */

PROCEDURE deleta_handle:

    IF  VALID-HANDLE(h-b1wgen0133) THEN
        DELETE PROCEDURE h-b1wgen0133.

END PROCEDURE. /* deleta_handle */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-devedor.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Dados IN h-b1wgen0133
                  ( INPUT glb_cdcooper,
                    INPUT 0,
                    INPUT 0,
                    INPUT glb_cdoperad,
                    INPUT glb_cdprogra,
                    INPUT 1, /* idorigem */
                    INPUT glb_dtmvtolt,
                    INPUT glb_cddopcao,
                    INPUT tel_nrcpfcgc,
                    INPUT tel_nrdconta,
                    INPUT tel_tpidenti,
                    INPUT tel_nrctremp,
                    INPUT tel_tpctrdev,
                    INPUT aux_nrdrowid,
                    INPUT 9999999,
                    INPUT 0,
                   OUTPUT aux_nmdcampo,
                   OUTPUT aux_qtregist,
                   OUTPUT TABLE tt-devedor,
                   OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Conta:

    EMPTY TEMP-TABLE tt-conta.
    
    RUN conecta_handle.

    RUN Busca_Conta IN h-b1wgen0133
                  ( INPUT glb_cdcooper,
                    INPUT tel_nrcpfcgc,
                   OUTPUT TABLE tt-conta) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE. /* Busca_Conta */

PROCEDURE Busca_Devedor:

    EMPTY TEMP-TABLE tt-devedor.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Devedor IN h-b1wgen0133
                    ( INPUT glb_cdcooper,
                      INPUT 0,               
                      INPUT 0,               
                      INPUT tel_nrdconta,
                      INPUT tel_nrcpfcgc,
                      INPUT tel_tpidenti,
                      INPUT glb_cddopcao,
                     OUTPUT aux_nmdcampo,
                     OUTPUT TABLE tt-devedor,
                     OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Busca_Devedor */

PROCEDURE Busca_Fiador:

    EMPTY TEMP-TABLE tt-devedor.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Fiador IN h-b1wgen0133
                   ( INPUT glb_cdcooper,
                     INPUT 0,               
                     INPUT 0,               
                     INPUT glb_cddopcao,
                     INPUT tel_nrdconta,
                     INPUT tel_nrcpfcgc,
                     INPUT tel_tpidenti,
                    OUTPUT aux_nmdcampo,
                    OUTPUT aux_flgassoc,
                    OUTPUT TABLE tt-devedor,
                    OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Busca_Fiador */

PROCEDURE Verifica_Fiador:

    EMPTY TEMP-TABLE tt-devedor.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Verifica_Fiador IN h-b1wgen0133
                     ( INPUT glb_cdcooper,
                       INPUT 0,               
                       INPUT 0,               
                       INPUT glb_cddopcao,
                       INPUT tel_nrdconta,
                       INPUT tel_nrcpfcgc,
                       INPUT tel_nrctaavl,
                       INPUT tel_tpidenti,
                      OUTPUT aux_nmdcampo,
                      OUTPUT TABLE tt-devedor,
                      OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Verifica_Fiador */

PROCEDURE Busca_Contratos:

    EMPTY TEMP-TABLE tt-devedor.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Contratos IN h-b1wgen0133
                      ( INPUT glb_cdcooper,
                        INPUT 0,               
                        INPUT 0,               
                        INPUT glb_cddopcao,
                        INPUT tel_nrdconta,
                        INPUT tel_nrcpfcgc,
                        INPUT tel_nrctremp,
                        INPUT tel_tpidenti,
                        INPUT tel_tpctrdev,
                        INPUT tel_nrctaavl,
                       OUTPUT aux_nmdcampo,
                       OUTPUT TABLE tt-contrato,
                       OUTPUT TABLE tt-erro) NO-ERROR.
    RUN deleta_handle.
    
    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Verifica_Fiador */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.
    
    RUN conecta_handle.

    RUN Valida_Dados IN h-b1wgen0133
                     ( INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,
                       INPUT glb_cddopcao,
                       INPUT glb_cdoperad,
                       INPUT tel_nrdconta,
                       INPUT tel_nrcpfcgc,
                       INPUT tel_tpidenti,
                       INPUT tel_dtvencto,
                       INPUT tel_dtinclus,
                       INPUT tel_vldivida,
                       INPUT tel_tpinsttu,
                       INPUT tel_dtdbaixa,
                      OUTPUT aux_nmdcampo,
                      OUTPUT tel_dsinsttu,
                      OUTPUT aux_operador,
                      OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    IF  aux_operador <> "" THEN
        DO:
            IF  glb_cddopcao = "A" THEN
                DO:
                    ASSIGN tel_operador = aux_operador.
                    DISPLAY tel_operador WITH FRAME f_spc.
                END.
            ELSE IF glb_cddopcao = "B" THEN
                    DO:
                        ASSIGN tel_opebaixa = aux_operador.
                        DISPLAY tel_opebaixa WITH FRAME f_spc.
                    END.

        END.
        
    RETURN "OK".
    
END PROCEDURE. /* Valida_Dados */

PROCEDURE Valida_Contrato:

    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Valida_Contrato IN h-b1wgen0133
                      ( INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,
                        INPUT glb_cddopcao,
                        INPUT glb_cdoperad,
                        INPUT tel_tpctrdev,
                        INPUT tel_nrdconta,
                        INPUT tel_nrctremp,
                        INPUT tel_nrcpfcgc,
                        INPUT tel_tpidenti,
                        INPUT tel_nrctaavl,
                       OUTPUT aux_nmdcampo,
                       OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.
    
    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.
        
    RETURN "OK".
    
END PROCEDURE. /* Valida_Contrato */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Grava_Dados IN h-b1wgen0133
                  ( INPUT glb_cdcooper,
                    INPUT 0,
                    INPUT 0,
                    INPUT 1,
                    INPUT glb_nmdatela,
                    INPUT glb_cdoperad,
                    INPUT glb_dtmvtolt,
                    INPUT glb_cddopcao,
                    INPUT tel_nrcpfcgc,
                    INPUT tel_nrdconta,
                    INPUT tel_tpidenti,
                    INPUT tel_nrctremp,
                    INPUT tel_tpctrdev,
                    INPUT tel_dtinclus,
                    INPUT tel_nrctrspc,
                    INPUT tel_dtvencto,
                    INPUT tel_vldivida,
                    INPUT tel_tpinsttu,
                    INPUT tel_dsoberv1,
                    INPUT tel_dtdbaixa,
                    INPUT tel_dsoberv2,
                    INPUT tel_nrctaavl,
                    INPUT aux_nrdrowid,
                   OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".
    
END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN conecta_handle.

    RUN Gera_Impressao IN h-b1wgen0133
                     ( INPUT glb_cdcooper,
                       INPUT 0,           
                       INPUT 0,           
                       INPUT 1,           
                       INPUT glb_nmdatela,
                       INPUT glb_cdprogra,
                       INPUT glb_dtmvtolt,
                       INPUT aux_nmendter,
                       INPUT tel_cdagenci,
                      OUTPUT aux_nmarqimp, 
                      OUTPUT aux_nmarqpdf,
                      OUTPUT TABLE tt-erro) NO-ERROR.

    RUN deleta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RUN confirma.

    IF  aux_confirma = "S"   THEN
        DO:
            ASSIGN glb_nmformul = "132col"
                   glb_nrcopias = 1
                   glb_nmarqimp = aux_nmarqimp.

            FIND FIRST crapass WHERE
                       crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

            { includes/impressao.i }
        END.

    RETURN "OK".
    
END PROCEDURE. /* Gera_Impressao */
/*...........................................................................*/
