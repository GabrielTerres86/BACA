/*!
 * FONTE        : hconve.js
 * CRIAÇÃO      : Andrey Formigari (Mouts) 
 * DATA CRIAÇÃO : 19/10/2018
 * OBJETIVO     : Biblioteca de funções da tela HCONVE
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

//Formulários e Tabela
var frmCabHconve = 'frmCabHconve';
var fileUpload;


$(document).ready(function() {
    estadoInicial();
		 
});


function estadoInicial() {

    formataCabecalho();
        
    $('#cddopcao', '#frmCabHconve').habilitaCampo().focus().val('A');        
    $('#divHconve').html('').css('display', 'none');

    layoutPadrao();

}


function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCabHconve').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCabHconve').css('width', '610px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCabHconve').css('display', 'block');

    highlightObjFocus($('#frmCabHconve'));
    $('#cddopcao', '#frmCabHconve').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCabHconve').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCabHconve').click();
            return false;
        }

    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCabHconve').unbind('click').bind('click', function () {

		$('input,select').removeClass('campoErro');
		$('#cddopcao', '#frmCabHconve').desabilitaCampo();
	
		apresentaFormFiltro();
		
    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCabHconve').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('#btOK', '#frmCabHconve').click();

			apresentaFormFiltro();           

        }

    });

    return false;

}



function apresentaFormFiltro() {   

    var cddopcao = $('#cddopcao', '#frmCabHconve').val();
	
	showMsgAguardo("Aguarde...");
	
	$.ajax({
        type: 'POST',
        url: UrlSite + 'telas/hconve/monta_filtro.php',
        data: {
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divHconve').html(response);
                    
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            }
        }
    });

    return false;

}


function formataFormOpcaoA(){

	highlightObjFocus( $('#frmOpcaoA') );   
	
    //Label dos campos
    $('label[for="cdconven"]', "#frmOpcaoA").addClass("rotulo").css({ "width": "140px" });

    //Campos 
    $('#cdconven', '#frmOpcaoA').css({ 'width': '100px'}).addClass('inteiro').attr('maxlength', '5').habilitaCampo();   
    $('#nmempres', '#frmOpcaoA').css({ 'width': '300px', 'text-align': 'left'}).desabilitaCampo();   
    $('#nmprimtl', '#frmOpcaoA').css({ 'width': '300px', 'text-align': 'left' }).desabilitaCampo();  
	
    $('#divHconve').css('display', 'block');
	
	$('input','#frmOpcaoA').unbind('paste input').bind('paste input', function (e) { 
	
		var self = $(this);
		setTimeout(function () {
			var initVal = self.val();			 
			var	outputVal = removeCaracteresInvalidos(initVal,1);
			
			if (initVal != outputVal) self.val(outputVal);
		});
	
	});

	// Ao pressionar do campo cdconven
	$('#cdconven', '#frmOpcaoA').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

	});

	// Acao para quando alterar o valor do campo
	$("#cdconven", "#frmOpcaoA").unbind('change').bind('change', function () {

       $('#divTela').css('display','block');
			
		var bo = 'TELA_HCONVE';
		var procedure = 'PC_BUSCA_CONVENIOS';
		var titulo = 'Conv&ecirc;nios';
		buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmempres', $(this).val(), 'nmempres', '', 'frmOpcaoA','$(\'#cdconven\',\'#frmOpcaoA\').focus();');
		
		return false;
	});
	
	var lupas = $('a', '#frmOpcaoA' );

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
                if (campoAnterior == 'nrdconta') {
                    mostraPesquisaAssociado('nrdconta|nmprimtl', 'frmOpcaoA');
					return false;

                }else if (campoAnterior == 'cdconven') {
                    //Definição dos filtros
					var filtros = 'Código;cdconven;30px;S;0;|Nome;nmempres;200px;S;';

					//Campos que serão exibidos na tela
					var colunas = 'Código;cdconven;20%;right|Nome;nmempres;80%;left';

					//Exibir a pesquisa
					mostraPesquisa("TELA_HCONVE", "PC_BUSCA_CONVENIOS", "Conv&ecirc;nios", "30", filtros, colunas, '', '$(\'#cdconven\',\'#frmOpcaoA\').focus();', 'frmOpcaoA');
					
					return false;

                } 
            }
        });
    }); 
	
	layoutPadrao();   
	
	$("#cdconven", "#frmOpcaoA").focus();
	
    return false;

}

function formataFormOpcaoF(){

	highlightObjFocus( $('#frmOpcaoF') );   
	
    //Label dos campos
    $('label[for="cdconven"]', "#frmOpcaoF").addClass("rotulo").css({ "width": "140px" });

    //Campos 
    $('#cdconven', '#frmOpcaoF').css({ 'width': '100px'}).addClass('inteiro').attr('maxlength', '5').habilitaCampo(); 
    $('#nmempres', '#frmOpcaoF').css({ 'width': '300px', 'text-align': 'left'}).desabilitaCampo();   	

    $('#divHconve').css('display', 'block');

	$('input','#frmOpcaoF').unbind('paste input').bind('paste input', function (e) { 
	
		var self = $(this);
		setTimeout(function () {
			var initVal = self.val();			 
			var	outputVal = removeCaracteresInvalidos(initVal,1);
			
			if (initVal != outputVal) self.val(outputVal);
		});
	
	});

	// Acao para quando alterar o valor do campo
	$("#cdconven", "#frmOpcaoF").unbind('change').bind('change', function () {

       $('#divTela').css('display','block');
			
		var bo = 'TELA_HCONVE';
		var procedure = 'PC_BUSCA_CONVENIOS';
		var titulo = 'Conv&ecirc;nios';
		buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmempres', $(this).val(), 'nmempres', '', 'frmOpcaoF','$(\'#cdconven\',\'#frmOpcaoF\').focus();');
		
		return false;
	});
	
	var lupas = $('a', '#frmOpcaoF' );

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

                if (campoAnterior == 'cdconven') {
                    //Definição dos filtros
					var filtros = 'Código;cdconven;30px;S;0;|Nome;nmempres;200px;S;';

					//Campos que serão exibidos na tela
					var colunas = 'Código;cdconven;20%;right|Nome;nmempres;80%;left';

					//Exibir a pesquisa
					mostraPesquisa("TELA_HCONVE", "PC_BUSCA_CONVENIOS", "Conv&ecirc;nios", "30", filtros, colunas, '', '$(\'#cdconven\',\'#frmOpcaoF\').focus();', 'frmOpcaoF');
					
					return false;

                } 
            }
        });
    }); 
	
	layoutPadrao();   
	
	$("#cdconven", "#frmOpcaoF").focus();
	
    return false;

}
  	
function formataformOpcaoI(){
	 
	highlightObjFocus( $('#frmOpcaoI') );   
     
    //Campos     
    $('#userfile', '#frmOpcaoI').val('').habilitaCampo();   
	
    $('#divHconve').css('display', 'block');
    $('#divBotoes').css('display', 'block');
		 	 
	 //Program a custom submit function for the form
	$("#frmOpcaoI").unbind('submit').bind('submit', function(event) { 
	 
		//disable the default form submission
		event.preventDefault();
	 
		var cddopcao = $('#cddopcao', '#frmCabHconve').val();
		var frmEnvia = $('#frmOpcaoI');
		
		showMsgAguardo("Aguarde...");
		
		// Incluir o campo de login para validação (campo necessario para validar sessao)
		$('#sidlogin', frmEnvia).remove();
		$('#cddopcao', frmEnvia).remove();
		$('#flglimpa', frmEnvia).remove();
		
		$(frmEnvia).append('<input type="hidden" id="sidlogin" name="sidlogin" />');
		$(frmEnvia).append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');
		
		// Seta o valor conforme id do menu
		$('#sidlogin',frmEnvia).val( $('#sidlogin','#frmMenu').val() );
				
		//grab all form data  
		var formData = new FormData($(this)[0]);
	 
		$.ajax({
			url: UrlSite + 'telas/hconve/upload_importacao_arquivo.php',
			type: 'POST',
			data: formData,
			cache: false,
			contentType: false,
			processData: false,
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Aimaro', 'estadoInicial();');
			},
			success: function (response) {
				hideMsgAguardo();
				if (response.indexOf('Gera_Impressao') == -1 && response.indexOf('showError("inform"') == -1 && response.indexOf('showError("error"') == -1 
				                                             && response.indexOf('XML error:') == -1         && response.indexOf('#frmErro') == -1) {
					try {
						$('#divInconsistencias').html(response);
						return false;
					} catch (error) {
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
					}
				} else {
					try {
						eval(response);
					} catch (error) {
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
					}
				}
			}
		});
		
		return false;
	  
	});

	layoutPadrao();   
	
	$("#userfile", "#frmOpcaoI").focus();
	
    return false;

}


function formataformOpcaoH(){
	 
	highlightObjFocus( $('#frmOpcaoH') );   

    //Label dos campos
    $('label[for="cdconvenio"]', "#frmOpcaoH").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdhistsug1"]', "#frmOpcaoH").addClass("rotulo").css({ "width": "150px" });
    $('label[for="historicoSugerido1"]', "#frmOpcaoH").addClass("rotulo-linha").css({ "width": "145px" });
    $('label[for="cdhistor"]', "#fsetHistorico1").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dshistor"]', "#fsetHistorico1").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsexthst"]', "#fsetHistorico1").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdhistsug2"]', "#frmOpcaoH").addClass("rotulo").css({ "width": "150px" });
    $('label[for="historicoSugerido2"]', "#frmOpcaoH").addClass("rotulo-linha").css({ "width": "145px" });
    $('label[for="cdhistor"]', "#fsetHistorico2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dshistor"]', "#fsetHistorico2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsexthst"]', "#fsetHistorico2").addClass("rotulo").css({ "width": "150px" });

    //Campos 
    $('#cdconvenio', '#frmOpcaoH').addClass('inteiro campo').attr('maxlength','4').css({'width': '100px','text-align': 'left'}).desabilitaCampo();   
    $('#cdhistsug1', '#frmOpcaoH').addClass('inteiro campo').attr('maxlength','5').css({'width': '100px','text-align': 'left'}).habilitaCampo(); 
    $('#historicoSugerido1', '#frmOpcaoH').addClass('inteiro campo').attr('maxlength','5').css({'width': '100px','text-align': 'left'}).desabilitaCampo(); 
    $('#cdhistor', '#fsetHistorico1').addClass('inteiro campo').css({'width': '100px','text-align': 'left'}).habilitaCampo();   
    $('#dshistor', '#fsetHistorico1').addClass('alpha').css({'width': '350px','text-transform': 'uppercase'}).attr('maxlength','34').habilitaCampo();   
    $('#dsexthst', '#fsetHistorico1').addClass('alpha').css({'width': '350px','text-transform': 'uppercase'}).attr('maxlength','50').habilitaCampo();   
    $('#cdhistsug2', '#frmOpcaoH').addClass('inteiro campo').css({'width': '100px','text-align': 'left'}).attr('maxlength','5').habilitaCampo();   
    $('#historicoSugerido2', '#frmOpcaoH').addClass('inteiro campo').css({'width': '100px','text-align': 'left'}).attr('maxlength','5').desabilitaCampo();   
    $('#cdhistor', '#fsetHistorico2').addClass('inteiro campo').css({'width': '100px','text-align': 'left'}).attr('maxlength','5').habilitaCampo();   
    $('#dshistor', '#fsetHistorico2').addClass('alpha').css({ 'width': '350px','text-transform': 'uppercase'}).attr('maxlength','34').habilitaCampo();   
    $('#dsexthst', '#fsetHistorico2').addClass('alpha').css({ 'width': '350px','text-transform': 'uppercase'}).attr('maxlength','50').habilitaCampo();   
		 	
    $('#divHconve').css('display', 'block');
	
	$('input','#frmOpcaoH').unbind('paste').bind('paste copy', function (e) { 
		
		if ($(this).attr('name') == 'dshistor' ||
		    $(this).attr('name') == 'dsexthst'){
			return false;
		}
		
		var self = $(this);
		setTimeout(function () {
			var initVal = self.val();			 
			var	outputVal = removeCaracteresInvalidos(initVal,1);
			
			if (initVal != outputVal) self.val(outputVal);
		});
	
	});  
	
	$('input','#frmOpcaoH').unbind('input').bind('input', function (e) { 
				
		var self = $(this);
		setTimeout(function () {
			var initVal = self.val();			 
			var	outputVal = removeCaracteresInvalidos(initVal,1);
			
			if (initVal != outputVal) self.val(outputVal);
		});
	
	});  	
		
	// Ao pressionar do campo cdhistsug1
	$('#cdhistsug1', '#frmOpcaoH').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');
	
		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#cdhistor', '#fsetHistorico1').focus();

			return false;

		}

	});

	// Ao pressionar do campo cdhistor
	$('#cdhistor', '#fsetHistorico1').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dshistor', '#fsetHistorico1').focus();

			return false;

		}
		
	});
	
	// Acao para quando alterar o valor do campo
	$("#cdhistor", "#fsetHistorico1").unbind('change').bind('change', function () {
        
		buscarDescricao(  'cdhistor','dshistor|dsexthst', $(this).val(), 'fsetHistorico1');

		return false;
		
	});
	
	// Ao pressionar do campo dshistor
	$('#dshistor', '#fsetHistorico1').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');
	
		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dsexthst', '#fsetHistorico1').focus();

			return false;

		}
			
	});
		 
	// Ao pressionar do campo dsexthst
	$('#dsexthst', '#fsetHistorico1').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');
						
		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#cdhistsug2', '#frmOpcaoH').focus();

			return false;

		}
		
	});
	
	// Ao pressionar do campo cdhistsug2
	$('#cdhistsug2', '#frmOpcaoH').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#cdhistor', '#fsetHistorico2').focus();

			return false;

		} 
		
	});
	
	// Ao pressionar do campo cdhistor
	$('#cdhistor', '#fsetHistorico2').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dshistor', '#fsetHistorico2').focus();

			return false;

		}

	});
	
	// Acao para quando alterar o valor do campo
	$("#cdhistor", "#fsetHistorico2").unbind('change').bind('change', function () {
        
		buscarDescricao(  'cdhistor','dshistor|dsexthst', $(this).val(), 'fsetHistorico2');
		
		return false;
	});
	
	// Ao pressionar do campo dshistor
	$('#dshistor', '#fsetHistorico2').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#dsexthst', '#fsetHistorico2').focus();

			return false;

		}
		
	});
	
	// Ao pressionar do campo dsexthst
	$('#dsexthst', '#fsetHistorico2').unbind('keydown').bind('keydown', function(e){

		if ( divError.css('display') == 'block' ) { return false; }		

		$('input,select').removeClass('campoErro');
	
		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btCriar', '#divBotoes').click();

			return false;

		}
		
	});
		
	var lupas = $('a', '#fsetHistorico1' );

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
                if (campoAnterior == 'cdhistor') {
                   
				    //Definição dos filtros
					var filtros = 'Código;cdhistor;30px;S;0;|Nome Histórico;dsexthst;200px;S;|Nome Histórico;dshistor;200px;S;;N';

					//Campos que serão exibidos na tela
					var colunas = 'Código;cdhistor;20%;right|Nome Histórico;dsexthst;80%;left|Nome Histórico;dshistor;200px;S;;N';

					//Exibir a pesquisa
					mostraPesquisa("TELA_HCONVE", "PC_HIST_LUPA_OPCAO_H", "Hist&oacute;rico", "30", filtros, colunas, '', '$(\'#cdhistor\',\'#fsetHistorico1\').focus();', 'fsetHistorico1');
					
					return false;

                } 
            }
        });
    }); 
	
	var lupas = $('a', '#fsetHistorico2' );

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
                if (campoAnterior == 'cdhistor') {
                   
				    //Definição dos filtros
					var filtros = 'Código;cdhistor;30px;S;0;|Nome Histórico;dsexthst;200px;S;|Nome Histórico;dshistor;200px;S;;N';

					//Campos que serão exibidos na tela
					var colunas = 'Código;cdhistor;20%;right|Nome Histórico;dsexthst;80%;left|Nome Histórico;dshistor;200px;S;;N';

					//Exibir a pesquisa
					mostraPesquisa("TELA_HCONVE", "PC_HIST_LUPA_OPCAO_H", "Hist&oacute;rico", "30", filtros, colunas, '', '$(\'#cdhistor\',\'#fsetHistorico2\').focus();', 'fsetHistorico2');
					
					return false;


                } 
            }
        });
    }); 
	
	
	layoutPadrao();   
	
	$("#cdhistsug1", "#frmOpcaoH").focus();
	
    return false;

}
  

function controlaVoltar(tipo) {

    switch (tipo) {

        case '1':

            estadoInicial();

        break;
		
		case '2':

            $('input, select','#frmOpcaoH').desabilitaCampo();
            $('#btCriar','#divBotoes').css('display','none');
			

        break;
		
		case '3':

            formataformOpcaoI();
            $('#divInconsistencias').html('');
			

        break;
		 
		
    }

    return false;

}

function criarHistNovoConvenio(){
	
	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	var hisconv1 = $('#cdhistsug1', '#fsetHistorico1').val();
	var hisrefe1 = $('#cdhistor', '#fsetHistorico1').val();
	var nmabrev1 = $('#dshistor', '#fsetHistorico1').val();
	var nmexten1 = $('#dsexthst', '#fsetHistorico1').val();
	var hisconv2 = $('#cdhistsug2', '#fsetHistorico2').val();
	var hisrefe2 = $('#cdhistor', '#fsetHistorico2').val();
	var nmabrev2 = $('#dshistor', '#fsetHistorico2').val();
	var nmexten2 = $('#dsexthst', '#fsetHistorico2').val();
	
	showMsgAguardo("Aguarde... Gravando dados.");
	$('input,select').removeClass('campoErro');
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/hconve/criar_historico_novo_convenio.php",
        data: {
            cddopcao: cddopcao,
            hisconv1: hisconv1,
            hisrefe1: hisrefe1,
            nmabrev1: nmabrev1,
            nmexten1: nmexten1,
            hisconv2: hisconv2,
            hisrefe2: hisrefe2,
            nmabrev2: nmabrev2,
            nmexten2: nmexten2,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
			try {

				eval(response);
			} catch (error) {

				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
			}
        }

    });
	
	return false;
}


function btnCriarHistNovoConvenio(){
	showConfirmacao('Deseja confirmar cria&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','criarHistNovoConvenio();','$(\'#btCriar\',\'#divBotoes\').focus();','sim.gif','nao.gif');
}
 
function btnEnviarImportacaoArquivo(){
	showConfirmacao('Deseja confirmar envio do arquivo?','Confirma&ccedil;&atilde;o - Aimaro','$(\'#frmOpcaoI\').submit();','$(\'#btEnvImporArq\',\'#divBotoes\').focus();','sim.gif','nao.gif');
}

function openFile(){
	var cNmupload = $('#nmupload', '#frmOpcaoI');
    cNmupload.click();
}

function capturaFileNameUpload(event){
	fileUpload = new FormData();
	fileUpload.append('fileUpload', event.target.files[0]);
	var name = event.target.files[0].name;

	var cnmarquiv = $('#nmarquiv', '#frmOpcaoI');
	cnmarquiv.val(name);
} 
 
function limparAutorizacaoDebito() {

	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	var cdconven = $('#cdconven','#frmOpcaoA').val(); 
	
	showMsgAguardo("Aguarde... Realizando limpeza de dados.");
	$('input,select').removeClass('campoErro');
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/hconve/limpar_autorizacao_debito.php",
        data: {
			cdconven: cdconven,
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
			try {

				eval(response);
			} catch (error) {

				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
			}
        }

    });
	
	return false;
}
 
function homologarAutorizacaoDebito() {

	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	var cdconven = $('#cdconven','#frmOpcaoA').val(); 
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, efetuando homologa&ccedil;&atilde;o ...');
	
	$('input', '#frmOpcaoA').removeClass('campoErro').desabilitaCampo();
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/hconve/homologar_autorizacao_debito.php',
		data: {
			cddopcao: cddopcao,	
		    cdconven: cdconven,				
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","estadoInicial();");							
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
 
function limparFaturas() {

	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	var cdconven = $('#cdconven','#frmOpcaoF').val(); 
	
	showMsgAguardo("Aguarde... Realizando limpeza de dados.");
	$('input,select').removeClass('campoErro');
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/hconve/limpar_faturas.php",
        data: {
			cdconven: cdconven,
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
			try {

				eval(response);
			} catch (error) {

				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
			}
        }

    });
	
	return false;
}

function homologarFaturas() {

	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	var cdconven = $('#cdconven','#fsetDadosConvenio').val(); 

	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, efetuando homologa&ccedil;&atilde;o ...');
	
	$('input', '#fsetDadosConvenio').removeClass('campoErro').desabilitaCampo();
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/hconve/homologar_faturas.php',
		data: {
			cddopcao: cddopcao,	
			cdconven: cdconven,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","estadoInicial();");							
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

function Gera_Impressao(nmarquiv,callback) {	
	
	hideMsgAguardo();	
	
	var action = UrlSite + 'telas/hconve/download_arquivo.php';
	
	$('#nmarquiv','#frmCabHconve').remove();	
	$('#sidlogin','#frmCabHconve').remove();	
	
	$('#frmCabHconve').append('<input type="hidden" id="nmarquiv" name="nmarquiv" value="' + nmarquiv + '" />');	
	$('#frmCabHconve').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	carregaImpressaoAyllos("frmCabHconve",action,callback);
	
}

function buscarDescricao(  campoCodigo, campoDescricao, codigoAtual, nomeFormulario) {

	var cddopcao = $('#cddopcao','#frmCabHconve').val(); 
	
	arrayCampoDescricao = campoDescricao.split("|");	
	
	// Ação utilizada para arrumar a pesquisa utilizando o evento change
	if ( $('#'+campoCodigo,'#'+nomeFormulario).attr('aux') == $('#'+campoCodigo, '#'+nomeFormulario).val() ) { return false; }
	
	showMsgAguardo("Aguarde, pesquisando ...");
	
	// Se o código estiver vazio, então limpa o campo de descrição
	if (codigoAtual == '') {
		
		$("input[name='"+arrayCampoDescricao[0]+"']",'#'+nomeFormulario).val("");
		$("input[name='"+arrayCampoDescricao[1]+"']",'#'+nomeFormulario).val("");

		// controle do evento CHANGE
		$('#'+campoCodigo,'#'+nomeFormulario).attr('aux',codigoAtual);
		
		hideMsgAguardo();
		if( $('#divTela').css('display') == 'block' ) { unblockBackground(); };
		return false;
		
	// Se o código for zero, então retorna "Não Informado"
	} else if (codigoAtual == 0) {
		$("input[name='"+arrayCampoDescricao[0]+"']",'#'+nomeFormulario).val("");
		$("input[name='"+arrayCampoDescricao[1]+"']",'#'+nomeFormulario).val("");

		// controle do evento CHANGE
		$('#'+campoCodigo,'#'+nomeFormulario).attr('aux',codigoAtual);

		hideMsgAguardo();		
		if( $('#divTela').css('display') == 'block' ) { unblockBackground(); };
		return false;
		
	} else {
		
		// controle do evento CHANGE
		$('#'+campoCodigo,'#'+nomeFormulario).attr('aux',codigoAtual);
		
		// Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: 'POST', 
			url: UrlSite + 'telas/hconve/buscar_descricao.php',
			data: {
				cddopcao: cddopcao,
				cdhistor: codigoAtual,
				nomeFormulario: nomeFormulario,
				redirect: 'html_ajax' // Tipo de retorno do ajax
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","estadoInicial();");							
			},
			success: function (response) {            
				hideMsgAguardo();
				try {
					hideMsgAguardo();
					eval(response);
				} catch (error) {
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
				}
			}				
		});	
		
	} // fim else
	
}


//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabelaInconsistencias(){

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({ 'height': '150px', 'width' : '100%'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
	    arrayLargura[0] = '50px';
		arrayLargura[1] = '50px'; 
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'left';
					 
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha);
	
	$('input','#frmOpcaoI').desabilitaCampo();
	$('#divBotoes').css('display','none');
	$('#divInconsistencias').css('display','block');
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();		
	
	return false;
	
}