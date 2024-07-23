#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDOX05
Integração DOX - Verificações no Sefaz
@author Leandro Spiller
@since 22/07/2020
@version 1.0
/*/
User Function XAGDOX05(_oJsonDOX)
	
	Local creturn  := "Falhou"
	Private oWS   
	Private oRetDox    := DOXWsRetorno():New()
	Private cChave     := "42210781632093000411550030003698811100047740"
	Private cCnpj      := "06888426000100"
	Private _cEmpFil   := "0103"

	cDoc      := _oJsonDOX:GetJsonText("documento")
	cSerie    := _oJsonDOX:GetJsonText("serie")
	cChave    := _oJsonDOX:GetJsonText("chave")
	_cEmpFil  := _oJsonDOX:GetJsonText("empFil")

	If !Empty(_cEmpFil)
		
		//RPCSetType(3)
		//RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"","","","",{"SA1","SF2"})

		
		RPCClearEnv()
		RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"USERREST","*R3st2021","","",{"SA1","SF2"})

		dbselectarea('SF2')
		 
		If alltrim(cChave) <> '' 
			dbsetorder(10)
			If !(dbSeek(xfilial('SF2') + cChave))
				//creturn := 'N'
				RetErro("Nota Fiscal não encontrada no Protheus")
			Endif 	
		Else
			dbsetorder(1)
			If !(dbSeek(xfilial('SF2')+ cDoc + cSerie ))
				//creturn := 'N'
				RetErro("Nota Fiscal não encontrada no Protheus")
			Endif 
			cChave := SF2->F2_CHVNFE 
		Endif 
	
		cCnpj := POSICIONE('SA1',1,xfilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_CGC' )

		If cCnpj = ''
			creturn := 'C'
			RetErro("Cliente nao encontrado no Protheus")
		Endif 
	
		oWS := WSUrbano():New() 
		oWS:Reset()
			
		oWS:cLogin  := AllTrim(GetNewPar("MV_ZSNWSUS", "integracao.agricopel"))
		oWS:cSenha  := AllTrim(GetNewPar("MV_ZSNWSPS", "j67@s2ij"))
		oWS:cCNPJ	:= cCNPJ
		oWS:cCHAVE	:= cCHAVE

		If oWS:ConsultaManifEmit()
			creturn := OWS:CCONSULTAMANIFEMITRESULT
			RetSucesso(creturn)
		Endif  

		//RPCClearEnv()
	Else
		RetErro("Nao foi possivel encontrar a empresa no Protheus!")
	Endif 

	//0 - Não Manifestado
	//1 - Ciencia da operação
	//2 - confirmação da operação
	//3 - desconhecimento da operação 
	//4 - operação nao realizadaadmin	
	//Z - documento não encontrado na Sefaz
	//C - Cliente nao encontrado
	//N - Nota fiscal não encontrada

Return(oRetDox)


Static Function RetErro(msgErro)

	oRetDox:errorMessage += msgErro + "|"
	oRetDox:Sucesso      := .F.

Return()

Static Function RetSucesso(mensagem)

	oRetDox:errorMessage := ""
	oRetDox:msgSucesso   := mensagem
	oRetDox:Sucesso      := .T.

Return()

