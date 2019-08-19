/* 
Solicitação: INC0013560
Objetivo   : Ajustar os registros de saldo do Associado 6815111 da Cooperativa 1
             O associado apresenta saldo bloqueado de R$ 2.200,00. 
             Este saldo permenece bloqueado desde 04/02/2019 e devido a um erro de 
             registro de valor na tabela CRAPDPB ocorrido nesta data, o valor 
             não está sendo desbloqueado.
Autor      : Jackson
*/

-- LISTAGEM DE UPDATES PARA CORRECAO DE SALDO
-- Acerto do valor na tabela crapdpb
update crapdpb set vllanmto = vllanmto + 2200 where cdcooper = 1 and nrdconta = 6815111 and dtliblan = '04/02/2019' and progress_recid = 12784744; 
   
--01/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADgAABlyxADO';

--01/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADEAABYJ8AAR';

--02/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADCAABj8HAC7';

--02/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADLAACIuPAAg';

--03/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADGAABOo8ADS';

--03/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADJAABw2gAAj';

--04/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADSAAA38CAAp';

--04/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AACS6UAAO';

--05/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADWAAASDAADK';

--05/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADBAAByCXAC6';

--06/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADSAAA7EHAAf';

--06/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADlAABKscAAf';

--06/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADJAAByQ8AC+';

--07/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADWAABMqEAAs';

--07/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADkAABJm4AAj';

--07/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADKAACeE/ADD';

--08/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADSAAA+SpAAh';

--08/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADkAABKk1AAK';

--08/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADAAAB/R4AAr';

--08/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADLAACPYqAAW';

--09/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADEAABczWAA4';

--09/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADKAAChGDACK';

--10/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AACXomAAZ';

--10/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADLAACS6hAAi';

--11/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADWAABRyxAA0';

--11/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADiAAB9cHABr';

--11/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AACYt9AAf';

--12/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADWAABSiXABC';

--12/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADkAABMHRAAj';

--12/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AACaJLAAX';

--13/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADWAABTZuAAd';

--13/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADiAAB+8NAAd';

--13/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADKAAClVBACT';

--14/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADTAABlvZABL';

--14/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADkAABNjUAAh';

--14/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADLAACWO7AAq';

--15/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADZAAAzDiADG';

--15/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADiAACASeADF';

--15/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADAAACGoqADO';

--15/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADMAAB3EnAAf';

--16/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADBAAB8H2ACz';

--16/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADOAABSXrADQ';

--17/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADBAAB97wAC7';

--17/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADJAACqweADA';

--18/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADXAABS2SABU';

--18/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADkAABPPGAAT';

--18/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADAAACKsKAAZ';

--19/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADVAABYrVAAb';

--19/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADfAAB32AADF';

--20/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADSAAB2jvAAo';

--20/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADhAACF6nAC+';

--20/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADOAABVdiAAk';

--21/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADYAAA8yJAC8';

--21/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADiAACDULAC9';

--21/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADNAABhyfAAE';

--22/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADYAAA7FyAAT';

--22/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADgAACa9JACy';

--22/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AACgbzABK';

--22/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADLAACZuzADR';

--23/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADAAACPGzACe';

--23/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADJAACt2eAC2';

--24/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxAC/AAClNbAAE';

--24/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADJAACs70AAf';

--25/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADXAABVogAC5';

--25/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADfAAB7GBAB2';

--25/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADFAABTW5ADM';

--26/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADTAABxjjAAu';

--26/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADfAAB6DzAC3';

--26/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADDAABm+2AC5';

--27/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADTAAByZwADL';

--27/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADiAACD1fACp';

--27/05/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAqd6oADOAABWttAC4';

--28/02/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAkASTADVAABi1WAAe';

--28/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADgAACdBtABb';

--29/03/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAmCx4ADfAACpcHACu';

--29/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADCAABm/QACu';

--30/04/2019
update crapsda c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.rowid = 'AAoFDxADAAACQhVAC8';

--CRAPSLD
update crapsld c set c.vlsddisp = c.vlsddisp + 2200 , c.vlsdbloq = c.vlsdbloq - 2200  where c.cdcooper = 1    and c.nrdconta = 6815111;

commit;
