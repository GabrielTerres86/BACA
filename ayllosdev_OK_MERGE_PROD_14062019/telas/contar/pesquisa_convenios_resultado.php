<? 
/*!
 * FONTE        : pesquisa_convenios_resultado.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 01/11/2018
 * OBJETIVO     : Efetuar pesquisa de convenios
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
$nrconven    = (!empty($_POST['nrconven'])) ? $_POST['nrconven'] : null;
$flgativo    = ($_POST['flgativo'] === '1' ? 1 : (($_POST['flgativo'] === '0') ? 0 : null));
$ls_nrconven = (!empty($_POST['ls_nrconven'])) ? $_POST['ls_nrconven'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('nrconven',$nrconven);
$xml->add('flgativo',$flgativo);
$xml->add('ls_nrconven',$ls_nrconven);

$xmlResult = mensageria($xml, "TELA_CONTAR", "CONSULTA_CONVENIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
	exibeErroNew($msgErro);exit;
}

$registros = $xmlObj->roottag->tags;

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","'.$msgErro.'","Alerta - Ayllos","desbloqueia()");');
}
?>
<div id="divPesquisaConveniosItens" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			$count = count($registros);

			// Caso a pesquisa nao retornou itens, montar uma celula mesclada com a quantidade colunas que seria exibida
			if ( !$count ) { 
				$i = 0;					
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
				?> <tr><td colspan="2" style="font-size:12px; text-align:center;">N&atilde;o existem conv&ecirc;nios com os dados informados.</td></tr> <?		
			// Caso a pesquisa retornou itens, exibilos em diversas linhas da tabela
			} else {  
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < $count; ++$i) { ?>
					<?
					$nrconven = getByTagName($registros[$i]->tags,'nrconven');
					$dsorgarq = getByTagName($registros[$i]->tags,'dsorgarq');
					$flgativo = getByTagName($registros[$i]->tags,'flgativo');
					?>
					<tr onClick="popup.onClick_Selecionar('C', '<?php echo $nrconven; ?>'); return false;">
						<td style="width:151px;font-size:11px">
							<?php echo $nrconven; ?>
						</td>
						<td style="width:319px;font-size:11px">
							<?php echo $dsorgarq; ?>
						</td>
						<td style="width:219px;font-size:11px">
							<?php echo ( ( $flgativo ) ? 'Ativo' : 'Inativo' ); ?>
						</td>
					</tr> 
				<? } // fecha o loop for		
			} // fecha else ?> 
		</tbody>
	</table>
</div>

<script type="text/javascript">		
	hideMsgAguardo();
	bloqueiaFundo($('#divRotina'));
</script>