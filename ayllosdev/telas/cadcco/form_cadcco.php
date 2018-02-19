<?php
/* * *********************************************************************

  Fonte: form_cadcco.php
  Autor: Jonathan - RKAM
  Data : Marco/2016                      Última Alteração: 12/09/2017

  Objetivo  : Mostrar valores da CADCCO.

  Alterações: 19/09/2016 - Incluida opcao "ACORDO" no campo "dsorgarq", Prj. 302 (Jean Michel)

              12/09/2017 - Inclusao da Agencia do Banco do Brasil. (Jaison/Elton - M459)
  

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
			<option value="ACORDO" <? echo getByTagName($inf,'dsorgarq') == 'ACORDO' ? 'selected' : '' ?> >Acordo</option>
			
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

		<label for="cdagedbb"><? echo utf8ToHtml('Ag&ecirc;ncia BB:') ?></label>
		<input type="text" id="cdagedbb" name="cdagedbb" value="<?php echo getByTagName($inf,'cdagedbb');?>" disabled />
				
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
		
		<label for="cdcartei"><? echo utf8ToHtml('Nro. Carteira/Varia&ccedil;&atilde;o:') ?></label>
		<input type="text" id="cdcartei" name="cdcartei" value="<?php echo getByTagName($inf,'cdcartei');?>" disabled />

		<label for="nrvarcar"><? echo utf8ToHtml('/') ?></label>
		<input type="text" id="nrvarcar" name="nrvarcar" value="<?php echo getByTagName($inf,'nrvarcar');?>" disabled />
		
		<label for="nrlotblq"><? echo utf8ToHtml('Lote Tarifa Impres.Boleto:') ?></label>
		<input type="text" id="nrlotblq" name="nrlotblq" value="<?php echo getByTagName($inf,'nrlotblq');?>" disabled />
		
		</br>
		
		
		<label for="flprotes"><? echo utf8ToHtml('Usar op&ccedil;&atilde;o protesto:') ?></label>
		<select id="flprotes" name="flprotes" alt="Informe situacao desejada (Sim/Nao)" onchange="onChangeProtesto()" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flprotes') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flprotes') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Não') ?> </option>
		</select>

		<label for="insrvprt"><? echo utf8ToHtml('Serviço de protesto:') ?></label>
		<select id="insrvprt" name="insrvprt" alt="Informe o serviço de protesto" disabled>
			<option value="0" id="insrvprt_0" disabled <? echo getByTagName($inf,'insrvprt') == 0 ? 'selected' : "" ?> >Desabilitado</option>
			<option value="1" id="insrvprt_1" disabled <? echo getByTagName($inf,'insrvprt') == 1 ? 'selected' : "" ?> >IEPTB</option>
			<option value="2" id="insrvprt_2" disabled <? echo getByTagName($inf,'insrvprt') == 2 ? 'selected' : "" ?> >Banco do Brasil</option>
		</select>	

		</br>
		
		<label for="qtdfloat"><? echo utf8ToHtml('Permitir Uso Float De:') ?></label>		
		<select id="qtdfloat" name="qtdfloat" value="<?php echo getByTagName($inf,'qtdfloat');?>" disabled>
			<option value="0" <?php echo (getByTagName($inf,'qtdfloat') == 0 ? "selected" : ""); ?>>0</option>
			<option value="1" <?php echo (getByTagName($inf,'qtdfloat') == 1 ? "selected" : ""); ?>>1</option> 
			<option value="2" <?php echo (getByTagName($inf,'qtdfloat') == 2 ? "selected" : ""); ?>>2</option> 
			<option value="3" <?php echo (getByTagName($inf,'qtdfloat') == 3 ? "selected" : ""); ?>>3</option> 
			<option value="4" <?php echo (getByTagName($inf,'qtdfloat') == 4 ? "selected" : ""); ?>>4</option> 
			<option value="5" <?php echo (getByTagName($inf,'qtdfloat') == 5 ? "selected" : ""); ?>>5</option> 
		</select>
		
		<label for="qtfltate"><? echo utf8ToHtml('At&eacute;:') ?></label>		
		<select id="qtfltate" name="qtfltate" value="<?php echo getByTagName($inf,'qtfltate');?>" disabled>
			<option value="0" <?php echo (getByTagName($inf,'qtfltate') == 0 ? "selected" : ""); ?>>0</option>
			<option value="1" <?php echo (getByTagName($inf,'qtfltate') == 1 ? "selected" : ""); ?>>1</option> 
			<option value="2" <?php echo (getByTagName($inf,'qtfltate') == 2 ? "selected" : ""); ?>>2</option> 
			<option value="3" <?php echo (getByTagName($inf,'qtfltate') == 3 ? "selected" : ""); ?>>3</option> 
			<option value="4" <?php echo (getByTagName($inf,'qtfltate') == 4 ? "selected" : ""); ?>>4</option> 
			<option value="5" <?php echo (getByTagName($inf,'qtfltate') == 5 ? "selected" : ""); ?>>5</option> 
		</select>
		<label class="rotulo-linha">dias</label>

		<label for="flserasa"><? echo utf8ToHtml('Usar op&ccedil;&atilde;o Serasa:') ?></label>
		<select id="flserasa" name="flserasa" alt="Informe situacao desejada (Sim/Nao)" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flserasa') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flserasa') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Não') ?> </option>
		</select>

		</br>
		
		<label for="qtdecini"><? echo utf8ToHtml('Usar Decurso de Prazo de:') ?></label>
		<input type="text" id="qtdecini" name="qtdecini" value="<?php echo getByTagName($inf,'qtdecini');?>" disabled />
		
		<label for="qtdecate"><? echo utf8ToHtml('At&eacute;:') ?></label>		
		<input type="text" id="qtdecate" name="qtdecate" value="<?php echo getByTagName($inf,'qtdecate');?>" disabled />
		<label class="rotulo-linha">dias</label>
		</br>
		
		<label for="fldctman"><? echo utf8ToHtml('Permite Desconto Manual:') ?></label>		
		<select id="fldctman" name="fldctman" alt="Informe situacao desejada (Sim/Nao)" disabled>
			<option value="1" <?php echo (getByTagName($inf,'fldctman') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'fldctman') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Não') ?> </option>
		</select>
		
		<label for="perdctmx"><? echo utf8ToHtml('% M&aacute;ximo de Desconto Manual:') ?></label>
		<input type="text" id="perdctmx" name="perdctmx" value="<?php echo formataMoeda(getByTagName($inf,'perdctmx'));?>" disabled />
		
		</br>
				
		<label for="flrecipr"><? echo utf8ToHtml('Usar Reciprocidade:') ?></label>		
		<select id="flrecipr" name="flrecipr" alt="Informe situacao desejada (Sim/Nao)" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flrecipr') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flrecipr') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Não') ?> </option>
		</select>
		
		<label for="flgapvco"><? echo utf8ToHtml('Obrigat&oacute;rio Aprova&ccedil;&atilde;o Coordenador:') ?></label>		
		<select id="flgapvco" name="flgapvco" alt="Informe situacao desejada (Sim/Nao)" disabled>
			<option value="1" <?php echo (getByTagName($inf,'flgapvco') == 1 ? "selected" : "");?>> <? echo utf8ToHtml('Sim') ?> </option> 
			<option value="0" <?php echo (getByTagName($inf,'flgapvco') == 0 ? "selected" : "");?>> <? echo utf8ToHtml('Não') ?> </option>
		</select>		
		</br>
		
		<label for="dtmvtolt"><? echo utf8ToHtml('Data altera&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dtmvtolt" name="dtmvtolt" value="<?php  if($cddopcao == 'I' ){echo $glbvars["dtmvtolt"];} else{ echo getByTagName($inf,'dtmvtolt');}?>" disabled />	
		
		<label for="cdoperad"><? echo utf8ToHtml('Operador:') ?></label>
		<input type="text" id="cdoperad" name="cdoperad" value="<?php if($cddopcao == 'I' ){echo $glbvars["cdoperad"].' - '.$glbvars["nmoperad"];} else{ echo getByTagName($inf,'cdoperad');}?>" disabled />	
		
		<input type="hidden" id="idprmrec" name="idprmrec" value="<?php echo getByTagName($inf,'idprmrec');?>" />

		<input type="hidden" id="dslogcfg" name="dslogcfg" value="<?php echo getByTagName($inf,'dslogcfg');?>" />

		<input type="hidden" id="glb_desmensagem" name="glb_desmensagem" value="" />

	</fieldset>
</form>

<div id="divBotoesCadcco" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');return false;" >Voltar</a>
	<a href="#" class="botao" id="btConcluir"  onClick="confirma();return false;">Concluir</a>	
	<a href="#" class="botao" id="btProsseguir"  style="display: none; text-align: right;">Prosseguir</a>	

</div>

<script type="text/javascript">

	exisbole = '<?echo $exisbole;?>';

	$('#divRegistrosRodape','#divCadcco').formataRodapePesquisa();	
	formataInformacoes();
	formataTabelaTarifas();
	$('#divBotoesFiltro').css('display','none');

	if('<?php echo $cddopcao;?>' == 'E' || '<?php echo $cddopcao;?>' == 'C'){

		$('input,select','#frmCadcco').desabilitaCampo();
		
		if('<?php echo $cddopcao;?>' == 'C'){

			$('#btProsseguir','#divBotoesCadcco').attr('onClick', 'mostraConfrp();return false;');
			 
		}

		$('#btVoltar','#divBotoesCadcco').focus();
	}else{
		$('#btProsseguir','#divBotoesCadcco').attr('onClick', 'validarDados();return false;');
		$('.campo:first', '#frmCadcco').focus();
	}	
	
</script>

