//************************************************************************//
//*** Fonte: navegacao.js                                              ***//
//*** Autor: Evandro(RKAM)                                             ***//
//*** Data : Julho/2016                 Última Alteração: 12/07/2016   ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de navegação de telas                     ***//
//***                                                                  ***//	 
//*** Alterações: 
//*** [19/07/2016] Evandro          (RKAM)   :  adicionado condição se não carregar conteudo atribui tabindex -1 ao campo
//***                                           adicionado encerraAnotacoes na condição ESC                        
             
//************************************************************************//

/** Navegação com o teclado nos campos **/
onload = function(){

    $(document.body).bind('keydown', function(e) {
        var target = e.target;
        switch (e.keyCode) {
            case 9://ALT
			    //se não carregar conteudo atribui tabindex -1 ao campo
			    var carregaTit = '';
				$('.SetFocus').each(function () {
					carregaTit = $(this).text(); //Carrega titulo da aba
					var CarregaName = $(this).attr("name"); //Carrega valor do name
					var TabValue = $(this).attr({tabindex : ''+CarregaName+''});//atribui o name a um tabindex para utilizar ao carregar novamente a consulta
					if(carregaTit == ' '){
						$(this).attr('tabindex', '-1');
					}
				});

			    //navega pra frente e pra tras
				var bShift = e.shiftKey;				
				if (bShift){
					var iSoma = -1;				
				}else{
					var iSoma = 1;
				}			
                return setFocusCampo($(target), e, false, iSoma);
            break;

            case 13://ENTER   			
				var simulaClick = $('.SetFocus:focus');
				simulaClick.trigger('click');
            break;	

            case 27://ESC
                $(".FirstInput:first").focus();

                var TituloWindow = '';
                TituloWindow = $(".SetWindow").text();//Capta titulo da janela modal
                if (TituloWindow) { // Se abrir janela modal
                    encerraRotina(true).click();
                }
                else {
				encerraAnotacoes().click();
				return false;
                }
            break;
			
            case 39://RIGHT	
				var bctrl = e.ctrlKey; //Combina Ctrl + seta direita				
				if (bctrl){
					var idAba = '';
					$('.txtBrancoBold').each(function () {
						idAba = $(this).attr('id');
					});
					var receive = idAba;

                    //Condições de navegação com seta right aba Capital(Atenda)
					var TituloAba = '';
					TituloAba = $(".titcap").text();//Capta titulo da aba
                    if (TituloAba == 'CAPITAL'){
						if (receive == 'linkAba0'){
							acessaOpcaoAba(5,1,'S').click();
							return false;
						}
						else if (receive == 'linkAba1'){
							acessaOpcaoAba(5,2,'P').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(5,3,'E').click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(5,4,'I').click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(7,6,'L').click();
							return false;
						};
					}//FIM Condições de navegação com seta right aba Capital

					
					
                    //Condições de navegação com seta right aba Depósitos à vista(Atenda)
					var TituloAba = '';
					TituloAba = $(".titdep").text();//Capta titulo da aba
                    if (TituloAba == 'DEPÓSITOS À VISTA'){
						if (receive == 'linkAba0'){
							acessaOpcaoAba(7,1,1).click();
							return false;
						}
						else if (receive == 'linkAba1'){
							acessaOpcaoAba(7,2,2).click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(7,3,3).click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(7,4,4).click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(7,5,5).click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(7,6,6).click();
							return false;
						}
						else if (receive == 'linkAba6'){
							acessaOpcaoAba(7,7,7).click();
							return false;
						};
					}//FIM Condições de navegação com seta right aba Depósitos à vista
					
					
					
                    //Condições de navegação com seta right aba Ocorrencias(Atenda)
					var TituloAba = '';
					TituloAba = $(".titoco").text();//Capta titulo da aba
                    if (TituloAba == 'OCORRÊNCIAS'){
						if (receive == 'linkAba0'){
							acessaOpcaoAba(6,1,1).click();
							return false;
						}
						else if (receive == 'linkAba1'){
							acessaOpcaoAba(6,2,2).click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(6,3,3).click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(6,4,4).click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(6,5,5).click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(6,6,6).click();
							return false;
						};
					}//FIM Condições de navegação com seta right aba Ocorrencias
					
					
					//Condições de navegação com seta right aba Limite Empresarial(Atenda)
					var TituloAba = '';
					TituloAba = $(".titlim").text();//Capta titulo da aba
                    if (TituloAba == 'LIMITE DE CRÉDITO' || TituloAba == 'LIMITE EMPRESARIAL' ||  TituloAba == 'LIMITE DE CR&Eacute;DITO'){
						if (receive == 'linkAba0'){
							acessaOpcaoAba(8,1,'N').click();
							return false;
						}
						else if (receive == 'linkAba1'){
							acessaOpcaoAba(8,2,'I').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(8,3,'U').click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(8,4,'A').click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(8,7,'P').click();
							return false;
						};
					}//FIM Condições de navegação com seta right aba Limite Empresarial(Atenda)
					
					
					//Condições de navegação com seta right aba Conta Investimento(Atenda)
					var TituloAba = '';
					TituloAba = $(".titinv").text();//Capta titulo da aba
                    if (TituloAba == 'CONTA INVESTIMENTO'){
						if (receive == 'linkAba0'){
							acessaOpcaoAba(4,1,'S').click();
							return false;
						}
						else if (receive == 'linkAba1'){
							acessaOpcaoAba(4,2,'C').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(4,3,'I').click();
							return false;
						};
					}//FIM Condições de navegação com seta right aba Conta Investimento(Atenda)
				}
            break;
	
	
			case 37://LEFT
                 var bctrl = e.ctrlKey; //Combina Ctrl + seta esquerda				
				 if (bctrl){  			
				    var idAba = '';
					$('.txtBrancoBold').each(function () {
						idAba = $(this).attr('id');
					});
					var receive = idAba;
					
					
                    //Condições de navegação com seta left aba Capital(Atenda)
					var TituloAba = '';
                    TituloAba = $(".titcap").text();//Capta titulo da aba
                    if (TituloAba == 'CAPITAL'){					
						if (receive == 'linkAba1'){
							acessaOpcaoAba(5,0,'@').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(5,1,'S').click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(5,2,'P').click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(5,3,'E').click();
							return false;
						}
						else if (receive == 'linkAba6'){
							acessaOpcaoAba(7,5,'').click();
							return false;
						};
					}//FIM Condições de navegação com seta left aba Capital(Atenda)
					
					
				    //Condições de navegação com seta left aba Depósitos à vista(Atenda)
					var TituloAba = '';
					TituloAba = $(".titdep").text();//Capta titulo da aba
                    if (TituloAba == 'DEPÓSITOS À VISTA'){
						if (receive == 'linkAba1'){
							acessaOpcaoAba(7,0,0).click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(7,1,1).click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(7,2,2).click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(7,3,3).click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(7,4,4).click();
							return false;
						}
						else if (receive == 'linkAba6'){
							acessaOpcaoAba(7,5,5).click();
							return false;
						};
					}//FIM Condições de navegação com seta left aba Depósitos à vista(Atenda)	
					
					
					//Condições de navegação com seta left aba Ocorrencias(Atenda)
					var TituloAba = '';
					TituloAba = $(".titoco").text();//Capta titulo da aba
                    if (TituloAba == 'OCORRÊNCIAS'){
						if (receive == 'linkAba1'){
							acessaOpcaoAba(6,0,0).click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(6,1,1).click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(6,2,2).click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(6,3,3).click();
							return false;
						}
						else if (receive == 'linkAba5'){
							acessaOpcaoAba(6,4,4).click();
							return false;
						};
					}//FIM Condições de navegação com seta left aba Ocorrencias(Atenda)
					
					
					//Condições de navegação com seta left aba Limite Empresarial(Atenda)
					var TituloAba = '';
					TituloAba = $(".titlim").text();//Capta titulo da aba
                    if (TituloAba == 'LIMITE DE CRÉDITO' || TituloAba == 'LIMITE EMPRESARIAL' ||  TituloAba == 'LIMITE DE CR&Eacute;DITO'){
						if (receive == 'linkAba1'){
							acessaOpcaoAba(8,0,'@').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(8,1,'N').click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(8,2,'I').click();
							return false;
						}
						else if (receive == 'linkAba4'){
							acessaOpcaoAba(8,3,'U').click();
							return false;
						}
						else if (receive == 'linkAba7'){
							acessaOpcaoAba(8,4,'A').click();
							return false;
						};
					}//FIM Condições de navegação com seta left aba Limite Empresarial(Atenda)
					
					
					//Condições de navegação com seta left aba Conta Investimento(Atenda)
					var TituloAba = '';
					TituloAba = $(".titinv").text();//Capta titulo da aba
                    if (TituloAba == 'CONTA INVESTIMENTO'){
						if (receive == 'linkAba1'){
							acessaOpcaoAba(4,0,'@').click();
							return false;
						}
						else if (receive == 'linkAba2'){
							acessaOpcaoAba(4,1,'S').click();
							return false;
						}
						else if (receive == 'linkAba3'){
							acessaOpcaoAba(4,2,'C').click();
							return false;
						};
					}//FIM Condições de navegação com seta left aba Conta Investimento(Atenda)
					
				}
            break;
			
        };
		
    });			
}






/** Determina se seta focus no objeto **/
function isSetFocusCampo(oObjeto) {
    $oAlvo = $(oObjeto);    
    if (($oAlvo.attr('readOnly')) || ($oAlvo.attr('disabled')) || (!$oAlvo.is(':visible'))) {
        return false;
    }
    return true;
}

/** Retorna todos os campos do Documento
* @param oDocument
* @return Array 
*/
function getCamposForm(oDocument) {
    var aTypes = ['input', 'textarea', 'select', 'button', 'a.SetFocus'];
    var aSelector = [];
    jQuery.each(aTypes, function() {
        aSelector.push(this);        
    });
    return $(aSelector.join(','), oDocument);      
}             

/** seta o focus no Objeto
* @param oObjetoAtual
* @param event
* @param aCampos
*/
function setFocusCampo(oObjetoAtual, event, aCampos, iSoma) {
	if ((oObjetoAtual.get(0).type.toUpperCase() == "BUTTON") || (oObjetoAtual.get(0).type.toUpperCase() == "")){
        return true;        
    }
    
	if (!aCampos) {
        var aCampos = getCamposForm(document.body);
    }                              
    
	if (event){
		event.stopPropagation();
		event.preventDefault();
	}
      
    //identifica o numero de campos a pular
    $(aCampos).each(function(i) {
        if (this == oObjetoAtual.get(0)) {
            try{
                 var oProximo = $(aCampos).eq(i + iSoma);
                 // Verifica se pode setar o focus no campo
                 if (isSetFocusCampo(oProximo)){
                     oProximo.get(0).focus();
                     return true;
                 }else{
                     return setFocusCampo(oProximo, event, aCampos, iSoma);
                 }
            }catch(e){
                return true;
            }
        }
    });
}