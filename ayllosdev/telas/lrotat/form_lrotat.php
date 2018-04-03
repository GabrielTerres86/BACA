	<? 
	/*!
	 * FONTE        : form_lrotat.php						Última alteração: 02/08/2016
	 * CRIAÇÃO      : Otto - RKAM
	 * DATA CRIAÇÃO : 06/07/2016
	 * OBJETIVO     : Formulario de informações.
	 * --------------
	 * ALTERAÇÕES   : 12/07/2016 - Ajustes para finzaliZação da conversáo 
     *                             (Andrei - RKAM)
	 *
	 *				  02/08/2016 - Ajuste para alimentar corretamente o campo tipo de limite
	 *							   (Adriano).
	 *
	 *				  10/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
	 * --------------
	 */	


	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	require_once("../../includes/carrega_permissoes.php");
	?>

	<form id="frmLrotat" name="frmLrotat" class="formulario" style="display:none;">

		<fieldset id="frmConteudo" style="padding:0px; margin:0px; padding-bottom:10px;">

			<legend><? echo utf8ToHtml("Cr&eacute;dito Rotativo"); ?></legend>

			<label for="dsdlinha"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:"); ?></label>
			<input  type="text" id="dsdlinha" name="dsdlinha" value="<?echo getByTagName($linhas->tags,'dsdlinha'); ?>">

			<br style="clear: both;" />

			<label for="tpdlinha"><? echo utf8ToHtml("Tipo de Limite:"); ?></label>
			<select  id="tpdlinha" name="tpdlinha" value="<?echo getByTagName($linhas->tags,'tpdlinha'); ?>">
				<option value="1" <?php if (getByTagName($linhas->tags,'tpdlinha') == 1) { ?> selected <?php } ?> ><? echo utf8ToHtml("Limite de crédito PF"); ?></option>
				<option value="2" <?php if (getByTagName($linhas->tags,'tpdlinha') == 2) { ?> selected <?php } ?> ><? echo utf8ToHtml("Limite de crédito PJ"); ?></option>
			</select>

			<label  for="dssitlcr"><? echo utf8ToHtml("Situa&ccedil;&atilde;o:"); ?></label>
			<input  type="text" id="dssitlcr" name="dssitlcr" value="<?echo getByTagName($linhas->tags,'dssitlcr'); ?>" >

			<br />			
			
			<label id="Operacional">Operacional</label>

			<label id="Cecred">CECRED</label>

			<br />

			<!-- Esquerda e Direita -->
			<label for="qtvezcap"><? echo utf8ToHtml("Quantidade de Vezes do Capital:"); ?></label>
			<input  type="text" id="qtvezcap" name="qtvezcap" value="<?echo getByTagName($linhas->tags,'qtvezcap'); ?>" > 
			<input  type="text" id="qtvcapce" name="qtvcapce" value="<?echo getByTagName($linhas->tags,'qtvcapce'); ?>">

			<br />

			<!-- Esquerda e Direita -->
			<label for="vllimmax"><? echo utf8ToHtml("Valor Limite M&aacute;ximo:"); ?></label>
			<input  type="text" id="vllimmax" name="vllimmax" value="<?echo getByTagName($linhas->tags,'vllimmax'); ?>"> 
			<input  type="text" id="vllmaxce" name="vllmaxce" value="<?echo getByTagName($linhas->tags,'vllmaxce'); ?>">

			<br />

			<!-- Direita -->
			<label for="qtdiavig"><? echo utf8ToHtml("Dias de Vig&ecirc;ncia do Contrato:"); ?></label>
			<input  type="text" id="qtdiavig" name="qtdiavig" value="<?echo getByTagName($linhas->tags,'qtdiavig'); ?>"> 

			<br />

			<!-- Direita -->
			<label for="txjurfix"><? echo utf8ToHtml("Taxa Fixa (%):"); ?></label>
			<input  type="text" id="txjurfix" name="txjurfix" value="<?echo getByTagName($linhas->tags,'txjurfix'); ?>"> 

			<br />

			<!-- Direita -->
			<label for="txjurvar"><? echo utf8ToHtml("Taxa Vari&aacute;vel (%):"); ?></label>
			<input  type="text" id="txjurvar" name="txjurvar" value="<?echo getByTagName($linhas->tags,'txjurvar'); ?>"> 

			<br />

			<!-- Direita -->
			<label for="txmensal"><? echo utf8ToHtml("Taxa Mensal (%):"); ?></label>
			<input  type="text" id="txmensal" name="txmensal"value="<?echo getByTagName($linhas->tags,'txmensal'); ?>" > 

			<br />
			
			<label for="tpctrato"><? echo utf8ToHtml("Modelo:"); ?></label>
			<select  id="tpctrato" name="tpctrato" value="<?echo getByTagName($linhas->tags,'tpctrato'); ?>">
				<option value="1" <?php if (getByTagName($linhas->tags,'tpctrato') == 1) { ?> selected <?php } ?> >Geral</option>
				<option value="4" <?php if (getByTagName($linhas->tags,'tpctrato') == 4) { ?> selected <?php } ?> >Aplica&ccedil;&atilde;o</option>
			</select>
			
			<br />
			
			<label for="permingr"><? echo utf8ToHtml("% M&iacute;nimo Garantia:"); ?></label>
			<input  type="text" id="permingr" name="permingr"value="<?echo getByTagName($linhas->tags,'permingr') ? getByTagName($linhas->tags,'permingr') : '0,00'; ?>" > 

			<br />

			<!-- Texto no contrato -->
			<label for="dsencfin1"><? echo utf8ToHtml("Texto no contrato:"); ?></label>
			<input  type="text" id="dsencfin1" name="dsencfin1" value="<?echo getByTagName($linhas->tags,'dsencfin1'); ?>" >

			<br />
			 
			<label for="dsencfin2"></label>
			<input  type="text" id="dsencfin2" name="dsencfin2" value="<?echo getByTagName($linhas->tags,'dsencfin2'); ?>"> 

			<br />

			<label for="dsencfin2"></label>
			<input  type="text" id="dsencfin3" name="dsencfin3"value="<?echo getByTagName($linhas->tags,'dsencfin3'); ?>" > 

			<br />

		</fieldset>
     
		<fieldset id="fsetCentralRisco" style="padding:0px; margin:0px; padding-bottom:10px;">

				<legend><? echo utf8ToHtml("Informa&ccedil;&otilde;es Central de Risco"); ?></legend>

				<label for="origrecu"><? echo utf8ToHtml("Origem do recurso:"); ?></label>
				<select  id="origrecu" name="origrecu" value="<?echo getByTagName($linhas->tags,'origrecu'); ?>">
					<option value="RECURSO PROPRIO">RECURSO PROPRIO</option>
					<option value="BNDES/FINAME">BNDES/FINAME</option>
				</select>

				<br />

				<label for="cdmodali"><? echo utf8ToHtml("Modalidade (BACEN):"); ?></label>
				<input  type="text" id="cdmodali" name="cdmodali"value="<?echo getByTagName($linhas->tags,'cdmodali'); ?>" > 
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
				<input  type="text" id="dsmodali" name="dsmodali"value="<?echo getByTagName($linhas->tags,'dsmodali'); ?>" >
				
				<br />

				<label for="cdsubmod"><? echo utf8ToHtml("Submodalidade (BACEN):"); ?></label>
				<input  type="text" id="cdsubmod" name="cdsubmod"value="<?echo getByTagName($linhas->tags,'cdsubmod'); ?>" > 
			    <a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
				<input  type="text" id="dssubmod" name="dssubmod"value="<?echo getByTagName($linhas->tags,'dssubmod'); ?>" >
				

				<br style="clear:both" />

		</fieldset>

	</form>

	<div id="divBotoesFiltroLrotat" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(2); return false;">Voltar</a>																
		<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="btnProsseguir();return false;" style="float:none;">Prosseguir</a>																				
	</div>


<script type="text/javascript">

  formataFormularioLrotat();
  
</script>