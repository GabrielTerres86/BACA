/*********************************************************************************************
 Fonte: cadseg.js                                       			                   
 Autor: Cristian Filipe                                                                
 Data : Novembro/2013                                                                  
 Alterações:                                          Ultima Alteracao: 26/05/2017
 																					
 23/01/2014 - Ajustes gerais para liberacao. (Jorge)	
 
 26/05/2017 - Alteracao no contrato conforme solicitado no chamado 655583. (Kelvin)

*********************************************************************************************/

// Definição de algumas variáveis globais 
var cddopcao, cTodosCabecalho;
//Formulário Cabeçalhho
var frmCab   		= 'frmCab';
// Verifica se ja fez a solicitação inicial
var escolheOpcao;

$(document).ready(function(){
       
    estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	

	return false;
    
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	escolheOpcao = false;
	$('#frmInfSeguradora').css({'display':'none'});
	$('#frmInfHistorico').css({'display':'none'});
	
	trocaBotao('Prosseguir');
	$('#divBotoes', '#divTela').css({'display':'none'});
	
	
	formataCabecalho();
	
	// Remover class campoErro
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmInfSeguradora').removeClass('campoErro');
	$('input,select', '#frmInfHistorico').removeClass('campoErro');
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	controlaFoco();
	controlaPesquisas();
	
	
	$('#cddopcao','#frmCab').habilitaCampo();
	$('#cddopcao','#frmCab').focus();
	
	return false;
}

function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	//Ajusta layout para o Internet Explorer
	if ( $.browser.msie ) {
		rCddopcao.css('width','40px');
	}else {
		rCddopcao.css('width','44px');
	}
	
	cCddopcao.css({'width':'460px'});
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();

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
	
	var cTodosFormSeguradora;
	var cTodosFormHistorico;
	
	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	
	
	// Desabilita campo opção
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	cddopcao = cCddopcao.val();
	
	$('input,select', '#frmInfSeguradora').removeClass('campoErro');
	$('input,select', '#frmInfHistorico').removeClass('campoErro');
	
	formataSeguradoras();
	
	cTodosFormSeguradora = $('input[type="text"],select,input[type="checkbox"]','#frmInfSeguradora'); 
	cTodosFormSeguradora.desabilitaCampo();
	cTodosFormSeguradora.limpaFormulario();
	
	cTodosFormHistorico = $('input[type="text"],select,input[type="checkbox"]','#frmInfHistorico'); 
	cTodosFormHistorico.desabilitaCampo();
	cTodosFormHistorico.limpaFormulario();		


    layoutPadrao();
	
	controlaOperacao();
	
	return false;

}
function controlaOperacao() {
		
	var cTodosFormSeguradora = $('input[type="text"],select,input[type="checkbox"]','#frmInfSeguradora'); 
	var cTodosFormHistorico  = $('input[type="text"],select,input[type="checkbox"]','#frmInfHistorico'); 
	var cCdsegura  = $('#cdsegura','#frmInfSeguradora');
	var cCdhstaut1 = $('#cdhstaut1');
	
	//controle inicial
	if(escolheOpcao == false){
		controlaFocoFormulariosSeguradora(cddopcao); // chamando desta forma aparecera o formulario para inclusão
		hideMsgAguardo();
		
		escolheOpcao = true;
		return false;
		
	}else {
		//se campo estiver habilitado para digitar... busca seguradora
		if(!cCdsegura.hasClass('campoTelaSemBorda'))
		{	
			mostraRotina('busca_seguradora');
			return false;
		}
		switch(cddopcao)
		{
			case "A": trocaBotao('Alterar'); break;
			case "I": trocaBotao('Incluir'); break;
			case "E": trocaBotao('Excluir'); break;
			case "C": trocaBotao('Prosseguir'); break;
		}
		
		if(cddopcao == "C")
		{
			estadoInicial();
			return false;
		}else{
			showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","manterRotina();","showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','estadoInicial()');","sim.gif","nao.gif");	
			return false;
		}
		
		if ((cddopcao == "A") || (cddopcao == "C" )|| (cddopcao == "E")) {
				mostraRotina('lista_seguradora');
				return false;
		} else if (cddopcao == "I"){
			controlaFocoFormulariosSeguradora('I');
			return false;
		} else if (cddopcao == "E"){
			return false;
		}
	}
} 

function controlaFocoFormulariosSeguradora(param)
{
	var cTodosFormSeguradora = $('input[type="text"],select,input[type="checkbox"]','#frmInfSeguradora'); 
	var cTodosFormHistorico  = $('input[type="text"],select,input[type="checkbox"]','#frmInfHistorico'); 
	
	var cCdsegura  = $('#cdsegura');
	var cNmsegura  = $('#nmsegura');
	var cFlgativo  = $('#flgativo');
	var cNmresseg  = $('#nmresseg');
	var cNrcgcseg  = $('#nrcgcseg');
	var cNrctrato  = $('#nrctrato');
    var cNrultpra  = $('#nrultpra');
    var cNrlimpra  = $('#nrlimpra');
    var cNrultprc  = $('#nrultprc');
    var cNrlimprc  = $('#nrlimprc');
    var cDsasauto  = $('#dsasauto');
	
	var cCdhstaut1   = $('#cdhstaut1');
	var cCdhstaut2   = $('#cdhstaut2');
	var cCdhstaut3   = $('#cdhstaut3');
	var cCdhstaut4   = $('#cdhstaut4');
	var cCdhstaut5   = $('#cdhstaut5');
	var cCdhstaut6   = $('#cdhstaut6');
	var cCdhstaut7   = $('#cdhstaut7');
	var cCdhstaut8   = $('#cdhstaut8');
	var cCdhstaut9   = $('#cdhstaut9');
	var cCdhstaut10  = $('#cdhstaut10');
	var cCdhstcas1   = $('#cdhstcas1');
	var cCdhstcas2   = $('#cdhstcas2');
	var cCdhstcas3   = $('#cdhstcas3');
	var cCdhstcas4   = $('#cdhstcas4');
	var cCdhstcas5   = $('#cdhstcas5');
	var cCdhstcas6   = $('#cdhstcas6');
	var cCdhstcas7   = $('#cdhstcas7');
	var cCdhstcas8   = $('#cdhstcas8');
	var cCdhstcas9   = $('#cdhstcas9');
	var cCdhstcas10  = $('#cdhstcas10');
	var cDsmsgseg    = $('#dsmsgseg');
	
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	$('#frmInfSeguradora').css({'display':'block'});
	$('#frmInfHistorico').css({'display':'block'});
	
	cCdsegura.focus().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			controlaOperacao();
			return false;
		}	
	});	
	
	if(cCdsegura.prop("disabled") ==  true){
		cCdsegura.habilitaCampo().focus();
	}else{
		cTodosFormSeguradora.habilitaCampo();
		cTodosFormHistorico.habilitaCampo();		
		cCdsegura.desabilitaCampo();
	}
	
	if(cddopcao == "I"){
		cNmsegura.focus();
	}
	
	/*Primeira tela*/	
	cNmsegura.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmresseg.focus();
			return false;
		}	
	});		
	cNmresseg.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cFlgativo.focus();
			return false;
		}	
	});		
	cFlgativo.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrcgcseg.focus();
			return false;
		}	
	});			
	cNrcgcseg.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrctrato.focus();
			return false;
		}	
	});				
	cNrctrato.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrultpra.focus();
			return false;
		}	
	});				
	cNrultpra.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrlimpra.focus();
			return false;
		}	
	});						
	cNrlimpra.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrultprc.focus();
			return false;
		}	
	});						
	cNrultprc.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrlimprc.focus();
			return false;
		}	
	});							
	cNrlimprc.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsasauto.focus();
			return false;
		}	
	});								
	cDsasauto.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut1.focus();
			return false;
		}	
	});			
	/*Primeira tela*/
	/*Segunda Tela*/
	cCdhstaut1.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut2.focus();
			return false;
		}	
	});	
	cCdhstaut2.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut3.focus();
			return false;
		}	
	});	
	cCdhstaut3.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut4.focus();
			return false;
		}	
	});		
	cCdhstaut4.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut5.focus();
			return false;
		}	
	});		
	cCdhstaut5.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut6.focus();
			return false;
		}	
	});		
	cCdhstaut6.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut7.focus();
			return false;
		}	
	});
	cCdhstaut7.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut8.focus();
			return false;
		}	
	});	
	cCdhstaut8.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut9.focus();
			return false;
		}	
	});	
	cCdhstaut9.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstaut10.focus();
			return false;
		}	
	});	
	cCdhstaut10.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas1.focus();
			return false;
		}	
	});		
	cCdhstcas1.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas2.focus();
			return false;
		}	
	});			
	cCdhstcas2.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas3.focus();
			return false;
		}	
	});			
	cCdhstcas3.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas4.focus();
			return false;
		}	
	});			
	cCdhstcas4.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas5.focus();
			return false;
		}	
	});				
	cCdhstcas5.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas6.focus();
			return false;
		}	
	});				
	cCdhstcas6.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas7.focus();
			return false;
		}	
	});					
	cCdhstcas7.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas8.focus();
			return false;
		}	
	});					
	cCdhstcas8.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas9.focus();
			return false;
		}	
	});					
	cCdhstcas9.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdhstcas10.focus();
			return false;
		}	
	});						
	cCdhstcas10.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsmsgseg.focus();
			return false;
		}	
	});							
	cDsmsgseg.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			controlaOperacao();
			return false;
		}	
	});		
	/*Segunda Tela*/
	
}
function manterRotina() {

	var cCdsegura  = $('#cdsegura');
	var cNmsegura  = $('#nmsegura');
	var cFlgativo  = $('#flgativo');
	var cNmresseg  = $('#nmresseg');
	var cNrcgcseg  = $('#nrcgcseg');
	var cNrctrato  = $('#nrctrato');
    var cNrultpra  = $('#nrultpra');
    var cNrlimpra  = $('#nrlimpra');
    var cNrultprc  = $('#nrultprc');
    var cNrlimprc  = $('#nrlimprc');
    var cDsasauto  = $('#dsasauto');
	
	var cCdhstaut1   = $('#cdhstaut1');
	var cCdhstaut2   = $('#cdhstaut2');
	var cCdhstaut3   = $('#cdhstaut3');
	var cCdhstaut4   = $('#cdhstaut4');
	var cCdhstaut5   = $('#cdhstaut5');
	var cCdhstaut6   = $('#cdhstaut6');
	var cCdhstaut7   = $('#cdhstaut7');
	var cCdhstaut8   = $('#cdhstaut8');
	var cCdhstaut9   = $('#cdhstaut9');
	var cCdhstaut10  = $('#cdhstaut10');
	var cCdhstcas1   = $('#cdhstcas1');
	var cCdhstcas2   = $('#cdhstcas2');
	var cCdhstcas3   = $('#cdhstcas3');
	var cCdhstcas4   = $('#cdhstcas4');
	var cCdhstcas5   = $('#cdhstcas5');
	var cCdhstcas6   = $('#cdhstcas6');
	var cCdhstcas7   = $('#cdhstcas7');
	var cCdhstcas8   = $('#cdhstcas8');
	var cCdhstcas9   = $('#cdhstcas9');
	var cCdhstcas10  = $('#cdhstcas10');
	var cDsmsgseg    = $('#dsmsgseg');
	
	if(cFlgativo.is(':checked'))
	{
		cFlgativo.val('yes');
	}else{
		cFlgativo.val('no');
	}
	
	// Remover class campoErro
	$('input,select', '#frmInfSeguradora').removeClass('campoErro');
	
    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadseg/manter_rotina.php', 
        data: {
            cddopcao: cddopcao,
            cdsegura: normalizaNumero(cCdsegura.val()),
            nmsegura: cNmsegura.val().toUpperCase(),
            nmresseg: cNmresseg.val().toUpperCase(),
            flgativo: cFlgativo.val(),
            nrcgcseg: normalizaNumero(cNrcgcseg.val()),
            nrctrato: normalizaNumero(cNrctrato.val()),
            nrultpra: normalizaNumero(cNrultpra.val()),
            nrlimpra: normalizaNumero(cNrlimpra.val()),
            nrultprc: normalizaNumero(cNrultprc.val()),
            nrlimprc: normalizaNumero(cNrlimprc.val()),
            dsasauto: cDsasauto.val().toUpperCase(),

            cdhstaut1:  normalizaNumero(cCdhstaut1.val()),
            cdhstaut2:  normalizaNumero(cCdhstaut2.val()),
            cdhstaut3:  normalizaNumero(cCdhstaut3.val()),
            cdhstaut4:  normalizaNumero(cCdhstaut4.val()),
            cdhstaut5:  normalizaNumero(cCdhstaut5.val()),
            cdhstaut6:  normalizaNumero(cCdhstaut6.val()),
            cdhstaut7:  normalizaNumero(cCdhstaut7.val()),
            cdhstaut8:  normalizaNumero(cCdhstaut8.val()),
            cdhstaut9:  normalizaNumero(cCdhstaut9.val()),
            cdhstaut10: normalizaNumero(cCdhstaut10.val()),
            cdhstcas1:  normalizaNumero(cCdhstcas1.val()),
            cdhstcas2:  normalizaNumero(cCdhstcas2.val()),
            cdhstcas3:  normalizaNumero(cCdhstcas3.val()),
            cdhstcas4:  normalizaNumero(cCdhstcas4.val()),
            cdhstcas5:  normalizaNumero(cCdhstcas5.val()),
            cdhstcas6:  normalizaNumero(cCdhstcas6.val()),
            cdhstcas7:  normalizaNumero(cCdhstcas7.val()),
            cdhstcas8:  normalizaNumero(cCdhstcas8.val()),
            cdhstcas9:  normalizaNumero(cCdhstcas9.val()),
            cdhstcas10: normalizaNumero(cCdhstcas10.val()),
            dsmsgseg:   cDsmsgseg.val().toUpperCase(),
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == - 1 && response.indexOf('XML error:') == - 1 && response.indexOf('#frmErro') == - 1) {
                try {
					eval(response);
                } catch(error) {
                        hideMsgAguardo();
                        showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }else {
                try {
						eval(response);
					} catch (error) {
						hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                    }
                } 
        }
    });
return false;
}



//função para diversas requisições passando apenas no nome do arquivo e os dados
function mostraRotina(pagina) {

	var cCdsegura  = $('#cdsegura');
	var cdsegura = normalizaNumero(cCdsegura.val());
	
	if (cdsegura == 0){
		showError('error','Informe o codigo da seguradora.','Alerta - Ayllos',"hideMsgAguardo();focaCampoErro('cdsegura','frmInfSeguradora');");
		return false;
	}
	
	showMsgAguardo('Aguarde, buscando ...');

	$('input,select', '#frmInfSeguradora').removeClass('campoErro');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadseg/'+pagina+'.php', 
		data: {
			cddopcao: cddopcao,
			cdsegura: cdsegura,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			if (response.indexOf('showError("error"') == - 1 && response.indexOf('XML error:') == - 1 && response.indexOf('#frmErro') == - 1) {
				try {
					if(pagina == "lista_seguradora")
					{
						$('#divRotina').html(response);
						mostraRotina('busca_seguradora');
						return false;

					}else if ((pagina == 'busca_seguradora') && cddopcao != "I")	
					{
						eval(response);
						return false;
						
					} else if ((pagina == 'busca_seguradora') && cddopcao == "I")	
					{
						hideMsgAguardo();
						controlaFocoFormulariosSeguradora();
						return false;
					}
					return false;
				} catch(error) {
						hideMsgAguardo();
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}else {
				try {
					eval(response);
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} 
		}
	});
return false;
}
 
function formataSeguradoras()
{
	//primeira tela
	//rotulo
	var rCdsegura = $('label[for="cdsegura"]');
	var rNmsegura = $('label[for="nmsegura"]');
	var rNmresseg = $('label[for="nmresseg"]');
	var rFlgativo = $('label[for="flgativo"]');
	var rNrcgcseg = $('label[for="nrcgcseg"]');
	var rNrctrato = $('label[for="nrctrato"]');
	var rNrultpra = $('label[for="nrultpra"]');
	var rNrlimpra = $('label[for="nrlimpra"]');
	var rNrultprc = $('label[for="nrultprc"]');
	var rNrlimprc = $('label[for="nrlimprc"]');
	var rDsasauto = $('label[for="dsasauto"]');

    rCdsegura.css({width:'125px'});
    rNmsegura.css({width:'60px'});
	//altera o layout do rotulo para o Campo Seguradora Ativa se o brownser for IE
	$.browser.msie?rFlgativo.css({width:'217px'}):rFlgativo.css({width:'180px'});
	
    rNmresseg.css({width:'125px'});
    rNrcgcseg.css({width:'125px'});
    rNrctrato.css({width:'158px'});
    rNrultpra.css({width:'125px'});
    rNrlimpra.css({width:'228px'});
    rNrultprc.css({width:'125px'});
    rNrlimprc.css({width:'228px'});
    rDsasauto.css({width:'125px'});
	//campos
    var cCdsegura  = $('#cdsegura');
    var cNmsegura  = $('#nmsegura');
    var cNmresseg  = $('#nmresseg');
    var cFlgativo  = $('#flgativo');
    var cNrcgcseg  = $('#nrcgcseg');
    var cNrctrato  = $('#nrctrato');
    var cNrultpra  = $('#nrultpra');
    var cNrlimpra  = $('#nrlimpra');
    var cNrultprc  = $('#nrultprc');
    var cNrlimprc  = $('#nrlimprc');
    var cDsasauto  = $('#dsasauto');
	
    cCdsegura.css({width:'70px'}).prop({'maxlength':'11'}).addClass('campo').setMask('INTEGER','zzz.zzz.zz9','.','');
    cNmsegura.css({width:'240px'}).prop({'maxlength':'40'}).addClass('campo');
    cNmresseg.css({width:'195px'}).prop({'maxlength':'30'}).addClass('campo');
    cNrcgcseg.css({width:'150px'}).addClass('cnpj').addClass('campo');
    cNrctrato.css({width:'80px'}).prop({'maxlength':'10'}).addClass('campo').setMask('INTEGER','zz.zzz.zz9','.','');	 //Mascara Setada desta forma pois o input.contrato do layout padrão estava com um digito a menos
    cNrultpra.css({width:'80px'}).prop({'maxlength':'11'}).addClass('campo').addClass('propCadseg');
    cNrlimpra.css({width:'80px'}).prop({'maxlength':'11'}).addClass('campo').addClass('propCadseg');
    cNrultprc.css({width:'80px'}).prop({'maxlength':'11'}).addClass('campo').addClass('propCadseg');
    cNrlimprc.css({width:'80px'}).prop({'maxlength':'11'}).addClass('campo').addClass('propCadseg');
    cDsasauto.css({width:'391px'}).prop({'maxlength':'40'}).addClass('campo');     	

	// mascara para os campos de proposta
	$('input.propCadseg').setMask('INTEGER','zzz.zzz.zz9','.','');	
	
	highlightObjFocus($('#frmInfSeguradora'));	
	//fim primeira tela
	
	// segunda tela
	// rotulo
    var rCdhstaut1    = $('label[for="cdhstaut1"]');
    var rCdhstaut2    = $('label[for="cdhstaut2"]');
    var rCdhstaut3    = $('label[for="cdhstaut3"]');
    var rCdhstaut4    = $('label[for="cdhstaut4"]');
    var rCdhstaut5    = $('label[for="cdhstaut5"]');
    var rCdhstaut6    = $('label[for="cdhstaut6"]');
    var rCdhstaut7    = $('label[for="cdhstaut7"]');
    var rCdhstaut8    = $('label[for="cdhstaut8"]');
    var rCdhstaut9    = $('label[for="cdhstaut9"]');
    var rCdhstaut10   = $('label[for="cdhstaut10"]');
    var rCdhstcas1    = $('label[for="cdhstcas1"]');
    var rCdhstcas2    = $('label[for="cdhstcas2"]');
    var rCdhstcas3    = $('label[for="cdhstcas3"]');
    var rCdhstcas4    = $('label[for="cdhstcas4"]');
    var rCdhstcas5    = $('label[for="cdhstcas5"]');
    var rCdhstcas6    = $('label[for="cdhstcas6"]');
    var rCdhstcas7    = $('label[for="cdhstcas7"]');
    var rCdhstcas8    = $('label[for="cdhstcas8"]');
    var rCdhstcas9    = $('label[for="cdhstcas9"]');
    var rCdhstcas10   = $('label[for="cdhstcas10"]');
    var rDsmsgseg     = $('label[for="dsmsgseg"]');
	
    rCdhstaut1.css({width:'160px'});
    rCdhstaut2.css({width:'23.5px'});
    rCdhstaut3.css({width:'23.5px'});
    rCdhstaut4.css({width:'23.5px'});
    rCdhstaut5.css({width:'23.5px'});
    rCdhstaut6.css({width:'160px'});
    rCdhstaut7.css({width:'23.5px'});
    rCdhstaut8.css({width:'23.5px'});
    rCdhstaut9.css({width:'23.5px'});
    rCdhstaut10.css({width:'23.5px'});
    rCdhstcas1.css({width:'160px'});
    rCdhstcas2.css({width:'23.5px'});
    rCdhstcas3.css({width:'23.5px'});
    rCdhstcas4.css({width:'23.5px'});
    rCdhstcas5.css({width:'23.5px'});
    rCdhstcas6.css({width:'160px'});
    rCdhstcas7.css({width:'23.5px'});
    rCdhstcas8.css({width:'23.5px'});
    rCdhstcas9.css({width:'23.5px'});
    rCdhstcas10.css({width:'23.5px'});
    rDsmsgseg.css({width:'125px'});  

	//campos
	var cCdhstaut1   = $('#cdhstaut1');
	var cCdhstaut2   = $('#cdhstaut2');
	var cCdhstaut3   = $('#cdhstaut3');
	var cCdhstaut4   = $('#cdhstaut4');
	var cCdhstaut5   = $('#cdhstaut5');
	var cCdhstaut6   = $('#cdhstaut6');
	var cCdhstaut7   = $('#cdhstaut7');
	var cCdhstaut8   = $('#cdhstaut8');
	var cCdhstaut9   = $('#cdhstaut9');
	var cCdhstaut10  = $('#cdhstaut10');
	var cCdhstcas1   = $('#cdhstcas1');
	var cCdhstcas2   = $('#cdhstcas2');
	var cCdhstcas3   = $('#cdhstcas3');
	var cCdhstcas4   = $('#cdhstcas4');
	var cCdhstcas5   = $('#cdhstcas5');
	var cCdhstcas6   = $('#cdhstcas6');
	var cCdhstcas7   = $('#cdhstcas7');
	var cCdhstcas8   = $('#cdhstcas8');
	var cCdhstcas9   = $('#cdhstcas9');
	var cCdhstcas10  = $('#cdhstcas10');
	var cDsmsgseg    = $('#dsmsgseg');

    cCdhstaut1.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut2.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut3.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut4.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut5.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut6.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut7.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut8.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut9.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstaut10.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas1.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas2.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas3.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas4.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas5.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas6.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas7.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas8.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas9.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cCdhstcas10.css({width:'50px'}).prop({'maxlength':'5'}).addClass('campo').addClass('mascCadseg');
    cDsmsgseg.css({width:'392px'}).prop({'maxlength':'60'}).addClass('campo');	
	$.browser.msie?cDsmsgseg.css({width:'390px'}):cDsmsgseg.css({width:'392px'});
	
	$('input.mascCadseg').setMask('INTEGER','z.zz9','.','');
	
	highlightObjFocus($('#frmInfHistorico'));
}


function btnVoltar() {

	var cNmsegura  = $('#nmsegura');
	
	// verifica se existe display block no formulario de seguradoras
	if($('#frmInfSeguradora').css('display') == "block")
	{
		estadoInicial();
		return false;
	}else if($('#frmInfHistorico').css('display') == "block")	
	{  
		trocaBotao('Prosseguir');
		$('#frmInfHistorico').css({'display':'none'});
		$('#frmInfSeguradora').css({'display':'block'});
		if(cddopcao == "C" || cddopcao == "E")
		{
			$('#btSalvar', '#divBotoes').focus();
		}else{
			cNmsegura.focus();
		}
		return false;
	}
	estadoInicial();
	return false;
}

//função para troca do nome do botão
function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao"  id="btSalvar" onClick="controlaOperacao(); return false;" >'+botao+'</a>');
	}
	return false;
}

//Adiciona os eventos aos campos/lupas de pesquisas
function controlaPesquisas() {
					
	var nomeForm = 'frmInfSeguradora';
	var lupas = $('a','#'+nomeForm);
	
	lupas.addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	lupas.each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');		
		
		$(this).prev().unbind('blur').bind('blur', function() { 
			if ( !$(this).hasClass('campoTelaSemBorda') ) {
				controlaPesquisas();
			}
			return false;
		});
		
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {			
				// Obtenho o nome do campo anterior
				campoAnterior = $(this).prev().attr('name');		
				
				// Seguradora				
				if ( campoAnterior == 'cdsegura' ) {
					
					bo			= 'b1wgen0181.p';
					procedure	= 'busca_crapcsg';
					titulo      = 'Seguradoras';
					qtReg		= '20';					
					filtrosPesq	= 'Código;cdsegura;30px;S;0;;codigo;;|Seguradora;nmsegura;200px;S;;;descricao;;|Ativa;flgativo;20px;S;yes;;descricao;radio;';
					colunas 	= 'Código;cdsegura;20%;center|Nome;nmsegura;60%;left|Ativa;flgativo;20%;center';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'','',nomeForm);
					
				}
				return false;
			}
		});
	});
	
	return false;
	
}