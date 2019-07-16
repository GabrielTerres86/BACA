<?php
//*********************************************************************************************//
//*** Fonte: form_v.php                                    						            ***//
//*** Autor: David Valente - Envolti                                           				***//
//*** Data : Abril/2019                  Última Alteração: --/--/----  					    ***//
//***                                                                  						***//
//*** Objetivo  : Monta a tela B - Filtro Valores devido com a B3		                    ***//
//***                                                                  						***//
//*** Alterações: 																			***//
//*********************************************************************************************//
?>

<script>
$(document).ready(function() {
  $('#datade', '#frmPesquisa').setMask("INTEGER", "99/99/9999", "");
  $('#datate', '#frmPesquisa').setMask("INTEGER", "99/99/9999", "");
  return false;
});
</script>

<style>
    .selecionada{background-color: #ffbaad !important;}
	#frmPesquisa td label {
		width:100%;
		text-align:right;
	}
</style>

<form id="frmPesquisa" name="frmPesquisa" class="formulario cabecalho" style="border:none;">
    <div id="divConsulta divConsultaFormV" >

        <fieldset>
            <hr width="250px"><br>
            <legend>Par&acirc;metros de Pesquisa</legend>
            <table border="1" width="100%">
				<tr>
					<td>
						<label for="cdcooper">Coop:</label>
					</td>
                    <td>
                        <select tabindex="1" id="cdcooper" name="cdcooper" class="filtrocooperativa campo" style="width:100px;" onchange="atualizaCooperativaSelecionada($(this));">
                            <option value="0">-- Selecione --</option>
                        </select>
                    </td>
					<td>
						<label for="nrdconta">Conta:</label>
					</td>
					<td>
						<input type="text" id="nrdconta" name="nrdconta" class="conta pesquisa campo filtroconta" value="<? echo formataContaDV($_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']); ?>" 
						autocomplete="off" class='campo' onchange="buscaConta();consultaAplicacoes();" readonly="readonly" />			 
					</td>
					<td width="30">
						<a style="margin-top:5px;display:none;" id="brnBuscaConta" href="#" onClick="GerenciaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					</td>
					<td>
						<input name="dtmvtolt" id="dtmvtolt" type="text" value="" autocomplete="off" class='campo' readonly="readonly" />
					</td>
                    <td>
                        <a href="#" class="botao" id="btnTabInvestidor" name="btnTabInvestidor" onClick="mostraTabelaInverstidores(); return false;">Tab. de Investidor</a>
                    </td>
				</tr>
                <tr>
                    <td>
                        <label for="datade"><? echo utf8ToHtml('Data de:') ?></label>
                    </td>
                    <td>
                        <input name="datade" id="datade" type="text" size="10" maxlength = "10" value="" class='campo' />
                    </td>
                    <td>
                        <label for="datate"><? echo utf8ToHtml('Data até:') ?></label>
                    </td>
                    <td>
                        <input name="datate" id="datate" type="text" size="10" maxlength = "10" value="" class='campo' />
                    </td>
                    <td width="30"> &nbsp; </td>
                    <td> &nbsp; </td>
                    <td>
						<a href="#" class="botao" id="btnConsulta" name="btnConsulta" onClick="listaCustoDevido('1'); return false;">Gerar</a>
					</td>
                </tr>
            </table>
        </fieldset>
    </div>

    <br style="clear:both" />

</form>

<div id="divBotoes">
    <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial();return false;">Voltar</a>
    <a href="#" class="botao" id="btVoltarSegGridTelaA" name="btVoltarSegGridTelaA"style="display:none;" onClick="estadoInicialTelaA();return false;">Voltar</a>
	<a href="#" class="botao" id="btnConsulta" name="btnConsulta" onClick="listaCustoDevido('2'); return false;">Consultar</a>
	<a href="#" class="botao" id="btnConsulta" name="btnConsulta" onClick="listaCustoDevido('3'); return false;">Exportar</a>
</div>

<div id="divLogsDeArquivo"></div>
<div id="divRegistrosArquivo"></div>


<script>atualizaCooperativas(1);</script>