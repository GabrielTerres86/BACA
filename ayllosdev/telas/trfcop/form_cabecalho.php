<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Gabriel                                                     
	 Data : Setembro/2011                Última Alteração: 28/12/2012 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da TRFCOP.                                  
	                                                                  
	 Alterações: 18/12/2012 - Alteracao layout tela. (Daniel) 
	 
				 28/12/2012 - Aumentar tamanho dos campos operacoes e tipo
							  (Gabriel) 
							  
				 14/03/2013 - Incluir nova informacao de Origem (Gabriel)					
	**********************************************************************/
?>

<form name="frmTrfcop" id="frmTrfcop" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="redirect" id="redirect" value="popup">
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<label for="cddopcao" style="width:80px">Op&ccedil;&atilde;o:</label>
			  <select name="cddopcao" id="cddopcao" class="campo" style="width: 400px;">
				<option value="L" >L - Apresenta o log das transacoes efetuadas</option>
				<option value="P">P - Apresenta e permite alteracao dos parametros.</option>
			  </select>
		
			<label for="dttransa" style="width:50px">Data:</label>
			<input name="dttransa" type="text" class="campo" id="dttransa" style="width:80px;"  value="<?php echo $glbvars["dtmvtolt"]; ?>" /> 
		</td>
	</tr>
	<tr>
		<td>
			<label for="tpoperac" style="width:80px">Opera&ccedil;&atilde;o:</label>
			  <select name="tpoperac" id="tpoperac" class="campo" style="width: 110px;">
				<option value="1" selected> Dep&oacute;sito</option>
				<option value="2"> Transfer&ecirc;ncia</option>
			 </select>
																								
			<label for="tpdenvio" style="width:70px">Tipo:</label>	
			<select name="tpdenvio" id="tpdenvio" class="campo" style="width: 110px;">
				<option value="1" selected>Recebimento</option>
				<option value="2">Envio</option>
			</select>		

			<label for="cdpacrem" style="width:80px">Origem:</label>	
			<select name="cdpacrem" id="cdpacrem" class="campo" style="width: 110px;">
				<option value="0" selected>Todos </option>		
				<option value="1" >Caixa on-line</option>
				<option value="90">Internet</option>
				<option value="91">TAA</option>
			</select>
			
			<a href="#" class="botao" id="btOk" style="margin-left:15px" onClick="consultaInicial();return false;" >OK</a> 
		</td>																							
	</tr>
	</table>
</form>	



