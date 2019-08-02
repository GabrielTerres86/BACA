/*!
 * FONTE        : blqjud.js                     Última alteração: 14/03/2018
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Biblioteca de funções da tela BLQJUD
 * --------------
 * ALTERAÇÕES   : 06/09/2013 - Alterado arrayLargura[1] para 120px  na 
							   funcao layoutConsulta() (Lucas R.)
							  
				  19/12/2013 - Alterado mensagem de erro ao pesquisar associado
							   de "CPF/CGC" para "CPF/CNPJ". (Reinert)
							 
				  15/09/2014 - Ajuste em processo de desbloqueio judicial. (Jorge/Gielow - SD 175038)
				  
				  08/12/2014 - Ajustado vlsaldo pois com versoes do ie 10 ou superior nao funcionava (Lucas R. #229878)
				  
				  10/12/2014 - Criado funcao segueBotaoOK2() para melhorar o fluxo do sistema 
							   (verificar permissao do operador antes de pedir senha do coordenador). 
							   (Jorge/Rosangela) - SD 228463

                  29/07/2016 - Ajuste para controle de permissão sobre as subrotinas de cada opção
                               (Adriano - SD 492902).

                  29/09/2017 - Melhoria 460 - (Andrey Formigari - Mouts)
				  
				  16/01/2018 - Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339 - Reinert)

                  02/01/2018 - Melhoria 460 - (Diogo - Mouts) - Ajuste no valor de desbloqueio, pois sem a validação, 
                               sempre desbloqueava o valor total
				  
				  14/03/2018 - Adicionado parametro que faltava na chamada da procedure
				     		   consulta-bloqueio-jud. (Kelvin)
					
                  21/06/2019 - Tratar caracteres especias ao salvar e atualizar o bloqueio. (Wagner  - PRB0041532).					
 * --------------
 */
 
var arrbloqueios = new Array();
 
var cddopcao = '', cdoperac = '';

var rCddopcao , rNrdconta, rNroficio, rNrproces, rDsjuizem, rDsresord , rDtenvres, rVlbloque, rVlsaldo, rNmprimtl, rDtinicio, rDtafinal, rAgenctel,
	cCddopcao , cNrdconta, cNroficio, cNrproces, cDsjuizem, cDsresord , cDtenvres, cVlbloque, cVlsaldo, cNmprimtl, cDtinicio, cDtafinal, cAgenctel,
    rNrctacon , rNroficon, rCdoperac, rFllauton, rDsinfadc, rNrofides, rNrprodes, rDsjuides, rDtenvdes, rDdsinfdes, rFldestrf,
    cNrctacon , cNroficon, cCdoperac, cFllauton, cDsinfadc, cNrofides, cNrprodes, cDsjuides, cDtenvdes, cDdsinfdes, cFldestrf; 

var btnOK, btnOK2, linkConta, cCampos, cCamposAcao;

var nrdconta = 0;

var lstDadosICF;

var dtinireq, intipreq, cdbanreq, nroficon, nrctareq;

var ordemSelecao = new Array();

var flgradio = 'false';


// Variaveis para controle do checkbox e dos valores
var arrBloquear;

var seqClick    = new Array();
var vlrBloqueio = new Array();
var vlrSaldoLau = 0;
var contClick   = 0;
var contador    = 0;


$(document).ready(function() {

	estadoInicial();
		
});

// seletores
function estadoInicial() {

	$('#divOpcaoR').css({'display':'none'});	
	
	$('#divTela').fadeTo(0,0.1);

	fechaRotina( $('#divRotina') );

	cddopcao    = "";
    cdoperac    = "";
    arrBloquear = new Array();
    $('#divResultado').html("");

	controlaLayout();

	cCddopcao.val(cddopcao);

	removeOpacidade('divTela');

    controlaBotoes(0);
    
    controlaFoco();
    $('#divCab').css({'display':'block'});
	$('#cddopcao','#frmCab').habilitaCampo().focus();
	return false;

}

function controlaLayout() {

    // CAMPOS frmCab
	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab');
    cCddopcao			= $('#cddopcao'	,'#frmCab');
	btnOK				= $('#btnOK','#frmCab');
	
	// CAMPOS frmOperacao
    rCdoperac			= $('label[for="cdoperac"]'	,'#frmOperacao');
    cCdoperac           = $('#cdoperac' ,'#frmOperacao');
    btnOK2				= $('#btnOK','#frmOperacao');    

    // CAMPOS frmAssociado
    rNrdconta           = $('label[for="nrdconta"]'	,'#frmAssociado');
    cNrdconta			= $('#nrdconta'	,'#frmAssociado');
    cNmprimtl           = $('#nmprimtl' ,'#frmAssociado');
	
    // CAMPOS frmAcaojud
	rNroficio           = $('label[for="nroficio"]' ,'#frmAcaojud');
	rNrproces           = $('label[for="nrproces"]' ,'#frmAcaojud');
	rDsjuizem           = $('label[for="dsjuizem"]' ,'#frmAcaojud');
    rFllauton           = $('label[for="flblcrft"]' ,'#frmAcaojud');
	rDsresord           = $('label[for="dsresord"]' ,'#frmAcaojud');
	rDtenvres           = $('label[for="dtenvres"]' ,'#frmAcaojud');
	rVlbloque           = $('label[for="vlbloque"]' ,'#frmAcaojud');
	rDsinfadc           = $('label[for="dsinfadc"]' ,'#frmAcaojud');
    rVlsaldo            = $('label[for="vlsaldo"]' ,'#frmContas');
	
	cNroficio           = $('#nroficio' ,'#frmAcaojud');
	cNrproces           = $('#nrproces' ,'#frmAcaojud');
	cDsjuizem           = $('#dsjuizem' ,'#frmAcaojud');
    cFllauton           = $('#flblcrft' ,'#frmAcaojud');
	cDsresord           = $('#dsresord' ,'#frmAcaojud');
    cDtenvres           = $('#dtenvres' ,'#frmAcaojud');
    cVlbloque           = $('#vlbloque' ,'#frmAcaojud');
	cDsinfadc		    = $('#dsinfadc' ,'#frmAcaojud');
    cVlsaldo            = $('#vlsaldo'  ,'#frmContas');
	
	//CAMPOS DESBLOQUEIO
	rNrofides           = $('label[for="nrofides"]' ,'#frmDesbloqueio');
	rNrprodes           = $('label[for="nrprodes"]' ,'#frmDesbloqueio');
	rDsjuides           = $('label[for="dsjuides"]' ,'#frmDesbloqueio');
    rDtenvdes           = $('label[for="dtenvdes"]' ,'#frmDesbloqueio');
	rDsinfdes           = $('label[for="dsinfdes"]' ,'#frmDesbloqueio');
	rFldestrf			= $('label[for="fldestrf"]' ,'#frmDesbloqueio');
	rVldesblo           = $('label[for="vldesblo"]', '#frmDesbloqueio');
	
	cNrofides           = $('#nrofides' ,'#frmDesbloqueio');
	cNrprodes           = $('#nrprodes' ,'#frmDesbloqueio');
	cDsjuides           = $('#dsjuides' ,'#frmDesbloqueio');
    cDtenvdes           = $('#dtenvdes' ,'#frmDesbloqueio');
    cDsinfdes           = $('#dsinfdes' ,'#frmDesbloqueio');
    cVldesblo           = $('#vldesblo' ,'#frmDesbloqueio');
    cFldestrf			= $('input[id="#fldestrf"]' ,'#frmDesbloqueio');	

    // CAMPOS frmConsulta
	rNroficon           = $('label[for="nroficon"]' ,'#divConsulta');
	rNrctacon           = $('label[for="nrctacon"]' ,'#divConsulta');
	cNroficon           = $('#nroficon' ,'#divConsulta');
	cNrctacon           = $('#nrctacon' ,'#divConsulta');
	
	cCampos             = $('input' ,'#divConsulta, #frmOperacao, #frmAssociado, #frmAcaojud, #frmContas, #frmOpcaoR, #frmDesbloqueio');
    cCamposAcao         = $('#nroficio, #nrproces, #dsjuizem, #flblcrft, #dsresord, #dtenvres, #vlbloque, #dsinfadc'	,'#frmAcaojud');
	cCamposDesbloqueio  = $('#nrofides, #dtenvdes, #dsinfdes, #fldestrf', '#frmDesbloqueio');

	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao.css({'width':'430px'});

    rCdoperac.addClass('rotulo').css({'width':'60px'});
	cCdoperac.css({'width':'330px'});

	//campos cddopcao R
	rDtinicio = $('label[for="dtinicio"]', '#frmOpcaoR');
	rDtafinal = $('label[for="dtafinal"]', '#frmOpcaoR');
	rAgenctel = $('label[for="agenctel"]', '#frmOpcaoR');
	cDtinicio = $('#dtinicio', '#frmOpcaoR');
	cDtafinal = $('#dtafinal', '#frmOpcaoR');
	cAgenctel = $('#agenctel', '#frmOpcaoR');
					
    $('#divOperacao').css({'display':'none'});
    $('#divConsulta').css({'display':'none'});
	$('#divAcaojud').css({'display':'none'});
	$('#divAssociado').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});	
	$('#divRegistrosOficios').css({ 'display': 'none' });
	$('#divDesbloqueio').css({ 'display': 'none' });
	$('#div_tabblqjud').css({'display':'none'});
	
    cCampos.limpaFormulario();
    cCamposAcao.limpaFormulario();
	
	if (cddopcao == 'B' || cddopcao == 'C') {

		$('#divOperacao').css({'display':'block'});
        cCdoperac.focus();
		
        if (cdoperac == 'I' ) {
       		
			highlightObjFocus($('#frmAcaojud'));
            highlightObjFocus($('#frmAssociado'));

            rNroficio.addClass('rotulo').css({'width':'170px'});
            rNrproces.addClass('rotulo').css({'width':'170px'});
            rDsjuizem.addClass('rotulo').css({'width':'170px'});
            rDsresord.addClass('rotulo').css({'width':'170px'});
            rDtenvres.addClass('rotulo').css({'width':'170px'});
			rDsinfadc.addClass('rotulo').css({'width':'170px'});
            rVlbloque.addClass('rotulo').css({'width':'170px'});
            rVlsaldo.addClass('rotulo-linha').css({ 'width': '180px' });
			
            rVlbloque.show();
            rVlbloque.next().show();
			
            cNroficio.addClass('rotulo').css({'width':'200px'});
            cNrproces.addClass('rotulo').css({'width':'200px'});
            cDsjuizem.addClass('rotulo').css({'width':'350px'});
            cDsresord.addClass('rotulo').css({'width':'350px'});
            cDtenvres.addClass('data').css({'width':'72px'});
			cDsinfadc.addClass('rotulo').css({'width':'350px'});
            cVlbloque.addClass('monetario').css({'width':'100px'});
            cVlsaldo.addClass('monetario').addClass('descricao').css({'width':'100px'});
			
            rFllauton.addClass('rotulo-linha').css({'width':'224px'});
            cFllauton.addClass('rotulo-linha').css({'width':'22px'});
        
			rNrdconta.addClass('rotulo').css({'width':'180px'});
            cNrdconta.addClass('rotulo').css({'width':'120px'}).setMask('INTEGER','zzzzzzzzzzzzz9','','');
            cNmprimtl.addClass('descricao').css({'width':'330px'}); 
		
            cCamposAcao.habilitaCampo();
            
			cVlsaldo.val('0.00');
            cCampos.removeClass('campoErro');
            cCamposAcao.removeClass('campoErro');

            $('#divAcaojud').css({'display':'block'});

            cNroficio.focus();

        } else if (cdoperac == 'A' || cdoperac == 'C' || cdoperac == 'D') {
            highlightObjFocus($('#frmConsulta'));
			
            rNroficon.addClass('rotulo-linha').css({'width':'125px'});
            rNrctacon.addClass('rotulo-linha').css({'width':'125px'});
            cNroficon.addClass('rotulo').css({'width':'200px'});
            cNrctacon.addClass('rotulo-linha').css({ 'width': '110px' }).setMask('INTEGER', 'zzzzzzzzzzzzz9', '', '');
			
            rVlbloque.hide();
            rVlbloque.next().hide();
			
			cCampos.habilitaCampo();
			cCamposDesbloqueio.habilitaCampo();
            $('#divConsulta').css({'display':'block'});
            cNroficon.focus();
        }
	
	} else if(cddopcao == 'R') {
					
		highlightObjFocus($('#frmOpcaoR'));
		
		rAgenctel.addClass('rotulo').css({'width':'70px'});
		rDtinicio.addClass('rotulo').css({'width':'70px'});
		rDtafinal.addClass('rotulo-linha').css({'width':'20px'});
				
		cDtinicio.addClass('campo').css({'width':'85px'});	
		cDtafinal.addClass('campo').css({'width':'85px'});
		cAgenctel.addClass('campo').css({'width':'85px'}).setMask('INTEGER','zz9');	
						
		cCampos.habilitaCampo();
		$('#divOpcaoR').css({'display':'block'});	
		$('#agenctel','#frmOpcaoR').focus();
		carregaOpcaoR();  			    
		
		// Seta máscara aos campos dtinicio e dtafinal
		$("#dtinicio,#dtafinal","#frmOpcaoR").setMask("DATE","","","divRotina");
		
		$('#agenctel','#frmOpcaoR').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dtinicio','#frmOpcaoR').focus();
				return false;
			}	
		});
			
		$('#dtinicio','#frmOpcaoR').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dtafinal','#frmOpcaoR').focus();
				return false;
			}	
		});
		
		$('#dtafinal','#frmOpcaoR').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnImprimir','#divBotoes').focus();
				return false;
			}	
		});
	}	
	
	if (cddopcao == 'T') {

		$('#divOperacao').css({'display':'block'});
        cCdoperac.focus();
		
        if (cdoperac == 'I' ) {
       		
			highlightObjFocus($('#frmAcaojud'));
            highlightObjFocus($('#frmAssociado'));

            rNroficio.addClass('rotulo').css({'width':'170px'});
            rNrproces.addClass('rotulo').css({'width':'170px'});
            rDsjuizem.addClass('rotulo').css({'width':'170px'});
            rDsresord.addClass('rotulo').css({'width':'170px'});
            rDtenvres.addClass('rotulo').css({'width':'170px'});
			rDsinfadc.addClass('rotulo').css({'width':'170px'});
            rVlbloque.addClass('rotulo').css({'width':'170px'});
            rVlsaldo.addClass('rotulo-linha').css({'width':'180px'});
			
			
            cNroficio.addClass('rotulo').css({'width':'200px'});
            cNrproces.addClass('rotulo').css({'width':'200px'});
            cDsjuizem.addClass('rotulo').css({'width':'350px'});
            cDsresord.addClass('rotulo').css({'width':'350px'});
            cDtenvres.addClass('data').css({'width':'72px'});
			cDsinfadc.addClass('rotulo').css({'width':'350px'});
            cVlbloque.addClass('monetario').css({'width':'100px'});
            cVlsaldo.addClass('monetario').addClass('descricao').css({'width':'100px'});
			
            rFllauton.addClass('rotulo-linha').css({'width':'224px'});
            cFllauton.addClass('rotulo-linha').css({'width':'22px'});
        
			rNrdconta.addClass('rotulo').css({'width':'180px'});
            cNrdconta.addClass('rotulo').css({'width':'120px'}).setMask('INTEGER','zzzzzzzzzzzzz9','','');
            cNmprimtl.addClass('descricao').css({'width':'330px'}); 
		
            cCamposAcao.habilitaCampo();
            $("#vlsaldo"  ,"#frmContas").val("0.00");
            cCampos.removeClass('campoErro');
            cCamposAcao.removeClass('campoErro');

			$("#flblcrft","#frmAcaojud").desabilitaCampo();
			
			$('#vlbloque','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
				if ( e.keyCode == 9 || e.keyCode == 13 ) {	
					$('#btnContinuar','#divBotoes').focus();
					return false;
				}
			});
					
            $('#divAcaojud').css({'display':'block'});

            cNroficio.focus();

        } else if (cdoperac == 'A' || cdoperac == 'C') {
            highlightObjFocus($('#frmConsulta'));
			
            rNroficon.addClass('rotulo-linha').css({'width':'125px'});
            rNrctacon.addClass('rotulo-linha').css({'width':'125px'});
            cNroficon.addClass('rotulo').css({'width':'200px'});
            cNrctacon.addClass('rotulo-linha').css({'width':'110px'}).setMask('INTEGER','zzzzzzzzzzzzz9','','');
			
			cCampos.habilitaCampo();
            $('#divConsulta').css({'display':'block'});
            
            cNroficon.focus();
        } 
	}
	
	cCddopcao.habilitaCampo();
    cCdoperac.habilitaCampo();
	
	cCddopcao.unbind('change').bind('change', function() { 	
		cddopcao = cCddopcao.val();
		return false;

	});

	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }

		cddopcao = cCddopcao.val();
		if ( cddopcao == '' ) { return false; }

		controlaLayout();
        $('#divBotoes').css({'display':'block'});
		
		cCddopcao.desabilitaCampo();
		
		if(cddopcao == 'R') {
			controlaBotoes(4);
		}
        else {
            $('#cdoperac','#frmOperacao').focus();
			controlaBotoes(1);
        }
        		
		return false;
			
	});

	layoutPadrao();

	return false;

}
  
function controlaBotoes(seq) {

    if (seq == 0){ // Apenas Continuar
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'       ,'#divBotoes').hide();
        $('#btnContinuar'   ,'#divBotoes').show();
        $('#btnSalvar'      ,'#divBotoes').hide();
        $('#btnPesquisar'   ,'#divBotoes').hide();
        $('#btnImprimir'    ,'#divBotoes').hide();     
		$('#btnAlterar'     ,'#divBotoes').hide();		
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
    }
    else if (seq == 1){ // Voltar Continuar
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnContinuar','#divBotoes').show();

        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnImprimir' ,'#divBotoes').hide();
		$('#btnAlterar' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
    }
	else if (seq == 2){ // Voltar Pesquisar
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnPesquisar','#divBotoes').show();

        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnContinuar','#divBotoes').hide();
        $('#btnImprimir' ,'#divBotoes').hide();
		$('#btnAlterar' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
    }
    else if (seq == 3){ // Voltar Salvar
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnSalvar'   ,'#divBotoes').show();

        $('#btnContinuar','#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnImprimir' ,'#divBotoes').hide();
		$('#btnAlterar' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
    }
    else if (seq == 4){ // Voltar Imprimir
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnImprimir' ,'#divBotoes').show();

        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnContinuar','#divBotoes').hide();
		$('#btnAlterar' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
    }
	 else if (seq == 5){ // Voltar Alterar
		$('#divBotoes').css({'display':'block'});
        $('#btVoltar'   ,'#divBotoes').show();
        $('#btnAlterar' ,'#divBotoes').show();

        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnContinuar','#divBotoes').hide();
		$('#btnImprimir' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
    }
	 else if (seq == 6) { //apenas Voltar
		$('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
		
        $('#btnAlterar'  ,'#divBotoes').hide();
        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnContinuar','#divBotoes').hide();
		$('#btnImprimir' ,'#divBotoes').hide();
		$('#btnDesbloqueio' ,'#divBotoes').hide();
		
		return false;
	 }
	  else if (seq == 7) { //Voltar Desbloquear
		$('#divBotoes').css({'display':'block'});
        $('#btVoltar'       ,'#divBotoes').show();
		$('#btnDesbloqueio' ,'#divBotoes').show();
		
        $('#btnAlterar'  ,'#divBotoes').hide();
        $('#btnSalvar'   ,'#divBotoes').hide();
        $('#btnPesquisar','#divBotoes').hide();
        $('#btnContinuar','#divBotoes').hide();
		$('#btnImprimir' ,'#divBotoes').hide();
		
		return false;
	  }	    
    return false;
    
}

function controlaFoco() {
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmCab').focus();
				return false;
			}	
	});

	$('#cdoperac','#frmOperacao').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmOperacao').focus();
				return false;
			}	
	});
    
    
	$('#nroficon','#frmConsulta').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#nrctacon','#frmConsulta').focus();
				return false;
			}	
	});
	
	$('#nrctacon','#frmConsulta').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnPesquisar','#divTela').focus();				
				return false;
			}	
	});
	
	$('#nroficio','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#nrproces','#frmAcaojud').focus();
				return false;
			}	
	});

	$('#nrproces','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dsjuizem','#frmAcaojud').focus();
				return false;
			}
	});

    $('#dsjuizem','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dsresord','#frmAcaojud').focus();
				return false;
			}
	});

	$('#dsresord','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dtenvres','#frmAcaojud').focus();
				return false;
			}
	});

	$('#dtenvres','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dsinfadc','#frmAcaojud').focus();
				return false;
			}
	});

	$('#dsinfadc','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#vlbloque','#frmAcaojud').focus();
				return false;
			}
	});
	
	$('#vlbloque','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#flblcrft','#frmAcaojud').focus();
				return false;
			}
	});
	
	$('#flblcrft','#frmAcaojud').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnContinuar','#divBotoes').focus();
				return false;
			}
	});
	
	$('#nrdconta','#frmAssociado').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#divAssociado').focus();
				return false;
			}
	});	
	
	$('#nrofides','#frmDesbloqueio').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dtenvdes','#frmDesbloqueio').focus();
				return false;
			}
	});
	
	$('#dtenvdes','#frmDesbloqueio').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#dsinfdes','#frmDesbloqueio').focus();
				return false;
			}
	});
	
	$('#dsinfdes','#frmDesbloqueio').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnDesbloqueio','#divBotoes').focus();
				return false;
			}
	});
}

function consultaInicial() {
	
    // nrdconta é utilizado tanto pra CPF/CGC quanto para Conta/DV
	if ( divError.css('display') == 'block' ) { return false; }
	if( $('#nrdconta','#frmAssociado').hasClass('campoTelaSemBorda') ){ return false; }
	
	cNmprimtl.val("");
	// Armazena o número da conta/cpf na variável global e operacao
	nrdconta = normalizaNumero( $('#nrdconta','#frmAssociado').val() );
	
	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) {
        showError('error','Conta/dv ou CPF/CNPJ devem ser informados.','Alerta - BLQJUD','focaCampoErro(\'nrdconta\',\'frmAssociado\');');
        return false; 
    }

    cNrdconta.removeClass('campoErro').blur();
	cNroficio.focus();
	buscaCooperado();
}

function buscaCooperado() {
	
    cdopcao = $('#cddopcao','#frmCab').val();
    
	$('#btnOK','#frmAssociado').blur();
	
    if (cdopcao == 'T' || cdopcao == 'B') {
        cdtppesq = 4; // Transferencia e Bloqueio Normal
    } else {cdtppesq = 1;} // Bloqueio Capital

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperado e saldos modalidades ...");
	
	// Executa script de consulta através de ajax
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/blqjud/busca_cooperado.php", 
		data: {
			nrdconta: nrdconta,
            cdtppesq: cdtppesq,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
		},
		success: function(response) {
			try {
				eval(response);
				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
			}
		}				
	});

}

function preValidar() {

	var nroficio = $("#nroficio","#frmAcaojud").val();
	var nrproces = $("#nrproces","#frmAcaojud").val();
	var dsjuizem = $("#dsjuizem","#frmAcaojud").val();
	var dsresord = $("#dsresord","#frmAcaojud").val();
    var dtenvres = $("#dtenvres","#frmAcaojud").val();
    var vlbloque = $("#vlbloque","#frmAcaojud").val();
		
	if (nroficio == '') {
		showError('error','Número do Oficio não informado.','Alerta - BLQJUD','focaCampoErro(\'nroficio\',\'frmAcaojud\');');
		return false;
	}
	cNroficio.removeClass('campoErro');

	if (nrproces == '') {
		showError('error','Número do processo não informado.','Alerta - BLQJUD','focaCampoErro(\'nrproces\',\'frmAcaojud\');');
		return false;
	}	
	cNrproces.removeClass('campoErro');

	if (dsjuizem == '') {
		showError('error','Juiz Emissor não informado.','Alerta - BLQJUD','focaCampoErro(\'dsjuizem\',\'frmAcaojud\');');
		return false;
	}
	cDsjuizem.removeClass('campoErro');

	if (dsresord == '') {
		showError('error','Resumo da ordem judicial não informada.','Alerta - BLQJUD','focaCampoErro(\'dsresord\',\'frmAcaojud\');');
		return false;
	}
	cDsresord.removeClass('campoErro');

    if (dtenvres == '') {
		showError('error','Data de Envio da Resposta não informada.','Alerta - BLQJUD','focaCampoErro(\'dtenvres\',\'frmAcaojud\');');
		return false;
	}
	cDtenvres.removeClass('campoErro');

    if (vlbloque == '' || vlbloque == '0' || vlbloque == '0.00' || vlbloque == '0,00') {
		showError('error','Valor do Bloqueio/Transferência não informado.','Alerta - BLQJUD','focaCampoErro(\'vlbloque\',\'frmAcaojud\');');
		return false;
	}
	cVlbloque.removeClass('campoErro');

    cCamposAcao.desabilitaCampo();   
	
	$('#divAssociado').css({'display':'block'});
	
	cNrdconta.focus();   
}

function atualizaSaldo(chk) {
	
	var vlrBloquear = parseFloat($("#vlbloque","#frmAcaojud").val().replace('.', '').replace(',','.'));
    var vlrAntes    = parseFloat($('#vlsaldo', '#frmContas').val().replace('.', '').replace(',','.'));	
	
    var vlrClick    = 0;
    var vlbloque    = 0;
    
    if (chk.checked) {vlrClick = parseFloat(chk.value);}
    else{vlrClick = 0;}

    vlrAtual = vlrBloquear;
    
    $("input[id='chk-cta']").each(function () {           
        if (this.checked) {
            vlrAtual = vlrAtual - parseFloat($(this).val());
        }
		this.disabled = false;
    });
	
    vlrAtual    = parseFloat(vlrAtual);

    if (vlrAntes > 0) {
        if (vlrAtual <= 0) {
            vlrAtual = 0;
            vlrSaldoLau = 0;
			vlbloque = number_format(vlrAntes,2,",","");
			$("input[id='chk-cta']").each(function () {           
				if (!this.checked) {
					this.disabled = true;
				}
			});
        } else {
			vlbloque    = number_format(vlrClick,2,",","");
			vlrSaldoLau = number_format(vlrAtual,2,",","");
        }
    }else{
		vlrAntes = 0;
		if(vlrAtual <= 0){
			$("input[id='chk-cta']").each(function () {           
				if (!this.checked) {
					this.disabled = true;
				}
			});
		}
	}
	
    chkbox   = chk.name.split("-");
    cdcooper = chkbox[1];
    nrdconta = chkbox[2];
    cdmodali = chkbox[0];

    cdopcao = $('#cddopcao','#frmCab').val();
    if (cdopcao == 'T') {cdtipmov = 2;} // Transferencia
    else if (cdopcao == 'B') {cdtipmov = 1;} // Bloqueio
    else if (cdopcao == 'C') {cdtipmov = 3; }    // Bloqueio Capital

	if (vlrAtual < 0) vlrAtual = 0;
	
    vlrAtual    = number_format(vlrAtual,2,",",".");
	
    $("#vlsaldo","#frmContas").val(vlrAtual);
    
    vlresblq = 0;
    nrsequen = 0;

    vlrAntes = vlrAtual;
	
    if (chk.checked) {
        criaObjetoBloqueios(cdcooper, nrdconta, cdtipmov, cdmodali, vlbloque, vlresblq, nrsequen);
    }
    else {
        excluirRegistro(nrdconta, cdtipmov, cdmodali);
    }

    return false;

}

function layoutConsulta() {
	
    altura = '195px';
	largura = '425px';

	// Configurações da tabela
	var divRegistro = $('div.divRegistros');		
    var divRegistroOficio = $('div.divRegistrosOficios');
    var tabela = $('table', divRegistro);
    var tabelaOficio = $('table', divRegistroOficio);
    var linha = $('table > tbody > tr', divRegistro);
		
    divRegistro.css('height', '90px');
    divRegistroOficio.css('height', '90px');
		
	var ordemInicial = new Array();
    ordemInicial = [[0, 0]];
		
    var ordemInicialOficio = new Array();
    ordemInicialOficio = [[0, 0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '79px';
        arrayLargura[1] = '115px';
        arrayLargura[2] = '124px';
        arrayLargura[3] = '60px';
        arrayLargura[4] = '44px';
        arrayLargura[5] = '46px';

    var arrayLarguraOficio = new Array();
        arrayLarguraOficio[0] = '170px';
        arrayLarguraOficio[1] = '170px';
        arrayLarguraOficio[2] = '125px';
		
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';

    var arrayAlinhaOficio = new Array();
        arrayAlinhaOficio[0] = 'center';
        arrayAlinhaOficio[1] = 'center';
        arrayAlinhaOficio[2] = 'center';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    tabelaOficio.formataTabela(ordemInicialOficio, arrayLarguraOficio, arrayAlinhaOficio, '');
			
    divRotina.css('width', largura);
    $('#divRotina').css({ 'height': altura, 'width': largura });
	
	layoutPadrao();
	removeOpacidade('#divRegistros');

    $('form#frmConsultaDadosOficio .divRegistrosOficios table tbody tr:first').click();
    $('form#frmConsultaDados .divRegistros table tbody tr:first').click();

}

function executaPesquisa() {
		
	var cdoperac = $('#cdoperac' ,'#divOperacao').val();
	var cddopcao = $('#cddopcao' ,'#divCab').val();
	
	//$('#divConsulta').css({'display':'none'});
			
	if (cddopcao == 'T') {
		$('#div_tabblqjud').css({'display':'none'}); 
		$('#divDesbloqueio').css({'display':'none'});
    }
	
	highlightObjFocus($('#frmAcaojud'));
	highlightObjFocus($('#frmDesbloqueio'));
	
    rNroficio.addClass('rotulo').css({'width':'170px'});
	rNrproces.addClass('rotulo').css({'width':'170px'});
	rDsjuizem.addClass('rotulo').css({'width':'170px'});
	rDsresord.addClass('rotulo').css({'width':'170px'});
	rDtenvres.addClass('rotulo').css({'width':'170px'});
	rVlbloque.addClass('rotulo').css({'width':'170px'});        
	rFllauton.addClass('rotulo-linha').css({'width':'224px'});
    rDsinfadc.addClass('rotulo').css({'width':'170px'});
	
	cNroficio.addClass('rotulo').css({'width':'200px'}).focus();
	cNrproces.addClass('rotulo').css({'width':'200px'});
	cDsjuizem.addClass('rotulo').css({'width':'350px'});
	cDsresord.addClass('rotulo').css({'width':'350px'});
	cDtenvres.addClass('data').css({'width':'72px'});
	cVlbloque.addClass('monetario').css({'width':'100px'});
	cFllauton.addClass('rotulo').css({'width':'15px'});
	cDsinfadc.addClass('rotulo').css({'width':'350px'});
	
	rNrofides.addClass('rotulo').css({'width':'200px'});
	rDtenvdes.addClass('rotulo').css({'width':'200px'});
	rDsinfdes.addClass('rotulo').css({'width':'200px'});
	rFldestrf.addClass('rotulo').css({'width':'200px'});
		
	cNrofides.addClass('rotulo').css({'width':'200px'});
	cDtenvdes.addClass('data').css({'width':'80px'});
	cDsinfdes.addClass('rotulo').css({'width':'330px'});
	cFldestrf.addClass('rotulo').css({ 'width': '100px' });
	rVldesblo.addClass('rotulo').css({ 'width': '200px' });
		
	if ( $.browser.msie ) {	
		cFllauton.addClass('rotulo').css({'width':'18px'});			
	}
	
    nroficon = cNroficon.val();
	nrctacon = cNrctacon.val();
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, executando a pesquisa ...");

	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/blqjud/consulta_bloqueio.php", 
		data: {
			nroficon: nroficon, 
			nrctacon: nrctacon,
			operacao: cdoperac,
			cddopcao: cddopcao,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {  
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
                $('#divAcaojud').css({'display':'block'});                
				$('#div_tabblqjud').html(response);
				return false;
			} catch(error) {
				hideMsgAguardo(); 
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	
	if (cdoperac == 'A') {

		$("#vlbloque","#frmAcaojud").desabilitaCampo();
		
	//	$("#nrofides","#frmDesbloqueio").desabilitaCampo();
	//	$("#dtenvdes","#frmDesbloqueio").desabilitaCampo();
	//	$("#dsinfdes","#frmDesbloqueio").desabilitaCampo();
	//	$("#flgsim","#frmDesbloqueio").desabilitaCampo();		
	//	$("#flgnao","#frmDesbloqueio").desabilitaCampo();
		controlaBotoes(5);
		
	} else if (cdoperac == 'C' ) {
		
		$("#nroficio","#frmAcaojud").desabilitaCampo();
		$("#nrproces","#frmAcaojud").desabilitaCampo();
		$("#dsjuizem","#frmAcaojud").desabilitaCampo();
		$("#dsresord","#frmAcaojud").desabilitaCampo();
		$("#dtenvres","#frmAcaojud").desabilitaCampo();
		$("#vlbloque","#frmAcaojud").desabilitaCampo();
		$("#dsinfadc","#frmAcaojud").desabilitaCampo();
		
		$("#nrofides","#frmDesbloqueio").desabilitaCampo();
		$("#dtenvdes","#frmDesbloqueio").desabilitaCampo();
		$("#dsinfdes","#frmDesbloqueio").desabilitaCampo();
		$("#flgsim","#frmDesbloqueio").desabilitaCampo();		
		$("#flgnao", "#frmDesbloqueio").desabilitaCampo();
		$("#vldesblo", "#frmDesbloqueio").desabilitaCampo();
		controlaBotoes(4);												
				
	} else if (cdoperac == 'D' ) {
		
		$("#nroficio","#frmAcaojud").desabilitaCampo();
		$("#nrproces","#frmAcaojud").desabilitaCampo();
		$("#dsjuizem","#frmAcaojud").desabilitaCampo();
		$("#dsresord","#frmAcaojud").desabilitaCampo();
		$("#dtenvres","#frmAcaojud").desabilitaCampo();
		$("#vlbloque","#frmAcaojud").desabilitaCampo();
		$("#dsinfadc","#frmAcaojud").desabilitaCampo();		
		$("#nrofides","#frmDesbloqueio").focus();
		controlaBotoes(7);			
	}
}

function showConfirma() {

	showConfirmacao("Confirma a altera&ccedil;&atilde;o dos registros?","Confirma&ccedil;&atilde;o - Ayllos","alteraBloqueio();","","sim.gif","nao.gif");
}

function alteraBloqueio() {
	
	nroficon = cNroficon.val();
	nrctacon = cNrctacon.val();

	var nrsequen = 0;

    var nroficio = removeCaracteresInvalidos($("#nroficio","#frmAcaojud").val(),true);
	var nrproces = $("#nrproces","#frmAcaojud").val();
	var dsjuizem = removeCaracteresInvalidos($("#dsjuizem","#frmAcaojud").val(),true);
	var dsresord = removeCaracteresInvalidos($("#dsresord","#frmAcaojud").val(),true);
    var dtenvres = $("#dtenvres","#frmAcaojud").val();
	var flblcrft = $("#flblcrft","#frmAcaojud").val();
	var dsinfadc = $("#dsinfadc","#frmAcaojud").val();
	var nrofides = $("#nrofides","#frmDesbloqueio").val();
	var dtenvdes = $("#dtenvdes","#frmDesbloqueio").val();
    var dsinfdes = $("#dsinfdes","#frmDesbloqueio").val();
	
	showMsgAguardo("Aguarde, alterando dados ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/blqjud/altera_bloqueio.php", 
		data: {
		    nroficio: nroficio,
			nrproces: nrproces,
			dsjuizem: dsjuizem, 
			dsresord: dsresord, 
			dtenvres: dtenvres, 
			flblcrft: flblcrft,
			nrdconta: nrdconta,
			nroficon: nroficon, 
			nrctacon: nrctacon,
			dsinfadc: dsinfadc,
		    nrofides: nrofides,
			dtenvdes: dtenvdes,
			dsinfdes: dsinfdes,
			fldestrf: flgradio,
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

function showConfirmaInc() {

	showConfirmacao("Confirma a inclus&atilde;o dos registros?","Confirma&ccedil;&atilde;o - Ayllos","gravarBloqueio();","","sim.gif","nao.gif");
}


function gravarBloqueio() {

    if (cddopcao == "T") { tpinclusao = "Transferência"; }
    else if (cddopcao == "B") { tpinclusao = "Bloqueio"; }
    else{ tpinclusao = "Bloqueio Capital"; }

	var fields = $("input[id='chk-cta']").serializeArray(); 
	
	if (cddopcao != "T" ) {
	  
	  	if (fields.length == 0)  { 
			showError('error','Para gravar ' + tpinclusao + ', você deve selecionar alguma Modalidade!','Alerta - BLQJUD','');
			return false;
		}
	}  
	
	var nroficio = removeCaracteresInvalidos($("#nroficio","#frmAcaojud").val(),true);
	var nrproces = $("#nrproces","#frmAcaojud").val();
	var dsjuizem = removeCaracteresInvalidos($("#dsjuizem","#frmAcaojud").val(),true);
	var dsresord = removeCaracteresInvalidos($("#dsresord","#frmAcaojud").val(),true);
    var dtenvres = $("#dtenvres","#frmAcaojud").val();
    var dsinfadc = $("#dsinfadc", "#frmAcaojud").val();
    var cdoperac = $('#cdoperac', '#divOperacao').val();
    
    // Monta lista com contas a serem processadas.
	var strNrdconta = '';
	var strCdtipmov = '';
	var strCdmodali = '';
	var strVlbloque = 0;
	var strVlresblq = 0;

    var flblcrft;
	
    $("input[id='flblcrft']").each(function () {

            // Bloqueia Creditos Futuros ? Sim/Nao
           if (this.checked) {
               //flblcrft = 'true';              
               flblcrft = 1;  // Deverá passar o valor do Flag como 0 ou 1
           }
           else {
               //flblcrft = 'false';
               flblcrft = 0;
               vlrSaldoLau = 0; // Se nao bloqueia, vlr para LAUTOM é zero.
           }
    });
	
    var nrSeqAtual  = 0;
		
	if (cddopcao == 'T') {
	    strVlbloque = $("#vlbloque","#frmAcaojud").val();
		strNrdconta =  normalizaNumero($("#nrdconta","#frmAssociado").val());
		strCdtipmov = "2"; /* 2 = Transferencia */
	} else {
		for(var i=0,len=arrBloquear.length; i<len; i++){
			strNrdconta = strNrdconta + arrBloquear[i].nrdconta + ';';
			strCdtipmov = strCdtipmov + arrBloquear[i].cdtipmov + ';';
			strCdmodali = strCdmodali + arrBloquear[i].cdmodali + ';';
			strVlbloque = strVlbloque + arrBloquear[i].vlbloque + ';';
			strVlresblq = strVlresblq + normalizaNumero(arrBloquear[i].vlresblq) + ';';
			nrSeqAtual  = arrBloquear[i].nrsequen;
		}
		
		$.trim(strNrdconta);
		strNrdconta = strNrdconta.substr(0,strNrdconta.length - 1);
		$.trim(strCdmodali);
		strCdmodali = strCdmodali.substr(0,strCdmodali.length - 1);
		$.trim(strCdtipmov);
		strCdtipmov = strCdtipmov.substr(0,strCdtipmov.length - 1);
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando registro de " + tpinclusao + " ...");

	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/blqjud/incluir_bloqueio.php",
		data: {
			nroficio: nroficio,
			nrproces: nrproces,
			dsjuizem: dsjuizem,
			dsresord: dsresord,
            flblcrft: flblcrft,
            dtenvres: dtenvres,
			dsinfadc: dsinfadc,
            vlrsaldo: vlrSaldoLau,
            nrdconta: strNrdconta,
            cdtipmov: strCdtipmov,
            cdmodali: strCdmodali,
            vlbloque: strVlbloque,
            vlresblq: strVlresblq,
			cddopcao: cddopcao,
            cdoperac: cdoperac,
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

function geraImpressao() {

	var cddopcao = $('#cddopcao' ,'#divCab').val();
	
	if (cddopcao == 'R') {
		confirmaOpcaoR();
	} else {
		showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","btnImprimir();","hideMsgAguardo();","sim.gif","nao.gif");
	 }
}

function btnImprimir() {
	
	nroficon = cNroficon.val();
	nrctacon = cNrctacon.val();
	operacao = cCdoperac.val();
	cddopcao = cCddopcao.val();	
	
	$('#nroficon','#frmImpressao').val( nroficon );
	$('#nrctacon','#frmImpressao').val( nrctacon );
	$('#operacao','#frmImpressao').val( operacao );
	$('#cddopcao','#frmImpressao').val( cddopcao );
	
	var action    = UrlSite + 'telas/blqjud/imprime_bloqueio.php';	
	var callafter = "bloqueiaFundo(divRotina);hideMsgAguardo();";
	
	carregaImpressaoAyllos("frmImpressao",action,callafter);
	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="preValidar(); return false;" >'+botao+'</a>');
	}
	return false;
	
}

function btnVoltar() {

	if($('#divResultado').css('display') == 'block'){
		controlaBotoes(1);
		$('#divResultado').limpaFormulario().hide();
		$('#nrdconta','#divAssociado').habilitaCampo().focus();
	}else if($('#divAssociado').css('display') == 'block'){
		$('#divAssociado').limpaFormulario().hide();
		$('input','#divAcaojud').habilitaCampo().focus();
		if($('#cddopcao','#frmCab').val() == "T") {
			$('#nroficio','#divAcaojud').focus();
			$('#flblcrft','#divAcaojud').desabilitaCampo();
		} 
	}else if($('#divAcaojud').css('display') == 'block'){
			if($('#cdoperac','#frmOperacao').val() == "A" || $('#cdoperac','#frmOperacao').val() == "C" || $('#cdoperac','#frmOperacao').val() == "D" ){
				$('#cdoperac' ,'#frmOperacao').desabilitaCampo();
				$('#nroficon','#frmConsulta').habilitaCampo().focus();			
				$('#nrctacon','#frmConsulta').habilitaCampo();
				$('input','#divDesbloqueio').habilitaCampo().focus();
				controlaBotoes(2);
			}else if($('#cdoperac','#frmOperacao').val() == "I") 	{ 
				$('select','#divOperacao').habilitaCampo().focus();	
				controlaBotoes(1);
			}		
		$('#divAcaojud').limpaFormulario().hide();
		$('#divDesbloqueio').limpaFormulario().hide();
		$('#div_tabblqjud').hide();					
	}else if($('#divConsulta').css('display') == 'block'){   
		$('#divConsulta').limpaFormulario().hide();
		$('select','#divConsulta').habilitaCampo().focus();
		$('#cdoperac' ,'#frmOperacao').habilitaCampo();
		$('#cdoperac' ,'#frmOperacao').focus();
		
		controlaBotoes(1);
	}else{ 
		estadoInicial();
	}
	return false;
}

function btnContinuar(){
	
	if($('#divOperacao').css('display') == 'none'){ 
		if($('#divAcaojud').css('display') == 'block'){ 
			preValidar();
		}else{ 
			$('#btnOK','#frmCab').click();
		}
	}else if($('#divAcaojud').css('display') == 'none'){ 
		$('#btnOK','#frmOperacao').click();
		
	}else if($('#divAcaojud').css('display') == 'block'){ 
		if($('#divAssociado').css('display') == 'none'){
		    cNrdconta.habilitaCampo();
			preValidar();
		}else{
			$('#btnOK','#divAssociado').click();
		} 
	}
	return false;
}

function confirmaDesbloqueio() {
	
	showConfirmacao("Para realizar o desbloqueio é necessário o recebimento de ordem judicial. Deseja confirmar o desbloqueio?","Confirma&ccedil;&atilde;o - Ayllos","efetuaDesbloqueio();","hideMsgAguardo();","sim.gif","nao.gif");	
	
}

function efetuaDesbloqueio() {
	
	nroficon = cNroficon.val();
	nrctacon = cNrctacon.val();

	var nrsequen = 0;
	var cdtipmov = 0;

	$('input','#frmDesbloqueio').removeClass('campoErro');
	
	var nroficio = $("#nroficio","#frmAcaojud").val();
	var nrproces = $("#nrproces","#frmAcaojud").val();
	var dsjuizem = $("#dsjuizem","#frmAcaojud").val();
	var dsresord = $("#dsresord","#frmAcaojud").val();
    var dtenvres = $("#dtenvres","#frmAcaojud").val();
	var vlbloque = $("#vlbloque","#frmAcaojud").val();
	var flblcrft = $("#flblcrft","#frmAcaojud").val();
	var dsinfadc = $("#dsinfadc","#frmAcaojud").val();
	var cdmodali = $("#cdmodali","#frmAcaojud").val();
	
	var nrofides = $("#nrofides","#frmDesbloqueio").val();
	var dtenvdes = $("#dtenvdes","#frmDesbloqueio").val();
	var dsinfdes = $("#dsinfdes", "#frmDesbloqueio").val();
	var vldesblo = converteMoedaFloat($("#vldesblo", "#frmDesbloqueio").val());
	var vltmpbloque = converteMoedaFloat($("#vltmpbloque", "#frmDesbloqueio").val());

    // cpf pode ter mais de uma conta, por isso, pegar a conta selecionada
	nrdconta = normalizaNumero($('#frmConsultaDados .divRegistros tr.corSelecao td:first span').text());

	var fldestrf = 0;

	if (flgradio == 'true') {
	    fldestrf = 1;
	} else {
	    fldestrf = 0;
	}

	
	if (nrofides == '') {
		showError('error','Número do Ofício de Desbloqueio não informado.','Alerta - BLQJUD','focaCampoErro(\'nrofides\',\'frmDesbloqueio\');');
		return false;
	}
	cNrofides.removeClass('campoErro');
	
	if (dtenvdes == '') {
		showError('error','Data de Envio Resposta de Desbloqueio não informado.','Alerta - BLQJUD','focaCampoErro(\'dtenvdes\',\'frmDesbloqueio\');');
		return false;
	}
	cDtenvdes.removeClass('campoErro');
	
	if (dsinfdes == '') {
		showError('error','Informação adicional de Desbloqueio não informado.','Alerta - BLQJUD','focaCampoErro(\'dsinfdes\',\'frmDesbloqueio\');');
		return false;
	}
	cDsinfdes.removeClass('campoErro');
		
	if (vldesblo == '' || vldesblo == '0' || vldesblo == '0.00' || vldesblo == '0,00' || vldesblo <= 0) {
		showError('error','Valor do Desbloqueio não informado.','Alerta - BLQJUD','focaCampoErro(\'vldesblo\',\'frmDesbloqueio\');');
		return false;
	}
	
	if (vldesblo > vltmpbloque) {
		showError('error','Valor do Desbloqueio está limitado ao valor bloqueado ('+$("#vltmpbloque", "#frmDesbloqueio").val()+').','Alerta - BLQJUD','focaCampoErro(\'vldesblo\',\'frmDesbloqueio\');');
		return false;
	}
	cVldesblo.removeClass('campoErro');

	showMsgAguardo("Aguarde, efetuando opera&ccedil;&atilde;o ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/blqjud/efetua_desbloqueio.php", 
		data: {
		    nroficio: nroficio,
			nrproces: nrproces,
			dsjuizem: dsjuizem, 
			dsresord: dsresord, 
			dtenvres: dtenvres, 
			vlbloque: vlbloque, 
			flblcrft: flblcrft,
			nrdconta: nrdconta,
			nroficon: nroficon, 
			nrctacon: nrctacon,
			dsinfadc: dsinfadc,
			nrofides: nrofides,
			dtenvdes: dtenvdes,
			dsinfdes: dsinfdes,
			fldestrf: fldestrf,
			vldesblo: vldesblo,
			cdmodali: cdmodali,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) { 
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
				$('#btnDesbloqueio','#divBotoes').hide();		
				eval(response);
			}
		
	});
}

function validaConsulta() {
	
	nroficon = cNroficon.val();
	nrctacon = cNrctacon.val();
	cdoperac = cCdoperac.val();
	
	if (nroficon == '' && (cdoperac == 'A')) {
		showError('error','Número de Ofício não informado.','Alerta - BLQJUD','focaCampoErro(\'nroficon\',\'frmConsulta\');');
		return false;
	}
	cNroficon.removeClass('campoErro');
	
	if (nrctacon == 0) {
		showError('error','Número Conta/CPF não informado.','Alerta - BLQJUD','focaCampoErro(\'nrctacon\',\'frmConsulta\');');
		return false;
	}
	cNrctacon.removeClass('campoErro');
	
	executaPesquisa();
}

function bloqueios(cdcooper, nrdconta, cdtipmov, cdmodali, vlbloque, vlresblq, nrsequen ) {

    this.cdcooper=cdcooper;
	this.nrdconta=nrdconta;
    this.cdtipmov=cdtipmov;
	this.cdmodali=cdmodali;
	this.vlbloque=vlbloque;
    this.vlresblq=vlresblq;
	this.nrsequen=nrsequen;
}

function criaObjetoBloqueios(cdcooper, nrdconta, cdtipmov, cdmodali, vlbloque, vlresblq, nrsequen){
	var objBloqueios = new bloqueios(cdcooper, nrdconta, cdtipmov, cdmodali, vlbloque, vlresblq, nrsequen);
	arrBloquear.push( objBloqueios );
	
}

function excluirRegistro(nrdconta, cdtipmov, cdmodali) {
	
	arrBloquear.length = 0;
	
	$("input[id='chk-cta']").each(function () { 
		
        if (this.checked) {
			chkbox   = this.name.split("-");
			cdcooper = chkbox[1];
			nrdconta = chkbox[2];
			cdmodali = chkbox[0];
			vlbloque = number_format(this.value,2,",","");
			vlresblq = 0;
			nrsequen = 0;
			criaObjetoBloqueios(cdcooper, nrdconta, cdtipmov, cdmodali, vlbloque, vlresblq, nrsequen);
        }
		
    });
	return false;
	
}

// senha
function mostraSenha() {

	showMsgAguardo('Aguarde, abrindo ...');
	
	cddopcao = cCddopcao.val();
    var cdoperac = cCdoperac.val();
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/blqjud/senha.php', 
		data: {
			cddopcao: cddopcao,
            cdoperac: cdoperac,
			redirect: 'html_ajax'
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			return false;
		}				
	});
	
	return false;
	
}

function buscaSenha() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');
	
	cddopcao = cCddopcao.val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/blqjud/form_senha.php', 
		data: {
			cddopcao: cddopcao,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenha();
					$('#codsenha','#frmSenha').unbind('keydown').bind('keydown', function(e) { 	
						if ( divError.css('display') == 'block' ) { return false; }		
						// Se é a tecla ENTER, 
						if ( e.keyCode == 13 ) {
							validarSenha();
							return false;			
						} 
					});
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	
	return false;
}

function formataSenha() {

	highlightObjFocus($('#frmSenha'));

	rOperador 	= $('label[for="operauto"]', '#frmSenha');
	rSenha		= $('label[for="codsenha"]', '#frmSenha');	
	
	rOperador.addClass('rotulo').css({'width':'165px'});
	rSenha.addClass('rotulo').css({'width':'165px'});

	cOperador	= $('#operauto', '#frmSenha');
	cSenha		= $('#codsenha', '#frmSenha');
	
	cOperador.addClass('campo').css({'width':'100px'}).attr('maxlength','10');		
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','30');		
	
	$('#divConteudoSenha').css({'width':'400px', 'height':'120px'});	

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});	
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	cOperador.focus();
	
	return false;
}

function validarSenha() {
		
	hideMsgAguardo();		
	
	// Situacao
	operauto 		= $('#operauto','#frmSenha').val();
	var codsenha 	= $('#codsenha','#frmSenha').val();

	cddopcao = cCddopcao.val();
	
	showMsgAguardo( 'Aguarde, validando dados ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/blqjud/valida_senha.php', 		
			data: {
				operauto	: operauto,
				codsenha	: codsenha,
				cddopcao    : cddopcao,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		});	
		
	return false;	
	
}

function botaoOK2() {

	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cCdoperac.hasClass('campoTelaSemBorda') ) { return false; }
	
	cdoperac = cCdoperac.val();
	cddopcao = cCddopcao.val();
	if ( cddopcao == '' ) { return false; };
	
	if(cddopcao == 'C' && (cdoperac == "A" || cdoperac == "I" || cdoperac == "D")){
		mostraSenha();
	}else{
		segueBotaoOK2();
	}
}

function segueBotaoOK2(){

	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cCdoperac.hasClass('campoTelaSemBorda') ) { return false; }
	
	cdoperac = cCdoperac.val();
	cddopcao = cCddopcao.val();
	if ( cddopcao == '' ) { return false; };
	
	controlaLayout();
			
	cCddopcao.desabilitaCampo();
	cCdoperac.desabilitaCampo();
	
	$('#nroficon','#divConsulta').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrctacon','#divConsulta').focus();
			return false;
		}	
	});
	
	$('#nrctacon','#divConsulta').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnPesquisar','#divBotoes').focus();				
				return false;
			}	
	});
	
	if (cddopcao == 'B' || cddopcao == 'C') {
		if (cdoperac == 'A' || cdoperac == 'C' || cdoperac == 'D') {
				
			 $('#nroficon','#frmConsulta').habilitaCampo();
			 $('#nrctacon','#frmConsulta').habilitaCampo();
			 $('#divConsulta').css({'display':'block'});
			 controlaBotoes(2);
			 controlaFoco();
			 $('#nroficon','#divConsulta').focus();			 		
		} else {
			$('#nroficio','#frmAcaojud').focus();
			controlaBotoes(1);
		}
	} else if (cddopcao == 'T') {
		if (cdoperac == 'D') {
			cCdoperac.habilitaCampo();
			showError('error','Operação inválida para a opção T - Transferência.','Alerta - BLQJUD','focaCampoErro(\'cdoperac\',\'frmOperacao\');');
			return false;

			cCdoperac.removeClass('campoErro');					
		} else if (cdoperac == 'A' || cdoperac == 'C') {
			 $('#nroficon','#frmConsulta').habilitaCampo();
			 $('#nrctacon','#frmConsulta').habilitaCampo();
			 $('#divConsulta').css({'display':'block'});
			 controlaBotoes(2);
			 controlaFoco();
			 $('#nroficon','#divConsulta').focus(); 
		} else { 
			$('#nroficio','#frmAcaojud').focus();
			controlaBotoes(1);
		}
		
	}
	
	return false;
	
}

function carregaOpcaoR() {
	
	var msg = ", carregando op&ccedil;&atilde;o impress&atilde;o.";
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde" + msg + " ...");
			
	// Carrega conteúdo da opção através de ajax
		$.ajax({		
			type    : "POST",
			dataType: "html",
			url     : UrlSite + 'telas/blqjud/form_impressao.php',
			data: {					
				redirect: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {				
				hideMsgAguardo();
				eval(response);				
				return false;
			}				
		}); 
		
}

function confirmaOpcaoR() {

	showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","imprimirOpcaoR();","hideMsgAguardo();","sim.gif","nao.gif");
	
}	

function imprimirOpcaoR() {

	var dtinicio = cDtinicio.val();
	var dtafinal = cDtafinal.val();
	var agenctel = cAgenctel.val();
	
	// Valida data inicial
	if ($.trim(dtinicio) == "" || !validaData(dtinicio)) {
		hideMsgAguardo();
		showError("erro","Data inicial inv&aacute;lida.","Alerta - Ayllos","$('#dtinicio','#frmOpcaoR').focus()");
		$("#dtinicio","#frmOpcaoR").val("");
		return false;
	}
	
	// Valida data final
	if ($.trim(dtafinal) == "" || !validaData(dtafinal)) {
		hideMsgAguardo();
		showError("erro","Data final inv&aacute;lida.","Alerta - Ayllos","$('#dtafinal','#frmOpcaoR').focus()");
		$("#dtafinal","#frmOpcaoR").val("");
		return false;
	}
	
	var action    = UrlSite + 'telas/blqjud/gera_impressao.php';	
	var callafter = "bloqueiaFundo(divRotina);hideMsgAguardo();";
	
	$('#sidlogin','#frmOpcaoR').remove();
	
	$('#frmOpcaoR').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	
	carregaImpressaoAyllos("frmOpcaoR",action,callafter);
	return false;
	
}

function check(){
	flgradio = 'true';
}

function uncheck(){
	flgradio = 'false';
}

function selecionaOficio(oficio, conta) {
    $('form#frmConsultaDados div.divRegistros table tr.tr_oficio').hide();
    $('form#frmConsultaDados div.divRegistros table tr.ofi_' + oficio + "_" + conta).css('display', 'table-row');
    $('form#frmConsultaDados div.divRegistros table tr.ofi_' + oficio + "_" + conta).first().click();
}

function selecionaBloqueio(seq, cdmodali) {
    $('#divDesbloqueio').css({ 'display': 'block' });
    if (arrbloqueios[seq]['flblcrft'] == "yes") {
		$('#flblcrft','#frmAcaojud').val(arrbloqueios[seq]['flblcrft']).attr('disabled','true').attr('checked','true');
	}else{
		$('#flblcrft','#frmAcaojud').val(arrbloqueios[seq]['flblcrft']).attr('disabled','true');
	}
	$('#nroficio','#frmAcaojud').val(arrbloqueios[seq]['nroficio']);
    $('#nrproces','#frmAcaojud').val(arrbloqueios[seq]['nrproces']);
    $('#dsjuizem','#frmAcaojud').val(arrbloqueios[seq]['dsjuizem']);
    $('#dsresord','#frmAcaojud').val(arrbloqueios[seq]['dsresord']);
    $('#dtenvres','#frmAcaojud').val(arrbloqueios[seq]['dtenvres']);
    $('#vlbloque','#frmAcaojud').val(arrbloqueios[seq]['vltotblq']);
    $('#dsinfadc','#frmAcaojud').val(arrbloqueios[seq]['dsinfadc']);	
    
    $('#nrofides','#frmDesbloqueio').val(arrbloqueios[seq]['nrofides']);
    $('#dtenvdes','#frmDesbloqueio').val(arrbloqueios[seq]['dtenvdes']);
    $('#dsinfdes','#frmDesbloqueio').val(arrbloqueios[seq]['dsinfdes']);
	$('#cdmodali','#frmAcaojud').val(cdmodali);
	
    if (arrbloqueios[seq]['fldestrf'] == "yes") {
        $('#flgsim', '#frmDesbloqueio').prop('checked', 'true');
        $('legend', '#frmDesbloqueio').html("Dados Judiciais - Ofício Transferência");
    } else {
        $('#flgnao', '#frmDesbloqueio').prop('checked', 'true');
        $('legend', '#frmDesbloqueio').html("Dados Judiciais - Ofício Desbloqueio");
	}
	
	if(cCddopcao.val() == "T"){
		$('#divDesbloqueio').css({'display':'none'});
	}else if (arrbloqueios[seq]['dtblqfim'] != "" || cCdoperac.val() == "A" || cCdoperac.val() == "C" || cCdoperac.val() == "D") {
		$('#vldesblo','#frmDesbloqueio').val('');//valor bloqueio, preencho o máximo
		$('#vltmpbloque','#frmDesbloqueio').val(''); //campo para controle e validação do valor
		if((($('#div_tabblqjud').css('display') == "block") && (arrbloqueios[seq]['dtblqfim'] != "" || cCdoperac.val() == "D"))){
			$('#divDesbloqueio').css({'display':'block'});
			$('#vldesblo','#frmDesbloqueio').val(arrbloqueios[seq]['vlbloque']);//valor bloqueio, preencho o máximo
			$('#vltmpbloque','#frmDesbloqueio').val(arrbloqueios[seq]['vlbloque']); //campo para controle e validação do valor
		}
	}
	
	if (arrbloqueios[seq]['dtblqfim'] != ""){
		$("#nroficio","#frmAcaojud").desabilitaCampo();
		$("#nrproces","#frmAcaojud").desabilitaCampo();
		$("#dsjuizem","#frmAcaojud").desabilitaCampo();
		$("#dsresord","#frmAcaojud").desabilitaCampo();
		$("#dtenvres","#frmAcaojud").desabilitaCampo();
		$("#vlbloque","#frmAcaojud").desabilitaCampo();
		$("#dsinfadc","#frmAcaojud").desabilitaCampo();
		
		$("#nrofides","#frmDesbloqueio").desabilitaCampo();
		$("#dtenvdes","#frmDesbloqueio").desabilitaCampo();
		$("#dsinfdes","#frmDesbloqueio").desabilitaCampo();
		$("#flgsim","#frmDesbloqueio").desabilitaCampo();		
		$("#flgnao","#frmDesbloqueio").desabilitaCampo();	
		controlaBotoes(4);
	}
	
	return false;
}
