#Include 'Protheus.ch'
        
/*/{Protheus.doc} XAG0001
//Valida Dados para diversos bancos
@author Leandro Spiller
@since 30/08/2017
@version 1  
@param xCodBanco , caractere  , Codigo Banco
@param xNomeBanco, caractere  , Nome do Banco 
@param xAlert    , logico     , Exibe Msg de alerta 
@return logico, .T. caso a conta == banco
@type function
/*/
User Function XAG0001(xCodBanco,xNomeBanco,xAlert,xAgencia,xConta,xSubCon,xCarteira)  
	
	Local lRet  := .T. 
	Local lNyke := .F.
	Default xCodBanco  := ""
	Default xNomeBanco := ""            
	Default xAlert     := .T.
	Default xAgencia   := ""
	Default xConta     := "" 
	Default xSubCon	   := "" 
	Default xCarteira  := "" 
	
	Do Case
	Case alltrim(UPPER(xNomeBanco)) == 'BB' .or. 'BRASIL' $ alltrim(UPPER(xNomeBanco))
		If alltrim(xCodBanco) <> '001'
          lRet := .F.         
        Endif        
	Case alltrim(UPPER(xNomeBanco)) == 'SICOOB'
		If alltrim(xCodBanco) <> '756'
          lRet := .F.         
        Endif  
	Case alltrim(UPPER(xNomeBanco)) == 'BRADESCO'
		If alltrim(xCodBanco) <> '237'
          lRet := .F.         
        Endif  
	Case alltrim(UPPER(xNomeBanco)) == 'SAFRA'
		If alltrim(xCodBanco) <> '422'
          lRet := .F.         
        Endif  
	Case alltrim(UPPER(xNomeBanco)) == 'SANTANDER'
		If alltrim(xCodBanco) <> '033'
          lRet := .F.         
        Endif  
	Case alltrim(UPPER(xNomeBanco)) == 'CAIXA' .or.'CEF' $ alltrim(UPPER(xNomeBanco))  
		If alltrim(xCodBanco) <> '104'
          lRet := .F.         
        Endif   
   	Case alltrim(UPPER(xNomeBanco)) == 'NYKE' .or.'NYKE' $ alltrim(UPPER(xNomeBanco))  
		If alltrim(xCodBanco) <> '237' .OR. alltrim(xAgencia) <> '02693' .OR. alltrim(xConta) <> '00277207';
			.OR. alltrim(xSubCon) <> '001' .OR. alltrim(xCarteira) <> '09'
          lNyke := .T.
          lRet := .F.         
        Endif   
    EndCase 
         
    //Mostra aLerta de conta errada
    iF lNyke
    	MsgInfo(' Dados bancários informados inválidos para Projeto '+alltrim(xNomeBanco)+' !    ') 	
    Else
    	If xAlert .and. !lRet 
      		MsgInfo('  Conta informada não é do banco '+alltrim(xNomeBanco)+' !    ')
    	Endif
    Endif         
    
Return lRet 