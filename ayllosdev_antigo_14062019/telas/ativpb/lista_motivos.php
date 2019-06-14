<?php
/*
 * FONTE        : lista_motivos.php
 * CRIAÃ?ÃƒO      : Marcel Kohls (AMCom)
 * DATA CRIAÃ?ÃƒO : 05/04/2018
 * OBJETIVO     : carrega motivos do banco e monta a lista em html
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

  // Montar o xml de Requisicao com os dados da opera??o
  $xml = "";
  $xml .= "<Root>";
  $xml .= " <Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
  $xml .= "		<tipo>".$tipoLista."</tipo>";
  $xml .= " </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TELA_ATIVPB", "ATIVPB_LISTA_MOTIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObjeto = getObjectXML($xmlResult);
  $motivos = $xmlObjeto->roottag->tags[0]->tags;
?>


<?php if ($tipoLista == 'T'): ?>
  <option value="0">Todos</option>
<?php endif; ?>

<?php foreach( $motivos as $motivo ): ?>
  <option value="<?= getByTagName($motivo->tags,'cdmotivo'); ?>"><?= getByTagName($motivo->tags,'dsmotivo'); ?></option>
<?php endforeach; ?>
