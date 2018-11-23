<?php
	 
 /************************************************************************
   Fonte: form_cabecalho.php
   Autor: Rogerius Militão - DB1
   Data : 29/06/2011                 Última Alteração: 23/11/2018

   Objetivo  : Cabeçalho da tela inicial da ATENDA
			   
   Alterações: 26/09/2013 - Inclusão de link p/ consulta de cartão assinatura (Jean Michel
	           12/07/2016 - Adicionado classe FirstInput no primeiro campo input, necessario
						    para dar foco ao retornar uma consulta de tela - (Evandro - RKAM)
               27/07/2016 - Corrigi o uso da variavel $glbvars. SD 479874 (Carlos R.)
			   22/02/2018 - Alteracoes referentes ao uso do Ctrl+C Ctrl+V no CPF/CNPJ do cooperado (Lucas Ranghetti #851205)
			   26/03/2018 - Alterado para permitir acesso a tela pelo CRM. (Reinert)
               16/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)
               23/11/2018 - P442 - Inclusao de Score (Thaise-Envolti)
	
  ************************************************************************************/
?>
<form action="" method="post" name="frmCabAtenda" id="frmCabAtenda" class="formulario condensado cabecalho">
  <input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : 0; ?>" />
	<input type="hidden" name="hdnServSM" id="hdnServSM" value="<?php echo($GEDServidor); ?>" />
	<input type="hidden" name="hdnFlgdig" id="hdnFlgdig" />
  <input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
  <input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
  <label for="nrdconta">Conta/dv:</label>
  <input name="nrdconta" type="text" class="FirstInput" tabindex="1000" id="nrdconta" />
  <label for="nrdctitg">Conta/ITG:</label>
  <input name="nrdctitg" type="text" tabindex="2" id="nrdctitg" />
  <input name="dssititg" type="text" id="dssititg" />
  <input type="image" tabindex="3" src="<?php echo $UrlImagens; ?>/botoes/ok.gif" onclick="obtemCabecalho();return false;">
  <a tabindex="4" name="4" class="SetFocus" onclick="mostraPesquisaAssociado('nrdconta','frmCabAtenda','');return false;" style="margin-left: 1px">Pesquisa</a>
  <a href="#" onclick="mostraPesquisaAssociado('nrdconta','frmCabAtenda','');return false;">
    <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0">
  </a>
  <a tabindex="5" name="5" class="SetFocus Anotacoes" onFocus="EnterAnotacoes();return false;" onclick="buscaAnotacoes();return false;" style="margin-left: 1px">&nbsp;&nbsp;Anota&ccedil;&otilde;es</a>
  <div id="divSemCartaoAss">
    <a tabindex="6" name="6" class="SetFocus" style="margin-left: 1px; cursor:default">&nbsp;&nbsp;Cart&atilde;o Ass.</a>
  </div>
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
  <label for="nrmatric">Matr&iacute;cula:</label>
  <input name="nrmatric" type="text" id="nrmatric" />
  <label for="cdagenci">PA:</label>
  <input name="cdagenci" type="text" id="cdagenci" />
  <label for="nrctainv">Conta/Invest.:</label>
  <input name="nrctainv" type="text" id="nrctainv" />
  <label for="dtadmiss">Admiss&atilde;o:</label>
  <input name="dtadmiss" type="text" id="dtadmiss" />
	<br />
  <label for="dtadmemp">Admiss&atilde;o Empresa</label>
  <input name="dtadmemp" type="text" id="dtadmemp" />
  <label for="dtaltera">Atualiza&ccedil;&atilde;o Cadastral:</label>
  <input name="dtaltera" type="text" id="dtaltera" />
  <label for="dtdemiss">Demiss&atilde;o:</label>
  <input name="dtdemiss" type="text" id="dtdemiss" />
	<br style="clear:both" />
	<hr style="background-color:#666; height:1px;" />

  <label for="nmprimtl">Nome/Raz&atilde;o Social:</label>
  <input name="nmprimtl" type="text" id="nmprimtl" />
	<br />
  <label for="nmsocial">Nome Social:</label>
  <input name="nmsocial" type="text" id="nmsocial" />
  <br />
  <label for="dsnatopc">Ocupa&ccedil;&atilde;o:</label>
  <input name="dsnatopc" type="text" id="dsnatopc" />
  <label for="nrramfon">Telefone:</label>
  <input name="nrramfon" type="text" id="nrramfon" />
	<br />
  <label for="dsnatura">Naturalidade:</label>
  <input name="dsnatura" type="text" id="dsnatura" />
  <label for="nrcpfcgc">CPF/CNPJ:</label>
  <input name="nrcpfcgc" type="text" id="nrcpfcgc" onSelect="if(podeCopiar == true){ copiarCampo();}" oncopy="podeCopiar = true; return false;" />
  <input name="nrcpfcgc2" type="text" id="nrcpfcgc2" />
	<br />
  <label for="dstipcta">Tipo de Conta:</label>
  <input name="dstipcta" type="text" id="dstipcta" />
  <label for="dssitdct">Situa&ccedil;&atilde;o:</label>
  <input name="dssitdct" type="text" id="dssitdct" />
	<br />
  <label for="indnivel">N&iacute;vel:</label>
  <input name="indnivel" type="text" id="indnivel" />
  <label for="cdempres">Empresa:</label>
  <input name="cdempres" type="text" id="cdempres" />
  <!--<label for="cdsecext">Se&ccedil;&atilde;o:</label>
  <input name="cdsecext" type="text" id="cdsecext" />
  <label for="cdturnos">Turno:</label>
  <input name="cdturnos" type="text" id="cdturnos" />
  <label for="cdtipsfx">Tipo Sal&aacute;rio:</label>
  <input name="cdtipsfx" type="text" id="cdtipsfx" />-->
  <label for="cdscobeh">Score:</label>
  <input name="cdscobeh" type="text" id="cdscobeh" />
	<br style="clear:both" />
	<hr style="background-color:#666; height:1px;" />
  <label for="qtdevolu">Devolu&ccedil;&otilde;es:</label>
  <input name="qtdevolu" type="text" id="qtdevolu" />
  <label for="qtdddeve">Cred Liq/Estouro:</label>
  <input name="qtdddeve" type="text" id="qtdddeve" />
  <label for="dtabtcct">Data SFN:</label>
  <input name="dtabtcct" type="text" id="dtabtcct" />
	<br />
  <label for="ftsalari">Ft. Salarial:</label>
  <input name="ftsalari" type="text" id="ftsalari" />
  <label for="vlprepla">Plano de Capital:</label>
  <input name="vlprepla" type="text" id="vlprepla" />
  <label for="qttalret">Fs Retiradas:</label>
  <input name="qttalret" type="text" id="qttalret" />
	<br style="clear:both" />
</form>
<script>
formataCabecalho();
</script>
