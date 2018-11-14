/*****************************************************************************************
 Fonte: conjob.js                                                   
 Autor: Mateus Zimmermann - Mouts                                                
 Data : Junho/2018             					   Última Alteração:         
                                                                  
 Objetivo  : Biblioteca de funções da tela CONJOB
                                                                  
 Alterações:  
						  
******************************************************************************************/


$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#frmIncluir').css('display','none');
	$('#frmParametrosGerais').css('display','none');
	$('#frmConsulta').css('display','none');
	$('#frmFiltroConsultaLogJobs').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#divBotoesIncluir').css('display','none');
	$('#divBotoesParametros').css('display','none');
	$('#divBotoesConsulta').css('display','none');
	$('#divBotoesFiltroConsultaLogJobs').css('display','none');
	$('#cddopcao','#frmCabConjob').habilitaCampo().focus().val('P');

	// chamada para pegar os parametros de email e arquivo de log
	consultarParametros();
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabConjob').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabConjob').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabConjob').css('display','block');
		
	highlightObjFocus( $('#frmCabConjob') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabConjob').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabConjob').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabConjob').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabConjob').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabConjob').desabilitaCampo();		
		$(this).unbind('click');
		
		if($('#cddopcao','#frmCabConjob').val() == 'I'){
			formataIncluir();
		} else if($('#cddopcao','#frmCabConjob').val() == 'P'){
			buscaParametrosGerais();
		} else if($('#cddopcao','#frmCabConjob').val() == 'L'){
			mostrarFiltroConsultaLogJobs();
		} else {
			formataFiltro();
		}
								
	});
	
	$('#cddopcao','#frmCabConjob').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rNmjob = $('label[for="nmjob"]','#frmFiltro');
	
	rNmjob.addClass("rotulo").css('width','100px');
	  
	//Campos do frmFiltro
	var cNmjob = $('#nmjob','#frmFiltro');
 
    cNmjob.css({'width':'400px'}).addClass('alphanum').habilitaCampo();

    //Define ação para o campo
	$('#nmjob','#frmFiltro').unbind('keypress').bind('keypress', function (e) {
	    // se pressionar enter, consultar o job preenchido
	    if(e.keyCode == 13){
				
			$('#btProsseguir','#divBotoesFiltro').click();
			
			return false;						
			
		}
	});
	
	$('#frmIncluir').css('display','none');
	$('#frmConsulta').css('display','none');
	$('#frmConsultaLogJobs').css('display','none');
	$('#divBotoesIncluir').css('display','none');
	$('#divBotoesConsulta').css('display','none');
	$('#divBotoesConsultaLogJobs').css('display','none');
	$('#frmFiltro').css('display','block');
	$('#divBotoesFiltro').css('display','block');
	
	controlaPesquisas();
	
	layoutPadrao();
	
	return false;
	
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
    var campoAnterior = '';
	
    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmFiltro').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmFiltro').each(function () {
	
		if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
		
        $(this).unbind("click").bind("click", (function () {
			
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// Nome job
                if (campoAnterior == 'nmjob') {
					
					var filtrosPesq = "Nome Job;nmjob;200px;S;|Tipo Consulta;tpconsul;200px;N;2;N";
                    var colunas = 'Nome Job;nmjob;75%;left';
                    mostraPesquisa("TELA_CONJOB", "CONJOB_CONSULTAR_JOB", "Jobs", "30", filtrosPesq, colunas, '','', 'frmFiltro');
                    
					return false;
                }

            }
            
        }));
    });

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmFiltroConsultaLogJobs').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmFiltroConsultaLogJobs').each(function () {
	
		if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
		
        $(this).unbind("click").bind("click", (function () {
			
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// Nome job
                if (campoAnterior == 'nmjob') {
					
					var filtrosPesq = "Nome Job;nmjob;200px;S;|Tipo Consulta;tpconsul;200px;N;2;N";
                    var colunas = 'Nome Job;nmjob;75%;left';
                    mostraPesquisa("TELA_CONJOB", "CONJOB_CONSULTAR_JOB", "Jobs", "30", filtrosPesq, colunas, '','', 'frmFiltroConsultaLogJobs');
                    
					return false;
                }

            }
            
        }));
    });	
}

function formataConsulta(){

	highlightObjFocus( $('#frmConsulta') );
	$('#fsetConsulta').css({'border-bottom':'1px solid #777'});	
	
	//Label do frmDetalhes
	var rNmjob                = $('label[for="nmjob"]','#frmConsulta');
	var rIdativo              = $('label[for="idativo"]','#frmConsulta');
	var rDsdetalhe            = $('label[for="dsdetalhe"]','#frmConsulta');
	var rDsprefixo_jobs       = $('label[for="dsprefixo_jobs"]','#frmConsulta');
	var rIdperiodici_execucao = $('label[for="idperiodici_execucao"]','#frmConsulta');
	var rQtintervalo          = $('label[for="qtintervalo"]','#frmConsulta');	
	var rDsdias_habilitados   = $('label[for="dsdias_habilitados"]','#frmConsulta');	
	var rDsdias_habilitadosD  = $('label[for="dsdias_habilitadosD"]','#frmConsulta');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmConsulta');	
	var rDsdias_habilitadosT  = $('label[for="dsdias_habilitadosT"]','#frmConsulta');	
	var rDsdias_habilitadosQ  = $('label[for="dsdias_habilitadosQ"]','#frmConsulta');	
	var rDsdias_habilitadosQ  = $('label[for="dsdias_habilitadosQ"]','#frmConsulta');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmConsulta');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmConsulta');	
	var rLblCbDiasHabilitados = $('label[for="lblCbDiasHabilitados"]','#frmConsulta');	
	var rDtprox_execucao      = $('label[for="dtprox_execucao"]','#frmConsulta');	
	var rHrprox_execucao      = $('label[for="hrprox_execucao"]','#frmConsulta');	
	var rHrjanela_exec        = $('label[for="hrjanela_exec"]','#frmConsulta');	
	var rHrjanela_exec_ini    = $('label[for="hrjanela_exec_ini"]','#frmConsulta');	
	var rHrjanela_exec_fim    = $('label[for="hrjanela_exec_fim"]','#frmConsulta');	
	var rFlaguarda_processo   = $('label[for="flaguarda_processo"]','#frmConsulta');	
	var rFlexecuta_feriado    = $('label[for="flexecuta_feriado"]','#frmConsulta');	
	var rlbltpaviso           = $('label[for="lbltpaviso"]','#frmConsulta');	
	var rFlsaida_email        = $('label[for="flsaida_email"]','#frmConsulta');	
	var rDsdestino_email      = $('label[for="dsdestino_email"]','#frmConsulta');	
	var rlblLog               = $('label[for="lblLog"]','#frmConsulta');	
	var rFlsaida_log          = $('label[for="flsaida_log"]','#frmConsulta');	
	var rDsnome_arq_log       = $('label[for="dsnome_arq_log"]','#frmConsulta');	
	var rLbl_ponto_log        = $('label[for="lbl_ponto_log"]','#frmConsulta');	
	var rDscodigo_plsql       = $('label[for="dscodigo_plsql"]','#frmConsulta');	
	
	rNmjob.addClass("rotulo").css('width','200px');
	rIdativo.addClass("rotulo-linha").css('width','80px');
	rDsdetalhe.addClass("rotulo").css('width','200px');
	rDsprefixo_jobs.addClass("rotulo").css('width','200px');
	rIdperiodici_execucao.addClass("rotulo").css('width','200px');
	rQtintervalo.addClass("rotulo-linha").css('width','125px');
	rDsdias_habilitados.addClass("rotulo").css('width','200px');
	rDsdias_habilitadosD.css({'width':'25px','text-align':'center','border':'1px solid','margin-left':'3px'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosT.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosQ.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosQ.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rLblCbDiasHabilitados.addClass("rotulo").css('width','200px');
	rDtprox_execucao.addClass("rotulo").css('width','200px');
	rHrprox_execucao.addClass("rotulo").css('width','200px');
	rHrjanela_exec.addClass("rotulo").css('width','200px');
	rHrjanela_exec_ini.addClass("rotulo-linha").css('width','40px');
	rHrjanela_exec_fim.addClass("rotulo-linha").css('width','35px');
	rFlaguarda_processo.addClass("rotulo").css('width','200px');
	rFlexecuta_feriado.addClass("rotulo").css('width','200px');
	rlbltpaviso.addClass("rotulo").css('width','200px');
	rFlsaida_email.addClass("rotulo-linha");
	rDsdestino_email.addClass("rotulo-linha").css('width','80px');
	rlblLog.addClass("rotulo").css('width','200px');
	rFlsaida_log.addClass("rotulo-linha");
	rDsnome_arq_log.addClass("rotulo-linha").css('width','87px');
	rLbl_ponto_log.addClass("rotulo-linha");
	rDscodigo_plsql.addClass("rotulo").css('width','200px');
  
	//Campos do frmConsulta
	var cNmjob                = $('#nmjob','#frmConsulta');	
	var cIdativo              = $('#idativo','#frmConsulta');
	var cDsdetalhe            = $('#dsdetalhe','#frmConsulta');
	var cDsprefixo_jobs       = $('#dsprefixo_jobs','#frmConsulta');
	var cIdperiodici_execucao = $('#idperiodici_execucao','#frmConsulta');
	var cTpintervalo          = $('#tpintervalo','#frmConsulta');
	var cQtintervalo          = $('#qtintervalo','#frmConsulta');	
	var cCb_domingo           = $('#cb_domingo','#frmConsulta');
	var cCb_segunda           = $('#cb_segunda','#frmConsulta');
	var cCb_terca             = $('#cb_terca','#frmConsulta');
	var cCb_quarta            = $('#cb_quarta','#frmConsulta');
	var cCb_quinta            = $('#cb_quinta','#frmConsulta');
	var cCb_sexta             = $('#cb_sexta','#frmConsulta');
	var cCb_sabado            = $('#cb_sabado','#frmConsulta');
	var cDtprox_execucao      = $('#dtprox_execucao','#frmConsulta');
	var cHrprox_execucao      = $('#hrprox_execucao','#frmConsulta');
	var cHrjanela_exec_ini    = $('#hrjanela_exec_ini','#frmConsulta');
	var cHrjanela_exec_fim    = $('#hrjanela_exec_fim','#frmConsulta');
	var cFlaguarda_processo   = $('#flaguarda_processo','#frmConsulta');
	var cFlexecuta_feriado    = $('#flexecuta_feriado','#frmConsulta');
	var cFlsaida_email        = $('#flsaida_email','#frmConsulta');
	var cDsdestino_email      = $('#dsdestino_email','#frmConsulta');	
	var cFlsaida_log          = $('#flsaida_log','#frmConsulta');
	var cDsnome_arq_log       = $('#dsnome_arq_log','#frmConsulta');
	var cDscodigo_plsql       = $('#dscodigo_plsql','#frmConsulta');
  
    cNmjob.css({'width':'200px'});
    cIdativo.css({'width':'80px'});
    cDsdetalhe.addClass('alphanum textarea').css('width', '366px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '40px').css('margin-left', '3').attr('maxlength', '160');
    cDsprefixo_jobs.css({'width':'200px'}).attr('maxlength','18');
    cIdperiodici_execucao.css({'width':'100px'});
    cQtintervalo.css({'width':'30px'});
    cTpintervalo.css({'width':'100px'});
    cCb_domingo.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 7px'});
    cCb_segunda.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_terca.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_quarta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_quinta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_sexta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_sabado.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cDtprox_execucao.css({'width':'75px'}).addClass('data');
    cHrprox_execucao.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cHrjanela_exec_ini.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cHrjanela_exec_fim.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cFlaguarda_processo.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cFlexecuta_feriado.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cFlsaida_email.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cDsdestino_email.css({'width':'200px'});
    cFlsaida_log.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cDsnome_arq_log.css({'width':'200px'});
    cDscodigo_plsql.addClass('textarea').css('width', '366px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '80px').css('margin-left', '3').attr('maxlength', '4000');
	
	// Caso seja opção alterar, então irá habilitar os campos, definir a navegação dos campos usando tab e enter 
	// e setar focus no primeiro campo da tela
	if($('#cddopcao','#frmCabConjob').val() == 'A'){

		$('input, select, textarea', '#frmConsulta').habilitaCampo();

		$('input, select', '#frmConsulta').each(function () {
		
			//Define ação para o campo
			$(this).unbind('keypress').bind('keypress', function (e) {

				$('input,select').removeClass('campoErro');
				
				if (divError.css('display') == 'block') { return false; }

				// Se é a tecla ENTER, TAB
				if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
					
					$(this).nextAll('.campo:first').focus();

					return false;
				}
				
			});
		
		});

		if(cIdperiodici_execucao.val() == 'R') {
			cQtintervalo.habilitaCampo();
			cTpintervalo.habilitaCampo();
			cHrjanela_exec_ini.habilitaCampo();
			cHrjanela_exec_fim.habilitaCampo();
		} else {
			cQtintervalo.desabilitaCampo().val('');
			cTpintervalo.desabilitaCampo().val('');
			cHrjanela_exec_ini.desabilitaCampo().val('');
			cHrjanela_exec_fim.desabilitaCampo().val('');
		}

		cIdperiodici_execucao.unbind('change').bind('change', function(){ 
			if ( $(this).val() == 'R' ) {
				cQtintervalo.habilitaCampo();
				cTpintervalo.habilitaCampo();
				cHrjanela_exec_ini.habilitaCampo();
				cHrjanela_exec_fim.habilitaCampo();
			} else {
				cQtintervalo.desabilitaCampo().val('');
				cTpintervalo.desabilitaCampo().val('');
				cHrjanela_exec_ini.desabilitaCampo().val('');
				cHrjanela_exec_fim.desabilitaCampo().val('');
			}
			return true;
		});	

		cIdperiodici_execucao.unbind('keyup').bind('keyup', function(){ 
			if ( $(this).val() == 'R' ) {
					cQtintervalo.habilitaCampo();
					cTpintervalo.habilitaCampo();
					cHrjanela_exec_ini.habilitaCampo();
					cHrjanela_exec_fim.habilitaCampo();
				} else {
					cQtintervalo.desabilitaCampo().val('');
					cTpintervalo.desabilitaCampo().val('');
					cHrjanela_exec_ini.desabilitaCampo().val('');
					cHrjanela_exec_fim.desabilitaCampo().val('');
				}
			return true;
		});	

		if($('#FL_MAIL_JOB_BATCH_MASTER','#divTela').val() == 'S') {
			cFlsaida_email.habilitaCampo();		
		} else {
			cFlsaida_email.desabilitaCampo();
			cFlsaida_email.prop('checked', false);
		}

		if(cFlsaida_email.is(':checked')) {
			cDsdestino_email.habilitaCampo();		
		} else {
			cDsdestino_email.desabilitaCampo();
		}	

		cFlsaida_email.unbind('change').bind('change', function(){ 
			if ( $(this).is(':checked') ) {
				cDsdestino_email.habilitaCampo();
			} else {
				cDsdestino_email.desabilitaCampo();
			}
			return true;
		});	

		if($('#FL_ARQV_JOB_BATCH_MASTER','#divTela').val() == 'S') {
			cFlsaida_log.habilitaCampo();		
		} else {
			cFlsaida_log.desabilitaCampo();
			cFlsaida_log.prop('checked', false);
		}

		if(cFlsaida_log.is(':checked')) {
			cDsnome_arq_log.habilitaCampo();		
		} else {
			cDsnome_arq_log.desabilitaCampo();
		}

		cFlsaida_log.unbind('change').bind('change', function(){ 
			if ( $(this).is(':checked') ) {
				cDsnome_arq_log.habilitaCampo();
			} else {
				cDsnome_arq_log.desabilitaCampo();
			}
			return true;
		});	
		
		// Nome da job nao pode ser alterado, pois é a "chave" da tabela
		$('#nmjob','#frmConsulta').desabilitaCampo();

	} else {
		$('input, select, textarea', '#frmConsulta').desabilitaCampo();
	}	
	
	$('#divBotoesFiltro').css('display','none');
	$('#frmConsulta').css('display','block');
	$('#divBotoesConsulta').css('display','block');
	$('input','#frmFiltro').desabilitaCampo();
	layoutPadrao();
	
	return false;
	
}

function consultarJobs(){	

	var cddopcao = $('#cddopcao','#frmCabConjob').val();
	var nmjob    = $('#nmjob','#frmFiltro').val();
	var tpconsul = 1;
		
	showMsgAguardo( "Aguarde, consultando jobs..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/consultar_jobs.php", 
        data: {
			cddopcao: cddopcao,
			nmjob:    nmjob,
			tpconsul: tpconsul,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConsulta').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function incluirJob(){
	
	var cddopcao             = $('#cddopcao','#frmCabConjob').val();
	var nmjob                = $('#nmjob','#frmIncluir').val();
	var idativo              = $('#idativo','#frmIncluir').val();
	var dsdetalhe            = $('#dsdetalhe','#frmIncluir').val();
	var dsprefixo_jobs       = $('#dsprefixo_jobs','#frmIncluir').val();
	var idperiodici_execucao = $('#idperiodici_execucao','#frmIncluir').val();
	var tpintervalo          = $('#tpintervalo','#frmIncluir').val();
	var qtintervalo          = $('#qtintervalo','#frmIncluir').val();
	var dsdias_habilitados   = $('#cb_domingo','#frmIncluir').is(':checked') ? '1' : '0';
		dsdias_habilitados  += $('#cb_segunda','#frmIncluir').is(':checked') ? '1' : '0';
		dsdias_habilitados  += $('#cb_terca','#frmIncluir').is(':checked')   ? '1' : '0';
		dsdias_habilitados  += $('#cb_quarta','#frmIncluir').is(':checked')  ? '1' : '0';
		dsdias_habilitados  += $('#cb_quinta','#frmIncluir').is(':checked')  ? '1' : '0';
		dsdias_habilitados  += $('#cb_sexta','#frmIncluir').is(':checked')   ? '1' : '0';
		dsdias_habilitados  += $('#cb_sabado','#frmIncluir').is(':checked')  ? '1' : '0';
	var dtprox_execucao      = $('#dtprox_execucao','#frmIncluir').val();
	var hrprox_execucao      = $('#hrprox_execucao','#frmIncluir').val();
	var hrjanela_exec_ini    = $('#hrjanela_exec_ini','#frmIncluir').val();
	var hrjanela_exec_fim    = $('#hrjanela_exec_fim','#frmIncluir').val();
	var flaguarda_processo   = $('#flaguarda_processo','#frmIncluir').is(':checked') ? 'S' : 'N';
	var flexecuta_feriado    = $('#flexecuta_feriado','#frmIncluir').is(':checked') ? 1 : 0;
	var flsaida_email        = $('#flsaida_email','#frmIncluir').is(':checked') ? 'S' : 'N';
	var dsdestino_email      = $('#dsdestino_email','#frmIncluir').val();
	var flsaida_log          = $('#flsaida_log','#frmIncluir').is(':checked') ? 'S' : 'N';
	var dsnome_arq_log       = $('#dsnome_arq_log','#frmIncluir').val();
	var dscodigo_plsql       = $('#dscodigo_plsql','#frmIncluir').val();
	
	showMsgAguardo( "Aguarde, incluindo job..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/incluir_job.php", 
        data: {
			cddopcao:             cddopcao,
			nmjob:                nmjob,
			idativo:              idativo,
			dsdetalhe:            dsdetalhe,  
			dsprefixo_jobs:       dsprefixo_jobs,  
			idperiodici_execucao: idperiodici_execucao,  
			tpintervalo:          tpintervalo,  
			qtintervalo:          qtintervalo,  
			dsdias_habilitados:   dsdias_habilitados,  
			dtprox_execucao:      dtprox_execucao,  
			hrprox_execucao:      hrprox_execucao,
			hrjanela_exec_ini:    hrjanela_exec_ini,
			hrjanela_exec_fim:    hrjanela_exec_fim,  
			flaguarda_processo:   flaguarda_processo,
			flexecuta_feriado:    flexecuta_feriado,  
			flsaida_email:        flsaida_email,  
			dsdestino_email:      dsdestino_email,
			flsaida_log:          flsaida_log,
			dsnome_arq_log:       dsnome_arq_log,
			dscodigo_plsql:       dscodigo_plsql,
            redirect:             "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
			}
		}
    });
    return false;
	
	
}

function excluirJob(){
	
	var cddopcao = $('#cddopcao','#frmCabConjob').val();
	var nmjob = $('#nmjob','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, excluíndo job..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/excluir_job.php", 
        data: {
			cddopcao: cddopcao,
			nmjob: nmjob,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nmjob','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nmjob','#frmFiltro').focus();");
			}
		}
    });

    return false;	

}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabConjob').val();
	
	switch(cddopcao){
		
		case 'C':
		
			consultarJobs();
							
		break;
		
		case 'A':
		
			consultarJobs();
		
		break;
		
		
		case 'E':
			
			showConfirmacao('Confirmar exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirJob();','','sim.gif','nao.gif');
		
		break;
		
		case 'I':
		
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirJob();','','sim.gif','nao.gif');
		
		break;

		case 'L':
		
			consultarLogJobs(1,30);
		
		break;
		
		
	};
	
	return false;
	
}

function controlaVoltar(op){
	
	
	switch(op){
		
		case '1':
		
			estadoInicial();
			
		break;
		
		case '2':

			formataFiltro();
		
		break;

		case '3':

			formataFiltroConsultaLogJobs();
		
		break;
		
		
	};
	
	return false;
	
}

function formataIncluir(){

	highlightObjFocus( $('#frmIncluir') );
	$('#fsetIncluir').css({'border-bottom':'1px solid #777'});	
	
	$('input, select, textarea','#frmIncluir').val('');
	
	//Label do frmDetalhes
	var rNmjob                = $('label[for="nmjob"]','#frmIncluir');
	var rIdativo              = $('label[for="idativo"]','#frmIncluir');
	var rDsdetalhe            = $('label[for="dsdetalhe"]','#frmIncluir');
	var rDsprefixo_jobs       = $('label[for="dsprefixo_jobs"]','#frmIncluir');
	var rIdperiodici_execucao = $('label[for="idperiodici_execucao"]','#frmIncluir');
	var rQtintervalo          = $('label[for="qtintervalo"]','#frmIncluir');	
	var rDsdias_habilitados   = $('label[for="dsdias_habilitados"]','#frmIncluir');	
	var rDsdias_habilitadosD  = $('label[for="dsdias_habilitadosD"]','#frmIncluir');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmIncluir');	
	var rDsdias_habilitadosT  = $('label[for="dsdias_habilitadosT"]','#frmIncluir');	
	var rDsdias_habilitadosQ  = $('label[for="dsdias_habilitadosQ"]','#frmIncluir');	
	var rDsdias_habilitadosQ  = $('label[for="dsdias_habilitadosQ"]','#frmIncluir');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmIncluir');	
	var rDsdias_habilitadosS  = $('label[for="dsdias_habilitadosS"]','#frmIncluir');	
	var rLblCbDiasHabilitados = $('label[for="lblCbDiasHabilitados"]','#frmIncluir');	
	var rDtprox_execucao      = $('label[for="dtprox_execucao"]','#frmIncluir');	
	var rHrprox_execucao      = $('label[for="hrprox_execucao"]','#frmIncluir');	
	var rHrjanela_exec        = $('label[for="hrjanela_exec"]','#frmIncluir');	
	var rHrjanela_exec_ini    = $('label[for="hrjanela_exec_ini"]','#frmIncluir');	
	var rHrjanela_exec_fim    = $('label[for="hrjanela_exec_fim"]','#frmIncluir');	
	var rFlaguarda_processo   = $('label[for="flaguarda_processo"]','#frmIncluir');
	var rFlexecuta_feriado    = $('label[for="flexecuta_feriado"]','#frmIncluir');	
	var rlbltpaviso           = $('label[for="lbltpaviso"]','#frmIncluir');	
	var rFlsaida_email        = $('label[for="flsaida_email"]','#frmIncluir');	
	var rDsdestino_email      = $('label[for="dsdestino_email"]','#frmIncluir');	
	var rlblLog               = $('label[for="lblLog"]','#frmIncluir');	
	var rFlsaida_log          = $('label[for="flsaida_log"]','#frmIncluir');	
	var rDsnome_arq_log       = $('label[for="dsnome_arq_log"]','#frmIncluir');	
	var rLbl_ponto_log        = $('label[for="lbl_ponto_log"]','#frmIncluir');	
	var rDscodigo_plsql       = $('label[for="dscodigo_plsql"]','#frmIncluir');	
	
	rNmjob.addClass("rotulo").css('width','200px');
	rIdativo.addClass("rotulo-linha").css('width','80px');
	rDsdetalhe.addClass("rotulo").css('width','200px');
	rDsprefixo_jobs.addClass("rotulo").css('width','200px');
	rIdperiodici_execucao.addClass("rotulo").css('width','200px');
	rQtintervalo.addClass("rotulo-linha").css('width','125px');
	rDsdias_habilitados.addClass("rotulo").css('width','200px');
	rDsdias_habilitadosD.css({'width':'25px','text-align':'center','border':'1px solid','margin-left':'3px'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosT.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosQ.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosQ.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rDsdias_habilitadosS.css({'width':'25px','text-align':'center','border':'1px solid'});
	rLblCbDiasHabilitados.addClass("rotulo").css('width','200px');
	rDtprox_execucao.addClass("rotulo").css('width','200px');
	rHrprox_execucao.addClass("rotulo").css('width','200px');
	rHrjanela_exec.addClass("rotulo").css('width','200px');
	rHrjanela_exec_ini.addClass("rotulo-linha").css('width','40px');
	rHrjanela_exec_fim.addClass("rotulo-linha").css('width','30px');
	rFlaguarda_processo.addClass("rotulo").css('width','200px');
	rFlexecuta_feriado.addClass("rotulo").css('width','200px');
	rlbltpaviso.addClass("rotulo").css('width','200px');
	rFlsaida_email.addClass("rotulo-linha");
	rDsdestino_email.addClass("rotulo-linha").css('width','80px');
	rlblLog.addClass("rotulo").css('width','200px');
	rFlsaida_log.addClass("rotulo-linha");
	rDsnome_arq_log.addClass("rotulo-linha").css('width','87px');
	rLbl_ponto_log.addClass("rotulo-linha");
	rDscodigo_plsql.addClass("rotulo").css('width','200px');
  
	//Campos do frmIncluir
	var cNmjob                = $('#nmjob','#frmIncluir');	
	var cIdativo              = $('#idativo','#frmIncluir');
	var cDsdetalhe            = $('#dsdetalhe','#frmIncluir');
	var cDsprefixo_jobs       = $('#dsprefixo_jobs','#frmIncluir');
	var cIdperiodici_execucao = $('#idperiodici_execucao','#frmIncluir');
	var cTpintervalo          = $('#tpintervalo','#frmIncluir');
	var cQtintervalo          = $('#qtintervalo','#frmIncluir');	
	var cCb_domingo           = $('#cb_domingo','#frmIncluir');
	var cCb_segunda           = $('#cb_segunda','#frmIncluir');
	var cCb_terca             = $('#cb_terca','#frmIncluir');
	var cCb_quarta            = $('#cb_quarta','#frmIncluir');
	var cCb_quinta            = $('#cb_quinta','#frmIncluir');
	var cCb_sexta             = $('#cb_sexta','#frmIncluir');
	var cCb_sabado            = $('#cb_sabado','#frmIncluir');
	var cDtprox_execucao      = $('#dtprox_execucao','#frmIncluir');
	var cHrprox_execucao      = $('#hrprox_execucao','#frmIncluir');
	var cHrjanela_exec_ini    = $('#hrjanela_exec_ini','#frmIncluir');
	var cHrjanela_exec_fim    = $('#hrjanela_exec_fim','#frmIncluir');
	var cFlaguarda_processo   = $('#flaguarda_processo','#frmIncluir');
	var cFlexecuta_feriado    = $('#flexecuta_feriado','#frmIncluir');
	var cFlsaida_email        = $('#flsaida_email','#frmIncluir');
	var cDsdestino_email      = $('#dsdestino_email','#frmIncluir');	
	var cFlsaida_log          = $('#flsaida_log','#frmIncluir');
	var cDsnome_arq_log       = $('#dsnome_arq_log','#frmIncluir');
	var cDscodigo_plsql       = $('#dscodigo_plsql','#frmIncluir');
  
    cNmjob.css({'width':'200px'});
    cIdativo.css({'width':'80px'});
    cDsdetalhe.addClass('alphanum textarea').css('width', '366px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '40px').css('margin-left', '3').attr('maxlength', '160');
    cDsprefixo_jobs.css({'width':'200px'}).attr('maxlength','18');
    cIdperiodici_execucao.css({'width':'100px'});
    cQtintervalo.css({'width':'30px'});
    cTpintervalo.css({'width':'100px'});
    cCb_domingo.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 7px'});
    cCb_segunda.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_terca.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_quarta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_quinta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_sexta.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cCb_sabado.css({'width':'20px', 'height':'23px','margin':'3px 3px 3px 4px'});
    cDtprox_execucao.css({'width':'75px'}).addClass('data');
    cHrprox_execucao.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cHrjanela_exec_ini.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cHrjanela_exec_fim.css({'width':'45px'}).addClass('inteiro').setMask("STRING", "ZZ:ZZ", ":", "");
    cFlaguarda_processo.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cFlexecuta_feriado.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cFlsaida_email.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cDsdestino_email.css({'width':'200px'});
    cFlsaida_log.css({'width':'20px', 'height':'20px', 'margin':'3px'});
    cDsnome_arq_log.css({'width':'200px'});
    cDscodigo_plsql.addClass('textarea').css('width', '366px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '80px').css('margin-left', '3').attr('maxlength', '4000');
	
	$('input, select, textarea', '#frmIncluir').habilitaCampo();
		
	// Percorrendo todos os links
    $('input, select', '#frmIncluir').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				$(this).nextAll('.campo:first').focus();

				return false;
			}			
		});		
	});         

	cIdperiodici_execucao.unbind('change').bind('change', function(){ 
		if ( $(this).val() == 'R' ) {
				cQtintervalo.habilitaCampo();
				cTpintervalo.habilitaCampo();
				cHrjanela_exec_ini.habilitaCampo();
				cHrjanela_exec_fim.habilitaCampo();
			} else {
				cQtintervalo.desabilitaCampo().val('');
				cTpintervalo.desabilitaCampo().val('');
				cHrjanela_exec_ini.desabilitaCampo().val('');
				cHrjanela_exec_fim.desabilitaCampo().val('');
			}
		return true;
	});

	cIdperiodici_execucao.unbind('keyup').bind('keyup', function(){ 
		if ( $(this).val() == 'R' ) {
				cQtintervalo.habilitaCampo();
				cTpintervalo.habilitaCampo();
				cHrjanela_exec_ini.habilitaCampo();
				cHrjanela_exec_fim.habilitaCampo();
			} else {
				cQtintervalo.desabilitaCampo().val('');
				cTpintervalo.desabilitaCampo().val('');
				cHrjanela_exec_ini.desabilitaCampo().val('');
				cHrjanela_exec_fim.desabilitaCampo().val('');
			}
		return true;
	});

	if($('#FL_MAIL_JOB_BATCH_MASTER','#divTela').val() == 'S') {
		cFlsaida_email.habilitaCampo();		
	} else {
		cFlsaida_email.desabilitaCampo();
		cFlsaida_email.prop('checked', false);
	}

	if(cFlsaida_email.is(':checked')) {
		cDsdestino_email.habilitaCampo();		
	} else {
		cDsdestino_email.desabilitaCampo();
	}	

	cFlsaida_email.unbind('change').bind('change', function(){ 
		if ( $(this).is(':checked') ) {
			cDsdestino_email.habilitaCampo();
		} else {
			cDsdestino_email.desabilitaCampo();
		}
		return true;
	});	

	if($('#FL_ARQV_JOB_BATCH_MASTER','#divTela').val() == 'S') {
		cFlsaida_log.habilitaCampo();		
	} else {
		cFlsaida_log.desabilitaCampo();
		cFlsaida_log.prop('checked', false);
	}

	if(cFlsaida_log.is(':checked')) {
		cDsnome_arq_log.habilitaCampo();		
	} else {
		cDsnome_arq_log.desabilitaCampo();
	}

	cFlsaida_log.unbind('change').bind('change', function(){ 
		if ( $(this).is(':checked') ) {
			cDsnome_arq_log.habilitaCampo();
		} else {
			cDsnome_arq_log.desabilitaCampo();
		}
		return true;
	});	
	
	$('#frmIncluir').css('display','block');
	$('#divBotoesIncluir').css('display','block');
	layoutPadrao();
	
	$('#nmjob','#frmIncluir').focus();
	
	return false;
	
}

function formataParametrosGerais(){

	highlightObjFocus( $('#frmParametrosGerais') );
	$('#fsetParametrosGerais').css({'border-bottom':'1px solid #777'});	
	
	//Label do frmIncluir
	var rNmjobmaster   = $('label[for="nmjobmaster"]'  ,'#frmParametrosGerais');
	var rNumminjob     = $('label[for="numminjob"]'    ,'#frmParametrosGerais');
	var rLblminutos    = $('label[for="lblminutos"]'   ,'#frmParametrosGerais');
	var rQtjobporhor0  = $('label[for="qtjobporhor0"]' ,'#frmParametrosGerais');
	var rQtjobporhor1  = $('label[for="qtjobporhor1"]' ,'#frmParametrosGerais');
	var rQtjobporhor2  = $('label[for="qtjobporhor2"]' ,'#frmParametrosGerais');
	var rQtjobporhor3  = $('label[for="qtjobporhor3"]' ,'#frmParametrosGerais');
	var rQtjobporhor4  = $('label[for="qtjobporhor4"]' ,'#frmParametrosGerais');
	var rQtjobporhor5  = $('label[for="qtjobporhor5"]' ,'#frmParametrosGerais');
	var rQtjobporhor6  = $('label[for="qtjobporhor6"]' ,'#frmParametrosGerais');
	var rQtjobporhor7  = $('label[for="qtjobporhor7"]' ,'#frmParametrosGerais');
	var rQtjobporhor8  = $('label[for="qtjobporhor8"]' ,'#frmParametrosGerais');
	var rQtjobporhor9  = $('label[for="qtjobporhor9"]' ,'#frmParametrosGerais');
	var rQtjobporhor10 = $('label[for="qtjobporhor10"]','#frmParametrosGerais');
	var rQtjobporhor11 = $('label[for="qtjobporhor11"]','#frmParametrosGerais');
	var rQtjobporhor12 = $('label[for="qtjobporhor12"]','#frmParametrosGerais');
	var rQtjobporhor13 = $('label[for="qtjobporhor13"]','#frmParametrosGerais');
	var rQtjobporhor14 = $('label[for="qtjobporhor14"]','#frmParametrosGerais');
	var rQtjobporhor15 = $('label[for="qtjobporhor15"]','#frmParametrosGerais');
	var rQtjobporhor16 = $('label[for="qtjobporhor16"]','#frmParametrosGerais');
	var rQtjobporhor17 = $('label[for="qtjobporhor17"]','#frmParametrosGerais');
	var rQtjobporhor18 = $('label[for="qtjobporhor18"]','#frmParametrosGerais');
	var rQtjobporhor19 = $('label[for="qtjobporhor19"]','#frmParametrosGerais');
	var rQtjobporhor20 = $('label[for="qtjobporhor20"]','#frmParametrosGerais');
	var rQtjobporhor21 = $('label[for="qtjobporhor21"]','#frmParametrosGerais');
	var rQtjobporhor22 = $('label[for="qtjobporhor22"]','#frmParametrosGerais');
	var rQtjobporhor23 = $('label[for="qtjobporhor23"]','#frmParametrosGerais');
	var rFltpaviso     = $('label[for="fltpaviso"]'    ,'#frmParametrosGerais');
	var rFlmailhab     = $('label[for="flmailhab"]'     ,'#frmParametrosGerais');
	var rlblLog        = $('label[for="lblLog"]'     ,'#frmParametrosGerais');
	var rFlarqhab      = $('label[for="flarqhab"]'     ,'#frmParametrosGerais');
	
	rNmjobmaster.addClass("rotulo").css('width','200px');
	rNumminjob.addClass("rotulo").css('width','200px');
	rLblminutos.addClass("rotulo-linha");
	rQtjobporhor0.addClass("rotulo").css('width','325px');
	rQtjobporhor1.addClass("rotulo").css('width','325px');
	rQtjobporhor2.addClass("rotulo").css('width','325px');
	rQtjobporhor3.addClass("rotulo").css('width','325px');
	rQtjobporhor4.addClass("rotulo").css('width','325px');
	rQtjobporhor5.addClass("rotulo").css('width','325px');
	rQtjobporhor6.addClass("rotulo").css('width','325px');
	rQtjobporhor7.addClass("rotulo").css('width','325px');
	rQtjobporhor8.addClass("rotulo").css('width','325px');
	rQtjobporhor9.addClass("rotulo").css('width','325px');
	rQtjobporhor10.addClass("rotulo").css('width','325px');
	rQtjobporhor11.addClass("rotulo").css('width','325px');
	rQtjobporhor12.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor13.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor14.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor15.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor16.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor17.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor18.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor19.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor20.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor21.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor22.addClass("rotulo-linha").css('width','160px');
	rQtjobporhor23.addClass("rotulo-linha").css('width','160px');
	rFltpaviso.addClass("rotulo").css('width','200px');
	rFlmailhab.addClass("rotulo-linha");
	rlblLog.addClass("rotulo").css('width','200px');
	rFlarqhab.addClass("rotulo-linha");
  
	//Campos do frmParametrosGerais
	var cNmjobmaster   = $('#nmjobmaster','#frmParametrosGerais');
	var cNumminjob     = $('#numminjob','#frmParametrosGerais');    
	var cQtjobporhor0  = $('#qtjobporhor0','#frmParametrosGerais'); 
	var cQtjobporhor1  = $('#qtjobporhor1','#frmParametrosGerais'); 
	var cQtjobporhor2  = $('#qtjobporhor2','#frmParametrosGerais'); 
	var cQtjobporhor3  = $('#qtjobporhor3','#frmParametrosGerais'); 
	var cQtjobporhor4  = $('#qtjobporhor4','#frmParametrosGerais'); 
	var cQtjobporhor5  = $('#qtjobporhor5','#frmParametrosGerais'); 
	var cQtjobporhor6  = $('#qtjobporhor6','#frmParametrosGerais'); 
	var cQtjobporhor7  = $('#qtjobporhor7','#frmParametrosGerais'); 
	var cQtjobporhor8  = $('#qtjobporhor8','#frmParametrosGerais'); 
	var cQtjobporhor9  = $('#qtjobporhor9','#frmParametrosGerais'); 
	var cQtjobporhor10 = $('#qtjobporhor10','#frmParametrosGerais');
	var cQtjobporhor11 = $('#qtjobporhor11','#frmParametrosGerais');
	var cQtjobporhor12 = $('#qtjobporhor12','#frmParametrosGerais');
	var cQtjobporhor13 = $('#qtjobporhor13','#frmParametrosGerais');
	var cQtjobporhor14 = $('#qtjobporhor14','#frmParametrosGerais');
	var cQtjobporhor15 = $('#qtjobporhor15','#frmParametrosGerais');
	var cQtjobporhor16 = $('#qtjobporhor16','#frmParametrosGerais');
	var cQtjobporhor17 = $('#qtjobporhor17','#frmParametrosGerais');
	var cQtjobporhor18 = $('#qtjobporhor18','#frmParametrosGerais');
	var cQtjobporhor19 = $('#qtjobporhor19','#frmParametrosGerais');
	var cQtjobporhor20 = $('#qtjobporhor20','#frmParametrosGerais');
	var cQtjobporhor21 = $('#qtjobporhor21','#frmParametrosGerais');
	var cQtjobporhor22 = $('#qtjobporhor22','#frmParametrosGerais');
	var cQtjobporhor23 = $('#qtjobporhor23','#frmParametrosGerais');
	var cFlmailhab     = $('#flmailhab','#frmParametrosGerais');    
	var cFlarqhab      = $('#flarqhab','#frmParametrosGerais');     

    cNmjobmaster.css({'width':'250px'}).addClass('alphanum').attr('maxlength','40');
	cNumminjob.css({'width':'80px'}).addClass('inteiro').attr('maxlength','5');
	cQtjobporhor0.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor1.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor2.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor3.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor4.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor5.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor6.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor7.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor8.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor9.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2'); 
	cQtjobporhor10.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor11.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor12.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor13.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor14.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor15.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor16.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor17.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor18.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor19.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor20.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor21.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor22.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cQtjobporhor23.css({'width':'50px'}).addClass('inteiro').attr('maxlength','2');
	cFlmailhab.css({'width':'20px'});
	cFlarqhab.css({'width':'20px'});
	
	$('input','#frmParametrosGerais').habilitaCampo();

	$('#frmParametrosGerais').css('display','block');
	$('#divBotoesParametros').css('display','block');
	layoutPadrao();
	
	$('#nmjobmaster','#frmParametrosGerais').focus();
	
	return false;
	
}

function buscaParametrosGerais(){
		
	showMsgAguardo( "Aguarde, carregando os parâmetros gerais..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/form_parametros_gerais.php", 
        data: {
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divParametrosGerais').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function gravarParametrosGerais(){
	
	var cddopcao      = $('#cddopcao','#frmCabConjob').val();
	var nmjobmaster   = $('#nmjobmaster','#frmParametrosGerais').val();
	var numminjob     = $('#numminjob','#frmParametrosGerais').val();
	var qtjobporhor0  = $('#qtjobporhor0','#frmParametrosGerais').val();
	var qtjobporhor1  = $('#qtjobporhor1','#frmParametrosGerais').val();
	var qtjobporhor2  = $('#qtjobporhor2','#frmParametrosGerais').val();
	var qtjobporhor3  = $('#qtjobporhor3','#frmParametrosGerais').val();
	var qtjobporhor4  = $('#qtjobporhor4','#frmParametrosGerais').val();
	var qtjobporhor5  = $('#qtjobporhor5','#frmParametrosGerais').val();
	var qtjobporhor6  = $('#qtjobporhor6','#frmParametrosGerais').val();
	var qtjobporhor7  = $('#qtjobporhor7','#frmParametrosGerais').val();
	var qtjobporhor8  = $('#qtjobporhor8','#frmParametrosGerais').val();
	var qtjobporhor9  = $('#qtjobporhor9','#frmParametrosGerais').val();
	var qtjobporhor10 = $('#qtjobporhor10','#frmParametrosGerais').val();
	var qtjobporhor11 = $('#qtjobporhor11','#frmParametrosGerais').val();
	var qtjobporhor12 = $('#qtjobporhor12','#frmParametrosGerais').val();
	var qtjobporhor13 = $('#qtjobporhor13','#frmParametrosGerais').val();
	var qtjobporhor14 = $('#qtjobporhor14','#frmParametrosGerais').val();
	var qtjobporhor15 = $('#qtjobporhor15','#frmParametrosGerais').val();
	var qtjobporhor16 = $('#qtjobporhor16','#frmParametrosGerais').val();
	var qtjobporhor17 = $('#qtjobporhor17','#frmParametrosGerais').val();
	var qtjobporhor18 = $('#qtjobporhor18','#frmParametrosGerais').val();
	var qtjobporhor19 = $('#qtjobporhor19','#frmParametrosGerais').val();
	var qtjobporhor20 = $('#qtjobporhor20','#frmParametrosGerais').val();
	var qtjobporhor21 = $('#qtjobporhor21','#frmParametrosGerais').val();
	var qtjobporhor22 = $('#qtjobporhor22','#frmParametrosGerais').val();
	var qtjobporhor23 = $('#qtjobporhor23','#frmParametrosGerais').val();
	var flmailhab     = $('#flmailhab','#frmParametrosGerais').is(':checked') ? 'S' : 'N';
	var flarqhab      = $('#flarqhab','#frmParametrosGerais').is(':checked') ? 'S' : 'N';
	
	showMsgAguardo( "Aguarde, gravando parâmetros..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/gravar_parametros_gerais.php", 
        data: {
			cddopcao:      cddopcao,
			nmjobmaster:   nmjobmaster,
			numminjob:     numminjob,
			qtjobporhor0:  qtjobporhor0,  
			qtjobporhor1:  qtjobporhor1,  
			qtjobporhor2:  qtjobporhor2,  
			qtjobporhor3:  qtjobporhor3,  
			qtjobporhor4:  qtjobporhor4,  
			qtjobporhor5:  qtjobporhor5,  
			qtjobporhor6:  qtjobporhor6,  
			qtjobporhor7:  qtjobporhor7,  
			qtjobporhor8:  qtjobporhor8,  
			qtjobporhor9:  qtjobporhor9,  
			qtjobporhor10: qtjobporhor10,
			qtjobporhor11: qtjobporhor11,
			qtjobporhor12: qtjobporhor12,
			qtjobporhor13: qtjobporhor13,
			qtjobporhor14: qtjobporhor14,
			qtjobporhor15: qtjobporhor15,
			qtjobporhor16: qtjobporhor16,
			qtjobporhor17: qtjobporhor17,
			qtjobporhor18: qtjobporhor18,
			qtjobporhor19: qtjobporhor19,
			qtjobporhor20: qtjobporhor20,
			qtjobporhor21: qtjobporhor21,
			qtjobporhor22: qtjobporhor22,
			qtjobporhor23: qtjobporhor23,
			flmailhab:     flmailhab,        
			flarqhab:      flarqhab,          
            redirect:      "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ", "Alerta - Ayllos", "");
			}
		}
    });

    return false;	
	
}

function alterarJob(){

	showMsgAguardo( "Aguarde, alterando job..." );
	
	var cddopcao             = $('#cddopcao','#frmCabConjob').val();
	var nmjob                = $('#nmjob','#frmConsulta').val();
	var idativo              = $('#idativo','#frmConsulta').val();
	var dsdetalhe            = $('#dsdetalhe','#frmConsulta').val();
	var dsprefixo_jobs       = $('#dsprefixo_jobs','#frmConsulta').val();
	var idperiodici_execucao = $('#idperiodici_execucao','#frmConsulta').val();
	var tpintervalo          = $('#tpintervalo','#frmConsulta').val();
	var qtintervalo          = $('#qtintervalo','#frmConsulta').val();
	var dsdias_habilitados   = $('#cb_domingo','#frmConsulta').is(':checked') ? '1' : '0';
		dsdias_habilitados  += $('#cb_segunda','#frmConsulta').is(':checked') ? '1' : '0';
		dsdias_habilitados  += $('#cb_terca','#frmConsulta').is(':checked')   ? '1' : '0';
		dsdias_habilitados  += $('#cb_quarta','#frmConsulta').is(':checked')  ? '1' : '0';
		dsdias_habilitados  += $('#cb_quinta','#frmConsulta').is(':checked')  ? '1' : '0';
		dsdias_habilitados  += $('#cb_sexta','#frmConsulta').is(':checked')   ? '1' : '0';
		dsdias_habilitados  += $('#cb_sabado','#frmConsulta').is(':checked')  ? '1' : '0';
	var dtprox_execucao      = $('#dtprox_execucao','#frmConsulta').val();
	var hrprox_execucao      = $('#hrprox_execucao','#frmConsulta').val();
	var hrjanela_exec_ini    = $('#hrjanela_exec_ini','#frmConsulta').val();
	var hrjanela_exec_fim    = $('#hrjanela_exec_fim','#frmConsulta').val();
	var flaguarda_processo   = $('#flaguarda_processo','#frmConsulta').is(':checked') ? 'S' : 'N';
	var flexecuta_feriado    = $('#flexecuta_feriado','#frmConsulta').is(':checked') ? 1 : 0;
	var flsaida_email        = $('#flsaida_email','#frmConsulta').is(':checked') ? 'S' : 'N';
	var dsdestino_email      = $('#dsdestino_email','#frmConsulta').val();
	var flsaida_log          = $('#flsaida_log','#frmConsulta').is(':checked') ? 'S' : 'N';
	var dsnome_arq_log       = $('#dsnome_arq_log','#frmConsulta').val();
	var dscodigo_plsql       = $('#dscodigo_plsql','#frmConsulta').val();

    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/alterar_job.php", 
        data: {
			cddopcao:             cddopcao,
			nmjob:                nmjob,
			idativo:              idativo,
			dsdetalhe:            dsdetalhe,  
			dsprefixo_jobs:       dsprefixo_jobs,  
			idperiodici_execucao: idperiodici_execucao,  
			tpintervalo:          tpintervalo,  
			qtintervalo:          qtintervalo,  
			dsdias_habilitados:   dsdias_habilitados,  
			dtprox_execucao:      dtprox_execucao,  
			hrprox_execucao:      hrprox_execucao,
			hrjanela_exec_ini:    hrjanela_exec_ini,
			hrjanela_exec_fim:    hrjanela_exec_fim,
			flaguarda_processo:   flaguarda_processo,  
			flexecuta_feriado:    flexecuta_feriado,  
			flsaida_email:        flsaida_email,  
			dsdestino_email:      dsdestino_email,
			flsaida_log:          flsaida_log,
			dsnome_arq_log:       dsnome_arq_log,
			dscodigo_plsql:       dscodigo_plsql,
            redirect:             "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ", "Alerta - Ayllos", "");
			}
		}
    });

    return false;	
	
}

function consultarLogJobs(nriniseq,nrregist){

	var cddopcao  = $('#cddopcao','#frmCabConjob').val();
	var cdcooper  = $('#cdcooper','#frmFiltroConsultaLogJobs').val();
	var nmjob     = $('#nmjob','#frmFiltroConsultaLogJobs').val();
	var data_de   = $('#data_de','#frmFiltroConsultaLogJobs').val();
	var data_ate  = $('#data_ate','#frmFiltroConsultaLogJobs').val();
	var id_result = $('#id_result','#frmFiltroConsultaLogJobs').val();
		
	showMsgAguardo( "Aguarde, consultando log de jobs..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/consultar_log_jobs.php",
        data: {
			cddopcao:  cddopcao,
			cdcooper:  cdcooper,
			nmjob:     nmjob,
			data_de:   data_de,
			data_ate:  data_ate,
			id_result: id_result,
			nrregist :nrregist,
			nriniseq :nriniseq,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabelaConsultaLogJobs').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataLogJobs(){

	$('#fsetConsultaLogJobs').css({'border-bottom':'1px solid #777'});
	
	var divRegistro = $('div.divRegistros', '#frmConsultaLogJobs');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '450px', 'width' : '900px'});
    $('#divRegistrosRodape','#frmConsultaLogJobs').formataRodapePesquisa();
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[1] = '280px';
    arrayLargura[2] = '62px';
    arrayLargura[3] = '62px';
    arrayLargura[4] = '65px';
    arrayLargura[5] = '62px';	
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'left';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('#divTabelaConsultaLogJobs').css('display','block');
	$('#frmConsultaLogJobs').css('display','block');
	$('#divBotoesConsultaLogJobs').css('display','block');
	$('#divBotoesFiltroConsultaLogJobs').css('display','none');
	$('input, select', '#frmFiltroConsultaLogJobs').desabilitaCampo();
	
	return false;
	
}

function mostrarFiltroConsultaLogJobs(){	
		
	showMsgAguardo( "Aguarde, abrindo filtro..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/form_filtro_consulta_log_jobs.php", 
        data: {
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divFiltroConsultaLogJobs').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataFiltroConsultaLogJobs(){

	highlightObjFocus( $('#frmFiltroConsultaLogJobs') );
	$('#fsetFiltroConsultaLogJobs').css({'border-bottom':'1px solid #777'});

	$('input','#frmFiltroConsultaLogJobs').val('');
	
	//Label do frmFiltroConsultaLogJobs
	var rCdcooper  = $('label[for="cdcooper"]','#frmFiltroConsultaLogJobs');
	var rNmjob     = $('label[for="nmjob"]','#frmFiltroConsultaLogJobs');
	var rData_de   = $('label[for="data_de"]','#frmFiltroConsultaLogJobs');
	var rData_ate  = $('label[for="data_ate"]','#frmFiltroConsultaLogJobs');
	var rId_result = $('label[for="id_result"]','#frmFiltroConsultaLogJobs');
	
	rCdcooper.addClass("rotulo").css('width','100px');
	rNmjob.addClass("rotulo-linha").css('width','80px');
	rData_de.addClass("rotulo").css('width','100px');
	rData_ate.addClass("rotulo-linha").css('width','80px');
	rId_result.addClass("rotulo-linha").css('width','100px');
	  
	//Campos do frmFiltroConsultaLogJobs
	var cCdcooper  = $('#cdcooper','#frmFiltroConsultaLogJobs');
	var cNmjob     = $('#nmjob','#frmFiltroConsultaLogJobs');
	var cData_de   = $('#data_de','#frmFiltroConsultaLogJobs');
	var cData_ate  = $('#data_ate','#frmFiltroConsultaLogJobs');
	var cId_result = $('#id_result','#frmFiltroConsultaLogJobs');
 
 	cCdcooper.css({'width':'100px'}).addClass('alphanum');
    cNmjob.css({'width':'356px'}).addClass('alphanum');
    cData_de.css({'width':'100px'}).addClass('data');
    cData_ate.css({'width':'100px'}).addClass('data');
    cId_result.css({'width':'150px'}).addClass('alphanum');
	
	$('input, select','#frmFiltroConsultaLogJobs').habilitaCampo();	

	//Define ação para o campo
	$('#nmjob','#frmFiltroConsultaLogJobs').unbind('keypress').bind('keypress', function (e) {
	    // se pressionar enter, consultar o job preenchido
	    if(e.keyCode == 13){
				
			$('#btProsseguir','#divBotoesFiltroConsultaLogJobs').click();
			
			return false;						
			
		}
	});

	$('#frmIncluir').css('display','none');
	$('#frmConsulta').css('display','none');
	$('#frmConsultaLogJobs').css('display','none');
	$('#divBotoesIncluir').css('display','none');
	$('#divBotoesConsulta').css('display','none');
	$('#divBotoesFiltro').css('display','none');
	$('#divBotoesConsultaLogJobs').css('display','none');	
	$('#frmFiltroConsultaLogJobs').css('display','block');
	$('#divBotoesFiltroConsultaLogJobs').css('display','block');
	
	controlaPesquisas();
	
	layoutPadrao();
	
	$('#cdcooper','#frmFiltro').focus();
	
	return false;
	
}

function consultarParametros(){
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conjob/consultar_parametros.php", 
        data: {
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","unblockBackground();estadoInicial();");
        },
        success: function(response) {
        	try {
        		eval( response );						
        	} catch(error) {						
        		showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
        	}
		}
    });

    return false;

}

function validarHora(campo){
	hrs = $(campo).val().substring(0,2); 
	min = $(campo).val().substring(3,5); 

	if ((hrs < 00 ) || (hrs > 23) || ( min < 00) ||( min > 59)){ 
	 	$(campo).val(''); 
	}
}
