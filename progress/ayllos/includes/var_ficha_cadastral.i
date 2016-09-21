/* ..........................................................................

   Programa: includes/var_ficha_cadastral.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo          
   Data    : Junho/2006                        Ultima atualizacao: 24/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis compartilhadas e forms para FICHA CADASTRAL.

   Alteracoes: 08/08/2006 - Alterada a var tel_dtvalida para tipo CHAR (David).
   
               09/01/2007 - Criado o FORM do item "RESPONSAVEL LEGAL" e o item
                            "DEPENDENTES" para a pessoa fisica (Evandro).
                            
               30/01/2007 - Incluidas variaveis utilizadas no Conjuge (Diego).
               
               20/03/2007 - Alterado formato do campo crapcem.dsdemail para 35
                            caracteres (Elton).
               
               26/03/2007 - Incluido campo "Secao" nos dados comerciais (Elton).

               31/07/2007 - Aumentado o tamanho do e-mail para 40 caracteres
                            (Evandro).
                            
               18/03/2009 - Alteracao cdempres (Kbase IT).

               18/06/2009 - Extender tel_dstipren para 6, re-arrumar
                            form para contemplar 4 rendimentos, apresentar
                            os bens do cooperado (Gabriel). 

               31/07/2009 - Incluido campo crapjfn.perfatcl no frame 
                            f_registro_pj (Fernando).
                            
               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).
               
               27/04/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
               
               28/07/2010 - Corrigir FORMAT do campo cdgraupr (David).
               
               15/12/2010 - Alteracao FORMAT nmprimtl (Kbase - Gilnei).
               
               02/05/2011 - Aumentar formato do bairro e cidade.
                            Retirar variaveis nao utilizadas (Gabriel).
                            
               18/08/2011 - Adicionado campos Apto e Bloco na parte de 
                            ENDERECO. (Jorge)
                            
               03/04/2012 - Alterado labels de endereco em FICHA CADASTRAL. 
                            (Jorge)
                            
               25/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
               25/04/2013 - Incluir tt-fcad-psfis.cdufnatu no frame f_dados_pf
                            (Lucas R.)
              
               02/07/2013 - Inclusao de poderes de Representantes/Procuradores
                            (Jean Michel)
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               16/12/2013 - Alterado form f_responsa de "CPF/CGC" para 
                            "CPF/CNPJ". (Reinert)
                            
               24/05/2014 - Ajuste em format em Endereco eletronico.(Jorge)
               
               07/10/2014 - Remoção do Endividamento e dos Bens dos representantes
                            por caracterizar quebra de sigilo bancário (Dionathan)
                            
               05/08/2015 - Projeto 217 - Reformulacao cadastral
                            (Tiago Castro - RKAM).
                            
               24/08/2015 - Reformulacao cadastral (Gabriel-RKAM).             
                            
............................................................................. */
{ sistema/generico/includes/b1wgen0062tt.i }

DEF STREAM str_1.

DEF BUFFER crabass FOR crapass.

DEF {1} SHARED VAR aux_tipconsu AS LOGI FORMAT "Visualizar/Imprimir"   NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR 


                   INNER-CHARS 78 INNER-LINES 8 LARGE PFCOLOR 0        NO-UNDO.

DEF VAR aux_nrcoluna AS INT                                            NO-UNDO.

DEF VAR edi_ficha   AS CHAR VIEW-AS EDITOR SIZE 78 BY 15 PFCOLOR 0.     

DEF VAR aux_dsoutpo1 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsoutpo2 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsoutpo3 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsoutpo4 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsoutpo5 AS CHAR                                         NO-UNDO.

DEF FRAME fra_ficha 
    edi_ficha  HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 78 BY 15 ROW 6 COLUMN 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.

/*** Frames para montagem da ficha ***/

FORM HEADER
     "PAG:"            AT  74
     PAGE-NUMBER(str_1)       AT  78 FORMAT "zz9"
     WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_paginacao.

FORM 
"+--------------------------------------------------------------------------+"
"|" SPACE(0) tt-fcad.nmextcop  AT 02 NO-LABEL FORMAT "x(50)"  "|" AT 76
"|                                                                          |"
"|" SPACE(0) tt-fcad.nrdconta  AT 02 LABEL "CONTA/DV" FORMAT "X(10)"
     tt-fcad.dsagenci          AT 33 LABEL "PA" FORMAT "x(20)" 
     tt-fcad.nrmatric    AT 58 LABEL "MATRICULA" FORMAT "X(7)"    SPACE(0) "|"
     SKIP
"|                                                                          |"
"|" "FICHA CADASTRAL" AT 31              "|" AT 76
"+--------------------------------------------------------------------------+"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_identi.
 
FORM SKIP(1)
     tt-fcad.dsmvtolt      AT 01 NO-LABEL FORMAT "x(30)"
     SKIP(2)
     "__________________________________________________"
     SKIP
     tt-fcad.nmprimtl            NO-LABEL FORMAT "x(50)"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_cadast.

FORM "RESPONSABILIZO-ME PELA EXATIDAO DAS INFORMACOES PRESTADAS, A VISTA"
                "DOS ORI-" SKIP
     "GINAIS DO DOCUMENTO DE  IDENTIDADE, DO CPF/CNPJ,  E DE OUTROS"
     "COMPROBATORIOS" SKIP
     "DOS DEMAIS  ELEMENTOS DE INFORMACAO APRESENTADOS, SOB  PENA DE APLICACAO" 
     "DO" SKIP
     "DISPOSTO NO ARTIGO 64 DA LEI NUMERO 8.383 DE 30/12/1991." 
     SKIP(3)
     "____/_____/_____  ___________________________ " 
     "____________________________"  SKIP
     "      DATA           GERENTE/COORDENADOR" 
     tt-fcad.dsoperad AT 50 NO-LABEL FORMAT "x(27)"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_responsa.

     
FORM  "----------------------------------------------------------------------------"
      SKIP
      "TELEFONES"      AT 35                    
      SKIP
"----------------------------------------------------------------------------"
      SKIP
 "Operadora    DDD   Telefone Ramal Identificacao Setor    Pessoa de Contato"
      SKIP
      WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                  FRAME f_titulo_telefones.
     
FORM tt-fcad-telef.dsopetfn  AT 01 FORMAT "x(12)"
     tt-fcad-telef.nrdddtfc  AT 14 FORMAT "999"  
     tt-fcad-telef.nrtelefo  AT 18 FORMAT "zzzzzzzzz9"           
     tt-fcad-telef.nrdramal  AT 30 FORMAT "zzzz"
     tt-fcad-telef.tptelefo  AT 35 FORMAT "x(11)"
     tt-fcad-telef.secpscto  AT 49 FORMAT "x(08)"
     tt-fcad-telef.nmpescto  AT 58 FORMAT "x(18)"
     WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76
                 FRAME f_telefones.

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "E-MAILS"        AT 35           
     SKIP
"----------------------------------------------------------------------------"
     SKIP
"Endereco eletronico                              Setor   Pessoa de Contato  "
     SKIP
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                              FRAME f_titulo_emails.

FORM tt-fcad-email.dsdemail  AT 01 FORMAT "x(46)"
     tt-fcad-email.secpscto  AT 48 FORMAT "x(08)"
     tt-fcad-email.nmpescto  AT 57 FORMAT "x(20)"
     SKIP
     WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76
                 FRAME f_emails.

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "ENDERECO"       AT 34
     SKIP
"----------------------------------------------------------------------------"
     SKIP
     tt-fcad.incasprp  AT 08 LABEL "Tipo do Imovel"   FORMAT "9"
     tt-fcad.dscasprp        NO-LABEL                 FORMAT "x(07)"      
     tt-fcad.vlalugue  AT 39 LABEL "Valor do Imovel"  FORMAT "zzz,zzz,zz9.99"
     tt-fcad.dtabrres  AT 02 LABEL "Inicio de Residencia" FORMAT "x(7)"
     tt-fcad.dstemres  AT 38 LABEL "Tempo Residencia" FORMAT "x(20)" 
     SKIP(1)
     tt-fcad.nrcepend  AT 04 LABEL "CEP"              FORMAT "X(9)"
     tt-fcad.dsendere  AT 24 LABEL "Endereco"         FORMAT "x(40)"
     tt-fcad.nrendere  AT 03 LABEL "Nro."             FORMAT "zzz,zz9"
     tt-fcad.complend  AT 21 LABEL "Complemento"      FORMAT "x(40)"
     tt-fcad.nrdoapto  AT 03 LABEL "Apto"             FORMAT "zzz,zz9"
     tt-fcad.cddbloco  AT 27 LABEL "Bloco"            FORMAT "x(3)"
     tt-fcad.nmbairro  AT 01 LABEL "Bairro"           FORMAT "x(40)"
     tt-fcad.nrcxapst  AT 52 LABEL "Cx.Postal"        FORMAT "zzzzz,zz9"
     SKIP
     tt-fcad.nmcidade  AT 01 LABEL "Cidade"       FORMAT "x(25)"
     tt-fcad.cdufende  AT 59 LABEL "UF"           FORMAT "!!"
     SKIP(1)                                              
     WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                      FRAME f_endereco.


FORM "Aguarde... Imprimindo ficha cadastral"
     WITH ROW 14 CENTERED OVERLAY /*ATTR-SPACE*/ FRAME f_aguarde.


/******************************************************************************/
/***********************  P E S S O A    F I S I C A  *************************/
/******************************************************************************/

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "IDENTIFICACAO"  AT 32  
     SKIP
"----------------------------------------------------------------------------"
     SKIP
     tt-fcad-psfis.nmextttl       NO-LABEL                   FORMAT "x(76)"      
     SKIP                                                    
     tt-fcad-psfis.inpessoa AT  1 LABEL "Tp.Natureza"        FORMAT "9"        
     "-"                                                     
     tt-fcad-psfis.dspessoa       NO-LABEL                   FORMAT "X(8)"       
     SKIP                                                    
     tt-fcad-psfis.nrcpfcgc AT  6 LABEL "C.P.F."             FORMAT "X(18)"
     tt-fcad-psfis.dtcnscpf AT 50 LABEL "Consulta"           FORMAT "99/99/9999" 
     SKIP                                                    
     tt-fcad-psfis.cdsitcpf AT 50 LABEL "Situacao"           FORMAT "9"
     tt-fcad-psfis.dssitcpf       NO-LABEL                   FORMAT "x(11)"   
     SKIP(1)                                                 
     tt-fcad-psfis.tpdocttl AT  3 LABEL "Documento"          FORMAT "XX"
     tt-fcad-psfis.nrdocttl       NO-LABEL                   FORMAT "x(11)"
     tt-fcad-psfis.cdoedttl AT 33 LABEL "Org.Emi."           FORMAT "x(5)"
     tt-fcad-psfis.cdufdttl AT 54 LABEL "U.F."               FORMAT "!!"        
     SKIP                                                    
     tt-fcad-psfis.dtemdttl AT 49 LABEL "Data Emi."          FORMAT "99/99/9999" 
     SKIP(1)
     tt-fcad-psfis.dtnasttl AT  4 LABEL "Data Nascimento"    FORMAT "99/99/9999"
     tt-fcad-psfis.cdsexotl AT 54 LABEL "Sexo"               FORMAT "!" 
     SKIP
     tt-fcad-psfis.tpnacion AT  1 LABEL "Tipo Nacionalidade" FORMAT "9"
     tt-fcad-psfis.restpnac       NO-LABEL                   FORMAT "X(15)" 
     tt-fcad-psfis.dsnacion AT 45 LABEL "Nacionalidade"      FORMAT "x(15)" 
     SKIP
     tt-fcad-psfis.dsnatura AT  9 LABEL "Natural De"         FORMAT "x(25)" 
     tt-fcad-psfis.cdufnatu AT 55 LABEL "U.F"
     SKIP
     tt-fcad-psfis.inhabmen AT  2 LABEL "Habilitacao Menor"  FORMAT "9"
     tt-fcad-psfis.dshabmen       NO-LABEL                   FORMAT "x(16)"
     tt-fcad-psfis.dthabmen AT 42 LABEL "Data Emancipacao"
     tt-fcad-psfis.cdgraupr AT  3 LABEL "Relacionamento com o 1 titular" 
                                                             FORMAT "9"
     tt-fcad-psfis.dsgraupr       NO-LABEL                   FORMAT "x(14)"
     SKIP(1)
     tt-fcad-psfis.cdestcvl AT  7 LABEL "Est.Civil"          FORMAT "z9"
     tt-fcad-psfis.dsestcvl       NO-LABEL                   FORMAT "x(15)"
     tt-fcad-psfis.grescola AT 37 LABEL "Escolaridade"       FORMAT "z9"
     tt-fcad-psfis.dsescola       NO-LABEL                   FORMAT "x(12)"
     SKIP
     tt-fcad-psfis.cdfrmttl AT  2 LABEL "Curso Superior"     FORMAT "zz9"
     tt-fcad-psfis.rsfrmttl       NO-LABEL                   FORMAT "x(15)"
     tt-fcad-psfis.nrcertif AT 38 LABEL "Certificado"        FORMAT "x(20)"
     SKIP
     tt-fcad-psfis.nmtalttl AT 6  LABEL "Nome Talao"         FORMAT "x(40)"
     SKIP
     tt-fcad-psfis.qtfoltal AT 1  LABEL "Qtd. Folhas Talao"  FORMAT "z9"
     SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_dados_pf.

FORM  
"----------------------------------------------------------------------------"
     SKIP
     "FILIACAO"  AT 34
     SKIP
"----------------------------------------------------------------------------"
     SKIP
     tt-fcad-filia.nmmaettl  AT  2 LABEL "Nome da Mae" FORMAT "X(40)" SKIP(1)
     tt-fcad-filia.nmpaittl  AT  2 LABEL "Nome do Pai" FORMAT "X(40)" SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_filiacao_pf.


FORM 
"----------------------------------------------------------------------------"
     SKIP
     "COMERCIAL"  AT 34
     SKIP
"----------------------------------------------------------------------------"
     SKIP
     tt-fcad-comer.cdnatopc  AT  1  LABEL "Nat.Ocupacao" FORMAT "z9"
     tt-fcad-comer.rsnatocp         NO-LABEL             FORMAT "x(15)"
     tt-fcad-comer.cdocpttl  AT 48  LABEL "Ocupacao"     FORMAT "zz9"
     tt-fcad-comer.rsocupa          NO-LABEL             FORMAT "x(15)" 
     SKIP
     tt-fcad-comer.tpcttrab  AT  1  LABEL "Tp.Ctr.Trab." FORMAT "9"
     tt-fcad-comer.dsctrtab         NO-LABEL             FORMAT "x(15)" 
     SKIP
     tt-fcad-comer.cdempres  AT  6  LABEL "Empresa"      FORMAT "zzzz9"
     tt-fcad-comer.nmresemp         NO-LABEL             FORMAT "x(15)"
     tt-fcad-comer.nmextemp  AT 37  LABEL "Nome empresa" FORMAT "x(25)"
     SKIP
     tt-fcad-comer.nrcgcemp  AT 5   LABEL "C.N.P.J."     FORMAT "x(20)"
     SKIP
     tt-fcad-comer.dsproftl  AT  8  LABEL "Cargo"        FORMAT "x(20)"
     tt-fcad-comer.cdnvlcgo  AT 36  LABEL "Nivel Cargo"  FORMAT "9"
     tt-fcad-comer.rsnvlcgo         NO-LABEL             FORMAT "x(10)"
     SKIP(1)
     tt-fcad-comer.nrcepend  AT  4  LABEL "CEP"          FORMAT "X(9)"
     tt-fcad-comer.dsendere  AT 23  LABEL "Endereco"     FORMAT "x(40)"
     SKIP
     tt-fcad-comer.nrendere  AT  3  LABEL "Nro."         FORMAT "zzz,zz9"
     tt-fcad-comer.complend  AT 20  LABEL "Complemento"  FORMAT "x(40)"
     SKIP
     tt-fcad-comer.nmbairro  AT  1  LABEL "Bairro"       FORMAT "x(40)"
     tt-fcad-comer.nrcxapst  AT 52  LABEL "Cx.Postal"    FORMAT "zzzzz,zz9"
     SKIP
     tt-fcad-comer.nmcidade  AT  1  LABEL "Cidade"       FORMAT "x(25)"
     tt-fcad-comer.cdufende  AT 59  LABEL "UF"           FORMAT "!!"  
     SKIP
     tt-fcad-comer.cdturnos  AT  2  LABEL "Turno"        FORMAT "z9"
     tt-fcad-comer.dtadmemp  AT 23  LABEL "Admissao"     FORMAT "99/99/9999"
     tt-fcad-comer.vlsalari  AT 55  LABEL "Rendimento"   FORMAT "zzz,zz9.99"
      SKIP(1)
     "Outros Rendimentos - Origem:"
     tt-fcad-comer.tpdrend1  AT 30  NO-LABEL             FORMAT "z9"
     "-"
     tt-fcad-comer.dstipre1         NO-LABEL             FORMAT "x(20)"
     tt-fcad-comer.vldrend1  AT 60  LABEL "Valor"        FORMAT "zzz,zz9.99"
     tt-fcad-comer.tpdrend2  AT 30  NO-LABEL             FORMAT "z9"
     "-"
     tt-fcad-comer.dstipre2         NO-LABEL             FORMAT "x(20)"
     tt-fcad-comer.vldrend2  AT 60  LABEL "Valor"        FORMAT "zzz,zz9.99"
     tt-fcad-comer.tpdrend3  AT 30  NO-LABEL             FORMAT "z9"
     "-"                                                 
     tt-fcad-comer.dstipre3         NO-LABEL             FORMAT "x(20)"
     tt-fcad-comer.vldrend3  AT 60  LABEL "Valor"        FORMAT "zzz,zz9.99"
     tt-fcad-comer.tpdrend4  AT 30  NO-LABEL             FORMAT "z9"
     "-"                                                 
     tt-fcad-comer.dstipre4         NO-LABEL             FORMAT "x(20)"
     tt-fcad-comer.vldrend4  AT 60  LABEL "Valor"        FORMAT "zzz,zz9.99"
     SKIP(1)   
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_comercial_pf.

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "CONTATOS"  AT 34
     SKIP
"----------------------------------------------------------------------------"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
          FRAME f_titulo_contatos_pf.

FORM tt-fcad-ctato.nrdctato       LABEL "Conta/dv"     FORMAT "X(10)"
     tt-fcad-ctato.nmdavali       LABEL "   Nome"      FORMAT "x(40)"  SKIP(1)
     tt-fcad-ctato.nrcepend       LABEL "   CEP"       FORMAT "x(9)"
     tt-fcad-ctato.dsendere AT 23 LABEL "Endereco"     FORMAT "x(40)"  SKIP
     tt-fcad-ctato.nrendere       LABEL "  Nro."       FORMAT "zzz,zz9"
     tt-fcad-ctato.complend AT 20 LABEL "Complemento"  FORMAT "x(40)"  SKIP
     tt-fcad-ctato.nmbairro AT 01 LABEL "Bairro"       FORMAT "x(40)"    
     tt-fcad-ctato.nrcxapst AT 52 LABEL "Cx.Postal"    FORMAT "zzzzz,zz9"
     SKIP                                                                
     tt-fcad-ctato.nmcidade AT 01 LABEL "Cidade"       FORMAT "x(25)"    
     tt-fcad-ctato.cdufende AT 59 LABEL "UF"           FORMAT "!!"       
     SKIP(1)
     tt-fcad-ctato.nrtelefo       LABEL "Telefones"    FORMAT "x(20)"  SKIP
     tt-fcad-ctato.dsdemail AT 04 LABEL "E_Mail"       FORMAT "x(40)"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_contatos_pf.

FORM  
"----------------------------------------------------------------------------"
     SKIP
     "CONJUGE"  AT 35
     SKIP
"----------------------------------------------------------------------------"
     SKIP
     tt-fcad-cjuge.nrctacje AT  2 LABEL "Conta/DV"      FORMAT "X(10)"
     tt-fcad-cjuge.nmconjug AT 31 LABEL "Nome"   
     tt-fcad-cjuge.nrcpfcje AT  4 LABEL "C.P.F."        FORMAT "X(18)"
     tt-fcad-cjuge.dtnasccj AT 48 LABEL "Data Nascimento"             SKIP
     tt-fcad-cjuge.tpdoccje       LABEL "Documento"  
     tt-fcad-cjuge.nrdoccje       NO-LABEL 
     tt-fcad-cjuge.cdoedcje       LABEL "Org.Emi." 
     " U.F.:"              
     tt-fcad-cjuge.cdufdcje       NO-LABEL 
     " Data Emi.:" 
     tt-fcad-cjuge.dtemdcje       NO-LABEL SKIP(1)
     tt-fcad-cjuge.gresccje       LABEL "Escolaridade"   
     tt-fcad-cjuge.dsescola       NO-LABEL             FORMAT "x(12)" SPACE(4)
     tt-fcad-cjuge.cdfrmttl       LABEL "Curso Superior" 
     tt-fcad-cjuge.rsfrmttl       NO-LABEL             FORMAT "x(15)"
     tt-fcad-cjuge.cdnatopc       LABEL "Nat.Ocupacao"
     tt-fcad-cjuge.rsnatocp       NO-LABEL             FORMAT "x(15)" SPACE(10)
     tt-fcad-cjuge.cdocpttl
     tt-fcad-cjuge.rsocupa        NO-LABEL             FORMAT "x(15)" SKIP(1)
     tt-fcad-cjuge.tpcttrab       LABEL "Tp.Ctr.Trab."
     tt-fcad-cjuge.dsctrtab       NO-LABEL             FORMAT "x(15)" SKIP
     tt-fcad-cjuge.nmextemp AT  6
     tt-fcad-cjuge.nrcpfemp AT 53 LABEL "CNPJ"                        SKIP
     tt-fcad-cjuge.dsproftl AT  8 LABEL "Cargo"
     tt-fcad-cjuge.cdnvlcgo AT 46 LABEL "Nivel Cargo"
     tt-fcad-cjuge.rsnvlcgo       NO-LABEL                            SKIP
     tt-fcad-cjuge.nrfonemp       LABEL "Tel.Comercial" 
     tt-fcad-cjuge.nrramemp AT 52 LABEL "Ramal"                       SKIP
     tt-fcad-cjuge.cdturnos AT  9
     tt-fcad-cjuge.dtadmemp AT 22
     tt-fcad-cjuge.vlsalari AT 47 LABEL "Rendimento" FORMAT "zzz,zz9.99" SKIP(2)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_conjuge_pf.

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "RESPONSAVEL LEGAL"  AT 30
     SKIP
"----------------------------------------------------------------------------"
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
          FRAME f_titulo_responsavel_pf.

FORM tt-fcad-respl.nrdconta AT  1  LABEL " Conta/dv" FORMAT "X(10)"
     tt-fcad-respl.nrcpfcgc AT 30  LABEL "   C.P.F." FORMAT "X(18)" SKIP
     tt-fcad-respl.nmrespon AT  5  LABEL " Nome"                    SKIP
     tt-fcad-respl.tpdeiden AT  1  LABEL "Documento"
     tt-fcad-respl.nridenti        NO-LABEL
     tt-fcad-respl.dsorgemi AT 31  LABEL "Org.Emi."  FORMAT "x(5)"
     tt-fcad-respl.cdufiden AT 49  LABEL "U.F."                     SKIP
     tt-fcad-respl.dtemiden AT 44  LABEL "Data Emi."                SKIP(1)
     tt-fcad-respl.dtnascin AT  1  LABEL "Data Nascimento"
     tt-fcad-respl.cddosexo AT 31  LABEL "Sexo"      FORMAT "!"
     tt-fcad-respl.cdestciv        LABEL "  Estado Civil" 
     tt-fcad-respl.dsestciv        NO-LABEL          FORMAT "x(19)"
     tt-fcad-respl.dsnacion AT  3  LABEL "Nacionalidade"            SKIP
     tt-fcad-respl.dsnatura AT  6  LABEL "Natural de"               SKIP(1)
     tt-fcad-respl.cdcepres AT  4  LABEL "CEP"       FORMAT "x(9)"
     tt-fcad-respl.dsendres AT 20  LABEL "End.Residencial"          SKIP
     tt-fcad-respl.nrendres AT  3  LABEL "Nro."
     tt-fcad-respl.dscomres AT 24  LABEL "Complemento"              SKIP

     tt-fcad-respl.dsbaires AT  1  LABEL "Bairro"    FORMAT "x(40)"           
     tt-fcad-respl.nrcxpost AT 52  LABEL "Cx.Postal" FORMAT "zzzzz,zz9" 
     SKIP
     tt-fcad-respl.dscidres AT 01  LABEL "Cidade"    FORMAT "x(25)"
     tt-fcad-respl.dsdufres AT 59  LABEL "UF"        FORMAT "!!"
     SKIP(1)
     "Filiacao:"
     tt-fcad-respl.nmmaersp AT 11  LABEL "Mae"                      SKIP
     tt-fcad-respl.nmpairsp AT 11  LABEL "Pai"                      SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
          FRAME f_responsavel_pf.

FORM 
"----------------------------------------------------------------------------"
     SKIP
     "DEPENDENTES"        AT 35           
     SKIP
"----------------------------------------------------------------------------"
     SKIP
"Nome                                     Data Nasc.      Tipo Dependente"
     SKIP
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                              FRAME f_titulo_dependentes_pf.

FORM tt-fcad-depen.nmdepend FORMAT "X(40)"
     tt-fcad-depen.dtnascto FORMAT "99/99/9999" SPACE(6)
     tt-fcad-depen.tpdepend FORMAT ">9" "-"
     tt-fcad-depen.dstextab FORMAT "x(14)"
     WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76
                 FRAME f_dependentes_pf.

FORM  
"----------------------------------------------------------------------------"
      SKIP
      "REPRESENTANTE / PROCURADOR"  AT 25  
      SKIP
"----------------------------------------------------------------------------"
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                                    FRAME f_titulo_procuradores_pf.


FORM tt-fcad-procu.nrdctato AT 02 LABEL  "Conta/dv"        FORMAT "zzzz,zzz,9"
     tt-fcad-procu.nrcpfcgc AT 51 LABEL  "C.P.F."          FORMAT "x(18)" 
     SKIP
     tt-fcad-procu.nmdavali AT 06 LABEL "Nome"             FORMAT "x(40)" 
     SKIP
     tt-fcad-procu.tpdocava       LABEL "Documento"        FORMAT "x(2)"
     tt-fcad-procu.nrdocava       NO-LABEL                 FORMAT "x(15)"
     tt-fcad-procu.cdoeddoc       LABEL "Org.Emi."         FORMAT "x(05)"
     tt-fcad-procu.cdufddoc       LABEL "UF"               FORMAT "!(02)"
     tt-fcad-procu.dtemddoc       LABEL "Data Emi."        FORMAT "99/99/9999" 
     SKIP
     tt-fcad-procu.dtnascto AT  1 LABEL "Data Nascimento"  FORMAT "99/99/9999"
     tt-fcad-procu.inhabmen AT 31 LABEL "Responsab. Legal" FORMAT "9"
     tt-fcad-procu.dshabmen       NO-LABEL                 FORMAT "x(13)"
     tt-fcad-procu.dthabmen       LABEL "Data Emancipacao" FORMAT "99/99/9999" 
     tt-fcad-procu.cdsexcto AT 33 LABEL "Sexo"             FORMAT "!"
     tt-fcad-procu.dsestcvl AT 46 LABEL "Estado Civil"     FORMAT "x(12)" 
     SKIP
     tt-fcad-procu.dsnacion AT 03 LABEL "Nacionalidade"    FORMAT "x(15)"
     tt-fcad-procu.dsnatura AT 37 LABEL "Natural de"       FORMAT "x(25)" 
     SKIP(1)
     tt-fcad-procu.nrcepend AT 04 LABEL "CEP"              FORMAT "x(9)" 
     tt-fcad-procu.dsendere AT 20 LABEL "End.Residencial"  FORMAT "x(40)" 
     SKIP
     tt-fcad-procu.nrendere AT 03 LABEL "Nro."             FORMAT "zzz,zz9"
     tt-fcad-procu.complend AT 24 LABEL "Complemento"      FORMAT "x(40)" 
     SKIP
     tt-fcad-procu.nmbairro AT 01 LABEL "Bairro"           FORMAT "x(40)"
     tt-fcad-procu.nrcxapst AT 52 LABEL "Cx.Postal"        FORMAT "zzzzzzz9" 
     SKIP
     tt-fcad-procu.nmcidade AT 01 LABEL "Cidade"           FORMAT "x(25)"
     tt-fcad-procu.cdufende AT 59 LABEL "UF"               FORMAT "!(02)"
     tt-fcad-procu.nmmaecto AT 01 LABEL "Filiacao: Mae"    FORMAT "x(40)" 
     SKIP
     tt-fcad-procu.nmpaicto AT 11 LABEL "Pai"              FORMAT "x(40)" 
     SKIP(1)
     /*tt-fcad-procu.vledvmto AT 01 LABEL "Endividamento"    FORMAT "zzz,zzz,zz9.99"*/
     tt-fcad-procu.dtvalida AT 01 LABEL "Vigencia"         FORMAT "x(13)"
     SKIP(1)
     WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                      FRAME f_procuradores_pf.


/******************************************************************************/
/********************** P E S S O A    J U R I D I C A ************************/
/******************************************************************************/

FORM  
"----------------------------------------------------------------------------"
      SKIP
      "IDENTIFICACAO"  AT 32  
      SKIP
"----------------------------------------------------------------------------"
      SKIP
      "Razao  Social:"     
      tt-fcad-psjur.nmprimtl       NO-LABEL                  FORMAT "x(50)" 
      SKIP                                                   
      tt-fcad-psjur.inpessoa       LABEL "Tipo Natureza"     FORMAT "9"
      "-"
      tt-fcad-psjur.dspessoa       NO-LABEL                  FORMAT "x(8)"  
      SKIP
      tt-fcad-psjur.nmfansia       LABEL "Nome Fantasia"     FORMAT "x(40)" 
      SKIP 
      "C.N.P.J.: "           AT 06
      tt-fcad-psjur.nrcpfcgc       NO-LABEL                  FORMAT "x(20)"
      " Consulta:"           AT 53
      tt-fcad-psjur.dtcnscpf       NO-LABEL                  FORMAT "99/99/9999" 
      SKIP
      " Situacao:"           AT 53
      tt-fcad-psjur.cdsitcpf       NO-LABEL                  FORMAT "9"
      tt-fcad-psjur.dssitcpf       NO-LABEL                  FORMAT "x(11)" 
      SKIP(1)
      tt-fcad-psjur.natjurid       LABEL "Natureza Juridica" FORMAT "zzz9"
      "-"
      tt-fcad-psjur.dsnatjur       NO-LABEL                  FORMAT "x(30)" 
      SKIP
      tt-fcad-psjur.qtfilial AT 06 LABEL "Qtd. Filiais"      FORMAT "zz9"           
      tt-fcad-psjur.qtfuncio AT 45 LABEL "Qtd. Funcionarios" FORMAT "zzz,zz9" 
      SKIP
      tt-fcad-psjur.dtiniatv AT 02 LABEL "Inicio Atividade"  
                                   FORMAT "99/99/9999"
      SKIP
      tt-fcad-psjur.cdseteco AT 03 LABEL "Setor Economico"   FORMAT "9"
      "-"
      tt-fcad-psjur.nmseteco       NO-LABEL                  FORMAT "x(20)" 
      SKIP
      tt-fcad-psjur.cdrmativ AT 04 LABEL "Ramo Atividade"    FORMAT "zz9"         
      "-"
      tt-fcad-psjur.dsrmativ AT 26 NO-LABEL                  FORMAT "x(30)" 
      SKIP(1)
      tt-fcad-psjur.dsendweb AT 01 LABEL "Endereco na Internet(Site)" 
                                   FORMAT "x(40)"
      SKIP
      tt-fcad-psjur.nmtalttl AT  1 LABEL "Nome Talao"        FORMAT "x(40)"
      tt-fcad-psjur.qtfoltal AT 53 LABEL "Qtd. Folhas Talao" 
                                   FORMAT "99" SKIP(1)
      WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_dados_pj.
 
FORM  
"----------------------------------------------------------------------------"
      SKIP
      "REGISTRO"       AT 35
      SKIP
"----------------------------------------------------------------------------"
      SKIP
      tt-fcad-regis.vlfatano AT 05 LABEL  "Faturamento Ano"
                                   FORMAT "zzz,zzz,zz9.99-"
      tt-fcad-regis.vlcaprea AT 44 LABEL  "Capital Realizado"
                                   FORMAT "zzz,zzz,zz9.99" SKIP(1)
      tt-fcad-regis.nrregemp AT 12 LABEL "Registro" 
                                   FORMAT "zzzzzzzzzzzz"
      tt-fcad-regis.dtregemp AT 57 LABEL "Data"     
                                   FORMAT "99/99/9999"   SKIP
      tt-fcad-regis.orregemp AT 56 LABEL "Orgao"    
                                   FORMAT "x(12)" SKIP(1)
      tt-fcad-regis.nrinsmun AT 01 LABEL "Inscricao Municipal"
                                   FORMAT "zzz,zzz,zzz,zzz,9"
      tt-fcad-regis.dtinsnum AT 57 LABEL "Data"     
                                   FORMAT "99/99/9999" SKIP
      tt-fcad-regis.nrinsest AT 02 LABEL "Inscricao Estadual"
                                   FORMAT "X(17)"
      tt-fcad-regis.flgrefis AT 48 LABEL "Optante REFIS" FORMAT "X(3)" SKIP
      tt-fcad-regis.perfatcl AT 01 LABEL "Concentracao faturamento unico cliente"
                                   FORMAT "zz9.99"
      tt-fcad-regis.nrcdnire AT 50 LABEL "Numero NIRE" 
                                   FORMAT "zzzzzzzzzzzz"
      WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 FRAME f_registro_pj.


FORM  
"----------------------------------------------------------------------------"
      SKIP
      "REPRESENTANTE / PROCURADOR"  AT 25  
      SKIP
"----------------------------------------------------------------------------"
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                                    FRAME f_titulo_procuradores_pj.
      
FORM  
    tt-fcad-procu.nrdctato AT 02 LABEL  "Conta/dv"        FORMAT "zzzz,zzz,9"
    tt-fcad-procu.nrcpfcgc AT 51 LABEL  "C.P.F."          FORMAT "x(18)" 
    SKIP                                                 
    tt-fcad-procu.nmdavali AT 06 LABEL "Nome"             FORMAT "x(40)" 
    SKIP                                                 
    tt-fcad-procu.tpdocava       LABEL "Documento"        FORMAT "x(2)"
    tt-fcad-procu.nrdocava       NO-LABEL                 FORMAT "x(15)"
    tt-fcad-procu.cdoeddoc       LABEL "Org.Emi."         FORMAT "x(05)"
    tt-fcad-procu.cdufddoc       LABEL "UF"               FORMAT "!(02)"
    tt-fcad-procu.dtemddoc       LABEL "Data Emi."        FORMAT "99/99/9999" 
    SKIP                                                 
    tt-fcad-procu.dtnascto AT  1 LABEL "Data Nascimento"  FORMAT "99/99/9999"
    tt-fcad-procu.inhabmen AT 31 LABEL "Responsab. Legal" FORMAT "9"
    tt-fcad-procu.dshabmen       NO-LABEL                 FORMAT "x(13)"
    tt-fcad-procu.dthabmen       LABEL "Data Emancipacao" FORMAT "99/99/9999" 
    tt-fcad-procu.cdsexcto AT 33 LABEL "Sexo"             FORMAT "!"
    tt-fcad-procu.dsestcvl AT 46 LABEL "Estado Civil"     FORMAT "x(12)" 
    SKIP                                                 
    tt-fcad-procu.dsnacion AT 03 LABEL "Nacionalidade"    FORMAT "x(15)"
    tt-fcad-procu.dsnatura AT 37 LABEL "Natural de"       FORMAT "x(25)" 
    SKIP(1)                                              
    tt-fcad-procu.nrcepend AT 04 LABEL "CEP"              FORMAT "x(9)" 
    tt-fcad-procu.dsendere AT 20 LABEL "End.Residencial"  FORMAT "x(40)" 
    SKIP                                                 
    tt-fcad-procu.nrendere AT 03 LABEL "Nro."             FORMAT "zzz,zz9"
    tt-fcad-procu.complend AT 24 LABEL "Complemento"      FORMAT "x(40)" 
    SKIP                                                 
    tt-fcad-procu.nmbairro AT 01 LABEL "Bairro"           FORMAT "x(40)"
    tt-fcad-procu.nrcxapst AT 52 LABEL "Cx.Postal"        FORMAT "zzzzzzz9" 
    SKIP                                                 
    tt-fcad-procu.nmcidade AT 01 LABEL "Cidade"           FORMAT "x(25)"
    tt-fcad-procu.cdufende AT 59 LABEL "UF"               FORMAT "!(02)"
    tt-fcad-procu.nmmaecto AT 01 LABEL "Filiacao: Mae"    FORMAT "x(40)" 
    SKIP                                                 
    tt-fcad-procu.nmpaicto AT 11 LABEL "Pai"              FORMAT "x(40)" 
    SKIP(1)                                              
    /*tt-fcad-procu.vledvmto AT 01 LABEL "Endividamento"    FORMAT "zzz,zzz,zz9.99"*/
    tt-fcad-procu.dtvalida AT 01 LABEL "Vigencia"         FORMAT "x(13)"
    tt-fcad-procu.dsproftl AT 31 LABEL "Cargo"            FORMAT "x(20)" 
    SKIP                                                 
    tt-fcad-procu.persocio AT 01 LABEL "% Societ."        FORMAT "zz9.99"
    tt-fcad-procu.flgdepec AT 31 LABEL "Depend. Econ."    FORMAT "SIM/NAO"
    SKIP(1)
    WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                       FRAME f_procuradores_pj.

/* Poderes */
FORM 
"----------------------------------------------------------------------------"
      SKIP
     "PODERES" AT 36
      SKIP
"----------------------------------------------------------------------------"
      SKIP
                                                                    
"Descricao do Poder                                     Conjunto    Isolado"
      SKIP(1)
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                                    FRAME f_titulo_poderes.

FORM 
    SKIP(1)    
"PODERES"
    SKIP(1)    
"Descricao do Poder                                     Conjunto    Isolado"
    SKIP(1)
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                                    FRAME f_cabecalho_poderes.

FORM tt-fcad-poder.dscpoder AT 1   FORMAT "x(34)"
     tt-fcad-poder.flgconju AT 59  FORMAT "x(1)"
     tt-fcad-poder.flgisola AT 70  FORMAT "x(1)" SKIP
     
     WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76 FRAME f_poderes.

FORM 
   SKIP
   aux_dsoutpo1 AT 6 FORMAT "x(48)"
   SKIP
   aux_dsoutpo2 AT 6 FORMAT "x(48)"
   SKIP
   aux_dsoutpo3 AT 6 FORMAT "x(48)"
   SKIP
   aux_dsoutpo4 AT 6 FORMAT "x(48)"
   SKIP        
   aux_dsoutpo5 AT 6 FORMAT "x(48)"
   
   WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76 FRAME f_poderes_outros.
/* Fim Poderes */

/* Bens */

FORM 
"----------------------------------------------------------------------------"
      SKIP
     "BENS" AT 36
      SKIP
"----------------------------------------------------------------------------"
      SKIP

"Descricao do bem            Perc.s/onus  Parc. Valor Parcela       Valor Bem"
      SKIP(1)
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                                    FRAME f_titulo_bens.

FORM 
    SKIP(1)    
"Descricao do bem            Perc.s/onus  Parc. Valor Parcela       Valor Bem"
      SKIP(1)
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76
                                    FRAME f_cabecalho_bens.

FORM tt-fcad-cbens.dsrelbem AT 1  FORMAT "x(27)"          
     tt-fcad-cbens.persemon AT 34 FORMAT "zz9.99"         
     tt-fcad-cbens.qtprebem AT 42 FORMAT "zz9"            
     tt-fcad-cbens.vlprebem AT 48 FORMAT "zz,zzz,zz9.99"     
     tt-fcad-cbens.vlrdobem AT 62 FORMAT "zzzz,zzz,zz9.99" 
     WITH DOWN COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 76 FRAME f_bens.
/* Fim Bens */

FORM  
"----------------------------------------------------------------------------"
      SKIP
     "REFERENCIAS (PESSOAIS/COMERCIAIS/BANCARIAS)"  AT 20  
      SKIP
"----------------------------------------------------------------------------"
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                                    FRAME f_titulo_referencias_pj.


FORM  tt-fcad-refer.nrdctato AT 01 LABEL "Conta/dv"     FORMAT "x(10)"
      tt-fcad-refer.nmdavali AT 27 LABEL "Nome"         FORMAT "X(40)" SKIP
      tt-fcad-refer.nmextemp AT  2 LABEL "Empresa"      FORMAT "x(35)"
      tt-fcad-refer.cddbanco AT 47 LABEL "Banco"        FORMAT "z,zz9"
      tt-fcad-refer.cdagenci AT 68 LABEL "Ag."          FORMAT "zzz9"  SKIP
      tt-fcad-refer.dsproftl AT 04 LABEL "Cargo"        FORMAT "x(20)" SKIP(1)
      tt-fcad-refer.nrcepend AT 04 LABEL "CEP"          FORMAT "x(9)" 
      tt-fcad-refer.dsendere AT 23 LABEL "Endereco"     FORMAT "x(40)" SKIP
      tt-fcad-refer.nrendere AT 03 LABEL "Nro."         FORMAT "zzz,zz9"
      tt-fcad-refer.complend AT 20 LABEL "Complemento"  FORMAT "x(40)" SKIP
      tt-fcad-refer.nmbairro AT 01 LABEL "Bairro"       FORMAT "x(40)"
      tt-fcad-refer.nrcxapst AT 52 LABEL "Cx.Postal"    FORMAT "zzzzz,zz9"
      tt-fcad-refer.nmcidade AT 01 LABEL "Cidade"       FORMAT "x(25)"
      tt-fcad-refer.cdufende AT 59 LABEL "UF"           FORMAT "x(2)"    
      SKIP(1)
      tt-fcad-refer.nrtelefo AT 01 LABEL "Telefones"    FORMAT "x(20)" SKIP
      tt-fcad-refer.dsdemail AT 03 LABEL "E-Mails"      FORMAT "x(30)" 
      WITH DOWN COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
                       FRAME f_referencias_pj.
                       

FORM SKIP
     "RESPONSAVEL LEGAL:"  AT 01
     SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
          FRAME f_titulo_responsavel_pj.

FORM tt-fcad-respl.nrdconta AT  1  LABEL " Conta/dv" FORMAT "X(10)"
     tt-fcad-respl.nrcpfcgc AT 30  LABEL "   C.P.F." FORMAT "X(18)" SKIP
     tt-fcad-respl.nmrespon AT  5  LABEL " Nome"                    SKIP
     tt-fcad-respl.tpdeiden AT  1  LABEL "Documento"
     tt-fcad-respl.nridenti        NO-LABEL
     tt-fcad-respl.dsorgemi AT 31  LABEL "Org.Emi."  FORMAT "x(5)"
     tt-fcad-respl.cdufiden AT 49  LABEL "U.F."                     SKIP
     tt-fcad-respl.dtemiden AT 44  LABEL "Data Emi."                SKIP(1)
     tt-fcad-respl.dtnascin AT  1  LABEL "Data Nascimento"
     tt-fcad-respl.cddosexo AT 31  LABEL "Sexo"      FORMAT "!"
     tt-fcad-respl.cdestciv        LABEL "  Estado Civil" 
     tt-fcad-respl.dsestciv        NO-LABEL          FORMAT "x(19)"
     tt-fcad-respl.dsnacion AT  3  LABEL "Nacionalidade"            SKIP
     tt-fcad-respl.dsnatura AT  6  LABEL "Natural de"               SKIP(1)
     tt-fcad-respl.cdcepres AT  4  LABEL "CEP"       FORMAT "x(9)"
     tt-fcad-respl.dsendres AT 20  LABEL "End.Residencial"          SKIP
     tt-fcad-respl.nrendres AT  3  LABEL "Nro."
     tt-fcad-respl.dscomres AT 24  LABEL "Complemento"              SKIP

     tt-fcad-respl.dsbaires AT  1  LABEL "Bairro"    FORMAT "x(40)"           
     tt-fcad-respl.nrcxpost AT 52  LABEL "Cx.Postal" FORMAT "zzzzz,zz9" 
     SKIP
     tt-fcad-respl.dscidres AT 01  LABEL "Cidade"    FORMAT "x(25)"
     tt-fcad-respl.dsdufres AT 59  LABEL "UF"        FORMAT "!!"
     SKIP(1)
     "Filiacao:"
     tt-fcad-respl.nmmaersp AT 11  LABEL "Mae"                      SKIP
     tt-fcad-respl.nmpairsp AT 11  LABEL "Pai"                      SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX SIDE-LABELS WIDTH 76 
          FRAME f_responsavel_pj.



/* ..........................................................................*/
