<?php
	/*!
	 * FONTE        : consultar_notificacoes.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 11/09/2017
	 * OBJETIVO     : Formulário com tabela das informações referente a PUSH
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
	
	$xml  = '';
	$xml .= '<Root><Dados></Dados></Root>';
	
	// Enviar XML de ida e receber String XML de resposta
	$xmlResult = mensageria($xml, 'TELA_ENVNOT', 'LISTA_CONSULTA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$qtRegistros = count($registros);
	
?>
<div class="divRegistros">
	<input type="hidden" id="qtdConsultas" name="qtdConsultas" value="<?php echo $qtRegistros; ?>" />
	<table id="tableConsultas" name="tableConsultas">
		<thead>
			<tr>
				<th>T&iacute;tulo</th>
				<th>Data/Hora</th>
				<th>Operador</th>
				<th>Enviados</th>
				<th>Lidos</th>
				<th>Situa&ccedil;&atilde;o</th>
			</tr>
		</thead>
		<tbody>
			<?php
				if($qtRegistros > 0){
					for ($i = 0; $i < $qtRegistros; $i++){ 
			?>
				<tr onclick="carregaConsulta(<?php echo getByTagName($registros[$i]->tags,'CDMENSAGEM'); ?>);">
					<td><?php echo getByTagName($registros[$i]->tags,'DSTITULO_MENSAGEM'); ?></td>
					<td><?php echo getByTagName($registros[$i]->tags,'DHENVIO_MENSAGEM'); ?></td>
					<td><?php echo getByTagName($registros[$i]->tags,'NMOPERAD'); ?></td>
					<td><?php echo getByTagName($registros[$i]->tags,'QTENVIADOS'); ?></td>
					<td><?php echo getByTagName($registros[$i]->tags,'QTLIDOS'); ?></td>
					<td><?php echo getByTagName($registros[$i]->tags,'DSSITUACAO_MENSAGEM'); ?></td>
				</tr>
			<?php	
					}
				}else{
					?>
					<tr>
						<td colspan="6" style="text-align: center;">Nenhum registro encontrado</td>
					</tr>
					<?php
				}
			?>
		</tbody>
	</table>
</div>
<script>	
	tabela();
</script>	