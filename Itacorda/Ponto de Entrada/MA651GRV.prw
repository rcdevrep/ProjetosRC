#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"


//user function MTA650I()

	//PONTO DE ENTRADA DESATIVADO DEVIDO IMPLEMENTAÇÃO DO MRP
	//U_OKEAMES()

//return

User Function MA651GRV


//EXECUTADO APÓS A TROCA DO STATUS DE FIRME
U_OKEAMES(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)

Return 


USER FUNCTION OKEATESTE()

	RpcSetType(3)
	RPCSetEnv("01", "0101", , , , , , .T., .T., .T.)

	U_OKEAMES("03307301001")

RETURN

USER FUNCTION OKEAMES(cNumOP)

	Local oIntegrador := OKEA_Integracao():New()
	Local oOpData := OKEA_OpData():New()
	Local cMensagem := ""

	cQuery := "select "
	cQuery += "CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) CDOP, "
	cQuery += "C2_PRODUTO CDPROD, "
	cQuery += "B1_DESC PROD, "
	cQuery += "B1_UM UNIDADE, "
	cQuery += "B1_UMPRIN UNIDMES, "
	cQuery += "B1_FATOR FATORMES, "
	cQuery += "B1_TIPFATO TPCONVMES, "
	cQuery += "C2_DATPRI DTINI, "
	cQuery += "C2_DATPRF DTENT, "
	cQuery += "ROUND(CASE WHEN B1_TIPFATO = 'M' THEN C2_QUANT * B1_FATOR ELSE  C2_QUANT / B1_FATOR END,2) QTPECA "

	cQuery += "from "+RETSQLNAME("SC2")+" SC2 "
	cQuery += "inner join "+RETSQLNAME("SB1")+" SB1 on B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ <> '*' "
	//cQuery += "where CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' AND C2_FILIAL = '"+xFilial("SC2")+"' "
	cQuery += "where CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) = '"+cNumOp+"' AND C2_FILIAL = '"+xFilial("SC2")+"' "


	conout(cQuery)

	If !Empty(Select("TRB"))
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "TRB"

	dbSelectArea('TRB')
	dbgotop()
	IF TRB->(!Eof())

		oOpData:NumeroOp           := val(TRB->CDOP)
		oOpData:DataEntrega        := STOD(TRB->DTENT)
		oOpData:DataCriacao        := dDataBase
		oOpData:Quantidade         := TRB->QTPECA
		oOpData:TipoSituacao       := 1
		oOpData:TipoProducao       := 1
		oOpData:RoteiroProducaoId  := 0

		oOpData:FichasTecnicas:Quantidade     := TRB->QTPECA
		oOpData:FichasTecnicas:PosicaoSlots   := 1
		oOpData:FichasTecnicas:SlotsParalelos := 1

		oOpData:FichasTecnicas:Artigo:Referencia    := alltrim(TRB->CDPROD)
		oOpData:FichasTecnicas:Artigo:Descricao     := alltrim(TRB->PROD)

		oOpData:UnidadeProduto:Sigla          := alltrim(TRB->UNIDMES)
		oOpData:UnidadeProduto:Descricao      := alltrim(TRB->UNIDMES)
		oOpData:UnidadeProduto:CasasDecimais  := 2

		oIntegrador:Url := "VirtualLoomService.svc/Rest/RestIntegracaoDAO_CriarOrdemCompleta"
		oIntegrador:Body := oOpData

		oIntegrador := oIntegrador:Enviar()

		Dbselectarea("SC2")
		DbSetOrder(1)
		dbGotop()
		IF(DbSeek(xFilial("SC2")+cNumOp))
			If(oIntegrador:Retorno)

				cMensagem := RetornoIntegracao:Mensagem
				RECLOCK("SC2",.F.)
				SC2->C2_STATMES := "1" // ENVIADO OK
				MSUNLOCK()
				FWAlertSuccess(cMensagem, FunName())

			ELSE

				cMensagem := RetornoIntegracao:Mensagem
				RECLOCK("SC2",.F.)
				SC2->C2_STATMES := "2" // ERRO NO ENVIO
				MSUNLOCK()
				FWAlertError(cMensagem, FunName())

			ENDIF

		ENDIF

	EndIf
	dbCloseArea()



RETURN
