<?
/*!
 * FONTE        : class_tags_emv.php
 * CRIAÇÃO      : Oscar
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Classe para tratar estrutura TLV.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 

class TagsEmv {

	private $tagList;     
	private $Script    	 = "";
	private $tagPosIni   = 0;
	private $taglength   = 0;
	private $tagValue  	 = "";
	
	function __construct ($Script, $tagListNames) { 
	  
	  $this->_setScript($Script, $tagListNames);
	  
	} 

	protected function _setScript($Script, $tagListNames){
		
		$this->Script  = $Script;	
		$this->tagList = array();
		
		foreach($tagListNames as $tagvalue) {
          
          $this->tagList[$tagvalue] = $this->getInternalTagValueByTagName($tagvalue);
    		
        };
			
	}
	
	protected function _getTagValueByTagName($tagName){
	   return $this->tagList[$tagName];
	}
	
    private function getInternalTagValueByTagName($tag){
	    
		$tagPosIni = stripos($this->Script, $tag);
		$tagValue  = "";
		
		if ($tagPosIni !== false) {
		
			$tagPosIni = stripos($this->Script, $tag) + strlen($tag);
			$taglength = hexdec(substr($this->Script, $tagPosIni, 02)) * 2;
			$tagValue  = substr($this->Script, $tagPosIni + 2, $taglength);
			
			$this->Script = substr($this->Script, stripos($this->Script, $tag) + 
												  strlen($tag) + 2 + 
												  $taglength, 
												  strlen($this->Script));
        }
		return $tagValue;
	}
	
}
?>

