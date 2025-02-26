#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#DEFINE LF chr(10)


User Function ITA10A01()

	Local aSeek   := {}
	Local bKeyF12			:= {|| REFRESH(.T.) }
	Private oMark
	Private cError := ""
	Private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11
	Private _Mv_par01,_Mv_par02,_Mv_par03,_Mv_par04,_Mv_par05,_Mv_par06,_Mv_par07,_Mv_par08,_Mv_par09,_Mv_par10,_Mv_par11
	Private aSize := MsAdvSize(.F.)
	Private nJanLarg := aSize[5]
	Private nJanAltu := aSize[6]
	Private oDlgExemp



	cPerg := "ITA10A01"


	If	!Pergunte(cPerg,.T.)
		Msginfo("Cancelado!","Tela de Ops em Aberto")
		return
	Endif

	// FILIAL - NUMOP - CODPRO - PRODUTO - LOCPAD -  QUANT - PREVINI - PREVFIM - STATUS - TPOP - OPERACAO - DESCRICAO - LEGENDA - PRODOPERA - TEMPO - OPERADOR - IDADE

	aStru:={}
	Aadd(aStru,{"OK"     ,"C",02,0})
	Aadd(aStru,{"FILIAL","C",04,0})
	Aadd(aStru,{"NUMOP","C",12,0})
    Aadd(aStru,{"OKEA","C",1,0})
	Aadd(aStru,{"CODPRO"   ,"C",10,0})
	Aadd(aStru,{"PRODUTO"   ,"C",200,0})
	Aadd(aStru,{"LOCPAD"   ,"C",02,0})
	Aadd(aStru,{"QUANT","N",09,0})
	Aadd(aStru,{"CICLO","N",09,0})
	Aadd(aStru,{"CAVID","N",09,0})
	Aadd(aStru,{"PREVINI"  ,"D",8,0})
	Aadd(aStru,{"PREVFIM"  ,"D",8,0})
	Aadd(aStru,{"STATUS"  ,"C",2,0})
	Aadd(aStru,{"TPOP"  ,"C",20,0})
	Aadd(aStru,{"OPERACAO"  ,"C",20,0})
	Aadd(aStru,{"DESCRICAO"  ,"C",300,0})
	Aadd(aStru,{"LEGENDA"  ,"C",20,0})
	Aadd(aStru,{"PRODOPERA"  ,"N",09,0})
	Aadd(aStru,{"PERDA"  ,"N",09,0})
	Aadd(aStru,{"TEMPO"  ,"C",1,0})
	Aadd(aStru,{"OPERADOR"  ,"C",100,0})
	Aadd(aStru,{"IDADE"  ,"C",20,0})
	Aadd(aStru,{"GRUPTRAB"  ,"C",20,0})
	Aadd(aStru,{"DESCGRUP"  ,"C",20,0})



	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	aAdd(aSeek,{"NUMOP"	,{{"","C",010,0,"Numero Op"	,"@!"}} } )
	aAdd(aSeek,{"CODPRO"	,{{"","C",009,0,"Codigo Produto"	,"@!"}} } )
	aAdd(aSeek,{"PRODUTO"	,{{"","C",006,0,"Produto"	,"@!"}} } )
	Processa({||GeraDados()},'Gerando informacoes...')

	DEFINE MSDIALOG oDlgExemp TITLE "TAcompanhamento de OPs"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgExemp,.F.)

	oFWLayer:addLine("CORPO",  095, .F.)
	oFWLayer:addLine("RODAPE", 005, .F.)

	oFWLayer:addCollumn("COLGRID",      100, .T., "CORPO")
	oFWLayer:addCollumn("COLBTN",     100, .T., "RODAPE")

	oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "CORPO")
	oPanSair   := oFWLayer:GetColPanel("COLBTN",    "RODAPE")

	oMark := FWMarkBrowse():New()
	oMark:SetDescription('TELA DE OPS')

	oMark:SetParam(bKeyF12)
	oMark:SetAlias("TRB")
	oMark:SetFieldMark( "OK" )
	oMark:oBrowse:SetDBFFilter(.T.)
	oMark:oBrowse:SetUseFilter(.T.)
	oMark:oBrowse:SetFixedBrowse(.T.)
	oMark:SetWalkThru(.F.)
	oMark:SetAmbiente(.T.)
	oMark:SetTemporary()
	oMark:oBrowse:SetSeek(.T.,aSeek)
	oMark:oBrowse:SetFilterDefault("")

	bAPT := {|| EnviaOkea() }
	bCC := {|| CloseBrowse() }

	oMark:AddButton('Enviar OKEA',bAPT)
	//oMark:AddButton('Sair',bCC)
	//oMark:AddButton('Sair',bCC)
	//oMark:AddButton('Sair',bCC)
	//oMark:AddButton('Sair',bCC)


	oMark:ForceQuitButton(.T.)

	//oMark:AddLegend( "STATUS != 'E'", "ORANGE",	"Não Enviado" )
	//oMark:AddLegend( "STATUS == 'E'", "GREEN",	"Enviado" )

	// FILIAL - NUMOP - CODPRO - PRODUTO - LOCPAD -  QUANT - PREVINI - PREVFIM - STATUS - TPOP

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||FILIAL})
	oColumn:SetTitle("Filial")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||NUMOP})
	oColumn:SetTitle("Num OP")
	oColumn:SetSize(3)
	oMark:SetColumns({oColumn})

    oColumn := FWBrwColumn():New()
	oColumn:SetData({||OKEA})
	oColumn:SetTitle("Okea")
	oColumn:SetSize(3)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||CODPRO})
	oColumn:SetTitle("Codigo")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||PRODUTO})
	oColumn:SetTitle("Produto")
	oColumn:SetSize(10)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||LOCPAD})
	oColumn:SetTitle("Armazem")
	oColumn:SetSize(10)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||QUANT})
	oColumn:SetTitle("Quantidade")
	oColumn:SetSize(5)
	oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
	oColumn:SetData({||PRODOPERA})
	oColumn:SetTitle("Saldo Pendente")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||CICLO})
	oColumn:SetTitle("Ciclo Maq")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||CAVID})
	oColumn:SetTitle("Cavidades")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||PREVINI})
	oColumn:SetTitle("Prev Ini")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||PREVFIM})
	oColumn:SetTitle("Prev Fim")
	oColumn:SetSize(5)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||STATUS})
	oColumn:SetTitle("Status")
	oColumn:SetSize(3)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||TPOP})
	oColumn:SetTitle("Tipo OP")
	oColumn:SetSize(6)
	oMark:SetColumns({oColumn})

	//OPERACAO - DESCRICAO - LEGENDA - PRODOPERA - TEMPO - OPERADOR - IDADE

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||OPERACAO})
	oColumn:SetTitle("Operacao")
	oColumn:SetSize(3)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||DESCRICAO})
	oColumn:SetTitle("Descricao")
	oColumn:SetSize(20)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||LEGENDA})
	oColumn:SetTitle("Legenda")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})



	oColumn := FWBrwColumn():New()
	oColumn:SetData({||PERDA})
	oColumn:SetTitle("Perda")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||TEMPO})
	oColumn:SetTitle("Tempo")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||OPERADOR})
	oColumn:SetTitle("Operador")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||IDADE})
	oColumn:SetTitle("Idade")
	oColumn:SetSize(30)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||GRUPTRAB})
	oColumn:SetTitle("Cod.Grup")
	oColumn:SetSize(2)
	oMark:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||DESCGRUP})
	oColumn:SetTitle("Grupo Trab.")
	oColumn:SetSize(10)
	oMark:SetColumns({oColumn})

	oMark:SetOwner(oPanGrid)

	oMark:Activate()
	oMark:oBrowse:Setfocus()

	Activate MsDialog oDlgExemp Centered


Return

STATIC FUNCTION REFRESH(lPerg)
	IF lPerg
		If	!Pergunte("VEIM007",.T.)
			Msginfo("Cancelado!","Picking")
			return
		Endif
	ENDIF


	Processa({||GeraDados()},'Gerando informacoes...')
	oMark:SetInvert(.F.)
	oMark:Refresh(.T.)
RETURN

// FILIAL - NUMOP - CODPRO - PRODUTO - LOCPAD -  QUANT - PREVINI - PREVFIM - STATUS - TPOP - OPERACAO - DESCRICAO - LEGENDA - PRODOPERA - TEMPO - OPERADOR - IDADE 

static function GeraDados()

	Local cPermissao := ""
	Private _oDZPR			:= oDZPR010():New()

	_UsersEstoque := Alltrim(_oDZPR:getTabelaGenerica("VEIM007","ESTOQUE"))
	_UsersProducao := Alltrim(_oDZPR:getTabelaGenerica("VEIM007","PRODUCAO"))
	bEstoque := __cUserId $ _UsersEstoque
	bProducao := __cUserId $ _UsersProducao
	bAdmin := __cUserId = "000000"

	cQuery := ""
	cQuery2 := ""
	cQuery3 := ""
	cQuery += "select C2_FILIAL FILIAL, CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) NUMOP, C2_STATMES OKEA, "
	cQuery += "C2_PRODUTO CODPRO, B1_DESC PRODUTO, C2_LOCAL LOCPAD, C2_QUANT QUANT, C2_DATPRI PREVINI, C2_DATPRF PREVFIM, "
	cQuery += "C2_STATUS STATUS, C2_TPOP TPOP, G2_OPERAC OPERACAO, G2_DESCRI DESCRICAO, "
	cQuery += "CASE WHEN C2_TPOP = 'F' AND C2_QUJE >= C2_QUANT THEN 'Encerrada Totalmente'  "
	cQuery += "ELSE CASE WHEN C2_TPOP = 'F' AND C2_QUJE = 0 THEN 'Aberta'  "
	cQuery += "ELSE CASE WHEN C2_TPOP = 'F' AND C2_QUJE < C2_QUANT THEN 'Encerrada Parcialmente' ELSE "
	cQuery += "'Outro Status' END END END AS LEGENDA, NVL(H6_QTDPROD,0)  PRODOPERA,NVL(H6_QTDPERD,0) PERDA, NVL(H6_TEMPO,'00:00') TEMPO, NVL(H6_OPERADO,'PENDENTE') OPERADOR, "
	cQuery += "CASE WHEN TO_DATE(C2_DATPRI,'YYYYMMDD') < SYSDATE - 30 AND C2_QUJE < C2_QUANT THEN 'Acima de 30 Dias'   "
	cQuery += "else CASE WHEN  C2_QUJE >= C2_QUANT THEN 'Encerrada' ELSE 'Atual'END END IDADE, SH4.H4_NUMCAV CAVID, SH4.H4_CICLOMA CICLO, G2_CTRAB GRUPTRAB, HB_NOME DESCGRUP, "

	cQuery += "(select SUM(H6_QTDPROD - H6_QTDPERD) from "+RETSQLNAME("SH6")+" TOT where  "
	cQuery += "TOT.D_E_L_E_T_ <> '*' AND H6_OP =  CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) AND H6_FILIAL = C2_FILIAL AND H6_PRODUTO = C2_PRODUTO AND G2_OPERAC = "
	cQuery += "H6_OPERAC) QTD_TOTAL "

	cQuery2 += "from "+RETSQLNAME("SC2")+" SC2  "
	cQuery2 += "inner join "+RETSQLNAME("SB1")+" SB1 on B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ <> '*' "
	//cQuery += "inner join "+RETSQLNAME("SB2")+" SB2 on B1_COD = B2_COD AND B2_LOCAL = 'GF' AND B2_FILIAL = C2_FILIAL AND SB1.D_E_L_E_T_ <> '*' "
	cQuery2 += "inner join "+RETSQLNAME("SG2")+" SG2 on G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ <> '*' AND SUBSTR(G2_FILIAL,1,2) = SUBSTR(C2_FILIAL,1,2) "
	cQuery2 += "inner join "+RETSQLNAME("SHB")+" SHB on G2_CTRAB = HB_COD AND SHB.D_E_L_E_T_ <> '*' "
	cQuery2 += "left join "+RETSQLNAME("SH6")+" SH6 on SH6.D_E_L_E_T_ <> '*' AND H6_OP =  CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) AND H6_FILIAL = C2_FILIAL AND H6_PRODUTO = C2_PRODUTO AND G2_OPERAC = H6_OPERAC "
	cQuery2 += "left join "+RETSQLNAME("SH3")+" SH3 on H3_PRODUTO = C2_PRODUTO AND SH3.D_E_L_E_T_ <> '*' AND H3_FILIAL = '02'"
	//cQuery += "left join "+RETSQLNAME("SG2")+" SG2 on G2_PRODUTO = C2_PRODUTO AND G2_OPERAC = '01' AND SG2.D_E_L_E_T_ <> '*' AND G2_FILIAL = '02' "
	cQuery2 += "left join "+RETSQLNAME("SH4")+" SH4 on SH4.H4_CODIGO = G2_FERRAM AND SH4.D_E_L_E_T_ <> '*' AND SH4.H4_FILIAL = '02' "



	cQuery2 += "where SC2.D_E_L_E_T_ <> '*' AND C2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND C2_FILIAL = '"+cFilAnt+"' AND C2_EMISSAO <= '"+DTOS(MV_PAR02)+"'  "
	cQuery2 += "AND C2_PRODUTO >= '"+MV_PAR06+"' AND C2_PRODUTO <= '"+MV_PAR07+"' AND CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) >= '"+MV_PAR03+"' "
	cQuery2 += "AND CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN) <= '"+MV_PAR04+"' "

	if(bEstoque)

		//select MAX(G2_OPERAC) ULTIMA from SG2010 SG2 where D_E_L_E_T_ <> '*' AND G2_PRODUTO = '"+_cCodPro+"'

		cPermissao := " AND ((SELECT SUM(H6_QTDPROD) H6_QTDPROD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = CONCAT(CONCAT(C2_NUM,C2_ITEM),C2_SEQUEN)  AND D_E_L_E_T_ <> '*') > 0 OR G2_OPERAC = '01')  "
		cPermissao += " AND G2_CTRAB = '0041' "

	endif

	if(bProducao)
		cPermissao := "AND G2_CTRAB <> '0041' "
	endif

	if(!bAdmin)
		cQuery3 += cPermissao
	endif



	IF(!EMPTY(MV_PAR08))
		cQuery3 += "AND B1_TIPO = '"+MV_PAR08+"' "
	ENDIF

	IF(MV_PAR05 == 1) //TOTAL
		cQuery3 += "AND C2_TPOP = 'F' AND C2_QUJE >= C2_QUANT "
	ENDIF

	IF(MV_PAR05 == 2) //PARCIAL
		cQuery3 += "AND C2_TPOP = 'F' AND C2_QUJE < C2_QUANT AND C2_QUJE <> 0 AND C2_DATRF = ' ' " //C2_TPOP = 'F' AND C2_QUJE < C2_QUANT
		//IF(MV_PAR09 == 1) //VENCIDAS
		//cQuery3 += "AND TO_DATE(C2_DATPRI,'YYYYMMDD') < SYSDATE - 30 AND C2_QUJE < C2_QUANT "
		//ENDIF
	ENDIF

	IF(MV_PAR05 == 3) //ABERTAS
		cQuery3 += "AND C2_TPOP = 'F' AND C2_QUJE = 0 "
		//IF(MV_PAR09 == 1) //VENCIDAS
		//cQuery3 += "AND TO_DATE(C2_DATPRI,'YYYYMMDD') < SYSDATE - 30 AND C2_QUJE < C2_QUANT "
		//ENDIF
	ENDIF

	cQuery3 += "ORDER BY C2_NUM, G2_OPERAC"




	//IF(!EMPTY(MV_PAR05))
	//cQuery += "AND B1_TIPO = '"+MV_PAR08+"' "
	//ENDIF

	If (Select("TEMPSC2") <> 0)
		dbSelectArea("TEMPSC2")
		dbCloseArea()
	Endif
	TCQuery cQuery + cQuery2 + cQuery3 NEW ALIAS "TEMPSC2"
	TCSetField("TEMPSC2","QUANT","N",14,2)
	TCSetField("TEMPSC2","PRODOPERA","N",14,2)
	TCSetField("TEMPSC2","PERDA","N",14,2)


	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("01", {"NUMOP"} )
	oTempTable:AddIndex("02", {"CODPRO"} )
	oTempTable:AddIndex("03", {"PRODUTO"} )


	oTempTable:Create()
	DbSelectArea('TRB')

	// FILIAL - NUMOP - CODPRO - PRODUTO - LOCPAD -  QUANT - PREVINI - PREVFIM - STATUS - TPOP - OPERACAO - DESCRICAO - LEGENDA - PRODOPERA - TEMPO - OPERADOR - IDADE

	dbSelectArea("TEMPSC2")
	dbGoTop()
	Procregua(reccount())
	While !EOF()
		RECLOCK('TRB',.T.)
		TRB->FILIAL := ALLTRIM(TEMPSC2->FILIAL)
		TRB->NUMOP := ALLTRIM(TEMPSC2->NUMOP)
        TRB->OKEA := ALLTRIM(TEMPSC2->OKEA)
		TRB->CODPRO := ALLTRIM(TEMPSC2->CODPRO)
		TRB->PRODUTO := ALLTRIM(TEMPSC2->PRODUTO)
		TRB->LOCPAD 	:= ALLTRIM(TEMPSC2->LOCPAD)
		TRB->QUANT := TEMPSC2->QUANT
		TRB->PREVINI   := STOD(TEMPSC2->PREVINI)
		TRB->PREVFIM   := STOD(TEMPSC2->PREVFIM)
		TRB->STATUS    := ALLTRIM(TEMPSC2->STATUS)
		TRB->TPOP   := ALLTRIM(TEMPSC2->TPOP)
		TRB->OPERACAO   := ALLTRIM(TEMPSC2->OPERACAO)
		TRB->DESCRICAO   := ALLTRIM(TEMPSC2->DESCRICAO)
		TRB->LEGENDA := ALLTRIM(TEMPSC2->LEGENDA)
		TRB->PRODOPERA  := TEMPSC2->QUANT - TEMPSC2->QTD_TOTAL
		TRB->PERDA  := TEMPSC2->PERDA
		TRB->TEMPO := ALLTRIM(TEMPSC2->TEMPO)
		TRB->OPERADOR := ALLTRIM(TEMPSC2->OPERADOR)
		TRB->IDADE := TEMPSC2->IDADE
		TRB->CICLO := TEMPSC2->CICLO
		TRB->CAVID := TEMPSC2->CAVID
		TRB->GRUPTRAB := TEMPSC2->GRUPTRAB
		TRB->DESCGRUP := TEMPSC2->DESCGRUP

		MSUNLOCK('TRB')
		dbSelectArea("TEMPSC2")
		dbskip()

	end
return


static Function fSaveParam()

	_Mv_par01 := MV_PAR01
	_Mv_par02 := MV_PAR02
	_Mv_par03 := MV_PAR03
	_Mv_par04 := MV_PAR04
	_Mv_par05 := MV_PAR05
	_Mv_par06 := MV_PAR06
	_Mv_par07 := MV_PAR07
	_Mv_par08 := MV_PAR08
	_Mv_par09 := MV_PAR09
	_Mv_par10 := MV_PAR10
	_Mv_par11 := MV_PAR11



return

static function fLoadParam()

	MV_PAR01 := _Mv_par01
	MV_PAR02 := _Mv_par02
	MV_PAR03 := _Mv_par03
	MV_PAR04 := _Mv_par04
	MV_PAR05 := _Mv_par05
	MV_PAR06 := _Mv_par06
	MV_PAR07 := _Mv_par07
	MV_PAR08 := _Mv_par08
	MV_PAR09 := _Mv_par09
	MV_PAR10 := _Mv_par10
	MV_PAR11 := _Mv_par11

return

static function EnviaOkea()
	Local _cOP,_cCodPro,_cDescPro,_cOperac,_cDescOp,_nAponta,_cFilial, _cDescPerda,  bLote,_dDataValid, _cLote
	Local _dDataIni, _dDataFim, _nPerda, _cOperador,  _cArmazem, _cQtdFalt, _cEncerra
	Local cMarca := oMark:Mark()
	Private oAlteraPedidos
	Private _cHoraTotal, _cHoraIni, _cHoraFim

	dbSelectArea("TRB")
	TRB->(DbGoTop())
	While !TRB->(EoF())
		IF(oMark:IsMark(cMarca))

			_cFilial := TRB->FILIAL
			_cOP := ALLTRIM(TRB->NUMOP)
			_cCodPro := ALLTRIM(TRB->CODPRO)
			_cDescPro := TRB->PRODUTO
			_cOperac := ALLTRIM(TRB->OPERACAO)
			_cDescOp := TRB->DESCRICAO
			_cEncerra := "P"
			bLote := .F.

			IF(Posicione('SB1',1,xFilial("SB1")+_cCodPro,"B1_RASTRO") == "L")
				bLote := .T.
				_cLote := _cOP
				_dDataValid := DDATABASE + 730
			ENDIF

			_nCiclo := TRB->CICLO
			_nCavidade := TRB->CAVID
			_cQtdFalt := TRB->PRODOPERA - TRB->PERDA
			_nPerda := 0
			_cMotPerda := SPACE(50)
			_cHoraTotal := "00:00"

			_nMinTot := (((TRB->CICLO / TRB->CAVID) * TRB->QUANT) /60)/60

			_dDataIni := dDataBase
			_dDataFim := dDataBase
			_cHoraIni := "00:00"
			_cHoraFim := "00:00"
			_cOperador := SPACE(10)
			_cArmazem := IIF(cFilAnt == "0201","M1","E2")
			_nAponta := 0

			U_CHECKULT(@_cOperac,_cCodPro,@_cEncerra,@_nAponta,@_nPerda,_COP, TRB->QUANT)

			IF(_cOperac == "01")

				_nAponta := TRB->QUANT		
				cQueryOpera := "SELECT SUM(H6_QTDPROD) H6_QTDPROD, SUM(H6_QTDPERD) H6_QTDPERD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = '"+_cOP+"' AND H6_OPERAC = '"+_cOperac+"' AND D_E_L_E_T_ <> '*' "

				If (Select("TEMPOPE") <> 0)
					dbSelectArea("TEMPOPE")
					dbCloseArea()
				Endif
				TCQuery cQueryOpera NEW ALIAS "TEMPOPE"

				If (Select("TEMPOPE") > 0)
					DBSELECTAREA("TEMPOPE")
					_nAponta := _nAponta - TEMPOPE->H6_QTDPROD	
				ENDIF		
			ELSE
				cQueryOpera := "SELECT SUM(H6_QTDPROD) H6_QTDPROD, SUM(H6_QTDPERD) H6_QTDPERD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = '"+_cOP+"' AND H6_OPERAC = '"+_cOperac+"' AND D_E_L_E_T_ <> '*' "

				If (Select("TEMPOPE") <> 0)
					dbSelectArea("TEMPOPE")
					dbCloseArea()
				Endif
				TCQuery cQueryOpera NEW ALIAS "TEMPOPE"

				If (Select("TEMPOPE") > 0)
					DBSELECTAREA("TEMPOPE")
					_nAponta := TEMPOPE->H6_QTDPROD	
				ENDIF		
				
				cQueryAnt := "SELECT SUM(H6_QTDPROD) H6_QTDPROD, SUM(H6_QTDPERD) H6_QTDPERD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = '"+_cOP+"' AND H6_OPERAC =  "
				cQueryAnt += "(select MAX(G2_OPERAC) from ( "
  				cQueryAnt += "select G2_OPERAC, "
    			cQueryAnt += "row_number() over (partition by G2_PRODUTO order by G2_OPERAC desc) as rn "
  				cQueryAnt += "from SG2010 SG2 where G2_PRODUTO = H6_PRODUTO AND D_E_L_E_T_ <> '*' AND G2_FILIAL = '02') "
				cQueryAnt += "where rn > 1) AND D_E_L_E_T_ <> '*' " 

				If (Select("TEMPANT") <> 0)
					dbSelectArea("TEMPANT")
					dbCloseArea()
				Endif
				TCQuery cQueryAnt NEW ALIAS "TEMPANT"

				DBSELECTAREA("TEMPANT")
				_nAponta := TEMPANT->H6_QTDPROD - _nAponta  

				_nAponta := _cQtdFalt
				
			ENDIF
		
			

			@ 000,000 To 425,560 Dialog oAlteraPedidos TITLE ("Apontamento de OP") //OemToAnsi("Altera Pedidos")

			@ 015,010 Say "Numero da OP:"
			@ 015,075 Get _cOP Picture "99999999999" Size 30,020 OBJECT oGCodOP

			@ 028,010 Say "Produto:"
			@ 028,075 Get _cCodPro Size 145, 100 OBJECT oGCodProd
			@ 041,075 Get _cDescPro Size 145, 100 OBJECT oGetProd

			@ 054,010 Say "Operação:"
			@ 054,075 Get _cOperac Size 45, 020 OBJECT oGetOperac
			@ 067,075 Get _cDescOp Size 145, 100 OBJECT oGtDescOp

			@ 054,140 Say "Horas Totais:"
			@ 054,205 Get _nMinTot Size 45, 020 OBJECT oGetMinTot

			@ 080,010 Say "Qtde Produzida:"
			@ 080,075 Get _nAponta Picture "99999999999" Size 45, 020 OBJECT oGtAponta

			@ 080,140 Say "Perda:"
			@ 080,205 Get _nPerda Picture "99999999999" Size 45, 020  OBJECT oGPerda


			@ 095,010 Say "Motivo Perda:"
			@ 095,075 Get _cMotPerda Size 45, 020 F3 "CYO003" OBJECT oGMotPerda
			@ 095,140 Get _cDescPerda Size 45, 020 OBJECT oGDescPerda
			//_cMotPerda

			_dDataIni := Date()
			_dDataFim := Date()

			@ 108,010 Say "Data Inicial:"
			@ 108,075 Get _dDataIni Picture "99/99/99" SIZE 45,020 OBJECT oGDtIni 

			@ 108,140 Say "Data Final:"
			@ 108,205 Get _dDataFim  Picture "99/99/99"  SIZE 45,020  OBJECT oGDtFim

			@ 121,010 Say "Hora Inicial:"
			@ 121,075 Get _cHoraIni  Picture "99:99"  SIZE 45,020 OBJECT oGHrIni

			@ 121,140 Say "Hora Final"
			@ 121,205 Get _cHoraFim Picture "99:99"   SIZE 45,020 OBJECT oGHrFim valid CalcHoras()

			@ 134,140 Say "Total de Horas"
			@ 134,205 Get _cHoraTotal Picture "99:99"   SIZE 45,020 OBJECT oGHrTotFim

			//121 - 134 - 147
			@ 134,010 Say "Operador"
			@ 134,075 Get _cOperador SIZE 045,020 OBJECT oGOpera

			@ 147,010 Say "Armazem"
			@ 147,075 Get _cArmazem SIZE 045,020 OBJECT oGArmazem

			@ 160,010 Say "Lote:"
			@ 160,075 Get _cLote Picture SIZE 45,020 OBJECT oGLote

			@ 160,140 Say "Validade:"
			@ 160,205 Get _dDataValid Picture "99/99/99"  SIZE 45,020  OBJECT oGValid


			oGArmazem:Disable()
			oGHrTotFim:Disable()
			oGDescPerda:Disable()
			oGCodOP:Disable()
			oGCodProd:Disable()
			oGetProd:Disable()
			oGetOperac:Disable()
			oGtDescOp:Disable()
			oGetMinTot:Disable()
			oGDtIni:Disable()
			oGDtFim:Disable()

			if(_cOperac != "01")
				oGPerda:Disable()
				oGMotPerda:Disable()
			endif


			if(!bLote)
				oGLote:Disable()
				oGValid:Disable()
			endif

			//Local _cOP,_cCodPro,_cDescPro,_cOperac,_cDescOp,_nAponta
			//Local _dDataIni, _dDataFim, _cHoraIni, _cHoraFim, _nPerda, _cOperador, _cArmazem

			@ 195,205 BMPBUTTON TYPE 01 ACTION U_ApontarOp(_cFilial,_cOP,_cCodPro,_cOperac,_dDataIni,_cHoraIni,_dDataFim,_cHoraFim,_cOperador,_nAponta,_nPerda,_cArmazem, _cEncerra, _cLote, _dDataValid, TRB->QUANT)
			//@ 195,205 BMPBUTTON TYPE 01 ACTION ApontarOp(_cFilial,_cOP,_cCodPro,_cOperac,_dDataIni,_cHoraIni,_dDataFim,_cHoraFim,_cOperador,_nAponta,_nPerda,_cArmazem)
			@ 195,235 BMPBUTTON TYPE 02 ACTION Close(oAlteraPedidos)

			Activate Dialog oAlteraPedidos Centered    // Start janela
		ENDIF
		TRB->(dbskip())
	ENDDO

	REFRESH(.F.)

return

static function CalcHoras
	Local cHora := ""
	Local cMinutos := ""
	Default cSepar := ":"

	nValor := -1

	nValor := SubHoras(_cHoraFim,_cHoraIni)

	If nValor < 0
		cHora := SubStr(Time(), 1, 5)
		cHora := StrTran(cHora, ':', cSepar)

		//Senão, transforma o valor numérico
	Else
		cHora := Alltrim(Transform(nValor, "@E 99.99"))

		//Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
		If Len(cHora) < 5
			cHora := Replicate('0', 5-Len(cHora)) + cHora
		EndIf

		//Fazendo tratamento para minutos
		cMinutos := SubStr(cHora, At(',', cHora)+1, 2)
		cMinutos := StrZero(Val(cMinutos), 2)

		//Atualiza a hora com os novos minutos
		cHora := SubStr(cHora, 1, At(',', cHora))+cMinutos

		//Atualizando o separador
		cHora := StrTran(cHora, ',', cSepar)
	EndIf

	_cHoraTotal := cHora

return


User function ApontarOp(_cFilial,_cOP,_cCodPro,_cOperac,_dDataIni,_cHoraIni,_dDataFim,_cHoraFim,_cOperador,_nAponta,_nPerda,_cArmazem,_cEncerra, _cLote, _dValid, nQuant)
	Local aVetor := {}
	Local dData
	Local nOpc   := 3 //Incluir
	Local cMsg := ""
	Private lMsErroAuto :=.F.
	Private lMsHelpAuto :=.T.

	//fSaveParam()

	U_CHECKULT(@_cOperac,_cCodPro,@_cEncerra,_nAponta,@_nPerda,_COP, nQuant)
 
	cFilBkp := ""
	IF(cFilAnt <> _cFilial)
		cEmpBkp := cEmpAnt
		cFilBkp := cFilAnt

		cFilAnt := _cFilial
		cNumEmp := cEmpAnt+_cFilial
		OpenFile(cNumEmp)
	ENDIF

	dData:=dDataBase
	aVetor := {;
		{"H6_OP"      ,_cOP ,NIL},;
		{"H6_PRODUTO" ,_cCodPro        ,NIL},;
		{"H6_OPERAC"  ,_cOperac           ,NIL},;
		{"H6_DTAPONT" ,dData          ,NIL},;
		{"H6_DATAINI" ,_dDataIni          ,NIL},;
		{"H6_HORAINI" ,_cHoraIni        ,NIL},;
		{"H6_DATAFIN" ,_dDataFim          ,NIL},;
		{"H6_HORAFIN" ,_cHoraFim        ,NIL},;
		{"H6_PT"      ,_cEncerra            ,NIL},;
		{"H6_OPERADO" ,_cOperador            ,NIL},;
		{"H6_LOCAL"   ,_cArmazem           ,NIL},;
		{"H6_QTDPERD"   ,_nPerda           ,NIL},;
		{"H6_LOTECTL"   ,_cLote           ,NIL},;
		{"H6_DTVALID"   ,_dValid           ,NIL},;
		{"H6_QTDPROD" ,_nAponta             ,NIL}}

	MSExecAuto({|x| mata681(x)},aVetor, nOpc)

	If lMsErroAuto
		IF(!isBlind())
			Mostraerro()
		ELSE
			cMsg := GetAutoGRLog() 
		ENDIF
		//fLoadParam()
	Else
		IF(!isBlind())
			MSGINFO("Operação apontada com sucesso.")
		ELSE
			cMsg := "Operação apontada com sucesso."
		ENDIF
		//fLoadParam()
		//Close(oAlteraPedidos)
		//REFRESH(.F.)
	EndIf



	IF(!EMPTY(cFilBkp))
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		cNumEmp := cEmpAnt + cFilAnt
		OpenFile(cNumEmp)
	ENDIF
	REFRESH(.F.)

return cMsg


user function CHECKULT(_cOperac,_cCodPro,_cEncerra, _nAponta,_nPerda,_cOP, nQuant)

	IF(_cOperac == "01")

		cQueryOpera := "SELECT SUM(H6_QTDPROD) H6_QTDPROD, SUM(H6_QTDPERD) H6_QTDPERD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = '"+_cOP+"' AND H6_OPERAC = '"+_cOperac+"' AND D_E_L_E_T_ <> '*' "

		If (Select("TEMPOPE") <> 0)
			dbSelectArea("TEMPOPE")
			dbCloseArea()
		Endif
		TCQuery cQueryOpera NEW ALIAS "TEMPOPE"

		If (Select("TEMPOPE") > 0)
			DBSELECTAREA("TEMPOPE")
			_nAponta := TEMPOPE->H6_QTDPROD	+ _nAponta
		ENDIF		

		cQryEncer := "select MAX(G2_OPERAC) ULTIMA from SG2010 SG2 where D_E_L_E_T_ <> '*' AND G2_PRODUTO = '"+_cCodPro+"' AND G2_FILIAL = '02' "

		If (Select("G2OPERA") <> 0)
			dbSelectArea("G2OPERA")
			dbCloseArea()
		Endif
		TCQuery cQryEncer NEW ALIAS "G2OPERA"


		DBSELECTAREA("G2OPERA")

		cLog := "PROGRAMA VEIM007 "+LF
		cLog += "OP: "+_COP+LF
		cLog += "APONTAMENTO: "+ALLTRIM(STR(_nAponta))+LF
		cLog += "PERDA: "+ALLTRIM(STR(_nPerda))+LF
		cLog += "ULTIMA OPERACAO: "+ALLTRIM(G2OPERA->ULTIMA)+LF
		cLog += "OPERACAO ATUAL: "+_cOperac+LF

		Memowrite("\LOGOP\log.txt",cLog)
		
		IF(_nAponta + _nPerda >= TRB->QUANT .AND. ALLTRIM(G2OPERA->ULTIMA) == _cOperac )
			_cEncerra := "T"
		ELSE
			_cEncerra := "P"
		ENDIF

	ELSE

		cQueryOpera := "SELECT SUM(H6_QTDPROD) H6_QTDPROD, SUM(H6_QTDPERD) H6_QTDPERD FROM "+RETSQLNAME("SH6")+" SH6 where H6_OP = '"+_cOP+"' AND H6_OPERAC = '"+_cOperac+"' AND D_E_L_E_T_ <> '*' "

		If (Select("TEMPOPE") <> 0)
			dbSelectArea("TEMPOPE")
			dbCloseArea()
		Endif
		TCQuery cQueryOpera NEW ALIAS "TEMPOPE"

		If (Select("TEMPOPE") > 0)
			DBSELECTAREA("TEMPOPE")
			_nAponta := TEMPOPE->H6_QTDPROD	+ _nAponta
		ENDIF		
		
		If (Select("G2OPERA") <> 0)
			dbSelectArea("G2OPERA")
			dbCloseArea()
		Endif

		cQryEncer := "select MAX(G2_OPERAC) ULTIMA from SG2010 SG2 where D_E_L_E_T_ <> '*' AND G2_PRODUTO = '"+_cCodPro+"' AND G2_FILIAL = '02' "

		TCQuery cQryEncer NEW ALIAS "G2OPERA"


		DBSELECTAREA("G2OPERA")


		IF(_nAponta + _nPerda >= nQuant .AND. ALLTRIM(G2OPERA->ULTIMA) == _cOperac )
			_cEncerra := "T"
		ELSE
			_cEncerra := "P"
		ENDIF

	ENDIF


return

/*
CICLO DA PEÇA * QTDE PRODUZIDA

CICLO DE 
60 SEGUNDOS 
1 PEÇA

10000 * 60 SEGUNDOS
TEMPO SUGERIDO


Filtros Telas OP (Testes)

Tipo – Operação 

PA – ESTOQUE (Carlos Melo)

PI – TODAS AS OPERACOES (Edson e Tiago)

PA – OPERACOES DIFERENTES DE ESTOQUE (Edson e Tiago)



Adicionar colunas -> SALDO e PRIMEIRA OPERACAO
Adicionar coluna -> PERDA

Na última operação permitir apontamento de PERDA contra Centro de Custo.


SALDO DA OPERAÇÃO
SALDO GERAL

DATA INICIAL
HORA INICIAL
DATA FINAL
HORA FINAL

MINUTOS TOTAL -> SOMENTE INDICADOR

OPERADOR
QUANTIDADE
PERDA (OBRIGATORIO NA PRIMEIRA OPERACAO)


QTDE da OP VS QTDE no GF


ESTORNO DE APONTAMENTO DE PRODUÇÃO

BLOQUEAR E LIBERAR APENAS PARA O EDSON.*/
