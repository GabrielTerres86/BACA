/*!
 * FONTE        : debban.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 09/01/2017
 * OBJETIVO     : Biblioteca de funções da tela DEBBAN
 * --------------
 * ALTERAÇÕES   : 
 *								 
 *				  
 *				
 *
 *				
 * --------------
 */
 
var cddopcao = '';

var rCddopcao, rNmrescop, rDtmvtopg,
    cCddopcao, cNmrescop, cDtmvtopg;
    
var cTparrecd_3, cTparrecd_N3, cTparrecd_1, cTparrecd_N1, cTparrecd_2, cTparrecd_N2;	
    
var frmCab = 'frmCab';

// Form Consulta
var rDscooper, rNrdocmto, rDttransa, rHrtransa, rDslindig,
    cDscooper, cNrdocmto, cDttransa, cHrtransa, cDslindig;
var frmConsulta = 'frmConsulta';


// Form Sumario
var rQtefetiv, rQtnefeti, rQtpenden, rQttotlan,
    cQtefetiv, cQtnefeti, cQtpenden, cQttotlan;
var frmSumario = 'frmSumario';


        
$(document).ready(function() {
    
    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
	rCddopcao		= $('label[for="cddopcao"]'	,'#' + frmCab); 
	rNmrescop       = $('label[for="nmrescop"]'	,'#divCooper');    
    rDtmvtopg       = $('label[for="dtmvtopg"]'	,'#' + frmCab);    
    
    cCddopcao		= $('#cddopcao'	,'#' + frmCab); 
    cNmrescop       = $('#nmrescop'	,'#divCooper');
    cDtmvtopg       = $('#dtmvtopg'	,'#' + frmCab);              
    
    // Form Consulta
    cTodosConsulta  = $('input[type="text"],select', '#' + frmConsulta);
    rDscooper       = $('label[for="dscooper"]'	,'#' + frmConsulta); 
    rNrdocmto       = $('label[for="nrdocmto"]'	,'#' + frmConsulta); 
    rDttransa       = $('label[for="dttransa"]'	,'#' + frmConsulta); 
    rHrtransa       = $('label[for="hrtransa"]'	,'#' + frmConsulta); 
    rDslindig       = $('label[for="dslindig"]'	,'#' + frmConsulta); 
    
    cDscooper       = $('#dscooper'	,'#' + frmConsulta);              
    cNrdocmto       = $('#nrdocmto'	,'#' + frmConsulta);              
    cDttransa       = $('#dttransa'	,'#' + frmConsulta);              
    cHrtransa       = $('#hrtransa'	,'#' + frmConsulta);              
    cDslindig       = $('#dslindig'	,'#' + frmConsulta);      

    // Form Sumario
    cTodosSumario   = $('input[type="text"],select', '#' + frmSumario);
    rQtefetiv       = $('label[for="qtefetiv"]'	,'#' + frmSumario);   
    rQtnefeti       = $('label[for="qtnefeti"]'	,'#' + frmSumario);   
    rQtpenden       = $('label[for="qtpenden"]'	,'#' + frmSumario);   
    rQttotlan       = $('label[for="qttotlan"]'	,'#' + frmSumario);   
    
    cQtefetiv       = $('#qtefetiv'	,'#' + frmSumario);       
    cQtnefeti       = $('#qtnefeti'	,'#' + frmSumario);      
    cQtpenden       = $('#qtpenden'	,'#' + frmSumario);      
    cQttotlan       = $('#qttotlan'	,'#' + frmSumario);          
    
    estadoInicial();

});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	//fechaRotina( $('#divRotina') );
	
    // habilita foco no formulário inicial
    highlightObjFocus($('#' + frmCab));
	
	cddopcao = "C";
    cNmrescop.val(0);
    cCddopcao.val(cddopcao);
    
    controlaLayout();
	
	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();
    $('#btnBusca', '#frmCab').trocaClass('botaoDesativado','botao').attr("onClick","LiberaCampos(); return false;");
    
	return false;
	
}

function controlaLayout() {
	
	
	$('#frmCampos').css({'display':'none'});
    $('#frmConsulta').css({'display':'none'});
    $('#frmSumario').css({'display':'none'});
    formataCabecalho();
    
	layoutPadrao();
	return false;	
}

function LiberaCampos(tipo) {

	if ($('#cddopcao', '#'+frmCab).hasClass('campoTelaSemBorda')) {
        return false;
    } 
    
    
    if ($('#cddepart', '#'+frmCab).val() != 4 && 
        $('#cddepart', '#'+frmCab).val() != 20){
        showError("error","Operacao nao autorizada.","Alerta - Ayllos","");         
        return false;
    }
        
    // Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
    $('#btnBusca', '#frmCab').trocaClass('botao','botaoDesativado').attr("onClick","return false;");
    cTodosCabecalho.desabilitaCampo();
    
    if (cCddopcao.val() == 'C' || 
       cCddopcao.val() == 'P'){
       
       carregaAgenDebBancoob();
       
    }else if (cCddopcao.val() == 'S' ){
       
       carregaSumarioAgenDeb();      
    }
    
    
    layoutPadrao();
    return false;

}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();
    
    var btnBusca			= $('#btnBusca','#' + frmCab);
	
	rCddopcao.addClass('rotulo').css({'width':'80px'});
	cCddopcao.css({'width':'380px'});
    
    rNmrescop.addClass('rotulo').css({'padding-left':'8px'});
	cNmrescop.css('width','130px');
    
    rDtmvtopg.addClass('rotulo-linha').css({'padding-left':'18px'});
    cDtmvtopg.addClass('data').css('width','80px');
    
    cTodosCabecalho.habilitaCampo(); 
    
    cDtmvtopg.desabilitaCampo();
    
    //Navegação    
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cNmrescop.focus();
			return false;
		}
	});
    
    layoutPadrao();
    return false;
}

function formataConsulta(){
    
    
    var ordemInicial = new Array();
	ordemInicial = [[0,0]];			
		
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '125px';
	arrayLargura[2] = '300px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';
           

    var divRegistro = $('.tabDebitos .divRegistros');
    var tabela = $('table', divRegistro);
    divRegistro.css('height','150px'); 
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );            
       
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {                
        
        cDscooper.val($(this).find('#dscooper').val());
        cNrdocmto.val($(this).find('#nrdocmto').val());
        cDttransa.val($(this).find('#dttransa').val());
        cHrtransa.val($(this).find('#hrtransa').val());
        cDslindig.val($(this).find('#dslindig').val());
        
    }); 
    
    
    // formata campos Consulta
    
    rDscooper.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    rNrdocmto.addClass('rotulo-linha').css({'padding-left':'115px'});       
    rDttransa.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    rHrtransa.addClass('rotulo-linha').css({'padding-left':'210px'});       
    rDslindig.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    
    cDscooper.css('width','200px');       
    cNrdocmto.css({'text-align':'right','width':'104px'});              
    cDttransa.addClass('data').css('width','80px');              
    cHrtransa.css('width','80px');              
    cDslindig.css('width','400px');              
    
    cTodosConsulta.desabilitaCampo();     
    $('#btProsseguir','#frmConsulta').css('display','none');
    
    if (cCddopcao.val() == 'P') {
      $('#btProsseguir','#frmConsulta').css('display','inline-table');  
    }
      
    
    layoutPadrao();
    
    $('#frmConsulta').css({'display':'block'});
}    

function formataSumario(){
    
    // Form Sumario
    rQtefetiv.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    rQtnefeti.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    rQtpenden.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    rQttotlan.addClass('rotulo').css({'width':'100px','padding-right':'2px'});       
    
    cQtefetiv.addClass('inteiro').css('width','100px');              
    cQtnefeti.addClass('inteiro').css('width','100px');              
    cQtpenden.addClass('inteiro').css('width','100px');              
    cQttotlan.addClass('inteiro').css('width','100px');      

    cTodosSumario.desabilitaCampo();     
    layoutPadrao();    
    
    $('#frmSumario').css({'display':'block'});
    
}


function macara_data(data){  
  
    var dt = data.val().replace('/','');
    
    if (dt.length > 4 ){
        if (dt.length == 5 ){
            dt = dt[0] + "/" + dt.substring(1,5);
        } else {
            dt = dt.substring(0,2) + '/' + dt.substring(2,6);
        }
    }
    
    data.val(dt);
    return false;
}


// Validar data
function validarData(data){   
    /*nao validar data nula */
    if (data == ''){
      return true;
    }
    
    var valido = false;
    var dia = data.split("/")[0];
    var mes = data.split("/")[1];
    var ano = data.split("/")[2];
    var MyData = new Date(ano, mes-1, dia);

    if((MyData.getMonth()+1 != mes)|| (MyData.getDate() != dia)||  (MyData.getFullYear() != ano))
        valido = false;
      else
        valido = true;
    return valido;
  }

// Função para buscar anotações do associado
function buscaAnotacoes() {
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando anota&ccedil;&otilde;es ...");
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/busca_anotacoes.php", 
		data: {
			nrdconta: nrdconta,			
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divAnotacoes').css('z-index')))");
		},
		success: function(response) {
			$("#divListaAnotacoes").html(response);
		}				
	});	
}

function carregaAgenDebBancoob() {

    var dsaguardo = '';    
    hideMsgAguardo(); 
    
    cddopcao = cCddopcao.val(); 
    cdcoptel = $('#nmrescop','#frmCab').val(); 
    dtmvtopg = cDtmvtopg.val();
    
    dsaguardo = 'Aguarde, carregando debitos agendados...';
    showMsgAguardo(dsaguardo);     
    
            
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/debban/carrega_agend_debitos.php',
        data: {
            cddopcao: cddopcao,
            cdcoptel: cdcoptel,
            dtmvtopg: dtmvtopg,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                
                if ( response.indexOf('showError("error"') == -1 ) {
                    $('.tabDebitos').html(response);
                    formataConsulta();
                    hideMsgAguardo();
                    return false;
                } else {
                    eval(response);
                }
                
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}

function carregaSumarioAgenDeb() {

    var dsaguardo = '';    
    hideMsgAguardo(); 
    
    cddopcao = cCddopcao.val(); 
    cdcoptel = $('#nmrescop','#frmCab').val(); 
    dtmvtopg = cDtmvtopg.val();
    
    dsaguardo = 'Aguarde, carregando sumario de debitos agendados...';
    showMsgAguardo(dsaguardo);     
    
            
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/debban/carrega_sumario_agendeb.php',
        data: {
            cddopcao: cddopcao,
            cdcoptel: cdcoptel,
            dtmvtopg: dtmvtopg,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                formataSumario();
                hideMsgAguardo();
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}


function confirmaProcess() {

    var dsconfir = "";

    if (cNmrescop.val() == 0){
        dsconfir = ' todas as cooperativas';
    }else{
        dsconfir = ' a cooperativa ' + $('#nmrescop option:selected').text();;
    }

    showConfirmacao('Confirma o processo de debito para' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processaAgenDeb();', 'estadoInicial();', 'sim.gif', 'nao.gif');
}

function processaAgenDeb() {

    var dsaguardo = '';    
    hideMsgAguardo(); 
    
    cddopcao = cCddopcao.val(); 
    cdcoptel = $('#nmrescop','#frmCab').val(); 
    dtmvtopg = cDtmvtopg.val();
    
    dsaguardo = 'Aguarde, processando debitos agendados...';
    showMsgAguardo(dsaguardo);     
    
            
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/debban/processa_agend_debitos.php',
        data: {
            cddopcao: cddopcao,
            cdcoptel: cdcoptel,
            dtmvtopg: dtmvtopg,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
               // formataSumario();
                hideMsgAguardo();
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}
