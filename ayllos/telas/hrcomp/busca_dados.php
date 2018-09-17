<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 26/02/2013 
 * OBJETIVO     : Rotina para buscar grupo na tela CADGRU
 * --------------
 * ALTERAÇÕES   : 05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
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
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdcoopex		= (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'busca_dados';
	
	$retornoAposErro = 'focaCampoErro(\'cdcoopex\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0183.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<idorigem>5</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdcoopex>'.$cdcoopex.'</cdcoopex>';		
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$processos = $xmlObjeto->roottag->tags[0]->tags;
	
	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Arquivos').'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '                  <th>'.utf8ToHtml('Seq').'</th>';
	echo '					<th>'.utf8ToHtml('Processo').'</th>';
	echo '					<th>'.utf8ToHtml('Ativo').'</th>';
	echo '					<th>'.utf8ToHtml('Horario inicial').'</th>';
	echo '					<th>'.utf8ToHtml('Horario final').'</th>';	
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
			
	foreach( $processos as $r ) { 	
		echo "<tr>";
		echo	"<td id='nrseqexe'><span>".getByTagName($r->tags,'nrseqexe')."</span>";
		echo                 getByTagName($r->tags,'nrseqexe');
		echo    "</td>";		
		echo	"<td id='nmproces'><span>".getByTagName($r->tags,'nmproces')."</span>";
		echo                 getByTagName($r->tags,'nmproces');
		echo    "</td>";
		echo	"<td id='flgativo'><span>".getByTagName($r->tags,'flgativo')."</span>";
        echo    getByTagName($r->tags,'flgativo') == 'no' ? "N&atilde;o" : "Sim" ; 
		echo	"</td>";
		echo	"<td id='ageinihr'><span>".str_pad(getByTagName($r->tags,'ageinihr'), 2, '0', STR_PAD_LEFT).":".str_pad(getByTagName($r->tags,'ageinimm'), 2, '0', STR_PAD_LEFT)."</span>";
        echo                 str_pad(getByTagName($r->tags,'ageinihr'), 2, '0', STR_PAD_LEFT).":".str_pad(getByTagName($r->tags,'ageinimm'), 2, '0', STR_PAD_LEFT);
		echo	"</td>";
		echo	"<td id='agefimhr'><span>".str_pad(getByTagName($r->tags,'agefimhr'), 2, '0', STR_PAD_LEFT).":".str_pad(getByTagName($r->tags,'agefimmm'), 2, '0', STR_PAD_LEFT)."</span>";
		echo                 str_pad(getByTagName($r->tags,'agefimhr'), 2, '0', STR_PAD_LEFT).":".str_pad(getByTagName($r->tags,'agefimmm'), 2, '0', STR_PAD_LEFT);
		echo    "</td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';

?>
