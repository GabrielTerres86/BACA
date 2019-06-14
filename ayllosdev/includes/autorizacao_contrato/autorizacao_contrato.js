/*!
 * FONTE        : autorizacao_contrato.js
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * 			      Bruno Luiz Katzjarowski - Mout's
 * DATA CRIAÇÃO : 18/12/2018
 * OBJETIVO     : Biblioteca de funções JavaScript
 * --------------  
 * ALTERAÇÕES   : 06/09/2019 - Ajuste na validaSenhaAutorizacaoContrato para validar casos de obrigatoria == '1'
 *							   estava deixando passando com campo vazio. PRJ 470 SM2 (Mateus Z / Mouts)
 *
 * --------------
 */

/**
 * ____________________________________ 
 * CONSTANTES
 * ____________________________________
*/
var __QUANTIDADE_SENHAS_VALIDAR_MIN = 1;
var __flag_validandoSenha = false;
var __TELA_DCTROR = 30;
var __TELA_MANTAL = 31;

var __CALL_TYPE_TRANS_PEND = 'TRANS_PEND';
var __CALL_TYPE_PROTOCOLO_PF = 'PROTOCOLO_PF';
var __CALL_TYPE_PROTOCOLO_PJ = 'PROTOCOLO_PJ';
/**
 * ____________________________________
 * FIM CONSTANTES
 * ____________________________________
 */

/**____________________________________
 * VARIAVEIS DE CONTROLE
 * ____________________________________
 */
var __flgSenhasValidas = true;
var __senhasValidas = Array();
var __lstContasDigitadas = "";
var __countSenhasDigitadas = 0;
var __funcaoImpressao = "";

/* Variaveis de controle para a dctror */
var __aux_arrayDctror = Array();
var __aux_arrayMantal = Array();
var __type_call = "";
var __aux_cdopcao_dctror = "";
var __aux_cdopcao_mantal = "";
/**____________________________________
 * FIM VARIAVEIS DE CONTROLE
 * ____________________________________
 */

var autorizacao_globais = {
    nrdconta: '',
	obrigatoria: '',
	tpcontrato: '',
	nrcontrato: '',
	vlcontrato: '',
	funcaoImpressao: '', //Função executada somente quando é selecionado a opção de impressão
	funcaoGeraProtocolo: '', //Função enviada quando é executada um protocolo ou trans pend.
	dscomplemento: '',
    lstContas: ""
}

function mostraTelaAutorizacaoContrato(parametros) {

	autorizacao_globais = parametros;

    showMsgAguardo('Aguarde, abrindo autoriza&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'includes/autorizacao_contrato/form_autorizacao_contrato.php',
        data: {
        	nrdconta:    autorizacao_globais.nrdconta,
        	obrigatoria: autorizacao_globais.obrigatoria,
        	tpcontrato:  autorizacao_globais.tpcontrato,
        	nrcontrato:  autorizacao_globais.nrcontrato,
        	vlcontrato:  autorizacao_globais.vlcontrato,
			dscomplemento: autorizacao_globais.dscomplemento,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            formataAutorizacaoContrato(autorizacao_globais.funcaoImpressao);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));           
        }
    });
   
    return false;
}

function formataAutorizacaoContrato(funcaoImpressao){

	__funcaoImpressao = funcaoImpressao;

	$('#divUsoGenerico').css('width', '470px');
	$("input[type='radio']", '#frmAutorizacaoContrato').css('width', '20px');
	$("input[type='password']", '#frmAutorizacaoContrato').css('width', '50px');
	$('#fsSenhasAutorizacaoContrato', '#frmAutorizacaoContrato').css('display', 'none').css('padding-top', '5px');
	$('.lblErro', '#frmAutorizacaoContrato').addClass('rotulo-linha').css('color', 'red');

	$('label[data-campo-nome="sim"]','.senhas').css('text-align','left');
	$('label[data-campo-nome="sim"]','.senhas').css('overflow','hidden');

	$('label[data-campo-nome="sim"]','.senhas').css('width','350px');
	$('label','.senhas').css('font-weight;','inherit');



	$('#btProsseguirAutorizacaoContrato', '#divBotoesAutorizacaoContrato').unbind('click').bind('click', function(){
		
		var tipoAutorizacao = $('input[name=tipautor]:checked', '#frmAutorizacaoContrato').val();
		$('input[name=tipautor]').desabilitaCampo();

		if(tipoAutorizacao == 1){ // senha

			$('#fsSenhasAutorizacaoContrato', '#frmAutorizacaoContrato').css('display', 'block');

			$('#btVoltarAutorizacaoContrato').show();
			$('#btVoltarAutorizacaoContrato').unbind('click').bind('click',function(){
				$('#fsSenhasAutorizacaoContrato').hide();
				$('input[name=tipautor]').habilitaCampo();
				formataAutorizacaoContrato(funcaoImpressao);
			});
			$('input[type=password]','#fsSenhasAutorizacaoContrato')[0].focus();

			formataCamposSenha();


			$('#btProsseguirAutorizacaoContrato', '#divBotoesAutorizacaoContrato').unbind('click').bind('click', function(){
				iniciaValidacaoSenha(autorizacao_globais.funcaoImpressao);
			});

		} else if (tipoAutorizacao == 2){ // impressao

			fechaRotina($('#divUsoGenerico'));
			eval(funcaoImpressao);

		}
	});

	// $('#btVoltarAutorizacaoContrato, #btFecharAutorizacaoContrato', '#divUsoGenerico').unbind('click').bind('click', function(){
		
	// 	fechaRotina($('#divUsoGenerico'));
	// 	eval(funcaoImpressao);

	// });

	//Esconder botão voltar na abertura do modal
	$('#btVoltarAutorizacaoContrato').hide();
}

function iniciaValidacaoSenha(funcaoImpressao){
	$('#btProsseguirAutorizacaoContrato', '#divBotoesAutorizacaoContrato').unbind('click');
	validaSenhaAutorizacaoContrato(funcaoImpressao);

	
	$('#btProsseguirAutorizacaoContrato', '#divBotoesAutorizacaoContrato').unbind('click').bind('click', function(){
		iniciaValidacaoSenha(autorizacao_globais.funcaoImpressao);
	});
}

function validaSenhaAutorizacaoContrato(funcaoImpressao) {

	$('.lblErro', '#frmAutorizacaoContrato').text('');

	if(autorizacao_globais.obrigatoria == 'T'){ // Se todos os campos senha são obrigatorios, validar se foram preenchidos

		var valorVazio = false;
		$('.dssencar', '#frmAutorizacaoContrato').each(function(){
		   	if($(this).val() == ""){
		     	valorVazio = true;
		    }
		});

		if(valorVazio){
			hideMsgAguardo();
			showError("error", "Todos os campos de senha s&atilde;o obrigat&oacute;rios", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			return false;
		}
	}

	if(autorizacao_globais.obrigatoria == '1'){ // Validar se tem pelo menos 1 campo preenchido

		var camposSenhaVazios = true;
		$('.dssencar', '#frmAutorizacaoContrato').each(function(){
		   	if($(this).val() != ""){
		     	camposSenhaVazios = false;
		    }
		});

		if(camposSenhaVazios){
			hideMsgAguardo();
			showError("error", "Pelo menos 1 campo de senha deve ser preenchido", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			return false;
		}
	}

	validaSenhas(); //Função recursiva
	return false;
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Observação: ao alterar a função atentar ao formato recursivo.
 */
function validaSenhas(countSenhaDigitada){

	if(typeof countSenhaDigitada == "undefined"){
		countSenhaDigitada = 0;
	}

	var lstSenhas = $('.senhas', '#fsSenhasAutorizacaoContrato'); //Campos senha
	var inpessoa    = $('input[name="inpessoa"]', '#frmAutorizacaoContrato').val();

	var divSenha = $(lstSenhas)[countSenhaDigitada];
		var nrconta_senha = $(divSenha).data('nrcontausuario');
	var senhaCampo = $('.dssencar', divSenha).val();

	if(senhaCampo == ""){
		__flgSenhasValidas = false;
		__senhasValidas.push({
			senha: 'INVALIDA',
			digitada: false
		});

		if(countSenhaDigitada+1 < lstSenhas.length){
			countSenhaDigitada++;
			validaSenhas(countSenhaDigitada); //Recursive
		}else{
			finalizaValidaSenha();
		}
		return false;
	}

			$.ajax({
				type: "POST",
				url: UrlSite + "includes/autorizacao_contrato/valida_senha.php", 
				data: {
					nrdconta: nrconta_senha,
					inpessoa: inpessoa,
					nrcontrato: autorizacao_globais.nrcontrato, //bruno - prj 470 - alt 1
			obrigatoria: autorizacao_globais.obrigatoria,
			dssencar: senhaCampo,
					nrSenhas: lstSenhas.length,
					redirect: "script_ajax"
				}, 
		        error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
		            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				},
				beforeSend: function(){
					showMsgAguardo("Aguarde, validando senha ...");
					__flag_validandoSenha = true;
				},
		        success: function (response) {
					try {
						if ( response.indexOf('showError("error"') == -1 ) {
							if(trim(response) == 'invalida'){
								$('.lblErro', divSenha).text('Senha Incorreta');
						__flgSenhasValidas = false;
						__senhasValidas.push({
									senha: 'INVALIDA',
									digitada: true
								});
							} else {
						__lstContasDigitadas += (__lstContasDigitadas == '') ? trim(response) : ';' + trim(response);

						__senhasValidas.push({
									senha: 'VALIDA',
									digitada: true
								});
							}

					if(countSenhaDigitada+1 < lstSenhas.length){
						countSenhaDigitada++;
						validaSenhas(countSenhaDigitada); //Recursive
						} else {
						finalizaValidaSenha();
					}

				} else {
					__flgSenhasValidas = false;
							eval(response);
						}
		            } catch (error) {
		                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
					}
				}				
			});

		}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's;
 * Data: 12/02/2019
 */
function finalizaValidaSenha(codTela){
	var inpessoa    = $('input[name="inpessoa"]', '#frmAutorizacaoContrato').val();

	if(typeof codTela == 'undefined'){
		codTela = 0;
	}

	if(codTela == 0){
		switch (autorizacao_globais.tpcontrato) {
			case __TELA_DCTROR:
				finalizaValidaSenha(__TELA_DCTROR);
				return false;
				break;
			case __TELA_MANTAL:
				finalizaValidaSenha(__TELA_MANTAL);
				return false;
				break;
		}
	}

	//usada para saber qual vai ser a ação a ser usada | necessaria para a tela DCTROR
	var typeCall = '';

	if(autorizacao_globais.obrigatoria == "1" && 
	   verificaSenhas(__senhasValidas) &&
	   __senhasValidas.length >= 1){
		if(inpessoa == 1){
			typeCall = __CALL_TYPE_PROTOCOLO_PF; //geraProtocolo(__funcaoImpressao);
		} else {
			if(__flgSenhasValidas){
				typeCall = __CALL_TYPE_PROTOCOLO_PJ; //geraProtocolo_pj(__lstContasDigitadas,__funcaoImpressao);
			}else{
			typeCall = __CALL_TYPE_TRANS_PEND; //criaTransPend(__lstContasDigitadas,__funcaoImpressao);
		}
		}
	}else if(__flgSenhasValidas){ // Verifica se as senhas digitadas são válidas
		if(inpessoa == 1){
			typeCall = __CALL_TYPE_PROTOCOLO_PF; //geraProtocolo();
		} else {
			typeCall = __CALL_TYPE_PROTOCOLO_PJ; //geraProtocolo_pj(__lstContasDigitadas,__funcaoImpressao);
		}
	}

	__type_call = typeCall; //Salvar a chamada

	switch (typeCall) {
		case __CALL_TYPE_PROTOCOLO_PF:
			geraProtocolo(__funcaoImpressao, codTela);
			break;
		case __CALL_TYPE_PROTOCOLO_PJ:
			geraProtocolo_pj(__lstContasDigitadas,__funcaoImpressao, codTela);
			break;
		case __CALL_TYPE_TRANS_PEND:
			criaTransPend(__lstContasDigitadas,__funcaoImpressao, codTela);
			break;
	}

	if(!__flgSenhasValidas){
		zerarVariaveisControleValidaSenha();
		hideMsgAguardo();
		blockBackground(parseInt($('#divUsoGenerico').css('z-index')));
		return false;
	}
	zerarVariaveisControleValidaSenha();
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 12/02/2019;
 */
function zerarVariaveisControleValidaSenha(){
		__flag_validandoSenha = false;
	__flgSenhasValidas = true;
	__senhasValidas = Array();
	__lstContasDigitadas = "";
	__countSenhasDigitadas = null;
	__funcaoImpressao = null;
}

function geraProtocolo(funcaoImpressao, codTela){
	if(typeof codTela == 'undefined'){codTela = 0;}

	//Se for dctror preciso enviar o primeiro dccomplemento do mesmo
	// Executa o script de validação dos dados do rating através de ajax
	console.log(__aux_arrayDctror);
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/autorizacao_contrato/gera_protocolo.php",
		data: {
			nrdconta: autorizacao_globais.nrdconta,			
			cdtippro: autorizacao_globais.tpcontrato,
			nrcontrato: autorizacao_globais.nrcontrato,
			vlcontrato: autorizacao_globais.vlcontrato,
			funcaoImpressao: (typeof funcaoImpressao == 'undefined' ? autorizacao_globais.funcaoImpressao : funcaoImpressao),
			funcaoGeraProtocolo: autorizacao_globais.funcaoGeraProtocolo,
			dscomplemento: autorizacao_globais.dscomplemento,
			auxArrayDctror: getArrayDcTror(__aux_arrayDctror),
			auxArrayMantal:	getArrayMantal(__aux_arrayMantal),
			cdopcao_dctror: __aux_cdopcao_dctror,
			cdopcao_mantal: __aux_cdopcao_mantal,
			codTela: codTela,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				__flag_validandoSenha = false;
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

function geraProtocolo_pj(lstContasDigitadas,funcaoImpressao,codTela){
	if(typeof codTela == 'undefined'){codTela = 0;}
	// Executa o script de validação dos dados do rating através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/autorizacao_contrato/gera_protocolo_pj.php",
		data: {
			nrdconta: autorizacao_globais.nrdconta,			
			cdtippro: autorizacao_globais.tpcontrato,
			nrcontrato: autorizacao_globais.nrcontrato,
			vlcontrato: autorizacao_globais.vlcontrato,
			contas_digitadas: lstContasDigitadas,
			funcaoImpressao: funcaoImpressao,
			funcaoGeraProtocolo: autorizacao_globais.funcaoGeraProtocolo,
			dscomplemento: autorizacao_globais.dscomplemento,
			auxArrayDctror: getArrayDcTror(__aux_arrayDctror),
			auxArrayMantal:	getArrayMantal(__aux_arrayMantal),
			cdopcao_dctror: __aux_cdopcao_dctror,
			cdopcao_mantal: __aux_cdopcao_mantal,
			codTela: codTela,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				__flag_validandoSenha = false;
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

function criaTransPend(lstContasDigitadas,funcaoImpressao, codTela){
	if(typeof codTela == 'undefined'){codTela = false;}
	// Executa o script de validação dos dados do rating através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/autorizacao_contrato/cria_trans_pend.php",
		data: {
			nrdconta: autorizacao_globais.nrdconta,			
			tpcontrato: autorizacao_globais.tpcontrato,
			nrcontrato: autorizacao_globais.nrcontrato,
			vlcontrato: autorizacao_globais.vlcontrato,
			contas_digitadas: lstContasDigitadas,
			funcaoImpressao: funcaoImpressao,
			funcaoGeraProtocolo: autorizacao_globais.funcaoGeraProtocolo,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				__flag_validandoSenha = false;
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}


function formataCamposSenha(){
	var lengthSenhas = $('.senhas input', '#fsSenhasAutorizacaoContrato').length;

	$('.senhas input', '#fsSenhasAutorizacaoContrato').attr('maxlength','6');

	$('.senhas input', '#fsSenhasAutorizacaoContrato').each(function(index,elem){
		var tbSenha = elem;

		$(tbSenha).unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 13 || e.keyCode == 9) {
                if(lengthSenhas > 0 && (index+1) < lengthSenhas){
					var campoSenha = $('.senhas input', '#fsSenhasAutorizacaoContrato')[index+1];
					campoSenha.focus();
				}else{
					$("#btProsseguirAutorizacaoContrato").focus();
					//validaSenhaAutorizacaoContrato();
				}
            }
		});
	});
}


/**
 * Autor: Bruno Luiz Katzjarowski;
 * Validar senhas para regra de obrigatoria == 1
 * @param {senha: ['VALIDA'|'INVALIDA'], digitada: true|false} arrSenhas 
 */
function verificaSenhas(arrSenhas){
	var senhasDigitadas = arrSenhas.filter(function(obj){
		return obj.digitada;
	});

	var senhasDigitadasValidas = senhasDigitadas.filter(function(obj){
		return (obj.senha == "VALIDA");
	});

	// if(senhasDigitadasValidas.length > 1){
	// 	return false;
	// }

	if(senhasDigitadas.length > senhasDigitadasValidas.length){
		return false;
	}else{
			return true;
		}
}


/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 14/02/2019
 * @param {string} cdopcao Opção selecionada na tela dctror 
 * @param {array} dados Contra ordens adicionadas na tela dctror
 */
function getDscomplementoDctror(cdopcao,dados){
	var tipoOpcao = "";
	switch(cdopcao){
		case 'I':
			tipoOpcao = "Inclusao";
			break;
		case 'A':
			tipoOpcao = "Alteracao";
			break;
		case 'E':
			tipoOpcao = "Cancelamento";
			break;
	}
	var retorno = tipoOpcao;

	if(typeof dados != "undefined"){
		retorno += '#'+dados["cdbanchq"];
		retorno += '#'+dados["cdagechq"];
		retorno += '#'+dados["nrdconta"];
		retorno += '#'+dados["nrinichq"];
		retorno += '#'+dados["nrfinchq"];
	}

	return retorno;
}

function getArrayMantal(){
	var auxArray = [];
	$(__aux_arrayMantal).each(function(i,elem){
		var obj = {
			cdagechq: elem['cdagechq'],
			cdbanchq: elem['cdbanchq'],
			nrctachq: elem['nrctachq'],
			nrfimchq: elem['nrfimchq'],
			nrinichq: elem['nrinichq']
		}
		auxArray.push(obj);
	});
	return auxArray;
}

function getArrayDcTror(){
	var auxArray = [];
	$(__aux_arrayDctror).each(function(i,elem){
		var obj = {
			cdagechq: elem['cdagechq'],
			cdbanchq: elem['cdbanchq'],
			nrdconta: elem['nrdconta'],
			nrinichq: elem['nrinichq'],
			nrfimchq: elem['nrfimchq']
		}
		auxArray.push(obj);
	});
	console.log(auxArray);
	return auxArray;
}