<? 
 /*!
 * FONTE        : form_previsoes.php							Última alteração: 21/03/2016
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011 
 * OBJETIVO     : Formulário de exibição das previsoes
 * --------------
 * ALTERAÇÕES   : 21/03/2016 - Ajuste layout, valores negativos (Adriano)
 * -------------- 
 */	
?>
<form name="frmPrevisoes" id="frmPrevisoes" class="formulario" onSubmit="return false;" >	

	<fieldset>
		<legend> <? echo utf8ToHtml('Devolução') ?> </legend>	
		
		<label for="vldepesp"><? echo utf8ToHtml('Deposito Cooper:') ?></label>
		<input name="vldepesp" id="vldepesp" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vldepesp')) ?>" />
		
		<label for="vldvlnum"><? echo utf8ToHtml('Numerario:') ?></label>
		<input name="vldvlnum" id="vldvlnum" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vldvlnum')) ?>" />
		
		<label for="vldvlbcb"><? echo utf8ToHtml('Cheques COMPE:') ?></label>
		<input name="vldvlbcb" id="vldvlbcb" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vldvlbcb')) ?>" />

	</fieldset>		


	<fieldset>
		<legend> <? echo utf8ToHtml('Titulos') ?> </legend>	

		<label for="qtremtit"><? echo utf8ToHtml('Quantidade:') ?></label>                 
		<input name="qtremtit" id="qtremtit" type="text" value="<?php echo formataNumericos("zzz.zzz.zzz",getByTagName($registro,'qtremtit'),"."); ?>" />
		
		<label for="vlremtit"><? echo utf8ToHtml('Valor:') ?></label>
		<input name="vlremtit" id="vlremtit" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vlremtit')) ?>" />
		
	</fieldset>


	<fieldset>
		<legend> <? echo utf8ToHtml('Suprimentos') ?> </legend>	
																					
		<label for="vlmoedas"><? echo utf8ToHtml('Moedas:') ?></label>                 
		<label for="qtmoedas"><? echo utf8ToHtml('Pacotes:') ?></label>                 
		<label for="submoeds"><? echo utf8ToHtml('Total:') ?></label>
		<label for="vldnotas"><? echo utf8ToHtml('Notas:') ?></label>
		<label for="qtdnotas"><? echo utf8ToHtml('Qtde:') ?></label>
		<label for="subnotas"><? echo utf8ToHtml('Total:') ?></label>

		<br />
		
		<label for="vlmoeda1"></label>                 
		<input name="vlmoeda1" id="vlmoeda1" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.1')) ?>" />                         
		<label for="qtmoeda1"></label>                 
		<input name="qtmoeda1" id="qtmoeda1" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.1') ?>" />                         
		<input name="qtmoepc1" id="qtmoepc1" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.1') ?>" />                         
		<label for="submoed1"></label>
		<input name="submoed1" id="submoed1" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.1')) ?>" />
		<label for="vldnota1"></label>
		<input name="vldnota1" id="vldnota1" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.1')) ?>" />
		<label for="qtdnota1"></label>
		<input name="qtdnota1" id="qtdnota1" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.1') ?>" />
		<label for="subnota1"></label>
		<input name="subnota1" id="subnota1" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.1')) ?>" />
		
		<br />

		<label for="vlmoeda2"></label>                 
		<input name="vlmoeda2" id="vlmoeda2" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.2')) ?>" />                         
		<label for="qtmoeda2"></label>                 
		<input name="qtmoeda2" id="qtmoeda2" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.2') ?>"  />                         
		<input name="qtmoepc2" id="qtmoepc2" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.2') ?>" />                         
		<label for="submoed2"></label>
		<input name="submoed2" id="submoed2" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.2')) ?>" />
		<label for="vldnota2"></label>
		<input name="vldnota2" id="vldnota2" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.2')) ?>" />
		<label for="qtdnota2"></label>
		<input name="qtdnota2" id="qtdnota2" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.2') ?>" />
		<label for="subnota2"></label>
		<input name="subnota2" id="subnota2" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.2')) ?>" />
		
		<br />

		<label for="vlmoeda3"></label>                 
		<input name="vlmoeda3" id="vlmoeda3" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.3')) ?>" />                         
		<label for="qtmoeda3"></label>                 
		<input name="qtmoeda3" id="qtmoeda3" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.3') ?>"  />                         
		<input name="qtmoepc3" id="qtmoepc3" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.3') ?>" />                         
		<label for="submoed3"></label>
		<input name="submoed3" id="submoed3" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.3')) ?>" />
		<label for="vldnota3"></label>
		<input name="vldnota3" id="vldnota3" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.3')) ?>" />
		<label for="qtdnota3"></label>
		<input name="qtdnota3" id="qtdnota3" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.3') ?>" />
		<label for="subnota3"></label>
		<input name="subnota3" id="subnota3" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.3')) ?>" />

		<br />

		<label for="vlmoeda4"></label>                 
		<input name="vlmoeda4" id="vlmoeda4" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.4')) ?>" />                         
		<label for="qtmoeda4"></label>                 
		<input name="qtmoeda4" id="qtmoeda4" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.4') ?>" />                         
		<input name="qtmoepc4" id="qtmoepc4" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.4') ?>" />                         
		<label for="submoed4"></label>
		<input name="submoed4" id="submoed4" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.4')) ?>" />
		<label for="vldnota4"></label>
		<input name="vldnota4" id="vldnota4" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.5')) ?>" />
		<label for="qtdnota4"></label>
		<input name="qtdnota4" id="qtdnota4" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.5') ?>" />
		<label for="subnota4"></label>
		<input name="subnota4" id="subnota4" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.5')) ?>" />
		
		<br />
		
		<label for="vlmoeda5"></label>                 
		<input name="vlmoeda5" id="vlmoeda5" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.5')) ?>" />                         
		<label for="qtmoeda5"></label>                 
		<input name="qtmoeda5" id="qtmoeda5" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.5') ?>" />                         
		<input name="qtmoepc5" id="qtmoepc5" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.5') ?>" />                         
		<label for="submoed5"></label>
		<input name="submoed5" id="submoed5" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.5')) ?>" />
		<label for="vldnota5"></label>
		<input name="vldnota5" id="vldnota5" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.4')) ?>" />
		<label for="qtdnota5"></label>
		<input name="qtdnota5" id="qtdnota5" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.4') ?>" />
		<label for="subnota5"></label>
		<input name="subnota5" id="subnota5" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.4')) ?>" />
		
		<br />	
	
		<label for="vlmoeda6"></label>                 
		<input name="vlmoeda6" id="vlmoeda6" type="text" value="<?php echo formataMoeda(getByTagName($vlmoedas,'vlmoedas.6')) ?>" />                         
		<label for="qtmoeda6"></label>                 
		<input name="qtmoeda6" id="qtmoeda6" type="text" value="<?php echo getByTagName($qtmoedas,'qtmoedas.6') ?>" />                         
		<input name="qtmoepc6" id="qtmoepc6" type="hidden" value="<?php echo getByTagName($qtmoepct,'qtmoepct.6') ?>" />                         
		<label for="submoed6"></label>
		<input name="submoed6" id="submoed6" type="text" value="<?php echo formataMoeda(getByTagName($submoeds,'submoeda.6')) ?>" />
		<label for="vldnota6"></label>
		<input name="vldnota6" id="vldnota6" type="text" value="<?php echo formataMoeda(getByTagName($vldnotas,'vldnotas.6')) ?>" />
		<label for="qtdnota6"></label>
		<input name="qtdnota6" id="qtdnota6" type="text" value="<?php echo getByTagName($qtdnotas,'qtdnotas.6') ?>" />
		<label for="subnota6"></label>
		<input name="subnota6" id="subnota6" type="text" value="<?php echo formataMoeda(getByTagName($subnotas,'subnotas.6')) ?>" />
		<br />

		<label for="totalpre">Total:</label>
		<label for="totmoeda"></label>
		<input name="totmoeda" id="totmoeda" type="text" value="<?php echo formataMoeda(getByTagName($registro,'totmoeda')) ?>" />
		<label for="totnotas"></label>
		<input name="totnotas" id="totnotas" type="text" value="<?php echo formataMoeda(getByTagName($registro,'totnotas')) ?>" />
		
		<br  style="clear:both" /><br />
		
		<label for="nmoperad">Operador:</label>
		<input name="nmoperad" id="nmoperad" type="text" value="<?php echo getByTagName($registro,'nmoperad') ?>" />
		<label for="hrtransa"></label>
		<input name="hrtransa" id="hrtransa" type="text" value="<?php echo getByTagName($registro,'hrtransa') ?>" />
		
	</fieldset>	
	
</form>

<div id="divBotoesPrevisoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>																				
</div>

