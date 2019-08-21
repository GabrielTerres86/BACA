<? 
/*!
 * FONTE        : tela_aprovacao.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 31/07/2018
 * OBJETIVO     : Tela para aprovação, aberta a partir de outras telas
 *
 * ALTERACOES   : 
 *
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


// Recebe a operação que está sendo realizada
$cdcooper  = (!empty($_POST['cdcooper']))  ? $_POST['cdcooper']  : $glbvars['cdcooper'];
$idrecipr  = (!empty($_POST['idrecipr']))  ? $_POST['idrecipr']  : '';
$fnconfirm = (!empty($_POST['fnconfirm'])) ? $_POST['fnconfirm'] : "hideMsgAguardo();fechaRotina($('#telaAprovacao'));estadoInicial();";

if (($msgError = validaPermissao('CADRES','',$cddopcao)) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('cdcooprt',$cdcooper);
$xml->add('idcalculo_reciproci',$idrecipr);

$xmlResult = mensageria($xml, "TELA_CADRES", "BUSCA_ALCADA_APROVACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
	exibeErroNew($msgErro);exit;
}

$registros = $xmlObj->roottag->tags[0]->tags;

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");');
}

$g_cdalcada = 0;
$g_nvopelib = 0;
?>
<input type="hidden" id="cdalcada" value="">
<input type="hidden" id="nvopelib" value="">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center">

			<!-- CABECALHO DO RESULTADO DA CONSULTA -->
			<div id="divCabecalhoAprovacao" class="divCabecalhoPesquisa">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<td width="33%" style="font-size:11px;">Cargo</td>
							<td width="33%" style="font-size:11px;">Situa&ccedil;&atilde;o</td>
							<td width="33%" style="font-size:11px;">&nbsp;</td>
						</tr>
					</thead>
				</table>
			</div>

			<!-- DIV DO RESULTADO DA CONSULTA -->
			<div id="divResultadoAprovacao" class="divResultadoPesquisa" style="height:auto">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tbody>
						<?php
						for ($i = 0, $count = count($registros); $i < $count; ++$i) {
							$cdalcada    = getByTagName($registros[$i]->tags,"cdalcada_aprovacao");
							$dsalcada    = getByTagName($registros[$i]->tags,"dsalcada_aprovacao");
							$dsstatus    = getByTagName($registros[$i]->tags,"dsstatus_aprovacao");
							$idaprovador = getByTagName($registros[$i]->tags,"idaprovador");
							// muda para ficar de acordo com os níveis recebidos na função `pedeSenhaCoordenador`
							$nvopelib    = ($cdalcada == 1 ? 2 : $cdalcada == 2 ? 3 : 1);
						?>
						<tr>
							<td width="33%" style="padding:2px 4px;height:25px;font-size:11px"><?php echo $dsalcada; ?></td>
							<td width="33%" style="padding:2px 4px;height:25px;font-size:11px"><a class="txtNormal" href="#" onclick="return false;" style="font-size:11px"><?php echo $dsstatus ?></a></td>
							<td width="33%" style="padding:2px 4px;height:25px;font-size:11px" align="center"><?php if ($idaprovador && strtoupper($dsstatus) == 'PENDENTE') { ?><button type="button" class="botao" onclick="showConfirmacao('Confirma a aprova&ccedil;&atilde;o do contrato?', 'Confirma&ccedil;&atilde;o - Aimaro', 'aprovarContrato(<?php echo $cdcooper; ?>,<?php echo $cdalcada; ?>,<?php echo $idrecipr; ?>)', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))', 'sim.gif', 'nao.gif');return false;">Aprovar</button><?php } ?>&nbsp;</td>
							<?php
							if ($idaprovador && strtoupper($dsstatus) == 'PENDENTE') {
								$g_cdalcada = $cdalcada;
								$g_nvopelib = $nvopelib;
							}
							?>
						</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>

			<div id="divBotoes" style="margin-bottom: 10px;">
				<a href="#" class="botao" id="btVoltar">Voltar</a>
				<a href="#" class="botao" id="btDetalhes">Detalhes da negocia&ccedil;&atilde;o</a>
			</div>

			<?php
			echo '<script>
					$("#cdalcada").val("'.$g_cdalcada.'");
					$("#nvopelib").val("'.$g_nvopelib.'");
				  </script>';
			?>

		</td>
	</tr>
</table>
<script>
	hideMsgAguardo();
	// exibe tela de aprovação
	$('#telaAprovacao').show().setCenterPosition();

	// bloqueia fundo da div
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	zebradoLinhaTabela($('#divResultadoAprovacao > table > tbody > tr'));

	function aprovarContrato(cdcooper, cdalcada, idrecipr) {
		$.ajax({
			type: "POST",
			dataType: 'html',
			url: UrlSite + "telas/cadres/atualizar_contrato.php",
			data: {
				cddopcao: 'A',
				cdcooper: cdcooper,
				cdalcada: cdalcada,
				idrecipr: idrecipr,
				fnconfirm: "<?php echo $fnconfirm; ?>",
				redirect: "script_ajax" // Tipo de retorno do ajax
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
			},
			beforeSend: function () {
				showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
			},
			success: function (response) {
				eval(response);
				$('#telaAprovacao').html('');
				/*$('#divUsoGenerico').html(response);
				exibeRotina($('#divUsoGenerico'));*/
			}
		});
	}
</script>
