<? 
/*!
* FONTE        : formulario_conta_corrente.php
* CRIAÇÃO      : Rodolpho Telmo (DB1)
* DATA CRIAÇÃO : 13/05/2010 
* OBJETIVO     : Formulário da rotina CONTA CORRENTE da tela de CONTAS
* --------------
* ALTERAÇÕES   : 08/02/2013 - Incluir novo label de Grau de acesso (Lucas R.)
* --------------
*                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
*
*                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
*                             'flgcrdpa' (Jaison).	
*  
*  	             11/08/2014 - Retirar campos do SPC e Serasa (Jonata-RKAM).
*
*				 28/08/2014 - Incluir label dscadpos Projeto Cadastro Positvo 
*						      (Lucas R./Thiago Rodrigues)
*
*				 10/10/2014 - (Chamado 184712) Alteracao do botao Gerar Conta Consorcio
*							  (Tiago Castro - RKAM).
*
*                05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
*
*                11/08/2015 - Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi).
* 
*				 27/10/2015 - Projeto 131 - Inclusão do campo “Exige Assinatura Conjunta em Autoatendimento”
*							  (Jean Michel). 
*				
*				 02/11/2015 - Melhoria 126 - Encarteiramento de cooperados (Heitor - RKAM)
*
*                07/01/2016 - Remover campo de Libera Credito Pre Aprovado (Anderson).
*
*                19/07/2016 - Correcao do erro no campo conta consorcio. SD 479874. (Carlos R.)
*
*
*			     15/07/2016 - Incluir flg de devolução automatica - Melhoria 69(Lucas Ranghetti #484923)
*/	

//recupera tag com a conta consorcio
$vr_nrctacns = getByTagName($registro,'nrctacns');

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "    <inpessoa>". getByTagName($registro,'inpessoa') ."</inpessoa>";
$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0006", "BUSCAR_TPCONTA_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);	

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------
if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
}

$tipos_conta = $xmlObj->roottag->tags[0]->tags;


//recupera tag com a conta consorcio
$vr_nrctacns = getByTagName($registro,'nrctacns');

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0006", "BUSCAR_SITUACOES_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);	

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------
if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
}

$situacoes = $xmlObj->roottag->tags[0]->tags;

?>
<script>
<?

$idindividual = 0;
$idconjunta_solidaria = 0;
//$idconjunta_nao_solidaria = 0;

foreach($tipos_conta as $tipo_conta) {
	if (getByTagName($tipo_conta->tags,'cdtipo_conta') == getByTagName($registro,'cdtipcta')) {
		$idindividual = getByTagName($tipo_conta->tags,'idindividual');
		$idconjunta_solidaria = getByTagName($tipo_conta->tags,'idconjunta_solidaria');
		//$idconjunta_nao_solidaria = getByTagName($tipo_conta->tags,'idconjunta_nao_solidaria');
	}
	?>
	var tipoConta = {
		cdtipo_conta: <? echo getByTagName($tipo_conta->tags,'cdtipo_conta');?>,
		idindividual: <? echo getByTagName($tipo_conta->tags,'idindividual');?>,
		idconjunta_solidaria: <? echo getByTagName($tipo_conta->tags,'idconjunta_solidaria');?>
		/*idconjunta_nao_solidaria: <? echo getByTagName($tipo_conta->tags,'idconjunta_nao_solidaria');?>*/
	}
	tiposConta[<?echo getByTagName($tipo_conta->tags,'cdtipo_conta');?>] = tipoConta;
	<?
}
?>
</script>
<form name="frmContaCorrente" id="frmContaCorrente" class="formulario">
	<fieldset>
		<legend>Principal</legend>

		<label for="cdagepac">PA:</label>
		<input name="cdagepac" id="cdagepac" type="text" value="<? echo getByTagName($registro,'cdagepac') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsagepac" id="dsagepac" type="text" value="<? echo getByTagName($registro,'dsagepac') ?>" />
		
		<label for="cdsitdct">Situa&ccedil;&atilde;o</label>
		<select id="cdsitdct" name="cdsitdct">
			<?
				foreach($situacoes as $situacao) {
				?> 
					<option value="<? echo getByTagName($situacao->tags,'cdsituacao'); ?>" <? if (getByTagName($registro,'cdsitdct') == getByTagName($situacao->tags,'cdsituacao') ){ echo ' selected'; } ?>>
						<? echo getByTagName($situacao->tags,'cdsituacao') . ' - ' . getByTagName($situacao->tags,'dssituacao'); ?>
					</option>
				<?
				}
			?>
		</select>	
		<br />
		
		<label for="cdtipcta">Tipo Conta:</label>
		<select name="cdtipcta" id="cdtipcta">
			<?
				foreach($tipos_conta as $tipo_conta) {
				?> 
					<option value="<? echo getByTagName($tipo_conta->tags,'cdtipo_conta'); ?>" <? if (getByTagName($registro,'cdtipcta') == getByTagName($tipo_conta->tags,'cdtipo_conta') ){ echo ' selected'; } ?>>
						<? echo getByTagName($tipo_conta->tags,'cdtipo_conta') . ' - ' . getByTagName($tipo_conta->tags,'dstipo_conta'); ?>
					</option>
				<?
				}
			?>
		</select>
		
		<label for="cdbcochq">Banco Emiss&atilde;o do Cheque</label>
		<input name="cdbcochq" id="cdbcochq" type="text" value="<? echo getByTagName($registro,'cdbcochq') ?>" />
		<br />
		
		<label for="cdcatego" <?php echo getByTagName($registro,'inpessoa') > 1 ? 'style="display: none";' : '' ?>>Categoria</label>
		<select name="cdcatego" id="cdcatego" <?php echo getByTagName($registro,'inpessoa') > 1 ? 'style="display: none";' : '' ?>>
			<? if ($idindividual == 1) { ?> <option value="1" <? if (getByTagName($registro,'cdcatego') == 1) echo 'Selected'; ?>>Individual</option> <? } ?>
			<? if ($idconjunta_solidaria == 1) { ?> <option value="2" <? if (getByTagName($registro,'cdcatego') == 2) echo 'Selected'; ?>>Conjunta</option> <? } ?>
			<!--< ? if ($idconjunta_solidaria == 1) { ?> <option value="1" < ? if (getByTagName($registro,'cdcatego') == 1) echo 'Selected'; ?>>Conjunta solid&aacute;ria</option> < ? } ?>
			< ? if ($idconjunta_nao_solidaria == 1) { ?> <option value="2" < ? if (getByTagName($registro,'cdcatego') == 2) echo 'Selected'; ?>>Conjunta n&atilde;o solid&aacute;ria</option> < ? } ?>-->
		</select>
		<br />
		
		<label for="nrdctitg">Conta/ITG:</label>
		<input name="nrdctitg" id="nrdctitg" type="text" value="<? echo getByTagName($registro,'nrdctitg') ?>" />
		<input name="dssititg" id="dssititg" type="text" value="<? echo getByTagName($registro,'dssititg') ?>" />
		
		<label for="cdagedbb">Age. ITG:</label>
		<input name="cdagedbb" id="cdagedbb" type="text" value="<? echo getByTagName($registro,'cdagedbb') ?>" />

		<label for="cdbcoitg">Bco. ITG:</label>
		<input name="cdbcoitg" id="cdbcoitg" type="text" value="<? echo getByTagName($registro,'cdbcoitg') ?>" />	
		
		<br />
		
		<label for="nrctacns"> Conta Consorcio: </label>
		<input name="nrctacns" id="nrctacns" type="text" value="<?php echo ( $vr_nrctacns > 0 ) ? formataContaDVsimples($vr_nrctacns) : ''; ?>" />		
		<label for="dscadpos"> Cadastro Positvo: </label>
		<input name="dscadpos" id="dscadpos" type="text" value="<? echo getByTagName($registro,'dscadpos') ?>" />
		
	</fieldset>
	
	<fieldset>
		<legend>Geral</legend>	

		<label for="flgiddep"><? echo utf8ToHtml('Identifica Depósito:') ?></label>
			<input name="flgiddep" id="flgiddepOp1" type="radio" class="radio" value="yes" <? if (getByTagName($registro,'flgiddep') == 'yes') { echo ' checked'; } ?> />
			<label for="flgiddepOp1" class="radio">Sim</label>
			<input name="flgiddep" id="flgiddepOp2" type="radio" class="radio" value="no" <? if (getByTagName($registro,'flgiddep') == 'no') { echo ' checked'; } ?> />
			<label for="flgiddepOp2" class="radio"><? echo utf8ToHtml('Não') ?></label>
		
		<label for="tpextcta">Tipo Extrato Conta:</label>
			<input name="tpextcta" id="tpextctaOp1" type="radio" class="radio" value="0" <? if (getByTagName($registro,'tpextcta') == '0') { echo ' checked'; } ?> />
			<label for="tpextctaOp1" class="radio"><? echo utf8ToHtml('Não Emite') ?></label>
			<input name="tpextcta" id="tpextctaOp2" type="radio" class="radio" value="1" <? if (getByTagName($registro,'tpextcta') == '1') { echo ' checked'; } ?> />
			<label for="tpextctaOp2" class="radio">Mensal</label>	
			<input name="tpextcta" id="tpextctaOp3" type="radio" class="radio" value="2" <? if (getByTagName($registro,'tpextcta') == '2') { echo ' checked'; } ?> />
			<label for="tpextctaOp3" class="radio">Quinzenal</label>			
		<br />
			
		<label for="tpavsdeb">Emitir Aviso:</label>
			<input name="tpavsdeb" id="tpavsdebOp1" type="radio" class="radio" value="1" <? if (getByTagName($registro,'tpavsdeb') == '1') { echo ' checked'; } ?> />
			<label for="tpavsdebOp1" class="radio">Sim</label>		
			<input name="tpavsdeb" id="tpavsdebOp2" type="radio" class="radio" value="0" <? if (getByTagName($registro,'tpavsdeb') == '0') { echo ' checked'; } ?> />
			<label for="tpavsdebOp2" class="radio"><? echo utf8ToHtml('Não') ?></label>						
			
		<label for="cdsecext">Destino Extrato:</label>
			<input name="cdsecext" id="cdsecext" type="text" value="<? echo getByTagName($registro,'cdsecext') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dssecext" id="dssecext" type="text" value="<? echo getByTagName($registro,'dssecext') ?>" />	
		<br />
			
		<?php $disabled=($glbvars['nvoperad']!=3) ? "disabled" : ""; ?>

		<label for="flgrestr">Grau de Acesso:</label>
			<input name="flgrestr" id="flgrestrOp1" type="radio" class="radio" value="yes" <? if (getByTagName($registro,'flgrestr') == 'yes') { echo ' checked '; } echo $disabled; ?> />
			<label for="flgrestrOp1" class="radio">Restrito</label>		
			<input name="flgrestr" id="flgrestrOp2" type="radio" class="radio" value="no" <? if (getByTagName($registro,'flgrestr') == 'no') { echo ' checked '; } echo $disabled; ?> />
			<label for="flgrestrOp2" class="radio"><? echo utf8ToHtml('Liberado') ?></label>
		
		<label for="cdconsultor">Consultor:</label>
			<input name="cdconsultor" id="cdconsultor" type="text" value="<? echo $cdconsul ?>"/>
			<a id="pesqconsul" name="pesqconsul" href="#" onClick="mostrarPesquisaConsultor('#frmContaCorrente,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
			<input name="nmconsultor" id="nmconsultor" type="text" value="<? echo $nmconsul ?>"/>

		<br />
		
        <label for="indserma"><? echo utf8ToHtml('Serviço de Malote:') ?></label>
            <input name="indserma" id="indsermaOp1" type="radio" class="radio" value="yes" <? if (getByTagName($registro,'indserma') == 'yes') { echo ' checked'; } ?> />
            <label for="indsermaOp1" class="radio">Sim</label>		
		<input name="indserma" id="indsermaOp2" type="radio" class="radio" value="no" <?php if (getByTagName($registro,'indserma') == 'no') { echo ' checked'; } ?> />
		<label for="indsermaOp2" class="radio"><?php echo utf8ToHtml('Não') ?></label>
		
		<label for="flgdevolu_autom"><? echo utf8ToHtml('Dev. Aut. Cheques:') ?></label>
            <input name="flgdevolu_autom" id="flgdevolu_automOp1" type="radio" class="radio" value="1" <? if ($flgdevolu_autom == 1) { echo ' checked'; } ?> />
            <label for="flgdevolu_automOp1" class="radio">Sim</label>		
		<input name="flgdevolu_autom" id="flgdevolu_automOp2" type="radio" class="radio" value="0" <?php if ($flgdevolu_autom == 0) { echo ' checked'; } ?> />
		<label for="flgdevolu_automOp2" class="radio"><?php echo utf8ToHtml('Não') ?></label>
		
		<br />
		<?php if(getByTagName($registro,'inpessoa') > 1){ ?>
			<label class="rotulo" for="idastcjt"><?php echo utf8ToHtml('Exige Assinatura Conjunta em Autoatendimento:') ?></label>
			<input name="idastcjt" id="idastcjtOp1" type="radio" class="radio" value="1" <?php if (getByTagName($registro,'idastcjt') == '1') { echo ' checked'; } ?> />
			<label for="idastcjtOp1" class="radio">Sim</label>		
			<input name="idastcjt" id="idastcjtOp2" type="radio" class="radio" value="0" <?php if (getByTagName($registro,'idastcjt') == '0') { echo ' checked'; } ?> />
			<label for="idastcjtOp2" class="radio"><?php echo utf8ToHtml('Não') ?></label>
			<br />
		<?php } ?>
		
	</fieldset>
	
	<fieldset>
		<legend>Consultas</legend>
		
		<label for="dtcnsscr">Consulta SCR:</label>
		<input name="dtcnsscr" id="dtcnsscr" type="text" value="<? echo getByTagName($registro,'dtcnsscr') ?>" />
		
		<input name="inadimpl" id="inadimpl" type="hidden" value="<? echo getByTagName($registro,'inadimpl') ?>" />
		<input name="dtcnsspc" id="dtcnsspc" type="hidden" value="<? echo getByTagName($registro,'dtcnsspc') ?>" />
		<input name="dtdsdspc" id="dtdsdspc" type="hidden" value="<? echo getByTagName($registro,'dtdsdspc') ?>" />		
		
		<label for="inlbacen">CCF:</label>
			<input name="inlbacen" id="inlbacen_1" type="radio" class="radio" value="1" <? if (getByTagName($registro,'inlbacen') == '1') { echo ' checked'; } ?> />
			<label for="inlbacen_1" class="radio">Sim</label>		
			<input name="inlbacen" id="inlbacen_2" type="radio" class="radio" value="0" <? if (getByTagName($registro,'inlbacen') == '0') { echo ' checked'; } ?> />
			<label for="inlbacen_2" class="radio"><? echo utf8ToHtml('Não') ?></label>								
		<br />
		
	</fieldset>
	
	<fieldset>
		<legend>Datas</legend>
		
		<label for="dtabtcoo">Como Cooperado => Abertura:</label>
		<input name="dtabtcoo" id="dtabtcoo" type="text" value="<? echo getByTagName($registro,'dtabtcoo') ?>" />
		
		<label for="dtelimin">Encerramento:</label>
		<input name="dtelimin" id="dtelimin" type="text" value="<? echo getByTagName($registro,'dtelimin') ?>" />
		<br />
		
		<label for="dtabtcct">Como Correntista => Abertura:</label>
		<input name="dtabtcct" id="dtabtcct" type="text" value="<? echo getByTagName($registro,'dtabtcct') ?>" />		
		
		<label for="dtdemiss">Demiss&atilde;o:</label>
		<input name="dtdemiss" id="dtdemiss" type="text" value="<? echo getByTagName($registro,'dtdemiss') ?>" />
	</fieldset>
	
</form>

<div id="divBotoes">
	<? if ( in_array($operacao,array('AC','FA','')) ) { ?> 

		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="encerraRotina(true);" />
		
		<? if ($btsolitg == 'yes') { ?> <input type="image" id="btReativar" src="<? echo $UrlImagens; ?>botoes/solicitar_reativar_itg.gif" onClick="controlaOperacao('VS');" /> <? } ?>
		<? if ($btaltera == 'yes' && $idseqttl == 1) { ?> <input type="image" id="btAlterar"  src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" /> <? } ?>
		<? if ($btencitg == 'yes') { ?> <input type="image" id="btEncerrar" src="<? echo $UrlImagens; ?>botoes/encerrar_itg.gif" onClick="controlaOperacao('VG');" /> <? } ?>		
		<? if ($btexcttl == 'yes') { ?> <input type="image" id="btExcluir"  src="<? echo $UrlImagens; ?>botoes/excluir_titulares.gif" onClick="controlaOperacao('VT');" /> <? } ?>
		
		<input type="image" id="btGerarConta" src="<? echo $UrlImagens; ?>botoes/gerar_conta_sicredi.gif" onClick="showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina( \'GC\');',' bloqueiaFundo(divRotina); ','sim.gif','nao.gif'); return false;" /> 
				
	<? } else if ($operacao == 'CA' ) { ?> 
	
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('AC');" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" /> 
					
	<? } ?>	
	
	<!--<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" /> -->

</div>