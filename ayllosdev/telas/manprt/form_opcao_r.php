<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIAÇÃO      : Helinton Steffens - (Supero)
 * DATA CRIAÇÃO : 13/03/2018 
 * OBJETIVO     : Formulario para conciliar uma ted.
 */
 
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	//include('form_cabecalho.php');

    // Monta o xml de requisiï¿½ï¿½o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0111.p</Bo>';
	$xml .= '		<Proc>Busca_Cooperativas</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nmrescop>'.$glbvars['nmrescop'].'</nmrescop>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 		= getDataXML($xml);
	$xmlObjeto 		= getObjectXML($xmlResult);

    // Recebe as cooperativas
	$nmcooper		= $xmlObjeto->roottag->tags[0]->attributes['NMCOOPER'];
		
	// Faz o tratamento para criar o select
	$nmcooperArray	= explode(',', $nmcooper);
	$qtcooper		= count($nmcooperArray);
	$slcooper		= '<option value="">TODAS</option>';
	    
	for ( $j = 0; $j < $qtcooper; $j +=2 ) {
		if($j > 0) {
			$slcooper .= '<option '. (($nmcooperArray[$j+1] == $cdcooper) ? 'selected' : '') .' value="'.$nmcooperArray[$j+1].'">'.$nmcooperArray[$j].'</option>';
		}
	}
?>
<script>

	var slcooper = '<?php echo $slcooper ?>';

</script>
<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<div id="divFiltro">
		<div>
			<label for="inidtpro"><? echo utf8ToHtml('Data inicial');  ?>:</label>
			<input type="text" id="inidtpro" name="inidtpro" value="<?php echo $inidtpro ?>"/>

			<label for="fimdtpro"><? echo utf8ToHtml('Data fim:');  ?></label>
			<input type="text" id="fimdtpro" name="fimdtpro" value="<?php echo $fimdtpro ?>" />

			<div id="divCooper">
                <label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
                <select id="nmrescop" name="nmrescop">
                 
                </select>
            </div>
			<br style="clear:both" />
            <label for="nrdconta">Conta:</label>
            <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a> 

            <label for='cduflogr'> Estado:</label>
            <input id="cduflogr" name="cduflogr" alt="Sigla do estado.">


            <label for="flcustas"><? echo utf8ToHtml('Taxas/Custas pagas');  ?>:</label>
			<select id="flcustas" name="flcustas" class="campo">
				<option value="">TODAS</option>
				<option value="1">Sim</option>
				<option value="0">Não</option>
			</select>
		</div>
	</div>		
</form>


<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" onclick="btnContinuar(); return false;" ><? echo utf8ToHtml('Avan&ccedilar'); ?></a>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<!--<a href="#" class="botao" onclick="exportarConsultaPDF(); return false;" ><? echo utf8ToHtml('Exportar PDF'); ?></a>
    <a href="#" class="botao" onclick="exportarConsultaCSV(); return false;" ><? echo utf8ToHtml('Exportar CSV'); ?></a>-->
</div>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_custas_csv.php" method="post" id="frmExportarCSV" name="frmExportarCSV">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $nmrescop; ?>">
	<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo $nrdconta; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="flcustas" id="flcustas" value="<?php echo $flcustas; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_custas_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $nmrescop; ?>">
	<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo $nrdconta; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="flcustas" id="flcustas" value="<?php echo $flcustas; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>





