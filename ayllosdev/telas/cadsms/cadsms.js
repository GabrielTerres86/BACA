/*!
 * FONTE        : cadsms.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Biblioteca de funções da tela CADSMS
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

var rCddopcao, rNmrescop, 
    cCddopcao, cNmrescop, cCamposAltera;
	
var lstCooperativas = new Array();

var frmCab = 'frmCab';

$(document).ready(function() {
    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
	rCddopcao		= $('label[for="cddopcao"]'	,'#frmCab'); 
	rNmrescop       = $('label[for="nmrescop"]'	,'#divCooper');
    
    cCddopcao		= $('#cddopcao'	,'#frmCab'); 
    cNmrescop       = $('#nmrescop'	,'#divCooper');    
    
    //Opcao O
    rFlofesms		= $('label[for="flofesms"]'	,'#frmOpcaoO'); 
	rDtiniofe		= $('label[for="dtiniofe"]'	,'#frmOpcaoO'); 
    rDtfimofe		= $('label[for="dtfimofe"]'	,'#frmOpcaoO');         
    
    cFlofesms       = $('#flofesms'	,'#frmOpcaoO');
    cDtiniofe		= $('#dtiniofe'	,'#frmOpcaoO');
    cDtfimofe		= $('#dtfimofe'	,'#frmOpcaoO');
    cDsmensag		= $('#dsmensag'	,'#frmOpcaoO'); 
    
    //Opcao M
    rFllindig		= $('label[for="fllindig"]'	,'#frmOpcaoM'); 
    cFllindig       = $('#fllindig'	,'#frmOpcaoM');
    
    //Opcao P
    rNrdialau		= $('label[for="nrdialau"]'	,'#frmOpcaoP'); 
    cNrdialau       = $('#nrdialau'	,'#frmOpcaoP');
    
    estadoInicial();

});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	
    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
	
	$('#nmrescop','#frmFiltros').val(0);    
    
    cDtiniofe.val("");
    cDtiniofe.datepicker('disable');
    cDtfimofe.val("");
    cDtfimofe.datepicker('disable');
	cddopcao = "M";
    cCddopcao.val(cddopcao);
    
    controlaLayout();
	
	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();
    
	return false;
	
}

function controlaLayout() {
	
	
	cCamposAltera		= $('#nmrescop,#dtiniope,#dtfimope','#frmFiltros');    
    
	$('#frmOpcaoO').css({'display':'none'});
    $('#frmOpcaoM').css({'display':'none'});
    $('#frmOpcaoP').css({'display':'none'});
    $('#frmOpcaoZ').css({'display':'none'});
	formataCabecalho();
    
	
	layoutPadrao();
	return false;	
}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();
    
    var btnOK			= $('#btnOK','#frmCab');
	
	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'330px'});
    
    rNmrescop.css({'padding-left':'10px'});
	cNmrescop.addClass('rotulo').css('width','130px');
    
    cTodosCabecalho.habilitaCampo(); 
    return false;
}

function FormatOpcaoO(){

    $("#frmOpcaoO").css({'display':'block'});	
    rFlofesms.addClass('rotulo-linha').css({'padding-left':'5px'});	
    cFlofesms.addClass('checkbox').css({'margin':'0px'});
    
    rDtiniofe.addClass('rotulo').css({'width':'100px'});	
    rDtfimofe.addClass('rotulo-linha').css({'width':'35px','text-align': 'center','padding-left':'60px'});				
    
    cDtiniofe.addClass('campo').css({'width':'70px'}).setMask("STRING","ZZ/ZZ/ZZZZ","/","");
    cDtfimofe.addClass('campo').css({'width':'70px'}).setMask("STRING","ZZ/ZZ/ZZZZ","/","");
    
    cDsmensag.addClass('campo').css({'width':'670px','height':'98px','float':'left','margin-top':'10px', 'margin-left':'10px'});       
    cDsmensag.attr('maxlength', '4000');
    
    // Validar data ao sair do campo 
    cDtiniofe.unbind('blur').bind('blur', function() { 
      if (!validarData(cDtiniofe.val())) {
          showError("error","Data de inicio inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniofe.focus();");
          return false;
      }
     
    });
    
    /*Validar data ao sair do campo */
    cDtfimofe.unbind('blur').bind('blur', function() { 
      if (!validarData(cDtfimofe.val())) {
          showError("error","Data de fim inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");
          return false;
      }
     
    });
    
    layoutPadrao();
} 

function FormatOpcaoM(){

    $("#frmOpcaoM").css({'display':'block'});	 
    
    rFllindig.addClass('rotulo-linha').css({'padding-left':'5px'});	
    cFllindig.addClass('checkbox').css({'margin':'0px'});
    
    cTodosTextarea = $('textarea', '#frmOpcaoM');
    cTodosTextarea.addClass('campo').css({'width':'95%','height':'50px','margin':'10px'});
    //cTodosTextarea.attr('maxlength', '145');
    return false;
} 

function FormatOpcaoP(){

    $("#frmOpcaoP").css({'display':'block'});	 
    rNrdialau.addClass('rotulo').css({'padding-rigth':'5px','font-weight':'normal'});	
    cNrdialau.addClass('campo').addClass('inteiro').css({'width':'35px','text-align':'right'});
    cNrdialau.attr('maxlength', '3').setMask("INTEGER", "zz9", ".", "");
    
    cTodosTextarea = $('textarea', '#frmOpcaoP');
    cTodosTextarea.addClass('campo').css({'width':'95%','height':'100px','margin':'10px'});//.setMask("STRING","4000","*","");     
    cTodosTextarea.attr('maxlength', '4000');
    
    layoutPadrao();
    return false;
} 

function FormatOpcaoZ(){

    $("#frmOpcaoZ").css({'display':'block'});	
    
    var divRegistro = $('div.divRegistros', '#divLotes');
    var tabela = $('table', divRegistro);

    tabela.zebraTabela(0);
      
    $('#divLotes').css({'width': '80%'});
    divRegistro.css({'height':'80px'});
                        
    var ordemInicial = new Array();
              
    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '200px';
                        
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
                                
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('tbody > tr', tabela).each(function () {
        if ($(this).hasClass('corSelecao')) {
            $(this).focus();		
        }
    });    
    
    // Centralizar a div
    var larguraRotina = $("#divOpcaoZ").innerWidth();
    var larguraObjeto = $('#divLotes').innerWidth();				
    
    var left = larguraRotina - larguraObjeto;
    left = Math.floor(left / 2);
       
    $('#divLotes').css('margin-left', left.toString());
    $('#divLotes').css('margin-bottom', '10px');
       
    layoutPadrao();
    
    
}    

function LiberaCampos() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }
	
	// Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
	if ( $('#cddopcao', '#frmCab').val() == 'O' ) {
		
		$('#frmOpcaoO').css({'display': 'block'});		
		$('#divBotoes', '#frmOpcaoO').css({'display': 'block'});
        cDtiniofe.datepicker('enable');
        cDtfimofe.datepicker('enable');
        FormatOpcaoO();
        manterRotina($('#cddopcao', '#frmCab').val());
        
	}else if ( $('#cddopcao', '#frmCab').val() == 'M' ) {
        	
		$('#divBotoes', '#frmOpcaoM').css({'display': 'block'}); 
        manterRotina($('#cddopcao', '#frmCab').val());
        
        // Aguardar carregar as informaçoes para posteriormente formatar
        setTimeout(function () {
            FormatOpcaoM();
        }, 500); 
        
    }else if ( $('#cddopcao', '#frmCab').val() == 'P' ) {
        	
		$('#divBotoes', '#frmOpcaoP').css({'display': 'block'});         
        manterRotina($('#cddopcao', '#frmCab').val());
        
        // Aguardar carregar as informaçoes para posteriormente formatar
        setTimeout(function () {
            FormatOpcaoP();
        }, 500); 
	}else if ( $('#cddopcao', '#frmCab').val() == 'Z' ) {
        	
		$('#divBotoes', '#frmOpcaoZ').css({'display': 'block'});       
        $('div.divRegistros', '#divLotes').empty();
        manterRotina($('#cddopcao', '#frmCab').val());
        
        // Aguardar carregar as informaçoes para posteriormente formatar
        setTimeout(function () {
            FormatOpcaoZ();
        }, 500); 
	}      
    
    
    
	$('#divBotoes').css({'display': 'block'});

    return false;

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

function manterRotina(cdopcao) {

    var dsaguardo = '';
    var dsmensag  = '';
    var mensagens 	= [];
    var lotesReenvio = [];
    hideMsgAguardo(); 
    var cdcoptel = $('#nmrescop','#frmCab').val(); 
    
    if (cdopcao == 'GO')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var dtiniofe = cDtiniofe.val();     
        var dtfimofe = cDtfimofe.val();            
        mensagens.push({ dsmensagem: "<![CDATA["+ cDsmensag.val() + "]]>"});
        var flofesms = $('#flofesms','#frmOpcaoO').is(':checked') ? 1 : 0;
    }
    
    // Gravar opcao Manter mensagem
	if (cdopcao == 'GM')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var fllindig    = $('#fllindig','#frmOpcaoM').is(':checked') ? 1 : 0;                
        
		// Gera um objeto com o conteúdo das mensagens na tela
		$("textarea","#divMensagens").each(function() {
			
				mensagens.push({
						  cdtipo_mensagem: $(this).attr("cdtipo_mensagem"),
						  dsmensagem: $(this).val()
				});
        
		});
	}
	
    // Gravar opcao P - Cadastrar Parametro
	if (cdopcao == 'GP')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var nrdialau    = cNrdialau.val();
        
		// Gera um objeto com o conteúdo das mensagens na tela
		$("textarea","#divMensagensP").each(function() {
			
				mensagens.push({
						  cdtipo_mensagem: $(this).attr("cdtipo_mensagem"),
						  dsmensagem: "<![CDATA["+ $(this).val() + "]]>"
				});
        
		});
	}
    
    // Gravar opcao RZ - Reenviar Zendia
	if (cdopcao == 'RZ')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        
		// Gera um objeto com o conteúdo das mensagens na tela
		$("input","#divLotes").each(function() {
			
            if ($(this).is(':checked'))
			{                
				lotesReenvio.push({
						  idlote_sms: $(this).val(),
				});
			}
            
		});
        
	}
    
	//alert(JSON.stringify(mensagens));
    
        
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadsms/manter_rotina.php',
        data: {
            cddopcao: cdopcao,
            cdcoptel: cdcoptel,
            flofesms: flofesms,
            dtiniofe: dtiniofe,
            dtfimofe: dtfimofe,
            dsmensag: dsmensag,
            fllindig: fllindig,
            nrdialau: nrdialau,
		    json_mensagens	: JSON.stringify(mensagens),
            json_lotesReenv : JSON.stringify(lotesReenvio),
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);				
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}

function confirmaOpcaoO() {
    
    if (cDtiniofe.val() == ""){
        showError("error","Data de inicio do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniofe.focus();");        
        return false;
    }
    
    if (cDtfimofe.val() == "" ){
        showError("error","Data de final do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");        
        return false;
    }
    
    //Validar periodo
    var dia = cDtiniofe.val().split("/")[0];
    var mes = cDtiniofe.val().split("/")[1];
    var ano = cDtiniofe.val().split("/")[2];
    var DataIni = new Date(ano, mes-1, dia);
    
    var dia = cDtfimofe.val().split("/")[0];
    var mes = cDtfimofe.val().split("/")[1];
    var ano = cDtfimofe.val().split("/")[2];
    var DatFim = new Date(ano, mes-1, dia);
    
    if (DataIni > DatFim){
        showError("error","Data de inicio do periodo deve ser menor ou igual a data final.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");        
        return false;            
    }
    
    var dsconfir = "";
    
    if (cNmrescop.val() == 0){
        dsconfir = ', dados serão replicados para todas as cooperativas';     
    }
    
    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GO\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoM() {    
    
    var dsconfir = "";
    
    if (cNmrescop.val() == 0){
        dsconfir = ', dados serão replicados para todas as cooperativas';     
    }
    
    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GM\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoP() {    
    
    var dsconfir = "";
    
    if (cNmrescop.val() == 0){
        dsconfir = ', dados serão replicados para todas as cooperativas';     
    }
    
    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GP\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoZ() {           
    
    showConfirmacao('Confirma reenvio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'RZ\');', '', 'sim.gif', 'nao.gif');
}
/*
function ajustarCentraliCadsms() {
	var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
	x = x - 178;
	$('#divRotina').css({'width': x+'px'});
	$('#divRotina').centralizaRotinaH();
	return false;
}*/