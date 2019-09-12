<? 
/*!
 * FONTE        : realiza_pesquisa_associados_dados_cadastrais.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMCOM
 * DATA CRIAÇÃO : 30/01/2019
 * OBJETIVO     : Efetuar pesquisa de associados pelo nome ou CPFCGC apenas
 * --------------
 * ALTERAÇÕES   :
 * 001: [06/02/2019] Luiz Otávio Olinegr Momm (AMCOM): Retirada uma validação de CPFCGC pois é um campo inteiro e não char e a validação
                                                       considerava 11 caracteres ou 14 carateres e o zero a esquerda não é informado
                                                       usado
 * --------------
 */

session_start();
require_once("../config.php");
require_once("../funcoes.php");
require_once("../controla_secao.php");
require_once("../../class/xmlfile.php");
isPostMethod();

// Verifica se os parâmtros necessários foram informados
if (!isset($_POST["nmdbusca"]) || !isset($_POST["nrcpfcgc"])) {
	exibirErro('error','Par&acirc;metros incorretos para a pesquisa.','Alerta - Ayllos','hideMsgAguardo(); bloqueiaFundo($(\'#divConsultaAssociadoDadosCadastrais\'))',true);
}

$nrcpfcgc = $_POST["nrcpfcgc"];
$nmdbusca = $_POST["nmdbusca"];
$cdcooper = $glbvars["cdcooper"];

// Verifica se foi informado um nome maior que três caracteres
if (strlen($nmdbusca) < 3 && strlen($nrcpfcgc) == 0) {
	exibirErro('error','Nome de pesquisa deve ser maior.','Alerta - Ayllos','hideMsgAguardo(); bloqueiaFundo($(\'#divConsultaAssociadoDadosCadastrais\'))',true);
}





// Monta o xml de de pesquisa de associado pelo nome ou cpfcgc
$xmlSetPesquisa  = "";
$xmlSetPesquisa .= "<Root>";
$xmlSetPesquisa .= "	<Dados>";
$xmlSetPesquisa .= "		<nmprimtl>".$nmdbusca."</nmprimtl>";
$xmlSetPesquisa .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
$xmlSetPesquisa .= "	</Dados>";
$xmlSetPesquisa .= "</Root>";

$xmlResult = mensageria($xmlSetPesquisa, "TELA_RATMOV", "RATMOV_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$xmlObjPesquisa = getObjectXML($xmlResult);

// Cria objeto para classe de tratamento de XML
$xmlObjPesquisa = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
$msgErro = '';
$pesquisa = array();
if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
	// exibirErro('error',utf8_encode($xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','hideMsgAguardo(); bloqueiaFundo($(\'#divConsultaAssociadoDadosCadastrais\'))');
} else {
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags;
}
// print_r($pesquisa->attributes["tags"]);

// Quantidade total de cooperados na pesquisa
// $qtcopera = $xmlObjPesquisa->roottag->tags[0]->attributes["QTCOPERA"]; 
?>

<div id="divPesquisaAssociadoItensDadosCadastrais" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			// Caso a pesquisa não retornou itens, montar uma célula mesclada com a quantidade colunas que seria exibida
			if ( count($pesquisa) == 0 ) {
				$i = 0;
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
			?>
				<tr><td colspan="2" style="font-size:12px; text-align:center;">N&atilde;o existe associado com os dados informados.</td></tr>
			<?
			// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
			} else {
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < count($pesquisa); $i++) {
			?>
					<tr onClick="selecionaAssociadoDadosCadastrais(<? echo "'".getByTagName($pesquisa[$i]->tags,'PR_NRCPFCGC')."'"; ?>); return false;">
						<td style="width:110px; font-size:11px;">
							<? echo getByTagName($pesquisa[$i]->tags,'PR_NRCPFCGC'); ?>
						</td>
						<td style="width:300px;font-size:11px;">
							<? echo getByTagName($pesquisa[$i]->tags,'PR_NMPRIMTL'); ?>
						</td>
					</tr> 
				<? } // fecha o loop for
			} // fecha else 
			?> 
		</tbody>
	</table>
	<br clear="both" />
</div>

<script type="text/javascript">
	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisaAssociadoDadosCadastrais"));
</script>