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
	 
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>0</cdcooper>";
    $xml .= "   <flgativo>1</flgativo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }
?>

<div id="divQuebraSigilo" name="divQuebraSigilo">
	<form id="frmQuebraSigilo" name="frmQuebraSigilo" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fsqbrsig" style="display: none">
		<legend><? echo utf8ToHtml("Quebra de sigilo banc&aacute;rio") ?></legend>

		<label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="nmrescop" name="nmrescop">
		<?php
		foreach ($registros as $r) {
			if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
		?>
			<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"
					<?  if (getByTagName($r->tags, 'cdcooper')== $glbvars['cdcooper']){ echo ' selected';} ?> > <?= getByTagName($r->tags, 'nmrescop'); ?></option> 
		<?php
			}
		}
		?>
		</select>

		<label for="nrdconta"><? echo utf8ToHtml("Conta:") ?></label>
		<input name="nrdconta" type="text"  id="nrdconta" class="campo" style="width: 50px;">

		<a href="#" onclick="qbrsigMostraPesquisaAssociado(); return false;">
			<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0">
		</a>

		<label for="nrcpfcgc"><? echo utf8ToHtml("CPF:") ?></label>
		<input name="nrcpfcgc" type="text"  id="nrcpfcgc" class="campo" style="width: 50px;">

		<br style="clear:both" />

		<label for="nmprimtl"><? echo utf8ToHtml("Nome:") ?></label>
		<input name="nmprimtl" type="text"  id="nmprimtl" class="campo" style="width: 50px;">

		<br style="clear:both" />

		<label for="dtiniper"><? echo utf8ToHtml("Dt Inicial:") ?></label>
		<input name="dtiniper" type="text"  id="dtiniper" class="campo" style="width: 50px;">

		<label for="dtfimper"><? echo utf8ToHtml("Dt Final:") ?></label>
		<input name="dtfimper" type="text"  id="dtfimper" class="campo" style="width: 50px;">
		
		<label for="btnIncluirConta"><? echo utf8ToHtml("") ?></label>
		<a href="#" class="botao" id="btnIncluirConta" name="btnIncluirConta" style = "text-align:center;" onclick="incluirConta(); return false;"><? 
			                   echo utf8ToHtml("Incluir Conta");?></a>

		<br style="clear:both" />

		<div id="tabQbrsigcontas">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbQbrsigcontas">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Conta");?></th>
							<th><? echo utf8ToHtml("Data Inicial");?></th>
							<th><? echo utf8ToHtml("Data Final");?></th>
							<th><? echo utf8ToHtml("Exclus&atilde;o");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>

		<br style="clear:both" />

		<fieldset>
		<legend><? echo utf8ToHtml("Quebra") ?></legend>
		<label for="nrseq_quebra_sigilo"><? echo utf8ToHtml("Seq Quebra:") ?></label>
		<input name="nrseq_quebra_sigilo" type="text"  id="nrseq_quebra_sigilo" class="inteiro campo" style="width: 50px;">

		<label for="filtro_idsitqbr"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
		<select id="filtro_idsitqbr" name="filtro_idsitqbr">
			<option value="0"><? echo utf8ToHtml('0-Todos') ?></option>
			<option value="1"><? echo utf8ToHtml('1-Informa&ccedil;&otilde;es encontradas') ?></option>
			<option value="2"><? echo utf8ToHtml('2-Informa&ccedil;&otilde;es encontradas em regra n&atilde;o parametrizada') ?></option>
			<option value="3"><? echo utf8ToHtml('3-DOC - Informa&ccedil;&otilde;es devem ser informadas manualmente') ?></option>
			<option value="4"><? echo utf8ToHtml('4-Informa&ccedil;&otilde;es n&atilde;o encontradas') ?></option>
			<option value="5"><? echo utf8ToHtml('5-Lan&ccedil;amentos inclu&iacute;dos para busca no ICFJUD') ?></option>
			<option value="6"><? echo utf8ToHtml('6-Atualizados manualmente') ?></option>
			<option value="7"><? echo utf8ToHtml('7-Erro na busca das informa&ccedil;&otilde;es') ?></option>
			<option value="8"><? echo utf8ToHtml('8-Parametrizacao Ailos x Receita inexistente') ?></option>
		</select>
		</fieldset>
		<br style="clear:both" />

		<div id="tabQbrsig">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbQbrsig">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Data");?></th>
							<th><? echo utf8ToHtml("Hist&oacute;rico");?></th>
							<th><? echo utf8ToHtml("Valor");?></th>
							<th><? echo utf8ToHtml("Situa&ccedil;&atilde;o");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
		<div id="divPesquisaRodape" class="divPesquisaRodape">
		    <table>
				<tr>
					<td><a href="#" onClick="consultaQuebra('CQQ','ANTERIOR');return false;"><< Anterior</a></td>
					<td><a href="#" id="txtPaginacao" onClick="return false;"></a></td>
					<td><a href="#" onClick="consultaQuebra('CQQ','PROXIMO');return false;">Pr&oacute;ximo >></a></td>					
				</tr>
			</table>
		</div>
		
		<br style="clear:both" />
		
		<fieldset>
		<legend><? echo utf8ToHtml("Complemento") ?></legend>
		
		<label for="compldsobsqbr"><? echo utf8ToHtml("Observa&ccedil;&atilde;o:") ?></label>
		<input name="dsobsqbr" type="text"  id="compldsobsqbr" class="campo" style="width: 500px;">

		<br style="clear:both" />
		
		<label for="complnrdocmto"><? echo utf8ToHtml("Documento:") ?></label>
		<input name="nrdocmto" type="text"  id="complnrdocmto" class="campo" style="width: 140px;">

		<label for="complcdbandep"><? echo utf8ToHtml("Banco:") ?></label>
		<input name="cdbandep" type="text"  id="complcdbandep" class="campo" style="width: 50px;">
		<input name="nmextbcc" type="text"  id="complnmextbcc" class="campo" style="width: 250px;">
		
		<br style="clear:both" />
		
		<label for="complcdagedep"><? echo utf8ToHtml("Agencia:") ?></label>
		<input name="cdagedep" type="text"  id="complcdagedep" class="campo" style="width: 50px;">
		
		<label for="complnrctadep"><? echo utf8ToHtml("Conta:") ?></label>
		<input name="nrctadep" type="text"  id="complnrctadep" class="campo" style="width: 50px;">

		<br style="clear:both" />
		
		<label for="complnrcpfcgc"><? echo utf8ToHtml("CPF/CNPJ:") ?></label>
		<input name="nrcpfcgc" type="text"  id="complnrcpfcgc" class="campo" style="width: 50px;">
		
		<label for="complnmprimtl"><? echo utf8ToHtml("Nome:") ?></label>
		<input name="nmprimtl" type="text"  id="complnmprimtl" class="campo" style="width: 250px;">

		<input name="nrseqlcm" type="text"  id="complnrseqlcm" class="campo" style="display:none;">
		
		<br style="clear:both" />
		</fieldset>
		
		</fieldset>	
	</form>
</div>