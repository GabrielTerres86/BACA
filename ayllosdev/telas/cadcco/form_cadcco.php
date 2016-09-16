<?php
/* * *********************************************************************

  Fonte: form_cadcco.php
  Autor: Jonathan - RKAM
  Data : Marco/2016                      Última Alteração:

  Objetivo  : Mostrar valores da CADCCO.

  Alterações: 
  

 * ********************************************************************* */

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>

<form id="frmCadcco" name="frmCadcco" class="formulario">	

	<fieldset>

		<legend> <? echo utf8ToHtml('Informações gerais')?>  </legend>

		<label for="flgativo"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
		<select id="flgativo" name="flgativo" alt="Informe situacao desejada (Ativo/Inativo)" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flgativo') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Ativo') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flgativo') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Inativo') ?> </option>
		</select>

		<label for="dsorgarq"><? echo utf8ToHtml('Origem:') ?></label>		
		<select id="dsorgarq" name="flgregis" alt="Informe situacao desejada (Sim/Nao)" disabled>
			<option value="IMPRESSO PELO SOFTWARE" <? echo getByTagName($inf,'dsorgarq') == 'IMPRESSO PELO SOFTWARE' ? 'selected' : '' ?> >Impresso pelo software</option> 
			<option value="PRE-IMPRESSO" <? echo getByTagName($inf,'dsorgarq') == 'PRE-IMPRESSO' ? 'selected' : '' ?> >Pr&eacute;-impresso</option>
			<option value="INTERNET" <? echo getByTagName($inf,'dsorgarq') == 'INTERNET' ? 'selected' : '' ?> >Internet</option>
			<option value="PROTESTO" <? echo getByTagName($inf,'dsorgarq') == 'PROTESTO' ? 'selected' : '' ?> >Protesto</option>
			<option value="EMPRESTIMO" <? echo getByTagName($inf,'dsorgarq') == 'EMPRESTIMO' ? 'selected' : '' ?> >Empr&eacute;stimo</option>
			
			<?php if($cddopcao != 'I'){?>
				<option value="MIGRACAO" <? echo getByTagName($inf,'dsorgarq') == 'MIGRACAO' ? 'selected' : '' ?>> Migra&ccedil;&atilde;o</option>
				<option value="INCORPORACAO" <? echo getByTagName($inf,'dsorgarq') == 'INCORPORACAO' ? 'selected' : '' ?>> Incorpora&ccedil;&atilde;o</option>
			<?}?>

		</select>	

		</br>

		<label for="nrdctabb"><? echo utf8ToHtml('Conta Base:') ?></label>
		<input type="text" id="nrdctabb" name="nrdctabb" value="<?php echo getByTagName($inf,'nrdctabb');?>" disabled />
		
		<label for="flgregis"><? echo utf8ToHtml('Cobran&ccedil;a Registrada:') ?></label>		
		<select id="flgregis" name="flgregis" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flgregis') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flgregis') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Nao') ?> </option>
		</select>	
		
		</br>
		
		<label for="cddbanco"><? echo utf8ToHtml('Banco:') ?></label>		
		<input type="text" id="cddbanco" name="cddbanco" value="<?php echo getByTagName($inf,'cddbanco');?>" disabled />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		<input type="text" id="nmextbcc" name="nmextbcc" value="<?php echo getByTagName($inf,'nmextbcc');?>" disabled />
		
		</br>

		<label for="cdbccxlt"><? echo utf8ToHtml('Banco/Caixa:') ?></label>
		<input type="text" id="cdbccxlt" name="cdbccxlt" value="<?php echo getByTagName($inf,'cdbccxlt');?>" disabled />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(4); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo getByTagName($inf,'cdagenci');?>" disabled />	
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(5); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		<label for="nrdolote"><? echo utf8ToHtml('Lote:') ?></label>
		<input type="text" id="nrdolote" name="nrdolote" value="<?php echo getByTagName($inf,'nrdolote');?>" disabled />
		
		<br /> 

		<label for="flserasa"><? echo utf8ToHtml('Integra Serasa:') ?></label>
		<select id="flserasa" name="flserasa" disabled >
			<option value="1" <?php echo (getByTagName($inf,'flserasa') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flserasa') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Nao') ?> </option>
		</select>		
		
		<label for="cdhistor"><? echo utf8ToHtml('Hist&oacute;rico Cobran&ccedil;a:') ?></label>
		<input type="text" id="cdhistor" name="cdhistor" value="<?php echo getByTagName($inf,'cdhistor');?>" disabled />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>		
		
		</br>
		
		<label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
		<input type="text" id="nmarquiv" name="nmarquiv" value="<?php echo getByTagName($inf,'nmarquiv');?>" disabled />
		
		<label for="flcopcob"><? echo utf8ToHtml('Utiliza CoopCob:') ?></label>
		<select id="flcopcob" name="flcopcob" disabled >
			<option value="1" <?php echo (getByTagName($inf,'flcopcob') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flcopcob') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Nao') ?> </option>
		</select>
		
		</br>
		
		<label for="nmdireto"><? echo utf8ToHtml('Diret&oacute;rio:') ?></label>
		<input type="text" id="nmdireto" name="nmdireto" value="<?php echo getByTagName($inf,'nmdireto');?>" disabled />
		
		<label for="qtdfloat"><? echo utf8ToHtml('Float:') ?></label>
		<select id="qtdfloat" name="qtdfloat" disabled >
			<option value="0" <?php echo (getByTagName($inf,'qtdfloat') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('0 Dia') ?> </option> 
			<option value="1" <?php echo (getByTagName($inf,'qtdfloat') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('1 Dia') ?> </option>
			<option value="2" <?php echo (getByTagName($inf,'qtdfloat') == 2 ? "selected" : "");?>> <? echo utf8ToHtml('2 Dia') ?> </option>
			<option value="3" <?php echo (getByTagName($inf,'qtdfloat') == 3 ? "selected" : "");?>> <? echo utf8ToHtml('3 Dia') ?> </option>
			<option value="4" <?php echo (getByTagName($inf,'qtdfloat') == 4 ? "selected" : "");?>> <? echo utf8ToHtml('4 Dia') ?> </option>
			<option value="5" <?php echo (getByTagName($inf,'qtdfloat') == 5 ? "selected" : "");?>> <? echo utf8ToHtml('5 Dia') ?> </option>
		</select>

		</br>		

		<label for="nrbloque"><? echo utf8ToHtml('Nr.Boleto:') ?></label>
		<input type="text" id="nrbloque" name="nrbloque" value="<?php echo getByTagName($inf,'nrbloque');?>" disabled />
		
		<label for="flgcnvcc"><? echo utf8ToHtml('Identifica Sequ&ecirc;ncia:') ?></label>
		<select id="flgcnvcc" name="flgcnvcc" disabled >
			<option value="1" <?php echo (getByTagName($inf,'flgcnvcc') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flgcnvcc') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Nao') ?> </option>
		</select>
		
		<label for="tamannro"><? echo utf8ToHtml('Tamanho Nro.:') ?></label>
		<input type="text" id="tamannro" name="tamannro" value="<?php echo getByTagName($inf,'tamannro');?>" disabled />
		
		</br>

	</fieldset>

	<fieldset>

		<legend>Tarifas</legend>		
		
		<label for="cdcartei"><? echo utf8ToHtml('Nro. Carteira/Varia&ccedil;&atilde;o:') ?></label>
		<input type="text" id="cdcartei" name="cdcartei" value="<?php echo getByTagName($inf,'cdcartei');?>" disabled />

		<label for="nrvarcar"><? echo utf8ToHtml('/') ?></label>
		<input type="text" id="nrvarcar" name="nrvarcar" value="<?php echo getByTagName($inf,'nrvarcar');?>" disabled />
		
		<label for="nrlotblq"><? echo utf8ToHtml('Lote Tarifa Impres.Boleto:') ?></label>
		<input type="text" id="nrlotblq" name="nrlotblq" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'nrlotblq'),'.');?>" disabled />
		
		</br>
		
		<label id="lblvalor"><? echo utf8ToHtml('Valor da Tarifa:') ?></label>
		<label id="lblhisto"><? echo utf8ToHtml('Hist&oacute;rico da Tarifa:') ?></label>
		
		</br> 

		<label for="vlrtarif"><? echo utf8ToHtml('Cobran&ccedil;a:') ?></label>
		<input type="text" id="vlrtarif" name="vlrtarif" value="<?php echo getByTagName($inf,'vlrtarif');?>" disabled />
		
		<label for="cdtarhis"><? echo utf8ToHtml('Cobran&ccedil;a:') ?></label>
		<input type="text" id="cdtarhis" name="cdtarhis" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'cdtarhis'),'.');?>" disabled /> 
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(6); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			

		</br>
		
		<label for="vlrtarcx"><? echo utf8ToHtml('Boleto Pago Coop:') ?></label>
		<input type="text" id="vlrtarcx" name="vlrtarcx" value="<?php echo getByTagName($inf,'vlrtarcx');?>" disabled />
		
		<label for="cdhiscxa"><? echo utf8ToHtml('Boleto Pago Coop:') ?></label>
		<input type="text" id="cdhiscxa" name="cdhiscxa" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'cdhiscxa'),'.');?>" disabled />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(7); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		</br>
		
		<label for="vlrtarnt"><? echo utf8ToHtml('Boleto Pago Internet:') ?></label>
		<input type="text" id="vlrtarnt" name="vlrtarnt" value="<?php echo getByTagName($inf,'vlrtarnt');?>" disabled />
		
		<label for="cdhisnet"><? echo utf8ToHtml('Boleto Pago Internet:') ?></label>
		<input type="text" id="cdhisnet" name="cdhisnet" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'cdhisnet'),'.');?>" disabled />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(8); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		</br>
		
		<label for="vltrftaa"><? echo utf8ToHtml('Boleto Pago TAA:') ?></label>
		<input type="text" id="vltrftaa" name="vltrftaa" value="<?php echo getByTagName($inf,'vltrftaa');?>" disabled />
		
		<label for="cdhistaa"><? echo utf8ToHtml('Boleto Pago TAA:') ?></label>
		<input type="text" id="cdhistaa" name="cdhistaa" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'cdhistaa'),'.');?>" disabled />	
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(9); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		</br>
		
		<label for="vlrtrblq"><? echo utf8ToHtml('Pr&eacute;-Impresso:') ?></label> 
		<input type="text" id="vlrtrblq" name="vlrtrblq" value="<?php echo getByTagName($inf,'vlrtrblq');?>" disabled />	
		
		<label for="cdhisblq"><? echo utf8ToHtml('Pr&eacute;-Impresso:') ?></label>
		<input type="text" id="cdhisblq" name="cdhisblq" value="<?php echo formataNumericos('zzz.zzz',getByTagName($inf,'cdhisblq'),'.');?>" disabled />				
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(10); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		</br>
		
		<label for="dtmvtolt"><? echo utf8ToHtml('Data altera&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dtmvtolt" name="dtmvtolt" value="<?php  if($cddopcao == 'I' ){echo $glbvars["dtmvtolt"];} else{ echo getByTagName($inf,'dtmvtolt');}?>" disabled />	
		
		<label for="cdoperad"><? echo utf8ToHtml('Operador:') ?></label>
		<input type="text" id="cdoperad" name="cdoperad" value="<?php if($cddopcao == 'I' ){echo $glbvars["cdoperad"].' - '.$glbvars["nmoperad"];} else{ echo getByTagName($inf,'cdoperad');}?>" disabled />	
		
	</fieldset>
	
</form>

<div id="divBotoesCadcco" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');return false;" >Voltar</a>
	
	<?php if($cddopcao == 'A' || $cddopcao == 'I' || $cddopcao == 'E'){?>
		<a href="#" class="botao" id="btConcluir"  onClick="confirma();return false;">Concluir</a>	
	<?}?>

</div>

<script type="text/javascript">
	
	exisbole = '<?echo $exisbole;?>';

	$('#divRegistrosRodape','#divCadcco').formataRodapePesquisa();	
	formataInformacoes();
	formataTabelaTarifas();
	$('#divBotoesFiltro').css('display','none');

	if('<?php echo $cddopcao;?>' == 'E' || '<?php echo $cddopcao;?>' == 'C'){

		$('input,select','#frmCadcco').desabilitaCampo();
		
		if('<?php echo $cddopcao;?>' == 'C' && '<?php echo getByTagName($inf,'flgregis');?>' == 1 ){

			buscaTarifas(1,30,'<?echo $nrconven;?>','<?php echo getByTagName($inf,'cddbanco');?>'); 
			 
		}

		$('#btVoltar','#divBotoesCadcco').focus();
	}else{
		  $('.campo:first', '#frmCadcco').focus();
	}
	
</script>

