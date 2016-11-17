<?php 
/************************************************************************
Fonte: formulario_cartao.php                                     
Autor: David                                                     
Data : Outubro/2008
                                                                
Objetivo  : Formul&aacute;rio dados de Cart&atilde;o Magn&eacute;tico

Alterações	13/07/2011 - Alterado para layout padrão (Rogerius - DB1).
		
		    23/07/2015 - Remover os campos Limite, Forma de Saque e Recido
                         de entrega. (James) 
						 
			08/10/2015 - Reformulacao cadastral (Gabriel-RKAM)			 
************************************************************************/
?>
<div id="divFormCartaoMag">

	<form method="post" name="frmDadosCartaoMagnetico" id="frmDadosCartaoMagnetico" class="formulario">
		
		<fieldset>
		<legend><? echo $legend ?></legend>
		
		<label for="nmtitcrd">Titular:</label>
		<?php 
		if ($flgSolicitacao && $magnetico[3]->cdata == "1") { 
		?>
			<script type="text/javascript">var titular = new Array();</script>
			<select name="tpusucar" id="tpusucar" class="campo" style="width: 130px;">
			<?php for ($i = 0; $i < count($titular); $i++) { ?>						
				<script type="text/javascript">titular[<?php echo $titular[$i]->tags[0]->cdata; ?>] = "<?php echo $titular[$i]->tags[2]->cdata; ?>";</script>				
				<option value="<?php echo $titular[$i]->tags[0]->cdata; ?>"<?php if ($titular[$i]->tags[3]->cdata == "yes") { echo " selected"; } ?>><?php echo $titular[$i]->tags[1]->cdata; ?></option>
			<?php }  ?>
			</select>
			<input name="nmtitcrd" type="text" class="campo" id="nmtitcrd" style="width: 217px;" value="<?php echo $magnetico[0]->cdata; ?>">

		<?php } else {  ?>
		
			<?php
			if ($flgSolicitacao) {
				$nmtitcrd = $titular[0]->tags[2]->cdata;
			?>
			<input name="tpusucar" type="hidden" id="tpusucar" value="<?php echo $titular[0]->tags[0]->cdata; ?>">
			<?php
			} else {
				$nmtitcrd = ($magnetico[3]->cdata == "1" ? $magnetico[4]->cdata." - " : "").$magnetico[0]->cdata;
			}
			?>
			<input name="nmtitcrd" type="text" class="campoTelaSemBorda" id="nmtitcrd" style="width: 351px;" value="<?php echo $nmtitcrd; ?>" readonly>
		
		<?php } ?>

		<br />
		
		<label for="nrcartao">N&uacute;mero:</label>	
		<input name="nrcartao" type="text" id="nrcartao" value="<?php echo $magnetico[1]->cdata; ?>" />
	
		<label for="nrseqcar">Sequencial:</label>
		<input name="nrseqcar" type="text" id="nrseqcar" value="<?php echo formataNumericos("zzz.zzz.zz9",$magnetico[2]->cdata,"."); ?>" />

		<br />
	
		<label for="dtemscar">Emitido Em:</label>
		<input name="dtemscar" type="text" id="dtemscar" value="<?php echo $magnetico[13]->cdata; ?>" />
		
		<br />
		
		<label for="dscarcta">Tipo de Cart&atilde;o:</label>
		<input name="dscarcta" type="text"id="dscarcta" value="<?php echo $magnetico[6]->cdata; ?>" />
		
		<label for="dtvalcar">V&aacute;lido At&eacute;:</label>
		<input name="dtvalcar" type="text" id="dtvalcar" value="<?php echo $magnetico[14]->cdata; ?>" />
		
		<br />
		
		<label for="dssitcar">Situa&ccedil;&atilde;o:</label>
		<input name="dssitcar" type="text" id="dssitcar" value="<?php echo $magnetico[8]->cdata; ?>" />
		
		<label for="dtentcrm">Entregue Em:</label>
		<input name="dtentcrm" type="text" id="dtentcrm" value="<?php echo $magnetico[12]->cdata; ?>" />
		
		<br />
		
		<label for="dtcancel">Cancelado Em:</label>
		<input name="dtcancel" type="text" id="dtcancel" value="<?php echo $magnetico[5]->cdata; ?>" />
		
		<br />
		
		<label for="dttransa">Data da Transa&ccedil;&atilde;o:</label>
		<input name="dttransa" type="text" id="dttransa" value="<?php echo $magnetico[10]->cdata; ?>" />
		
		<label for="hrtransa">Hora da Transa&ccedil;&atilde;o:</label>
		<input name="hrtransa" type="text" id="hrtransa" value="<?php echo $magnetico[11]->cdata; ?>" />
		
		<br />
		
		<label for="nmoperad">Operador:</label>
		<input name="nmoperad" type="text" id="nmoperad" value="<?php echo $magnetico[9]->cdata; ?>" />

		</fieldset>
		
		<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/<?php if ($flgSolicitacao) { echo "cancelar"; } else { echo "voltar"; } ?>.gif" onClick="voltarDivPrincipal(185);return false;">

		<?php 
		if ($flgSolicitacao) {
			if ($flgSolicitacao) {
				if ($cddopcao == "A") {
					$fncBotao = "validarDadosAlteracao();";
					$nomeBotao = "alterar";
				} elseif ($cddopcao == "I") {
					$fncBotao = "validarDadosInclusao();";
					$nomeBotao = "incluir";
				}
			}
		?>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/<?php echo $nomeBotao; ?>.gif" onClick="<?php echo $fncBotao; ?>return false;">
		<?php
		} 
		?>
		</div>
		
		
	</form>
	
</div>

<script>
// Formata layout
formataCartao('<? echo $cddopcao; ?>');
</script>
