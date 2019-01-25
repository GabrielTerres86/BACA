<? 
/*! 
 * FONTE        : tab_devolu_conta.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Tabela - tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 15/04/2015 - #273953 Inclusao das colunas Banco e Agencia para ficar conforme tela do ambiente caracter (Carlos)
 *
 *				  19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 * --------------
 */
?>

<?
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="tabDevoluConta" style="display:none" >

	<input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo($glbvars["cdcooper"]); ?>" />
	<input type="hidden" name="hdnServSM" id="hdnServSM" value="<?php echo($GEDServidor); ?>" />
	
	<div class="divRegistros">		
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('   ');  ?></th>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Ag'); ?></th>
                	<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Sit.');  ?></th>
                    <th><? echo utf8ToHtml('Alinea');  ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
					
					<th><? echo utf8ToHtml('Aplicação'); ?></th>
					<th><? echo utf8ToHtml('Contato');  ?></th>
					<th><? echo utf8ToHtml('Imagem');    ?></th>
					<th><? echo utf8ToHtml('Assinatura');?></th>
				</tr>
			</thead>
			<tbody>
				<? $cont_id = 0;
				foreach($lancamento as $lancamento){
                ?>	<tr>
						<td><input type="checkbox" name="indice" id="indice" onclick="validaSelecao(this,<?php echo $inprejuz; ?>)" value="<? echo $cont_id; ?>"  <?if(getByTagName($lancamento->tags,'cddsitua') == 1  || 
																																		      getByTagName($lancamento->tags,'cdalinea') == 0  || 
																																			  getByTagName($lancamento->tags,'cdalinea') == 20 || 
																																			  getByTagName($lancamento->tags,'cdalinea') == 21 || 																																			  
																																			  getByTagName($lancamento->tags,'cdalinea') == 28 || 
																																			  getByTagName($lancamento->tags,'cdalinea') == 49 ||
																																			  getByTagName($lancamento->tags,'cdalinea') == 70){ ?> disabled <? } ?> />
							<script>
								var id_reg = arrayRegLinha.length;																	
								arrayRegLinha[id_reg] = new Array();                                                                
								arrayRegLinha[id_reg]["banco"]    = '<? echo getByTagName($lancamento->tags,'banco'); ?>';      
								arrayRegLinha[id_reg]["cdagechq"] = '<? echo getByTagName($lancamento->tags,'cdagechq'); ?>';   
								arrayRegLinha[id_reg]["nrdconta"] = '<? echo $nrdconta; ?>'; 										
								arrayRegLinha[id_reg]["nrcheque"] = '<? echo getByTagName($lancamento->tags,'nrdocmto'); ?>';   
								arrayRegLinha[id_reg]["vllanmto"] = '<? echo getByTagName($lancamento->tags,'vllanmto'); ?>';   
								arrayRegLinha[id_reg]["cdalinea"] = '<? echo getByTagName($lancamento->tags,'cdalinea'); ?>';   
								arrayRegLinha[id_reg]["nrctachq"] = '<? echo getByTagName($lancamento->tags,'nrctachq'); ?>';   
								arrayRegLinha[id_reg]["nrdctitg"] = '<? echo getByTagName($lancamento->tags,'nrdctitg'); ?>';   
								arrayRegLinha[id_reg]["nrdrecid"] = '<? echo getByTagName($lancamento->tags,'nrdrecid'); ?>';   
								arrayRegLinha[id_reg]["flag"]     = 'yes';   
							</script>                                                                                               
						</td>                                                                                                       
						<? $cont_id = $cont_id + 1; ?>                                                                              
						
						<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($lancamento->tags,'cdcooper') ?>" />
						<input type="hidden" id="dsbccxlt" name="dsbccxlt" value="<? echo getByTagName($lancamento->tags,'dsbccxlt') ?>" />
						<input type="hidden" id="banco"    name="banco"    value="<? echo getByTagName($lancamento->tags,'banco') ?>" />
						<input type="hidden" id="nrdctitg" name="nrdctitg" value="<? echo getByTagName($lancamento->tags,'nrdctitg') ?>" />
						<input type="hidden" id="cdbanchq" name="cdbanchq" value="<? echo getByTagName($lancamento->tags,'cdbanchq') ?>" />
						<input type="hidden" id="cdagechq" name="cdagechq" value="<? echo getByTagName($lancamento->tags,'cdagechq') ?>" />
						<input type="hidden" id="nrctachq" name="nrctachq" value="<? echo getByTagName($lancamento->tags,'nrctachq') ?>" />
						<input type="hidden" id="cddsitua" name="cddsitua" value="<? echo getByTagName($lancamento->tags,'cddsitua') ?>" />
						<input type="hidden" id="nrcheque" name="nrcheque" value="<? echo getByTagName($lancamento->tags,'nrdocmto') ?>" />
						<input type="hidden" id="flag"     name="flag"     value="<? echo getByTagName($lancamento->tags,'flag')     ?>" />
						<input type="hidden" id="nrdrecid" name="nrdrecid" value="<? echo getByTagName($lancamento->tags,'nrdrecid') ?>" />
						<input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($lancamento->tags,'nmoperad') ?>" />
						<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo getByTagName($lancamento->tags,'vllanmto') ?>" />
						<input type="hidden" id="cdalinea" name="cdalinea" value="<? echo getByTagName($lancamento->tags,'cdalinea') ?>" />
						<input type="hidden" id="dstabela" name="dstabela" value="<? echo getByTagName($lancamento->tags,'dstabela') ?>" />
						
						
						<td><span><? echo getByTagName($lancamento->tags,'banco'); ?></span>
							      <? echo getByTagName($lancamento->tags,'dsbccxlt'); ?>
						</td>
						
						<td><span><? echo getByTagName($lancamento->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($lancamento->tags,'cdagechq'); ?>
						</td>

						<td><span><? echo formataContaDVsimples(getByTagName($lancamento->tags,'nrdocmto')); ?></span>
							      <? echo formataContaDVsimples(getByTagName($lancamento->tags,'nrdocmto')); ?>
						</td>
						<td><span><? echo formataMoeda(getByTagName($lancamento->tags,'vllanmto')) ; ?></span>
								  <? echo formataMoeda(getByTagName($lancamento->tags,'vllanmto')) ; ?>
						</td>
						<td><span><? echo getByTagName($lancamento->tags,'dssituac');?></span>
								  <? echo getByTagName($lancamento->tags,'dssituac'); ?>
						</td>
						<td><span><? echo getByTagName($lancamento->tags,'cdalinea'); ?></span>
							      <? echo getByTagName($lancamento->tags,'cdalinea'); ?>
						</td>
						<td><span><? echo getByTagName($lancamento->tags,'nmoperad'); ?></span>
							      <? echo getByTagName($lancamento->tags,'nmoperad'); ?>
						</td>
						<td id="dsaplica"  title="<? echo "Total Aplic.: ".formataMoeda(getByTagName($lancamento->tags,'vlaplica'))."&#013;Total Poup.: ".formataMoeda(getByTagName($lancamento->tags,'vlsldprp')); ?>">
										   <span><?echo getByTagName($lancamento->tags,'dsaplica'); ?></span>
												 <?echo getByTagName($lancamento->tags,'dsaplica'); ?>
						  <input type="hidden" id="vlaplica" name="tabvlaplica" value="<? echo getByTagName($lancamento->tags,'vlaplica'); ?>" /> 
						  <input type="hidden" id="vlsldprp" name="tabvlsldprp" value="<? echo getByTagName($lancamento->tags,'vlsldprp'); ?>" /> 
						</td>
						<td id="contato">
							<a href="#" onClick="mostraContatos();"><img src="<?php echo $UrlImagens; ?>geral/telefone.png" width="15" height="15" border="0"></a>
						</td>
						<td id="imagcheq">
							<a href="#" onClick="consultaCheque('<? echo getByTagName($lancamento->tags,'cdagechq'); ?>','<? echo getByTagName($lancamento->tags,'nrctachq'); ?>','<? echo getByTagName($lancamento->tags,'nrdocmto'); ?>' );">
								<img src="<?php echo $UrlImagens; ?>geral/documento.png" width="15" height="15" border="0">
							</a>
						</td>
						<td> 
							<a href="http://<?php echo $GEDServidor;?>/smartshare/Clientes/ViewerExterno.aspx?pkey=8O3ky&conta=<?php echo formataContaDVsimples($nrdconta); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>" target="_blank">
							<img src="<?php echo $UrlImagens; ?>geral/editar.png" width="15" height="15" border="0"></a>
						</td>
					</tr>
                <? } ?>
            </tbody>
		</table>
	</div>
	
</div>

<div id="linha">
	<ul class="complemento">
		<li id="complemento"></li>	
	</ul>
</div>
