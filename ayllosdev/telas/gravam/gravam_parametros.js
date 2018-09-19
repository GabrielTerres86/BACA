$(document).ready(function(){
	$("#aprvcord", "#divFiltroParametros").change(function(){
		if($(this).val() == 'A'){
			$('label[for="perccber"]', '#divFiltroParametros').css({'display': 'block'});	
			$('#perccber', '#divFiltroParametros').css({'display': 'block'});	
		} else{
			$('label[for="perccber"]', '#divFiltroParametros').css({'display': 'none'});	
			$('#perccber', '#divFiltroParametros').css({'display': 'none'});	
		}
	});

	formataFiltroParametros();
});

function formataFiltroParametros(){
	// Desabilitar a opção
	$("#cddopcao", "#frmCab").desabilitaCampo();
	
	$("#cddopcao", "#frmCab").css("width", "560px");
	
	//rotulo
	$('label[for="hrenvi02"]', '#divFiltroParametros').removeClass('rotulo');
	$('label[for="hrenvi03"]', '#divFiltroParametros').removeClass('rotulo');	
	
	$('#nrdiaenv', '#divFiltroParametros').setMask("INTEGER", "999", "");
	$('#perccber', '#divFiltroParametros').css({ 'text-align': 'center' }).setMask("DECIMAL", "zz9,99", ".", "");
	$('#nrdnaoef', '#divFiltroParametros').setMask("INTEGER", "999", "");
	$('#nrdnaoef', '#divFiltroParametros').addClass('campo').css({'width': '50px'});
	$("#aprvcord", "#divFiltroParametros").change();
	
	$('#frmFiltro').css({ 'display': 'block' });
}

function gravaParametros() {
	var nrdiaenv = $("#nrdiaenv","#divFiltroParametros").val();
	var hrenvi01 = $("#hrenvi01","#divFiltroParametros").val();
	var hrenvi02 = $("#hrenvi02","#divFiltroParametros").val();
	var hrenvi03 = $("#hrenvi03","#divFiltroParametros").val();
	var aprvcord = $("#aprvcord","#divFiltroParametros").val();
	var perccber = $("#perccber","#divFiltroParametros").val();
	var tipcomun = $("#tipcomun","#divFiltroParametros").val();
	var nrdnaoef = $("#nrdnaoef","#divFiltroParametros").val();
	var emlnaoef = $("#emlnaoef","#divFiltroParametros").val();


	emlnaoef = myTrim(emlnaoef);

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo configura&ccedil;&otilde;es de Par&acirc;metros ...");

	// Executa script de consulta através de ajax
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/gravam/grava_parametros_gravam.php",
		data: {
			nrdiaenv: nrdiaenv,
			hrenvi01: hrenvi01,
			hrenvi02: hrenvi02,
			hrenvi03: hrenvi03,
			aprvcord: aprvcord,
			perccber: perccber,
			tipcomun: tipcomun,
			nrdnaoef: nrdnaoef,
			emlnaoef: emlnaoef,
			redirect: "script_ajax"
		},
		error: function(objAjax, responseError, objExcept) {
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


function myTrim(x) {
    return x.replace(/^\s+|\s+$/gm,'');
}
