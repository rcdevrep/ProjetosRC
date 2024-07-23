#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"

/*
Realiza a importação de pedidos programados
*/

User Function AGR245F()

	Local   cPerg     := 'AGR245F'
	Local   cQuery    := ''
	Local   cPlaca    := 'XXXXXXXX'
	Local   cValNF    := '' 
	Local   cFilBKP   := cFilAnt
	Local   nViagem   := 99
	Private cNfImp    := ''
	
	If !(Pergunte(cPerg,.t.))
		Return
		//Seta Filial para importação
	Else
		If Empty(MV_PAR02)
			alert('Obrigatório preenchimento do Campo Filial ')
			Return
		Endif 
	Endif 

	//Valida se foi gerado nota para todos os pedidos programados
	cValNF := ValidaNF()

	If cValNF <> ''
		If !(MsgYesNo( cValNF +chr(13)+ chr(13)+'Deseja importar sem esse(s) pedidos? ','Atenção: Pedido(s) não faturado(s): '))
			cFilAnt := cFilBKP
			Return
		Endif  
	Endif 

	cFilant := MV_PAR02

	//Busca Placas Programadas
	cQuery := " SELECT C5_XVIAGEM,NNR_XBASE,C5_FILIAL,C5_NUM,C5_VEICULO,C5_CLIENTE,C5_LOJACLI,C5_XDTPRG,C5_XNUMPRG,D2_DOC,D2_SERIE,F2_VOLUME1,F2_VALFAT,F2_PLIQUI,A1_NOME,C5_XCONDUT,ZC_NUM  " 
	cQuery += " FROM "+RetSqlName('SC5')+" SC5 WITH (NOLOCK)  " 
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6 WITH (NOLOCK)  ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND "
	cQuery += " C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC6.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RetSqlName('SD2')+" SD2 WITH (NOLOCK)  ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO  "
	cQuery += " AND C6_ITEM = D2_ITEMPV AND SD2.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName('SF2') +" SF2 WITH (NOLOCK)  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND D2_SERIE = F2_SERIE AND SF2.D_E_L_E_T_ = '' "
	cQuery += " LEFT  JOIN "+RetSqlName('SZC') +" SZC WITH (NOLOCK)  ON F2_FILIAL = ZC_FILIAL AND F2_DOC = ZC_DOC AND ZC_SERIE = F2_SERIE AND SZC.D_E_L_E_T_ = '' "
	cQuery += " AND ZC_CLIENTE = F2_CLIENTE AND ZC_LOJA = F2_LOJA "	
	cQuery += " INNER JOIN "+RetSqlName('SA1') +" SA1 WITH (NOLOCK)  ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
	cQuery += " LEFT  JOIN "+RetSqlName('NNR') +" NNR WITH (NOLOCK)  ON C6_LOCAL = NNR_CODIGO AND NNR.D_E_L_E_T_ = ''
	cQuery += " AND NNR_FILIAL = '"+xFilial('NNR')+"' "
	cQuery += " WHERE C5_FILIAL = '"+MV_PAR02+"' AND C5_XDTPRG = '" + dtos(MV_PAR01) + "' "
	If !Empty(MV_PAR03)
		cQuery += " AND C6_LOCAL = '"+MV_PAR03+"' "
	Endif 
	cQuery += " AND SC5.D_E_L_E_T_ = '' AND SZC.ZC_NUM IS NULL "
	cQuery += " GROUP BY C5_FILIAL,C5_NUM,C5_VEICULO,C5_CLIENTE,C5_LOJACLI,C5_XDTPRG,C5_XNUMPRG,D2_DOC,D2_SERIE,F2_VOLUME1,F2_VALFAT,F2_PLIQUI,A1_NOME,NNR_XBASE,C5_XCONDUT,C5_XVIAGEM,ZC_NUM  "
	cQuery += " ORDER BY C5_FILIAL,C5_VEICULO,C5_XVIAGEM,D2_DOC,D2_SERIE,C5_NUM,C5_CLIENTE,C5_LOJACLI,NNR_XBASE "
    

	If (Select("AGR245F") <> 0)
		DbSelectArea("AGR245F")
		AGR245F->(DbCloseArea())
	Endif       

	TCQuery cQuery NEW ALIAS "AGR245F"

	DbSelectarea('AGR245F')

	//Se Trouxe Registros Exclui romaneios existentes para o Dia 
	//If AGR245F->(!eof())
	//	ExcluiSZB(MV_PAR02,MV_PAR01 )
	//Endif 
	
	While AGR245F->(!eof())


		//Se não encontrou registro - Grava 
		/*If alltrim(AGR245F->ZC_NUM) <> ''
			AGR245F->(DbSkip())
			loop
		Endif */

		//Grava cabeçalho 
		if (cPlaca <> AGR245F->C5_VEICULO) .or. nViagem <> AGR245F->C5_XVIAGEM .and.AGR245F->(!eof())
			GeraSZB()
			
			If !Empty(cNfImp) 
				cNfImp += +chr(10)+CHR(13)  
			Endif
			
			cNfImp +=  SZB->ZB_NUM +"     - "
		Endif 
		
		//Grava itens
		GeraSZC()
						
		cPlaca  := AGR245F->C5_VEICULO
		nViagem := AGR245F->C5_XVIAGEM
			

		AGR245F->(DbSkip())
	Enddo

	dbselectArea('SZB')
	dbSetOrder(3)
	Dbseek(xfilial('SZB')+DTOC(MV_PAR01) )

	If (Select("AGR245F") <> 0)
		DbSelectArea("AGR245F")
		AGR245F->(DbCloseArea())
	Endif   

	//Retorna para a filial anterior
	cFilAnt := cFilBKP

	If Empty(cNfImp)  
		MsgInfo('Nenhuma Nota encontrada para importação!')
	Else
		//MsgInfo(/*'Gerado romaneios:'+chr(13)+*/'Romaneio - Notas'+chr(13)+ cNfImp, 'Romaneios Gerados')
		U_MsgMemo('Romaneios Gerados','Romaneio - Notas'+chr(10)+chr(13)+ cNfImp,.f.)
	
	Endif 

Return

//Gera dados na tabela SZB
Static Function GeraSZB()

	Local cNumRom    := ""   


	DbSelectarea('SZB')
	Dbsetorder(3)
	If !( Dbseek( AGR245F->C5_FILIAL +AGR245F->C5_XDTPRG + AGR245F->C5_VEICULO))

		cNumRom := GETSX8NUM("SZB","ZB_NUM")

		Reclock('SZB',.T.)
			ZB_FILIAL  := AGR245F->C5_FILIAL 
			ZB_NUM     := cNumRom
			ZB_PLACA   := AGR245F->C5_VEICULO
			ZB_MOTORIS := AGR245F->C5_XCONDUT
			ZB_DTSAIDA := stod(AGR245F->C5_XDTPRG)
			ZB_KMSAIDA := 0 
			ZB_BASE    := AGR245F->(NNR_XBASE)
			ZB_DHIMP   :=  Dtos(Date())+' '+time() 
		SZB->(MsUnlock())
		//ZB_DTCHEGA := 
		//ZB_KMCHEGA :=
		If __lSX8
			ConfirmSX8()
		EndIf
	Else

		//É Necessario excluir SZC, pois pode alterar o documento perdendo a chave 
		//ExcluiSZC()

		Reclock('SZB',.F.)
			ZB_FILIAL  := AGR245F->C5_FILIAL 
			ZB_PLACA   := AGR245F->C5_VEICULO
			ZB_MOTORIS := AGR245F->C5_XCONDUT
			ZB_DTSAIDA := stod(AGR245F->C5_XDTPRG)
			ZB_KMSAIDA := 0
			ZB_BASE    := AGR245F->(NNR_XBASE) 
			ZB_DHIMP   :=  Dtos(Date())+' '+time() 
		SZB->(MsUnlock())
	
	Endif

Return 

//Gera dados na tabela SZC
Static Function GeraSZC()

    //C5_FILIAL,C5_NUM,C5_VEICULO,C5_CLIENTE,C5_LOJA,C5_XDTPRG,C5_XNUMPRG,D2_DOC,D2_SERIE
 	DbSelectArea("SZC")
	DbSetorder(1)
	RecLock("SZC",.T.)
		SZC->ZC_FILIAL  := AGR245F->C5_FILIAL
		SZC->ZC_NUM     := SZB->ZB_NUM
		SZC->ZC_DOC     := AGR245F->D2_DOC//aCols[_q,1]
		SZC->ZC_SERIE   := AGR245F->D2_SERIE//aCols[_q,2]
		SZC->ZC_PESO    := AGR245F->F2_PLIQUI//aCols[_q,3]
		SZC->ZC_VOLUME  := AGR245F->F2_VOLUME1//aCols[_q,4]
		SZC->ZC_VALOR   := AGR245F->F2_VALFAT//aCols[_q,5]
		SZC->ZC_CLIENTE	:= AGR245F->C5_CLIENTE //aCols[_q,6]
		SZC->ZC_LOJA    := AGR245F->C5_LOJACLI //aCols[_q,7]
		SZC->ZC_NOME    := AGR245F->A1_NOME//aCols[_q,8]
	SZC->(MsUnLock())

	cNfImp += AGR245F->D2_DOC + ' '

	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(SZC->ZC_FILIAL+SZC->ZC_DOC+SZC->ZC_SERIE+SZC->ZC_CLIENTE+SZC->ZC_LOJA)
		DbSelectArea("SF2")
		RecLock("SF2",.F.)
	 		SF2->F2_ROMANE := SZC->ZC_NUM
		SF2->(MsUnLock())
	EndIf 


Return 


Static Function ValidaNf()

	Local cRetNF := ''
	Local cQuery := ''


	//Busca Placas Programadas
	cQuery := " SELECT C5_FILIAL,C5_NUM,C5_VEICULO,C5_CLIENTE,C5_LOJACLI,C5_XDTPRG,C5_XNUMPRG,D2_DOC,D2_SERIE,F2_VOLUME1,F2_VALFAT,F2_PLIQUI,A1_NOME,C5_XCONDUT " 
	cQuery += " FROM "+RetSqlName('SC5')+" SC5 WITH (NOLOCK)  " 
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6 WITH (NOLOCK)  ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND "
	cQuery += " C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC6.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+RetSqlName('SD2') +" SD2 WITH (NOLOCK)  ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO  "
	cQuery += " AND C6_ITEM = D2_ITEMPV AND SD2.D_E_L_E_T_ = '' "
	cQuery += " LEFT  JOIN "+RetSqlName('SF2') +" SF2 WITH (NOLOCK)  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND D2_SERIE = F2_SERIE AND SF2.D_E_L_E_T_ = '' "
	cQuery += " LEFT  JOIN "+RetSqlName('SZC') +" SZC WITH (NOLOCK)  ON F2_FILIAL = ZC_FILIAL AND F2_DOC = ZC_DOC AND ZC_SERIE = F2_SERIE AND SZC.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName('SA1') +" SA1 WITH (NOLOCK)  ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE C5_FILIAL = '"+MV_PAR02+"' AND C5_XDTPRG = '" + dtos(MV_PAR01) + "' "
	If !Empty(MV_PAR03)
		cQuery += " AND C6_LOCAL = '"+MV_PAR03+"' "
	Endif 
	cQuery += " AND SC5.D_E_L_E_T_ = '' AND SD2.D2_DOC IS NULL "
	cQuery += " GROUP BY C5_FILIAL,C5_NUM,C5_VEICULO,C5_CLIENTE,C5_LOJACLI,C5_XDTPRG,C5_XNUMPRG,D2_DOC,D2_SERIE,F2_VOLUME1,F2_VALFAT,F2_PLIQUI,A1_NOME,C5_XCONDUT "
	cQuery += " ORDER BY C5_FILIAL,C5_VEICULO,D2_DOC,D2_SERIE,C5_NUM,C5_CLIENTE,C5_LOJACLI "


	If (Select("VALNF") <> 0)
		DbSelectArea("VALNF")
		VALNF->(DbCloseArea())
	Endif       

	TCQuery cQuery NEW ALIAS "VALNF"

	While VALNF->(!eof())
		
		cRetNF += VALNF->C5_NUM+' - ' + VALNF->C5_VEICULO + CHR(13)  

		VALNF->(dbSkip())

	Enddo
	
	If (Select("VALNF") <> 0)
		DbSelectArea("VALNF")
		VALNF->(DbCloseArea())
	Endif      


Return cRetNF


/*Static function ExcluiSZB(xFilSZB,XDTPRG)

	Local cQuery    := ""
	Local aAreaRom  := GetArea()

	cQuery := " SELECT ZB_FILIAL,ZB_NUM,R_E_C_N_O_ AS RECNO FROM "+RetSqlName('SZB')+" WITH (NOLOCK)"
	cQuery += " WHERE ZB_FILIAL = '"+xFilSZB+"' AND ZB_DTSAIDA  = '"+DTOS(XDTPRG)+"' AND D_E_L_E_T_ = '' AND ZB_DHIMP <> '' "

	If (Select("EXSZB") <> 0)
		DbSelectArea("EXSZB")
		EXSZB->(DbCloseArea())
	Endif       

	TCQuery cQuery NEW ALIAS "EXSZB"

	While EXSZB->(!eof())

		dbselectarea('SZB')
		dbgoto(EXSZB->RECNO)

		ExcluiSZC(EXSZB->ZB_FILIAL,EXSZB->ZB_NUM)
		
		Reclock('SZB',.F.)
			SZB->(dbDelete())
		SZB->(Msunlock())

		

		EXSZB->(dbSkip())
	Enddo

	If (Select("EXSZB") <> 0)
		DbSelectArea("EXSZB")
		EXSZB->(DbCloseArea())
	Endif   

	Restarea(aAreaRom)
Return*/

/*Static function ExcluiSZC(xFilSZB,xNUMSZB)

	Local cQuery := ""

	cQuery := " UPDATE  "+RetSqlName('SZC')+" SET D_E_L_E_T_ = '*' "
	cQuery += " WHERE ZC_FILIAL = '"+xFilSZB+"' AND ZC_NUM   = '"+xNUMSZB+"' AND D_E_L_E_T_ = '' 

	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Return */


