/*..............................................................................

    Programa: b1wgen0048tt.i
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 04/12/2009   

    Objetivo  : 

    Alteracoes:  04/12/2009 - Incluido novos campos na TEMP-TABLE 
                              tt-inf-adicionais  (Elton).
   
..............................................................................*/


DEF TEMP-TABLE tt-inf-adicionais NO-UNDO
    FIELD cdopejfn LIKE crapjfn.cdopejfn[5]
    FIELD nmopejfn LIKE crapope.nmoperad
    FIELD dtaltjfn LIKE crapjfn.dtaltjfn[5]
    FIELD dsinfadi LIKE crapjfn.dsinfadi
    FIELD nrinfcad LIKE crapjur.nrinfcad  
    FIELD dsinfcad AS CHAR
    FIELD nrperger LIKE crapjur.nrperger
    FIELD dsperger AS CHAR
    FIELD nrpatlvr LIKE crapjur.nrpatlvr
    FIELD dspatlvr AS CHAR.


/*............................................................................*/
