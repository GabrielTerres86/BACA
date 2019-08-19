
-- Insere a tela
INSERT INTO craptel 
    (nmdatela,
     nrmodulo,
     cdopptel,
     tldatela,
     tlrestel,
     flgteldf,
     flgtelbl,
     nmrotina,
     lsopptel,
     inacesso,
     cdcooper,
     idsistem,
     idevento,
     nrordrot,
     nrdnivel,
     nmrotpai,
     idambtel)
    SELECT 'CONSIG',  --> nmdatela - Nome da tela.
           5,  --> nrmodulo -  Numero do modulo
           '@,C,A,H,D', --> cdopptel - Opcoes disponiveis para a tela.
           'Cadastro de Empresas do Consignado', --> tldatela - Titulo da tela em uso.
           'Cadastro de Empresas do Consignado', -->tlrestel - Titulo resumido da tela para uso na formacao dos menus.
           0, -->flgteldf - Indica se a permissao para esta tela eh criada automaticamente.
           1, --> flgtelbl - bloqueio da tela - Indica se a tela esta liberada ou bloqueada para uso no sistema.
           ' ', --> nmrotina - Rotina especializada em determida funcao.
           'ACESSO,CONSULTAR,ALTERAR,HABILITAR,DESABILITAR', --> lsopptel - Lista de opcoes da rotina especializada em determinada funcao.
           0, --> inacesso - Indicador de Acesso(0-Nao/1-Apos Solic./2-Durante Proc.)
           cdcooper, -- cooperativa - Codigo que identifica a Cooperativa.
           1, --> idsistem - Identificacao do Sistema (1-Ayllos, 2-Progrid).
           0, --> idevento - Identificacao do Modulo
           1, --> nrordrot - Ordem de apresentacao da rotina na Tela
           1, --> nrdnivel - Nivel de apresentacao da tela
           '', --> nmrotpai - Nome da Rotina Pai
           2 -->idambtel -    Ambiente do sistema Ayllos que a tela esta disponivel.
      FROM crapcop;     
 
-- Insere o registro de cadastro do programa
INSERT INTO crapprg
    (nmsistem,
     cdprogra,
     dsprogra##1,
     dsprogra##2,
     dsprogra##3,
     dsprogra##4,
     nrsolici,
     nrordprg,
     inctrprg,
     cdrelato##1,
     cdrelato##2,
     cdrelato##3,
     cdrelato##4,
     cdrelato##5,
     inlibprg,
     cdcooper) 
    SELECT 'CRED', --> nmsistem -- Nome do sistema.
           'CONSIG', --> cdprogra -- Codigo que identifica o programa.
           'Cadastro de Empresas do Consignado', --> dsprogra##1 -- Descreve o objetivo do programa.
           '.', --> dsprogra##2 -- Descreve o objetivo do programa.
           '.', --> dsprogra##3 -- Descreve o objetivo do programa.
           '.', --> dsprogra##4 -- Descreve o objetivo do programa.
           50, --> nrsolici -- Informa o numero da solicitacao implantada.           
           (select max(crapprg.nrordprg) + 1 from crapprg where crapprg.cdcooper = crapcop.cdcooper and crapprg.nrsolici = 50), --> nrordprg -- Numero de ordem do programa dentro da solicitacao
           1, --> inctrprg -- Controle de execucao do programa (1-nao executado, 2-executado).
           0, --> cdrelato##1 -- Codigo do relatorio.
           0, --> cdrelato##2 -- Codigo do relatorio.
           0, --> cdrelato##3 -- Codigo do relatorio.
           0, --> cdrelato##4 -- Codigo do relatorio.
           0, --> cdrelato##5 -- Codigo do relatorio.
           1, --> inlibprg -- Indicador de liberacao do programa (1=lib, 2=bloq e 3=em teste)
           cdcooper --> cdcooper --      Codigo que identifica a Cooperativa.
      FROM crapcop;
COMMIT;