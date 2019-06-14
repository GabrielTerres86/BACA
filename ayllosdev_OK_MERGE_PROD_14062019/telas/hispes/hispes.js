/*!
 * FONTE        : hispes.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Biblioteca de funções da tela HISPES
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 */


var nrdconta = ""; // Variável global para armazenar nr. da conta/dv

var rNmrescop, rNrdconta, rIdseqttl, rNrcpfcgc, rNmpessoa, 
    cNmrescop, cNrdconta, cIdseqttl, cNrcpfcgc, cNmpessoa, cIdpessoa, cTppessoa;

var pesAces = [];    
var frmCab = 'frmCab';

$(document).ready(function () {

    var cSeqTitular = $('#idseqttl', '#frmCab');    
    
    
    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);        
    rNmrescop       = $('label[for="nmrescop"]'	,'#divCooper');    
    rNrdconta       = $('label[for="nrdconta"]'	,'#' + frmCab);    
    rIdseqttl       = $('label[for="idseqttl"]'	,'#' + frmCab);  
    rNrcpfcgc       = $('label[for="nrcpfcgc"]'	,'#' + frmCab);      
    rNmpessoa       = $('label[for="nmpessoa"]'	,'#' + frmCab);  
    
    cNmrescop       = $('#nmrescop'	,'#divCooper');
    cNrdconta       = $('#nrdconta'	,'#' + frmCab);
    cIdseqttl       = $('#idseqttl'	,'#' + frmCab);    
    cNrcpfcgc       = $('#nrcpfcgc'	,'#' + frmCab);    
    cNmpessoa       = $('#nmpessoa'	,'#' + frmCab);   
    cIdpessoa       = $('#idpessoa'	,'#' + frmCab);   
    cTppessoa       = $('#tppessoa'	,'#' + frmCab);   

    incializarTela();
    
    // Evento onKeyUp no campo "nrdconta"
    cNrdconta.bind('keyup', function (e) {
        // Seta máscara ao campo
        if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
            return false;
        }
    });
       

    // Evento onKeyDown no campo "nrdconta"
    cNrdconta.bind('keypress', function (e) {
        incializarTela('C');
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        if (keyValue == 118) { // Se for F7
            if ($(this).hasClass('campo')) {
                $('a', '#frmCabCadcta').first().click();
                return false;
            }
        }

        // Se alguma tecla foi pressionada, seta o idseqttl para 1
        if ((keyValue >= 48 && keyValue <= 57) || (keyValue >= 96 && keyValue <= 105)) {
            cSeqTitular.val('1');            
        }

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            if ($(this).val() != ""){
              obtemTitular();          
            }        
            cIdseqttl.focus();    
            return true;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });

    // Evento onBlur no campo "nrdconta"
    cNrdconta.bind('change', function () {
        
        incializarTela('C');
        if ($(this).val() == '') {
            incializarTela();
            return true;
        }

        // Valida número da conta
        if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
            showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#"+ frmCab +"').focus()");
            incializarTela();
            return false;
        }

        obtemTitular();
        return true;
    });
    
    
    cNmrescop.bind('change', function () {        
        incializarTela();        
        return true;
    });
    
    // Evento onBlur no campo "nrdconta"
    cIdseqttl.bind('change', function () {        
        obtemPessoa();        
        return true;
    });
    
    cNrcpfcgc.bind('change', function () {
        incializarTela('N');
        if ($(this).val() != ""){
            obtemPessoa();
        }
        return true;
    });
    
    
     // Evento onBlur no campo "nrdconta"
    cNrcpfcgc.bind('keypress' , function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);
        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            if ($(this).val() != ""){
                obtemPessoa();
            }
        }
        return true;
    });
    
    cNrdconta.focus();
    
    // Se origem foi do CRM
	if (crm_inacesso == 1){
		
		if (normalizaNumero(crm_nrdconta) > 0){
            cNrdconta.val(crm_nrdconta);	
            obtemTitular();
		}else if (normalizaNumero(crm_nrcpfcgc) > 0){
            cNrcpfcgc.val(crm_nrcpfcgc);    
            obtemPessoa();
        }else{
			showError("error", "Numero de conta deve ser informado.", "Alerta - Ayllos", "");
            cNrdconta.desabilitaCampo();		
            return false;    
		}
	}else{        
        // Controle da pesquisa Assosicado
        controlaPesquisaAssociado('frmCab');
        
    }
      
    formataTela();  
	
});

function incializarTela(tipo){
    
    // alterando numero da conta
    if (tipo == 'C'){
        cNrcpfcgc.val('');
    // alterando numero cpf/cnpj    
    }else if (tipo == 'N'){
        cNrdconta.val('');
    }else{
        cNrdconta.val('');
        cNrcpfcgc.val('');
    }
    
    $('#frmAbas').css('display', 'none');    
    cNmpessoa.val('');  
    cIdpessoa.val('');   
    cTppessoa.val('');  
    cIdseqttl.html("<option value=\"1\"></option>");
    
    $('.pessoaAcesso').css('display', 'none');    
    $('#divConteudoOpcao').empty();
    $('#divAcessoPessoa').empty();
    pesAces = [];
    
    
}

function formataTela() {
    
    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
        
    $('br', '#' + frmCab).css({ 'clear': 'both' });
    $('a' , '#' + frmCab).css({ 'float': 'left', 'font-size': '11px', 'padding-top': '4px' });
    $('a' , '#' + frmCab).css({ 'float': 'left', 'padding': '0px 0px 0px 3px' });
    $('.botao', '#' + frmCab).css({ 'float': '', 'padding': '3px 6px 3px 6px' });
    
    cTodosCabecalho.habilitaCampo();
    
    rNmrescop.addClass('rotulo').css('width','80px');;
	cNmrescop.css('width','130px');
    
    rNrdconta.addClass('rotulo').css('width','80px');
    cNrdconta.addClass('conta pesquisa').css({'width':'70px'})
    
    rIdseqttl.addClass('rotulo-linha').css({'padding-left':'5px'});
    cIdseqttl.addClass('campo').css({'width':'300px'})
    
    rNrcpfcgc.addClass('rotulo').css('width','80px');
    cNrcpfcgc.addClass('campo inteiro').css({'width':'120px'})
    
    rNmpessoa.addClass('rotulo-linha').css({'padding-left':'5px'});
    cNmpessoa.addClass('campo').css({'width':'300px'})
    
    
    cNmpessoa.desabilitaCampo();
    
    // Hack IE
    if ($.browser.msie) {
        $('#nrdctitg', '#' + frmCab  ).css({ 'width': '66px' });
        $('hr', '#' + frmCab ).css({ 'margin': '25px 0px 0px 0px', ' ': '0px', 'color': '#777', 'display': 'block', 'height': '1px' });
    } else {
        $('hr', '#' + frmCab ).css({ 'background-color': '#777', 'height': '1px', 'margin': '5px 0px 2px 0px' });
    }
    
    // Se origem foi do CRM
	if (crm_inacesso == 1){
        cNrcpfcgc.desabilitaCampo();
        cNrdconta.desabilitaCampo();	
    }
    
    
    layoutPadrao();    
    setaNavegacaoCampos();
    

}

function setaNavegacaoCampos(){
    // Controlar navegacao         
	cNmrescop.unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {			
			cNrdconta.focus();
            return false;            				
		}
	});
    
    cIdseqttl.unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {			
			cNrcpfcgc.focus();
            return false;            				
		}
	});
    
    return true;
        
}

function carregaResumo(){
    
    setTimeout(function(){
        
        if (cNrdconta.val() == "" && 
            cNrcpfcgc.val() == "" &&
            cIdpessoa.val() == "" ){
            return false;    
        
        }
        
        $('#frmAbas').css('display', 'block');
        
        if (cTppessoa.val() == 1){
            
            $('.abaPessoaFis').css('display', 'table-cell');
            $('.abaPessoaJur').css('display', 'none');
            
        }else if (cTppessoa.val() == 2){
            $('.abaPessoaFis').css('display', 'none');
            $('.abaPessoaJur').css('display', 'table-cell');
        }
        
        //aguardar terminar de carregar dados
        acessaOpcaoAbaDados(0);
        $('#frmAbas').css('display', 'block');
     }, 200);    
    
}

function formataTabela(id){
    
    //tabela de resumos
    if (id == 0 ) { 
        var divRegistro = $('div.divRegistrosRes');		
        var tabela      = $('table', divRegistro );
        
        divRegistro.css('height','250px');
        
        var ordemInicial = new Array();
        //ordemInicial = [[0,0]];
        
        var arrayLargura = new Array();
        arrayLargura[0] = '300px';
        arrayLargura[1] = '110px';
        arrayLargura[2] = '130px';
        
        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
                        
        var metodoTabela = "";
        tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
    } else {
        var divRegistro = $('div.divRegistrosHis');		
        var tabela      = $('table', divRegistro );
        
        divRegistro.css('height','250px');
        
        var ordemInicial = new Array();
        //ordemInicial = [[2,0]];
        
        var arrayLargura = new Array();
        arrayLargura[0] = '105px';
        arrayLargura[1] = '60px';
        arrayLargura[2] = '180px';
        arrayLargura[3] = '180px';
        arrayLargura[4] = '180px';
        
        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
                        
        var metodoTabela = "";
        tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
    }
}

// Função para carregar os titulares da conta 
function obtemTitular() {
   
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os titulares da conta/dv ...");

    // Armazena conta/dv e seq.contas informadas
    nrdconta = retiraCaracteres(cNrdconta.val(), "0123456789", true);
    cdcooper = cNmrescop.val();

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == "") {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
        return false;
    }

    // Se conta/dv foi informada, valida
    if (nrdconta != "") {
        if (!validaNroConta(nrdconta)) {
            hideMsgAguardo();
            showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#" + frmCab + "').focus()");
            incializarTela();
            return false;
        }
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/hispes/obtem_titulares.php",
        data: {
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#" + frmCab + "').focus()");
        },
        success: function (response) {
            try {
                eval(response);                
                obtemPessoa();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#" + frmCab + "').focus()");
            }
        }
    });
}

// Função para carregar pessoa pelo CPF/CNPJ
function obtemPessoa() {
   
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os pessoa ...");

    nrcpfcgc = retiraCaracteres(cNrcpfcgc.val(), "0123456789", true);        
    cdcooper = cNmrescop.val();
    nrdconta = retiraCaracteres(cNrdconta.val(), "0123456789", true);    
    idseqttl = cIdseqttl.val();   
    
    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/hispes/obtem_pessoa.php",
        data: {
            nrcpfcgc: nrcpfcgc,
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrcpfcgc','#" + frmCab + "').focus()");
        },
        success: function (response) {
            try {
                eval(response);
                carregaResumo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrcpfcgc','#" + frmCab + "').focus()");
            }
        }
    });
}

function acessaOpcaoAbaDados(id,nmtabela,dtaltera) {

	var nmdfonte  = "historico_tabela.php"; 
    //numero de abas
    nrOpcoes = 21;

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando historico ...");
	
    // caso id indefinido, deve buscar pelo nome da tabela
    if (id == 999 ){
        
        // Tratamento para chamada de cada "Rotina"
        switch (nmtabela) {
            case 'TBCADAST_PESSOA': 			
                id = 1;
                break;            
            case 'TBCADAST_PESSOA_FISICA': 			
                id = 2;
                break;            
            case 'TBCADAST_PESSOA_JURIDICA': 			
                id = 3;
                break;
            case 'TBCADAST_PESSOA_ENDERECO': 			
                id = 4;
                break;
            case 'TBCADAST_PESSOA_TELEFONE': 			
                id = 5;
                break;
            case 'TBCADAST_PESSOA_EMAIL': 			
                id = 6;
                break;               
            case 'TBCADAST_PESSOA_BEM': 			
                id = 7;
                break;  
            case 'TBCADAST_PESSOA_RENDA': 			
                id = 8;
                break;  
            case 'TBCADAST_PESSOA_RENDACOMPL': 			
                id = 9;
                break;  
            case 'TBCADAST_PESSOA_ESTRANGEIRA': 			
                id = 10;
                break;  
            case 'TBCADAST_PESSOA_RELACAO': 			
                id = 11;
                break;  
            case 'TBCADAST_PESSOA_REFERENCIA': 			
                id = 12;
                break;      
            case 'TBCADAST_PESSOA_POLEXP': 			
                id = 13;
                break;  
            case 'TBCADAST_PESSOA_FISICA_RESP': 			
                id = 14;
                break;  
            case 'TBCADAST_PESSOA_FISICA_DEP': 			
                id = 15;
                break; 
            case 'TBCADAST_PESSOA_JURIDICA_REP': 			
                id = 16;
                break;      
            case 'TBCADAST_PESSOA_JURIDICA_BCO': 			
                id = 17;
                break;  
            case 'TBCADAST_PESSOA_JURIDICA_FAT': 			
                id = 18;
                break; 
            case 'TBCADAST_PESSOA_JURIDICA_FNC': 			
                id = 19;
                break; 
            case 'TBCADAST_PESSOA_JURIDICA_PTP': 			
                id = 20;
                break;  
        } 
        
    }

	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i <= nrOpcoes; i++) {
		if ($('#linkAba' + id).length == false) {
			continue;
		}
				
		if (id == i) { // Atribui estilos para foco da opção	
			
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
			
		$('#linkAba'   + i).attr('class','txtNormalBold'); //txtNormalBold
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
		
	}
	
	// Tratamento para chamada de cada "Rotina"
	switch (id) {
		case 0: {			
			nmdfonte = "resumo";
			break;
		}
	} 
		 	
	carregaDados(nmdfonte,id,nmtabela,dtaltera);		
}
function carregaDados (nmdfonte,id,nmtabela,dtaltera) {
    
   
    cdcooper = cNmrescop.val();
    nrdconta = retiraCaracteres(cNrdconta.val(), "0123456789", true);
    idseqttl = cIdseqttl.val();   
    nrcpfcgc = retiraCaracteres(cNrcpfcgc.val(), "0123456789", true);
    idpessoa = cIdpessoa.val();
    
	
    // Carrega conteúdo da opção através do Ajax
    $.ajax({		
        type: 'POST', 
        dataType: 'html',
        url: UrlSite + 'telas/hispes/' + nmdfonte,
        data: {
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nrcpfcgc: nrcpfcgc,
            idpessoa: idpessoa,
            nmtabela: nmtabela,
            dtaltera: dtaltera,
            nmdatela: "HISPES",
            nmrotina: nmrotina,
            redirect: 'script_ajax'
        },		
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1 ) {
                        
                
                $('#divConteudoOpcao').html(response);   // Limpar tela e colocar somente novo conteudo                
                formataTabela(id);
                hideMsgAguardo();
                            
            } else {
                eval( response );
                hideMsgAguardo();
            }
            return false;
            hideMsgAguardo();
        }				 
    });
}

function confirmaHistPessoa(idpessoa,nrcpfcgc,nmpessoa,tppessoa) {

    showConfirmacao('Deseja visualizar historico de '+ nmpessoa +'?', 'Confirma&ccedil;&atilde;o - Ayllos', 'carregaHistPessoa("'+idpessoa+'","'+nrcpfcgc+'","'+nmpessoa+'","'+tppessoa+'");', '', 'sim.gif', 'nao.gif');
}

function carregaHistPessoa(idpessoa,nrcpfcgc,nmpessoa,tppessoa,tipo){
    
    $('.pessoaAcesso').css('display', 'block');    
    
    // Verificar se pessoa ja foi incluida na listagem de acesso
    if (pesAces.length == 0 || 
       pesAces.indexOf(cIdpessoa.val()) == -1 ){
           
        pesAces[pesAces.length] = cIdpessoa.val();
        
        aux_html = '<a class="txtNormalBold pointer" style="font-size:10px;" onclick="carregaHistPessoa(\''+ cIdpessoa.val() +'\',';
        aux_html += '\''+ cNrcpfcgc.val() +'\',';
        aux_html += '\''+ cNmpessoa.val() +'\',';
        aux_html += '\''+ cTppessoa.val() +'\',';
        //identificador de retorno
        aux_html += '\'R\')">';
        if (tipo == 'R'){
             aux_html += '&nbsp; &nbsp;'
        }        
        aux_html +=  cNmpessoa.val() +'</a> <br style="clear: both">';
        $('#divAcessoPessoa').append(aux_html);
        
    }    
    
    cNrcpfcgc.val(nrcpfcgc);
    cNmpessoa.val(nmpessoa);
    cIdpessoa.val(idpessoa);
    cTppessoa.val(tppessoa);    
    carregaResumo();    
    
}
