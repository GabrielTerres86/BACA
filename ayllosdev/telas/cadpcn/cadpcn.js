/*********************************************************************************************
 Fonte: cadpcn.js                                       			                   
 Autor: Andrew Luis Golden
 Data : Mar�o/2018                                                                  
 Altera��es:                                          Ultima Alteracao: 18/03/2018
 																					
 19/03/2018 - Ajustes gerais para liberacao. (______)	
 
*********************************************************************************************/

// Defini��o de algumas vari�veis globais 
var cddopcao, cTodosCabecalho;

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
		
		cCddopcao.val( cddopcao );
		removeOpacidade('divTela');	
		unblockBackground();
		hideMsgAguardo();
		controlaFoco();

		$('#cddopcao','#frmCab').habilitaCampo();
		$('#cddopcao option[value="C"]').attr("selected", "selected");
		$('#cddopcao','#frmCab').focus();
		$('#vlcnae','#frmValorMaximoCnae').habilitaCampo();
		$('#vlcnae','#frmValorMaximoCnae').focus(function(){$(this).select();});

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



	function controlaFoco() {

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
		$('#vlcnae','#frmValorMaximoCnae').desabilitaCampo();
		
		$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
		//$('#vlcnae','#frmValorMaximoCnae').setMaskOnKeyUp("INTEGER","zzzzzzzzzzz","",e);

		$('#vlcnae','#frmValorMaximoCnae').trigger('blur');

		formataCnae();
	    layoutPadrao();
		controlaOperacao();

		return false;

	}



	function controlaOperacaoExcluir() {

		controlaOperacao('E');
	}




	function controlaOperacao(action) {

		if(action){
			cddopcao = action;
		}

		//controle inicial
		if(escolheOpcao == false){
			
			controlaFocoFormulariosCnae(cddopcao);
			hideMsgAguardo();

			escolheOpcao = true;
			return false;
			
		} else {


			if ((cddopcao == "C" )) {
			
					manterRotina();
					return false;
			
			} else if (cddopcao == "I"){
			
				controlaFocoFormulariosCnae('I');
				//mostraRotina('manter_rotina');
				mostraRotina('principal');

				return false;

			} else if (cddopcao == "A"){
			
				controlaFocoFormulariosCnae('A');
				//mostraRotina('manter_rotina');
				mostraRotina('principal');
				return false;

			} else if (cddopcao == "E"){

				controlaFocoFormulariosCnae('E');
				//mostraRotina('manter_rotina');
				mostraRotina('principal');
				return false;

			} else if (cddopcao == "AE"){
			
				manterRotina(cddopcao);


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


		if(param == 'I'){

			$('#vlcnae','#frmValorMaximoCnae').habilitaCampo();
		}

		if(param == 'A'){

			$('#vlcnae','#frmValorMaximoCnae').habilitaCampo();
		}


		$('#cdcnae','#frmValorMaximoCnae').unbind('blur').bind('blur',function() {

					if(!cdcnae){
						
						$('#cdcnae').val();
					}

					buscaDescricaoCnae(cdcnae);

		});



		cdcnae.focus().unbind('keypress').bind('keypress', function(e) {

			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				
				if(param == 'E' || param == 'C' || param == 'AE'){

							$(this).removeClass('campoErro');
							
							btSalvar.focus();

							return false;

				} else {

							$(this).removeClass('campoErro');
							vlcnae.focus();
							return false;
				}
			}	
		});	

		vlcnae.unbind('keypress').bind('keypress', function(e) {

			if ( e.keyCode == 9 || e.keyCode == 13 ) {	

				btSalvar.focus();
				return false;
			}	

			$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
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
		
			showError('error','N&atilde;o foi poss&iacute;vel concluirrrrr1111 a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}

		
		if (cdcnae == undefined || cdcnae == '' || cdcnae < 1){
		
			showError('error','Informe o codigo do CNAE111.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
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
				$.ajax({		
					type: "POST",
					dataType: 'html',
					url: UrlSite + 'telas/cadpcn/principal.php', 
					data: {
						cddopcao: cddopcao,
						cdcnae: cdcnae,
						dscnae: dscnae,
						vlcnae: vlcnae,
						redirect: 'html_ajax'
					}, 
					error: function(objAjax,responseError,objExcept) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
					},

					success: function(response) {

						try {
							hideMsgAguardo();				
							eval(response);

								$('#vlcnae').val(response);
								//$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');	

						} catch(error) {

							hideMsgAguardo();
							showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
							
						}
					}				
				});			
			

		}


		if(cddopcao == 'AE'){

			cddopcao = 'C';

				showMsgAguardo('Aguarde, buscando ...');

			// Executa script de confirma��o atrav�s de ajax
				$.ajax({		
					type: "POST",
					dataType: 'html',
					url: UrlSite + 'telas/cadpcn/principal.php', 
					data: {
						cddopcao: cddopcao,
						cdcnae: cdcnae,
						dscnae: dscnae,
						vlcnae: vlcnae,
						redirect: 'html_ajax'
					}, 
					error: function(objAjax,responseError,objExcept) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
					},

					success: function(response) {

						try {
							hideMsgAguardo();				
							eval(response);
							$('#vlcnae').val(response);
							cddopcao = 'E';
							trocaBotao('Excluir');
							$('#btSalvar').focus();


						} catch(error) {
							hideMsgAguardo();
							cddopcao = 'AE';
							showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
							
						}
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

		if(cddopcao == 'AE'){

			cddopcao = 'E';
		}


		if (pagina === undefined){
		
			showError('error','N&atilde;o foi poss&iacute;vel concluirrrrr a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}

		
		if (cdcnae === undefined || cdcnae === '' || cdcnae < 1){
		
			showError('error','Informe o codigo do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
			return false;
		}
		

		if(cddopcao != 'C' && cddopcao != 'E' && cddopcao != 'AE'){

			vlcnae = normalizaNumero( vlcnae );

			if (vlcnae == undefined || vlcnae == ""){

				showError('error','Informe o valor do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
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
					//cdcoop: cdcoop,
					cdcnae: cdcnae,
					vlcnae: vlcnae,
					redirect: 'html_ajax'			
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();			
					showError('error','N�o foi poss�vel concluir1111 a requisi��o.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {
					
					if (response === undefined || response == null || response.length <= 0 || response == '' || response <= 0) {

						$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');

					} else {

						$('#vlcnae').val(response);
						$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');					
					}
						hideMsgAguardo();
						$msgOK = "Dados exclu&iacute;dos com sucesso";
						showError('error', $msgOK, 'Alerta - Ayllos', "hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
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

							$('#vlcnae').val(response);
							$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');

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
					showError('error','N�o foi poss�vel concluir1111 a requisi��o.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {

					try {

						hideMsgAguardo();				
						eval(response);
							$('#vlcnae').val(response);
							$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');	
					} catch(error) {

						hideMsgAguardo();
						showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
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

		var cddopcao  = $('#cddopcao');
		
		// verifica se existe display block no formulario de valor CNAE
		if($('#frmValorMaximoCnae').css('display') == "block") {
			
			$('#cdcnae').attr( "aux", " " );
			estadoInicial();
			return false;
		} 	
	}



	//fun��o para troca do nome do bot�o
	function trocaBotao( botao ) {

		$('#divBotoes','#divTela').html('');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Cancelar</a>');

		if ( botao != '') {
			var cddopcao = 'E';
			$('#divBotoes','#divTela', '#').append('&nbsp;<a href="#" class="botao"  id="btSalvar" onClick="controlaOperacaoExcluir(); return false;" >'+botao+'</a>');
		}

		return false;
	}


	function controlaPesquisas() {

		// Vari�vel local para guardar o elemento anterior
		var campoAnterior = '';
		var bo, procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	

		bo = 'b1wgen0059.p';
		procedure	= 'BUSCA_CNAE';
		titulo      = 'CNAE';
		qtReg		= '30';
		filtros     = 'C�d. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
		colunas     = 'C�digo;cdcnae;20%;right|Desc CANE;dscnae;80%;left';			
		
		mostraPesquisa('ZOOM0001',procedure,titulo,qtReg,filtros,colunas);

		// CNAE
		$('#cdcnae','#frmValorMaximoCnae').unbind('change').bind('change',function() {
			procedure	= 'BUSCA_CNAE';
			titulo      = 'CNAE';		
			filtrosDesc = 'flserasa|2';
			buscaDescricao('ZOOM0001',
				procedure,
				titulo,
				$(this).attr('name'),
				'dscnae',
				$(this).val(),'dscnae',filtrosDesc,'frmValorMaximoCnae');
		});	
		$('#vlcnae').val("");
	}



	function buscaDescricaoCnae(cdcnae) {

		var bo 				= 'b1wgen0059.p';
		var procedure		= 'BUSCA_CNAE';
		var titulo      	= 'CNAE';
		var filtros     	= 'C�d. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
	  	var filtrosDesc = 'flserasa|2';
	    var nomeFormulario 	= 'frmValorMaximoCnae';
		buscaDescricao('ZOOM0001', procedure, titulo, 'cdcnae', 'dscnae', cdcnae.val(),'dscnae',filtrosDesc,'frmValorMaximoCnae');
		$('#vlcnae').val("");
	    return false;
	}