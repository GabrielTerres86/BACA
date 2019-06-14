//************************************************************************//
//*** Fonte: mascara.js                                                ***//
//*** Autor: David                                                     ***//
//*** Data : Dezembro/2007                Última Alteração: 13/08/2009 ***//
//***                                                                  ***//
//*** Objetivo  : Funções para mascaras de campos                      ***//
//***             Necessita a chamada de jquery.js e funcoes.js        ***//
//***                                                                  ***//	 
//*** Alterações: 13/08/2009 - Considerar ENTER tecla válida na        ***//
//***                          validação de numéricos (Guilherme).     ***//	 
//************************************************************************//

var pasteVar = ($.browser.msie ? 'paste' : 'input') + ".mascara";

jQuery.fn.extend({ 
	// Função geral para máscara
	setMask: function(tipo,formato,specialChars,objBlock) {
		// Formata máscara no evento onKeyUp do campo
		$(this).unbind("keyup.mascara").bind("keyup.mascara",function(e) { return $(this).setMaskOnKeyUp(tipo,formato,specialChars,e); }); 

		// Formata máscara no evento onKeyDown do campo
		$(this).unbind("keydown.mascara").bind("keydown.mascara",function(e) { return $(this).setMaskOnKeyDown(tipo,formato,specialChars,e); });		
		
		// Formata máscara no evento onBlur do campo
		$(this).unbind("blur.mascara").bind("blur.mascara",function() { return $(this).setMaskOnBlur(tipo,formato,specialChars,objBlock); });		
		
		$(this).unbind(pasteVar).bind(pasteVar,function(e) { return $(this).setMaskOnPaste(tipo,formato,specialChars,e); });
	},	
	setMaskOnPaste: function(tipo,formato,specialChars,e) {			
		var tecla = getKeyValue(e);
		
		// Se cópia foi efetuada com botão direito do mouse
		if (tecla == 0) {
			// Preparar parâmetros para utilização na função setTimeout			
			var objPaste = { t: tipo, f: formato, s: specialChars, o: $(this) }         					
			
			// Prepara métodos para execução na função setTimeout
			// Esse métodos serão utilizados para validar e formatar o conteúdo copiado
			objPaste.call = function() { 
				if (objPaste.o.setMaskOnKeyDown(objPaste.t,objPaste.f,objPaste.s,e)) {
					objPaste.o.setMaskOnKeyUp(objPaste.t,objPaste.f,objPaste.s,e);
				}
			}
			
			// Aguarda 20 milisegundos para que a cópia seja feita no campo
			// A cópia acontece somente quando o return true é executado
			setTimeout(objPaste.call,20);		
		}
		
		return true;
	},
	// Função para formatar máscara no evento onBlur do campo
	setMaskOnBlur: function(tipo,formato,specialChars,objBlock) {
		// Formata valor do campo
		$(this).formataDado(tipo,formato,specialChars,false);		
				
		if (tipo.toUpperCase() == "INTEGER" || tipo.toUpperCase() == "DECIMAL" || (tipo.toUpperCase() == "STRING" && isNaN(formato))) {						
			// ------------------------------------------------------------------------------- //
			// Se for campo númerico, preenche com "0" (zeros) quando encontrar "9" no formato //
			// Ex: Formato: "zzz,zz.9,99" -> Valor digitado: "1" -> Valor formatado: "0,01"    //
			// ------------------------------------------------------------------------------- //
			
			// Encontra posição do primeiro caracter do valor informado na string de formato
			var posFim = formato.length - $(this).val().length;
			
			// Encontra posição do primeiro "9" na string de formato
			var pos9 = formato.substr(0,posFim).search("9");
			
			// Se foi encontrado algum "9" na string de formato
			if (pos9 != "-1") {
				var newValue = $(this).val();				

				for (var i = posFim - 1; i >= pos9; i--) {					
					newValue = formato.substr(i,1) == "9" ? "0" + newValue : formato.substr(i,1) + newValue;					
				}
				
				$(this).val(newValue);
			}
		} else if (tipo.toUpperCase() == "DATE") {

			// ------------------------------------------------------------------------------------------- //
			// Se for campo de data e o ano digitado tiver "2" digitos, transforma para ano de "4" digitos //
			// Ex: Formato: "99/99/9999" -> Valor digitado: "02/01/08" -> Valor formatado: "02/01/2008"    //
			// É verificado também se o valor digitado é uma data válida                                   //
			// ------------------------------------------------------------------------------------------- //
			
			// Métodos utilizados na mensagem de erro
			/*var strFunctions = "";
			strFunctions += $.trim(objBlock) != "" ? "blockBackground(parseInt($('#" + objBlock + "').css('z-index')));": "";			
			strFunctions += "$('#" + $(this).attr("id") + "').val('');";
			strFunctions += "$('#" + $(this).attr("id") + "').focus()";*/

			if ($(this).val().length != 8 && $(this).val().length != 10 && $(this).val() != "") {
				//showError("error","Data informada n&atilde;o &eacute; v&aacute;lida.","Alerta - Ayllos",strFunctions);
				$(this).val('').focus();
				return false;
			}
			
			var dia = $(this).val().substr(0,2);
			var mes = $(this).val().substr(3,2);
			var ano = $(this).val().substr(6);
			
			if (ano.length == 2) {
				if (parseInt("20" + ano) >= parseInt(new Date().getFullYear() + 30)) {
					ano = "19" + ano;
				} else {
					ano = "20" + ano;
				}
				
				$(this).val(dia + "/" + mes + "/" + ano);
			}			
			
			if (!validaData($(this).val()) && $(this).val() != "") {
				//showError("error","Data informada n&atilde;o &eacute; v&aacute;lida.","Alerta - Ayllos",strFunctions);
				$(this).val('').focus();
				return false;
			}			
		}
		
		return true;
	},
	// Função para formatar máscara no evento onKeyDown do campo
	setMaskOnKeyDown: function(tipo,formato,specialChars,e) {		
		if (tipo.toUpperCase() == "INTEGER" || tipo.toUpperCase() == "DECIMAL") { // Se for campo númerico
			if (tipo.toUpperCase() == "INTEGER") { // Se for inteiro				
				var maxSize = formato.replace(/\./g,"").replace(/-/g,"").length; // Número máximo de caracteres que podem ser digitados 
			} else if (tipo.toUpperCase() == "DECIMAL") { // Se for decimal
				var maxSize = formato.replace(/\./g,"").replace(/-/g,"").replace(/,/g,"").length;	// Número máximo de caracteres que podem ser digitados			
			}
			
			// Valida se tecla pressionada é um número e o tamanho da string
			if (!$(this).validaInteiroAndTamanho(maxSize,e)) {
				return false;
			}	
		} else if (tipo.toUpperCase() == "STRING") { // Se for um campo char
			var tecla  = getKeyValue(e);
			var objEdit = $(this).get(0);
			
			// Número máximo de caracteres que podem ser digitados			
			var maxSize = (isNaN(formato)) ? retiraCaracteres(formato,specialChars,false).length : formato;
			
			// Valida se tecla pressionada é um número e o tamanho da string
			var strVal = (isNaN(formato)) ? retiraCaracteres($(this).val(),specialChars,false) : $(this).val();				
			var size   = strVal.length;
			
			// Valida tecla númerica e tamanho máximo do conteúdo do campo
			if (size == maxSize && tecla != 8 && tecla != 9 && tecla != 46 && (tecla < 35 || tecla > 40)) {		
				if (objEdit.setSelectionRange) {
					var caret_pos_ini = objEdit.selectionStart;
					var caret_pos_fim = objEdit.selectionEnd;					
				} else if (document.selection) {
					var range         = document.selection.createRange();					
					var caret_pos_ini = 0 - range.duplicate().moveStart('character', -100000);
					var caret_pos_fim = caret_pos_ini + range.text.length;					
				}
				
				if (caret_pos_ini == caret_pos_fim) {
					return false;
				} 			
			} else if (size > maxSize) {				
				$(this).val(strVal.substr(0,maxSize));				
			}		
		} else if (tipo.toUpperCase() == "DATE") { // Se for um campo de data
			if (!$(this).validaInteiroAndTamanho(8,e)) {
				// Valida se tecla pressionada é um número e o tamanho da string
				return false;
			}
		}
		
		return true;
	},
	// Função para formatar máscara no evento onKeyUp do campo
	setMaskOnKeyUp: function(tipo,formato,specialChars,e) {				
		// Captura código da tecla pressionada
		var tecla = getKeyValue(e);	
		
		// Formata valor do campo somente se não for tecla de movimentação
		if ((tecla < 35 || tecla > 40) && tecla != 9 && tecla != 16) {
			$(this).formataDado(tipo,formato,specialChars,true);			
		}		

		return true;
	},
	// Função para formatar valor do campo
	formataDado: function(tipo,formato,specialChars,flgCaretPos) { 
		if ($(this).val() == "") { 
			return true;
		}
		
		var objEdit   = $(this).get(0);
		var caret_pos = 0;	

		if (flgCaretPos) { 					
			caret_pos = $(this).getCaretPosition().start; 
		}
		
		if (tipo.toUpperCase() == "INTEGER" || tipo.toUpperCase() == "DECIMAL" || tipo.toUpperCase() == "STRING")  { 						
			if (tipo.toUpperCase() == "INTEGER") { // Se for inteiro
				specialChars = ".-/"; // Caracteres especiais permitidos em um número inteiro
				var value = retiraCaracteres($(this).val(),"0123456789",true);
			} else if (tipo.toUpperCase() == "DECIMAL") { // Se for decimal
				specialChars = ".-,"; // Caracteres especiais permitidos em um número decimal
				var value = retiraCaracteres($(this).val(),"0123456789",true);
			}	else if (tipo.toUpperCase() == "STRING") { // Se for string							
				var value = retiraCaracteres($(this).val(),specialChars,(isNaN(formato) ? false : true));
				
				if (specialChars != charPermitido()) {
					value = retiraCaracteres(value,charPermitido(),true);
				}
			}
		
			if (tipo.toUpperCase() != "STRING" || (tipo.toUpperCase() == "STRING" && isNaN(formato))) {						
				var newValue = "";
				var j        = formato.length - 1;
				
				// Formatando valor do campo
				for (var i = value.length - 1; i >= 0; i--) {
					if (specialChars.search(formato.substr(j,1)) != "-1") {
						newValue = formato.substr(j,1) + newValue;
						j--;
					}
					
					newValue = value.substr(i,1) + newValue;
					j--;
				}

				caret_pos += newValue.length - $(this).val().length;
				
				// Retorna valor formatado
				$(this).val(newValue);				
			} else {
				$(this).val(value);
			}
		} else if (tipo.toUpperCase() == "DATE") { // Se for campo de data
			var value = retiraCaracteres($(this).val(),"0123456789",true);
			var size  = value.length;			
			
			// Formata e retorna valor
			if (size < 3) {
				$(this).val(value);
			} 
			if (size >= 3 && size <= 4) {
				caret_pos -= $(this).val().length;
				$(this).val(value.substr(0,2) + "/" + value.substr(2));
				caret_pos += $(this).val().length;
			}
			if (size >= 5 && size <= 8) {
				caret_pos -= $(this).val().length;
				$(this).val(value.substr(0,2) + "/" + value.substr(2,2) + "/" + value.substr(4));
				caret_pos += $(this).val().length;
			}
		}					
		
		if (flgCaretPos) {			
			$(this).setCaretPosition(caret_pos); 
		}			
		
		return true;
	},
	// Função para validar tecla pressionada e tamanho máximo do conteúdo do campo
	validaInteiroAndTamanho: function(maxSize,e) {
		var tecla   = getKeyValue(e);		
		var objEdit = $(this).get(0);
		
		// Se não foi pressionada tecla númerica, de movimentação, delete, backspace, tab ou enter
		if (!(tecla == 86 && e.ctrlKey) && !(tecla == 67 && e.ctrlKey) && tecla != 0 && tecla != 8 && tecla != 9 && tecla != 46 && tecla != 13 && (tecla < 35 || tecla > 40) && (tecla < 48 || tecla > 57) && (tecla < 96 || tecla > 105)) {
			return false;
		} else {
			var size = retiraCaracteres($(this).val(),"0123456789",true).length;							
			
			// Valida tecla númerica e tamanho máximo do conteúdo do campo
			if (size == maxSize && ((tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105))) {	
				var caret = $(this).getCaretPosition();
				var caret_pos_ini = caret.start;
				var caret_pos_fim = caret.end;				
				
				if (caret_pos_ini == caret_pos_fim) {
					return false;
				} 
				
				return true;
			} else if (size > maxSize) {
				$(this).val($(this).val().substr(0,maxSize));				
			}
		}
		
		return true;		
	},
	// Função para setar posição do cursor no campo
	setCaretPosition: function(pos) {
		var ctrl = $(this).get(0);
		
		if (ctrl.setSelectionRange) { 
			ctrl.focus(); 
			ctrl.setSelectionRange(pos,pos); 
		} else if (ctrl.createTextRange) { 
			var range = ctrl.createTextRange(); 
			range.collapse(true); 
			range.moveEnd('character', pos); 
			range.moveStart('character', pos); 
			range.select(); 
		} 
	},	
	// Função para obter posição do cursor no campo
	getCaretPosition: function() { 
		var el = $(this).get(0);
		var start = 0, end = 0, normalizedValue, range, 
			textInputRange, len, endRange; 

		if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") { 
			start = el.selectionStart; 
			end = el.selectionEnd; 			
		} else { 
			range = document.selection.createRange(); 

			if (range && range.parentElement() == el) { 
				len = el.value.length; 
				normalizedValue = el.value.replace(/\r\n/g, ""); 				
				
				// Create a working TextRange that lives only in the input 
				textInputRange = el.createTextRange(); 
				textInputRange.moveToBookmark(range.getBookmark()); 

				// Check if the start and end of the selection are at the very end 
				// of the input, since moveStart/moveEnd doesn't return what we want 
				// in those cases 
				endRange = el.createTextRange(); 
				endRange.collapse(false); 

				if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) { 
					start = end = len; 
				} else { 
					start = -textInputRange.moveStart("character", -len); 
					start += normalizedValue.slice(0, start).split("\n").length - 1; 

					if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) { 
						end = len; 
					} else { 
						end = -textInputRange.moveEnd("character", -len); 
						end += normalizedValue.slice(0, end).split("\n").length - 1; 
					} 			
				} 
			}
		}

		return { 
			start: start, 
			end: end 
		};		
	}
})