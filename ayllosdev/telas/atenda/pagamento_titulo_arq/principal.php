<?php
/*************************************************************************
	Fonte: principal.php
	Autor: Andre Santos - SUPERO
	Data : Setembro/2014            Ultima atualizacao:  /  /

	Objetivo: Listar os Pagtos de Titulos por Arquivos.

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

// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];

// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");

setVarSession("opcoesTela",$opcoesTela);

// Monta o xml para a requisicao
$xmlGetDadosTitulos  = "";
$xmlGetDadosTitulos .= "<Root>";
$xmlGetDadosTitulos .= " <Cabecalho>";
$xmlGetDadosTitulos .= "   <Bo>b1wgen0192.p</Bo>";
$xmlGetDadosTitulos .= "   <Proc>verif-aceite-conven</Proc>";
$xmlGetDadosTitulos .= " </Cabecalho>";
$xmlGetDadosTitulos .= " <Dados>";
$xmlGetDadosTitulos .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlGetDadosTitulos .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosTitulos .= " </Dados>";
$xmlGetDadosTitulos .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosTitulos);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosTitulos = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosTitulos->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosTitulos->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

// Seta a tag de arquivos para a variavel
$arquivos = $xmlObjDadosTitulos->roottag->tags[0]->tags;

$dscritic = $xmlObjDadosTitulos->roottag->tags[0]->attributes["DSCRITIC"];
$flconven = $xmlObjDadosTitulos->roottag->tags[0]->attributes["FLCONVEN"];

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}

?>
<div id="divResultado">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Conv&ecirc;nio</th>
					<th>Data Adesao</th>
					<th>Operador</th>
					<th>Situacao</th>
					<th>Origem</th>
				</tr>
			</thead>
			<tbody>
				<?  for ($i = 0; $i < count($arquivos); $i++) {

					   $nrconven =  getByTagName($arquivos[$i]->tags,'nrconven');
					   $dtcadast =  getByTagName($arquivos[$i]->tags,'dtdadesa');
					   $cdoperad =  getByTagName($arquivos[$i]->tags,'cdoperad');
					   $flgativo =  getByTagName($arquivos[$i]->tags,'flgativo');
					   $dsorigem =  getByTagName($arquivos[$i]->tags,'dsorigem');

					   $mtdClick = "selecionaConvenio( '".$i."', '".$nrconven."','".$dtcadast."','".$cdoperad."','".$flgativo."','".$dsorigem."');";
				?>
					<tr id="convenio<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">

						<td><span><? echo $nrconven;?></span>
							<?php echo formataNumericos("zz.zzz.zz9",$nrconven,'.');  ?> </td>

						<td> <?php echo $dtcadast; ?> </td>

						<td> <?php echo $cdoperad; ?> </td>

						<td> <?php echo $flgativo ?> </td>

						<td> <?php echo $dsorigem ?> </td>

				    </tr>
				<?} // Fim do for ?>
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes">
	<input type="hidden" id= "nrconven"    name="nrconven">
	<input type="hidden" id= "dtcadast"    name="dtcadast">
	<input type="hidden" id= "cdoperad"    name="cdoperad">
	<input type="hidden" id= "flgativo"    name="flgativo">
	<input type="hidden" id= "dsorigem"    name="dsorigem">
	
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelamento.gif" <? if (in_array("X",$glbvars["opcoesTela"]) && $flconven == 1) { ?> onClick="confirmaExclusao();return false;" <? } else { ?> style="cursor: default;" <? } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" <? if (in_array("I",$glbvars["opcoesTela"])) { ?> onClick="acessaImpressaoTermo();return false;" <? } else { ?> style="cursor: default;" <? } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/habilitar.gif" <? if (in_array("H",$glbvars["opcoesTela"]) && $flconven == 0) { ?> onClick="confirmaInclusao();return false;" <? } else { ?> style="cursor: default;" <? } ?> />
</div>

<script type="text/javascript">
controlaLayout('divResultado');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>

