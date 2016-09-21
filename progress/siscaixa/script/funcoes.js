/*
Autor..........: Tiago
Programa.......: formataconta.js
Data de cria��o: 05/09/2016

Objetivo.......: Funcoes genericas para caixa online

Alteracoes.....: 
*/


/*!
 * OBJETIVO  : Retirar caracteres indesejados
 * PAR�METROS: flgRetirar -> Se TRUE retira caracteres que n�o est�o na vari�vel "valid"
 *                           Se FALSE retira caracteres que est�o na vari�vel "valid"    
 */	
function retiraCaracteres(str,valid,flgRetirar) {
	
	var result = "";	// vari�vel que armazena os caracteres v&aacute;lidos
	var temp   = "";	// vari�vel para armazenar caracter da string
	
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


