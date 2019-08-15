/***********************************************************************
 Fonte: consig.js                                                  
 Autor: Leonardo Oliveira - GFT 
 Data : Agoso/2018                Ultima Altera��o:                                                                    
 Objetivo  : Cadastro de servicos ofertados na tela CADCCO
                                                                   	 
 Altera��es: 03/2019 - JDB AMcom P437

************************************************************************/
//
var CooperConsig = '';
var linhasNovas = 0; 

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
var Ccddopcao // * Cabecalho // C�digo Opera��o
    ,Ccdempres // * Filtro // C�digo Empresa
    ,Cindconsignado // 'Conv�nio Consignado'
    ,Cdtativconsignado // 'Data'
    ,Cnmextemp // * Form Consignado // Raz�o Social
    ,Ctpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Cdtfchfol // Dia Fechamento Folha
    ,Cnrdialimiterepasse // Dia Limite para Repasse
    ,Cindautrepassecc // Autoriza D�bito Repasse em C/C?
    ,Cindinterromper // Interrompe Cobran�a
    ,Cdtinterromper // Data Interrup��o Cobran�a
    ,Cdsdemail // E-mail
    ,Cindalertaemailemp // Alertas (check box)
    ,Cdsdemailconsig // E-mail Consignado
    ,Cindalertaemailconsig
	,Cdcooper
	; // Alertas Consignado (check box)

//labels
var Lcddopcao // * Cabecalho
    ,Lcdempres // * Filtro
    ,Lindconsignado // 'Conv�nio Consignado'
    ,Ldtativconsignado // 'Data'
    ,Lnmextemp // * Form Consignado // Raz�o Social
    ,Ltpmodconvenio // Tipo de Convenio INSS/ Publico / Privado
    ,Ldtfchfol // Dia Fechamento Folha
    ,Lnrdialimiterepasse // Dia Limite para Repasse
    ,Lindautrepassecc // Autoriza D�bito Repasse em C/C?
    ,Lindinterromper // Interrompe Cobran�a
    ,Ldtinterromper // Data Interrup��o Cobran�a
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
	linhasNovas = 0; 
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

    Ccdempres = $('#cdempres', Filtro); // * Filtro // C�digo Empresa
    Cindconsignado = $('#text_indconsignado', Filtro); // 'Conv�nio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'
    Crowid = $('#rowid_emp_consig', Filtro); // rowid

    Lcdempres = $('label[for="cdempres"]', Filtro); // * Filtro // C�digo Empresa
    Lindconsignado = $('label[for="text_indconsignado"]', Filtro); // 'Conv�nio Consignado'
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
			BtProsseguir.focus();
            return false;
        }
    });

    //Ao clicar no botao OK
    BtProsseguir.unbind('click').bind('click', function () {
        if(!existeEmpresa()){
            buscarDescricao();
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

    Ccdempres = $('#cdempres', Filtro); // * Filtro // C�digo Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Conv�nio Consignado'
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
    var filtros = 'Cod. Empresa;cdempres;60;S;;S;;|Nome Empresa;nmextemp;150;S;;S;;|;cddopcao;;N;' + cddopcao + ';N;|Habilitado;indconsignado;30;N;;N;;radio|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var colunas = 'Codigo;cdempres;19%;right;;S;;|Empresa;nmextemp;60%;left;;S;;|;cddopcao;;N;;N;|Habilitado;hindconsignado;19%;right;;N;;|Data;dtativconsignado;;N;;N;;|rowid;rowid_emp_consig;;N;;N;;';
    var divBloqueia = '';
    var fncOnClose = 'buscarDescricao();';
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
    if (cdempres != '' && cdempres > 0){
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
                        if (rowid_emp_consig == "") {
                            Ccdempres.val('');
							return false;
						}
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
        }
    return false;
}


function callbackBuscarDescricao(){
    return false;
}

function fecharPesquisa(){
    Filtro = $('#'+NomeFiltro);
    Cindconsignado = $('#indconsignado', Filtro); // 'Conv�nio Consignado'
    CtextIndconsignado = $('#text_indconsignado', Filtro); // 'Conv�nio Consignado'
    var indconsignado = Cindconsignado.val();
    if(indconsignado == "1"){
        CtextIndconsignado.val("Sim");
    } else if(indconsignado == '0') {
        CtextIndconsignado.val("N㯢); 
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
    Ccdempres = $('#cdempres', Filtro); // * Filtro // C�digo Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Conv�nio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    var cddopcao = Ccddopcao.val();
    var cdempres = Ccdempres.val(); // * Filtro // C�digo Empresa
    var indconsignado = Cindconsignado.val(); // 'Conv�nio Consignado'
    var dtativconsignado = Cdtativconsignado.val(); // 'Data'
        if(!existeEmpresa()){
                hideMsgAguardo();
                showError(
                    'error',
                    'N&atilde;o ha codigo de empresa cadastrado.',
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
                    'N&atilde;o foi possivel concluir a operacao.',
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
    Cdempres = $('#cdempres', Filtro);// C�digo Empresa

    cdempres = Cdempres.val();
    rowid = Crowid.val();
    
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

    Lnmextemp = $('label[for="nmextemp"]', FrmConsig); // * Form Consignado // Raz�o Social
    Ltpmodconvenio = $('label[for="select_tpmodconvenio"]', FrmConsig);  // Tipo de Convenio INSS/ Publico / Privado
    Ldtfchfol = $('label[for="dtfchfol"]', FrmConsig);  // Dia Fechamento Folha
    Lnrdialimiterepasse = $('label[for="nrdialimiterepasse"]', FrmConsig);  // Dia Limite para Repasse
    Lindautrepassecc = $('label[for="radio_indautrepassecc"]', FrmConsig);  // Autoriza D�bito Repasse em C/C?
    Lindinterromper = $('label[for="radio_indinterromper"]', FrmConsig);  // Interrompe Cobran�a
    Ldtinterromper = $('label[for="dtinterromper"]', FrmConsig); // Data Interrup��o Cobran�a
    Ldsdemail = $('label[for="dsdemail"]', FrmConsig); // E-mail
    Ldsdemailconsig = $('label[for="dsdemailconsig"]', FrmConsig); // E-mail Consignado
    Llbalertaconsig =  $('#lbalertaconsig', FrmConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Raz�o Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza D�bito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobran�a
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrup��o Cobran�a
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

	// verifica��o de altera��o de valores pelo usu�rio
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

// Se Interrompe Cobran�a == N�o ENTAO data interrup��o == ''
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

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Raz�o Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza D�bito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobran�a
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza D�bito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobran�a
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrup��o Cobran�a
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
    Cdsdemail.desabilitaCampo(); // E-mail sempre desabilitado par altera��o manual
    
    // Configura os valores default para radios e checks
    $('input[name=radio_indautrepassecc]').prop('checked', false);
    $('input[name=radio_indautrepassecc][value='+Hindautrepassecc.val()+']').prop('checked', true); 
    $('input[name=radio_indinterromper]').prop('checked', false);
    $('input[name=radio_indinterromper][value='+Hindinterromper.val()+']').prop('checked', true); 
    if(Hindalertaemailemp.val() == '1')$('input[name=checkbox_indalertaemailemp]').prop('checked', true); 
    if(Hindalertaemailconsig.val() == '1')$('input[name=checkbox_indalertaemailconsig]').prop('checked', true);


    if(cddopcao == 'C' || cddopcao == 'D'){ // CONSULTA - desabilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Raz�o Social
        Cdtfchfol.desabilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.desabilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.desabilitaCampo(); // Autoriza D�bito Repasse em C/C?
        Cindinterromper.desabilitaCampo(); // Interrompe Cobran�a
        Cdtinterromper.desabilitaCampo(); // Data Interrup��o Cobran�a
        Cindalertaemailemp.desabilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.desabilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.desabilitaCampo(); // Alertas Consignado (check box)
    } else { // Se n�o for CONSULTA por padr�o habilita todos os campos
        Cnmextemp.desabilitaCampo(); // * Form Consignado // Raz�o Social - por padr�o nao fica desabilatado para altera��o
        Cdtfchfol.habilitaCampo(); // Dia Fechamento Folha
        Cnrdialimiterepasse.habilitaCampo(); // Dia Limite para Repasse
        Cindautrepassecc.habilitaCampo(); // Autoriza D�bito Repasse em C/C?
        Cindinterromper.habilitaCampo(); // Interrompe Cobran�a
        Cdtinterromper.habilitaCampo(); // Data Interrup��o Cobran�a
        Cindalertaemailemp.habilitaCampo(); // Alertas (check box)
        Cdsdemailconsig.habilitaCampo(); // E-mail Consignado
        Cindalertaemailconsig.habilitaCampo(); // Alertas Consignado (check box)
    }

    // Select do tipo de convenivo s� fica habilitado para H - Habilitar
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
            //$('input[name=radio_indinterromper]').prop('checked', false);
            //$('input[name=radio_indinterromper][value=0]').prop('checked', true); 
			$('#indinterromper', FrmConsig).val(0);
        }

    }else if(tpmodconvenio == 2){// Publico
        //Autoriza D�bito Repasse em C/C?		
		DivVencParc.css('display', 'block');
		if (Cdtfchfol.val() == '')
			Cdtfchfol.val(dtfchfolOld);
        Cindautrepassecc.desabilitaCampo();
        if(cddopcao == 'A' || cddopcao == 'H'){
            $('input[name=radio_indautrepassecc]').prop('checked', false);
			$('#indautrepassecc', FrmConsig).val(0);
			$('#indinterromper', FrmConsig).val(0);
        }
    } else if ( tpmodconvenio == 3 || tpmodconvenio == 0){ // INSS
        // Limpa data de interrup��o para INSS
		DivVencParc.css('display', 'none');
        Cdtfchfol.val('');
        //Cdsdemail.val('');
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
            // Autoriza D�bito Repasse em C/C?
            Cindautrepassecc.desabilitaCampo();
            // Interrompe Cobran�a
            Cindinterromper.desabilitaCampo();
            // Data Interrup��o Cobran�a
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
            // Raz�o Social
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
    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Raz�o Social
    Ctpmodconvenio = $('#select_tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza D�bito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobran�a
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrup��o Cobran�a
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
            // Voltar de filtro para cabe�alho
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
    Ccdempres = $('#cdempres', Filtro); // * Filtro // C�digo Empresa
    Cindconsignado = $('#indconsignado', Filtro); // 'Conv�nio Consignado'
    Cdtativconsignado = $('#dtativconsignado', Filtro); // 'Data'

    cdempres = Ccdempres.val(); // * Filtro // C�digo Empresa
    indconsignado = Cindconsignado.val(); // 'Conv�nio Consignado'
    dtativconsignado = Cdtativconsignado.val(); // 'Data'

    //form
    FrmConsig = $('#'+NomeFrmConsig);
    DivConsig = $('#'+NomeDivConsig);

    Cnmextemp = $('#nmextemp', FrmConsig); // * Form Consignado // Raz�o Social
    Ctpmodconvenio = $('#tpmodconvenio', FrmConsig); // Tipo de Convenio INSS/ Publico / Privado
    Cdtfchfol = $('#dtfchfol', FrmConsig); // Dia Fechamento Folha
    Cnrdialimiterepasse = $('#nrdialimiterepasse', FrmConsig); // Dia Limite para Repasse
    Cindautrepassecc = $('#radio_indautrepassecc', FrmConsig); // Autoriza D�bito Repasse em C/C?
    Cindinterromper = $('#radio_indinterromper', FrmConsig); // Interrompe Cobran�a
    Hindautrepassecc = $('#indautrepassecc', FrmConsig); // HIDDEN Autoriza D�bito Repasse em C/C?
    Hindinterromper = $('#indinterromper', FrmConsig); // HIDDEN Interrompe Cobran�a
    Cdtinterromper = $('#dtinterromper', FrmConsig); // Data Interrup��o Cobran�a
    Cdsdemail = $('#dsdemail', FrmConsig); // E-mail
    Cindalertaemailemp = $('#checkbox_indalertaemailemp', FrmConsig); // Alertas (check box)
    Cdsdemailconsig = $('#dsdemailconsig', FrmConsig); // E-mail Consignado
    Cindalertaemailconsig = $('#checkbox_indalertaemailconsig', FrmConsig);// Alertas Consig(check box)

    nmextemp = Cnmextemp.val(); // * Form Consignado // Raz�o Social
    tpmodconvenio = Ctpmodconvenio.val(); // Tipo de Convenio INSS/ Publico / Privado
    dtfchfol = Cdtfchfol.val(); // Dia Fechamento Folha
    nrdialimiterepasse =  Cnrdialimiterepasse.val(); // Dia Limite para Repasse
    indautrepassecc = Hindautrepassecc.val(); // Autoriza D�bito Repasse em C/C?
    indinterromper = Hindinterromper.val(); // Interrompe Cobran�a
    dtinterromper = Cdtinterromper.val(); // Data Interrup��o Cobran�a
    dsdemail = Cdsdemail.val(); // E-mail
    indalertaemailemp = Cindalertaemailemp.is(':checked') ? 1 : 0;
    dsdemailconsig = Cdsdemailconsig.val(); // E-mail Consignado
    indalertaemailconsig = Cindalertaemailconsig.is(':checked') ? 1 : 0;

    // Calida絥s de campos obrigat?s no front
    if(tpmodconvenio == 0){
        hideMsgAguardo();
            showError(
                'error',
                'Tipo de Convenio deve ser selecionado.',
                'Alerta - Ayllos',
                 "$('#dtfchfol','#"+FrmConsig.attr('id')+"').focus()");
            return false;
    }

    //Valida磯 email
    if (indalertaemailconsig == 1 && dsdemailconsig == ''){
        if (!validaEmailCademp(dsdemailconsig)) {
            showError('error', 'E-mail Consig. deve ser informado!',
                    'Campo Obrigat&oacute;rio!',
                    '$(Cdsdemailconsig).focus();');
            return false;
        }
    }
    if (dsdemailconsig != '') {
        if (!validaEmailCademp(dsdemailconsig)) {
            showError('error', 'E-mail Consig. inv&aacute;lido!',
                    'Valida&ccedil;&atilde;o e-mail',
                    '$(Cdsdemailconsig).focus();');
            return false;
        }
    }

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
        // Interrompe cobran�a
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
        // Interrompe cobran�a
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
	
	var vencimentos = retVencimentos();
	showMsgAguardo("Aguarde ...");
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
			vencimentos: vencimentos,
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

function NovoRegistro(){
		if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
			proxIndice = document.getElementById('tblVencParc').rows.length-1;
			var novaLinha = document.getElementById('tblVencParc').insertRow(proxIndice);
			novaLinha.className = 'corSelecao';	
			if (linhasNovas == 0){			
				linhasNovas = proxIndice;
			}
			novoId = linhasNovas;
			novaLinha.setAttribute('id', novoId);
			
			var novasCelulas = new Array(5); 
			for(var i=0; i<5; i++){
				novasCelulas[i] = novaLinha.insertCell(i); 
			}
			
			if (proxIndice == 1){
				document.getElementById('tdReplicar').innerHTML = '<a href="javascript:Replicar();"  class="botao">Replicar</a>';
			}else{
				document.getElementById('tdReplicar').innerHTML = '&nbsp;';
			}
			novasCelulas[0].innerHTML = '<input type="hidden" id="idemprconsigparam_'+linhasNovas+'" name="idemprconsigparam_'+linhasNovas+'" readonly>';
			novasCelulas[0].innerHTML += '<input type="text"  class="campo" style=\"text-align:center\" id="dtinclpropostade_'+linhasNovas+'" name="dtinclpropostade_'+linhasNovas+'"  maxlength="5" autofocus>';
			novasCelulas[1].innerHTML = '<input type="text"  class="campo" style=\"text-align:center\" id="dtinclpropostaate_'+linhasNovas+'" name="dtinclpropostaate_'+linhasNovas+'" maxlength="5">';
			novasCelulas[2].innerHTML = '<input type="text"  class="campo" style=\"text-align:center\" id="dtenvioarquivo_'+linhasNovas+'" name="dtenvioarquivo_'+linhasNovas+'"  maxlength="5">';
			novasCelulas[3].innerHTML = '<input type="text" class="campo" style=\"text-align:center\" id="dtvencimento_'+linhasNovas+'" name="dtvencimento_'+linhasNovas+'" maxlength="5">';
			novasCelulas[4].innerHTML = '<a href="javascript:Cancelar(\''+novoId+'\');" class="botao" >Excluir</a>';
			
			$('#dtinclpropostade_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
			$('#dtinclpropostaate_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
			$('#dtenvioarquivo_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
			$('#dtvencimento_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
			linhasNovas = linhasNovas +1;
		}else{
			showError("info","Voc&ecirc; precisa estar na Op&ccedil;&atilde;o H - (Habilitar) ou A - (Alterar)! ","Alerta - Ayllos","");			
		}
	
}

function mascara(total){
	if(Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
		$('#btincluir').css('display', 'block');	
	}else{
		$('#btincluir').css('display', 'none');	
	}
	for(var i=0; i<total; i++){
		$('#dtinclpropostade_'+i).setMask("DATEDM", "", "", "divVencParc");
		$('#dtinclpropostaate_'+i).setMask("DATEDM", "", "", "divVencParc");
		$('#dtenvioarquivo_'+i).setMask("DATEDM", "", "", "divVencParc");
		$('#dtvencimento_'+i).setMask("DATEDM", "", "", "divVencParc");
		$('#dtinclpropostade_'+i).desabilitaCampo();
		$('#dtinclpropostaate_'+i).desabilitaCampo();
		$('#dtenvioarquivo_'+i).desabilitaCampo();
		$('#dtvencimento_'+i).desabilitaCampo();
		$('#btexcluir_'+i).css('display', 'none');		
		if(Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
			$('#dtinclpropostade_'+i).habilitaCampo();
			$('#dtinclpropostaate_'+i).habilitaCampo();
			$('#dtenvioarquivo_'+i).habilitaCampo();
			$('#dtvencimento_'+i).habilitaCampo();
			$('#btexcluir_'+i).css('display', 'block');	
		}
	}
}

function Cancelar(linhaEmEdicao){	
	if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
		var linha = document.getElementById(linhaEmEdicao);
		linha.parentNode.removeChild(linha);
		var proxIndice = document.getElementById('tblVencParc').rows.length-1;
		if (proxIndice == 2){
			document.getElementById('tdReplicar').innerHTML = '<a href="javascript:Replicar();"  class="botao">Replicar</a>';
		}else{
			document.getElementById('tdReplicar').innerHTML = '&nbsp;';
		}
	}else{
		showError("info","Voc&ecirc; precisa estar na Op&ccedil;&atilde;o H - (Habilitar) ou A - (Alterar)! ","Alerta - Ayllos","");
	}
	
}

function retVencimentos(){
	 var tabela = document.getElementById('tblVencParc');
	 var nlinhas = tabela.rows.length;
	 var tbLinhas = tabela.rows;
	 var ret,idLinha,dtinclpropostade,dtinclpropostaate,dtenvioarquivo,dtvencimento;
	 var cnt = 0;
	 ret = '<vencimentos>';
	 for(var i=0; i< nlinhas; i++){		
		idLinha = tbLinhas[i].getAttribute('id');
		dtinclpropostade = $('#dtinclpropostade_'+idLinha).val();
		dtinclpropostaate = $('#dtinclpropostaate_'+idLinha).val();
		dtenvioarquivo = $('#dtenvioarquivo_'+idLinha).val();
		dtvencimento = $('#dtvencimento_'+idLinha).val();		
		if((typeof dtinclpropostade != 'undefined')&&(typeof dtinclpropostaate != 'undefined')&&(typeof dtenvioarquivo != 'undefined')&&(typeof dtvencimento != 'undefined')){
			if ((dtinclpropostade != "") && (dtinclpropostaate != "") && (dtenvioarquivo != "") && (dtvencimento != "")){
				cnt++;
				ret += '<vencimento'+cnt+'>';
				ret += '<dtinclpropostade>'+dtinclpropostade+'</dtinclpropostade>';
				ret += '<dtinclpropostaate>'+dtinclpropostaate+'</dtinclpropostaate>';
				ret += '<dtenvioarquivo>'+dtenvioarquivo+'</dtenvioarquivo>';
				ret += '<dtvencimento>'+dtvencimento+'</dtvencimento>';									
				ret += '</vencimento'+cnt+'>';
			}
		}		
	 }	 
	 ret += '<total>'+cnt+'</total>'
	 ret += '</vencimentos>';
	 //console.log(ret);
	 return ret;
	
}

function Replicar()
{
	if (Ccddopcao.val() == 'A' || Ccddopcao.val() == 'H'){
		document.getElementById('tdReplicar').innerHTML = '&nbsp;';
		
		var tabela = document.getElementById('tblVencParc');
		var nlinhas = tabela.rows.length;
		var tbLinhas = tabela.rows;
		var idLinha,dtinclpropostade,dtinclpropostaate,dtenvioarquivo,dtvencimento,made,maate,maarq,maven,dtde,dtate,dtarq,dtven,diade,diaate,diaarq,diaven;
		tbLinhas[1].className = 'even corImpar';	
		idLinha = tbLinhas[1].getAttribute('id');
		dtinclpropostade = $('#dtinclpropostade_'+idLinha).val();
		made = dtinclpropostade.substring(3, 5);
		diade = dtinclpropostade.substring(0, 2);
		dtinclpropostaate = $('#dtinclpropostaate_'+idLinha).val();
		maate = dtinclpropostaate.substring(3, 5);
		diaate = dtinclpropostaate.substring(0, 2);
		dtenvioarquivo = $('#dtenvioarquivo_'+idLinha).val();
		maarq = dtenvioarquivo.substring(3, 5);
		diaarq = dtenvioarquivo.substring(0, 2);
		dtvencimento = $('#dtvencimento_'+idLinha).val();		
		maven = dtvencimento.substring(3, 5);
		diaven = dtvencimento.substring(0, 2);
		if((typeof dtinclpropostade != 'undefined')&&(typeof dtinclpropostaate != 'undefined')&&(typeof dtenvioarquivo != 'undefined')&&(typeof dtvencimento != 'undefined')){
			if ((dtinclpropostade != "") && (dtinclpropostaate != "") && (dtenvioarquivo != "") && (dtvencimento != "")){
				for(var x=0; x<11; x++){
					//console.log
					proxIndice = document.getElementById('tblVencParc').rows.length-1;
					var novaLinha = document.getElementById('tblVencParc').insertRow(proxIndice);
					novaLinha.className = 'even corImpar';	
					if (linhasNovas == 0){			
						linhasNovas = proxIndice;
					}
					novoId = linhasNovas;
					novaLinha.setAttribute('id', novoId);
					
					var novasCelulas = new Array(5); 
					for(var i=0; i<5; i++){
						novasCelulas[i] = novaLinha.insertCell(i); 
					}	
					
					if (made < 12){
						made = Number(made) + 1;				
					}else if (made == 12){
						made = 1;
					}
					if (([4,6,9,11].indexOf(made) >= 0) && (diade > 30)){
						dtde = 30 + '/' + ('00' + made).slice(-2); 
					}else if ((made == 2) && (diade >28)){
						dtde = 28 + '/' + ('00' + made).slice(-2); 
					}else{	
						dtde = diade + '/' + ('00' + made).slice(-2); 
					}
					
					if (maate < 12){
						maate = Number(maate) + 1;				
					}else if (maate == 12){
						maate = 1;
					}
					if (([4,6,9,11].indexOf(maate) >= 0) && (diaate > 30)){
						dtate = 30 + '/' + ('00' + maate).slice(-2); 
					}else if ((maate == 2) && (diaate >28)){
						dtate = 28 + '/' + ('00' + maate).slice(-2); 
					}else{	
						dtate = diaate + '/' + ('00' + maate).slice(-2); 
					}
					
					if (maarq < 12){
						maarq = Number(maarq) + 1;				
					}else if (maarq == 12){
						maarq = 1;				
					}
					if (([4,6,9,11].indexOf(maarq) >= 0) && (diaarq > 30)){
						dtarq = 30 + '/' + ('00' + maarq).slice(-2); 
					}else if ((maarq == 2) && (diaarq >28)){
						dtarq = 28 + '/' + ('00' + maarq).slice(-2); 
					}else{	
						dtarq = diaarq + '/' + ('00' + maarq).slice(-2); 
					}
					
					if (maven < 12){
						maven = Number(maven) + 1;				
					}else if  (maven == 12){
						maven = 1;
					}
					if (([4,6,9,11].indexOf(maven) >= 0) && (diaven > 30)){
						dtven = 30 + '/' + ('00' + maven).slice(-2); 
					}else if ((maven == 2) && (diaven >28)){
						dtven = 28 + '/' + ('00' + maven).slice(-2); 
					}else{	
						dtven = diaven + '/' + ('00' + maven).slice(-2); 
					}
					
					novasCelulas[0].innerHTML = '<input type="hidden" id="idemprconsigparam_'+linhasNovas+'" name="idemprconsigparam_'+linhasNovas+'" readonly>';
					novasCelulas[0].innerHTML += '<input type="text" class="campo" value="'+dtde+'" style=\"text-align:center\" id="dtinclpropostade_'+linhasNovas+'" name="dtinclpropostade_'+linhasNovas+'"  maxlength="5" autofocus>';
					novasCelulas[1].innerHTML = '<input type="text" class="campo" value="'+dtate+'" style=\"text-align:center\" id="dtinclpropostaate_'+linhasNovas+'" name="dtinclpropostaate_'+linhasNovas+'" maxlength="5">';
					novasCelulas[2].innerHTML = '<input type="text" class="campo" value="'+dtarq+'" style=\"text-align:center\" id="dtenvioarquivo_'+linhasNovas+'" name="dtenvioarquivo_'+linhasNovas+'"  maxlength="5">';
					novasCelulas[3].innerHTML = '<input type="text" class="campo" value="'+dtven+'" style=\"text-align:center\" id="dtvencimento_'+linhasNovas+'" name="dtvencimento_'+linhasNovas+'" maxlength="5">';
					novasCelulas[4].innerHTML = '<a href="javascript:Cancelar(\''+novoId+'\');" class="botao" >Excluir</a>';
					
					$('#dtinclpropostade_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
					$('#dtinclpropostaate_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
					$('#dtenvioarquivo_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
					$('#dtvencimento_'+linhasNovas).setMask("DATEDM", "", "", "divVencParc");
					linhasNovas = linhasNovas +1;
				}
			}else{
				document.getElementById('tdReplicar').innerHTML = '<a href="javascript:Replicar();"  class="botao">Replicar</a>';
				showError("info","Valor Inv&aacute;lido para Replicar!","Alerta - Ayllos","");			
			}
		}else{
			document.getElementById('tdReplicar').innerHTML = '<a href="javascript:Replicar();"  class="botao">Replicar</a>';
			showError("info","Valor Inv&aacute;lido para Replicar!","Alerta - Ayllos","");
		}
	}else{
		showError("info","Voc&ecirc; precisa estar na Op&ccedil;&atilde;o H - (Habilitar) ou A - (Alterar)! ","Alerta - Ayllos","");			
	}
}

function validaEmailCademp(emailAddress) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))|(\",;+\")$/;
    var registro = new RegExp(re);
    return registro.test(emailAddress);
}