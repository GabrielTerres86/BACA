
/*********************************************************************************************
* Fonte: cadpcn.js                                       			                   
* CRIA��O      : Andr� (DB1)
* DATA CRIA��O : 15/03/2018
* OBJETIVO     : Mostrar tela CADPCN
*********************************************************************************************/


// Defini��o de algumas vari�veis globais 
var cddopcao, cTodosCabecalho, cCddopcao;

//Formul�rio Cabe�alhho
var frmCab = 'frmCab';


// Verifica se ja fez a solicita��o inicial
var escolheOpcao;

	$(document).ready(function(){
	    estadoInicial();
		highlightObjFocus( $('#frmCab') );
		$( "#cddopcao" ).focus();
		//Exibe cabe�alho e define tamanho da tela
		$("#frmCab").css({"display":"block"});
		$("#divTela").css({"width":"700px","padding-bottom":"2px"});

		return false;
	});

	function estadoInicial() {
		$('#divTela').fadeTo(0,0.1);
		$('#frmCab').css({'display':'block'});

		escolheOpcao = false;
		
		$('#frmValorMaximoCnae').css({'display':'none'});
		$('#divBotoes', '#divTela').css({'display':'none'});
		
		formataCabecalho();
		
		// Remover class campoErro
		$('input,select', '#frmCab').removeClass('campoErro');
		$('input,select', '#frmValorMaximoCnae').removeClass('campoErro');
		
		cCddopcao.val( 'C' );
		removeOpacidade('divTela');	
		unblockBackground();
		hideMsgAguardo();
		controlaFocoInicial();
		trocaBotao('Prosseguir');
		
		$('#cddopcao','#frmCab').habilitaCampo();
		$('#cddopcao option[value="C"]').attr("selected", "selected");
		$('#cddopcao','#frmCab').focus();
		$('#vlcnae','#frmValorMaximoCnae').desabilitaCampo().val('');
		$('#cdcnae','#frmValorMaximoCnae').desabilitaCampo().val('');
		cTodosFormCnae = $('input[type="text"],select,input[type="checkbox"]','#frmValorMaximoCnae'); 
		cTodosFormCnae.limpaFormulario();
		return false;
	}


	function formataCabecalho() {

		// Cabecalho
		rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
		cCddopcao			= $('#cddopcao','#'+frmCab); 
		btnCab				= $('#btOK','#'+frmCab);
		
		//Ajusta layout para o Internet Explorer
		if ( $.browser.msie ) {

			rCddopcao.css('width','40px');
			
		}else {

			rCddopcao.css('width','44px');
		}
		

		cCddopcao.css({'width':'460px'});

		$('#cddopcao','#frmCab').focus();

		layoutPadrao();
		
		return false;	
	}



	function controlaFocoInicial() {

		$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaFormulario();
				return false;
			}	
		});

		$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaFormulario();
				return false;
			}
		});
	}


	function LiberaFormulario() {
		var cTodosFormCnae;
		cddopcao = cCddopcao.val();
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	
		
		// Desabilita campo op��o
		$('#cddopcao','#frmCab').desabilitaCampo();
		$('#btOK','#frmCab').desabilitaCampo();
		$('input,select', '#frmValorMaximoCnae').removeClass('campoErro');

		// Controle de M�scaras
		$('#cdcnae','#frmValorMaximoCnae').habilitaCampo();
		$('#vlcnae','#frmValorMaximoCnae').desabilitaCampo();
		// $('#vlcnae','#frmValorMaximoCnae').trigger('blur');
	
		escolheOpcao = false;
		formataCnae();
	    layoutPadrao();
		controlaOperacao();

		return false;
	}

	function controlaOperacao(action) {
		if(action){
			cddopcao = action;
		}
		//controle inicial
		controlaFocoFormulariosCnae(cddopcao);
		if(!escolheOpcao){
			hideMsgAguardo();
			escolheOpcao = true;
			return false;
		} 
		else if($("#cdcnae").val()!='' && $("#dscnae").val()==''){
			controlaBuscaCnae(cddopcao,$("#cdcnae").val());
		}
		else {
			if ((cddopcao == "C" )) {
					manterRotina();
					return false;
			} else if (cddopcao == "I"){
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');
				return false;
			} else if (cddopcao == "A"){
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');
				return false;
			} else if (cddopcao == "E"){
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');
				return false;
			}
		}
	} 


	function controlaFocoFormulariosCnae(param) {
		var cdcnae  = $('#cdcnae');
		var dscnae  = $('#dscnae');
		var vlcnae  = $('#vlcnae');
		var btSalvar  = $('#btSalvar');
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#frmValorMaximoCnae').css({'display':'block'});
		/*Limpa as funcoes*/
		$('#cdcnae').unbind('change');
		$('#cdcnae').unbind('keypress');
		$("#cdcnae").addClass('inteiro').focus();
		$("#vlcnae").addClass('monetario').focus();
		layoutPadrao();

		$('#cdcnae','#frmValorMaximoCnae').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				controlaBuscaCnae(cddopcao,cdcnae.val());
			}
		});
		$("#vlcnae").bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btSalvar').focus();
				return false;
			}	
		});
	}

	function controlaBuscaCnae(cddopcao,cdcnae){
		buscaDescricaoCnae(cdcnae,function(){
			$('input,select', '#frmValorMaximoCnae').removeClass('campoErro');

			trocaBotao('Prosseguir');
			$('#vlcnae','#frmValorMaximoCnae').val('');
			if(!$("#divError").is(":visible")){
				switch (cddopcao){
					case 'C':
						$("#btSalvar").focus();
					break;
					case 'I':
						$("#vlcnae").habilitaCampo().focus();
					break;
					case 'A':
						buscaValorCnae(cdcnae,function(){
							if($("#vlcnae").val()!=""){
								$("#vlcnae").blur();
								$("#vlcnae").habilitaCampo().focus();
							}
						});
					break;
					case 'E':
						buscaValorCnae(cdcnae,function(){
							if(!$("#divError").is(":visible")){
								$("#vlcnae").blur();
								trocaBotao('Excluir');
								$('#btSalvar').focus();
							}
						});
					break;
				}
			}
		});
	}


	function manterRotina(action) {
		if(!action){
			var cddopcao  = $('#cddopcao').val();
		} else {
			var cddopcao = action;
		}
		var cdcnae  = $('#cdcnae').val();
		var dscnae  = $('#dscnae').val();
		var vlcnae  = $('#vlcnae').val();

		$('#btSalvar','#frmValorMaximoCnae').desabilitaCampo();

		if (cddopcao == undefined || cddopcao == '') {
		
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}

		
		if (cdcnae == undefined || cdcnae == '' || cdcnae < 1){
		
			showError('error','Informe o codigo do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}
		

		if(cddopcao != 'C' && cddopcao != 'E' && cddopcao != 'AE'){

			if (vlcnae == undefined || vlcnae == '' || vlcnae < 1){
			
				showError('error','Informe o valor do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
				return false;
			}
		}

		if(cddopcao == 'C'){
			showMsgAguardo('Aguarde, buscando ...');
			// Executa script de confirma��o atrav�s de ajax
			buscaValorCnae(cdcnae,function(){
				if($("#vlcnae").val()!=""){
					$("#vlcnae").blur();
					trocaBotao('');
					$('#btVoltar').focus();
				}
			});
		}
	}


	//fun��o para diversas requisi��es passando apenas no nome do arquivo e os dados
	function mostraRotina(pagina) {
		var cddopcao  = $('#cddopcao').val();
		var cdcnae  = $('#cdcnae').val();
		var dscnae  = $('#dscnae').val();
		var vlcnae  = $('#vlcnae').val();

		if (pagina === undefined){
		
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}

		
		if (cdcnae === undefined || cdcnae === '' || cdcnae < 1){
		
			showError('error','Informe o codigo do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}
		

		if(cddopcao != 'C' && cddopcao != 'E' && cddopcao != 'AE'){

			vlcnae = normalizaNumero( vlcnae );

			if (vlcnae == undefined || vlcnae == ""){

				showError('error','Informe o valor do CNAE corretamente.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
				return false;
			}
		}


		showMsgAguardo('Aguarde, buscando ...');

		if( cddopcao == 'E'){

			// Executa script de confirma��o atrav�s de ajax
			$.ajax({		
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/'+pagina+'.php', 
				data: {
					cddopcao: cddopcao,
					cdcnae: cdcnae,
					vlcnae: vlcnae,
					redirect: 'html_ajax'			
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();			
					showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {
					
					// if (response === undefined || response == null || response.length <= 0 || response == '' || response <= 0) {

					// 	// $('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');

					// } else {

					// 	// $('#vlcnae').val(response);
					// 	// $('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');					
					// }
						hideMsgAguardo();
						$msgOK = "Dados exclu&iacute;dos com sucesso";
						showError('inform', $msgOK, 'Alerta - Ayllos', "hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
						estadoInicial();
				}
			});
		} 


		if( cddopcao == 'A'){

			// Executa script de confirma��o atrav�s de ajax
			$.ajax({		
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/'+pagina+'.php', 
				data: {
					cddopcao: cddopcao,
					//cdcoop: cdcoop,
					cdcnae: cdcnae,
					vlcnae: vlcnae,
					redirect: 'html_ajax'			
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();			
					showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {

					try {
						hideMsgAguardo();
						eval(response);
						$('#vlcnae').val('');
						$('#cdcnae').val('');
						$('#dscnae').val('');

						showError("inform","Dados alterados com sucesso","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");

					} catch(error) {
						hideMsgAguardo();
						showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
					}
				}
			});
		} 


		if( cddopcao == 'I'){

		// Executa script de confirma��o atrav�s de ajax
			$.ajax({		
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/'+pagina+'.php', 
				data: {
					cddopcao: cddopcao,
					//cdcoop: cdcoop,
					cdcnae: cdcnae,
					vlcnae: vlcnae,
					redirect: 'html_ajax'			
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();			
					showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {
					try {

						hideMsgAguardo();				
						eval(response);
						//$('#vlcnae').val(response);
						//$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');	
					} catch(error) {
						hideMsgAguardo();
						showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
						$('#vlcnae').val('');
						$('#cdcnae').val('');
						$('#dscnae').val('');
					}
				}
			});
		}

		return false;
	}
 


	function formataCnae() {

		highlightObjFocus($('#frmValorMaximoCnae'));	
	}


	function btnVoltar() {

		// var cddopcao  = $('#cddopcao');

		// // verifica se existe display block no formulario de valor CNAE
		// if($('#frmValorMaximoCnae').css('display') == "block") {
			
		// 	$('#cdcnae').attr( "aux", " " );
		// 	estadoInicial();
		// 	return false;
		// } 	

	    estadoInicial();
		// highlightObjFocus( $('#frmCab') );
		// $("#frmCab").css({"display":"block"});
		// $("#divTela").css({"width":"700px","padding-bottom":"2px"});
		// trocaBotao('Prosseguir');

		// controlaFocoFormulariosCnae();

		// $( "#cddopcao" ).focus();


	}


	//fun��o para troca do nome do bot�o
	function trocaBotao( botao ) {
		$('#divBotoes','#divTela').html('');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
		if ( botao != '') {
			$('#divBotoes','#divTela', '#').append('&nbsp;<a href="" class="botao" id="btSalvar" name="btSalvar"  onClick="controlaOperacao(); return false;">'+botao+'</a>');
		}
		return false;
	}

	function controlaPesquisas() {
		var procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	

		procedure	= 'BUSCA_CNAE';
		titulo      = 'CNAE';
		qtReg		= '30';
		filtros     = 'C�d. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
		colunas     = 'C�digo;cdcnae;20%;right|Desc CANE;dscnae;80%;left';
		
		mostraPesquisa('ZOOM0001',procedure,titulo,qtReg,filtros,colunas,'' ,'sequenciaPesquisa()');

		return false;
	}

	function sequenciaPesquisa(){
		cddopcao = $("#cddopcao").val();
		if(cddopcao == 'A' || cddopcao == 'E'){
			controlaBuscaCnae(cddopcao,$("#cdcnae").val());
		}
	}

	function buscaDescricaoCnae(cdcnae,callback) {
		if(cdcnae){
			showMsgAguardo('Aguarde, buscando ...');
			// Executa script de confirma��o atrav�s de ajax
			$.ajax({		
				type: "POST",
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/manter_rotina.php', 
				data: {
					operacao: 'CONSULTA_CNAE',
					cdcnae: cdcnae,
					redirect: 'html_ajax'
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);$("#cdcnae").focus();');
					$("#vlcnae").val('');
				},
				success: function(response) {
					try {
						hideMsgAguardo();
						eval(response);
						callback();
					
					} catch(error) {
						hideMsgAguardo();
					}
				}				
			});
		}
	}

	function buscaValorCnae(cdcnae,callback) {
		if(cdcnae){
			showMsgAguardo('Aguarde, buscando ...');
			// Executa script de confirma��o atrav�s de ajax
			$.ajax({		
				type: "POST",
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/manter_rotina.php', 
				data: {
					operacao: 'CONSULTA_VALOR_CNAE',
					cdcnae: cdcnae,
					redirect: 'html_ajax'
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					$("#vlcnae").val('');
					showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);$("#cdcnae").focus();');
				},
				success: function(response) {
					try {
						hideMsgAguardo();
						eval(response);
						callback();
					} catch(error) {
						$("#vlcnae").val('');
						hideMsgAguardo();
					}
				}
			});
		}
	}