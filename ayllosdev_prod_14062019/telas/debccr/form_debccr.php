<? 
/*!
 * FONTE        : form_debccr.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : 24/07/2015 
 * OBJETIVO     : Form da tela debccr
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 
?>

<?php
 	session_start();
	set_time_limit(999999999);
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:6px;
	margin-top:6px;
}
</style> 

<form id="frmDebccr" name="frmDebccr" style="display:none" class="formulario">
	
	<table width="100%">
			<tr>		
				<td>
					<div id="divCdcooper" name="divCdcooper">
						<label name="label_cdcooper" for="cdcopaux">Cooperativa:</label>
						<input type="text" id="cdcopaux" name="cdcopaux" value="<? echo $cdcooper ?>" />
						<a name="lupa_cdcooper" href="#" onclick="controlaPesquisas(1); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<input type="text" id="nmrescop" name="nmrescop" value="<? echo $nmrescop ?>" />
					</div>
				</td>
			</tr>
			
			<tr>		
				<td>
					<label for="nrdconta">Conta:</label>
					<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
					<a href="#" onclick="controlaPesquisas(2); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input id="nmprimtl" name="nmprimtl" type="text" value="<? echo $nmprimtl ?>"/>
				</td>
			</tr>			
	</table>	
	
	<input type="hidden" id="cdcooper1" name="cdcooper1" />	
	<input type="hidden" id="nrdconta1" name="nrdconta1" />	
	<!--	<input type="hidden" id="nmarqpdf1" name="nmarqpdf1" />	-->
		
</form>

<script>
  glbDtmvtolt = "<?php echo $glbvars["dtmvtolt"]; ?>";
</script>
