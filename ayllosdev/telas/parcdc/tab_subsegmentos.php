<? 
	/*!
	 * FONTE        : tab_subsegmentos.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 07/12/2017
	 * OBJETIVO     : Tabela de exibição de subsegmentos
	 * --------------
	 * ALTERAÇÕES   :
	 * -------------- 
	 */
  
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cdsegmento = (isset($_POST['cdsegmento'])) ? $_POST['cdsegmento'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
    $nmrotina = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'], $nmrotina, 'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "  <cddopcao>C</cddopcao>";
	$xml .= "  <cdsegmento>".$cdsegmento."</cdsegmento>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_SUBSEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}
		
	$subsegmentos = $xmlObjeto->roottag->tags[2]->tags;

?>

<fieldset>
    <br/>
	<legend align="center">Lista de Subsegmentos</legend>
	<div class="divRegistros" id="divSubsegmentos">		
		<table class="tituloRegistros" id="tableSubsegmento" name="tableSubsegmento">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('C&oacute;digo'); ?></th>
					<th><?php echo utf8ToHtml('Subsegmento'); ?></th>
					<th><?php echo utf8ToHtml('Parcela M&aacute;xima'); ?></th>
					<th><?php echo utf8ToHtml('Valor M&aacute;ximo'); ?></th>																	
					<th><?php echo utf8ToHtml('Car&ecirc;ncia'); ?></th>																	
				</tr>
				</tr>
			</thead>
			<tbody>		
				<?php
					if(count($subsegmentos) > 0){
						foreach($subsegmentos as $subsegmento){
				?>
							<tr>
								<td><?php echo getByTagName($subsegmento->tags, 'CDSUBSEGMENTO'); ?></td>
								<td><?php echo getByTagName($subsegmento->tags, 'DSSUBSEGMENTO'); ?></td>
								<td><?php echo str_replace('.',',', getByTagName($subsegmento->tags, 'NRMAX_PARCELA')); ?></td>
                <td><?php echo str_replace('.',',', getByTagName($subsegmento->tags, 'VLMAX_FINANC')); ?></td>
                <td><?php echo str_replace('.',',', getByTagName($subsegmento->tags, 'NRCARENCIA')); ?></td>
                <input type="hidden" id="cdsubsegmento" value="<?php echo getByTagName($subsegmento->tags, 'CDSUBSEGMENTO'); ?>"/>
							</tr>                                             
				<?php
						}
					}else{
				?>
						<tr>
							<td colspan="2">
								<b>N&atilde;o h&aacute; registros de subsegmentos cadastrados</b>
							</td>
							</td>
						</tr>
				<?php
					}
				?>
			</tbody>
		</table>
	</div>
</fieldset>
<script>
  formataTabelaSubsegmento();	
</script>