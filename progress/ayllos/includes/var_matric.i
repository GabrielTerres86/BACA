/* .............................................................................

   Programa: includes/var_matric.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                     Ultima atualizacao: 05/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela MATRIC.

   Alteracao : 26/07/2006 - Criar variaveis shr_cdempres e shr_nmresemp (David)
   
               19/03/2007 - Nao permitir tipo de pessoa 3 (Magui)
               
               20/11/2007 - Incluido BUFFER crabttl (Diego).

               01/09/2008 - Alteracao cdempres (Kbase IT).
               
               12/08/2009 - Incluida variavel aux_flgexist (Diego).
               
               23/07/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               14/01/2011 - Alterado layout para permitir a utilizacao do 
                            format x(50) para o campo nome (Henrique).
                
               12/04/2011 - Ajustado layout para bairro format x(40) e
                            cidade x(25) - CEP integrado. (André - DB1)
                            
               14/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
               26/04/2013 - Incluir campo tel_cdufnatu no frame de pessoa fisica
                            (Lucas R.)
               
               30/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).

               27/05/2014 - Alterado o like dos campos de crapass.cdestcvl para
                            crapttl.cdestcvl (Douglas - Chamado 131253)
                            
               16/06/2014 - (Chamado 117414) - Alteraçao das informaçoes do conjuge da crapttl 
                            para utilizar somente crapcje. (Tiago Castro - RKAM)
               
               05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin).
............................................................................. */

DEF {1} SHARED  VAR shr_dsnacion AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR shr_inpessoa AS INT                                NO-UNDO.
DEF {1} SHARED  VAR shr_cdestcvl LIKE crapttl.cdestcvl                 NO-UNDO.
DEF {1} SHARED  VAR shr_dsestcvl AS CHAR   FORMAT "x(12)"              NO-UNDO.
DEF {1} SHARED  VAR shr_tpnacion LIKE crapttl.tpnacion                 NO-UNDO.
DEF {1} SHARED  VAR shr_restpnac AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR shr_dsnatura AS CHAR                               NO-UNDO.
DEF {1} SHARED  VAR shr_ocupacao_pesq AS CHAR FORMAT "x(15)"           NO-UNDO.
DEF {1} SHARED  VAR shr_cdocpttl LIKE crapttl.cdocpttl                 NO-UNDO.
DEF {1} SHARED  VAR shr_rsdocupa AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR shr_cdnatjur LIKE crapjur.natjurid                 NO-UNDO.
DEF {1} SHARED  VAR shr_rsnatjur AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR shr_dsnatjur AS CHAR   FORMAT "x(50)"              NO-UNDO.
DEF {1} SHARED  VAR shr_cdseteco AS INT                                NO-UNDO.
DEF {1} SHARED  VAR shr_nmseteco AS CHAR   FORMAT "x(20)"              NO-UNDO.
DEF {1} SHARED  VAR shr_cdrmativ AS INT                                NO-UNDO.
DEF {1} SHARED  VAR shr_nmrmativ AS CHAR   FORMAT "x(40)"              NO-UNDO.
DEF {1} SHARED  VAR shr_cdempres LIKE crapemp.cdempres                 NO-UNDO.
DEF {1} SHARED  VAR shr_nmresemp LIKE crapemp.nmresemp                 NO-UNDO.

DEF {1} SHARED  VAR tel_cdrmativ LIKE crapjur.cdrmativ                 NO-UNDO.
DEF {1} SHARED  VAR tel_nrdconta AS INT    FORMAT "zzzz,zzz,9"         NO-UNDO.
DEF {1} SHARED  VAR tel_nrcpfcgc AS CHAR FORMAT "X(18)"                NO-UNDO.
DEF {1} SHARED  VAR tel_dtaltera AS DATE                               NO-UNDO.
DEF {1} SHARED  VAR tel_dssitcpf AS CHAR   FORMAT "X(11)"              NO-UNDO.
DEF {1} SHARED  VAR dis_nrcpfcgc AS CHAR   FORMAT "x(18)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dsestcvl AS CHAR   FORMAT "x(11)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dsmotdem AS CHAR   FORMAT "x(18)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dsagenci AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dspessoa AS CHAR   FORMAT "x(08)"              NO-UNDO.
DEF {1} SHARED  VAR tel_cdsexotl AS CHAR   FORMAT "!"                  NO-UNDO.
DEF {1} SHARED  VAR tel_restpnac AS CHAR   FORMAT "x(15)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dsocpttl AS CHAR   FORMAT "x(12)"              NO-UNDO.
DEF {1} SHARED  VAR tel_nmresemp AS CHAR   FORMAT "x(12)"              NO-UNDO.
DEF {1} SHARED  VAR tel_nmfansia AS CHAR   FORMAT "X(40)"              NO-UNDO.
DEF {1} SHARED  VAR tel_insestad AS DEC    FORMAT "999,999,999,999"    NO-UNDO.
DEF {1} SHARED  VAR tel_natjurid AS INTE   FORMAT "zzz9"               NO-UNDO.
DEF {1} SHARED  VAR tel_dsnatjur AS CHAR   FORMAT "X(15)"              NO-UNDO.
DEF {1} SHARED  VAR tel_dtiniatv AS DATE   FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED  VAR tel_dsrmativ AS CHAR   FORMAT "X(40)"              NO-UNDO.
DEF {1} SHARED  VAR tel_nrtelefo LIKE craptfc.nrtelefo                 NO-UNDO.
DEF {1} SHARED  VAR tel_nrdddtfc LIKE craptfc.nrdddtfc                 NO-UNDO.

DEF {1} SHARED  VAR tel_nrcepend LIKE crapenc.nrcepend                 NO-UNDO.
DEF {1} SHARED  VAR tel_dsendere LIKE crapenc.dsendere                 NO-UNDO.
DEF {1} SHARED  VAR tel_nrendere LIKE crapenc.nrendere                 NO-UNDO.
DEF {1} SHARED  VAR tel_complend LIKE crapenc.complend                 NO-UNDO.
DEF {1} SHARED  VAR tel_nmbairro AS CHAR   FORMAT "X(40)"              NO-UNDO.
DEF {1} SHARED  VAR tel_nmcidade AS CHAR   FORMAT "X(25)"              NO-UNDO.
DEF {1} SHARED  VAR tel_cdufende LIKE crapenc.cdufende                 NO-UNDO.
DEF {1} SHARED  VAR tel_nrcxapst LIKE crapenc.nrcxapst                 NO-UNDO.
DEF {1} SHARED  VAR tel_cdseteco LIKE crapjur.cdseteco                 NO-UNDO.
DEF {1} SHARED  VAR tel_nmseteco AS CHAR FORMAT "x(11)"                NO-UNDO.
DEF {1} SHARED  VAR tel_inhabmen AS INT  FORMAT "9"                    NO-UNDO.
DEF {1} SHARED  VAR tel_dthabmen AS DATE FORMAT "99/99/9999"           NO-UNDO.
DEF {1} SHARED  VAR tel_dshabmen AS CHAR FORMAT "x(13)"                NO-UNDO.

DEF {1} SHARED  VAR aux_nrcadast AS INT  FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF {1} SHARED  VAR aux_nrdconta AS INT  FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF {1} SHARED  VAR aux_contador AS INT  FORMAT "z9"                   NO-UNDO.
DEF {1} SHARED  VAR aux_cddopcao AS CHAR                               NO-UNDO.
DEF {1} SHARED  VAR aux_confirma AS CHAR FORMAT "!"                    NO-UNDO.

DEF {1} SHARED  VAR rel_nrmatric LIKE crapass.nrmatric                 NO-UNDO.
DEF {1} SHARED  VAR rel_nrdconta LIKE crapass.nrdconta                 NO-UNDO.



DEF {1} SHARED VAR tel_dsdopcao AS CHAR FORMAT "x(24)" EXTENT 24       NO-UNDO.
DEF {1} SHARED VAR tel_dstipcta AS CHAR FORMAT "x(15)"                 NO-UNDO.
DEF {1} SHARED VAR tel_dssitdct AS CHAR FORMAT "x(18)"                 NO-UNDO.
DEF {1} SHARED VAR tel_idseqttl AS INTE FORMAT "9"                     NO-UNDO.
DEF {1} SHARED VAR tel_nmfatasi AS CHAR FORMAT "X(40)"                 NO-UNDO.
DEF {1} SHARED VAR tel_nmdavali AS CHAR FORMAT "x(40)"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfcto AS CHAR FORMAT "X(18)"                 NO-UNDO.

DEF {1} SHARED VAR aux_nrdeanos AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrdmeses AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_dsdidade AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmttlrfb AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_inconrfb AS INTE                              NO-UNDO.

DEF {1} SHARED  FRAME f_matric.
DEF {1} SHARED  FRAME f_matric_novo.

DEF BUFFER crabttl FOR crapttl.

FORM glb_cddopcao      AT  1 LABEL "Opcao" AUTO-RETURN
                       HELP "Informe a opcao desejada (A, C, D, I, R, X ou J)"
                       VALIDATE(CAN-DO("A,C,D,I,R,X,J",glb_cddopcao),
                                "014 - Opcao errada.")

     tel_nrdconta      AT 14 LABEL "Conta/Dv" AUTO-RETURN
                             HELP "Informe o numero da conta do cooperado"

     tel_cdagenci LIKE crapass.cdagenci  AT 37 LABEL "PA" AUTO-RETURN
                                         HELP "Informe o numero do PA." 
     "-"               
     tel_dsagenci            NO-LABEL
     tel_nrmatric LIKE crapass.nrmatric  AT 63 LABEL "Matr."
     SKIP
     tel_inpessoa LIKE crapass.inpessoa  AT  1 LABEL "Tp.Nat."
                  HELP "Tipo de pessoa: 1 - fisica, 2 - juridica"
     "-"
     tel_dspessoa            NO-LABEL
     tel_nmprimtl LIKE crapass.nmprimtl AT 23 LABEL "Nome" AUTO-RETURN  
                  HELP "Entre com o nome do associado." FORMAT "x(50)"
     SKIP
     tel_nrcpfcgc      AT  1 LABEL "C.P.F."  AUTO-RETURN 
                             HELP "Entre com o CPF do cooperado."
     tel_dtcnscpf LIKE crapass.dtcnscpf  AT 31 LABEL "Consulta" AUTO-RETURN
                  HELP "Entre com a data de consulta do CPF."
     tel_cdsitcpf LIKE crapass.cdsitcpf  AT 56 LABEL "Situacao" AUTO-RETURN
     HELP "Informe situacao CPF(1=Reg.,2=Pend.,3=Cancel.,4=Irreg.,5=Susp.)"
     tel_dssitcpf            NO-LABEL
     SKIP
     tel_tpdocptl LIKE crapass.tpdocptl  AT  1 LABEL "Documento"  AUTO-RETURN
                  HELP "Entre com o tipo de documento (CH, CI, CP, CT)."
     tel_nrdocptl LIKE crapass.nrdocptl        NO-LABEL           AUTO-RETURN
                  HELP "Entre com o numero do documento."
     tel_cdoedptl LIKE crapass.cdoedptl  AT 31 LABEL "Org.Emi."   AUTO-RETURN
                  HELP "Entre com o orgao expedidor do documento do titular."
     tel_cdufdptl LIKE crapass.cdufdptl  AT 49 LABEL "U.F."       AUTO-RETURN
                  HELP "Entre com a U.F. do orgao expedidor do doc.do titular."
     tel_dtemdptl LIKE crapass.dtemdptl  AT 58 LABEL "Data Emi."  AUTO-RETURN
                  HELP "Entre com a data de emissao do documento do titular."
     SKIP
     "  Filiacao:"
     tel_nmmaettl LIKE crapttl.nmmaettl  AT 13 LABEL "Mae"
                  HELP "Entre com o nome da mae do titular."
     SKIP
     tel_nmpaittl LIKE crapttl.nmpaittl  AT 13 LABEL "Pai" VALIDATE(TRUE,"")
                  HELP "Entre com o nome do pai do titular."
     SKIP
     tel_dtnasctl LIKE crapass.dtnasctl  AT  1 LABEL "Data Nascimento" 
                             AUTO-RETURN FORMAT "99/99/9999"
                  HELP "Entre com a data do nascimento do titular."
     tel_cdsexotl      AT 31 LABEL "Sexo" HELP "(M)asculino / (F)eminino"
                                      
     tel_tpnacion LIKE crapttl.tpnacion  AT 42 LABEL "Tipo Nacionalidade"
                 HELP "Informe o tipo de nacionalidade ou tecle F7 para listar"
     tel_restpnac            NO-LABEL
     SKIP
     tel_dsnacion LIKE crapass.dsnacion AT  3 LABEL "Nacionalidade" AUTO-RETURN
                  HELP "Entre com a nacionalidade ou tecle F7 para listar."
     tel_dsnatura LIKE crapttl.dsnatura AT 35 LABEL "Natural De"    AUTO-RETURN
                  HELP "Entre com a naturalidade ou tecle F7 para listar."
     tel_cdufnatu LIKE crapttl.cdufnatu AT 73 LABEL "UF" AUTO-RETURN
                  HELP "Entre com o estado de naturalidade."
     SKIP
     tel_inhabmen LABEL " Capc. Civil"
             HELP "(0)-menor/maior (1)-menor emancipado (2)-incapacidade civil"

     tel_dshabmen       NO-LABEL
     tel_dthabmen AT 42 LABEL "Data Emancipacao"
                        HELP "Informe a data de emancipacao" 
     SKIP
     tel_cdestcvl LIKE crapttl.cdestcvl  AT  1 LABEL "Estado Civil"
                  HELP "Entre com o estado civil do titular ou F7 para listar."
     tel_dsestcvl            NO-LABEL 
     tel_nmconjug LIKE crapcje.nmconjug  AT 30 LABEL "Conjuge"
                  HELP "Entre com o nome do conjuge."
     SKIP
     tel_nrcepend      AT  4 LABEL "CEP" FORMAT "99999,999" 
                       HELP "Entre com o CEP ou pressione F7 para pesquisar"
                                      
     tel_dsendere      AT 22 LABEL "End.Residencial"        AUTO-RETURN
     SKIP
     tel_nrendere      AT  3 LABEL "Nro."        AUTO-RETURN
                             HELP "Informe o numero da residencia."
                             
     tel_complend      AT 26 LABEL "Complemento" AUTO-RETURN
                             HELP "Informe o complemento do endereco."
     SKIP
     tel_nmbairro      AT  1 LABEL "Bairro"  AUTO-RETURN

     tel_nrcxapst      AT 50 LABEL "Cxa Postal"
     SKIP
     tel_nmcidade      AT 1 LABEL "Cidade"  AUTO-RETURN
                                      
     tel_cdufende      AT 50 LABEL "UF"      AUTO-RETURN
     SKIP
     tel_cdempres LIKE crapttl.cdempres  FORMAT "zzzz9" AT  1 
                       LABEL "Empresa"  AUTO-RETURN
                    HELP "Informe o codigo da empresa ou tecle F7 para listar"
     "-"
     tel_nmresemp            NO-LABEL
     tel_nrcadast LIKE crapass.nrcadast  AT 31 LABEL "Cad.Emp"  AUTO-RETURN
                  HELP "Entre com o numero do cadastro/dv do associado."
     tel_cdocpttl LIKE crapttl.cdocpttl  AT 51 LABEL "Ocupacao"
     HELP "Informe o codigo de ocupacao do cooperado ou tecle F7 para listar"
     "-" SPACE(0)   
     tel_dsocpttl            NO-LABEL         AUTO-RETURN
     SKIP
     tel_dtadmiss LIKE crapass.dtadmiss  AT  1 LABEL "Admissao Coop"  
                                         FORMAT "99/99/9999"
     tel_dtdemiss LIKE crapass.dtdemiss  AT 27 LABEL "Saida Coop" 
                                         FORMAT "99/99/9999"
                  HELP "Entre com a data de demissao do associado."
     tel_cdmotdem LIKE crapass.cdmotdem  AT 50 LABEL "Motivo"  FORMAT "Z9" 
                  HELP "Entre com o codigo do motivo ou tecle F7 para listar"
     tel_dsmotdem            NO-LABEL
     WITH SIDE-LABELS TITLE glb_tldatela ROW 4 COLUMN 1 OVERLAY WIDTH 80 
          FRAME f_matric.

FORM glb_cddopcao      AT  1 LABEL "Opcao"    AUTO-RETURN
                       HELP "Informe a opcao desejada (A, C, D, I, R, X ou J)"
                       VALIDATE (CAN-DO("A,C,D,I,R,X,J",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_nrdconta      AT 14 LABEL "Conta/Dv" AUTO-RETURN
            HELP "Informe o numero da conta do cooperado"

     tel_cdagenci AT 37 LABEL "PA" AUTO-RETURN
     "-"               
     tel_dsagenci            NO-LABEL
     tel_nrmatric AT 63 LABEL "Matr."
     SKIP
     tel_inpessoa AT  1 LABEL "Tp.Nat."
                             HELP "Tipo de pessoa: 1 - fisica, 2 - juridica"
     tel_dspessoa            NO-LABEL
     tel_nmprimtl AT 21 LABEL "Nome"  
                             AUTO-RETURN FORMAT "x(50)"
                             HELP "Informe a razao social"
     SKIP
     tel_nmfansia      AT  1 LABEL "Nome Fantasia"             FORMAT "x(40)"
                             HELP "Entre com o nome fantasia da empresa"
     SKIP
     tel_nrcpfcgc      AT  1 LABEL "C.N.P.J."      AUTO-RETURN
                             HELP "Informe o CNPJ da empresa"
     tel_dtcnscpf AT 32 LABEL "Consulta" AUTO-RETURN
                  HELP "Entre com a data de consulta do CPF."
     tel_cdsitcpf AT 54 LABEL "Situacao" AUTO-RETURN
         HELP "Entre com a situacao do CPF (1=Reg.,2=Pend.,3=Cancel.,4=Irreg.)"
     tel_dssitcpf            NO-LABEL
     SKIP
     tel_insestad      AT  1 LABEL "Inscricao Estadual"
     HELP "Informe a inscricao estadual ou TUDO ZEROS para Isento"

     tel_natjurid      AT 38 LABEL "Natureza Juridica"
         HELP "Entre com o codigo da natureza juridica ou tecle F7 para listar"
     tel_dsnatjur            NO-LABEL 

     tel_dtiniatv      AT  1 LABEL "Inicio Atividade"
                             HELP "Informe a data de inicio da atividade"
                             
     tel_cdseteco      AT 31 LABEL "Setor Economico" 
                       HELP "Informe o setor economico ou tecle F7 para listar"

     tel_nmseteco      NO-LABEL FORMAT "x(20)"
     SKIP
     tel_cdrmativ      AT  3 LABEL "Ramo"  FORMAT "zz9"
                       HELP "Informe o ramo atividade ou tecle F7 para listar"

     tel_dsrmativ      NO-LABEL FORMAT "x(30)"
     tel_nrdddtfc      AT 48 LABEL "DDD"
                                      
     tel_nrtelefo            LABEL "Telefone"

     SKIP(1)
     tel_nrcepend      AT  4 LABEL "CEP"  FORMAT "99999,999"  
                       HELP "Entre com o CEP ou pressione F7 para pesquisar"

     tel_dsendere      AT 22 LABEL "End.Comercial"             AUTO-RETURN
                             HELP "Entre com o endereco da empresa"
     SKIP
     tel_nrendere      AT  3 LABEL "Nro."                      AUTO-RETURN
                             HELP "Informe o numero do endereco."
     tel_complend      AT 24 LABEL "Complemento"               AUTO-RETURN
                             HELP "Informe o complemento do endereco."     
     SKIP
     tel_nmbairro      AT  1 LABEL "Bairro"                    AUTO-RETURN
     tel_nrcxapst      AT 50 LABEL "Cxa Postal" HELP "Informe a caixa postal."
     SKIP
     tel_nmcidade      AT 1  LABEL "Cidade"                    AUTO-RETURN
     tel_cdufende      AT 50 LABEL "UF"                        AUTO-RETURN
     SKIP(1)
     tel_dtadmiss AT  1 LABEL "Admissao Coop"  FORMAT "99/99/9999"
     tel_dtdemiss AT 27 LABEL "Saida Coop"     FORMAT "99/99/9999" AUTO-RETURN 
                        HELP "Entre com a data de demissao do associado."
     tel_cdmotdem AT 50 LABEL "Motivo"         FORMAT "Z9" AUTO-RETURN
             HELP "Entre com o codigo do motivo ou tecle F7 para listar"
     tel_dsmotdem            NO-LABEL
     SKIP(2)
     WITH NO-BOX SIDE-LABELS ROW 5 COLUMN 2 OVERLAY FRAME f_matric_juridica.
     

FORM shr_ocupacao_pesq LABEL "Ocupacao"
     WITH ROW 9  COLUMN 15   OVERLAY SIDE-LABELS  TITLE
     "PESQUISA OCUPACAO"  FRAME f_pesq_ocupacao.


/*............................................................................*/


