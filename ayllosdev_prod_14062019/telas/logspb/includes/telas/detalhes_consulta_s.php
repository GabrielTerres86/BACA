<?php
/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 12/11/2018
Ultima alteração:

Alteração:
*/
?>
<div id='detalhesConsultaS'>
	<div id='mensagemSDiv1' class='bloco'>

			<div>
				<label class='rotulo txtNormalBold' for='dstransa'>JDSBP:</label>
				<input type='text' class='campo' name='dstransa' id='dstransa' value="">
			</div>
			
			<div>
				<label class='rotulo txtNormalBold'  for='nmevento'>Mensagem:</label>
				<input type='text' class='campo'  name='nmevento' id='nmevento' value="">
			</div>
			
			<div>
				<label class='rotulo txtNormalBold'  for='nrctrlif'>N&uacute;mero Controle:</label>
				<input type='text' class='campo'  name='nrctrlif' id='nrctrlif' value="">
			</div>
			
			<div>
				<label class='rotulo txtNormalBold'  for='vltransa'>Valor:</label>
				<input type='text' class='campo'  name='vltransa' id='vltransa' value="">
			</div>
			
			<div>
				<label class='rotulo txtNormalBold'  for='dhtransa'>Hora:</label>
				<input type='text' class='campo'  name='dhtransa' id='dhtransa' value="">
			</div>
			
			<div>
				<label class='rotulo txtNormalBold'  for='dsmotivo'>Detalhes:</label>
				<textarea name='dsmotivo'  class='campo'  id='dsmotivo' value=""></textarea>
			</div>

	</div>

	<div id='mensagemSDiv2' class='bloco'>
		<div id='divCamposRemetente' class='left-div'>				
				<span>REMETENTE</span>
				
				<br>
				<div>
					<label for='cdbanren'>Banco:</label>
					<input type='text' name='cdbanren' class='campo'  id='cdbanren' value="">
				</div>
			
				<div>
					<label for='cdispbren'>ISPB:</label>
					<input type='text' name='cdispbren' class='campo'  id='cdispbren' value="">
				</div>
			
				<div>
					<label for='cdagerem'>Ag&ecirc;ncia:</label>
					<input type='text' name='cdagerem' class='campo'  id='cdagerem' value="">
				</div>
			
				<div>
					<label for='nrctarem'>Conta/dv:</label>
					<input type='text' name='nrctarem' class='campo'  id='nrctarem' value="">
				</div>
			
				<div>
					<label for='dsnomrem'>Nome:</label>
					<input type='text' name='dsnomrem' class='campo'  id='dsnomrem' value="">
				</div>
			
				<div>
					<label for='dscpfrem'>CPF/CNPJ:</label>
					<input type='text' name='dscpfrem' class='campo'  id='dscpfrem' value="">
				</div>
				
		</div><!-- FIM divCamposRemetente -->

		<div id='divCamposDestinatario' class='right-div'>
			<span>DESTINAT&Aacute;RIO</span>
			
			<br>
			<div>
				<label for='cdbandst'>Banco:</label>
				<input type='text' name='cdbandst' class='campo'  id='cdbandst' value="">
			</div>
		
			<div>
				<label for='cdispbdst'>ISPB:</label>
				<input type='text' name='cdispbdst' class='campo'  id='cdispbdst' value="">
			</div>
		
			<div>
				<label for='cdagedst'>Ag&ecirc;ncia:</label>
				<input type='text' name='cdagedst' class='campo'  id='cdagedst' value="">
			</div>
		
			<div>
				<label for='nrctadst'>Conta/dv:</label>
				<input type='text' name='nrctadst' class='campo'  id='nrctadst' value="">
			</div>
		
			<div>
				<label for='dsnomdst'>Nome:</label>
				<input type='text' name='dsnomdst' class='campo'  id='dsnomdst' value="">
			</div>
		
			<div>
				<label for='dscpfdst'>CPF/CNPJ:</label>
				<input type='text' name='dscpfdst' class='campo'  id='dscpfdst' value="">
			</div>
		</div> <!-- FIM divCamposDestinatario -->
	</div> <!-- FIM mensagemSDiv2 -->

</div>