#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include 'Protheus.ch'

/*/{Protheus.doc} AGX599
//Transfere registros da tabela TEMP_DT6 para a tabela DT6010
//TEMP_DT6 vêm de uma planilha importada
@author Rodrigo Berthelsen da Silveira
@version 1
@type function
/*/
User Function AGX599()

	RPCSetType(3)
	RPCSetEnv("01","01")

	ALERT("TMPDT6_7")

	cAliasQRY1 := GetNextAlias()

	cQuery := ""
	cQuery := "select DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DATEMI, DT6_VOLORI, DT6_QTDVOL ,DT6_VALMER, DT6_VALFRE, DT6_VALIMP, DT6_VALTOT, "
	cQuery += " DT6_PRIPER,DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, DT6_CLIDEV, DT6_LOJDEV, DT6_DEVFRE, DT6_SERVIC, DT6_STATUS, DT6_VENCTO, DT6_FILDEB, DT6_TIPO , DT6_MOEDA, DT6_VALFAT, DT6_CHVCTE FROM TEMP_DT6 "
	//cQuery += "	WHERE DT6_FILDOC in ('02','07') "

	If Select(cAliasQRY1) <> 0
		dbSelectArea(cAliasQRY1)
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY1)

	dbSelectArea(cAliasQRY1)
	dbGoTop()
	Do While !eof()
		dbSelectArea("DT6")
		RecLock("DT6",.T.)
		DT6->DT6_FILDOC := (cAliasQRY1)->DT6_FILDOC
		DT6->DT6_DOC    := (cAliasQRY1)->DT6_DOC
		DT6->DT6_SERIE  := (cAliasQRY1)->DT6_SERIE
		DT6->DT6_DATEMI :=  STOD((cAliasQRY1)->DT6_DATEMI)
		DT6->DT6_VOLORI := (cAliasQRY1)->DT6_VOLORI
		DT6->DT6_QTDVOL := ROUND((cAliasQRY1)->DT6_QTDVOL,0)
		DT6->DT6_VALMER := (cAliasQRY1)->DT6_VALMER
		DT6->DT6_VALFRE := (cAliasQRY1)->DT6_VALFRE
		DT6->DT6_VALIMP := (cAliasQRY1)->DT6_VALIMP
		DT6->DT6_VALTOT := (cAliasQRY1)->DT6_VALTOT
		DT6->DT6_PRIPER := (cAliasQRY1)->DT6_PRIPER
		DT6->DT6_CLIREM := (cAliasQRY1)->DT6_PRIPER
		DT6->DT6_CLIREM := (cAliasQRY1)->DT6_CLIREM
		DT6->DT6_LOJREM := (cAliasQRY1)->DT6_LOJREM
		DT6->DT6_CLIDES := (cAliasQRY1)->DT6_CLIDES
		DT6->DT6_LOJDES := (cAliasQRY1)->DT6_LOJDES
		DT6->DT6_CLIDEV := (cAliasQRY1)->DT6_CLIDEV
		DT6->DT6_LOJDEV := (cAliasQRY1)->DT6_LOJDEV
		DT6->DT6_DEVFRE := (cAliasQRY1)->DT6_DEVFRE
		DT6->DT6_SERVIC := (cAliasQRY1)->DT6_SERVIC
		DT6->DT6_STATUS := (cAliasQRY1)->DT6_STATUS
		DT6->DT6_VENCTO := STOD((cAliasQRY1)->DT6_VENCTO)
		DT6->DT6_FILDEB := (cAliasQRY1)->DT6_FILDEB
		DT6->DT6_TIPO   := (cAliasQRY1)->DT6_TIPO
		DT6->DT6_MOEDA  := (cAliasQRY1)->DT6_MOEDA
		DT6->DT6_VALFAT := (cAliasQRY1)->DT6_VALFAT
		DT6->DT6_CHVCTE := (cAliasQRY1)->DT6_CHVCTE
		MsUnLock()

		dbSelectArea(cAliasQRY1)
		(cAliasQRY1)->(dbSkip())
	EndDo

	RpcClearEnv()
	ALERT("FIM")

Return()