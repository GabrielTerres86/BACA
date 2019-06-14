<?php
/*!
 * FONTE        : form_chqsin.php
 * CRIAÇÃO      : Rodrigo Bertelli(RKAM)         
 * DATA CRIAÇÃO : Julho/2014
 * OBJETIVO     : Formulario para tela CHQSIN
 *
 * Alteração    : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
	*				 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<div id="divChqsin" name="divChqsin">
	<form id="frmChqsin" name="frmChqsin" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset>
			<legend>Cheques Sinistrados</legend>
			<table width="80%" style="margin-left:80px">
				<tr>
					<td style="width: 130px;"><label style="text-align:right;" for="datinclusao">Data Inclu&atilde;o:</label></td>
					<td><input type="text" class="clsvalidainclusao clsData"  style="text-align:right;" id="datinclusao" name="datinclusao" maxlength="10" onchange="validaDataInput(this)" value="" alt="Data Inclusão." /></td>
				</tr>
				<tr>											
					<td style="width: 130px;"><label  style="text-align:right;" for="codbanco">Banco do Sinistro:</label></td>
					<td><input class="clsvalidainclusao somenteNumeros" type="text"  style="text-align:right;" id="codbanco" name="codbanco" maxlength="10" value="" alt="Código do Banco." onchange="buscaInformacao($('#cdtipchq','#frmCab').val(),'codbanco',this.value)" width="10px"/></td>
					<td><input type="text"  id="nombanco" name="nombanco" maxlength="10" style="text-align:left;" disabled="disabled" width="100px" value="" alt="Nome do Banco." /></td>
				</tr>
				<tr>
					<td style="width: 130px;"><label for="codagencia">Ag&ecirc;ncia:</label></td>
					<td><input class="clsvalidainclusao somenteNumeros" type="text" style="text-align:right;"  id="codagencia" name="codagencia" maxlength="10" value="" alt="Código do Agência." onchange="buscaInformacao($('#cdtipchq','#frmCab').val(),'codagencia',$('#codbanco').val()+';'+this.value)" /></td>
					<td><input type="text"  id="nomagencia" name="nomagencia" maxlength="10" style="text-align:left;" disabled="disabled" value="" alt="Nome da Agência." /></td>
				</tr>	
				<tr>
					<td style="width: 130px;"><label for="nrconta">N&uacute;mero da Conta:</label></td>
					<td><input class="clsvalidainclusao somenteNumeros" type="text" style="text-align:right;" id="nrconta" name="nrconta" maxlength="10" value="" alt="Nr. Conta." onchange="buscaInformacao($('#cdtipchq','#frmCab').val(),'nrconta',$('#codagencia').val()+';'+this.value)" />
					<td><input type="text"  id="nomconta" name="nomconta" maxlength="10" style="text-align:left;" disabled="disabled" value="" alt="Nome da Conta." /></td></td>
				</tr>
				<tr>
					<td style="width: 130px;"><label for="nrcheque" id="nrchqlbl">N&uacute;mero do Cheque:</label></td>
					<td><input class="clsvalidainclusao somenteNumeros" type="text" style="text-align:right;" id="nrcheque" name="nrcheque" maxlength="10" value="" alt="Nr. Cheque."/>
					<label style="width: 40px;" for="nrchqfim" id="nrchqlbl">At&eacute;:</label>
					<td><input class="clsvalidainclusao somenteNumeros" type="text" style="text-align:right;" id="nrchqfim" name="nrchqfim" maxlength="10" value="" alt="Nr. Cheque."/>
				</tr>
				
			</table>
			<table style="margin-left: 80px;">
				<tr>
					<td style="width:132px;"><label for="dscmotivo">Motivo:</label></td>
					<td><textarea class="clsvalidainclusao" id="dscmotivo" name="dscmotivo" cols="51" rows="5"></textarea></td>
				</tr>
			</table>
		</fieldset>
	</form>
</div>

