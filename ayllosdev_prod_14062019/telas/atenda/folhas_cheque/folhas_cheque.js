/************************************************************************
 Fonte: folhas_cheque.js                                          
 Autor: David                                                     
 Data : Fevereiro/2008               Ultima Alteracao: 27/06/2012 

 Objetivo  : Biblioteca de funcoes da rotina Folhas de Cheque da  
             tela ATENDA                                          
                                                                  	 
 Alteracoes: 27/06/2012 - Alterado esquema para impressao em      
						   carrega_lista() (Jorge)    			   
			 25/05/2018 - Criadas funcoes confirmaChequesNaoCompensados
						  e confirmaSolicitarTalonario. PRJ366 (Lombardi)
			 16/08/2018 - Criadas funcoes acessaEntregaTalonario, formataLayout, 
						  formataOpcoes, buscaContaPeloCPF, confimaEntregaTalonario, 
						  entregaTalonario, dscShowHideDiv, voltarConteudo, 
						  cartaoAssinatura e controlaFocoEnterComLink. 
						  Acelera - Entrega de Talonarios no Ayllos (Lombardi)
			 24/01/2019 - Criado campo qtreqtal. 
						  Acelera - Entrega de Talonarios no Ayllos (Lombardi)

************************************************************************/
var Ltpentrega1;
var Ltpentrega2;
var Lcpfterce;
var Lnmtercei;
var Ltprequis1;
var Ltprequis2;
var Lnrinichq;
var Lnrfinchq;
var Lqtreqtal;

var Ctpentrega1;
var Ctpentrega2;
var Ccpfterce;
var Cnmtercei;
var Ctprequis1;
var Ctprequis2;
var Cnrinichq;
var Cnrfinchq;
var Cqtreqtal;
var ultimoTalao;

// Funcao para carregar lista de cheques n&atilde;o compensados em PDF
function carrega_lista() {	
	
	var nmprimtl = $("#nmprimtl","#frmCabAtenda").val().search("E/OU") == "-1" ? $("#nmprimtl","#frmCabAtenda").val() : $("#nmprimtl","#frmCabAtenda").val().substr(0,$("#nmprimtl","#frmCabAtenda").val().search("E/OU") - 1);

	$("#nrdconta","#frmCheques").val(nrdconta);
	$("#nmprimtl","#frmCheques").val(nmprimtl);
	
	var action = $("#frmCheques").attr("action");
	var callafter = "encerraRotina(false);";
	
	carregaImpressaoAyllos("frmCheques",action,callafter);
}

function solicitarTalonario () {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, solicitando talonarios ...");
	
	var qtreqtal = $('#qtreqtal','#frmSolicitaTalonarios').val();
	
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/folhas_cheque/solicita_talonarios/solicitar_talonario.php',
        data: {
            nrdconta: nrdconta,
			qtreqtal: qtreqtal,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
			try {
                eval(response);
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            }
        }
    });
}

function validarAcessoLista () {
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'script',
        url: UrlSite + 'telas/atenda/folhas_cheque/lista_cheques_acesso.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
			try {
                eval(response);
				//carrega_lista();
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            }
        }
    });
}

function confirmaChequesNaoCompensados () {
	showConfirmacao('Deseja visualizar a rela&ccedil;&atilde;o de cheques n&atilde;o compensados?','Confirma&ccedil;&atilde;o - Aimaro','validarAcessoLista();','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');
}

function confirmaSolicitarTalonario () {
	
	var qtreqtal = $('#qtreqtal','#frmSolicitaTalonarios').val();
	
	if (qtreqtal == 0 || qtreqtal == '') {
		showError("error", "Informe a quantidade de tal&otilde;es a solicitar.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Cqtreqtal.focus();");
		return false;
	}
	
	showConfirmacao('Confirma a solicita&ccedil;&atilde;o do talon&aacute;rio?','Confirma&ccedil;&atilde;o - Aimaro','solicitarTalonario();','blockBackground(parseInt($("#divRotina").css("z-index")));Cqtreqtal.focus();','sim.gif','nao.gif');
}

function acessaEntregaTalonario () {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de entrega de talonarios ...");
	
	// Carrega biblioteca javascript da rotina
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/folhas_cheque/entrega_talonarios/form_entrega_talonarios.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));");
		},
		success: function(response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
					$("#divTalionario").html(response);
                    return false;
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
                }
            }
		}				
	});
}

function acessaSolicitaTalonario () {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de solicita&ccedil;&atilde;o de talonarios ...");
	
	// Carrega biblioteca javascript da rotina
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/folhas_cheque/solicita_talonarios/form_solicita_talonarios.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));");
		},
		success: function(response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
					$("#divTalionario").html(response);
                    return false;
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
                }
            }
		}				
	});
}

function formataLayout(nomeForm, ultimo_talao){

	if(typeof nomeForm == 'undefined'){ return false;}
	
	$('#'+nomeForm).addClass('formulario');
	
	highlightObjFocus( $('#' + nomeForm) );
	
	if( nomeForm == 'frmEntregaTalonarios' ) {
		
		Ltpentrega1 = $('label[for="tpentrega_1"]','#'+nomeForm);
		Ltpentrega2 = $('label[for="tpentrega_2"]','#'+nomeForm);
		Lcpfterce = $('label[for="cpfterce"]','#'+nomeForm);
		Lnmtercei = $('label[for="nmtercei"]','#'+nomeForm);
		Ltprequis1 = $('label[for="tprequis_1"]','#'+nomeForm);
		Ltprequis2 = $('label[for="tprequis_2"]','#'+nomeForm);
		Lnrinichq = $('label[for="nrinichq"]','#'+nomeForm);
		Lnrfinchq = $('label[for="nrfinchq"]','#'+nomeForm);
		Lqtreqtal = $('label[for="qtreqtal"]','#'+nomeForm);
		
		Ctpentrega1 = $('#tpentrega_1','#'+nomeForm);
		Ctpentrega2 = $('#tpentrega_2','#'+nomeForm);
		Ccpfterce = $('#cpfterce','#'+nomeForm);
		Cnmtercei = $('#nmtercei','#'+nomeForm);
		Ctprequis1 = $('#tprequis_1','#'+nomeForm);
		Ctprequis2 = $('#tprequis_2','#'+nomeForm);
		Cnrinichq = $('#nrinichq','#'+nomeForm);
		Cnrfinchq = $('#nrfinchq','#'+nomeForm);
		Cqtreqtal = $('#qtreqtal','#'+nomeForm);
		
		btnVoltar	 = $('#btnVoltar','#divBotoes');
		btnContinuar = $('#btnContinuar','#divBotoes');
		
		$('#'+nomeForm).css('width','400px');
		
		Ltpentrega1.css({'width':'110px','text-align':'left'});
		Lcpfterce.addClass('rotulo').css('width','90px');
		Lnmtercei.addClass('rotulo').css('width','90px');
		Ltprequis1.css({'width':'110px','text-align':'left'});
		Lnrinichq.addClass('rotulo').css('width','90px');
		Lnrfinchq.css('width','50px');
		Lqtreqtal.addClass('rotulo').css('width','90px');
		
		Ccpfterce.addClass('cpf').css('width','140px');
		Cnmtercei.css('width','290px');
		Cnrinichq.css({'width':'70px','text-align':'right'});
		Cnrinichq.setMask('INTEGER', 'zzzzzzz.9', '.', '');
		Cnrfinchq.css({'width':'70px','text-align':'right'});
		Cnrfinchq.setMask('INTEGER', 'zzzzzzz.9', '.', '');
		Cqtreqtal.css({'width':'35px','text-align':'right'});
		Cqtreqtal.setMask('INTEGER', 'zz9', '.', '');
		
		Ctpentrega1.attr('style', 'margin: 5px 3px 0px 3px !important; border: none !important; height: 16px !important;').habilitaCampo();
		Ctpentrega2.attr('style', 'margin: 5px 3px 0px 3px !important; border: none !important; height: 16px !important;').habilitaCampo();
		Ccpfterce.habilitaCampo();
		Cnmtercei.habilitaCampo();
		Ctprequis1.attr('style', 'margin: 5px 3px 0px 3px !important; border: none !important; height: 16px !important;').habilitaCampo();
		Ctprequis2.attr('style', 'margin: 5px 3px 0px 3px !important; border: none !important; height: 16px !important;').habilitaCampo();
		Cnrinichq.habilitaCampo();
		Cnrfinchq.habilitaCampo();
		Cqtreqtal.habilitaCampo();
		
		Ctpentrega1.focus();
		formataOpcoes();
		layoutPadrao();
		controlaFocoEnterComLink(nomeForm);
		
		//Evento keypress do campo Ccpfterce
		Ccpfterce.unbind('keydown').bind('keydown', function (e) {
			if ( divError.css('display') == 'block' ) { return false; }		
			if (e.keyCode == 9 || e.keyCode == 13) {
				$(this).removeClass('campoErro');
				Cnmtercei.focus();
				buscaContaPeloCPF(Ccpfterce.val().replace('-','').replace(/\./g, ""));
				return false;
			}
		});
		
		if (document.getElementById('#'+ultimo_talao) != null){
			ultimoTalao = $('#'+ultimo_talao,'#'+nomeForm);
			ultimoTalao.unbind('keydown').bind('keydown', function (e) {
				if ( divError.css('display') == 'block' ) { return false; }
				if (e.keyCode == 9 || e.keyCode == 13) {
					$(this).removeClass('campoErro');
					btnContinuar.focus();
					return false;
				}
			});
		}
		
		//Evento keypress do campo Ccpfterce
		btnVoltar.unbind('keydown').bind('keydown', function (e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if (e.keyCode == 9) {
				$(this).removeClass('campoErro');
				btnContinuar.focus();
				return false;
			}
		});
	} else if( nomeForm == 'frmSolicitaTalonarios' ) {
		
		Lqtreqtal = $('label[for="qtreqtal"]','#'+nomeForm);
		Cqtreqtal = $('#qtreqtal','#'+nomeForm);
		
		btnVoltar	 = $('#btnVoltar','#divBotoes');
		btnContinuar = $('#btnContinuar','#divBotoes');
		
		$('#'+nomeForm).css('width','400px');
		
		Lqtreqtal.addClass('rotulo').css('width','180px');
		Cqtreqtal.css({'width':'35px','text-align':'right'});
		Cqtreqtal.setMask('INTEGER', 'zz9', '.', '');
		Cqtreqtal.habilitaCampo();
		
		Cqtreqtal.focus();
		
		layoutPadrao();
		controlaFocoEnterComLink(nomeForm);
		
		//Evento keypress do campo Ccpfterce
		Cqtreqtal.unbind('keydown').bind('keydown', function (e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if (e.keyCode == 9 || e.keyCode == 13) {
				$(this).removeClass('campoErro');
				confirmaSolicitarTalonario();
				return false;
			}
		});
		
	}
	return false;
}

function formataOpcoes() {
	tpentrega = $('input[name="tpentrega"]:checked','#frmEntregaTalonarios').val();
	tprequis = $('input[name="tprequis"]:checked','#frmEntregaTalonarios').val();
	
	if (tpentrega == 0) {
		$('#divTerceiro','#frmEntregaTalonarios').css("display","none");
		Ccpfterce.val('');
		Cnmtercei.val('');
		Ccpfterce.desabilitaCampo();
		Cnmtercei.desabilitaCampo();
	} else {
		$('#divTerceiro','#frmEntregaTalonarios').css("display","block");
		Ccpfterce.habilitaCampo();
		Cnmtercei.habilitaCampo();
	}
	
	if (tprequis == 1) {
		$('#divTaloes','#frmEntregaTalonarios').css("display","block");
		$('#divContinuo','#frmEntregaTalonarios').css("display","none");
		Cnrinichq.val('');
		Cnrfinchq.val('');
		Cnrinichq.desabilitaCampo('');
		Cnrfinchq.desabilitaCampo('');
	} else {
		$('#divTaloes','#frmEntregaTalonarios').css("display","none");
		$('#divContinuo','#frmEntregaTalonarios').css("display","block");
		Cnrinichq.habilitaCampo('');
		Cnrfinchq.habilitaCampo('');
	}
}

function buscaContaPeloCPF(nrcpfcgc) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando nome do terceiro ...");
	
	// Carrega biblioteca javascript da rotina
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/folhas_cheque/entrega_talonarios/busca_conta_pelo_cpf.php",
		dataType: "html",
		data: {
			nrcpfcgc: nrcpfcgc,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
            }
		}				
	});
}

function confimaEntregaTalonario() {
	
	var tprequis = $('input[name="tprequis"]:checked','#frmEntregaTalonarios').val();
	var nrinichq = Number($('#nrinichq','#frmEntregaTalonarios').val().replace(".", ""));
	var nrfinchq = Number($('#nrfinchq','#frmEntregaTalonarios').val().replace(".", ""));
	var terceiro = $('input[name="tpentrega"]:checked','#frmEntregaTalonarios').val();
	var cpfterce = $('#cpfterce','#frmEntregaTalonarios').val().replace('-','').replace(/\./g, "");
	var nmtercei = $('#nmtercei','#frmEntregaTalonarios').val();
	var nrtaloes = '';
	var executa;
	
	$("input:checkbox[name=talao]:checked").each(function(i, el){
        if (nrtaloes.length > 0) {
			nrtaloes += ';';
		}
		nrtaloes += $(this).attr("id");
    });
	
	if (terceiro == '1' && (cpfterce == 0 || cpfterce == '' || nmtercei == '')) {
		showError("error", "Informe CPF e Nome do Terceiro.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Ccpfterce.focus();");
		return false;
	}
	
	if (tprequis == '1' && nrtaloes == '') {
		showError("error", "Nenhum tal&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Cnrinichq.focus();Ctpentrega1.focus();");
		return false;
	}
	
	if (tprequis == '2') {
		if (nrinichq == 0 || nrinichq == '') {
			showError("error", "Informe folha inicial.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Cnrinichq.focus();");
			return false;
		}
		
		if (nrfinchq == 0 || nrfinchq == '') {
			showError("error", "Informe folha final.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Cnrfinchq.focus();");
			return false;
		}
		
		if (nrinichq > nrfinchq) {
			showError("error", "Numero dos cheques errados.", "Alerta - Aimaro", "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));Cnrfinchq.focus();");
			return false;
		}
	}
	
	showConfirmacao("Deseja entregar o talon&aacute;rio?","Confirma&ccedil;&atilde;o - Aimaro","entregaTalonario(1)","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))","sim.gif","nao.gif");
}

function entregaTalonario(verifica) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando entrega de talonarios...");
	
	var tprequis = $('input[name="tprequis"]:checked','#frmEntregaTalonarios').val();
	var nrinichq = Number($('#nrinichq','#frmEntregaTalonarios').val().replace(".", ""));
	var nrfinchq = Number($('#nrfinchq','#frmEntregaTalonarios').val().replace(".", ""));
	var terceiro = $('input[name="tpentrega"]:checked','#frmEntregaTalonarios').val();
	var cpfterce = $('#cpfterce','#frmEntregaTalonarios').val().replace('-','').replace(/\./g, "");
	var nmtercei = $('#nmtercei','#frmEntregaTalonarios').val();
	var qtreqtal = $('#qtreqtal','#frmEntregaTalonarios').val();
	var nrtaloes = '';
	
	$("input:checkbox[name=talao]:checked").each(function(i, el){
        if (nrtaloes.length > 0) {
			nrtaloes += ';';
		}
		nrtaloes += $(this).attr("id");
    });
	
	// Carrega biblioteca javascript da rotina
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/folhas_cheque/entrega_talonarios/entrega_talonarios.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			tprequis: tprequis,
			nrinichq: nrinichq,
			nrfinchq: nrfinchq,
			terceiro: terceiro,
			cpfterce: cpfterce,
			nmtercei: nmtercei,
			nrtaloes: nrtaloes,
			qtreqtal: qtreqtal,
			verifica: verifica,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));");
            }
		}				
	});
}

function dscShowHideDiv(show,hide) {
	var divShow = show.split(";");
	var divHide = hide.split(";");
	
	for (var i = 0; i < divShow.length; i++) {
		$("#" + divShow[i]).css("display","block");
	}
	
	for (var i = 0; i < divHide.length; i++) {
		$("#" + divHide[i]).css("display","none");
	}	
}

function voltarConteudo(show,hide) {
	
	if (hide == 'divTalionario')
		$("#divTalionario").html('');
	
	dscShowHideDiv(show,hide);
}

function cartaoAssinatura(){
	
	var flgdigit = $("#hdnFlgdig", "#frmCabAtenda").val();
	
	if (flgdigit != "yes" && flgdigit != "S")
		return false;
	
	var mensagem = 'Aguarde, acessando dossie...';
	showMsgAguardo( mensagem );
	
	// Carrega dados da conta através de ajax
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/digdoc.php',
		data    :
				{
					nrdconta	: nrdconta,
					cdproduto   : 9, // Cartão Assinatura
                    nmdatela    : 'ATENDA',
 					redirect	: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					blockBackground(parseInt($('#divRotina').css('z-index')));
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval( response );
							return false;
						} catch(error) {
							hideMsgAguardo();							
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					} else {
						try {
							eval( response );							
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					}
				}
	});

	return false;
}	  

function controlaFocoEnterComLink(frmName) {

    var cTodos = $("input[type='text'],input[type='radio'],input[type='checkbox'],select,textarea", '#' + frmName);

    cTodos.unbind('keypress').bind('keypress', function (e) {
		
        if (e.keyCode == 9 || e.keyCode == 13) {
				
			var indice = cTodos.index(this);	
				
			while (true) {
			
				indice++;
				
				// Desconsiderar os que estao bloqueados
				if (jQuery(cTodos[indice]).hasClass('campoTelaSemBorda')) {
					continue;
				}

				//Desconsiderar os que estao com display none
				if (jQuery(cTodos[indice]).css('display') == 'none') {					
					continue;
				}

				// Se campo nao e' nullo, focar no proximo
                if (cTodos[indice] != null) {
					cTodos[indice].focus();
				}
			
				break;

			}										
			return false;
		}
	});

}	  
