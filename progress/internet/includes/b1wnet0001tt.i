/*..............................................................................

   Programa: b1wnet0001tt.i                  
   Autor   : David
   Data    : Marco/2008                        Ultima atualizacao: 16/12/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wnet0001.p

   Alteracoes: 12/05/2008 - Alterar nrdoccop para dsdoccop (David). 

               27/02/2009 - Melhorias no servico de cobranca (David).
               
               17/04/2009 - Incluir campo dsinssac na tt-sacados-blt (David).
               
               28/05/2009 - Incluir campo tt-consulta-blt.cdcartei (David).
               
               15/06/2009 - Incluir campo tt-sacados-blt.nrctasac
                                          tt-sacados-blt.dsctasac(Guilherme).
                                          
               18/04/2011 - Incluir campo tt-dados-blt.cdcartei
                                          tt-dados-blt.nrvarcar
                                          (Rafael - Cob.Registrada)
                                          
               19/05/2011 - Adicionado campo flgsacad na tt-dados-sacado-blt
                            (Jorge).
                           
               25/07/2013 - Incluido intipemi ref. ao tipo de emissao de boleto 
                            (Cooperado emite e expede ou Banco emite e expede) 
                            (Rafael/Jorge).

               22/01/2015 - Adicionar campo flgemail na tt-sacados-blt para 
                            identificar se existe e-mail na crapsab.
                            Projeto Boleto por E-mail (Douglas).     

               04/02/2016 - Ajuste Projeto Negativação Serasa (Daniel)

               16/02/2016 - Criacao do campo flprotes na tt-dados-blt.
                            (Jaison/Marcos)

               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança(Odirlei-AMcom)             

               16/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Jaison/Cechet)

..............................................................................*/

DEF TEMP-TABLE tt-dados-blt NO-UNDO              
    FIELD nrdctabb LIKE crapcco.nrdctabb
    FIELD nrconven LIKE crapcco.nrconven
    FIELD tamannro LIKE crapcco.tamannro
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD vllbolet LIKE crapsnh.vllbolet
    FIELD dsdinstr LIKE crapsnh.dsdinstr
/*    FIELD cdcartei LIKE crapcco.nrvarcar.*/
    FIELD cdcartei LIKE crapcco.cdcartei
    FIELD nrvarcar LIKE crapcco.nrvarcar
    FIELD flgaceit LIKE crapcob.flgaceit
    /* 1 - Cob s/ registro 
       2 - Cob c/ registro 
       3 - Todos */
    FIELD intipcob AS INTE
    /*
       0 - sem convenio
       1 - cooperado emite e expede
       2 - banco emite e expede
       3 - cooperado + banco (emite e expede)
    */
    FIELD intipemi AS INTE
    FIELD flserasa AS INTE
    FIELD qtminneg AS INT
    FIELD qtmaxneg AS INT
    FIELD valormin AS DEC
    FIELD textodia AS CHAR
    FIELD flprotes AS INT
    FIELD flpersms AS INT
    FIELD fllindig AS INT
    FIELD cddbanco AS INT
    FIELD flgregon AS INT
    FIELD flgpgdiv AS INT.

DEF TEMP-TABLE tt-sacados-blt NO-UNDO
    FIELD nmdsacad LIKE crapsab.nmdsacad
    FIELD nrinssac LIKE crapsab.nrinssac
    FIELD dsinssac AS CHAR
    FIELD nrctasac LIKE crapass.nrdconta
    FIELD dsctasac AS CHAR
    /* Campo para identificar se exite e-mail crapsab*/
    FIELD flgemail AS LOGI
    FIELD dsflgend AS LOGI
    FIELD dsflgprc AS LOGI
    FIELD nmsacado LIKE crapsab.nmdsacad. 
    
DEF TEMP-TABLE tt-gera-blt NO-UNDO                 
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD dsdoccop LIKE crapcob.dsdoccop
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD nrinssac LIKE crapcob.nrinssac.
     
DEF TEMP-TABLE tt-dados-sacado-blt NO-UNDO LIKE crapsab
    FIELD dsdemail AS CHAR
    FIELD flgremov AS LOGI
    FIELD flgsacad AS LOGI
    FIELD dscriend AS CHAR.
 
/*............................................................................*/
