#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"


user function MTA650I()
Local oIntegrador := OKEA_Integracao():New()
Local oOpData := OKEA_OpData():New()
Local cMensagem := ""

	cQuery := "select "
	cQuery += "CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) CDOP, "
	cQuery += "' ' OPER, "
	cQuery += "REPLACE(CONCAT(CONCAT(G2_FERRAM,CASE WHEN H3_FERRAM <> ' ' THEN ',' ELSE ' ' END),H3_FERRAM),'-','') CDFER,  "
	cQuery += "SH4.H4_DESCRI DESCFER,  "
	cQuery += "'1' ESTR, "
	cQuery += "C2_PRODUTO CDPROD, "
	cQuery += "B1_DESC PROD, "
	cQuery += "B1_UM UNIDADE, "
	cQuery += "'FLUIDRA' CLI, "
	cQuery += "H1_MAQUINA MAQ, "
	cQuery += "SH4.H4_CICLOMA TXPROD, "
	cQuery += "2 TIPO, "
	cQuery += "SH4.H4_NUMCAV PCICLO, "
	cQuery += "1 PPECAS, "
	cQuery += "C2_DATPRI DTINI, "
	cQuery += "C2_DATPRF DTENT, "
	cQuery += "C2_QUANT QTPECA "

	cQuery += "from "+RETSQLNAME("SC2")+" SC2 "
	cQuery += "left join "+RETSQLNAME("SH3")+" SH3 on H3_PRODUTO = C2_PRODUTO AND SH3.D_E_L_E_T_ <> '*'  "
	cQuery += "left join "+RETSQLNAME("SG2")+" SG2 on G2_PRODUTO = C2_PRODUTO AND G2_OPERAC = '01' AND SG2.D_E_L_E_T_ <> '*' "
	cQuery += "left join "+RETSQLNAME("SH4")+" SH4 on SH4.H4_CODIGO = G2_FERRAM AND SH4.D_E_L_E_T_ <> '*' "
	cQuery += "left join "+RETSQLNAME("SH1")+" SH1 on SH1.D_E_L_E_T_ <> '*' AND H1_CODIGO = G2_RECURSO  "
	cQuery += "inner join "+RETSQLNAME("SB1")+" SB1 on B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += "where CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' AND C2_FILIAL = '"+xFilial("SC2")+"' "

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

		oOpData:UnidadeProduto:Sigla          := alltrim(TRB->UNIDADE)
		oOpData:UnidadeProduto:Descricao      := alltrim(TRB->UNIDADE)   
		oOpData:UnidadeProduto:CasasDecimais  := 2 

		oIntegrador:Url := "VirtualLoomService.svc/Rest/RestIntegracaoDAO_CriarOrdemCompleta"
		oIntegrador:Body := oOpData

		oIntegrador := oIntegrador:Enviar()

		If(oIntegrador:Retorno)

			cMensagem := RetornoIntegracao:Mensagem
			FWAlertSuccess(cMensagem, "MTA650I")
			
		ELSE

			cMensagem := RetornoIntegracao:Mensagem
			FWAlertError(cMensagem, "MTA650I")			

		ENDIF

	EndIf
	dbCloseArea()


	

return



