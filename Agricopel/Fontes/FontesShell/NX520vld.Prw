#include 'Protheus.ch'    
#include 'Topconn.ch'      
#include "rwmake.ch"
   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MS520VLD  บAutor  ณLeandro F Silveira  บ Data ณ 11/01/2017 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada chamado antes da exclusao da nota fiscal  บฑฑ
ฑฑบ          ณ de saida.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function NX520vld()
      
	Local lRet      := .T.
	Local cMsg      := ""
	Local nAnoSF2   := 0
	Local nMesSF2   := 0
	Local nMesAtual := 0
	Local nAnoAtual := 0
	Local cCodUsuar := " "
	Local _cUserExc := ""

	_cUserExc :=  SuperGetMv("MV_XEXCNF", ,"000000")

	If (cEmpAnt <> '20' .AND. cEmpAnt <> '21' .AND. cEmpAnt <> '51' .AND. cEmpAnt <> '44')
		If (SF2->F2_ESPECIE <> 'CTE' .AND. SF2->F2_ESPECIE <> 'NFS' .AND. SF2->F2_ESPECIE <> 'NFPS')

			nAnoSF2   := Year(SF2->F2_EMISSAO)
			nMesSF2   := Month(SF2->F2_EMISSAO)
			nAnoAtual := Year(Date())
			nMesAtual := Month(Date())

			If (nMesSF2 <> nMesAtual .OR. nAnoSF2 <> nAnoAtual)

				cMsg := "Nใo foi possํvel excluir a nota fiscal, pois a mesma foi faturada em um m๊s/ano diferente da data atual." + CHR(13)
				cMsg += "Nota Fiscal: " + SF2->F2_DOC + CHR(13)
				cMsg += "Data de emissใo: " + DTOC(SF2->F2_EMISSAO) + CHR(13)
				cMsg += "Esp้cie: " + SF2->F2_ESPECIE

				cCodUsuar := RetCodUsr()
			
				If cCodUsuar $ _cUserExc //(cCodUsuar == "000000" .Or. cCodUsuar == "000296" .Or. cCodUsuar == "000018" .Or. cCodUsuar == "000017") // SE FOR USUมRIO ADMIN OU VANDERLEIA OU ELIANE chamado 61624 | ADICIONADO USUมRIO DO ALEXANDRE chamado 437340
					cMsg += CHR(13) + CHR(13) + "Deseja excluir mesmo assim?"
					lRet := MsgYesNo(cMsg)
				Else
					cMsg += CHR(13) + CHR(13) + " MV_XEXCNF - Para excluir a nota, entrar em contato com a contabilidade."
					Alert(cMsg)
					lRet := .F.
				EndIf
			Endif
		Endif	
	Endif

	//Impede a Exclusใo do Doc quando a NCF estiver baixada
	If SF2->F2_TIPO == 'D' .AND. U_XAG0053V(SF2->F2_FILIAL)
		lRet := U_XAG0053E(.F.)
	Endif    

Return lRet
