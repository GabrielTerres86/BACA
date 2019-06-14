<? 
/*!
 * FONTE        : form_principal.php
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : 06/04/2015 
 * OBJETIVO     : Formulário da rotina PRINCIPAL
 
 * ALTERAÇÕES   : 22/12/2015 - Variável para alteração do número da proposta de limite de crédito. (Lunelli - SD 360072 [M175])
 *                10/10/2016 - Remover verificacao de digitalizaco para o botao de consultar imagem (Lucas Ranghetti #510032)
 *                15/12/2016 - Alterado tag do botão consultar imagem href para Onclick adaptando-se a função controlaFoco() (Evandro Guaranha-Mout's TI #562864)
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *				  06/03/2018 - Adicionado campo idcobope. (PRJ404 Reinert)
 *                22/03/2018 - Implementado nova situação para considerar Cancelamento Automático de Limite
 *							   por inadimplência e também novo campo onde contém a data do cancelamento automático. (Simas - Amcom)
 *                13/04/2018 - Incluida chamada da function validaAdesaoValorProduto. PRJ366 (Lombardi)
 *
 */	
?>
<form action="" method="post" name="frmDadosLimiteCredito" id="frmDadosLimiteCredito" class="formulario">
		
	<input type="hidden" name="dsobserv" id="dsobserv" value="<?php echo $dsobserv ?>">

	<div id="divDadosPrincipal">
		<input id="idcobope" name="idcobope" type="hidden" value="<?php echo $idcobope; ?>" />
		<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>	
		<input id="vllimite" name="vllimite" type="text" value="<?php echo number_format(str_replace(",",".",$vllimite),2,",",".")."  ".$dslimcre; ?>" />	

		<label for="dtmvtolt"><? echo utf8ToHtml('Contrata&ccedil;&atilde;o:') ?></label>	
		<input id="dtmvtolt" name="dtmvtolt" type="text" value="<?php echo $dtmvtolt; ?>" />
		<br />
		
		<label for="cddlinha"><? echo utf8ToHtml('Linha:') ?></label>	
		<input id="cddlinha" name="cddlinha" type="text" value="<?php echo $cddlinha."  ".$dsdlinha; ?>" />

		<label for="dtfimvig"><? echo utf8ToHtml('Data de T&eacute;rmino:') ?></label>	
		<input id="dtfimvig" name="dtfimvig" type="text" value="<?php echo $dtfimvig; ?>" />
		<br />
		
		<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>	
		<input id="nrctrlim" name="nrctrlim" type="text" value="<?php echo formataNumericos("zzz.zzz.zzz",$nrctrlim,"."); ?>" />	

		<label for="qtdiavig"><? echo utf8ToHtml('Vig&ecirc;ncia:') ?></label>	
		<input id="qtdiavig" name="qtdiavig" type="text" value="<?php echo $qtdiavig; ?> dias" />
		<br />
		
		<label for="dstprenv"><? echo utf8ToHtml('Tipo Renova&ccedil;&atilde;o:') ?></label>	
		<input id="dstprenv" name="dstprenv" type="text" value="<?= $dstprenv ?>" />	

		<label for="qtrenova"><? echo utf8ToHtml('Renova&ccedil;&otilde;es:') ?></label>
		<input id="qtrenova" name="qtrenova" type="text" value="<?= $qtrenova ?>" />
		
		<label for="dtrenova"><? echo utf8ToHtml('Data Renova&ccedil;&atilde;o:') ?></label>
		<input id="dtrenova" name="dtrenova" type="text" value="<?= $dtrenova ?>" />
		<br />
		
		<label for="dtcanlim"><? echo utf8ToHtml('Data Cancelamento:') ?></label>	
		<input id="dtcanlim" name="dtcanlim" type="text" value="<?php echo $dtcanlim; ?>" />
		<br />
		
		<label for="dsencfi1"><? echo utf8ToHtml('Encargos Financeiros:') ?></label>	
		<input id="dsencfi1" name="dsencfi1" type="text" style="width: 322px;" value="<?php echo $dsencfi1; ?>" />
		<br />
		
		<label for="dsencfi2"></label>	
		<input id="dsencfi2" name="dsencfi2" type="text" style="width: 322px;" value="<?php echo $dsencfi2; ?>" />
		<br />
		
		<label for="dsencfi3"></label>	
		<input id="dsencfi3" name="dsencfi3" type="text" style="width: 322px;" value="<?php echo $dsencfi3; ?>" />

		
		<label for="dssitlli"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>	
		<input id="dssitlli" name="dssitlli" type="text" value="<?php echo $dssitlli.(trim($dsmotivo) == "" ? "" : " - ".$dsmotivo); ?>" />	

		<label for="dtultmaj"><? echo utf8ToHtml('Ult. Majora&ccedil;&atilde;o:') ?></label>	
		<input id="dtultmaj" name="dtultmaj" type="text" value="<?php echo $dtultmaj; ?>" />

		<br />

		<label for="nmoperad"><? echo utf8ToHtml('Operador(a):') ?></label>	
		<input id="nmoperad" name="nmoperad" type="text" value="<?php echo $nmoperad; ?>" />
		<br />

		<label for="nmopelib"><? echo utf8ToHtml('Op. Libe:') ?></label>	
		<input id="nmopelib" name="nmopelib" type="text" value="<?php echo $nmopelib; ?>" />
		<br />

		<label for="flgenvio"><? echo utf8ToHtml('Comit&ecirc;:') ?></label>	
		<input id="flgenvio" name="flgenvio" type="text" value="<?php echo $flgenvio; ?>" />

		<br />	
	
	</div>
	
	<div id="divDadosObservacoes" style="display: none;">
		<fieldset class="fsObservacoes">
			<legend> Observa&ccedil;&otilde;es </legend>			
			<textarea name="dsobserv" id="dsobserv" rows="5" style="width:95%">  </textarea>
		</fieldset>		

		<div id="divBotoes">
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="escondeObservacoes(); return false;">
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="confirmaAlteracaoObservacao('<?php echo $nrctrpro; ?>');return false;">
		</div>
	</div>
	
	<?php if ((in_array("C",$glbvars["opcoesTela"]) && strtolower($flgpropo) == "yes") || (intval($nrctrlim) > 0 && strtolower($flgpropo) == "no")) { ?>
		
		<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";<?php if (in_array("C",$glbvars["opcoesTela"]) && strtolower($flgpropo) == "yes") { ?> changeAbaPropLabel("Alterar Limite"); <? }else{?> changeAbaPropLabel("Novo Limite"); <? } ?> </script>
		 <div id="divDadosPrincipal_2">
			 <table align="center" border="0" cellpadding="0" cellspacing="3"> 		
				<tr>	
					<?php if (in_array("C",$glbvars["opcoesTela"]) && strtolower($flgpropo) == "yes") { ?>
					<td style="background-color: #E3E2DD;" class="txtNormal" align="center">&nbsp;&nbsp;&nbsp;Novo contrato <strong><?php echo formataNumericos("zzz.zzz.zzz",$nrctrpro,"."); ?></strong> da linha de cr&eacute;dito <strong><?php echo $cdlinpro; ?></strong>&nbsp;&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;no valor de R$ <strong><?php echo number_format(str_replace(",",".",$vllimpro),2,",","."); ?></strong>, <?php if ($flgenpro == "no") { ?>nao <?php } ?> enviado a sede.&nbsp;&nbsp;&nbsp;</td>
					 <td class="txtNormalBold" align="center">>></td> &nbsp;
					
					<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/confirmar_novo_limite.gif" onClick="showConfirmacao('Deseja confirmar novo ' + strTitRotinaLC + '?','Confirma&ccedil;&atilde;o - Aimaro','confirmaNovoLimite(1,false)',metodoBlock,'sim.gif','nao.gif');return false;"></td>					
					
					<? if (strtoupper($dssitlli) == "ATIVO"){ ?>
						<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/renovar.gif" onClick="showConfirmacao('Deseja renovar o ' + strTitRotinaLC + ' atual?','Confirma&ccedil;&atilde;o - Aimaro','validaAdesaoValorProduto(\'renovarLimiteAtual(<?php echo intval($nrctrlim); ?>)\',<?php echo $vllimite; ?>)',metodoBlock,'sim.gif','nao.gif');return false;"></td>
					<?	
					   }
					} 
					?>
				</tr>
			</table> 
		 </div>
				
		<div id="divBotoes" align="center">
			<?php if (intval($nrctrlim) > 0 && strtolower($flgpropo) == "no") { ?>
				<a target="_blank" onClick="showConfirmacao('Deseja cancelar o ' + strTitRotinaLC + ' atual?','Confirma&ccedil;&atilde;o - Aimaro','cancelarLimiteAtual(<?php echo intval($nrctrlim); ?>)',metodoBlock,'sim.gif','nao.gif');return false;">
				<img src="<?php echo $UrlImagens; ?>botoes/cancelar_limite_atual.gif" /></a>
				
				<? if (strtoupper($dssitlli) == "ATIVO"){ ?>
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/renovar.gif" onClick="showConfirmacao('Deseja renovar o ' + strTitRotinaLC + ' atual?','Confirma&ccedil;&atilde;o - Aimaro','validaAdesaoValorProduto(\'renovarLimiteAtual(<?php echo intval($nrctrlim); ?>)\',<?php echo $vllimite; ?>)',metodoBlock,'sim.gif','nao.gif');return false;">
				<? } ?>
				
				<a onclick="window.open('http://<?php echo $GEDServidor;?>/smartshare/clientes/viewerexterno.aspx?tpdoc=<?php echo $tpdocmto ?>&conta=<?php echo formataContaDVsimples($nrdconta); ?>&contrato=<?php echo formataNumericos("z.zzz.zz9",$nrctrlim,"."); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>', '_blank')">						
						<img src="<? echo $UrlImagens; ?>botoes/consultar_imagem.gif" />
					</a> 
				
			<?php } ?>
		</div>
	<?php } ?>
	
</form>

<form action="<?php echo $UrlSite; ?>telas/atenda/limite_credito/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nrctrlim" id="nrctrlim" value="">			
<input type="hidden" name="idimpres" id="idimpres" value="">
<input type="hidden" name="flgemail" id="flgemail" value="">
<input type="hidden" name="flgimpnp" id="flgimpnp" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">		
</form>					


<script type="text/javascript">
    
	formataPrincipal();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	nrctrpro = "<?php echo $nrctrpro;  ?>";
	situacao_limite = "<?php echo strtoupper($dssitlli);  ?>";
	
</script>