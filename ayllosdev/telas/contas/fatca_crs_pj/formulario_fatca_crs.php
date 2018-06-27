<? 
/*!
 * FONTE        : formulario_fatca_crs.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : 10/04/2018 
 * OBJETIVO     : Rotina para validar/alterar os dados do FATCA/CRS da tela de CONTAS
 * ALTERACOES	: 
 */
?>

<fieldset id="fsetTitular">
	<form name="frmDadosFatcaCrs" id="frmDadosFatcaCrs" class="formulario">

		<input type="hidden" name="inacordo" id="inacordo" value="<? echo getByTagName($dados,'inacordo') ?>">
				
		<label for="inobrigacao_exterior"><? echo utf8ToHtml('Cooperado possui domicílio ou qualquer obrigação fiscal fora do Brasil?') ?></label>
		<select name="inobrigacao_exterior" id="inobrigacao_exterior">
			<option value=""  <?php if (getByTagName($dados,'inobrigacao_exterior') == "")  { echo ' selected'; } ?>></option>
			<option value="S" <?php if (getByTagName($dados,'inobrigacao_exterior') == "S") { echo ' selected'; } ?>>Sim</option>
			<option value="N" <?php if (getByTagName($dados,'inobrigacao_exterior') == "N") { echo ' selected'; } ?>><? echo utf8ToHtml('Não') ?></option>
		</select>

		<label for="insocio_obrigacao"><? echo utf8ToHtml('Possui algum sócio com 10% ou mais de capital e obrigação fiscal fora do Brasil?') ?></label>
		<select name="insocio_obrigacao" id="insocio_obrigacao">
			<option value=""  <?php if (getByTagName($dados,'insocio_obrigacao') == "") { echo ' selected'; } ?>></option>
			<option value="S" <?php if (getByTagName($dados,'insocio_obrigacao') == "S") { echo ' selected'; } ?>>Sim</option>
			<option value="N" <?php if (getByTagName($dados,'insocio_obrigacao') == "N") { echo ' selected'; } ?>><? echo utf8ToHtml('Não') ?></option>
		</select>
		
		<label for="cdpais"><? echo utf8ToHtml('País onde possui domicílio/obrigação fiscal:') ?></label>
		<input name="cdpais" id="cdpais" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspais" id="dspais" type="text" value="<? echo getByTagName($dados,'nmpais') ?>" />

		<label for="nridentificacao">NIF:</label>
		<input name="nridentificacao" id="nridentificacao" type="text" value="<? echo getByTagName($dados,'nridentificacao') ?>" />

		<fieldset id="fsetEndereco">
		
			<legend><?php echo utf8ToHtml('Endereço no Exterior') ?></legend>

			<label for="dscodigo_postal"><?php echo utf8ToHtml('Cd.Postal:') ?></label>
			<input name="dscodigo_postal" id="dscodigo_postal" type="text" value="<?php echo getByTagName($dados,'dscodigo_postal') ?>" />

			<label for="nmlogradouro"><?php echo utf8ToHtml('Rua:') ?></label>
			<input name="nmlogradouro" id="nmlogradouro" type="text" value="<?php echo getByTagName($dados,'nmlogradouro') ?>" />		

			<label for="nrlogradouro"><?php echo utf8ToHtml('Nr.:') ?></label>
			<input name="nrlogradouro" id="nrlogradouro" type="text" value="<?php echo getByTagName($dados,'nrlogradouro') ?>" />
			
			<label for="dscomplemento"><?php echo utf8ToHtml('Compl.:') ?></label>
			<input name="dscomplemento" id="dscomplemento" type="text" value="<?php echo getByTagName($dados,'dscomplemento') ?>" />
			
			<label for="dscidade"><?php echo utf8ToHtml('Cidade:') ?></label>
			<input name="dscidade" id="dscidade" type="text" value="<?php echo getByTagName($dados,'dscidade') ?>"/>

			<label for="dsestado"><?php echo utf8ToHtml('Estado:') ?></label>
			<input name="dsestado" id="dsestado" type="text" value="<?php echo getByTagName($dados,'dsestado') ?>"/>

			<label for="cdpais_exterior"><? echo utf8ToHtml('País do endereço no exterior:') ?></label>
			<input name="cdpais_exterior" id="cdpais_exterior" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais_exterior') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dspais_exterior" id="dspais_exterior" type="text" value="<? echo getByTagName($dados,'nmpais_exterior') ?>" />

		</fieldset>
	</form>

	<div id="divBotoes">
		<? if ( in_array($operacao,array('AC','')) ) { ?>
			<a href="#" class="botao" id="btAlterar" onclick="controlaOperacao('CA'); return false;"><? echo utf8ToHtml('Alterar Conta') ?></a>
		<? } ?>
	</div>

</fieldset>	

<fieldset id="fsetSocios">
	
	<legend><? echo utf8ToHtml('Sócios') ?></legend>
	
	<form class="formulario">
		<div id="divTabelaSocios" class="divRegistros">
			<table>
				<thead>
					<tr><th>Nome</th>
						<th>CPF</th>
						<th>Obr. Fiscal</th>
						<th><? echo utf8ToHtml('País NIF') ?></th>
						<th>NIF</th>
					</tr>			
				</thead>
				<tbody>
					<? foreach( $socios as $socio ) { ?>
						<tr>
							<td>
								<span><? echo getByTagName($socio->tags,'nmpessoa_socio') ?></span>
								<? echo getByTagName($socio->tags,'nmpessoa_socio') ?>
							</td>
							<td>
								<span><? echo getByTagName($socio->tags,'nrcpfcgc_socio') ?></span>
								<? echo getByTagName($socio->tags,'nrcpfcgc_socio') ?>
							</td>
							<td>
								<span><? echo getByTagName($socio->tags,'inobrigacao_exterior') ?></span>
								<? echo getByTagName($socio->tags,'inobrigacao_exterior') ?>
							</td>
							<td>
								<span><? echo getByTagName($socio->tags,'cdpais_nif') ?></span>
								<? echo getByTagName($socio->tags,'cdpais_nif') ?>
							</td>
							<td>
								<span><? echo getByTagName($socio->tags,'nridentificacao') ?></span>
								<? echo getByTagName($socio->tags,'nridentificacao') ?>
							</td>

							<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($socio->tags,'nrcpfcgc_socio') ?>">

						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>
	</form>

	<div id="divBotoes">
		<? if ( in_array($operacao,array('AC','')) ) { ?>
			<a href="#" class="botao" id="btAlterarSocio" onclick="alterarSocioSelecionado(); return false;"><? echo utf8ToHtml('Alterar Sócio') ?></a>
		<? } ?>
	</div>

</fieldset>

<div id="divBotoes">

	<? if ( in_array($operacao,array('AC','')) ) { ?>
		
		<a href="#" class="botao" id="btVoltar" onclick="fechaRotina(divRotina); return false;"><? echo utf8ToHtml('Voltar') ?></a>
		<a href="#" class="botao" id="btContinuar" onclick="controlaContinuar(); return false;"><? echo utf8ToHtml('Continuar') ?></a>
		
	<? } else if ( $operacao == 'CA' ) { ?>
	
		<? if ($flgcadas == 'M' ) { ?>
			<a href="#" class="botao" id="btVoltar" onclick="voltarRotina(); return false;"><? echo utf8ToHtml('Voltar') ?></a>
		<? } else { ?>
			<a href="#" class="botao" id="btVoltar" onclick="controlaOperacao('AC'); return false;"><? echo utf8ToHtml('Cancelar') ?></a>
		<? } ?>

		<a href="#" class="botao" id="btSalvar" onclick="controlaOperacao('AV'); return false;"><? echo utf8ToHtml('Concluir') ?></a>
	<? } ?>
		
</div>