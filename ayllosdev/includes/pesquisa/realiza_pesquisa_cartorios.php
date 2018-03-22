<? 
/*!
 * FONTE        : realiza_pesquisa_cartorios.php
 * CRIA��O      : Helinton Steffens (Supero)
 * DATA CRIA��O : 20/03/2018
 * OBJETIVO     : Efetuar pesquisa de cart�rios de modo gen�rico, para ser utilizada por diversas telas
 */ 
?>

<?	
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");	
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();	
	
	// Verifica se os par�mtros necess�rios foram informados
	if (!isset($_POST["cdpesqui"]) || 
		!isset($_POST["tpdorgan"])) {
		exibirErro('error','Par&acirc;metros incorretos para a pesquisa.','Alerta - Ayllos','bloqueiaFundo($(\'#divPesquisaCartorios\'))',true);
	}	

	
	$cdpesqui = $_POST["cdpesqui"];
	$nmdbusca = $_POST["nmdbusca"];
	$cdcidade = $_POST["cdcidade"];
	$tpdorgan = $_POST["tpdorgan"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$cdcooper = $_POST["cdcooper"];

	// Dados para pagina��o dos cooperados
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist = 50;
	
	if ($cdcooper == null || $cdcooper == 0 || $cdcooper == ''){
		$cdcooper = $glbvars["cdcooper"];
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<nmcartorio>".$nmdbusca."</nmcartorio>";
	$xml .= "		<dscidade>".$cdcidade."</dscidade>";
	$xml .= "		<documento>".$nrcpfcgc."</documento>";
	$xml .= "		<tpdorgan>".$tpdorgan."</tpdorgan>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, 'ZOOM0001', 'BUSCACARTORIOS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPesquisa = getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjPesquisa->roottag->tags[0]->name) && strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo($(\'#divPesquisa\'))');
	
	$pesquisa = ( isset($xmlObjPesquisa->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjPesquisa->roottag->tags : array(); 

	$qtcartorios = $xmlObjPesquisa->roottag->attributes["QTREGIST"];
?>

<div id="divPesquisaCartoriosItens" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			// Caso a pesquisa n�o retornou itens, montar uma c�lula mesclada com a quantidade colunas que seria exibida
			if ( count($pesquisa) == 0 ) { 
				$i = 0;					
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
				?> <tr><td colspan="3" style="font-size:12px; text-align:center;">N&atilde;o existe cart&oacuterios com os dados informados.</td></tr> <?		
			// Caso a pesquisa retornou itens, exib�los em diversas linhas da tabela
			} else {  
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < count($pesquisa); $i++) { ?>				 
					<tr onClick="selecionaCartorio(<? echo "'".getByTagName($pesquisa[$i]->tags[0]->tags,'documento')."'"; ?>); return false;">												
						<td style="width:125px;text-align:center;font-size:11px;">
							<? echo getByTagName($pesquisa[$i]->tags[0]->tags,'documento'); ?>
						</td> 
						<td style="width:350px;font-size:11px;">
							<? echo getByTagName($pesquisa[$i]->tags[0]->tags,'nmcartorio'); ?>
						</td> 
						<td style="width:100px;font-size:11px;">
							<? echo getByTagName($pesquisa[$i]->tags[0]->tags,'dscidade'); ?>
						</td>
					</tr> 
				<? } // fecha o loop for		
			} // fecha else ?> 
		</tbody>
	</table>
	<br clear="both" />
</div>

<div id="divPesquisaCartorioRodape" class="divPesquisaRodape">
	<table>
		<tr>
			<td>
				
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtcartorios) { echo $qtcartorios; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtcartorios; ?>
			</td>
			<td>
							
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">		
	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisaAssociado"));
</script>