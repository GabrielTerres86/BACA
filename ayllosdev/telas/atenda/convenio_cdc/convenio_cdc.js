/*!
 * FONTE        : convenio_cdc.js
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Biblioteca de funções da rotina Convenio CDC  da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 09/03/2015 - Incluir o item Convenio CDC - Pessoa Fisica  (Andre Santos - SUPERO)
 *							   
 *				  24/08/2015 - Projeto Reformulacao cadastral (Tiago Castro - RKAM)			
 *
 *                25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
 *
 *                11/08/2016 - Inclusao de campos para apresentacao no site da cooperativa.
 *                             (Jaison/Anderson)
 *
 *                19/01/2016 - Alterado layout do form de conveio e adicionado lupa para o CEP. (Reinert)
 *
 *    		  	  27/09/2017 - Ajute para chamar a rotina de consulta do CNAE da package zoom0001
 *                             (Adriano - SD 765556).
 *
 *				  29/11/2017 - Inclusão de novos campos, Prj. 402(Jean Michel)
 * 
 * 				  04/05/2018 - Inclusão de novos campos e funcionalidades 
 *	                           Reestruturação CDC - Diego Simas - AMcom
 *
 *                01/06/2018 - Tratar exibição das abas ao acessar telas filhas.
 *                             PRJ - Reestruturação CDC (Odirlei-AMcom)
 *
 *                31/07/2019 - Permitir a inclusão dos usuários CDC para quem não possuir e tiver o CDC habilitado na tela.
 *                             (Darlei / Supero)
 * --------------
 */
 
var glbIdMatriz = 0, glbIdCooperado_CDC = 0;
var camposOrigem = 'nrcepend;dslogradouro;nrendereco;complend;nrcxapst;nmbairro;cdufende;dscidade';
var qtdAbas = 4;
var glb_cdsubsegmento = 0;
var glb_cdusuario = 0;

// Função para acessar opções da rotina
function acessaOpcaoAba(cddopcao, id) {
    
    exibeAbasCDC();
    
	if (cddopcao == "" || cddopcao == null || cddopcao == undefined) {
		cddopcao = 'P';
		id = 0;
	}
	for (var i = 0; i < qtdAbas; i++) {
		$("#linkAba" + i).attr("class", "txtNormalBold");
		$("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
		$("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color", "#C6C8CA");

		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
			$("#linkAba" + id).attr("class", "txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
			$("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color", "#969FA9");
		}
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST",		
		url: UrlSite + "telas/atenda/convenio_cdc/principal.php",
		data: {
			nrdconta: nrdconta,
            inpessoa: inpessoa,
            idmatriz: 0,
			cddopcao: cddopcao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina)); 
		},
		success: function(response) {

			$('#divConteudoOpcao').html(response);
		}				
	});
}

function manterRotina(operacao) {

	var idcooperado_cdc    = $('#idcooperado_cdc',    '#frmConvenioCdc').val();
    var flgconve           = $('#flgconve',           '#frmConvenioCdc').val();
	var dtinicon           = $('#dtinicon',           '#frmConvenioCdc').val();
	var inmotcan = $('#inmotcan', '#frmConvenioCdc').val();
	var dtcancon = $('#dtcancon', '#frmConvenioCdc').val();
	var dsmotcan = $('#dsmotcan', '#frmConvenioCdc').val();
	var dtrencon = $('#dtrencon', '#frmConvenioCdc').val();
	var dttercon = $('#dttercon', '#frmConvenioCdc').val();

    var nmfantasia         = $('#nmfantasia',         '#frmConvenioCdc').val();
    var cdcnae             = $('#cdcnae',             '#frmConvenioCdc').val();
    var dslogradouro       = $('#dslogradouro',       '#frmConvenioCdc').val();
    var dscomplemento      = $('#dscomplemento',      '#frmConvenioCdc').val();
    var nrendereco         = $('#nrendereco',         '#frmConvenioCdc').val();
    var nmbairro           = $('#nmbairro',           '#frmConvenioCdc').val();
    var nrcep              = $('#nrcepend',           '#frmConvenioCdc').val();
    var idcidade           = $('#idcidade',           '#frmConvenioCdc').val();
    var dstelefone         = $('#dstelefone',         '#frmConvenioCdc').val();
    var dsemail            = $('#dsemail',            '#frmConvenioCdc').val();
	var nrlatitude = $('#nrlatitude', '#frmConvenioCdc').val();
	var nrlongitude = $('#nrlongitude', '#frmConvenioCdc').val();
	var idcomissao = $('#idcomissao', '#frmConvenioCdc').val();
	var flgitctr = $('#flgitctr', '#frmConvenioCdc').val();

    var fncRetorno  = '';
	var msgRetorno  = '';
    var msgOperacao = '';

	switch (operacao) {
		// Filial - Consulta para Exclusao
		case 'FCE':
            msgRetorno      = 'Filial exclu&iacute;da com sucesso!';
            msgOperacao     = 'excluindo filial';
            idmatriz        = glbIdMatriz;
            idcooperado_cdc = glbIdCooperado_CDC;
			break;
		// Finalizar Inclusao
		case 'INCLUIR':
			msgRetorno      = 'Dados inclu&iacute;dos com sucesso!';
            msgOperacao     = 'salvando inclus&atilde;o';
			break;
		case 'ALTERAR':
			msgRetorno      = 'Dados alterados com sucesso!';
            msgOperacao     = 'salvando altera&atilde;o';
			break;
		default: 
			msgRetorno      = 'Dados alterados com sucesso!';
            msgOperacao     = 'salvando altera&ccedil;&atilde;o';
            if (glbIdMatriz == 0 || glbIdMatriz == '' ){
                idmatriz = idcooperado_cdc;
            }else{
                idmatriz = glbIdMatriz;
            }
            
            
            }
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');

	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/atenda/convenio_cdc/manter_rotina.php', 		
		data: {
			cddopcao           : cddopcao,
            operacao           : operacao,
            nrdconta           : nrdconta,
            inpessoa           : inpessoa,
            idmatriz           : normalizaNumero(idmatriz),
            idcooperado_cdc    : normalizaNumero(idcooperado_cdc),
			flgconve           : normalizaNumero(flgconve),
			dtinicon           : dtinicon,
			inmotcan: inmotcan,
			dtcancon: dtcancon,
			dsmotcan: dsmotcan,
			dtrencon: dtrencon,
			dttercon: dttercon,
            nmfantasia         : nmfantasia,
            cdcnae             : cdcnae,
            dslogradouro       : dslogradouro,
            dscomplemento      : dscomplemento,
            nrendereco         : normalizaNumero(nrendereco),
            nmbairro           : nmbairro,
            nrcep              : normalizaNumero(nrcep),
            idcidade           : normalizaNumero(idcidade),
            dstelefone         : dstelefone,
            dsemail            : dsemail,
			nrlatitude: nrlatitude,
			nrlongitude: nrlongitude,
			idcomissao: idcomissao,
			flgitctr: normalizaNumero(flgitctr),
			redirect           : 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();

            if((operacao == 'ALTERAR') && (parseInt(idmatriz) == 0)){
				fncRetorno = 'acessaOpcaoAba(\'P\',0)';
			}else{
				// Se NAO possuir matriz volta para tela inicial, caso contratio volta para a listagem de filiais
				fncRetorno = (idmatriz == idcooperado_cdc ? 'acessaOpcaoAba(\'P\',0)' : 'abreFiliais(\'' + idmatriz + '\')');
			}
			showError('inform',msgRetorno,'Alerta - Aimaro','bloqueiaFundo(divRotina);' + fncRetorno);
			eval(response);
			
		}				
	});
}

function controlaLayout(operacao) {

	var rFlgconve           = $('label[for="flgconve"]',           '#frmConvenioCdc');
	var rDtinicon           = $('label[for="dtinicon"]',           '#frmConvenioCdc');
	var rInmotcan = $('label[for="inmotcan"]', '#frmConvenioCdc');
	var rDtcancon = $('label[for="dtcancon"]', '#frmConvenioCdc');
	var rDsmotcan = $('label[for="dsmotcan"]', '#frmConvenioCdc');
	var rDtrencon = $('label[for="dtrencon"]', '#frmConvenioCdc');
	var rDttercon = $('label[for="dttercon"]', '#frmConvenioCdc');
	var rDtacectr = $('label[for="dtacectr"]', '#frmConvenioCdc');

	var rIdcooperado_cdc = $('label[for="idcooperado_cdc"]', '#frmConvenioCdc');
    var rNmfantasia         = $('label[for="nmfantasia"]',         '#frmConvenioCdc');
    var rCdcnae             = $('label[for="cdcnae"]',             '#frmConvenioCdc');
    var rDslogradouro       = $('label[for="dslogradouro"]',       '#frmConvenioCdc');
    var rDscomplemento      = $('label[for="dscomplemento"]',      '#frmConvenioCdc');
    var rNrendereco         = $('label[for="nrendereco"]',         '#frmConvenioCdc');
    var rNmbairro           = $('label[for="nmbairro"]',           '#frmConvenioCdc');
    var rNrcep              = $('label[for="nrcepend"]',           '#frmConvenioCdc');
    var rIdcidade           = $('label[for="idcidade"]',           '#frmConvenioCdc');
    var rDscidade           = $('label[for="dscidade"]',           '#frmConvenioCdc');
    var rCdufende           = $('label[for="cdufende"]',           '#frmConvenioCdc');
    var rDstelefone         = $('label[for="dstelefone"]',         '#frmConvenioCdc');
    var rDsemail            = $('label[for="dsemail"]',            '#frmConvenioCdc');
	var rIdcomissao = $('label[for="idcomissao"]', '#frmConvenioCdc');
	var rNrlatitude = $('label[for="nrlatitude"]', '#frmConvenioCdc');
	var rNrlongitude = $('label[for="nrlongitude"]', '#frmConvenioCdc');
	var rFlgitctr = $('label[for="flgitctr"]', '#frmConvenioCdc');


	var cFlgconve           = $('#flgconve',                       '#frmConvenioCdc');
	var cDtinicon           = $('#dtinicon',                       '#frmConvenioCdc');
	var cInmotcan = $('#inmotcan', '#frmConvenioCdc');
	var cDtcancon = $('#dtcancon', '#frmConvenioCdc');
	var cDsmotcan = $('#dsmotcan', '#frmConvenioCdc');
	var cDtrencon = $('#dtrencon', '#frmConvenioCdc');
	var cDttercon = $('#dttercon', '#frmConvenioCdc');
	var cDtacectr = $('#dtacectr', '#frmConvenioCdc');
    var cIdcooperado_cdc = $('#idcooperado_cdc', '#frmConvenioCdc');
    var cNmfantasia         = $('#nmfantasia',                     '#frmConvenioCdc');
    var cCdcnae             = $('#cdcnae',                         '#frmConvenioCdc');
    var cDscnae             = $('#dscnae',                         '#frmConvenioCdc');
    var cDslogradouro       = $('#dslogradouro',                   '#frmConvenioCdc');
    var cDscomplemento      = $('#dscomplemento',                  '#frmConvenioCdc');
    var cNrendereco         = $('#nrendereco',                     '#frmConvenioCdc');
    var cNmbairro           = $('#nmbairro',                       '#frmConvenioCdc');
    var cNrcep              = $('#nrcepend',                       '#frmConvenioCdc');
    var cIdcidade           = $('#idcidade',                       '#frmConvenioCdc');
    var cDscidade           = $('#dscidade',                       '#frmConvenioCdc');
	var cCdufende           = $('#cdufende',           		       '#frmConvenioCdc');
    var cDstelefone         = $('#dstelefone',                     '#frmConvenioCdc');
    var cDsemail            = $('#dsemail',                        '#frmConvenioCdc');
	var cIdcomissao = $('#idcomissao', '#frmConvenioCdc');
	var cNmcomissao = $('#nmcomissao', '#frmConvenioCdc');
	var cNrlatitude = $('#nrlatitude', '#frmConvenioCdc');
	var cNrlongitude = $('#nrlongitude', '#frmConvenioCdc');
	var cFlgitctr = $('#flgitctr', '#frmConvenioCdc');

	$('#frmConvenioCdc').css({'padding-top':'5px','padding-bottom':'15px'});

	// Formatação dos rotulos
	rFlgconve.css('width','134px');		
	rDtinicon.css('width', '69px');
	rInmotcan.css('width', '46px');
	rDsmotcan.css('width', '66px');
	rDtcancon.css('width', '62px');
	rDtrencon.css('width', '94px');
	rDttercon.css('width', '85px');
	rDtacectr.css('width', '90px');
	rFlgitctr.css('width', '105px');
    
    rIdcooperado_cdc.addClass('rotulo').css({ 'width': '110px' });
    rNmfantasia.addClass('rotulo').css({'width': '110px'});
    rCdcnae.addClass('rotulo').css({'width': '110px'});
    rNrcep.addClass('rotulo').css({'width': '110px'});
    rDslogradouro.addClass('rotulo').css({'width': '110px'});
    rNrendereco.addClass('rotulo-linha').css({'width': '20px'});
    rDscomplemento.addClass('rotulo').css({'width': '110px'});
    rNmbairro.addClass('rotulo').css({'width': '110px'});
    rIdcidade.addClass('rotulo').css({'width': '110px'});
	rCdufende.addClass('rotulo-linha').css({'width': '20px'});
    rDstelefone.addClass('rotulo').css({'width': '110px'});
    rDsemail.addClass('rotulo').css({'width': '110px'});
	rIdcomissao.addClass('rotulo').css({ 'width': '110px' });
	rNrlatitude.addClass('rotulo').css({ 'width': '110px' });
	rNrlongitude.addClass('rotulo').css({ 'width': '110px' });
	
	cFlgconve.addClass('campo').css('width','50px');
	//cFlgitctr.addClass('campo').css('width', '50px');
	cDtinicon.addClass('campo').addClass('data').css({ 'width': '70px' });
	cInmotcan.addClass('campo').css({ 'width': '110px' });
	cDsmotcan.addClass('campo').css({ 'width': '121px' });
	cDtcancon.addClass('campo').addClass('data').css({ 'width': '70px' });
	cDtrencon.addClass('campo').addClass('data').css({ 'width': '70px' });
	cDttercon.addClass('campo').addClass('data').css({ 'width': '70px' });
	cDtacectr.addClass('campo').addClass('data').css({ 'width': '70px' });
    cIdcooperado_cdc.addClass('campo').addClass('inteiro').css({ 'width': '70px' })	
    cNmfantasia.addClass('campo').css({'width':'370px'}).attr('maxlength','500');
    cCdcnae.addClass('campo pesquisa').css({'width':'80px'}).attr('maxlength','10');
    cDscnae.addClass('campo').addClass('data').css({'width':'267px'});
    cNrcep.addClass('campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zz.zzz-zzz','','');
    cDslogradouro.addClass('campo').css({'width':'280px'}).attr('maxlength','200');
    cNrendereco.addClass('campo').css({'width':'64px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
    cDscomplemento.addClass('campo').css({'width':'370px'}).attr('maxlength','200');
    cNmbairro.addClass('campo').css({'width':'370px'}).attr('maxlength','200');
    cIdcidade.addClass('campo pesquisa').css({'width':'40px'}).attr('maxlength','8').setMask('INTEGER','zzzzzzzz','','');
    cDscidade.addClass('campo').css({'width':'250px'});
	cCdufende.addClass('campo').css({'width':'31px'});
    cDstelefone.addClass('campo').css({'width':'370px'}).attr('maxlength','50');
    cDsemail.addClass('campo').css({'width':'370px'}).attr('maxlength','200');
	cIdcomissao.addClass('campo pesquisa').css({ 'width': '60px' }).attr('maxlength', '10').setMask('INTEGER', 'zzzzzzzz', '', '');
	cNmcomissao.addClass('campo').css({ 'width': '287px' }).attr('maxlength', '200');

	cNrlatitude.addClass('campo').css({ 'width': '150px' });
	cNrlongitude.addClass('campo').css({ 'width': '150px' });
	cDtacectr.desabilitaCampo();
	cDttercon.desabilitaCampo();
	cDtrencon.desabilitaCampo();
    cIdcooperado_cdc.desabilitaCampo();
		
	highlightObjFocus( $('#frmConvenioCdc') );
				
    switch (operacao) {			
        case 'FCI': // Filial - Consulta para Inclusao
        case 'FCA': // Filial - Consulta para Alteracao
            $('.clsCampos', '#frmConvenioCdc').hide();
            break;
        default: 
            $('.clsCampos', '#frmConvenioCdc').show();
	}
			
	cFlgconve.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDtinicon.focus();
			return false;
		}
    }).unbind('change').bind('change', function(e){
		if ($(this). val() == 1){
			showConfirmacao('Deseja importar os dados de endere&ccedil;o da Tela CONTAS?','Confirma&ccedil;&atilde;o - Aimaro','buscaInformacoesCadastro();$(\'#dtinicon\',\'#frmConvenioCdc\').focus();','bloqueiaFundo(divRotina);cDtinicon.focus();','sim.gif','nao.gif');
		}
	});
	
	cDtinicon.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cInmotcan.focus();
			return false;
		}
	});

	cInmotcan.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			cDsmotcan.focus();
			return false;
		}
	});

	cDsmotcan.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			cDtcancon.focus();
			return false;
		}
	});

	cDtcancon.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			cFlgitctr.focus();
			return false;
		}
	});

	cFlgitctr.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			cNmfantasia.focus();
			return false;
}
	});	
	
	cNmfantasia.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
            // Filial - Consulta para Inclusao ou Filial - Consulta para Alteracao
            if (operacao == 'FCI' || operacao == 'FCA') {
                cNrcep.focus();
            } else {
                cCdcnae.focus();
            }
			return false;
}
	});

	cCdcnae.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrcep.focus();
			return false;
		}
	});
	
	cNrcep.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) {
			if ( normalizaNumero($(this).val()) == 0 ) {
				limparEndereco(camposOrigem, 'frmConvenioCdc');
				return false;
			}
			mostraPesquisaEndereco('frmConvenioCdc', camposOrigem, divRotina, $(this).val());
			return false;
		}
	});
	
	cDslogradouro.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrendereco.focus();
			return false;
		}
	});

	cNrendereco.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDscomplemento.focus();
			return false;
		}
	});

	cDscomplemento.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNmbairro.focus();
			return false;
		}
	});
	
	cNmbairro.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdcidade.focus();
			return false;
		}
	});
	

	cIdcidade.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDstelefone.focus();
			return false;
		}
	});
	
	cDstelefone.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsemail.focus();
			return false;
		}
	});
	
	cDsemail.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {		
			cNrlatitude.focus();
			return false;
		}
	});
	
	cNrlatitude.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			cNrlongitude.focus();
			return false;
		}
	});

	cNrlatitude.keyup(function () {

		this.value = this.value.replace(/\./g, ',').replace(/[^0-9,.-]/g, '');// Deixa digitar somente hífen, ponto e número

		if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
			this.value = this.value.replace(/\-$/g, '');

		if ((this.value.match(/\,/g) || []).length > 1) //Remove as ocorrências de vírgula (,), deixando apenas a primeira
			this.value = this.value.replace(/\,$/g, '');
	});

	cNrlongitude.unbind('keypress').bind('keypress', function (e) {
		if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey) ) {

            switch (operacao) {
                case 'FCI': // Filial - Consulta para Inclusao
                    controlaOperacao('INCLUIR');
                    break;
                default:
                    controlaOperacao('ALTERAR');
            }
			return false;
		}
	});

	cNrlongitude.keyup(function () {
		this.value = this.value.replace(/\./g, ',').replace(/[^0-9,.-]/g, '');// Deixa digitar somente hífen, ponto e número

		if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
			this.value = this.value.replace(/\-$/g, '');

		if ((this.value.match(/\,/g) || []).length > 1) //Remove as ocorrências de vírgula (,), deixando apenas a primeira
			this.value = this.value.replace(/\,$/g, '');

    });
	
	var divRegistro = $('div.divRegistros','#divTitularCDCPrincipal');		
	var tabela      = $('table', divRegistro );
					
	divRegistro.css('height','55px');
					
	var ordemInicial = new Array();


    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
			
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
					
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
							
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('tbody > tr',tabela).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			$(this).focus();		
		}
	});
		
    switch (operacao) {
        case 'CA': // Consulta para Alteração
            cDscnae.desabilitaCampo();
			cNmcomissao.desabilitaCampo();
            cDscidade.desabilitaCampo();
			cCdufende.desabilitaCampo();
            if (inpessoa == 1) {
                cCdcnae.habilitaCampo();
            } else {
                cCdcnae.desabilitaCampo();
            }
            cFlgconve.focus();
            break;
        case 'FCI': // Filial - Consulta para Inclusao
        case 'FCA': // Filial - Consulta para Alteracao
            cDscidade.desabilitaCampo();
            cNmfantasia.focus();
            break;
        default:
            $('input,select,textarea', '#frmConvenioCdc').desabilitaCampo();
            $('#btAlterar','#divBotoes').focus();
    }

    controlaPesquisas();

    $('#cdcnae','#frmConvenioCdc').trigger('change');
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	$(this).fadeIn(1000);
	divRotina.centralizaRotinaH(); 
	return false;
}

function controlaOperacao(operacao) {

	// integracao cdc
	var flgconve = $('#flgconve', '#frmConvenioCdc').val();
	var dtcancon = $('#dtcancon', '#frmConvenioCdc').val();
	var inmotcan = $('#inmotcan', '#frmConvenioCdc').val();
	var dsmotcan = $('#dsmotcan', '#frmConvenioCdc').val();
	var idcidade = $('#idcidade', '#frmConvenioCdc').val();
	var dscidade = $('#dscidade', '#frmConvenioCdc').val();
	var dtinicon = $('#dtinicon', '#frmConvenioCdc').val();

    exibeAbasCDC();
    
	// Verifica permissões de acesso
	if ( (operacao == 'CA')  && (flgAlterar != '1') ||
         (operacao == 'FCE') && (flgExcluir != '1') ||
         (operacao == 'FCI') && (flgExcluir != '1') ||
         (operacao == 'FCA') && (flgAlterar != '1') ) {
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o para realizar esta opera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		return false;
	}

    // Se foi clicado para Excluir ou Alterar filial e nao possui registros
    if ($('#tBodyRegs tr').length == 0 &&
        (operacao == 'FCE' || operacao == 'FCA')) {
        ocultaAbasCDC();    
        showError('error','Nenhuma filial dispon&iacute;vel.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		return false;
    }
	
	if (operacao == 'ALTERAR' || operacao == 'INCLUIR') {

		// valida cidade
		if (idcidade == 0 && dscidade != '') {
		showError('error','Informe o c&oacute;digo da cidade.','Alerta - Aimaro','bloqueiaFundo(divRotina);$(\'#idcidade\', \'#frmConvenioCdc\').focus();');
		return false;
	}

		// valida data de inicio convenio cdc
		if (flgconve == 1 && (dtinicon == "" || dtinicon == null || dtinicon == undefined)) {
			showError('error', 'Informe a data de inicio do convenio cdc.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			return false;
		}

		// valida data de cancelamento
		if (flgconve == 0 && (dtcancon == "" || dtcancon == null || dtcancon == undefined)) {
			showError('error', 'Informe a data de cancelamento.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			return false;
		}

	    // valida motivo de cancelamento
	    if (flgconve == 0 && inmotcan == 0) {
			showError('error', 'Selecione o motivo do cancelamento.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			return false;
		}

		// validq descricao de outros
		if (flgconve == 0 && inmotcan == 5 && (dsmotcan == "" || dsmotcan == null || dsmotcan == undefined)) {
			showError('error', 'Preencha o motivo do cancelamento.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			return false;
		}
	}

	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {
		// Consulta para Alteração
		case 'CA':
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao    = 'A';
			break;
		// Alteração para Consulta
		case 'AC':
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Finalizar Alteracao
		case 'ALTERAR':
			showConfirmacao('Confirma a altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'' + operacao + '\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			return false;
			break;
		// Finalizar Inclusao
		case 'INCLUIR':
			showConfirmacao('Confirma a inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'' + operacao + '\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			return false;
			break;
		// Carregar tela de filiais
		case 'FILIAIS':
            ocultaAbasCDC();
            
            var idcooperado_cdc = (normalizaNumero(glbIdMatriz) == 0 ? normalizaNumero($('#idcooperado_cdc', '#frmConvenioCdc').val()) : normalizaNumero(glbIdMatriz));
            if (idcooperado_cdc == 0) {
                showError('error','Antes de acessar as filiais &eacute; necess&aacute;rio gravar os dados da matriz.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
                return false;
            } else {
                abreFiliais(idcooperado_cdc);
                return false;
            }
			break;
		// Filial - Consulta para Exclusao
		case 'FCE':
            cddopcao = 'E';
            showConfirmacao('Confirma a exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'' + operacao + '\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			return false;
			break;
		// Filial - Consulta para Inclusao
		case 'FCI':
            ocultaAbasCDC();
            msgOperacao     = 'abrindo inclus&atilde;o';
            idmatriz        = glbIdMatriz;
            idcooperado_cdc = 0;
            cddopcao        = 'I';
            break;
		// Filial - Consulta para Alteracao
		case 'FCA':
            ocultaAbasCDC();
            msgOperacao     = 'abrindo altera&ccedil;&atilde;o';
            idmatriz        = glbIdMatriz;
            idcooperado_cdc = glbIdCooperado_CDC;
            cddopcao        = 'A';
			break;
		// Subsegmento - Cancelar inclusão
		case 'SCI':
			showConfirmacao('Deseja cancelar a inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'acessaOpcaoAba(\'S\',0);', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			return false;
            break;
		default: 
			msgOperacao = 'abrindo consulta';
			cddopcao = '@';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/convenio_cdc/principal.php', 
		data: {
			nrdconta       : nrdconta,
			inpessoa       : inpessoa,
			operacao       : operacao,
            idmatriz       : normalizaNumero(idmatriz),
            idcooperado_cdc: normalizaNumero(idcooperado_cdc),
			redirect       : "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );				
			}
			return false;
		}				
	});
}

function controlaPesquisas() {
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosPesq, filtrosDesc, cdestado, cCEP;	
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.link)','#frmConvenioCdc');
	lupas.addClass('lupa').css('cursor','auto');

	// Percorrendo todos os links
	lupas.each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
	
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				// CNAE
				if ( campoAnterior == 'cdcnae' ) {
					procedure	= 'BUSCA_CNAE';
					titulo      = 'CNAE';
					qtReg		= '30';
					filtrosPesq = 'Codigo;cdcnae;60px;S;0;;descricao|CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
					colunas     = 'Codigo;cdcnae;20%;right|CNAE;dscnae;80%;left';			
					mostraPesquisa('ZOOM0001', procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
					return false;
				
                // CEP
                } else if ( campoAnterior == 'nrcepend' ) {
					cCEP = $(this).prev(); 
					if( cCEP.hasClass('campo') || cCEP.hasClass('campoFocusIn')) mostraPesquisaEndereco('frmConvenioCdc', camposOrigem, divRotina);
					return false;
                // Cidade
                } else if (campoAnterior == 'idcidade') {
                    cdestado    = $('#cdestado', '#frmConvenioCdc').val();
                    bo          = 'CADA0003'
                    procedure   = 'LISTA_CIDADES';
                    titulo      = 'Cidades';
                    qtReg       = '20';
                    filtrosPesq = 'Codigo;idcidade;70px;S;;S;codigo|Cidade;dscidade;200px;S;;S;descricao|UF;cdestado;40px;S;' + cdestado + ';S;descricao|;infiltro;;N;1;N;codigo|;intipnom;;N;1;N;codigo|;cdcidade;;N;0;N;codigo';
                    colunas     = 'Codigo;idcidade;30%;center|Cidade;dscidade;60%;left|UF;cdestado;10%;center';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;
				} else if (campoAnterior == 'idcomissao') {

					var idcomissao = $('#idcomissao', '#frmConvenioCdc').val();
    				var nmcomissao = $('#nmcomissao', '#frmConvenioCdc').val();

					pck = 'zoom0001';
					acao = 'BUSCA_COMISSAO';
					titulo = 'Comiss&atildeo';
					qtReg = '';
					filtros = 'C&oacuted. Comiss&atildeo;idcomissao;30px;S;' + idcomissao + ';S|Comiss&atildeo;nmcomissao;200px;S;' + nmcomissao + ';S';
					colunas = 'C&oacuted. Comiss&atildeo;idcomissao;20%;center' +
							  '|Comiss&atildeo;nmcomissao;48%;left';
					mostraPesquisa(pck, acao, titulo, qtReg, filtros, colunas);
					var telaPrincipal = $('#divPesquisa');
					telaPrincipal.css('zIndex', 4000);
					return false;
                }
			}
		}));
	});

	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRICOES     */
	/*-------------------------------------*/	

	// CNAE
	$('#cdcnae','#frmConvenioCdc').unbind('change').bind('change',function() {
        procedure	= 'BUSCA_CNAE';
		titulo      = 'CNAE';		
		filtrosDesc = 'flserasa|2'; // 2 - Todos
		buscaDescricao('ZOOM0001', procedure, titulo, $(this).attr('name'), 'dscnae', $(this).val(), 'dscnae', filtrosDesc, 'frmConvenioCdc');
		return false;
    });

	return false;
}

function abreFiliais(idmatriz) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
    
    glbIdMatriz = idmatriz;

    // Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST",		
		url: UrlSite + "telas/atenda/convenio_cdc/filiais.php",
		data: {
			idmatriz: idmatriz,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina)); 
		},
		success: function(response) {
			$('#divConteudoOpcao').html(response);
            controlaLayoutTabela();
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	$(this).fadeIn(1000);
	divRotina.centralizaRotinaH(); 
	return false;	
}
	});
}

function controlaLayoutTabela() {

    var divRegistro  = $('div.divRegistros');		
    var tabela       = $('table', divRegistro );
    var linha        = $('table > tbody > tr', divRegistro );

    var ordemInicial = new Array();
    var arrayLargura = new Array();

    arrayLargura[0] = '180px';
    arrayLargura[1] = '170px';
    arrayLargura[2] = '120px';

    var arrayAlinha = new Array();

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

    // seleciona o registro que e clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbIdMatriz = $(this).find('#glbIdMatriz').val();
        glbIdCooperado_CDC = $(this).find('#glbIdCooperado_CDC').val();
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();

}

mtSelecaoEndereco = function() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Verificando cidade...");	
	
	var cdufende, nmcidade;
	
	cdufende = $('#cdufende', '#frmConvenioCdc').val();
	nmcidade = $('#dscidade', '#frmConvenioCdc').val();
	
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/convenio_cdc/verifica_cidade.php",
        data: {
            cdufende: cdufende,
            nmcidade: nmcidade,
            redirect: "script_ajax"
        },
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina)); 
        },
		success: function(response) {
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
            eval(response);
        }
    });	
}

function buscaInformacoesCadastro(){
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando informa&ccedil;&atilde;o de cadastro...");	
		
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/convenio_cdc/busca_informacoes_cadastro.php",
        data: {
			nrdconta: nrdconta
           ,redirect: "script_ajax"
        },
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina)); 
        },
		success: function(response) {
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
            eval(response);
        }
    });		
}


function formataTabelaSegmento() {
	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('#tableSegmento', divRegistro);

	divRegistro.css('height', '300px');
	divRegistro.css('width', '650px');

	var ordemInicial = new Array();


	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '35px';
	arrayLargura[2] = '120px';
	arrayLargura[3] = '35px';
	arrayLargura[4] = '100px';
	arrayLargura[5] = '75px';	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'center';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	$('tbody > tr', tabela).each(function () {
		if ($(this).hasClass('corSelecao')) {
			$(this).click();
			$(this).focus();
		}
	});
}

function formataTabelaVendedores() {
	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('#tableVendedores', divRegistro);

	divRegistro.css('height', '300px');
	divRegistro.css('width', '750px');

	var ordemInicial = new Array();


	var arrayLargura = new Array();
	arrayLargura[0] = '44px';
	arrayLargura[1] = '178px';
	arrayLargura[2] = '94px';
	arrayLargura[3] = '144px';
	arrayLargura[4] = '44px';
	//arrayLargura[5] = '162px';	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	$('tbody > tr', tabela).each(function () {
		if ($(this).hasClass('corSelecao')) {
			$(this).click();
			$(this).focus();
		}
	});
}

function formataTabelaUsuarios() {
	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('#tableUsuarios', divRegistro);

	divRegistro.css('height', '300px');
	divRegistro.css('width', '750px');

	var ordemInicial = new Array();


	var arrayLargura = new Array();
	arrayLargura[0] = '24px';
	arrayLargura[1] = '33px';
	arrayLargura[2] = '22px';
	arrayLargura[3] = '47px';
	arrayLargura[4] = '19px';
	arrayLargura[5] = '48px';	    

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
  
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	$('tbody > tr', tabela).each(function () {
		if ($(this).hasClass('corSelecao')) {
			$(this).click();
			$(this).focus();
		}
	});
}

function controlaPesquisasSegmentos() {
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosPesq, filtrosDesc, cdsubsegmento, dssubsegmento;

	cdsubsegmento = $('#cdsubsegmento', '#frmIncluiSegCdc').val();
	dssubsegmento = $('#dssubsegmento', '#frmIncluiSegCdc').val();

	bo = 'TELA_ATENDA_CVNCDC'
	procedure = 'LISTA_SUBSEGMENTOS';
	titulo = 'Subsegmentos';
	qtReg = '20';
	filtrosPesq = 'Codigo;cdsubsegmento;70px;S;' + cdsubsegmento + ';S;cdsubsegmento|Descricao;dssubsegmento;200px;S;' + dssubsegmento + ';S;descricao|Coop;cdcooper;1px;N;' + cdcooper + ';N;cdcooper'; 
	colunas = 'Codigo;cdsubsegmento;10%;center|Descricao;dssubsegmento;45%;left|Segmento;dssegmento;45%;center';
	mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
	return false;
}

function controlaPesquisaVinculo() {
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosPesq, filtrosDesc, cdsubsegmento, dssubsegmento;

	idcooperado_cdc = $('#idcooperado_cdc', '#idcooperado_cdc').val();

    cdvinculo = 0;
	dsvinculo = '';

	bo = 'TELA_ATENDA_CVNCDC'
	procedure = 'LISTA_VINCULOS';
	titulo = 'V&iacute;nculos';
	qtReg = '20';
	filtrosPesq = 'Codigo;cdvinculo;70px;S;' + cdvinculo + ';S;cdvinculo|'+
		'Descri&ccedil&atildeo;dsvinculo;200px;S;' + dsvinculo + ';S;dsvinculo|'+
		';idcooperado_cdc;;N;' + idcooperado_cdc + ';N';		
	colunas = 'Codigo;cdvinculo;10%;center|Descricao;dsvinculo;45%;left';
	mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
	return false;
}

function manterSubsegmento(cddopcao) {
	var idcooperado_cdc = 0;
	var cdsubsegmento = 0;

	if (cddopcao == "I") {
		idcooperado_cdc = $('#idcooperado_cdc', '#frmIncluiSegCdc').val();
		cdsubsegmento = $('#cdsubsegmento', '#frmIncluiSegCdc').val();
	} else if (cddopcao == "E") {
		idcooperado_cdc = $('#idcooperado_cdc', '#frmSegmentoCdc').val();
		cdsubsegmento = glb_cdsubsegmento;
	}

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/convenio_cdc/manter_subsegmento.php',
		data: {
			cddopcao: cddopcao,
			cdsubsegmento: cdsubsegmento,
			idcooperado_cdc: normalizaNumero(idcooperado_cdc),
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			eval(response);
			return false;
		}
	});
}

function alteraUsuario() {

	var cddopcao = 'A';
	var senha = $('#senha', '#frmUsuario').val();
	var tipo = $('#tipo', '#frmUsuario').val();
	var vinculo = $('#cdvinculo', '#frmUsuario').val();
	var ativo = $('#ativo', '#frmUsuario').val();
    var bloqueio = $('#bloqueio', '#frmUsuario').val();
	var senhaUsuario = $('#senhaUsuario', '#frmUsuario').val();

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/convenio_cdc/manter_usuario.php',
		data: {
			cddopcao: cddopcao,
			senha: senha,
			tipo: normalizaNumero(tipo),
			vinculo: normalizaNumero(vinculo),
			ativo: normalizaNumero(ativo),
			bloqueio: normalizaNumero(bloqueio),
			cdusuario: glb_cdusuario,
			senhaUsuario: senhaUsuario,
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			eval(response);
		}
	});
}

function selecionaSubsegmento(cdsubsegmento) {
	glb_cdsubsegmento = cdsubsegmento;
}

function selecionaUsuario(cdusuario) {
	glb_cdusuario = cdusuario;
}

function mostraFormInclusaoSeg(idcooperado_cdc) {

    idcooperado_cdc = $('#idcooperado_cdc', '#frmSegmentoCdc').val();

	// não deixar incluir segmentos para um lojista desabilitado
	if (idcooperado_cdc == 0 || idcooperado_cdc==null || idcooperado_cdc==undefined){
		showError('error', 'Lojista nao esta habilitado!', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	$.ajax({
		dataType: 'html',
		type: 'POST',
		url: UrlSite + 'telas/atenda/convenio_cdc/form_inclui_segmento_cdc.php',
		data: {
			idcooperado_cdc: normalizaNumero(idcooperado_cdc),
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			$('#divConteudoOpcao').html(response);
            ocultaAbasCDC();
			return false;
		}
	});
}

function mostraFormUsuAlterar(idcooperado_cdc) {

    // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	$.ajax({
		dataType: 'html',
		type: 'POST',
		url: UrlSite + 'telas/atenda/convenio_cdc/form_altera_usuario.php',
		data: {
			idcooperado_cdc: normalizaNumero(idcooperado_cdc),
            idusuario: glb_cdusuario,
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			$('#divConteudoOpcao').html(response);
            ocultaAbasCDC();
			return false;
		}
	});  

}

function formataInclusaoSegmento() {

	/* ABA SEGMENTOS */
	var rCdsubsegmento = $('label[for="cdsubsegmento"]', '#frmIncluiSegCdc');
	var cCdsubsegmento = $('#cdsubsegmento', '#frmIncluiSegCdc');
	var cDssubsegmento = $('#dssubsegmento', '#frmIncluiSegCdc');
	cCdsubsegmento.addClass('campo').addClass('inteiro').css({ 'width': '35px' });
	cDssubsegmento.addClass('campo').css({ 'width': '250px' });

	/* SUBSEGMENTO */
	cCdsubsegmento.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			controlaPesquisasSegmentos();
			return false;
		}
	});

	cDssubsegmento.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			controlaPesquisasSegmentos();
			return false;
		}
	});

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	$(this).fadeIn(1000);
	divRotina.centralizaRotinaH();

	return false;
}

function formataUsuario() {
  layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	$(this).fadeIn(1000);
	divRotina.centralizaRotinaH();
	return false;
}

// Controlar exibição das abas ao abrir telas filhas
function ocultaAbasCDC(){
    
    $('#tbAbasCDC').css({'display':'none'});
    return false;
}

function exibeAbasCDC(){
    
    $('#tbAbasCDC').css({'display':'block'});
    return false;
}