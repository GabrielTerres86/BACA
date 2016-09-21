<?php
	 
 /************************************************************************
   Fonte: form_cabecalho.php
   Autor: Rogerius Militão - DB1
   Data : 29/06/2011                 Última Alteração: 00/00/0000

   Objetivo  : Cabeçalho da tela inicial da ATENDA
			   
   Alterações: 
  * 
  *		26/09/2013 - Inclusão de link p/ consulta de cartão assinatura (Jean Michel
  *     
  *     12/07/2016 - Adicionado classe FirstInput no primeiro campo input, necessario 
  *                  para dar foco ao retornar uma consulta de tela - (Evandro - RKAM)
  *
  ************************************************************************************/
	
?>

<form action="" method="post" name="frmCabAtenda" id="frmCabAtenda" class="formulario condensado cabecalho">

  <input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo($glbvars["cdcooper"]); ?>" />
  <input type="hidden" name="hdnServSM" id="hdnServSM" value="<?php echo($GEDServidor); ?>" />
  <input type="hidden" name="hdnFlgdig" id="hdnFlgdig" />

  <label for="nrdconta">
    <? echo utf8ToHtml('Conta/dv:') ?>
  </label>
  <input name="nrdconta" type="text" class="FirstInput" tabindex="1000" id="nrdconta" />

  <label for="nrdctitg">
    <? echo utf8ToHtml('Conta/ITG:') ?>
  </label>
  <input name="nrdctitg" type="text" tabindex="2" id="nrdctitg" />

  <input name="dssititg" type="text" id="dssititg" />
  <input type="image" tabindex="3" src="<?php echo $UrlImagens; ?>/botoes/ok.gif" onClick="obtemCabecalho();return false;">

  <a tabindex="4" class="SetFocus" onClick="mostraPesquisaAssociado('nrdconta','frmCabAtenda','');return false;" style="margin-left: 1px">Pesquisa</a>

  <a href="#" onClick="mostraPesquisaAssociado('nrdconta','frmCabAtenda','');return false;" >
    <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0">
  </a>
  <a tabindex="5" class="SetFocus" onClick="buscaAnotacoes();return false;" style="margin-left: 1px">&nbsp;&nbsp;Anota&ccedil;&otilde;es</a>

  <div id="divSemCartaoAss">
    <a tabindex="6" class="SetFocus" style="margin-left: 1px; cursor:default">&nbsp;&nbsp;Cart&atilde;o Ass.</a>
  </div>


  <br style="clear:both;" />
  <hr style="background-color:#666; height:1px;" />

  <label for="nrmatric">
    <? echo utf8ToHtml('Matr&iacute;cula:') ?>
  </label>
  <input name="nrmatric" type="text"  id="nrmatric" />

  <label for="cdagenci">
    <? echo utf8ToHtml('PA:') ?>
  </label>
  <input name="cdagenci" type="text"  id="cdagenci" />

  <label for="nrctainv">
    <? echo utf8ToHtml('Conta/Invest.:') ?>
  </label>
  <input name="nrctainv" type="text"  id="nrctainv" />

  <label for="dtadmiss">
    <? echo utf8ToHtml('Admiss&atilde;o:') ?>
  </label>
  <input name="dtadmiss" type="text"  id="dtadmiss" />

  <br />

  <label for="dtadmemp">
    <? echo utf8ToHtml('Admiss&atilde;o Empresa:') ?>
  </label>
  <input name="dtadmemp" type="text"  id="dtadmemp" />

  <label for="dtaltera">
    <? echo utf8ToHtml('Atualiza&ccedil;&atilde;o Cadastral:') ?>
  </label>
  <input name="dtaltera" type="text"  id="dtaltera" />

  <label for="dtdemiss">
    <? echo utf8ToHtml('Demiss&atilde;o:') ?>
  </label>
  <input name="dtdemiss" type="text"  id="dtdemiss" />

  <br style="clear:both" />
  <hr style="background-color:#666; height:1px;" />


  <label for="nmprimtl">
    <? echo utf8ToHtml('Nome/Raz&atilde;o Social:') ?>
  </label>
  <input name="nmprimtl" type="text"  id="nmprimtl" />

  <br />

  <label for="dsnatopc">
    <? echo utf8ToHtml('Ocupa&ccedil;&atilde;o:') ?>
  </label>
  <input name="dsnatopc" type="text"  id="dsnatopc" />

  <label for="nrramfon">
    <? echo utf8ToHtml('Telefone:') ?>
  </label>
  <input name="nrramfon" type="text"  id="nrramfon" />

  <br />

  <label for="dsnatura">
    <? echo utf8ToHtml('Naturalidade:') ?>
  </label>
  <input name="dsnatura" type="text"  id="dsnatura" />

  <label for="nrcpfcgc">
    <? echo utf8ToHtml('CPF/CNPJ:') ?>
  </label>
  <input name="nrcpfcgc" type="text"  id="nrcpfcgc" />

  <br />

  <label for="dstipcta">
    <? echo utf8ToHtml('Tipo de Conta:') ?>
  </label>
  <input name="dstipcta" type="text"  id="dstipcta" />

  <label for="dssitdct">
    <? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?>
  </label>
  <input name="dssitdct" type="text"  id="dssitdct" />

  <br />

  <label for="indnivel">
    <? echo utf8ToHtml('N&iacute;vel:') ?>
  </label>
  <input name="indnivel" type="text"  id="indnivel" />

  <label for="cdempres">
    <? echo utf8ToHtml('Empresa:') ?>
  </label>
  <input name="cdempres" type="text"  id="cdempres" />

  <label for="cdsecext">
    <? echo utf8ToHtml('Se&ccedil;&atilde;o:') ?>
  </label>
  <input name="cdsecext" type="text"  id="cdsecext" />

  <label for="cdturnos">
    <? echo utf8ToHtml('Turno:') ?>
  </label>
  <input name="cdturnos" type="text"  id="cdturnos" />

  <label for="cdtipsfx">
    <? echo utf8ToHtml('Tipo Sal&aacute;rio:') ?>
  </label>
  <input name="cdtipsfx" type="text"  id="cdtipsfx" />

  <br style="clear:both" />
  <hr style="background-color:#666; height:1px;" />

  <label for="qtdevolu">
    <? echo utf8ToHtml('Devolu&ccedil;&otilde;es:') ?>
  </label>
  <input name="qtdevolu" type="text"  id="qtdevolu" />

  <label for="qtdddeve">
    <? echo utf8ToHtml('Cred Liq/Estouro:') ?>
  </label>
  <input name="qtdddeve" type="text"  id="qtdddeve" />

  <label for="dtabtcct">
    <? echo utf8ToHtml('Data SFN:') ?>
  </label>
  <input name="dtabtcct" type="text"  id="dtabtcct" />

  <br />

  <label for="ftsalari">
    <? echo utf8ToHtml('Ft. Salarial:') ?>
  </label>
  <input name="ftsalari" type="text"  id="ftsalari" />

  <label for="vlprepla">
    <? echo utf8ToHtml('Plano de Capital:') ?>
  </label>
  <input name="vlprepla" type="text"  id="vlprepla" />

  <label for="qttalret">
    <? echo utf8ToHtml('Fs Retiradas:') ?>
  </label>
  <input name="qttalret" type="text"  id="qttalret" />

  <br style="clear:both" />


</form>


<script>
  formataCabecalho();
</script>

