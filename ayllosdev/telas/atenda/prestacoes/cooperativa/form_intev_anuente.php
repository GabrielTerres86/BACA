<? 
 /*!
 * FONTE        : form_intev_anuente.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [29/04/2011] Rogerius (DB1): reorganizado os campos de endereco conforme o padrao do zoom generico do CEP
 * 002: [22/11/2018] Mateus Z (Mouts): Alterado o layout da tela - PRJ 438.
 * 003: [07/02/2019] Bruno L. Katzjarowski (Mout's): Adicionando campo data de pagamento/abertura
 */	
 ?>

<form name="frmIntevAnuente" id="frmIntevAnuente" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend></legend>
	
		<label for="nrctaava">Conta:</label>
		<input name="nrctaava" id="nrctaava" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<br />	
				
		<label for="inpessoa">Tipo Natureza:</label>
		<input name="inpessoa" id="inpessoa" type="text" value="" />
		<input name="dspessoa" id="dspessoa" type="text" value="" />		
		<br />
		
		<label for="nrcpfcgc">C.P.F.:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="" />
		<br />			
				
		<label for="nmdavali">Nome:</label>
		<input name="nmdavali" id="nmdavali" type="text" value="" />
		<br />
		
		<label for="dsnacion">Nacionalidade:</label>
		<input name="dsnacion" id="dsnacion" type="text" value="" />

		<!-- bruno - prj 438 - bug 14668 -->
		<label for="dtnascto">Data Nasc.:</label>
		<input name="dtnascto" id="dtnascto" type="text" value="" />
		</br>

	</fieldset>
	
	<fieldset id="fsetConjugeInterv">
		<legend><? echo utf8ToHtml('Dados Cônjuge') ?></legend>
						
		<label for="nrctacjg">Conta:</label>
		<input name="nrctacjg" id="nrctacjg" type="text" value="" />
						
		<label for="nrcpfcjg">C.P.F.:</label>
		<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="" />
		<br />
			
		<label for="nmconjug"><?php echo utf8ToHtml('Cônjuge:') ?></label>
		<input name="nmconjug" id="nmconjug" type="text" value="" />
		<br />
		
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Endereço') ?></legend>			

		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<label for="dsendre1"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendre1" id="dsendre1" type="text" value="" />		
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="" />

		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" value="" />
		<br />

		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Post.:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" value="" />		

		<label for="dsendre2"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="dsendre2" id="dsendre2" type="text" value="" />								
		<br />	

		<label for="cdufresd"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufresd', '', 1); ?>	

		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="" />

	</fieldset>	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Contato') ?></legend>					
		
		<label for="nrfonres">Telefone:</label>
		<input name="nrfonres" id="nrfonres" type="text" value="" />
		
		<label for="dsdemail">E-mail:</label>
		<input name="dsdemail" id="dsdemail" type="text" value="" />
		<br />
		
	</fieldset>	
  
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_INTEV_ANU') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_INTEV_ANU'); return false;" />
	<? } ?>
</div>