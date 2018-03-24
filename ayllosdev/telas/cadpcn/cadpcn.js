
/*********************************************************************************************
* Fonte: cadpcn.js                                       			                   
* CRIAÇÃO      : André (DB1)
* DATA CRIAÇÃO : 15/03/2018
* OBJETIVO     : Mostrar tela CADPCN
*********************************************************************************************/


// Definição de algumas variáveis globais 
var cddopcao, cTodosCabecalho;

//Formulário Cabeçalhho
var frmCab = 'frmCab';


// Verifica se ja fez a solicitação inicial
var escolheOpcao;

	$(document).ready(function(){
	       
	    estadoInicial();
		
		highlightObjFocus( $('#frmCab') );
		$( "#cddopcao" ).focus();
		
		//Exibe cabeçalho e define tamanho da tela
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
		trocaBotaon('Prosseguir');
		
		
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
		
		// Desabilita campo opção
		$('#cddopcao','#frmCab').desabilitaCampo();
		$('#btOK','#frmCab').desabilitaCampo();
		$('input,select', '#frmValorMaximoCnae').removeClass('campoErro');

		// Controle de Máscaras
		$('#vlcnae','#frmValorMaximoCnae').desabilitaCampo();
		
//		$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');

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
			
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');

				return false;

			} else if (cddopcao == "A"){
			
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');
				return false;

			} else if (cddopcao == "E"){

				controlaFocoFormulariosCnae('E');
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','mostraRotina(\'principal\');','btnVoltar();','sim.gif','nao.gif');
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
			$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
		}

		if(param == 'A'){

			$('#vlcnae','#frmValorMaximoCnae').habilitaCampo();
			$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
		}


		$('#cdcnae','#frmValorMaximoCnae').unbind('blur').bind('blur',function() {

			if(!cdcnae){
					
				cdcnae = $('#cdcnae').val();
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

			//$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
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

			// Executa script de confirmação através de ajax
			$.ajax({		
				type: "POST",
				dataType: 'html',
				url: UrlSite + 'telas/cadpcn/principal.php', 
				data: {
					cddopcao: cddopcao,
					cdcnae: cdcnae,
					dscnae: dscnae,
					vlcnae: vlcnae,
					//vlcnae: normalizaNumero(vlcnae),
					redirect: 'html_ajax'
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				},
				success: function(response) {

						try {

							hideMsgAguardo();
							eval(response);
							$('#vlcnae').val(response);
							$('#btVoltar').focus('');
							trocaBotao('');
						
						} catch(error) {
							hideMsgAguardo();
							
							var verify = parseInt(response);

						if( ( isNaN( eval(verify) ) ) ){

							showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
							$('#cdcnae').val('');
							$('#dscnae').val('');
							$('#vlcnae').val('');

						} else {

							$('#vlcnae').val(response);
							$('#btVoltar').focus('');
							trocaBotao('');
						}
					}
				}				
			});			
		}


		if(cddopcao == 'AE'){

			cddopcao = 'C';

			showMsgAguardo('Aguarde, buscando ...');

			// Executa script de confirmação através de ajax
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
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				},

				success: function(response) {

					try {
						hideMsgAguardo();				
						//eval(response);
						$('#vlcnae').val(response);
						cddopcao = 'E';
						trocaBotao('Excluir');
						$('#btSalvar').focus();

					} catch(error) {

						hideMsgAguardo();
						cddopcao = 'AE';
						
						var verify = parseInt(response);

						if( ( isNaN( eval(verify) ) ) ){

							showError("error",response,"Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
							$('#cdcnae').val('');
							$('#dscnae').val('');
							$('#vlcnae').val('');

						} else {

							$('#vlcnae').val(response);
							$('#btVoltar').focus('');
							trocaBotao('');
						}
					}
				}				
			});			
		}
	}


	//função para diversas requisições passando apenas no nome do arquivo e os dados
	function mostraRotina(pagina) {

		var cddopcao  = $('#cddopcao').val();
		var cdcnae  = $('#cdcnae').val();
		var dscnae  = $('#dscnae').val();
		var vlcnae  = $('#vlcnae').val();

		if(cddopcao == 'AE'){
			cddopcao = 'E';
		}

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

				showError('error','Informe o valor do CNAE.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
				return false;
			}
		}


		showMsgAguardo('Aguarde, buscando ...');

		if( cddopcao == 'E'){

			// Executa script de confirmação através de ajax
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
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
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
						showError('inform', $msgOK, 'Alerta - Ayllos', "hideMsgAguardo();focaCampoErro('cdcnae','frmValorMaximoCnae');");
						//estadoInicial();
						$('#vlcnae').val('');
				}
			});
		} 


		if( cddopcao == 'A'){

			// Executa script de confirmação através de ajax
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
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
				},

				success: function(response) {

					try {

						hideMsgAguardo();				
						eval(response);

						//$('#vlcnae').val(response);
						//$('#vlcnae','#frmValorMaximoCnae').setMask('DECIMAL','zzz.zzz.zz9,99',',','');

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

		// Executa script de confirmação através de ajax
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
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
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

		var cddopcao  = $('#cddopcao');

		// verifica se existe display block no formulario de valor CNAE
		if($('#frmValorMaximoCnae').css('display') == "block") {
			
			$('#cdcnae').attr( "aux", " " );
			estadoInicial();
			//buscaDescricaoCnae();
			return false;
		} 	

	    estadoInicial();
		highlightObjFocus( $('#frmCab') );
		$("#frmCab").css({"display":"block"});
		$("#divTela").css({"width":"700px","padding-bottom":"2px"});
		trocaBotaon('Prosseguir');

		controlaFocoFormulariosCnae();

		$( "#cddopcao" ).focus();


	}



	//função para troca do nome do botão
	function trocaBotao( botao ) {

		$('#divBotoes','#divTela').html('');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

		if ( botao != '') {
			$('#divBotoes','#divTela', '#').append('&nbsp;<a href="#" class="botao"  id="btSalvar" onClick="controlaOperacaoExcluir(); return false;" >'+botao+'</a>');
		}

		return false;
	}



	function trocaBotaon( botao ) {

		$('#divBotoes','#divTela').html('');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

		if ( botao != '') {
			$('#divBotoes','#divTela', '#').append('&nbsp;<a href="#" class="botao"  id="btSalvar" onClick="controlaOperacao(); return false;" >'+botao+'</a>');
		}

		return false;
	}











	function controlaPesquisas() {

		// Variável local para guardar o elemento anterior
		var campoAnterior = '';
		var bo, procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	

		bo = 'b1wgen0059.p';
		procedure	= 'BUSCA_CNAE';
		titulo      = 'CNAE';
		qtReg		= '30';
		filtros     = 'Cód. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
		colunas     = 'Código;cdcnae;20%;right|Desc CANE;dscnae;80%;left';			
		
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
		return false;
	}



	function buscaDescricaoCnae(cdcnae) {

	
		if(cdcnae){

		var bo 				= 'b1wgen0059.p';
		var procedure		= 'BUSCA_CNAE';
		var titulo      	= 'CNAE';
		var filtros     	= 'Cód. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
	  	var filtrosDesc = 'flserasa|2';
	    var nomeFormulario 	= 'frmValorMaximoCnae';
		buscaDescricao('ZOOM0001', procedure, titulo, 'cdcnae', 'dscnae', cdcnae.val(),'dscnae',filtrosDesc,'frmValorMaximoCnae');
		$('#vlcnae').val("");
	    return false;
		

		}

	}