<?php
/*************************************************************************
	Fonte: form_descontos.php
	Autor: André Clemer - Supero			Ultima atualizacao: --/--/----
	Data : Julho/2018
	
	Objetivo: Listar os contratos de descontos (Reciprocidade)
	
	Alteracoes: 18/12/2018 - Correção caracteres de justificativa
	                         (Andre Clemer - Supero)
*************************************************************************/

session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	
		
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Ayllos","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))");';
	echo '</script>';
	//exit();
}

function getArrayByTagName( $xml, $tagName ) {
	$resultado = "";
	if ( $xml != ''){
		foreach( $xml as $tag ) {
			if ( strtoupper($tag->name) == strtoupper($tagName) ) {
				$resultado = $tag;
				break;
			}
		}
	}
	return $resultado->tags;
}

$idcalculo_reciproci = (!empty($_POST['idcalculo_reciproci'])) ? $_POST['idcalculo_reciproci'] : '';
$cdcooper            = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$cddopcao            = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
$nrdconta            = (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : $glbvars['nrdconta'];

// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <idcalculo_reciproci>".$idcalculo_reciproci."</idcalculo_reciproci>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "CONSULTA_DESCONTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$dados = $xmlObj->roottag;

$vr_boletos_liquidados = getByTagName($dados->tags,"vr_boletos_liquidados");
$vr_volume_liquidacao  = getByTagName($dados->tags,"vr_volume_liquidacao");
$vr_flgdebito_reversao = getByTagName($dados->tags,"vr_flgdebito_reversao");
$vr_qtdfloat           = getByTagName($dados->tags,"vr_qtdfloat");
$vr_dtfimcontrato      = getByTagName($dados->tags,"vr_dtfimcontrato");
$vr_aplicacoes         = getByTagName($dados->tags,"vr_aplicacoes");
$vr_deposito           = getByTagName($dados->tags,"vr_vldeposito");
$vr_vldesconto_adicional_coo = getByTagName($dados->tags,"vr_vldesconto_adicional_coo");
$vr_idfim_desc_adicional_coo = getByTagName($dados->tags,"vr_idfim_desc_adicional_coo");
$vr_vldesconto_adicional_cee = getByTagName($dados->tags,"vr_vldesconto_adicional_cee");
$vr_idfim_desc_adicional_cee = getByTagName($dados->tags,"vr_idfim_desc_adicional_cee");
$vr_dsjustificativa_desc_adic = getByTagName($dados->tags,"vr_dsjustificativa_desc_adic");
$insitceb = getByTagName($dados->tags,"insitceb");
$idvinculacao = getByTagName($dados->tags,"idvinculacao");
$nmvinculacao = getByTagName($dados->tags,"nmvinculacao");
if (!isset($idvinculacao)) {
	$idvinculacao = 0;
}
$vldesconto_concedido_coo = getByTagName($dados->tags,"vldesconto_concedido_coo");
$vldesconto_concedido_cee = getByTagName($dados->tags,"vldesconto_concedido_cee");
$qtdaprov = getByTagName($dados->tags,"qtdaprov");
$insitapr = getByTagName($dados->tags,"insitapr");

$nrconven = 0;
$convenios = getArrayByTagName($dados->tags,"convenios");
if (count($convenios)) {
	$nrconven = $convenios[0]->tags[0]->cdata;
}

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_CATEGORIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlSubGru = $xmlObject->roottag->tags[0]->tags;

$perdescontos = array();
foreach ($xmlSubGru as $sgr) {
	foreach ($sgr->tags as $cat) {
		if (getByTagName($cat->tags,'PERDESCONTO') != "" && getByTagName($cat->tags,'PERDESCONTO') != "0") {
			$perdescontos[] = getByTagName($cat->tags,'CDCATEGO') . "#" . getByTagName($cat->tags,'PERDESCONTO');
		}
	}
}

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}


// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>TPMESES_RECIPRO</nmdominio>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_DOMINIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$meses = $xmlObj->roottag->tags[0]->tags;

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}


// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>TPFLOATING_RECIPR</nmdominio>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_DOMINIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$floats = $xmlObj->roottag->tags[0]->tags;

function sortByCddominio($a, $b) {
    return getByTagName($a->tags,"cddominio") - getByTagName($b->tags,"cddominio");
}

usort($floats, 'sortByCddominio');
usort($meses,  'sortByCddominio');

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}

// Só iremos consultar a vinculação atual se ainda não soubermos a atual ou se for consulta
if ($cddopcao != 'C' || $idvinculacao == 0 || empty($nmvinculacao)) {
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";     
	$xml .= "</Root>";
	$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_VINCULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$vinculacao = getObjectXML($xmlResult);
	$vinculacao = $vinculacao->roottag->tags[0];
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($vinculacao->name) == "ERRO") {
		$msgErro = $vinculacao->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	$nmvinculacao = getByTagName($vinculacao->tags, "nmvinculacao");
	$idvinculacao = getByTagName($vinculacao->tags, "idvinculacao");
}

if ($cddopcao == 'I') {
	// Monta o xml de requisição
	$xmlGetDadosAtenda = "";
	$xmlGetDadosAtenda .= "<Root>";	
	$xmlGetDadosAtenda .= "	<Dados>";
	$xmlGetDadosAtenda .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlGetDadosAtenda .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosAtenda .= "		<nrdctitg></nrdctitg>";
	$xmlGetDadosAtenda .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
	$xmlGetDadosAtenda .= "		<dtmvtopr>" . $glbvars["dtmvtopr"] . "</dtmvtopr>";
	$xmlGetDadosAtenda .= "		<dtmvtoan>" . $glbvars["dtmvtoan"] . "</dtmvtoan>";
	$xmlGetDadosAtenda .= "		<dtiniper>" . date("d/m/Y") . "</dtiniper>";
	$xmlGetDadosAtenda .= "		<dtfimper>" . date("d/m/Y") . "</dtfimper>";
	$xmlGetDadosAtenda .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
	$xmlGetDadosAtenda .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
	$xmlGetDadosAtenda .= "		<inproces>" . $glbvars["inproces"] . "</inproces>";
	$xmlGetDadosAtenda .= "		<flgerlog>N</flgerlog>";
	$xmlGetDadosAtenda .= "	</Dados>";
	$xmlGetDadosAtenda .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xmlGetDadosAtenda, "ATENDA", "CARREGA_DADOS_ATENDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosAtenda = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica	
	if (strtoupper($xmlObjDadosAtenda->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosAtenda->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$valores = ( isset($xmlObjDadosAtenda->roottag->tags[2]->tags[0]->tags) ) ? $xmlObjDadosAtenda->roottag->tags[2]->tags[0]->tags : null;
	$vr_deposito = ( isset($valores[5]->cdata) ) ? number_format(str_replace(",", ".", $valores[5]->cdata), 2, ",", ".") : '';
	$vr_aplicacoes = ( isset($valores[2]->cdata) ) ? number_format(str_replace(",", ".", $valores[2]->cdata), 2, ",", ".") : '';
	if ($vr_deposito < 0) {
		$vr_deposito = number_format(str_replace(",", ".", 0), 2, ",", ".");
	}

}

?>
<style>
img,input[type="image"]{outline: none}.inteiro{text-align: left !important}
</style>
<input type="hidden" id="idcalculo_reciproci" value="<?php echo $idcalculo_reciproci ?>" />
<input type="hidden" id="cddopcao" value="<?php echo $cddopcao; ?>" />
<input type="hidden" id="qtdaprov" value="<?php echo $qtdaprov; ?>" />
<input type="hidden" id="insitapr" value="<?php echo $insitapr; ?>" />
<input type="hidden" id="imgEditar" value="<?php echo $UrlImagens; ?>icones/ico_editar.png" />
<input type="hidden" id="imgExcluir" value="<?php echo $UrlImagens; ?>geral/excluir.gif" />
<div align="center">
	<a href="#" class="botao" style="float:none; padding: 3px 6px; margin: 15px 0" id="btnConveniosCobranca" onClick="descontoConvenio('A','1'); return false;">Conv&ecirc;nios de Cobran&ccedil;a</a>
</div>
<div id="divConveniosRegistros">
	<div class="divRegistros">
		<table id="gridDescontoConvenios" style="table-layout: fixed;">
			<thead>
				<tr><th>Conv&ecirc;nio</th>
					<th>&nbsp;</th>
				</tr>
			</thead>
			<tbody>
				<?php
				$cnv = array();
				
				foreach($convenios as $convenio) {
					foreach($convenio->tags as $key => $value) {
						$cnv[strtolower($value->name)] = $value->cdata;
					}
					$aux[] = $cnv;

					// quantidade de boletos emitidos
					$cnv_qtbolcob = (int) getByTagName($convenio->tags, 'qtbolcob');
					$cnv_insitceb = (int) getByTagName($convenio->tags, 'insitceb');
					$cnv_nrconven = (int) getByTagName($convenio->tags, 'convenio');
					$cnv_tipoconv = getByTagName($convenio->tags, 'tipo');
					
					$title = 'Excluir Conv&ecirc;nio';
					$fnc = 'excluirConvenio('.$cnv_nrconven.', true);';
					$img = $UrlImagens.'geral/excluir.gif';

					if ($cnv_insitceb === 1 && $cnv_qtbolcob > 0) {
						$title = 'Inativar Conv&ecirc;nio';
						$fnc = 'inativarConvenio('.$cnv_nrconven.',true);return false;';
					} elseif ($cnv_insitceb === 2) {
						$title = 'Ativar Conv&ecirc;nio';
						$fnc = 'ativarConvenio('.$cnv_nrconven.',true);return false;';
						$img = $UrlImagens.'geral/btn_excluir.gif';
					}
				?>
				<tr id="convenio_<?php echo $cnv_nrconven; ?>">
					<td width="330"><?php echo $cnv_nrconven, ' - ', $cnv_tipoconv; ?></td>
					<td>
						<a class="imgEditar" title="Editar Conv&ecirc;nio" onclick="editarConvenio(<?php echo $cnv_nrconven; ?>); return false;"><img src="<?php echo $UrlImagens; ?>icones/ico_editar.png" style="margin-right:5px;width:14px;margin-top:1px"/></a>
						<a class="imgExcluir" title="<?php echo $title; ?>" onclick="<?php echo $fnc; ?>"><img src="<?php echo $img; ?>" style="width:15px;margin-top:1px"/></a>
					</td>
				</tr>
				<?php
				}
				?>
			</tbody>
		</table>
	</div>
</div>
<script>
descontoConvenios = [];
perdescontos = [];
atualizacaoDesconto = false;
<?php if (count($aux)) { ?>
	descontoConvenios = <?php echo json_encode($aux); ?>;
<?php }?>
<?php if (count($perdescontos)) { ?>
	perdescontos = <?php echo json_encode($perdescontos); ?>;
<?php }?>
</script>
<table width="100%" class="tabelaDesconto">
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr class="corPar">
		<td width="60%">Boletos liquidados</td>
		<td align="right" width="40%">
			<input type="hidden" id="qtdboletos_liquidados_old" value="<?php echo $vr_boletos_liquidados; ?>">
			<span>Qtd</span>
			<input name="qtdboletos_liquidados" id="qtdboletos_liquidados" class="campo inteiro calculo" value="<?php echo $vr_boletos_liquidados; ?>" style="width:153px;text-align:left" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Volume liquida&ccedil;&atilde;o</td>
		<td align="right">
			<input type="hidden" id="valvolume_liquidacao_old" value="<?php echo $vr_volume_liquidacao; ?>">
			<span>R$</span>
			<input name="valvolume_liquidacao" id="valvolume_liquidacao" class="campo valor calculo" value="<?php echo $vr_volume_liquidacao; ?>" style="width:153px;" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Floating</td>
		<td align="right">
			<input type="hidden" id="qtdfloat_old" value="<?php echo $vr_qtdfloat; ?>">
			<select class="campo calculo" style="width:153px" id="qtdfloat" name="qtdfloat">
			<?php foreach($floats as $float) {
				echo '<option ' . (($vr_qtdfloat == getByTagName($float->tags,"dscodigo")) ? 'selected' : '') . ' value="' . getByTagName($float->tags,"cddominio") . '">' . getByTagName($float->tags,"dscodigo") . '</option>';
			} ?>
			</select>
		</td>
	</tr>
	<tr class="corImpar">
		<td>Vincula&ccedil;&atilde;o</td>
		<td align="right">
			<input name="nmvinculacao" id="nmvinculacao" type="text" class="campo campoTelaSemBorda" disabled value="<? echo $nmvinculacao; ?>" style="width:153px;" />
			<input name="idvinculacao" id="idvinculacao" type="hidden" value="<? echo $idvinculacao; ?>" style="width:153px;" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Investimentos</td>
		<td align="right">
			<input type="hidden" id="vlaplicacoes_old" value="<?php echo $vr_aplicacoes; ?>">
			<span>R$</span>
			<input class="campo valor calculo" value="<?php echo $vr_aplicacoes; ?>" id="vlaplicacoes" name="vlaplicacoes" style="width:153px;" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Dep&oacute;sito &agrave; vista</td>
		<td align="right">
			<input type="hidden" id="vldeposito_old" value="<?php echo $vr_deposito; ?>">
			<span>R$</span>
			<input class="campo valor calculo" value="<?php echo $vr_deposito; ?>" id="vldeposito" name="vldeposito" style="width:153px;" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Data fim do contrato (meses)</td>
		<td align="right">
			<input type="hidden" id="dtfimcontrato_old" value="<?php echo $vr_dtfimcontrato; ?>">
			<select class="campo" style="width:153px" name="dtfimcontrato" id="dtfimcontrato">
			<option value=""></option>
			<?php foreach($meses as $mes) {
				echo '<option ' . (($vr_dtfimcontrato == getByTagName($mes->tags,"cddominio")) ? 'selected' : '') . ' value="' . getByTagName($mes->tags,"cddominio") . '">' . getByTagName($mes->tags,"dscodigo") . '</option>';
			} ?>
			</select>
		</td>
	</tr>
	<tr class="corImpar">
		<td>D&eacute;bito reajuste da tarifa</td>
		<td align="right">
			<input type="hidden" id="debito_reajuste_reciproci_old" value="<?php echo $vr_flgdebito_reversao; ?>">
			<select class="campo" id="debito_reajuste_reciproci" name="debito_reajuste_reciproci" style="width:153px;">
				<option value="1" <?php echo (($vr_flgdebito_reversao == "1" ? 'selected' : ''))?>>Sim</option>
				<option value="0" <?php echo (($vr_flgdebito_reversao == "0" ? 'selected' : (!$vr_flgdebito_reversao ? 'selected' : '') ))?>>N&atilde;o</option>
			</select>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr class="corPar">
		<td>Desconto concedido <span title="Cooperado Emite e Expede" class="hint">COO</span></td>
		<td align="right">
			<span>%</span>
			<input name="" id="vldescontoconcedido_coo" value="<?php echo $vldesconto_concedido_coo; ?>" class="campo campoTelaSemBorda" disabled value="" style="width:153px;" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Desconto concedido <span title="Cooperativa Emite e Expede" class="hint">CEE</span></td>
		<td align="right">
			<span>%</span>
			<input name="" id="vldescontoconcedido_cee" value="<?php echo $vldesconto_concedido_cee; ?>" class="campo campoTelaSemBorda" disabled value="" style="width:153px;" />
		</td>
	</tr>
</table>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Desconto adicional</legend>
	<table width="100%" class="tabelaDesconto">
		<tr class="corPar">
			<td width="60%">Desconto adicional <span title="Cooperado Emite e Expede" class="hint">COO</span></td>
			<td align="right" width="40%">
				<span>%</span>
				<input name="vldesconto_coo_old" id="vldesconto_coo_old" type="hidden" value="<?php echo $vr_vldesconto_adicional_coo; ?>" />
				<input name="vldesconto_coo" id="vldesconto_coo" value="<?php echo $vr_vldesconto_adicional_coo; ?>" class="campo campoTelaSemBorda per" disabled style="width:153px;" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional <span title="Cooperado Emite e Expede" class="hint">COO</span> (meses)</td>
			<td align="right">
				<input name="dtfimadicional_coo_old" id="dtfimadicional_coo_old" type="hidden" value="<?php echo $vr_idfim_desc_adicional_coo; ?>" />
				<select name="dtfimadicional_coo" id="dtfimadicional_coo" class="campo campoTelaSemBorda" disabled style="width:153px">
					<option value=""></option>
					<?php foreach($meses as $mes) {
						echo '<option ' . (($vr_idfim_desc_adicional_coo == getByTagName($mes->tags,"cddominio")) ? 'selected' : '') . ' value="' . getByTagName($mes->tags,"cddominio") . '">' . getByTagName($mes->tags,"dscodigo") . '</option>';
					} ?>
				</select>
			</td>
		</tr>
		<tr class="corPar">
			<td>Desconto adicional <span title="Cooperativa Emite e Expede" class="hint">CEE</span></td>
			<td align="right">
				<span>%</span>
				<input name="vldesconto_cee_old" id="vldesconto_cee_old" type="hidden" value="<?php echo $vr_vldesconto_adicional_cee; ?>" />
				<input name="vldesconto_cee" id="vldesconto_cee" value="<?php echo $vr_vldesconto_adicional_cee; ?>" class="campo campoTelaSemBorda per" disabled style="width:153px;" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional <span title="Cooperativa Emite e Expede" class="hint">CEE</span> (meses)</td>
			<td align="right">
				<input name="dtfimadicional_cee_old" id="dtfimadicional_cee_old" type="hidden" value="<?php echo $vr_idfim_desc_adicional_cee; ?>" />
				<select name="dtfimadicional_cee" id="dtfimadicional_cee" class="campo campoTelaSemBorda" disabled style="width:153px">
					<option value=""></option>
					<?php foreach($meses as $mes) {
						echo '<option ' . (($vr_idfim_desc_adicional_cee == getByTagName($mes->tags,"cddominio")) ? 'selected' : '') . ' value="' . getByTagName($mes->tags,"cddominio") . '">' . getByTagName($mes->tags,"dscodigo") . '</option>';
					} ?>
				</select>
			</td>
		</tr>
		<tr class="corPar">
			<td width="60%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr class="corImpar">
			<td>Tarifa negociada <span title="Cooperado Emite e Expede" class="hint">COO</span></td>
			<td align="center">
				<a href="#" class="botao" onclick="acessaTarifa(0); return false;">Visualizar</a>
			</td>
		</tr>
		<tr class="corPar">
			<td>Tarifa negociada <span title="Cooperativa Emite e Expede" class="hint">CEE</span></td>
			<td align="center">
				<a href="#" class="botao" onclick="acessaTarifa(1); return false;">Visualizar</a>
			</td>
		</tr>
	</table>
</fieldset>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Justificativa desconto adicional:</legend>
	<table width="100%" class="tabelaDesconto">
		<tr class="corPar">
			<td>
				<textarea name="txtjustificativa_old" id="txtjustificativa_old" style="display:none"><?php echo utf8_decode($vr_dsjustificativa_desc_adic); ?></textarea>
				<textarea name="txtjustificativa" id="txtjustificativa" class="textarea campoTelaSemBorda" disabled onchange="validaDados(true); return false;" style="width: 100%;min-height: 70px;"><?php echo utf8_decode($vr_dsjustificativa_desc_adic); ?></textarea>
			</td>
		</tr>
	</table>
</fieldset>


<div id="divBotoes" style="margin:5px">
    <a href="#" id="btnContinuar" class="botao">Continuar</a>
	<?php
	// Em aprovação e não existe aprovação do "meu" usuario (insitapr)
	if ($insitceb == 3 && !$insitapr) {
	?>
    <a href="#" id="btnAbrirAprovacao" class="botao" onclick="abrirAprovacao(true)">Aprovar</a>
	<a href="#" id="btnAbrirRejeicao" class="botao" onclick="abrirRejeicao()">Rejeitar</a>
	<?php
	}
	?>
    <a href="#" id="btnAprovacao" class="botao">Solicitar aprova&ccedil;&atilde;o</a>
    <a href="#" class="botao" onclick="consulta('<?php echo $cddopcao; ?>','','','<?php echo $cddopcao == 'C' || $cddopcao == 'A' ? 'false' : 'true'; ?>','','', 1);return false;">Tarifas instru&ccedil;&atilde;o</a>
	<a href="#" id="btVoltar" class="botao" onclick="acessaOpcaoContratos(); return false;">Voltar</a>
</div>

<script type="text/javascript">
cDataFimContrato = $('#dtfimcontrato', '.tabelaDesconto');
idcalculo_reciproci = $('#idcalculo_reciproci', '#divConteudoOpcao').val();
cVldesconto_cee = $('#vldesconto_cee', '.tabelaDesconto');
cVldesconto_coo = $('#vldesconto_coo', '.tabelaDesconto');
cDataFimAdicionalCee = $('#dtfimadicional_cee', '.tabelaDesconto');
cDataFimAdicionalCoo = $('#dtfimadicional_coo', '.tabelaDesconto');
cJustificativaDesc = $('#txtjustificativa', '.tabelaDesconto');
// cDebitoReajusteReciproci = $('#debito_reajuste_reciproci', '.tabelaDesconto');

validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
validaEmiteExpede(false);
<?php if ($cddopcao != 'I' && $cddopcao != 'C') { echo 'calcula_desconto();'; } ?>

cDataFimContrato.change(function (){
	validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
});


// cDebitoReajusteReciproci.change(function(){
//	validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
//});

$('#vldesconto_cee, #vldesconto_coo, #txtjustificativa').bind('keyup', function (){
	validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
});

$('#dtfimadicional_cee, #dtfimadicional_coo').bind('change', function (){
	validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
});


controlaLayout('divConveniosRegistros');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Se a tela foi chamada pela rotina "Produtos" então acessa a opção "Habilitar".
(executandoProdutos == true) ? consulta('S','','',true,'','') : '';

$('.valor').setMask('DECIMAL', 'zzz.zzz.zzz.zzz.zz9,99', '.', '');
$('.inteiro').setMask('DECIMAL', 'z.zzz.zzz.zzz.zzz', '.', '');
$('.per').setMask('DECIMAL','zz0,00',',','');

$('.imgEditar').tooltip();	
$('.imgExcluir').tooltip();
$('.hint').tooltip();


$("input.calculo").blur(function() {
  calcula_desconto();
});


$("select.calculo").change(function() {
  calcula_desconto();
});


</script>
