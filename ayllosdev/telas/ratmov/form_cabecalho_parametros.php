<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 29/01/2019
 * OBJETIVO     : Cabeçalho para a tela RATMOV filtros pesquisa
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [08/03/2019] - P450 - Inclusão da consulta do parametro se a coopoerativa pode Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 001: [08/05/2019] - P450 - Solicitado para remover da pesquisa os Status "Não enviado", "Em análise" e "Em Contingência" (Luiz Otávio Olinger Momm - AMCOM).
 * 002: [30/05/2019] - P450 - Adicionado acentos nos produtos (Luiz Otávio Olinger Momm - AMCOM).
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// [000]
$permiteAlterarRating = false;
$oXML = new XmlMensageria();
$oXML->add('cooperat', $glbvars["cdcooper"]);

$xmlResult = mensageria($oXML, "TELA_PARRAT", "CONSULTA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$registrosPARRAT = $xmlObj->roottag->tags[0]->tags;
foreach ($registrosPARRAT as $r) {
	if (getByTagName($r->tags, 'pr_inpermite_alterar') == '1') {
		$permiteAlterarRating = true;
	}
}
// [000]

$dataHoje = $glbvars['dtmvtolt'];
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<label for="cddopcao" class="cddopcao"><? echo utf8_decode('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" class="cddopcao">
		<option value="C"><? echo utf8_decode('C - Consultar') ?></option>
		<?php
		// [000]
		if ($permiteAlterarRating) {
		?>
		<option value="A"><? echo utf8_decode('A - Alterar') ?></option>
		<?php
		}
		// [000]
		?>
		<option value="H"><? echo utf8_decode('H - Histórico') ?></option>
	</select>

	<a href="#" class="botao" id="btnOK" name="btnOK" onClick="habilitaFiltros(); return false;" style = "text-align:right;">OK</a>
	<br style="clear:both" />
</form>

<form id="frmFiltros" name="frmFiltros" class="formulario">
<fieldset id="filtros" style="display:none;">
	<legend>Filtros</legend>
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta ?>" />
	<a href="#" id="formPesquisa_btnLupaAssociado"><img src="/imagens/geral/ico_lupa.gif" /></a>

	<label for="nrctro">Contrato:</label>
	<input type="text" id="nrctro" name="nrctro" value="<?php echo $nrctro ?>"/>
	<a href="#" id="formPesquisa_btnLupaContrato"><img src="/imagens/geral/ico_lupa.gif" /></a>

	<label for="nrcpfcgc">CPF/CNPJ:</label>
	<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>
	<a href="#" id="formPesquisa_btnLupaAssociadoCadastro"><img src="/imagens/geral/ico_lupa.gif" /></a>
	<br style="clear:both" />

	<label for="tpprod">Tipo Produto:</label>
		<div class="table_checkbox">
			<div class="row_checkbox">
				<div class="col_checkbox">Emprestimo/Financiamento
					<input type="checkbox" name="tpproduto_emp" id="tpproduto_emp" class="formPesquisa_tpproduto" value="S">
				</div>
				<div class="col_checkbox">Limite Desconto Cheque
					<input type="checkbox" name="tpproduto_che" id="tpproduto_che" class="formPesquisa_tpproduto" value="S">
				</div>
			</div>
			<div class="row_checkbox">
				<div class="col_checkbox"><? echo utf8_decode('Limite Crédito') ?>
					<input type="checkbox" name="tpproduto_cre" id="tpproduto_cre" class="formPesquisa_tpproduto" value="S">
				</div>
				<div class="col_checkbox"><? echo utf8_decode('Limite Desconto Título') ?>
					<input type="checkbox" name="tpproduto_des" id="tpproduto_des" class="formPesquisa_tpproduto" value="S">
				</div>
			</div>
			<div class="row_checkbox">
				<div class="col_checkbox"><? echo utf8_decode('Limite Pré-aprovado') ?>
					<input type="checkbox" name="tpproduto_cpa" id="tpproduto_cpa" class="formPesquisa_tpproduto" value="S">
				</div>
			</div>
		</div>
	<br style="clear:both" />

	<label for="prstatus"><? echo utf8_decode('Status:') ?></label>
	<select id="prstatus" name="prstatus">
		<option value="9"><? echo utf8_decode('Todos') ?></option>
		<option value="2"><? echo utf8_decode('Analisado') ?></option>
		<option value="3"><? echo utf8_decode('Vencido') ?></option>
		<option value="4"><? echo utf8_decode('Efetivado') ?></option>
	</select>
	<br style="clear:both" />

	<label for="fldtinic">Data Contrato Inicial:</label>
	<input type="text" id="fldtinic" name="fldtinic" value="<?php echo $dataHoje; ?>"/>

	<label for="fldtfina">Data Contrato Final:</label>
	<input type="text" id="fldtfina" name="fldtfina" value="<?php echo $dataHoje; ?>"/>
	<br style="clear:both" />

	<div id="contratoLiquidado">
		<input type="checkbox" name="contratoLiquidado" id="contratoLiquidado" value="1"> Contrato Liquidado
	</div>

</fieldset>

<div id="divBotoes" class="divBotoesFiltros" style="text-align:center; margin-bottom: 10px; display: none;">
<a href="#" class="botao" id="btnConsultaPesquisa" name="btnConsultaPesquisa" onClick="return false;" style = "text-align:right;">Consulta</a>
<a href="#" class="botao" id="btnConsultaVoltar" name="btnConsultaVoltar" onClick="return false;" style = "text-align:right;">Voltar</a>
</div>

</form>


<form class="formulario consultaGRID">
	<fieldset id="fsListagem" style="maring-top: 10px; display: none;">
	<legend><? echo utf8_decode('Resultado') ?></legend>
		<div id="conteudoListagem">
			<div id="divConta" style="border-bottom: 1px solid #777; padding-top: 10px;">

				<!-- soma das colunas 867px -->
				<table class="tituloRegistrosGrid">
					<thead>
						<tr>
							<th style="width: 60px;"><? echo utf8_decode('Data') ?></th>
							<th style="width: 40px;"><? echo utf8_decode('Tipo') ?></th>
							<th style="width: 80px;"><? echo utf8_decode('Conta') ?></th>
							<th style="width: 80px;"><? echo utf8_decode('Contrato') ?></th>
							<th style="width: 80px;"><? echo utf8_decode('Valor') ?></th>
							<th style="width: 55px;" title="<? echo utf8_decode('Rating Automático') ?>"><? echo utf8_decode('Rating<br>Auto') ?></th>
							<th style="width: 70px;" title="<? echo utf8_decode('Data Automático') ?>"><? echo utf8_decode('Data<br>Auto') ?></th>
							<th style="width: 55px;" title="<? echo utf8_decode('Rating Efetivado') ?>"><? echo utf8_decode('Rating<br>Efet') ?></th>
							<th style="width: 70px;" title="<? echo utf8_decode('Data Efetivado') ?>"><? echo utf8_decode('Data<br>Efet') ?></th>
							<th style="width: 65px;" title="<? echo utf8_decode('Data Vencimento') ?>"><? echo utf8_decode('Data<br>Vencto') ?></th>
							<th style="width: 55px;"><? echo utf8_decode('Atualizar') ?></th>
							<th style="width: 65px;"><? echo utf8_decode('Rating<br>Novo') ?></th>
							<th style="width: 92px;"><? echo utf8_decode('Status') ?></th>
							<th></th>
						</tr>
				   </thead>
				</table>

				<div class="divRegistrosGrid" id="retornoPesquisaRating">

				</div>

			</div>
			<div id="divPesquisaRodape" class="divPesquisaRodape" style="border: 1px;">
				<table style="width: 100%;">
					<tbody>
					<tr style="height: 18px;">
					<td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 20%;"></td>
					<td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 60%;" id="divRegistrosGridTotal"></td>
					<td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 20%;"></td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</fieldset>
	<div id="divBotoes" class="divBotoesPesquisa" style="text-align:center; margin-bottom: 10px; display: none;">
		<a href="#" class="botao" id="btnVoltarPesquisa" name="btnVoltarPesquisa" onClick="voltarFiltroPesquisa(); return false;" style = "text-align:right;">Voltar</a>
		<a class="botao" id="btnEnviar" name="btnEnviar" onClick="enviarRating();return false;" style = "text-align:right;">Enviar</a>
		<!--
		<a class="botao" id="btnEfetivar" name="btnEfetivar" onClick="efetivarRating(); return false;" style = "text-align:right;">Efetivar</a>
		-->
	</div>
</form>
