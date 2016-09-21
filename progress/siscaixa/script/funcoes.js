/*
Autor..........: Tiago
Programa.......: formataconta.js
Data de criação: 05/09/2016

Objetivo.......: Funcoes genericas para caixa online

Alteracoes.....: 
*/


/*!
 * OBJETIVO  : Retirar caracteres indesejados
 * PARÂMETROS: flgRetirar -> Se TRUE retira caracteres que não estão na variável "valid"
 *                           Se FALSE retira caracteres que estão na variável "valid"    
 */	
function retiraCaracteres(str,valid,flgRetirar) {
	
	var result = "";	// variável que armazena os caracteres v&aacute;lidos
	var temp   = "";	// variável para armazenar caracter da string
	
	for (var i = 0; i < str.length; i++) {
		temp = str.substr(i,1);
			
		// Se for um n&uacute;mero concatena na string result
		if ((valid.indexOf(temp) != "-1" && flgRetirar) || (valid.indexOf(temp) == "-1" && !flgRetirar)) {
			result += temp;
		}
	}
	
	return result;		
}

function getKeyValue(e) {
	// charCode para Firefox e keyCode para IE
	var keyValue = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;	
	return keyValue;
}


