/***********************************************************************
 Fonte: cadgrp.js                                                  
 Autor: Jonata - Mouts
 Data : Setembro/2018                Última Alteração: 

 Objetivo  : Rotinas responsaveis pela tela CADGRP

 Alterações:

************************************************************************/


$(document).ready(function () {

    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();

    $('#cddopcao', '#frmCabCadgrp').habilitaCampo().focus().val('C');
    $('#frmFiltro').css('display', 'none');
    $('#divFiltro').css('display', 'none');
    $('#divBotoesFiltro').css('display', 'none');
    $('#frmCadgrp').css('display', 'none');
    $('#divCadgrp').html('').css('display', 'none');

    layoutPadrao();

}

function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCabCadgrp').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCabCadgrp').css('width', '800px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCabCadgrp').css('display', 'block');

    highlightObjFocus($('#frmCabCadgrp'));
    $('#cddopcao', '#frmCabCadgrp').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCabCadgrp').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCabCadgrp').click();
            return false;
        }

    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCabCadgrp').unbind('click').bind('click', function () {

		$('input,select').removeClass('campoErro');
		$('#cddopcao', '#frmCabCadgrp').desabilitaCampo();

		controlaInicio();

    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCabCadgrp').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('#btOK', '#frmCabCadgrp').click();

			controlaInicio();            

        }

    });

    return false;

}

function controlaInicio(){

	var opcao = $('#cddopcao','#frmCabCadgrp').val(); 

	if (opcao == 'P' ){
		consultaParametrosFracoesGrupo();
	}else if (opcao == 'E' ){
		consultaPeriodoEditalAssembleias(1,30);
	}else if (opcao == 'C' || opcao == 'B' ){
		apresentaFormFiltro();
	}else if (opcao == "G"){
		consultaDistribuicaoGrupos();
	}

	return false;

}

function consultaDistribuicaoGrupos() {

	var cddopcao = $('#cddopcao','#frmCabCadgrp').val(); 

	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando ag&ecirc;ncias ...');

	$('input').removeClass('campoErro');

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/consulta_distribuicao_grupos.php',
		data: {
			cddopcao: cddopcao,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divCadgrp').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});

	return false;

}

function apresentaFormFiltro() {   

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();

	$.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadgrp/monta_filtro.php',
        data: {
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divFiltro').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

    return false;

}


function consultaPeriodoEditalAssembleias(nriniseq,nrregist) {

	var cddopcao = $('#cddopcao','#frmCabCadgrp').val(); 

	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando periacute;odos ...');

	$('input').removeClass('campoErro');

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/consulta_periodo_edital_assembleias.php',
		data: {
			cddopcao: cddopcao,			
		    nriniseq: nriniseq,			
			nrregist: nrregist,				
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divCadgrp').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});

	return false;

}


function consultaDetalhadaGrupos(nriniseq,nrregist) {

	var cddopcao = $('#cddopcao','#frmCabCadgrp').val(); 
	var cdagenci = $('#cdagenci','#frmFiltroConsultaDetalhada').val(); 
	var nrdgrupo = $('#nrdgrupo','#frmFiltroConsultaDetalhada').val();
	var qtdRetorno = $('#qtdRetorno','#frmFiltroConsultaDetalhada').val(); 

	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando ...');

	$('input').removeClass('campoErro');

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/consulta_detalhada_grupo.php',
		data: {
			cddopcao: cddopcao,			
			cdagenci: cdagenci,			
			nrdgrupo: nrdgrupo,			
		    nriniseq: nriniseq,			
			nrregist: nrregist,
			qtdRetorno: qtdRetorno,		
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divCadgrp').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','formataFiltroConsultaDetalhada();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','formataFiltroConsultaDetalhada();');
					}
				}
		}				
	});

	return false;

}


function buscaGrupoCooperado() {

	var cddopcao = $('#cddopcao','#frmCabCadgrp').val(); 
	var nrdconta = normalizaNumero($('#nrdconta','#frmFiltroBuscaGrupo').val()); 
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmFiltroBuscaGrupo').val()); 

	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando ...');

	$('input').removeClass('campoErro');

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/busca_grupo_cooperado.php',
		data: {
			cddopcao: cddopcao,			
			nrdconta: nrdconta,			
			nrcpfcgc: nrcpfcgc,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divCadgrp').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','formataFiltroConsultaDetalhada();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','formataFiltroConsultaDetalhada();');
					}
				}
		}				
	});

	return false;

}

function consultaParametrosFracoesGrupo(){

    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es...");

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadgrp/consulta_parametros_fracoes_grupo.php',
        data: {
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divCadgrp').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

	return false;

}


function formataFormOpcaoP(){

	highlightObjFocus( $('#frmOpcaoP') );   

    //Label dos campos
    $('label[for="frmideal"]', "#frmOpcaoP").addClass("rotulo").css({ "width": "180px" });
    $('label[for="frmmaxim"]', "#frmOpcaoP").addClass("rotulo").css({ "width": "180px" });
	$('label[for="intermin"]', "#frmOpcaoP").addClass("rotulo").css({ "width": "180px" });


    //Campos 
    $('#frmideal', '#frmOpcaoP').css({ 'width': '235px'}).desabilitaCampo().addClass('inteiro').attr('maxlength', '10');   
    $('#frmmaxim', '#frmOpcaoP').css({ 'width': '235px'}).desabilitaCampo().addClass('inteiro').attr('maxlength', '10');  
	$('#intermin', '#frmOpcaoP').css({ 'width': '235px'}).desabilitaCampo().addClass('inteiro').attr('maxlength', '10');  

    $('#btConcluir','#divBotoesOpcaoP').css('display', 'none');
    $('#btAlterar','#divBotoesOpcaoP').css('display', 'inline');
    $('#divCadgrp').css('display', 'block');

	// Ao pressionar do campo frmideal
	$('#frmideal', '#frmOpcaoP').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#frmmaxim', '#frmOpcaoP').focus();

			return false;

		}

	});

	// Ao pressionar do campo frmmaxim
	$('#frmmaxim', '#frmOpcaoP').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesOpcaoP').click();

			return false;

		}

	});
	
	// Ao pressionar do campo frmmaxim
	$('#intermin', '#frmOpcaoP').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesOpcaoP').click();

			return false;

		}

	});

	layoutPadrao();   

    return false;

}


function formataFormBuscaGrupo(){

	highlightObjFocus( $('#frmDetalhadaGrupo') );   

    //Label dos campos
    $('label[for="cdagenci"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });
    $('label[for="nrdgrupo"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });
    $('label[for="dsfuncao"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });
    $('label[for="nrdconta"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });
    $('label[for="nrcpfcgc"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });
    $('label[for="nmprimtl"]', "#frmDetalhadaGrupo").addClass("rotulo").css({ "width": "140px" });


    //Campos 
    $('#cdagenci', '#frmDetalhadaGrupo').css({ 'width': '60px'}).desabilitaCampo().addClass('inteiro').attr('maxlength', '2');   
    $('#nrdgrupo', '#frmDetalhadaGrupo').css({ 'width': '60px'}).desabilitaCampo().addClass('inteiro').attr('maxlength', '2');   
    $('#dsfuncao', '#frmDetalhadaGrupo').css({ 'width': '350px'}).desabilitaCampo().attr('maxlength', '100');   
    $('#nrdconta', '#frmDetalhadaGrupo').css({ 'width': '160px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').desabilitaCampo();  
    $('#nrcpfcgc', '#frmDetalhadaGrupo').css('width','160px').addClass('inteiro').attr('maxlength','18').desabilitaCampo();   
    $('#nmprimtl', '#frmDetalhadaGrupo').css({ 'width': '350px'}).desabilitaCampo().attr('maxlength', '100');   

    $('#btConcluir','#divBotoesBuscaGrupo').css('display', 'none');
    $('#btAlterar','#divBotoesBuscaGrupo').css('display', 'inline');
    $('#divCadgrp').css('display', 'block');


	// Ao pressionar do campo nrdgrupo
	$('#nrdgrupo', '#frmDetalhadaGrupo').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesBuscaGrupo').click();

			return false;

		}

	});

	var lupas = $('a', '#frmDetalhadaGrupo' );


    // Atribui a classe lupa para os links
    lupas.addClass('lupa').css('cursor', 'pointer');

    // Percorrendo todos os links
    lupas.each(function() {
        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                // PA
                if (campoAnterior == 'nrdgrupo') {
                    var filtrosPesq = 'Código;nrdgrupo;100px;S;0|Agência;cdagenci;30px;N;' + $('#cdagenci','#frmDetalhadaGrupo').val() + ';S;codigo;';
					var colunas = 'Código;nrdgrupo;20%;center';
					mostraPesquisa("TELA_CADGRP", "BUSCA_GRP_DISP", "Grupo Dispon&iacute;vel", "30", filtrosPesq, colunas, '','$(\'#nrdgrupo\',\'#frmDetalhadaGrupo\').focus();','frmDetalhadaGrupo');

                    return false;

                } 
            }
        });
    });
	
	layoutPadrao();   

    return false;

}

function controlaBotao(){

	$('#nrdgrupo', '#frmDetalhadaGrupo').habilitaCampo().focus();
	$('#btAlterar','#divBotoesBuscaGrupo').css('display', 'none');
   	$('#btConcluir','#divBotoesBuscaGrupo').css('display', 'inline');
	return false;

}

function formataFiltroConsultaDetalhada(){

	highlightObjFocus( $('#frmFiltroConsultaDetalhada') );   

    //Label dos campos
    $('label[for="cdagenci"]', "#frmFiltroConsultaDetalhada").addClass('rotulo').css({'width': '100px'});
    $('label[for="nrdgrupo"]', "#frmFiltroConsultaDetalhada").addClass("rotulo").css({ "width": "100px" });
    $('label[for="qtdRetorno"]', "#frmFiltroConsultaDetalhada").addClass("rotulo").css({ "width": "100px" });

    //Campos 
    $("#cdagenci", "#frmFiltroConsultaDetalhada").addClass('campo pesquisa').css({'width':'50px','text-align':'right'}).attr('maxlength','3').setMask('INTEGER','zzz','',''); 	
	$('#nrdgrupo', '#frmFiltroConsultaDetalhada').css('width','50px').addClass('inteiro').attr('maxlength','2');
	$("#qtdRetorno", "#frmFiltroConsultaDetalhada").css({'width':'50px','text-align':'right'});
	

	$("#cdagenci", "#frmFiltroConsultaDetalhada").val('');
	$('#nrdgrupo', '#frmFiltroConsultaDetalhada').val('');

	$('#divFiltro').css('display', 'block');
    $('#divBotoesFiltroConsultaDetalhda').css('display', 'block');

	// Ao pressionar do campo cdagenci
	$('#cdagenci', '#frmFiltroConsultaDetalhada').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#nrdgrupo', '#frmFiltroConsultaDetalhada').focus();

			return false;

		}

	});

	// Ao pressionar do campo nrdgrupo
	$('#nrdgrupo', '#frmFiltroConsultaDetalhada').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btProsseguir', '#divBotoesFiltroConsultaDetalhda').click();

			return false;

		}

	});

	controlaPesquisas();
	layoutPadrao();   

	$("#cdagenci", "#frmFiltroConsultaDetalhada").habilitaCampo();
	$('#nrdgrupo', '#frmFiltroConsultaDetalhada').habilitaCampo();
	$('#qtdRetorno', '#frmFiltroConsultaDetalhada').habilitaCampo();
	$("#cdagenci", "#frmFiltroConsultaDetalhada").focus();

    return false;

}



function formataFiltroBuscaGrupo(){

	highlightObjFocus( $('#frmFiltroBuscaGrupo') );   

    //Label dos campos
    $('label[for="nrdconta"]', "#frmFiltroBuscaGrupo").addClass("rotulo").css({ "width": "120px" });
    $('label[for="nrcpfcgc"]', "#frmFiltroBuscaGrupo").addClass("rotulo").css({ "width": "120px" });


    //Campos 
    $("#nrdconta", "#frmFiltroBuscaGrupo").css({ 'width': '185px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').habilitaCampo();
	$('#nrcpfcgc', '#frmFiltroBuscaGrupo').css('width','185px').addClass('inteiro').attr('maxlength','18').habilitaCampo();

    $('#divFiltro').css('display', 'block');
    $('#divBotoesFiltroBuscaGrupo').css('display', 'block');

	// Ao pressionar do campo nrdconta
	$('#nrdconta', '#frmFiltroBuscaGrupo').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#nrcpfcgc', '#frmFiltroBuscaGrupo').focus();

			return false;

		}

	});

	// Se pressionar cNrcpfcgc
	$('#nrcpfcgc', '#frmFiltroBuscaGrupo').unbind('blur').bind('blur', function(){ 	

		if ( divError.css('display') == 'block' ) { return false; }		

		$(this).removeClass('campoErro');

		var cpfCnpj = normalizaNumero($('#nrcpfcgc','#frmFiltroBuscaGrupo').val());

		if(cpfCnpj.length <= 11){	
			$(this).val(mascara(cpfCnpj,'###.###.###-##'));
		}else{
			$(this).val(mascara(cpfCnpj,'##.###.###/####-##'));
		}

		return false;	

	});	

	// Ao pressionar do campo nrcpfcgc
	$('#nrcpfcgc', '#frmFiltroBuscaGrupo').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btProsseguir', '#divBotoesFiltroBuscaGrupo').click();

			return false;

		}

	});

	controlaPesquisas();
	layoutPadrao();   
	$("#nrdconta", "#frmFiltroBuscaGrupo").val(''); 
	$('#nrcpfcgc', '#frmFiltroBuscaGrupo').val('');
	$("#nrdconta", "#frmFiltroBuscaGrupo").focus();

    return false;

}


function controlaPesquisas() {

    var nmformul = ($('#cddopcao','#frmCabCadgrp').val() == 'C') ? 'frmFiltroConsultaDetalhada' : 'frmFiltroBuscaGrupo' ;
    var campoAnterior = '';
    var lupas = $('a', '#' + nmformul);


    // Atribui a classe lupa para os links
    lupas.addClass('lupa').css('cursor', 'pointer');

    // Percorrendo todos os links
    lupas.each(function() {
        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                // PA
                if (campoAnterior == 'cdagenci') {
                   
					filtrosPesq	= 'Cód. PA;cdagenci;30px;N;0;N;codigo';
					colunas 	= 'Código;cdagenci;20%;center';
					mostraPesquisa("TELA_CADGRP", "BUSCA_AGE_DISP", "Ag&ecirc;ncia Dispon&iacute;vel", "30", filtrosPesq, colunas, '','$(\'#cdagenci\',\'#' + nmformul +'\').focus();',nmformul);
                    return false;

                }else if (campoAnterior == 'nrdconta') {
                    
                    mostraPesquisaAssociado('nrdconta', nmformul);
					return false;

				}else if(campoAnterior == 'nrdgrupo'){
					
					//var filtrosPesq = "Código;nrdgrupo;100px;S;0|Agência;cdagenci;30px;N;' + $('#cdagenci','#frmDetalhadaGrupo').val() + ';N;codigo;";
					//filtros = 'Codigo;cdsegura;80px;S;' + cdsegura + ';S|Descricao;nmresseg;280px;S;;S';
					filtrosPesq = 'Código;nrdgrupo;100px;S;0|Agência;cdagenci;30px;N;' + $('#cdagenci','#' + nmformul).val() + ';S;codigo;';
					//filtrosPesq = "Código;nrdgrupo;100px;S;0";
					colunas = 'Código;nrdgrupo;20%;center';
					mostraPesquisa("TELA_CADGRP", "BUSCA_GRP_DISP", "Grupo Dispon&iacute;vel", "30", filtrosPesq, colunas, '','$(\'#nrdgrupo\',\'#' + nmformul +'\').focus();',nmformul);

					return false;
													
				}	
            }
        });
    });
}


function formataFormOpcaoE(ope){

	highlightObjFocus( $('#frmOpcaoE') );   

    //Label dos campos
    $('label[for="nrano_exercicio"]', "#frmOpcaoE").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dtinicio_grupo"]', "#frmOpcaoE").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dtfim_grupo"]', "#frmOpcaoE").addClass("rotulo").css({ "width": "100px" });

    //Campos 
    $('#nrano_exercicio', '#frmOpcaoE').css({ 'width': '100px'}).addClass('inteiro').attr('maxlength', '4').habilitaCampo();
    $('#dtinicio_grupo', '#frmOpcaoE').css({ 'width': '100px'}).addClass('data').habilitaCampo();  
    $('#dtfim_grupo', '#frmOpcaoE').css({ 'width': '100px'}).addClass('data').habilitaCampo();   


	// Ao pressionar do campo nrano_exercicio
	$('#nrano_exercicio', '#frmOpcaoE').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dtinicio_grupo', '#frmOpcaoE').focus();

			return false;

		}

	});

	// Ao pressionar do campo dtinicio_grupo
	$('#dtinicio_grupo', '#frmOpcaoE').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dtfim_grupo', '#frmOpcaoE').focus();

			return false;

		}

	});

	// Ao pressionar do campo dtfim_grupo
	$('#dtfim_grupo', '#frmOpcaoE').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesOpcaoE').click();

			return false;

		}

	});

	layoutPadrao();  

    $('#nrano_exercicio', '#frmOpcaoE').css({'text-align': 'left'});
	
	if(ope == 'A'){
		$('#nrano_exercicio', '#frmOpcaoE').desabilitaCampo();
		$('#dtinicio_grupo', '#frmOpcaoE').focus();
	}else{
		$('#nrano_exercicio', '#frmOpcaoE').focus();
	}



    return false;

}


function controlaFormOpcaoP(){

	$('#frmideal', '#frmOpcaoP').habilitaCampo().focus();
	$('#frmmaxim', '#frmOpcaoP').habilitaCampo();
	$('#btConcluir','#divBotoesOpcaoP').css('display', 'inline');
    $('#btAlterar','#divBotoesOpcaoP').css('display', 'none');

	return false;

}

function controlaVoltar(tipo) {

    switch (tipo) {

        case '1':

            estadoInicial();

        break;

        case '2':

            $('#divForms').html('').css('display','none');
            $('#divCadgrp').css('display','block');

        break;

		case '3':

            $('#divForms').html('').css('display','none');

			consultaPeriodoEditalAssembleias(1,30);

        break;

		case '4':

			consultaPeriodoEditalAssembleias(1,30);

		break;

		case '5':

            $('#divCadgrp').html('').css('display','none');
            formataFiltroConsultaDetalhada();

        break;

		case '6':

            $('#divCadgrp').html('').css('display','none');
            formataFiltroBuscaGrupo();

        break;
		
		case '7':

            consultaDistribuicaoGrupos();

        break;

    }

    return false;

}

function isIE() {
	var myNav = navigator.userAgent.toLowerCase();
	return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
}

function alterarParametrosFracoesGrupo() {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();
    var frmideal = $('#frmideal', '#frmOpcaoP').val();
    var frmmaxim = $('#frmmaxim', '#frmOpcaoP').val();

    $('input', '#frmOpcaoP').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando par&acirc;metros...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/alterar_parametros_fracoes_grupo.php",
        data: {
            cddopcao: cddopcao,
            frmideal: frmideal,
			frmmaxim: frmmaxim,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesOpcaoP").focus();');
            }
        }
    });

    return false;
}



function alterarGrupoCooperado() {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();
    var nrdgrupo = $('#nrdgrupo', '#frmDetalhadaGrupo').val();
    var rowid = $('#rowid', '#frmDetalhadaGrupo').val();

    $('input', '#frmDetalhadaGrupo').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando grupo...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/alterar_grupo_cooperado.php",
        data: {
            cddopcao: cddopcao,
            nrdgrupo: nrdgrupo,
			rowid: rowid,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesBuscaGrupo").focus();');
            }
        }
    });

    return false;
}



function excluirPeriodoEditalAssembleias(rowid, nrano_exercicio) {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/excluir_periodo_edital_assembleias.php",
        data: {
            cddopcao: cddopcao,
            rowid: rowid,
            nrano_exercicio: nrano_exercicio,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesPeriodos').focus();");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesPeriodos").focus();');
            }
        }
    });

    return false;
}


function alterarPeriodoEditalAssembleias() {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();
    var rowid = $('#rowid', '#frmOpcaoE').val();
    var dtinicio_grupo = $('#dtinicio_grupo', '#frmOpcaoE').val();
    var dtfim_grupo = $('#dtfim_grupo', '#frmOpcaoE').val();

    $('input', '#frmOpcaoE').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando periodo...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/alterar_periodo_edital_assembleias.php",
        data: {
            cddopcao: cddopcao,
            rowid: rowid,
			dtinicio_grupo: dtinicio_grupo,
			dtfim_grupo: dtfim_grupo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesOpcaoE").focus();');
            }
        }
    });

    return false;
}



function incluirPeriodoEditalAssembleias() {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();
    var nrano_exercicio = $('#nrano_exercicio', '#frmOpcaoE').val();
    var dtinicio_grupo = $('#dtinicio_grupo', '#frmOpcaoE').val();
    var dtfim_grupo = $('#dtfim_grupo', '#frmOpcaoE').val();

    $('input', '#frmOpcaoE').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, incluindo per&iacute;odo...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/incluir_periodo_edital_assembleias.php",
        data: {
            cddopcao: cddopcao,
            nrano_exercicio: nrano_exercicio,
			dtinicio_grupo: dtinicio_grupo,
			dtfim_grupo: dtfim_grupo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesOpcaoE").focus();');
            }
        }
    });

    return false;
}

function formataTabelaDistribuicaoGrupos(){

	var divRegistro = $('div.divRegistros');

	var tabela      = $('table',divRegistro );

	divRegistro.css({ 'height': '150px', 'width' : '100%'});

	var ordemInicial = new Array();

	var arrayLargura = new Array(); 
	    arrayLargura[0] = '20px';
	    arrayLargura[1] = '60px';
	    arrayLargura[2] = '60px';
	    arrayLargura[3] = '130px';
	    arrayLargura[4] = '130px';
	    arrayLargura[5] = '130px';
		arrayLargura[6] = '130px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
		arrayAlinha[7] = 'center';

	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');

	$('#divCadgrp').css('display', 'block');

	//Seleciona o registro que é clicado
	$('table > tbody > tr > td', divRegistro).bind('click', function() {

		var linha    = $(this).closest('tr');
		var cdagenci = $('#cdagenci', linha).val();

		if(linha.hasClass('corSelecao') == false){
			atualizaTabelaAgenciaSelecionada(cdagenci);
		}

	});

	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function () {

		if ($(this).hasClass('corSelecao')) {

			var linha    = $(this);
			var cdagenci = $('#cdagenci', linha).val();

			atualizaTabelaAgenciaSelecionada(cdagenci);

		}

	});

	$('input[type=checkbox]', '#frmDistribuicaoGrupos').unbind('click').bind('click', function(e){
		e.stopPropagation();
	});

	$('#cbMarcarDesmarcarTodos','#frmDistribuicaoGrupos').unbind('change').bind('change', function(){

		marcarDesmarcarTodos(this.checked);

	});

	$('#thMarcarDesmarcarTodos', '#frmDistribuicaoGrupos').removeClass('headerSort').unbind('click');

}

//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabelaPeriodos(){

	$('label[for="tituloAssembleias"]', "#frmPeriodo").css({ "width": "165px" });
    $('label[for="tituloTravamento"]', "#frmPeriodo").css({ "width": "340px"});

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );

	divRegistro.css({ 'height': '150px', 'width' : '100%'});

	var ordemInicial = new Array();

	var arrayLargura = new Array(); 
	    arrayLargura[0] = '210px';
	    arrayLargura[1] = '210px';
	    arrayLargura[2] = '210px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';

	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');

	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divCadgrp').formataRodapePesquisa();		
	$('#divCadgrp').css('display', 'block');
	$('#frmPeriodo').css('display','block');	
	$('#divBotoesPeriodos').css('display','block');	

	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {

		var linha = $(this);

		//Ao clicar no botao btExcluir
		$('#btExcluir','#divBotoesPeriodos').unbind('click').bind('click', function(){

			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirPeriodoEditalAssembleias("' + $('#rowid', linha ).val() + '" , "' + $('#nrano_exercicio', linha ).val() + '");','$(\'#btVoltar\',\'#divBotoesPeriodos\').focus();','sim.gif','nao.gif');

		});

		//Ao clicar no botao btAlterar
		$('#btAlterar','#divBotoesPeriodos').unbind('click').bind('click', function(){

			apresentaFormOpcaoE('A',linha);

		});

		/* Ao clicar no botão "Ativar" */
		$('#btAtivar', "#divBotoesPeriodos").unbind('click').bind('click', function(){
			//ativarAssembleia(linha);
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?',
				'Confirma&ccedil;&atilde;o - Ayllos',
				'ativarAssembleia("' + $('#rowid', linha ).val() +'");',
				'$(\'#btAtivar\',\'#divBotoesPeriodos\').focus();','sim.gif','nao.gif');
			return false;
		});


	});			

	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function (i) {

		if ($(this).hasClass('corSelecao')) {

			var linha = $(this);

			//Ao clicar no botao btExcluir
			$('#btExcluir','#divBotoesPeriodos').unbind('click').bind('click', function(){

				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirPeriodoEditalAssembleias("' + $('#rowid', linha ).val() + '" , "' + $('#nrano_exercicio', linha ).val() + '");','$(\'#btVoltar\',\'#divBotoesPeriodos\').focus();','sim.gif','nao.gif');

			});	

			//Ao clicar no botao btAlterar
			$('#btAlterar','#divBotoesPeriodos').unbind('click').bind('click', function(){

				apresentaFormOpcaoE('A',linha);

			});	

			/* Ao clicar no botão "Ativar" */
			$('#btAtivar', "#divBotoesPeriodos").unbind('click').bind('click', function(){
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?',
					'Confirma&ccedil;&atilde;o - Ayllos',
					'ativarAssembleia("' + $('#rowid', linha ).val() +'");',
					'$(\'#btAtivar\',\'#divBotoesPeriodos\').focus();','sim.gif','nao.gif');
				return false;
			});



		}

	});

	//Ao clicar no botao btIncluir
	$('#btIncluir','#divBotoesPeriodos').unbind('click').bind('click', function(){

		apresentaFormOpcaoE('I');

	});
	return false;

}

function ativarAssembleia(rowid){

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadgrp/ativar_periodo_edital_assembleias.php',
        data: {
            rowid: rowid
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });

}


//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabelaDetalhadaGrupo(){

	/* Qtd de itens p/ busca */
	var qtdRetorno = $("#qtdRetorno", "#frmFiltroConsultaDetalhada").val();
	var hTable = getHeightTabela(parseInt(qtdRetorno));

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});

	$("#fsetDetalhadaGrupo").css({'height':hTable});

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );

	$(divRegistro).css({ 'height': hTable-50, 'width' : '100%'});

	var ordemInicial = new Array();

	var arrayLargura = new Array(); 
	    arrayLargura[0] = '70px';
		arrayLargura[1] = '200px';
	    arrayLargura[2] = '80px';
	    arrayLargura[3] = '140px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'left';
		

	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');

	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divCadgrp').formataRodapePesquisa();		
	$('#divCadgrp').css('display', 'block');
	$('#frmDetalhadaGrupo').css('display','block');	
	$('#divBotoesDetalhadaGrupo').css('display','block');	


	return false;

}

function apresentaFormOpcaoE(ope,linha) {   

    var cddopcao            = $('#cddopcao', '#frmCabCadgrp').val();

    var rowid               = (ope == 'A') ? $('#rowid', linha).val() : '';
    var nrano_exercicio     = (ope == 'A') ? $('#nrano_exercicio', linha).val() : '';
    var dtinicio_grupo      = (ope == 'A') ? $('#dtinicio_grupo', linha).val() : '';
    var dtfim_grupo         = (ope == 'A') ? $('#dtfim_grupo', linha).val() : '';

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde ...");

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadgrp/apresenta_form_prd_edt_assembleias.php',
        data: {
            cddopcao: cddopcao,
            rowid              : rowid    ,
            nrano_exercicio    : nrano_exercicio    ,
            dtinicio_grupo     : dtinicio_grupo     ,
            dtfim_grupo        : dtfim_grupo        ,
            ope                : ope        ,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divForms').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

    return false;

}


function getHeightTabela(qtd){
	switch(qtd){
		case 30:
			return 200;
		case 60:
			return 400;
		case 100:
			return 550;
		default:
			return 200;
	}
}

function atualizaTabelaAgenciaSelecionada(cdagenci){

	showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es da ag&ecirc;ncia...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/consulta_agencia_selecionada.php',
		data: {
			cdagenci: cdagenci,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divTabelaAgenciaSelecionada', '#frmDistribuicaoGrupos').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});

	return false;
}

function formataTabelaAgenciaSelecionada(){

	var divRegistroPA = $('div.divRegistros', '#frmAgenciaSelecionada');

	var tabelaPA      = $('table',divRegistroPA );	

	divRegistroPA.css({ 'height': '80px', 'width' : '100%'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	    arrayLargura[0] = '170px';
	    arrayLargura[1] = '170px';
	    arrayLargura[2] = '170px';
	    arrayLargura[3] = '170px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';

	tabelaPA.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');

	$('#frmAgenciaSelecionada').css('margin-top', '10px');

}

function marcarDesmarcarTodos(isChecked){
	
	if(isChecked){
		$('input:checkbox:enabled').prop('checked', true);
	}else{
		$('input:checkbox:enabled').prop('checked', false);
	}
}

function consultaListaAgencias(){

	showMsgAguardo("Aguarde, buscando as ag&ecirc;ncia...");

	var listaAgencias = '';
	var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();

	$('table > tbody > tr', '#frmDistribuicaoGrupos').each(function(){
		if ($("input[type=checkbox]", this).is(':checked')){
			
			if(listaAgencias != ''){
				listaAgencias += ';';
			}

			listaAgencias += $("#cdagenci", this).val();
		}
	});

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/consulta_lista_agencias.php',
		data: {
		    cddopcao: cddopcao,
			listaAgencias: listaAgencias,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");							
		},
		success: function(response) {			
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divCadgrp').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}				
	});

	return false;
}

function consultaDistribuirTodos(){

	showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'distribuirTodos();', '', 'sim.gif', 'nao.gif');

}

function distribuirTodos(){
	
	showMsgAguardo("Aguarde, fazendo a distribuicao...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/cadgrp/botao_dst_cooperativa.php',
		data: {
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");							
		},
		success: function(response) {			
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					//$('#divCadgrp').html(response);
					eval( response );	
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}				
	});

	return false;
}

function formataTabelaListaAgencias(){

	var divRegistro = $('div.divRegistros', '#frmListaAgencias');

	var tabela      = $('table',divRegistro );	

	divRegistro.css({ 'height': '150px', 'width' : '100%'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	    arrayLargura[0] = '135px';
	    arrayLargura[1] = '135px';
	    arrayLargura[2] = '135px';
	    arrayLargura[3] = '135px';
	    arrayLargura[4] = '135px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';

	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');

	$('input[type=text]', '#frmListaAgencias').addClass('inteiro').habilitaCampo();
    $('#qtdgrupo', '#frmListaAgencias').addClass('inteiro').attr('maxlength', '2');

	// Ao pressionar do campo nrdgrupo
	$('input[type=text]', '#frmListaAgencias').each(function(){
		
		$(this).unbind('keydown').bind('keydown', function(e){

			if ( divError.css('display') == 'block' ) { return false; }		

			$('input,select').removeClass('campoErro');

			// Se é a tecla ENTER, TAB, F1
			if (e.keyCode == 13) {

				$('#btConfirmar', '#divBotoesListaAgencias').click();

				return false;

			}
		});

		var linha = $(this).closest('tr');
		var tdQtMembros = $('.tdQtMembros span', linha).text();
		var tdQtGrupos = $(this).val();

		if(tdQtMembros != '' && tdQtGrupos != ''){
			var tdMembrosGrupo = Math.ceil(tdQtMembros / tdQtGrupos);
		} else {
			var tdMembrosGrupo = 0;
		}

		$('.tdQtTotal', linha).text(tdMembrosGrupo);
	});

	layoutPadrao();

	$('input[type=text]', '#frmListaAgencias').css({'float':'none', 'width':'80px', 'text-align':'center'});

	// Capturar alteracao de valor nos inputs text dentro da tabela para atualizar o Qt. Total
	$('input[type=text]', '#frmListaAgencias').unbind('keyup').bind('keyup', function(){

		var linha = $(this).closest('tr');
		var tdQtMembros = $('.tdQtMembros span', linha).text();
		var tdQtGrupos = $(this).val();

		if(tdQtMembros != '' && tdQtGrupos != ''){
			var tdMembrosGrupo = Math.ceil(tdQtMembros / tdQtGrupos);
		} else {
			var tdMembrosGrupo = 0;
		}

		$('.tdQtTotal', linha).text(tdMembrosGrupo);

	});

}

function validaDistribuiContaGrupo(){

	var listaCdagenci = '';
	var listaQtdgrupo = '';

	$('table > tbody > tr', '#frmListaAgencias').each(function () {

		if(listaCdagenci != ''){
			listaCdagenci += ';' 
		}

		listaCdagenci += $('#cdagenci', $(this)).val();

		if(listaQtdgrupo != ''){
			listaQtdgrupo += ';' 
		}

		listaQtdgrupo += $('#qtdgrupo', $(this)).val();

	});

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando distribui&ccedil;&atilde;o...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/valida_distribui_conta_grupo.php",
        data: {
            listaCdagenci: listaCdagenci,
            listaQtdgrupo: listaQtdgrupo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesOpcaoP").focus();');
            }
        }
    });

    return false;
}

function distribuiContaGrupo(listaCdagenci, listaQtdgrupo){

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, distribuindo...");

    var xhr = $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadgrp/distribui_conta_grupo.php",
        data: {
            listaCdagenci: listaCdagenci,
            listaQtdgrupo: listaQtdgrupo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesOpcaoP").focus();');
            }
        }
    });

    return false;
}

function exportar_csv() {

    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'geraArquivoCSV();', '', 'sim.gif', 'nao.gif');

}

function geraArquivoCSV() {

    var cddopcao = $('#cddopcao', '#frmCabCadgrp').val();
    var cdagenci = $('#cdagenci', '#frmFiltroConsultaDetalhada').val();
    var nrdgrupo = $('#nrdgrupo', '#frmFiltroConsultaDetalhada').val();

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, exportando ...');

    $.ajax({
        url: UrlSite + 'telas/cadgrp/export_csv.php',
        type: 'POST',
        data: {
            cddopcao: cddopcao,
            cdagenci: cdagenci,
            nrdgrupo: nrdgrupo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        cache: false,
        // contentType: false,
        // processData: false,
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
            }
        }
    });

    return false;

}

function Gera_Impressao(nmarquiv, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/cadgrp/download_arquivo.php';

    $('#nmarquiv', '#frmCabCadgrp').remove();
    $('#sidlogin', '#frmCabCadgrp').remove();
    $('#frmCabCadgrp').append('<input type="hidden" id="nmarquiv" name="nmarquiv" value="' + nmarquiv + '" />');
    $('#frmCabCadgrp').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmCabCadgrp", action, callback);

}
