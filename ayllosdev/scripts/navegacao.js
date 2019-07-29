//************************************************************************//
//*** Fonte: navegacao.js                                              ***//
//*** Autor: Evandro(RKAM)                                             ***//
//*** Data : Julho/2016                 Última Alteração: 21/07/2016   ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de navegação de telas                     ***//
//***                                                                  ***//	 
//*** Alterações: 
//*** [19/07/2016] Evandro (RKAM)   :  adicionado condição se não carregar conteudo atribui tabindex -1 ao campo;
//***                                  adicionado encerraAnotacoes na condição ESC;
//***                    
//*** [21/07/2016] Evandro (RKAM)   :  adicionado condição de navegação para janelas modals;
//***
//*** [17/04/2018] Marcos (MOUTS)   :  Removido chamada .click do UnblockBackground. (CRM)
//*** [27/06/2018] Christian (CECRED): Ajustes JS para execução do Ayllos em modo embarcado no CRM.
//*** [27/06/2018] Mateus Z (Mouts): PRJ 438 - Sprint 13 - Comentado tratamento do ESC para usar 
//***                                apenas o tratamento usado dentro do funcoes.js
//************************************************************************//

/** Navegação com o teclado nos campos **/
onload = function () {


    $(document.body).bind('keydown', function (e) {
        var target = e.target;

        switch (e.keyCode) {

            case 8://BACKSPACE
                var targetType = e.target.tagName.toUpperCase();
                // Permite a tecla BACKSPACE somente em campos INPUT e TEXTAREA e se estiverem habilitados para digitação			
                if ((targetType == "INPUT" || targetType == "TEXTAREA") && !e.target.disabled && !e.target.readonly) return true;
                return false;
                break;

            case 16://SHIFT

                break;

            case 9://TAB
                var TituloWindow = '';
                TituloWindow = $(".SetWindow").text();//Capta titulo da janela modal
                if (TituloWindow) { // Se abrir janela modal

                    var bShift = e.shiftKey;
                    if (bShift) {
                        var iSoma = -1;
                    } else {
                        var iSoma = 1;

                        //Se estiver com foco na classe LastInputModal
                        $(".LastInputModal").focus(function () {
                            var pressedShift = false;

                            $(this).bind('keyup', function (e) {
                                if (e.keyCode == 16) {
                                    pressedShift = false;//Quando tecla shift for solta passa valor false 
                                }
                            })

                            $(this).bind('keydown', function (e) {
                                e.stopPropagation();
                                e.preventDefault();

                                if (e.keyCode == 16) {
                                    pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                                }
                                if ((e.keyCode == 9) && pressedShift == true) {
                                    return setFocusCampo($(target), e, false, 0);
                                }
                                else if (e.keyCode == 9) {
                                    $(".FirstInputModal").focus();
                                }
                            });

                        });

                    }
                    return setFocusCampo($(target), e, false, iSoma);

                }
                else {
                    //se não carregar conteudo atribui tabindex -1 ao campo
                    var carregaTit = '';
                    $('.SetFocus').each(function () {
                        carregaTit = $(this).text(); //Carrega titulo da aba
                        var CarregaName = $(this).attr("name"); //Carrega valor do name
                        var TabValue = $(this).attr({ tabindex: '' + CarregaName + '' });//atribui o name a um tabindex para utilizar ao carregar novamente a consulta
                        if (carregaTit == ' ') {
                            $(this).attr('tabindex', '-1');
                        }
                    });

                    //navega pra frente e pra tras
                    var bShift = e.shiftKey;
                    if (bShift) {
                        var iSoma = -1;
                    } else {
                        var iSoma = 1;
                    }
                    return setFocusCampo($(target), e, false, iSoma);
                }
                break;

            case 13://ENTER   			
                TituloWindow = $(".SetWindow").text();//Capta titulo da janela modal
                if (TituloWindow) { // Se abrir janela modal
                }
                else {
                    var simulaClick = $('.SetFocus:focus');
                    simulaClick.trigger('click');
                };
            break;

            // PRJ 438 - Sprint 13 - Comentado tratamento do ESC para usar apenas o tratamento usado dentro do funcoes.js (Mateus Z / Mouts)
            /*case 27://ESC			    				
                $(".FirstInput:first").focus();

                //Condição para voltar foco na opção selecionada
                var CaptaIdRetornoFoco = '';
                CaptaIdRetornoFoco = $(".SetFoco").attr("id");
                if (CaptaIdRetornoFoco) { 
					var DefaultFoco = CaptaIdRetornoFoco.substring(0, 9);
					
                    $('#divError').css('display', 'none');
                    if (DefaultFoco == '#labelRot') {
                        $('#divConfirm').css('display','none');
                        $(CaptaIdRetornoFoco).focus();
                        unblockBackground();
                        encerraRotina();
                    }
                    else {
                        $(CaptaIdRetornoFoco).focus();
                        fechaSimulacoes(true);
                        fechaRotina($('#divUsoGenerico'));
                        fechaRotina(divRotina);
                        encerraRotina();
                    }
                }
                else {
                    encerraAnotacoes();
                };
                break;*/

            case 39://RIGHT 
                var bctrl = '';
                bctrl = e.ctrlKey; //Combina Ctrl + seta direita				
                if (bctrl) {
                    var TituloAba = '';
                    var TituloAbaLimCred = '';

                    $('#divRotina').each(function () {
                        TituloAba = $(this).find(".SetWindow").text().replace(/^\s+|\s+$/g, "");//Capta titulo da aba
                        TituloAbaLimCred = $(this).find(".SetWindowLimCred").text().replace(/^\s+|\s+$/g, "");//Capta titulo da aba Limite de credito/empresarial

                        if (TituloAba == 'CAPITAL') {
                            $('#divRotina').each(function () {//Senão executa a ação
                                if ($(this).find("#linkAba0").hasClass('txtBrancoBold')) {
                                    acessaOpcaoAba(5, 1, 'S').click();
                                }
                                else if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                    acessaOpcaoAba(5, 2, 'P').click();
                                }
                                else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                    acessaOpcaoAba(5, 3, 'E').click();
                                }
                                else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                    acessaOpcaoAba(5, 4, 'I').click();
                                }
                                else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                    acessaOpcaoAba(7, 6, 'L').click();
                                }
                            });
                        };

                        if (TituloAba == 'DEPOSITOS A VISTA') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba0").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 1, 1).click();
                                            }
                                            else if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 2, 2).click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 3, 3).click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 4, 4).click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 5, 5).click();
                                            }
                                            else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 6, 6).click();
                                            }
                                            else if ($(this).find("#linkAba6").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 7, 7).click();
                                            }
                                            else {
                                                acessaOpcaoAba(7, 0, 0).click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if (TituloAba == 'OCORRENCIAS') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba0").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 1, 1).click();
                                            }
                                            else if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 2, 2).click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 3, 3).click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 4, 4).click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 5, 5).click();
                                            }
                                            else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 6, 6).click();
                                            }
                                            else {
                                                acessaOpcaoAba(6, 0, 0).click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if ((TituloAbaLimCred == 'LIMITE DE CREDITO') || (TituloAbaLimCred == 'LIMITE EMPRESARIAL')) {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba0").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 1, 'N').click();
                                            }
                                            else if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 2, 'I').click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 3, 'U').click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 4, 'A').click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 7, 'P').click();
                                            }
                                            else {
                                                acessaOpcaoAba(8, 0, '@').click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if (TituloAba == 'CONTA INVESTIMENTO') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba0").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 1, 'S').click();
                                            }
                                            else if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 2, 'C').click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 3, 'I').click();
                                            }
                                            else {
                                                acessaOpcaoAba(4, 0, '@').click();
                                            }
                                        });
                                    }
                                }
                            });
                        };
                    });
                }
                break;

            case 37://LEFT 
                var bctrl = '';
                bctrl = e.ctrlKey; //Combina Ctrl + seta esquerda				
                if (bctrl) {
                    var TituloAba = '';
                    var TituloAbaLimCred = '';

                    $('#divRotina').each(function () {
                        TituloAba = $(this).find(".SetWindow").text().replace(/^\s+|\s+$/g, "");//Capta titulo da aba
                        TituloAbaLimCred = $(this).find(".SetWindowLimCred").text().replace(/^\s+|\s+$/g, "");//Capta titulo da aba Limite de credito/empresarial

                        if (TituloAba == 'CAPITAL') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(5, 0, '@').click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(5, 1, 'S').click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(5, 2, 'P').click();
                                            }
                                            else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(5, 3, 'E').click();
                                            }
                                            else if ($(this).find("#linkAba6").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 5, '').click();
                                            }
                                            else {
                                                acessaOpcaoAba(5, 0, '@').click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if (TituloAba == 'DEPOSITOS A VISTA') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 0, 0).click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 1, 1).click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 2, 3).click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 3, 3).click();
                                            }
                                            else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 4, 4).click();
                                            }
                                            else if ($(this).find("#linkAba6").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 5, 5).click();
                                            }
                                            else if ($(this).find("#linkAba7").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(7, 6, 6).click();
                                            }
                                            else {
                                                acessaOpcaoAba(7, 0, 0).click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if (TituloAba == 'OCORRENCIAS') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 0, 0).click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 1, 1).click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 2, 2).click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 3, 3).click();
                                            }
                                            else if ($(this).find("#linkAba5").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 4, 4).click();
                                            }
                                            else if ($(this).find("#linkAba6").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(6, 5, 5).click();
                                            }
                                            else {
                                                acessaOpcaoAba(6, 0, 0).click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if ((TituloAbaLimCred == 'LIMITE DE CREDITO') || (TituloAbaLimCred == 'LIMITE EMPRESARIAL')) {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 0, '@').click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 1, 'N').click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 2, 'I').click();
                                            }
                                            else if ($(this).find("#linkAba4").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 3, 'U').click();
                                            }
                                            else if ($(this).find("#linkAba7").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(8, 4, 'A').click();
                                            }
                                            else {
                                                acessaOpcaoAba(8, 0, '@').click();
                                            }
                                        });
                                    }
                                }
                            });
                        };

                        if (TituloAba == 'CONTA INVESTIMENTO') {
                            $('#divError').each(function () {//Verifica se mensagem d erro esta aberta
                                if ($(this).css('display') == 'block') {
                                    hideMsgAguardo();
                                    showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                    $(this).find("#btnError").first().focus();
                                    $(this).bind('keydown', function (e) {
                                        if (e.keyCode == 27) {
                                            $('#divError').css('display', 'none');
                                        }
                                    });
                                }
                                else {
                                    if ($('#divAguardo').css('display') == 'block') { //Verifica se mensagem d alerta esta aberta
                                        setTimeout(function () {
                                            hideMsgAguardo();
                                            showError("error", "Por favor aguarde o carregamento completo do conte&uacute;do!", "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
                                            $("#btnError").first().focus();
                                        }, 200);
                                    }
                                    else {
                                        $('#divRotina').each(function () {
                                            if ($(this).find("#linkAba1").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 0, '@').click();
                                            }
                                            else if ($(this).find("#linkAba2").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 1, 'S').click();
                                            }
                                            else if ($(this).find("#linkAba3").hasClass('txtBrancoBold')) {
                                                acessaOpcaoAba(4, 2, 'C').click();
                                            }
                                            else {
                                                acessaOpcaoAba(4, 0, '@').click();
                                            }
                                        });
                                    }
                                }
                            });
                        };
                    });
                }
                break;

        };

    });
}

/** Determina se seta focus no objeto **/
function isSetFocusCampo(oObjeto) {
    $oAlvo = $(oObjeto);
    if (($oAlvo.attr('readOnly')) || ($oAlvo.attr('disabled')) || (!$oAlvo.is(':visible'))) {
        return false;
    }
    return true;
}

/** Retorna todos os campos do Documento
* @param oDocument
* @return Array 
*/
function getCamposForm(oDocument) {
    var aTypes = ['input', 'textarea', 'select', 'button', 'a.SetFocus', 'a.botao', 'a.FirstInputModal', 'a.LastInputModal', '.FluxoNavega'];
    var aSelector = [];
    jQuery.each(aTypes, function () {
        aSelector.push(this);
    });
    return $(aSelector.join(','), oDocument);
}

/** seta o focus no Objeto
* @param oObjetoAtual
* @param event
* @param aCampos
*/

function setFocusCampo(oObjetoAtual, event, aCampos, iSoma) {

    if ((oObjetoAtual.get(0).type.toUpperCase() == "BUTTON") || (oObjetoAtual.get(0).type.toUpperCase() == "")) {
        return true;
    }

    if (!aCampos) {
        var aCampos = getCamposForm(document.body);
    }

    if (event) {
        event.stopPropagation();
        event.preventDefault();
    }

    //identifica o numero de campos a pular
    $(aCampos).each(function (i) {
        if (this == oObjetoAtual.get(0)) {
            try {
                var oProximo = $(aCampos).eq(i + iSoma);
                // Verifica se pode setar o focus no campo
                if (isSetFocusCampo(oProximo)) {
                    oProximo.get(0).focus();
                    return true;
                } else {
                    return setFocusCampo(oProximo, event, aCampos, iSoma);
                }
            } catch (e) {
                return true;
            }
        }
    });
}
