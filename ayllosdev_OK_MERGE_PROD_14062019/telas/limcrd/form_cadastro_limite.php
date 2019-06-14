<?php
	/*!
    * FONTE        : form_cadastro_limite.php
	* CRIAÇÃO      : Amasonas Borges Vieira Junior(Supero)
	* DATA CRIAÇÃO : 19/02/2018
	* OBJETIVO     : Formulário para a tela LIMCRD
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

$cddopcao = ((!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'I');

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao, false)) <> '') {
   exibirErro('error',$msgError,'Alerta - Ayllos','',false);
   exit;
}

	require_once('supfn.php');

	$admcrd = intval($_POST['admcrd']);
	$CECRED = (($admcrd > 10) && ($admcrd < 81));

	if($CECRED){
	?>
<table class="tableform hideable" style="padding-top: 10px; padding-botton: 10px; ">

	<tr>
		<td><label for="vllimite_min" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Mínimo") ?>:</label> <td>
		<td><input type="text" id="vllimite_min" name="vllimite_min" class="campoTelaSemBorda VLLIMCRD"> </td>
		<td><label for="vllimite_max" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Máximo") ?>:</label> <td>
		<td><input type="text" id="vllimite_max" name="vllimite_max" class="campoTelaSemBorda VLLIMCRD"> </td>
	</tr>
	<tr >
		<td>
			<label for="DDDEBITO" class="rotulo txtNormalBold"><? echo utf8ToHtml("Dia de Débito") ?>:</label>
		<td>
		<td colspan="4">
			
			<? 		$dias = array();
					for($i = 1;$i<30; $i++){
							$label = $i<10? "0".$i: $i;
							array_push($dias, array($label,$i));
					}
					//build_select("DDDEBITO", array(0=>array("03",03), 1=>array("07",07), 2=>array("11",11),3=>array("19",19),4=>array("22",22),5=>array("27",27),6=>array("30",30)), "");	
					build_select("DDDEBITO",$dias,"campoTelaSemBorda",0);
			?>
		</td>
	</tr>

</table>

	<?

	}else{

?>
<table class="tableform hideable" style="padding-top: 10px; padding-botton: 10px; ">
	<tr>

		<td>
			<label for="VLLIMCRD" class="rotulo txtNormalBold">Valor Limite:</label>
		<td>
		<td>
			<input type="text" id="VLLIMCRD" name="VLLIMCRD" class="campoTelaSemBorda VLLIMCRD"> 
		</td>
		<td>
			<label for="NRCTAMAE" class="rotulo txtNormalBold"><? echo utf8ToHtml("Nro. Conta Mãe") ?>:</label>
		<td>
		<td>
			<input type="text" id="NRCTAMAE" name="NRCTAMAE" class="campoTelaSemBorda"> 
		</td>
	</tr>
	<tr >
		<td>
			<label for="cdlimcrd"  class="rotulo txtNormalBold"><? echo utf8ToHtml("Cód. Limite") ?>:</label>
		<td>
		<td>
			<input type="text" id="cdlimcrd" name="cdlimcrd" class=" campoTelaSemBorda "> 
		</td>
		<td>
			<label for="tpcartao"  class="rotulo txtNormalBold"><? echo utf8ToHtml("Tipo Cartão") ?>:</label>
		<td>
		<td>
			<select id="tpcartao" class=" ">
				<option value="0"> - </option>
				<option value="1">Nacional </option>
				<option value="2">Internacional </option>
				<option value="3">Gold </option>
			</select>

		</td>

	</tr>
	<tr>
		<td>
			<label for="insittab"  class="rotulo txtNormalBold"><? echo utf8ToHtml("Situação") ?>:</label>
		<td>
		<td>
			<select id="insittab" class="campoTelaSemBorda ">
				<option value="0"><? echo utf8ToHtml("Em Uso") ?> </option>
				<option value="1"><? echo utf8ToHtml("Em Desuso") ?> </option>
			</select>

		</td>
	</tr>

	<tr >

		<td>
			<label for="DDDEBITO" class="rotulo txtNormalBold"><? echo utf8ToHtml("Dia de Débito") ?>:</label>
		<td>
		<td colspan="4">
			<input type="text" id="DDDEBITO" name="DDDEBITO" class="campoTelaSemBorda "> 
		</td>
	</tr>
</table>
<?
	}
?>
<script>
$(".VLLIMCRD").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
</script>