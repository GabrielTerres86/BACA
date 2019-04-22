<?php
/* !
 * FONTE        : form_nomenclatura.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 30/04/2014
 * OBJETIVO     : Formulario de nomenclatura da tela PCAPTA
 * --------------
 * ALTERAÇÕES   : 23/10/2018 - Inclusão do campo com as principais características - Proj. 411.2 - CIS Corporate
 * --------------
 */


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina','NOMENCLATURA');

?>
<div id="nomenclaturaDados">
    <fieldset>
        <legend>Dados Nomenclatura</legend>
        <table>
            <tr>
                <td>
                    <label for="cdprodut">Produto:</label>
                    <select name="cdprodut" id="cdprodut">
                        <option value="0">-- Selecione --</option>                 
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="cdnomenc">Nome:</label>
                    <select name="cdnomenc" id="cdnomenc">
                        <option value="0">-- Selecione --</option>
                    </select>
                    <label style="display:none;" for="dsnomenc" >Nome:</label>
                    <input type="text" id="dsnomenc" style="display:none;" maxlength="20" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="qtmincar">Car&ecirc;ncia:</label>
                    <input type="text" name="qtmincar" id="qtmincar" style="margin-right: 2px;" maxlength="4" class="inteiro" /> 
                    <label for="qtmaxcar">at&eacute;</label>
                    <input type="text" name="qtmaxcar" id="qtmaxcar" style="margin-left: 2px;" maxlength="4" class="inteiro" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="vlminapl">Valor:</label>
                    <input type="text" name="vlminapl" id="vlminapl" class="moeda" style="margin-right: 2px;" />
                    <label for="vlmaxapl">at&eacute;</label>
                    <input type="text" name="vlmaxapl" id="vlmaxapl" class="moeda" style="margin-left: 2px;" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="idsitnom">Situa&ccedil;&atilde;o:</label>
                    <select name="idsitnom" id="idsitnom">
                        <option value="0">-- Selecione --</option>
                        <option value="1">ATIVA</option>
                        <option value="2">INATIVA</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="dscaract">Caracter&iacute;sticas:</label></br>
                    <textarea name="dscaract" id="dscaract" maxlength="500" style="margin-left: 40px; width: 330px; height: 180px; border:solid 1px;"></textarea>
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" id="btVoltar" name="btVoltar" onclick="resetaForm('nomenclaturaDados');">Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg"  onclick="validaOperacao();">Prosseguir</a>
                </td>
            </tr>
        </table>			
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="escolheOpcao('N', 'V');">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btAltera"  onclick="escolheOpcao('N', 'A');">Alterar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('N', 'C');">Consultar</a>
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('N', 'E');">Excluir</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('N', 'I');">Inserir</a>
            </td>
        </tr>
    </table>	
    <input type="hidden" id="hdnAcao" value="" />
    <input type="hidden" id="hdnAplicacao" value="" />
    <input type="hidden" id="hdnCdnomenc" value="" />
    <input type="hidden" id="hdnProdSel" value="0" />    
    <input type="hidden" id="hdnNomeSel" value="0" />    
</div>
<style type="text/css">

    #nmprodut, #cddindex, #cdprodut {
        width: 180px !important;
    }
    
    #pcapta fieldset table {
        margin-left: 72px;
    }

    fieldset table {
        margin-left: 25px;
    }
    #hdnAcao {
        display: none;
    }
    table.tituloRegistros {
        margin-left: 0px !important;
    }
    #divPesquisaRodape table {
        margin-left: 0px !important;
    }

    table.tableAcoes {
        margin-left: 120px;
    }
    
    tr.linhaBotoes #btVoltar {
        margin-left:120px;
    }      
    
    table tr.linhaBotoes {
        display: none;
    }
    
    #vlminapl, #vlmaxapl, #qtmincar, #qtmaxcar {
        margin: 3px 2px 0px 3px !important;
        width: 100px;
    }
</style>
<script type="text/javascript">

    $( function() {
        
        $('#cdprodut', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                carregaComboNomenclatura();
                return false;
            }
        }); 
        
        $('#cdprodut', '#frmCab').unbind('click').bind('click', function(e) {
            carregaComboNomenclatura();
            return false;
        });        
        
        
        $('#cdnomenc', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                carregaDadosNomenclatura();
                return false;
            }
        });        
        $('#cdnomenc', '#frmCab').unbind('click').bind('click', function(e) {
            carregaDadosNomenclatura();
            return false;            
        });       
        
        $('#dsnomenc', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {        
                $('#qtmincar', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#qtmincar', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#qtmaxcar', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#qtmaxcar', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#vlminapl', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#vlminapl', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#vlmaxapl', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#vlmaxapl', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#idsitnom', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#idsitnom', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#dscaract', '#frmCab').focus();
                return false;
            }
        });        
        
        $('#dscaract', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#btProseg', '#frmCab').focus();
                return false;
            }
        });        
        
        
    });
    
    
    function carregaComboNomenclatura()
    {

        if ( $("#cdprodut").val() > 0 ) {
            
            if ($("#hdnProdSel").val() != $("#cdprodut").val()) {

                var opcoes = '<option value="0">-- Selecione --</option>';
                showMsgAguardo("Aguarde, carregando dados...");

                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_nomenclatura.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: $("#cdprodut").val()
                    },
                    success: function(data) {
                        if (data.rows > 0) {
                            $.each(data.records, function(i, item) {
                                opcoes += '<option value="'+item.cdnomenc+'">'+item.dsnomenc+'</option>';
                            });
                            $('#nomenclaturaDados select#cdnomenc').empty().append(opcoes);
                            cCdprodut.attr('disabled', true);
                            cCdnomenc.attr('disabled', false);
                        } else {
                            $('#nomenclaturaDados select#cdnomenc').empty();
                            cCdprodut.attr('disabled', false);
                            cCdnomenc.attr('disabled', true);
                        }
                    }
                });
                ocultaMsgAguardo();
                
                if ( $("#hdnAcao").val() == 'I' ) {
                    $('#dsnomenc', '#frmCab').focus();
                } else {
                    $('#cdnomenc', '#frmCab').focus();
                }                
                
            }
        } 
        $("#hdnProdSel").val($('#cdprodut').val());
    }
    
    
    function carregaDadosNomenclatura()
    {

        if ( $("#cdprodut").val() > 0 && $("#cdnomenc").val() > 0 ) {
            
            if ($("#hdnNomeSel").val() != $("#cdnomenc").val()) {            
            
                showMsgAguardo("Aguarde, carregando dados...");	            

                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_nomenclatura.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: $("#cdprodut").val(),
                        cdnomenc: $("#cdnomenc").val()
                    },
                    success: function(data) {
                        if (data.rows > 0) {
                            //showMsgAguardo("Aguarde, carregando dados...");
                            $.each(data.records, function(i, item) {
                                $("#qtmincar").val(item.qtmincar);
                                $("#qtmaxcar").val(item.qtmaxcar);
                                $("#vlminapl").val(item.vlminapl);
                                $("#vlmaxapl").val(item.vlmaxapl);
                                $("#dscaract").val(item.dscaract);
                                $("#idsitnom option").each( function() {
                                    if ( $(this).val() == item.idsitnom ) {
                                        $(this).attr('selected', 'selected');
                                    }
                                });

                                $("#hdnAplicacao").val(item.aplicacao);

                                if ( $("#hdnAcao").val() == 'A' ) {
                                    $("#hdnCdnomenc").val($("#cdnomenc option:selected").val());
                                    if ( item.aplicacao == 'S' ) {
                                        cCdprodut.desabilitaCampo();
                                        cCdnomenc.desabilitaCampo();
                                        cQtmincar.desabilitaCampo();
                                        cQtmaxcar.desabilitaCampo();
                                        cVlminapl.desabilitaCampo();
                                        cVlmaxapl.desabilitaCampo();
                                        cIdsitnom.habilitaCampo();
                                        //foca o campo de situacao
                                        $('#idsitnom', '#frmCab').focus();
                                    } else {
                                        cDsnomenc.val($("#cdnomenc option:selected").text());
                                        //esconde o campo select
                                        cCdnomenc.hide();
                                        rCdnomenc.hide();
                                        //mostra o campo input
                                        cDsnomenc.show();
                                        cDsnomenc.attr("disabled", false);
                                        cDsnomenc.focus();
                                        rDsnomenc.show();
                                        //habilita os campos para edicao
                                        cQtmincar.habilitaCampo();
                                        cQtmaxcar.habilitaCampo();
                                        cVlminapl.habilitaCampo();
                                        cVlmaxapl.habilitaCampo();
                                        cIdsitnom.habilitaCampo();
                                        cDsCaract.habilitaCampo();
                                        //foca o campo de carencia minima
                                        $('#qtmincar', '#frmCab').focus();
                                    }
                                } else {
                                    cCdnomenc.attr('disabled', true);
                                }
                            }); 
                            ocultaMsgAguardo();
                        } else {
                            cCdnomenc.attr('disabled', false);
                        }
                    }
                });
                ocultaMsgAguardo();

                if ( $("#hdnAcao").val() == 'I' ) {
                    $('#qtmincar', '#frmCab').focus();
                } else if ( $("#hdnAcao").val() == 'C' ) {
                    $('#btVoltar', '#frmCab').focus();
                } else if ( $("#hdnAcao").val() == 'E' ) {
                    $('#btProseg', '#frmCab').focus();
                }           

            }
            
        } 
        
        $("#hdnNomeSel").val($('#cdnomenc').val());
    }
    
    function validaOperacao()
    {
        
        var acao = $("#hdnAcao").val();

        if ( $.trim(acao) != '' ) {
            
            switch (acao) {
                
                case 'A':
                    validaCamposTela('A');                
                    break;
                    
                case 'I':
                    validaCamposTela('I');
                    break;
                    
                case 'E':
                    if ($("#cdprodut").val() <= 0 || $("#cdprodut").val() == '' || $("#cdprodut").val() == null) {
                        showError("error", "Selecione o produto.", "Alerta - Ayllos", "");
                    } else if ($("#cdnomenc").val() <= 0 || $("#cdnomenc").val() == '' || $("#cdnomenc").val() == null) {
                        showError("error", "Selecione o nome.", "Alerta - Ayllos", "");
                    } else {
                        showConfirmacao('Confirma exclusão da nomenclatura ' + $("#cdnomenc option:selected").text() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluiNomenclatura()', '', 'sim.gif', 'nao.gif');
                    }
                    break;
            }
            
        }
        
    }
    
    
    function validaCamposTela(operacao) 
    {
        if ( $("#hdnAplicacao").val() == 'N' || $("#hdnAplicacao").val() == '' ) {
            showMsgAguardo("Aguarde, validando dados...");		

            if ($.trim($("#cdprodut").val()) == '' || $("#cdprodut").val() == null) {
                showError("error", "Selecine o produto.", "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#dsnomenc").val()) == '' || $("#dsnomenc").val() == null) {
                showError("error", "Preencha o nome.", "Alerta - Ayllos", "$('#dsnomenc', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#qtmincar").val()) == '' || $("#qtmincar").val() == null) {
                showError("error", "Preencha a carencia minima.", "Alerta - Ayllos", "$('#qtmincar', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#qtmaxcar").val()) == '' || $("#qtmaxcar").val() == null) {
                showError("error", "Preencha a carencia maxima.", "Alerta - Ayllos", "$('#qtmaxcar', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#vlminapl").val()) == '' || $("#vlminapl").val() == null) {
                showError("error", "Preencha a faixa de valor minimo.", "Alerta - Ayllos", "$('#vlminapl', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#vlmaxapl").val()) == '' || $("#vlmaxapl").val() == null) {
                showError("error", "Preencha a faixa de valor maxima.", "Alerta - Ayllos", "$('#vlmaxapl', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

            if ($.trim($("#dscaract").val()) == '' || $("#dscaract").val() == null) {
                showError("error", "Preencha as principais caracteristicas.", "Alerta - Ayllos", "$('#dscaract', '#frmCab').focus();ocultaMsgAguardo();");
                return false;
            }

        }

        if ($.trim($("#idsitnom").val()) == '' || $("#idsitnom").val() == null) {
            showError("error", "Selecione a situação.", "Alerta - Ayllos", "$('#idsitnom', '#frmCab').focus();ocultaMsgAguardo();");
            return false;
        }
        
        
        var opcao = ( operacao == 'I' ) ? 'inclusão' : 'alteração';
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_nomenclatura.php",
            dataType: "json",
               async: false,
            data: {
                flgopcao: 'V',
                cdprodut: $("#cdprodut option:selected").val(),
                cdnomenc: $("#hdnCdnomenc").val(),
                dsnomenc: $("#dsnomenc").val(),
                qtmincar: $("#qtmincar").val(),
                qtmaxcar: $("#qtmaxcar").val(),
                vlminapl: $("#vlminapl").val(),
                vlmaxapl: $("#vlmaxapl").val(),
                dscaract: $("#dscaract").val(),
                idsitnom: $("#idsitnom").val()
            },
            success: function(data) {
                if (data.rows == 1) {
                    $.each(data.records, function(i, retorno) {
                        if ( $("#hdnAplicacao").val() == 'N' || $("#hdnAplicacao").val() == '' ) {
                            if (retorno.produto == 'N') {
                                showError("error", 'Produto inválido', "Alerta - Ayllos", "ocultaMsgAguardo();");
                                return false;
                            } else if (retorno.nomenclatura == 'S') {
                                showError("error", 'Nomenclatura já cadastrada', "Alerta - Ayllos", "ocultaMsgAguardo();");
                                return false;
                            } else if (retorno.nom_valcar == 'S') {
                                showError("error", 'Existe nomenclatura cadastrada com mesmo valor e carencia para este produto', "Alerta - Ayllos", "ocultaMsgAguardo();");
                                return false;
                            } else if (retorno.carencia == 'N') {
                                showError("error", 'A carência mínima tem que ser menor a carência máxima', "Alerta - Ayllos", "$('#qtmincar', '#frmCab').focus();ocultaMsgAguardo();");
                                return false;
                            } else if (retorno.valor == 'N') {
                                showError("error", 'O valor mínimo tem que ser menor que o valor máximo', "Alerta - Ayllos", "$('#vlminapl', '#frmCab').focus();ocultaMsgAguardo();");
                                return false;
                            } 
                        }    
                        if (retorno.situacao == 'N') {
                            showError("error", 'Situação inválida', "Alerta - Ayllos", "$('#idsitnom', '#frmCab').focus();ocultaMsgAguardo();");
                            return false;
                        }                           
                        showConfirmacao('Confirma '+opcao+' da nomenclatura para o produto ' + $("#cdprodut option:selected").text() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaNomenclatura("'+operacao+'")', 'ocultaMsgAguardo();', 'sim.gif', 'nao.gif');
                    });
                } else {
                    if (data.erro == 'S') {
                        showError("error", data.msg, "Alerta - Ayllos", "");
                    }
                }
            }
        });
    }
    
    function gravaNomenclatura(operacao) 
    {
	showMsgAguardo("Aguarde, processando...");
		
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_nomenclatura.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: operacao,
                cdprodut: $("#cdprodut").val(),
                cdnomenc: $("#hdnCdnomenc").val(),
                dsnomenc: $("#dsnomenc").val(),
                qtmincar: $("#qtmincar").val(),
                qtmaxcar: $("#qtmaxcar").val(),
                vlminapl: $("#vlminapl").val(),
                vlmaxapl: $("#vlmaxapl").val(),
                dscaract: $("#dscaract").val(),
                idsitnom: $("#idsitnom").val()
            },
            success: function(data) {
                if (data.rows == 1) {
                    $.each(data.records, function(i, retorno) {
                        if (retorno.msg == 'OK') {
                            resetaForm('nomenclaturaDados');
                        }
                    });
                } else {
                    if (data.erro == 'S') {
                        showError("error", data.msg, "Alerta - Ayllos", "");
                    }                    
                }
            }
        });
        ocultaMsgAguardo();
    }
    
    
    function excluiNomenclatura()
    {
        if ( $("#cdprodut").val() > 0 && $("#cdnomenc").val() > 0 ) {
            showMsgAguardo("Aguarde, processando...");
			
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_nomenclatura.php",
                dataType: "json",
				async: false,
                data: {
                    flgopcao: 'E',
                    cdprodut: $("#cdprodut").val(),
                    cdnomenc: $("#cdnomenc").val()
                },
                success: function(data) {
                    if (data.rows > 0) {
                        $.each(data.records, function(i, item) {
                            if ( item.msg == 'OK' ) {
                                resetaForm('nomenclaturaDados');
                                ocultaMsgAguardo();
                            } else {
                                showError("error", item.msg, "Alerta - Ayllos", "");
                                ocultaMsgAguardo();
                            }
                        });
                    }
                }
            });
        } else {
            if ($("#cdprodut").val() <= 0) {
                showError("error", "Selecione o produto.", "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
            } else {
                showError("error", "Selecione o nome.", "Alerta - Ayllos", "$('#dsnomenc', '#frmCab').focus();");
            }
        }           
        
    }
    
    function carregaComboProdutos(acao)
    {
        var htmlOpcoes = '<option value="0">-- Selecione --</option>';

        showMsgAguardo("Aguarde, carregando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_historico.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'CAR',
                stracao: acao
            },
            success: function(data) {
                if (data.rows > 0) {
                    $.each(data.records, function(i, item) {
                        htmlOpcoes += '<option value="' + i + '">' + item + '</option>';
                    });

                }
            }
        });

        $("#nomenclaturaDados #cdprodut").empty().append(htmlOpcoes);
        ocultaMsgAguardo();
    }
    
</script>