	<?
	/***********************************************************************
	
	  Fonte: form.php                                               
	  Autor: Renato Darosci                                                  
	  Data : Ago/2016                       Última Alteração: 28/08/2016

	  Objetivo  : Mostrar os campos do formulario

	  Alterações: 

	***********************************************************************/	
	?>
	

<form id="frmPROVIS" name="frmPROVIS" class="formulario">

	<!--fieldset-->
		<!--legend><? echo utf8ToHtml('') ?></legend-->
		
		<table style="width:100%;"> 
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Riscos' ?></legend>
						<table style="width:95%;" >
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscAA" align = "right" style="width:100%;">AA:</label></td>
							<td><input  type="text" class="campo" id="vlriscAA" name="vlriscAA"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoA" align = "right" style="width:100%;">A:</label></td>
							<td><input  type="text" class="campo" id="vlriscoA" name="vlriscoA"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoB" align = "right" style="width:100%;">B:</label></td>
							<td><input  type="text" class="campo" id="vlriscoB" name="vlriscoB"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoC" align = "right" style="width:100%;">C:</label></td>
							<td><input  type="text" class="campo" id="vlriscoC" name="vlriscoC"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoD" align = "right" style="width:100%;">D:</label></td>
							<td><input  type="text" class="campo" id="vlriscoD" name="vlriscoD"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoE" align = "right" style="width:100%;">E:</label></td>
							<td><input  type="text" class="campo" id="vlriscoE" name="vlriscoE"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoF" align = "right" style="width:100%;">F:</label></td>
							<td><input  type="text" class="campo" id="vlriscoF" name="vlriscoF"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>	
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoG" align = "right" style="width:100%;">G:</label></td>
							<td><input  type="text" class="campo" id="vlriscoG" name="vlriscoG"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="width:45%;text-align:right;"> <label for="vlriscoH" align = "right" style="width:100%;">H:</label></td>
							<td><input  type="text" class="campo" id="vlriscoH" name="vlriscoH"  size = "4" maxlength = "6" style="text-align:right;"/><label class="txtNormalBold">&nbsp;(%)</label></td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						</table>
					</fieldset>
				</td>
			</tr>
		</table>
	<!--/fieldset-->
	
</form>

