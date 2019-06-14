/***************************************************************************
 Fonte: pesqti.js                                                    
 Autor: Adriano                                                      
 Data : Agosto/2011                Última Alteração: 19/09/2016
                                                                     
 Objetivo  : Biblioteca de funções da tela PESQTI                    
                                                                      
 Alterações: 06/08/2012 - Listar Históricos, campo Vl.FOZ e          
                          implementação da Opção A (Lucas).          
                                                                      
	 		  17/12/2012 - Ajuste para layout padrao (Daniel).        	
                                                                      
	 		  27/03/2013 - Alterações para tratar Convenios 	      	
 						   SICREDI (Lucas).     				      	
                                                                      
             12/06/2014 - Alteração para exibir detalhes de DARFs    
                          arrecadadas na Rot. 41 (SD. 75897 Lunelli) 
         															 
             16/12/2014 - #203812 Para as faturas (Cecred e Sicredi) 
                          no lugar da descrição do Banco Destino e o 
                          nome do banco, apresentar: Convênio e Nome 
                          do convênio (Carlos)                       
                                                                  	 	 
             16/06/2015 - Comentada linha que estava ocasionando  	 	 
                          problemas na paginacao da consulta da  	 	 
                          tela (Tiago/Adriano)                   	 	 
                                                                  	 	 
             17/06/2015 - Ajuste decorrente a melhoria no layout da tela
 						 (Adriano).                              	 

             12/05/2016 - Adicionado o campo de linha digitavel 
                          (Douglas - Chamado 426870)
						  
			 19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
						  pelo InternetBanking (Projeto 338 - Lucas Lunelli)
							  
        12/01/2018 - Alteracoes refrente ao PJ406.
							  
             14/05/2018 - Alterado para não permitir alterar faturas com datas
                          inferiores à data atual. (Melhoria PRJ406 - Reinert)
						  
             08/01/2019 - Alterações P510, campo Tipo Pgto (Christian Grauppe - Envolti).
****************************************************************************/

var frmPesqti    = 'frmPesqti';
var divTela    	 = $('#divTela');
var frmTitulos   = 'frmTitulos';
var frmFaturas   = 'frmFaturas';
var frmDarf41 	 = 'form_detalhe_darf_41';

var dtapurac, nrcpfcgc, cdtribut, nrrefere, dtlimite, vllanmto,
	vlrmulta, vlrjuros, vlrtotal, vlrecbru, vlpercen, dtmvtolt;


$(document).ready(function() {

  // Mostra mensagem de aguardo	
  //showMsgAguardo("Aguarde, carregando configura&ccedil;&otilde;es da tela ...");
    
	estadoInicial();
			
  // Evento onKeyUp no campo "nrdconta"
  $("#nrdconta", "#divFiltroFaturaSicredi").bind("keyup", function (e) {
      // Seta máscara ao campo
      if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
          return false;
      }
  });
  
  // Evento onKeyDown no campo "nrdconta"
    $("#nrdconta", "#divFiltroFaturaSicredi").bind("keydown", function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            flgcadas = 'C';
            obtemCabecalho();
            return false;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });
		
    // Evento onBlur no campo "nrdconta"
    $("#nrdconta", "#divFiltroFaturaSicredi").bind("blur", function () {
        if ($(this).val() == "") {
            return true;
        }

        // Valida número da conta
        if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
            showError("error", "Conta/dv inv&aacute;lida.", "Alerta - Ayllos", "$('#nrdconta','#divFiltroFaturaSicredi').focus()");
            limparDadosCampos();
            return false;
        }

        return true;
    });
});

function estadoInicial(){

	$('#divFiltro').css('display','none');	
	$('#frmFiltroPesqti').css('display','none');
	$('#divConsulta').css('display','none');	
	$('#divBotoes').css('display','none');	
	
	//Limpa o formulario filtro de pesquisa
	$('#frmFiltroPesqti').limpaFormulario();
	
	formataCabecalho();
	
	layoutPadrao();
	
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabPesqti').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabPesqti').css('width','570px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabPesqti').css('display','block');
		
	highlightObjFocus( $('#frmCabPesqti') );
	
	$('#cddopcao','#frmCabPesqti').habilitaCampo().focus().val('C');

	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabPesqti').unbind('keypress').bind('keypress', function(e){
	
		$('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#cddopcao','#frmCabPesqti').desabilitaCampo();
			formataFiltro();
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabPesqti').unbind('click').bind('click', function(){
			
		if ($('#cddopcao','#frmCabPesqti').hasClass('campoTelaSemBorda')){
			return false;
		}
		
		$('input,select').removeClass('campoErro');
		$('#cddopcao','#frmCabPesqti').desabilitaCampo();
				
		formataFiltro();
								
	});
	
	//Ao pressionar botao OK
	$('#btOK','#frmCabPesqti').unbind('keypress').bind('keypress', function(e){
	
		$('input,select').removeClass('campoErro');
		
		if ($('#cddopcao','#frmCabPesqti').hasClass('campoTelaSemBorda')){
			return false;
		}
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#cddopcao','#frmCabPesqti').desabilitaCampo();
			
			formataFiltro();
			
			return false;
			
		}
					
	});	
	
	return false;
	
}

function alteraExibicaoCampos(){

	$('#fsetFiltro').css('display','none');
	$('#divFiltroFatura').css('display','none');
	$('#divFiltroFaturaSicredi').css('display','none');
	$('#divFiltroTitulos').css('display','none');
		
	//Faturas
	if ($('#tpdpagto','#divTipoPagto').val() == "no") { 	
	
			//Formata os labels
      
		//PJ406
		$('label[for="dtipagto"]','#divFiltroFaturaSicredi').addClass('rotulo').css('width','55px');
		$('label[for="dtfpagto"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css('width','10px');
      
		$('label[for="cdempcon"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css({'width':'62px','display':'block'});
		$('label[for="cdsegmto"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css({'width':'128px','display':'block'});
		$('label[for="cdagenci"]','#divFiltroFaturaSicredi').addClass('rotulo').css('width','55px');
		$('label[for="nrdconta"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css('width','55px');
			$('label[for="vldpagto"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css('width','40px');
		$('label[for="nrautdoc"]','#divFiltroFaturaSicredi').addClass('rotulo-linha').css({'width':'85px','display':'block'});
      
		//PJ406
		$('#dtipagto','#divFiltroFaturaSicredi').addClass('data').css({'width':'75px'});
		$('#dtfpagto','#divFiltroFaturaSicredi').addClass('data').css({'width':'75px'});
      
		$('#cdempcon','#divFiltroFaturaSicredi').css({'width':'60px','text-align':'right'}).attr('maxlength','6');
		$('#cdsegmto','#divFiltroFaturaSicredi').css({'width':'60px','text-align':'right'}).attr('maxlength','6');
			$('#cdagenci','#divFiltroFaturaSicredi').addClass('pesquisa codigo').css({'width':'35px','text-align':'right'});
		$('#nrdconta','#divFiltroFaturaSicredi').addClass('conta pesquisa').css({'width':'75px','text-align':'right'});
			$('#vldpagto','#divFiltroFaturaSicredi').css({'width':'120px','text-align':'right'}).attr('maxlength','16');
			$('#vldpagto','#divFiltroFaturaSicredi').setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
		$('#nrautdoc','#divFiltroFaturaSicredi').css({'width':'120px','text-align':'right'}).attr('maxlength','6');
				
		//PJ406
		$('#dtipagto','#divFiltroFaturaSicredi').val(dtmvtolt);
		$('#dtfpagto','#divFiltroFaturaSicredi').val(dtmvtolt);
			
			$('#fsetFiltro').css('display','block');
			$('#divFiltroFaturaSicredi').css('display','block');
			
			// Se pressionar cdagenci
			$('#cdagenci','#divFiltroFaturaSicredi').unbind('keypress').bind('keypress', function(e) { 	
			
				if ( divError.css('display') == 'block' ) { return false; }		
								
				// Se é a tecla ENTER, F1 ou TAB 
				if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
					
					if($(this).val() == ''){
						$(this).val('0');				
					}
					
					$('#cdempcon','#divFiltroFaturaSicredi').focus();
									
					return false;		
				}
				
			});	
			
			// Se pressionar cdempcon
			$('#cdempcon','#divFiltroFaturaSicredi').unbind('keypress').bind('keypress', function(e) { 
			
				if ( divError.css('display') == 'block' ) { return false; }		
					
				// Se é a tecla ENTER, F1 ou TAB 
				if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
					$('#cdsegmto','#divFiltroFaturaSicredi').focus();		
					return false;
				}
				
			});	
			
			// Se pressionar cdsegmto
			$('#cdsegmto','#divFiltroFaturaSicredi').unbind('keypress').bind('keypress', function(e) { 	
			
				if ( divError.css('display') == 'block' ) { return false; }		
					
				// Se é a tecla ENTER, F1 ou TAB 
				if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
					$('#vldpagto','#divFiltroFaturaSicredi').focus();		
					return false;
				}
				
			});	

			// Se pressionar vldpagto
			$('#vldpagto','#divFiltroFaturaSicredi').unbind('keypress').bind('keypress', function(e) { 			
			
				if ( divError.css('display') == 'block' ) { return false; }		
					
				// Se é a tecla ENTER, F1 ou TAB 
				if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
					
					if($('#cddopcao','#frmCabPesqti').val() == 'C'){
						showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#tpdpagto","#fsetTipoPagto").focus()','sim.gif','nao.gif');
					}else{
					showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#dtipagto","#divFiltroFaturaSicredi").focus()','sim.gif','nao.gif');
					}
					
					return false;
				}
				
			});	
			
			controlaPesquisas('divFiltroFaturaSicredi');
			
		
	}else{//Titulos
	
		//Formata os labels
		$('label[for="dtdpagto"]','#divFiltroTitulos').addClass('rotulo').css('width','75px');
	    $('label[for="cdagenci"]','#divFiltroTitulos').addClass('rotulo-linha').css('width','25px');
		$('label[for="vldpagto"]','#divFiltroTitulos').addClass('rotulo-linha').css('width','35px');
	
		//Formata os campos
		$('#cdagenci','#divFiltroTitulos').addClass('pesquisa codigo').css({'width':'35px','text-align':'right'});
		$('#cdagenci','#divFiltroTitulos').attr('maxlength','3');
		$('#dtdpagto','#divFiltroTitulos').addClass('data').css({'width':'75px'});
		$('#vldpagto','#divFiltroTitulos').css({'width':'100px','text-align':'right'}).attr('maxlength','16');
		$('#vldpagto','#divFiltroTitulos').setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	
		$('#dtdpagto','#divFiltroTitulos').val(dtmvtolt);		
		$('#fsetFiltro').css('display','block');
		$('#divFiltroTitulos').css('display','block');
		
		// Se pressionar dtdpagto
		$('#dtdpagto','#divFiltroTitulos').unbind('keypress').bind('keypress', function(e) { 		
		
			if ( divError.css('display') == 'block' ) { return false; }		
				
			// Se é a tecla ENTER, F1 ou TAB 
			if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
				
				$('#cdagenci','#divFiltroTitulos').focus();		
				return false;
			}
		});	
		
		// Se pressionar cdagenci
		$('#cdagenci','#divFiltroTitulos').unbind('keypress').bind('keypress', function(e) { 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
							
			// Se é a tecla ENTER, F1 ou TAB 
			if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
				
				if($(this).val() == ''){
					$(this).val('0');				
				}
				
				$('#vldpagto','#divFiltroTitulos').focus();
								
				return false;		
			}
			
		});	
		
		// Se pressionar vldpagto
		$('#vldpagto','#divFiltroTitulos').unbind('keypress').bind('keypress', function(e) { 			
		
			if ( divError.css('display') == 'block' ) { return false; }		
				
			// Se é a tecla ENTER, F1 ou TAB 
			if ( e.keyCode == 13 || e.keyCode == 112 || e.keyCode == 9 ) {
				
				if($('#cddopcao','#frmCabPesqti').val() == 'C'){
					showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#tpdpagto","#frmFiltroPesqti").focus()','sim.gif','nao.gif');
				}else{
					showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#dtdpagto","#divFiltroTitulos").focus()','sim.gif','nao.gif');
				}
				
				return false;
			}
			
		});	
		
		controlaPesquisas('divFiltroTitulos');
		
	}
	
	return false;	
	
}

function formataFiltro() {
	
	//Inicializa variáveis de label dos objetos
	var rTpdpagto = $('label[for="tpdpagto"]','#divTipoPagto');	
		
	rTpdpagto.addClass('rotulo').css('width','75px');
		
	//Inicializa variáveis com o objeto campos
	var cTpdpagto   = $('#tpdpagto','#divTipoPagto');	
		
	cTpdpagto.css({'width':'100px','text-align':'left'});
		
	//Limpa o formulario filtro de pesquisa
	$('#frmFiltroPesqti').limpaFormulario();
	
	$('input,select','#frmFiltroPesqti').habilitaCampo();
	
	highlightObjFocus( $('#frmFiltroPesqti') );
	
	cTpdpagto.val('no');
	alteraExibicaoCampos();

	if ($('#cddopcao', '#frmCabPesqti').val() == "A") {
	    $('#dtdpagto', '#divFiltroFatura').desabilitaCampo();
	    $('#dtipagto', '#divFiltroFaturaSicredi').desabilitaCampo();
	    $('#dtfpagto', '#divFiltroFaturaSicredi').desabilitaCampo();
	    $('#dtdpagto', '#divFiltroTitulos').desabilitaCampo();
	} else {
	    $('#dtdpagto', '#divFiltroFatura').habilitaCampo();
	    $('#dtipagto', '#divFiltroFaturaSicredi').habilitaCampo();
	    $('#dtfpagto', '#divFiltroFaturaSicredi').habilitaCampo();		
	    $('#dtdpagto', '#divFiltroTitulos').habilitaCampo();
	}
	
	cTpdpagto.unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			
			$(this).triggerHandler('blur');
			alteraExibicaoCampos();
			
				$('#dtdpagto','#divFiltroTitulos').focus();
			
			return false;			
		}  		
		
	});	
	
	cTpdpagto.unbind('change').bind('change', function() {
		
		alteraExibicaoCampos();
		
			$('#dtdpagto','#divFiltroTitulos').focus();
		
		return false;		
		
	});	
		
		

	
	// Se pressionar btConsulta
	$('#btConsultar','#divBotoes').unbind('keypress').bind('keypress', function(e) { 		
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.keyCode == 112) {
			
			if($('#cddopcao','#frmCabPesqti').val() == 'C'){
				showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#tpdpagto","#divTipoPagto").focus()','sim.gif','nao.gif');
			}else{
				showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#dtdpagto","#frmFiltroPesqti").focus()','sim.gif','nao.gif');
			}
				
			return false;
		}
	});	
	
	// Se clicar no btConsulta
	$('#btConsultar','#divBotoes').unbind('click').bind('click', function() { 		
		
		if($('#cddopcao','#frmCabPesqti').val() == 'C'){
			showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)',' $("#tpdpagto","#frmFiltroPesqti").focus()','sim.gif','nao.gif');
		}else{
			showConfirmacao('Deseja efetuar a consulta?','Confirma&ccedil;&atilde;o - Ayllos','obtemConsulta(1,50)','$("#dtdpagto","#frmFiltroPesqti").focus()','sim.gif','nao.gif');
		}
				
		return false;

	});		
	
	// Se pressionar btAlterar
	$('#btAlterar','#divBotoes').unbind('keypress').bind('keypress', function(e) { 		
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 112) {
			
			showConfirmacao('Deseja gravar os dados alterados?','Confirma&ccedil;&atilde;o - Ayllos','gravaDados("frmFaturas")','obtemConsulta(1,50)','sim.gif','nao.gif');
			
			return false;
		}
	});	
	
	// Se clicar no btAlterar
	$('#btAlterar','#divBotoes').unbind('click').bind('click', function() { 		
		
		showConfirmacao('Deseja gravar os dados alterados?','Confirma&ccedil;&atilde;o - Ayllos','gravaDados("frmFaturas")','obtemConsulta(1,50)','sim.gif','nao.gif');
					
		return false;

	});		
		
	// Se pressionar btConsulta
	$('#btVoltar','#divBotoes').unbind('keypress').bind('keypress', function(e) { 		
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 112) {
				
			estadoInicial();
				
			return false;
			
		}
		
	});	
	
	// Se clicar no btConsulta
	$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
		
		estadoInicial();
				
		return false;

	});	
	
	$('#frmFiltroPesqti').css('display','block');
	$('#divTipoPagto').css('display','block');
	$('#divBotoes').css('display','block');
	$('#divFiltro').css('display','block');	
	$('#btVoltar','#divBotoes').css('display','inline');
	$('#btConsultar','#divBotoes').css('display','inline');
	$('#btAlterar','#divBotoes').css('display','none');
	
	if($('#cddopcao','#frmCabPesqti').val() == 'A' ){
	
		cTpdpagto.desabilitaCampo();
	
	}else{
	
		cTpdpagto.focus();
	}
	
	return false;
	
}

// Função para realizar consulta
function obtemConsulta( nriniseq , nrregist ) { 	

	var cddopcao = $("#cddopcao","#frmCabPesqti").val();
	var tpdpagto = $("#tpdpagto","#divTipoPagto").val();
	var nomeDoForm = '';
	
	if($('#divFiltroFatura').css('display') == 'block' ){
		nomeDoForm = 'divFiltroFatura';
	}else if ($('#divFiltroFaturaSicredi').css('display') == 'block'){
		nomeDoForm = 'divFiltroFaturaSicredi';
	}else if ($('#divFiltroTitulos').css('display') == 'block'){
		nomeDoForm = 'divFiltroTitulos';
	}
	
	var dtdpagto = $("#dtdpagto","#"+nomeDoForm+"").val();
	var vldpagto = $("#vldpagto","#"+nomeDoForm+"").val();
	var cdagenci = $("#cdagenci","#"+nomeDoForm+"").val();	
	var cdhiscxa = $("#cdhiscxa","#"+nomeDoForm+"").val();	
	var cdempcon = $("#cdempcon","#"+nomeDoForm+"").val();	
	var cdsegmto = $("#cdsegmto","#"+nomeDoForm+"").val();	
	
  //PJ406
  var dtipagto = $("#dtipagto","#"+nomeDoForm+"").val();
  var dtfpagto = $("#dtfpagto","#"+nomeDoForm+"").val();
  var nrdconta = normalizaNumero($("#nrdconta","#"+nomeDoForm+"").val());
  var nrautdoc = $("#nrautdoc","#"+nomeDoForm+"").val();
	
	//Remove a classe de Erro do form
	$('input,select', '#frmFiltroPesqti').removeClass('campoErro').desabilitaCampo();

	if (cddopcao == 'C' || cddopcao == 'A') {
	
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, carregando informacoes ...");
		
		// Carrega dados da conta através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "telas/pesqti/consulta_pesqti.php", 
			data: {
				cddopcao: cddopcao,
				cdhiscxa: cdhiscxa,
				tpdpagto: tpdpagto,
				cdagenci: cdagenci,
				dtdpagto: dtdpagto,
				vldpagto: vldpagto,
				cdempcon: cdempcon,
				cdsegmto: cdsegmto,
				nriniseq: nriniseq,
				nrregist: nrregist,
				//PJ406
        dtipagto: dtipagto,
        dtfpagto: dtfpagto,
        nrdconta: nrdconta,
        nrautdoc: nrautdoc,
				redirect: "script_ajax" // Tipo de retorno do ajax
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.01)","Alerta - Ayllos","$('#cddopcao','#frmCabPesqti').focus()");
			},
			success: function(response) {
				
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
				
						$('#divConsulta').html(response);
						return false;
					} catch(error) {						
				
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)','Alerta - Ayllos','$("#cddopcao","#frmCabPesqti").focus();');
					}
				} else {
					try {
				
						eval( response );						
					} catch(error) {
				
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.03)','Alerta - Ayllos','$("#cddopcao","#frmCabPesqti").focus();');
					}
				}
				
			}				
		});		
	}	
}

function escondeDivRotina() {
	fechaRotina($('#divRotina'));
	$('#divRotina').html('');
	hideMsgAguardo();
}

// Função para gravar alterações
function gravaDados(nmForm) { 	

	var cddopcao = $("#cddopcao","#frmCabPesqti").val();
	var nrdocmto = $("#nrdocmto","#"+nmForm).val();
	var nrdolote = $("#nrdolote","#"+nmForm).val();
	var cdagenci = $("#cdagenci","#"+nmForm).val();
	var dtdpagto = $("#dtdpagto","#"+nmForm).val();
	var cdbccxlt = $("#cdbccxlt","#"+nmForm).val();
	
	var insitfat = $("#insitfat","#"+nmForm).val();
	var dscodbar = $("#dscodbar","#"+nmForm).val();
	
	$('input,select','#'+nmForm).desabilitaCampo();
	
	nrdocmto = normalizaNumero(nrdocmto);
	
	if (cddopcao == 'A') {
	
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, gravando informacoes ...");
		
		// Carrega dados da conta através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "telas/pesqti/grava_pesqti.php", 
			data: {
				cdagenci: cdagenci,
				nrdocmto: nrdocmto,
				nrdolote: nrdolote,
				cdbccxlt: cdbccxlt,
				dtdpagto: dtdpagto,
				insitfat: insitfat,
				dscodbar: dscodbar,
				cddopcao: cddopcao,
				redirect: "script_ajax" // Tipo de retorno do ajax
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.04)","Alerta - Ayllos","$('#cddopcao','#frmCabPesqti').focus()");
			},
			success: function(response) {
				try {
					hideMsgAguardo();
					eval(response);
										
				} catch(error) {
					hideMsgAguardo();					
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.05)" + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabPesqti').focus()");									
				}
			}				
		});		
	}
}

function controlaLayout(operacao) {

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});

	$('#frmPesqti > fieldset:eq(0)').css({'border-left':'0','border-right':'0','margin':'3px 0px','padding':'3px 3px 5px 3px'});
	
	var cddopcao = $("#cddopcao",'#frmCabPesqti').val();
	var nmForm;
	
	switch(operacao) {		
	
		case '1':	
			
			var divRegistro = $('div.divRegistros');
			var tabela      = $('table',divRegistro );	
			var linha		= $('table > tbody > tr', divRegistro );
			var tpdpagto    = $("#tpdpagto","#frmFiltroPesqti").val();
			
			cTodos = $('input,select','#frmFiltroPesqti');
			cTodos.desabilitaCampo();
						
			divRegistro.css({'height':'150px'});
											
			var ordemInicial = new Array();
				ordemInicial = [[1,0]];		
			
			var arrayLargura = new Array(); 
				arrayLargura[0] = '34px';
				arrayLargura[1] = '98px';
				arrayLargura[2] = '343px'
							
			var arrayAlinha = new Array();
				arrayAlinha[0] = 'right';
				arrayAlinha[1] = 'right';
				
				if (tpdpagto == 'yes'){
					arrayAlinha[2] = 'left';
				}else{
					arrayAlinha[2] = 'center';
				}
				
				arrayAlinha[3] = 'right';
				
			var metodoTabela = '';
				
			tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
			
			//Deixa o primeiro registro já selecionado
			if (tpdpagto == 'yes'){
			
				$('table > tbody > tr', divRegistro).each( function(i) {
			
					if ( $(this).hasClass( 'corSelecao' ) ) {
			
						selecionaTitulos($(this));
						
					}	
					
				});	
				
				//seleciona o titulo que tiver foco
				$('table > tbody > tr', divRegistro).focus( function() {
					selecionaTitulos($(this));
				});				
			
				//seleciona o titulo que é clicado
				$('table > tbody > tr', divRegistro).click( function() {
					selecionaTitulos($(this));
				});						
				
			}else{
			
				$('table > tbody > tr', divRegistro).each( function(i) {
			
					if ( $(this).hasClass( 'corSelecao' ) ) {
					
						selecionaFaturas($(this));
					}	
					
				});	
				
				//seleciona a fatura que tiver foco
				$('table > tbody > tr', divRegistro).focus( function() {
					selecionaFaturas($(this));
				});	
				
				//seleciona a fatura que é clicada
				$('table > tbody > tr', divRegistro).click( function() {
					selecionaFaturas($(this));
				});	
				
				$('table > tbody > tr', divRegistro).unbind('dblclick').bind('dblclick', function(e) { 		
										
					if ( cddopcao == "C" 								  && 
					     $('#tpdpagto','#frmFiltroPesqti').val() == "no"  &&
						 $('#dscodbar', $(this)).val()			 == ""    ) {
						
						acessaRotina();
						
					}
				
					return false;
					
				});	
				
			}					
			
			$('#divConsulta').css('display','block');
			$('#divRegistros').css('display','block');
			$('#divRegistrosRodape','#divConsulta').formataRodapePesquisa();	
			
			//Permite a edição de campos se cddopcao = A
			if (cddopcao == 'A'){
			
				$("#insitfat","#frmFaturas").habilitaCampo();
				$("#dscodbar","#frmFaturas").habilitaCampo();
				
			} else {
			
				$("input","#frmFaturas").desabilitaCampo();
				$("select","#frmFaturas").desabilitaCampo();
				
			}
			
			// Se clicar no btVoltar
			$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
				
				controlaLayout('2');
						
				return false;

			});	
			
			layoutPadrao();
			
		break;			
		//Voltar
		case '2': 		
		
			$('#divConsulta').html('');
			$('#divConsulta').css({'display':'none'});
			
			$('#btAlterar').css({'display':'none'});
			$('#btVoltar').css({'display':'none'});
						
			formataFiltro();
			
			// Se clicar no btVoltar
			$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
				
				estadoInicial();
						
				return false;

			});	
			
		break;					
	}
	
	layoutPadrao();
	return false;	
	
}

function formataFormularios() {
	
	var cddopcao = $("#cddopcao","#frmCabPesqti").val();
	
	//Limpa formularios
	$('#'+frmTitulos).limpaFormulario();
	$('#'+frmFaturas).limpaFormulario();
	$('#'+frmDarf41).limpaFormulario();	 	 
	

	$('br', '#'+frmFaturas).css({'clear':'both'});
	$('br', '#'+frmTitulos).css({'clear':'both'});
	
	//form titulos - label
	rDspactaa  	= $('label[for="dspactaa"]', '#'+frmTitulos);
	rNrautdoc  	= $('label[for="nrautdoc"]', '#'+frmTitulos);
	rNrdocmto  	= $('label[for="nrdocmto"]', '#'+frmTitulos);
	rFlgpgdda  	= $('label[for="flgpgdda"]', '#'+frmTitulos);
	rCdbandst  	= $('label[for="cdbandst"]', '#'+frmTitulos);
	rNrdconta  	= $('label[for="nrdconta"]', '#'+frmTitulos);
	rDscodbar   = $('label[for="dscodbar"]', '#'+frmTitulos);
	rDslindig   = $('label[for="dslindig"]', '#'+frmTitulos);
	rDscptdoc  	= $('label[for="dscptdoc"]', '#'+frmTitulos);
	rTppagmto  	= $('label[for="tppagmto"]', '#'+frmTitulos);

	rDspactaa.addClass('rotulo').css({'width':'145px'});
	rNrautdoc.addClass('rotulo').css({'width':'145px'});
	rNrdocmto.addClass('rotulo-linha').css({'width':'60px'});
	rFlgpgdda.addClass('rotulo-linha').css({'width':'75px'});
	rCdbandst.addClass('rotulo').css({'width':'145px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'60px'});
	rDscodbar.addClass('rotulo').css({'width':'145px'});
	rDslindig.addClass('rotulo').css({'width':'145px'});
	rDscptdoc.addClass('rotulo').css({'width':'145px'});
	rTppagmto.addClass('rotulo').css({'width':'145px'});
		
	//form titulos - campos
	cDspactaa   = $('#dspactaa', '#'+frmTitulos);
	cNrautdoc  	= $('#nrautdoc', '#'+frmTitulos);
	cNrdocmto  	= $('#nrdocmto', '#'+frmTitulos);
	cFlgpgdda  	= $('#flgpgdda', '#'+frmTitulos);
	cCdbandst  	= $('#cdbandst', '#'+frmTitulos);
	cNrdconta  	= $('#nrdconta', '#'+frmTitulos);
	cDscodbar   = $('#dscodbar', '#'+frmTitulos);
	cDslindig   = $('#dslindig', '#'+frmTitulos);
	cDscptdoc  	= $('#dscptdoc', '#'+frmTitulos);
	cTppagmto  	= $('#tppagmto', '#'+frmTitulos);

	cDspactaa.css({'width':'120px'}).desabilitaCampo();
	cNrautdoc.css({'width':'120px'}).desabilitaCampo();
	cNrdocmto.css({'width':'114px'}).desabilitaCampo();
	cCdbandst.css({'width':'320px'}).desabilitaCampo();
	cTppagmto.css({'width':'475px'}).desabilitaCampo();
			
	if($.browser.msie){
		cFlgpgdda.css({'width':'100px'}).desabilitaCampo();
		cNrdconta.css({'width':'82px'}).desabilitaCampo();
		cDscodbar.css({'width':'465px'}).desabilitaCampo();
		cDslindig.css({'width':'465px'}).desabilitaCampo();
		cDscptdoc.css({'width':'465px'}).desabilitaCampo();
	}else{
		cFlgpgdda.css({'width':'94px'}).desabilitaCampo();
		cNrdconta.css({'width':'90px'}).desabilitaCampo();
		cDscodbar.css({'width':'475px'}).desabilitaCampo();
		cDslindig.css({'width':'475px'}).desabilitaCampo();
		cDscptdoc.css({'width':'475px'}).desabilitaCampo();
	}
	//form faturas - label
	rDspactaa  	= $('label[for="dspactaa"]', '#'+frmFaturas);
	rVlconfoz  	= $('label[for="vlconfoz"]', '#'+frmFaturas);
	rNrautdoc  	= $('label[for="nrautdoc"]', '#'+frmFaturas);
	rNrdocmto  	= $('label[for="nrdocmto"]', '#'+frmFaturas);
	rCdbandst  	= $('label[for="cdbandst"]', '#'+frmFaturas);
	rNmempres  	= $('label[for="nmempres"]', '#'+frmFaturas);
	rNrdconta  	= $('label[for="nrdconta"]', '#'+frmFaturas);
	rDscodbar  	= $('label[for="dscodbar"]', '#'+frmFaturas);    
    rNmarrecd   = $('label[for="nmarrecd"]', '#'+frmFaturas);
    rDslindig  	= $('label[for="dslindig"]', '#'+frmFaturas);    
	rDscptdoc  	= $('label[for="dscptdoc"]', '#'+frmFaturas);    
	rInsitfat  	= $('label[for="insitfat"]', '#'+frmFaturas);
	rDsnomfon  	= $('label[for="dsnomfon"]', '#'+frmFaturas);    
	rTppagmto  	= $('label[for="tppagmto"]', '#'+frmFaturas);
	
	rDspactaa.addClass('rotulo').css({'width':'145px'});
	rNrautdoc.addClass('rotulo').css({'width':'95px'});
	rCdbandst.addClass('rotulo').css({'width':'105px'});
	rDscodbar.addClass('rotulo').css({'width':'95px'});
  rNmarrecd.addClass('rotulo').css({'width':'95px'});
    rDslindig.addClass('rotulo').css({'width':'95px'});
	rDscptdoc.addClass('rotulo').css({'width':'95px'});
    rNmempres.addClass('rotulo').css({'width':'95px'});
	rDsnomfon.addClass('rotulo').css({'width':'95px'});
	rTppagmto.addClass('rotulo').css({'width':'95px'});

	if ($.browser.msie){
		rVlconfoz.addClass('rotulo-linha').css({'width':'353px'});
		rInsitfat.addClass('rotulo-linha').css({'width':'60px'});
		rNrdocmto.addClass('rotulo-linha').css({'width':'75px'});
		rNrdconta.addClass('rotulo-linha').css({'width':'65px'});
	}else{
		rVlconfoz.addClass('rotulo-linha').css({'width':'348px'});
		rInsitfat.addClass('rotulo-linha').css({'width':'60px'});
		rNrdocmto.addClass('rotulo-linha').css({'width':'70px'});
		rNrdconta.addClass('rotulo-linha').css({'width':'60px'});
	}
		
	//form faturas - campos
	cVlconfoz  	= $('#vlconfoz', '#'+frmFaturas);
	cInsitfat  	= $('#insitfat', '#'+frmFaturas);
	cDspactaa   = $('#dspactaa', '#'+frmFaturas);
	cNrautdoc  	= $('#nrautdoc', '#'+frmFaturas);
	cNrdocmto  	= $('#nrdocmto', '#'+frmFaturas);
	cCdbandst  	= $('#cdbandst', '#'+frmFaturas);
	cNrdconta  	= $('#nrdconta', '#'+frmFaturas);
	cDscodbar  	= $('#dscodbar', '#'+frmFaturas);
    cNmarrecd  	= $('#nmarrecd', '#'+frmFaturas);
	cDslindig   = $('#dslindig', '#'+frmFaturas);
	cDscptdoc  	= $('#dscptdoc', '#'+frmFaturas);
    cNmempres  	= $('#nmempres', '#'+frmFaturas);
	cDsnomfon  	= $('#dsnomfon', '#'+frmFaturas);
	cTppagmto  	= $('#tppagmto', '#'+frmFaturas);

	cVlconfoz.css({'width':'80px'}).desabilitaCampo();
	cInsitfat.css({'width':'60px'}).desabilitaCampo();
	cDspactaa.css({'width':'150px'}).desabilitaCampo();	
	cNrautdoc.css({'width':'150px'}).desabilitaCampo();
	cNrdocmto.css({'width':'320px'}).desabilitaCampo();
	cCdbandst.css({'width':'320px'}).desabilitaCampo();
	cNrdconta.css({'width':'90px'}).desabilitaCampo();
	cDscodbar.setMask("STRING","44",charPermitido(),"");	
  cNmarrecd.css({'width':'320px'}).desabilitaCampo();
    cNmempres.css({'width':'320px'}).desabilitaCampo();
	cDsnomfon.css({'width':'477px'}).desabilitaCampo();
	cTppagmto.css({'width':'477px'}).desabilitaCampo();
	
	if($.browser.msie){
		cDscodbar.css({'width':'354px'}).desabilitaCampo();
        cDslindig.css({'width':'381px'}).desabilitaCampo();
		cDscptdoc.css({'width':'381px'}).desabilitaCampo();
	}else{
		cDscodbar.css({'width':'350px'}).desabilitaCampo();
        cDslindig.css({'width':'477px'}).desabilitaCampo();
		cDscptdoc.css({'width':'477px'}).desabilitaCampo();
	}
	
	/* Habilita o campo de for Op. ALTERAÇÃO */
	if (cddopcao == "A"){

	    cDscodbar.habilitaCampo();
		cInsitfat.habilitaCampo();
	}	
			
}

function formataFormDarfs() {

	//form_detalhe_darf_41 - label
	rDtapurac = $('label[for="dtapurac"]', '#'+frmDarf41);
	rNrcpfcgc = $('label[for="nrcpfcgc"]', '#'+frmDarf41);
	rCdtribut = $('label[for="cdtribut"]', '#'+frmDarf41);
	rNrrefere = $('label[for="nrrefere"]', '#'+frmDarf41);
	rDtlimite = $('label[for="dtlimite"]', '#'+frmDarf41);
	rVllanmto = $('label[for="vllanmto"]', '#'+frmDarf41);
	rVlrmulta = $('label[for="vlrmulta"]', '#'+frmDarf41);
	rVlrjuros = $('label[for="vlrjuros"]', '#'+frmDarf41);
	rVlrtotal = $('label[for="vlrtotal"]', '#'+frmDarf41);	
	rVlrecbru = $('label[for="vlrecbru"]', '#'+frmDarf41);
	rVlpercen = $('label[for="vlpercen"]', '#'+frmDarf41);
	
	rDtapurac.addClass('rotulo-linha').css({'width':'155px'});
	rNrcpfcgc.addClass('rotulo-linha').css({'width':'165px'});
	rCdtribut.addClass('rotulo-linha').css({'width':'155px'});
	rNrrefere.addClass('rotulo-linha').css({'width':'197px'});
	
	if($.browser.msie){
		rDtlimite.addClass('rotulo').css({'width':'155px'});
	}else{
		rDtlimite.addClass('rotulo').css({'width':'160px'});
	}
	
	rVllanmto.addClass('rotulo-linha').css({'width':'155px'});
	rVlrmulta.addClass('rotulo-linha').css({'width':'125px'});
	rVlrjuros.addClass('rotulo-linha').css({'width':'155px'});
	rVlrtotal.addClass('rotulo-linha').css({'width':'125px'});
	rVlrecbru.addClass('rotulo-linha').css({'width':'155px'});
	rVlpercen.addClass('rotulo-linha').css({'width':'125px'});
	
	//form_detalhe_darf_41 - campo
	cDtapurac = $('#dtapurac', '#'+frmDarf41);
	cNrcpfcgc = $('#nrcpfcgc', '#'+frmDarf41);
	cCdtribut = $('#cdtribut', '#'+frmDarf41); 
	cNrrefere = $('#nrrefere', '#'+frmDarf41);
	cDtlimite = $('#dtlimite', '#'+frmDarf41);	
	cVllanmto = $('#vllanmto', '#'+frmDarf41);
	cVlrmulta = $('#vlrmulta', '#'+frmDarf41);
	cVlrjuros = $('#vlrjuros', '#'+frmDarf41);
	cVlrtotal = $('#vlrtotal', '#'+frmDarf41);
	cVlrecbru = $('#vlrecbru', '#'+frmDarf41);
	cVlpercen = $('#vlpercen', '#'+frmDarf41);
	
	cVllanmto.setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	cVlrmulta.setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	cVlrjuros.setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	cVlrtotal.setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	cDtapurac.css({'width':'75px'}).desabilitaCampo();
	cNrcpfcgc.css({'width':'110px'}).desabilitaCampo();
	cCdtribut.css({'width':'43px'}).desabilitaCampo();	
	cNrrefere.css({'width':'150px'}).desabilitaCampo();
	cDtlimite.css({'width':'75px'}).desabilitaCampo();
	cVllanmto.css({'width':'115px'}).desabilitaCampo();
	cVlrmulta.css({'width':'115px'}).desabilitaCampo();
	cVlrjuros.css({'width':'115px'}).desabilitaCampo();
	cVlrtotal.css({'width':'150px'}).desabilitaCampo();
	cVlrecbru.css({'width':'115px'}).desabilitaCampo();
	cVlpercen.css({'width':'45px'}).desabilitaCampo();
}

function acessaRotina() {
		
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pesqti/acessa_rotina.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.(cod.06)','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);				
			detalhaDarf();
			return false;
		}
	});
	return false;
	
}

function detalhaDarf() {

	showMsgAguardo('Aguarde, buscando ...');
			
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pesqti/darf_41.php', 
		data: {
				dtapurac : dtapurac,
				nrcpfcgc : nrcpfcgc,
				cdtribut : cdtribut,
				nrrefere : nrrefere,
				dtlimite : dtlimite,
				vllanmto : vllanmto,
				vlrmulta : vlrmulta,
				vlrjuros : vlrjuros,
				vlrtotal : vlrtotal,			
				vlrecbru : vlrecbru,			
				vlpercen : vlpercen,			
				redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.(cod.07)','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);						
					exibeRotina( $('#divRotina') );					
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.08)','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.09)','Alerta - Ayllos','unblockBackground()');
				}
			}
			
			formataFormDarfs();
			
			hideMsgAguardo();
			bloqueiaFundo( $('#divRotina') );
			
		}				
	});
	return false;
}

function selecionaTitulos(tr){

    var dspactaa = $('#dspactaa', tr ).val();
	
	$('#nrautdoc','#'+frmTitulos).val( $('#nrautdoc', tr ).val() );
	$('#nrdocmto','#'+frmTitulos).val( $('#nrdocmto', tr ).val() );
	$('#cdbandst','#'+frmTitulos).val( $('#cdbandst', tr ).val() );
	$('#nrdconta','#'+frmTitulos).val( $('#nrdconta', tr ).val() );
	$('#dscodbar','#'+frmTitulos).val( $('#dscodbar', tr ).val() );
    $('#dslindig','#'+frmTitulos).val( $('#dslindig', tr ).val() );
	$('#dscptdoc','#'+frmTitulos).val( $('#dscptdoc', tr ).val() );
	$('#tppagmto','#'+frmTitulos).val( $('#tppagmto', tr ).val() );
	
	if (dspactaa == "") {
		
		$('#dspactaa','#'+frmTitulos).css('display','none');
		$('label[for="dspactaa"]','#'+frmTitulos).css('display','none');
		
	}else{
		
		$('#dspactaa','#'+frmTitulos).val( $('#dspactaa', tr ).val() );
		$('#dspactaa','#'+frmTitulos).css('display','block');
		$('label[for="dspactaa"]','#'+frmTitulos).css('display','block');
		
	}
	
	if ($('#flgpgdda', tr ).val() == 'yes') {
		
		$('#flgpgdda','#'+frmTitulos).val( 'Sim' );
		
	}else{
		
		$('#flgpgdda','#'+frmTitulos).val( 'Não' );
		
	}
	
	$("#frmTitulos").css("display","block");
	$("#frmFaturas").css("display","none");
			
	return false;		
	
}
	
function selecionaFaturas(tr){

	var dspactaa = $('#dspactaa', tr ).val();
	var cdhiscxa = $('#cdhiscxa', tr ).val();
		
	$('#insitfat','#'+frmFaturas).val( $('#insitfat', tr ).val() );
	$('#vlconfoz','#'+frmFaturas).val( $('#vlconfoz', tr ).val() );
	$('#nrautdoc','#'+frmFaturas).val( $('#nrautdoc', tr ).val() );
	$('#nrdocmto','#'+frmFaturas).val( $('#nrdocmto', tr ).val() );
	$('#cdbandst','#'+frmFaturas).val( $('#cdbandst', tr ).val() );
	$('#nrdconta','#'+frmFaturas).val( $('#nrdconta', tr ).val() );
	$('#dscodbar','#'+frmFaturas).val( $('#dscodbar', tr ).val() );
    $('#nmarrecd','#'+frmFaturas).val( $('#nmarrecd', tr ).val() );
    $('#dslindig','#'+frmFaturas).val( $('#dslindig', tr ).val() );
	$('#dscptdoc','#'+frmFaturas).val( $('#dscptdoc', tr ).val() );
	$('#dsnomfon','#'+frmFaturas).val( $('#dsnomfon', tr ).val() );
	$('#tppagmto','#'+frmFaturas).val( $('#tppagmto', tr ).val() );
	
	if (dspactaa == "") {
		
		$('#dspactaa','#'+frmFaturas).css('display','none');
		$('label[for="dspactaa"]','#'+frmFaturas).css('display','none');
		
	}else{
		
		$('#dspactaa','#'+frmFaturas).val( $('#dspactaa', tr ).val() );
		$('#dspactaa','#'+frmFaturas).css('display','block');
		$('label[for="dspactaa"]','#'+frmFaturas).css('display','block');
		
	}
	
	$('#cdagenci','#'+frmFaturas).val( $('#cdagenci', tr ).val() );
	$('#nrdolote','#'+frmFaturas).val( $('#nrdolote', tr ).val() );
	$('#dtdpagto','#'+frmFaturas).val( $('#dtdpagto', tr ).val() );
	$('#cdbccxlt','#'+frmFaturas).val( $('#cdbccxlt', tr ).val() );
	$('#nmempres','#'+frmFaturas).val( $('#nmempres', tr ).val() );
			
	/* Exibe o campo Vl.FOZ de o Historico for 963 */
	if (cdhiscxa == 963){ /* FOZ DO BRASIL */
	
		$('#vlconfoz', '#frmFaturas').css('display','block');
		$('label[for="vlconfoz"]', '#frmFaturas').css('display','block');
		
	} else {
		
		$('#vlconfoz', '#frmFaturas').css('display','none');
		$('label[for="vlconfoz"]', '#frmFaturas').css('display','none');
		
	}
	
	dtapurac = $('#dtapurac', tr ).val();
	nrcpfcgc = $('#nrcpfcgc', tr ).val();
	cdtribut = $('#cdtribut', tr ).val();
	nrrefere = $('#nrrefere', tr ).val();
	dtlimite = $('#dtlimite', tr ).val();
	vllanmto = $('#vllanmto', tr ).val();
	vlrmulta = $('#vlrmulta', tr ).val();
	vlrjuros = $('#vlrjuros', tr ).val();
	vlrtotal = $('#vlrtotal', tr ).val();
	vlrecbru = $('#vlrecbru', tr ).val();
	vlpercen = $('#vlpercen', tr ).val();
	
	$('#frmFaturas').css('display','block');
	$("#frmTitulos").css("display","none");

	return false;		
}

function controlaPesquisas(nomeFormulario){

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
	
	var divRotina = 'divTela';
		
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				if ( campoAnterior == 'cdhiscxa' ) {
					bo			= 'b1wgen0101.p';
					procedure	= 'lista-historicos';
					titulo      = 'Hist&oacute;ricos';
					qtReg		= '50';
					filtros 	= 'C&oacutedigo;cdhiscxa;30px;S;0;S|Descr.;nmempres;200px;S';
					colunas 	= 'Cod.;cdhiscxa;20%;right|Descr.;nmempres;67%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);
					return false;
				}
				
				if ( campoAnterior == 'cdempcon' ) {
					bo			= 'b1wgen0101.p';
					procedure	= 'lista-empresas-conv';
					titulo      = 'Empr.Conven.';
					qtReg		= '20';
					filtros 	= 'Empresa;cdempcon;45px;S;0;S|Segmento;cdsegmto;35px;S|Conv&ecircnio;nmextcon;200px;S';
					colunas 	= 'Codigo;cdempcon;15%;right|Segmento;cdsegmto;18%;left|Conv&ecircnio;nmextcon;70%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);
					return false;
				}
				
				if ( campoAnterior == 'cdagenci' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_pac';
					titulo      = 'Agência PA';
					qtReg		= '20';
					filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
					colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,nomeFormulario);
					return false;
				}
				
			}
		});
	});
	
	return false;
	
}
