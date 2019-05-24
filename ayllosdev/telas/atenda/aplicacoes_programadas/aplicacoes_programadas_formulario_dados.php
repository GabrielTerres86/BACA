<?php 

	/************************************************************************
	 Fonte: aplicacoes_programadas_formulario_dados.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 05/09/2018
	                                                                  
	 Objetivo  : Formulário para dados das Aplicações Programada         
	                                                                  	 
	 Alterações: 13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)       
	             
				 27/07/2018 - Derivação para Aplicação Programada (Proj. 411.2 - CIS Corporate)	 

				 05/09/2018 - Inclusão do campo finalidade e redesenho do leioute (Proj. 411.2 - CIS Corporate) 

	*************************************************************************/
	
	if ($flgAlterar) {
		$desopcao = " - ALTERAR";
	} elseif ($flgSuspender) {
		$desopcao = " - SUSPENDER";
	}
	
?>
<div id="divDadosPoupanca">
	<form action="" class="condensado" method="post" name="frmDadosPoupanca" id="frmDadosPoupanca">
		<fieldset>
			<legend><? echo utf8ToHtml('Aplicação Programada') ?> <? echo !empty($legend) ? ' - ' . $legend : '' ?></legend>
									
			<label for="vlprerpp"><? echo utf8ToHtml('Valor da Prestação:') ?></label>
			<?php if ($flgAlterar) { ?>
				<input name="vlprerpp" type="text" class="campo" id="vlprerpp" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$poupanca[8]->cdata),2,",","."); ?>" />
			<?php } else { ?>
				<input name="vlprerpp" type="text" class="campoTelaSemBorda" id="vlprerpp" value="<?php echo number_format(str_replace(",",".",$poupanca[8]->cdata),2,",","."); ?>" readonly>
			<?php } ?>

			<label  for="diadebit"><? echo utf8ToHtml('Dia de débito:') ?></label>
			<?php if ($flgAlterar) { ?> 
				<input name="diadebit" type="text" class="campo" id="diadebit" autocomplete="no"  maxlength="2" value="<?php echo ltrim($diadebit, '0'); ?>"/>
			<?php } else { ?>
				<input name="diadebit" type="text" class="campoTelaSemBorda" id="diadebit" value="<?php echo ltrim($diadebit, '0'); ?>" readonly>
			<?php } ?>
			<br />
			<label for="dsfinali"><? echo utf8ToHtml('Finalidade:') ?></label>
			<?php if ($flgAlterar) { ?>
				<input name="dsfinali" type="text" class="campo" id="dsfinali" autocomplete="no" maxlength="20" value="<?php echo $dsfinali; ?>" />
			<?php } else { ?>
				<input name="dsfinali" type="text" class="campoTelaSemBorda" id="dsfinali" value="<?php echo $dsfinali; ?>" readonly>
			<?php } ?>
			<br />
			<label for="vlprepag"><? echo utf8ToHtml('Total Pago:') ?></label>
			<input name="vlprepag" type="text" class="campoTelaSemBorda" id="vlprepag" value="<?php echo number_format(str_replace(",",".",$poupanca[10]->cdata),2,",","."); ?>" readonly>
			<label for="qtprepag"><? echo utf8ToHtml('Qtd. Prestações Pagas:') ?></label>
			<input name="qtprepag" type="text" class="campoTelaSemBorda" id="qtprepag" value="<?php echo number_format(str_replace(",",".",$poupanca[9]->cdata),0,",","."); ?>" readonly>
			<br />
			
			<label for="vljuracu"><? echo utf8ToHtml('Total dos juros:') ?></label>
			<input name="vljuracu" type="text" class="campoTelaSemBorda" id="vljuracu" value="<?php echo number_format(str_replace(",",".",$poupanca[13]->cdata),2,",","."); ?>" readonly>
			<label for="vlrgtacu"><? echo utf8ToHtml('Total dos Resgates:') ?></label>
			<input name="vlrgtacu" type="text" class="campoTelaSemBorda" id="vlrgtacu" value="<?php echo number_format(str_replace(",",".",$poupanca[14]->cdata),2,",","."); ?>" readonly>
			<br />
			
			<label for="vlsdrdpp"><? echo utf8ToHtml('Saldo Atual:') ?></label>
			<input name="vlsdrdpp" type="text" class="campoTelaSemBorda" id="vlsdrdpp" value="<?php echo number_format(str_replace(",",".",$poupanca[12]->cdata),2,",","."); ?>" readonly>

			<br />
			<label class="rotulo"></label>
			<br />
			
			<label for="dtinirpp"><? echo utf8ToHtml('Início do Plano:') ?></label>
			<input name="dtinirpp" type="text" class="campoTelaSemBorda" id="dtinirpp" value="<?php echo $poupanca[15]->cdata; ?>" readonly>
			
			<label for="dtrnirpp"><? echo utf8ToHtml('Reinício do Plano:') ?></label>
			<input name="dtrnirpp" type="text" class="campoTelaSemBorda" id="dtrnirpp" value="<?php echo $poupanca[16]->cdata; ?>" readonly>
			<br />
			
			<label for="dtcancel"><? echo utf8ToHtml('Cancelado Em:') ?></label>
			<input name="dtcancel" type="text" class="campoTelaSemBorda" id="dtcancel" value="<?php echo $poupanca[18]->cdata; ?>" readonly>
			
			<label for="dtaltrpp"><? echo utf8ToHtml('Última Alteração:') ?></label>
			<input name="dtaltrpp" type="text" class="campoTelaSemBorda" id="dtaltrpp" value="<?php echo $poupanca[17]->cdata; ?>" readonly>
			<br />
			
			<label for="dtdebito"><? echo utf8ToHtml('Próximo Débito:') ?></label>
			<input name="dtdebito" type="text" class="campoTelaSemBorda" id="dtdebito" value="<?php echo $poupanca[6]->cdata; ?>" readonly>


			<br />
			<label class="rotulo"></label>
			<br />
			
			<?php if ($flgSuspender) { ?>
			
				<label for="nrmesusp"><? echo utf8ToHtml('Entre com a quantidade de meses para suspensão:') ?></label>
				<input name="nrmesusp" type="text" class="campo" id="nrmesusp" value="0" autocomplete="no" />
				<br />
				
			<?php } elseif (!$flgAlterar && trim($poupanca[23]->cdata) <>  "") { ?>
				
				<label for="dsmsgsaq"><? echo utf8ToHtml('') ?></label>
				<input name="dsmsgsaq" type="text" class="campoTelaSemBorda" id="dsmsgsaq" value="*** <?php echo $poupanca[23]->cdata; ?> ***" readonly>
				<br />
				
			<?php } ?>
			
			<label for="dspesqui"><? echo utf8ToHtml('Pesquisa:') ?></label>
			<input name="dspesqui" type="text" class="campoTelaSemBorda" id="dspesqui" value="<?php echo $poupanca[4]->cdata."-".formataNumericos("999",$poupanca[1]->cdata,"")."-".formataNumericos("999",$poupanca[2]->cdata,"")."-".formataNumericos("999999",$poupanca[3]->cdata,""); ?>" readonly>
			
			<label for="dssitrpp"><? echo utf8ToHtml('Situação:') ?></label>
			<input name="dssitrpp" type="text" class="campoTelaSemBorda" id="dssitrpp" value="<?php echo $poupanca[19]->cdata; ?>" readonly>
							
		</fieldset>
	</form>
	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarDivPrincipal();return false;" />
		<?php if ($flgAlterar || $flgSuspender) { ?>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="<?php if ($flgAlterar) { echo "validarAlteracaoAplicacao();"; } else { echo "validarSuspensaoAplicacao();"; } ?>return false;" />
		<?php } else { ?>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/extrato.gif" onClick="extratoAplicacaoProgramada();return false;" />
		<?php } ?>
	</div>
</div>

<div id="divExtratoPoupanca"></div>

<script type="text/javascript">
controlaLayout('frmDadosPoupanca');
<?php if ($flgAlterar) { ?>
$("#vlprerpp","#frmDadosPoupanca").setMask("DECIMAL","zzz,zzz.zz9,99","","");
$("#diadebit","#frmDadosPoupanca").setMask("INTEGER","99","","");
var width = "300px";
<?php } elseif ($flgSuspender) { ?>
$("#nrmesusp","#frmDadosPoupanca").setMask("INTEGER","zz9","","");
var width = "325px";
<?php } else { ?>
var width = "<?php if (trim($poupanca[23]->cdata) <> "") { echo "325px"; } else { echo "300px"; } ?>";
<?php } ?>

// Aumenta tamanho do div onde o conteúdo da opção será visualizado
$("#divConteudoOpcao").css("height",width);

$("#divPoupancasPrincipal").css("display","none");
$("#divExtratoPoupanca").css("display","none");
$("#divOpcoes").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
