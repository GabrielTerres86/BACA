<? 
/*!
 * FONTE        : revisao_cadastral.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 26/04/2010 
 * OBJETIVO     : Arquivo para realizar a revisão cadastral de forma genérica
 * 001: [22/10/2010] David       (CECRED) : Incluir parametro na funcao getDataXML
 */  
?>
 
<?	
    session_start();
	require_once('../includes/config.php');
	require_once('../includes/funcoes.php');
	require_once('../includes/controla_secao.php');
	require_once('../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica parâmetros necessários
	if ( !isset($_POST['nrdconta']) || 
	     !isset($_POST['idseqttl']) || 
	     !isset($_POST['chavealt']) || 
	     !isset($_POST['tpatlcad']) || 
	     !isset($_POST['businobj']) ) exibirErro('error','Par&acirc;metros incorretos para realizar a revis&atilde;o cadastral.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta 		= (isset($_POST['nrdconta'      ])) ? $_POST['nrdconta'      ] : '' ;
	$idseqttl 		= (isset($_POST['idseqttl'      ])) ? $_POST['idseqttl'      ] : '' ;	
	$chavealt 		= (isset($_POST['chavealt'      ])) ? $_POST['chavealt'      ] : '' ;
	$tpatlcad 		= (isset($_POST['tpatlcad'      ])) ? $_POST['tpatlcad'      ] : '' ;
	$businobj 		= (isset($_POST['businobj'      ])) ? $_POST['businobj'      ] : '' ;
	$stringArrayMsg = (isset($_POST['stringArrayMsg'])) ? $_POST['stringArrayMsg'] : '' ;
	$metodo 		= (isset($_POST['metodo'        ])) ? $_POST['metodo'        ] : '' ;
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>'.$businobj.'</Bo>';
	$xml .= '		<Proc>proc_altcad</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';	
	$xml .= '       <chavealt>'.$chavealt.'</chavealt>';
	$xml .= '       <tpatlcad>'.$tpatlcad.'</tpatlcad>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	$msg = Array();
	$msg = explode("|", $stringArrayMsg);
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode("|", $msg);
	
	echo 'exibirMensagens(\''.$stringArrayMsg.'\',\''.$metodo.'\');';
    exibirErro('inform',$msgRetorno.'Alterações realizadas com sucesso'.$msgAlerta,'Alerta - Ayllos','controlaOperacao(\'\')',false);
?>