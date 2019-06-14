<?php
	/*!
	 * FONTE        : form_origem_motivo.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 11/09/2017
	 * OBJETIVO     : Formulário com informações de Origem e Motivo
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
	
	$xml  = '';
	$xml .= '<Root><Dados></Dados></Root>';
	
	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResult = mensageria($xml, 'TELA_ENVNOT', 'LISTA_ORIGEM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}
	
	$origens = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$qtOrigens = count($origens);
	
?>
	<form class="cabecalho" style="border-top: 0px;">
		<table width="100%">
			<tr>	
				<td>
					<label for="cdorigem_mensagem"><? echo utf8ToHtml('Origem:') ?></label>
					<select id="cdorigem_mensagem" name="cdorigem_mensagem" class="Campo" onchange="setaTipo();" style="width:290px;">
						<?php
							if($qtOrigens > 1){
						?>
								<option value="0" tipo=""> -- SELECIONE --</option>
						<?php
							}
						
							if($qtOrigens > 0){
								for ($y = 0; $y < $qtOrigens; $y++){ 
									echo "<option value='".getByTagName($origens[$y]->tags,'cdorigem_mensagem')."' dstipo='".getByTagName($origens[$y]->tags,'dstipo_mensagem')."' cdtipo='".getByTagName($origens[$y]->tags,'cdtipo_mensagem')."' >".getByTagName($origens[$y]->tags,'dsorigem_mensagem')."</option>";
								}
							}
						?>
					</select>					
					<label for="cdtipo_mensagem" style="padding-left: 5px;"><? echo utf8ToHtml('Tipo:') ?></label>
					<input type="hidden" id="cdtipo_mensagem" name="cdtipo_mensagem" class="Campo" style="width:150px;" readonly="readonly"/>
					<input type="text" id="dstipo_mensagem" name="dstipo_mensagem" class="Campo" style="width:150px;" readonly="readonly"/>
					</br></br>				
					<label for="cdmotivo_mensagem" style="padding-left: 4px;"><? echo utf8ToHtml('Motivo:') ?></label>
					<select id="cdmotivo_mensagem" name="cdmotivo_mensagem" class="Campo" style="width:84%;" disabled onchange="escolheOpcao('AM');"></select>
				</td>
			</tr>
		</table>
	</form>