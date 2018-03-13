/*
 * FONTE        : funcoes.php
 * CRIA��O      : Lucas Lunelli
 * DATA CRIA��O : Outubro/2012
 * OBJETIVO     : Biblioteca de Fun��es para o PROGRID
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [19/10/2012] Lucas Lunelli : Inserida fun��es 'retornaTecla', 'validaString' e
									 'formataNum' para tratamento de campos.
									 
		[22/10/2012] Daniel Zimmermann: Inserido fun��es 'FormataCep', 'FormataDDD',
										'FormataTelefone', 'ValidaTamanho', 'validaInteiro'
 */

function retornaTecla(e) {
	var keyValue = 0;	
	
	if (e.charCode) {
		keyValue = e.charCode; // Mozilla
	} else {
		keyValue = e.keyCode; // IE
	}
	
	return keyValue;
}

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o para validar chars digitados em um campo.
 * PAR�METRO : obj		   -> Objeto do campo a ser tratado.
 *             e 		   -> Evento.
 *             valid_value -> [Opcional] Adiciona chars permitidos pela fun��o.
 *             acentos	   -> TRUE  = Fun��o permite acentua��o.
 *							  FALSE = Fun��o n�o permite digita��o de acentos.
 */
 function validaString(obj,e,valid_value,acentos,replace) {	

	var keyValue = retornaTecla(e);
	
	if ((keyValue >= 35 && keyValue <= 40) || (keyValue == 8) || (keyValue == 46)) {
		return true;
	} else { 
		var text   = new String(obj.value);
		var textok = '';
		var temp   = '';
		var valid  = '';
		var cont   = 0;
		
		if (acentos){
			valid = 'abcdefghijklmnopqrstuvwxyz' +
					'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \/' +
					'�����A�����aCcDdE��E�����e�e��������Nn���O����o���Rr�U��U��u���u��';
		} else {
			valid = 'abcdefghijklmnopqrstuvwxyz' +
					'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \/';
		}
		
		if (replace == null) replace = false;
		
		if (replace) {
			var qtReplace = valid_value.length;
			
			for (var i = 0; i < qtReplace; i++) {
				eval('valid = valid.replace(/\\' + valid_value.substr(i,1) + '/g,"")');				
			}
		} else {		
			var valid  = valid + valid_value;
		}	
		
		for (var i = 0; i < text.length; i++) {
			temp = text.substr(i,1);
			
			if (valid.indexOf(temp) == '-1') {
				obj.value = textok;
				return false;
			} else {
				textok += temp;
				cont++;
			}
		} 		
	}
	
	obj.value = textok;
	return true; 
}

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o similar � validaString, por�m voltada para campos num�ricos.
 * PAR�METRO : obj		   -> Objeto do campo a ser tratado.
 *             e 		   -> Evento.
 *             valid_value -> [Opcional] Adiciona chars permitidos pela fun��o.
 */
function formataNum(obj,e,valid_value) {
	var keyValue = retornaTecla(e);
	
	if ((keyValue >= 35 && keyValue <= 40) || (keyValue == 8) || (keyValue == 46)) {
		return true;
	} else {
		var data   = new String(obj.value);
		var dataok = '';
		var temp   = '';
		var valid  = '0123456789' + valid_value;
		var cont   = 0;
		
		for (var i = 0; i < data.length; i++) {
			temp = data.substr(i,1);
			
			if (valid.indexOf(temp) == '-1') {
				continue;				
			} else {
				dataok += temp;
				cont++;
			}
		}
	}
	
	obj.value = dataok;
	return true; 
}

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o para limitar tamanho em campos TextArea.
 * PAR�METRO : obj		-> Objeto do campo a ser tratado.
 *             tamanho 	-> Tamanho maximo do campo.
 */

function ValidaTamanho(obj,tamanho)  {

		if (obj.value.length > tamanho) {
			obj.value = obj.value.substring(0,tamanho);
		}		
}   


/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o campo CEP para 99999-999.
 * PAR�METRO : obj			-> Objeto do campo a ser tratado.
 *             teclapres 	-> Tecla pressionada.
 */
function FormataCep(obj,teclapres) {
   
   
   var tecla = teclapres.keyCode;
   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9 && tecla!= 16){
         event.returnValue = false;
         return;
   }

        vr = obj.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length + 1;

        if ( tecla != 9 && tecla != 8 ){
                if ( tam > 3 && tam < 8)
                        obj.value = vr.substr( 0, tam - 3  ) + '-' + vr.substr( tam - 3, tam );
						
				if ( tam = 8 )
				obj.value = vr.substr( 0, 5 ) + '-' + vr.substr( 5, 3 );
                 }              
				 
}	

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o para formata��o campo telefone.
 * PAR�METRO : campo		-> Objeto do campo a ser tratado.
 * 
 */

function FormataTelefone(campo){

   // backspace
   if(event.keyCode==8)
      return true;
   
   // tira o ponto
   campo.value = campo.value.replace('.','');
   
   // varre o campo em busca de caracteres inv�lidos e remove-os
   for(var i=0;i<campo.value.length;i++){
   
	  if((campo.value.substring(i,i+1)!='0')&&
         (campo.value.substring(i,i+1)!='1')&&
         (campo.value.substring(i,i+1)!='2')&&
         (campo.value.substring(i,i+1)!='3')&&
         (campo.value.substring(i,i+1)!='4')&&
         (campo.value.substring(i,i+1)!='5')&&
         (campo.value.substring(i,i+1)!='6')&&
         (campo.value.substring(i,i+1)!='7')&&
         (campo.value.substring(i,i+1)!='8')&&
         (campo.value.substring(i,i+1)!='9'))	  
    	  campo.value = campo.value.substring(0,i);   
   }

   if (campo.value.length >= 5)
       campo.value = campo.value.substring(0,5) + '.' + campo.value.substring(5,campo.value.length);
}	

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o para formata��o campo ddd.
 * PAR�METRO : campo		-> Objeto do campo a ser tratado.
 * 
 */

function FormataDDD(campo){

   // backspace
   if(event.keyCode==8)
      return true;
   
   // varre o campo em busca de caracteres inv�lidos e remove-os
   for(var i=0;i<campo.value.length;i++){   
	  if((campo.value.substring(i,i+1)!='0')&&
         (campo.value.substring(i,i+1)!='1')&&
         (campo.value.substring(i,i+1)!='2')&&
         (campo.value.substring(i,i+1)!='3')&&
         (campo.value.substring(i,i+1)!='4')&&
         (campo.value.substring(i,i+1)!='5')&&
         (campo.value.substring(i,i+1)!='6')&&
         (campo.value.substring(i,i+1)!='7')&&
         (campo.value.substring(i,i+1)!='8')&&
         (campo.value.substring(i,i+1)!='9'))	  
    	  campo.value = campo.value.substring(0,i);   
   }
}

/*!
 * ALTERA��O : 000
 * OBJETIVO  : Fun��o para validar campos com valores inteiro.
 * PAR�METRO : teclapres		-> Tecla pressionada a ser tratado.
 * 
 */

function validaInteiro(teclapres){
   var tecla = teclapres.keyCode;   
   if ( ( (tecla < 37 || tecla > 40) && (tecla < 48 || tecla > 57) && (tecla < 96 || tecla > 105)) && tecla != 8 && tecla != 9 && tecla!= 46){
         event.returnValue = false;
         return;
   }
}
