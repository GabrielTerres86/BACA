<?php
/*************************************************************************
	Fonte: form_descontos.php
	Autor: André Clemer - Supero			Ultima atualizacao: --/--/----
	Data : Julho/2018
	
	Objetivo: Listar os contratos de descontos (Reciprocidade)
	
	Alteracoes: 

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
	exit();
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
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN_AND", "CONSULTA_DESCONTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
$convenios = $dados->tags[13]->tags;

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

// Monta o xml para a requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";     
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN_AUG", "BUSCA_VINCULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$vinculacao = getObjectXML($xmlResult);
$vinculacao = $vinculacao->roottag->tags[0];
// Se ocorrer um erro, mostra crítica
if (strtoupper($vinculacao->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $vinculacao->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}
$nmvinculacao = getByTagName($vinculacao->tags, "nmvinculacao");
$idvinculacao = getByTagName($vinculacao->tags, "idvinculacao");

?>
<style>
img,input[type="image"]{outline: none}.inteiro{text-align: left !important}
</style>
<input type="hidden" id="idcalculo_reciproci" value="<?php echo $idcalculo_reciproci ?>" />
<input type="hidden" id="cddopcao" value="<?php echo $cddopcao; ?>" />
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
				?>
				<tr>
					<td width="60%"><?php echo $convenio->tags[0]->cdata, ' - ', $convenio->tags[1]->cdata ?></td>
					<td width="40%">
						<a class="imgEditar" title="Editar Conv&ecirc;nio" onclick="editarConvenio(<?php echo $convenio->tags[0]->cdata ?>); return false;"><img src="<?php echo $UrlImagens; ?>icones/ico_editar.png" style="margin-right:5px;width:14px;margin-top:1px"/></a>
						<a class="imgExcluir" title="Excluir Conv&ecirc;nio" onclick="excluirConvenio(<?php echo $convenio->tags[0]->cdata ?>); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.gif" style="width:15px;margin-top:1px"/></a>
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
<?php if (count($cnv)) { ?>
	descontoConvenios = <?php echo json_encode($aux); ?>;
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
			<span>Qtd</span>
			<input name="qtdboletos_liquidados" id="qtdboletos_liquidados" class="campo inteiro calculo" value="<?php echo $vr_boletos_liquidados; ?>" style="width:153px;text-align:left" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Volume liquida&ccedil;&atilde;o</td>
		<td align="right">
			<span>R$</span>
			<input name="valvolume_liquidacao" id="valvolume_liquidacao" class="campo valor calculo" value="<?php echo $vr_volume_liquidacao; ?>" style="width:153px;" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Floating</td>
		<td align="right">
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
		<td>Aplica&ccedil;&otilde;es</td>
		<td align="right">
			<span>R$</span>
			<input class="campo valor calculo" value="<?php echo $vr_aplicacoes; ?>" id="vlaplicacoes" name="vlaplicacoes" style="width:153px;" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Dep&oacute;sito &agrave; vista</td>
		<td align="right">
			<span>R$</span>
			<input class="campo valor calculo <?php echo (($glbvars["cdcooper"] == 16) ? '' : 'campoTelaSemBorda') ?>" <?php echo (($glbvars["cdcooper"] == 16) ? '' : 'disabled') ?> value="<?php echo $vr_deposito; ?>" id="vldeposito" name="vldeposito" style="width:153px;" />
		</td>
	</tr>
	<tr class="corPar">
		<td>Data fim do contrato</td>
		<td align="right">
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
			<select class="campo" id="debito_reajuste_reciproci" name="debito_reajuste_reciproci" style="width:153px;">
				<option value="1" <?php echo (($vr_flgdebito_reversao == "1" ? 'selected' : ''))?>>Sim</option>
				<option value="0" <?php echo (($vr_flgdebito_reversao == "0" ? 'selected' : ((!$vr_flgdebito_reversao ? 'selected' : ''))))?>>N&atilde;o</option>
			</select>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr class="corPar">
		<td>Desconto concedido COO</td>
		<td align="right">
			<span>%</span>
			<input name="" id="vldescontoconcedido_coo" class="campo campoTelaSemBorda" disabled value="" style="width:153px;" />
		</td>
	</tr>
	<tr class="corImpar">
		<td>Desconto concedido CEE</td>
		<td align="right">
			<span>%</span>
			<input name="" id="vldescontoconcedido_cee" class="campo campoTelaSemBorda" disabled value="" style="width:153px;" />
		</td>
	</tr>
</table>
<fieldset style="border:1px solid #777777; margin:5px 3px 0;padding:3px">
	<legend align="left">Desconto adicional</legend>
	<table width="100%" class="tabelaDesconto">
		<tr class="corPar">
			<td width="60%">Desconto adicional COO</td>
			<td align="right" width="40%">
				<span>%</span>
				<input name="vldesconto_coo_old" id="vldesconto_coo_old" type="hidden" value="<?php echo $vr_vldesconto_adicional_coo; ?>" />
				<input name="vldesconto_coo" id="vldesconto_coo" value="<?php echo $vr_vldesconto_adicional_coo; ?>" class="campo campoTelaSemBorda per" disabled style="width:153px;" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional COO</td>
			<td align="right">
				<input name="dtfimadicional_coo_old" id="dtfimadicional_coo_old" type="hidden" value="" />
				<select name="dtfimadicional_coo" id="dtfimadicional_coo" class="campo campoTelaSemBorda" disabled style="width:153px">
					<option value=""></option>
					<?php foreach($meses as $mes) {
						echo '<option ' . (($vr_idfim_desc_adicional_coo == getByTagName($mes->tags,"cddominio")) ? 'selected' : '') . ' value="' . getByTagName($mes->tags,"cddominio") . '">' . getByTagName($mes->tags,"dscodigo") . '</option>';
					} ?>
				</select>
			</td>
		</tr>
		<tr class="corPar">
			<td>Desconto adicional CEE</td>
			<td align="right">
				<span>%</span>
				<input name="vldesconto_cee_old" id="vldesconto_cee_old" type="hidden" value="<?php echo $vr_vldesconto_adicional_cee; ?>" />
				<input name="vldesconto_cee" id="vldesconto_cee" value="<?php echo $vr_vldesconto_adicional_cee; ?>" class="campo campoTelaSemBorda per" disabled style="width:153px;" />
			</td>
		</tr>
		<tr class="corImpar">
			<td>Data fim desc. Adicional CEE</td>
			<td align="right">
				<input name="dtfimadicional_cee_old" id="dtfimadicional_cee_old" type="hidden" value="" />
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
			<td>Tarifa negociada COO</td>
			<td align="center">
				<a href="#" class="botao" onclick="acessaTarifa(0); return false;">Visualizar</a>
			</td>
		</tr>
		<tr class="corPar">
			<td>Tarifa negociada CEE</td>
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
				<textarea name="txtjustificativa" id="txtjustificativa" class="textarea campoTelaSemBorda" disabled style="width: 100%;min-height: 70px;"><?php echo $vr_dsjustificativa_desc_adic; ?></textarea>
			</td>
		</tr>
	</table>
</fieldset>


<div id="divBotoes" style="margin:5px">
    <a href="#" id="btnContinuar" class="botao">Continuar</a>
	<?php if ($insitceb == 3 && $cddopcao != 'C') { ?>
    <a href="#" id="btnAbrirAprovacao" class="botao" onclick="abrirAprovacao(true)">Aprovar</a>
	<?php } ?>
    <a href="#" id="btnAprovacao" class="botao">Solicitar aprova&ccedil;&atilde;o</a>
    <a href="#" class="botao" onclick="consulta('A','','',true,'','', 1);return false;">Tarifas instru&ccedil;&atilde;o</a>
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

validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
validaEmiteExpede(false);
<?php if ($cddopcao != 'I') { echo 'calcula_desconto();'; } ?>

cDataFimContrato.change(function (){
	validaHabilitacaoCamposBtn('<?php echo $cddopcao; ?>');
});

$('#vldesconto_cee, #vldesconto_coo, #txtjustificativa').bind('blur', function (){
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


$("input.calculo").blur(function() {
  calcula_desconto();
});


$("select.calculo").change(function() {
  calcula_desconto();
});


</script>
