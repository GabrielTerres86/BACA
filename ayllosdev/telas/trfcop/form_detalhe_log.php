<?php  
    /*********************************************************************
	 Fonte: form_detalhe_log.php                                                 
	 Autor: Gabriel                                                     
	 Data : Setembro/2011                Última Alteração:  
	                                                                  
	 Objetivo  : Mostrar o form com os detalhes da opcao L.                                 
	                                                                  
	 Alterações: 18/12/2012 - Alteração layout tela (Daniel).

				 14/03/2013 - Incluir nova informacao de Origem (Gabriel)	
	**********************************************************************/
?>


<form method="post" name="frmDetalheLog" id="frmDetalheLog">

	<table border="0" cellpadding="0" cellspacing="0">
		
		<tr>
			<td colspan="4" height="10"></td>
		</tr>
		<tr>
			<td colspan="2" class="txtNormalBold" height="23" align="center">REMETENTE</td>
			<td colspan="2" class="txtNormalBold" height="23" align="center">DESTINAT&Aacute;RIO</td>
		</tr>
		<tr>
			<td width="75" class="txtNormalBold" height="23" align="right">Cooperativa:&nbsp;</td>
			<td width="205" class="txtNormal"><input name="cdagerem" type="text" class="campoTelaSemBorda" id="cdagerem" style="width: 250px;" readonly></td>
			<td width="85" class="txtNormalBold" height="23" align="right">Cooperativa:&nbsp;</td>
			<td width="205" class="txtNormal"><input name="cdagedst" type="text" class="campoTelaSemBorda" id="cdagedst" style="width: 250px;" readonly></td>																											
		</tr>
		<tr>
			<td class="txtNormalBold" height="23" align="right">Conta/dv:&nbsp;</td>
			<td class="txtNormal"><input name="nrctarem" type="text" class="campoTelaSemBorda" id="nrctarem" style="width: 250px;" readonly></td>
			<td class="txtNormalBold" height="23" align="right">Conta/dv:&nbsp;</td>
			<td class="txtNormal"><input name="nrctadst" type="text" class="campoTelaSemBorda" id="nrctadst" style="width: 250px;" readonly></td>
		</tr>
		<tr>
			<td class="txtNormalBold" height="23" align="right">Nome:&nbsp;</td>
			<td class="txtNormal"><input name="nmprirem" type="text" class="campoTelaSemBorda" id="nmprirem" style="width: 250px;" readonly></td>
			<td class="txtNormalBold" height="23" align="right">Nome:&nbsp;</td>
			<td class="txtNormal"><input name="nmpridst" type="text" class="campoTelaSemBorda" id="nmpridst" style="width: 250px;" readonly></td>
		</tr>
		<tr>
			<td class="txtNormalBold" height="23" align="right">CPF/CNPJ:&nbsp;</td>
			<td class="txtNormal"><input name="nrcpfrem" type="text" class="campoTelaSemBorda" id="nrcpfrem" style="width: 250px;" readonly></td>
			<td class="txtNormalBold" height="23" align="right">CPF/CNPJ:&nbsp;</td>
			<td class="txtNormal"><input name="nrcpfdst" type="text" class="campoTelaSemBorda" id="nrcpfdst" style="width: 250px;" readonly></td>
		</tr>	
		<tr>
			<td class="txtNormalBold" height="23" align="right">Origem:&nbsp;</td>
			<td class="txtNormal"><input name="dspacrem" type="text" class="campoTelaSemBorda" id="dspacrem" style="width: 250px;" readonly></td>
		</tr>	
		<tr>
			<td colspan="4" height="10"></td>
		</tr>
	</table>
</form>












