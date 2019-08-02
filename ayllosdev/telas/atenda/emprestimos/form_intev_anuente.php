<? 
 /*!
 * FONTE        : form_interv_anuente.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATEND
 *
 * ALTERACOES   : * 000: [05/09/2012] Mudar para layout padrao (Gabriel) 
 *                  001: [15/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 *                  002: [18/10/2018] Alterado layout da tela Interveniente. PRJ438 (Mateus Z / Mouts)
 *                  003: [05/02/2019] Inserido campo Data de Nascimento/Abertura - prj 438 - Burno Luiz k. - Mout's
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
		<select name="inpessoa" id="inpessoa" alt="Entre com 1-Fisica 2-Juridica.">
			<option value=""  > - </option> 
			<option value="1" >1 - Fisica</option>
			<option value="2" >2 - Juridica</option>
		</select>	
		<br />
		
		<label for="nrcpfcgc">CPF.:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="" />
		<br />			
				
		<label for="nmdavali">Nome:</label>
		<input name="nmdavali" id="nmdavali" type="text" value="" />
		<br />

		<!-- Rafael Ferreira (Mouts) Story 13447-->
		<div id="divNacionalidade">
		<label for="cdnacion">Nacionalidade:</label>
		<div id="divCdnacion">
	        <input name="cdnacion" id="cdnacion" type="text" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		</div>
		<input name="dsnacion" id="dsnacion" type="text" value="" />
		<br />		
		</div>		
				
		<!-- bruno - prj 438 - bug 14585 -->
		<label for="dtnascto">Data Nasc.:</label>
		<input name="dtnascto" id="dtnascto" type="text" value="" />
		</br>
				
		<select name="tpdocava" id="tpdocava">
			<option value=""  > - </option> 
			<option value="CH">CH</option>
			<option value="CI">CI</option>
			<option value="CP">CP</option>
			<option value="CT">CT</option>
		</select>
		<input name="nrdocava" id="nrdocava" type="hidden" value="" />
		<br />		
				
	</fieldset>
	
	<fieldset id="fsetConjugeInterv">
		<legend><? echo utf8ToHtml('Informações do Cônjuge') ?></legend>
				
		<label for="nrctacjg">Conta:</label>
		<input name="nrctacjg" id="nrctacjg" type="text" value="" />
						
		<label for="nrcpfcjg">CPF:</label>
		<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="" />
		<br />
			
		<label for="nmconjug"><?php echo utf8ToHtml('Cônjuge:') ?></label>
		<input name="nmconjug" id="nmconjug" type="text" value="" />
			
		<select name="tpdoccjg" id="tpdoccjg">
			<option value=""  > - </option> 
			<option value="CH">CH</option>
			<option value="CI">CI</option>
			<option value="CP">CP</option>
			<option value="CT">CT</option>
		</select>
		<input name="nrdoccjg" id="nrdoccjg" type="hidden" value="" />
		<br />
		
	</fieldset>
	
	<fieldset>
		<legend><?php echo utf8ToHtml('Endereço') ?></legend>
		
		<label for="nrcepend">CEP:</label>
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
		
		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" value="" />		
		
		<label for="dsendre2">Bairro:</label>
		<input name="dsendre2" id="dsendre2" type="text" value="" />
		<br />	
		
		<label for="cdufresd">UF:</label>
		<? echo selectEstado('cdufresd','', 1) ?>
				
		<label for="nmcidade">Cidade:</label>
		<input name="nmcidade" id="nmcidade" type="text" value="" />
		<br />
		
	</fieldset>
		
	<fieldset>
		<legend><?php echo utf8ToHtml('Contato') ?></legend>
		
		<label for="nrfonres">Telefone:</label>
		<input name="nrfonres" id="nrfonres" type="text" value="" />

		<label for="dsdemail">E-mail:</label>
		<input name="dsdemail" id="dsdemail" type="text" value="" />
		<br />
			
	</fieldset>
  
</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_INTEV_ANU' ) { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"  onClick="atualizaArray('A_INTEV_ANU'); return false;">Continuar</a>
		<a href="#" class="botao" id="btLimpar"  onClick="limpaForm('frmIntevAnuente'); return false;">Limpar</a>
	<? } else if ($operacao == 'AI_INTEV_ANU') { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"  onClick="exibeAguardo( 'Aguarde, validando dados...' , 'insereIntervente(\'A_INTEV_ANU\',\'A_DEMONSTRATIVO_EMPRESTIMO\');' , 400 ); return false;" >Continuar</a>
		<!-- exibeAguardo( 'Aguarde, validando dados...' , 'insereIntervente(\'A_INTEV_ANU\',\'A_FINALIZA\');' , 400 ); return false; -->
		<a href="#" class="botao" id="btLimpar"  onClick="limpaForm('frmIntevAnuente'); return false;">Limpar</a>		
	<? } else if ($operacao == 'C_INTEV_ANU') { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"  onClick="controlaOperacao('C_INTEV_ANU'); return false;">Continuar</a>	
	<? } else if ($operacao == 'E_INTEV_ANU') { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_INTEV_ANU') { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"  onClick="exibeAguardo( 'Aguarde, validando dados...' , 'insereIntervente(\'I_INTEV_ANU\',\'I_DEMONSTRATIVO_EMPRESTIMO\');' , 400 );return false;">Continuar</a>
		<!-- exibeAguardo( 'Aguarde, validando dados...' , 'insereIntervente(\'I_INTEV_ANU\',\'I_FINALIZA\');' , 400 );return false; -->
		<a href="#" class="botao" id="btLimpar"  onClick="limpaForm('frmIntevAnuente'); return false;">Limpar</a>		
	<? } else if ( $operacao == 'IA_INTEV_ANU' ) { ?>
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"  onClick="atualizaArray('I_INTEV_ANU'); return false;">Continuar</a>
		<a href="#" class="botao" id="btLimpar"  onClick="limpaForm('frmIntevAnuente'); return false;">Limpar</a>	
	<? }?>
</div>