/*************************************************************************
 Fonte: internet.js                                               
 Autor: David                                                     
 Data : Junho/2008                   Última Alteração: 13/12/2017
                                                                  
 Objetivo  : Biblioteca de funções da rotina de Internet da tela  
             ATENDA                                               
                                                                  
 Alterações: 03/09/2009 - Melhorias na rotina de Internet (David) 
                                                                  
             22/10/2010 - Alteracao na acessaOpcaoAba (David)     
																  
			 10/01/2011 - Retirar a parte de Cobranca (Gabriel)  
                                                                  
             08/07/2011 - Tratado na funcao selecionaTitularInternet,
						  a habilitacao do botao Liberacao (Fabricio)          
						                                          
			 13/07/2011 - Alterado para layout padrão (Gabriel - DB1)
						                                          
			 17/05/2012 - Projeto TED Internet	(Lucas)           
						                                          
			 27/06/2012 - Alterado funcao carregarContrato(),    
						  novo esquema para impressao.(Jorge)    
						                                          
             07/11/2012 - Permitir atualização das Letras de	  	 
		  				  Segurança juntamente com a Senha da    	 
						  Internet (Lucas).                      
						                                          
			 11/11/2012 - Incluso tratamento para os campos      
						  dtlimtrf dtlimpgo dtlimted dtlimweb 	  
						  e layout da tela (Daniel).             	 
						                                          
	         11/01/2013 - Requisitar cadastro de Letras ao       
						  liberar acesso (Lucas).   
						   
 			 08/04/2013 - Transferencia intercooperativa(Gabriel)
																   
			 23/04/2013 - Incluido novos campos referente ao      
                          cadastro de limites Vr Boleto           
  						  (David Kruger).						   
						                                           
             31/07/2013 - Correção transferencia intercoop. (Lucas)
						                                          
			 02/08/2013 - Alterado layout de Internet, adicionado
					      campo "Data Bloqueio Senha". (Jorge)   
						                                          
			 18/12/2014 - Melhorias Cadastro de Favorecidos TED  
                         (André Santos - SUPERO) 	 			  
                                                                  
             24/04/2015 - Inclusão do campo ISPB SD271603 FDR041  
						  e ajustes(Vanessa) 					  

             01/10/2015 - Ajuste para inclusão das novas telas "Produtos"
						  (Gabriel - Rkam -> Projeto 217).	

			 17/11/2015 - Alterações para o PRJ. Ass. Conjunta (Jean Michel) 

             12/04/2016 - Remocao Aprovacao Favorecido. (Jaison/Marcos - SUPERO)

		     30/08/2016 - Adição dos campos de data e hora de acesso ao Mobile e
                          formatação da tela (Dionathan).
						  
             07/09/2016 - Adicionado função controlaFoco.(Evandro - RKAM).

             26/08/2016 - Alteracao da function validaResponsaveis, SD 510426 (Jean Michel)

             13/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
	                      crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
						  (Adriano - P339).	
             05/09/2017 - Alteração referente ao Projeto Assinatura conjunta (Proj 397)

             04/09/2017 - Inclusão de novas functions, Prj. 354 (Jean Michel)
			 
			 13/12/2017 - Chamado 793407 - Ajustar teste para esconder botões em caso 
			              de operadores (Andrei-MOUTs)

*********************************************************************************/

var callafterInternet = '';
var idseqttl = 1;  // Variável para armazenar sequencial do titular selecionado
var nrcpfcgc = 0;  // Variável para armazenar CPF do preposto
var cpfpreat = 0;  // Variável para armazenar CPF do preposto atual
var nrctatrf = 0;  // Variável para armazenar conta selecionada

var reg      = new Array();
var ObjReg   = new Object();
var arrayPend = new Array();
var arrayCampos = new Array();
var arrayConfirma = new Array();
var strHTML    = '';
var tamanhoDiv = '';

var idastcjt;
var qtdTitular;
var confPJ = false;
var exibePJ = false;

var idmobile;

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) { 
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados dos titulares ...");

	// Atribui cor de destaque para aba da opção
	$("#linkAba0").attr("class","txtBrancoBold");
	$("#imgAbaEsq0").attr("src",UrlImagens + "background/mnu_sle.gif");				
	$("#imgAbaDir0").attr("src",UrlImagens + "background/mnu_sld.gif");
	$("#imgAbaCen0").css("background-color","#969FA9"); 
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/internet/principal.php",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
            controlaFoco();
		}				
	});
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao #divInternetPrincipal').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
        if ($('.LastInputModal').attr('disabled')) {//Se LastInputModal for disabled
            $('#divConteudoOpcao #divInternetPrincipal #liberacao').addClass("LastInputModal");
            $('#divConteudoOpcao #divInternetPrincipal').find("#divBotoes > :input[type=image]").last().removeClass("LastInputModal");
        }
    });

    $('#divConteudoOpcao #frmLiberarSenha').each(function () {
        $(this).find(":input[type=password]").first().addClass("FirstInputModal").focus();
        $(this).find(":input[type=image]").addClass("FluxoNavega");
        $(this).find(":input[type=image]").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 27) {
                e.stopPropagation();
                e.preventDefault();
                encerraRotina().click();
            }
        });
    });

    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();
            if (e.keyCode == 13) {
                $(this).click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });

    });

    $(".FirstInputModal").focus();
}

// Função para seleção de titular para consulta e alteração de dados
function selecionaTitularInternet(id,qtTitulares,cpf,idastcjt,titularidade,sqttl,cpfcgc) {
	
	// Formata cor da linha da tabela que lista titulares e esconde div com dados do mesmo
	for (var i = 1; i <= qtTitulares; i++) {		
				
		// Esconde div com dados do titular
		$("#divTitInternetOpe" + i).css("display","none");
		$("#divTitInternet" + i).css("display","none");
	}
		
	// Mostra div com os dados do titular selecionado
	$("#divTitInternetOpe" + id).css("display","block");
	if(sqttl == "999"){
      id = 1;
    }
	$("#divTitInternet" + id).css("display","block");
	
		if (sqttl == "999"){
			$('#divBotoes').hide();
			$('#preoroper').html('OPERADOR');
	}else{
			$('#preoroper').html('PREPOSTO');
			$('#divBotoes').show();
		}
		
	if(idastcjt == "1"){
		// Mostra CPF do titular no título da área de dados
		$("#spanSeqTitular").html(cpf);
	}else{
		// Mostra sequência do titular no título da área de dados
		$("#spanSeqTitular").html(id);	
	}
	
	$("#divInternetPrincipal > #divBotoes > input").each(function() {
		$(this).prop("disabled",false);
	});
	
	//Não permite acessar "LIBERAÇÃO" se a senha estiver ativa
	if ($("#dssitsnh" + id).val() == "ATIVA") {
		$("#liberacao").prop("disabled",true);
	} else {
		$("#liberacao").removeProp("disabled");
	}
	
	//Não permite acessar "HABILITAÇÃO" se a senha não estiver ativa
	if ($("#dssitsnh" + id).val() != "ATIVA") {
		$("#habilitacao").prop("disabled",true);
	} else {
		$("#habilitacao").removeProp("disabled");
	}
	
	//Só permite acesso a opção LIBERAÇÃO se estiver INATIVA
	if ($("#dssitsnh" + id).val() == "INATIVA") {
		$("#divInternetPrincipal > #divBotoes > input").each(function() {
			if ($(this).attr("id") != "liberacao") {
				$(this).prop("disabled",true);
			} else {
				$(this).removeProp("disabled");
			}			
		});
	}
	
	// Armazena sequencial do titular selecionado
	idseqttl = titularidade;
	nrcpfcgc = cpfcgc;
	idastcjt = idastcjt;
}

// Função para bloquear senha de acesso ao InternetBank
function bloqueiaSenhaAcesso() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, bloqueando senha de acesso ...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/bloqueia_senha_acesso.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
			    eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para cancelar senha de acesso ao InternetBank
function cancelaSenhaAcesso(inconfir) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando senha de acesso ...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/cancela_senha_acesso.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			inconfir: inconfir,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para mostrar div da opção Principal
function mostraOpcaoPrincipal() {

	// Se a tela foi chamada pela rotina "Produtos" então encerra a rotina.
	if(executandoProdutos == true){
		encerraRotina(true);
		return false;
	}
	
	$("#divInternetPrincipal").css("display","block");
	$("#divAlterarSenha").css("display","none");
	$("#divLiberarSenha").css("display","none");
	$("#divNumericaLetras").css("display","none");
	$('#frmSenhaLetras').css('display','none');
	
	// Aumenta tamanho do div onde o conteúdo da opção será visualizado
	$("#divConteudoOpcao").css("height",tamanhoDiv); 
	
}

// Função para mostrar div de alteração de senha
function mostraDivAlteraSenha() {

	if ($("#cddopcao","#frmSenhaLetras").val() == "L") {
	
		acessaOpcaoAba('0','0','@');
		$("#cddopcao","#frmSenhaLetras").val("");
	
	} else {

		$("#divInternetPrincipal").css("display","none");
		$("#divAlterarSenha").css("display","none");
		$('#frmSenhaLetras').css('display','none');
		$('#divNumericaLetras').css('display','block');
		$('#divConteudoOpcao').css('height','50px');
		
	}
	
}

// Função para mostrar div de alteração de senha numérica
function mostraDivAlteraSenhaNum() {

	$("#cddsenha","#frmAlterarSenha").val("");
	$("#cdsnhnew","#frmAlterarSenha").val("");
	$("#cdsnhrep","#frmAlterarSenha").val(""); 
	
	$("#divInternetPrincipal").css("display","none");
	$('#divNumericaLetras').css('display','none');
	$('#frmSenhaLetras').css('display','none');
	$("#divAlterarSenha").css("display","block");
	
	$('#divConteudoOpcao').css('height','150px');
	
}

// Função para mostrar div de alteração das letras
function mostraDivAlteraSenhaLetras(cddopcao) {

	formataSenhaLetras();
	
	$("#divInternetPrincipal").css("display","none");
	$('#divNumericaLetras').css('display','none');
	$("#divAlterarSenha").css("display","none");
	$("#divLiberarSenha").css("display","none");
	$('#frmSenhaLetras').css('display','block');
	
	$("#cddopcao","#frmSenhaLetras").val(cddopcao);
	
	$('#divConteudoOpcao').css('height','150px');
	
}


// Função formata o formulario de alteração das letras
function formataSenhaLetras() {
	
	var nomeForm = 'frmSenhaLetras';
	
	// label
	var rDssennov = $('label[for="dssennov"]', '#'+nomeForm);
	var rDssencon = $('label[for="dssencon"]', '#'+nomeForm);
	
	rDssennov.addClass('rotulo').css({'width':'220px'});
	rDssencon.addClass('rotulo').css({'width':'220px'});
	
	// campos
	var cDssennov = $('#dssennov', '#'+nomeForm);
	var cDssencon = $('#dssencon', '#'+nomeForm);
	
	cDssennov.addClass('campo').css({'width':'50px'});
	cDssencon.addClass('campo').css({'width':'50px'});
	
	$("#divMagneticosPrincipal").css("display","none");
	$("#divMagneticosOpcao01").css("display","block");
	
	cDssennov.focus();
	
	layoutPadrao();
	return false;
}

// Função para alterar letras de segurança
function alterarSenhaLetrasCartao() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando as Letras de Seguran&ccedil;a...");
	
	var dssennov = $("#dssennov","#frmSenhaLetras").val();	
	var dssencon = $("#dssencon","#frmSenhaLetras").val();	
	
	// Executa script de alteração de senha através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/alterar_senha_letras.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			dssennov: dssennov,
			dssencon: dssencon,
			executandoProdutos: executandoProdutos,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}

	});				
}

// Função para mostrar div de liberação de senha
function mostraDivLiberaSenha() {
		
	$("#divInternetPrincipal").css("display","none");
	$("#divLiberarSenha").css("display","block");
	$('#divConteudoOpcao').css('height','150px');
	
	$("#cdsnhrep","#frmLiberarSenha").val("");
	$("#cdsnhnew","#frmLiberarSenha").val("").focus();

}

// Função para cancelar senha de acesso ao InternetBank
function alteraSenhaAcesso() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando senha de acesso ...");
	
	var cddsenha = $("#cddsenha","#frmAlterarSenha").val();
	var cdsnhnew = $("#cdsnhnew","#frmAlterarSenha").val();	
	var cdsnhrep = $("#cdsnhrep","#frmAlterarSenha").val();
	
	if (cddsenha == "") {
		hideMsgAguardo();
		showError("error","Informe a senha atual.","Alerta - Ayllos","$('#cddsenha','#frmAlterarSenha').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;				
	}
	
	if (cdsnhnew == "") {
		hideMsgAguardo();
		showError("error","Informe a nova senha.","Alerta - Ayllos","$('#cdsnhnew','#frmAlterarSenha').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;				
	}
	
	if (cdsnhrep == "") {
		hideMsgAguardo();
		showError("error","Confirme a nova senha.","Alerta - Ayllos","$('#cdsnhrep','#frmAlterarSenha').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;				
	}	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/altera_senha_acesso.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			cddsenha: cddsenha,
			cdsnhnew: cdsnhnew,
			cdsnhrep: cdsnhrep,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para cancelar senha de acesso ao InternetBank
function liberaSenhaAcesso() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, liberando senha de acesso ...");
	
	var cdsnhnew = $("#cdsnhnew","#frmLiberarSenha").val();	
	var cdsnhrep = $("#cdsnhrep","#frmLiberarSenha").val();
	
	if (cdsnhnew == "") {
		hideMsgAguardo();
		showError("error","Informe a nova senha.","Alerta - Ayllos","$('#cdsnhnew','#frmLiberarSenha').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;				
	}
	
	if (cdsnhrep == "") {
		hideMsgAguardo();
		showError("error","Confirme a nova senha.","Alerta - Ayllos","$('#cdsnhrep','#frmLiberarSenha').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;				
	}		
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/libera_senha_acesso.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			cdsnhnew: cdsnhnew,
			cdsnhrep: cdsnhrep,
			executandoProdutos: executandoProdutos,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para carregar impressao de contrato em PDF
function carregarContrato(flgletca,flgimpte) {

    $("#nrdconta","#frmImpressaoInternet").val(nrdconta);
    $("#idseqttl","#frmImpressaoInternet").val(idseqttl);
    
    var action = $("#frmImpressaoInternet").attr("action");
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
    var msgLetras = 'showError("inform","Necess&aacute;rio cadastramento das Letras de Seguran&ccedil;a.","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
	
    if (flgletca == "no") {
	
        callafterInternet = '';
        callafter = msgLetras + "mostraDivAlteraSenhaLetras('L');" + callafter;
    }
	
    if (callafterInternet != '') {
        callafter = callafterInternet;
    }
		
    if (flgimpte == "yes") {
        carregaImpressaoAyllos("frmImpressaoInternet", action, callafter);
    } else {
        blockBackground(parseInt($('#divRotina').css('z-index')));
        if (flgletca == "no") {
            mostraDivAlteraSenhaLetras('L');
        } else {
            acessaOpcaoAba('0', '0', '@');
        }
    }
}

function carregaHabilitacao() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de habilita&ccedil;&atilde;o ...");
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/obtem_dados_habilitacao.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			idastcjt: idastcjt,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
		}				
	});
}

function carregaContas() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando cadastramento de contas ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
		}				
	});
}

function redimensiona() {

	//Volta o div de conteúdo ao seu tamanho original
	$("#divConteudoOpcao").css("width","565");
	
	return false;
}

//Funcao para controlar lista de Cnts. Cadatr.
function controlaListaCntsCad() {
	
	var tabDados	= 'tabContas';
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'100px','padding-bottom':'2px'});

	var ordemInicial = new Array();
	
	//Define qual config de colunas usar dependendo do nagegador
	if ( $.browser.msie ) {
	
		var arrayLargura = new Array();
		arrayLargura[0] = '120px';
		arrayLargura[1] = '100px';
		arrayLargura[2] = '350px';
		arrayLargura[3] = '0px';
				
	} else {

		var arrayLargura = new Array();
		arrayLargura[0] = '120px';
		arrayLargura[1] = '96px';
		arrayLargura[2] = '384px'; 
		arrayLargura[3] = '96px';
					
	}
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'center';
		
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

}

function obtemCntsCad(intipdif) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando contas ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_cadastradas.php",
		//dataType: "html",
		data: {
			intipdif: intipdif,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			
		}				
	});
}

function detalhesCntsCad(seq) {

	var objForm;
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, detalhes da conta ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_cadastradas_detalhes.php",
		//dataType: "html",
		data: {
			intipdif: reg[seq].intipdif,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			
				$("#tabContas").css("display","none");
				
				//Define que Form mostrar depenendo do tipo de IF: 1: Coop // 2: Outras IFs
				if (reg[seq].intipdif == 1){
				
					objForm = $('#frmDetalhesCoop');
					
					$("#frmDetalhesCoop").css("display","block");
					$("#frmDetalhesOtr").css("display","none");
					
				} else {
				
					objForm = $('#frmDetalhesOtr');
					
					$("#frmDetalhesCoop").css("display","none");
					$("#frmDetalhesOtr").css("display","block");
					
				}
				
				//Retorna os botoes à sua posição atual
				$("#btConcluir", objForm).css("display","none");
				$("#btAlterar",  objForm).css("display","block");
				
				//Esconde campos de CPF/CNPJ
				$('#CPF',objForm).css("display","none");
				$('#CNPJ',objForm).css("display","none");
				
				//Exibe elementos dos Forms de acordo com o Tp Pessoa
				if (reg[seq].inpessoa == 1){
				
					$('#CPF',objForm).css("display","block");
					$('#CPF',objForm).css("padding-left","26");
					
				} else {
				
					$('#CNPJ',objForm).css("display","block");
					$('#CNPJ',objForm).css("padding-left","18");
					
				}

				//Define qual opcao estara selecionada dependendo da Sit. da Conta
				$("#insitcta option[value= " + reg[seq].insitcta + " ]",objForm).prop('selected',true);
				
				//Define qual opcao estára selecionada dependendo do Tipo da Conta
				$("#intipcta option[value= " + reg[seq].intipcta + " ]",objForm).prop('selected',true);
							
				//Associa valores aos campos
				$('#cddbanco',objForm).val(reg[seq].cddbanco);
				$('#cdageban',objForm).val(reg[seq].cdageban);
                $('#cdispbif',objForm).val(reg[seq].cdispbif);
				$('#nrctatrf',objForm).val(reg[seq].nrctatrf);
				$('#nmtitula',objForm).val(reg[seq].nmtitula);
				$('#nrcpfcgc',objForm).val(reg[seq].dscpfcgc);
				$('#dstransa',objForm).val(reg[seq].dstransa);
				$('#dsoperad',objForm).val(reg[seq].dsoperad);
				$('#insitcta',objForm).val(reg[seq].insitcta);
				$('#intipdif',objForm).val(reg[seq].intipdif);
				$('#dsctatrf',objForm).val(reg[seq].dsctatrf);
				$('#inpessoa',objForm).val(reg[seq].inpessoa);
				$('#intipcta',objForm).val(reg[seq].intipcta);
				$('#dsageban',objForm).val(reg[seq].dsageban);
				
				//Desabilita elementos do form
				$('input', objForm).desabilitaCampo();
				$('select', objForm).desabilitaCampo();
								
			}				
	});

}

function habilitaAlterarDados(Form) {

	var intipdif = $('#intipdif','#'+Form).val();
	var inpessoa = $('#inpessoa','#'+Form).val();
	
	//Esconde campos de CPF/CNPJ
	$('#CPF','#'+Form).css("display","none");
	$('#CNPJ','#'+Form).css("display","none");
		
	//Aplica mascara de CPF ou CNPJ para digitação
	if (inpessoa == 1){
	
		$('#nrcpfcgc','#'+Form).setMask('INTEGER','999.999.999-99','.-','');
		$('#CPF','#'+Form).css("display","block");
		$('#CPF','#'+Form).css("padding-left","26");
	}
	if (inpessoa == 2){
	
		$('#nrcpfcgc','#'+Form).setMask('INTEGER','z.zzz.zzz/zzzz-zz','/.-','');
		$('#CNPJ','#'+Form).css("display","block");
		$('#CNPJ','#'+Form).css("padding-left","18");
		
	}
	
	//Permite a edição do Tit. e CPF/CNPJ somente se a conta pertence a outra IF
	if (intipdif == 2){
		$("#nmtitula",'#'+Form).setMask("STRING","40",charPermitido(),"");
		$('#nmtitula','#'+Form).habilitaCampo();
		$('#nrcpfcgc','#'+Form).habilitaCampo();
				
	} 
	
	//Habilita a Opção de alteração dependendo do Form informado [parametro]
	$('select','#'+Form).habilitaCampo();
	$("#btConcluir",'#'+Form).css("display","block");
	$("#btAlterar", '#'+Form).css("display","none");
	
	//Foca no próximo campo caso pressine ENTER 
	$('#nmtitula','#'+Form).keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#nrcpfcgc','#'+Form).focus(); 
			return false; 
		}		
	});
	
	$('#nrcpfcgc','#'+Form).keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#inpessoa','#'+Form).focus(); 
			return false;
		} 
	});
	
	$('#inpessoa','#'+Form).keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#intipcta','#'+Form).focus(); 
			return false; 
		}
	});
	
	$('#intipcta','#'+Form).keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#insitcta','#'+Form).focus(); 
			return false; 
		}		
	});
	
	$('#insitcta','#'+Form).keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#btConcluir','#'+Form).focus(); 
			return false; 
		}		
	}); 

}

function validaDadosConta(nomeForm) {

	// Mostra mensagem de aguardo
	//showMsgAguardo("Aguarde, validando alteracoes ...");
	
	var insitcta = $('#insitcta', '#'+nomeForm).val();
	var nrctatrf = $('#nrctatrf', '#'+nomeForm).val();	
	var cddbanco = $('#cddbanco', '#'+nomeForm).val();
	var cdageban = $('#cdageban', '#'+nomeForm).val();
	var nrcpfcgc = $('#nrcpfcgc', '#'+nomeForm).val();
	var inpessoa = $('#inpessoa', '#'+nomeForm).val();
	var intipcta = $('#intipcta', '#'+nomeForm).val();
	var nmtitula = $('#nmtitula', '#'+nomeForm).val();
	var intipdif = $('#intipdif', '#'+nomeForm).val();
    var cdispbif = $('#cdispbif', '#'+nomeForm).val();

	//Verifica se o Nome do Titular foi digitado
	if (nmtitula == "") {
		hideMsgAguardo();
		showError("error","Informe o Nome do Titular.","Alerta - Ayllos","focaCampoErro('#nmtitula', '# "+ nomeForm + "');bloqueiaFundo(divRotina)");
		return false;				
	}
	
	nrcpfcgc = normalizaNumero(nrcpfcgc);				
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeForm).removeClass('campoErro');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_cadastradas_alterar_validar.php",
		//dataType: "html",
		data: {
			cddbanco: cddbanco,
            cdispbif: cdispbif,
			nrcpfcgc: nrcpfcgc,
			nrctatrf: nrctatrf,
			cdageban: cdageban,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			intipcta: intipcta,
			inpessoa: inpessoa,
			nmtitula: nmtitula,
			insitcta: insitcta,
			intipdif: intipdif,
			nomeForm: nomeForm,                        
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) { 
			eval(response);	
		}				
	});
}

function alteraDadosConta(intipdif,nomeForm) {
		
	var insitcta = $('#insitcta', '#'+nomeForm).val();
	var nrctatrf = $('#nrctatrf', '#'+nomeForm).val();
	
	var nmtitula = $('#nmtitula', '#'+nomeForm).val();
	var cddbanco = $('#cddbanco', '#'+nomeForm).val();
	var cdageban = $('#cdageban', '#'+nomeForm).val();
	var nrcpfcgc = $('#nrcpfcgc', '#'+nomeForm).val();
	var inpessoa = $('#inpessoa', '#'+nomeForm).val();
	var intipcta = $('#intipcta', '#'+nomeForm).val();
	var insitcta = $('#insitcta', '#'+nomeForm).val(); 
		
	nrcpfcgc = normalizaNumero(nrcpfcgc);
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando dados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_cadastradas_alterar_confirmar.php",
		//dataType: "html",
		data: {
			intipdif: intipdif,
			cddbanco: cddbanco,
			nrcpfcgc: nrcpfcgc, 
			nrctatrf: nrctatrf,
			cdageban: cdageban,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			intipcta: intipcta,
			inpessoa: inpessoa,
			nmtitula: nmtitula,
			insitcta: insitcta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
				eval(response);	
			
		}				
	});
}

function InclusaoContas() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando formulario ...");
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_incluir.php",
		//dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			controlaLupas();
		}				
	});
}

function limpaFormularios() {

	$('#frmInclCoop').limpaFormulario();
	$('#frmInclOtr').limpaFormulario();
	
}

function exibeFormInclusaoContas(intipdif) {

	//Esconde botão de voltar
	$('#voltar').css("display", "none");
	
	//Exibe Forms dependendo do tipo de IF
	if (intipdif == 1){	
		$("#frmInclCoop").css("display","block");
		$("#frmInclOtr").css("display","none");
		$('#nmtitula', "#frmInclCoop").desabilitaCampo();
		$('#dscpfcgc', "#frmInclCoop").desabilitaCampo();
		$("#cdagectl","#frmInclCoop").setMask('INTEGER','zzzz','/.-','');
		$("#nrctatrf","#frmInclCoop").setMask("INTEGER","zzzz.zzz-z","","");
		$('#cdagectl','#frmInclCoop').focus();
		
		$('#nrctatrf','#frmInclCoop').keypress( function(e) {
			if ( e.keyCode == 13 ) { 
				ValidaInclConta(1, true); 
				return false; 
			}		
		});
		
		$("#divConteudoOpcao").css("height","265");
	} else {	
		$("#frmInclCoop").css("display","none");
		$("#frmInclOtr").css("display","block");
		
		$("#nrctatrf","#frmInclOtr").setMask("INTEGER","zzzzzzzzzzzz.z",".","");
		$("#nrcpfcgc","#frmInclOtr").setMask("INTEGER","zzzzzzzzzzzzzz",".","");
		$("#nmtitula","#frmInclOtr").setMask("STRING","40",charPermitido(),"");
		$('#cddbanco','#frmInclOtr').setMask('INTEGER','zzz','/.-','');
		$('#cdageban','#frmInclOtr').setMask('INTEGER','zzzz','/.-','');
		$("#cdispbif","#frmInclOtr").setMask("INTEGER","zzzzzzzz",".",""); 
		$("#divConteudoOpcao").css("height","295");
		
		//$('#cddbanco','#frmInclOtr').focus();
	}
	
	
	//Foca no próximo campo caso pressine ENTER 
	$('#cddbanco','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#cdageban','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#cdispbif','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#btContinuar','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#cdageban','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#nrctatrf','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#nrctatrf','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#nmtitula','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#nmtitula','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#nrcpfcgc','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#nrcpfcgc','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#inpessoa','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#inpessoa','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#intipcta','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	$('#intipcta','#frmInclOtr').keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#btContinuar','#frmInclOtr').focus(); 
			return false; 
		}		
	});
	
	
	return false;

}

function ValidaInclConta(intipdif) {

	var cddbanco;
    var cdispbif;
	var cdageban;
	var nrcpfcgc;
	var nrctatrf;
	var inpessoa;
	var intipcta;
	var nmtitula;
	
	//Armazena nome do Form
	var nomeForm;
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados ...");
	
	
	//Define que parametros enviar dependendo da IF	
	if (intipdif == 2){
		
		nomeForm = "frmInclOtr";
		//$('#cdispbif','#'+nomeForm).attr('disabled', 'false');
		//$("#cddbanco").attr('disabled', 'false');
		
		cddbanco = $('#cddbanco','#'+nomeForm).val();
        cdispbif = $('#cdispbif','#'+nomeForm).val();
		cdageban = $('#cdageban','#'+nomeForm).val();
		nrcpfcgc = $('#nrcpfcgc','#'+nomeForm).val();
		nrctatrf = $('#nrctatrf','#'+nomeForm).val();
		inpessoa = $('#inpessoa','#'+nomeForm).val();
		intipcta = $('#intipcta','#'+nomeForm).val();
		nmtitula = $('#nmtitula','#'+nomeForm).val();
		
		
		if (cdispbif == "") {
			hideMsgAguardo();
			showError("error","Informe o ISPB.","Alerta - Ayllos","focaCampoErro('#nmtitula', '# "+ nomeForm + "');bloqueiaFundo(divRotina)");
			return false;				
		}
		
		//Verifica se o Nome do Titular foi digitado
		if (nmtitula == "") {
			hideMsgAguardo();
			showError("error","Informe o Nome do Titular.","Alerta - Ayllos","focaCampoErro('#nmtitula', '# "+ nomeForm + "');bloqueiaFundo(divRotina)");
			return false;				
		}
		nrctatrf = retiraCaracteres(nrctatrf,".",false);
		
	} else {
	
		nomeForm = "frmInclCoop";
	
		cdageban = $("#cdagectl","#"+nomeForm).val();
		nrctatrf = $('#nrctatrf','#'+nomeForm).val();		
		nrctatrf = normalizaNumero(nrctatrf);
		
	}
	
	//Remove a classe de Erro do form
	$('input,select','#'+nomeForm).removeClass('campoErro');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_incluir_validar.php",
		//dataType: "html",
		data: {
			cddbanco: cddbanco,
            cdispbif: cdispbif,
			nrcpfcgc: nrcpfcgc,
			nrctatrf: nrctatrf,
			cdageban: cdageban,
			intipdif: intipdif,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			intipcta: intipcta,
			inpessoa: inpessoa,
			nmtitula: nmtitula,
			nomeForm: nomeForm,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			eval(response);	
			
		}				
	});
}

function VerificaSnhIncCont() {	
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando senha ...");
	
	//Recebe todos os parametros possiveis
	var idseqttl = $('#idseqttl', "#frmSnhIncluirConta").val();
	var nrdconta = $('#nrdconta', "#frmSnhIncluirConta").val();
	var cdsnhnew = $('#cdsnhnew', "#frmSnhIncluirConta").val();
	var cdsnhrep = $('#cdsnhrep', "#frmSnhIncluirConta").val();
	var cddbanco = $('#cddbanco', "#frmSnhIncluirConta").val();
	var cdageban = $('#cdageban', "#frmSnhIncluirConta").val();
	var intipdif = $('#intipdif', "#frmSnhIncluirConta").val();
	var nmtitula = $('#nmtitula', "#frmSnhIncluirConta").val();
	var nrctatrf = $('#nrctatrf', "#frmSnhIncluirConta").val();
	var inpessoa = $('#inpessoa', "#frmSnhIncluirConta").val();
	var nrcpfcgc = $('#nrcpfcgc', "#frmSnhIncluirConta").val();
	var dscpfcgc = $('#dscpfcgc', "#frmSnhIncluirConta").val();
	var intipcta = $('#intipcta', "#frmSnhIncluirConta").val();
    var cdispbif = $('#cdispbif', "#frmSnhIncluirConta").val();
	
	//Remove classe de erro dos elementos do form
	$('input','#VerificaSnhIncCont').removeClass('campoErro');
		
	//Verifica senhas digitadas
	if (cdsnhnew == "") {
		hideMsgAguardo();
		showError("error","Informe a senha.","Alerta - Ayllos","$('#cdsnhnew','#frmSnhIncluirConta').focus();focaCampoErro('cdsnhnew','frmSnhIncluirConta');bloqueiaFundo(divRotina)");
		return false;				
	}
	
	if (cdsnhrep == "") {
		hideMsgAguardo();
		showError("error","Confirme a senha.","Alerta - Ayllos","$('#cdsnhrep','#frmSnhIncluirConta').focus();focaCampoErro('cdsnhrep','frmSnhIncluirConta');bloqueiaFundo(divRotina)");
		return false;				
	}	

	if (cdsnhrep != cdsnhnew) {
		hideMsgAguardo();
		showError("error","Senhas diferentes.","Alerta - Ayllos","$('#cdsnhrep','#frmSnhIncluirConta').focus();focaCampoErro('cdsnhrep','frmSnhIncluirConta');bloqueiaFundo(divRotina)");
		return false;				
	}
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_incluir_validar_senha.php",
		//dataType: "html",
		data: {
			cdsnhnew: cdsnhnew,
			cdsnhrep: cdsnhrep,
			cddbanco: cddbanco,
			cdageban: cdageban,
			intipdif: intipdif,
			nmtitula: nmtitula,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrctatrf: nrctatrf,
			inpessoa: inpessoa,
			nrcpfcgc: nrcpfcgc,
			intipcta: intipcta,
			dscpfcgc: dscpfcgc,
            cdispbif: cdispbif,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			eval(response);	
			
		}
	});

}

function mostraDadosFormIncl(nomeForm) {

	var intipdif = $('#intipdif', "#InclDados").val();
	var nrctatrf = $('#nrctatrf', "#InclDados").val();
	var idseqttl = $('#idseqttl', "#InclDados").val();
	var nrdconta = $('#nrdconta', "#InclDados").val();
	var cddbanco = $('#cddbanco', "#InclDados").val();
    var cdispbif = $('#cdispbif', "#InclDados").val();
	var cdageban = $('#cdageban', "#InclDados").val();
	var nmtitula = $('#nmtitula', "#InclDados").val();
	var inpessoa = $('#inpessoa', "#InclDados").val();
	var nrcpfcgc = $('#nrcpfcgc', "#InclDados").val();
	var dscpfcgc = $('#dscpfcgc', "#InclDados").val();
	var intipcta = $('#intipcta', "#InclDados").val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_incluir.php",
		//dataType: "html",
		data: {
			cddbanco: cddbanco,
            cdispbif: cdispbif,
			cdageban: cdageban,
			intipdif: intipdif,
			nmtitula: nmtitula,
			dscpfcgc: dscpfcgc,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrctatrf: nrctatrf,
			inpessoa: inpessoa,
			nrcpfcgc: nrcpfcgc,
			intipcta: intipcta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
		
			$("#divConteudoOpcao").html(response);
			
			//Exibe Form de Inclusão com dados
			exibeFormInclusaoContas(intipdif);
						
			confirmaIncluirConta (intipdif , nomeForm );
								
		}				
	});

}

function confirmaIncluirConta (intipdif , nomeForm ) {

	if (intipdif == 1 ) {
		
		var nrctatrf = $('#nrctatrf', "#InclDados").val();
		var idseqttl = $('#idseqttl', "#InclDados").val();
		var nrdconta = $('#nrdconta', "#InclDados").val();
		var cddbanco = $('#cddbanco', "#InclDados").val();
        var cdispbif = $('#cdispbif', "#InclDados").val();
		var cdageban = $('#cdageban', "#InclDados").val();
		var nmtitula = $('#nmtitula', "#InclDados").val();
		var inpessoa = $('#inpessoa', "#InclDados").val();
		var nrcpfcgc = $('#nrcpfcgc', "#InclDados").val();
		var dscpfcgc = $('#dscpfcgc', "#InclDados").val();
		var intipcta = $('#intipcta', "#InclDados").val();
		
		//Envia valores valores para o Form
		$('#cdagectl', '#'+nomeForm).val(cdageban);
		$('#nmtitula', '#'+nomeForm).val(nmtitula);
		$('#nrctatrf', '#'+nomeForm).val(nrctatrf);
		$('#nrcpfcgc', '#'+nomeForm).val(nrcpfcgc);
		$('#dscpfcgc', '#'+nomeForm).val(dscpfcgc);
		$('#inpessoa', '#'+nomeForm).val(inpessoa);
		$('#cddbanco', '#'+nomeForm).val(cddbanco);
		$('#cdageban', '#'+nomeForm).val(cdageban);
		$('#intipcta', '#'+nomeForm).val(intipcta);
		$('#nrdconta', '#'+nomeForm).val(nrdconta);
		$('#idseqttl', '#'+nomeForm).val(idseqttl);
        $('#cdispbif', '#'+nomeForm).val(cdispbif);
		

	}
	
	//Mostra a confirmação e chama rotina de Inclusão da Conta
	showConfirmacao('Deseja incluir conta para transfer&ecirc;ncia?','Confirma&ccedil;&atilde;o - Ayllos','IncluirConta(' + intipdif + ', "' + nomeForm + '")','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');

}

function IncluirConta(intipdif, nomeForm) {
		
	//Recebe valores do Form
	var nrctatrf = $('#nrctatrf',"#" + nomeForm).val();
	var idseqttl = $('#idseqttl',"#" + nomeForm).val();
	var nrdconta = $('#nrdconta',"#" + nomeForm).val();
	var cddbanco = $('#cddbanco',"#" + nomeForm).val();
	var nmtitula = $('#nmtitula',"#" + nomeForm).val();
	var inpessoa = $('#inpessoa',"#" + nomeForm).val();
	var nrcpfcgc = $('#nrcpfcgc',"#" + nomeForm).val();
	var intipcta = $('#intipcta',"#" + nomeForm).val();
    var cdispbif = $('#cdispbif','#' + nomeForm).val();
	
	//Formata o nr da conta conforme cada IF
	if (intipdif == 1){
		
		var cdageban = $("#cdagectl","#" + nomeForm).val();
		
		//Retira TODOS os caracteres diferentes de números
		nrctatrf = normalizaNumero( nrctatrf );
				
	} else {
	
		var cdageban = $('#cdageban',"#" + nomeForm).val();

		//Retira somente os pontos, e mantém o "X" no número da conta de outras IFs
		nrctatrf = retiraCaracteres(nrctatrf,".",false);
		
	}
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo conta ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/contas_incluir_confirmar.php",
		//dataType: "html",
		data: {
			cddbanco: cddbanco,
            cdispbif: cdispbif,                       
			cdageban: cdageban,
			intipdif: intipdif,
			nmtitula: nmtitula,
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrctatrf: nrctatrf,
			inpessoa: inpessoa,
			nrcpfcgc: nrcpfcgc,
			intipcta: intipcta, 
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
				eval(response);
		
		}				
	});
}

// Função para mostrar a opção Habilitação
function obtemDadosLimites() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados dos limites ...");
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/limites.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			
			$('#vllimtrf','#frmAlterarLimites').focus(); 
			
			controlaFocoEnter("frmAlterarLimites");
			
			$('#vllimvrb','#frmAlterarLimites').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#btAlterar','#divBotoes').focus(); 
					return false; 
				}		
			});
			
		}				
	});
}

// Função para mostrar a opção Habilitação
function obtemDadosLimitesprep() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados dos limites ...");
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/limites_preposto.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			
			$('#vllimtrf','#frmAlterarLimites').focus(); 
			
			controlaFocoEnter("frmAlterarLimites");
			
			$('#vllimvrb','#frmAlterarLimites').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#btAlterar','#divBotoes').focus(); 
					return false; 
				}		
			});
			
		}				
	});
}

// Função para mostrar a opção Habilitação
function validaDadosLimites(inpessoa) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados de habilita&ccedil;&atilde;o ...");
	
	if (inpessoa == 1) {
		// Valida valor do limite diário
		if ($("#vllimweb","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimweb","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio inv&aacute;lido.","Alerta - Ayllos","$('#vllimweb','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	} else {
		// Valida valor do limite diário transferência
		if ($("#vllimtrf","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimtrf","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio para transfer&ecirc;ncia inv&aacute;lido.","Alerta - Ayllos","$('#vllimtrf','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}		

		// Valida valor do limite diário pagamento
		if ($("#vllimpgo","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimpgo","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio para pagamento inv&aacute;lido.","Alerta - Ayllos","$('#vllimpgo','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}		
	}
	// Valida valor do limite diário pagamento
	if ($("#vllimted","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimted","#frmAlterarLimites").val(),false,0,0)) {
		hideMsgAguardo();
		showError("error","Valor do limite di&aacute;rio para pagamento inv&aacute;lido.","Alerta - Ayllos","$('#vllimted','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/limites_validar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			vllimweb: $("#vllimweb","#frmAlterarLimites").val().replace(/\./g,""),
			vllimtrf: $("#vllimtrf","#frmAlterarLimites").val().replace(/\./g,""),
			vllimpgo: $("#vllimpgo","#frmAlterarLimites").val().replace(/\./g,""),
			vllimted: $("#vllimted","#frmAlterarLimites").val().replace(/\./g,""),
			vllimvrb: $("#vllimvrb","#frmAlterarLimites").val().replace(/\./g,""),
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divHabilitacaoInternet02").html(response);
		}				
	});
}

// Função para mostrar a opção Habilitação
function validaDadosLimitesprep(inpessoa) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados de habilita&ccedil;&atilde;o ...");
	
	if (inpessoa == 1) {
		// Valida valor do limite diário
		if ($("#vllimweb","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimweb","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio inv&aacute;lido.","Alerta - Ayllos","$('#vllimweb','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	} else {
		// Valida valor do limite diário transferência
		if ($("#vllimtrf","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimtrf","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio para transfer&ecirc;ncia inv&aacute;lido.","Alerta - Ayllos","$('#vllimtrf','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}		

		// Valida valor do limite diário pagamento
		if ($("#vllimpgo","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimpgo","#frmAlterarLimites").val(),false,0,0)) {
			hideMsgAguardo();
			showError("error","Valor do limite di&aacute;rio para pagamento inv&aacute;lido.","Alerta - Ayllos","$('#vllimpgo','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}		
	}
	// Valida valor do limite diário pagamento
	if ($("#vllimted","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimted","#frmAlterarLimites").val(),false,0,0)) {
		hideMsgAguardo();
		showError("error","Valor do limite di&aacute;rio para pagamento inv&aacute;lido.","Alerta - Ayllos","$('#vllimted','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Valida valor do limite diário pagamento
	if ($("#vllimflp","#frmAlterarLimites").val() == "" || !validaNumero($("#vllimflp","#frmAlterarLimites").val(),false,0,0)) {
		hideMsgAguardo();
		showError("error","Valor do limite di&aacute;rio para folha de pagamento inv&aacute;lido.","Alerta - Ayllos","$('#vllimflp','#frmAlterarLimites').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/limites_validar_prep.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			vllimweb: $("#vllimweb","#frmAlterarLimites").val().replace(/\./g,""),
			vllimtrf: $("#vllimtrf","#frmAlterarLimites").val().replace(/\./g,""),
			vllimpgo: $("#vllimpgo","#frmAlterarLimites").val().replace(/\./g,""),
			vllimted: $("#vllimted","#frmAlterarLimites").val().replace(/\./g,""),
			vllimvrb: $("#vllimvrb", "#frmAlterarLimites").val().replace(/\./g, ""),
			vllimflp: $("#vllimflp", "#frmAlterarLimites").val().replace(/\./g, ""),
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divHabilitacaoInternet02").html(response);
		}				
	});
}

// Função para esconder divtacaoInternet02
function escondeDivHabilitacao02() {
	$("#divHabilitacaoInternet01").css("display","block");
	$("#divHabilitacaoInternet02").css("display","none");
	
	// Aumenta tamanho do div onde o conteúdo da opção será visualizado
	$("#divConteudoOpcao").css("height","290px!important");
}

// Função para mostrar divHabilitacaoInternet02
function mostraDivHabilitacao02() {
	$("#divHabilitacaoInternet01").css("display","none");
	$("#divHabilitacaoInternet02").css("display","block");
}

// Função para seleção do preposto
function selecionaPreposto(id,qtPreposto,nmprepos,nrcpfpre) {
	
	// Mostra nome do novo preposto na tela
	$("#nmprepos","#frmSelecaoPreposto").val((cpfpreat == nrcpfpre ? "" : nmprepos));
	
	// Armazena sequencial do titular selecionado
	nrcpfcgc = nrcpfpre;
}

// Função para confirmar atualização de preposto
function confirmaAtualizacaoPreposto() {
	if (cpfpreat > 0 && cpfpreat == nrcpfcgc) {			
		confirmaAlteracaoLimites();		
	} else {
		var metodoNo = cpfpreat > 0 ? 'confirmaAlteracaoLimites()' : 'blockBackground(parseInt($("#divRotina").css("z-index")))';
		showConfirmacao('Confirma atualiza&ccedil;&atilde;o do preposto?','Confirma&ccedil;&atilde;o - Ayllos','atualizarPreposto()',metodoNo,'sim.gif','nao.gif');
	}
}

// Função para atualizar preposto
function atualizarPreposto() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, atualizando preposto ...");
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/atualizar_preposto.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para confirmar alteração dos limites de habilitação
function confirmaAlteracaoLimites() {
	// Escoder div de preposto e mostrar div com limites
	escondeDivHabilitacao02();

	// Confirma alteração dos dados da habilitação	
	showConfirmacao("Confirma altera&ccedil;&otilde;es de habilita&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","alterarDadosLimites()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
}

// Função para confirmar alteração dos limites de habilitação
function confirmaAlteracaoLimites2() {
	// Escoder div de preposto e mostrar div com limites
	escondeDivHabilitacao02();

	// Confirma alteração dos dados da habilitação	
	showConfirmacao("Confirma altera&ccedil;&otilde;es de habilita&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","alterarDadosLimites2()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
}

// Função para alterar limites
function alterarDadosLimites() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, atualizando dados de habilita&ccedil;&atilde;o ...");
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/limites_alterar.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			vllimweb: $("#vllimweb","#frmAlterarLimites").val().replace(/\./g,""),
			vllimtrf: $("#vllimtrf","#frmAlterarLimites").val().replace(/\./g,""),
			vllimpgo: $("#vllimpgo","#frmAlterarLimites").val().replace(/\./g,""),
			vllimted: $("#vllimted","#frmAlterarLimites").val().replace(/\./g,""),
			vllimvrb: $("#vllimvrb", "#frmAlterarLimites").val().replace(/\./g, ""),
			idastcjt: idastcjt,
			executandoProdutos: executandoProdutos,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para alterar limites
function alterarDadosLimites2() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, atualizando dados de habilita&ccedil;&atilde;o ...");
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/internet/limites_alterar_prep.php", 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			vllimweb: $("#vllimweb","#frmAlterarLimites").val().replace(/\./g,""),
			vllimtrf: $("#vllimtrf","#frmAlterarLimites").val().replace(/\./g,""),
			vllimpgo: $("#vllimpgo","#frmAlterarLimites").val().replace(/\./g,""),
			vllimted: $("#vllimted","#frmAlterarLimites").val().replace(/\./g,""),
			vllimvrb: $("#vllimvrb", "#frmAlterarLimites").val().replace(/\./g, ""),
			vllimflp: $("#vllimflp", "#frmAlterarLimites").val().replace(/\./g, ""),
			idastcjt: idastcjt,
			executandoProdutos: executandoProdutos,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

function controlaLayout( nomeForm ){

	$("#divBotoes").show();
	$("#divPrincipalPJ").hide();
	$("#divResponsaveisAss").hide();
	
	if( nomeForm == 'frmAlterarLimites' ){
	
		var Lvllimweb = $('label[for="vllimweb"]','#'+nomeForm);
		var Lvllimtrf = $('label[for="vllimtrf"]','#'+nomeForm);
		var Lvllimpgo = $('label[for="vllimpgo"]','#'+nomeForm);
		var Lvllimted = $('label[for="vllimted"]','#'+nomeForm);
		var Lvllimvrb = $('label[for="vllimvrb"]','#'+nomeForm); 
		var Lvllimflp = $('label[for="vllimflp"]', '#' + nomeForm);
				
		var Cvllimweb = $('#vllimweb','#'+nomeForm);
		var Cvllimtrf = $('#vllimtrf','#'+nomeForm);
		var Cvllimpgo = $('#vllimpgo','#'+nomeForm);
		var Cvllimted = $('#vllimted','#'+nomeForm);
		var Cvllimvrb = $('#vllimvrb','#'+nomeForm); 
		var Cvllimflp = $('#vllimflp', '#' + nomeForm);
		
		$('#'+nomeForm).addClass('formulario');
		
		Lvllimweb.addClass('rotulo').css('width','170px');
		Lvllimtrf.addClass('rotulo').css('width','170px');
		Lvllimpgo.addClass('rotulo').css('width','170px');
		Lvllimted.addClass('rotulo').css('width','170px');
		Lvllimvrb.addClass('rotulo').css('width','170px'); 
		Lvllimflp.addClass('rotulo').css('width', '170px');
		
		Cvllimweb.css({'width':'120px','text-align':'right'});
		Cvllimtrf.css({'width':'120px','text-align':'right'});
		Cvllimpgo.css({'width':'120px','text-align':'right'});
		Cvllimted.css({'width':'120px','text-align':'right'});
		Cvllimvrb.css({'width':'120px','text-align':'right'}); 
		Cvllimflp.css({ 'width': '120px', 'text-align': 'right' });
		$("#divConteudoOpcao").css("height", "290px");
	}else if( nomeForm == 'divInternetPrincipal' ){
		$("#divInternetPrincipal").show();
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
			
		$("#frmDadosTitInternet").show();
		
		divRegistro.css('height','55px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '80px';
						
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
								
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		nomeForm = 'frmDadosTitInternet';
		$("#divConteudoOpcao").css("width","100%");
		
		$('#'+nomeForm).css('width','560px');
		$('#'+nomeForm).addClass('formulario');
		
        var Ldssitsnh = $('#dssitsnh', '#' + nomeForm);
        var Lvllimweb = $('label[for="vllimweb"]', '#' + nomeForm);
        var Lnmprepos = $('label[for="nmprepos"]', '#' + nomeForm);
        var Lnmoperad = $('label[for="nmoperad"]', '#' + nomeForm);
        var Lvllimtrf = $('label[for="vllimtrf"]', '#' + nomeForm);
        var Lvllimpgo = $('label[for="vllimpgo"]', '#' + nomeForm);
        var Lvllimted = $('label[for="vllimted"]', '#' + nomeForm);
        var Lvllimvrb = $('label[for="vllimvrb"]', '#' + nomeForm);
        var Lvllimflp = $('label[for="vllimflp"]', '#' + nomeForm);
        var Ldtlibera = $('label[for="dtlibera"]', '#' + nomeForm);
        var Ldtaltsit = $('label[for="dtaltsit"]', '#' + nomeForm);
        var Ldtaltsnh = $('label[for="dtaltsnh"]', '#' + nomeForm);
        var Ldtblutsh = $('label[for="dtblutsh"]', '#' + nomeForm);
        var Ldtultace = $('label[for="dtultace"]', '#' + nomeForm);
        var Ldtacemob = $('label[for="dtacemob"]', '#' + nomeForm);
		
		var Ldtlimweb = $('label[for="dtlimweb"]','#'+nomeForm);
		var Ldtlimted = $('label[for="dtlimted"]','#'+nomeForm);
		var Ldtlimvrb = $('label[for="dtlimvrb"]','#'+nomeForm); 
		var Ldtlimpgo = $('label[for="dtlimpgo"]','#'+nomeForm);
		var Ldtlimtrf = $('label[for="dtlimtrf"]','#'+nomeForm);
		
        var Cdssitsnh = $('input[name="dssitsnh"]', '#' + nomeForm);
        var Cvllimweb = $('#vllimweb', '#' + nomeForm);
        var Cnmprepos = $('#nmprepos', '#' + nomeForm);
        var Cnmoperad = $('#nmoperad', '#' + nomeForm);
        var Cvllimtrf = $('#vllimtrf', '#' + nomeForm);
        var Cvllimpgo = $('#vllimpgo', '#' + nomeForm);
        var Cvllimted = $('#vllimted', '#' + nomeForm);
        var Cvllimvrb = $('#vllimvrb', '#' + nomeForm);
        var Cvllimflp = $('#vllimflp', '#' + nomeForm);
        var Cdtlibera = $('#dtlibera', '#' + nomeForm);
        var Cdtaltsit = $('#dtaltsit', '#' + nomeForm);
        var Cdtaltsnh = $('#dtaltsnh', '#' + nomeForm);
        var Cdtblutsh = $('#dtblutsh', '#' + nomeForm);
        var Cdtultace = $('#dtultace', '#' + nomeForm);
        var Cdtacemob = $('#dtacemob', '#' + nomeForm);
		
		var Cdtlimweb = $('#dtlimweb','#'+nomeForm);
		var Cdtlimted = $('#dtlimted','#'+nomeForm);
		var Cdtlimvrb = $('#dtlimvrb','#'+nomeForm); 
		var Cdtlimpgo = $('#dtlimpgo','#'+nomeForm);
		var Cdtlimtrf = $('#dtlimtrf','#'+nomeForm);
		
        Ldssitsnh.addClass('rotulo').css('width', '133px');
        Lvllimweb.addClass('rotulo').css('width', '133px');
        Lnmprepos.addClass('rotulo').css('width', '133px');
        Lnmoperad.addClass('rotulo').css('width', '133px');

        Lvllimtrf.css('width', '133px');
        Lvllimpgo.css('width', '133px');
        Lvllimted.css('width', '133px');
        Lvllimvrb.css('width', '133px');
        Lvllimflp.css('width', '133px');
        Ldtlibera.css('width', '133px');
        Ldtblutsh.css('width', '160px');
        Ldtaltsit.css('width', '133px');
        Ldtaltsnh.css('width', '160px');
		
        Ldtultace.css('width', '126px');
        Ldtacemob.css('width', '160px');
		
		Ldtlimweb.css('width','160px');
		Ldtlimted.css('width','160px');
		Ldtlimvrb.css('width','160px'); 
		Ldtlimpgo.css('width','160px');
		Ldtlimtrf.css('width','160px');
		
        Cdssitsnh.css({ 'width': '383px' });
        Cvllimweb.css({ 'width': '110px' });
        Cnmprepos.css({ 'width': '383px' });
        Cnmoperad.css({ 'width': '383px' });
        Cvllimtrf.css({ 'width': '110px' });
        Cvllimpgo.css({ 'width': '110px' });
        Cvllimted.css({ 'width': '110px' });
        Cvllimvrb.css({ 'width': '110px' });
        Cvllimflp.css({ 'width': '110px' });
        Cdtlibera.css({ 'width': '110px' });
        Cdtaltsit.css({ 'width': '110px' });
        Cdtaltsnh.css({ 'width': '110px' });
        Cdtblutsh.css({ 'width': '110px' });
        Cdtultace.css({ 'width': '110px' });
        Cdtacemob.css({ 'width': '110px' });
		
        Cdtlimweb.css({ 'width': '110px' });
        Cdtlimted.css({ 'width': '110px' });
        Cdtlimvrb.css({ 'width': '110px' });
        Cdtlimpgo.css({ 'width': '110px' });
        Cdtlimtrf.css({ 'width': '110px' });
		
		Cdssitsnh.desabilitaCampo();
		Cvllimweb.desabilitaCampo();
		Cnmprepos.desabilitaCampo();
		Cnmoperad.desabilitaCampo();
		Cvllimtrf.desabilitaCampo();
		Cvllimpgo.desabilitaCampo();
		Cvllimted.desabilitaCampo();
		Cvllimvrb.desabilitaCampo(); 
		Cvllimflp.desabilitaCampo();
		Cdtlibera.desabilitaCampo();
		Cdtaltsit.desabilitaCampo();
		Cdtaltsnh.desabilitaCampo();
		Cdtblutsh.desabilitaCampo();
		Cdtultace.desabilitaCampo();
        Cdtacemob.desabilitaCampo();
		
		Cdtlimweb.desabilitaCampo();
		Cdtlimted.desabilitaCampo();
		Cdtlimvrb.desabilitaCampo(); 
		Cdtlimpgo.desabilitaCampo();
		Cdtlimtrf.desabilitaCampo();
		
		nomeForm = 'frmAlterarSenha';
				
		$('#'+nomeForm).addClass('formulario');
		
		var Lcddsenha = $('label[for="cddsenha"]','#'+nomeForm);
		var Lcdsnhnew = $('label[for="cdsnhnew"]','#'+nomeForm);
		var Lcdsnhrep = $('label[for="cdsnhrep"]','#'+nomeForm);
		
		var Ccddsenha = $('#cddsenha','#'+nomeForm);
		var Ccdsnhnew = $('#cdsnhnew','#'+nomeForm);
		var Ccdsnhrep = $('#cdsnhrep','#'+nomeForm);
		
		Lcddsenha.addClass('rotulo').css('width','200px');
		Lcdsnhnew.addClass('rotulo').css('width','200px');
		Lcdsnhrep.addClass('rotulo').css('width','200px');
		         
		Ccddsenha.css({'width':'108px'});
		Ccdsnhnew.css({'width':'108px'});
	    Ccdsnhrep.css({'width':'108px'});
		
		Ccddsenha.habilitaCampo();
		Ccdsnhnew.habilitaCampo();
		Ccdsnhrep.habilitaCampo();

		$('#divBotoes1','#divAlterarSenha').css({'margin':'4px 0 0 50px','clear':'both'});
		

		nomeForm = 'frmLiberarSenha';
		
		$('#'+nomeForm).addClass('formulario');
		
		var Lcdsnhnew = $('label[for="cdsnhnew"]','#'+nomeForm);
		var Lcdsnhrep = $('label[for="cdsnhrep"]','#'+nomeForm);
		
		var Ccdsnhnew = $('#cdsnhnew','#'+nomeForm);
		var Ccdsnhrep = $('#cdsnhrep','#'+nomeForm);
		
		Lcdsnhnew.addClass('rotulo').css('width','185px');
		Lcdsnhrep.addClass('rotulo').css('width','185px');
		         
		Ccdsnhnew.css({'width':'108px'});
	    Ccdsnhrep.css({'width':'108px'});
		
		Ccdsnhnew.habilitaCampo();
	    Ccdsnhrep.habilitaCampo();
		
		Ccdsnhrep.unbind('keypress').bind('keypress',function(e) {
			if (e.keyCode == 13) {
				liberaSenhaAcesso();		
			}
		});		
		
		$('#divBotoes2','#divLiberarSenha').css({'margin':'4px 0 0 25px','clear':'both'});

		
	}else if( nomeForm == 'divSelecaoPreposto' ){
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		$('#'+nomeForm).css('width','560px');
		divRegistro.css('height','55px');
						
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '65px';
		arrayLargura[1] = '220px';
		arrayLargura[2] = '80px';
						
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
								
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		nomeForm = 'frmSelecaoPreposto';
		
		$('#'+nomeForm).addClass('formulario');
		
		var Lvllimtrf = $('label[for="vllimtrf"]','#'+nomeForm);
		var Lvllimpgo = $('label[for="vllimpgo"]','#'+nomeForm);
		var Lvllimted = $('label[for="vllimted"]','#'+nomeForm);
		var Lnmprepat = $('label[for="nmprepat"]','#'+nomeForm);
		var Lnmprepos = $('label[for="nmprepos"]','#'+nomeForm);
		
		var Cvllimtrf = $('#vllimtrf','#'+nomeForm);
		var Cvllimpgo = $('#vllimpgo','#'+nomeForm);
		var Cvllimted = $('#vllimted','#'+nomeForm);
		var Cnmprepat = $('#nmprepat','#'+nomeForm);
		var Cnmprepos = $('#nmprepos','#'+nomeForm);
		
		Lvllimtrf.addClass('rotulo').css('width','140px');
		Lvllimpgo.addClass('rotulo').css('width','140px');
		Lvllimted.addClass('rotulo').css('width','140px');
		Lnmprepat.addClass('rotulo').css('width','140px');
		Lnmprepos.addClass('rotulo').css('width','140px');
		
		Cvllimtrf.css({'width':'110px'});
		Cvllimpgo.css({'width':'110px'});
		Cvllimted.css({'width':'110px'});
		Cnmprepat.css({'width':'270px'});
		Cnmprepos.css({'width':'270px'});
		
		Cvllimtrf.desabilitaCampo();
		Cvllimpgo.desabilitaCampo();
		Cvllimted.desabilitaCampo();
		Cnmprepat.desabilitaCampo();
		Cnmprepos.desabilitaCampo();
			
	}else if( nomeForm == 'divPrincipalPJ' ){
		$("#divPrincipalPJ").show();
		$("#divBotoes").hide();
		$("#frmDadosTitInternet").hide();
		$("#divInternetPrincipal").hide();
		$("#divResponsaveisAss").hide();
	}else if( nomeForm == 'frmOpDesativaPush'){
		
		$("#divDispositivos").show();	
		$("#divPrincipalPJ").hide();
		$("#divBotoes").hide();
		$("#frmDadosTitInternet").hide();
		$("#divInternetPrincipal").hide();
		$("#divResponsaveisAss").hide();
		
		ajustarCentralizacao();
		
		var divRegistro = $('div.divRegistros','#divDispositivos');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css({'height':'50%','width':'100%'});
		
		if($("#qtdDispositivos").val() > 0){
			var ordemInicial = new Array();
			ordemInicial = [[2,0]];
			
			var arrayLargura = new Array();
			arrayLargura[0] = '100px';
			arrayLargura[1] = '200px';
			
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'right';
			arrayAlinha[1] = 'right';
			arrayAlinha[2] = 'right';
		}else{
			$("#btnDesativar").hide();
			$("#btnvoltar").css({'margin-left':'260px'});
		}
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('.divDispositivos > table > thead').remove();
				
		$('table', tabela).removeClass();
		$('th', tabela).unbind('click');
		$('.headerSort', tabela).removeClass();
		$('#frmOpDesativaPush').addClass('formulario');
		$("#divConteudoOpcao").css("width","100%");
	}else if( nomeForm == 'divResponsaveisAss' ){
				
		$("#divResponsaveisAss").show();
		$("#divPrincipalPJ").hide();
		$("#divBotoes").hide();
		$("#frmDadosTitInternet").hide();
		$("#divInternetPrincipal").hide();
		
		$("#divConteudoOpcao").css("width","800");
		
		ajustarCentralizacao();
		
		var divRegistro = $('div.divRegistros','#divResponsaveisAss');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css({'height':'170px','width':'100%'});
		
		var ordemInicial = new Array();
		ordemInicial = [[2,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '10px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '180px';
		arrayLargura[3] = '80px';
		arrayLargura[4] = '80px';
		arrayLargura[5] = '70px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('.divResponsaveisAss > table > thead').remove();
		
		$("#divConteudoOpcao").css("height","290"); 
		
		$('table', tabela).removeClass();
		$('th', tabela).unbind('click');
		$('.headerSort', tabela).removeClass();
		
	}
		
	if(nomeForm != 'divPrincipalPJ' && nomeForm != 'divResponsaveisAss' ){
		nomeForm = 'frmOpHabilitacao';
		$('#'+nomeForm).addClass('formulario');
		
		nomeForm = 'frmOpContas';
        $('#' + nomeForm).addClass('formulario');
		
		nomeForm = 'frmInclCoop';
		$('#'+nomeForm).addClass('formulario');
		
		callafterInternet = '';
	}	
	
	return false;
}


function controlaLupas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmInclOtr';
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				// Banco
				if ( campoAnterior == 'cddbanco' || campoAnterior == 'cdispbif' ) { 
					bo		= 'b1wgen0059.p';
					procedure	= 'busca_banco';
					titulo      = 'Banco';
					qtReg		= '30';
					filtros 	= 'Cód. Banco;cddbanco;30px;N;0;N|ISPB;cdispbif;70px;N;0;N|Nome Banco;nmdbanco;200px;S;';
					colunas 	= 'Código;cdbccxlt;20%;right|ISPB;nrispbif;20%;right|Banco;nmextbcc;60%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					
					 return false;
				
				// Agência
				} else if ( campoAnterior == 'cdageban' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_agencia';
					titulo      = 'Ag&ecircncia';
					qtReg		= '30';
					filtros 	= 'Cód. Agência;cdageban;30px;S;0|Agência;nmageban;200px;S;|Cód. Banco;cddbanco;30px;N;|Banco;nmdbanco;200px;N;';
					colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;

				}			
			}
		});
	});
	
	// Nome do Formulário que estamos trabalhando
	nomeFormulario = 'frmInclCoop';
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).click( function() {
				
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {	
							
				campoAnterior = $(this).prev().attr('name');
							
				// Cooperativa
				if ( campoAnterior == 'cdagectl' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'Busca_Cooperativa';
					titulo      = 'Cooperativas';
					qtReg		= '30';
					filtros 	= 'Agencia;cdagectl;30px;S;0';
					colunas 	= 'Agencia;cdagectl;20%;right|Cooperativa;nmrescop;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;		
				}
			}
		
		});
	});

	// Bancos cddbanco
	$('#cddbanco','#'+nomeFormulario).unbind('change').bind('change',function() {		
		$('#cdageban','#'+nomeFormulario).val('');
		
		buscaDescricao('b1wgen0059.p','busca_banco','Banco',$(this).attr('name'),'nmdbanco',$(this).val(),'nmextbcc','cddbanco',nomeFormulario);
		return false;
	});	
	
			
	// Agencia
	$('#cdageban','#'+nomeFormulario).unbind('change').bind('change', function() {	
		if ($('#cddbanco','#'+nomeFormulario).val() == '') {
			showError('error','Informe o banco','Alerta - Ayllos', 'bloqueiaFundo(divRotina)');			
			return false;
		}		
		buscaDescricao('b1wgen0059.p','busca_agencia','Agencia',$(this).attr('name'),'nmageban',$(this).val(),'nmageban','cddbanco',nomeFormulario);
		return false;
	});	
	
	return false;
}
function desabilitaCampos(){  
	$("#CamposHabDesab").find(':input').prop('disabled', true);
	//$('#cdispbif').focus();	
}

function habilitaCampos(){  
	$("#CamposHabDesab").find(':input').prop('disabled', false);
	$('#cdageban').focus();	
}
function carregaISPB(cddbanco){

	if (cddbanco > 0 ) {
		// Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: "POST", 
			url: UrlSite + "telas/atenda/internet/busca_ispbif.php",
			dataType: "html",
			data: {
				cddbanco: cddbanco,
				redirect: "html_ajax"
			},		
			error: function(objAjax,responseError,objExcept) { 
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				hideMsgAguardo();
				
				var cdispbif = response.split("-"); 
				if ((cdispbif[1] == '000' && cdispbif[0] == "00000000" ) || cdispbif[0] == '' || cddbanco == ''){ 
					showError("error","Banco não cadastrado.","Alerta - Ayllos","desabilitaCampos()");
					$("#cddbanco").prop('disabled', false);
					$("#cdispbif").prop('disabled', false);
					
	
					
				}else{ 
					$('#cdispbif').val(cdispbif[0]);
					$("#cddbanco").prop('disabled', false);
					$("#cdispbif").prop('disabled', true);
					habilitaCampos(); 
				}
			}
							
		});
	}else{
			$("#cdispbif").prop('disabled', false);
			$("#cdispbif").val('');
			$('#cdispbif').focus();	
	
	}
}


function carregaCdbanco(cdispbif){	
	if(cdispbif != '') {
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/busca_ispbif.php",
		dataType: "html",
		data: {
			cdispbif: cdispbif,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) { 
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
		    hideMsgAguardo();
			var cddbanco = response.split("-"); 
			if ((cddbanco[1] == '000' && cddbanco[0] == "00000000") || cddbanco[1] == '' || cdispbif == ''){ 
				showError("error","ISPB não cadastrado.","Alerta - Ayllos","desabilitaCampos()");
				$("#cddbanco").prop('disabled', false);
				$("#cdispbif").prop('disabled', false);
								
			}else{  
				if (cddbanco[1] == '000'){
					cdBanco = "";
				}else{
					cdBanco = cddbanco[1];
				}
				$('#cddbanco').val(cdBanco);
				$("#cdispbif").prop('disabled', true);
				$("#cddbanco").prop('disabled', false);
				habilitaCampos();
		  }
		}
						
	});
	}
}

function validaResponsaveis(){
	
	var dscpfcgc = "";	
	var flgconju = "yes";
	var qtminast = $("#qtminast").val();
	
	$("input:checkbox[name='chkRespAssConj']").each(function () {
	    if ($(this).val() != "on") {
	        if ($(this).prop('checked')) {
	            dscpfcgc += "#" + $(this).val();
	        }
	    }
	});
		
	dscpfcgc = dscpfcgc.substring(1,dscpfcgc.length);
	
	showMsgAguardo("Aguarde, validando responsaveis...");

	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/internet/valida_responsaveis.php",
		data: {
			nrdconta: nrdconta,
			dscpfcgc: dscpfcgc,
			flgconju: flgconju,
			qtminast: qtminast,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
		    hideMsgAguardo();
			eval(response);
		}				
	});
	
}

function salvarRepresentantes(){
	
	var responsa = "";	
	var qtminast = $("#qtminast").val();
	
	$("input:checkbox[name='chkRespAssConj']").each(function () {
		if($(this).val() != "on"){
			if(this.checked){
				responsa += "#" + $("#nrdctato" + $(this).val()).val() + "," + $(this).val() + ",yes,no";
			}else{
				responsa += "#" + $("#nrdctato" + $(this).val()).val() + "," + $(this).val() + ",no,no";
			}
		}
	});
	
	responsa = responsa.substring(1,responsa.length);	
	
	showMsgAguardo("Aguarde, atualizando responsaveis...");
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/internet/grava_responsaveis.php",
		data: {
			nrdconta: nrdconta,
			responsa: responsa,
			qtminast: qtminast,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}				
	});
}

function selecionarTodos(){
	
	var aux_checkado = 0;
		
	if ($("#chkTodosResp").prop('checked')) {
		aux_checkado = 1;
	}else{
		aux_checkado = 0;
	}
	
	$("input:checkbox[name='chkRespAssConj']").each(function() {
		if(aux_checkado == 1){
			$(this).prop('checked',true);
		}else{
			$(this).prop('checked',false);
		}
	});
}

function validaRespAssConj(nrconta, cpf){
	if ($("#chkRespAssConj"+cpf).prop('checked')) {
		aux_checkado = 1;
	}else{
		aux_checkado = 0;
	}
	
	if(aux_checkado == 0){
		if($("#chkMasterAssConj"+cpf).prop('checked')){
			alterarPrepostoMaster(nrconta, cpf);
			$("#chkRespAssConj"+cpf).prop('checked', false);
			$("#chkMasterAssConj"+cpf).prop('checked',false);
		}
	}
}

function validaPrepostoMaster(nrconta,nome,cpf){
	aux_checkado = 0;
	chkcount = 0;

	if ($("#chkMasterAssConj"+cpf).prop('checked')) {
		aux_checkado = 1;
		$(".chkMasterAssConj").each(function(){	
			if($(this).prop('checked')){
				chkcount = chkcount+1;
			}
		})
	}else{
		aux_checkado = 0;
	}
 
	if(chkcount > 1 && aux_checkado == 1){
		$("#chkMasterAssConj"+cpf).prop('checked',false);
		showError("error","Est&aacute conta j&aacute possui um PREPOSTO MASTER cadastrado.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
	} else {
		showConfirmacao('Deseja alterar o status de preposto master para '+nome+'?','Confirma&ccedil;&atilde;o - Ayllos','alterarPrepostoMaster(' + nrdconta + ', "' + cpf + '")','alteraChkBoxPrepostoMaster("'+cpf+'", '+aux_checkado+')','sim.gif','nao.gif');
	}
}

function alteraChkBoxPrepostoMaster(cpf, aux_checkado){
	if(aux_checkado == 1){
		$("#chkMasterAssConj"+cpf).prop('checked',false);
	}else{
		$("#chkMasterAssConj"+cpf).prop('checked',true);
	}
}

function alterarPrepostoMaster(nrdconta, cpf){
	if($("#chkRespAssConj"+cpf).prop('checked') == false && $("#chkMasterAssConj"+cpf).prop('checked')){
		$("#chkRespAssConj"+cpf).prop('checked',true);
	}
	
	showMsgAguardo("Aguarde, atualizando status do preposto master...");
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/internet/altera_preposto_master.php",
		data: {
			nrdconta: nrdconta,
			nrcpfcgc: cpf,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
}

function desativarPush(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando listagem de dispositivos...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/listagem_push.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
		}				
	});
}

function selecionaMobile(id){
	idmobile = id;
}
function desativarEnvioPush(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando listagem de dispositivos...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/internet/desativa_push.php",
		data: {
			idmobile: idmobile,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
}