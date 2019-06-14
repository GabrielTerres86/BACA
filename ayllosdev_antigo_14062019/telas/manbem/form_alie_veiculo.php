<?
/*!
 * FONTE        : form_veiculo.php
 * CRIAÇÃO      : Maykon D. Granemann (Envolti)
 * DATA CRIAÇÃO : 30/07/2018
 * OBJETIVO     : Formulário da rotina Emprestimos de veiculos
 * ALTERAÇÕES   :
 * --------------
 * 000:
 */

 ?>
 	<script src="../../scripts/jquery.mask.min.js" type="text/javascript"></script>
 	<script src="../../scripts/jquery.maskMoney.js" type="text/javascript"></script>

    <link href="../../css/aditiv_alie_veiculo.css" rel="stylesheet" type="text/css">

	<script type="text/javascript" src="../manbem/scripts/utils.js"></script>
	<script type="text/javascript" src="../manbem/scripts/aliena_veiculo.js"></script>
	<script type="text/javascript" src="../manbem/scripts/servico_fipe.js"></script>
	<script type="text/javascript" src="../manbem/scripts/interveniente.js"></script>

	<form name="frmTipo" id="frmTipo">
		<fieldset>
		<!-- Cabeçalho disponível somente para ADITIV -->
		<? if($glbvars['nmdatela'] == "ADITIV"){ ?>
			<legend>5 - Substituição de Veículo - Alienação</legend>
			<div class="cabecalho">
				<input id="nrctremp" name="nrctremp" type="hidden" value="" />
				<label id="lsbemfin"></label>
				<div id="msgErro">
					<h3 class="erro">* Campos de preenchimento obrigatório!</h3>
				</div>
				<br />
        		<!-- Data do ativo somente para ADITIV -->
				<label for="dtmvtolt"> Dt Inclusão Aditivo :</label>
				<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />
			</div>
			<hr >
		<? } else { ?>
			<div class="cabecalho">
				<input id="nrctremp" name="nrctremp" type="hidden" value="" />
				<label id="lsbemfin"></label>
			</div>
		<? } ?>
			<div class="bloco">
				<div>
					<label for="dscatbem" > Categoria :</label>
					<? echo selectCategoria('dscatbem', getByTagName($dados,'dscatbem')) ?>
				</div>
				<div>
					<label for="dstipbem"> Tipo Veículo :</label>
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
                    <label for="nrmodbem" >Ano Modelo:</label>
					<select name="nrmodbem" id="nrmodbem"></select>
					<input name="nrmodbem" id="nrmodbemC" type="text" hidden="hidden" value="<? echo getByTagName($dados,'nrmodbem')?> <? echo getByTagName($dados,'dstpcomb')?>"/>
					<label for="nranobem" id="lsanobem">Fab:</label>
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
					<label for="dssitgrv"> Situação :</label>
					<input name="dssitgrv" id="dssitgrv" type="text" value="<?echo getByTagName($dados,'dssitgrv') ?>" />					
				</div>
			</div>
 			<div class="bloco">
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
					<label for="nrcpfcgc"> CPF/CNPJ Interv. :</label>
					<input name="nrcpfcgc" id="nrcpfcgc" class="mascara-cpfcnpj" type="text" value="<? echo getCpfCnpj($dados,'nrcpfcgc')?>" maxlength="18" />
				</div>
			</div>
		</fieldset>
	</form>

<script type="text/javascript">
	var glbCdCooper = '<? echo $glbvars["cdcooper"]; ?>';
</script>
