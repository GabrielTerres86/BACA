/***********************************************************************
 Fonte: consig.js                                                  
 Autor: Leonardo Oliveira - GFT 
 Data : Agoso/2018                Ultima Alteração:                                                                    
 Objetivo  : Cadastro de servicos ofertados na tela CADCCO
                                                                   	 
 Alterações: 

************************************************************************/
//
var CooperConsig = '';

//nomes
var NomeCabecalho = 'frmCabecalhoConsig';
var NomeFiltro = 'frmFiltroConsig';
var NomeDivBotoesFiltro = 'divBotoesFiltro';
var NomeFrmConsig = 'frmConsig';
var NomeDivConsig = 'divConsig';
var NomeDivTela = 'divTela';
var NomeDivBotoesConsig = 'divBotoesConsig';
var NomeDivVencParc = 'divVencParc';

//componentes tela
var 
    Cabecalho,
    Filtro,
    DivBotoesFiltro,
    FrmConsig,
    DivConsig,
    DivTela,
    FrmPesquisaEmpresa, // Pesquisa empresa
    DivConteudoPesquisaEmpresa,
    DivTabPesquisaEmpresas,
    DivPesquisaEmpresa,
    DivTabEmpresas,
    FecharPesquisa,
	DivVencParc;
	

//campos
var Ccddopcao // * Cabecalho // Código Operação
    ,Ccdempres // * Filtro // Código Empresa
    ,Cindconsignado // 'Convênio Consignado'
    ,Cdtativconsignado // 'Data'
    ,Cnmextemp // * Form Consignado // Razão Social
    ,Ctpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Cdtfchfol // Dia Fechamento Folha
    ,Cnrdialimiterepasse // Dia Limite para Repasse
    ,Cindautrepassecc // Autoriza Débito Repasse em C/C?
    ,Cindinterromper // Interrompe Cobrança
    ,Cdtinterromper // Data Interrupção Cobrança
    ,Cdsdemail // E-mail
    ,Cindalertaemailemp // Alertas (check box)
    ,Cdsdemailconsig // E-mail Consignado
    ,Cindalertaemailconsig
	,Cdcooper
	; // Alertas Consignado (check box)

//labels
var Lcddopcao // * Cabecalho
    ,Lcdempres // * Filtro
    ,Lindconsignado // 'Convênio Consignado'
    ,Ldtativconsignado // 'Data'
    ,Lnmextemp // * Form Consignado // Razão Social
    ,Ltpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Ldtfchfol // Dia Fechamento Folha
    ,Lnrdialimiterepasse // Dia Limite para Repasse
    ,Lindautrepassecc // Autoriza Débito Repasse em C/C?
    ,Lindinterromper // Interrompe Cobrança
    ,Ldtinterromper // Data Interrupção Cobrança
    ,Ldsdemail // E-mail
    ,Ldsdemailconsig; // E-mail Consignado


//botoes
var BtnOK, BtProsseguir, btLupa;

//auxiliares
var dtinterromperOld, dtfchfolOld;

$(document).ready(function () {
    estadoInicial();

});

function validaCooperConsig()
{
	CooperConsig = document.getElementById('glb_val_cooper_consignado').value ;
	if (CooperConsig != 'S'){
		showError(
				"error",
				"Cooperativa sem acesso ao consignado!",
				"Alerta - Ayllos",
				"",
				false);
			BtnOK.css('display', 'none'); 
			Ccddopcao.desabilitaCampo(); 
	}
}

function estadoInicial() {

    formataCabecalho();

    Cabecalho = $('#'+NomeCabecalho);
    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
	DivVencParc = $('#'+NomeDivVencParc);

    //Cabecalho.habilitaCampo().focus().val('C');
    Filtro.css('display', 'none');
    DivBotoesFiltro.css('display', 'none');
    FrmConsig.css('display', 'none');
    DivConsig.html('').css('display', 'none');
	DivVencParc.css('display','none');
	
		
    layoutPadrao();
	validaCooperConsig();
}

function formataCabecalho() {

    DivTela = $('#'+NomeDivTela);
    Cabecalho = $('#'+NomeCabecalho);
    Lcddopcao = $('label[for="cddopcao"]', Cabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    BtnOK = $('#btOK', Cabecalho);


    Ccddopcao.habilitaCampo();
    Lcddopcao.css('width', '50px').addClass('rotulo');
    Ccddopcao.css('width', '520px');
    Cabecalho.css('display', 'block');

    DivTela.fadeTo(0, 0.1);
    removeOpacidade('divTela');
    highlightObjFocus(Cabecalho);

    //Ao clicar no botao OK
    BtnOK.unbind('click').bind('click', function () {
        // esconder cddopcao
        $('input,select').removeClass('campoErro');
        Ccddopcao.desabilitaCampo();
        BtnOK.unbind();
        formataFiltro();
    });
    controlaFocoCabecalho();
    Ccddopcao.focus();
}

function controlaFocoCabecalho() {

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    BtnOK = $('#btOK', Cabecalho);



    Ccddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            BtnOK.click();
            return false;
        }
    });

    BtnOK.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            BtnOK.click();
            return false;
        }
    });
    return false;
}

function formataFiltro(){

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    if (!(validaPermissao(Ccddopcao.val())))
		return false;

    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    BtProsseguir = $('#btProsseguir', DivBotoesFiltro);
    BtVoltar = $('#btVoltar', DivBotoesFiltro);
    BtLupa = $('#btLupa', Filtro);
    BtOK = $('#btOK', Filtro); 

    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#text_indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    Crowid = $('#rowid_emp_consig', Filtro); // rowid

    Lcdempres = $('label[for="cdempres"]', Filtro); // * Filtro // Código Empresa
    Lindconsignado = $('label[for="text_indconsignado"]', Filtro); // 'Convênio Consignado'
    Ldtativconsignado = $('label[for="dtativconsignado"]', Filtro); // 'Data'

    highlightObjFocus( Filtro );
    Lindconsignado.addClass('rotulo')
                .css('width','150px');

    Ldtativconsignado.addClass('rotulo')
                    .css('width','100px')
                    .css('float','left')
                    .css('clear','none');

    Lcdempres.addClass('rotulo')
            .css('width','150px');

    Ccdempres.css({ 'width': '57px', 'text-align': 'right' })
                .addClass('inteiro')
                .addClass('codigo pesquisa')
                .attr('maxlength', '10')
                .habilitaCampo()
                .val('');

    Cindconsignado.attr('size','4')
                .css('display', 'block');

    Ccdempres.setMask("INTEGER", "zzzzz.zz9", ".", "");
    Cdtativconsignado.attr('size','8')
        .attr('maxlength','10')
        .setMask("INTEGER", "zz/zz/zzzz", "","");

    Ccdempres.css('display', 'block');
    Filtro.css('display', 'block');
    DivBotoesFiltro.css('display', 'block');
    BtLupa.css('display','block');

    Ccdempres.habilitaCampo();
    Cindconsignado.desabilitaCampo();
    Cdtativconsignado.desabilitaCampo();

    Ccdempres.unbind('change').bind('change', function () {
        buscarDescricao();
        return false;
    });

        //Ao clicar no botao OK
    BtOK.unbind('click').bind('click', function () {
        buscarDescricao();
        return false;
    });

    Ccdempres.unbind('keypress').bind('keypress',function(e) {      
        if(e.keyCode == 13 || e.keyCode == 9){
            buscarDescricao();
            return false;
        }
    });

    //Ao clicar no botao OK
    BtProsseguir.unbind('click').bind('click', function () {
        if(!existeEmpresa()){
            buscarDescricao(function(){
                consultaParametros();
                return false;
            });
            return false;
        }
        consultaParametros();
        return false;
    });

    //Ao clicar no botao OK
    BtVoltar.unbind('click').bind('click', function () {
		linhaEmEdicao = null;	
        voltar('1');
        return false;
    });

    BtLupa.unbind('click').bind('click',function() {
        mostraPesquisaEmpresa();
        return false;
    });
    limparCamposFiltro();
    Ccdempres.focus();
    layoutPadrao();
    return false;
}

function limparCamposFiltro(){

    Filtro = $('#'+NomeFiltro);
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    CtextIndconsignado =  $('#text_indconsignado', Filtro);
    Crowid = $('#rowid_emp_consig', Filtro); // rowid
    CtextIndconsignado.val('');
    Cdtativconsignado.val('');
    Crowid.val('');
    return false;
}

function desabilitaFiltro(){
    Filtro = $('#'+NomeFiltro);
    DivBotoesFiltro = $('#'+NomeDivBotoesFiltro);
    BtProsseguir = $('#btProsseguir', DivBotoesFiltro);
    BtVoltar = $('#btVoltar', DivBotoesFiltro);
    BtLupa = $('#btLupa', Filtro); 

    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    BtLupa.css('display','none');
    Ccdempres.desabilitaCampo();
    Cindconsignado.desabilitaCampo();
    Cdtativconsignado.desabilitaCampo();
    DivBotoesFiltro.css('display', 'none');
    return false;
}

function mostraPesquisaEmpresa(){

    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    var cddopcao = Ccddopcao.val();
    var businessObject = 'TELA_CONSIG';
    var nomeProcedure = 'OBTEM_DADOS_EMP_CONSIGNADO';
    var titulo = 'Empresa';
    var qtReg = '30';
    var filtros = 'Cód. Empresa;cdempres;60;S;;S;;|Nome Empresa;nmextemp;150;S;;S;;|;cddopcao;;N;' + cddopcao + ';N;|Empréstimo Consigando;indconsignado;;N;;N;;|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var colunas = 'Código;cdempres;50;right;;S;;|Empresa;nmextemp;230;left;;S;;|;cddopcao;;N;;N;|Empréstimo Consigando;indconsignado;;N;;N;;|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var divBloqueia = '';
    var fncOnClose = 'fecharPesquisa();';
    var nomeRotina =  NomeFiltro;
    mostraPesquisa(businessObject, nomeProcedure, titulo, qtReg, filtros, colunas, divBloqueia, fncOnClose, nomeRotina);//, cdCooper);
	return false;
}

function buscarDescricao(callback){
    limparCamposFiltro();
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro);
    Cindconsignado = $('#indconsignado', Filtro);
    Crowid_emp_consig = $('#rowid_emp_consig', Filtro);
    Cdtativconsignado = $('#dtativconsignado', Filtro);

    var cdempres = Ccdempres.val();
    var cddopcao = Ccddopcao.val();
    var indconsignado = '';
    var rowid_emp_consig = '';
    var dtativconsignado = '';
    
     $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/consig/manter_rotina.php',
            data: {
                cddopcao: 'B',
                cdempres: cdempres,
                consulta_cddopcao: cddopcao,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError(
                    'error',
                    'Nao foi possivel concluir a operacao.',
                    'Alerta - Ayllos',
                    '$("#nrconven", "#frmFiltro").focus();');
            },
            success: function (response) {
                try {
                    eval(response);
                    Ccdempres.val(cdempres);
                    Cindconsignado.val(indconsignado);
                    Crowid_emp_consig.val(rowid_emp_consig);
                    Cdtativconsignado.val(dtativconsignado);
                    fecharPesquisa();
                    if(callback){
                        callback();
                    }
                    return false;
                } catch (error) {
                    showError(
                        'error',
                        'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,
                        'Alerta - Ayllos',
                        '$("#nrconven",'+NomeFiltro+').focus();');
                    return false;
                }//catch
            }//success
        });//ajax
    return false;
}

function callbackBuscarDescricao(){
    return false;
}

function fecharPesquisa(){
    Filtro = $('#'+NomeFiltro);
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    CtextIndconsignado = $('#text_indconsignado', Filtro); // 'Convênio Consignado'
    var indconsignado = Cindconsignado.val();
    if(indconsignado == "1"){
        CtextIndconsignado.val("Sim");
    } else if(indconsignado == '0') {
        CtextIndconsignado.val("Não");
	}else if(indconsignado == '2') {
        CtextIndconsignado.val("Pend.");
    }else{
        CtextIndconsignado.val('');
    }
    return false;
}

function consultaParametros(){
    DivConsig = $('#'+NomeDivConsig);
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);

    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    var cddopcao = Ccddopcao.val();
    var cdempres = Ccdempres.val(); // * Filtro // Código Empresa
    var indconsignado = Cindconsignado.val(); // 'Convênio Consignado'
    var dtativconsignado = Cdtativconsignado.val(); // 'Data'

    if(!existeEmpresa()){
            hideMsgAguardo();
            showError(
                'error',
                'Não há código de empresa cadastrado.',
                'Alerta - Ayllos',
                '');
            return false;
    }

     $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/consig/manter_rotina.php',
        data: {
            cddopcao: '',
            consulta_cddopcao : cddopcao,
            cdempres: cdempres,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError(
                'error',
                'Nao foi possivel concluir a operacao.',
                'Alerta - Ayllos',
                '$("#nrconven", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            desabilitaFiltro();
            try {

                try { // Javascript
                    eval(response);
                    return false;
                } catch (error) { // Html
                    DivConsig.html(response);
                    formataTelaConsig();
                    return false;
                }//catch
                
            } catch (error) {

                showError(
                    'error',
                    'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,
                    'Alerta - Ayllos',
                    '$("#nrconven",'+NomeFiltro+').focus();');
            }//catch
        }//success
    });//ajax
    return false;
}

function existeEmpresa(){
    Filtro = $('#'+NomeFiltro);
    Crowid = $('#rowid_emp_consig', Filtro);// rowid
    Cdempres = $('#cdempres', Filtro);// Código Empresa

    cdempres = Cdempres.val();
    rowid = Crowid.val();

    // console.log(rowid);

    if(!rowid || trim(rowid) == '' || rowid == 0){
        return false;
    }
    if(!cdempres || trim(cdempres) == '' || cdempres == 0){
        return false;
    }
    return true;
}

function formataTelaConsig(){
    DivVencParc = $('#'+NomeDivVencParc);
	DivVencParc.css('display', 'block');
	
	FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
    DivBotoesConsig = $('#'+NomeDivBotoesConsig);
	
    BtConcluir = $('#btConcluir', DivBotoesConsig);
    BtVoltar = $('#btVoltar', DivBotoesConsig);

    Lnmextemp = $('label[for="nmextemp"]', FrmConsig); // * Form Consignado // Razão Social
    Ltpmodconvenio = $('label[for="select_tpmodconvenio"]', FrmConsig);  // Tipo de Convenio INSS/ Publico / Privado
    Ldtfchfol = $('label[for="dtfchfol"]', FrmConsig);  // Dia Fechamento Folha
    Lnrdialimiterepasse = $('label[for="nrdialimiterepasse"]', FrmConsig);  // Dia Limite para Repasse
    Lindautrepassecc = $('label[for="radio_indautrepassecc"]', FrmConsig);  // Autoriza Débito Repasse em C/C?
    Lindinterromper = $('label[for="radio_indinterromper"]', FrmConsig);  // Interrompe Cobrança
    Ldtinterromper = $('label[for="dtinterromper"]', FrmConsig); // Data Interrupção Cobrança
    Ldsdemail = $('label[for="dsdemail"]', FrmConsig); // E-mail
    Ldsdemailconsig = $('label[for="dsdemailconsig"]', FrmConsig); // E-mail Consignado
    Llbalertaconsig =  $('#lbalertaconsig', FrmConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig);// Alertas Consig(check box)

    highlightObjFocus( Filtro );

    Lnmextemp.addClass('rotulo').css('width','200px');
    Ltpmodconvenio.addClass('rotulo').css('width','200px');
    Ldtfchfol.addClass('rotulo').css('width','200px');
    Lnrdialimiterepasse.addClass('rotulo').css('width','200px');
    Lindautrepassecc.addClass('rotulo').css('width','200px').css('margin-right','10px');
    Lindinterromper.addClass('rotulo').css('width','200px').css('margin-right','10px');
    Ldtinterromper.addClass('rotulo').css('width','200px');
    Ldsdemail.addClass('rotulo').css('width','200px');
    Ldsdemailconsig.addClass('rotulo').css('width','200px');
    Llbalertaconsig.addClass('rotulo').css('margin-left','400px');


    Cindautrepassecc.css('margin-left','10px');
    Cindinterromper.css('margin-left','10px');

    Cdsdemail.css('margin-right','10px');
    Cdsdemailconsig.css('margin-right','10px');

    DivConsig.css('display', 'block');
    FrmConsig.css('display', 'block');

    Cdtfchfol.attr('size','2')
            .attr('maxlength','2')
            .setMask("INTEGER", "zz", "","");
            
    Cdtfchfol.bind('blur', function () {
        if ($(this).val() == '') {
            return true;
        }

        if(!checkIsDay(Cdtfchfol)){
            return false;
        }
        return true;
    });

    Cnrdialimiterepasse.attr('size','2')
            .attr('maxlength','2')
            .setMask("INTEGER", "zz", "","");

    Cnrdialimiterepasse.bind('blur', function () {
        if ($(this).val() == '') {
            return true;
        }

        if(!checkIsDay(Cnrdialimiterepasse)){
            return false;
        }
        return true;
    });

    Cnmextemp.attr('size','50');
    Cdtinterromper.attr('size','10')
            .attr('maxlength','10')
            .setMask("INTEGER", "zz/zz/zzzz", "","");
    Cdsdemail.attr('size','30');
    Cdsdemailconsig.attr('size','30');

    controlaFocoTelaConsig();
    atualizaConvenio();

	// verificação de alteração de valores pelo usuário
    Ctpmodconvenio.unbind('change').bind('change', function(e) {
        $('#tpmodconvenio', FrmConsig).val(Ctpmodconvenio.val()); // Tipo de Convenio INSS/ Publico / Privado
		atualizaConvenio();
        return false;
    });

    $('input[name="radio_indautrepassecc"][value="0"]').unbind('change').bind('change', function(e) {
        $('#indautrepassecc', FrmConsig).val(0);
        return false;
    });

    $('input[name="radio_indautrepassecc"][value="1"]').unbind('change').bind('change', function(e) {
        $('#indautrepassecc', FrmConsig).val(1);
        return false;
    });


    $('input[name="radio_indinterromper"][value="0"]').unbind('change').bind('change', function(e) {
        $('#indinterromper', FrmConsig).val(0);
        return false;
    });

    $('input[name="radio_indinterromper"][value="1"]').unbind('change').bind('change', function(e) {
        $('#indinterromper', FrmConsig).val(1);
        return false;
    });

    Cindalertaemailemp.unbind('change').bind('change', function(e) {
        var val = Cindalertaemailemp.attr('checked') ? 1 : 0;
        $('#indalertaemailemp', FrmConsig).val(val); // Tipo de Convenio INSS/ Publico / Privado
           return false;
    });

    Cindalertaemailconsig.unbind('change').bind('change', function(e) {
		linhaEmEdicao = null;	
        var val = Cindalertaemailconsig.attr('checked') ? 1 : 0;
        $('#indalertaemailconsig', FrmConsig).val(val); // Tipo de Convenio INSS/ Publico / Privado
           return false;
    });

    BtVoltar.unbind('click').bind('click', function () {
		linhaEmEdicao = null;
        voltar('2');
        return false;
    });

    BtConcluir.unbind('click').bind('click', function () {
        controlaOperacao();
        return false;
    });

    Cindinterromper.change(function() {
       showHideDtInterrupcao(this.value);
    });

	//Cdcooper = document.getElementById('cdcooper').value;
    //controlaOperacao

}

function checkIsDay(field){
    if(field.val() < 1 || field.val() >31){
        showError("error", "Dia inv&aacute;lido.", "Alerta - Ayllos", "$('#"+field.attr('id')+"','#"+FrmConsig.attr('id')+"').focus()");
        field.val('');
        return false;
    }
    return true;
}

// Se Interrompe Cobrança == Não ENTAO data interrupção == ''
function showHideDtInterrupcao(value){
    if(value == 0){
         $('#dtinterromper', FrmConsig).val('');
    }else{
		if(value == 1){
			if (dtinterromperOld.length == 0)
			{
				var valData = $('#dtvmtolt', FrmConsig).val();
				$('#dtinterromper', FrmConsig).val(valData);
			}
			else
				$('#dtinterromper', FrmConsig).val(dtinterromperOld);
		}
		else
			$('#dtinterromper', FrmConsig).val(dtinterromperOld);
    }
}

function atualizaConvenio(){
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
	DivVencParc = $('#'+NomeDivVencParc);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza Débito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig); // Alertas Consignado (check box)
    Hindalertaemailemp = $('#indalertaemailemp', FrmConsig); // HIDDEN Alertas (check box)
    Hindalertaemailconsig = $('#indalertaemailconsig', FrmConsig); // HIDDEN Alertas Consignado (check box)


	if (Cdtfchfol.val() != '')
		dtfchfolOld = Cdtfchfol.val();
    dtinterromperOld = Cdtinterromper.val();
    cddopcao = Ccddopcao.val();
    tpmodconvenio = Ctpmodconvenio.val();
    Cdsdemail.desabilitaCampo(); // E-mail sempre desabilitado par alteração manual
    
    // Configura os valores default para radios e checks
    $('input[name=radio_indautrepassecc]').prop('checked', false);
    $('input[name=radio_indautrepassecc][value='+Hindautrepassecc.val()+']').prop('checked', true); 
    $('input[name=radio_indinterromper]').prop('checked', false);
    $('input[name=radio_indinterromper][value='+Hindinterromper.val()+']').prop('checked', true); 
    if(Hindalertaemailemp.val() == '1')$('input[name=checkbox_indalertaemailemp]').prop('checked', true); 
    if(Hindalertaemailconsig.val() == '1')$('input[name=checkbox_indalertaemailconsig]').prop('checked', true);


    if(cddopcao == 'C' || cddopcao == 'D'){ // CONSULTA - desabilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Razão Social
        Cdtfchfol.desabilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.desabilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.desabilitaCampo(); // Autoriza Débito Repasse em C/C?
        Cindinterromper.desabilitaCampo(); // Interrompe Cobrança
        Cdtinterromper.desabilitaCampo(); // Data Interrupção Cobrança
        Cindalertaemailemp.desabilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.desabilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.desabilitaCampo(); // Alertas Consignado (check box)
    } else { // Se não for CONSULTA por padrão habilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Razão Social - por padrão nao fica desabilatado para alteração
        Cdtfchfol.habilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.habilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.habilitaCampo(); // Autoriza Débito Repasse em C/C?
        Cindinterromper.habilitaCampo(); // Interrompe Cobrança
        Cdtinterromper.habilitaCampo(); // Data Interrupção Cobrança
        Cindalertaemailemp.habilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.habilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.habilitaCampo(); // Alertas Consignado (check box)
    }

    // Select do tipo de convenivo só fica habilitado para H - Habilitar
    if(cddopcao == 'H'){
        Ctpmodconvenio.habilitaCampo();
    }else{
        Ctpmodconvenio.desabilitaCampo();
    }

    /*
        INSS = 3
        Publico = 2
        Privado = 1
    */
    if(tpmodconvenio == 1){
		if (Cdtfchfol.val() == '')
			Cdtfchfol.val(dtfchfolOld);
			DivVencParc.css('display', 'block');
        if(cddopcao == 'H'){
            Cnrdialimiterepasse.val('');
            $('input[name=radio_indautrepassecc]').prop('checked', false);
            $('input[name=radio_indautrepassecc][value=1]').prop('checked', true); 
			$('#indautrepassecc', FrmConsig).val(1);
            $('input[name=radio_indinterromper]').prop('checked', false);
            $('input[name=radio_indinterromper][value=0]').prop('checked', true); 
			$('#indinterromper', FrmConsig).val(0);
        }

    }else if(tpmodconvenio == 2){// Publico
        //Autoriza Débito Repasse em C/C?		
		DivVencParc.css('display', 'block');
		if (Cdtfchfol.val() == '')
			Cdtfchfol.val(dtfchfolOld);
        Cindautrepassecc.desabilitaCampo();
        if(cddopcao == 'A' || cddopcao == 'H'){
            $('input[name=radio_indautrepassecc]').prop('checked', false);
			$('#indautrepassecc', FrmConsig).val(0);
			$('#indinterromper', FrmConsig).val(0);
        }
    } else if ( tpmodconvenio == 3){ // INSS
        // Limpa data de interrupção para INSS
		DivVencParc.css('display', 'none');
        Cdtfchfol.val('');
        Cdsdemail.val('');
        Cdsdemailconsig.val('');
        $('input[name=radio_indautrepassecc]').prop('checked', false);
        $('input[name=radio_indinterromper]').prop('checked', false);
		$('#indautrepassecc', FrmConsig).val(0);
		$('#indinterromper', FrmConsig).val(0);
        Cindalertaemailemp.prop('checked', false); 
        Cindalertaemailconsig.prop('checked', false); 
        if(cddopcao == 'A' || cddopcao == 'H'){ // ALTERAR || HABILITAR
            // Dia Fechamento Folha
            Cdtfchfol.desabilitaCampo();
            // Autoriza Débito Repasse em C/C?
            Cindautrepassecc.desabilitaCampo();
            // Interrompe Cobrança
            Cindinterromper.desabilitaCampo();
            // Data Interrupção Cobrança
            Cdtinterromper.desabilitaCampo();
            // E-mail
            //Cdsdemail.desabilitaCampo();
            //Alerta
            Cindalertaemailemp.desabilitaCampo();
            // E-mail Consignado
            Cdsdemailconsig.desabilitaCampo();
            // Alertas Consignado
            Cindalertaemailconsig.desabilitaCampo();
        }
        if(cddopcao == 'D'){ // DESABILITAR
            // Razão Social
            Cnmextemp.desabilitaCampo();
            //Dia Limite para Repasse
            Cnrdialimiterepasse.desabilitaCampo();
         }
         if(cddopcao == 'H'){ // HABILITAR
            Cnrdialimiterepasse.val('');
         }
    } // tpmodconvenio - INSS

    showHideDtInterrupcao($('input[name=indinterromper]:checked', '#'+FrmConsig.attr('id')+'').val());

    return false;
}

function controlaFocoTelaConsig(){

    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);
    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig);
    
	DivBotoesConsig = $('#'+NomeDivBotoesConsig);
    BtConcluir = $('#btConcluir', DivBotoesConsig);
    BtVoltar = $('#btVoltar', DivBotoesConsig);

    Cnmextemp.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Ctpmodconvenio.focus();
                return false;
            }
        });

    Ctpmodconvenio.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdtfchfol.focus();
                return false;
            }
        });

    Cdtfchfol.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cnrdialimiterepasse.focus();
                return false;
            }
        });

    Cnrdialimiterepasse.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindautrepassecc.focus();
                return false;
            }
        });

    Cindautrepassecc.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindinterromper.focus();
                return false;
            }
        });

    Cindinterromper.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdsdemail.focus();
                return false;
            }
        });

    Cdsdemail.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindalertaemailemp.focus();
                return false;
            }
        });

    Cindalertaemailemp.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cdsdemailconsig.focus();
                return false;
            }
        });

    Cdsdemailconsig.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 9 || e.keyCode == 13) {
                Cindalertaemailconsig.focus();
                return false;
            }
        });

    Cindalertaemailconsig.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/			
            if (e.keyCode == 9 || e.keyCode == 13) {
                BtConcluir.focus();
                return false;
            }
        });
    return false;
}

function voltar(flag){

    DivConsig = $('#'+NomeDivConsig);

    switch (flag) {
        case '1':
            // Voltar de filtro para cabeçalho
            estadoInicial();
            break;

        case '2':
            // Voltar de Consig para Filtro
            DivConsig.html('').css('display','none');
            formataFiltro();
            break;
    }
    return false;
}

function controlaOperacao(){
    //cabecalho
    Cabecalho = $('#'+NomeCabecalho);
    Ccddopcao = $('#cddopcao', Cabecalho);
    cddopcao = Ccddopcao.val();

    //filtro
    Filtro = $('#'+NomeFiltro);
    Ccdempres = $('#cdempres', Filtro); // * Filtro // Código Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Convênio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    cdempres = Ccdempres.val(); // * Filtro // Código Empresa
    indconsignado = Cindconsignado.val(); // 'Convênio Consignado'
    dtativconsignado = Cdtativconsignado.val(); // 'Data'

    //form
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Razão Social
    Ctpmodconvenio = $('#tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza Débito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobrança
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza Débito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobrança
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrupção Cobrança
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#indalertaemailconsig', FrmConsig);// Alertas Consig(check box)

    nmextemp = Cnmextemp.val(); // * Form Consignado // Razão Social
    tpmodconvenio = Ctpmodconvenio.val(); // Tipo de Convenio INSS/ Publico / Privado
    dtfchfol = Cdtfchfol.val(); // Dia Fechamento Folha
    nrdialimiterepasse =  Cnrdialimiterepasse.val(); // Dia Limite para Repasse
    indautrepassecc = Hindautrepassecc.val(); // Autoriza Débito Repasse em C/C?
    indinterromper = Hindinterromper.val(); // Interrompe Cobrança
    dtinterromper = Cdtinterromper.val(); // Data Interrupção Cobrança
    dsdemail = Cdsdemail.val(); // E-mail
    indalertaemailemp = Cindalertaemailemp.val(); // Alertas (check box)
    dsdemailconsig = Cdsdemailconsig.val(); // E-mail Consignado
    indalertaemailconsig = Cindalertaemailconsig.val();// Alertas Consig(check box)

    


    // Validações de campos obrigatórios no front
    // Publico
    if(tpmodconvenio == 2 && (cddopcao == 'A' || cddopcao == 'H')){
        // Dia fechamento folha
        if(dtfchfol == ''){
            hideMsgAguardo();
            showError(
                'error',
                'Informe um dia v&aacute;lido.',
                'Alerta - Ayllos',
                 "$('#dtfchfol','#"+FrmConsig.attr('id')+"').focus()");
            return false;
        }
        // Interrompe cobrança
        if(!Cindinterromper.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; deseja Interromper a Cobran&ccedil;a.',
                'Alerta - Ayllos',
                '');
            return false;
        }

    }

    // Privado
    if(tpmodconvenio == 1 && (cddopcao == 'A' || cddopcao == 'H')){
        // Dia fechamento folha
        if(dtfchfol == ''){
            hideMsgAguardo();
            showError(
                'error',
                'Informe um dia v&aacute;lido.',
                'Alerta - Ayllos',
                 "$('#dtfchfol','#"+FrmConsig.attr('id')+"').focus()");
            return false;
        }
        // Interrompe cobrança
        if(!Cindinterromper.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; deseja Interromper a Cobran&ccedil;a.',
                'Alerta - Ayllos',
                '');
            return false;
        }
        // Autoriza debito
        if(!Cindautrepassecc.is(':checked')) {
            showError(
                'error',
                'Informe se voc&ecirc; Autoriza d&eacute;bito repasse em c/c.',
                'Alerta - Ayllos',
                '');
            return false;
        }

    }

     $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/consig/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            cdempres: cdempres,
            indconsignado: indconsignado,
            dtativconsignado: dtativconsignado,
            nmextemp: nmextemp,
            tpmodconvenio: tpmodconvenio,
            dtfchfol: dtfchfol,
            nrdialimiterepasse: nrdialimiterepasse,
            indautrepassecc: indautrepassecc,
            indinterromper: indinterromper,
            dtinterromper: dtinterromper,
            dsdemail: dsdemail,
            indalertaemailemp: indalertaemailemp,
            dsdemailconsig: dsdemailconsig,
            indalertaemailconsig: indalertaemailconsig,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError(
                'error',
                'Nao foi possivel concluir a operacao.',
                'Alerta - Ayllos',
                '$("#nrconven", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                DivConsig.html(response);
                formataTelaConsig();

            }//catch
        }//success
    });//ajax
    return false;
}

function validaPermissao(cddopcao){
	var validaPerm = true;
	$.ajax({		
		type: "POST",
        async: false,
		url: UrlSite + "telas/consig/validaPermissao.php", 
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


//### tabela de parcelas
var dadosAtuais; 
var linhaEmEdicao = null; 
var linhasNovas = 0; 

function SalvaDados(idLinha){
	var celulas = document.getElementById(idLinha).cells;
	dadosAtuais = new Array(celulas.length);
	for(var i=0; i<celulas.length; i++){
		dadosAtuais[i] = celulas[i].innerHTML;
	}
	linhaEmEdicao = null;
}


function NovoRegistro(){
	if (Cindconsignado.val() =="1"){
		if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
			if(linhaEmEdicao){
				alert("Você está com um registro aberto. Feche-o antes de prosseguir");
			}else{
				proxIndice = document.getElementById('tblVencParc').rows.length-1;
				var novaLinha = document.getElementById('tblVencParc').insertRow(proxIndice);
				novaLinha.className = 'corSelecao';			
			}
			
			novoId = "nova"+linhasNovas;
			novaLinha.setAttribute('id', novoId);
			linhasNovas++; 
			linhaEmEdicao = novoId;
			
			var novasCelulas = new Array(8); 
			for(var i=0; i<8; i++){
				novasCelulas[i] = novaLinha.insertCell(i); 
			}
			
			if (proxIndice > 1){
				novasCelulas[0].innerHTML = '<input type="hidden" name="iLinha" >';
			}else{
				novasCelulas[0].innerHTML = '<a href="#" onclick="Replicar(\''+novoId+'\');"><img src="/imagens/icones/ico_reenviar.png" alt="Replicar" title="Replicar" /></a>';
			}
			novasCelulas[1].innerHTML = '<input type="hidden" id="iCod" name="iCod" readonly>';
			novasCelulas[2].innerHTML = '<input type="text" id="iDe" name="iDe"  maxlength="5" autofocus>';
			novasCelulas[3].innerHTML = '<input type="text" id="iAte" name="iAte" maxlength="5">';
			novasCelulas[4].innerHTML = '<input type="text" id="idtEnv" name="idtEnv"  maxlength="5">';
			novasCelulas[5].innerHTML = '<input type="text" id="idtVenc" name="idtVenc" maxlength="5">';
			novasCelulas[6].innerHTML = '<a href="#" onclick="Cadastrar(\''+novoId+'\');"><img src="/imagens/botoes/ok.gif" alt="Ok" /></a>';
			novasCelulas[7].innerHTML = '<a href="#" onclick="CancelarInclusao();"><img src="/imagens/botoes/cancelar.gif" alt="Cancelar" /></a>';
			$('#iDe').setMask("DATEDM", "", "", "divVencParc");
			$('#iAte').setMask("DATEDM", "", "", "divVencParc");
			$('#idtEnv').setMask("DATEDM", "", "", "divVencParc");
			$('#idtVenc').setMask("DATEDM", "", "", "divVencParc");
		}else{
			alert("Você precisa estar na Opção H(Habilitar) ou A(Alterar)!");
		}
	}else{
		alert("Você precisa Habilitar a empresa, clique em concluir!");
	}
}

function CancelarInclusao(){	
	
	var linha = document.getElementById(linhaEmEdicao);
	linha.parentNode.removeChild(linha);
	linhasNovas--;
	linhaEmEdicao = null;
	
}

function EditarLinha(idLinha, cod){
	if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
		if(linhaEmEdicao == null){
			var linha = document.getElementById(idLinha);
			linha.className = 'corSelecao';//Altera a cor da linha que será editada
			
			var celulas = linha.cells;//Aramazena a célula que será editada
			
			//salva os dados atuais para o caso de cancelamento
			SalvaDados(idLinha);

			linhaEmEdicao = idLinha; 

			celulas[0].innerHTML = '<input type="hidden" name="iLinha" value="'+celulas[0].innerHTML+'">';//Armazena o código do produto num campo oculto de formulário
			celulas[1].innerHTML = '<input type="hidden" id="iCod" name="iCod" value="'+celulas[1].innerHTML+'" maxlength="5" readonly autofocus>';//Mostrar o campo texto permitindo a edição do nome do produto
			celulas[2].innerHTML = '<input type="text" id="iDe" name="iDe" value="'+celulas[2].innerHTML+'" maxlength="5" autofocus>';//Mostrar o campo texto permitindo a edição do nome do produto
			celulas[3].innerHTML = '<input type="text" id="iAte" name="iAte" value="'+celulas[3].innerHTML+'" maxlength="5">';//Mostrar o campo texto permitindo a edição do preço do produto
			celulas[4].innerHTML = '<input type="text" id="idtEnv" name="idtEnv" value="'+celulas[4].innerHTML+'" maxlength="5">';//Mostrar o campo texto permitindo a edição do preço do produto
			celulas[5].innerHTML = '<input type="text" id="idtVenc" name="idtVenc" value="'+celulas[5].innerHTML+'" maxlength="5">';//Mostrar o campo texto permitindo a edição do preço do produto
			celulas[6].innerHTML = '<a href="#" onclick="Cadastrar(\''+idLinha+'\');"><img src="/imagens/botoes/ok.gif" alt="Ok" /></a>';//Monta os links que chamarão as funções para atualizar ou cancelar a edição da linha
			celulas[7].innerHTML = '<a href="#" onclick="Cancelar(\''+idLinha+'\');"><img src="/imagens/botoes/cancelar.gif" alt="Cancelar" /></a>';//Insere um espaço na última célula
			$('#iDe').setMask("DATEDM", "", "", "divVencParc");
			$('#iAte').setMask("DATEDM", "", "", "divVencParc");
			$('#idtEnv').setMask("DATEDM", "", "", "divVencParc");
			$('#idtVenc').setMask("DATEDM", "", "", "divVencParc");
		}
		else {alert("Você já está digitando um registro.");}
	}else{
		alert("Você precisa estar na Opção H(Habilitar) ou A(Alterar)!");
	}
}

function Cancelar(idLinha){
	
	var linha = document.getElementById(idLinha);
	
	if (dadosAtuais[0] % 2 == 0){
		linha.className = 'odd corPar';
	}else{
		linha.className = 'even corImpar';
	}
	
	linha.innerHTML = '<tr id="'+idLinha+'">' + 
	'<td align="center">'+dadosAtuais[0]+'</td>' +
	'<td align="center">'+dadosAtuais[1]+'</td>' +
	'<td align="center">'+dadosAtuais[2]+'</td>' +
	'<td align="center">'+dadosAtuais[3]+'</td>' +
	'<td align="center">'+dadosAtuais[4]+'</td>' +
	'<td align="center">'+dadosAtuais[5]+'</td>' +
	'<td align="center"><a href="#" onclick="EditarLinha(\''+idLinha+'\',\'' + dadosAtuais[0] + '\');"><img src="/imagens/botoes/alterar.gif" alt="Editar" title="Editar"></a></td>' +
	'<td align="center"><a href="#" onclick="ExcluirLinha(\''+idLinha+'\',\'' + dadosAtuais[0] + '\');"><img src="/imagens/botoes/excluir.gif" alt="Excluir" title="Excluir"></a></td>' ;
	linhaEmEdicao = null;
}

function Cadastrar(idLinha)
{
	var iCod,iDe,iAte,idtEnv,idtVenc;
	dadosAtuais = new Array(8);
	
	iCod = document.getElementById('iCod').value;
	iDe = document.getElementById('iDe').value;
	iAte = document.getElementById('iAte').value;
	idtEnv = document.getElementById('idtEnv').value;
	idtVenc = document.getElementById('idtVenc').value;
	
	//var proxIndice = document.getElementById('tblVencParc').rows.length-3;
	//var proxLinha = document.getElementById('tblVencParc').rows.length-2;	
	var proxLinha = Number(document.getElementById('total').value) +1;
	var proxIndice = proxLinha - 1;	
	dadosAtuais[0] = 'trLinha'+proxIndice;
	dadosAtuais[1] = proxLinha;
	dadosAtuais[2] = iCod;
	dadosAtuais[3] = iDe;
	dadosAtuais[4] = iAte;
	dadosAtuais[5] = idtEnv;
	dadosAtuais[6] = idtVenc;	
	dadosAtuais[7] = idLinha;
		
	if (iCod < 1 ){
		iCod = 0;
	}
	
	showMsgAguardo("Aguarde gravando dados...");
	
	$.ajax({
				type: 'POST',
				url: UrlSite + 'telas/consig/manter_rotina.php',
				data: {
					cddopcao: 'VPI',
					cdempres: cdempres,
					vp_cod: iCod,
					vp_de: iDe,
					vp_ate: iAte,
					vp_dtEnvio: idtEnv,
					vp_dtVencimento: idtVenc,
					
					redirect: 'script_ajax'
				},
				error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
					showError(
						'error',
						'Nao foi possivel concluir a operacao.',
						'Alerta - Ayllos',
						'$("#nrconven", "#frmFiltro").focus();');
				},
				success: function (response) {
					hideMsgAguardo();
					try {								
						linhaEmEdicao = null;	
						if (response.search('frmVencParc') == -1){
							showError(
								'error',
								response,
								'Alerta - Ayllos',
							'');
						}else{
							$('#divVencParc').html(response);						
						}
											
					
					} catch (error) {
						showError(
							'error',
							error,
							'Alerta - Ayllos',
							'');
					}//catch
				}//success
			});//ajax
			return false;
}

function Replicar(idLinha)
{
	var iCod,iDe,iAte,idtEnv,idtVenc;
	dadosAtuais = new Array(8);
	
	iCod = document.getElementById('iCod').value;
	iDe = document.getElementById('iDe').value;
	iAte = document.getElementById('iAte').value;
	idtEnv = document.getElementById('idtEnv').value;
	idtVenc = document.getElementById('idtVenc').value;
	
	//var proxIndice = document.getElementById('tblVencParc').rows.length-3;
	//var proxLinha = document.getElementById('tblVencParc').rows.length-2;	
	var proxLinha = Number(document.getElementById('total').value) +1;
	var proxIndice = proxLinha - 1;	
	dadosAtuais[0] = 'trLinha'+proxIndice;
	dadosAtuais[1] = proxLinha;
	dadosAtuais[2] = iCod;
	dadosAtuais[3] = iDe;
	dadosAtuais[4] = iAte;
	dadosAtuais[5] = idtEnv;
	dadosAtuais[6] = idtVenc;	
	dadosAtuais[7] = idLinha;
		
	if (iCod < 1 ){
		iCod = 0;
	}
	
	showMsgAguardo("Aguarde gravando dados...");
	
	$.ajax({
				type: 'POST',
				url: UrlSite + 'telas/consig/manter_rotina.php',
				dataType:'html',
				data: {
					cddopcao: 'VPR',
					cdempres: cdempres,
					vp_cod: iCod,
					vp_de: iDe,
					vp_ate: iAte,
					vp_dtEnvio: idtEnv,
					vp_dtVencimento: idtVenc,
					
					redirect: 'html_ajax'
				},
				error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
					showError(
						'error',
						'Nao foi possivel concluir a operacao.',
						'Alerta - Ayllos',
						'$("#nrconven", "#frmFiltro").focus();');
				},
				success: function (response) {
					hideMsgAguardo();
					try {								
						linhaEmEdicao = null;	
						if (response.search('frmVencParc') == -1){
							showError(
								'error',
								response,
								'Alerta - Ayllos',
							'');
						}else{
							$('#divVencParc').html(response);						
						}
											
					
					} catch (error) {
						showError(
							'error',
							error,
							'Alerta - Ayllos',
							'');
					}//catch
				}//success
			});//ajax
			return false;
}

function ExcluirLinha(idLinha, cod){
	if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
		if(!linhaEmEdicao){
			var linha = document.getElementById(idLinha);
			linha.className = 'corSelecao';
			if(confirm("Tem certeza que deseja excluir este registro?")){
				$.ajax({
					type: 'POST',
					dataType:'html',
					url: UrlSite + 'telas/consig/manter_rotina.php',
					data: {
						cddopcao: 'VPE',
						cdempres: cdempres,
						vp_cod: cod,
						redirect: 'html_ajax'
					},
					error: function (objAjax, responseError, objExcept) {
						hideMsgAguardo();
						showError(
							'error',
							'Nao foi possivel concluir a operacao.',
							'Alerta - Ayllos',
							'$("#nrconven", "#frmFiltro").focus();');
					},
					success: function (response) {
						hideMsgAguardo();
						try {								
							linhaEmEdicao = null;	
							if (response.search('frmVencParc') == -1){
								showError(
									'error',
									response,
									'Alerta - Ayllos',
								'');
							}else{
								$('#divVencParc').html(response);						
							}
							
							//document.getElementById('tblVencParc').innerHTML = ret;							
						
						} catch (error) {
							showError(
							'error',
							error,
							'Alerta - Ayllos',
							'');
						}//catch
					}//success
				});//ajax
				return false;
			}else{
				var celulas = linha.cells;				
				if (celulas[0].innerHTML % 2 == 0){
					linha.className = 'odd corPar';
				}else{
					linha.className = 'even corImpar';
				}
			}
		}else{
			alert("Você está com um registro aberto. Feche-o antes de prosseguir.");
		}
	}else{
		alert("Você precisa estar na Opção H(Habilitar) ou A(Alterar)!");
	}
}


function ajustaStatus(info){	
    if(info == "1"){
		Cindconsignado.val("1");
        CtextIndconsignado.val("Sim");
    } else if(indconsignado == '0') {
        Cindconsignado.val("0");
        CtextIndconsignado.val("Nao");
	}else if(indconsignado == '2') {
        Cindconsignado.val("2");
        CtextIndconsignado.val("Pend.");
    }else{
        Cindconsignado.val("");
        CtextIndconsignado.val("");
    }
	
};

/*
function Limpar() {
	var total = document.getElementById('total').value;
    console.log(total);
	for(var i = 0; i < total; i++){
		var linha = document.getElementById('linha'+(i));
		linha.parentNode.removeChild(linha);
	}
};
*/



