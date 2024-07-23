#Include "Rwmake.ch"
#INCLUDE "Topconn.ch"

User Function AGR064()
	OMSA010()

	cMsg := "Atencao: Se foi efetuada alguma alteracao na tabela de preco,"+chr(13)
	cMsg += "todas as regras de descontos vinculadas a esta tabela e produto serao alterados."		
	cMsg += "O processamento a seguir podera levar alguns minutos!!!!"	
	msgstop(cMsg)

	Processa({|lEnd| RecalcACP()})  // Chamada com regua
	
Return

/*BEGINDOC
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 GeL
//쿔ncluido em 08.08.03 por Valdecir.                                                                                                               �
//쿑uncao para Recalcular o preco unitario da Regra de Desconto com base na Tabela de preco 
//쿮 no percentual de desconto do item da regra de desconto.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 GeL
ENDDOC*/

Static Function RecalcACP()

	cxQuery := " "
	cxQuery += " SELECT DA1.DA1_FILIAL,DA1.DA1_CODTAB,DA1.DA1_PRCVEN,DA1.DA1_DATA,DA1.DA1_CODPRO,"
	cxQuery += " ACO.ACO_FILIAL, ACO.ACO_CODTAB,ACO.ACO_CODREG, ACO.ACO_CONDPG,ACO.ACO_CODCLI,ACO.ACO_LOJA,"
	cxQuery += " ACP.ACP_CODPRO,ACP.ACP_GRUPO,ACP.ACP_PERDES,ACP.ACP_PRECO"
	cxQuery += " FROM "+RetSqlName("DA1")+" DA1 (NOLOCK), "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK)"
	cxQuery += " WHERE DA1.D_E_L_E_T_ <> '*' AND ACO.D_E_L_E_T_ <> '*' AND ACP.D_E_L_E_T_ <> '*'"
	cxQuery += " AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"'AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"'"
	cxQuery += " AND  DA1.DA1_DATA <> ''"
	cxQuery += " AND  ACO.ACO_CODTAB = DA1.DA1_CODTAB"
	cxQuery += " AND  ACP.ACP_CODREG = ACO.ACO_CODREG"
	cxQuery += " AND  ACP.ACP_CODPRO = DA1.DA1_CODPRO"
	cxQuery += " ORDER BY DA1.DA1_CODTAB,ACO.ACO_CODREG,ACP.ACP_CODPRO"

	If (Select("MACP") <> 0)
		DbSelectArea("MACP")
		DbCloseArea()
	Endif       
	
	TcQuery cxQuery NEW ALIAS "MACP"

	TCSETFIELD("MACP","DA1.DA1_PRCVEN","N",10,4)
	TCSETFIELD("MACP","ACP.ACP_PERDES","N",10,4)	
	TCSETFIELD("MACP","DA1.DA1_DATA","D",08,0)

   DbSelectArea("MACP")	
	MACP->(ProcRegua(RecCount()))
   DbGotop()
   While !Eof()           

		IncProc("Processando Tabela: "+MACP->DA1_CODTAB+" Regra: "+MACP->ACO_CODREG)
		
		DbSelectArea("ACP")
		DbSetOrder(2)
		DbGotop()
		If DbSeek(xFilial("ACP")+MACP->ACO_CODREG+MACP->ACP_GRUPO+MACP->ACP_CODPRO,.T.)
		
			nPrcReg 	:= Round(MACP->DA1_PRCVEN - (( MACP->DA1_PRCVEN  * MACP->ACP_PERDES) / 100),4)
					
			DbSelectArea("ACP")
			RecLock("ACP",.F.)
				ACP->ACP_PRECO		:=	nPrcReg				
			MsUnLock("ACP")
			
			DbSelectArea("DA1")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("DA1")+MACP->DA1_CODTAB+MACP->DA1_CODPRO,.T.)
				DbSelectArea("DA1")
				RecLock("DA1",.F.)
					DA1->DA1_DATA := cTod("//")
				MsUnLock("DA1")			
			EndIf			
		EndIf

   	DbSelectArea("MACP")
   	MACP->(DbSkip())
   EndDo

Return