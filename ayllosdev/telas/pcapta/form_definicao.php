<?php
/* !
 * FONTE        : form_definicao.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 30/04/2014
 * OBJETIVO     : Formulario de definicao de da tela PCAPTA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina','DEFINICAO');

$xmlResult = $xmlObj = null; //limpa as variaveis

// Montar o xml de Requisicao
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Chama procedure consulta cooperativas	
$xmlResult = mensageria($xml, "PCAPTA", "CONCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Verifica se houve erro
if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
} else {
    $cooperativas = $xmlObj->roottag->tags;
}
?>
<div id="definicaoConsulta">
    <input type="hidden" class="idtxfixa" value="" />
    <fieldset>
        <legend>Pol&iacute;ticas da Cooperativa</legend>
        <table>
            <tr>
                <td>
                    <label for="cdcooper">Cooperativa:</label>
                    <select name="cdcooper" id="cdcooper">
                        <option value="0">-- Selecione --</option>
                            <?php
                            foreach ($cooperativas as $registro) {
                                echo '<option value="' . str_replace(PHP_EOL, "", $registro->tags[0]->cdata) . '">' . $registro->tags[1]->cdata . '</option>';
                            }
                            ?>                                        
                    </select>
                </td>
            </tr>
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
                    <label for="cddindex">Indexador:</label>
                    <input type="text" name="cddindex" id="cddindex" value="" />
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" id="btVoltar" onclick="resetaForm('definicaoConsulta');">Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg" onclick="executaFuncaoOperacao();">Prosseguir</a>
                </td>
            </tr>
        </table>
        <div class="divRetorno"></div>        
    </fieldset>
    <table class="tableAcoes" style="">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="escolheOpcao('D', 'V');">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btBloque"  onclick="escolheOpcao('D', 'B');">Bloquear</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('D', 'C');">Consultar</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('D', 'I');">Inserir</a>
                <a href="javascript:void(0);" class="botao" id="btDesblo"  onclick="escolheOpcao('D', 'D');">Desbloquear</a>
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('D', 'E');">Excluir</a>
            </td>
        </tr>
    </table>	
    <input type="hidden" id="hdnCodModalidade" value="" />
    <input type="hidden" id="hdnCodSubOpcao" value="" />
    <input type="hidden" id="hdnProdSel" value="0" />     
</div>
<style type="text/css">
    #pcapta fieldset table {
        margin-left: 70px;
    }    
    table.tituloRegistros {
        margin-left: 0px !important;
    }
    #divPesquisaRodape table {
        margin-left: 0px !important;
    }
    tr.linhaBotoes #btVoltar {
        margin-left: 120px;
    }
    tr.linhaBotoes {
        display: none;
    }
    table.tableAcoes {
        margin-left:55px;
    }    
</style>
<script type="text/javascript">

    $(function() {
        
        $('#cdcooper', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#cdprodut', '#frmCab').focus();
                return false;
            }
        });

        $('#cdprodut', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if ( (e.keyCode == 9 || e.keyCode == 13) && $(this).val() > 0) {
                consultaIndexadorProduto($(this));
            }
        });  
        
        $('#cdprodut', '#frmCab').unbind('click').bind('click', function() {
            consultaIndexadorProduto($(this));
        });
        
        $('#qtdiaprz', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#vlrfaixa', '#frmCab').focus();
                return false;
            }
        });
        
        $('#vlrfaixa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#btProseg', '#frmCab').focus();
                return false;
            }
        });
        
    });   
    
    
    function executaFuncaoOperacao()
    {
        //recupera o titulo da pagina
        var titulo = $('#definicaoConsulta legend').text().split(' - ');
        
        if ( $("#hdnCodSubOpcao").val() == '' ) {
            $("#hdnCodSubOpcao").val(titulo[1].charAt(0));
        }
        
        if ( $("#hdnCodSubOpcao").val() == 'I' ) {
            carregaPoliticas(1,30);
        } else {
            consultaModalidade(1,30);
        }
        
    }
    

    /**
     * @opcao D - Definicao Politica de Captacao
     * @name gravaModalidade
     * @returns 
     */
    function gravaModalidade() {

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_definicao.php",
            dataType: "json",
            data: {
                flgopcao: 'I',
                cdcooper: $("#definicaoDefinir #cdcooper option:selected").val(),
                cdmodali: $("#definicaoDefinir #cdmodali").val()
            },
            success: function(retorno) {
                if (retorno.erro == 'N') {
                    resetaForm('definicaoDefinir');
                } else {
                    showError("error", retorno.msg, "Alerta - Ayllos", "");
                }
            }
        });

    }
    
    
    
    /**
     * @opcao D - Definicao Politica de Captacao
     * @name consultaIndexadorProduto
     * @returns retorna o indexador
     */
    function consultaIndexadorProduto(obj) {

        if ( $(obj).val() > 0 ) {
            
            if ($("#hdnProdSel").val() != obj.val()) {            

                showMsgAguardo("Aguarde, carregando dados...");     

                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_definicao.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: $(obj).val()
                        ,redirect: "script_ajax"
                    },
                    success: function(data) {
                        if (data.rows == 1) {
                            $.each(data.records, function(i, item) {
                                $(obj).parent().parent().next().find("#cddindex").val(item.nmdindex);
                                if ( item.idtxfixa == 1 ) {
                                    $("#vltxfixa").parent().parent().show();
                                    $("#vlperren").parent().parent().hide();
                                    ocultaMsgAguardo();
                                } else if ( item.idtxfixa == 2 ) {
                                    $("#vlperren").parent().parent().show();
                                    $("#vltxfixa").parent().parent().hide();
                                    ocultaMsgAguardo();
                                }
                                $("input.idtxfixa").val(item.idtxfixa);
                            });
                        }
                    }
                });
                $('#btProseg', '#frmCab').focus();
            }   
        }
        $("#hdnProdSel").val(obj.val());
    }    
    
      
    /**
     * @opcao D - Definicao Politica de Captacao
     * @name consultaModalidade
     * @returns tabela com as modalidades do produto
     */
    function consultaModalidade(nriniseq, nrregist) 
    {
        var cooperativa = $('#definicaoConsulta select#cdcooper option:selected').val();
        var produto = $('#definicaoConsulta select#cdprodut option:selected').val();    

        if ( produto > 0 && cooperativa > 0 ) {
            $('#cdcooper, #cdprodut').attr('disabled', true);
			
            showMsgAguardo("Aguarde, carregando dados...");			
			
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_definicao.php",
                async: false,
                data: {
                    flgopcao: 'CM',
                    subopcao: $("#hdnCodSubOpcao").val(),
                    cdprodut: produto,
                    cdcooper: cooperativa,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    idtxfixa: $('#definicaoConsulta .idtxfixa').val(),
                    redirect: "script_ajax"
                },
                success: function(data) {
                    if (data.indexOf('showError("error"') == -1) {
                        $("tr.linhaBotoes").hide();
                        $('#definicaoConsulta .divRetorno').empty().html(data).show();                        
                        formataTabelaModalidade();
                        $('#btVoltar', '#frmCab').focus();                       
                        ocultaMsgAguardo();
                    } else {
                        eval(data);
                        ocultaMsgAguardo();
                    }
                }
            });
        } else {
            if ( cooperativa == 0 ) {
                showError('error', 'Selecione uma cooperativa', 'Alerta - Ayllos', "$('#cdcooper', '#frmCab').focus();ocultaMsgAguardo();");
            } else if ( produto == 0 ) {
                showError('error', 'Selecione um produto', 'Alerta - Ayllos', "$('#cdprodut', '#frmCab').focus();ocultaMsgAguardo();");
            }
        }
    }    
    
    /**
     * @opcao D - Definicao Politica de Captacao
     * @name carregaPoliticas
     * @param {integer} nriniseq numero inicial de sequencia
     * @param {integer} nrregist numero final de sequencia
     * @returns tabela com as politicas existentes ainda nao cadastradas na cooperativa
     */
    function carregaPoliticas(nriniseq, nrregist) 
    {
        var cooperativa = $('#definicaoConsulta select#cdcooper option:selected').val();
        var produto = $('#definicaoConsulta select#cdprodut option:selected').val();    
        
        if ( produto > 0 && cooperativa > 0 ) {
            $('#cdcooper, #cdprodut').attr('disabled', true);
			
            showMsgAguardo("Aguarde, carregando dados...");			
        
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_definicao.php",
                async: false,
                data: {
                    flgopcao: 'CP',
                    subopcao: 'I',
                    cdprodut: produto,
                    cdcooper: cooperativa,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    idtxfixa: $('#definicaoConsulta .idtxfixa').val(),
                    redirect: "script_ajax"
                },
                success: function(data) {
                    if (data.indexOf('showError("error"') == -1) {
                        $("tr.linhaBotoes").hide();
                        $('.divRetorno').empty().html(data).show();                        
                        formataTabelaModalidade();
                        $('#btVoltar', '#frmCab').focus();
                        ocultaMsgAguardo();
                    } else {
                        eval(data);
                        ocultaMsgAguardo();
                    }
                }
            });
        } else {
            if ( cooperativa == 0 ) {
                showError("error", 'Selecione uma cooperativa', "Alerta - Ayllos", "$('#cdcooper', '#frmCab').focus();ocultaMsgAguardo();");
            } else {
                showError("error", 'Selecione um produto', "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();ocultaMsgAguardo();");
            }
        }
    }    
    
    

    
    /**
     * @opcao D - Definicao Politica de Captacao
     * @name validaOperacao
     * @returns 
     */    
    function validaOperacao(cdoperacao)
    {
        var codModalidade = '';
        var dsOperacao = '';

        $("#frmTaxas .tabModalidade .tituloRegistros td input.cdmodali").each( function() {

            if ( $(this).is(':checked') ) {
                codModalidade += ( codModalidade == '' ) ? $(this).attr('id') : ','+$(this).attr('id');
            }
        });
        
        if ( cdoperacao == 'E' ) {
            dsOperacao = 'a exclusão'
        } else if ( cdoperacao == 'D' ) {
            dsOperacao = 'o desbloqueio'
        } else if ( cdoperacao == 'B' ) {
            dsOperacao = 'o bloqueio'
        } else if ( cdoperacao == 'I' ) {
            dsOperacao = 'o cadastro'
        }
        
        if ( codModalidade != '' ) {
            $("#hdnCodModalidade").val(codModalidade);
            showConfirmacao('Confirma '+dsOperacao+' da(s) modalidade(s)?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executaOperacao("'+cdoperacao+'")', '', 'sim.gif', 'nao.gif');
        } else {
           showError("error", 'Nenhuma modalidade selecionada para '+dsOperacao+'.', "Alerta - Ayllos", ""); 
        }
        
    }    
    

    function executaOperacao(cdoperacao)
    {
        var cdModali = '';
        cdModali = $("#hdnCodModalidade").val();
        var cooperativa = $('#definicaoConsulta select#cdcooper option:selected').val();            

        if ( cdModali != '' && cooperativa > 0 ) {
            showMsgAguardo("Aguarde, processando...");
		
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_definicao.php",
                dataType: "json",
		async: false,
                data: {
                    flgopcao: cdoperacao,
                    cdcooper: cooperativa,                    
                    cdmodali: cdModali 
                },
                success: function(retorno) {
                    if (retorno.erro == 'N') {

                        var arrModali = '';
                        arrModali = cdModali.split(',');
                        
                        for(var c=0; c<=arrModali.length ; c++) {
                            if ( arrModali[c] != 'undefined' ) {
                                $("#frmTaxas .tabModalidade #"+arrModali[c]).remove();
                            }
                        }
                        
                        var nrLinhasVisiveis = $("#frmTaxas .tabModalidade table tbody tr:visible").length;
                        
                        //caso nao houver mais nenhum item a ser selecionado na tabela, voltar
                        if ( nrLinhasVisiveis == 0 ) {
                            resetaCampos();
                        } else {
                            //atualiza o total de registros no rodape da tabela
                            $("#nrRegistrosTabela").text('Exibindo 1 até '+nrLinhasVisiveis+' de '+nrLinhasVisiveis);
                        }
                        // limpa o campo hidden
                        $("#hdnCodModalidade").val('');
                        ocultaMsgAguardo();
                    } else {
                        showError("error", retorno.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                    }
                    
                    
                }
            });

        } else {
            if ( cooperativa == 0 ) {
                showError("error", 'Selecione uma cooperativa', "Alerta - Ayllos", "$('#cdcooper', '#frmCab').focus();");
            } else {
                showError("error", 'Selecione um produto', "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
            }            
        }
    }
    
    
    /**
     * @opcao D - Definicao Politica de Captacao
     * @name formataTabelaModalidade
     * @returns tabela com dados formatada
     */
    function formataTabelaModalidade() {

        // Tabela
        $('.tabModalidade').css({'display': 'block'});
        $('#divConsulta').css({'display': 'block'});

        var divRegistro = $('div.divRegistros', '.tabModalidade');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        $('.tabModalidade').css({'margin-top': '5px'});
        divRegistro.css({'height': '150px', 'width': '590px', 'padding-bottom': '2px'});

        var ordemInicial = new Array();
        
        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'left';
        
        var arrayLargura = new Array();

        if ( $("#hdnCodSubOpcao").val() == 'B' || $("#hdnCodSubOpcao").val() == 'D' || $("#hdnCodSubOpcao").val() == 'E' || $("#hdnCodSubOpcao").val() == 'I' ) {
            arrayLargura[0] = '30px';
            arrayLargura[1] = '81px';
            arrayLargura[2] = '81px';
            arrayLargura[3] = '170px';
            //arrayLargura[4] = '170px';
            
            arrayAlinha[4] = 'left';            
        } else {
            arrayLargura[0] = '108px';
            arrayLargura[1] = '100px';
            arrayLargura[2] = '160px';
            //arrayLargura[3] = '161px';
        }

        var metodoTabela = '';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

        //valida acoes diferentes de Consulta
        if ( $("#hdnCodSubOpcao").val() != 'C' ) {           
            //remove ordenacao ao clicar no checkbox
            $("th:eq(0)", tabela).removeClass();
            $("th:eq(0)", tabela).unbind('click');
        }

        return false;
    }    
    
    function carregaComboProdutos(acao)
    {
        var htmlOpcoes = '<option value="0">-- Selecione --</option>';

        var div = '#definicaoConsulta #cdprodut';

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

        $(div).empty().append(htmlOpcoes);
        ocultaMsgAguardo();
    }	
	
	
</script>