/*!
 * FONTE        : gt0018.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 12/12/2017
 * OBJETIVO     : Biblioteca de funções da tela GT0018
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

var rCddopcao, rTparrecd, rCdempres, rCdempcon, rNmrescon, rCdsegmto, rCdempcon_I, rNmrescon_I, rCdsegmto_I, rVltarint, rVltartaa, rVltarcxa, rVltardeb, rVltarcor, rVltararq, rNrrenorm, rNrtolera, rDsdianor, rDtcancel, rNrlayout,           
    cCddopcao, cTparrecd, cCdempres, cCdempcon, cNmrescon, cCdsegmto, cCdempcon_I, cNmrescon_I, cCdsegmto_I, cVltarint, cVltartaa, cVltarcxa, cVltardeb, cVltarcor, cVltararq, cNrrenorm, cNrtolera, cDsdianor, cDtcancel, cNrlayout; 

var cNmextcon, cCamposAltera, cCamposAltSic;        

var frmCab = 'frmCab';
var frmCampos = 'frmCampos';

$(document).ready(function() {
    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    rCddopcao		= $('label[for="cddopcao"]'	,'#' + frmCab); 
    rTparrecd       = $('label[for="tparrecd"]'	,'#' + frmCab); 
    rCdempres       = $('label[for="cdempres"]'	,'#' + frmCab);      
    
    cCddopcao		= $('#cddopcao'	,'#' + frmCab); 
    cTparrecd		= $('#tparrecd'	,'#' + frmCab); 
    cCdempres		= $('#cdempres'	,'#' + frmCab); 
    cNmextcon       = $('#nmextcon'	,'#' + frmCab); 
    
    rCdempcon_I       = $('label[for="cdempcon"]'	,'#' + frmCab);
    rNmrescon_I       = $('label[for="nmrescon"]'	,'#' + frmCab);
    rCdsegmto_I       = $('label[for="cdsegmto"]'	,'#' + frmCab);     
    
    cCdempcon_I       = $('#cdempcon'	,'#' + frmCab);    
    cNmrescon_I       = $('#nmrescon'	,'#' + frmCab);
    cCdsegmto_I       = $('#cdsegmto'	,'#' + frmCab);
    
    // Form Campos
    cTodosCampos    = $('input[type="text"],select', '#' + frmCampos);    
    cCamposAltera   = $('#cdempcon,#vltarint,#vltartaa,#vltarcxa,#vltardeb,#vltarcor,#vltararq,#nrrenorm,#nrtolera,#dsdianor,#dtcancel,#nrlayout'	,'#' + frmCampos); 
    cCamposAltSic   = $('#cdempcon,#cdsegmto,#nmrescon','#' + frmCampos); 
    
    rCdempcon       = $('label[for="cdempcon"]'	,'#' + frmCampos);
    rNmrescon       = $('label[for="nmrescon"]'	,'#' + frmCampos);
    rCdsegmto       = $('label[for="cdsegmto"]'	,'#' + frmCampos);     
    
    rVltarint       = $('label[for="vltarint"]'	,'#' + frmCampos); 
    rVltartaa       = $('label[for="vltartaa"]'	,'#' + frmCampos); 
    rVltarcxa       = $('label[for="vltarcxa"]'	,'#' + frmCampos); 
    rVltardeb       = $('label[for="vltardeb"]'	,'#' + frmCampos); 
    rVltarcor       = $('label[for="vltarcor"]'	,'#' + frmCampos); 
    rVltararq       = $('label[for="vltararq"]'	,'#' + frmCampos); 
    rNrrenorm       = $('label[for="nrrenorm"]'	,'#' + frmCampos); 
    rNrtolera       = $('label[for="nrtolera"]'	,'#' + frmCampos); 
    rDsdianor       = $('label[for="dsdianor"]'	,'#' + frmCampos); 
    rDtcancel       = $('label[for="dtcancel"]'	,'#' + frmCampos); 
    rNrlayout       = $('label[for="nrlayout"]'	,'#' + frmCampos); 
    
    
    
    cCdempcon       = $('#cdempcon'	,'#' + frmCampos);    
    cNmrescon       = $('#nmrescon'	,'#' + frmCampos);
    cCdsegmto       = $('#cdsegmto'	,'#' + frmCampos);
    
    cVltarint       = $('#vltarint'	,'#' + frmCampos); 
    cVltartaa       = $('#vltartaa'	,'#' + frmCampos); 
    cVltarcxa       = $('#vltarcxa'	,'#' + frmCampos); 
    cVltardeb       = $('#vltardeb'	,'#' + frmCampos); 
    cVltarcor       = $('#vltarcor'	,'#' + frmCampos); 
    cVltararq       = $('#vltararq'	,'#' + frmCampos); 
    cNrrenorm       = $('#nrrenorm'	,'#' + frmCampos); 
    cNrtolera       = $('#nrtolera'	,'#' + frmCampos); 
    cDsdianor       = $('#dsdianor'	,'#' + frmCampos); 
    cDtcancel       = $('#dtcancel'	,'#' + frmCampos); 
    cNrlayout       = $('#nrlayout'	,'#' + frmCampos); 
    
    estadoInicial();

});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	//fechaRotina( $('#divRotina') );
	
    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    cTodosCampos.limpaFormulario();
    // habilita foco no formulário inicial
    highlightObjFocus($('#' + frmCab));
	
	cddopcao = "C";
    cCddopcao.val(cddopcao);
    cCdsegmto_I.val(0);
    cTodosCampos.desabilitaCampo();
    $('#divConv').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});
    
    controlaLayout();
	
	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();
    
	return false;
	
}

function controlaLayout() {
		
	$('#frmCampos').css({'display':'none'});
    formataCabecalho();
    formataCampos();
    
	
	layoutPadrao();
    
    $('#linkEmp','#' + frmCab).prop('tabindex','0');	
	return false;	
}

function LiberaCampos(tipo) {
    
     if (tipo == 'frmCab'){        
        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }
        
        if (cCddopcao.val() == 'I' && cTparrecd.val() == 1) {
            showError("error","Opção não disponível para Agente Sicredi.","Alerta - Ayllos","");
            return false;
        }
        
        $('#divConv').css({'display': 'block'});         
        cCddopcao.desabilitaCampo();
        cTparrecd.desabilitaCampo();
        
        // Caso for inclusao, exibir campos para inclusao
        if (cCddopcao.val() == 'I'){
            $('#divInsert').css({'display':'block'});    
            $('#lupaConv','#' + frmCab).css({'display':'none'});
            cCdempcon_I.desabilitaCampo();    
        }else {
            $('#lupaConv','#' + frmCab).css({'display':'block'});
        }
        
        
        $('#btnPross').attr("onClick","buscaDados(); return false;");
        $('#btnPross').css({'display': 'inline-table'});   

        
        cCdempres.focus();
         
     }else if (tipo == 'frmCampos'){
        
        if (cCdempres.hasClass('campoTelaSemBorda')) {
            return false;
        }
        
        if (cCdempres.val() == ""){
            showError("error","Informe o Convênio.","Alerta - Ayllos","cCdempres.focus()");
            return false;
        }
        
        cCdempres.desabilitaCampo();
        cCdsegmto.desabilitaCampo();
        
        $('#frmCampos').css({'display': 'block'});		
        $('#btnPross').attr("onClick","confirmaOpe(); return false;");
        
        // Controlar exibição dos campos exclusivos para o tipo de arrecad.
        if (cTparrecd.val() == 1){            
            $('#divCampoSicredi').css({'display':'block'});  
            $('.Bancoob').css({'display':'none'});     
            
        }else if (cTparrecd.val() == 2){
            $('#divCampoSicredi').css({'display':'none'});   
            $('.Bancoob').css({'display':'block'});   
        }
        
        if (cCddopcao.val() == 'C' ){
           $('#btnPross').css({'display': 'none'});     
           
        } else if (cCddopcao.val() == 'A' || 
                   cCddopcao.val() == 'I' ) {
                    
            if (cTparrecd.val() == 1){
                cCamposAltSic.habilitaCampo();
            }else{
                cCamposAltera.habilitaCampo();
            }
            
            // Ocultar block
            $('#divInsert').css({'display':'none'});   
            cCdempcon.focus();
            
            if (cTparrecd.val() == 2 && cCddopcao.val() == 'I' ){
                
                cCdempcon.val(cCdempcon_I.val());
                cCdsegmto.val(cCdsegmto_I.val());
                cNmrescon.val(cNmrescon_I.val());
            }
           
        }
        
        
     }
    
    $('#divBotoes').css({'display': 'block'});
    
    layoutPadrao();
    $('#linkEmp','#' + frmCab).prop('tabindex','0');	
    return false;

}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();
    
    var btnBusca			= $('#btnBusca','#' + frmCab);
	
	rCddopcao.addClass('rotulo').css({'width':'90px'});
	cCddopcao.css({'width':'340px'});
    
    rTparrecd.addClass('rotulo-linha').css({'padding-left':'20px'});
    cTparrecd.css({'width':'100px'}); 

    rCdempres.addClass('rotulo').css({'width':'90px'});
    cCdempres.addClass('alphanum' ).css({'width':'95px'}).attr('maxlength','10');     
    
    cNmextcon.css({'width':'350px','padding-right':'2px'});
    
    $('#divConv').css({'padding':'3px 0px 2px 0px','margin-bottom':'4px','border-top':'1px solid #777'});
    
    rCdempcon_I.addClass('rotulo').css({'width':'90px'});
    cCdempcon_I.css({'width':'40px'});
    cNmrescon_I.css({'width':'200px'});
    
    rCdsegmto_I.addClass('rotulo-linha').css({'padding-left':'10px'});
	cCdsegmto_I.css('width','200px');
    $('#divInsert').css({'display':'none'});
    
    cTodosCabecalho.habilitaCampo(); 
    
    cNmextcon.desabilitaCampo();
    cNmrescon_I.desabilitaCampo();
    cCdsegmto_I.desabilitaCampo();
    
    controlaPesquisas(frmCab);
    
    //Navegação    
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {                    
			cTparrecd.focus();
			return false;
		}
	});   

    cTparrecd.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {                    
			LiberaCampos('frmCab');
            cCdempres.focus();
			return false;
		}
	});  
    
    cCdempres.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {                    
			if (cCddopcao.val() == 'I'){
                //buscaDados();                
                $('#linkEmp','#' + frmCab).focus();                
                return false;
            }
            
		}
	}); 
    
    $('#linkEmp','#' + frmCab).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {                    
			if (cCddopcao.val() == 'I'){
                abrePesqCdempcon(frmCab)
                return false;
            }            
		}
	}); 
    
    return false;
}

function formataCampos(){
    
    
    rCdempcon.addClass('rotulo').css({'width':'85px'});
    cCdempcon.addClass('inteiro').css({'width':'40px'}).attr('maxlength','4');
    cNmrescon.addClass('alpha').css({'width':'200px'}).attr('maxlength','20');;
    
    rCdsegmto.addClass('rotulo-linha').css({'padding-left':'10px'});
	cCdsegmto.css('width','200px');
    
    rVltarint.addClass('rotulo').css({'width':'200px'});
    cVltarint.addClass('taxa').css({'width':'80px'});
        
    rVltartaa.addClass('rotulo').css({'width':'200px'});
    cVltartaa.addClass('taxa').css({'width':'80px'});
    
    rVltarcxa.addClass('rotulo').css({'width':'200px'});
    cVltarcxa.addClass('taxa').css({'width':'80px'});
    
    rVltardeb.addClass('rotulo').css({'width':'200px'});
    cVltardeb.addClass('taxa').css({'width':'80px'});
    
    rVltarcor.addClass('rotulo').css({'width':'200px'});
    cVltarcor.addClass('taxa').css({'width':'80px'});
    
    rVltararq.addClass('rotulo').css({'width':'200px'});
    cVltararq.addClass('taxa').css({'width':'80px'});
    
    rNrrenorm.addClass('rotulo-linha').css({'padding-left':'132px'});
    cNrrenorm.addClass('inteiro').css({'width':'40px'}).attr('maxlength','2');
        
    rDsdianor.addClass('rotulo-linha').css({'padding-left':'100px'});
    cDsdianor.css({'width':'95px'});
    
    rNrtolera.addClass('rotulo-linha').css({'padding-left':'50px'});
    cNrtolera.addClass('inteiro').css({'width':'40px'}).attr('maxlength','2');
        
    rDtcancel.addClass('rotulo-linha').css({'padding-left':'80px'});
    cDtcancel.addClass('data').css({'width':'80px'});
    
    rNrlayout.addClass('rotulo-linha').css({'padding-left':'395px'});
    cNrlayout.addClass('inteiro').css({'width':'60px'}).attr('maxlength','4');
    
    cTodosCampos.desabilitaCampo();     
    controlaPesquisas(frmCampos);
    
    layoutPadrao();
    
    //Navegação    
    
    cCdempcon.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
            if (cNmrescon.hasClass('campoTelaSemBorda')) {
                cVltarint.focus();
            }else{
                cNmrescon.focus();
            } 
			return false;
		}
	});
    
    cNmrescon.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cCdsegmto.focus();           
            return false;
		}
	});
    
    cCdsegmto.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cVltarint.focus();           
            return false;
		}
		
	});
    
    cVltarint.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cVltartaa.focus();           
            return false;
        }
		
	});
    
    cVltartaa.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cVltarcxa.focus();           
            return false;
        }
		
	});
    
    cVltarcxa.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cVltardeb.focus();           
            return false;
        }
		
	});
    
    cVltardeb.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            var divSic = document.getElementById("divCampoSicredi");
            
            if (divSic.style.display == 'none') {
                cNrrenorm.focus();
            }else{
                cVltarcor.focus();
            }                 
            return false;
        }    
		
	});
    
    cVltarcor.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cVltararq.focus();           
            return false;
        }
		
	});
    
    cVltararq.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cNrrenorm.focus();           
            return false;
        }
		
	});
    
    cNrrenorm.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cDsdianor.focus();           
            return false;
        }
		
	});
    
    cDsdianor.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cNrtolera.focus();           
            return false;
        }    
	});
    
    cNrtolera.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cDtcancel.focus();           
            return false;
        }
	});
    
    cDtcancel.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9) {	
            cNrlayout.focus();           
            return false;
        }
	});

    
    cDtcancel.unbind('change').bind('change', function(e) {
        
        if (validarData(cDtcancel.val()) = false ){
            showError("error","Data invalida.","Alerta - Ayllos","");
            return false;
        }
         
	});
        
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
            campoAnterior = $(this).prev().attr('name');
            
			if ( $(this).prev().hasClass('campoTelaSemBorda') && campoAnterior != 'cdempcon') {
                 
				return false;
                
			}else if ( nomeFormulario == 'frmCab' && 
                       campoAnterior == 'cdempcon' && 
                       cCdempres.hasClass('campoTelaSemBorda') ){
                
                return false;
            }else {						
				campoAnterior = $(this).prev().attr('name');
			
				
				if ( campoAnterior == 'cdempres' ) {  
                    abrePesqCdempres();
					return false;
				}else if (campoAnterior == 'cdempcon' ) {
                    
					abrePesqCdempcon(nomeFormulario);
					return false;
				}
                
				
			}
		});
	});
    
    
    cCdempres.unbind('change').bind('change', function() { 	
    
        if (cCddopcao.val() != 'I' ){
            bo			= 'ZOOM0001';
            procedure	= 'BUSCA_DESC_CONVEN';
            titulo      = 'Convênios';
            qtReg		= '20';
            filtros 	= 'tparrecd|'+ cTparrecd.val();
            buscaDescricao(bo,procedure,titulo,'cdempres','nmextcon',cCdempres.val(),'nmextcon',filtros,'frmCab','fechaRotina(divRotina);');
            return false;
        }/*else if (cTparrecd.val() == 2){
            abrePesqCdempcon('frmCab');
        }*/
    });
	
    cCdempcon.unbind('change').bind('change', function() { 	
        bo			= 'b1wgen0101.p';
        procedure	= 'lista-empresas-conv';
        titulo      = 'Empr.Conven.';
        filtrosDesc = 'cdsegmto|'+ cCdsegmto.val()  + ';tparrecd|'+ cTparrecd.val() ;
        buscaDescricao(bo,procedure,titulo,'cdempcon','nmrescon',cCdempcon.val(),'nmrescon',filtrosDesc,'frmCab','fechaRotina(divRotina);');
        return false;
    });
    
	return false;
	
}

function abrePesqCdempres(){
    var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
    bo			= 'ZOOM0001';
    procedure	= 'BUSCA_DESC_CONVEN';
    titulo      = 'Convênios';
    qtReg		= '20';
    filtros 	= 'Cod.Conv&ecircnio;cdempres;45px;S;;S|Conv&ecircnio;nmextcon;200px;S|Empresa;cdempcon;200px;N;;N|'+
                  'Segmento;cdsegmto;200px;N;;N|tparrecd;tparrecd;35px;N;'+ cTparrecd.val() +';N';
    /*if (cTparrecd.val() == 1){
      colunas 	= 'Codigo;cdempres;15%;right|Nome;nmextcon;85%;left';
    }else{*/
      colunas 	= 'Codigo;cdempres;15%;right|Nome;nmextcon;55%;left|Empresa;cdempcon;15%;left|Segmento;cdsegmto;15%;left';  
    //}
    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'frmCab');
    
}

function abrePesqCdempcon(nomeFormulario){
    var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
   
    if ( nomeFormulario == 'frmCab' ) {
        bo			= 'b1wgen0101.p';
        procedure	= 'lista-empresas-conv';
        titulo      = 'Empr.Conven.';
        qtReg		= '20';
        filtros 	= 'Empresa;cdempcon;45px;S;0;S|Conv&ecircnio;nmextcon;200px;S|nome;nmrescon;200px;N;;N|Segmento;cdsegmto;35px;N;;N';
        colunas 	= 'Codigo;cdempcon;15%;right|Conv&ecircnio;nmextcon;30%;left|Nome res.;nmrescon;30%;left|Segmento;cdsegmto;15%;left';
        mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'', '',nomeFormulario);
        return false;
    }else if (  nomeFormulario == 'frmCampos') {
        
        bo			= 'b1wgen0101.p';
        procedure	= 'lista-empresas-conv';
        titulo      = 'Empr.Conven.';
        qtReg		= '20';
        filtros 	= 'Empresa;cdempcon;45px;S;0;S|Conv&ecircnio;nmrescon;200px;S|Segmento;cdsegmto;35px;S';
        colunas 	= 'Codigo;cdempcon;15%;right|Conv&ecircnio;nmrescon;70%;left|Segmento;cdsegmto;18%;left';
        mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'', '',nomeFormulario);
        return false;
    }
    
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


function buscaDados(){
    
    cdempres = cCdempres.val();
    tparrecd = cTparrecd.val();
    cddopcao = cCddopcao.val();
    cdempcon = cCdempcon_I.val();
    cdsegmto = cCdsegmto_I.val();
    
    if (cdempres == "" ){
        showError("error","Convênio deve ser informado.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdempres.focus();");        
        return false;
    }
    
    if (tparrecd == "" ){
        showError("error","Agente deve ser informado.","Alerta - Ayllos","blockBackground(); unblockBackground(); cTparrecd.focus();");        
        return false;
    }
    if (cddopcao == "I"){
        
        if (cdempcon == "" ){
            showError("error","Empresa deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdempres.focus();");        
            return false;
        }
    }
           
    dsaguardo = 'Aguarde, buscando dados...';
    showMsgAguardo(dsaguardo);
    
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/gt0018/busca_dados.php',
        data: {
            cddopcao: cddopcao,
            cdempres: cdempres,
            tparrecd: tparrecd,
            cdempcon: cdempcon,
            cdsegmto: cdsegmto,            
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

function confirmaRegExist(){
    hideMsgAguardo();
    showConfirmacao('Convênio '+ cCdempres.val() +' já cadastrado, deseja altera-lo?', 'Confirma&ccedil;&atilde;o - Ayllos', 'cCddopcao.val("A");LiberaCampos("frmCampos");', '', 'sim.gif', 'nao.gif');
}

function confirmaOpe() {
    
     if (cCddopcao.val() == 'A' ||
         cCddopcao.val() == 'I' ){ 
         
        
        
        if (cCdsegmto.val() == ""){
            showError("error","Segmento deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdsegmto.focus();");        
            return false;
        }
        
        // Se for Bancoob
        if (cTparrecd.val() == 2){
            
            if (cCdempcon.val() == ""){
                showError("error","Codigo da empresa deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdempcon.focus();");        
               return false;
            }
            
            if (cNrlayout.val() == ""){
                showError("error","Layout Febraban deve ser informado.","Alerta - Ayllos","blockBackground(); unblockBackground(); cNrlayout.focus();");        
                return false;
            }
            
            
        }
        
    }
    
    
    if (cCddopcao.val() == 'A'){        
        aux_dsconfir = 'Altera&ccedil;&atilde;o dos dados';
        
    } else if (cCddopcao.val() == 'I'){        
        aux_dsconfir = 'Inclus&atilde;o dos dados';
        
    } 
    
    showConfirmacao('Confirma a ' + aux_dsconfir + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
}


function manterRotina() {

    var dsaguardo = '';    
    hideMsgAguardo(); 
       
    cddopcao = cCddopcao.val();
    tparrecd = cTparrecd.val(); 
    cdempres = cCdempres.val();     
    cdempcon = cCdempcon.val(); 
    cdsegmto = cCdsegmto.val();
    nmrescon = cNmrescon.val();
    nmextcon = cNmextcon.val();
    vltarint = normalizaNumero(cVltarint.val());
    vltartaa = cVltartaa.val();
    vltarcxa = cVltarcxa.val();
    vltardeb = cVltardeb.val();
    vltarcor = cVltarcor.val();
    vltararq = cVltararq.val();
    nrrenorm = cNrrenorm.val();
    nrtolera = cNrtolera.val();
    dsdianor = cDsdianor.val();
    dtcancel = cDtcancel.val();
    nrlayout = cNrlayout.val();
    
    if (cddopcao == 'A' || 
        cddopcao == 'I' ) {
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);     
    }  
            
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/gt0018/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            tparrecd: tparrecd,
            cdempres: cdempres,
            cdempcon: cdempcon,
            cdsegmto: cdsegmto,
            nmrescon: nmrescon,
            nmextcon: nmextcon,
            vltarint: vltarint,
		    vltartaa: vltartaa,
            vltarcxa: vltarcxa,
            vltardeb: vltardeb,
            vltarcor: vltarcor, 
            vltararq: vltararq,
            nrrenorm: nrrenorm,
            nrtolera: nrtolera,
            dsdianor: dsdianor,
            dtcancel: dtcancel,
            nrlayout: nrlayout,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);			
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
