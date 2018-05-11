<? 
/*!
 * FONTE        : consultar_historicos.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 11/03/2016
 * OBJETIVO     : Rotina para consultar históricos do sistema - HISTOR
 * --------------
 * ALTERAÇÕES   : 05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 *
 *                07/02/2017 - #552068 Mudança de informacao da coluna de descricao do historico,
 *                             de dshistor para dsexthst;
 *                             Comentada a coluna de CPMF(Carlos)
 *
 * -------------- 
 *
 * -------------- 
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdhistor	= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '';
	$dshistor	= (isset($_POST['dshistor'])) ? $_POST['dshistor'] : '';
	$tpltmvpq	= (isset($_POST['tpltmvpq'])) ? $_POST['tpltmvpq'] : 0;
	$cdgrphis	= (isset($_POST['cdgrphis'])) ? $_POST['cdgrphis'] : 0;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','liberaFormulario();',false);
	}
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0179.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '       <dshistor>'.$dshistor.'</dshistor>';
	$xml .= '       <tpltmvpq>'.$tpltmvpq.'</tpltmvpq>';
	$xml .= '       <cdgrphis>'.$cdgrphis.'</cdgrphis>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"liberaFormulario();",false);		
	} 

	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	
	echo "strHTML  = '  <div class=\"divRegistros\">';";
	echo "strHTML += '    <table>';";
	echo "strHTML += '       <thead>';";
	echo "strHTML += '         <tr>';";
	echo "strHTML += '            <th>C&oacute;digo</th>';";
	echo "strHTML += '  		    <th>Descri&ccedil;&atilde;o</th>';";
	echo "strHTML += '  		    <th>D/C</th>';";
	echo "strHTML += '  		    <th>Lote</th>';";
/*	echo "strHTML += '  		    <th>% CPMF</th>';"; */
	echo "strHTML += '  		    <th>Aviso</th>';";
	echo "strHTML += '  		    <th>Debita</th>';";
	echo "strHTML += '  		    <th>Credita</th>';";
	echo "strHTML += '  	   </tr>';";
	echo "strHTML += '       </thead>';";
	echo "strHTML += '       <tbody>';";		
	
	foreach($xmlObjeto->roottag->tags[0]->tags as $historico){
		// Recebo todos valores em variáveis
		$cdhistor	= getByTagName($historico->tags,'cdhistor');
		$dsexthst	= getByTagName($historico->tags,'dsexthst');
		$indebcre 	= getByTagName($historico->tags,'indebcre');
		$tplotmov 	= getByTagName($historico->tags,'tplotmov');
/*		$txcpmfcc 	= getByTagName($historico->tags,'txcpmfcc'); */
		$inavisar 	= getByTagName($historico->tags,'inavisar');
		$nrctadeb 	= getByTagName($historico->tags,'nrctadeb');
		$nrctacrd 	= getByTagName($historico->tags,'nrctacrd');
		
		/* Converter os campos de valores */ 			
		echo "strHTML += '<tr>';";	
		echo "strHTML += '   <td><span>".$cdhistor."</span>".$cdhistor."</td>';";
		echo "strHTML += '   <td><span>".$dsexthst."</span>".$dsexthst."</td>';";
		echo "strHTML += '   <td><span>".$indebcre."</span>".$indebcre."</td>';";
		echo "strHTML += '   <td><span>".$tplotmov."</span>".$tplotmov."</td>';";

/*		echo "strHTML += '   <td><span >".converteFloat($txcpmfcc,'MOEDA') ."</span>". formataMoeda($txcpmfcc) ."</td>';"; */

		echo "strHTML += '   <td><span>".$inavisar."</span>".$inavisar."</td>';";
		echo "strHTML += '   <td><span>".$nrctadeb."</span>".$nrctadeb."</td>';";
		echo "strHTML += '   <td><span>".$nrctacrd."</span>".$nrctacrd."</td>';";
		echo "strHTML += '</tr>';";
	}
	
	echo "strHTML += '      </tbody>';";
	echo "strHTML += '    </table>';";
	echo "strHTML += '  </div>';";
	echo "strHTML += '  <div id=\"divPesquisaRodape\" class=\"divPesquisaRodape\">';";
	echo "strHTML += '     <table>';";	
	echo "strHTML += '       <tr>';";
	echo "strHTML += '          <td>';";

	if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
	// Se a paginação não está na primeira, exibe botão voltar
	if ($nriniseq > 1) { 
		echo "strHTML += '<a class=\'paginacaoAnt\'><<< Anterior</a>';";
	}

	echo "strHTML += '          </td>';";
	echo "strHTML += '          <td>';";

	if (isset($nriniseq)) { 
		if (($nriniseq + $nrregist) > $qtregist) { 
			echo "strHTML += 'Exibindo " . $nriniseq . " at&eacute; " .  $qtregist . " de " .  $qtregist . "';";	
		} else {  
			echo "strHTML += 'Exibindo " . $nriniseq . " at&eacute; " .  ($nriniseq + $nrregist - 1) . " de " .  $qtregist . "';";	
		} 
	}

	echo "strHTML += '          </td>';";
	echo "strHTML += '          <td>';";

	// Se a paginação não está na &uacute;ltima página, exibe botão proximo
	if ($qtregist > ($nriniseq + $nrregist - 1)) {
		echo "strHTML += '<a class=\'paginacaoProx\'>Pr&oacute;ximo >>></a>';";
	}

	echo "strHTML += '        </td>';";
	echo "strHTML += '      </tr>';";
	echo "strHTML += '    </table>';";
	echo "strHTML += '  </div>';";
	
	echo "$('#divHistoricos','#frmTabHistoricos').html(strHTML);";
	echo "formataTabelaConsulta();";
	
	echo "$('#divPesquisaRodape','#divHistoricos').formataRodapePesquisa();";
	echo "$('a.paginacaoAnt').unbind('click').bind('click', function() { consultarHistoricos('".($nriniseq - $nrregist)."',true);});";
	echo "$('a.paginacaoProx').unbind('click').bind('click', function() { consultarHistoricos('".($nriniseq + $nrregist)."',true);});";

	echo "$('#frmTabHistoricos').css('display','block');"; 
	echo "$('#fsetHistoricos').css('display','block');"; 
	echo "$('#btSalvar','#divBotoes').css({'display':'none'});";
?>