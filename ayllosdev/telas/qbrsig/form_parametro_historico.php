<?php
	/*!
	 * FONTE        : form_parametro_historico.php
	 * CRIAÇÃO      : Heitor - Mouts
	 * DATA CRIAÇÃO : 07/12/2018
	 * OBJETIVO     : Cadastro de parametros para a tela QBRSIG
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
	 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
    $xml .= "  </Dados>";
	$xml .= "</Root>";

    $xmlResult = mensageria($xml, "QBRSIG", "QBRSIG_CON_REGRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
    $xmlObjeto = simplexml_load_string($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Aimaro","",false);
	}

?>
<div id="divParametroHistorico" name="divParametroHistorico">
	<form id="frmParametroHistorico" name="frmParametroHistorico" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fsparhis" style="display: none">
		<legend>Historicos x Regras de quebra de sigilo</legend>
		
		<label for="cdhistor"><? echo utf8ToHtml("Hist&oacute;rico:") ?></label>
		<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 50px;">

		<label for="dsexthst"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:") ?></label>
		<input name="dsexthst" type="text"  id="dsexthst" class="campo" style="width: 300px;">

		<br style="clear:both" />
		
		<label for="cdhisrec"><? echo utf8ToHtml("Hist&oacute;rico Receita:") ?></label>
		<input name="cdhisrec" type="text"  id="cdhisrec" class="inteiro campo" style="width: 50px;">

		<label for="cdestsig"><? echo utf8ToHtml('Regra:') ?></label>
		<select id="cdestsig" name="cdestsig">
		<option value="0">
		</option>

		<?php
		foreach ($xmlObjeto->estsig as $estsig) {
		?>
			<option value="<?= $estsig->cdestsig ?>">
			<?= $estsig->nmestsig ?>
			</option>
		<?php
		}
		?>
		</select>
		
		<a href="#" class="botao" id="btnSalvar" name="btnSalvar" style = "text-align:right;" onclick="salvarHistorico(); return false;"><? 
			                   echo utf8ToHtml("Salvar");?></a>

		<br style="clear:both" />

		<div id="tabParhis">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbParhis">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo Hist&oacute;rico");?></th>
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o Hist&oacute;rico");?></th>
							<th><? echo utf8ToHtml("His. Receita");?></th>
							<th><? echo utf8ToHtml("Regra Quebra Sigilo");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
		</fieldset>
	</form>
</div>