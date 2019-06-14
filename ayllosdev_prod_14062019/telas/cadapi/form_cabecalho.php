<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 05/02/2019
 * OBJETIVO     : Cabeçalho para a tela CADAPI
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>0</cdcooper>";
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;

function exibeErroNew($msgErro) {
    echo '<script>hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Aimaro","desbloqueia()");</script>';
    exit;
}
?>
<div id="divCab">
	<form id="frmCab" name="frmCab" class="formulario cabecalho">
		<input type="hidden" id="glbcdcooper" name="glbcdcooper" value="<? echo $glbvars["cdcooper"] ?>">
		<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>">
		<table width="100%">
			<tr>
				<td>
					<label for="cddopcao" class="rotulo" style="width: 115px">Op&ccedil;&atilde;o:</label>
					<select id="cddopcao" class="campo" name="cddopcao" style="width: 470px;">
					<? // if  ( $glbvars["cdcooper"] == 3 ) { ?>
					<option value="C"> C - Consultar Finalidade </option> 
					<option value="F"> F - Cadastrar Finalidade </option> 
					<option value="E"> E - Excluir Finalidade </option> 
					<? // } ?>
					</select>
					<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style="text-align:right;">OK</a>
				</td>
			</tr>
		</table>
	</form>
	<form id="frmCadapi" name="frmCadapi" class="formulario" style="display:none;">
		<table width="100%">
			<tr>
				<td>
					<fieldset style="margin:0">
						<legend>Produto</legend>
						<label for="cdproduto" class="rotulo" style="width: 112px">Produto:</label>
						<select id="cdproduto" class="campo" name="cdproduto" style="width: 470px;" onchange="onChangeServico();">
						<?php
						$xml = new XmlMensageria();
						$xml->add('dsproduto','');
						
						$xmlResult = mensageria($xml, "TELA_CADAPI", "CONSULTA_PRODUTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
						$xmlObj = getObjectXML($xmlResult);
						
						if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
							$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
							exibeErroNew($msgErro);exit;
						}

						$registros = $xmlObj->roottag->tags[0]->tags;

						
						foreach ($registros as $r) {
							$cdproduto = getByTagName($r->tags,"cdproduto");
							$dsproduto = getByTagName($r->tags,"dsproduto");
						?>
						<option value="<?php echo $cdproduto; ?>"><?php echo $cdproduto, ' - ', $dsproduto; ?></option> 
						<? } ?>
						</select>
						<a href="#" class="botao" id="btnOK" name="btnOK" onClick="form.onClick_ProsseguirServico();return false;" style="text-align:right;">OK</a>
					</fieldset>
				</td>
			</tr>
		</table>

		<div id="divBotoes" style="margin-bottom: 10px;">
			<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>
			<a href="#" class="botao" id="btProsseguir" onClick="form.onClick_ProsseguirServico();">Prosseguir</a>
		</div>

		<br style="clear:both" />
		
	</form>
	
	<form id="frmCadServico" name="frmCadServico" class="formulario" style="display:none;">
		<table width="100%">
			<tr>
				<td>
					<fieldset style="margin:0">
						<legend><? echo utf8ToHtml('Serviço API');?></legend>
						<label for="servico_api" class="rotulo" style="width: 112px"><? echo utf8ToHtml('Serviço API:');?></label>
						<select id="servico_api" class="campo" name="servico_api" style="width: 470px;"></select>
						<a href="#" class="botao" id="btnOK" name="btnOK" onClick="form.onClick_Prosseguir();return false;" style="text-align:right;">OK</a>
					</fieldset>
				</td>
			</tr>
		</table>

		<div id="divBotoes" style="margin-bottom: 10px;">
			<a href="#" class="botao" id="btVoltar" onClick="LiberaCampos(); return false;">Voltar</a>
			<a href="#" class="botao" id="btProsseguir" onClick="form.onClick_Prosseguir();">Prosseguir</a>
		</div>

		<br style="clear:both" />
		
	</form>
</div>
<?
	$registros = $xmlObj->roottag->tags[0];
	$count = 0;
	$array = array();
	foreach ($registros as $r) {

		foreach ($registros->tags[$count]->tags as $s){

			$_idservico = trim(getByTagName($s->tags,"idservico_api"));
			$_dsservico = utf8_encode(getByTagName($s->tags,"dsservico_api"));
			$_cdproduto = trim(getByTagName($s->tags,"cdproduto"));

			if (!$_idservico) { continue; }

			$array[$_cdproduto][count($array[$_cdproduto])] = array("idservico" => $_idservico, "dsservico" => $_dsservico);
		}
		$count++;
	} 
	$explode = json_encode($array);
?>
<script type="text/javascript">
	var jsonServicos = <? echo $explode; ?>;
	
	function onChangeServico(){
		var produtoSelecionado = $('#cdproduto option:selected').val();
		
		$('#servico_api').html("");
		
		for(var i = 0;i < jsonServicos[produtoSelecionado].length;i++){
			$('#servico_api').append('<option value="'+jsonServicos[produtoSelecionado][i].idservico+'">'+jsonServicos[produtoSelecionado][i].dsservico+'</option>');
		}
		
		$('#servico_api option[value="<? echo $idservico_api; ?>"]').attr('selected', 'selected');
	}
	onChangeServico();
</script>