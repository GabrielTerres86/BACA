<? 
/*!
 * FONTE        : pesquisa_aprovadores_resultado.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 25/07/2018
 * OBJETIVO     : Efetuar pesquisa de aprovadores
 * --------------
 * ALTERACOES   :
 * --------------
 *
 */ 

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe a operacao que esta sendo realizada
$cdcooper = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$cdalcada = (!empty($_POST['cdalcada'])) ? $_POST['cdalcada'] : null;
$cdoperad = (!empty($_POST['cdoperad'])) ? $_POST['cdoperad'] : '';
$nmoperad = (!empty($_POST['nmoperad'])) ? $_POST['nmoperad'] : '';

$nriniseq = (!empty($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
$nrregist = (!empty($_POST['nrregist'])) ? $_POST['nrregist'] : 25;

$tagCod = 'cdoperad';
$tagNom = 'nmoperad';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
	exibeErroNew($msgError);
}

// Opcao de Carregamento
if ( $cdalcada == '1' ) {

	$xml = new XmlMensageria();
    $xml->add('nmoperad',$nmoperad);
    $xml->add('nriniseq',$nriniseq);
    $xml->add('nrregist',$nrregist);
	$xml->add('cddopcao','C');

    $xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_OPERADORES_REG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    $qtdoperad = 0;

	validaErro($xmlObj);

	$tagCod = 'cdopereg';

    $qtdoperad = (int) $xmlObj->roottag->attributes["QTREGIST"];

	$registros = $xmlObj->roottag->tags;

} else if ( $cdalcada == '2' || $cdalcada == '3' ) {

	$xml = new XmlMensageria();
	$xml->add('cdcooprt',$cdcooper);
	$xml->add('cdoperad',$cdoperad);
	$xml->add('nmoperad',$nmoperad);
	$xml->add('nriniseq',$nriniseq);
	$xml->add('nrregist',$nrregist);
	$xml->add('cddopcao','C');

	$xmlResult = mensageria($xml, "TELA_CADRES", "BUSCA_OPERADORES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	validaErro($xmlObj);

	$qtdoperad = (int) getByTagName($xmlObj->roottag->tags[1]->tags,'qtoperad');

	$registros = $xmlObj->roottag->tags[0]->tags;

}

function validaErro($xmlObj) {
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
		exibeErroNew($msgErro);exit;
	}
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","'.$msgErro.'","Alerta - Ayllos","desbloqueia()");');
}
?>
<div id="divPesquisaAprovadoresItens" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			$count = count($registros);
			// Caso a pesquisa nao retornou itens, montar uma celula mesclada com a quantidade colunas que seria exibida
			if ( !$count ) { 
				$i = 0;					
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
				?> <tr><td colspan="2" style="font-size:12px; text-align:center;">N&atilde;o existe aprovadores com os dados informados.</td></tr> <?		
			// Caso a pesquisa retornou itens, exibilos em diversas linhas da tabela
			} else {  
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < $count; ++$i) { ?>
					<?
					$cdoperad = getByTagName($registros[$i]->tags,'cdoperad') | getByTagName($registros[$i]->tags,'cdopereg');
					$nmoperad = getByTagName($registros[$i]->tags,'nmoperad');
					$dsemail  = getByTagName($registros[$i]->tags,'dsemail_operador');
					?>
					<tr onClick="PopupAprovadores.onClick_Adicionar('<?php echo $cdalcada; ?>', '<?php echo $cdoperad; ?>', '<?php echo $nmoperad; ?>', '<?php echo $dsemail; ?>', true); return false;">
						<td style="width:151px;font-size:11px">
							<?php echo $cdoperad; ?>
						</td>
						<td style="width:319px;font-size:11px">
							<?php echo $nmoperad; ?>
						</td> 
					</tr> 
				<? } // fecha o loop for		
			} // fecha else ?> 
		</tbody>
	</table>
	<br clear="both" />
</div>

<div id="divPesquisaAprovadoresRodape" class="divPesquisaRodape">
	<table>
		<tr>
			<td>
				<?
					// Se a paginacao nao esta na primeira, exibe botao voltar
					if ($nriniseq > 1) { 
						?> <a onclick="PesquisaAprovadores.onPesquisar('<?php echo $cdalcada; ?>', '', '', <?php echo ($nriniseq - $nrregist); ?>, <?php echo $nrregist; ?>); return false;"><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtdoperad) { echo $qtdoperad; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtdoperad; ?>
			</td>
			<td>
				<?
					// Se a paginacao nao esta na ultima pagina, exibe botao proximo
					if ($qtdoperad > ($nriniseq + $nrregist - 1)) {
						?> <a onclick="PesquisaAprovadores.onPesquisar('<?php echo $cdalcada; ?>', '', '', <?php echo ($nriniseq + $nrregist); ?>, <?php echo $nrregist; ?>); return false;">Pr&oacute;ximo >>></a> <?
					} else { 
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">		
	hideMsgAguardo();
	//bloqueiaFundo($("#divPesquisaAprovadores"));
	exibeRotina($('#divPesquisa'));
</script>