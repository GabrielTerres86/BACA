<?php
//*********************************************************************************************//
//*** Fonte: form_o.php                                                						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Tela O - Log das Operações de Custódia Pendentes   						            ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

?>
<style>
	.selecionada{background-color: #ffbaad !important;}
</style>
<form id="frmPesquisa" name="frmPesquisa" class="formulario cabecalho">
	<div id="divConsulta" >
		<fieldset>
		<hr width="250px"><br>
		<legend>Par&acirc;metros de Pesquisa</legend>
			<table border="1">
				<tr>
					<td style="float: right;">
						<label for="cdcooper">Coop:</label>
					</td>
					<td>
						<select id="cdcooper" name="cdcooper" class="filtrocooperativa" style="width:100px;" onchange="atualizaCooperativaSelecionada($(this));">
							<option value="0">Todos</option>
						</select>
					</td>
					<td style="float: right;">
						<label for="nrdconta">Conta:</label>
					</td>
					<td>
						<input type="text" id="nrdconta" name="nrdconta" class="conta pesquisa campo filtroconta" value="<? echo formataContaDV($_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']); ?>" autocomplete="off" class='campo' onchange="buscaConta();consultaAplicacoes();" readonly="readonly" />
			 <!-- <input type="text" id="nrdconta" name="nrdconta" value="<? /*echo formataContaDV($nrdconta);*/ ?>" /> -->
					</td>
					<td>
						<a style="margin-top:5px;display:none;" id="brnBuscaConta" href="#" onClick="GerenciaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					</td>
					<td>
						<input name="dtmvtolt" id="dtmvtolt" type="text" value="" autocomplete="off" class='campo' readonly="readonly" />
					</td>
					<td style="float: right;">
						<label for="cdaplicacao"><? echo utf8ToHtml('Aplicação:') ?></label>
					</td>
					<td>
						<select name="nraplica" class="campo" id="nraplica" style="width:120px;">
							<option value="0">Todos</option>
					</select>
				</td>
					<td>
						<input type="checkbox" name="flgcritic" id="flgcritic" value="">C/ Criticas<br>
					</td>
				</tr>
				<tr>
					<td style="float: right;">
						<label for="datade"><? echo utf8ToHtml('Data de:') ?></label>
					</td>
					<td>
							<input name="datade" id="datade" type="date" value="" autocomplete="off" class='campo' />
					</td>
					<td style="float: right;">
						<label for="datate"><? echo utf8ToHtml('Data até:') ?></label>
					</td>
					<td>
						<input name="datate" id="datate" type="date" value="" autocomplete="off" class='campo' />
					</td>
					<td style="float: right;">
						<label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
					</td>
					<td>
						<input name="nmarquiv" id="nmarquiv" type="text" value="" autocomplete="off" class='campo' />
					</td>
					<td style="float: right;">
						<label for="dscodib3"><? echo utf8ToHtml('Codigo IF:') ?></label>
					</td>
					<td>
						<input name="dscodib3" id="dscodib3" type="text" value="" autocomplete="off" class='campo' />
					</td>
					<td>
						<a href="#" class="botao" id="btnConsulta" name="btnConsulta" onClick="buscaLogOperacoes(); return false;">Consulta</a>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
  <br style="clear:both" />
</form>
<div id="divLogsDeArquivo">

</div>
<div id="divRegistrosArquivo">

</div>
<div id="divBotoes">
	<a href="#" class="botao" id="btReenvio" name="btReenvio" style="display:none;" onClick="reenvioItens(); return false;">Solicitar Re-envio</a>
	<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
</div>
<script>atualizaCooperativas(1);</script>
