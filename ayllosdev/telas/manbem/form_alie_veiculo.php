<?
/*!
 * FONTE        : form_veiculo.php
 * CRIA��O      : Maykon D. Granemann (Envolti)
 * DATA CRIA��O : 30/07/2018
 * OBJETIVO     : Formul�rio da rotina Emprestimos de veiculos
 * ALTERA��ES   :
 * --------------
 * 001 [29/10/2018] - Adicionado campos para adapta��o ao layout pedido MAQUINA E EQUIPAMENTO - Bruno Luiz Katzjarowski - Mout's
 */

 ?>
 	<script src="../../scripts/jquery.mask.min.js" type="text/javascript"></script>
 	<script src="../../scripts/jquery.maskMoney.js" type="text/javascript"></script>

    <link href="../manbem/css/alie_veiculo.css" rel="stylesheet" type="text/css">
	<link href="../manbem/css/maquinaEquipamento.css?x=<?php echo rand(1,123123);  ?>" rel="stylesheet" type="text/css"/> <!-- PRJ - 438 - Bruno -->

	<script type="text/javascript" src="../manbem/scripts/utils.js"></script>
	<script type="text/javascript" src="../manbem/scripts/aliena_veiculo.js"></script>
	<script type="text/javascript" src="../manbem/scripts/servico_fipe.js"></script>
	<script type="text/javascript" src="../manbem/scripts/interveniente.js"></script>

	<form name="frmTipo" id="frmTipo">
		<fieldset>
		<!-- Cabe�alho dispon�vel somente para ADITIV -->
		<? if($glbvars['nmdatela'] == "ADITIV"){ ?>
			<legend style='margin-left: 42%;'>5 - Substitui��o de Ve�culo - Aliena��o</legend>
			<div class="cabecalho">
				<input id="nrctremp" name="nrctremp" type="hidden" value="" />
				<label id="lsbemfin"></label>
				<div id="msgErro">
					<h3 class="erro">* Campos de preenchimento obrigat�rio!</h3>
				</div>
				<br />
        		<!-- Data do ativo somente para ADITIV -->
				<label for="dtmvtolt"> Dt Inclus�o Aditivo :</label>
				<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />
			</div>
			<hr >
		<? } else { ?>
			<legend style='margin-left: 42%;'>Dados da Aliena&ccedil;&atilde;o</legend>
			<div class="cabecalho">
				<input id="nrctremp" name="nrctremp" type="hidden" value="" />
				<input id="idseqbem" name="idseqbem" type="hidden" value="<? echo getByTagName($dados,'idseqbem')?>" />
				<label id="lsbemfin"></label>
			</div>
		<? } ?>
			<div class="bloco">
				<!-- CATEGORIA -->
				<div>
					<label for="dscatbem" > Categoria :</label>
					<? echo selectCategoria('dscatbem', getByTagName($dados,'dscatbem')) ?>
				</div>

				<!-- PRJ - 438 - Bruno -->
				<div class='fieldMaquinaEquipamento' style='display: none;'>
					<!-- DESCRICAO -->
				<div>
						<label for="dsmarceq"> Descri��o:</label>
						<input name="dsmarceq" id="dsmarceq" type="text" value="<? echo getByTagName($dados,'dsmarceq')?>" />
					</div>
					<!-- MARCA -->
					<div>
						<label for="dsmarbemE"> Marca:</label>
						<input name="dsmarbemE" id="dsmarbemE" type="text" value="<? echo getByTagName($dados,'dsmarbem')?>" />

						<!-- VALOR DE MERCADO -->
						<label for="vlrdobemE"> Valor de Mercado :</label>
						<input name="vlrdobemE" id="vlrdobemE" type="text" class='moeda'  value="<? echo getByTagName($dados,'vlrdobem') ?>" 
						data-prefix="R$ " data-thousands="." data-decimal=","/>
					</div>
					<!-- MODELO -->
					<div>
						<label for="dsbemfinE"> Modelo:</label>
						<input name="dsbemfinE" id="dsbemfinE" type="text" value="<? echo getByTagName($dados,'dsbemfin')?>" />

						<!-- NR. SERIE -->
						<label for="dschassiE"> Nr. S�rie:</label>
						<input name="dschassiE" id="dschassiE" type="text" value="<? echo getByTagName($dados,'dschassi')?>" />
					</div>
					<!-- NOTA FISCAL -->
					<div>
						<label for="nrnotanf"> Nota Fiscal:</label>
						<input name="nrnotanf" id="nrnotanf" type="text" value="<? echo getByTagName($dados,'nrnotanf')?>" />
					</div>
					<!-- ANO FABRICACAO -->
					<div>
	                    <label for="nrmodbemE" >Ano Fabrica��o:</label>
	                    <input name="nrmodbemE" id="nrmodbemE" type="text" class='inteiro' value="<? echo getByTagName($dados,'nrmodbem')?>"/>

	                    <!-- CPF/CNPJ do INTERVENIENTE -->
	                    <label for="nrcpfcgcE"> CPF/CNPJ do Interveniente:</label>
						<input name="nrcpfcgcE" id="nrcpfcgcE" class="mascara-cpfcnpj" type="text" value="<? echo getCpfCnpj($dados,'nrcpfcgc')?>" maxlength="18" />
	                </div>
				</div>

				<!-- PRJ - 438 - Bruno -->
				<div class='fieldVeiculos'>
					<div>
					<label for="dstipbem"> Tipo Ve�culo :</label>
					<? echo selectTipoVeiculo('dstipbem', getByTagName($dados,'dstipbem')) ?>
					<input type="checkbox" id="dssemfip" name="dssemfip" value="scales" />
					<label for="dssemfip" id="lbsemfip">Sem Fipe</label>
				</div>
				<div>
					<label for="dsmarbem"> Marca :</label>
					<select name="dsmarbem" id="dsmarbem"></select>
						<input name="dsmarbem" id="dsmarbemC" type="text" hidden="hidden" value="<? echo getByTagName($dados,'dsmarbem')?>" />
				</div>
				<div>
					<label for="dsbemfin"> Modelo :</label>
					<select name="dsbemfin" id="dsbemfin"></select>
					<input name="dsbemfin" id="dsbemfinC" type="text" hidden="hidden" value="<? echo getByTagName($dados,'dsbemfin') ?>" />
				</div>
				<div>
					<label for="nranobem" > Ano Fabrica��o :</label>
						<input name="nranobem" id="nranobem" type="text" value="<? echo getByTagName($dados,'nranobem')?>" class="menor" onkeypress="return VerificaNumero(event)" maxlength="4" />
                    <label for="nrmodbem" id="lsanobem">Mod:</label>
					<select name="nrmodbem" id="nrmodbem"></select>
					<input name="nrmodbem" id="nrmodbemC" type="text" hidden="hidden" value="<? echo getByTagName($dados,'nrmodbem')?> <? echo getByTagName($dados,'dstpcomb')?>"/>
						<label for="nranobem" style='display:none'>Ano Fab.:</label>
						<input name="nranobem" id="nranobem" type="text" value="<? echo getByTagName($dados,'nranobem')?>" class="menor" onkeypress="return VerificaNumero(event)" maxlength="4" />
				</div>
				<div>
					<label for="vlfipbem"> Valor Fipe :</label>
					<input name="vlfipbem" id="vlfipbem" type="text" class="currency" value="<? echo getByTagName($dados,'vlfipbem') ?>" readonly data-prefix="R$ " data-thousands="." data-decimal=","/>
				</div>
				<div>
					<label for="vlrdobem"> Valor de Mercado :</label>
					<input name="vlrdobem" id="vlrdobem" type="text"  value="<? echo getByTagName($dados,'vlrdobem') ?>" readonly data-prefix="R$ " data-thousands="." data-decimal=","/>
				</div>
				<div>
					<label for="dssitgrv"> Situa��o :</label>
					<input name="dssitgrv" id="dssitgrv" type="text" value="<?echo getByTagName($dados,'dssitgrv') ?>" />					
				</div>
			</div>
			</div>

			<!-- PRJ - 438 - Bruno -->
 			<div class="bloco fieldVeiculos">
				<div>
					<label for="tpchassi"> Tipo Chassi :</label>
					<? echo selectTipoChassi('tpchassi', getByTagName($dados,'tpchassi')) ?>
				</div>
				<div>
					<label for="dschassi"> Chassi/N.Serie :</label>
					<input name="dschassi" id="dschassi" type="text" value="<? echo getByTagName($dados,'dschassi')?>" />
				</div>
				<div>
					<label for="dscorbem"> Cor/Classe :</label>
					<input name="dscorbem" id="dscorbem" type="text" value="<? echo getByTagName($dados,'dscorbem')?>" />
				</div>
				<div>
					<label for="ufdplaca"> UF/Placa :</label>
					<? echo selectEstado('ufdplaca', getByTagName($dados,'ufdplaca'), 1) ?>
					<label for="nrdplaca" style='display:none'>Placa:</label>
					<input name="nrdplaca" id="nrdplaca" type="text" value="<? echo mascara(getByTagName($dados,'nrdplaca'),'###-####') ?>"/>
				</div>
				<div>
					<label for="nrrenava"> RENAVAM :</label>
					<input name="nrrenava" id="nrrenava" type="text" value="<? echo mascara(getByTagName($dados,'nrrenava'),'###.###.###.###')?>" onkeypress="return VerificaNumero(event)" />
				</div>
				<div>
					<label for="uflicenc"> UF Licenciamento :</label>
					<? echo selectUfPa('uflicenc', getByTagName($dados, 'uflicenc')) ?>
				</div>
				<div>
					<label for="nrcpfcgc"> CPF/CNPJ Interveniente :</label>
					<input name="nrcpfcgc" id="nrcpfcgc" class="mascara-cpfcnpj" type="text" value="<? echo getCpfCnpj($dados,'nrcpfcgc')?>" maxlength="18" />
				</div>
			</div>
		</fieldset>
	</form>

<script type="text/javascript">
	var glbCdCooper = '<? echo $glbvars["cdcooper"]; ?>';
</script>
