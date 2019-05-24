/*!
 * FONTE        : comercial_pf.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 08/09/2015 
 * OBJETIVO     : Biblioteca de funções na rotina COMERCIAL PF da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

function acessaOpcaoAbaDados(nrOpcoes, id, opcao) {

    var urlScript = UrlSite + "telas/contas/";
    var nmdireto = "";
    var nmrotina = "";
    var nmdfonte = "principal.php";

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando ...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if ($('#linkAba' + id).length == false) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção	
            arr_guias_comercial[i] = true;
            $('#linkAba' + id).attr('class', 'txtBrancoBold');
            $('#imgAbaCen' + id).css('background-color', '#969FA9');
            continue;
        }		
		
        if (arr_guias_comercial[i] || flgcadas != 'M') { // Se ja passou por esta rotina, cor cinza senao vermelho (Quando vem da MATRIC)
            $('#linkAba' + i).attr('class', 'txtNormalBold'); //txtNormalBold
            $('#imgAbaCen' + i).css('background-color', '#C6C8CA');
        } else {
            $('#linkAba' + i).attr('class', 'txtBrancoBold'); //txtNormalBold
            $('#imgAbaCen' + i).css('background-color', '#EE0000');
        }
    }


	if (id == 0 && flgcadas == 'M') {		
		
		if (arr_guias_comercial[0]) { //se ja passou pela guia comercial
			$('#linkAba0').attr('class', 'txtNormalBold'); //txtNormalBold
			$('#imgAbaCen0').css('background-color', '#C6C8CA');
		} else {
			$('#linkAba0').attr('class', 'txtBrancoBold');
			$('#imgAbaCen0').css('background-color', '#969FA9');
		}
		
		$('#linkAba1').attr('class', 'txtBrancoBold');
		$('#imgAbaCen1').css('background-color', '#969FA9');
		
		$('#linkAba2').attr('class', 'txtBrancoBold');
        $('#imgAbaCen2').css('background-color', '#EE0000');		
	}		

	
	
	
    // Tratamento para chamada de cada "Rotina"
    switch (id) {
        case 0: {
            nmdireto = "comercial";
            nmrotina = "COMERCIAL";
            break;
        }
        case 1: {
            nmdireto = "bens";
            nmrotina = "Bens";
            break;
        }
        case 2: {
            nmdireto = "ppe";
            nmrotina = "PPE";
            break;
        }
    }

    chamaPrincipal(urlScript, nmdireto, nmrotina, nmdfonte, id, opcao);

}

function chamaPrincipal(urlScript, nmdireto, nmrotina, nmdfonte, id, opcao) {

    $.getScript(urlScript + nmdireto + "/" + nmdireto + ".js", function () {

        // Carrega conteúdo da opção através do Ajax
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/contas/' + nmdireto + '/' + nmdfonte,
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                nmdatela: "CONTAS",
                nmrotina: nmrotina,
                flgcadas: flgcadas,
                inpessoa: inpessoa,
                opcao: opcao,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                var err = eval("(" + objAjax.responseText + ")");
                showError('error', err.Message + ' N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            },
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
                    $('#divConteudoOpcao').html(response);
                } else {
                    eval(response);
                }
                return false;
            }
        });

    });

}