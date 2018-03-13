/*
 * FONTE        : funcoes.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : Outubro/2012
 * OBJETIVO     : Biblioteca de Funções para o PROGRID
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [19/10/2012] Lucas Lunelli : Inserida funções 'retornaTecla', 'validaString' e
									 'formataNum' para tratamento de campos.
									 
		[22/10/2012] Daniel Zimmermann: Inserido funções 'FormataCep', 'FormataDDD',
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função para validar chars digitados em um campo.
 * PARÂMETRO : obj		   -> Objeto do campo a ser tratado.
 *             e 		   -> Evento.
 *             valid_value -> [Opcional] Adiciona chars permitidos pela função.
 *             acentos	   -> TRUE  = Função permite acentuação.
 *							  FALSE = Função não permite digitação de acentos.
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
					'ÁÀÄÂÃAáàäâãaCcDdEÉÈEËÊéèëeêeÍÌÏÎíìïîNnÓÒÖOÔÕóòoöôõRrÚUÙÜUÛúuùüûuÇç';
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função similar à validaString, porém voltada para campos numéricos.
 * PARÂMETRO : obj		   -> Objeto do campo a ser tratado.
 *             e 		   -> Evento.
 *             valid_value -> [Opcional] Adiciona chars permitidos pela função.
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função para limitar tamanho em campos TextArea.
 * PARÂMETRO : obj		-> Objeto do campo a ser tratado.
 *             tamanho 	-> Tamanho maximo do campo.
 */

function ValidaTamanho(obj,tamanho)  {

		if (obj.value.length > tamanho) {
			obj.value = obj.value.substring(0,tamanho);
		}		
}   


/*!
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função campo CEP para 99999-999.
 * PARÂMETRO : obj			-> Objeto do campo a ser tratado.
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função para formatação campo telefone.
 * PARÂMETRO : campo		-> Objeto do campo a ser tratado.
 * 
 */

function FormataTelefone(campo){

   // backspace
   if(event.keyCode==8)
      return true;
   
   // tira o ponto
   campo.value = campo.value.replace('.','');
   
   // varre o campo em busca de caracteres inválidos e remove-os
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função para formatação campo ddd.
 * PARÂMETRO : campo		-> Objeto do campo a ser tratado.
 * 
 */

function FormataDDD(campo){

   // backspace
   if(event.keyCode==8)
      return true;
   
   // varre o campo em busca de caracteres inválidos e remove-os
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
 * ALTERAÇÃO : 000
 * OBJETIVO  : Função para validar campos com valores inteiro.
 * PARÂMETRO : teclapres		-> Tecla pressionada a ser tratado.
 * 
 */

function validaInteiro(teclapres){
   var tecla = teclapres.keyCode;   
   if ( ( (tecla < 37 || tecla > 40) && (tecla < 48 || tecla > 57) && (tecla < 96 || tecla > 105)) && tecla != 8 && tecla != 9 && tecla!= 46){
         event.returnValue = false;
         return;
   }
}
