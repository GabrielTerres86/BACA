/*
Autor..........: Tiago
Programa.......: formataconta.js
Data de criação: 05/09/2016

Objetivo.......: Funcoes genericas para caixa online

Alteracoes.....: 
*/


function getKeyValue(e) {
	// charCode para Firefox e keyCode para IE
	var keyValue = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;	
	return keyValue;
}


