/**************************************************************************************************
 Fonte: cademp.js                                                                         
 Autor: Cristian Filipe                                                                  
 Data : Novembro/2013   
 
 Alterações:  
	 29/01/2014 - Desabilita campo opção, exceto para relatório, em LiberaFormulario         
                  Correção de evento click da function layoutImpressao() (Carlos)            
                                                                                           																					   
	 25/03/2014 - Correção para impressão correta das empresas ordenadas por código ou pelo   
                   nome (Carlos)                                                               
                                                                                         
     05/08/2014 - Inclusão da opção de Pesquisa de Empresas (Vanessa)                         
                                                                                      
     19/01/2015 - Retirando a atualizacao do campo dtfchfol pois o mesmo nao retornava       
                  registro e substitua o valor atual da exibicao do campo                    
                  (Andre Santos - SUPERO)                                                     
                                                                                         
     03/07/2015 - Projeto 158 - Folha de pagamento                                           
                 (Andre Santos - SUPERO)                                                     
                                                                                        
     08/07/2015 - Adicionado validacao de dias na parte de tarifas                           
                  (Jorge/Elton - emergencial)                        

	 15/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
	 
	 25/11/2015 - Ajustando tabela para exibir uma mensagem
			      quando nao existir nenhum convênio na lista
				  (Andre Santos - SUPERO)

	 17/05/2016 - Permitir a digitacao do codigo da empresa na opcao Alterar.
                  Correcao do campo dtfchfol. Criacao do campo dtlimdeb. (Jaison/Marcos)          
          
	 07/04/2016 - Incluido a chamada da class layoutPadrao para validar o campo email que 
				  estava permitindo incluir caracteres invalidos. (Gisele Neves RKAM  - #426082)

     27/04/2016 - Ajustado nome da DIV para conseguir buscar corretamento o tipo de ordenacao 
                  da geracao do relatorio SD430677 (Odirlei-AMcom)

     29/07/2016 - Corrigi o tratamento de retorno dos dados consultados pela pesquisa de empresa
                  na funcao buscaEmpresas(). SD 491925 (Carlos R.)
     04/08/2016 - SD495726 Folha: Correcao cdempres na inclusao (Guilherme/SUPERO) 

     26/08/2016 - Ajuste emergencial referente ao chamado 511180 (Kelvin)

     30/08/2016 - Ajuste emergencial referente ao chamado 512307 (Kelvin)

     01/09/2016 - Ajuste substring do response na consulta de empresas (Douglas - EMERGENCIAL)

     18/10/2016 - Remocao dos caracteres invalidos na inserção/alteração dos dados. (SD 520605 - Kelvin)

     25/10/2016 - SD542975 - Tratamento correto do Nrdconta e validação (Guilherme/SUPERO)

	 06/01/2017 - SD588833 - No cadastro das empresas, não pode haver outra empresa na mesma 
				  cooperativa com a mesma NRDCONTA. A validação não estava funcionando quando 
				  a conta era selecionada via opção zoom. Ajuste realizado! (Renato - Supero)
				  
	 27/03/2017 - Incluido botão "Acessa DigiDOC" e adicionado function "dossieDigdoc".
				  (Projeto 357 - Reinert)

     06/08/2018 - Ajuste na formatação do campo e-mail (Andrey Formigari - Mouts)
     28/02/2019 - Projeto 437 Consignado AMcom - JDB (ID 20190208_437) - Ajutes conforme changeset feito por outra empresa	 (14/09/2018 - Tratamento para o projeto 437 Consignado (incluir  flnecont e tpmodcon,  remover indescsg))
     12/08/2019 - P437 Ajustes yes == 1 AMcom - JDB
************************************************************************************************/

//P437 s2
//Variavel parametro Cooperativa com Consignado
var CooperConsig ;

// Definição de algumas variáveis globais
var cddopcao, cTodosCabecalho;

//Formulário Cabeçalho
var frmCab = 'frmCab';

var lisconta = "";

// Formulario Informações Empresa Campos/Label
var
// Campos
        cCdempres,
        cNmextemp,
        cIdtpempr,
        cNmresemp,
        cNrdconta,
        cNmextttl,
        cNmcontat,
        cNmcontat,
        cDsendemp,
        cNrendemp,
        cDscomple,
        cNmbairro,
        cNmcidade,
        cCdufdemp,
        cNrcepend,
        cNrdocnpj,
		//P437
		cNrdddemp,
        cNrfonemp,
        cNrfaxemp,
        cDsdemail,
//campos Old (para a procedure Gera_Log)
        old_cCdempres,
        old_cNmextemp,
        old_cIdtpempr,
        old_cNmresemp,
        old_cNrdconta,
        old_cNmextttl,
        old_cNmcontat,
        old_cDsendemp,
        old_cNrendemp,
        old_cDscomple,
        old_cNmbairro,
        old_cNmcidade,
        old_cCdufdemp,
        old_cNrcepend,
        old_cNrdocnpj,
		//P437
		old_cNrdddemp,
        old_cNrfonemp,
        old_cNrfaxemp,
        old_cDsdemail;

// Formulario Informações tarifa
var cTodosFormTarifa,
// campos
        cFlgpagto,
        cCdempfol,
        cDdpgtmes,
        cDdpgthor,
        cVltrfsal,
//campos Old (para a procedure Gera_Log)
        old_cFlgpagto,
        old_cCdempfol,
        old_cDdpgtmes,
        old_cDdpgthor,
        old_cVltrfsal;

var cTodosFormIb,
// campos
        cFlgpgtib,
        cCdcontar,
        cDscontar,
        cVllimfol,
//campos Old (para a procedure Gera_Log)
        cDtultufp,
        old_cFlgpgtib,
        old_cCdcontar,
        old_cVllimfol;


// Formulario Informações Emprestimo
var cTodosFormEmprestimo,
// Campos
        cIndescsg,
        cDtfchfol,
        cFlgarqrt,
        cFlgvlddv,
        cDdmesnov,
        cDtlimdeb,
        cTpconven,
        cNrlotfol,
        cNrlotemp,
        cNrlotcot,
        cTpdebemp,
        cTpdebcot,
        cDtavsemp,
        cDtavscot,
		// -> ID 20190208_437
		cTpmodcon,
        cFlnecont,
		//<-
// Campos  old (Para a procedure Gera_log)
        old_cIndescsg,
        old_cDtfchfol,
        old_cFlgarqrt,
        old_cFlgvlddv,
        old_cDdmesnov,
        old_cDtlimdeb,
        old_cTpconven,
        old_cNrlotcot,
        old_cNrlotemp,
        old_cNrlotfol,
        old_cTpdebemp,
        old_cTpdebcot,
        old_cDtavsemp,
        old_cDtavscot,
		// -> ID 20190208_437
		old_cTpmodcon,
        old_cFlnecont;
		//<-




$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#' + frmCab));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    return false;

});

function estadoInicial() {

    trocaBotao('Prosseguir');
    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    $('#frmInfEmpresa').css({'display': 'none'});
    $('#frmInfTarifa').css({'display': 'none'});
    $('#frmInfIb').css({'display': 'none'});
    $('#frmInfEmprestimo').css({'display': 'none'});

    $('#divBotoes', '#divTela').css({'display': 'none'});

    $('#nmdbusca', '#frmPesquisaEmpresa').val('');

    formataCabecalho();

    // Remover class campoErro
    $('input,select', '#frmCab').removeClass('campoErro');

    cTodosCabecalho.limpaFormulario();
    cCddopcao.val(cddopcao);

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    cTodosCabecalho.desabilitaCampo();

    $('#cddopcao', '#frmCab').habilitaCampo();
    $('#cddopcao', '#frmCab').focus();
    fechaRotina($('#divPesquisaEmpresa'));
    fechaRotina($('#divTabEmpresas'));

    controlaFoco();
	
	if (executandoProdutos) {
		 $('#cddopcao', '#frmCab').val("I");
		LiberaFormulario();
	}	
	//P437 s2
	CooperConsig = document.getElementById('glb_val_cooper_consignado').value ;
	
}

function formataCabecalho() {

    // Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);


    var cNmextemp = $('#nmextemp', '#frmInfEmpresa');
    var cIdtpempr = $('#idtpempr', '#frmInfEmpresa');
    var cNmresemp = $('#nmresemp', '#frmInfEmpresa');
    var cNrdconta = $('#nrdconta', '#frmInfEmpresa');
    var cNmextttl = $('#nmextttl', '#frmInfEmpresa');
    var cNmcontat = $('#nmcontat', '#frmInfEmpresa');
    var cDsendemp = $('#dsendemp', '#frmInfEmpresa');
    var cDscomple = $('#dscomple', '#frmInfEmpresa');
    var cNmbairro = $('#nmbairro', '#frmInfEmpresa');
    var cNmcidade = $('#nmcidade', '#frmInfEmpresa');
    var cCdufdemp = $('#cdufdemp', '#frmInfEmpresa');
	//P437
	var cNrdddemp = $('#nrdddemp', '#frmInfEmpresa');
    var cNrfonemp = $('#nrfonemp', '#frmInfEmpresa');
    var cNrfaxemp = $('#nrfaxemp', '#frmInfEmpresa');
    var cDsdemail = $('#dsdemail', '#frmInfEmpresa');

    var cDdmesnov = $('#ddmesnov', '#frmInfTarifa');
    var cDdpgtmes = $('#ddpgtmes', '#frmInfTarifa');
    var cDdpgthor = $('#ddpgthor', '#frmInfTarifa');

    var cFlgpgtib = $('#flgpgtib', '#frmInfIb');
    var cDtultufp = $('#dtultufp', '#frmInfIb');
    var cCdcontar = $('#cdcontar', '#frmInfIb');
    var cDscontar = $('#dscontar', '#frmInfIb');
    var cVllimfol = $('#vllimfol', '#frmInfIb');

    var cDtfchfol = $('#dtfchfol', '#frmInfEmprestimo');
    var cCdempfol = $('#cdempfol', '#frmInfEmprestimo');

    cNmextemp.attr('maxlength', '35');
    cNmresemp.attr('maxlength', '15');
    cNrdconta.attr('maxlength', '10');
    cNmextttl.attr('maxlength', '60');
    cNmcontat.attr('maxlength', '60');
    cDsendemp.attr('maxlength', '40');
    cDscomple.attr('maxlength', '50');
    cNmbairro.attr('maxlength', '15');
    cNmcidade.attr('maxlength', '25');
    cCdufdemp.attr('maxlength', '2');
	//P437
	cNrdddemp.attr('maxlength', '2');
    cNrfonemp.attr('maxlength', '15');
    cNrfaxemp.attr('maxlength', '15');
    cDsdemail.attr('maxlength', '60');

    cDdmesnov.attr('maxlength', '2');
    cDdpgtmes.attr('maxlength', '2');
    cDdpgthor.attr('maxlength', '2');

    //cDsdemail.addClass('email');
    cDtfchfol.addClass('campo').css({ 'width': '30px' }).attr('maxlength', '2').setMask("INTEGER", "99");
    cCdempfol.addClass('campo').css({'width':'130px'}).attr('maxlength', '4').setMask("INTEGER", "99");

    //Ajusta layout para o Internet Explorer
    if ($.browser.msie) {
        rCddopcao.css('width', '40px');
    } else {
        rCddopcao.css('width', '44px');
    }

    cCddopcao.css({'width': '375px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();

	
    layoutPadrao();
    return false;
}

function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            LiberaFormulario();
            return false;
        }
    });

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            LiberaFormulario();
            return false;
        }
    });

}

// -> ID 20190208_437
function validaPermissao(){
	var validaPerm = true;
	$.ajax({		
		type: "POST",
        async: false,
		url: UrlSite + "telas/cademp/validaPermissao.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
	return validaPerm;
}
//<-

function LiberaFormulario() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    // Desabilita campo opção, exceto para relatório
    if (cCddopcao.val() != 'R') {
        $('#cddopcao', '#frmCab').desabilitaCampo();
    }

    cddopcao = cCddopcao.val();
	
	// -> ID 20190208_437
	if (!(validaPermissao()))
		return false;
	//<-

    formataInfEmpresas();

    if (cddopcao=="T") {
        mostraPesquisaEmpresa('cddopcao','frmPesquisaEmpresa','');
        return false;
    }

    var cTodosFormEmpresa;

    cTodosFormEmpresa = $('input[type="text"],select,checkbox', '#frmInfEmpresa');
    cTodosFormEmpresa.desabilitaCampo();
    cTodosFormEmpresa.limpaFormulario();

    cTodosFormTarifa = $('input[type="text"],select,checkbox', '#frmInfTarifa');
    cTodosFormTarifa.desabilitaCampo();
    cTodosFormTarifa.limpaFormulario();

    cTodosFormIb = $('input[type="text"],select,checkbox', '#frmInfIb');
    cTodosFormIb.desabilitaCampo();
    cTodosFormIb.limpaFormulario();

    cTodosFormEmprestimo = $('input[type="text"],select,input[type="checkbox"]', '#frmInfEmprestimo');
    cTodosFormEmprestimo.desabilitaCampo();
    cTodosFormEmprestimo.limpaFormulario();

    layoutPadrao();
    controlaOperacao();
    return false;
}

function formataInfEmpresas() {

    /*Formatando Formulario empresa*/
    var rCdempres = $('label[for="cdempres"]', '#frmInfEmpresa');
    var rNmextemp = $('label[for="nmextemp"]', '#frmInfEmpresa');
    var rIdtpempr = $('label[for="idtpempr"]', '#frmInfEmpresa');
    var rNmresemp = $('label[for="nmresemp"]', '#frmInfEmpresa');
    var rNrdconta = $('label[for="nrdconta"]', '#frmInfEmpresa');
    var rNmcontat = $('label[for="nmcontat"]', '#frmInfEmpresa');
    var rDsendemp = $('label[for="dsendemp"]', '#frmInfEmpresa');
    var rNrendemp = $('label[for="nrendemp"]', '#frmInfEmpresa');
    var rDscomple = $('label[for="dscomple"]', '#frmInfEmpresa');
    var rNmbairro = $('label[for="nmbairro"]', '#frmInfEmpresa');
    var rNmcidade = $('label[for="nmcidade"]', '#frmInfEmpresa');
    var rCdufdemp = $('label[for="cdufdemp"]', '#frmInfEmpresa');
    var rNrcepend = $('label[for="nrcepend"]', '#frmInfEmpresa');
    var rNrdocnpj = $('label[for="nrdocnpj"]', '#frmInfEmpresa');
	//P437
	var rNrdddemp = $('label[for="nrdddemp"]', '#frmInfEmpresa');
    var rNrfonemp = $('label[for="nrfonemp"]', '#frmInfEmpresa');
    var rNrfaxemp = $('label[for="nrfaxemp"]', '#frmInfEmpresa');
    var rDsdemail = $('label[for="dsdemail"]', '#frmInfEmpresa');

    rCdempres.css({width: "90px"});
    rNmextemp.css({width: "90px"});
    rIdtpempr.css({width: "235px"});
    rNmresemp.css({width: "90px"});
    rNrdconta.css({width: "90px"});
    rNmcontat.css({width: "90px"});
    rDsendemp.css({width: "90px"});
    rNrendemp.css({width: "90px"});
    rDscomple.css({width: "90px"});
    rNmbairro.css({width: "90px"});
    rNmcidade.css({width: '120px'});
    rCdufdemp.css({width: "90px"});
    rNrcepend.css({width: '62px'});
    rNrdocnpj.css({width: '90px'});
	//P437
	rNrdddemp.css({width: "90px"});
    rNrfonemp.css({width: "62px"});
    rNrfaxemp.css({width: '44px'});
    rDsdemail.css({width: "90px"});

    cCdempres = $('#cdempres', '#frmInfEmpresa');
    cNmextemp = $('#nmextemp', '#frmInfEmpresa');
    cIdtpempr = $('#idtpempr', '#frmInfEmpresa');
    cNmresemp = $('#nmresemp', '#frmInfEmpresa');
    cNrdconta = $('#nrdconta', '#frmInfEmpresa');
    cNmextttl = $('#nmextttl', '#frmInfEmpresa');
    cNmcontat = $('#nmcontat', '#frmInfEmpresa');
    cDsendemp = $('#dsendemp', '#frmInfEmpresa');
    cNrendemp = $('#nrendemp', '#frmInfEmpresa');
    cDscomple = $('#dscomple', '#frmInfEmpresa');
    cNmbairro = $('#nmbairro', '#frmInfEmpresa');
    cNmcidade = $('#nmcidade', '#frmInfEmpresa');
    cCdufdemp = $('#cdufdemp', '#frmInfEmpresa');
    cNrcepend = $('#nrcepend', '#frmInfEmpresa');
    cNrdocnpj = $('#nrdocnpj', '#frmInfEmpresa');
	//P437
	cNrdddemp = $('#nrdddemp', '#frmInfEmpresa');
    cNrfonemp = $('#nrfonemp', '#frmInfEmpresa');
    cNrfaxemp = $('#nrfaxemp', '#frmInfEmpresa');
    cDsdemail = $('#dsdemail', '#frmInfEmpresa');

    cCdempres.css({width: '50px'}).setMask("INTEGER", "zzzz");
    cNmextemp.css({width: '423px'});
    cIdtpempr.css({width: '120px'});
    cNmresemp.css({width: '423px'});
    cNrdconta.css({width: '80px'});
    cNmextttl.css({width: '323px'});
    cNmcontat.css({width: '423px'});
    cDsendemp.css({width: '265px'});
    cNrendemp.css({width: '65px'}).addClass('numerocasa');
    cDscomple.css({width: '423px'});
    cNmbairro.css({width: '150px'});
    cNmcidade.css({width: '150px'});
    cCdufdemp.css({width: '30px'}).addClass('alpha ');
    cNrcepend.css({width: '100px'}).addClass('cep');
    cNrdocnpj.css({width: '135px'}).addClass('cnpj');
	//P437
	cNrdddemp.css({width: '30px'}).setMask("INTEGER", "zz");
    cNrfonemp.css({width: '131px'});
    cNrfaxemp.css({width: '150px'});
    cDsdemail.css({width: '423px'});

	//cDsdemail.addClass('email');

    highlightObjFocus($('#frmInfEmpresa'));
    /*Formatando Formulario empresa*/

    /*Formatando Formulario tarifa*/
    var rFlgpagto = $('label[for="flgpagto"]', '#frmInfTarifa');
    var rCdempfol = $('label[for="cdempfol"]', '#frmInfTarifa');
    var rVltrfsal = $('label[for="vltrfsal"]', '#frmInfTarifa');
    var rDdpgtmes = $('label[for="ddpgtmes"]', '#frmInfTarifa');
    var rDdpgthor = $('label[for="ddpgthor"]', '#frmInfTarifa');

    rFlgpagto.css({width: '210px'});
    rCdempfol.css({width: '210px'});
    rVltrfsal.css({width: '210px'});
    rDdpgtmes.css({width: '210px'});
    rDdpgthor.css({width: '210px'});

    cFlgpagto = $('#flgpagto', '#frmInfTarifa');
    cCdempfol = $('#cdempfol', '#frmInfTarifa');
    cVltrfsal = $('#vltrfsal', '#frmInfTarifa');
    cDdpgtmes = $('#ddpgtmes', '#frmInfTarifa');
    cDdpgthor = $('#ddpgthor', '#frmInfTarifa');

    cCdempfol.attr('maxlength', '4').setMask("INTEGER", "zzzz");
    cVltrfsal.css({width: '120px'}).setMask('DECIMAL', 'zzzzzzzzz,zz', ',', '');
    cDdpgtmes.css({width: '30px'}).setMask('INTEGER','99');
    cDdpgthor.css({width: '30px'}).setMask('INTEGER','99');

    highlightObjFocus($('#frmInfTarifa'));
    /*Formatando Formulario tarifa*/

    /*Formatando Formulario Ib*/
    var rFlgpgtib = $('label[for="flgpgtib"]', '#frmInfIb');
    var rCdcontar = $('label[for="cdcontar"]', '#frmInfIb');
    var rVllimfol = $('label[for="vllimfol"]', '#frmInfIb');

    rFlgpgtib.css({width: '210px'});
    rCdcontar.css({width: '210px'});
    rVllimfol.css({width: '210px'});

    cFlgpgtib = $('#flgpgtib', '#frmInfIb');
    cCdcontar = $('#cdcontar', '#frmInfIb');
    cDscontar = $('#dscontar', '#frmInfIb');
    cVllimfol = $('#vllimfol', '#frmInfIb');

    cCdcontar.css({width: '80px'});
    cDscontar.css({width: '200px'});
    cCdcontar.attr('maxlength', '4').setMask("INTEGER", "0000");
    cVllimfol.css({width: '100px'}).setMask('DECIMAL', 'zzzzzzzzz,zz', ',', '');

    highlightObjFocus($('#frmInfIb'));
    /*Formatando Formulario Ib*/

    /*Formatando Formulario Emprestimo*/
    var rIndescsg = $('label[for="indescsg"]', '#frmInfEmprestimo');
    var rDtfchfol = $('label[for="dtfchfol"]', '#frmInfEmprestimo');
    var rFlgarqrt = $('label[for="flgarqrt"]', '#frmInfEmprestimo');
    var rFlgvlddv = $('label[for="flgvlddv"]', '#frmInfEmprestimo');
    var rDdmesnov = $('label[for="ddmesnov"]', '#frmInfEmprestimo');
    var rDtlimdeb = $('label[for="dtlimdeb"]', '#frmInfEmprestimo');
    var rTpconven = $('label[for="tpconven"]', '#frmInfEmprestimo');
    var rNrlotcot = $('label[for="nrlotcot"]', '#frmInfEmprestimo');
    var rNrlotemp = $('label[for="nrlotemp"]', '#frmInfEmprestimo');
    var rNrlotfol = $('label[for="nrlotfol"]', '#frmInfEmprestimo');
    var rTpdebemp = $('label[for="tpdebemp"]', '#frmInfEmprestimo');
    var rDtavsemp = $('label[for="dtavsemp"]', '#frmInfEmprestimo');
    var rTpdebcot = $('label[for="tpdebcot"]', '#frmInfEmprestimo');
    var rDtavscot = $('label[for="dtavscot"]', '#frmInfEmprestimo');
	
	// -> ID 20190208_437
	var rTpmodcon = $('label[for="tpmodcon"]', '#frmInfEmprestimo');
    var rFlnecont = $('label[for="flnecont"]', '#frmInfEmprestimo');
	// <-

    rIndescsg.css({width: '210px'});
    rDtfchfol.css({width: '199px'});
    rFlgarqrt.css({width: '210px'});
    rFlgvlddv.css({width: '210px'});
    rDdmesnov.css({width: '210px'});
    rDtlimdeb.css({width: '193px'});
    rTpconven.css({width: '150px'});
    rNrlotcot.css({width: '80px'});
    rNrlotemp.css({width: '110px'});
    rNrlotfol.css({width: '100px'});
    rTpdebemp.css({width: '150px'});
    rDtavsemp.css({width: '152px'});
    rTpdebcot.css({width: '150px'});
    rDtavscot.css({width: '152px'});
	// -> ID 20190208_437
	rTpmodcon.css({width: '190px'});
    rFlnecont.css({width: '190px'});
	//<-

    cIndescsg = $('#indescsg', '#frmInfEmprestimo');
    cDtfchfol = $('#dtfchfol', '#frmInfEmprestimo');
    cFlgarqrt = $('#flgarqrt', '#frmInfEmprestimo');
    cFlgvlddv = $('#flgvlddv', '#frmInfEmprestimo');
    cDdmesnov = $('#ddmesnov', '#frmInfEmprestimo');
    cDtlimdeb = $('#dtlimdeb', '#frmInfEmprestimo');
    cTpconven = $('#tpconven', '#frmInfEmprestimo');
    cNrlotcot = $('#nrlotcot', '#frmInfEmprestimo');
    cNrlotemp = $('#nrlotemp', '#frmInfEmprestimo');
    cNrlotfol = $('#nrlotfol', '#frmInfEmprestimo');
    cTpdebemp = $('#tpdebemp', '#frmInfEmprestimo');
    cDtavsemp = $('#dtavsemp', '#frmInfEmprestimo');
    cTpdebcot = $('#tpdebcot', '#frmInfEmprestimo');
    cDtavscot = $('#dtavscot', '#frmInfEmprestimo');
	// -> ID 20190208_437
	cTpmodcon = $('#tpmodcon', '#frmInfEmprestimo');
    cFlnecont = $('#flnecont', '#frmInfEmprestimo');
	//<-
	
    cDdmesnov.css({width: '30px'}).setMask('INTEGER','99');
    cDtlimdeb.css({width: '30px'}).setMask('INTEGER','99');
    cTpconven.css({width: '355px'});
    cNrlotfol.css({width: '70px'});
    cNrlotemp.css({width: '70px'});
    cNrlotcot.css({width: '70px'});
    cTpdebemp.css({width: '120px'});
    cDtavsemp.addClass('data').css({'width': '80px', 'float': 'left'});
    cTpdebcot.css({width: '120px'});
    cDtavscot.addClass('data').css({'width': '80px', 'float': 'left'});
	// -> ID 20190208_437
	cTpmodcon.css({width: '120px'});
	//<-

    highlightObjFocus($('#frmInfEmprestimo'));
    /*Formatando Formulario Emprestimo*/
	layoutPadrao();
}

function controlaOperacao() {
	
    // verifica se existe display block no formulario de empresas
    if (($('#frmInfEmpresa').css('display') == "block") && cddopcao) {

        /* validacao */
        if ((($.trim(cCdempres.val()).length == 0) || cCdempres.val() == 0) && (cddopcao != 'I')) {
            showError('error','C&oacute;digo inv&aacute;lido!','Campo obrigat&oacute;rio','$("#cdempres","#frmInfEmpresa").focus();');
            return false;
        }

        if (cddopcao == 'I' || cddopcao == 'A') {
			
			cNrdocnpj = $('#nrdocnpj', '#frmInfEmpresa');
            cnpj = normalizaNumero(cNrdocnpj.val());
            cFlgpagto.habilitaCampo();
            conta = normalizaNumero(cNrdconta.val());

            if (cNmextemp.val() == "") {
                showError('error','Raz&atilde;o social deve ser informada!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nmextemp","#frmInfEmpresa").focus();');
                return false;
            }

            if (cNmresemp.val() == "") {
                showError('error','Nome fantasia deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nmresemp","#frmInfEmpresa").focus();');
                return false;
            }
			
            if (cNmcontat.val() == "") {
                showError('error','Nome do contato da empresa deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nmcontat","#frmInfEmpresa").focus();');
                return false;
            }

            if (cnpj != 0) {
                // Valida o CNPJ
                if (!validaCpfCnpj(cnpj, 2)) {
                    showError('error', 'CNPJ inv&aacute;lido.',
                            'Valida&ccedil;&atilde;o CNPJ',
                            '$("#nrdocnpj","#frmInfEmpresa").focus();');
                    return false;
                }
				// -> ID 20190208_437
				if (cddopcao == 'I') {
					if (!validaCNPJCadastrado(cnpj))
					{
						return false;
					}
				}
				//<-
				
            }else{
                showError('error','campo de CNPJ ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nrdocnpj","#frmInfEmpresa").focus();');
                return false;
            }
			
			//P437
			if (cNrdddemp.val() == 0) {
                showError('error','N&uacute;mero de DDD deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nrdddemp","#frmInfEmpresa").focus();');
                return false;
            }

            if (cNrfonemp.val() == 0) {
                showError('error','N&uacute;mero de Telefone deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nrfonemp","#frmInfEmpresa").focus();');
                return false;
            }

            if (cDsdemail.val() != '') {
                if (!validaEmailCademp(cDsdemail.val())) {
                    showError('error', 'E-mail inv&aacute;lido.',
                            'Valida&ccedil;&atilde;o e-mail',
                            '$("#dsdemail","#frmInfEmpresa").focus();');
                    return false;
                }
            }else{
                showError('error','Campo de E-MAIL deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#dsdemail","#frmInfEmpresa").focus();');
                return false;

            }
        }

        trocaBotao('Prosseguir');
        $('#frmInfEmpresa').css({'display': 'none'});
        $('#frmInfTarifa').css({'display': 'block'});

        if (cddopcao == 'I') {
            cNrlotcot.val('80' + cCdempres.val() + '0');
            cNrlotemp.val('50' + cCdempres.val() + '0');
            cNrlotfol.val('90' + cCdempres.val() + '0');

            cDdpgtmes.val('01');
            cDdpgthor.val('01');
            cDdmesnov.val('15');
            cDtlimdeb.val('10');
        }else
        if (cddopcao == "C") {
            cFlgpagto.desabilitaCampo();
            $('#btSalvar', '#divBotoes').focus();
        }else {
            cFlgpagto.focus();
        }

        return false;
    }else
    if (($('#frmInfTarifa').css('display') == "block") && cddopcao) {

        if (cddopcao == 'I' || cddopcao == 'A') {
			
			if (cFlgpagto.is(":checked") && (cCdempfol.val()==0 || cCdempfol.val()=="")) {
				showError('error','Codigo da Empresa Sistema Folha deve ser maior que ZERO!','Campo obrigat&oacute;rio','$("#cdempfol","#frmInfTarifa").focus();');
                return false;				
			}else
			if	(!(cFlgpagto.is(":checked")) && cCdempfol.val()>0) {
				showError('error','Codigo da Empresa Sistema Folha deve ser igual a ZERO','Campo obrigat&oacute;rio','$("#cdempfol","#frmInfTarifa").focus();');
                return false;
			}
			
            //validar campos
            if(($.trim(cDdpgtmes.val()).length == 0) || (cDdpgtmes.val() <= 0 || cDdpgtmes.val() > 28)){
                showError('error','Dia inv&aacute;lido!','Campo obrigat&oacute;rio','$("#ddpgtmes","#frmInfTarifa").focus();');
                return false;
            }else if(($.trim(cDdpgthor.val()).length == 0) || (cDdpgthor.val() <= 0 || cDdpgthor.val() > 28)){
                showError('error','Dia inv&aacute;lido!','Campo obrigat&oacute;rio','$("#ddpgthor","#frmInfTarifa").focus();');
                return false;
            }
        }

        $('#frmInfTarifa').css({'display': 'none'});
        $('#frmInfIb').css({'display': 'block'});

        if (cddopcao == "C") {
            cFlgpgtib.desabilitaCampo();
            $('#btSalvar', '#divBotoes').focus();
        }else{
            cFlgpgtib.habilitaCampo();
        }
        return false;
    }else
    if (($('#frmInfIb').css('display') == "block") && cddopcao){

        if (cddopcao == 'I' || cddopcao == 'A') {

            if (conta == 0 && cFlgpgtib.is(":checked")) {
                showError('error','Conta d&eacutebito da empresa deve ser informado!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nrdconta","#frmInfEmpresa").focus();');
                return false;
            }

            if (cFlgpgtib.is(":checked")) {
                if (cCdcontar.val() == "" || cCdcontar.val() == 0) {
                    showError('error','Conv&ecirc;nio T&aacute;rifario deve ser informado!',
                              'Campo Obrigat&oacute;rio!',
                              '$("#cdcontar","#frmInfIb").focus();');
                    return false;
                }

                if (cVllimfol.val().replace(',','') == 0 || cVllimfol.val() == "") {
                    showError('error','Valor de limite deve ser informado!',
                              'Campo Obrigat&oacute;rio!',
                              '$("#vllimfol","#frmInfIb").focus();');
                    return false;
                }
            }
        }

        $('#frmInfIb').css({'display': 'none'});
        $('#frmInfEmprestimo').css({'display': 'block'});

        if (cddopcao == "C") {
            $('#btSalvar', '#divBotoes').focus();
        }else {
            cIndescsg.focus();
        }

        cNrlotcot.desabilitaCampo();
        cNrlotemp.desabilitaCampo();
        cNrlotfol.desabilitaCampo();

        if (cddopcao == "C") {
            trocaBotao('Carregar Empresas');
            $('#btSalvar', '#divBotoes').focus();
        }else
        if (cddopcao == "A") {
            trocaBotao('Alterar');
        }else
        if (cddopcao == "I") {
            trocaBotao('Incluir');
        }

        return false;
    }else
    if (($('#frmInfEmprestimo').css('display') == "block") && cddopcao) {

        if (cddopcao == "A" || cddopcao == "I") {
            if(($.trim(cDdmesnov.val()).length == 0) || (cDdmesnov.val() <= 0 || cDdmesnov.val() > 28)){
                showError('error','Dia inv&aacute;lido!','Campo obrigat&oacute;rio','$("#ddmesnov","#frmInfEmprestimo").focus();');
                return false;
            }

            if(($.trim(cDtlimdeb.val()).length == 0) || (cDtlimdeb.val() <= 0 || cDtlimdeb.val() > 20)){
                showError('error','Dia inv&aacute;lido!','Campo obrigat&oacute;rio','$("#dtlimdeb","#frmInfEmprestimo").focus();');
                return false;
            }

            if (cFlgpgtib.is(':checked')) {
                if (cNrdconta.val() == 0) {
                    showError('error','N&uacute;mero de conta d&eacute;bito inv&aacute;lida!',
                              'Campo Obrigat&oacute;rio!',
                              '$("#nrdconta","#frmInfEmpresa").focus();');
                    return false;
                }
            }
			
            // Se estiver checado, efetuamos as validacoes necessarias
			//P437 s2
            if (CooperConsig != 'S'){
				if (cIndescsg.is(":checked") && (cDtfchfol.val()=="" || (cDtfchfol.val() <= 0 || cDtfchfol.val() > 28))){
					showError('error','Dia Fechamento Folha deve ser entre 1 e 28.','Campo obrigat&oacute;rio','$("#dtfchfol","#frmInfEmprestimo").focus();');
					return false;
				}
			}else{
				if (cFlnecont.is(":checked") && (cDtfchfol.val()=="" || (cDtfchfol.val() <= 0 || cDtfchfol.val() > 28))){			
					showError('error','Dia Fechamento Folha deve ser entre 1 e 28.','Campo obrigat&oacute;rio','$("#dtfchfol","#frmInfEmprestimo").focus();');
					return false;
				}
			}
        }

        if (cddopcao == "C") {
            $('#frmInfEmprestimo').css({'display': 'none'});
            $('#divBotoes', '#divTela').css({'display': 'none'});
            mostraRotina('empresa');
            return false;
        }else
        if (cddopcao == "A") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "alteraInclui();", "hideMsgAguardo();", "sim.gif", "nao.gif");
            return false;
        } else
        if (cddopcao == "I") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "define_cdempres();", "hideMsgAguardo();", "sim.gif", "nao.gif");
            return false;
        }
    }

    if ((cddopcao == "A") || (cddopcao == "C")) {
        controlaFocoFormulariosEmpresa();
        return false;
    } else if (cddopcao == "I") {
        buscaEmpresas();
        return false;
    } else if (cddopcao == "R") {
        showConfirmacao("Deseja imprimir a rela&ccedil;&atilde;o de empresas?", "Confirma&ccedil;&atilde;o - Ayllos", "mostraRotina('montaImpressao');", "estadoInicial();", "sim.gif", "nao.gif");
        return false;
    }
}

// Controla foco dos campos
function controlaFocoFormulariosEmpresa() {

    if (cddopcao == "T") {

        /* Se a empresa possui ou ja possuiu o servico de folha de pagto */
        if (!($('#flgpgtib', '#frmInfIb').val()=="yes" || ( !($('#flgpgtib', '#frmInfIb').val()=="yes") && $('#dtultufp', '#frmInfIb').val() != "" ))) {
            showError("error", "A empresa selecionada n&atilde;o possui servi&ccedil;o Folha de Pagamento", "Alerta - Ayllos", "estadoInicial();");
            return false;
        }
        impressaTermoServico();
        return false;
    }

    trocaBotao('Prosseguir');
    $('#divBotoes', '#divTela').css({'display': 'block'});
    $('#frmInfEmpresa').css({'display': 'block'});

    if (cddopcao == "C") {

        if ($('#cdempres', '#frmInfEmpresa').val() != '') {
            $('#cdempres', '#frmInfEmpresa').desabilitaCampo();
        }else {
            $('#cdempres', '#frmInfEmpresa').habilitaCampo();
        }

        // Foco no campo de empresa
        $('#cdempres', '#frmInfEmpresa').focus();

        cCdempres.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                if (cCdempres.val()!=""){
                    buscaEmpresas();
                }
                return false;
            }
        });

    }else
    if (cddopcao == "A" || cddopcao == "I") {

        /* Formulario Empresa */


        
        if (cddopcao == "A" && cCdempres.val() == '') {
            cCdempres.habilitaCampo();
            cCdempres.focus().unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 9 || e.keyCode == 13) {
                    if (cCdempres.val()!=""){
                        buscaEmpresas();
                        cIdtpempr.focus();
                    }
                    return false;
                }
            });
        } else {
        cTodosFormEmpresa = $('input[type="text"],select,checkbox', '#frmInfEmpresa');
        cTodosFormEmpresa.habilitaCampo();
        cNmextttl.desabilitaCampo();

        cTodosFormIb.habilitaCampo();
        cCdempres.desabilitaCampo();
        }

        cIdtpempr.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNmextemp.focus();
                return false;
            }
        });
        cNmextemp.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNmresemp.focus();
                return false;
            }
        });
        cNmresemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrdconta.focus();
                return false;
            }
        });
        
                    cNrdconta.unbind('change').bind('change', function(e) {

                        if (normalizaNumero(cNrdconta.val()) > 0){
                            buscaContaEmp(1);
					} else {

						showError('error','N&uacute;mero de conta d&eacute;bito inv&aacute;lida!',
                              'Campo Obrigat&oacute;rio!',
                              '$("#nrdconta","#frmInfEmpresa").focus();');
						cNrdconta.val("");
						return false;
                        }
                cNmcontat.focus();
                return false;
        });
        cNmcontat.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrdocnpj.focus();
                return false;
            }
        });
		cNrdocnpj.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDsendemp.focus();
                return false;
            }
        });
        cDsendemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrendemp.focus();
                return false;
            }
        });
        cNrendemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDscomple.focus();
                return false;
            }
        });
        cDscomple.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNmbairro.focus();
                return false;
            }
        });
        cNmbairro.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNmcidade.focus();
                return false;
            }
        });
        cNmcidade.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cCdufdemp.focus();
                return false;
            }
        });
        cCdufdemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrcepend.focus();
                return false;
            }
        });
        cNrcepend.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrdddemp.focus();
                return false;
            }
        }); 
		
		//P437
		cNrdddemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrfonemp.focus();
                return false;
            }
        });
		
        cNrfonemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cNrfaxemp.focus();
                return false;
            }
        });
        cNrfaxemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDsdemail.focus();
                return false;
            }
        });
        cDsdemail.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOperacao();
                return false;
            }
        });
        /*Formulario Empresa*/
        /*Formulario Tarifa*/
		layoutPadrao();
        cTodosFormTarifa.habilitaCampo();
        cNrlotcot.desabilitaCampo();
        cNrlotemp.desabilitaCampo();
        cNrlotfol.desabilitaCampo();

        cFlgpagto.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cCdempfol.focus();
                return false;
            }
        });
        cCdempfol.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cVltrfsal.focus();
                return false;
            }
        });
        cVltrfsal.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDdpgtmes.focus();
                return false;
            }
        });
        cDdpgtmes.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDdpgthor.focus();
                return false;
            }
        });
        cDdpgthor.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOperacao();
                return false;
            }
        });

        /*Formulario Tarifa*/
        /*Formulario Ib*/

        cFlgpgtib.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cCdcontar.focus();
                return false;
            }
        });
        cCdcontar.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cVllimfol.focus();
                return false;
            }
        });
        cVllimfol.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOperacao();
                return false;
            }
        });

        /*Formulario Ib*/
        /*Formulario Emprestimo */

        cTodosFormEmprestimo.habilitaCampo();
        cDtavsemp.desabilitaCampo();
        cDtavscot.desabilitaCampo();
		//P437 s2
		if (CooperConsig != 'S'){
			cIndescsg.unbind('keypress').bind('keypress', function(e) {
				if (e.keyCode == 9 || e.keyCode == 13) {
					cDtfchfol.focus();
					return false;
				}
			});
		}else{
			cFlnecont.unbind('keypress').bind('keypress', function(e) {
				if (e.keyCode == 9 || e.keyCode == 13) {
					cDtfchfol.focus();
					return false;
				}
			});
		}
		
		
        cDtfchfol.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cFlgarqrt.focus();
                return false;
            }
        });
        cFlgarqrt.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cFlgvlddv.focus();
                return false;
            }
        });
        cFlgvlddv.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDdmesnov.focus();
                return false;
            }
        });
        cDdmesnov.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cDtlimdeb.focus();
                return false;
            }
        });
        cDtlimdeb.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cTpconven.focus();
                return false;
            }
        });
        cTpconven.focus().unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cTpdebemp.focus();
                return false;
            }
        });
        cTpdebemp.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                cTpdebcot.focus();
                return false;
            }
        }).change(function() {
            var dat_calcu = $('#data-' + $(this).val(), '#frmInfEmprestimo').val();
            if (cddopcao == 'A') {
                // Se data armazenada for menor que data atual e estiver no mesmo mes
                if (dataParaNumero(old_cDtavsemp) < dataParaNumero(glb_dtmvtolt) && old_cDtavsemp.substr(3,2) == glb_dtmvtolt.substr(3,2)) {
                    dat_calcu = $('#data-proxmes-' + $(this).val(), '#frmInfEmprestimo').val();
                }
            }
            cDtavsemp.val(dat_calcu);
        });
        cTpdebcot.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOperacao();
                return false;
            }
        }).change(function() {
            var dat_calcu = $('#data-' + $(this).val(), '#frmInfEmprestimo').val();
            if (cddopcao == 'A') {
                // Se data armazenada for menor que data atual e estiver no mesmo mes
                if (dataParaNumero(old_cDtavscot) < dataParaNumero(glb_dtmvtolt) && old_cDtavscot.substr(3,2) == glb_dtmvtolt.substr(3,2)) {
                    dat_calcu = $('#data-proxmes-' + $(this).val(), '#frmInfEmprestimo').val();
                }
            }
            cDtavscot.val(dat_calcu);
        });
		
		// -> ID 20190208_437
		//Informacoes consignado
		
		if (CooperConsig == 'S'){
			//tpmodcon
			cTpmodcon.unbind('keypress').bind('keypress', function(e) {
				if (e.keyCode == 9 || e.keyCode == 13) {
					cDdmesnov.focus();
					return false;
				}
			});
			cTpmodcon.desabilitaCampo();
			if (cddopcao == "I") {
				cTpmodcon.val("");
			}
			
			//ddmesnov
			cDdmesnov.focus().unbind('keypress').bind('keypress', function(e) {
				if (e.keyCode == 9 || e.keyCode == 13) {
					cFlnecont.focus();
					return false;
				}
			});
			
			cFlnecont.desabilitaCampo();
			//flnecont
			cFlnecont.focus().unbind('keypress').bind('keypress', function(e) {
				if (e.keyCode == 9 || e.keyCode == 13) {
					controlaOperacao();
					return false;
				}
			});
		}
		//<-
		
        /*Formulario Emprestimo */
        
        if (cddopcao == "A" && cCdempres.val() == '') {
            $('#cdempres', '#frmInfEmpresa').focus();
        } else {
            $('#nmextemp', '#frmInfEmpresa').focus();
        }
    }
}

function dataParaNumero(data) {
	dia = data.substr(0,2); 
	mes = data.substr(3,2);
	ano = data.substr(6,4);
	return ano + mes + dia;
}

function trocaBotao(botao) {
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
	if (cddopcao == 'C')
		$('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" id="btndossie" onClick="dossieDigdoc(5);return false;">Dossi&ecirc; DigiDOC</a>');
    if (botao != '') {
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao"  id="btSalvar" onClick="controlaOperacao(); return false;" >' + botao + '</a>');
    }
    return false;
}





function btnVoltar() {
    // verifica se existe displayblock no formulario de empresas

    if ($('#frmInfEmpresa').css('display') == "block")
    {
		if (executandoProdutos)
			voltarAtenda();
		else
			estadoInicial();
        return false;
    } else if ($('#frmInfTarifa').css('display') == "block")
    {
        $('#frmInfTarifa').css({'display': 'none'});
        $('#frmInfEmpresa').css({'display': 'block'});
        $('#btSalvar', '#divBotoes').focus();
        return false;
    }else if ($('#frmInfIb').css('display') == "block")
    {
        $('#frmInfIb').css({'display': 'none'});
        $('#frmInfTarifa').css({'display': 'block'});
        $('#btSalvar', '#divBotoes').focus();
        return false;
    } else if ($('#frmInfEmprestimo').css('display') == "block")
    {
        trocaBotao('Prosseguir');
        $('#frmInfIb').css({'display': 'block'});
        $('#frmInfEmprestimo').css({'display': 'none'});
        $('#btSalvar', '#divBotoes').focus();
        return false;
    }
	if (executandoProdutos) 
		voltarAtenda();
	else
		estadoInicial();
    return false;
}


function monitorarCTRLV(evento, x_dsdemail) {
    var x_email = "";
    /*if ( (evento.ctrlKey && evento.keyCode == 86) || (evento.shiftKey && evento.keyCode == 45) || (!evento.shiftKey && !evento.keyCode) ){*/
    x_email = x_dsdemail.value;
    x_email = removeAcentos(x_email);
    x_email = x_email.replace(/[;]+/g, ',');
    x_email = x_email.replace(/[^a-zA-Z._,;@ 0-9]+/g, '');
    x_dsdemail.value = x_email;
    /*}*/
}


function alteraInclui() {

	//Variaveis para tratamento de caracteres invalidos
    var nmextemp, nmresemp, nmcontat, dsendemp, dscomple, nmbairro, nmcidade, cdufdemp, nrdddemp,nrfonemp, nrfaxemp, dsdemail;
		
    var cnpj;

    /* Altera valor nos campos Checkbox */
    // -> ID 20190208_437
	if (CooperConsig != 'S'){
		cIndescsg.is(':checked') ? cIndescsg.val(2) : cIndescsg.val(1);
	}else{
		cFlnecont.is(':checked') ? cFlnecont.val(1) : cFlnecont.val(0);
	}
	//<-
    cFlgpagto.is(':checked') ? cFlgpagto.val("yes") : cFlgpagto.val("no");
    cFlgpgtib.is(':checked') ? cFlgpgtib.val("yes") : cFlgpgtib.val("no");
    cFlgarqrt.is(':checked') ? cFlgarqrt.val("yes") : cFlgarqrt.val("no");
    cFlgvlddv.is(':checked') ? cFlgvlddv.val("yes") : cFlgvlddv.val("no");

    cNrdocnpj = $('#nrdocnpj', '#frmInfEmpresa');
    cnpj = normalizaNumero(cNrdocnpj.val());

	//Substitui/Remove os caracteres invalidos dos campos ao inserer ou alterar
	nmextemp = removeCaracteresInvalidos(cNmextemp.val().toUpperCase()); // Razao social
	nmresemp = removeCaracteresInvalidos(cNmresemp.val().toUpperCase()); // Nome fantazia
	nmcontat = removeCaracteresInvalidos(cNmcontat.val().toUpperCase()); // Contato
	dsendemp = removeCaracteresInvalidos(cDsendemp.val().toUpperCase()); // Endereço
	dscomple = removeCaracteresInvalidos(cDscomple.val().toUpperCase()); // Complemento
	nmbairro = removeCaracteresInvalidos(cNmbairro.val().toUpperCase()); // Bairro
	nmcidade = removeCaracteresInvalidos(cNmcidade.val().toUpperCase()); // Cidade
	cdufdemp = removeCaracteresInvalidos(cCdufdemp.val());				 // UF
	//P437
	nrdddemp = removeCaracteresInvalidos(cNrdddemp.val());				 // DDD
	nrfonemp = removeCaracteresInvalidos(cNrfonemp.val());				 // Telefone
	nrfaxemp = removeCaracteresInvalidos(cNrfaxemp.val());				 // Fax
	dsdemail = removeCaracteresInvalidos(cDsdemail.val());				 // Email

    /* Altera valor nos campos Checkbox */
    if (cddopcao == "A") {
        showMsgAguardo("Aguarde, alterando empresa...");
    } else {
        showMsgAguardo("Aguarde, incluindo empresa...");
    }

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cademp/altera_inclui.php",
        data: {
            cddopcao: cddopcao,
            //campos tela empresa
            cdempres: cCdempres.val(),
            nmextemp: nmextemp,
            idtpempr: cIdtpempr.val().toUpperCase(),
            nmresemp: nmresemp,
            nrdconta: cNrdconta.val().toUpperCase(),
            nmcontat: nmcontat,
            dsendemp: dsendemp,
            nrendemp: normalizaNumero(cNrendemp.val()),
            dscomple: dscomple,
            nmbairro: nmbairro,
            nmcidade: nmcidade,
            cdufdemp: cdufdemp,
            nrcepend: normalizaNumero(cNrcepend.val()),
            nrdocnpj: normalizaNumero(cNrdocnpj.val()),
			//P437
			nrdddemp: nrdddemp,
            nrfonemp: nrfonemp,
            nrfaxemp: nrfaxemp,
            dsdemail: dsdemail,
            //valores old tela empresa
            old_nmextemp: old_cNmextemp,
            old_idtpempr: old_cIdtpempr,
            old_nmresemp: old_cNmresemp,
            old_nrdconta: old_cNrdconta,
            old_nmcontat: old_cNmcontat,
            old_dsendemp: old_cDsendemp,
            old_nrendemp: normalizaNumero(old_cNrendemp),
            old_dscomple: old_cDscomple,
            old_nmbairro: old_cNmbairro,
            old_nmcidade: old_cNmcidade,
            old_cdufdemp: old_cCdufdemp,
            old_nrcepend: normalizaNumero(old_cNrcepend),
            old_nrdocnpj: normalizaNumero(old_cNrdocnpj),
			//P437
			old_nrdddemp: old_cNrdddemp,
            old_nrfonemp: old_cNrfonemp,
            old_nrfaxemp: old_cNrfaxemp,
            old_dsdemail: old_cDsdemail,
            ddmesnov: cDdmesnov.val(),
            dtlimdeb: cDtlimdeb.val(),
            ddpgtmes: cDdpgtmes.val(),
            ddpgthor: cDdpgthor.val(),
            flgpgtib: cFlgpgtib.val(),
            cdcontar: cCdcontar.val(),
            vllimfol: cVllimfol.val(),
            nrlotfol: cNrlotfol.val(),
            nrlotemp: cNrlotemp.val(),
            nrlotcot: cNrlotcot.val(),
            vltrfsal: cVltrfsal.val(),
            old_ddmesnov: old_cDdmesnov,
            old_dtlimdeb: old_cDtlimdeb,
            old_ddpgtmes: old_cDdpgtmes,
            old_ddpgthor: old_cDdpgthor,
            old_flgpgtib: old_cFlgpgtib,
            old_cdcontar: old_cCdcontar,
            old_vllimfol: old_cVllimfol,
            old_nrlotfol: old_cNrlotfol,
            old_nrlotemp: old_cNrlotemp,
            old_nrlotcot: old_cNrlotcot,
            old_vltrfsal: old_cVltrfsal,
            flgvlddv: cFlgvlddv.val(),
            tpconven: cTpconven.val(),
            tpdebemp: cTpdebemp.val(),
            tpdebcot: cTpdebcot.val(),
            indescsg: cIndescsg.val(),
            flgpagto: cFlgpagto.val(),
            flgarqrt: cFlgarqrt.val(),
            dtfchfol: cDtfchfol.val(),
            cdempfol: cCdempfol.val(),
            dtavsemp: cDtavsemp.val(),
            dtavscot: cDtavscot.val(),
			// -> ID 20190208_437
			tpmodcon: cTpmodcon.val(),
            flnecont: cFlnecont.val(),
            //<-
			old_flgvlddv: old_cFlgvlddv,
            old_tpconven: old_cTpconven,
            old_tpdebemp: old_cTpdebemp,
            old_tpdebcot: old_cTpdebcot,
            old_indescsg: old_cIndescsg,
            old_flgpagto: old_cFlgpagto,
            old_flgarqrt: old_cFlgarqrt,
            old_dtfchfol: old_cDtfchfol,
            old_cdempfol: old_cCdempfol,
            old_dtavsemp: old_cDtavsemp,
            old_dtavscot: old_cDtavscot,
			// -> ID 20190208_437
			old_tpmodcon: old_cTpmodcon,
            old_flnecont: old_cFlnecont,
			//<-
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    eval(response);
                    if (cFlgpgtib.val() != old_cFlgpgtib ) {
						var metodo = (executandoProdutos) ? "voltarAtenda();" : "estadoInicial();"; 
						
						showError("inform", "Opera&ccedil;&atilde;o efetuada com sucesso!</BR>C&oacute;digo: " +cCdempres.val() + "</BR>Favor efetuar a gera&ccedil;&atilde;o e digitaliza&ccedil;&atilde;o do termo dessa conta.", "Alerta - Ayllos", metodo);
                    }else{
						if (executandoProdutos) {
							voltarAtenda();
						} else {
							estadoInicial();
						}
                    }
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            }
        }
    });
}

// Define as informações da empresa
function define_cdempres() {

    var cdempres = '';

    // Mostra mensagem de aguardo.
    $urlFonte = "telas/cademp/define_cdempres.php";

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + $urlFonte,
        data: {
            cdempres: cdempres,
            cddopcao: cddopcao,
            nmdatela: 'CADEMP',
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
            }
        }
    });
}

// -> ID 20190208_437
// Valida a existencia de CNPJ já cadastrado
function validaCNPJCadastrado(cnpj) {
     var retornoValida = true;
	 $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/cademp/valida_cnpjempresa.php',
        data: {
            nrdocnpj: cnpj,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError(
                'error',
                'Nao foi possivel concluir a operacao.',
                'Alerta - Ayllos',
                '$("#nrdocnpj","#frmInfEmpresa").focus();');
			retornoValida = false;
        },
        success: function (response) {
            hideMsgAguardo();
			eval(response);
			if (cdemprescnpj != '')	
			{
				showError(
					'error',
					'CNPJ j&aacute; v&iacute;nculado &aacute; empresa ' + cdemprescnpj + '. N&atilde;o &eacute; poss&iacute;vel cadastrar.',
					'Alerta - Ayllos',
					'$("#nrdocnpj","#frmInfEmpresa").focus();');
				retornoValida = false;
			}
				
        }//success
    });//ajax
	return retornoValida;
}
//<-

// Busca as informações da empresa
function buscaEmpresas() {

    /* Tabela de Empresas */

    var nmdbusca = $('#nmdbusca', '#frmPesquisaEmpresa').val();
    var cdpesqui = $('input[type="radio"]:checked', '#frmPesquisaEmpresa').val();
    var cdempres = $('#cdempres', '#frmInfEmpresa').val();

    //Limpa variável código da empresa para buscar por nome ou razão social
    if (nmdbusca != '') {
        cdempres = '';
    }

    // Mostra mensagem de aguardo.
    if (cddopcao == "I") {
        $('#frmInfEmpresa').css({ 'display': 'block' });
        controlaFocoFormulariosEmpresa();
        hideMsgAguardo();
        return false;
    } else {
        $urlFonte = "telas/cademp/busca_empresas.php";
    }

    showMsgAguardo("Aguarde, buscando empresas...");
    // Executa script de bloqueio através de ajax

    $.ajax({
        type: "POST",
        url: UrlSite + $urlFonte,
        data: {
            cddopcao: cddopcao,
            cdpesqui: cdpesqui,
            nmdbusca: nmdbusca,
            cdempres: cdempres,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function(response) {
            try {
                if (cddopcao == "I") {
                    eval(response);
                    $('#frmInfEmpresa').css({'display': 'block'});
                    controlaFocoFormulariosEmpresa();
                    hideMsgAguardo();
                }else {
                    if (cdempres == '') {

                        if ($.trim(response).substring(1,4) == 'div') {
                            $('#divConteudo', '#divPesquisaEmpresa').html(response);
                            fechaRotina($('#divCabecalhoPesquisaEmpresa'));
                            exibeRotina($('#divPesquisaEmpresa'));
                            exibeRotina($('#divTabEmpresas'));
                            formataTabEmpresas();
                            hideMsgAguardo();
                        } else {
                            hideMsgAguardo();
                            eval(response);
                        }
                    }else {
                        if (response.search("showError") > 0) {
                            $('#cdempres','#frmInfEmpresa').val('');
                        } else {
                            $('input,select', '#frmInfEmpresa').removeClass('campoErro');
                            
							$('#divConteudo', '#divPesquisaEmpresa').html(response);
                            exibeRotina($('#divPesquisaEmpresa'));
                            exibeRotina($('#divTabEmpresas'));
                            formataTabEmpresas();
                            selecionaEmpresa();
                            hideMsgAguardo();
                        }
                        
                    }
                }
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
            }
        }
    });
}

// Formata a tabela de empresas
function formataTabEmpresas() {

    var divRegistro = $('div.divRegistros', '#divPesquisaEmpresa', '#divTabEmpresas');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '155px', 'width': '555px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '250px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';

    var metodoTabela = 'selecionaEmpresa();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));

    return false;
}

function selecionaEmpresa() {

    if ($('table > tbody > tr', 'div#divTabEmpresas div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div#divTabEmpresas div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {

                // Popula campos Formulario empresa
                cCdempres.val($('#hcdempres', $(this)).val());

                // Função para executar a procedure Busca_tabela e encontrar as informações restantes.

                BuscaTabela();

                //função para executar a procedure Busca_tabela e encontrar as informações restantes.
                cNmextemp.val($('#hnmextemp', $(this)).val());
                cIdtpempr.val($('#hidtpempr', $(this)).val());
                cNmresemp.val($('#hnmresemp', $(this)).val());
                cNrdconta.val($('#hnrdconta', $(this)).val());
                cNmextttl.val($('#hnmextttl', $(this)).val());
                cNmcontat.val($('#hnmcontat', $(this)).val());
                cDsendemp.val($('#hdsendemp', $(this)).val());
                cNrendemp.val($('#hnrendemp', $(this)).val());
                cDscomple.val($('#hdscomple', $(this)).val());
                cNmbairro.val($('#hnmbairro', $(this)).val());
                cNmcidade.val($('#hnmcidade', $(this)).val());
                cCdufdemp.val($('#hcdufdemp', $(this)).val());
                cNrcepend.val($('#hnrcepend', $(this)).val());
                cNrdocnpj.val($('#hnrdocnpj', $(this)).val());
				//P437
				cNrdddemp.val($('#hnrdddemp', $(this)).val());
                cNrfonemp.val($('#hnrfonemp', $(this)).val());
                cNrfaxemp.val($('#hnrfaxemp', $(this)).val());
                cDsdemail.val($('#hdsdemail', $(this)).val());
                cDtlimdeb.val($('#hdtlimdeb', $(this)).val());

                //Campos_Old
                old_cNmextemp = $('#hnmextemp', $(this)).val();
                old_cIdtpempr = $('#hidtpempr', $(this)).val();
                old_cNmresemp = $('#hnmresemp', $(this)).val();
                old_cNrdconta = $('#hnrdconta', $(this)).val();
                old_cNmextttl = $('#hnmextttl', $(this)).val();
                old_cNmcontat = $('#hnmcontat', $(this)).val();
                old_cDsendemp = $('#hdsendemp', $(this)).val();
                old_cNrendemp = $('#hnrendemp', $(this)).val();
                old_cDscomple = $('#hdscomple', $(this)).val();
                old_cNmbairro = $('#hnmbairro', $(this)).val();
                old_cNmcidade = $('#hnmcidade', $(this)).val();
                old_cCdufdemp = $('#hcdufdemp', $(this)).val();
                old_cNrcepend = $('#hnrcepend', $(this)).val();
                old_cNrdocnpj = $('#hnrdocnpj', $(this)).val();
				//P437
				old_cNrdddemp = $('#hnrdddemp', $(this)).val();
                old_cNrfonemp = $('#hnrfonemp', $(this)).val();
                old_cNrfaxemp = $('#hnrfaxemp', $(this)).val();
                old_cDsdemail = $('#hdsdemail', $(this)).val();
                old_cDtlimdeb = $('#hdtlimdeb', $(this)).val();

                // Popula campos Formulario Emprestimo
                cFlgvlddv.val($('#hflgvlddv', $(this)).val());
                (cFlgvlddv.val() == 'yes' || cFlgvlddv.val() == '1') ? cFlgvlddv.attr('checked', 'checked') : cFlgvlddv.removeAttr('checked');                
                cTpconven.val($('#htpconven', $(this)).val());
                cTpdebemp.val($('#htpdebemp', $(this)).val());
                cTpdebcot.val($('#htpdebcot', $(this)).val());
                cIndescsg.val($('#hindescsg', $(this)).val());
                // -> ID 20190208_437
				if (CooperConsig != 'S'){
					cIndescsg.val() == 2 ? cIndescsg.attr('checked', 'checked') : cIndescsg.removeAttr('checked');
				}
                //<-
				cFlgpagto.val($('#hflgpagto', $(this)).val());
                (cFlgpagto.val() == 'yes' || cFlgpagto.val() == '1') ? cFlgpagto.attr('checked', 'checked') : cFlgpagto.removeAttr('checked');
                cFlgarqrt.val($('#hflgarqrt', $(this)).val());
                (cFlgarqrt.val() == 'yes' || cFlgarqrt.val() == '1') ? cFlgarqrt.attr('checked', 'checked') : cFlgarqrt.removeAttr('checked');                
                cDtfchfol.val($('#hdtfchfol', $(this)).val());
                cCdempfol.val($('#hcdempfol', $(this)).val());
                cDtavsemp.val($('#hdtavsemp', $(this)).val());
                cDtavscot.val($('#hdtavscot', $(this)).val());
                cFlgpgtib.val($('#hflgpgtib', $(this)).val());
                (cFlgpgtib.val() == 'yes' || cFlgpgtib.val() == '1') ? cFlgpgtib.attr('checked', 'checked') : cFlgpgtib.removeAttr('checked');                
                $('#dtultufp', '#frmInfIb').val($('#hdtultufp', $(this)).val());
                cCdcontar.val($('#hcdcontar', $(this)).val());
                cDscontar.val($('#hdscontar', $(this)).val());
                cVllimfol.val($('#hvllimfol', $(this)).val());
				// -> ID 20190208_437
				cTpmodcon.val($('#htpmodcon', $(this)).val());
                cFlnecont.val($('#hflnecont', $(this)).val());
                cFlnecont.val() == 1 ? cFlnecont.attr('checked', 'checked') : cFlnecont.removeAttr('checked');
				//<-
                old_cFlgvlddv = $('#hflgvlddv', $(this)).val();
                old_cTpconven = $('#htpconven', $(this)).val();
                old_cTpdebemp = $('#htpdebemp', $(this)).val();
                old_cTpdebcot = $('#htpdebcot', $(this)).val();
                old_cIndescsg = $('#hindescsg', $(this)).val();
                old_cFlgpagto = $('#hflgpagto', $(this)).val();
                old_cFlgarqrt = $('#hflgarqrt', $(this)).val();
                old_cDtfchfol = $('#hdtfchfol', $(this)).val();
                old_cCdempfol = $('#hcdempfol', $(this)).val();
                old_cDtavsemp = $('#hdtavsemp', $(this)).val();
                old_cDtavscot = $('#hdtavscot', $(this)).val();
                old_cFlgpgtib = $('#hflgpgtib', $(this)).val();
                old_cCdcontar = $('#hcdcontar', $(this)).val();
                old_cVllimfol = $('#hvllimfol', $(this)).val();
				// -> ID 20190208_437
				old_cTpmodcon = $('#htpmodcon', $(this)).val();
                old_cFlnecont = $('#hflnecont', $(this)).val();
				//<-
                cCdempres.desabilitaCampo();
            }
        });
    }

    fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divPesquisaEmpresa'));
    fechaRotina($('#divTabEmpresas'));
    return false;
}

/*!
 * ALTERAÇÃO  : Criação da função "mostraPesquisaEmpresa"
 * OBJETIVO   : Função para mostrar a rotina de Pesquisa de Empresas Genérica.
 * PARÂMETROS : campoRetorno -> (String) O campo retorno é o nome do campo que representa o Nome da Empresa, para que na seleção
 *                              da empresa o sistema saiba para onde deve enviar o valor da empresa escolhida
 *              formRetorno  -> (String) Nome do formulário que irá receber as informações da empresa selecionada
 *              divBloqueia  -> (Opcional) Seletor jQuery da div que será ao qual queremos bloquear o fundo, logo em seguida de fecharmos a janela de pesquisa
 *              fncFechar    -> (Opcional) String que será executada como script ao fechar o formulário de Pesquisa Empresa. Na maioria
 *                               das vezes será uma instrução de foco para algum campo.
 */
function mostraPesquisaEmpresa(campoRetorno, formRetorno, divBloqueia, fncFechar) {

    if ($('#cddopcao', '#frmCab').val()=="I") {return false;}

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando Pesquisa de Empresas ...');

    // Guardo o campoRetorno e o formRetorno em variáveis globais para serem utilizados na seleção do associado
    vg_campoRetorno = campoRetorno;
    vg_formRetorno = formRetorno;

    $('#tpdapesq', '#frmPesquisaEmpresa').empty();

    // Limpar campos de pesquisa
    $('#nmdbusca', '#frmPesquisaEmpresa').val('');
    $('#tpdapesq', '#frmPesquisaEmpresa').val('0');

    // Formatação Inicial
    $('#nmdbusca, #tpdapesq', '#frmPesquisaEmpresa').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
    $('#tpdapesq', '#frmPesquisaEmpresa').removeProp('disabled');

    $('.fecharPesquisa', '#divPesquisaEmpresa').click(function() {
        $('#nmdbusca', '#frmPesquisaEmpresa').val('');
        // 015 - Retirado tratamento do tipo do divBloqueia e acrescentado a fncFechar
        fechaRotina($('#divPesquisaEmpresa'), divBloqueia, fncFechar);
        fechaRotina($('#divTabEmpresas'));
        $('#cdempres','#frmInfEmpresa').focus();
    });

    // Limpa Tabela de pesquisa
    $('#divConteudoPesquisaEmpresa').empty();
    $('#divTabPesquisaEmpresas').empty();

    exibeRotina($('#divPesquisaEmpresa'));
    $('#divPesquisaEmpresa').css({'left': '475px'});
    $('#nmdbusca', '#frmPesquisaEmpresa').focus();
    hideMsgAguardo();
}

function BuscaTabela() {

    showMsgAguardo('Aguarde, buscando dados tabela ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cademp/valida_tabela.php',
        data: {
            cddopcao: cddopcao,
            cdempres: cCdempres.val(),
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground();");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    eval(response);
                    controlaFocoFormulariosEmpresa();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            }
        }
    });
}

/*Impressão*/
function layoutImpressao() {
    var flgOrdem = $('#flgordem', '#divConteudoR');
    flgOrdem.css({width: '200px'}).focus();
    hideMsgAguardo();
    blockBackground();
    flgOrdem.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            imprimirPDF();
            return false;
        }
    });

    $('#btImprimir').click(function() {
        imprimirPDF();
        return false;
    });

    layoutPadrao();
}

function imprimirPDF() {

    var sidlogin = $("#sidlogin", "#frmMenu").val();
    var flgordem = $("#flgordem", '#divConteudoR').val();

    $('#frmImpressao').append('<input type="hidden" id="flgordem" name="flgordem" value="' + flgordem + '" />')
            .append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');

    var action = UrlSite + "telas/cademp/imprime_relacao.php";

    carregaImpressaoAyllos("frmImpressao", action, 'estadoInicial();');
    fechaRotina($('#divUsoGenerico'));

}

// Monta Janela Modal
function mostraRotina(pagina) {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cademp/' + pagina + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground()");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            if (pagina == "empresa"){
                buscaEmpresas();
            } else if (pagina == 'montaImpressao') {
                exibeRotina($('#divUsoGenerico'));
                layoutImpressao();
            }
            return false;
        }
    });
    return false;
}


// Funcoes para buscar o ZOOM de convenio
function mostrarTela() {

    if ($('#cddopcao', '#frmCab').val()=="C") {return false;}

    $.ajax({
        type    : "POST",
        dataType: "html",
        url     : UrlSite + "telas/cademp/busca_convenio.php",
        data: {
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
             mostraRotinaConv();
            $("#divRotina").html(response);
        }
    });
    return false;
}
function mostraRotinaConv() {
    $("#divRotina").css("visibility","visible");
    $("#divRotina").centralizaRotinaH();
}
function encerraRotina(flgCabec) {
    $("#divRotina").css({"width":"545px","visibility":"hidden"});
    $("#divRotina").html("");

    // Esconde div de bloqueio
    unblockBackground();
    return false;
}
function acessaOpcaoAba() {

    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/cademp/form_convenio.php",
        data: {
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            $("#divConteudoOpcao").html(response);
            formataTabela();
        }
    });
    return false;
}

function formataTabela() {

    var divRegistro = $('div.divRegistros', '#tabConvenio');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );
    var conteudo    = $('#conteudo', linha).val();

    $('#tabConvenio').css({'margin-top':'1px'});
    divRegistro.css({'height':'200px','padding-bottom':'1px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0]  = '300px';
    arrayLargura[1]  = '100px';
    arrayLargura[2]  = '90px';
    arrayLargura[3]  = '90px';
    arrayLargura[4]  = '90px';
    arrayLargura[5]  = '25px';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
    para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
    excluir o registro selecionado */

    $('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
        $('table > tbody > tr > td', divRegistro).focus();
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        selecionaTabela($(this));
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).dblclick( function() {
        selecionaTabela($(this));
        encerraRotina();
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus( function() {
        selecionaTabela($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
    return false;
}

function selecionaTabela(tr) {
    cCdcontar.val($('#cdcontar', tr).val());
    cDscontar.val($('#dscontar', tr).val());
    return false;
}

function mostraContaEmp() {

    if ($('#cddopcao', '#frmCab').val()=="C") {return false;}

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cademp/contas_emp.php',
        data: {
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            formataContaEmp();
            return false;
        }
    });

    return false;
}

function formataContaEmp() {

    var rNmprimtl2 = $('label[for="nmprimtl"]','#frmContaEmp');
    var cNmprimtl2 = $('#nmprimtl','#frmContaEmp');

    //Label
    rNmprimtl2.addClass('rotulo').css({'width':'120px'});

    //Campos
    cNmprimtl2.css({'width':'300px'}).habilitaCampo();

    cNmprimtl2.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            buscaContaEmp(2);
            return false;
        }
    });

    var divRegistro = $('div.divRegistros','#divContaEmp');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'130px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '280px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';

    var metodoTabela = 'selecionaAvalista();';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    // centraliza a divRotina
    $('#divRotina').css({'width':'525px'});
    $('#divRotina').centralizaRotinaH();

    hideMsgAguardo();
    bloqueiaFundo( $('#divRotina') );
    highlightObjFocus( $('#frmContaEmp') );
    layoutPadrao();
    cNmprimtl2.focus();
    return false;
}

function selecionaAvalista() {

    if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
        $('table > tbody > tr', 'div.divRegistros').each( function() {
            if ( $(this).hasClass('corSelecao') ) {
                cNrdconta.val( $('#nrdconta', $(this) ).val() );
                cNmextttl.val( $('#nmfuncio', $(this) ).val() );
                cNrdconta.trigger('blur');
                //buscaDadosCooperado();
				buscaContaEmp(1);
                return false;
            }
        });
    }
    return false;
}

function buscaContaEmp(opcao) {

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cdempres = $('#cdempres','#frmInfEmpresa').val();
    var nrdconta = normalizaNumero($('#nrdconta','#frmInfEmpresa').val());
    var nmprimtl = $('#nmprimtl','#frmContaEmp').val();

    // Inicializa se estiver indefinido os campos
    if (nrdconta === undefined){ nrdconta = 0;}
    if (nmprimtl === undefined){ nmprimtl = "";}

    // Se a pesquisa for por conta
    if (nrdconta != 0 && opcao==1) {
        $('#nmprimtl','#frmContaEmp').val("");
        nmprimtl = "";
    }

    // Se a pesquisa for por nome
    if (nmprimtl != "" && opcao==2) {
        nrdconta = 0;
    }

    if ($('#nmprimtl','#frmContaEmp').val()=="" && opcao==2) {
        showError('error','Informe o campo para pesquisa!',
                          'Campo Obrigat&oacute;rio!',
                          '$("#nmprimtl","#frmContaEmp").focus();bloqueiaFundo($(\'#divRotina\'));');

        return false;
    }

    showMsgAguardo('Aguarde, buscando ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cademp/busca_conta_emp.php',
        data: {
            nrdconta: nrdconta,
            nmprimtl: nmprimtl,
            cdempres: cdempres,
            cddopcao: cddopcao,
            redirect: 'script_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {

            if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                try {
                    $('#divConteudo').html(response);
                    formataContaEmp();
                    return false;
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            }
        }
    });
    return false;
}

function buscaDadosCooperado() {
    showConfirmacao("Deseja buscar informa&ccedil;&otilde;es do Associado? (S/N)", "Confirma&ccedil;&atilde;o - Ayllos", "consultaDadosCooperado();", "fechaDadosCooperado();", "sim.gif", "nao.gif");
    return false;
}

function fechaDadosCooperado() {
    fechaRotina( $('#divRotina') );
    cNmcontat.focus();
}

function consultaDadosCooperado() {
    showConfirmacao("Deseja Complementar ou Substituir as Informa&ccedil;&otilde;es? (C/S)", "Confirma&ccedil;&atilde;o - Ayllos", "buscandoDados('C');", "buscandoDados('S');", "botao_complementar.gif", "botao_substituir.gif");
    return false;
}

function buscandoDados(opcao) {

    var nrdconta = cNrdconta.val();

    showMsgAguardo('Aguarde, buscando dados do associado...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cademp/busca_dados_ass.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {

            if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                try {
                    eval(response);
                    fechaRotina( $('#divRotina') );
                    cNmcontat.focus();
                    return false;
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            }
        }
    });
    return false;
}


function impressaTermoServico() {
    showConfirmacao("Impress&atilde;o do termo de Ades&atilde;o ou Cancelamento? (A/C)", "Confirma&ccedil;&atilde;o - Ayllos", "selecionaProcurador();","impTermoServico(1)", "botao_adesao.gif", "cancelamento.gif");
}

function impTermoServico(termo) {

    var sidlogin = $("#sidlogin", "#frmMenu").val();
    var cdempres = cCdempres.val();
    var indtermo = termo;

    $('#frmImpressao').append('<input type="hidden" id="cdempres" name="cdempres" value="' + cdempres + '" />')
					  .append('<input type="hidden" id="indtermo" name="indtermo" value="' + indtermo + '" />')
					  .append('<input type="hidden" id="lisconta" name="lisconta" value="' + lisconta + '" />')
					  .append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');

    var action = UrlSite + "telas/cademp/imprimir_termo.php";

    carregaImpressaoAyllos("frmImpressao", action, 'estadoInicial();');
    fechaRotina($('#divUsoGenerico'));
	
	encerraRotinaProcurador(true);
		
}

function selecionaProcurador() {

    if ($('#cddopcao', '#frmCab').val()=="C") {return false;}

    $.ajax({
        type    : "POST",
        dataType: "html",
        url     : UrlSite + "telas/cademp/busca_procurador.php",
        data: {
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
             mostraRotinaProcurador();
            $("#divRotina").html(response);
        }
    });
    return false;

}

function encerraRotinaProcurador(flgCabec) {
    $("#divRotina").css({"width":"545px","visibility":"hidden"});
    $("#divRotina").html("");

    // Esconde div de bloqueio
    unblockBackground();

    estadoInicial();
    return false;
}

function mostraRotinaProcurador() {
    $("#divRotina").css("visibility","visible");
    $("#divRotina").centralizaRotinaH();
}

function acessaOpcaoAbaProc() {

    var cdempres = cCdempres.val();

    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/cademp/form_procurador.php",
        data: {
            cdempres : cdempres,
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            $("#divConteudoOpcao").html(response);
            formataTabelaProc();
        }
    });
    return false;
}

function formataTabelaProc() {

    var divRegistro = $('div.divRegistros', '#tabProcurador');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );
    var conteudo    = $('#conteudo', linha).val();

    $('#tabProcurador').css({'margin-top':'1px'});
    divRegistro.css({'height':'200px','padding-bottom':'1px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0]  = '30px';
    arrayLargura[1]  = '100px';
    arrayLargura[2]  = '250px';
    arrayLargura[3]  = '100px';
    arrayLargura[4]  = '100px';
    arrayLargura[5]  = '145px';
    arrayLargura[6]  = '18px';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
    para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
    excluir o registro selecionado */

    $('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
        $('table > tbody > tr > td', divRegistro).focus();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
    return false;
}

function selecionaRegistro() {
    lisconta = "";

    // Agrupa todas as contas selecionadas em uma lista
    $("input[type=checkbox][id='chk']:checked").each(function(){
        lisconta = $(this).val()+","+lisconta;
    });

    // Verifica se ao menos uma conta foi selecionada
    if (lisconta=="") {
        showError('error','Deve ser informado ao menos um procurador!',
                          'Campo Obrigat&oacute;rio!',
                          "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return false;
    }

    // Prepara a lista de conta para pesquisa dos associados selecionados
    lisconta = "," + lisconta;
    impTermoServico(0);
    return false;
}


function voltarAtenda() {
	setaParametros ('ATENDA', '', nrdconta, flgcadas);
	setaATENDA();
	direcionaTela('ATENDA','no');
}


function validaEmailCademp(emailAddress) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))|(\",;+\")$/;
	var registro = new RegExp(re);
    return registro.test(emailAddress);
}

function dossieDigdoc(cdproduto){

	var mensagem = 'Aguarde, acessando dossie...';
	showMsgAguardo( mensagem );

	// Carrega dados da conta através de ajax
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/digdoc.php',
		data    :
				{
				    nrdconta    : $('#nrdconta', '#frmInfEmpresa').val(),
					cdproduto   : cdproduto, // Codigo do produto
                    nmdatela    : 'CADEMP',
 					redirect	: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval( response );
							return false;
						} catch(error) {
							hideMsgAguardo();							
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					} else {
						try {
							eval( response );							
							blockBackground(parseInt($('#divRotina').css('z-index')));
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					}
				}
	});

	return false;
}
