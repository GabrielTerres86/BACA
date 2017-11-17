/*!
 * FONTE        : envnot.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 11/09/2017
 * OBJETIVO     : Biblioteca de funções da tela ENVNOT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

 var cddopcao;
 var cdorigem_mensagem;
 var cdmotivo_mensagem;
 var nmimagem_banner;	
 var idacao_botao_acao_mobile;
 var dstitulo_mensagem;
 var cdicone;
 var dstexto_mensagem;
 var inexibir_banner;
 var dshtml_mensagem;
 var inexibe_botao_acao_mobile;
 var dstexto_botao_acao_mobile;
 var dslink_acao_mobile;
 var cdmenu_acao_mobile;
 var cdtipo_mensagem;
 var dhenvio_mensagem;
 var nrdias_mes;
 var nrdias_semana;
 var intipo_repeticao; 
 var inenviar_push;
 var dsmensagem_acao_mobile;
 var chk_dsmensagem_acao_mobile
 var inmensagem_ativa;
 var dsfiltro_tipos_conta;
 var tpfiltro;
 var dsfiltro_cooperativas;
 var dsfiltro_tipos_conta;
 var dtenvio_mensagem;
 var hrenvio_mensagem;
 var tpfiltro_mobile;
 var nmarquivo_csv;
 var cdmensagem;
 
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {
	$("#btnVoltar").hide();
	$("#btnSalvar").hide();
	$("#btnSalvar").hide();
	$("#divConteudoConsulta").hide();
	$("#cdmotivo_mensagem").prop('disabled', true);
	$("#btnOK").show();
	$("#cddopcao").prop('disabled', false);
	$("#cdorigem_mensagem").prop('disabled', false);
	$("#cdmotivo_mensagem").prop('disabled', false);
	$("#divConteudo").empty();
	layoutPadrao();	
}

function escolheOpcao(par_cddopcao){
		
	cddopcao = par_cddopcao;	
	
	cdorigem_mensagem = $("#cdorigem_mensagem").val();
	cdmotivo_mensagem = $("#cdmotivo_mensagem").val();
		
	if(cddopcao == "N" ||cddopcao == "C" ){
		$("#divConteudo").empty();
	}
	
	$("#btnOK").hide();
	$("#cddopcao").prop('disabled', true);
	$("#cdorigem_mensagem").prop('disabled', true);
	$("#cdmotivo_mensagem").prop('disabled', true);	
	$("#btnVoltar").show();
	
	if(cddopcao == "AM" || cddopcao == "N"){
		$("#btnSalvar").show();
	}
			
	// Executa script de exclusao de mensagens através de ajax
	$.ajax({		
		type: "POST",
		url: "carrega_layout.php", 
		data: {
			cddopcao: cddopcao,
			cdorigem_mensagem: cdorigem_mensagem,
			cdmotivo_mensagem: cdmotivo_mensagem,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
		},
		success: function(response) {
			try {
				$("#divConteudo").append(response);
				layoutPadrao();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
			}
		}				
	});
	
	return false;
		
}

function voltar(){
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	
	if($("#divConteudoConsulta").is(':visible')){
		$("#btnSalvar").hide();
		$("#divConteudoConsulta").hide();
		tabela.zebraTabela();
	}else{
		estadoInicial();
	}	
}

function carregaMotivo(cdorigem){
	var contmotivos = 0;
	
	// Executa script de exclusao de mensagens através de ajax
	$.ajax({		
		type: "POST",
		dataType: "json",
		url: "carrega_motivo.php", 
		data: {
			cdorigem: cdorigem,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
		},
		success: function(json) {
			try {
				$('#cdmotivo_mensagem').empty();
				if(json != ""){
					$.each(json, function (key, data) {
						$('#cdmotivo_mensagem').append($('<option>', {
							value: data.cdmotivo,
							text: data.dsmotivo
						}));
						contmotivos = contmotivos + 1;
					})
					$("#cdmotivo_mensagem").removeAttr('disabled');
					
					if(contmotivos == 1){
						escolheOpcao('AM');
					}
					
				}else{
					$("#cdmotivo_mensagem").attr('disabled',true);
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
			}
		}				
	});
}

function setaTipo(){
	$("#dstipo_mensagem").val($("#cdorigem_mensagem").children(":selected").attr("dstipo"));
	$("#cdtipo_mensagem").val($("#cdorigem_mensagem").children(":selected").attr("cdtipo"));
	carregaMotivo($("#cdorigem_mensagem").val());
}

function carregaIcone(){
	
	var conteudo = "";
	
	if($("#cdicone").val() != 0){
		conteudo = '<img src="'+ $("#cdicone").children(":selected").attr("urlImg") +'" alt="Icone" height="48" width="48">';
	}
	
	$("#divIcone").empty();
	$("#divIcone").html(conteudo);
}

function desabilitaPush(){
	if ($("#inmensagem_ativa").val() == 0)
	{
		$('#inenviar_push option[value=0]').attr('selected','selected');
		$('#inenviar_push').attr('disabled','disabled');
	}
	else
		$('#inenviar_push').removeAttr('disabled');
}

function tabela(){
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var cabecalho   = $('table > thead > tr', divRegistro );
	
	divRegistro.css({'height':'50%','width':'100%'});
	
	if($("#qtdConsultas").val() > 0){
		var ordemInicial = new Array();
		//ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[1] = '15%';
		arrayLargura[2] = '20%';
		arrayLargura[3] = '10%';
		arrayLargura[4] = '8%';
		arrayLargura[5] = '10%';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'left';
	}else{
		$("#btnvoltar").css({'margin-left':'260px'});
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('.divRegistros > table > thead').remove();
			
	$('table', tabela).removeClass();
	$('th', tabela).unbind('click');
	$('.headerSort', tabela).removeClass();
	var tabela      = $('table', divRegistro );
	tabela.zebraTabela();
}

function carregaImagem(tipoImg){
	
	var extn = "";
	var imgPath = "";
	var image_holder = $("#divNmimagem_banner");
	
	if(tipoImg == 0){
		imgPath = $("#dirimagem_banner")[0].value;
	}else{
		imgPath = $("#urlimagem_banner").val();
	}
	
	extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
  $("#nmimagem_banner").val(imgPath.substring(imgPath.lastIndexOf('/') + 1).toLowerCase());
	$("#nmimagem_banner").val(imgPath.substring(imgPath.lastIndexOf('\\') + 1).toLowerCase());
	
	if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {

		if(tipoImg == 0){
			if (typeof (FileReader) != "undefined"){

					image_holder.empty();

					var reader = new FileReader();
					reader.onload = function (e) {
						
						$("<img />", {
								"src": e.target.result,
								"class": "thumb-image",
								"height" : "192px",
								"width": "310px"
						}).appendTo(image_holder);

					}
					image_holder.show();
					reader.readAsDataURL($("#dirimagem_banner")[0].files[0]);
						
			} else {
				image_holder.empty();
				image_holder.html('<div style="padding:20px; text-align: center;"><b>IMAGEM ALTERADA</b><br/><br/> Para visualizar a imagem em tempo real utilize os navegadores IE 10+, Google Chrome 7+, Firefox 3.6+ ou Safari 6+</div>');
			}
		}else{
			image_holder.empty();
			$("<img />",{ "src": imgPath, "class": "thumb-image", "height": "192px", "width": "310px"}).appendTo(image_holder);
		}
	} else {
			if($('#inexibir_banner').is(':checked')){
				image_holder.empty();
				image_holder.html("<div style='padding-top:90px; text-align: center;'><b>IMAGEM N&Atilde;O CARREGADA</b></div>");
				alert("Selecione somente imagens!");
			}
	}
}

function exibeBanner(){
		
	if($('#inexibir_banner').is(':checked')){
		$('#divNmimagem_banner').show(); $('#divBannerObs').show();
	}else{
		$('#divNmimagem_banner').hide(); $('#divBannerObs').hide();
	}
}

function exibeAcao(){
		
	if($('#inexibe_botao_acao_mobile').is(':checked')){
		$('#divBtnAcaoConteudo').show();
	}else{
		$('#divBtnAcaoConteudo').hide();
	}
}

function acaoRadio(cdRaio,cdmenu_acao_mobile){
	
	idacao_botao_acao_mobile = cdRaio;
	
	if(cdRaio == 1){	
		$("#idacao_botao_acao_mobile_url").attr('checked', 'checked');
		$("#cdmenu_acao_mobile").val("0");
		$('#cdmenu_acao_mobile').prop('disabled', true);
		$('#dslink_acao_mobile').prop('disabled', false);
	}else{
		$("#idacao_botao_acao_mobile_tela").attr('checked', 'checked');
		$('#dslink_acao_mobile').val("");
		$('#dslink_acao_mobile').prop('disabled', true);
		$('#cdmenu_acao_mobile').prop('disabled', false);
		$('#cdmenu_acao_mobile').val(cdmenu_acao_mobile);
	}
}

function msgAcaoMobile(msgAcao){
	
	if($('#chk_dsmensagem_acao_mobile').is(':checked')){
  	$('#dsmensagem_acao_mobile').prop('disabled', false);
		$('#dsmensagem_acao_mobile').val(msgAcao);
	}else{
		$('#dsmensagem_acao_mobile').val(msgAcao);
		$('#dsmensagem_acao_mobile').prop('disabled', true);
	}
}
function tipoRepeticao(tpRepeticao){
		
	if(tpRepeticao == 1){	
	  $("#intipo_repeticao_sem").attr('checked', 'checked');
		$("#divMensal").hide();
		$("#divSemanal").show();
	}else{
		$("#intipo_repeticao_mes").attr('checked', 'checked');
		$("#divSemanal").hide();
		$("#divMensal").show();
	}
}

function marcaDiaSemana(nrDiasSemana){
	var arrDiasSemana = nrDiasSemana.split(",");
	
	for (var i = 0; i < arrDiasSemana.length; i++) {
		$("#nrdias_semana_" + arrDiasSemana[i]).attr('checked', true);
	}
}

function marcaSemana(nrSemanas){
	var arrNrSemana = nrSemanas.split(",");
	for (var i = 0; i < arrNrSemana.length; i++) {
		$("#nrsemanas_" + arrNrSemana[i]).attr('checked', true);
	}
}

function marcaMes(nrMeses){
	var arrNrMeses = nrMeses.split(",");
	for (var i = 0; i < arrNrMeses.length; i++) {
		$("#nrmeses_" + arrNrMeses[i]).attr('checked', true);
	}
}

function validaDados(){

	var flgerror = false;
	var dscritic = "";
	
	//VALIDA OS CAMPOS OBRIGATÓRIOS
	if(dstitulo_mensagem == ""){
		dscritic = "Título é obrigatório";
		flgerror = true;
	}else if(cdicone == 0 || cdicone < 0){
		dscritic = "Ícone é obrigatório";
		flgerror = true;
	}else if(dstexto_mensagem == ""){
		dscritic = "Mensagem é obrigatória";
		flgerror = true;
	}else if(inexibir_banner == 1 && nmimagem_banner == ""){
    dscritic = "Exibir Banner está ativo mas nenhuma imagem foi selecionada";
		flgerror = true;
	}else if(dshtml_mensagem == ""){
		dscritic = "Conteúdo é obrigatório";
		flgerror = true;
	}else if(inexibe_botao_acao_mobile == 1){
		if(dstexto_botao_acao_mobile == ""){
		  dscritic = "O texto do botão de ação do Cecred Mobile é obrigatório";
			flgerror = true;
		}else if(idacao_botao_acao_mobile == 1 && dslink_acao_mobile == ""){
			dscritic = "URL do botão de ação é obrigatório";
			flgerror = true;
		}else if(idacao_botao_acao_mobile == 2 && cdmenu_acao_mobile == ""){
			dscritic = "Tela do Cecred Mobile do botão de ação é obrigatória";	
			flgerror = true;
		}
	}	
    
	//VALIDA AS MENSAGENS AUTOMÁTICAS RECORRENTES (Tipo: Serviços)
  if(cdtipo_mensagem == 1){ // Serviços
  	if(intipo_repeticao != 1 && intipo_repeticao != 2){ // Se não for selecionado nenhum tipo de recorrência
			dscritic = "Obrigatório escolher um tipo de recorrência: Por mês ou por semana";
		}else if(intipo_repeticao == 1 && (nrdias_semana == "" || nrsemanas == "")){ // Se for semana
			dscritic = "Para ativar a recorrência por semana é necessário informar os dias e as semanas em que deve ocorrer os envios da mensagem";
		}else if(intipo_repeticao == 2 && (nrdias_mes == "" || nrmeses == "")){ // Se for mês
			dscritic = "Para ativar a recorrência por mês é necessário informar os dias e os meses em que deve ocorrer os envios da mensagem";
		}
	}else if(cdtipo_mensagem == 3){ // VALIDA AS MENSAGENS MANUAIS (Tipo: Avisos)
      if(dhenvio_mensagem == ""){
        dscritic = "Data do envio da mensagem é obrigatória";
      }else if(hrenvio_mensagem == ""){
        dscritic = "Hora do envio da mensagem é obrigatória";
      }else if(tpfiltro != 1 && tpfiltro != 2){
        dscritic = "É necessário escolher um tipo de filtro";
      }else if((dsfiltro_cooperativas == "" || dsfiltro_cooperativas == 0) && tpfiltro == 1){
        dscritic = "É necessário selecionar ao menos uma cooperativa";
      }else if((dsfiltro_tipos_conta == "" || dsfiltro_tipos_conta == 0) && tpfiltro == 1){
        dscritic = "É necessário selecionar ao menos um tipo de conta";
      }
  }
	
	if(flgerror){
		showError("error",dscritic,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
		return false;
	}
	
	return true;
}

function salvar(){
	
	if(cddopcao == "CM"){
		$("#frmMsgConsulta :input").removeAttr('disabled');
		$("#dtenvio_mensagem").datepicker('enable');
	}
	
	nrdias_semana = "";
	nrsemanas = "";
	nrdias_mes = "";
	nrmeses = "";
	inexibir_banner = 0;
		
	//TITULO
	cdtipo_mensagem = $("#cdtipo_mensagem").val();
	dstitulo_mensagem = $("#dstitulo_mensagem").val();
	cdicone					  = $("#cdicone").val();
	inmensagem_ativa = $("#inmensagem_ativa").val();
	inenviar_push = $("#inenviar_push").val();
	dstexto_mensagem  = $("#dstexto_mensagem").val();
	
	//BANNER DETALHAMENTO
	if($('#inexibir_banner').is(':checked')){ inexibir_banner = 1; }else{ inexibir_banner = 0; }
	nmimagem_banner   = $("#nmimagem_banner").val();
	
	//CONTEUDO
	dshtml_mensagem = CKEDITOR.instances['dshtml_mensagem'].getData(); 
	
	//BOTAO ACAO
	if($('#inexibe_botao_acao_mobile').is(':checked')){ inexibe_botao_acao_mobile = 1; }else{ inexibe_botao_acao_mobile  = 0; }
	//idacao_botao_acao_mobile
	dslink_acao_mobile = $("#dslink_acao_mobile").val();
	dstexto_botao_acao_mobile = $("#dstexto_botao_acao_mobile").val();
	cdmenu_acao_mobile = $("#cdmenu_acao_mobile").val();
	if($('#chk_dsmensagem_acao_mobile').is(':checked')){ dsmensagem_acao_mobile = $("#dsmensagem_acao_mobile").val(); }else{ dsmensagem_acao_mobile = ""; }
	
	// RECORRENCIA
  hrenvio_mensagem = $("#hrenvio_mensagem").val();
	if($("#intipo_repeticao_sem").is(':checked')){ //SEMANAL
		intipo_repeticao = 1;
		//DIAS DA SEMANA
		for (var i = 1; i <= 7; i++) {
			if($('#nrdias_semana_'+i).is(':checked')){	
				nrdias_semana = nrdias_semana + "," + i;
			}
		}
		
		nrdias_semana = nrdias_semana.substring(1);
		
		//SEMANAS
		for (var i = 1; i <= 5; i++) {
			if($('#nrsemanas_'+i).is(':checked')){	
				nrsemanas = nrsemanas + "," + i;
			}
		}
		
		if($('#nrsemanas_U').is(':checked')){	
			nrsemanas = nrsemanas + ",U";
		}
		
		nrsemanas = nrsemanas.substring(1);
	}else if($("#intipo_repeticao_mes").is(':checked')){ //MENSAL
		intipo_repeticao = 2;
		nrdias_mes = $("#nrdias_mes").val();
		
		//MESES
		for (var i = 1; i <= 12; i++) {
			if($('#nrmeses_'+i).is(':checked')){	
				nrmeses = nrmeses + "," + i;
			}
		}
	}	
	nrmeses = nrmeses.substring(1);

	if(cddopcao == "N"){
		
		tpfiltro = $("#tpfiltro").val();
		if(tpfiltro == 1){
			dsfiltro_cooperativas = $("#dsfiltro_cooperativas").val();
			
			dsfiltro_tipos_conta = "";
			
			if($("#dsfiltro_tipos_conta_fis").is(':checked')){
				dsfiltro_tipos_conta = "1";
			}
			
			if($("#dsfiltro_tipos_conta_jur").is(':checked')){
				if(dsfiltro_tipos_conta == ""){
					dsfiltro_tipos_conta = "2";
				}else{
					dsfiltro_tipos_conta = dsfiltro_tipos_conta + ",2";
				}
			}
			
			for (var i = 0; i <= 4; i++) {
				if($('#tpfiltro_mobile_'+i).is(':checked')){	
					tpfiltro_mobile = i;
				}
			}
		}else{
			nmarquivo_csv = $("#nmarquivo_csv").val();
		}
		
		dtenvio_mensagem = $("#dtenvio_mensagem").val();
		hrenvio_mensagem = $("#hrenvio_mensagem").val();
	}
	
	if(!validaDados()){
		return false;
	}
	
	showMsgAguardo("Aguarde, salvando informa&ccedil;&otilde;es...");
	$('#frmNovaMsg').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#sidlogin','#frmNovaMsg').val( $('#sidlogin','#frmMenu').val() );
	
	var NavVersion = CheckNavigator();
	
	if(cddopcao == "N"){
		
		action = 'upload_manual.php?keylink=' + milisegundos();
		
		// Configuro o formulário para posteriormente submete-lo
		$('#frmMsgManual').attr('method','post');
		$('#frmMsgManual').attr('action',action);
		$('#frmMsgManual').attr("target",'frameBlank');		
		$('#divListErr').html('');
		$('#frmMsgManual').submit();
		
	}else if(cddopcao == "AM"){
		action = 'upload_automatica.php?keylink=' + milisegundos();
		
		// Configuro o formulário para posteriormente submete-lo
		$('#frmMsgAutomatica').attr('method','post');
		$('#frmMsgAutomatica').attr('action',action);
		$('#frmMsgAutomatica').attr("target",'frameBlank');		
		$('#divListErr').html('');
		$('#frmMsgAutomatica').submit();
	}else if(cddopcao == "CM"){
		action = 'upload_manual.php?keylink=' + milisegundos();
		// Configuro o formulário para posteriormente submete-lo
		$('#frmMsgConsulta').attr('method','post');
		$('#frmMsgConsulta').attr('action',action);
		$('#frmMsgConsulta').attr("target",'frameBlank');		
		$('#divListErr').html('');
		$('#frmMsgConsulta').submit();
	}
}

function carregaEnviar(tpfiltro){
	
	$("#divFile").hide();
	$("#divCooperativas").hide();
	
	if(tpfiltro == "" || tpfiltro == undefined){
		tpfiltro = 1;
	}
	
	if(tpfiltro == 1){		
		$("#divCooperativas").show();
	}else if(tpfiltro == 2){	
		$("#divFile").show();
	}
	
}

function carregaConsulta(cdMensagem){
	
	cddopcao = "CM";
	
	// Executa script de exclusao de mensagens através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/envnot/carrega_layout.php", 
		data: {
			cddopcao: cddopcao,
			cdmensagem: cdMensagem,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
		},
		success: function(response) {
			try {
				$("#divConteudoConsulta").show();
				$("#divConteudoConsulta").empty();
				$("#divConteudoConsulta").append(response);				
				layoutPadrao();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
			}
		}				
	});
	
	return false;	
}

function editarMsg(){
	$("#frmMsgConsulta :input").removeAttr('disabled');
	$("#dtenvio_mensagem").datepicker('enable');
	$("#btnEditarMsg").hide();
	$("#btnCancelarEnvio").hide();
	$("#btnSalvar").show();
}

function cancelarEnvioMsg(cdmensagem){
		
	showMsgAguardo("Aguarde, cancelando envio...");
	
	// Executa script de exclusao de mensagens através de ajax
	$.ajax({		
		type: "POST",
		url: "cancelar_envio.php", 
		data: {
			cdmensagem: cdmensagem,
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
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
			}
		}				
	});
	
	return false;
}

function reenviarMsg(){
	$("#frmMsgConsulta :input").removeAttr('disabled');
	CKEDITOR.instances['dshtml_mensagem'].setReadOnly(false);
	$("#hdnCdmensagem").val(0);
	$("#dtenvio_mensagem").datepicker('enable');
	$("#dtenvio_mensagem").val("");
	$("#hrenvio_mensagem").val("");
	$("#btnReenviarMsg").hide();
	$("#btnSalvar").show();
}