<? 
/*!
 * FONTE        : pesquisa_linhas_resultado.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 01/11/2018
 * OBJETIVO     : Efetuar pesquisa de linhas de credito
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
$cdlcremp    = (!empty($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : null;
$flgativo    = (!empty($_POST['flgativo'])) ? $_POST['flgativo'] : null;
$ls_cdlcremp = (!empty($_POST['ls_cdlcremp'])) ? $_POST['ls_cdlcremp'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('cdlcremp',$cdlcremp);
$xml->add('ls_cdlcremp',$ls_cdlcremp);

$xmlResult = mensageria($xml, "TELA_CONTAR", "CONSULTA_CREDITOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
<div id="divPesquisaPopupItens" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			$count = count($registros);

			// Caso a pesquisa nao retornou itens, montar uma celula mesclada com a quantidade colunas que seria exibida
			if ( !$count ) { 
				$i = 0;					
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
				?> <tr><td colspan="2" style="font-size:12px; text-align:center;">N&atilde;o existem linhas de cr&eacute;dito com os dados informados.</td></tr> <?		
			// Caso a pesquisa retornou itens, exibilos em diversas linhas da tabela
			} else {  
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < $count; ++$i) { ?>
					<?
					$cdlcremp = getByTagName($registros[$i]->tags,'cdlcremp');
					$dslcremp = getByTagName($registros[$i]->tags,'dslcremp');
					?>
					<tr onClick="popup.onClick_Selecionar('L', '<?php echo $cdlcremp; ?>'); return false;">
						<td style="width:151px;font-size:11px">
							<?php echo $cdlcremp; ?>
						</td>
						<td style="width:319px;font-size:11px">
							<?php echo $dslcremp; ?>
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